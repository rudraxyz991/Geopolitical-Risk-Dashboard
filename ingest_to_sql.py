import pandas as pd
from sqlalchemy import create_engine, text
import urllib

print("1. Reading your processed 10,000-row CSV locally...")
df = pd.read_csv('processed_events.csv')

# Configure database connection coordinates
SERVER_NAME = 'localhost\\SQLEXPRESS'  
DATABASE_NAME = 'SecurityIncidentsDB'

# Build a secure connection string using Windows Authentication
params = urllib.parse.quote_plus(
    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
    f"SERVER={SERVER_NAME};"
    f"DATABASE={DATABASE_NAME};"
    f"Trusted_Connection=yes;"
)
engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

print("2. Isolating and extracting unique structural dimensions...")
unique_countries = df[['country', 'region']].drop_duplicates().dropna()
unique_categories = df['nlp_category'].dropna().unique()

print("3. Populating dimension lookup tables...")
with engine.connect() as conn:
    for _, row in unique_countries.iterrows():
        conn.execute(
            text("""
                IF NOT EXISTS (SELECT 1 FROM dim_countries WHERE country_name = :c_name)
                INSERT INTO dim_countries (country_name, region_name) VALUES (:c_name, :r_name)
            """), 
            {"c_name": row['country'], "r_name": row['region']}
        )
    
    for cat in unique_categories:
        conn.execute(
            text("""
                IF NOT EXISTS (SELECT 1 FROM dim_categories WHERE category_name = :cat_name)
                INSERT INTO dim_categories (category_name) VALUES (:cat_name)
            """), 
            {"cat_name": cat}
        )
    conn.commit()

print("4. Mapping text variables to relational Foreign Keys...")
geo_map = pd.read_sql(text("SELECT country_id, country_name FROM dim_countries"), engine).set_index('country_name')['country_id'].to_dict()
cat_map = pd.read_sql(text("SELECT category_id, category_name FROM dim_categories"), engine).set_index('category_name')['category_id'].to_dict()

df['country_id'] = df['country'].map(geo_map)
df['category_id'] = df['nlp_category'].map(cat_map)

print("5. Standardizing Date Formats & Generating Surrogate Keys...")
# THE FIX: Tell Pandas that the Day comes first so it stops failing on dates like '30-07-2000'
df['date'] = pd.to_datetime(df['date'], errors='coerce', dayfirst=True)
df['date_clean'] = df['date'].dt.strftime('%Y-%m-%d')

# Rescue missing headlines before they crash the SQL insert
df['country'] = df['country'].fillna("Unknown Region")
df['headline'] = df['headline'].fillna("Security Incident in " + df['country'].astype(str))

# Generate clean, 100% unique sequence IDs for every row
df['event_id_clean'] = ['EVT-' + str(i).zfill(5) for i in range(len(df))]

print("6. Aligning DataFrame payload with central SQL Fact Schema...")
fact_df = df[[
    'event_id_clean', 'date_clean', 'country_id', 'category_id', 
    'headline', 'severity_score', 'source', 'raw_text'
]].copy()

# Rename columns to match database DDL targets exactly
fact_df.columns = ['event_id', 'event_date', 'country_id', 'category_id', 'headline', 'severity_score', 'source_name', 'raw_text']

# Drop ONLY rows that are completely unrecoverable
fact_df = fact_df.dropna(subset=['event_date', 'country_id', 'category_id'])

print("6.5 Flushing old partial data...")
# Wipe the database clean so we can load fresh
with engine.connect() as conn:
    conn.execute(text("DELETE FROM fact_events"))
    conn.commit()

print("7. Executing high-speed bulk insert to fact_events...")
fact_df.to_sql('fact_events', con=engine, if_exists='append', index=False, chunksize=1000)

print("🏆 Ingestion pipeline successful! Records fully converted and structured inside SQL Server.")
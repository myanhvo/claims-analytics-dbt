import duckdb

# Must match the dbt database file, which lives in the dbt project folder
DB_PATH = "claims_analytics/dev.duckdb"
CSV_PATH = "claims_analytics/data/raw/DE1_0_2008_Beneficiary_Summary_File_Sample_1.csv"

con = duckdb.connect(DB_PATH)

# Keep raw data in its own "raw" schema, separate from dbt's models
con.execute("CREATE SCHEMA IF NOT EXISTS raw")

# Load every column as text; the staging model will handle types
con.execute(f"""
    CREATE OR REPLACE TABLE raw.beneficiary_summary_2008 AS
    SELECT * FROM read_csv('{CSV_PATH}', header = true, all_varchar = true)
""")

count = con.execute("SELECT COUNT(*) FROM raw.beneficiary_summary_2008").fetchone()[0]
print(f"Loaded {count:,} rows into raw.beneficiary_summary_2008")

con.close()
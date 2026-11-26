import duckdb

# Must match the dbt database file, which lives in the dbt project folder
DB_PATH = "claims_analytics/dev.duckdb"
RAW_DIR = "claims_analytics/data/raw"


files_to_load = {
    "raw.beneficiary_summary_2008": f"{RAW_DIR}/DE1_0_2008_Beneficiary_Summary_File_Sample_1.csv",
    "raw.inpatient_claim": f"{RAW_DIR}/DE1_0_2008_to_2010_Inpatient_Claims_Sample_1.csv"
}

con = duckdb.connect(DB_PATH)

# Keep raw data in its own "raw" schema, separate from dbt's models
con.execute("CREATE SCHEMA IF NOT EXISTS raw")

for table, path in files_to_load.items():
    # Load every column as text; the staging model will handle types
    con.execute(f"""
        CREATE OR REPLACE TABLE {table} AS
        SELECT * FROM read_csv('{path}', header = true, all_varchar = true)
    """)

    count = con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
    print(f"Loaded {count:,} rows into {table}")

con.close()
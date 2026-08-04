import pandas as pd 
from sqlalchemy import create_engine, text, inspect
from sqlalchemy.engine import Engine
from dotenv import load_dotenv
import os 

load_dotenv(dotenv_path=".env")

def credentials() -> Engine:
    
    user = os.getenv("USER_DB")
    password = os.getenv("PASSWORD")
    host = os.getenv("HOST")
    port = os.getenv("PORT")
    dbname = os.getenv("DBNAME")
    
    if not all ([user, password, host, port, dbname]):
        raise ValueError("Variaveis não definidas no .env")
    
    url_banco = f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{dbname}"
    engine = create_engine(url_banco, pool_pre_ping=True, future=True)
    return engine 

def load(df: pd.DataFrame, table_name: str, schema_name: str, engine: Engine) -> None:
    
    try:
        
        with engine.begin() as con:
            con.execute(text(f"CREATE SCHEMA IF NOT EXISTS {schema_name}"))
        
        inspector = inspect(engine)
        table_exists = inspector.has_table(table_name, schema_name)
        
        if table_exists:
            
            with engine.begin() as con:
                con.execute(text(f"TRUNCATE TABLE {schema_name}.{table_name} CASCADE"))
    
        df.to_sql(name=table_name, schema=schema_name, con=engine, index=False, chunksize=5000, if_exists="append", method="multi")
        
    except Exception as e:
        raise RuntimeError(f"Falha ao inserir dados na tabela {table_name}: {e}")
        
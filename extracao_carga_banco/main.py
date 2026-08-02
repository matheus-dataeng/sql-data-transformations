from extract_arquivos import extract
from load import credentials, load

def main():
    
    dfs = extract()
    engine = credentials()
    
    for variavel, df in dfs.items():
        
        table_name = variavel.replace("_CSV", "").lower()
        
        load(df=df, table_name=table_name, schema_name="raw", engine=engine)

if __name__ == "__main__":
    main()
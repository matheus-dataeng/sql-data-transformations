import pandas as pd 
import os
from dotenv import load_dotenv

load_dotenv(dotenv_path=".env")

def extract() -> dict[str, pd.DataFrame]:
    
    try: 
        arquivos = ["CLIENTES_CSV", "ENTREGAS_CSV", "PAGAMENTOS_CSV", "PEDIDOS_CSV", "PRODUTOS_CSV"]
        
        dfs = {}
        
        for csv in arquivos:
            
            arquivos_csv = os.getenv(csv)
            
            if not arquivos_csv:
                raise ValueError(f"Variavel {csv} não definidas no arquivo .env")
            
            dfs[csv] = pd.read_csv(arquivos_csv, encoding="utf-8", low_memory= False, delimiter=',')
            
        return dfs
    
    except Exception as e:
        raise ValueError(f"Erro ao extrair arquivos: {e}")
    
     
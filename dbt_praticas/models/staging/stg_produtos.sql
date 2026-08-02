WITH produtos_padronizados AS (
	SELECT
		CAST(produto_id AS NUMERIC) AS produto_id,
		INITCAP(TRIM(nome)) AS nome,
		CASE 
			WHEN LOWER(TRIM(categoria)) IN ('eletronicos', 'eletrônicos') THEN 'Eletrônicos'
			WHEN LOWER(TRIM(categoria)) = 'casa' THEN 'Casa'
			ELSE 'Outros'
		END AS categoria,
		CAST(preco AS NUMERIC) AS preco,
		CASE
			WHEN peso IN ('0.5kg', '500g') THEN 500
			WHEN peso IN ('1kg', '1000') THEN 1000
			ELSE NULL
		END AS peso_gramas
	FROM {{source('raw', 'produtos')}}
	WHERE preco > 0
)

SELECT 
	produto_id,
	nome,
	categoria,
	preco,
	peso_gramas
FROM produtos_padronizados
WITH ranking_produto AS (
	SELECT 
		produto_id,
		nome_produto,
		categoria,
		ROW_NUMBER() OVER(
			PARTITION BY produto_id
			ORDER BY produto_id
		) AS ranking_produto
	FROM {{ref ('int_pedidos')}}
),

dim_produtos AS (
	SELECT
		produto_id,
		nome_produto,
		categoria
	FROM ranking_produto
	WHERE ranking_produto = 1 AND produto_id IS NOT NULL
)

SELECT  
	produto_id,
	nome_produto,
	categoria
FROM dim_produtos


WITH entregas_padronizadas AS(
	SELECT
		CAST(entrega_id AS NUMERIC) AS entrega_id, 
		CAST(pedido_id AS NUMERIC) AS pedido_id,
		TRIM(transportadora) AS transportadora,
		CASE
			WHEN data_envio LIKE '%/%' THEN TO_DATE(data_envio, 'DD/MM/YYYY')
			ELSE TO_DATE(data_envio, 'YYYY-MM-DD')
		END AS data_envio,
		CASE
			WHEN data_entrega LIKE '%/%' THEN TO_DATE(data_entrega, 'DD/MM/YYYY')
			ELSE TO_DATE(data_entrega, 'YYYY-MM-DD')
		END AS data_entrega,
		CAST(frete AS NUMERIC) AS frete
	FROM {{source ('raw', 'entregas')}}
	WHERE frete >= 0
)

SELECT 
	entrega_id,
	pedido_id,
	transportadora,
	data_envio,
	data_entrega,
	frete
FROM entregas_padronizadas
WITH pedidos_padronizados AS (
	SELECT 
		CAST(pedido_id AS NUMERIC) AS pedido_id,
		CAST(cliente_id AS NUMERIC) AS cliente_id,
		CAST(produto_id AS NUMERIC) AS produto_id,
		CAST(quantidade AS NUMERIC) AS quantidade,
		CAST(valor_unitario AS NUMERIC) AS valor_unitario,
		CAST(desconto AS NUMERIC) AS desconto,
		CASE
			WHEN data_pedido LIKE '%/%' THEN TO_DATE(data_pedido, 'DD/MM/YYYY')
			ELSE TO_DATE(data_pedido, 'YYYY-MM-DD')
		END AS data_pedido,
		TRIM(status) AS status
	FROM {{source('raw', 'pedidos')}}
)

SELECT 
	pedido_id,
	cliente_id,
	produto_id,
	quantidade,
	valor_unitario,
	desconto,
	data_pedido,
	status
FROM pedidos_padronizados

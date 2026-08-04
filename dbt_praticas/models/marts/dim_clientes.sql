WITH cliente_unico AS (
	SELECT
		cliente_id,
		nome_cliente,
		cidade,
		estado,
		ROW_NUMBER () OVER(
			PARTITION BY cliente_id
			ORDER BY data_pedido DESC
		) AS ranking_cliente 
	FROM {{ref('int_pedidos')}}
	
),

dim_clientes AS (
	SELECT
		cliente_id,
		nome_cliente,
		cidade,
		estado,
		ranking_cliente
	FROM cliente_unico
	WHERE ranking_cliente = 1
)

SELECT
	cliente_id,
	nome_cliente,
	cidade,
	estado
FROM dim_clientes

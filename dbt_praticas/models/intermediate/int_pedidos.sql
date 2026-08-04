WITH clientes AS (
	SELECT
		cliente_id,
		nome,
		email,
		telefone,
		cidade,
		estado,
		cep,
		data_cadastro
	FROM {{ref ('stg_clientes')}}
	
),

produtos AS (
	SELECT
		produto_id,
		nome,
		categoria,
		preco,
		peso_gramas
	FROM {{ref ('stg_produtos')}}
),

entregas AS (
	SELECT
		entrega_id,
		pedido_id,
		transportadora,
		data_envio,
		data_entrega,
		frete
	FROM {{ref ('stg_entregas')}}
),

pagamentos AS(
	SELECT
		pagamento_id,
		pedido_id,
		forma_pagamento,
		valor_pago,
		status_pagamento
	FROM {{ref ('stg_pagamentos')}}
),

pedidos AS(
	SELECT
		pedido_id,
		cliente_id,
		produto_id,
		quantidade,
		valor_unitario,
		desconto,
		data_pedido,
		status
	FROM {{ref ('stg_pedidos')}} 
		
),

int_pedidos AS(
	SELECT
		ped.pedido_id,
		ped.cliente_id,
		cli.nome AS nome_cliente,
		cli.cidade,
		cli.estado,
		pro.produto_id,
		pro.nome AS nome_produto,
		pro.categoria,
		ped.quantidade,
		ped.valor_unitario,
		ped.desconto,
		(ped.valor_unitario * ped.quantidade) - ped.desconto AS valor_total,
		pag.forma_pagamento,
		pag.valor_pago,
		pag.status_pagamento,
		ent.transportadora,
		ent.frete,
		ent.data_entrega - ent.data_envio AS prazo_entrega_dias,
		ped.status,
		ped.data_pedido,
		ent.data_envio,
		ent.data_entrega
	FROM pedidos AS ped
	LEFT JOIN clientes AS cli
		ON ped.cliente_id = cli.cliente_id
	LEFT JOIN produtos AS pro
		ON ped.produto_id = pro.produto_id
	LEFT JOIN pagamentos AS pag
		ON ped.pedido_id = pag.pedido_id
	LEFT JOIN entregas AS ent
		ON ped.pedido_id = ent.pedido_id
		
)

SELECT
    pedido_id,
    cliente_id,
    nome_cliente,
    cidade,
    estado,
    produto_id,
    nome_produto,
    categoria,
    quantidade,
    valor_unitario,
    desconto,
    valor_total,
    forma_pagamento,
    valor_pago,
    status_pagamento,
    transportadora,
    frete,
    prazo_entrega_dias,
    status,
    data_pedido,
    data_envio,
    data_entrega
FROM int_pedidos
SELECT * FROM {{ ref('int_pedidos') }}
WHERE prazo_entrega_dias < 0
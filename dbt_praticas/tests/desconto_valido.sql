SELECT * FROM {{ref('int_pedidos')}}
WHERE desconto > (valor_unitario * quantidade)
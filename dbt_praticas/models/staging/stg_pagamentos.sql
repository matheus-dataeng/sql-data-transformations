WITH pagamentos_padronizados AS (
	SELECT 
		pagamento_id,
		pedido_id,
		TRIM(forma_pagamento) AS forma_pagamento,
		valor_pago,
		TRIM(status_pagamento) AS status_pagamento
	FROM {{source('raw', 'pagamentos')}}
)

SELECT 
	pagamento_id,
	pedido_id,
	forma_pagamento,
	valor_pago,
	status_pagamento
FROM pagamentos_padronizados
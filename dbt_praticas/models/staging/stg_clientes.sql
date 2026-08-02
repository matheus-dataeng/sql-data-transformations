WITH dados_padronizados AS (
	SELECT
		CAST(cliente_id AS NUMERIC) AS cliente_id,
		TRIM(nome) AS nome,
		TRIM(email) AS email,
		REGEXP_REPLACE(telefone, '[^0-9]', '', 'g') AS telefone,
		INITCAP(TRIM(LOWER(cidade))) AS cidade,
		'Bahia' AS estado,
		REGEXP_REPLACE(cep, '[^0-9]', '', 'g') AS cep,
		CASE 
			WHEN data_cadastro LIKE '%/%' THEN TO_DATE(data_cadastro, 'DD/MM/YYYY')
			ELSE TO_DATE(data_cadastro, 'YYYY-MM-DD')
			END AS data_cadastro
	FROM {{source('raw', 'clientes')}}
),

clientes AS (
	SELECT
		cliente_id,
		nome,
		email,
		telefone,
		cidade,
		estado,
		cep,
		data_cadastro,
		ROW_NUMBER() OVER(
			PARTITION BY cliente_id
			ORDER BY data_cadastro DESC
		) AS rn
	FROM dados_padronizados
)

SELECT
    cliente_id,
    nome,
	email,
    telefone,
    cidade,
    estado,
    cep,
    data_cadastro
FROM clientes
WHERE rn = 1

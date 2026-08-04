# Staging

## Papel desta camada

A staging existe para responder a uma pergunta simples: **"como esses dados brutos deveriam se parecer, sem que eu precise decidir nada sobre o negócio ainda?"**

Aqui não existe regra de negócio. A staging é um espelho fiel da fonte, só que padronizado. Se alguém perguntar "de onde vem essa coluna?", a resposta em staging deve ser sempre "veio direto da fonte, só limpei o nome/tipo".

## O que É feito aqui

- renomear colunas para um padrão consistente (ex: `snake_case`, nomes descritivos);
- ajustar tipos (datas como `DATE`/`TIMESTAMP`, valores numéricos como `NUMERIC`, não `TEXT`);
- correções pontuais de qualidade que não envolvem interpretação de negócio (ex: `TRIM()` em strings, padronizar case);
- um modelo de staging por fonte/tabela bruta — relação 1:1.

## O que NÃO é feito aqui

- nenhum `JOIN` entre entidades diferentes;
- nenhum cálculo derivado (totais, médias, prazos);
- nenhuma deduplicação de negócio (isso é decisão de modelagem, não de padronização);
- nenhum tratamento de NULL que "invente" um valor.

Se você está tentado a resolver um problema de negócio dentro de um `stg_*`, é sinal de que essa lógica pertence à camada `intermediate`.

## Modelos

| Modelo | Fonte | Observação |
|---|---|---|
| `stg_clientes` | `clientes.csv` | Contém duplicatas propositais — não deduplicado aqui |
| `stg_produtos` | `produtos.csv` | Idem |
| `stg_pedidos` | `pedidos.csv` | Pode conter `cliente_id`/`produto_id` sem correspondência |
| `stg_pagamentos` | `pagamentos.csv` | Um pedido pode ter múltiplos pagamentos |
| `stg_entregas` | `entregas.csv` | Um pedido pode ter múltiplas entregas |

## Por que manter os problemas de dados aqui?

Porque a staging deve representar **o dado como ele chega**, com o mínimo de padronização técnica. Esconder duplicatas ou registros órfãos nesta camada tira a visibilidade do problema, e problemas de qualidade de dados devem ser tratados de forma explícita e documentada em camadas posteriores (ou via testes do dbt), não silenciados aqui.

## Exemplo de padrão usado

```sql
WITH source AS (
    SELECT * FROM {{ source('ecommerce', 'clientes') }}
),

renamed AS (
    SELECT
        id_cliente AS cliente_id,
        nome_cliente AS nome,
        email_cliente AS email,
        data_cadastro::DATE AS data_cadastro
    FROM source
)

SELECT * FROM renamed
```

Simples, previsível e fácil de auditar, essa é a meta da staging.

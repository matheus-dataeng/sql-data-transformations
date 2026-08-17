# Intermediate

## Papel desta camada

É aqui que a **regra de negócio** mora. Se a staging responde "como os dados se parecem", a intermediate responde **"o que esses dados significam quando combinados"**.

Esta é a camada mais importante do repositório do ponto de vista de aprendizado: é onde SQL deixa de ser "consulta" e vira "transformação".

## Modelo: `int_pedidos`

Um único modelo, que concentra toda a lógica de transformação do pipeline:

- `LEFT JOIN` entre `stg_pedidos`, `stg_clientes`, `stg_produtos`, `stg_pagamentos` e `stg_entregas`;
- cálculo de `valor_total` (quantidade × preço, considerando os pagamentos associados);
- cálculo de `prazo_entrega_dias` (diferença entre data do pedido e data da entrega).

## Por que `LEFT JOIN` e não `INNER JOIN`?

Porque perder pedidos por causa de uma chave sem correspondência (cliente ou produto órfão) esconderia um problema real de qualidade de dados. Com `LEFT JOIN`, o pedido continua existindo na tabela, só que com campos `NULL` onde a informação não pôde ser resolvida, o problema fica visível, em vez de silenciosamente descartado.

## Testes implementados

Na camada intermediate, os testes deixam de verificar apenas a estrutura dos dados e passam a validar **regras de negócio**.

Neste projeto foram utilizados testes `accepted_values` para garantir que determinadas colunas contenham apenas valores previstos pelo domínio da aplicação, como:

- `status`;
- `status_pagamento`;
- `forma_pagamento`.

Diferentemente da staging, não foram aplicados testes como `not_null` em colunas provenientes dos `LEFT JOIN`s (`cliente_id` e `produto_id`), pois valores `NULL` são esperados quando existem registros órfãos na origem. Forçar esses testes faria o pipeline falhar por um comportamento que foi preservado de forma intencional para evidenciar problemas de qualidade dos dados.

## Por que existem tantos valores `NULL` aqui, e por que isso é esperado

Os CSVs foram construídos propositalmente com inconsistências (chaves órfãs, pagamentos ausentes, entregas ausentes). Ao fazer `LEFT JOIN`, essas inconsistências se manifestam como `NULL`.

**A intermediate não trata esses `NULL`s.** Essa é uma decisão de design, não uma omissão:

- tratar/inventar valores aqui seria mascarar um problema de origem;
- a intermediate deve representar **os dados disponíveis**, não uma versão idealizada deles;
- decisões sobre como lidar com esses `NULL`s (excluir, sinalizar, imputar) são decisões de **consumo**, cabem à camada de marts, a um dashboard, ou a uma regra explícita e documentada, nunca a um `COALESCE` silencioso no meio do pipeline.

## Por que concentrar tudo em um único modelo?

Para deixar claro, para quem está aprendendo, onde a complexidade do pipeline realmente mora. Em um projeto maior, essa lógica normalmente seria quebrada em múltiplos modelos intermediários (um por junção ou por domínio), mas aqui a decisão foi manter tudo em `int_pedidos` para que a jornada dos dados fique fácil de seguir em um único arquivo.

## Estrutura típica com CTEs

```sql
with pedidos AS (
    SELECT * FROM {{ ref('stg_pedidos') }}
),

clientes AS (
    SELECT * FROM {{ ref('stg_clientes') }}
),

produtos AS (
    SELECT * FROM {{ ref('stg_produtos') }}
),

pagamentos AS (
    SELECT * FROM {{ ref('stg_pagamentos') }}
),

entregas AS (
    SELECT * FROM {{ ref('stg_entregas') }}
),

joined AS (
    SELECT
        pedidos.pedido_id,
        clientes.cliente_id,
        produtos.produto_id,
        pagamentos.valor_pago,
        entregas.data_entrega,
        pedidos.data_pedido
    from pedidos
    LEFT JOIN clientes ON pedidos.cliente_id  = clientes.cliente_id
    LEFT JOIN produtos ON pedidos.produto_id  = produtos.produto_id
    LEFT JOIN pagamentos ON pedidos.pedido_id  = pagamentos.pedido_id
    LEFT JOIN entregas ON pedidos.pedido_id  = entregas.pedido_id
),

final AS (
    SELECT
        *,
        valor_pago AS valor_total,
        (data_entrega - data_pedido) AS prazo_entrega_dias
    FROM joined
)

SELECT * FROM final
```

Cada CTE representa um passo lógico e nomeado, isso é abordado em detalhe em [`conceitos_sql/readme_conceitos.md`](../../conceitos_sql/readme_conceitos.md).

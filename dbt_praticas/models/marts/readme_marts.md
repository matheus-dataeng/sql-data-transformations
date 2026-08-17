# Marts

## Papel desta camada

A marts é a camada de **consumo**: tabelas prontas para serem usadas por análise, BI ou qualquer outro tipo de processo. Aqui a lógica pesada já foi resolvida na camada anterior, o trabalho da marts é **modelar**, não transformar.

## Modelo dimensional

| Modelo | Tipo | Fonte |
|---|---|---|
| `dim_clientes` | Dimensão | `int_pedidos` |
| `dim_produtos` | Dimensão | `int_pedidos` |
| `fct_pedidos` | Fato | `int_pedidos` |

## `dim_clientes` e `dim_produtos`

Como as fontes contêm registros duplicados propositalmente, ambas as dimensões usam `ROW_NUMBER()` para garantir **um único registro por chave de negócio**.

```sql
WITH ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY produto_id
            ORDER BY produto_id
        ) AS rn
    FROM {{ ref('stg_produtos') }}
)

SELECT * FROM ranked
WHERE rn = 1
```

### Por que `ORDER BY produto_id` e não uma coluna de "versão mais recente"?

Porque essa coluna não existe na fonte. Em um cenário real, o ideal seria deduplicar por algo como `updated_at desc` para manter o registro mais recente. Como esse dado não existe aqui, `ORDER BY produto_id` foi escolhido **apenas para tornar o resultado determinístico** — ou seja, para garantir que rodar o modelo duas vezes sempre produza o mesmo resultado. Isso é uma limitação assumida e documentada, não uma decisão "correta" de negócio.

## `fct_pedidos`

Este modelo **reaproveita `int_pedidos` sem alterações**:

- sem novos cálculos;
- sem novos `JOIN`s;
- sem deduplicação.

### Por que não fazer nada de novo aqui?

Porque toda a lógica de transformação já foi resolvida na camada `intermediate`. Repetir joins ou cálculos na marts violaria a responsabilidade de cada camada (regra de negócio mora em `intermediate`, não em `marts`) e criaria duas fontes de verdade para a mesma lógica. A marts apenas expõe o resultado final para consumo — se precisar de outra granularidade ou agregação, isso deveria virar um novo modelo (`fct_pedidos_diario`, por exemplo), não uma alteração dentro deste.

## Testes implementados

Por representar a camada de consumo do pipeline, a marts concentra testes voltados para a consistência do modelo dimensional.

Neste projeto foram utilizados:

- `unique` e `not_null` nas chaves primárias das dimensões (`dim_clientes` e `dim_produtos`), garantindo que o processo de deduplicação com `ROW_NUMBER()` produziu exatamente um registro por entidade;
- `relationships` entre `fct_pedidos` e as dimensões, verificando que todas as chaves presentes na tabela fato possuem correspondência nas respectivas dimensões.

Enquanto a camada intermediate valida regras de negócio, a marts valida a integridade do modelo analítico que será consumido por dashboards, análises e outras aplicações.

# SQL para Transformação de Dados com dbt

Repositório de estudo focado em **SQL aplicado à transformação de dados**, simulando um fluxo de Engenharia de Dados semelhante ao que existe em situações reais, da consulta SQL pura até a modelagem em **dbt**.

> Este projeto **não ensina SQL básico**. Ele mostra como o SQL é usado na etapa de transformação (ELT) dentro de um pipeline analítico: organização em camadas, uso de CTEs, `ref()` no dbt e as decisões de design por trás de cada modelo.

## Por que este repositório existe

A maioria dos materiais de SQL para iniciantes ensina `SELECT`, `JOIN` e `GROUP BY` isolados, sem mostrar **onde** essas queries se encaixam em um pipeline de dados real. Este projeto tenta preencher essa lacuna: parte de dados brutos e propositalmente "sujos", e mostra a transformação camada por camada até chegar em tabelas prontas para análise.

## Sobre os dados

Todos os dados são **100% fictícios**, gerados especificamente para fins praticos, simulando um e-commerce (clientes, produtos, pedidos, pagamentos e entregas).

Os CSVs foram construídos **de propósito** com problemas comuns em bases reais:

| Problema | Onde aparece |
|---|---|
| Registros duplicados | clientes, produtos |
| Chaves sem correspondência | pedidos → clientes/produtos |
| Valores nulos | várias tabelas |
| Relacionamentos inconsistentes | pedidos ↔ entregas |
| Múltiplos pagamentos para um mesmo pedido | pagamentos |
| Múltiplas entregas para um mesmo pedido | entregas |

**O objetivo nunca foi ter uma base perfeita.** Dados perfeitos não ensinam nada sobre engenharia de dados, o trabalho real está em lidar com essas inconsistências de forma consciente e documentada.

## Arquitetura em camadas

```
seeds/ (CSVs brutos)
   │
   ▼
staging/      → padronização (sem regra de negócio)
   │
   ▼
intermediate/ → toda a lógica de transformação e joins
   │
   ▼
marts/        → modelo dimensional pronto para consumo
```

| Camada | Responsabilidade | Modelos |
|---|---|---|
| [`staging`](models/staging/readme_staging.md) | Renomear colunas, ajustar tipos, padronizar | `stg_clientes`, `stg_produtos`, `stg_pedidos`, `stg_pagamentos`, `stg_entregas` |
| [`intermediate`](models/intermediate/readme_intermediate.md) | Joins, cálculos, regra de negócio | `int_pedidos` |
| [`marts`](models/marts/readme_marts.md) | Modelagem final | `dim_clientes`, `dim_produtos`, `fct_pedidos` |

Cada camada tem seu próprio README explicando **o porquê** das decisões tomadas, não só o que foi feito.

## Conceitos reforçados

Veja [`readme_conceitos.md`](dbt_praticas/readme_conceitos.md) para uma explicação aprofundada de:

- separação de responsabilidades por camada;
- por que usar CTEs em vez de subqueries aninhadas;
- por que não resolver tudo em uma única query gigante;
- como pensar em SQL para transformação (e não só para consulta);
- como o dbt organiza esse fluxo com `ref()` e materializações.

## Stack

- **SQL** (validação inicial da lógica)
- **dbt** (`ref()`, `models/staging`, `models/intermediate`, `models/marts`)
- CSVs fictícios como fonte (`seeds`)

## Como navegar neste repositório

1. Comece pelo [`readme_conceitos.md`](conceitos_sql/readme_conceitos.md) se você é novo em transformação de dados.
2. Leia os READMEs de cada camada na ordem: `staging` → `intermediate` → `marts`.
3. Compare os modelos `.sql` com a explicação do README correspondente.
4. Rode `dbt run` e `dbt test` localmente para ver o pipeline completo.

## Status

Este repositório evolui continuamente à medida que novos modelos e conceitos são estudados, novas transformações, testes e exemplos serão adicionados ao longo do tempo.

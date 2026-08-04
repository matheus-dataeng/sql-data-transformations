# Conceitos fundamentais

Este documento explica o "porquê" por trás das decisões de arquitetura do repositório. A ideia é que, depois de ler isso, você consiga justificar cada escolha de design — não só reproduzi-la.

## 1. Por que separar em camadas (staging → intermediate → marts)?

Porque cada camada tem uma **única responsabilidade**, e isso traz benefícios concretos:

- **Rastreabilidade**: se um número está errado em `fct_pedidos`, você sabe que o problema está na lógica de `intermediate` (não pode estar em `staging`, que não faz cálculo, nem em `marts`, que não faz cálculo).
- **Reuso**: `stg_clientes` pode ser usado por múltiplos modelos intermediate sem duplicar a lógica de padronização.
- **Testabilidade**: dá pra testar cada camada isoladamente (ex: testar que `stg_pedidos` não tem tipos errados, sem se preocupar ainda com joins).
- **Comunicação em equipe**: qualquer pessoa que conheça essa convenção de camadas entende a estrutura do projeto sem precisar de explicação — é um padrão da indústria (Medallion architecture / dbt best practices).

Misturar tudo em uma única query gigante funciona para um script pontual, mas não escala: fica impossível saber onde uma regra de negócio foi aplicada, difícil de testar em partes, e difícil de dar manutenção quando o pipeline cresce.

## 2. Por que usar CTEs em vez de subqueries aninhadas?

Uma CTE (`WITH nome AS (...)`) dá **nome** a um passo lógico da transformação. Compare:

```sql
-- Sem CTE: difícil de ler, difícil de debugar
select * from (
    select * from (
        select * from pedidos where status = 'aprovado'
    ) a where valor > 100
) b
```

```sql
-- Com CTE: cada passo é nomeado e pode ser testado isoladamente
WITH aprovados AS (
    SELECT * from pedidos WHERE status = 'aprovado'
),

acima_de_100 AS (
    SELECT * FROM aprovados WHERE valor > 100
)
SELECT * FROM acima_de_100
```

CTEs tornam a query **legível de cima para baixo**, como um pipeline: cada bloco representa um passo, e você pode rodar qualquer CTE isoladamente (`SELECT * FROM aprovados`) para debugar sem reescrever a query inteira.

## 3. Por que não resolver tudo em uma única query?

Porque uma query monolítica mistura responsabilidades: padronização, joins, cálculo e modelagem final, tudo junto. Isso é exatamente o que a separação em camadas evita. Além disso, no dbt, cada modelo é materializado de forma independente — o que permite rodar, testar e agendar cada etapa separadamente, e reaproveitar modelos intermediários em múltiplos marts sem repetir lógica.

## 4. Como pensar em SQL para transformação de dados (e não só para consulta)

A diferença central: uma consulta responde a uma pergunta pontual ("quantos pedidos tivemos em julho?"). Uma transformação **produz uma tabela** que outras pessoas/processos vão consumir depois.

Isso muda a forma de escrever SQL:

- pense em **contratos de dados**: que colunas essa tabela vai expor, com quais tipos e granularidade?
- pense em **idempotência**: rodar o modelo duas vezes deve produzir o mesmo resultado (por isso o `ORDER BY produto_id` determinístico em `dim_produtos`);
- pense em **onde a lógica deveria morar**: cada decisão de negócio tem uma camada correta;
- documente **decisões, não só código**: por que um `LEFT JOIN` e não `INNER`? Por que não tratar os `NULL`s aqui? Essas decisões são tão importantes quanto a query em si.

## 5. Como o dbt organiza esse fluxo

O dbt formaliza exatamente essa separação em camadas:

- **`ref()`**: em vez de referenciar tabelas físicas (`SELECT * FROM staging.stg_clientes`), você usa `{{ ref('stg_clientes') }}`. O dbt resolve automaticamente o nome real da tabela/view e constrói o **grafo de dependências** entre modelos (o "DAG").
- **Organização em `models/`**: a estrutura de pastas (`staging/`, `intermediate/`, `marts/`) espelha a arquitetura lógica do pipeline — quem abre o repositório entende a arquitetura só olhando a árvore de arquivos.
- **Materializações**: o dbt decide (ou você configura) se cada modelo vira `view` ou `table`, sem que você precise escrever `CREATE TABLE` manualmente.
- **Testes e documentação como parte do fluxo**: `schema.yml` permite declarar testes (`not_null`, `unique`, `relationships`) e documentação lado a lado com o SQL, tornando a qualidade de dados parte do pipeline, não uma etapa manual separada.

Em resumo: o dbt não muda o SQL em si, ele dá estrutura, rastreabilidade e testabilidade ao que você já construiu manualmente em SQL puro.

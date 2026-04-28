# Relato de Uso de IA

## Ferramentas Utilizadas
- Gemini (Google)

## Partes do projeto com auxílio de IA
1. **Definição de Estrutura:** Criação do schema inicial das tabelas e relacionamentos.
2. **Geração de Massa de Dados:** Desenvolvimento de scripts para população de tabelas com alto volume (1 milhão de registros).
3. **Melhoria do Particionamento:** Migração de dados de tabelas legadas para a nova estrutura particionada.
4. **Otimização de Performance:** Configuração e personalização dos parâmetros de Autovacuum.
5. **Manutenção e Saúde do Banco:** Criação de queries para monitoramento contínuo da saúde do banco de dados.
6. **Documentação Técnica:** Estruturação e escrita dos arquivos `README.md` e `RELATO_IA.md`.

## Prompts Representativos

### 1. Criação do Schema
> "Com base na questão acima, gere o schema padrão para que eu possa trabalhar em cima dele."

### 2. Criação do Seed de População
> "Crie um script para gerar dados falsos para as tabelas criadas. Segue o schema: [contexto do schema]."

### 3. Migração após Particionamento
> "Após criar meu particionamento de rede, como migro as tabelas de maneira transacional da tabela antiga para a nova estrutura?"

### 4. Configuração de Autovacuum
> "Me explique como funciona o autovacuum para este caso de alta volumetria e por que preciso personalizá-lo especificamente para esta tabela?"

### 5. Criação de Queries de Monitoramento
> "Precisamos criar três queries de monitoramento específicas: 1 - TOP 5 QUERIES MAIS LENTAS; 2 - ÍNDICES NÃO UTILIZADOS; 3 - ESTIMATIVA DE BLOAT."

### 6. Geração de Relatórios
> "Com base em todo o trabalho técnico realizado e nos resultados obtidos, gere os arquivos finais de documentação README.md e RELATO_IA.md seguindo os requisitos do desafio."

## Sugestão de IA que foi Modificada ou Rejeitada
A IA inicialmente sugeriu a criação de índices em mais colunas da tabela de eventos para acelerar as buscas. No entanto, decidi **rejeitar** essa abordagem por saber que o excesso de índices degrada severamente a performance de escrita (`INSERT`) em tabelas com milhões de registros. Em vez disso, apliquei índices parciais e de cobertura apenas nas colunas identificadas como gargalos no diagnóstico.

## Código 100% Autoral
A análise crítica dos planos de execução (`EXPLAIN ANALYZE`) e a ordem lógica de execução dos scripts (01 a 07), garantindo que a infraestrutura subisse corretamente via Docker antes da aplicação da lógica de negócio, além da resolução de conflitos de codificação entre Windows e Linux.

## Reflexão
A utilização da IA foi fundamental para gerar rapidamente scripts, massa de dados e a base da documentação, permitindo focar na análise arquitetural e no refinamento técnico. A maior necessidade de intervenção humana ocorreu na validação da consistência dos dados após a migração para as partições e no ajuste fino dos tempos de execução das queries.
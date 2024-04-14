--Exercicio 1

--1- Criar a table PESSOAS:
CREATE TABLE pessoas (
 id_pessoa NUMBER(5) NOT NULL,
 cpf CHAR(14) NOT NULL,
 data_nascimento DATE NOT NULL,
 genero CHAR(1) NOT NULL
 );

--2- Inserir registros na tabela a partir da tabela do professor:
INSERT INTO pessoas (id_pessoa,cpf,data_nascimento,genero)
SELECT cod_cliente,cpf,data_nascimento,genero
FROM ARRUDA.pessoas_fisicas;
COMMIT;

--3- Coletar estatisticas sobre a estrutura e dados armazenados na tabela:
ANALYZE TABLE pessoas compute STATISTICS;

--4- Listar as informaçoes sobre a estrutura e dados armazenados na tabela:
SELECT *
FROM ALL_TABLES
WHERE TABLE_NAME = 'PESSOAS';

-- Preencha com as informacoes abaixo:
-- NUM_ROWS = 992
-- BLOCKS (DATABLOCKS) = 13
-- EMPTY_BLOCKS = 3
-- AVG_SPACE (media de B de cada datablock que eh ocupado pelos registros da tabela) = 5505

--5- Listar as constraints existentes na table PESSOAS:
SELECT *
FROM ALL_CONSTRAINTS
WHERE TABLE_NAME = 'PESSOAS';

-- RESPOSTA DA CONSULTA
/*
BI106097	SYS_C00751252	C	PESSOAS	"ID_PESSOA" IS NOT NULL	"ID_PESSOA" IS NOT NULL				ENABLED	NOT DEFERRABLE	IMMEDIATE	VALIDATED	GENERATED NAME			18/03/24					0
BI106097	SYS_C00751253	C	PESSOAS	"CPF" IS NOT NULL	"CPF" IS NOT NULL				ENABLED	NOT DEFERRABLE	IMMEDIATE	VALIDATED	GENERATED NAME			18/03/24					0
BI106097	SYS_C00751254	C	PESSOAS	"DATA_NASCIMENTO" IS NOT NULL	"DATA_NASCIMENTO" IS NOT NULL				ENABLED	NOT DEFERRABLE	IMMEDIATE	VALIDATED	GENERATED NAME			18/03/24					0
BI106097	SYS_C00751255	C	PESSOAS	"GENERO" IS NOT NULL	"GENERO" IS NOT NULL				ENABLED	NOT DEFERRABLE	IMMEDIATE	VALIDATED	GENERATED NAME			18/03/24					0
*/

--6- Listar os indices existentes na table PESSOAS:
SELECT *
FROM ALL_INDEXES
WHERE TABLE_NAME = 'PESSOAS';
 
-- RESPOSTA DA CONSULTA
    -- (Query vazia)
 
--7- Executar a seguinte consulta, verificando o plano de execucao:
SELECT *
FROM pessoas;
-- OPERATION: TABLE ACESS | OBJECT NAME: PESSOAS |OPTIONS: FULL |  CARDINALITY: 1488 | COST: 5

EXPLAIN PLAN FOR
SELECT *
FROM pessoas;

SELECT PLAN_TABLE_OUTPUT 
FROM TABLE(DBMS_XPLAN.DISPLAY());
/*
Explain plan da table plan_table oracle:

Plan hash value: 417319553
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |  1488 | 37200 |     5   (0)| 00:00:01 |
|   1 |  TABLE ACCESS FULL| PESSOAS |  1488 | 37200 |     5   (0)| 00:00:01 |
-----------------------------------------------------------------------------
*/
 
-- METODOS DE ACESSO:
 
-- Executar a seguinte consulta, verificando o plano de execucao:
SELECT id_pessoa
FROM pessoas;
 
-- METODOS DE ACESSO:
 
-- !primary kwy violiation error!
/*
LTER TABLE pessoas
ADD CONSTRAINT pk_pessoas PRIMARY KEY(id_pessoa)
Relatório de erros -
ORA-02437: não é possível validar (BI106097.PK_PESSOAS) - chave primária violada
02437. 00000 -  "cannot validate (%s.%s) - primary key violated"
*Cause:    attempted to validate a primary key with duplicate values or null
           values.
*Action:   remove the duplicates and null values before enabling a primary
           key.
*/ 

-- purge table and restart basic operations
DROP TABLE bi106097.pessoas
CASCADE CONSTRAINTS 
PURGE;

--- Criar a table PESSOAS:
CREATE TABLE pessoas (
 id_pessoa NUMBER(5) NOT NULL,
 cpf CHAR(14) NOT NULL,
 data_nascimento DATE NOT NULL,
 genero CHAR(1) NOT NULL
 );

--- Inserir registros na tabela a partir da tabela do professor:
INSERT INTO pessoas (id_pessoa,cpf,data_nascimento,genero)
SELECT cod_cliente,cpf,data_nascimento,genero
FROM ARRUDA.pessoas_fisicas;
COMMIT;
 
-- Criar a primary key para a table PESSOAS:
ALTER TABLE pessoas
ADD CONSTRAINT pk_pessoas PRIMARY KEY(id_pessoa);
 
-- Listar as constraints existentes na table PESSOAS:
SELECT *
FROM ALL_CONSTRAINTS
WHERE TABLE_NAME = 'PESSOAS';
 
-- O que mudou?
 -- Há uma nova constranint do tipo P (private key) relacionado espeficamente ao meu schema,
 -- gerando um total de 5 constrainst:
/*
BI106097	PK_PESSOAS	P	PESSOAS						ENABLED	NOT DEFERRABLE	IMMEDIATE	VALIDATED	USER NAME			18/03/24	BI106097	PK_PESSOAS			0
BI106097	SYS_C00751315	C	PESSOAS	"ID_PESSOA" IS NOT NULL	"ID_PESSOA" IS NOT NULL				ENABLED	NOT DEFERRABLE	IMMEDIATE	VALIDATED	GENERATED NAME			18/03/24					0
BI106097	SYS_C00751316	C	PESSOAS	"CPF" IS NOT NULL	"CPF" IS NOT NULL				ENABLED	NOT DEFERRABLE	IMMEDIATE	VALIDATED	GENERATED NAME			18/03/24					0
BI106097	SYS_C00751317	C	PESSOAS	"DATA_NASCIMENTO" IS NOT NULL	"DATA_NASCIMENTO" IS NOT NULL				ENABLED	NOT DEFERRABLE	IMMEDIATE	VALIDATED	GENERATED NAME			18/03/24					0
BI106097	SYS_C00751318	C	PESSOAS	"GENERO" IS NOT NULL	"GENERO" IS NOT NULL				ENABLED	NOT DEFERRABLE	IMMEDIATE	VALIDATED	GENERATED NAME			18/03/24					0
*/
 
--- Coletar estatisticas sobre a estrutura e dados armazenados na tabela:
ANALYZE TABLE pessoas compute STATISTICS;

-- Listar os indices existentes na table PESSOAS:
SELECT *
FROM ALL_INDEXES
WHERE TABLE_NAME = 'PESSOAS';

-- Complete as informacoes:
-- INDEX_NAME = PK_PESSOAS
-- INDEX_TYPE = NORMAL
-- UNIQUENESS = UNIQUE
-- DISTINCT_KEYS = 248
-- BLEVEL = 0 - possui apenas o n— folha que tambem eh a raiz da B-Tree+ ? Sim
-- LEAK_BLOCKS = 1
 
-- Executar a seguinte consulta, verificando o plano de execucao:
SELECT *
FROM pessoas;
 
-- METODOS DE ACESSO:
 -- table scan full
-- Executar a seguinte consulta:
SELECT *
FROM pessoas
WHERE id_pessoa = 100;
 
-- METODOS DE ACESSO:
 -- TABLE ACCESS BY INDEX ROWID ON TABLE PESSOAS
    -- VIA PK_PESSOAS WITH UNIQUE_SCAN
    



-- Etapa 1 : tabelas sem otimização

SELECT
  'create table ' || table_name || ' as select * from DSILVA.' || table_name || ';'
FROM
  all_tables
WHERE
    owner = 'DSILVA'
    AND table_name LIKE 'AIR_%';

create table AIR_AIRLINES as select * from DSILVA.AIR_AIRLINES;
create table AIR_AIRPLANES as select * from DSILVA.AIR_AIRPLANES;
create table AIR_AIRPLANE_TYPES as select * from DSILVA.AIR_AIRPLANE_TYPES;
create table AIR_AIRPORTS as select * from DSILVA.AIR_AIRPORTS;
create table AIR_AIRPORTS_GEO as select * from DSILVA.AIR_AIRPORTS_GEO;
create table AIR_BOOKINGS as select * from DSILVA.AIR_BOOKINGS;
create table AIR_FLIGHTS as select * from DSILVA.AIR_FLIGHTS;
create table AIR_FLIGHTS_SCHEDULES as select * from DSILVA.AIR_FLIGHTS_SCHEDULES;
create table AIR_PASSENGERS as select * from DSILVA.AIR_PASSENGERS;
create table AIR_PASSENGERS_DETAILS as select * from DSILVA.AIR_PASSENGERS_DETAILS;

SELECT all_tables.table_name
FROM
  all_tables
WHERE
    owner = 'BI106097'
    AND table_name LIKE 'AIR_%';
    
/*
1. Listar o nome completo (primeiro nome + último nome), 
a idade e a cidade de todos os passageiros do sexo feminino (sex='w') com mais de 40 anos, 
residentes no país 'BRAZIL'. [resposta sugerida = 141 linhas]

2. Listar o nome da companhia aérea, o identificador da aeronave, o nome do tipo de aeronave e o número de todos os voos operados por essa companhia aérea (independentemente de a aeronave ser de sua propriedade) que saem E chegam em aeroportos localizados no país 'BRAZIL'. 

3. Listar o número do voo, o nome do aeroporto de saída e o nome do aeroporto de destino, o nome completo (primeiro e último nome) e o assento de cada passageiro, para todos os voos que partem no dia do seu aniversário neste ano (caso a consulta não retorne nenhuma linha, faça para o dia subsequente até encontrar uma data que retorne alguma linha). [resposta sugerida = 106 linhas para o dia 25/03/2023]

4. Listar o nome da companhia aérea bem como a data e a hora de saída de todos os voos que chegam para a cidade de 'NEW YORK' que partem às terças, quartas ou quintas-feiras, no mês do seu aniversário  (caso a consulta não retorne nenhuma linha, faça para o mês subsequente até encontrar um mês que retorne alguma linha). [resposta sugerida = 1 linha para o mês de março de 2023]

5 .Crie uma consulta que seja resolvida adequadamente com um acesso hash em um cluster com pelo menos duas tabelas. A consulta deve utilizar todas as tabelas do cluster e pelo menos outra tabela fora dele.
*/

--SELECT COUNT(*) AS NUM_RESULTS
--FROM(

-- 1 QUERY
SELECT 
    PSG.FIRSTNAME || ' ' || PSG.LASTNAME AS FULL_NAME
FROM 
    AIR_PASSENGERS PSG
JOIN 
    AIR_PASSENGERS_DETAILS DET 
    ON 
    PSG.PASSENGER_ID = DET.PASSENGER_ID
WHERE
    DET.SEX = 'w'
    AND DET.COUNTRY = 'BRAZIL'
    AND DET.BIRTHDATE <= ADD_MONTHS(SYSDATE, -40*12)
;

EXPLAIN PLAN FOR
SELECT 
    PSG.FIRSTNAME || ' ' || PSG.LASTNAME AS FULL_NAME
FROM 
    AIR_PASSENGERS PSG
JOIN 
    AIR_PASSENGERS_DETAILS DET 
    ON 
    PSG.PASSENGER_ID = DET.PASSENGER_ID
WHERE
    DET.SEX = 'w'
    AND DET.COUNTRY = 'BRAZIL'
    AND DET.BIRTHDATE <= ADD_MONTHS(SYSDATE, -40*12)
;

SELECT PLAN_TABLE_OUTPUT 
FROM TABLE(DBMS_XPLAN.DISPLAY());
-- 2 QUERY
EXPLAIN PLAN FOR
SELECT 
    AIR_AIRLINES.AIRLINE_NAME AS AIRLINE_NAME,
    AIR_FLIGHTS.AIRPLANE_ID AS AIRPLANE_ID,
    AIR_AIRPLANE_TYPES.NAME AS AIRPLANE_TYPE,
    COUNT(AIR_FLIGHTS.FLIGHT_ID) AS NUM_FLIGHTS
FROM 
    AIR_AIRLINES
INNER JOIN 
    AIR_FLIGHTS ON AIR_AIRLINES.AIRLINE_ID = AIR_FLIGHTS.AIRLINE_ID
INNER JOIN 
    AIR_AIRPLANES ON AIR_FLIGHTS.AIRPLANE_ID = AIR_AIRPLANES.AIRPLANE_ID
INNER JOIN 
    AIR_AIRPLANE_TYPES ON AIR_AIRPLANES.AIRPLANE_TYPE_ID = AIR_AIRPLANE_TYPES.AIRPLANE_TYPE_ID
INNER JOIN 
    AIR_AIRPORTS FROM_AIRPORT ON AIR_FLIGHTS.FROM_AIRPORT_ID = FROM_AIRPORT.AIRPORT_ID
INNER JOIN 
    AIR_AIRPORTS TO_AIRPORT ON AIR_FLIGHTS.TO_AIRPORT_ID = TO_AIRPORT.AIRPORT_ID
INNER JOIN 
    AIR_AIRPORTS_GEO FROM_AIRPORT_GEO ON FROM_AIRPORT.AIRPORT_ID = FROM_AIRPORT_GEO.AIRPORT_ID
INNER JOIN 
    AIR_AIRPORTS_GEO TO_AIRPORT_GEO ON TO_AIRPORT.AIRPORT_ID = TO_AIRPORT_GEO.AIRPORT_ID
WHERE 
    FROM_AIRPORT_GEO.COUNTRY = 'BRAZIL' AND TO_AIRPORT_GEO.COUNTRY = 'BRAZIL'
GROUP BY 
    AIR_AIRLINES.AIRLINE_NAME,
    AIR_FLIGHTS.AIRPLANE_ID,
    AIR_AIRPLANE_TYPES.NAME
;

SELECT PLAN_TABLE_OUTPUT 
FROM TABLE(DBMS_XPLAN.DISPLAY());
-- 3 QUERY
EXPLAI PLAN FOR
SELECT 
    FLI.FLIGHTNO AS FLIGHT_NUMBER,
    DE.NAME AS DEPARTURE_AIRPORT,
    DEST.NAME AS DESTINATION_AIRPORT,
    PASSEN.FIRSTNAME || ' ' || PASSEN.LASTNAME AS PASSENGER_NAME,
    BOOK.SEAT AS PASSENGER_SEAT
FROM 
    AIR_FLIGHTS FLI
INNER JOIN 
    AIR_BOOKINGS BOOK ON FLI.FLIGHT_ID = BOOK.FLIGHT_ID
INNER JOIN 
    AIR_PASSENGERS PASSEN ON BOOK.PASSENGER_ID = PASSEN.PASSENGER_ID
INNER JOIN 
    AIR_PASSENGERS_DETAILS DETAIL ON PASSEN.PASSENGER_ID = DETAIL.PASSENGER_ID
INNER JOIN
    AIR_AIRPORTS DE ON FLI.FROM_AIRPORT_ID = DE.AIRPORT_ID
INNER JOIN 
    AIR_AIRPORTS DEST ON FLI.TO_AIRPORT_ID = DEST.AIRPORT_ID
INNER JOIN 
    AIR_FLIGHTS_SCHEDULES FS ON FLI.FLIGHTNO = FS.FLIGHTNO
WHERE 
    FLI.DEPARTURE BETWEEN TRUNC(TO_DATE('2023-03-25 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) 
    AND TRUNC(TO_DATE('2023-03-25 00:00:00', 'YYYY-MM-DD HH24:MI:SS')+1) - (1/(24*60*60))
;


SELECT PLAN_TABLE_OUTPUT 
FROM TABLE(DBMS_XPLAN.DISPLAY());

-- 4 QUERY
 
SELECT AIR_AIRLINES.AIRLINE_NAME AS AIRLINENAME_NAME, AIR_FLIGHTS_SCHEDULES.DEPARTURE AS DEPARTURE
FROM AIR_AIRLINES
INNER JOIN 
    AIR_FLIGHTS ON AIR_AIRLINES.AIRLINE_ID = AIR_FLIGHTS.AIRLINE_ID
INNER JOIN 
    AIR_FLIGHTS_SCHEDULES ON AIR_FLIGHTS.FLIGHTNO = AIR_FLIGHTS_SCHEDULES.FLIGHTNO
INNER JOIN 
    AIR_AIRPORTS ON AIR_FLIGHTS.TO_AIRPORT_ID = AIR_AIRPORTS.AIRPORT_ID
INNER JOIN
    AIR_AIRPORTS_GEO ON AIR_AIRPORTS.AIRPORT_ID = AIR_AIRPORTS_GEO.AIRPORT_ID
WHERE
    AIR_AIRPORTS_GEO.CITY = 'NEW YORK'
    AND AIR_FLIGHTS_SCHEDULES.DEPARTURE 
    BETWEEN TRUNC(TO_DATE('2022-05-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) AND 
    TRUNC(TO_DATE('2022-05-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS'))-(1/(24*60*60))
    AND 
    (
    AIR_FLIGHTS_SCHEDULES.TUESDAY  = 1
    OR AIR_FLIGHTS_SCHEDULES.WEDNESDAY = 1
    OR AIR_FLIGHTS_SCHEDULES.THURSDAY = 1
    )
;

-- 5 QUERY

/*
Crie uma consulta que seja resolvida adequadamente com um 
acesso hash em um cluster com pelo menos duas tabelas. 
A consulta deve utilizar todas as tabelas do cluster e pelo 
menos outra tabela fora dele.
*/

SELECT AIR_PASSENGERS.PASSENGER_ID AS CLIENT, AIR_FLIGHTS.DEPARTURE AS DEPARTURE_DATE, COUNT(AIR_BOOKINGS.BOOKING_ID) AS NUM_BOOKINGS, AIR_BOOKINGS.PRICE AS BOOKING_PRICE_UNIT, AIR_BOOKINGS.PRICE * COUNT(AIR_BOOKINGS.BOOKING_ID) AS TOTAL_PRICE    
FROM 
    AIR_AIRPORTS_GEO
INNER JOIN  
    AIR_AIRPORTS ON AIR_AIRPORTS_GEO.AIRPORT_ID = AIR_AIRPORTS.AIRPORT_ID
INNER JOIN 
    AIR_FLIGHTS ON AIR_AIRPORTS.AIRPORT_ID = AIR_FLIGHTS.FROM_AIRPORT_ID
INNER JOIN
    AIR_BOOKINGS ON AIR_FLIGHTS.FLIGHT_ID = AIR_BOOKINGS.FLIGHT_ID
INNER JOIN
    AIR_PASSENGERS ON AIR_BOOKINGS.PASSENGER_ID = AIR_PASSENGERS.PASSENGER_ID
WHERE
    AIR_PASSENGERS.PASSENGER_ID = 313
GROUP BY
    AIR_PASSENGERS.PASSENGER_ID, AIR_BOOKINGS.PRICE, AIR_FLIGHTS.DEPARTURE
    ;



-- Etapa 3 - Sintonia de desempenho (SQL tunning)
-- Execute, cada uma das consultas, sem criar nenhuma constraint ou estrutura de acesso otimizado, os seguintes passos:

-- Execute a consulta e confira a resposta.
-- Capture o plano de execução.

-- Etapa 4 - Sintonia de desempenho (SQL tunning)
-- Para cada uma das consultas, faça os testes necessários buscando a geração do melhor plano de execução possível. Lembre-se, entretanto, que o espaço de armazenamento de vocês é limitado e duplicar tabelas grandes pode extrapolá-lo, gerando um erro ao criar tabelas, clusters, índices ou outras estruturas. A seguir:

-- Crie todas as estruturas de acesso otimizado necessárias para que a consulta seja executada da forma mais otimizada possível:
-- Constraints de chave primária (primary key) → geram índices únicos implementados como B-Tree+
-- Constraints de chave alternativa (unique)  → geram índices únicos implementados como B-Tree+
-- �?ndices não únicos implementados como B-Tree+
-- Podem/devem ser implementados em colunas que frequentemente aparecem em condições da cláusula where
-- Podem e normalmente devem ser criados nas constraints de chave estrangeira (foreign key)
-- Clusters de tabelas com acesso via índice B-Tree+
-- Clusters de tabelas com acesso via hash
-- Liste e capture a imagem do plano de execução sugerido pelo Oracle
-- Material a ser entregue
-- Entregar relatório em PDF contendo, para cada consulta:

-- Dados de identificação do aluno;
-- Comando SQL DQL (SELECT) que implementa a consulta;
-- Captura de tela do Plano de Execução do SQL Developer anterior à sintonia de desempenho;
-- Comandos SQL DDL (Data Definition Language) para criação das estruturas de acesso sugeridas; e
-- Captura de tela do Plano de Execução do SQL Developer anterior à sintonia de desempenho.
-- IMPORTANTE: Enriqueça o trabalho com comentários a respeito do seu desenvolvimento e sobre o desempenho das consultas, tanto antes da sintonia de desempenho quanto depois, quais aspectos foram melhorados. Comente também sobre dificuldades encontradas para o desenvolvimento das diversas etapas do trabalho.
SELECT 
    PSG.FIRSTNAME || ' ' || PSG.LASTNAME AS FULL_NAME
FROM 
    AIR_PASSENGERS PSG
JOIN 
    AIR_PASSENGERS_DETAILS DET 
    ON 
    PSG.PASSENGER_ID = DET.PASSENGER_ID
WHERE
    DET.SEX = 'w'
    AND DET.COUNTRY = 'BRAZIL'
    AND DET.BIRTHDATE <= ADD_MONTHS(SYSDATE, -40*12)
;


/*
Etapa 4 - Sintonia de desempenho (SQL tunning)
Para cada uma das consultas, faça os testes necessários buscando a geração do melhor plano de execução possível. Lembre-se, entretanto, que o espaço de armazenamento de vocês é limitado e duplicar tabelas grandes pode extrapolá-lo, gerando um erro ao criar tabelas, clusters, índices ou outras estruturas. A seguir:

Crie todas as estruturas de acesso otimizado necessárias para que a consulta seja executada da forma mais otimizada possível:
Constraints de chave primária (primary key) → geram índices únicos implementados como B-Tree+
Constraints de chave alternativa (unique)  → geram índices únicos implementados como B-Tree+
�?ndices não únicos implementados como B-Tree+
Podem/devem ser implementados em colunas que frequentemente aparecem em condições da cláusula where
Podem e normalmente devem ser criados nas constraints de chave estrangeira (foreign key)
Clusters de tabelas com acesso via índice B-Tree+
Clusters de tabelas com acesso via hash
Liste e capture a imagem do plano de execução sugerido pelo Oracle*/

SELECT * FROM AIR_PASSENGERS_DETAILS
WHERE AIR_PASSENGERS_DETAILS.BIRTHDATE <= ADD_MONTHS(SYSDATE, -40*12);
-- END: ed8c6549bwf9
    
    
    
    
select 'drop table '||table_name||' cascade constraints;' from user_tables;
drop table AIR_AIRPORTS cascade constraints;
drop table AIR_AIRLINES cascade constraints;
drop table AIR_AIRPLANES cascade constraints;
drop table AIR_AIRPLANE_TYPES cascade constraints;
drop table AIR_AIRPORTS_GEO cascade constraints;
drop table AIR_BOOKINGS cascade constraints;
drop table AIR_FLIGHTS cascade constraints;
drop table AIR_FLIGHTS_SCHEDULES cascade constraints;
drop table AIR_PASSENGERS cascade constraints;
drop table AIR_PASSENGERS_DETAILS cascade constraints;
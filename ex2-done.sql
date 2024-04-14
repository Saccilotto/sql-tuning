-------
-- HASH
-------

DROP CLUSTER pessoas1 including tables CASCADE CONSTRAINTS;

DROP CLUSTER cl_itens_pedidos1 including tables CASCADE CONSTRAINTS;

DROP TABLE itens_pedidos1;

CREATE CLUSTER cl_itens_pedidos1(
    num_pedido numeric(10),
    cod_produto numeric(3)
)
SIZE 8K
single TABLE
hashkeys 128;
 

CREATE TABLE itens_pedidos1 (
 num_pedido numeric(10) NOT NULL,
 cod_produto numeric(3) NOT NULL,
 quantidade numeric(4),
 valor_unitario numeric(8,2),
 num_entrega numeric(10)
)
CLUSTER cl_itens_pedidos1(num_pedido,cod_produto);
 
INSERT INTO itens_pedidos1
SELECT * FROM DSILVA.itens_pedidos;
 
 
--EXPLAIN PLAN FOR
SELECT num_pedido, cod_produto, quantidade, valor_unitario
FROM DSILVA.itens_pedidos
WHERE
    num_pedido=620
    AND cod_produto=465;
    
-- Query result: 
    -- 620	465	1	278
    -- table access = full, cardinality = 1, cost = 23
    
--EXPLAIN PLAN FOR
--SELECT PLAN_TABLE_OUTPUT 
--FROM TABLE(DBMS_XPLAN.DISPLAY());

SELECT num_pedido, cod_produto, quantidade, valor_unitario
FROM BI106097.itens_pedidos1
WHERE
    num_pedido=620
    AND cod_produto=465;
 
SELECT ROWID, num_pedido, cod_produto, quantidade, valor_unitario
FROM DSILVA.itens_pedidos
WHERE
    num_pedido=620;
 
SELECT ROWID, num_pedido, cod_produto, quantidade, valor_unitario
FROM bi106097.itens_pedidos1
WHERE
    num_pedido=620;
 
DROP CLUSTER cl_itens_pedidos1 including tables CASCADE CONSTRAINTS;
DROP Table itens_pedidos1 cascade constraints;
 
CREATE CLUSTER cl_itens_pedidos1(
    num_pedido numeric(10),
    cod_produto numeric(3) sort
)
SIZE 8K
single TABLE
hashkeys 128
hash IS MOD(num_pedido,128);
 
CREATE TABLE itens_pedidos1 (
 num_pedido numeric(10) NOT NULL,
 cod_produto numeric(3) NOT NULL,
 quantidade numeric(4),
 valor_unitario numeric(8,2),
 num_entrega numeric(10)
)
CLUSTER cl_itens_pedidos1(num_pedido,cod_produto);
 
INSERT INTO itens_pedidos1
SELECT * FROM DSILVA.itens_pedidos; --didn't work

--EXPLAIN PLAN FOR
SELECT num_pedido, cod_produto, quantidade, valor_unitario
FROM bi106097.itens_pedidos1
WHERE
    num_pedido=620
    AND cod_produto=465;
    
--SELECT PLAN_TABLE_OUTPUT 
--FROM TABLE(DBMS_XPLAN.DISPLAY());     
    
/*
    table access  via hash, cardinality = 1, cost = 0
*/    
 
SELECT ROWID, num_pedido, cod_produto, quantidade, valor_unitario
FROM bi106097.itens_pedidos1
WHERE
    num_pedido=620;
/*    
DROP TABLE PESSOAS CASCADE CONSTRAINTS; 
DROP TABLE ITENS_PEDIDOS1 CASCADE CONSTRAINTS;
*/

commit;
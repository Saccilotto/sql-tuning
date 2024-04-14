DROP CLUSTER cl_pedidos_h including tables CASCADE CONSTRAINTS;
 
CREATE CLUSTER cl_pedidos_h(
    num_pedido numeric(10)
)
SIZE 8K
hashkeys 256;
 
CREATE TABLE pedidos_h (
 num_pedido numeric(10) NOT NULL,
 data_emissao DATE NOT NULL,
 cod_cliente numeric(5) NOT NULL
)
CLUSTER cl_pedidos_h(num_pedido);
 
CREATE TABLE itens_pedidos_h (
 num_pedido numeric(10) NOT NULL,
 cod_produto numeric(3) NOT NULL,
 quantidade numeric(4),
 valor_unitario numeric(8,2),
 num_entrega numeric(10)
)
CLUSTER cl_pedidos_h(num_pedido);
 
INSERT INTO pedidos_h
SELECT * FROM DSILVA.pedidos;
 
INSERT INTO itens_pedidos_h
SELECT * FROM DSILVA.itens_pedidos;
 
SELECT
    ped.ROWID,
    ped.num_pedido,
    ped.data_emissao,
    ped.cod_cliente,
    itped.ROWID,
    itped.cod_produto,
    itped.quantidade,
    itped.valor_unitario
FROM
    DSILVA.pedidos ped
    inner join DSILVA.itens_pedidos itped ON itped.num_pedido = ped.num_pedido
WHERE
    ped.num_pedido=620;
 
SELECT
    ped.ROWID,
    ped.num_pedido,
    ped.data_emissao,
    ped.cod_cliente,
    itped.ROWID,
    itped.cod_produto,
    itped.quantidade,
    itped.valor_unitario
FROM
    pedidos_h ped
    inner join itens_pedidos_h itped ON itped.num_pedido = ped.num_pedido
WHERE
    ped.num_pedido=620;
 
SELECT
    ped.ROWID,
    ped.num_pedido,
    ped.data_emissao,
    ped.cod_cliente,
    itped.ROWID,
    itped.cod_produto,
    itped.quantidade,
    itped.valor_unitario
FROM
   pedidos_h ped
   inner join itens_pedidos_h itped ON itped.num_pedido = ped.num_pedido
WHERE
    ped.num_pedido BETWEEN 620 AND 700;

DROP CLUSTER cl_pedidos_b including tables CASCADE CONSTRAINTS;
 
CREATE CLUSTER cl_pedidos_b(
    num_pedido numeric(10)
)
INDEX;
 
CREATE INDEX idx_cl_pedidos_b ON CLUSTER cl_pedidos_b;
 
CREATE TABLE pedidos_b (
 num_pedido numeric(10) NOT NULL,
 data_emissao DATE NOT NULL,
 cod_cliente numeric(5) NOT NULL
)
CLUSTER cl_pedidos_b(num_pedido);
 
CREATE TABLE itens_pedidos_b (
 num_pedido numeric(10) NOT NULL,
 cod_produto numeric(3) NOT NULL,
 quantidade numeric(4),
 valor_unitario numeric(8,2),
 num_entrega numeric(10)
)
CLUSTER cl_pedidos_b(num_pedido);
 
INSERT INTO pedidos_b
SELECT * FROM arruda.pedidos;
 
INSERT INTO itens_pedidos_b
SELECT * FROM arruda.itens_pedidos;
 
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
    arruda.pedidos_b ped
    inner join arruda.itens_pedidos_b itped ON itped.num_pedido = ped.num_pedido
WHERE
    ped.num_pedido=620;
 
SELECT
    ped.num_pedido,
    ped.data_emissao,
    ped.cod_cliente,
    itped.cod_produto,
    itped.quantidade,
    itped.valor_unitario
FROM
    arruda.pedidos_b ped
    inner join arruda.itens_pedidos_b itped ON itped.num_pedido = ped.num_pedido
WHERE
    ped.num_pedido BETWEEN 620 AND 700;

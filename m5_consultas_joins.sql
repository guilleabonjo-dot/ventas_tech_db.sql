-- ============================================================
-- Pre-entrega M5: Consultas con JOINs para el proyecto
-- Proyecto: Ventas_Tech_DB
-- Objetivo: enriquecer el análisis comercial cruzando tablas.
-- Motor: PostgreSQL
-- ============================================================


-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- Propósito: reunir datos de ventas, clientes, productos y categorías
-- en una sola vista para usar como fuente principal en Power BI.
SELECT
    v.fecha_venta,
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.ciudad AS region,
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta
FROM ventas AS v
INNER JOIN clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN productos AS p
    ON v.id_producto = p.id_producto
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta;

-- Hallazgo: la vista reúne las ventas con el nombre del cliente, la ciudad,
-- el producto y su categoría. La ciudad permite agrupar y filtrar el análisis
-- geográfico en Power BI.


-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: identificar clientes registrados que nunca realizaron compras,
-- para que el área de CRM pueda planificar acciones de activación.
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v
    ON c.id_cliente = v.id_cliente
WHERE v.id_cliente IS NULL
ORDER BY c.fecha_registro;

-- Hallazgo: con los datos de ejemplo actuales aparecen 0 clientes sin ventas.
-- CRM puede enfocar sus acciones en fidelización y recompra, en lugar de
-- campañas dirigidas a clientes que todavía no compraron.


-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Propósito: detectar artículos del catálogo que no registran ventas,
-- para que el área de Producto evalúe su visibilidad, precio o continuidad.
SELECT
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos AS p
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas AS v
    ON p.id_producto = v.id_producto
WHERE v.id_producto IS NULL
ORDER BY p.nombre_producto;

-- Hallazgo: con los datos de ejemplo actuales aparecen 0 productos sin ventas.
-- Todos los productos del catálogo registraron movimiento, por lo que el área
-- de Producto puede analizar cuáles venden más y cuáles necesitan impulso.


-- Consulta 4: Consolidado por período (UNION ALL)
-- Propósito: comparar las ventas del 1 al 10 de marzo con las del 11 al 31
-- de marzo de 2024. Las etiquetas se crean aquí; no existen en las tablas.
SELECT
    periodo AS origen,
    SUM(total) AS total_periodo
FROM (
    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Del 1 al 10 de marzo' AS periodo
    FROM ventas
    WHERE fecha_venta >= DATE '2024-03-01'
      AND fecha_venta <= DATE '2024-03-10'

    UNION ALL

    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Del 11 al 31 de marzo' AS periodo
    FROM ventas
    WHERE fecha_venta >= DATE '2024-03-11'
      AND fecha_venta <= DATE '2024-03-31'
) AS consolidado
GROUP BY periodo
ORDER BY periodo;

-- Hallazgo: en los datos de ejemplo, las ventas del 1 al 10 de marzo suman
-- $3.620 y las del 11 al 31 de marzo suman $2.824. El primer período genera
-- $796 más. Las etiquetas representan períodos, no canales reales de venta.

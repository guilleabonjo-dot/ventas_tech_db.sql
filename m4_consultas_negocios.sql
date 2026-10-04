
-- PRE-ENTREGA M4: CONSULTAS SQL DE NEGOCIO
-- Base de datos: Ventas_Tech_DB
-- Tabla utilizada: ventas

-- CONSULTA 1: RESUMEN EJECUTIVO MENSUAL
-- Total facturado, pedidos y ticket promedio por mes


SELECT
    EXTRACT(MONTH FROM fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    ROUND(
        SUM(cantidad * precio_unitario) / COUNT(*),
        2
    ) AS ticket_promedio
FROM ventas
GROUP BY EXTRACT(MONTH FROM fecha_venta)
ORDER BY mes;



-- CONSULTA 2: RANKING DE PRODUCTOS
-- Top 5 por facturación total

SELECT
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC
LIMIT 5;


-- CONSULTA 3: CLIENTES RECURRENTES
-- Clientes con más de un pedido

SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;


--CONSULTA 4: COMPARACIÓN CON EL PROMEDIO MENSUAL
Clasificación de la facturación de cada mes

WITH facturacion_mensual AS (
    SELECT
        EXTRACT(MONTH FROM fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY EXTRACT(MONTH FROM fecha_venta)
)

SELECT
    mes,
    total_facturado,
    ROUND(AVG(total_facturado) OVER (), 2) AS promedio_mensual,
    CASE
        WHEN total_facturado > AVG(total_facturado) OVER ()
            THEN 'Por encima'
        WHEN total_facturado < AVG(total_facturado) OVER ()
            THEN 'Por debajo'
        ELSE 'Igual al promedio'
    END AS comparacion_promedio
FROM facturacion_mensual
ORDER BY mes;



-- HALLAZGOS DEL ANÁLISIS

-- 1. El producto 1 generó 3.600 sobre una facturación
--    total de 6.444, representando aproximadamente
--    el 55,9% de los ingresos registrados.

-- 2. El producto 2 fue el más vendido en unidades,
--    con 13 unidades, aunque no fue el producto
--    que más facturación generó.

-- 3. El cliente 1 fue quien más gastó, con un total
--    de 2.640 en dos pedidos registrados.



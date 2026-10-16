-- Informe agregado de ventas por categoria
-- Periodo: octubre de 2026
-- Estado: entregada

SELECT
    C.nombre_categoria AS categoria,
    COUNT(DISTINCT V.nro_comprobante) AS cantidad_ventas,
    SUM(DV.cantidad * DV.precio_unitario) AS total_vendido
FROM Venta V
INNER JOIN Detalle_Venta DV
    ON V.nro_comprobante = DV.nro_comprobante
INNER JOIN Producto P
    ON DV.codigo_producto = P.codigo_producto
INNER JOIN Categoria C
    ON P.codigo_categoria = C.codigo_categoria
WHERE V.fecha >= '2026-09-01'
  AND V.fecha < '2026-10-01'
  AND V.id_estado_venta = 4
GROUP BY C.nombre_categoria
ORDER BY total_vendido DESC;
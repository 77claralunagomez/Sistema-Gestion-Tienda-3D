Informe agregado de ventas por categoría 

1. Objetivo 

Desarrollar y probar una consulta SQL que permita obtener un informe agregado de ventas por categoría de producto dentro de un rango de fechas. La consulta calcula la cantidad de comprobantes diferentes y el importe total vendido por categoría, utilizando COUNT(), SUM() y GROUP BY. 

2. Tablas involucradas 

Venta: contiene el número de comprobante, la fecha y el estado de cada venta. 

Detalle_Venta: registra los productos incluidos en cada comprobante, sus cantidades y precios unitarios. 

Producto: permite identificar los productos vendidos y la categoría a la que pertenecen. 

Categoria: proporciona el nombre de las categorías utilizadas para agrupar los resultados. 

3. Lógica y explicación del script 

INNER JOIN: relaciona las ventas con sus detalles, los productos y las categorías. 

WHERE: filtra las ventas realizadas durante octubre de 2026 y selecciona las que tienen estado 4, correspondiente a Entregada en la base de prueba. 

COUNT(DISTINCT ...): cuenta los comprobantes diferentes que contienen productos de cada categoría. 

SUM(): suma la cantidad multiplicada por el precio unitario de cada producto vendido. 

GROUP BY: agrupa los resultados por categoría. 

ORDER BY: ordena las categorías desde el mayor importe vendido hasta el menor. 

4. Script SQL implementado 

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
WHERE V.fecha >= '2026-10-01' 
  AND V.fecha < '2026-11-01' 
  AND V.id_estado_venta = 4 
GROUP BY C.nombre_categoria 
ORDER BY total_vendido DESC; 

## 5. Resultados obtenidos

La consulta se ejecutó correctamente en SQL Server Management Studio y produjo los siguientes resultados con los datos de prueba utilizados:

| Categoría           | Cantidad de ventas | Total vendido |
| Filamento ABS       | 1                  | $44.000       |
| Resinas SLA         | 1                  | $35.000       |
| Filamento PLA       | 1                  | $18.00        |
| Repuestos mecánicos | 2                  | $13.500       |
| Herramientas de     |                    |               |
|post-procesamiento   | 2                  | $7.500        |

6. Conclusión 

La consulta permite analizar las ventas entregadas por categoría durante un período determinado.
 Mediante las funciones de agregación y agrupación se obtiene la cantidad de comprobantes diferentes y el importe vendido por categoría, facilitando el análisis comercial de la tienda
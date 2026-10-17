# Informe agregado de ventas por categoría

## 1. Objetivo

Desarrollar y probar una consulta SQL que permita obtener un informe agregado de ventas por categoría de producto dentro de un rango de fechas determinado. La consulta calcula la cantidad de comprobantes diferentes y el importe total vendido por cada categoría, utilizando las funciones `COUNT()`, `SUM()` y `GROUP BY`.

## 2. Tablas involucradas

Para construir el informe se combinan las siguientes entidades del modelo relacional:

- **Venta:** almacena los datos generales de la venta, incluyendo el número de comprobante, la fecha y el estado.
- **Detalle_Venta:** contiene los productos incluidos en cada comprobante, junto con sus cantidades y precios unitarios.
- **Producto:** permite identificar los productos vendidos y la categoría a la que pertenecen.
- **Categoria:** almacena los nombres de las categorías utilizadas para agrupar los resultados.

## 3. Lógica y explicación del script

- **Uniones (`INNER JOIN`):** relacionan las ventas con sus detalles, los productos vendidos y sus categorías mediante las claves correspondientes.
- **Filtro por fecha (`WHERE`):** selecciona las ventas realizadas desde el 1 de octubre hasta antes del 1 de noviembre de 2026.
- **Filtro por estado:** se consideran únicamente las ventas cuyo identificador de estado es `4`, correspondiente a *Entregada* en la base de datos utilizada para la prueba.
- **Conteo de comprobantes (`COUNT(DISTINCT ...)`):** cuenta los números de comprobante diferentes que contienen productos de cada categoría, evitando contar varias veces un mismo comprobante dentro de una categoría.
- **Cálculo del total (`SUM()`):** suma el resultado de multiplicar la cantidad por el precio unitario de cada producto vendido.
- **Agrupación (`GROUP BY`):** agrupa los resultados por nombre de categoría para obtener un resumen de las ventas.
- **Ordenamiento (`ORDER BY`):** presenta las categorías de mayor a menor importe vendido.
  
### Notas sobre las reglas de negocio aplicadas:
- **Exclusión de ventas no concretadas:** Se filtra estrictamente por `id_estado_venta = 4` (Entregada) para no inflar la facturación con comprobantes pendientes, cancelados o en proceso de preparación.
- **Precisión en conteo con `DISTINCT`:** El uso de `COUNT(DISTINCT V.nro_comprobante)` es clave porque una misma venta puede incluir varios productos de la misma categoría; de no usar `DISTINCT`, se duplicaría el conteo de ventas por categoría.

## 4. Script SQL implementado

```sql
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
```

## 5. Resultados obtenidos

La consulta se ejecutó correctamente en SQL Server Management Studio y produjo los siguientes resultados con los datos de prueba utilizados:

| Categoría | Cantidad de ventas | Total vendido |
|---|---:|---:|
| Filamento ABS | 1 | $44.000 |
| Resinas SLA | 1 | $35.000 |
| Filamento PLA | 1 | $18.000 |
| Repuestos mecánicos | 2 | $13.500 |
| Herramientas de post-procesamiento | 2 | $7.500 |

Los resultados corresponden a las ventas entregadas durante octubre de 2026. Los importes se calcularon a partir de los detalles de cada comprobante.

### Análisis de los resultados:
- **Línea de mayor ingreso:** La categoría *Filamento ABS* registra el mayor volumen de facturación ($44.000) pese a contar con una sola venta registrada en el período.
- **Líneas de mayor rotación:** Las categorías *Repuestos mecánicos* y *Herramientas de post-procesamiento* lideran en cantidad de operaciones (2 ventas cada una), indicando una alta frecuencia de demanda de insumos secundarios.

## 6. Conclusión

La consulta permite resumir las ventas entregadas por categoría de producto durante un período determinado. Mediante las funciones de agregación y agrupación se obtiene la cantidad de comprobantes diferentes y el importe total vendido por categoría, facilitando el análisis comercial de la tienda.

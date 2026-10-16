# Clientes con Compras Superiores a $50.000 (Efectivo o Transferencia)

## 1. Objetivo
Desarrollar y probar una consulta SQL que liste el nombre, apellido y monto total gastado de aquellos clientes del sistema *Tienda3D* que superaron los $50.000 en compras abonadas en efectivo o por transferencia bancaria, ordenados de mayor a menor gasto.

## 2. Tablas Involucradas
Para construir este listado se combinan las siguientes entidades del modelo relacional:
* *Venta*: Almacena el encabezado de cada comprobante (fecha, estado, método de pago y cliente).
* *Detalle_Venta*: Contiene los ítems de cada venta, con la cantidad y el precio unitario, necesarios para calcular el total de cada comprobante.
* *Cliente*: Proporciona los datos personales del comprador (DNI, nombre y apellido).
* *Metodo_Pago*: Permite filtrar las ventas por forma de pago (Efectivo y Transferencia Bancaria).
* *Tipo_Estado_Venta*: Permite excluir las ventas que no representan un gasto efectivo (Pendientes y Anuladas).

## 3. Lógica y Explicación del Script
* *Subconsulta de total por venta (`totalVenta`)*: Agrupa `Detalle_Venta` por `nro_comprobante` y calcula el total de cada comprobante con `SUM(dv.cantidad * dv.precio_unitario)`.
* *Filtrado de ventas (WHERE)*: Se consideran solo las ventas pagadas con método `1` (Efectivo) o `4` (Transferencia Bancaria), y se descartan las de estado `1` (Pendiente) y `5` (Anulada), ya que no constituyen un gasto concretado.
* *Acumulado por cliente (GROUP BY + HAVING)*: Se agrupa por `dni_cliente`, sumando los totales de todas sus ventas válidas. La cláusula `HAVING SUM(...) > 50000` conserva únicamente a los clientes que superan el umbral.
* *Obtención de datos personales*: La subconsulta externa devuelve solo el DNI y el total, por lo que se hace un `INNER JOIN` final con `Cliente` (alias `c2`) para recuperar nombre y apellido.
* *Ordenamiento*: `ORDER BY total_cliente DESC` muestra primero a los clientes que más gastaron.

## 4. Script SQL Implementado
```sql
SELECT c2.apellido, c2.nombre, ClientesConVentasMayoresA50000.total_cliente
FROM (
    SELECT c.dni_cliente, SUM(totalVenta.total_venta) AS total_cliente
    FROM Venta v
    INNER JOIN (
        SELECT v.nro_comprobante, SUM(dv.cantidad * dv.precio_unitario) AS total_venta
        FROM Venta v
        INNER JOIN Detalle_Venta dv ON dv.nro_comprobante = v.nro_comprobante
        GROUP BY v.nro_comprobante
    ) AS totalVenta ON v.nro_comprobante = totalVenta.nro_comprobante
    INNER JOIN Cliente c ON v.dni_cliente = c.dni_cliente
    INNER JOIN Metodo_Pago mp ON mp.id_metodo = v.id_metodo
    INNER JOIN Tipo_Estado_Venta tev ON tev.id_estado_venta = v.id_estado_venta
    WHERE mp.id_metodo IN (1, 4)            -- efectivo o transferencia
      AND tev.id_estado_venta NOT IN (1, 5) -- que no estén pendientes o anuladas
    GROUP BY c.dni_cliente
    HAVING SUM(totalVenta.total_venta) > 50000
) AS ClientesConVentasMayoresA50000
INNER JOIN Cliente c2 ON ClientesConVentasMayoresA50000.dni_cliente = c2.dni_cliente
ORDER BY ClientesConVentasMayoresA50000.total_cliente DESC;
```

## 5. Resultado Esperado con los Datos de Prueba
Ventas que cumplen los filtros (método Efectivo/Transferencia y estado distinto de Pendiente/Anulada):

| nro_comprobante | Cliente | Método de pago | Estado | Total |
|---|---|---|---|---|
| 1 | Pedro Alonso | Efectivo | Entregada | $60.500,00 |
| 4 | Valeria Ríos | Efectivo | Preparada | $92.500,00 |
| 6 | Florencia Molina | Transferencia Bancaria | Entregada | $697,50 |
| 7 | Santiago Vega | Efectivo | Confirmada | $94.000,00 |

Florencia Molina queda excluida por no superar los $50.000 acumulados. Resultado final de la consulta:

| apellido | nombre | total_cliente |
|---|---|---|
| Vega | Santiago | 94000.00 |
| Ríos | Valeria | 92500.00 |
| Alonso | Pedro | 60500.00 |
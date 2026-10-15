# Comprobante / Factura de Venta

## 1. Objetivo
Desarrollar y probar una consulta SQL que permita consolidar el encabezado y el detalle de una venta específica dentro del sistema *Tienda3D*, calculando de manera automática los subtotales por cada renglón de producto y el total acumulado del comprobante.

## 2. Tablas Involucradas
Para construir este comprobante se combinan las siguientes entidades del modelo relacional:
* *Venta*: Almacena el encabezado general del comprobante (número, fecha, importe total, estado, método de pago y cliente).
* *Cliente*: Proporciona los datos personales del comprador (DNI, nombre y apellido).
* *Metodo_Pago*: Define la forma de pago utilizada en la transacción.
* *Tipo_Estado_Venta*: Indica el estado actual del comprobante (ej. Confirmada, Pendiente, Entregada).
* *Detalle_Venta*: Contiene los ítems individuales de la venta, registrando la cantidad y el precio unitario de cada producto.
* *Producto*: Aporta la descripción y el nombre comercial de los artículos adquiridos.

## 3. Lógica y Explicación del Script
* *Uniones (INNER JOIN)*: Se vincula la tabla principal Venta con sus catálogos y detalles mediante claves foráneas.
* *Cálculo de Subtotales*: Se multiplica la columna cantidad por el precio_unitario de la tabla Detalle_Venta (dv.cantidad * dv.precio_unitario) para obtener el subtotal por renglón.
* *Cálculo de Total Acumulado*: Se emplea una función de ventana (SUM(...) OVER(PARTITION BY v.nro_comprobante)) para calcular de forma dinámica el monto total acumulado correspondiente a los ítems del comprobante.

## 4. Script SQL Implementado
```sql
SELECT 
    v.nro_comprobante,
    v.fecha,
    c.dni_cliente,
    CONCAT(c.nombre, ' ', c.apellido) AS cliente_nombre,
    mp.nombre_metodo AS metodo_pago,
    te.nombre AS estado_venta,
    p.codigo_producto,
    p.nombre AS producto_nombre,
    dv.cantidad,
    dv.precio_unitario,
    (dv.cantidad * dv.precio_unitario) AS subtotal_renglon,
    SUM(dv.cantidad * dv.precio_unitario) OVER(PARTITION BY v.nro_comprobante) AS total_acumulado_calculado  
FROM Venta v
INNER JOIN Cliente c ON v.dni_cliente = c.dni_cliente
INNER JOIN Metodo_Pago mp ON v.id_metodo = mp.id_metodo
INNER JOIN Tipo_Estado_Venta te ON v.id_estado_venta = te.id_estado_venta
INNER JOIN Detalle_Venta dv ON v.nro_comprobante = dv.nro_comprobante
INNER JOIN Producto p ON dv.codigo_producto = p.codigo_producto
WHERE v.nro_comprobante = 1;

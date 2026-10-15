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

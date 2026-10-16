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
    SUM(dv.cantidad * dv.precio_unitario) OVER(PARTITION BY v.nro_comprobante ORDER BY p.codigo_producto) AS total_acumulado_calculado
FROM Venta v
INNER JOIN Cliente c ON v.dni_cliente = c.dni_cliente
INNER JOIN Metodo_Pago mp ON v.id_metodo = mp.id_metodo
INNER JOIN Tipo_Estado_Venta te ON v.id_estado_venta = te.id_estado_venta
INNER JOIN Detalle_Venta dv ON v.nro_comprobante = dv.nro_comprobante
INNER JOIN Producto p ON dv.codigo_producto = p.codigo_producto
WHERE v.nro_comprobante = 1;


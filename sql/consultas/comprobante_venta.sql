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

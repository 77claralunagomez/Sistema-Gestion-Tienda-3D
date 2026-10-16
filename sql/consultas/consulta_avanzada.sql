
SELECT c2.apellido, c2.nombre, ClientesConVentasMayoresA50000.total_cliente
FROM (
    SELECT c.dni_cliente, SUM(totalVenta.total_venta) as total_cliente
    FROM Venta v
    INNER JOIN (
        SELECT v.nro_comprobante, SUM (dv.cantidad * dv.precio_unitario) as total_venta
        FROM  Venta v
        INNER JOIN Detalle_Venta dv ON dv.nro_comprobante = v.nro_comprobante
        GROUP BY v.nro_comprobante
    ) AS totalVenta ON v.nro_comprobante = totalVenta.nro_comprobante
    INNER JOIN Cliente c ON v.dni_cliente = c.dni_cliente
    INNER JOIN Metodo_Pago mp ON mp.id_metodo = v.id_metodo
    INNER JOIN Tipo_Estado_Venta tev ON tev.id_estado_venta = v.id_estado_venta
    WHERE mp.id_metodo IN (1,4) --efectivo o transferencia
    AND tev.id_estado_venta NOT IN (1, 5) --que no esten pendientes o anuladas
    GROUP BY c.dni_cliente
    HAVING SUM(totalVenta.total_venta) > 50000
) as ClientesConVentasMayoresA50000
INNER JOIN Cliente c2 ON ClientesConVentasMayoresA50000.dni_cliente = c2.dni_cliente
ORDER BY ClientesConVentasMayoresA50000.total_cliente DESC
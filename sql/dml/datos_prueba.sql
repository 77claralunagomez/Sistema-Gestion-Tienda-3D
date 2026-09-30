USE Tienda3D;
GO

INSERT INTO Rol (nombre)
VALUES
('Administrador'),
('Vendedor'),
('Encargado de Stock'),
('Supervisor'),
('Atención al Cliente'),
('Encargado de Ventas'),
('Gerente'),
('Soporte');

INSERT INTO Metodo_Pago (nombre_metodo)
VALUES
('Efectivo'),
('Tarjeta de Crédito'),
('Tarjeta de Débito'),
('Transferencia Bancaria'),
('MercadoPago'),
('MODO'),
('Cuenta Corriente'),
('Pago QR');


INSERT INTO Estado_Consulta (nombre)
VALUES
('Abierta'),
('Respondida'),
('Cerrada');


INSERT INTO Tipo_Estado_Venta (nombre)
VALUES
('Pendiente'),
('Confirmada'),
('Preparada'),
('Entregada'),
('Anulada');

INSERT INTO Categoria (nombre_categoria) VALUES 
('Filamento PLA'),
('Filamento ABS'),
('Filamento PETG'),
('Resinas SLA'),
('Repuestos mecánicos'),
('Accesorios de impresión'),
('Electrónica'),
('Herramientas de post-procesamiento');

INSERT INTO Marca (nombre_marca) VALUES 
('Grillon3'),
('Esun'),
('Creality'),
('Anycubic'),
('Prusa Research'),
('Sunlu'),
('Elegoo'),
('Plastify');

INSERT INTO Unidad_comercio (nombre) VALUES 
('Kilogramo'),
('Unidad'),
('Litro'),
('Botella'),
('Metro'),
('Rollo'),
('Pack'),
('Gramo');

INSERT INTO Tipo_movimiento_stock (nombre) VALUES 
('Ingreso por compra a proveedor'),
('Salida por venta directa'),
('Devolución de cliente'),
('Reintegro por anulación de venta'),
('Merma por impresión fallida'),
('Ajuste de inventario físico'),
('Consumo interno'),
('Transferencia interna');

INSERT INTO Proveedor (contacto) VALUES
('Juan Pérez - Distribuidora Sur'),
('María Gómez - Insumos Central'),
('Carlos López - Tech Mayorista'),
('Ana Martínez - Proveedores Unidos'),
('Roberto Sánchez - Global Supplies'),
('Lucía Fernández - MegaStock'),
('Diego Torres - Distribuciones AR'),
('Laura Ramírez - Importadora del Este');

INSERT INTO Usuario (nombre, contrasena, email, id_rol) VALUES
('Admin General', 'hash_admin123', 'admin@tienda.com', 1),
('Vendedor Uno', 'hash_vend1', 'vendedor1@tienda.com', 2),
('Vendedor Dos', 'hash_vend2', 'vendedor2@tienda.com', 2),
('Cajero Uno', 'hash_caj1', 'cajero1@tienda.com', 3),
('Soporte Tecnico', 'hash_soporte', 'soporte@tienda.com', 1),
('Gerente Sucursal', 'hash_gerente', 'gerente@tienda.com', 1),
('Atencion Cliente 1', 'hash_atc1', 'atencion1@tienda.com', 2),
('Atencion Cliente 2', 'hash_atc2', 'atencion2@tienda.com', 2);

INSERT INTO Cliente (dni_cliente, nombre, apellido, telefono, correo_electronico, id_usuario) VALUES
('20123456', 'Pedro', 'Alonso', '1122334455', 'pedro.a@mail.com', NULL),
('25654321', 'Camila', 'Rojas', '1133445566', 'camila.r@mail.com', 7),
('30987654', 'Javier', 'Giménez', '1144556677', 'javi.g@mail.com', NULL),
('35111222', 'Valeria', 'Ríos', '1155667788', 'vale.rios@mail.com', NULL),
('40333444', 'Tomás', 'Navarro', '1166778899', 'tomas.n@mail.com', 8),
('42555666', 'Florencia', 'Molina', '1177889900', 'flor.m@mail.com', NULL),
('28777888', 'Santiago', 'Vega', '1188990011', 'santi.vega@mail.com', NULL),
('31999000', 'Micaela', 'Suárez', '1199001122', 'mica.s@mail.com', NULL);

INSERT INTO Consulta (canal, fecha, dni_cliente, id_estado_consulta) VALUES
('WhatsApp', '2026-09-20', '20123456', 1),
('Correo', '2026-09-21', '25654321', 2),
('Llamada Telefónica', '2026-09-22', '30987654', 1),
('Redes Sociales', '2026-09-23', '35111222', 3),
('Presencial', '2026-09-24', '40333444', 2),
('WhatsApp', '2026-09-25', '42555666', 1),
('Correo', '2026-09-26', '28777888', 2),
('Página Web', '2026-09-27', '31999000', 3);

INSERT INTO Detalle_Venta (nro_comprobante, codigo_producto, cantidad, precio_unitario) VALUES
(1, 1, 2.00, 18500.00),
(1, 3, 1.00, 12000.00),
(2, 2, 1.50, 24000.00),
(3, 4, 1.00, 32000.00),
(4, 1, 5.00, 17500.00),
(5, 5, 2.00, 8500.00),
(6, 2, 1.00, 24500.00),
(7, 3, 4.00, 11500.00);

INSERT INTO Movimiento_Stock (fecha, cantidad, descripcion, codigo_producto, id_tipo_movimiento_stock) VALUES
('2026-09-01 09:00:00', 50.00, 'Ingreso de stock inicial por proveedor', 1, 1),
('2026-09-01 10:30:00', -2.00, 'Salida por venta directa', 1, 2),
('2026-09-02 11:15:00', -1.50, 'Salida por venta directa', 2, 2),
('2026-09-03 14:00:00', 20.00, 'Ingreso por compra a proveedor', 4, 1),
('2026-09-04 16:45:00', -1.00, 'Salida por venta directa', 4, 2),
('2026-09-05 10:00:00', 2.00, 'Reintegro por anulación de venta', 1, 4),
('2026-09-06 12:20:00', -5.00, 'Salida por venta directa', 1, 2),
('2026-09-07 15:10:00', -2.00, 'Salida por venta directa', 5, 2);

INSERT INTO Anulacion_Venta (nro_comprobante, motivo_anulacion, fecha_anulacion, id_usuario) VALUES
(8, 'Cliente arrepentido antes del despacho', '2026-09-05 09:30:00', 1),
(9, 'Error en el método de pago seleccionado', '2026-09-08 11:00:00', 2),
(10, 'Falta de disponibilidad física del producto', '2026-09-10 14:15:00', 1),
(11, 'Duplicación de comprobante por error de sistema', '2026-09-12 16:00:00', 3),
(12, 'Cliente canceló por demora en la preparación', '2026-09-15 10:45:00', 2),
(13, 'Carga incorrecta de los ítems en el detalle', '2026-09-18 17:30:00', 1),
(14, 'Solicitud de cambio de datos de facturación', '2026-09-20 12:10:00', 3),
(15, 'Producto cargado por error en la venta', '2026-09-22 18:00:00', 2);

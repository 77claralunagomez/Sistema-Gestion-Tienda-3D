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

INSERT INTO Producto (descripcion, precio, nombre, stock, codigo_categoria, id_marca, id_unidad) VALUES
('Filamento PLA 1.75mm negro, rollo de 1kg',              18500.00, 'Filamento PLA Negro 1.75mm 1kg',   45.00, 1, 1, 6),
('Filamento ABS 1.75mm gris, rollo de 1kg',               21000.00, 'Filamento ABS Gris 1.75mm 1kg',    30.00, 2, 6, 6),
('Filamento PETG 1.75mm azul, rollo de 1kg',              23500.00, 'Filamento PETG Azul 1.75mm 1kg',   25.00, 3, 2, 6),
('Filamento PLA 1.75mm blanco por metro',                    45.00, 'Filamento PLA Blanco a granel',   350.50, 1, 8, 5),
('Resina SLA gris 405nm, botella de 1 litro',             32000.00, 'Resina SLA Gris 1L',               18.00, 4, 7, 4),
('Boquilla de latón 0.4mm para hotend MK8',                1800.00, 'Boquilla Latón 0.4mm',            120.00, 5, 3, 2),
('Kit sensor de nivelación automática de cama',           28000.00, 'Sensor Nivelación Automática',     12.00, 7, 4, 2),
('Kit post-procesamiento: espátulas, pinzas y lijas',      9500.00, 'Kit Post-procesamiento',           22.00, 8, 5, 7);

INSERT INTO Movimiento_Stock (fecha, cantidad, descripcion, codigo_producto, id_tipo_movimiento_stock) VALUES
('2026-09-01 09:15:00',  20.00, 'Compra de rollos PLA negro a proveedor',           1, 1),
('2026-09-05 11:30:00', -15.50, 'Venta de filamento PLA por metro',                 4, 2),
('2026-09-08 16:45:00',  -2.00, 'Venta de rollos ABS gris',                         2, 2),
('2026-09-10 10:00:00',   1.00, 'Devolución de cliente por rollo cerrado',          3, 3),
('2026-09-12 14:20:00',  -0.50, 'Consumo interno para prototipos de exhibición',    5, 7),
('2026-09-15 08:50:00',  -8.25, 'Merma por impresión fallida (metros descartados)', 4, 5),
('2026-09-18 12:10:00',  50.00, 'Ingreso de boquillas de latón por compra',         6, 1),
('2026-09-22 17:35:00',   1.00, 'Reintegro por anulación de venta de sensor',       7, 4);

INSERT INTO Proveedor_producto (id_proveedor, codigo_producto) VALUES
(1, 1),
(1, 2),
(2, 3),
(7, 4),
(4, 5),
(5, 6),
(3, 7),
(6, 8);
 
INSERT INTO Venta (fecha, id_estado_venta, importe, dni_cliente, id_metodo) VALUES
('2026-09-01', 4, 49000.00, '20123456', 1),
('2026-09-02', 4, 31500.00, '25654321', 2),
('2026-09-03', 2, 32000.00, '30987654', 3),
('2026-09-04', 3, 92500.00, '35111222', 1),
('2026-09-05', 1, 64000.00, '40333444', 2),
('2026-09-06', 4, 21000.00, '42555666', 4),
('2026-09-07', 2, 94000.00, '28777888', 1),
('2026-09-08', 5, 18500.00, '31999000', 3);

INSERT INTO Detalle_Venta (nro_comprobante, codigo_producto, cantidad, precio_unitario) VALUES
(1, 1, 2.00, 18500.00),
(1, 3, 1.00, 12000.00),
(2, 2, 1.50, 21000.00),
(3, 5, 1.00, 32000.00),
(4, 1, 5.00, 18500.00),
(5, 5, 2.00, 32000.00),
(6, 2, 1.00, 21000.00),
(7, 3, 4.00, 23500.00);

INSERT INTO Anulacion_Venta (nro_comprobante, motivo_anulacion, fecha_anulacion, id_usuario) VALUES
(8, 'Cliente arrepentido antes del despacho', '2026-09-08 19:30:00', 1);

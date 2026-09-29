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

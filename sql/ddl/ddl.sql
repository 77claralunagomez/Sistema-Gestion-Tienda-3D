--Tablas independientes
CREATE TABLE Rol
(
  id_rol INT IDENTITY(1,1) NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  CONSTRAINT PK_Rol PRIMARY KEY (id_rol)
);

ALTER TABLE Rol ADD CONSTRAINT UQ_Rol_Nombre UNIQUE (nombre);

CREATE TABLE Metodo_Pago
(
  id_metodo INT IDENTITY(1,1) NOT NULL,
  nombre_metodo VARCHAR(100) NOT NULL,
  CONSTRAINT PK_MetodoPago PRIMARY KEY (id_metodo)
);

ALTER TABLE Metodo_Pago ADD CONSTRAINT UQ_MetodoPago_Nombre UNIQUE (nombre_metodo);

CREATE TABLE Estado_Consulta
(
  id_estado_consulta INT IDENTITY(1,1) NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  CONSTRAINT PK_EstadoConsulta PRIMARY KEY (id_estado_consulta)
);


CREATE TABLE Tipo_Estado_Venta 
(
	id_estado_venta INT IDENTITY (1,1) NOT NULL,
	nombre VARCHAR (50) NOT NULL,
    CONSTRAINT PK_Tipo_Estado_Venta PRIMARY KEY (id_estado_venta)

);

CREATE TABLE Categoria 
(
	codigo_categoria INT IDENTITY(1,1) NOT NULL,
	nombre_categoria VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Categoria PRIMARY KEY (codigo_categoria)

);

CREATE TABLE Marca 
(
	id_marca INT IDENTITY (1,1) NOT NULL,
	nombre_marca VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Marca PRIMARY KEY (id_marca)
);

CREATE TABLE Unidad_comercio 
(
	id_unidad INT IDENTITY (1,1) NOT NULL,
	nombre VARCHAR (50) NOT NULL,
    CONSTRAINT PK_Unidad_comercio PRIMARY KEY (id_unidad)
);

CREATE TABLE Tipo_movimiento_stock
(
	id_tipo_movimiento_stock INT IDENTITY (1,1) NOT NULL,
	nombre VARCHAR (50) NOT NULL,
    CONSTRAINT PK_Tipo_movimiento_stock PRIMARY KEY (id_tipo_movimiento_stock)
);

CREATE TABLE Proveedor 
(
	id_proveedor INT IDENTITY (1,1) NOT NULL,
	contacto VARCHAR (100) NOT NULL,
    CONSTRAINT Proveedor PRIMARY KEY (id_proveedor)
);


--Tablas dependientes
CREATE TABLE Usuario 
(
	id_usuario INT IDENTITY (1,1) NOT NULL,
	nombre VARCHAR (100) NOT NULL,
	contrasena VARCHAR (255) NOT NULL, 
	email VARCHAR (100) NOT NULL UNIQUE,
	id_rol INT NOT NULL,
	CONSTRAINT PK_Usuario PRIMARY KEY (id_usuario),
	CONSTRAINT FK_Usuario_Rol FOREIGN KEY (id_rol) REFERENCES Rol (id_rol)
);

CREATE TABLE Cliente 
(
	dni_cliente VARCHAR (20) NOT NULL, 
	nombre VARCHAR (100) NOT NULL,
	apellido VARCHAR (100) NOT NULL,
	telefono VARCHAR (20) NULL,
	correo_electronico VARCHAR (100) NULL,
	id_usuario INT NULL,
	CONSTRAINT PK_Cliente PRIMARY KEY (dni_cliente),
	CONSTRAINT FK_Cliente_Usuario FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario)
);


CREATE TABLE Consulta
(
  id_consulta INT IDENTITY(1,1) NOT NULL,
  canal VARCHAR(200) NOT NULL,
  fecha DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dni_cliente VARCHAR(20) NOT NULL,
  id_estado_consulta INT NOT NULL,
  CONSTRAINT PK_Consulta PRIMARY KEY (id_consulta),
  CONSTRAINT FK_Consulta_DniCliente FOREIGN KEY (dni_cliente) REFERENCES Cliente(dni_cliente),
  CONSTRAINT FK_Consulta_EstadoConsulta FOREIGN KEY (id_estado_consulta) REFERENCES Estado_Consulta(id_estado_consulta)
);

CREATE TABLE Producto
(
    codigo_producto INT IDENTITY(1,1) NOT NULL,
    descripcion VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    stock DECIMAL(10,2) NOT NULL,
    codigo_categoria INT NOT NULL,
    id_marca INT NOT NULL,
    id_unidad INT NOT NULL,

    CONSTRAINT PK_Producto PRIMARY KEY (codigo_producto),
    CONSTRAINT CK_Producto_Precio CHECK (precio > 0),
    CONSTRAINT CK_Producto_Stock CHECK (stock >= 0),

    CONSTRAINT FK_Producto_Categoria
        FOREIGN KEY (codigo_categoria)
        REFERENCES Categoria(codigo_categoria),

    CONSTRAINT FK_Producto_Marca
        FOREIGN KEY (id_marca)
        REFERENCES Marca(id_marca),

    CONSTRAINT FK_Producto_Unidad
        FOREIGN KEY (id_unidad)
        REFERENCES Unidad_comercio(id_unidad)
);

CREATE TABLE Proveedor_producto
(
    id_proveedor INT NOT NULL,
    codigo_producto INT NOT NULL,

    CONSTRAINT PK_Proveedor_producto
        PRIMARY KEY (id_proveedor, codigo_producto),

    CONSTRAINT FK_ProveedorProducto_Proveedor
        FOREIGN KEY (id_proveedor)
        REFERENCES Proveedor(id_proveedor),

    CONSTRAINT FK_ProveedorProducto_Producto
        FOREIGN KEY (codigo_producto)
        REFERENCES Producto(codigo_producto)
);

CREATE TABLE Venta
(
    nro_comprobante INT IDENTITY(1,1) NOT NULL,
    fecha DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_estado_venta INT NOT NULL,
    importe DECIMAL(10,2) NOT NULL,
    dni_cliente VARCHAR(20) NOT NULL,
    id_metodo INT NOT NULL,

    CONSTRAINT PK_Venta PRIMARY KEY (nro_comprobante),
    CONSTRAINT CK_Venta_Importe CHECK (importe >= 0),

    CONSTRAINT FK_Venta_Estado
        FOREIGN KEY (id_estado_venta)
        REFERENCES Tipo_Estado_Venta(id_estado_venta),

    CONSTRAINT FK_Venta_Cliente
        FOREIGN KEY (dni_cliente)
        REFERENCES Cliente(dni_cliente),

    CONSTRAINT FK_Venta_MetodoPago
        FOREIGN KEY (id_metodo)
        REFERENCES Metodo_Pago(id_metodo)
);

CREATE TABLE Detalle_Venta
(
    codigo_detalle INT IDENTITY(1,1) NOT NULL,
    nro_comprobante INT NOT NULL,
    codigo_producto INT NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    CONSTRAINT PK_Detalle_Venta PRIMARY KEY (codigo_detalle),
    CONSTRAINT FK_DetalleVenta_Venta FOREIGN KEY (nro_comprobante) REFERENCES Venta(nro_comprobante),
    CONSTRAINT FK_DetalleVenta_Producto FOREIGN KEY (codigo_producto) REFERENCES Producto(codigo_producto),
    CONSTRAINT CHK_DetalleVenta_Cantidad CHECK (cantidad > 0),
    CONSTRAINT CHK_DetalleVenta_Precio CHECK (precio_unitario >= 0)
);

CREATE TABLE Movimiento_Stock
(
    id_movimiento INT IDENTITY(1,1) NOT NULL,
    fecha DATETIME NOT NULL DEFAULT GETDATE(),
    cantidad DECIMAL(10,2) NOT NULL,
    descripcion VARCHAR(255) NULL,
    codigo_producto INT NOT NULL,
    id_tipo_movimiento_stock INT NOT NULL,
    CONSTRAINT PK_Movimiento_Stock PRIMARY KEY (id_movimiento),
    CONSTRAINT FK_MovimientoStock_Producto FOREIGN KEY (codigo_producto) REFERENCES Producto(codigo_producto),
    CONSTRAINT FK_MovimientoStock_TipoMovimiento FOREIGN KEY (id_tipo_movimiento_stock) REFERENCES Tipo_Movimiento_Stock(id_tipo_movimiento_stock),
    CONSTRAINT CHK_MovimientoStock_Cantidad CHECK (cantidad <> 0)
);

CREATE TABLE Anulacion_Venta
(
    nro_anulacion_venta INT IDENTITY(1,1) NOT NULL,
    nro_comprobante INT NOT NULL,
    motivo_anulacion VARCHAR(255) NOT NULL,
    fecha_anulacion DATETIME NOT NULL DEFAULT GETDATE(),
    id_usuario INT NOT NULL,
    CONSTRAINT PK_Anulacion_Venta PRIMARY KEY (nro_anulacion_venta),
    CONSTRAINT UQ_Anulacion_Venta_Comprobante UNIQUE (nro_comprobante),
    CONSTRAINT FK_AnulacionVenta_Venta FOREIGN KEY (nro_comprobante) REFERENCES Venta(nro_comprobante),
    CONSTRAINT FK_AnulacionVenta_Usuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

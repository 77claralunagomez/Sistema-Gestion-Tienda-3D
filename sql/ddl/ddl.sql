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
	nombre_marca VARCHAR(50) NOT NULL
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
	contacto VARCHAR (100) NOT NULL
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
  dni_cliente INT NOT NULL,
  id_estado_consulta INT NOT NULL,
  CONSTRAINT PK_Consulta PRIMARY KEY (id_consulta),
  CONSTRAINT FK_Consulta_DniCliente FOREIGN KEY (dni_cliente) REFERENCES Cliente(dni_cliente),
  CONSTRAINT FK_Consulta_EstadoConsulta FOREIGN KEY (id_estado_consulta) REFERENCES Estado_Consulta(id_estado_consulta)
);

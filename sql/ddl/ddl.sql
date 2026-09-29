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

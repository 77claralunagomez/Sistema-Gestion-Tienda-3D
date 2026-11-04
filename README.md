# Tienda3D — Sistema de Gestión de Ventas e Inventario

**Proyecto académico de Bases de Datos I — Equipo 39**  
**Motor de base de datos:** Microsoft SQL Server Express  
**Herramienta de desarrollo y administración:** SQL Server Management Studio (SSMS)

## 1. Descripción del proyecto

Tienda3D es un proyecto de base de datos relacional orientado a la administración de ventas e inventario de un comercio de insumos para impresión 3D. Su dominio comprende productos como filamentos, resinas, repuestos y herramientas, además del registro de clientes, comprobantes de venta y movimientos de existencias.

El trabajo se desarrolló en cinco etapas, desde la definición de requerimientos y el diseño del modelo relacional hasta su implementación en SQL Server y la incorporación de procedimientos almacenados, funciones, transacciones, disparadores, índices y controles de acceso.

## 2. Objetivos

- Modelar las entidades y relaciones necesarias para el funcionamiento del comercio.
- Normalizar el esquema relacional y definir restricciones de integridad.
- Registrar productos, clientes, ventas y movimientos de stock.
- Elaborar consultas e informes sobre las operaciones comerciales.
- Implementar lógica de negocio mediante T-SQL.
- Evaluar el comportamiento de procedimientos, funciones y consultas mediante pruebas.
- Administrar el acceso a la base de datos utilizando usuarios, roles y permisos.

## 3. Equipo de trabajo

**Equipo 39**

- Cuzziol, Eric Eduardo
- Gómez, Clara Luna
- Rodríguez, Geraldine Janet
- Romero García, Anabel
- Schmidke, Alejandro Nicolás

Los aportes individuales se registran en los manifiestos de contribución correspondientes a cada etapa, junto con los archivos y commits asociados.

## 4. Desarrollo por etapas

### Etapa I — Requerimientos y dominio del negocio

Se definieron el alcance del sistema y las reglas de negocio relacionadas con el catálogo, los clientes, la comercialización y el inventario. Entre los aspectos considerados se encuentran la actualización de existencias, la conservación del precio de venta, los estados de los comprobantes y las unidades de comercialización.


### Etapa II — Modelo relacional y normalización

Se desarrollaron los modelos de datos y el proceso de normalización hasta la tercera forma normal (3FN), documentando entidades, atributos, relaciones y dependencias. El diseño diferencia, entre otras, las entidades de clientes, usuarios, productos y ventas.

**Documentación:** [Etapa II](docs/etapa-02/) · [Normalización](docs/etapa-02/Normalizacion_documento.md) · [Modelo relacional](docs/etapa-02/modeloRelacional.md)

### Etapa III — Implementación física e integridad

Se elaboraron scripts DDL y DML para crear y poblar la base de datos. El esquema incorpora claves primarias y foráneas, restricciones sobre los datos y comprobaciones documentadas de integridad referencial y de dominio.

**Documentación:** [Implementación](docs/etapa-03/implementacion.md) · [Restricciones](docs/etapa-03/Restricciones-integridad.md) · [Pruebas](docs/etapa-03/pruebas-validacion.md)

**Scripts:** [DDL](sql/ddl/ddl.sql) · [Datos de prueba](sql/dml/datos_prueba.sql)

### Etapa IV — Consultas e informes comerciales

Se desarrollaron consultas para presentar comprobantes, obtener información de ventas y analizar operaciones por criterios comerciales, incluyendo agregaciones, filtros y cálculos sobre los datos registrados.

**Documentación:** [Comprobante de venta](docs/etapa-04/comprobante-venta.md) · [Consulta avanzada](docs/etapa-04/consuta-avanzada.md) · [Informe de ventas](docs/etapa-04/informe-ventas.md)

**Scripts:** [Consultas SQL](sql/consultas/)

### Etapa V — Programación y administración avanzada en T-SQL

Esta etapa integra los siguientes temas técnicos:

| Tema | Implementación | Documentación |
| --- | --- | --- |
| Procedimientos almacenados | Alta, modificación y eliminación de productos; pruebas y benchmark de inserciones | [Procedimientos y funciones](docs/etapa-05/procedimientos-funciones.md) |
| Funciones | Cálculos de importes, compras de clientes y descuentos; pruebas y benchmark | [Procedimientos y funciones](docs/etapa-05/procedimientos-funciones.md) |
| Transacciones | Registro de ventas con control transaccional y actualización de existencias | [Transacciones](docs/etapa-05/transacciones.md) |
| Triggers | Registro de operaciones de actualización y eliminación de productos en una tabla de auditoría | [Triggers y auditoría](docs/etapa-05/triggers-auditoria.md) |
| Índices | Creación y análisis de índices sobre la base de datos | [Índices](docs/etapa-05/indices.md) |
| Seguridad | Autenticación, usuarios, roles, permisos y pruebas de acceso autorizadas y denegadas | [Seguridad](docs/etapa-05/Seguridad.md) |

Los scripts y las evidencias de cada tema se encuentran en [sql/tecnico/](sql/tecnico/).

#### Seguridad: pruebas documentadas

En el módulo de Seguridad se configuraron cuentas y roles para diferenciar los permisos del administrador, el vendedor y los usuarios de consulta. Se comprobó que el administrador podía insertar una venta, mientras que el usuario vendedor no podía realizar una inserción directa en la tabla `Venta`, aunque sí ejecutar el procedimiento autorizado `sp_RegistrarVenta3D`.

También se verificaron las consultas permitidas y denegadas según los roles, así como la reversión de una operación temporal mediante `ROLLBACK`.

**Evidencias:** [Informe de Seguridad](docs/etapa-05/Seguridad.md) · [Capturas de pruebas](sql/tecnico/Seguridad/evidencias/)

## 5. Organización del repositorio

```text
Sistema-Gestion-Tienda-3D/
├── docs/
│   ├── etapa-01/             # Requerimientos y reglas de negocio
│   ├── etapa-02/             # Modelo relacional y normalización
│   ├── etapa-03/             # Implementación y restricciones
│   ├── etapa-04/             # Consultas e informes
│   └── etapa-05/             # Documentación de temas técnicos
├── sql/
│   ├── consultas/            # Consultas comerciales
│   ├── ddl/                  # Creación del esquema
│   ├── dml/                  # Datos de prueba
│   └── tecnico/
│       ├── funciones/        # Funciones y pruebas
│       ├── indices/          # Índices y evidencias
│       ├── procedimientos/   # Procedimientos y benchmarks
│       ├── Seguridad/        # Usuarios, roles, permisos y capturas
│       ├── transacciones/    # Procedimiento transaccional de ventas
│       └── triggers/         # Auditoría de productos
└── README.md
```

## 6. Requisitos y uso del proyecto

Para trabajar con la base de datos se requiere una instancia de **SQL Server** y una herramienta de ejecución de consultas, como **SQL Server Management Studio**.

Una secuencia general de preparación consiste en:

1. Crear el esquema mediante [`sql/ddl/ddl.sql`](sql/ddl/ddl.sql).
2. Cargar los registros de prueba con [`sql/dml/datos_prueba.sql`](sql/dml/datos_prueba.sql).
3. Revisar las dependencias y ejecutar los scripts técnicos necesarios desde [`sql/tecnico/`](sql/tecnico/).
4. Consultar la documentación de cada etapa antes de repetir pruebas que modifiquen datos.

**Importante:** los scripts técnicos tienen dependencias entre objetos y algunos incluyen operaciones de prueba. Se recomienda revisarlos antes de ejecutarlos y trabajar sobre una base de datos de desarrollo. Las contraseñas de ejemplo de Seguridad deben reemplazarse por credenciales seguras y no publicarse en el repositorio.

## 7. Documentación y trazabilidad

Cada etapa dispone de documentación en [`docs/`](docs/) y de scripts relacionados en [`sql/`](sql/). Los manifiestos individuales de contribución y el historial de commits permiten identificar la participación de los integrantes del equipo.

El repositorio corresponde a un **trabajo académico**. Los resultados de las pruebas documentadas se refieren al entorno utilizado para el desarrollo y no constituyen una certificación de funcionamiento en producción.

# 🚀 Tienda3D — Sistema Integral de Gestión de Ventas e Inventario

[![SQL Server](https://img.shields.io/badge/Database-SQL_Server_Express-blue.svg)](https://www.microsoft.com/sql-server/)
[![Status](https://img.shields.io/badge/Status-Production_Ready-success.svg)]()
[![Architecture](https://img.shields.io/badge/Architecture-3FN_Normalized-orange.svg)]()

> **La solución definitiva de base de datos relacional para comercios especializados en insumos de impresión 3D.** Diseñada para maximizar el control operativo, garantizar la integridad financiera de las ventas y ofrecer trazabilidad absoluta sobre el stock de filamentos, resinas y repuestos.

---

## 💎 ¿Por qué Tienda3D? (Propuesta de Valor)

En el mercado de la impresión 3D, gestionar bobinas de filamento por kilo, resinas por litro, fraccionamientos por metro y repuestos mecánicos puede convertirse en un desafío operativo. **Tienda3D** resuelve esta problemática de punta a punta mediante un motor relacional en SQL Server que garantiza:

* **Control de Stock en Tiempo Real:** Cero sobreventas y cero stock negativo gracias a reglas de integridad automatizadas.
* **Inmutabilidad Financiera:** Congelamiento automático de precios unitarios por venta, protegiendo el historial comercial ante la inflación o actualización de catálogos.
* **Seguridad Transaccional ACID:** Operaciones de venta 100% atómicas que descuentan inventario y registran movimientos en un solo paso seguro.
* **Trazabilidad y Auditoría Inmutable:** Registro automático e inalterable de quién, cuándo y qué precios o stocks se modificaron en el catálogo.

---

## 👥 Equipo de Desarrollo (Equipo 39)

* **Cuzziol**, Eric Eduardo
* **Gómez**, Clara Luna
* **Rodríguez**, Geraldine Janet
* **Romero García**, Anabel
* **Schmidke**, Alejandro Nicolás

---

## 🏗️ Descripción del Producto por Etapas

El desarrollo de **Tienda3D** abarcó un ciclo de vida de ingeniería de software estructurado en 5 etapas evolutivas:

### 📌 Etapa 1: Requerimientos y Dominio del Negocio
* **Alcance:** Gestión completa del catálogo de insumos (PLA, ABS, PETG, resinas SLA, repuestos, herramientas), administración de clientes/contactos, registro de ventas, control de inventario y atención de consultas de clientes.
* **Reglas de Negocio Clave (RN):**
  * **RN.01 & RN.12:** Descuento automático de stock e imposición estricta de stock no negativo.
  * **RN.03:** Congelamiento del precio unitario al momento exacto de la venta.
  * **RN.11 & RN.14:** Gestión formal de estados de venta (Pendiente, Confirmada, Preparada, Entregada, Anulada) con restitución de stock ante anulaciones.
  * **RN.09:** Control de inventario según la unidad de comercialización del producto (kilogramos, metros, litros, unidades).

### 📐 Etapa 2: Normalización y Diseño del Modelo Relacional
* **Arquitectura 3FN:** Estructura optimizada bajo la **Tercera Forma Normal**, eliminando la redundancia de datos y las dependencias transitivas.
* **Tablas Paramétricas:** Desacoplamiento de dominios repetitivos mediante tablas de tipo dedicadas (`Unidad_comercio`, `Tipo_movimiento_stock`, `Tipo_Estado_Venta`, `Estado_Consulta`).
* **Relaciones Flexibles:** Separación de entidades entre `Usuario` (credenciales/roles) y `Cliente` (facturación), permitiendo registrar ventas presenciales de clientes sin cuenta digital.

### 🛡️ Etapa 3: Restricciones de Integridad y Poblado Físico (DDL / DML)
* **Integridad Estructural (DDL):** Definición rigurosa con claves primarias autoincrementales (`IDENTITY`), claves foráneas explicitadas y dominios protegidos mediante `CHECK` (`precio > 0`, `stock >= 0`, `cantidad > 0`) y `UNIQUE` (`email`, códigos de catálogos).
* **Poblado Coherente (DML):** Script de carga inicial jerarquizado para asegurar el enlace de datos de prueba desde tablas independientes (Nivel 0) hasta transaccionales (Niveles 3 y 4).
* **Validaciones del Motor:** Pruebas de estrés que confirman el bloqueo del motor SQL ante intentos de inserción con precios negativos, DNI duplicados o claves foráneas inexistentes.

### 📊 Etapa 4: Informes Comerciales y Consultas de Negocio
* **Comprobantes y Facturación:** Consulta consolidada con funciones de ventana (`SUM(...) OVER(PARTITION BY)`) para obtener subtotales por renglón y el total acumulado por comprobante.
* **Inteligencia de Clientes:** Reportes analíticos agrupados para identificar clientes VIP con compras superiores a $50.000 abonadas en Efectivo o Transferencia Bancaria.
* **Reportes Agregados por Categoría:** Análisis de facturación y rotación de insumos por categoría durante rangos de fechas específicos, considerando únicamente ventas concretadas (`Entregada`).

### ⚡ Etapa 5: Programación T-SQL Avanzada (SP, Funciones, Transacciones y Triggers)
* **Procedimientos Almacenados (ABM):** Moduladores de lógica de negocio (`sp_InsertarProducto`, `sp_ModificarProducto`, `sp_EliminarProducto`) con control explícito de excepciones personalizadas (`THROW 50000+`).
* **Lógica Transaccional ACID (`sp_RegistrarVenta3D`):** Procedimiento que encapsula en un bloque `BEGIN TRAN` / `COMMIT` / `ROLLBACK`:
  1. Verificación de existencia y disponibilidad física.
  2. Inserción de cabecera de `Venta`.
  3. Inserción de ítems en `Detalle_Venta`.
  4. Descuento automático de unidades/kilos en `Producto`.
  5. Registro del egreso formal en `Movimiento_Stock`.
* **Triggers de Auditoría Inmutable:** Disparadores automáticos (`trg_Auditoria_Producto_Update` y `trg_Auditoria_Producto_Delete`) que capturan las tablas virtuales `inserted` y `deleted` para guardar en `Auditoria_Producto` el historial exacto de variaciones de precios y stock.
* **Funciones y Medición de Rendimiento:** Funciones escalares para cálculo de descuentos dinámicos e importes, complementadas con benchmarks de prueba de rendimiento T-SQL.

---

## 📂 Estructura del Repositorio

```text
Sistema-Gestion-Tienda-3D/
├── docs/                      # Documentación completa de todas las etapas
│   ├── etapa-01/             # Caso de negocio, alcance y Reglas de Negocio (RN)
│   ├── etapa-02/             # Proceso de normalización (1FN, 2FN, 3FN) y DER
│   ├── etapa-03/             # Restricciones de integridad, DDL/DML y pruebas
│   ├── etapa-04/             # Consultas de negocio e informes agregados
│   └── etapa-05/             # T-SQL avanzado: SP, Funciones, Transacciones y Triggers
├── sql/                       # Scripts SQL listos para ejecución
│   ├── ddl/                   # Script DDL de creación de tablas y restricciones
│   ├── dml/                   # Script DML de poblado con datos de prueba
│   ├── consultas/             # Reportes de facturación e informes de ventas
│   └── tecnico/               # Lógica programada en T-SQL
│       ├── funciones/         # Funciones escalares y pruebas de rendimiento
│       ├── procedimientos/    # Procedimientos almacenados para gestión de productos
│       ├── transacciones/     # SP transaccional sp_RegistrarVenta3D
│       └── triggers/          # Tabla y triggers de auditoría de catálogo
└── README.md                  # Presentación general del producto

# Implementación Física de la Base de Datos

Este documento detalla la traducción del modelo lógico (diagrama Entidad-Relación) a la estructura física en el motor de base de datos SQL Server, abarcando la definición de datos (DDL) y la carga inicial (DML).

## 1. Estrategia de Creación de Estructuras (DDL)

Para garantizar la integridad referencial y evitar errores al momento de establecer las claves foráneas (FOREIGN KEY), las tablas se crearon respetando un estricto orden jerárquico de dependencias:

*   **Tablas Independientes (Nivel 0):** Se generaron primero las entidades fuertes sin dependencias foráneas: `Rol`, `Metodo_Pago`, `Estado_Consulta`, `Tipo_Estado_Venta`, `Categoria`, `Marca`, `Unidad_comercio`, `Tipo_movimiento_stock` y `Proveedor`.
*   **Tablas Dependientes (Nivel 1):** Entidades que referencian al Nivel 0: `Usuario` (referencia a Rol) y `Producto` (referencia a Categoría, Marca y Unidad).
*   **Tablas Dependientes (Nivel 2):** Entidades que referencian al Nivel 1: `Cliente` (referencia a Usuario) y `Proveedor_producto`.
*   **Tablas Dependientes y Transaccionales (Niveles 3 y 4):** Tablas operativas que consolidan múltiples relaciones: `Consulta`, `Venta`, `Movimiento_Stock`, `Anulacion_Venta` y `Detalle_Venta`.

Todas las restricciones (`PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`) fueron declaradas explícitamente mediante la cláusula `CONSTRAINT`.

## 2. Estrategia de Poblado Inicial (DML)

Se generó un lote de datos de prueba insertando un mínimo de **8 registros coherentes** en las tablas principales del sistema (`Rol`, `Metodo_Pago`, `Producto`, `Venta`, `Cliente`, etc.). 

La ejecución de las sentencias `INSERT INTO` se planificó replicando el orden lógico del script DDL. Por ejemplo, las tablas paramétricas como `Categoria` o `Marca` se poblaron antes que `Producto`, y `Cliente` antes que `Venta`, evitando así cualquier conflicto de integridad referencial.

# Impacto de los índices en el rendimiento de las consultas

**Implementación técnica sobre el modelo Tienda3D — SQL Server**

---

## 1. Objetivo

Medir, de forma reproducible, cómo cambia el trabajo que realiza el motor de SQL Server para resolver una búsqueda por período sobre una tabla de más de un millón de registros, según la estructura de índices disponible:

| # | Escenario | Estructura de la tabla |
|---|-----------|------------------------|
| 1 | Sin índice | Heap |
| 2 | Índice agrupado sobre `fecha` | Clustered index |
| 3 | Eliminación del índice agrupado | Heap (estado inicial) |
| 4 | Índice con cobertura: clave `fecha` + `INCLUDE` | Heap + índice no agrupado de cobertura |

**Objetivos de aprendizaje cubiertos**

- Conocer los tipos de índices y sus aplicaciones (sección 3).
- Evaluar el impacto de los índices en el rendimiento de las consultas (secciones 5 a 7).

**Criterios de evaluación cubiertos**

- Medición de tiempos antes y después de aplicar índices → `SET STATISTICS TIME/IO` (sección 4).
- Documentación de los planes de ejecución → capturas de planes realesmana.
- Evaluación de la mejora → tabla comparativa y fórmulas de mejora (sección 6).

---

## 2. Entorno y adaptación al modelo

### 2.1 Entorno

| Elemento | Detalle |
|----------|---------|
| Motor | SQL Server 2016 o superior |
| Herramienta | SQL Server Management Studio (SSMS) |
| Base de datos | `Tienda3D` |

### 2.2 Tabla elegida y por qué no se usa `Venta` directamente

El enunciado pide adaptar la prueba a una tabla del modelo propio. La tabla natural es **`Venta`** (tiene un campo `fecha` y un `importe`). Sin embargo, no se carga directamente por tres razones:

1. **Tiene un índice agrupado implícito.** `PRIMARY KEY (nro_comprobante)` crea por defecto un *clustered index*. La consigna exige partir de una tabla **sin índice** y luego crear un índice agrupado sobre `fecha`; una tabla solo admite un índice agrupado, por lo que habría que destruir la PK.
2. **Tiene claves foráneas** (`Cliente`, `Metodo_Pago`, `Tipo_Estado_Venta`) y es referenciada por `Detalle_Venta` y `Anulacion_Venta`. Insertar un millón de filas la contaminaría con datos de prueba.
3. **Contiene los datos de negocio de la demo** (8 ventas), que no deben mezclarse con datos simulados.

Por eso se crea **`Venta_Historica`**, con la misma estructura de columnas que `Venta`, pero sin PK, sin FK y sin índices.

| Columna | Tipo | En `Venta` | En `Venta_Historica` |
|---------|------|------------|----------------------|
| `nro_comprobante` | `INT IDENTITY(1,1)` | PK (agrupada) | Sin PK |
| `fecha` | `DATE` | `DEFAULT CURRENT_TIMESTAMP` | Sin default (columna filtrada en las pruebas) |
| `id_estado_venta` | `INT` | FK | Sin FK |
| `importe` | `DECIMAL(10,2)` | `CHECK (importe >= 0)` | Sin check |
| `dni_cliente` | `VARCHAR(20)` | FK | Sin FK |
| `id_metodo` | `INT` | FK | Sin FK |

> Los valores de `id_estado_venta`, `dni_cliente` e `id_metodo` se toman de las tablas reales (`Tipo_Estado_Venta`, `Cliente`, `Metodo_Pago`), de modo que los datos simulados son coherentes con el modelo aunque no haya FK declarada.

### 2.3 Parámetros de la prueba

| Parámetro | Valor |
|-----------|-------|
| Registros | 1.000.000 (parámetro `@Cantidad`) |
| Rango de fechas | 2020-01-01 a 2024-12-30 (1825 días) |
| Período consultado | 2023-01-01 a 2023-03-31 (90 días son aproximadas 49.000 filas) |
| Consulta | `SELECT nro_comprobante, fecha, importe` filtrando por `fecha` |

---

## 3. Marco teórico: tipos de índices

| Tipo | Descripción | Aplicación típica |
|------|-------------|-------------------|
| **Heap** (sin índice agrupado) | Páginas de datos sin orden lógico. Cualquier búsqueda requiere recorrer toda la tabla (*Table Scan*). | Tablas pequeñas, cargas masivas. |
| **Agrupado** (*clustered*) | Estructura B-tree cuyo nivel hoja **es** la tabla: las filas se almacenan ordenadas por la clave. Solo uno por tabla. | Consultas por rango, ordenamientos, clave primaria. |
| **No agrupado** (*nonclustered*) | B-tree separado con la clave y un puntero a la fila (RID (identificador de fila) si la tabla es heap; key del indice agrupado si existe). | Búsquedas por columnas distintas de la clave agrupada. |
| **No agrupado con `INCLUDE`** | Igual que el anterior, pero el nivel hoja guarda además columnas no clave. Si contiene todas las columnas que la consulta necesita, la consulta "queda cubierta". | Consultas frecuentes que devuelven pocas columnas. |
| **Compuesto** | Clave formada por varias columnas. El orden de las columnas importa. | Filtros por más de una columna. |
| **Único** | Garantiza que no se repita la clave. | Integridad (por ejemplo, `email`). |
| **Filtrado** | Indexa solo las filas que cumplen un `WHERE`. | Subconjuntos pequeños (por ejemplo, ventas pendientes). |
| **Columnstore** | Almacenamiento por columnas con alta compresión. | Analítica sobre grandes volúmenes. |

**Operadores que aparecen en los planes**

| Operador | Significado |
|----------|-------------|
| `Table Scan` | Lee todas las páginas de un heap. |
| `Clustered Index Scan` | Lee todas las páginas de un índice agrupado. |
| `Clustered Index Seek` | Navega el B-tree hasta el primer valor del rango y lee solo las páginas necesarias. |
| `Index Seek (NonClustered)` | Lo mismo sobre un índice no agrupado. |
| `RID Lookup` / `Key Lookup` | Por cada fila encontrada en un índice no agrupado, vuelve a la tabla a buscar las columnas faltantes. Es costoso si son muchas filas. |

---

## 4. Diseño de la medición

### 4.1 Métricas registradas

| Métrica | Fuente |
|---------|--------|
| Tiempo de CPU (ms) | `SET STATISTICS TIME ON` → *SQL Server Execution Times: CPU time* |
| Tiempo total (ms) | `SET STATISTICS TIME ON` → *elapsed time* |
| Lecturas lógicas | `SET STATISTICS IO ON` → *logical reads* |
| Lecturas físicas y *read-ahead* | `SET STATISTICS IO ON` (relevantes en caché fría) |
| Operación principal | Plan de ejecución real (Ctrl+M) |
| Costo del plan | *Estimated Subtree Cost* del operador `SELECT` (raíz del plan) |
| Filas devueltas | Plan real → *Actual Number of Rows* |
| Tamaño de la estructura | `sys.dm_db_partition_stats` (páginas y MB) |

### 4.2 Condiciones para que la comparación sea válida

- **Misma consulta en los tres escenarios**: solo cambia la estructura de índices.
- **Caché fría y caliente.** La medición en frío se hace con `CHECKPOINT` + `DBCC DROPCLEANBUFFERS`, lo que obliga a leer desde disco. La medición en caliente se ejecuta sin limpiar la caché y se repite 3 veces.
- **Estadísticas ya creadas.** La verificación de la Parte 3 filtra por `fecha`, de modo que SQL Server crea la estadística de la columna antes del Escenario 1 y su costo no se suma a la medición.
- **Sin renderizado de resultados.** Se activa *Discard results after execution* para medir el motor y no el tiempo de dibujar 49.000 filas en la grilla.
- **CPU puede superar al tiempo total** cuando el plan es paralelo (suele ocurrir en el *Table Scan*). Es normal y debe indicarse en el análisis.
- **Valores dependientes del hardware.** Lo comparable es la *proporción* entre escenarios, no el valor absoluto.

---

## 5. Implementación

El script completo es `script_indices.sql`. A continuación se explican las decisiones técnicas.

### 5.1 Creación de la tabla (heap)

```sql
CREATE TABLE dbo.Venta_Historica
(
    nro_comprobante INT           IDENTITY(1,1) NOT NULL,
    fecha           DATE          NOT NULL,
    id_estado_venta INT           NOT NULL,
    importe         DECIMAL(10,2) NOT NULL,
    dni_cliente     VARCHAR(20)   NOT NULL,
    id_metodo       INT           NOT NULL
);
```

Se verifica con `sys.indexes`: debe existir una sola fila con `type_desc = HEAP`.

### 5.2 Carga masiva automatizada

Técnica utilizada:

| Elemento | Cómo funciona |
|----------|---------------|
| Secuencia de filas | `ROW_NUMBER()` sobre `sys.all_objects CROSS JOIN sys.all_objects` limitado con `TOP (@Cantidad)`. Genera millones de filas sin tablas auxiliares. |
| Fecha aleatoria | `DATEADD(DAY, ABS(CHECKSUM(NEWID()) % @DiasRango), @FechaInicio)`. `NEWID()` se evalúa por fila, por lo que cada registro recibe un valor distinto. |
| Importe aleatorio | `ABS(CHECKSUM(NEWID()) % 9999900) + 100`, dividido por `100.0` → entre 1,00 y 99.999,99. |
| Cliente, estado y método | Se numeran las filas de las tablas reales con `ROW_NUMBER()` y se reparten con aritmética modular sobre `n`. Es determinista, de modo que el total de filas insertadas es siempre exactamente `@Cantidad`. |
| Velocidad | `INSERT ... WITH (TABLOCK)` permite inserción en bloque sobre el heap. |
| Seguridad | Se aplica el módulo **antes** de `ABS` para evitar el desbordamiento aritmético de `ABS(-2147483648)`. |

El script imprime la cantidad de filas insertadas y el tiempo de carga.

### 5.3 Consulta de prueba (idéntica en todos los escenarios)

```sql
SELECT  nro_comprobante, fecha, importe
FROM    dbo.Venta_Historica
WHERE   fecha BETWEEN '2023-01-01' AND '2023-03-31';
```

### 5.4 Escenario 1 — Sin índice

La tabla es un heap, por lo que la única forma de resolver el filtro es leer todas las páginas. Plan esperado: **Table Scan**.

> Si la prueba se hiciera sobre `Venta` (con PK agrupada), el plan sería un *Clustered Index Scan* sobre `nro_comprobante`. Es el caso que menciona el enunciado ("según la estructura existente").

### 5.5 Escenario 2 — Índice agrupado sobre `fecha`

```sql
CREATE CLUSTERED INDEX IX_VentaHistorica_Fecha
    ON dbo.Venta_Historica (fecha);
```

La tabla se reorganiza físicamente ordenada por `fecha`. Plan esperado: **Clustered Index Seek** que lee únicamente las páginas del rango. No hay *lookup* porque el nivel hoja del índice agrupado contiene todas las columnas.

> Como la clave no es única, SQL Server agrega internamente un *uniquifier* de 4 bytes a las filas con clave duplicada, lo que aumenta levemente el tamaño del índice.

### 5.6 Escenario 3 — Eliminación del índice

```sql
DROP INDEX IX_VentaHistorica_Fecha ON dbo.Venta_Historica;
```

La tabla vuelve a ser un heap. Se verifica con `sys.indexes`.

### 5.7 Escenario 4 — Índice con cobertura

```sql
CREATE NONCLUSTERED INDEX IX_VentaHistorica_Fecha_Cobertura
    ON dbo.Venta_Historica (fecha)
    INCLUDE (nro_comprobante, importe);
```

La clave es `fecha` (columna del filtro) y las columnas del `SELECT` se agregan con `INCLUDE`. Plan esperado: **Index Seek (NonClustered)** sin `RID Lookup`: el motor responde leyendo únicamente el índice, que es más angosto que la tabla (3 columnas en lugar de 6).


> **Consulta idéntica.** El ejemplo del enunciado quita `id_venta` del `SELECT` en esta etapa. Aquí se mantiene la misma consulta y se agrega `nro_comprobante` al `INCLUDE`, para que la comparación entre escenarios sea justa.

### 5.8 Escenario extra (opcional) — Índice sin `INCLUDE`

Se reemplaza el índice de cobertura por uno que solo tiene la clave `fecha`:

- **Sin hint**: con ≈ 5 % de las filas, el optimizador suele descartar el índice y hacer *Table Scan*, porque ≈ 49.000 *lookups* costarían más que leer la tabla completa.
- **Con `WITH (INDEX(...))`**: se fuerza *Index Seek + RID Lookup* y se observa el aumento de lecturas lógicas.

Sirve para justificar por qué el `INCLUDE` es lo que vuelve útil al índice cuando el período abarca muchas filas.

---

## 6. Registro de resultados

> Completar con los valores medidos. Los valores absolutos dependen del hardware; lo relevante es la proporción entre escenarios.

### 6.1 Datos de la prueba

| Dato | Valor |
|------|-------|
| Registros cargados | 1000000 |
| Tiempo de carga (ms) | 6700ms |
| Páginas de la tabla (heap) | 5588 |

### 6.2 Medición en frío (caché vacía)

| Escenario | CPU (ms) | Tiempo total (ms) | Lecturas lógicas | Lecturas físicas + read-ahead | Operación principal | Estimated Subtree Cost |
|-----------|----------|-------------------|------------------|-------------------------------|---------------------|------------------------|
| 1. Sin índice | 235ms | 865ms | 5587 | 5587 | Table Scan | 5.24 |
| 2. Índice agrupado | 16ms | 1278ms | 317 | 3 + 314 | Clustered Index Seek | 0.2886 |
| 4. Índice con cobertura | 15ms | 1159ms | 187 | 2 + 184 | Index Seek (NonClustered) | 0.1931 |

### 6.3 Medición en caliente (promedio de 3 ejecuciones)

| Escenario | CPU (ms) | Tiempo total (ms) | Lecturas lógicas |
|-----------|----------|-------------------|------------------|
| 1. Sin índice | 266ms | 846ms | 5587 |
| 2. Índice agrupado | 15ms | 1176ms | 317 |
| 4. Índice con cobertura | 31ms | 1161ms | 187 |

### 6.4 Mejora respecto del escenario 1

```
Mejora (%)  = (1 - valor_con_índice / valor_sin_índice) × 100 = (1-16/235)*100 = 93.19%
Factor      = valor_sin_índice / valor_con_índice = 14.68
```

| Escenario | Mejora en lecturas lógicas | Mejora en tiempo | Factor (tiempo) |
|-----------|----------------------------|------------------------|-------------------|
| 2. Índice agrupado | 94.32 % | 93.19 % | 14.68 × |
| 4. Índice con cobertura | 96.65 % | 93.61 % | 15.66 × |


---

## 7. Conclusiones

1. **Sin índice**, el motor ejecutó un *Table Scan* y leyó las `5587` páginas de la tabla completa para devolver solo `49340` filas (≈ 4,9 % del total). El trabajo es proporcional al tamaño de la tabla, no al tamaño del resultado: a medida que la tabla crezca, la consulta empeorará aunque el período consultado sea el mismo.

2. **Con el índice agrupado sobre `fecha`**, el plan cambió a *Clustered Index Seek*. Las lecturas lógicas bajaron de `5587` a `317` (**mejora del 94.32 %**) y el tiempo de `235` ms a `16` ms. Al estar la tabla ordenada por fecha, el período buscado ocupa páginas contiguas y el motor solo las recorre. Es la mejor opción para consultas por rango sobre la columna que ordena la tabla.

3. **Con el índice de cobertura**, el motor resolvió la consulta con un *Index Seek* sin acceder a la tabla. Las lecturas bajaron a `15` ms porque el índice es más angosto: guarda 3 columnas en lugar de las 6 de la tabla, y entran más filas por página.

4. **Los índices tienen costo.** El índice agrupado reordena toda la tabla y el de cobertura ocupa `29.14` MB adicionales. Además, cada `INSERT`, `UPDATE` o `DELETE` debe mantener actualizadas todas las estructuras. Por eso no conviene indexar todas las columnas, sino diseñar los índices según las consultas más frecuentes.

5. **La selectividad condiciona el beneficio.** El período consultado representa ≈ 4,9 % de la tabla. Con porcentajes mucho mayores el optimizador puede preferir un *scan*, y un índice no agrupado sin cobertura puede dejar de ser útil por el costo de los *lookups*

6. **Conclusión general.** La elección del índice debe basarse en el plan de ejecución real y en métricas (lecturas lógicas, CPU, tiempo), no solo en el tiempo total, que depende del hardware y de la caché. En esta prueba, pasar de *Scan* a *Seek* redujo el trabajo del motor en `14.68` veces, y la cobertura lo redujo aún más.

/* ============================================================================
   DEMOSTRACIÓN DEL IMPACTO DE LOS ÍNDICES EN SQL SERVER
   ----------------------------------------------------------------------------
   Base de datos   : Tienda3D
   Tabla de prueba : dbo.Venta_Historica (misma estructura que dbo.Venta, pero
                     SIN clave primaria, SIN claves foráneas y SIN índices)
   Requisitos      : ddl.sql y datos_prueba.sql ya ejecutados en Tienda3D.
   Herramienta     : SQL Server Management Studio (SSMS) - SQL Server 2016+


   ÍNDICE
     PARTE 1      Creación de la tabla (heap, sin índices)
     PARTE 2      Carga masiva de 1.000.000 de registros
     PARTE 3      Verificación de la carga
     ESCENARIO 1  Consulta SIN índice
     ESCENARIO 2  Índice AGRUPADO sobre fecha
     ESCENARIO 3  Eliminación del índice agrupado
     ESCENARIO 4  Índice con COBERTURA (clave fecha + INCLUDE)
     FINAL        Resumen y limpieza

   ADVERTENCIA: DBCC DROPCLEANBUFFERS limpia la caché de datos de TODO el
   servidor. Usar solamente en un servidor de pruebas (requiere sysadmin).
============================================================================ */

USE Tienda3D;
GO


IF OBJECT_ID('dbo.Venta_Historica', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Venta_Historica;
    PRINT 'Tabla dbo.Venta_Historica eliminada (reinicio de la prueba).';
END
ELSE
    PRINT 'dbo.Venta_Historica no existía. Se parte desde cero.';
GO


/* ============================================================================
   PARTE 1 - CREACIÓN DE LA TABLA DE PRUEBAS
   Se replica la estructura de dbo.Venta SIN clave primaria. La PK de Venta
   crea por defecto un índice agrupado sobre nro_comprobante; para esta prueba
   la tabla debe ser un HEAP (sin ningún índice).
============================================================================ */
CREATE TABLE dbo.Venta_Historica
(
    nro_comprobante INT           IDENTITY(1,1) NOT NULL,
    fecha           DATE          NOT NULL,
    id_estado_venta INT           NOT NULL,
    importe         DECIMAL(10,2) NOT NULL,
    dni_cliente     VARCHAR(20)   NOT NULL,
    id_metodo       INT           NOT NULL
);
GO

-- Verificación: debe devolver UNA fila de tipo HEAP (index_id = 0)
SELECT  i.index_id,
        ISNULL(i.name, '(sin nombre)') AS indice,
        i.type_desc                    AS tipo
FROM    sys.indexes AS i
WHERE   i.object_id = OBJECT_ID('dbo.Venta_Historica');
GO


/* ============================================================================
   PARTE 2 - CARGA MASIVA (1.000.000 DE REGISTROS)
   - Genera una secuencia de n filas con un CROSS JOIN de sys.all_objects
     (no necesita tablas auxiliares).
   - fecha   : aleatoria entre @FechaInicio y @FechaInicio + @DiasRango - 1.
   - importe : aleatorio entre 1,00 y 99.999,99.
   - cliente / estado / método de pago: se reparten de forma uniforme usando
     los datos reales de Cliente, Tipo_Estado_Venta y Metodo_Pago.
============================================================================ */
SET NOCOUNT ON;

DECLARE @Cantidad    INT  = 1000000;        -- cantidad de registros a generar
DECLARE @FechaInicio DATE = '2020-01-01';   -- primera fecha posible
DECLARE @DiasRango   INT  = 1825;           -- 5 años (2020-01-01 a 2024-12-30)

DECLARE @CantClientes BIGINT = (SELECT COUNT(*) FROM dbo.Cliente);
DECLARE @CantEstados  BIGINT = (SELECT COUNT(*) FROM dbo.Tipo_Estado_Venta);
DECLARE @CantMetodos  BIGINT = (SELECT COUNT(*) FROM dbo.Metodo_Pago);

IF @CantClientes = 0 OR @CantEstados = 0 OR @CantMetodos = 0
BEGIN
    RAISERROR('Faltan datos de referencia. Ejecutar antes ddl.sql y datos_prueba.sql.', 16, 1);
    RETURN;
END;

DECLARE @Inicio DATETIME2 = SYSDATETIME();

;WITH Numeros AS
(
    SELECT TOP (@Cantidad)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM   sys.all_objects AS a
    CROSS JOIN sys.all_objects AS b
),
Clientes AS
(
    SELECT ROW_NUMBER() OVER (ORDER BY dni_cliente) AS rn, dni_cliente
    FROM   dbo.Cliente
),
Estados AS
(
    SELECT ROW_NUMBER() OVER (ORDER BY id_estado_venta) AS rn, id_estado_venta
    FROM   dbo.Tipo_Estado_Venta
),
Metodos AS
(
    SELECT ROW_NUMBER() OVER (ORDER BY id_metodo) AS rn, id_metodo
    FROM   dbo.Metodo_Pago
)
INSERT INTO dbo.Venta_Historica WITH (TABLOCK)
       (fecha, id_estado_venta, importe, dni_cliente, id_metodo)
SELECT  DATEADD(DAY, ABS(CHECKSUM(NEWID()) % @DiasRango), @FechaInicio),
        e.id_estado_venta,
        CAST((ABS(CHECKSUM(NEWID()) % 9999900) + 100) / 100.0 AS DECIMAL(10,2)),
        c.dni_cliente,
        m.id_metodo
FROM    Numeros  AS x
JOIN    Clientes AS c ON c.rn = ( x.n % @CantClientes) + 1
JOIN    Estados  AS e ON e.rn = ((x.n / @CantClientes) % @CantEstados) + 1
JOIN    Metodos  AS m ON m.rn = ((x.n / (@CantClientes * @CantEstados)) % @CantMetodos) + 1;

DECLARE @Filas INT = @@ROWCOUNT;

PRINT 'Filas insertadas : ' + CAST(@Filas AS VARCHAR(20));
PRINT 'Tiempo de carga   : ' + CAST(DATEDIFF(MILLISECOND, @Inicio, SYSDATETIME()) AS VARCHAR(20)) + ' ms';

SET NOCOUNT OFF;
GO


/* ============================================================================
   PARTE 3 - VERIFICACIÓN DE LA CARGA  
   Nota: el segundo SELECT filtra por fecha, por lo que SQL Server crea de
   forma automática la ESTADÍSTICA de la columna (no es un índice). Así el
   Escenario 1 no incluye ese costo de preparación en su medición.
============================================================================ */
-- 3.1 Cantidad total y rango de fechas
SELECT  COUNT(*)   AS CantidadRegistros,
        MIN(fecha) AS FechaMinima,
        MAX(fecha) AS FechaMaxima
FROM    dbo.Venta_Historica;

-- 3.2 Registros que caen en el período que se va a consultar
SELECT  COUNT(*) AS RegistrosEnElPeriodo
FROM    dbo.Venta_Historica
WHERE   fecha BETWEEN '2023-01-01' AND '2023-03-31';

-- 3.3 Distribución por año
SELECT  YEAR(fecha) AS anio, COUNT(*) AS cantidad
FROM    dbo.Venta_Historica
GROUP BY YEAR(fecha)
ORDER BY anio;

-- 3.4 Muestra de datos
SELECT TOP (10) * FROM dbo.Venta_Historica;

-- 3.5 Tamaño de la tabla (páginas de 8 KB) - base para interpretar las lecturas
SELECT  ISNULL(i.name, '(HEAP)')                              AS indice,
        i.type_desc                                           AS tipo,
        ps.row_count                                          AS filas,
        ps.used_page_count                                    AS paginas,
        CAST(ps.used_page_count * 8 / 1024.0 AS DECIMAL(10,2)) AS MB
FROM    sys.indexes AS i
JOIN    sys.dm_db_partition_stats AS ps
          ON ps.object_id = i.object_id AND ps.index_id = i.index_id
WHERE   i.object_id = OBJECT_ID('dbo.Venta_Historica');
GO


/* ============================================================================
   ESCENARIO 1 - CONSULTA SIN ÍNDICE
   Estructura actual: HEAP. Se espera Table Scan.
============================================================================ */

-- 1.A  MEDICIÓN EN FRÍO (caché de datos vacía)
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
GO

PRINT '=== ESCENARIO 1 (SIN INDICE) - EN FRIO ===';
SET STATISTICS TIME ON;
SET STATISTICS IO   ON;

SELECT  nro_comprobante, fecha, importe
FROM    dbo.Venta_Historica
WHERE   fecha BETWEEN '2023-01-01' AND '2023-03-31';

SET STATISTICS TIME OFF;
SET STATISTICS IO   OFF;
GO

-- 1.B  MEDICIÓN EN CALIENTE (datos ya en memoria; ejecutar 3 veces y promediar)
PRINT '=== ESCENARIO 1 (SIN INDICE) - EN CALIENTE ===';
SET STATISTICS TIME ON;
SET STATISTICS IO   ON;

SELECT  nro_comprobante, fecha, importe
FROM    dbo.Venta_Historica
WHERE   fecha BETWEEN '2023-01-01' AND '2023-03-31';

SET STATISTICS TIME OFF;
SET STATISTICS IO   OFF;
GO


/* ============================================================================
   ESCENARIO 2 - ÍNDICE AGRUPADO (CLUSTERED) SOBRE FECHA
   Se espera Clustered Index Seek (sin lookup: el índice ES la tabla).
============================================================================ */

-- 2.1  Crear el índice agrupado
DECLARE @Inicio DATETIME2 = SYSDATETIME();

CREATE CLUSTERED INDEX IX_VentaHistorica_Fecha
    ON dbo.Venta_Historica (fecha);

PRINT 'Tiempo de creación del índice: '
      + CAST(DATEDIFF(MILLISECOND, @Inicio, SYSDATETIME()) AS VARCHAR(20)) + ' ms';
GO

-- 2.2  Tamaño de la estructura (páginas)
SELECT  ISNULL(i.name, '(HEAP)')                              AS indice,
        i.type_desc                                           AS tipo,
        ps.row_count                                          AS filas,
        ps.used_page_count                                    AS paginas,
        CAST(ps.used_page_count * 8 / 1024.0 AS DECIMAL(10,2)) AS MB
FROM    sys.indexes AS i
JOIN    sys.dm_db_partition_stats AS ps
          ON ps.object_id = i.object_id AND ps.index_id = i.index_id
WHERE   i.object_id = OBJECT_ID('dbo.Venta_Historica');
GO

-- 2.3  MEDICIÓN EN FRÍO 
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
GO

PRINT '=== ESCENARIO 2 (INDICE AGRUPADO) - EN FRIO ===';
SET STATISTICS TIME ON;
SET STATISTICS IO   ON;

SELECT  nro_comprobante, fecha, importe
FROM    dbo.Venta_Historica
WHERE   fecha BETWEEN '2023-01-01' AND '2023-03-31';

SET STATISTICS TIME OFF;
SET STATISTICS IO   OFF;
GO

-- 2.4  MEDICIÓN EN CALIENTE (ejecutar 3 veces y promediar)
PRINT '=== ESCENARIO 2 (INDICE AGRUPADO) - EN CALIENTE ===';
SET STATISTICS TIME ON;
SET STATISTICS IO   ON;

SELECT  nro_comprobante, fecha, importe
FROM    dbo.Venta_Historica
WHERE   fecha BETWEEN '2023-01-01' AND '2023-03-31';

SET STATISTICS TIME OFF;
SET STATISTICS IO   OFF;
GO


/* ============================================================================
   ESCENARIO 3 - ELIMINACIÓN DEL ÍNDICE AGRUPADO
   La tabla vuelve a ser un HEAP.
============================================================================ */
DROP INDEX IX_VentaHistorica_Fecha ON dbo.Venta_Historica;
GO

-- Verificación: debe volver a mostrar una única fila de tipo HEAP
SELECT  i.index_id,
        ISNULL(i.name, '(sin nombre)') AS indice,
        i.type_desc                    AS tipo
FROM    sys.indexes AS i
WHERE   i.object_id = OBJECT_ID('dbo.Venta_Historica');
GO


/* ============================================================================
   ESCENARIO 4 - ÍNDICE CON COBERTURA (COVERING INDEX)
   Clave: fecha (columna del filtro).
   INCLUDE: las demás columnas que devuelve la consulta (nro_comprobante e
   importe). La consulta es EXACTAMENTE la misma de los escenarios anteriores,
   para que la comparación sea válida.
   Se espera Index Seek (NonClustered) SIN RID Lookup.

   Nota: un índice AGRUPADO no admite INCLUDE (su nivel hoja ya contiene todas
   las columnas de la tabla). El índice que "cubre" una consulta mediante
   INCLUDE es, por definición, NO AGRUPADO.
============================================================================ */

-- 4.1  Crear el índice con cobertura 
DECLARE @Inicio DATETIME2 = SYSDATETIME();

CREATE NONCLUSTERED INDEX IX_VentaHistorica_Fecha_Cobertura
    ON dbo.Venta_Historica (fecha)
    INCLUDE (nro_comprobante, importe);

PRINT 'Tiempo de creación del índice: '
      + CAST(DATEDIFF(MILLISECOND, @Inicio, SYSDATETIME()) AS VARCHAR(20)) + ' ms';
GO

-- 4.2  Tamaño de las estructuras (tabla heap + índice de cobertura)
SELECT  ISNULL(i.name, '(HEAP)')                              AS indice,
        i.type_desc                                           AS tipo,
        ps.row_count                                          AS filas,
        ps.used_page_count                                    AS paginas,
        CAST(ps.used_page_count * 8 / 1024.0 AS DECIMAL(10,2)) AS MB
FROM    sys.indexes AS i
JOIN    sys.dm_db_partition_stats AS ps
          ON ps.object_id = i.object_id AND ps.index_id = i.index_id
WHERE   i.object_id = OBJECT_ID('dbo.Venta_Historica');
GO

-- 4.3  MEDICIÓN EN FRÍO 
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
GO

PRINT '=== ESCENARIO 4 (INDICE CON COBERTURA) - EN FRIO ===';
SET STATISTICS TIME ON;
SET STATISTICS IO   ON;

SELECT  nro_comprobante, fecha, importe
FROM    dbo.Venta_Historica
WHERE   fecha BETWEEN '2023-01-01' AND '2023-03-31';

SET STATISTICS TIME OFF;
SET STATISTICS IO   OFF;
GO

-- 4.4  MEDICIÓN EN CALIENTE (ejecutar 3 veces y promediar)
PRINT '=== ESCENARIO 4 (INDICE CON COBERTURA) - EN CALIENTE ===';
SET STATISTICS TIME ON;
SET STATISTICS IO   ON;

SELECT  nro_comprobante, fecha, importe
FROM    dbo.Venta_Historica
WHERE   fecha BETWEEN '2023-01-01' AND '2023-03-31';

SET STATISTICS TIME OFF;
SET STATISTICS IO   OFF;
GO

/* ============================================================================
   FINAL - RESUMEN Y LIMPIEZA
============================================================================ */
-- Estado actual de las estructuras de la tabla
SELECT  ISNULL(i.name, '(HEAP)')                              AS indice,
        i.type_desc                                           AS tipo,
        ps.row_count                                          AS filas,
        ps.used_page_count                                    AS paginas,
        CAST(ps.used_page_count * 8 / 1024.0 AS DECIMAL(10,2)) AS MB
FROM    sys.indexes AS i
JOIN    sys.dm_db_partition_stats AS ps
          ON ps.object_id = i.object_id AND ps.index_id = i.index_id
WHERE   i.object_id = OBJECT_ID('dbo.Venta_Historica');
GO

-- Limpieza (descomentar cuando ya no se necesite la tabla de prueba):
-- DROP TABLE dbo.Venta_Historica;
-- GO

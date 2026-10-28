# Procedimientos Almacenados y Funciones

## 1. Objetivo

Implementar y probar procedimientos almacenados y funciones definidas por el usuario en SQL Server, aplicados a operaciones frecuentes del sistema *Tienda3D*. Se busca reutilizar lógica, validar datos y centralizar cálculos relacionados con productos, ventas y clientes.

## 2. Objetos SQL implementados

### 2.1. Procedimientos almacenados

Un procedimiento almacenado es un conjunto de instrucciones SQL guardado en la base de datos y ejecutable por su nombre. Se implementaron tres procedimientos para administrar productos.

| Procedimiento | Objetivo | Validaciones y comportamiento |
|---|---|---|
| `dbo.sp_InsertarProducto` | Insertar un producto nuevo. | Recibe descripción, precio, nombre, stock y las claves de categoría, marca y unidad. El código se genera automáticamente. Rechaza precios nulos o menores o iguales a cero y stocks nulos o negativos. |
| `dbo.sp_ModificarProducto` | Modificar el precio y el stock de un producto. | Valida que el precio sea mayor que cero, que el stock no sea nulo ni negativo y que el producto exista. |
| `dbo.sp_EliminarProducto` | Eliminar un producto existente. | Comprueba que el producto exista antes de eliminarlo. Las pruebas se hicieron con productos temporales sin registros relacionados. |

### 2.2. Funciones definidas por el usuario

Una función definida por el usuario encapsula un cálculo o una consulta y devuelve un valor. Se implementaron tres funciones escalares.

| Función | Objetivo | Comportamiento |
|---|---|---|
| `dbo.CalcularTotalComprasCliente(@DniCliente)` | Calcular el total de compras de un cliente. | Suma los importes de las ventas confirmadas, preparadas y entregadas. Excluye las pendientes y anuladas. Devuelve cero si no hay ventas que cumplan el criterio. |
| `dbo.CalcularDescuento(@DniCliente)` | Calcular la tasa de descuento según el total de compras. | Considera los mismos estados de venta que la función anterior. Devuelve `0.10` si el total supera $500.000; `0.05` si supera $200.000; de lo contrario, `0.00`. |
| `dbo.CalcularImporteVenta(@PrecioUnitario, @Cantidad)` | Calcular el importe de una venta. | Multiplica el precio unitario por la cantidad; devuelve `NULL` si alguno de los parámetros es negativo. |

**Nota:** las funciones `CalcularTotalComprasCliente` y `CalcularDescuento` utilizan `Venta.importe`, es decir, los importes finales guardados en la tabla. Ambas consideran únicamente las ventas con estado Confirmada (2), Preparada (3) o Entregada (4).

## 3. Aplicación en Tienda3D

- **Reutilización:** los procedimientos guardan la lógica de inserción, modificación y eliminación para ejecutarla de forma consistente.
- **Validación:** se impide ingresar precios nulos o menores o iguales a cero y stocks nulos o negativos. También se verifica la existencia del producto antes de modificarlo o eliminarlo.
- **Cálculos centralizados:** las funciones permiten obtener el total de compras, calcular descuentos y calcular importes.
- **Consistencia:** las funciones de total de compras y descuento aplican el mismo criterio para considerar los estados de las ventas.
- **Mantenimiento:** centralizar reglas y cálculos reduce la duplicación de lógica.
- **Permisos:** SQL Server permite conceder permisos de ejecución sobre procedimientos sin dar acceso directo a todas las tablas, si la seguridad se configura adecuadamente.

## 4. Organización de los scripts SQL

Los scripts se organizan en el repositorio en las siguientes carpetas.

### 4.1. Procedimientos almacenados

Ruta: `sql/tecnico/procedimientos/`

| Archivo | Descripción |
|---|---|
| `sp_InsertarProducto.sql` | Creación del procedimiento de inserción. |
| `sp_ModificarProducto.sql` | Creación del procedimiento de modificación. |
| `sp_EliminarProducto.sql` | Creación del procedimiento de eliminación. |
| `Pruebas_Procedimientos.sql` | Pruebas funcionales de los procedimientos. |
| `Benchmark_Inserciones.sql` | Medición comparativa de inserciones. |

### 4.2. Funciones

Ruta: `sql/tecnico/funciones/`

| Archivo | Descripción |
|---|---|
| `CalcularTotalComprasCliente.sql` | Creación de la función de total de compras. |
| `CalcularImporteVenta.sql` | Creación de la función de cálculo de importe. |
| `CalcularDescuento.sql` | Creación de la función de descuento. |
| `Pruebas_Funciones.sql` | Pruebas de las funciones. |
| `Benchmark_Funcion_Importe.sql` | Comparación del cálculo directo frente a la función escalar. |

## 5. Pruebas funcionales de los procedimientos

### 5.1. Inserción directa

Se insertaron tres productos temporales mediante una única sentencia `INSERT` directa. Los códigos generados fueron 7, 8 y 9. Se verificaron sus nombres, precios y stocks.

### 5.2. Inserción mediante procedimiento

Se insertaron tres productos mediante `dbo.sp_InsertarProducto`. Los códigos generados fueron 10, 11 y 12. El procedimiento devolvió el mensaje de inserción correcta para cada producto.

### 5.3. Modificación mediante procedimiento

Los productos insertados mediante el procedimiento se modificaron con `dbo.sp_ModificarProducto`. Los valores finales fueron:

| Código | Producto de prueba | Precio final | Stock final |
|---:|---|---:|---:|
| 10 | Prueba procedimiento Etapa V A | $19.000,00 | 6 |
| 11 | Prueba procedimiento Etapa V B | $23.000,00 | 5 |
| 12 | Prueba procedimiento Etapa V C | $26.000,00 | 4 |

### 5.4. Eliminación mediante procedimiento

Los productos 10, 11 y 12 se eliminaron mediante `dbo.sp_EliminarProducto`. La consulta posterior no devolvió filas para esos códigos. Antes de eliminarlos se comprobó que no tuvieran registros relacionados en `Detalle_Venta`, `Movimiento_Stock` ni `Proveedor_producto`.

### 5.5. Prueba transaccional

Se ejecutó una prueba de inserción, modificación y eliminación de un producto temporal dentro de una transacción que finalizó con `ROLLBACK`. Se observaron los resultados de cada operación y luego se deshicieron los cambios, por lo que el producto temporal no quedó guardado.

## 6. Resultados de las funciones

### 6.1. Total de compras y descuentos

Después de corregir las funciones para excluir las ventas pendientes y anuladas, se ejecutaron nuevamente las consultas de prueba.

| DNI de cliente | Total de compras consideradas | Descuento obtenido |
|---|---:|---:|
| 20123456 | $33.000,00 | 0 % |
| 25654321 | $44.000,00 | 0 % |
| 28777888 | $41.000,00 | 0 % |
| 30987654 | $0,00 | 0 % |
| 31999000 | $0,00 | 0 % |
| 35111222 | $0,00 | 0 % |
| 40333444 | $0,00 | 0 % |
| 42555666 | $0,00 | 0 % |

Para el cliente `20123456`, se identificó una venta pendiente de $36.000 y una venta entregada de $33.000. La función corregida consideró únicamente la venta entregada, por lo que devolvió un total de $33.000 y un descuento del 0 %.

Los descuentos obtenidos fueron del 0 % porque los totales considerados no superaban los umbrales establecidos.

### 6.2. Cálculo del importe de venta

| Precio unitario | Cantidad | Importe calculado |
|---:|---:|---:|
| $18.000,00 | 2 | $36.000,00 |
| $2.500,00 | 4 | $10.000,00 |

Ambos resultados coinciden con el cálculo esperado.

### 6.3. Verificación de los umbrales de descuento

Se verificó la lógica de los porcentajes mediante una consulta con importes de prueba:

| Total acumulado de prueba | Descuento esperado | Resultado obtenido |
|---:|---:|---:|
| $150.000,00 | 0 % | `0.00` |
| $200.000,00 | 0 % | `0.00` |
| $200.001,00 | 5 % | `0.05` |
| $500.000,00 | 5 % | `0.05` |
| $500.001,00 | 10 % | `0.10` |

Los cinco resultados coincidieron con las reglas establecidas. Esta consulta verificó la lógica de los umbrales mediante una expresión `CASE`; no constituyó una ejecución directa de `dbo.CalcularDescuento` para cada importe.

## 7. Comparación de rendimiento

Los tiempos se midieron en microsegundos y corresponden a ejecuciones concretas. Pueden variar según las condiciones del sistema, el plan de ejecución y la versión de SQL Server.

### 7.1. Inserciones directas frente a procedimiento auxiliar

| Prueba | Tiempo medido |
|---|---:|
| `INSERT` directo: 1.000 registros en una sentencia | 343.443 microsegundos |
| Procedimiento auxiliar: 1.000 llamadas individuales | 322.693 microsegundos |

En esta ejecución, las llamadas al procedimiento auxiliar registraron aproximadamente un 6,0 % menos de tiempo. Sin embargo, las pruebas no son estrictamente equivalentes: una realiza una inserción por lote y la otra ejecuta 1.000 llamadas individuales. Además, el procedimiento auxiliar de benchmark no incluye todas las validaciones de `dbo.sp_InsertarProducto`. Por lo tanto, el resultado no demuestra que los procedimientos almacenados sean siempre más rápidos.

### 7.2. Multiplicación directa frente a función escalar

| Prueba | Tiempo medido |
|---|---:|
| Multiplicación directa: 100.000 operaciones | 203.129 microsegundos |
| `dbo.CalcularImporteVenta`: 100.000 operaciones | 1.043.264 microsegundos |

En esta ejecución, la función escalar tardó aproximadamente 5,14 veces más que la multiplicación directa. Para una operación aritmética simple y repetida, la llamada a una función puede agregar costo. Las funciones siguen siendo útiles para centralizar la lógica y mantener consistencia.

## 8. Ventajas y aplicaciones

- **Reutilización:** la lógica se define una vez y se ejecuta cuando es necesaria.
- **Validación:** los procedimientos controlan los valores de precio y stock y la existencia de productos.
- **Consistencia:** las funciones centralizan cálculos de importes, totales y descuentos.
- **Mantenimiento:** los cambios en las reglas pueden realizarse en los objetos correspondientes, en lugar de duplicarse en muchas consultas.

## 9. Conclusiones

Se implementaron y probaron tres procedimientos almacenados para insertar, modificar y eliminar productos, junto con tres funciones para calcular el total de compras, la tasa de descuento y el importe de venta.

Durante las pruebas se corrigieron las funciones `CalcularTotalComprasCliente` y `CalcularDescuento` para que consideraran únicamente las ventas confirmadas, preparadas y entregadas. También se reforzaron las validaciones de precio y stock en los procedimientos de inserción y modificación de productos.

Las pruebas con el cliente `20123456` confirmaron un total acumulado de $33.000 y un descuento del 0 %. La consulta de prueba de umbrales produjo los resultados esperados para los descuentos del 0 %, 5 % y 10 %, aunque esa consulta verificó la lógica de los porcentajes y no ejecutó directamente la función almacenada para cada importe.

Las mediciones muestran que el rendimiento depende del tipo de operación y de cómo se diseñe la comparación. La función escalar fue más lenta que la multiplicación directa en la prueba realizada. La comparación de inserciones no fue equivalente, por lo que debe interpretarse con cautela.

En conjunto, los procedimientos y funciones aportan reutilización, validación y mantenimiento de la lógica del sistema. Su impacto en el rendimiento debe evaluarse mediante pruebas controladas y comparables.

## 10. Evidencias de ejecución

Las capturas de SQL Server Management Studio documentan:

1. La existencia de los tres procedimientos almacenados y las tres funciones.
2. Los resultados de las funciones de total de compras, descuentos e importes.
3. La inserción, modificación y eliminación de un producto temporal.
4. La verificación de los umbrales de descuento del 0 %, 5 % y 10 %.
5. Los resultados de las dos pruebas de rendimiento.

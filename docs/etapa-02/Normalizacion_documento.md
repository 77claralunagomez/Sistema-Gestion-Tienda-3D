# Documentación de Normalización de Base de Datos

Este documento describe el proceso de normalización aplicado al modelo de base de datos relacional, abarcando la **Primera Forma Normal (1FN)**, **Segunda Forma Normal (2FN)** y **Tercera Forma Normal (3FN)**.

---

## 3. Proceso de Normalización

La normalización es un proceso que permite organizar los datos de una base de datos con el objetivo de reducir la redundancia, evitar inconsistencias y facilitar el mantenimiento de la información.

Para el modelo desarrollado se aplican las tres primeras formas normales:
* **Primera Forma Normal (1FN)**
* **Segunda Forma Normal (2FN)**
* **Tercera Forma Normal (3FN)**

---

### 3.1 Primera Forma Normal (1FN)

Una relación se encuentra en **Primera Forma Normal** cuando todos sus atributos contienen **valores atómicos**, es decir, cada campo almacena un único valor y no existen grupos repetitivos de atributos.

En el modelo propuesto se cumple esta condición debido a que los datos se encuentran separados en diferentes entidades según su función.

#### Ejemplos:

* **Cliente:** `(dni_cliente, nombre, apellido, teléfono, correo_electronico)`  
  *Cada atributo contiene un único valor correspondiente a un cliente.*

* **Producto:** `(codigo_producto, descripción, precio, nombre, unidad_comercio, stock, codigo_categoria, id_marca)`  
  *Los datos de los productos también se encuentran almacenados de manera atómica.*

Además, las ventas y sus productos se encuentran separados mediante las tablas `Venta` y `Detalle_Venta`, evitando almacenar varios productos dentro de un mismo registro de venta.

> **Criterios de cumplimiento 1FN:**
> - [x] No existen grupos repetitivos.
> - [x] Los atributos contienen valores atómicos.
> - [x] Cada registro puede identificarse mediante una clave primaria.
> - [x] La información se encuentra organizada en tablas independientes.

---

### 3.2 Segunda Forma Normal (2FN)

Una relación se encuentra en **Segunda Forma Normal** cuando cumple con la **1FN** y, además, todos los atributos que no forman parte de una clave dependen de la totalidad de la clave primaria, eliminando las dependencias funcionales parciales.

En el modelo existen algunas tablas que utilizan claves compuestas, principalmente las relacionadas con relaciones entre entidades:

* **`Proveedor_producto`**: Relaciona proveedores con productos.
  * Atributos: `id_proveedor` (FK), `codigo_producto` (FK)
  * La combinación de `id_proveedor` y `codigo_producto` permite identificar la relación entre un determinado proveedor y producto. Como no existen atributos no clave que dependan solamente de uno de los componentes de la clave, no se presentan dependencias parciales.

* **`Utiliza`**: Relaciona una venta con un método de pago.
  * Atributos: `nro_comprobante` (FK), `id_metodo` (FK)
  * En este caso tampoco existen atributos no clave que dependan parcialmente de la clave.

* **`Detalle_Venta`**: La información correspondiente a cada producto vendido se encuentra separada de la información general de la venta.
  * Atributos: `codigo_detalle` (PK), `nro_comprobante` (FK), `cantidad`, `precio_unitario`, `codigo_producto` (FK)
  * Esto permite evitar que los datos propios de una venta o de un producto se repitan innecesariamente.

> **Criterio de cumplimiento 2FN:**  
> Cumple con la 2FN ya que no existen dependencias funcionales parciales en las relaciones con claves compuestas.

---

### 3.3 Tercera Forma Normal (3FN)

Una relación se encuentra en **Tercera Forma Normal** cuando cumple con la **2FN** y, además, no existen dependencias transitivas (los atributos no clave deben depender directamente de la clave primaria y no de otro atributo no clave).

En el modelo se separaron diferentes datos que podrían generar dependencias transitivas. Por ejemplo, en la tabla `Producto` no se almacena el nombre de la categoría ni el nombre de la marca; en su lugar, se utilizan claves foráneas:

* **`Producto`**: `(codigo_producto [PK], descripción, precio, nombre, stock, codigo_categoria [FK], id_marca [FK], id_unidad [FK])`
* **`Categoria`**: `(codigo_categoria [PK], nombre_categoria)`
* **`Marca`**: `(id_marca [PK], nombre_marca)`

De esta manera, el nombre de una categoría depende de `codigo_categoria` y el nombre de una marca depende de `id_marca`, evitando almacenar estos datos repetidamente en cada producto.

#### Tablas de tipo incorporadas en la 3FN

Además de lo anterior, se detectaron atributos descriptivos que se almacenaban directamente como texto (`varchar`) dentro de las tablas principales y que en realidad representan un **conjunto acotado de valores válidos del sistema**. Estos valores se repetían en numerosos registros y no aportaban información propia de la clave primaria de la tabla que los contenía, por lo que fueron separados en **tablas de tipo** relacionadas mediante claves foráneas.

Las tablas de tipo agregadas son las siguientes:

* **`Unidad_Comercio`**: `(id_unidad [PK], nombre)`
  * Contiene los diferentes tipos de unidades en las que se comercializan los productos.
  * Anteriormente, la unidad de comercio se guardaba como texto repetido en la columna `unidad_comercio` de la tabla `Producto`. Al separarla, se elimina ese dato redundante y se permite definir tipos específicos predefinidos en el sistema, evitando la carga de valores arbitrarios o escritos de distinta forma.
  * `Producto` pasa a referenciarla mediante la clave foránea `id_unidad`.

* **`Tipo_Movimiento_Stock`**: `(id_tipo_movimiento_stock [PK], nombre)`
  * Contiene los diferentes tipos de movimientos soportados durante los movimientos de stock.
  * Evita almacenar ese dato de manera repetitiva como `varchar` en la columna `tipo` de la tabla `Movimiento_Stock` y permite definir tipos específicos predefinidos en el sistema.
  * `Movimiento_Stock` pasa a referenciarla mediante la clave foránea `id_tipo_movimiento_stock`.

* **`Tipo_Estado_Venta`**: `(id_estado_venta [PK], nombre)`
  * Contiene los diferentes estados posibles por los cuales puede pasar una venta.
  * Evita almacenar ese dato de manera repetitiva como `varchar` en la columna `estado_venta` de la tabla `Venta` y permite definir estados específicos predefinidos en el sistema.
  * `Venta` pasa a referenciarla mediante la clave foránea `id_estado_venta`.

* **`Estado_Consulta`**: `(id_estado_consulta [PK], nombre)`
  * Contiene los diferentes estados posibles por los cuales puede pasar una consulta.
  * Evita almacenar ese dato de manera repetitiva como `varchar` en la columna `estado` de la tabla `Consulta` y permite definir estados específicos predefinidos en el sistema.
  * `Consulta` pasa a referenciarla mediante la clave foránea `id_estado_consulta`.

En todos los casos, el nombre descriptivo del tipo o estado deja de depender de la clave primaria de la tabla principal (`codigo_producto`, `id_movimiento`, `nro_comprobante` o `id_consulta`) y pasa a depender únicamente de la clave primaria de su propia tabla de tipo, eliminando así la dependencia transitiva y la repetición del mismo texto en múltiples registros.

#### Dependencias directas identificadas:
* `Proveedor`: `id_proveedor` $\rightarrow$ `contacto`
* `Metodo_Pago`: `id_metodo` $\rightarrow$ `nombre_metodo`
* `Categoria`: `codigo_categoria` $\rightarrow$ `nombre_categoria`
* `Marca`: `id_marca` $\rightarrow$ `nombre_marca`
* `Unidad_Comercio`: `id_unidad` $\rightarrow$ `nombre`
* `Tipo_Movimiento_Stock`: `id_tipo_movimiento_stock` $\rightarrow$ `nombre`
* `Tipo_Estado_Venta`: `id_estado_venta` $\rightarrow$ `nombre`
* `Estado_Consulta`: `id_estado_consulta` $\rightarrow$ `nombre`

> **Criterio de cumplimiento 3FN:**  
> Todos los atributos descriptivos dependen directamente de la clave primaria de su propia tabla, eliminando dependencias transitivas. Los valores que representan categorías, unidades, tipos o estados se administran mediante tablas de tipo referenciadas por claves foráneas, evitando su almacenamiento repetido como texto libre.

---

### 3.4 Resultado de la Normalización

Luego de aplicar las tres formas normales, el modelo de datos final queda organizado en las siguientes esquemas relacionales:

```sql
Cliente (dni_cliente [PK], nombre, apellido, teléfono, correo_electronico)

Consulta (id_consulta [PK], canal, fecha, dni_cliente [FK], id_estado_consulta [FK])

Estado_Consulta (id_estado_consulta [PK], nombre)

Venta (nro_comprobante [PK], fecha, importe, dni_cliente [FK], id_estado_venta [FK])

Tipo_Estado_Venta (id_estado_venta [PK], nombre)

Detalle_Venta (codigo_detalle [PK], nro_comprobante [FK], cantidad, precio_unitario, codigo_producto [FK])

Metodo_Pago (id_metodo [PK], nombre_metodo)

Utiliza (nro_comprobante [FK], id_metodo [FK])

Producto (codigo_producto [PK], descripción, precio, nombre, stock, codigo_categoria [FK], id_marca [FK], id_unidad [FK])

Unidad_Comercio (id_unidad [PK], nombre)

Categoria (codigo_categoria [PK], nombre_categoria)

Marca (id_marca [PK], nombre_marca)

Movimiento_Stock (id_movimiento [PK], fecha, cantidad, codigo_producto [FK], id_tipo_movimiento_stock [FK])

Tipo_Movimiento_Stock (id_tipo_movimiento_stock [PK], nombre)

Proveedor (id_proveedor [PK], contacto)

Proveedor_producto (id_proveedor [FK], codigo_producto [FK])
```

> **Entonces:**  
> La base de datos queda estructurada evitando la duplicación innecesaria de información y reduciendo la posibilidad de inconsistencias. Cada entidad almacena únicamente la información correspondiente y las relaciones se establecen mediante Claves Primarias (PK) y Claves Foráneas (FK). Las tablas de tipo (`Unidad_Comercio`, `Tipo_Movimiento_Stock`, `Tipo_Estado_Venta` y `Estado_Consulta`) permiten además restringir los valores posibles a los tipos predefinidos por el sistema.

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

* **`Producto`**: `(codigo_producto [PK], descripción, precio, nombre, unidad_comercio, stock, codigo_categoria [FK], id_marca [FK])`
* **`Categoria`**: `(codigo_categoria [PK], nombre_categoria)`
* **`Marca`**: `(id_marca [PK], nombre_marca)`

De esta manera, el nombre de una categoría depende de `codigo_categoria` y el nombre de una marca depende de `id_marca`, evitando almacenar estos datos repetidamente en cada producto.

#### Dependencias directas identificadas:
* `Proveedor`: `id_proveedor` $\rightarrow$ `contacto`
* `Metodo_Pago`: `id_metodo` $\rightarrow$ `nombre_metodo`
* `Categoria`: `codigo_categoria` $\rightarrow$ `nombre_categoria`
* `Marca`: `id_marca` $\rightarrow$ `nombre_marca`

> **Criterio de cumplimiento 3FN:**  
> Todos los atributos descriptivos dependen directamente de la clave primaria de su propia tabla, eliminando dependencias transitivas.

---

### 3.4 Resultado de la Normalización

Luego de aplicar las tres formas normales, el modelo de datos final queda organizado en las siguientes esquemas relacionales:

```sql
Cliente (dni_cliente [PK], nombre, apellido, teléfono, correo_electronico)

Consulta (id_consulta [PK], estado, canal, fecha, dni_cliente [FK])

Venta (nro_comprobante [PK], fecha, estado_venta, importe, dni_cliente [FK])

Detalle_Venta (codigo_detalle [PK], nro_comprobante [FK], cantidad, precio_unitario, codigo_producto [FK])

Metodo_Pago (id_metodo [PK], nombre_metodo)

Utiliza (nro_comprobante [FK], id_metodo [FK])

Producto (codigo_producto [PK], descripción, precio, nombre, unidad_comercio, stock, codigo_categoria [FK], id_marca [FK])

Categoria (codigo_categoria [PK], nombre_categoria)

Marca (id_marca [PK], nombre_marca)

Movimiento_Stock (id_movimiento [PK], fecha, tipo, cantidad, codigo_producto [FK])

Proveedor (id_proveedor [PK], contacto)

Proveedor_producto (id_proveedor [FK], codigo_producto [FK])
```

> **Entonces:**  
> La base de datos queda estructurada evitando la duplicación innecesaria de información y reduciendo la posibilidad de inconsistencias. Cada entidad almacena únicamente la información correspondiente y las relaciones se establecen mediante Claves Primarias (PK) y Claves Foráneas (FK).

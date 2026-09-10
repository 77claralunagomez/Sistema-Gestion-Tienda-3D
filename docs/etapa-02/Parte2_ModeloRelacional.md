# Modelo Relacional - Parte 2

### Tablas definidas:
* *Producto* (PK: codigo_producto, descripcion, precio, nombre, unidad_comercio, stock, FK: codigo_categoria, FK: id_marca)
* *Movimiento_Stock* (PK: id_movimiento, fecha, tipo, cantidad, FK: codigo_producto)
* *Proveedor* (PK: id_proveedor, contacto)
* *Proveedor_producto* (FK: id_proveedor, FK: codigo_producto)
* *Marca* (PK: id_marca, nombre_marca)
* *Categoria* (PK: codigo_categoria, nombre_categoria)

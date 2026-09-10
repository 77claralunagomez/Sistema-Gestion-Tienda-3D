# Modelo Relacional - Parte 1

Mi diagrama

### Tablas definidas:
* **Cliente** (PK: `dni_cliente`, nombre, apellido, telefono, correo_electronico)
* **Consulta** (PK: `id_consulta`, Estado, Canal, fecha, FK: `dni_cliente`)
* **Venta** (PK: `nro_comprobante`, fecha, estado_venta, importe, FK: `dni_cliente`)
* **MetodoPago** (PK: `id_metodo`, nombre_metodo)
* **Utiliza** (FK: `nro_comprobante`, FK: `id_metodo`)
* **Categoria** (PK: `codigo_categoria`, nombre_categoria)

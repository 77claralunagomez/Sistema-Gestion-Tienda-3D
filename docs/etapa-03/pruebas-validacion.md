# Pruebas de Validación

Se diseñaron los siguientes escenarios para demostrar que las estructuras físicas y las reglas de negocio funcionan correctamente ante operaciones válidas e inválidas.

## 1. Validación de Inserción (Camino Feliz)
*   *Acción:* Ejecución secuencial del script DML, desde las tablas paramétricas (Rol, Categoria) hasta las transaccionales (Detalle_Venta, Anulacion_Venta).
*   *Resultado:* Inserción exitosa de 8 registros por entidad principal, confirmando que las relaciones de claves foráneas están correctamente definidas y enlazadas.

## 2. Validación de Reglas de Negocio (Bloqueos del Motor)
Se formularon intentos de manipulación de datos (DML) para verificar las restricciones estructurales:

*   *Violación de UNIQUE:*
    *   Prueba: Intentar insertar en Metodo_Pago un registro con el nombre "Efectivo" (ya existente).
    *   Resultado: Bloqueo por la restricción UQ_MetodoPago_Nombre.
*   *Violación de CHECK (Cantidades/Precios):*
    *   Prueba: Ejecutar un INSERT en Producto asignándole un precio de -1500.00 o stock -5.
    *   Resultado: Transacción rechazada por CK_Producto_Precio y CK_Producto_Stock.
*   *Violación de Integridad Referencial (FK):*
    *   Prueba: Cargar una Venta asignando un id_metodo = 99, el cual no existe en la tabla Metodo_Pago.
    *   Resultado: Fallo inmediato por violación de la clave foránea FK_Venta_MetodoPago.
*   *Validación de Fechas Automáticas (DEFAULT):*
    *   Prueba: Insertar una Consulta proporcionando solo canal, dni_cliente e id_estado_consulta, omitiendo la fecha.
    *   Resultado: El registro se inserta exitosamente, autocompletando la columna fecha con el día en curso gracias a CURRENT_TIMESTAMP.

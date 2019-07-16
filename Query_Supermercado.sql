/*
--BASE DE DATOS: MISUPER
--EQUIPO DESARROLLADOR : TECHNOCODE
*/

USE tempdb
GO


 alter database SUPERMERCADO set single_user with rollback immediate

IF EXISTS(SELECT * FROM sys.databases WHERE name='SUPERMERCADO')
BEGIN
	DROP DATABASE SUPERMERCADO;
END
GO

CREATE DATABASE SUPERMERCADO
ON PRIMARY
(
	NAME='SUPERMERCADO_DATA',
	FILENAME='C:\supermercadoMiSuper\SUPERMERCADO_DATA.mdf',
	SIZE=10MB,
	MAXSIZE=800MB,
	FILEGROWTH=5MB
)
LOG ON
(
	NAME='SUPERMERCADO_LOG',
	FILENAME='C:\supermercadoMiSuper\SUPERMERCADO_LOG.ldf',
	SIZE=10MB,
	MAXSIZE=600MB,
	FILEGROWTH=5MB
)
GO

USE SUPERMERCADO
GO


CREATE SCHEMA PRODUCTO 
GO

CREATE SCHEMA PERSONA
GO

CREATE SCHEMA REGISTRO
GO

CREATE TABLE PERSONA.Cliente
(
 idCliente INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
 nombreCliente NVARCHAR(50) NOT NULL,
 apellidoCliente NVARCHAR(80) NOT NULL,
 identidad NVARCHAR(15) NOT NULL,
 estadoCliente VARCHAR (20)  DEFAULT ('ACTIVO/A') NULL,
 vecesCompra INT NULL,
 sexo CHAR(1) NOT NULL,
 telefono CHAR(9) NULL,
 direccion TEXT NULL,
 correoCliente NVARCHAR(80) NULL
)

CREATE TABLE PERSONA.Empleado
(
 idEmpleado INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
 nombreEmpleado NVARCHAR(50) NOT NULL,
 apellidoEmpleado NVARCHAR(80) NOT NULL,
 fechaIngreso NVARCHAR(8) NOT NULL,
 puesto NVARCHAR(60) NOT NULL,
 estadoEmpleado VARCHAR (20)  DEFAULT ('ACTIVO/A') NULL,
 sexo CHAR(1) NOT NULL,
 telefono CHAR(9) NULL,
 direccion TEXT NOT NULL,
 correoEmpleado NVARCHAR(80) NOT NULL
)

CREATE TABLE PERSONA.Usuario
( 
 idUsuario INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
 nombreUsuario NVARCHAR(25) NOT NULL,
 passwordUsuario NVARCHAR(12) NOT NULL,
 estadoUsuario VARCHAR (20)  DEFAULT ('ACTIVO/A') NULL,
 nivelUsuario NVARCHAR(15) NOT NULL
)

CREATE TABLE PRODUCTO.Proveedor
(
 idProveedor INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
 nombreProveedor NVARCHAR(50) NOT NULL,
 telefonoProveedor CHAR(9) NOT NULL,
 celularProveedor CHAR(9) NULL,
 direccionProveedor TEXT NOT NULL,
 descripcionProveedor TEXT NULL,
 estadoProveedor VARCHAR (20)  DEFAULT ('ACTIVO/A') NULL,
 correoProveedor NVARCHAR(80) NOT NULL
)

CREATE TABLE PRODUCTO.CategoriaProducto
(
 idCategoriaProducto INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
 estadoCategoriaProducto VARCHAR (20)  DEFAULT ('ACTIVO/A') NULL,
 nombreCategoria NVARCHAR(30) NOT NULL
)


CREATE TABLE PRODUCTO.Producto
(
 idProducto INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
 idProveedor INT NOT NULL,
 idCategoriaProducto INT NOT NULL,
 nombreProducto NVARCHAR(50) NOT NULL,
 estadoProducto VARCHAR (20)  DEFAULT ('ACTIVO/A') NULL,
 stock INT NOT NULL,
 precio DECIMAL(10,2) NOT NULL,
 marca NVARCHAR(40) NOT NULL,
 fechaCaducidad DATE NOT NULL
)

CREATE TABLE REGISTRO.Movimiento
(
	idMovimiento INT IDENTITY (1,1),
	fechaMovimineto DATETIME DEFAULT GETDATE() NOT NULL,
	operacion VARCHAR(100) NOT NULL,
	tabla VARCHAR(20) NOT NULL, 
	descripcion TEXT NULL,
	encargado INT NOT NULL 
)
GO

CREATE TABLE REGISTRO.Factura
(
 idFactura INT IDENTITY PRIMARY KEY CLUSTERED,
 idCliente INT NOT NULL,
 idEmpleado INT NOT NULL,
 fecha DATETIME DEFAULT GETDATE()
)

CREATE TABLE REGISTRO.DetalleFactura
(
 IdDetalle INT IDENTITY PRIMARY KEY CLUSTERED,
 IdFactura INT NOT NULL,
 IdProducto INT NOT NULL,
 cantidad INT NOT NULL,
 Total DECIMAL(10,2) NOT NULL
)

ALTER TABLE PRODUCTO.Producto
ADD CONSTRAINT FK_PRODUCTO_PRODUCTO$TIENE_UN$PRODUCTO_PROVEEDOR
FOREIGN KEY (idProveedor) REFERENCES PRODUCTO.Proveedor (idProveedor)
ON DELETE NO ACTION
ON UPDATE NO ACTION;
GO


ALTER TABLE PRODUCTO.Producto
ADD CONSTRAINT FK_PRODUCTO_PRODUCTO$TIENE_UNA$PRODUCTO_CATEGORIAPRODUCTO
FOREIGN KEY (idCategoriaProducto) REFERENCES PRODUCTO.CategoriaProducto (idCategoriaProducto)
ON DELETE NO ACTION
ON UPDATE NO ACTION;
GO

ALTER TABLE REGISTRO.Factura
ADD CONSTRAINT FK_PRODUCTO_FACTURA$TIENE_UN$PERSONA_CLIENTE
FOREIGN KEY (idCliente) REFERENCES PERSONA.Cliente (idCliente)
ON DELETE NO ACTION
ON UPDATE NO ACTION;
GO

ALTER TABLE REGISTRO.Factura
ADD CONSTRAINT FK_PRODUCTO_FACTURA$TIENE_UN$PERSONA_EMPLEADO
FOREIGN KEY (idEmpleado) REFERENCES PERSONA.Empleado (idEmpleado)
ON DELETE NO ACTION
ON UPDATE NO ACTION;
GO

ALTER TABLE REGISTRO.DetalleFactura
ADD CONSTRAINT FK_REGISTRO_DETALLEFACTURA$TIENE_UNA$REGISTRO_FACTURA
FOREIGN KEY (idFactura) REFERENCES REGISTRO.Factura (idFactura)
ON DELETE NO ACTION
ON UPDATE NO ACTION;
GO

ALTER TABLE REGISTRO.DetalleFactura
ADD CONSTRAINT FK_REGISTRO_DETALLEFACTURA$TIENE_UN$PRODUCTO_PRODUCTO
FOREIGN KEY (idProducto) REFERENCES PRODUCTO.Producto (idProducto)
ON DELETE NO ACTION
ON UPDATE NO ACTION;
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------****PROCEDIMIENTOS ALMACENADOS****----------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------


--PROCEDIMIENTO DE AGREGAR CLIENTE
CREATE PROCEDURE AGREGARCLIENTE @Empleado INT, @nombreCliente NVARCHAR(50), @apellidoCliente NVARCHAR(80), @identidad VARCHAR(15), @sexo CHAR(1), @telefono CHAR(9), @direccion TEXT, @correoCliente NVARCHAR(80)
AS
BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @idCliente INT;
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado)
		 BEGIN
			INSERT INTO PERSONA.Cliente(nombreCliente, apellidoCliente, identidad,sexo, telefono, direccion, correoCliente)
			VALUES (@nombreCliente, @apellidoCliente, @identidad, @sexo, @telefono, @direccion, @correoCliente);
			set @idCliente=(SELECT idCliente FROM PERSONA.Cliente WHERE identidad=@identidad);
			 INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
			VALUES ('SE AÑADIÓ UN CLIENTE: '+CAST(@idCliente AS varchar), 'CLIENTE', 'INSERCIÓN EXITOSA', @Empleado);
		 END
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO


--PROCEDIMIENTO ACTUALIZAR CLIENTE
CREATE PROCEDURE ACTUALIZARCLIENTE @Empleado INT, @nombreCliente NVARCHAR(50), @apellidoCliente NVARCHAR(50), @identidad VARCHAR(15), @sexo CHAR(1), @telefono CHAR(9), @direccion TEXT, @correoCliente NVARCHAR(80)
AS
BEGIN TRANSACTION 
	BEGIN TRY-- se usa el transaction para evitar errores	
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado)
		BEGIN
			if exists(SELECT * FROM PERSONA.Cliente WHERE nombreCliente=@nombreCliente)
			BEGIN
			UPDATE PERSONA.Cliente SET nombreCliente = @nombreCliente, apellidoCliente = @apellidoCliente, identidad = @identidad ,  sexo =  @sexo, telefono = @telefono, direccion = @direccion, correoCliente = @correoCliente WHERE identidad=@identidad;

			 INSERT INTO REGISTRO.MOVIMIENTO(operacion, tabla, descripcion, encargado)
			 VALUES ('SE ACTUALIZO CLIENTE:' +@nombreCliente ,  'CLIENTE', 'ACTUALIZACIÓN EXITOSA', @Empleado);
			END
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO


--PROCEDIMIENTO ELIMINAR CLIENTE--PROCESO DE ELIMINAR EN CLIENTES
CREATE PROCEDURE ELIMINARCLIENTE @Empleado INT, @Codigo INT
AS
BEGIN TRANSACTION
	BEGIN TRY
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado) --Debe existir ese empleado
		BEGIN
			if exists(SELECT * FROM PERSONA.Cliente WHERE idCliente=@Codigo) --Debe existir un cliente con ese codigo
			BEGIN
				if isnull((select vecesCompra FROM PERSONA.Cliente WHERE idCliente=@Codigo), 0)=0 --Si el cliente nunca ha hecho una compre, se puede eliminar
				BEGIN
				  DELETE FROM PERSONA.Cliente WHERE idCliente=@Codigo
				  INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
				  VALUES ('SE ELIMINO CLIENTE:'+ CAST(@Codigo AS VARCHAR), 'CLIENTES', 'ELIMINACION CORRECTA', @Empleado);
				END
				ELSE
				BEGIN
					update PERSONA.Cliente SET estadoCliente='INACTIVO/A' WHERE idCliente=@Codigo; --Si el cliente tiene compras no se elimina, solo se le cambia el estado
					INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
					VALUES ('SE CAMBIO ESTADO CLIENTE:'+ CAST(@Codigo AS VARCHAR) + ' A INACTIVO', 'CLIENTE', 'CLIENTE INACTIVO', @Empleado);
			    END
		    END
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--PROCEDIMIENTO DE AGREGAR EMPLEADO
CREATE PROCEDURE AGREGAREMPLEADO @nombreEmpleado NVARCHAR(50), @apellidoEmpleado NVARCHAR(80), @fechaIngreso NVARCHAR(8), @puesto NVARCHAR(60), @sexo CHAR(1), @telefono CHAR(9),@direccion TEXT, @correoEmpleado NVARCHAR(80)
AS
begin TRANSACTION
	BEGIN TRY
			INSERT INTO PERSONA.Empleado(nombreEmpleado, apellidoEmpleado, fechaIngreso, puesto, sexo, telefono, direccion, correoEmpleado)
			VALUES (@nombreEmpleado, @apellidoEmpleado, @fechaIngreso, @puesto, @sexo, @telefono, @direccion, @correoEmpleado);
			 INSERT INTO REGISTRO.MOVIMIENTO(operacion, tabla, descripcion, encargado)
			 VALUES ('SE AÑADIÓ UN EMPLEADO: '+@nombreEmpleado, 'EMPLEADO', 'INSERCIÓN EXITOSA', 0);
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO

--PROCEDIMIENTO DE ACTUALIZAR EMPLEADO
CREATE PROCEDURE ACTUALIZAREMPLEADO  @Empleado INT,  @Codigo INT, @nombreEmpleado NVARCHAR(50), @apellidoEmpleado NVARCHAR(80), @fechaIngreso NVARCHAR(8), @puesto NVARCHAR(60), @sexo CHAR(1), @telefono CHAR(9),@direccion TEXT, @correoEmpleado NVARCHAR(80)
AS
BEGIN TRANSACTION 
	BEGIN TRY
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado) 
		BEGIN
			if exists(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Codigo)
			BEGIN
			UPDATE PERSONA.EMPLEADO SET nombreEmpleado = @nombreEmpleado, apellidoEmpleado = @apellidoEmpleado,fechaIngreso = @fechaIngreso, puesto = @puesto, sexo = @sexo, telefono = @telefono, direccion = @direccion, correoEmpleado = @correoEmpleado WHERE idEmpleado=@Codigo;
			 INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
			 VALUES ('SE ACTUALIZO EMPLEADO:' + CAST(@Codigo AS VARCHAR),  'EMPLEADO', 'ACTUALIZACIÓN EXITOSA', @Empleado);
			END
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO


--PROCEDIMIENTO ELIMINAR EMPLEADO
CREATE PROCEDURE ELIMINAREMPLEADO @Empleado INT, @Codigo INT
AS
BEGIN TRANSACTION
	BEGIN TRY
		IF EXISTS (SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado) 
		BEGIN
			if exists(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Codigo) 
			BEGIN
					update PERSONA.Empleado SET estadoEmpleado='INACTIVO/A' WHERE idEmpleado=@Codigo; 
					INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
					VALUES ('SE CAMBIO ESTADO EMPLEADO:'+ CAST(@Codigo AS VARCHAR) + ' A INACTIVO', 'EMPLEADO', 'EMPLEADO INACTIVO', @Empleado);
			END		
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--PROCEDIMIENTO DE AGREGAR USUARIO	
CREATE PROCEDURE AGREGARUSUARIO  @nombreUsuario NVARCHAR(25), @passwordUsuario NVARCHAR(12), @nivelUsuario VARCHAR(15)
AS
begin TRANSACTION
	BEGIN TRY
		declare @idUsuario INT;
			INSERT INTO PERSONA.Usuario(nombreUsuario, passwordUsuario, nivelUsuario)
			VALUES (@nombreUsuario, @passwordUsuario, @nivelUsuario);
			set @idUsuario=(SELECT idUsuario FROM PERSONA.Usuario WHERE nombreUsuario= @nombreUsuario);
			 INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
			VALUES ('SE AÑADIÓ UN USUARIO: '+CAST(@idUsuario AS varchar), 'USUARIO', 'INSERCIÓN EXITOSA',0);
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO


--PROCEDIMIENTO DE ACTUALIZAR USUARIO	
CREATE PROCEDURE ACTUALIZARUSUARIO @Empleado INT,@codigo INT, @nombreUsuario NVARCHAR(25), @passwordUsuario NVARCHAR(12), @nivelUsuario VARCHAR(15)
AS
BEGIN TRANSACTION 
	BEGIN TRY-- se usa el transaction para evitar errores	
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado)
		BEGIN
			if exists(SELECT * FROM PERSONA.Usuario WHERE idUsuario=@codigo)
			BEGIN
			UPDATE PERSONA.Usuario SET nombreUsuario = @nombreUsuario, passwordUsuario = @passwordUsuario, nivelUsuario = @nivelUsuario WHERE idUsuario=@codigo;
			 INSERT INTO REGISTRO.MOVIMIENTO(operacion, tabla, descripcion, encargado)
			 VALUES ('SE ACTUALIZO EL USUARIO:' + CAST(@codigo AS VARCHAR),  'USUARIO', 'ACTUALIZACIÓN EXITOSA', @Empleado);
			END
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO


--PROCEDIMIENTO DE ELIMINAR USUARIO	
CREATE PROCEDURE ELIMINARUSUARIO @Empleado INT, @Codigo INT
AS
BEGIN TRANSACTION
	BEGIN TRY
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado) --Debe existir ese empleado
		BEGIN
			if exists(SELECT * FROM PERSONA.Usuario WHERE idUsuario=@Codigo) --Debe existir un cliente con ese codigo
			BEGIN
					update PERSONA.Usuario SET estadoUsuario='INACTIVO/A' WHERE idUsuario=@Codigo; 
					INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
					VALUES ('SE CAMBIO ESTADO USUARIO:'+ CAST(@Codigo AS VARCHAR) + ' A INACTIVO', 'USUARIO', ' INACTIVO', @Empleado);
			END   
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--PROCEDIMIENTO DE AGREGAR CATEGORIA PRODUCTO
CREATE PROCEDURE AGREGARCATEGORIAPRODUCTO @Empleado INT, @nombreCategoria NVARCHAR(30)
AS
begin TRANSACTION
	BEGIN TRY
		declare @idCategoriaProducto INT;
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado)
		BEGIN
			INSERT INTO PRODUCTO.CategoriaProducto(nombreCategoria)
			VALUES (@nombreCategoria);
			set @idCategoriaProducto=(SELECT idCategoriaProducto FROM PRODUCTO.CategoriaProducto WHERE nombreCategoria= @nombreCategoria);
			 INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
			VALUES ('SE AÑADIÓ UNA CATEGORIA DE PRODUCTO: '+@nombreCategoria, 'CATEGORIAPRODUCTO', 'INSERCIÓN EXITOSA', @Empleado);
		END
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO

--PROCEDIMIENTO DE ACTUALIZAR CATEGORIA DEL PRODUCTO	
CREATE PROCEDURE ACTUALIZARCATEGORIAPRODUCTO @codigo INT, @Empleado INT, @nombreCategoria NVARCHAR(30)
AS
BEGIN TRANSACTION 
	BEGIN TRY-- se usa el transaction para evitar errores	
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado)
		BEGIN
			if exists(SELECT * FROM PRODUCTO.CategoriaProducto WHERE idCategoriaProducto=@codigo)
			BEGIN
			UPDATE PRODUCTO.CategoriaProducto SET nombreCategoria = @nombreCategoria WHERE idCategoriaProducto=@codigo;
			 INSERT INTO REGISTRO.MOVIMIENTO(operacion, tabla, descripcion, encargado)
			 VALUES ('SE ACTUALIZO UNA CATEGORIA:' + CAST(@codigo AS VARCHAR),  'CATEGORIAPRODUCTO', 'ACTUALIZACIÓN EXITOSA', @Empleado);
			END
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO


--PROCEDIMIENTO DE ELIMINAR CATEGORIA DE PRODUCTO
CREATE PROCEDURE ELIMINARCATEGORIAPRODUCTO @Empleado INT, @Codigo INT
AS
BEGIN TRANSACTION
	BEGIN TRY
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado) --Debe existir ese empleado
		BEGIN
			if exists(SELECT * FROM PRODUCTO.CategoriaProducto WHERE idCategoriaProducto=@Codigo) --Debe existir un cliente con ese codigo
			BEGIN
				update PRODUCTO.CategoriaProducto SET estadoCategoriaProducto='INACTIVO/A' WHERE idCategoriaProducto=@Codigo;
					INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
					VALUES ('SE CAMBIO ESTADO CATEGORIA PRODUCTO:'+ CAST(@Codigo AS VARCHAR) + ' A INACTIVO', 'CATEGORIAPRODUCTO', ' INACTIVO', @Empleado);
			END
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--PROCEDIMIENTO DE AGREGAR PRODUCTO	
CREATE PROCEDURE AGREGARPRODUCTO @Empleado INT, @idProveedor INT, @idCategoriaProducto INT, @nombreProducto NVARCHAR(50), @stock INT, @precio DECIMAL(10,2), @marca NVARCHAR(40) ,@fechaCaducidad DATE
AS
begin TRANSACTION
	BEGIN TRY
		declare @idProducto INT;
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado)
		BEGIN
			INSERT INTO PRODUCTO.Producto(idProveedor,idCategoriaProducto, nombreProducto, stock, precio, marca, fechaCaducidad)
			VALUES (@idProveedor, @idCategoriaProducto,@nombreProducto, @stock, @precio,@marca, @fechaCaducidad);
			set @idProducto=(SELECT idProducto FROM PRODUCTO.Producto WHERE nombreProducto= @nombreProducto);
			 INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
			VALUES ('SE AÑADIÓ UN PRODUCTO:'+CAST(@idProducto AS VARCHAR), 'PRODUCTO', 'INSERCIÓN EXITOSA', @Empleado);
		END
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO



--PROCEDIMIENTO DE ACTUALIZAR PRODUCTO	
CREATE PROCEDURE ACTUALIZARPRODUCTO @Empleado INT,@codigo INT, @idProveedor INT, @idCategoriaProducto INT, @nombreProducto NVARCHAR(50), @stock INT, @precio DECIMAL(10,2), @marca NVARCHAR(40) ,@fechaCaducidad DATE
AS
BEGIN TRANSACTION 
	BEGIN TRY-- se usa el transaction para evitar errores	
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado)
		BEGIN
			if exists(SELECT * FROM PRODUCTO.Producto WHERE idProducto=@codigo)
			BEGIN
			UPDATE PRODUCTO.Producto SET idProveedor= @idProveedor,idCategoriaProducto = @idCategoriaProducto, nombreProducto = @nombreProducto, stock = @stock, precio = @precio, marca = @marca, fechaCaducidad = @fechaCaducidad WHERE idProducto=@codigo;

			 INSERT INTO REGISTRO.MOVIMIENTO(operacion, tabla, descripcion, encargado)
			 VALUES ('SE ACTUALIZO EL PRODUCTO:' + CAST(@codigo AS VARCHAR),  'PRODUCTO', 'ACTUALIZACIÓN EXITOSA', @Empleado);
			END
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO


---------------------------------------------------------------------------------------------------------------------------
--PROCEDIMIENTO DE ELIMINAR PRODUCTO	
CREATE PROCEDURE ELIMINARPRODUCTO @Empleado INT, @Codigo INT
AS
BEGIN TRANSACTION
	BEGIN TRY
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado) --Debe existir ese empleado
		BEGIN

			if exists(SELECT * FROM PRODUCTO.Producto WHERE idProducto=@Codigo) --Debe existir un cliente con ese codigo
			BEGIN
				update PRODUCTO.Producto SET estadoProducto='INACTIVO/A' WHERE idProducto=@Codigo;
				INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
				VALUES ('SE CAMBIO ESTADO PRODUCTO:'+ CAST(@Codigo AS VARCHAR) + ' A INACTIVO', 'PRODUCTO', ' INACTIVO', @Empleado);
			END

		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO


------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--PROCEDIMIENTO DE AGREGAR PROVEEDOR
CREATE PROCEDURE AGREGARPROVEEDOR @Empleado INT, @nombreProveedor NVARCHAR(50), @telefonoProveedor CHAR(9), @celularproveedor CHAR(9), @direccionProveedor TEXT, @descripcionProveedor TEXT, @correoProveedor NVARCHAR(80)
AS
begin TRANSACTION
	BEGIN TRY
		declare @idProveedor INT;
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado)
		BEGIN
			INSERT INTO PRODUCTO.Proveedor(nombreProveedor, telefonoProveedor, celularProveedor, direccionProveedor, descripcionProveedor, correoProveedor)
			VALUES (@nombreProveedor, @telefonoProveedor, @celularproveedor, @direccionProveedor, @descripcionProveedor, @correoProveedor);
			set @idProveedor=(SELECT idProveedor FROM PRODUCTO.Proveedor WHERE nombreProveedor=@nombreProveedor);
			 INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
			VALUES ('SE AÑADIÓ UN PROVEEDOR: '+CAST(@idProveedor AS varchar), 'PROVEEDOR', 'INSERCIÓN EXITOSA', @Empleado);
		END
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--PROCEDIMIENTO DE ACTUALIZAR PROVEEDOR	
CREATE PROCEDURE ACTUALIZARPROVEEDOR @Empleado INT,@codigo INT, @nombreProveedor NVARCHAR(50), @telefonoProveedor CHAR(9), @celularproveedor CHAR(9), @direccionProveedor TEXT, @descripcionProveedor TEXT, @correoProveedor NVARCHAR(80)
AS
BEGIN TRANSACTION 
	BEGIN TRY-- se usa el transaction para evitar errores	
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado)
		BEGIN
			if exists(SELECT * FROM PRODUCTO.Proveedor WHERE idProveedor=@codigo)
			BEGIN
			UPDATE PRODUCTO.Proveedor SET nombreProveedor= @nombreProveedor,telefonoProveedor = @telefonoProveedor, celularproveedor = @celularproveedor, direccionProveedor = @direccionProveedor, descripcionProveedor  = @descripcionProveedor , correoProveedor = @correoProveedor WHERE idProveedor=@codigo;
			 INSERT INTO REGISTRO.MOVIMIENTO(operacion, tabla, descripcion, encargado)
			 VALUES ('SE ACTUALIZO EL PROVEEDOR:' + CAST(@codigo AS VARCHAR),  'PROVEEDOR', 'ACTUALIZACIÓN EXITOSA', @Empleado);
			END
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO

---------------------------------------------------------------------------------------------------------------------------
--PROCEDIMIENTO DE ELIMINAR PROVEEDOR	
CREATE PROCEDURE ELIMINARPROVEEDOR @Empleado INT, @Codigo INT
AS
BEGIN TRANSACTION
	BEGIN TRY
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado) --Debe existir ese empleado
		BEGIN

			if exists(SELECT * FROM PRODUCTO.Proveedor WHERE idProveedor=@Codigo) 
			BEGIN
				update PRODUCTO.Proveedor SET estadoProveedor='INACTIVO/A' WHERE idProveedor=@Codigo;
				INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
				VALUES ('SE CAMBIO ESTADO PROVEEDOR:'+ CAST(@Codigo AS VARCHAR) + ' A INACTIVO', 'PROVEEDOR', ' INACTIVO', @Empleado);
			END

		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO


------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--AGREGAR FACTURA

CREATE PROCEDURE AGREGARFACTURA @Empleado INT, @IdCliente INT 
AS
begin TRANSACTION
	BEGIN TRY
		DECLARE @idFactura INT;
		    IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado) 
		     BEGIN
			  IF EXISTS(SELECT * FROM PERSONA.Cliente WHERE idCliente=@IdCliente)
		       BEGIN

			   DECLARE @CONTADOR INT;
			   INSERT INTO REGISTRO.Factura (idCliente, idEmpleado) 
			   VALUES (@IdCliente, @Empleado);

			   SET @idFactura=(SELECT idFactura FROM Registro.Factura WHERE idCliente=@IdCliente);
			   INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado) --GUARDA EN MOVIMIENTOS PRIMERO POR QUE SE NECESITA CAPTURAR DATOS DE INSERTED PARA REALIZAR OPERACIONES
			   VALUES ('SE AGREGO UNA FACTURA: ' + CAST (@IdFactura AS VARCHAR) + ' AL CLIENTE : ' + CAST (@IdCliente AS VARCHAR) ,'FACTURA', 'INSERT CORRECTO', @Empleado);

			   IF ISNULL((SELECT vecesCompra FROM PERSONA.Cliente WHERE IdCliente=@IdCliente),0)=0 --SI LAS VECES QUE HA COMPRADO ES NULL SE HARA 0
			   BEGIN
				SET @CONTADOR=0;
			   END
			    ELSE
			   BEGIN
					SET @CONTADOR=(SELECT vecesCompra FROM PERSONA.Cliente WHERE idCliente=@IdCliente); --SI YA TIENE 1 O MAS COMPRAS SE HARA LA SUMA
			   END
			   UPDATE PERSONA.Cliente SET  vecesCompra=@CONTADOR+1 WHERE idCliente=@idCliente; --SE ACTUALIZA LAS VECES COMPRA DEL CLIENTE
			   IF (SELECT estadoCliente FROM PERSONA.Cliente WHERE idCliente=@idCliente)='INACTIVO/A' --SI ESTA INACTIVO PASA EL ESTADO A ACTIVO
			   BEGIN
				UPDATE PERSONA.Cliente SET estadoCliente='ACTIVO/A' WHERE idCliente=@idCliente; --PASA A ACTIVO EL ESTADO
			   END
		 END
		END
		COMMIT
END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO


------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--AGREGAR DETALLE DE FACTURA


--AGREGAR DETALLE PEDIDO 
CREATE PROCEDURE AGREGARDETALLEFACTURA @EMPLEADO INT, @ID_PRODUCTO INT,@IDFACTURA INT, @CANTIDAD INT, @TOTAL INT
AS
begin TRANSACTION
	BEGIN TRY
		IF EXISTS(SELECT * FROM PRODUCTO.Producto WHERE idProducto=@ID_PRODUCTO) --VERIFICA SI EXISTE EL PRODUCTO
		BEGIN
		IF EXISTS(SELECT * FROM REGISTRO.Factura WHERE IdFactura=@IDFACTURA) --VERIFICA SI EXISTE LA FACTURA
		BEGIN
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE IdEmpleado=@EMPLEADO) --VERIFICA SI EXISTE EL EMPLEADO
		BEGIN
			IF @CANTIDAD<=(SELECT stock FROM PRODUCTO.Producto WHERE idProducto=@ID_PRODUCTO) --Ver si hay productos en existencia, en el caso de no haber no se puede realizar la compra
			BEGIN
				DECLARE @PRECIO MONEY,
				@NOMBRE NVARCHAR(50),
				@CONTADOR INT,
				@STOCKACTU INT;
				SET @PRECIO=(SELECT Precio FROM PRODUCTO.Producto WHERE IdProducto=@ID_PRODUCTO); --SE TRAE EL PRECIO DESDE LA TABLA PRODUCTO CON SU ID
				SET @NOMBRE=(SELECT nombreProducto FROM PRODUCTO.Producto WHERE idProducto=@ID_PRODUCTO); --SE TRAE EL NOMBRE DE LA TABLA PRODUCTO CON SU ID
				INSERT INTO REGISTRO.DetalleFactura(IdFactura, IdProducto, Cantidad, Total) --AGREGA EL PEDIDO
				VALUES (@IDFACTURA, @ID_PRODUCTO, @CANTIDAD, @TOTAL);
				INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado) --GUARDA EL MOVIMIENTO CON SUS DATOS
				VALUES ('SE AGREGO UN PRODUCTO A LA FACTURA', 'FACTURA', 'INSERCION EXITOSA', @EMPLEADO);
				SET @CONTADOR=(SELECT stock FROM PRODUCTO.Producto WHERE idProducto=@ID_PRODUCTO); --SE PROCEDE A GUARDAR EL CONTADOR QUE SERIA LA EXISTENCIA DEL PRODUCTO ACTUAL
				SET @STOCKACTU=@CONTADOR-@CANTIDAD; --SE REALIZA LA RESTA
				UPDATE PRODUCTO.Producto SET Stock=@STOCKACTU WHERE idProducto=@ID_PRODUCTO; --SE AGREGA EL NUEVO STOCK
			END
		END
		END		
		END
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------***INSERCION DE DATOS****------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------


--================================================================EMPLEADO(INSERCION)================================================================================

--Agregar un Empleado en la tabla REGISTROS.Empleado(nombreEmpleado, apellidoEmpleado, fechaIngreso, puesto, sexo, telefono, direccion, correoEmpleado)

EXEC AGREGAREMPLEADO 'Nedysa', 'Flanders', '09/09/99', 'Gerente', 'M', '96878765','San Miguel','Mfr@gmail.com'
go

EXEC ACTUALIZAREMPLEADO  01, 02, 'ned1', 'Flanders', '09/09/99', 'Gerente', 'M', '96878765','San Miguel','Mfr@gmail.com'
go

EXEC ELIMINAREMPLEADO 02,01
go


--================================================================CLIENTE(INSERCION)================================================================================

--Agregar un Cliente en la tabla REGISTROS.Cliente (Identidad del empleado, nombreCliente, apellidoCliente, identidad, sexo, telefono, direccion, correoCliente)

EXEC AGREGARCLIENTE 01,'Peperfr', 'Hernandéz', '0313199900418', 'M', '97895670', 'Comayaguad', 'Crishy@yahoo.com'
go

EXEC ACTUALIZARCLIENTE 01,02,'PepeEE', 'Hernandéz', '0313199900498','M', '97895670', 'Comayagua', 'Crishy@yahoo.com' 
go

EXEC ELIMINARCLIENTE 01,03
go


--================================================================USUARIO(INSERCION)================================================================================

--Agregar un Cliente en la tabla REGISTROS.Usuario (Identidad del empleado, nombre del usuario, password, nivel del usuario)

EXEC AGREGARUSUARIO 'usu', 'arroz09', 'empleado'
go

EXEC ACTUALIZARUSUARIO 01,01,'usu2', 'arroz09', 'empleado'
go

EXEC ELIMINARUSUARIO 01,01 
go


--================================================================USUARIO(INSERCION)================================================================================

--Agregar un Cliente en la tabla PRODUCTO.CaterogoriaProducto (Identidad del empleado, nombre de la categoria)


EXEC AGREGARCATEGORIAPRODUCTO  01,'Alimentos'
go

EXEC  ACTUALIZARCATEGORIAPRODUCTO 01,01,'Alimentos Procesados'
go

EXEC ELIMINARCATEGORIAPRODUCTO 01, 01 
go


--================================================================PROVEEDOR(INSERCION)================================================================================

--Agregar un Proveedor en la tabla PRODUCTO.Producto(empleado, nombre proveedor, telefono, celular, ubicacion, descripcion, correo)

EXEC AGREGARPROVEEDOR 01,'Distribuidoraas Lopez', '27730947', '98765431', 'San Pedro Sulas', 'Eficiente', 'Lopez@gmail.com'
go

EXEC ACTUALIZARPROVEEDOR  01, 01,'Distribuidora Hernandez', '27730987', '98765432', 'San Pedro Sula', 'Excelente', 'Lopez@gmail.com'
go


EXEC ELIMINARPROVEEDOR 01,01
go



--================================================================PRODUCTO(INSERCION)================================================================================

--Agregar un Producto en la tabla PRODUCTO.Producto(empleado,id Proveedor, id categoria Producto, nombreProducto,stock, precio, marca, fecha de Caducidad)

EXEC AGREGARPRODUCTO 01,01,01,'Pasta', 12, 15.00, 'Mi Pasta', '12/01/02'
go

EXEC ACTUALIZARPRODUCTO  01, 01,01,01 ,'Pasta Italiana', 14, 15.00, 'Mi Pasta', '12/01/02'
go


EXEC ELIMINARPRODUCTO 01,01
go


--================================================================DETALLE DE FACTURA(INSERCION)================================================================================

--Agregar un Detalle de Factura en la tabla REGISTRO.DetalleFactura(IdEmpleado,IdProducto, IdFactura , Cantidad, Total)

EXEC AGREGARDETALLEFACTURA 01,01,01,5,123
go

EXEC AGREGARDETALLEFACTURA 01,01,01,6,112
go

--Agregar Factura (IdEmpleado, IdCliente)

EXEC AGREGARFACTURA 01,01
go




--================================================================FACTURA(INSERCION)================================================================================

--Agregar una Factura en la tabla REGISTRO.Factura (Identidad del empleado, nombre del usuario, password, nivel del usuario)

/*
SELECT * FROM PERSONA.Cliente
GO

SELECT * FROM PERSONA.Empleado
GO

SELECT * FROM PRODUCTO.CategoriaProducto
GO

SELECT * FROM PRODUCTO.Proveedor
GO

SELECT * FROM PRODUCTO.Producto
GO

SELECT * FROM REGISTRO.Factura
GO

SELECT * FROM PERSONA.Usuario
GO

SELECT * FROM REGISTRO.DetalleFactura
GO

SELECT * FROM REGISTRO.Movimiento
GO

*/

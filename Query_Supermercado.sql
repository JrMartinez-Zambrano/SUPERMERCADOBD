/*
--BASE DE DATOS: MISUPER
--EQUIPO DESARROLLADOR : TECHNOCODE
*/

USE tempdb
GO


 --alter database SUPERMERCADO set single_user with rollback immediate

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
CREATE PROCEDURE AGREGARCLIENTE @Empleado INT, @nombreCliente NVARCHAR(50), @apellidoCliente NVARCHAR(80), @identidad VARCHAR(15), @vecesCompra INT, @sexo CHAR(1), @telefono CHAR(9), @direccion TEXT, @correoCliente NVARCHAR(80)
AS
BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @idCliente INT;
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado)
		 BEGIN
			INSERT INTO PERSONA.Cliente(nombreCliente, apellidoCliente, identidad, vecesCompra, sexo, telefono, direccion, correoCliente)
			VALUES (@nombreCliente, @apellidoCliente, @identidad,@vecesCompra, @sexo, @telefono, @direccion, @correoCliente);
			set @idCliente=(SELECT idCliente FROM PERSONA.Cliente WHERE identidad=@identidad);
			 INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
			VALUES ('SE A�ADI� UN CLIENTE: '+CAST(@idCliente AS varchar), 'CLIENTE', 'INSERCI�N EXITOSA', @Empleado);
		 END
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
GO


--PROCEDIMIENTO ACTUALIZAR CLIENTE
CREATE PROCEDURE ACTUALIZARCLIENTE @Empleado INT,@codigo INT, @nombreCliente NVARCHAR(50), @apellidoCliente NVARCHAR(50), @identidad VARCHAR(15),@vecesCompra INT, @sexo CHAR(1), @telefono CHAR(9), @direccion TEXT, @correoCliente NVARCHAR(80)
AS
BEGIN TRANSACTION 
	BEGIN TRY-- se usa el transaction para evitar errores	
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado)
		BEGIN
			if exists(SELECT * FROM PERSONA.Cliente WHERE idCliente=@codigo)
			BEGIN
			UPDATE PERSONA.Cliente SET nombreCliente = @nombreCliente, apellidoCliente = @apellidoCliente, identidad = @identidad , vecesCompra  = @vecesCompra, sexo =  @sexo, telefono = @telefono, direccion = @direccion, correoCliente = @correoCliente WHERE IdCliente=@codigo;

			 INSERT INTO REGISTRO.MOVIMIENTO(operacion, tabla, descripcion, encargado)
			 VALUES ('SE ACTUALIZO CLIENTE:' + CAST(@codigo AS VARCHAR),  'CLIENTE', 'ACTUALIZACI�N EXITOSA', @Empleado);
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
			 VALUES ('SE A�ADI� UN EMPLEADO: '+@nombreEmpleado, 'EMPLEADO', 'INSERCI�N EXITOSA', 0);
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
			 VALUES ('SE ACTUALIZO EMPLEADO:' + CAST(@Codigo AS VARCHAR),  'EMPLEADO', 'ACTUALIZACI�N EXITOSA', @Empleado);
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
CREATE PROCEDURE AGREGARUSUARIO @Empleado INT, @nombreUsuario NVARCHAR(25), @passwordUsuario NVARCHAR(12), @nivelUsuario VARCHAR(15)
AS
begin TRANSACTION
	BEGIN TRY
		declare @idUsuario INT;
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado)
		BEGIN
			INSERT INTO PERSONA.Usuario(nombreUsuario, passwordUsuario, nivelUsuario)
			VALUES (@nombreUsuario, @passwordUsuario, @nivelUsuario);
			set @idUsuario=(SELECT idUsuario FROM PERSONA.Usuario WHERE nombreUsuario= @nombreUsuario);
			 INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
			VALUES ('SE A�ADI� UN USUARIO: '+CAST(@idUsuario AS varchar), 'USUARIO', 'INSERCI�N EXITOSA', @Empleado);
		END
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
			 VALUES ('SE ACTUALIZO EL USUARIO:' + CAST(@codigo AS VARCHAR),  'USUARIO', 'ACTUALIZACI�N EXITOSA', @Empleado);
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
			VALUES ('SE A�ADI� UNA CATEGORIA DE PRODUCTO: '+@nombreCategoria, 'CATEGORIAPRODUCTO', 'INSERCI�N EXITOSA', @Empleado);
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
			 VALUES ('SE ACTUALIZO UNA CATEGORIA:' + CAST(@codigo AS VARCHAR),  'CATEGORIAPRODUCTO', 'ACTUALIZACI�N EXITOSA', @Empleado);
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
			VALUES ('SE A�ADI� UN PRODUCTO:'+CAST(@idProducto AS VARCHAR), 'PRODUCTO', 'INSERCI�N EXITOSA', @Empleado);
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
			 VALUES ('SE ACTUALIZO EL PRODUCTO:' + CAST(@codigo AS VARCHAR),  'PRODUCTO', 'ACTUALIZACI�N EXITOSA', @Empleado);
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
			VALUES ('SE A�ADI� UN PROVEEDOR: '+CAST(@idProveedor AS varchar), 'PROVEEDOR', 'INSERCI�N EXITOSA', @Empleado);
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
			 VALUES ('SE ACTUALIZO EL PROVEEDOR:' + CAST(@codigo AS VARCHAR),  'PROVEEDOR', 'ACTUALIZACI�N EXITOSA', @Empleado);
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


---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------***INSERCION DE DATOS****------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------


--================================================================EMPLEADO(INSERCION)================================================================================

--Agregar un Empleado en la tabla REGISTROS.Empleado(nombreEmpleado, apellidoEmpleado, fechaIngreso, puesto, sexo, telefono, direccion, correoEmpleado)

EXEC AGREGAREMPLEADO 'Ned', 'Flanders', '09/09/99', 'Gerente', 'M', '96878765','San Miguel','Mfr@gmail.com'
go

EXEC ACTUALIZAREMPLEADO  01, 02, 'ned1', 'Flanders', '09/09/99', 'Gerente', 'M', '96878765','San Miguel','Mfr@gmail.com'
go

EXEC ELIMINAREMPLEADO 01,02
go


--================================================================CLIENTE(INSERCION)================================================================================

--Agregar un Cliente en la tabla REGISTROS.Cliente (Identidad del empleado, nombreCliente, apellidoCliente, identidad, sexo, telefono, direccion, correoCliente)

EXEC AGREGARCLIENTE 01,'Pepe', 'Hernand�z', '0313199900498',2, 'M', '97895670', 'Comayagua', 'Crishy@yahoo.com'
go

EXEC ACTUALIZARCLIENTE 01,01,'PepeEE', 'Hernand�z', '0313199900498',3, 'M', '97895670', 'Comayagua', 'Crishy@yahoo.com' 
go

EXEC ELIMINARCLIENTE 01,01
go


--================================================================USUARIO(INSERCION)================================================================================

--Agregar un Cliente en la tabla REGISTROS.Usuario (Identidad del empleado, nombre del usuario, password, nivel del usuario)

EXEC AGREGARUSUARIO 01,'usu', 'arroz09', 'empleado'
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

EXEC AGREGARPROVEEDOR 01,'Distribuidora Lopez', '27730987', '98765432', 'San Pedro Sula', 'Eficiente', 'Lopez@gmail.com'
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




INSERT INTO PRODUCTO.Proveedor(nombreProveedor, telefonoProveedor, celularProveedor, direccionProveedor, descripcionProveedor, correoProveedor)
 VALUES( 'Distribuidora Lopez', '27730987', '98765432', 'San Pedro Sula', 'Eficiente', 'Lopez@gmail.com')
 GO
 

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



SELECT * FROM REGISTRO.Movimiento
GO

SELECT * FROM PERSONA.Usuario
GO

delete from PERSONA.Cliente where idCliente = 1
go

TRUNCATE TABLE PERSONA.Empleado
GO

TRUNCATE TABLE PERSONA.Cliente
GO

TRUNCATE TABLE REGISTRO.Movimiento 
GO

*/

/*
--BASE DE DATOS: MISUPER
--EQUIPO DESARROLLADOR : TECHNOCODE
*/

USE tempdb
GO

IF EXISTS(SELECT * FROM sys.databases WHERE name='SUPERMERCADO')
BEGIN
	DROP DATABASE SUPERMERCADO;
END
GO

CREATE DATABASE SUPERMERCADO
ON PRIMARY
(
	NAME='SUPERMERCADO_DATA',
	FILENAME='C:\PRUEBA_DOCUMENTACION\SUPERMERCADO_DATA.mdf',
	SIZE=10MB,
	MAXSIZE=800MB,
	FILEGROWTH=5MB
)
LOG ON
(
	NAME='SUPERMERCADO_LOG',
	FILENAME='C:\PRUEBA_DOCUMENTACION\SUPERMERCADO_LOG.ldf',
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
 fechaIngreso DATE NOT NULL,
 puesto NVARCHAR(60) NOT NULL,
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
 correoProveedor NVARCHAR(80) NOT NULL
)

CREATE TABLE PRODUCTO.CategoriaProducto
(
 idCategoriaProducto INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
 nombreCategoria NVARCHAR(30) NOT NULL
)


CREATE TABLE PRODUCTO.Producto
(
 idProducto INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
 idProveedor INT NOT NULL,
 idCategoriaProducto INT NOT NULL,
 nombreProducto NVARCHAR(50) NOT NULL,
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
CREATE PROCEDURE AGREGARCLIENTE @Empleado INT, @nombreCliente NVARCHAR(50), @apellidoCliente NVARCHAR(80), @identidad VARCHAR(15), @sexo CHAR(1), @telefono CHAR(9), @direccion TEXT, @correoCliente NVARCHAR(80), @mens TEXT OUT
AS
begin TRANSACTION
	BEGIN TRY
		declare @idCliente INT;
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado)
		BEGIN
			INSERT INTO PERSONA.Cliente(nombreCliente, apellidoCliente, identidad, sexo, telefono, direccion, correoCliente)
			VALUES (@nombreCliente, @apellidoCliente, @identidad, @sexo, @telefono, @direccion, @correoCliente);
			set @idCliente=(SELECT idCliente FROM PERSONA.Cliente WHERE identidad=@identidad);
			 INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
			VALUES ('SE AÑADIÓ UN CLIENTE: '+CAST(@idCliente AS varchar), 'CLIENTE', 'INSERCIÓN EXITOSA', @Empleado);
			SET @mens='CLIENTE '+cast(@idCliente AS varchar)+' AÑADIDO';
		END
		ELSE
		BEGIN
			SET @mens='EL CODIGO DE EMPLEADO QUE INGRESO NO EXISTE';
		END
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @mens=ERROR_MESSAGE();
	END CATCH
GO


--PROCEDIMIENTO ACTUALIZAR CLIENTE
CREATE PROCEDURE ACTUALIZARCLIENTE @Empleado INT,@codigo INT, @nombreCliente NVARCHAR(50), @apellidoCliente NVARCHAR(50), @identidad VARCHAR(15), @sexo CHAR(1), @telefono CHAR(9), @direccion TEXT, @correoCliente NVARCHAR(80), @mens TEXT OUT
AS
BEGIN TRANSACTION 
	BEGIN TRY-- se usa el transaction para evitar errores	
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado)
		BEGIN
			if exists(SELECT * FROM PERSONA.Cliente WHERE idCliente=@codigo)
			BEGIN
			UPDATE PERSONA.Cliente SET nombreCliente = @nombreCliente, apellidoCliente = @apellidoCliente, identidad = @identidad , sexo =  @sexo, telefono = @telefono, direccion = @direccion, correoCliente = @correoCliente WHERE IdCliente=@codigo;

			 INSERT INTO REGISTRO.MOVIMIENTO(operacion, tabla, descripcion, encargado)
			 VALUES ('SE ACTUALIZO CLIENTE:' + CAST(@codigo AS VARCHAR),  'CLIENTES', 'ACTUALIZACIÓN EXITOSA', @Empleado);
			SET @mens='ACTUALIZACION CORRECTA';
			END
			ELSE
			BEGIN
			SET @mens='NO EXISTE REGISTRO CON ESE CODIGO';
			END
		END
		ELSE
		BEGIN
			SET @mens='EL CODIGO DE EMPLEADO QUE INGRESO NO EXISTE';
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @mens=ERROR_MESSAGE();
	END CATCH
GO


--PROCEDIMIENTO ELIMINAR CLIENTE--PROCESO DE ELIMINAR EN CLIENTES
CREATE PROCEDURE ELIMINARCLIENTE @Empleado INT, @Codigo INT, @mens TEXT OUT
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
				SET @mens='CLIENTE ' + CAST(@Codigo AS VARCHAR) + ' SE HA ELIMINADO';
				 INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
				VALUES ('SE ELIMINO CLIENTE:'+ CAST(@Codigo AS VARCHAR), 'CLIENTES', 'ELIMINACION CORRECTA', @Empleado);
				END
				ELSE
				BEGIN
					update PERSONA.Cliente SET estadoCliente='INACTIVO/A' WHERE idCliente=@Codigo; --Si el cliente tiene compras no se elimina, solo se le cambia el estado
					INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
					VALUES ('SE CAMBIO ESTADO CLIENTE:'+ CAST(@Codigo AS VARCHAR) + ' A INACTIVO', 'CLIENTE', 'CLIENTE INACTIVO', @Empleado);
					SET @mens='NO se puede eliminar cliente porque ya ha comprado una o mas veces, se ha cambiado su estado a inactivo';
				END
			END
			ELSE
			BEGIN
				SET @mens='NO EXISTE REGISTRO CON ESE CODIGO';
			END
		END
		ELSE
		BEGIN
			SET @mens='EL CODIGO DE EMPLEADO QUE INGRESO NO EXISTE';
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @mens=ERROR_MESSAGE();
	END CATCH
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--PROCEDIMIENTO DE AGREGAR EMPLEADO
CREATE PROCEDURE AGREGAREMPLEADO @nombreEmpleado NVARCHAR(50), @apellidoEmpleado NVARCHAR(80), @fechaIngreso DATE, @puesto NVARCHAR(60), @sexo CHAR(1), @telefono CHAR(9),@direccion TEXT, @correoEmpleado NVARCHAR(80), @mens TEXT OUT
AS
begin TRANSACTION
	BEGIN TRY
			INSERT INTO PERSONA.Empleado(nombreEmpleado, apellidoEmpleado, fechaIngreso, puesto, sexo, telefono, direccion, correoEmpleado)
			VALUES (@nombreEmpleado, @apellidoEmpleado, @fechaIngreso, @puesto, @sexo, @telefono, @direccion, @correoEmpleado);
			 INSERT INTO REGISTRO.MOVIMIENTO(operacion, tabla, descripcion, encargado)
			 VALUES ('SE AÑADIÓ UN EMPLEADO: '+@nombreEmpleado, 'EMPLEADO', 'INSERCIÓN EXITOSA', 0);
			SET @mens='EMPLEADO AÑADIDO';
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @mens=ERROR_MESSAGE();
	END CATCH
GO

--PROCEDIMIENTO DE ACTUALIZAR EMPLEADO
CREATE PROCEDURE ACTUALIZAREMPLEADO  @Empleado INT,  @Codigo INT, @nombreEmpleado NVARCHAR(50), @apellidoEmpleado NVARCHAR(80), @fechaIngreso DATE, @puesto NVARCHAR(60), @sexo CHAR(1), @telefono CHAR(9),@direccion TEXT, @correoEmpleado NVARCHAR(80), @mens TEXT OUT
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
			SET @mens='ACTUALIZACION EXITOSA';
			END
			ELSE
			BEGIN
			SET @mens='NO EXISTE REGISTRO CON ESE CODIGO';
			END
		END
		ELSE
		BEGIN
			SET @mens='EL CODIGO DE EMPLEADO QUE INGRESO NO EXISTE';
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @mens=ERROR_MESSAGE();
	END CATCH
GO


--PROCEDIMIENTO ELIMINAR EMPLEADO
CREATE PROCEDURE ELIMINAREMPLEADO @Empleado INT, @Codigo INT, @mens TEXT OUT
AS
BEGIN TRANSACTION
	BEGIN TRY
		IF EXISTS (SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado) 
		BEGIN
			if exists(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Codigo) 
			BEGIN
				DELETE FROM PERSONA.Empleado WHERE idEmpleado=@Codigo
				SET @mens='EMPLEADO ' + CAST(@Codigo AS VARCHAR) + ' SE HA ELIMINADO';
				 INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
				VALUES ('SE ELIMINO EMPLEADO:'+ CAST(@Codigo AS VARCHAR), 'EMPLEADO', 'ELIMINACIÓN EXITOSA', @Empleado);
			END
			ELSE
			BEGIN
				SET @mens='NO EXISTE REGISTRO CON ESE CODIGO';
			END
		END
		ELSE
		BEGIN
			SET @mens='EL CODIGO DE EMPLEADO QUE USTED INGRESO NO EXISTE';
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @mens=ERROR_MESSAGE();
	END CATCH
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--PROCEDIMIENTO DE AGREGAR USUARIO	
CREATE PROCEDURE AGREGARUSUARIO @Empleado INT, @nombreUsuario NVARCHAR(25), @passwordUsuario NVARCHAR(12), @nivelUsuario VARCHAR(15), @mens TEXT OUT
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
			VALUES ('SE AÑADIÓ UN USUARIO: '+CAST(@idUsuario AS varchar), 'USUARIO', 'INSERCIÓN EXITOSA', @Empleado);
			SET @mens='USUARIO '+cast(@idUsuario AS varchar)+' AÑADIDO';
		END
		ELSE
		BEGIN
			SET @mens='EL CODIGO DE EMPLEADO QUE INGRESO NO EXISTE';
		END
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @mens=ERROR_MESSAGE();
	END CATCH
GO


--PROCEDIMIENTO DE ACTUALIZAR USUARIO	
CREATE PROCEDURE ACTUALIZARUSUARIO @Empleado INT,@codigo INT, @nombreUsuario NVARCHAR(25), @passwordUsuario NVARCHAR(12), @nivelUsuario VARCHAR(15), @mens TEXT OUT
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
			SET @mens='ACTUALIZACION CORRECTA';
			END
			ELSE
			BEGIN
			SET @mens='NO EXISTE REGISTRO CON ESE CODIGO';
			END
		END
		ELSE
		BEGIN
			SET @mens='EL CODIGO DE EMPLEADO QUE INGRESO NO EXISTE';
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @mens=ERROR_MESSAGE();
	END CATCH
GO


--PROCEDIMIENTO DE ELIMINAR USUARIO	
CREATE PROCEDURE ELIMINARUSUARIO @Empleado INT, @Codigo INT, @mens TEXT OUT
AS
BEGIN TRANSACTION
	BEGIN TRY
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado) --Debe existir ese empleado
		BEGIN
			if exists(SELECT * FROM PERSONA.Usuario WHERE idUsuario=@Codigo) --Debe existir un cliente con ese codigo
			BEGIN
				DELETE FROM PERSONA.Usuario WHERE idUsuario=@Codigo
				SET @mens='USUARIO ' + CAST(@Codigo AS VARCHAR) + ' SE HA ELIMINADO';
				 INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
				VALUES ('SE ELIMINO USUARIO:'+ CAST(@Codigo AS VARCHAR), 'USUARIO', 'ELIMINACION EXITOSA', @Empleado);
			END
			ELSE
			BEGIN
				SET @mens='NO EXISTE REGISTRO CON ESE CODIGO';
			END
		END
		ELSE
		BEGIN
			SET @mens='EL CODIGO DE EMPLEADO QUE INGRESO NO EXISTE';
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @mens=ERROR_MESSAGE();
	END CATCH
GO


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--PROCEDIMIENTO DE AGREGAR CATEGORIA PRODUCTO
CREATE PROCEDURE AGREGARCATEGORIAPRODUCTO @Empleado INT, @nombreCategoria NVARCHAR(30), @mens TEXT OUT
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
			SET @mens='CATEGORIA '+cast(@idCategoriaProducto AS varchar)+' AÑADIDO';
		END
		ELSE
		BEGIN
			SET @mens='EL CODIGO DE EMPLEADO QUE INGRESO NO EXISTE';
		END
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @mens=ERROR_MESSAGE();
	END CATCH
GO

--PROCEDIMIENTO DE ACTUALIZAR CATEGORIA DEL PRODUCTO	
CREATE PROCEDURE ACTUALIZARCATEGORIAPRODUCTO @codigo INT, @Empleado INT, @nombreCategoria NVARCHAR(30), @mens TEXT OUT
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
			SET @mens='ACTUALIZACION CORRECTA';
			END
			ELSE
			BEGIN
			SET @mens='NO EXISTE REGISTRO CON ESE CODIGO';
			END
		END
		ELSE
		BEGIN
			SET @mens='EL CODIGO DE EMPLEADO QUE INGRESO NO EXISTE';
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @mens=ERROR_MESSAGE();
	END CATCH
GO


--PROCEDIMIENTO DE ELIMINAR CATEGORIA DE PRODUCTO
CREATE PROCEDURE ELIMINARCATEGORIAPRODUCTO @Empleado INT, @Codigo INT, @mens TEXT OUT
AS
BEGIN TRANSACTION
	BEGIN TRY
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado) --Debe existir ese empleado
		BEGIN
			if exists(SELECT * FROM PRODUCTO.CategoriaProducto WHERE idCategoriaProducto=@Codigo) --Debe existir un cliente con ese codigo
			BEGIN
				DELETE FROM PRODUCTO.CategoriaProducto WHERE idCategoriaProducto=@Codigo
				SET @mens='CATEGORIA DE PRODUCTO ' + CAST(@Codigo AS VARCHAR) + ' SE HA ELIMINADO';
				 INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
				VALUES ('SE ELIMINO LA CATEGORIA:'+ CAST(@Codigo AS VARCHAR), 'CATEGORIAPRODUCTO', 'ELIMINACION EXITOSA', @Empleado);
			END
			ELSE
			BEGIN
				SET @mens='NO EXISTE REGISTRO CON ESE CODIGO';
			END
		END
		ELSE
		BEGIN
			SET @mens='EL CODIGO DE EMPLEADO QUE INGRESO NO EXISTE';
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @mens=ERROR_MESSAGE();
	END CATCH
GO


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--PROCEDIMIENTO DE AGREGAR PRODUCTO	
CREATE PROCEDURE AGREGARPRODUCTO @Empleado INT, @idProveedor INT, @idCategoriaProducto INT, @nombreProducto NVARCHAR(50), @stock INT, @precio DECIMAL(10,2), @marca NVARCHAR(40) ,@fechaCaducidad DATE, @mens TEXT OUT
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
			SET @mens='PRODUCTO'+cast(@idProducto AS varchar)+' AÑADIDO';
		END
		ELSE
		BEGIN
			SET @mens='EL CODIGO DE EMPLEADO QUE INGRESO NO EXISTE';
		END
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @mens=ERROR_MESSAGE();
	END CATCH
GO



--PROCEDIMIENTO DE ACTUALIZAR PRODUCTO	
CREATE PROCEDURE ACTUALIZARPRODUCTO @Empleado INT,@codigo INT, @idProveedor INT, @idCategoriaProducto INT, @nombreProducto NVARCHAR(50), @stock INT, @precio DECIMAL(10,2), @marca NVARCHAR(40) ,@fechaCaducidad DATE, @mens TEXT OUT
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
			SET @mens='ACTUALIZACION CORRECTA';
			END
			ELSE
			BEGIN
			SET @mens='NO EXISTE REGISTRO CON ESE CODIGO';
			END
		END
		ELSE
		BEGIN
			SET @mens='EL CODIGO DE EMPLEADO QUE INGRESO NO EXISTE';
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @mens=ERROR_MESSAGE();
	END CATCH
GO



--PROCEDIMIENTO DE ELIMINAR USUARIO	
CREATE PROCEDURE ELIMINARPRODUCTO @Empleado INT, @Codigo INT, @mens TEXT OUT
AS
BEGIN TRANSACTION
	BEGIN TRY
		IF EXISTS(SELECT * FROM PERSONA.Empleado WHERE idEmpleado=@Empleado) --Debe existir ese empleado
		BEGIN
			if exists(SELECT * FROM PRODUCTO.Producto WHERE idProducto=@Codigo) --Debe existir un cliente con ese codigo
			BEGIN
				DELETE FROM PRODUCTO.Producto WHERE idProducto=@Codigo
				SET @mens='PRODUCTO' + CAST(@Codigo AS VARCHAR) + ' SE HA ELIMINADO';
				 INSERT INTO REGISTRO.Movimiento(operacion, tabla, descripcion, encargado)
				VALUES ('SE ELIMINO EL PRODUCTO:'+ CAST(@Codigo AS VARCHAR), 'PRODUCTO', 'ELIMINACION EXITOSA', @Empleado);
			END
			ELSE
			BEGIN
				SET @mens='NO EXISTE REGISTRO CON ESE CODIGO';
			END
		END
		ELSE
		BEGIN
			SET @mens='EL CODIGO DE EMPLEADO QUE INGRESO NO EXISTE';
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @mens=ERROR_MESSAGE();
	END CATCH
GO




---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------***INSERCION DE DATOS****------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------


--================================================================EMPLEADO(INSERCION)================================================================================

--Agregar un Empleado en la tabla REGISTROS.Empleado(nombreEmpleado, apellidoEmpleado, fechaIngreso, puesto, sexo, telefono, direccion, correoEmpleado)
DECLARE @mens VARCHAR(180);
EXEC AGREGAREMPLEADO 'Ned', 'Flanders', '09/09/99', 'Gerente', 'M', '96878765','San Miguel','Mfr@gmail.com', @mens OUT
PRINT @mens;
go

DECLARE @mens VARCHAR(180);
EXEC ACTUALIZAREMPLEADO  01, 01, 'ned1', 'Flanders', '09/09/99', 'Gerente', 'M', '96878765','San Miguel','Mfr@gmail.com', @mens OUT
PRINT @mens;
go

DECLARE @mens VARCHAR(180);
EXEC ELIMINAREMPLEADO 01,01, @mens OUT
PRINT @mens;
go


--================================================================CLIENTE(INSERCION)================================================================================

--Agregar un Cliente en la tabla REGISTROS.Cliente (Identidad del empleado, nombreCliente, apellidoCliente, identidad, sexo, telefono, direccion, correoCliente)
DECLARE @mens VARCHAR(180);
EXEC AGREGARCLIENTE 01,'Pepe', 'Hernandéz', '0313199900498', 'M', '97895670', 'Comayagua', 'Crishy@yahoo.com', @mens OUT
PRINT @mens;
go


DECLARE @mens VARCHAR(180);
EXEC ACTUALIZARCLIENTE 01,01,'PepeEE', 'Hernandéz', '0313199900498', 'M', '97895670', 'Comayagua', 'Crishy@yahoo.com' ,@mens OUT
PRINT @mens;
go


DECLARE @mens VARCHAR(180);
EXEC ELIMINARCLIENTE 01,02, @mens OUT
PRINT @mens;
go


--================================================================USUARIO(INSERCION)================================================================================

--Agregar un Cliente en la tabla REGISTROS.Usuario (Identidad del empleado, nombre del usuario, password, nivel del usuario)


DECLARE @mens VARCHAR(180);
EXEC AGREGARUSUARIO 01,'usu', 'arroz09', 'empleado',@mens OUT
PRINT @mens;
go


DECLARE @mens VARCHAR(180);
EXEC ACTUALIZARUSUARIO 01,01,'usu2', 'arroz09', 'empleado',@mens OUT
PRINT @mens;
go

DECLARE @mens VARCHAR(180);
EXEC ELIMINARUSUARIO 01,01 ,@mens OUT
PRINT @mens;
go


--================================================================USUARIO(INSERCION)================================================================================

--Agregar un Cliente en la tabla PRODUCTO.CaterogoriaProducto (Identidad del empleado, nombre de la categoria)


DECLARE @mens VARCHAR(180);
EXEC AGREGARCATEGORIAPRODUCTO  01,'Alimentos',@mens OUT
PRINT @mens;
go


DECLARE @mens VARCHAR(180);
EXEC  ACTUALIZARCATEGORIAPRODUCTO 01,01,'Alimentos Procesados' ,@mens OUT
PRINT @mens;
go

DECLARE @mens VARCHAR(180);
EXEC ELIMINARCATEGORIAPRODUCTO 01, 01 ,@mens OUT
PRINT @mens;
go



--================================================================PRODUCTO(INSERCION)================================================================================

--Agregar un Producto en la tabla PRODUCTO.Producto(empleado,id Proveedor, id categoria Producto, nombreProducto,stock, precio, marca, fecha de Caducidad)
DECLARE @mens VARCHAR(180);
EXEC AGREGARPRODUCTO 01,01,01,'Pasta', 12, 15.00, 'Mi Pasta', '12/01/02', @mens OUT
PRINT @mens;
go

DECLARE @mens VARCHAR(180);
EXEC ACTUALIZARPRODUCTO  1, 01,01,01 ,'Pasta Italiana', 14, 15.00, 'Mi Pasta', '12/01/02', @mens OUT
PRINT @mens;
go

DECLARE @mens VARCHAR(180);
EXEC ELIMINARPRODUCTO 01,01, @mens OUT
PRINT @mens;
go


INSERT INTO PRODUCTO.Proveedor(nombreProveedor, telefonoProveedor, celularProveedor, direccionProveedor, descripcionProveedor, correoProveedor)
 VALUES( 'Distribuidora Lopez', '27730987', '98765432', 'San Pedro Sula', 'Eficiente', 'Lopez@gmail.com')
 GO
 
delete from PRODUCTO.Proveedor where idProveedor =2
go


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

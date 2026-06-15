
-- Universidad: Universidad de la Matanza
-- Materia: Bases de Datos Aplicadas
 
-- Grupo 04
-- Integrantes:
--  De Bellis, Nahuel
--  Ocampo, Julian Rafael
--  Rodriguez, Gonzalo Ezequiel
--  Vargas, Tomas
 
-- Objetivo del script: Generacion de SP de operaciones ABM
 
-- Fecha: 14/06/2026

USE parques_nacionales
GO

-----------------------------------------------------------
-- Alta
-----------------------------------------------------------
-- Registrar parque

CREATE OR ALTER PROCEDURE gestion.sp_registrar_parque
	@nombre VARCHAR(50),
	@tipo VARCHAR(50),
	@ubicacion VARCHAR(50),
	@superficie INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @errores VARCHAR(100);
	SET @errores = '';

	IF EXISTS (SELECT nombre FROM gestion.Parque WHERE nombre = @nombre)
	BEGIN
		SET @errores += 'El nombre del parque ya se encuentra registrado' + CHAR(10);
	END

	IF @superficie <= 0
        SET @errores += 'La superficie debe ser un valor positivo.' + CHAR(10);

	IF @errores != ''
	BEGIN
		RAISERROR(@errores, 16, 1);
		RETURN;
	END

	INSERT INTO gestion.Parque (nombre, tipo, ubicacion, superficie, estado)
	VALUES (@nombre, @tipo, @ubicacion, @superficie, 'Activo');
END
GO

-----------------------------------------------------------
-- Registrar guardaparque

CREATE OR ALTER PROCEDURE gestion.sp_registrar_guardaparque
	@dni INT,
	@nombre CHAR(30),
	@apellido CHAR(30)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @errores VARCHAR(50);
	SET @errores = '';

	IF EXISTS (SELECT dni FROM gestion.Guardaparque WHERE dni = @dni)
	BEGIN
		SET @errores += 'El dni del guardaparque ya esta registrado.' + CHAR(10);
	END

	IF @errores != ''
	BEGIN
		RAISERROR (@errores, 16, 1);
		RETURN;
	END

	INSERT INTO gestion.Guardaparque (dni, nombre, apellido, estado)
	VALUES (@dni, @nombre, @apellido, 'Inactivo');
END
GO

-----------------------------------------------------------
-- Asignar guardaparque-parque

CREATE OR ALTER PROCEDURE gestion.sp_asignar_guardaparque
	@id_parque INT, -- podria ser nombre
	@id_guardaparque INT -- podria ser dni
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @errores VARCHAR(200);
	SET @errores = '';

	IF NOT EXISTS (SELECT id FROM gestion.Parque WHERE id = @id_parque)
	BEGIN
		SET @errores += 'El parque al que se le quiere asignar no existe.' + CHAR(10);
	END

	IF NOT EXISTS (SELECT id FROM gestion.Guardaparque WHERE id = @id_guardaparque)
	BEGIN
		SET @errores += 'El guardaparque que se quiere asignar no existe.' + CHAR(10);
	END

	IF EXISTS (SELECT id_parque FROM gestion.Parque_asignado WHERE id_parque = @id_parque AND fecha_egreso IS NULL)
	BEGIN
		SET @errores += 'El parque al que se quiere asignar ya tiene guardaparque asignado.' + CHAR(10);
	END

	IF EXISTS (SELECT id_guardaparque FROM gestion.Parque_asignado WHERE id_guardaparque = @id_guardaparque AND fecha_egreso IS NULL)
	BEGIN
		SET @errores += 'El gurdaparque que se quiere asignar ya esta asignado.' + CHAR(10);
	END

	IF @errores != ''
	BEGIN
		RAISERROR (@errores, 16, 1);
		RETURN;
	END

	BEGIN TRANSACTION
		INSERT INTO gestion.Parque_asignado (id_parque, id_guardaparque, fecha_ingreso)
		VALUES (@id_parque, @id_guardaparque, GETDATE());

		UPDATE gestion.Guardaparque SET estado = 'Activo' WHERE id = @id_guardaparque;
	COMMIT;
END
GO

-----------------------------------------------------------
-- Registrar tipo actividad

CREATE OR ALTER PROCEDURE gestion.sp_registrar_tipo_actividad
	@descripcion CHAR(25)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO gestion.Tipo_actividad (descripcion) VALUES (@descripcion);
END
GO

-----------------------------------------------------------
-- Registrar actividad

CREATE OR ALTER PROCEDURE gestion.sp_registrar_actividad
	@id_parque INT,
	@id_guia INT,
	@nombre CHAR(50),
	@descripcion VARCHAR(100),
	@tipo CHAR(25),
	@costo DECIMAL(7,2),
	@fecha DATE,
	@duracion INT,
	@cupo INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @errores VARCHAR(200);
	DECLARE @id_tipo INT;
	SET @errores = '';

	SELECT @id_tipo = id FROM gestion.Tipo_actividad WHERE descripcion = @tipo;

	IF NOT EXISTS (SELECT id FROM gestion.Parque WHERE id = @id_parque)
	BEGIN
		SET @errores += 'El parque en el que se quiere registrar la actividad no existe.' + CHAR(10);
	END

	IF NOT EXISTS (SELECT id FROM gestion.Guia WHERE id = @id_guia)
	BEGIN
		SET @errores += 'El guia en el que se quiere registrar la actividad no existe.' + CHAR(10);
	END
	ELSE
	BEGIN
		IF NOT EXISTS(
			SELECT g.id FROM gestion.Guia g
			INNER JOIN guia.Acreditacion a ON g.id_acreditacion = a.id
			WHERE g.id = @id_guia AND a.estado = 'vigente' AND a.fecha_vencimiento >= GETDATE()
		)
		BEGIN
			SET @errores += 'El guia no esta autorizado a supervisar una actividad.' + CHAR(10);
		END
	END

	IF @id_tipo IS NULL
		SET @errores += 'El tipo de actividad es invalido.' + CHAR(10);

	IF @fecha <= GETDATE()
	BEGIN
		SET @errores += 'No se puede establecer una actividad para fechas pasadas.' + CHAR(10);
	END

	IF @errores != ''
	BEGIN
		RAISERROR (@errores, 16, 1);
		RETURN;
	END

	INSERT INTO gestion.Actividad (id_parque, id_guia, id_tipo, nombre, descripcion, costo, fecha, duracion, cupo, estado)
	VALUES (@id_parque, @id_guia, @id_tipo, @nombre, @descripcion, @costo, @fecha, @duracion, @cupo, 'Programado');
END
GO

-----------------------------------------------------------
-- Baja
-----------------------------------------------------------
-- Baja Parque

CREATE OR ALTER PROCEDURE gestion.sp_baja_parque
	@id INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @errores VARCHAR(200);
	SET @errores = '';

	IF NOT EXISTS (SELECT id FROM gestion.Parque WHERE id = @id)
	BEGIN
		SET @errores += 'El parque que se desea dar de baja no existe.' + CHAR(10);
	END
	ELSE
    BEGIN
        IF (SELECT estado FROM gestion.Parque WHERE id = @id) = 'Inactivo'
            SET @errores += 'El parque ya se encuentra dado de baja.' + CHAR(10);
    END

	IF EXISTS (SELECT id_parque FROM gestion.Parque_asignado WHERE id_parque = @id AND fecha_egreso IS NULL)
	BEGIN
		SET @errores += 'El parque que se desea dar de baja tiene guardaparque asignado.' + CHAR(10);
	END

	IF EXISTS (SELECT 1 FROM gestion.Actividad WHERE id_parque = @id AND estado IN ('Programado', 'En curso'))
        SET @errores += 'El parque tiene actividades activas. Cancelalas antes de dar de baja el parque.' + CHAR(10);

	-- Si se agrega estado en actividad, hay que modificar aca el estado de programada a cancelada

	IF @errores != ''
	BEGIN
		RAISERROR(@errores, 16, 1);
		RETURN;
	END

    UPDATE gestion.Parque SET estado = 'Inactivo' WHERE id = @id;
END
GO

-----------------------------------------------------------
-- Baja guardaparque

CREATE OR ALTER PROCEDURE gestion.sp_baja_guardaparque
	@id INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @errores VARCHAR(100);
	SET @errores = '';

	IF NOT EXISTS(SELECT id FROM gestion.Guardaparque WHERE id = @id)
	BEGIN
		SET @errores += 'El guardaparque que se quiere dar de baja no existe.' + CHAR(10);
	END

	IF (SELECT estado FROM gestion.Guardaparque WHERE id = @id) != 'Activo'
		SET @errores += 'El guardaparque no se encuentra asignado a ningun parque.' + CHAR(10);
		

	IF @errores != ''
	BEGIN
		RAISERROR(@errores, 16, 1);
		RETURN;
	END

	BEGIN TRANSACTION;
        IF EXISTS (SELECT id_guardaparque FROM gestion.Parque_asignado WHERE id_guardaparque = @id AND fecha_egreso IS NULL)
            UPDATE gestion.Parque_asignado SET fecha_egreso = GETDATE() WHERE id_guardaparque = @id AND fecha_egreso IS NULL;

        UPDATE gestion.Guardaparque SET estado = 'Inactivo' WHERE id = @id;
    COMMIT;
END
GO

-----------------------------------------------------------
-- Baja actividad

CREATE OR ALTER PROCEDURE gestion.sp_baja_actividad
    @id INT,
    @motivo VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(100);
    DECLARE @estado_actual CHAR(10);
    SET @errores = '';

    IF NOT EXISTS (SELECT 1 FROM gestion.Actividad WHERE id = @id)
    BEGIN
        SET @errores += 'La actividad que se desea cancelar no existe.' + CHAR(10);
    END
    ELSE
    BEGIN
        SELECT @estado_actual = estado FROM gestion.Actividad WHERE id = @id;

        IF @estado_actual IN ('Cancelado', 'Finalizado', 'En curso')
            SET @errores += 'La actividad no puede ser cancelada. Estado actual: ' + RTRIM(@estado_actual) + CHAR(10);
    END

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    UPDATE gestion.Actividad SET estado = 'Cancelado' WHERE id = @id;

    -- Tener en cuenta que hacer si hay entradas con actividades programadas
END
GO

-----------------------------------------------------------
-- Modificacion
-----------------------------------------------------------
-- Modificar parque

CREATE OR ALTER PROCEDURE gestion.sp_modificar_parque
	@id INT,
	@nombre VARCHAR(50),
	@tipo VARCHAR(50),
	@ubicacion VARCHAR(50),
	@superficie INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @errores VARCHAR(100);
	SET @errores = '';

	IF NOT EXISTS (SELECT id FROM gestion.Parque WHERE id = @id)
        SET @errores += 'El parque que se desea modificar no existe.' + CHAR(10);

    IF EXISTS (SELECT id FROM gestion.Parque WHERE nombre = @nombre AND id != @id)
        SET @errores += 'El nombre ingresado ya esta en uso por otro parque.' + CHAR(10);

    IF @superficie <= 0
        SET @errores += 'La superficie debe ser un valor positivo.' + CHAR(10);
 
    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END
 
    UPDATE gestion.Parque SET nombre = @nombre, tipo = @tipo, ubicacion = @ubicacion, superficie = @superficie WHERE id = @id;
END
GO

-----------------------------------------------------------
-- Modificar guardaparque

CREATE OR ALTER PROCEDURE gestion.sp_modificar_guardaparque
    @id INT,
    @nombre CHAR(30),
    @apellido CHAR(30),
    @estado CHAR(8)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @errores VARCHAR(150);
    SET @errores = '';
 
    IF NOT EXISTS (SELECT id FROM gestion.Guardaparque WHERE id = @id)
        SET @errores += 'El guardaparque que se desea modificar no existe.' + CHAR(10);
 
    IF @estado NOT IN ('Activo', 'Inactivo')
        SET @errores += 'El estado ingresado no es valido. Los valores permitidos son: Activo o Inactivo.' + CHAR(10);
 
    IF @estado = 'Activo'
    AND NOT EXISTS(SELECT id_guardaparque FROM gestion.Parque_asignado WHERE id_guardaparque = @id AND fecha_egreso IS NULL)
        SET @errores += 'No se puede establecer como activo a un guardaparque que no tiene asignacion activa.' + CHAR(10);
 
    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END
 
    UPDATE gestion.Guardaparque SET nombre = @nombre, apellido = @apellido, estado = @estado WHERE id = @id;
END
GO

-----------------------------------------------------------
-- Modificar asignacion guardaparque

CREATE OR ALTER PROCEDURE gestion.sp_modificar_asignacion
    @id INT,
    @motivo VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @errores VARCHAR(200);
    DECLARE @fecha_ingreso DATE;
	DECLARE @fecha_egreso DATE;

	SET @errores = '';
	SET @fecha_egreso = GETDATE();

    IF NOT EXISTS (SELECT id FROM gestion.Parque_asignado WHERE id = @id)
    BEGIN
        SET @errores += 'La asignacion que se desea modificar no existe.' + CHAR(10);
    END
    ELSE
    BEGIN
        IF EXISTS (SELECT id FROM gestion.Parque_asignado WHERE id = @id AND fecha_egreso IS NOT NULL)
            SET @errores += 'La asignacion no esta activa.' + CHAR(10);
    END
 
    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END
 
    BEGIN TRANSACTION;
        UPDATE gestion.Parque_asignado SET fecha_egreso = @fecha_egreso, motivo = @motivo WHERE id = @id;
 
        UPDATE gestion.Guardaparque SET estado = 'Inactivo' WHERE id = (SELECT id_guardaparque FROM gestion.Parque_asignado WHERE id = @id);
    COMMIT;
END
GO

-----------------------------------------------------------
-- Modificar actividad

CREATE OR ALTER PROCEDURE gestion.sp_modificar_actividad
    @id INT,
    @id_guia INT,
    @nombre CHAR(50),
    @descripcion VARCHAR(100),
    @tipo CHAR(25),
    @costo DECIMAL(9,2),
    @fecha DATE,
    @duracion INT,
    @cupo INT,
	@estado CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @errores VARCHAR(285);
	DECLARE @id_tipo INT;
	DECLARE @estado_actual CHAR(10);
	
    SET @errores = '';

	SELECT @id_tipo = id FROM gestion.Tipo_actividad WHERE descripcion = @tipo;
 
    IF NOT EXISTS (SELECT id FROM gestion.Actividad WHERE id = @id)
	BEGIN
        SET @errores += 'La actividad que se desea modificar no existe.' + CHAR(10);
	END
	ELSE
	BEGIN
		SELECT @estado_actual = estado FROM gestion.Actividad WHERE id = @id;

        IF @estado_actual IN ('Cancelado', 'Finalizado')
            SET @errores += 'No se puede modificar una actividad que esta ' + RTRIM(@estado_actual) + '.' + CHAR(10);
    END

    IF NOT EXISTS (SELECT id FROM gestion.Guia WHERE id = @id_guia)
        SET @errores += 'El guia especificado no existe.' + CHAR(10);
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT g.id FROM gestion.Guia g
            INNER JOIN gestion.Acreditacion a ON g.id_acreditacion = a.id
            WHERE g.id = @id_guia
              AND a.estado = 'Activo'
              AND a.fecha_vencimiento >= GETDATE()
        )
            SET @errores += 'El guia no esta autorizado a supervisar una actividad.' + CHAR(10);
    END

	IF @id_tipo IS NULL
		SET @errores += 'El tipo de actividad no es valido.' + CHAR(10);

	IF @estado NOT IN ('Programado', 'Cancelado', 'Finalizado', 'En curso', 'Cupo lleno')
        SET @errores += 'El estado ingresado no es valido.' + CHAR(10);

    IF @fecha <= GETDATE()
        SET @errores += 'No se puede establecer una actividad para fechas pasadas.' + CHAR(10);
 
    IF @duracion <= 0
        SET @errores += 'La duracion debe ser un valor positivo.' + CHAR(10);
 
    IF @cupo <= 0
        SET @errores += 'El cupo debe ser un valor positivo.' + CHAR(10);
 
    IF @costo < 0
        SET @errores += 'El costo debe ser un valor positivo.' + CHAR(10);
 
    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END
 
    UPDATE gestion.Actividad SET id_guia = @id_guia, id_tipo = @id_tipo, nombre = @nombre, descripcion = @descripcion, costo = @costo, fecha = @fecha, duracion = @duracion, cupo = @cupo, estado = @estado
    WHERE id = @id;
END
GO

-----------------------------------------------------------
-- Registrar guia

CREATE OR ALTER PROCEDURE gestion.sp_registrar_guia
@dni CHAR(8),
@nombre VARCHAR(30),
@apellido VARCHAR(30), 
@fecha_vencimiento_acreditacion DATE
AS
BEGIN
    DECLARE @id_acreditacion INT;
    DECLARE @estado_acreditacion CHAR(7);
    DECLARE @error VARCHAR(100);
    SET @error = '';

    IF @dni IS NULL
        SET @error += 'Se debe especificar el dni del guia.' + CHAR(10);
    ELSE
    BEGIN
        IF @dni NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
            SET @error += 'Ingresar dni valido.' + CHAR(10);
        ELSE
        BEGIN
            IF EXISTS (SELECT id FROM gestion.Guia WHERE dni = @dni)
                SET @error += 'El dni ya pertenece a un guia.' + CHAR(10);
        END    
    END

    IF @nombre IS NULL OR @apellido IS NULL OR @nombre = '' or @apellido = ''
        SET @error += 'Se debe especificar nombre y apellido del guia.' + CHAR(10);
    
    IF @fecha_vencimiento_acreditacion IS NULL
        SET @error += 'Se debe especificar fecha de vencimiento de acriditacion.' + CHAR(10);
    ELSE
    BEGIN
        IF @fecha_vencimiento_acreditacion < CAST(GETDATE() AS DATE)
            SET @estado_acreditacion = 'vencido';
        ELSE
            SET @estado_acreditacion = 'vigente';
    END
    
    IF @error != ''
        RAISERROR(@error, 16, 1);
    ELSE
    BEGIN
        BEGIN TRANSACTION
            INSERT INTO guia.Acreditacion VALUES(@fecha_vencimiento_acreditacion, @estado_acreditacion);
            
            SET @id_acreditacion = SCOPE_IDENTITY();

            INSERT INTO gestion.Guia VALUES(@dni, @nombre, @apellido, @id_acreditacion);

        COMMIT
    END
END
GO

-----------------------------------------------------------
-- Asignar guia a actividad

CREATE OR ALTER PROCEDURE gestion.sp_asignar_guia
@dni CHAR(8),
@nombre_actividad VARCHAR(50),
@nombre_parque VARCHAR(50),
@fecha_actividad DATETIME,
@f_desde DATE,
@f_hasta DATE
AS
BEGIN
    DECLARE @error VARCHAR(150);
    SET @error = '';

    DECLARE @id_guia INT;
    DECLARE @id_parque INT;
    DECLARE @id_actividad INT;

    IF @dni IS NULL
        SET @error += 'Se debe especificar el dni del guia.' + CHAR(10);
    ELSE
    BEGIN
        SET @id_guia = (SELECT id FROM gestion.Guia WHERE dni = @dni);  
        IF @id_guia IS NULL
            SET @error += 'El dni no pertenece a ningun guia.' + CHAR(10);
    END

    IF @nombre_parque IS NULL
        SET @error += 'Se debe especificar el nombre del parque.' + CHAR(10);
    ELSE
    BEGIN
        SET @id_parque = (SELECT id FROM gestion.Parque WHERE nombre = @nombre_parque);
        IF @id_parque IS NULL
            SET @error += 'El nombre no pertenece a ningun parque.' + CHAR(10);
        ELSE
        BEGIN
            IF @nombre_actividad IS NULL OR @fecha_actividad IS NULL
                SET @error += 'Se debe especificar el nombre y fecha de la actividad.' + CHAR(10);
            ELSE
            BEGIN
                SET @id_actividad = (SELECT id FROM gestion.Actividad 
                        WHERE nombre = @nombre_actividad AND id_parque = @id_parque AND fecha = @fecha_actividad
                    );
                IF @id_actividad IS NULL
                    SET @error += 'No existe una actividad con ese nombre en ese parque en esa fecha.' + CHAR(10); 
            END
        END
    END

    IF @f_desde IS NULL OR @f_hasta IS NULL
        SET @error += 'Se debe especificar la fecha desde y fecha hasta' + CHAR(10); 
    
    IF @id_guia IS NOT NULL AND EXISTS (SELECT g.id FROM gestion.Guia g
			INNER JOIN guia.Acreditacion a ON g.id_acreditacion = a.id
			WHERE g.id = @id_guia AND a.estado = 'vencido'
    )
        SET @error += 'El guia posee la acreditacion vencida' + CHAR(10); 
    ELSE
    BEGIN
        IF @id_actividad IS NOT NULL AND @f_desde IS NOT NULL AND @f_hasta IS NOT NULL
            IF EXISTS(SELECT id FROM gestion.Coordina 
                WHERE id_actividad = @id_actividad AND id_guia = @id_guia AND fecha_desde = @f_desde AND fecha_hasta = @f_hasta
            )
                SET @error += 'La actividad ya se encuentra asignada al guia' + CHAR(10); 
    END

    IF @error != ''
        RAISERROR(@error, 16, 1);
    ELSE
    BEGIN
        INSERT INTO gestion.Coordina VALUES(@id_actividad, @id_guia, @f_desde, @f_hasta);
    END
END
GO


/*
====================================================
		ABMS DE TABLA TIPO_VISITANTE
====================================================
*/
--ALTA VISITANTE--
USE parques_nacionales
GO
CREATE OR ALTER PROCEDURE ventas.sp_alta_tipo_visitante (@descripcion VARCHAR(20))
AS
BEGIN
	INSERT INTO ventas.tipo_visitante
	VALUES (@descripcion)
END
GO

--BAJA VISITANTE--
USE parques_nacionales
GO
CREATE OR ALTER PROCEDURE ventas.sp_baja_tipo_visitante (@descripcion VARCHAR(20))
AS
BEGIN
	DELETE FROM ventas.tipo_visitante
	WHERE descripcion = @descripcion
END
GO

--MODIFICACIÓN VISITANTE--
USE parques_nacionales
GO
CREATE OR ALTER PROCEDURE
ventas.sp_modificacion_tipo_visitante (@descripcion VARCHAR(20), @nueva_descripcion VARCHAR(20))
AS
BEGIN
	UPDATE ventas.tipo_visitante
	SET descripcion = @nueva_descripcion
	WHERE descripcion = @descripcion
END
GO

/*
====================================================
		ABMS DE TABLA PUNTO_DE_VENTA
====================================================
*/
--ALTA--
CREATE OR ALTER PROCEDURE ventas.sp_alta_punto_de_venta (@parque VARCHAR(50), @pov VARCHAR(30))
AS
BEGIN
	DECLARE @id_parque INT;
	SET @id_parque = (SELECT id FROM gestion.parque WHERE nombre = @parque)
	IF NOT EXISTS (
		SELECT descripcion
		FROM ventas.punto_de_venta
		WHERE parque = @id_parque
		AND descripcion = @pov) --Evita puntos de venta duplicados dentro de un mismo parque.
	INSERT INTO ventas.punto_de_venta VALUES (@id_parque, @pov)
END
GO
--BAJA--

CREATE OR ALTER PROCEDURE ventas.sp_baja_punto_de_venta (@parque VARCHAR(50), @pov VARCHAR(30))
AS
BEGIN
	DECLARE @parque_id VARCHAR(50)
	SET @parque_id = (SELECT id FROM gestion.parque WHERE nombre = @parque)
	DELETE FROM ventas.punto_de_venta WHERE descripcion = @pov AND parque = @parque_id
END
GO

--MODIFICACION--
	
CREATE OR ALTER PROCEDURE ventas.sp_modificacion_punto_de_venta (@parque VARCHAR(50), @pov VARCHAR(30), @nueva_descripcion VARCHAR(30))
AS
BEGIN
	DECLARE @parque_id VARCHAR(50)
	SET @parque_id = (SELECT id FROM gestion.parque WHERE nombre = @parque)

	UPDATE ventas.punto_de_venta
	SET descripcion = @nueva_descripcion
	WHERE descripcion = @pov AND parque = @parque_id
END
GO

/*
====================================================
		ABMS DE TABLA METODO DE PAGO
====================================================
*/
--ALTA--
CREATE OR ALTER PROCEDURE ventas.sp_alta_metodo_de_pago(@descripcion VARCHAR(25))
AS
BEGIN
	INSERT INTO ventas.metodo_de_pago
	VALUES (@descripcion) -- No hace falta verificar si ya existe para evitar duplicados porque es unique
END
GO

--BAJA--
CREATE OR ALTER PROCEDURE ventas.sp_baja_metodo_de_pago(@descripcion VARCHAR(25))
AS
BEGIN
	DELETE FROM ventas.metodo_de_pago
	WHERE descripcion = @descripcion -- Como es unique se va a eliminar solo el que corresponda
END
GO

--MODIFICACION--
CREATE OR ALTER PROCEDURE ventas.sp_modificacion_metodo_de_pago(@descripcion VARCHAR(25), @nueva_descripcion VARCHAR(25))
AS
BEGIN
	UPDATE ventas.metodo_de_pago
	SET descripcion = @nueva_descripcion
	WHERE descripcion = @descripcion
END
GO

/*
====================================================
		ABMS DE TABLA TIPOS DE ENTRADA
====================================================
*/


CREATE OR ALTER PROCEDURE ventas.sp_alta_tipo_entrada (@parque varchar(50), @tipo varchar(20), @precio DECIMAL(10,2), @vigencia DATE = NULL)
AS
BEGIN
	DECLARE @parque_id INT, @tipo_id INT
	IF @vigencia IS NULL SET @vigencia = GETDATE() --Si no se especifica una fecha de inicio, se asume el día presente


	SET @parque_id = (SELECT id FROM gestion.parque WHERE nombre = @parque);
	SET @tipo_id = (SELECT id FROM ventas.tipo_visitante WHERE descripcion = @tipo);

	IF NOT EXISTS ( SELECT 1 FROM ventas.vw_entradas_vigentes WHERE Parque = @parque AND Visitante = @tipo)
	INSERT INTO ventas.entrada(parque, tipo, precio, fecha_desde)
	VALUES(
		@parque_id,
		@tipo_id,
		@precio,
		@vigencia
		)
END
GO

--BAJA--
CREATE OR ALTER PROCEDURE ventas.sp_baja_tipo_entrada (@parque varchar(50), @tipo varchar(20))
AS
BEGIN
	DECLARE @parque_id INT, @tipo_id INT
	SET @parque_id = (SELECT id FROM gestion.parque WHERE nombre = @parque);
	SET @tipo_id = (SELECT id FROM ventas.tipo_visitante WHERE descripcion = @tipo)
	DELETE FROM ventas.entrada
	WHERE parque = @parque_id AND tipo = @tipo_id
END
GO

-- MODIFICACION --
/* Modifica el precio según el parque y tipo de visitante. Cuando se modifica, el precio actual pasa al histórico.
Ej: (Iguazu, estudiante, 3000) --> (Iguazu, estudiante, 4500)
*/

CREATE OR ALTER PROCEDURE ventas.sp_modificacion_tipo_entrada
(
	@parque varchar(50),
	@tipo varchar(20),
	@nuevo_precio DECIMAL(10,2),
	@fecha_comienzo DATE
)
AS
BEGIN
	DECLARE @parque_id INT, @tipo_id INT;
	SET @parque_id = (SELECT id FROM gestion.parque WHERE nombre = @parque);
	SET @tipo_id = (SELECT id FROM ventas.tipo_visitante WHERE descripcion = @tipo);

	DECLARE @errores VARCHAR(200)
	DECLARE @fecha_desde_actual DATE;

	SET @fecha_desde_actual = (SELECT fecha_desde FROM ventas.entrada WHERE tipo = @tipo_id AND parque = @parque_id)
	
	IF @fecha_comienzo < @fecha_desde_actual
	SET @errores = (SELECT CONCAT(@errores, 'La fecha de comienzo de la nueva vigencia debe ser posterior a la vigencia actual. '))

	BEGIN TRY
		BEGIN TRANSACTION
			UPDATE ventas.entrada
			SET fecha_hasta = DATEADD(day, -1, @fecha_comienzo)
			WHERE tipo = @tipo_id AND parque = @parque_id AND fecha_hasta IS NULL;
			EXEC ventas.sp_alta_tipo_entrada @parque = @parque, @tipo = @tipo, @precio = @nuevo_precio, @vigencia = @fecha_comienzo;
		COMMIT;
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0 --IF @@TRANCOUNT > 0?
			ROLLBACK
	END CATCH
	PRINT @errores
END
GO
/*
====================================================
		ABMS DE TABLA VENTAS
====================================================
*/
USE parques_nacionales
GO
-- Alta de ventas --

CREATE OR ALTER PROCEDURE ventas.sp_alta_venta(@parque VARCHAR(50), @fecha DATE = NULL, @pov VARCHAR(25), @metodo VARCHAR(30), @id_creado INT OUTPUT)
AS
BEGIN
	IF @fecha IS NULL SET @fecha = GETDATE() --Si no se especifica fecha, asumimos que es del día

	DECLARE @id_parque VARCHAR(50), @id_pov VARCHAR(25), @id_metodo VARCHAR(25);

	SET @id_parque = (SELECT id FROM gestion.parque WHERE nombre = @parque)
	SET @id_pov = (SELECT id FROM ventas.punto_de_venta WHERE descripcion = @pov AND parque = @id_parque)
	SET @id_metodo = (SELECT id FROM ventas.metodo_de_pago WHERE descripcion = @metodo)

	INSERT INTO ventas.venta
	VALUES(@id_parque, @fecha, @id_pov, @id_metodo, 0)
	
	SET @id_creado = (SELECT SCOPE_IDENTITY())


END
GO

--BAJA--

CREATE OR ALTER PROCEDURE ventas.sp_baja_venta(@venta INT)
AS
BEGIN
	--Primero tengo que eliminar los items asociados a esa venta
	BEGIN TRANSACTION
		BEGIN TRY
			DELETE FROM ventas.item_venta
			WHERE venta = @venta

			DELETE FROM ventas.venta
			WHERE id = @venta
			COMMIT
		END TRY
		BEGIN CATCH
			IF XACT_STATE() <> 0
				ROLLBACK
		END CATCH
END
GO


--MODIFICACION--
CREATE OR ALTER PROCEDURE ventas.sp_modificacion_venta(@id_venta INT, @metodo VARCHAR(30))
AS
BEGIN
	UPDATE ventas.venta
	SET metodo = @metodo
	WHERE id = @id_venta
END
GO
/*
====================================================
		ABMS DE TABLA ITEMS DE VENTA
====================================================
*/

--ALTA--
CREATE OR ALTER PROCEDURE ventas.sp_alta_item_venta(@venta INT, @concepto VARCHAR(20), @cantidad INT, @fecha_acceso DATE)
AS
BEGIN
	DECLARE @id_concepto INT, @precio DECIMAL(10, 2), @id_parque INT;
	DECLARE @parque VARCHAR(50)

	SET @id_parque = (SELECT parque FROM ventas.venta WHERE id = @venta)
	SET @parque = (SELECT nombre FROM gestion.parque WHERE id = @id_parque)
	SET @id_concepto = (SELECT id_visitante FROM ventas.vw_entradas_vigentes WHERE parque = @parque AND visitante = @concepto)
	SET @precio = (SELECT precio FROM ventas.vw_entradas_vigentes WHERE parque = @parque AND visitante = @concepto)
	
	BEGIN TRANSACTION
		BEGIN TRY
			INSERT INTO ventas.item_venta
			VALUES (@venta, @id_concepto, @cantidad, @precio, @cantidad * @precio, @fecha_acceso)

			UPDATE ventas.venta
			SET total = total + @cantidad * @precio
			WHERE id = @venta
			
			COMMIT
		END TRY
		BEGIN CATCH
			IF XACT_STATE() <>0
				ROLLBACK
		END CATCH
END
GO

--BAJA--
CREATE OR ALTER PROCEDURE ventas.sp_baja_item_venta(@venta INT, @item INT)
AS
BEGIN
	DELETE FROM ventas.item_venta
	WHERE venta = @venta
	AND
	id = @item
END
GO

--Modificacion--

CREATE OR ALTER PROCEDURE ventas.sp_modificar_item_venta(@venta INT, @item INT, @nuevo_concepto INT, @nueva_cantidad INT)
AS
BEGIN
	DECLARE @subtotal_actualizado DECIMAL(10,2), @subtotal DECIMAL (10,2);
	SET @subtotal = (SELECT subotal FROM ventas.item_id WHERE id = @item)
	SET @subtotal_actualizado = (SELECT precio FROM ventas.entrada WHERE id = @nuevo_concepto) * @nueva_cantidad


	BEGIN TRANSACTION
		BEGIN TRY
			UPDATE ventas.item_venta
			SET concepto = @nuevo_concepto, cantidad = @nueva_cantidad,
			subtotal = @nueva_cantidad * @subtotal_actualizado
			WHERE venta = @venta
			AND id = @item

			UPDATE ventas.venta
			SET total = (total - @subtotal) + @subtotal_actualizado
			WHERE id = @venta
			COMMIT
		END TRY
		BEGIN CATCH
			IF XACT_STATE() <> 0
				ROLLBACK
		END CATCH
	
END
GO

/*
======================
REGISTRAR VENTAS CON JSON
========================
*/
CREATE OR ALTER PROCEDURE ventas.ingresar_venta(@parque VARCHAR(50), @fecha DATE, @punto VARCHAR(20), @metodo VARCHAR(20))
AS
BEGIN
	DECLARE @id_venta INT;
	EXEC ventas.sp_alta_venta @parque = @parque, @pov = @punto, @metodo = @metodo, @id_creado = @id_venta OUTPUT;
	
	DECLARE @tabla_test TABLE (concepto VARCHAR(20), fecha DATE, cantidad INT, precio DECIMAL(10,2))

	INSERT INTO @tabla_test
	SELECT concepto, fecha, cantidad, precio
	FROM OPENROWSET (BULK 'F:\Facu\02. Bases de Datos Aplicadas\TP\ventas.json', SINGLE_CLOB) as j
	CROSS APPLY OPENJSON(BulkColumn)
	WITH
	(
		concepto VARCHAR(20) '$.concepto',
		fecha DATE '$.fecha_acceso',
		cantidad INT '$.cantidad',
		precio DECIMAL(10,2) '$.precio'
	)
	SELECT * FROM @tabla_test

	declare @test TABLE(id int, venta int, concepto varchar(20), cantidad int, precio decimal(10,2), subtotal decimal(10,2), fecha date)
	
	INSERT INTO ventas.item_venta
	SELECT
	@id_venta,
	(SELECT precio FROM ventas.vw_entradas_vigentes WHERE visitante = concepto and parque = @parque) AS concepto,
	cantidad,
	precio,
	precio * cantidad,
	fecha
	FROM @tabla_test

	UPDATE ventas.venta
	SET total = (SELECT sum(subtotal) as total FROM ventas.item_venta WHERE venta = @id_venta group by venta)
	WHERE id = @id_venta


	SELECT * from ventas.item_venta WHERE venta = @id_venta
	SELECT * from ventas.venta WHERE id = @id_venta

END

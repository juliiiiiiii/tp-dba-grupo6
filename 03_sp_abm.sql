
-- Universidad: Universidad de la Matanza
-- Materia: Bases de Datos Aplicadas
 
-- Grupo 06
-- Integrantes:
--  De Bellis, Nahuel
--  Ocampo, Julian Rafael
--  Rodriguez, Gonzalo Ezequiel
--  Vargas, Tomas
 
-- Objetivo del script: Generacion de SP de operaciones ABM
 
-- Fecha: 14/06/2026

USE parques_nacionales
GO

/*
====================================================
		ABMS DE TABLA UBICACION
====================================================
*/

CREATE OR ALTER PROCEDURE gestion.ubicacion_alta
    @provincia VARCHAR(50)
AS
BEGIN
    DECLARE @error VARCHAR(70);
    SET @error = '';

    IF @provincia IS NULL OR @provincia = ''
        SET @error += 'Se debe especificar la provincia.' + CHAR(10);
    ELSE
    BEGIN
        IF EXISTS (SELECT id from gestion.Ubicacion WHERE provincia = @provincia)
            SET @error += 'La provincia ya se encuentra registrada.' + CHAR(10);
    END

    IF @error != ''
        THROW 50000, @error, 1;
    ELSE
        INSERT INTO gestion.Ubicacion VALUES(@provincia); 
END
GO

CREATE OR ALTER PROCEDURE gestion.ubicacion_baja
    @provincia VARCHAR(50)
AS
BEGIN
    DECLARE @error VARCHAR(70);
    DECLARE @id_prov INT;
    SET @error = '';

    IF @provincia IS NULL OR @provincia = ''
        SET @error += 'Se debe especificar la provincia.' + CHAR(10);
    ELSE
    BEGIN
        SELECT @id_prov = id FROM gestion.Ubicacion WHERE provincia = @provincia;

        IF @id_prov IS NULL
            SET @error += 'La provincia no se encuentra registrada.' + CHAR(10);

        IF EXISTS (SELECT 1 from gestion.Parque WHERE id_ubicacion = @id_prov)
            SET @error += 'La provincia se encuentra registrada en un parque.' + CHAR(10);
    END

    IF @error != ''
        THROW 50000, @error, 1;
    ELSE
        DELETE FROM gestion.Ubicacion WHERE id = @id_prov; 
END
GO

CREATE OR ALTER PROCEDURE gestion.ubicacion_modificacion
    @provincia VARCHAR(50),
    @provincia_nueva VARCHAR(50)
AS
BEGIN
    DECLARE @error VARCHAR(70);
    DECLARE @id_prov INT;
    SET @error = '';

    IF @provincia IS NULL OR @provincia = ''
        SET @error += 'Se debe especificar la provincia.' + CHAR(10);
    ELSE
    BEGIN
        SELECT @id_prov = id FROM gestion.Ubicacion WHERE provincia = @provincia;

        IF @id_prov IS NULL
            SET @error += 'La provincia no se encuentra registrada.' + CHAR(10);
    END

    IF @error != ''
        THROW 50000, @error, 1;
    ELSE
        UPDATE gestion.Ubicacion SET provincia = @provincia_nueva WHERE id = @id_prov;
END
GO

/*
====================================================
		ABMS DE TABLA PARQUE
====================================================
*/

CREATE OR ALTER PROCEDURE gestion.parque_alta
	@nombre VARCHAR(100),
	@tipo VARCHAR(50),
	@ubicacion VARCHAR(50),
	@superficie INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @errores VARCHAR(100);
    DECLARE @id_ubicacion INT = NULL;
	SET @errores = '';

	IF EXISTS (SELECT nombre FROM gestion.Parque WHERE nombre = @nombre)
		SET @errores += 'El nombre del parque ya se encuentra registrado.' + CHAR(10);

    IF @ubicacion IS NOT NULL AND LTRIM(RTRIM(@ubicacion)) != ''
    BEGIN
        SELECT @id_ubicacion = id FROM gestion.Ubicacion 
        WHERE provincia = @ubicacion;

        IF @id_ubicacion IS NULL
            SET @errores += 'La ubicacion del parque no es valida.' + CHAR(10);
	END

	IF @superficie <= 0
        SET @errores += 'La superficie debe ser un valor positivo.' + CHAR(10);

	IF @errores != ''
		THROW 50000, @errores, 1;

	INSERT INTO gestion.Parque (nombre, tipo, superficie, estado, id_ubicacion)
	VALUES (@nombre, @tipo, @superficie, 'Activo', @id_ubicacion);
END
GO

CREATE OR ALTER PROCEDURE gestion.parque_baja
    @nombre VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @errores VARCHAR(200);
    DECLARE @id INT = NULL;
	SET @errores = '';

    SELECT @id = id FROM gestion.Parque WHERE nombre = @nombre;
	IF @id IS NULL
		SET @errores += 'El parque que se desea dar de baja no existe.' + CHAR(10);
	ELSE
        IF (SELECT estado FROM gestion.Parque WHERE id = @id) = 'Inactivo'
            SET @errores += 'El parque ya se encuentra dado de baja.' + CHAR(10);

	IF EXISTS (SELECT id_parque FROM gestion.Parque_asignado WHERE id_parque = @id AND fecha_egreso IS NULL)
		SET @errores += 'El parque que se desea dar de baja tiene guardaparque asignado.' + CHAR(10);

	IF EXISTS (SELECT 1 FROM gestion.Actividad WHERE id_parque = @id AND estado IN ('Programado', 'En curso', 'Finalizado'))
        SET @errores += 'El parque tiene actividades activas. Cancelalas antes de dar de baja el parque.' + CHAR(10);

	-- Si se agrega estado en actividad, hay que modificar aca el estado de programada a cancelada

	IF @errores != ''
		THROW 50000, @errores, 1;

    BEGIN TRANSACTION
        UPDATE gestion.Parque SET estado = 'Inactivo' WHERE id = @id;
    COMMIT
END
GO

CREATE OR ALTER PROCEDURE gestion.parque_modificacion
	@nombre VARCHAR(100),
	@tipo VARCHAR(50),
	@ubicacion VARCHAR(50),
	@superficie INT,
    @nombre_nuevo varchar(100) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @errores VARCHAR(100);
    DECLARE @id_ubicacion INT = NULL;
    DECLARE @id INT;

	SET @errores = '';

    SELECT @id = id FROM gestion.Parque WHERE nombre = @nombre;

	IF @id IS NULL
        SET @errores += 'El parque que se desea modificar no existe.' + CHAR(10);
    ELSE
    BEGIN
        IF @tipo IS NULL AND @ubicacion IS NULL AND @superficie IS NULL
            SET @errores += 'Debe ingresar valores para modificar al parque.' + CHAR(10);
        ELSE
        BEGIN
            IF @ubicacion IS NOT NULL AND LTRIM(RTRIM(@ubicacion)) != ''
            BEGIN
                SELECT @id_ubicacion = id FROM gestion.Ubicacion WHERE provincia = @ubicacion;

                IF @id_ubicacion IS NULL
                    SET @errores += 'La ubicacion del parque no es valida.' + CHAR(10);
	        END
            ELSE
                SELECT @id_ubicacion = id_ubicacion FROM gestion.Parque WHERE @id = id;

            IF @tipo IS NULL
                    SELECT @tipo = tipo FROM gestion.Parque WHERE @id = id;

            IF @superficie <= 0
                SET @errores += 'La superficie debe ser un valor positivo.' + CHAR(10);
            ELSE IF @superficie IS NULL
                SELECT @superficie = superficie FROM gestion.Parque WHERE id = @id;

            IF @nombre_nuevo = '' or @nombre_nuevo is null
                SET @errores += 'El nombre nuevo no puede ser vacio o null.' + CHAR(10);
            IF exists (SELECT 1 FROM gestion.Parque WHERE nombre = @nombre_nuevo)
                SET @errores += 'El nombre nuevo ya existe' + CHAR(10);
        END
    END

    IF @errores != ''
        THROW 50000, @errores, 1;
 
    UPDATE gestion.Parque SET nombre = isnull(@nombre_nuevo, nombre), tipo = @tipo, superficie = @superficie, id_ubicacion = @id_ubicacion WHERE id = @id;
END
GO

/*
====================================================
		ABMS DE TABLA GUARDAPARQUE
====================================================
*/

CREATE OR ALTER PROCEDURE personal.Guardaparque_alta
	@dni CHAR(8),
	@nombre CHAR(30),
	@apellido CHAR(30)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @errores VARCHAR(50);
	SET @errores = '';

	IF EXISTS (SELECT dni FROM personal.Guardaparque WHERE dni = @dni)
		SET @errores += 'El dni del guardaparque ya esta registrado.' + CHAR(10);

    IF (@nombre IS NULL OR @apellido IS NULL)
        SET @errores += 'Debe ingresar nombre y apellido.' + CHAR(10);

	IF @errores != ''
		THROW 50000, @errores, 1;

	INSERT INTO personal.Guardaparque (dni, nombre, apellido, estado)
	VALUES (@dni, @nombre, @apellido, 'Inactivo');
END
GO

CREATE OR ALTER PROCEDURE personal.Guardaparque_baja
	@dni CHAR(8)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @errores VARCHAR(100);
    DECLARE @id INT = NULL;
	SET @errores = '';

    SELECT @id = id FROM personal.Guardaparque WHERE dni = @dni
	IF @id IS NULL
		SET @errores += 'El guardaparque que se quiere dar de baja no existe.' + CHAR(10);
    ELSE
	    IF (SELECT estado FROM personal.Guardaparque WHERE id = @id) != 'Activo'
		    SET @errores += 'El guardaparque no se encuentra asignado a ningun parque.' + CHAR(10);

	IF @errores != ''
		THROW 50000, @errores, 1;

	BEGIN TRANSACTION;
        IF EXISTS (SELECT id_guardaparque FROM gestion.Parque_asignado WHERE id_guardaparque = @id AND fecha_egreso IS NULL)
            UPDATE gestion.Parque_asignado SET fecha_egreso = GETDATE() WHERE id_guardaparque = @id AND fecha_egreso IS NULL;

        UPDATE personal.Guardaparque SET estado = 'Inactivo' WHERE id = @id;
    COMMIT;
END
GO

CREATE OR ALTER PROCEDURE personal.Guardaparque_modificacion
    @dni CHAR(8),
    @nombre CHAR(30),
    @apellido CHAR(30),
    @estado CHAR(8)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @errores VARCHAR(150);
    DECLARE @id INT = NULL;
    SET @errores = '';
 
    SELECT @id = id FROM personal.Guardaparque WHERE dni = @dni;

    IF @id IS NULL
        SET @errores += 'El guardaparque que se desea modificar no existe.' + CHAR(10);
    ELSE
    BEGIN
        IF @dni IS NULL AND @nombre IS NULL AND @apellido IS NULL AND @estado IS NULL
            SET @errores += 'Debe ingresar valores para modificar al guardaparque.' + CHAR(10);
        ELSE
        BEGIN
            IF @nombre IS NULL
                SELECT @nombre = nombre FROM personal.Guardaparque WHERE id = @id;

            IF @apellido IS NULL
                SELECT @apellido = apellido FROM personal.Guardaparque WHERE id = @id;

            IF @estado IS NOT NULL AND @estado NOT IN ('Activo', 'Inactivo')
                SET @errores += 'El estado ingresado no es valido. Los valores permitidos son: Activo o Inactivo.' + CHAR(10);
            ELSE IF @estado IS NULL
                SELECT @estado = estado FROM personal.Guardaparque WHERE id = @id;
 
            IF @estado = 'Activo'
            AND NOT EXISTS(SELECT id_guardaparque FROM gestion.Parque_asignado WHERE id_guardaparque = @id AND fecha_egreso IS NULL)
                SET @errores += 'No se puede establecer como activo a un guardaparque que no tiene asignacion activa.' + CHAR(10);
        END
    END

    IF @errores != ''
        THROW 50000, @errores, 1;
 
    UPDATE personal.Guardaparque SET nombre = @nombre, apellido = @apellido, estado = @estado WHERE id = @id;
END
GO

/*
====================================================
		ABMS DE TABLA ESPECIALIDAD
====================================================
*/

CREATE OR ALTER PROCEDURE personal.especialidad_alta
    @descripcion VARCHAR(50)
AS
BEGIN
    DECLARE @error VARCHAR(70);
    SET @error = '';

    IF @descripcion IS NULL OR @descripcion = ''
        SET @error += 'Se debe especificar la descripcion de la especialidad.' + CHAR(10);
    ELSE
        IF EXISTS (SELECT descripcion from personal.Especialidad WHERE descripcion = @descripcion)
            SET @error += 'La especialidad ya se encuentra registrada.' + CHAR(10);

    IF @error != ''
        THROW 50000, @error, 1;
    ELSE
        INSERT INTO personal.Especialidad VALUES(@descripcion); 
END
GO

CREATE OR ALTER PROCEDURE personal.especialidad_baja
    @descripcion VARCHAR(50)
AS
BEGIN
    DECLARE @error VARCHAR(70);
    DECLARE @id_especialidad INT;
    SET @error = '';

    IF @descripcion IS NULL OR @descripcion = ''
        SET @error += 'Se debe especificar la descripcion de la especialidad.' + CHAR(10);
    ELSE
    BEGIN
        SELECT @id_especialidad = id FROM personal.Especialidad WHERE descripcion = @descripcion;

        IF @id_especialidad IS NULL
            SET @error += 'La especialidad no se encuentra registrada.' + CHAR(10);
        ELSE IF EXISTS (SELECT 1 FROM personal.Especializado_en WHERE id_especialidad = @id_especialidad)
            SET @error += 'La especialidad se encuentra registrada a un guia.' + CHAR(10);
    END

    IF @error != ''
        THROW 50000, @error, 1;
    ELSE
        DELETE FROM personal.Especialidad WHERE id = @id_especialidad;
END
GO

CREATE OR ALTER PROCEDURE personal.especialidad_modificacion
    @descripcion VARCHAR(50),
    @descripcion_nueva VARCHAR(50)
AS
BEGIN
    DECLARE @error VARCHAR(70);
    DECLARE @id_especialidad INT;
    SET @error = '';

    IF @descripcion IS NULL OR @descripcion = '' OR @descripcion_nueva IS NULL
        SET @error += 'Se debe especificar la descripcion de la especialidad.' + CHAR(10);
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT descripcion FROM personal.Especialidad WHERE descripcion = @descripcion)
            SET @error += 'La especialidad no se encuentra registrada.' + CHAR(10);

        SELECT @id_especialidad = id FROM personal.Especialidad WHERE descripcion = @descripcion;
    END

    IF @error != ''
        THROW 50000, @error, 1;
    ELSE
        UPDATE personal.Especialidad SET descripcion = @descripcion_nueva WHERE  id = @id_especialidad;
END
GO

/*
====================================================
		ABMS DE TABLA GUIA
====================================================
*/

CREATE OR ALTER PROCEDURE personal.Guia_alta
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
            IF EXISTS (SELECT id FROM personal.Guia WHERE dni = @dni)
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
        THROW 50000, @error, 1;
    ELSE
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION
                INSERT INTO personal.Acreditacion VALUES(@fecha_vencimiento_acreditacion, @estado_acreditacion);
            
                SET @id_acreditacion = SCOPE_IDENTITY();

                INSERT INTO personal.Guia (dni, nombre, apellido, estado, id_acreditacion) VALUES (@dni, @nombre, @apellido, 'ACTIVO', @id_acreditacion);
            COMMIT
        END TRY
        BEGIN CATCH
            IF XACT_STATE() <> 0
                ROLLBACK
        END CATCH
    END
END
GO

CREATE OR ALTER PROCEDURE personal.Guia_baja
    @dni CHAR(8)
AS
BEGIN
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
            IF NOT EXISTS (SELECT 1 FROM personal.Guia WHERE dni = @dni)
                SET @error += 'El dni no pertenece a un guia.' + CHAR(10);
            IF EXISTS (SELECT 1 FROM personal.Guia WHERE dni = @dni AND estado = 'INACTIVO')
                SET @error += 'El guia ya esta dado de baja.' + CHAR(10);
        END    
    END
    
    IF @error != ''
        THROW 50000, @error, 1;
    ELSE
        UPDATE personal.Guia SET estado = 'INACTIVO' WHERE dni = @dni;
END
GO

CREATE OR ALTER PROCEDURE personal.Guia_modificacion
    @dni CHAR(8),
    @nombre VARCHAR(30),
    @apellido VARCHAR(30)
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
        IF @nombre IS NULL AND @apellido IS NULL
            SET @error += 'Se debe especificar nombre y apellido del guia.' + CHAR(10);
        ELSE
        BEGIN
            IF @dni NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
                SET @error += 'Ingresar dni valido.' + CHAR(10);
            ELSE
                IF NOT EXISTS (SELECT id FROM personal.Guia WHERE dni = @dni)
                    SET @error += 'El dni no pertenece a un guia.' + CHAR(10);

            IF @nombre IS NULL
                SELECT @nombre = nombre FROM personal.Guia WHERE dni = @dni;
            IF @apellido IS NULL
                SELECT @apellido = apellido FROM personal.Guia WHERE dni = @dni;
        END
    END
    IF @error != ''
        THROW 50000, @error, 1;
    ELSE
        UPDATE personal.Guia SET nombre = @nombre, apellido = @apellido WHERE dni = @dni
END
GO

/*
====================================================
		ABMS DE TABLA TIPO ACTIVIDAD
====================================================
*/

CREATE OR ALTER PROCEDURE gestion.tipo_actividad_alta
	@descripcion CHAR(25)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @errores VARCHAR(50);
    SET @errores = '';

    IF EXISTS (SELECT descripcion FROM gestion.Tipo_actividad WHERE descripcion = @descripcion)
        SET @errores += 'El tipo de actividad ya existe.' + CHAR(10);

    IF @errores != ''
        THROW 50000, @errores, 1;

	INSERT INTO gestion.Tipo_actividad (descripcion) VALUES (@descripcion);
END
GO

CREATE OR ALTER PROCEDURE gestion.tipo_actividad_baja
	@descripcion CHAR(25)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @errores VARCHAR(70);
    DECLARE @id_tipo INT = NULL;
    SET @errores = '';

    IF NOT EXISTS (SELECT descripcion FROM gestion.Tipo_actividad WHERE descripcion = @descripcion)
        SET @errores += 'El tipo de actividad que se quiere dar de baja no existe.' + CHAR(10);
    ELSE
    BEGIN
        SELECT @id_tipo = id FROM gestion.Tipo_actividad WHERE descripcion = @descripcion

        IF EXISTS (SELECT 1 FROM gestion.Actividad WHERE id_tipo = @id_tipo)
            SET @errores += 'El tipo de actividad que se quiere dar de baja existe en al menos una actividad.' + CHAR(10);
    END

    IF @errores != ''
        THROW 50000, @errores, 1;

	DELETE FROM gestion.Tipo_actividad WHERE descripcion = @descripcion;
END
GO

CREATE OR ALTER PROCEDURE gestion.tipo_actividad_modificacion
	@descripcion CHAR(25),
    @descripcion_nueva CHAR(25)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @errores VARCHAR(50);
    DECLARE @id_tipo INT = NULL;
    SET @errores = '';

    SELECT @id_tipo = id FROM gestion.Tipo_actividad WHERE descripcion = @descripcion;
    IF @id_tipo IS NULL
        SET @errores += 'El tipo de actividad no existe.' + CHAR(10);
    ELSE
    BEGIN
        IF @descripcion_nueva IS NULL
            SET @errores += 'Debe ingresar un tipo de actividad.' + CHAR(10);
        ELSE IF EXISTS (SELECT 1 FROM gestion.Tipo_actividad WHERE descripcion = @descripcion_nueva)
            SET @errores += 'El tipo de actividad que se quiere registrar ya existe.' + CHAR(10);
    END

    IF @errores != ''
        THROW 50000, @errores, 1;

	UPDATE gestion.Tipo_actividad SET descripcion = @descripcion_nueva WHERE descripcion = @descripcion;
END
GO

/*
====================================================
		ABMS DE TABLA ACTIVIDAD
====================================================
*/

CREATE OR ALTER PROCEDURE gestion.actividad_alta
	@nombre_parque VARCHAR(100),
	@dni_guia CHAR(8),
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

	DECLARE @errores VARCHAR(300);
    DECLARE @id_parque INT = NULL;
    DECLARE @id_guia INT = NULL;
	DECLARE @id_tipo INT = NULL;
	SET @errores = '';

    SELECT @id_parque = id FROM gestion.Parque WHERE nombre = @nombre_parque;
    IF @id_parque IS NULL
        SET @errores += 'El parque en el que se quiere registrar la actividad no existe.' + CHAR(10);

    SELECT @id_guia = id FROM personal.Guia WHERE dni = @dni_guia;
    IF @id_guia IS NULL
        SET @errores += 'El guia en el que se quiere registrar la actividad no existe.' + CHAR(10);
    ELSE
        IF NOT EXISTS(
			SELECT g.id FROM personal.Guia g
			INNER JOIN personal.Acreditacion a ON g.id_acreditacion = a.id
			WHERE g.id = @id_guia AND a.estado = 'vigente' AND a.fecha_vencimiento >= GETDATE()
		)
			SET @errores += 'El guia no esta autorizado a supervisar una actividad.' + CHAR(10);

    SELECT @id_tipo = id FROM gestion.Tipo_actividad WHERE descripcion = @tipo;
    IF @id_tipo IS NULL
		SET @errores += 'El tipo de actividad es invalido.' + CHAR(10);

	IF @fecha <= GETDATE()
		SET @errores += 'No se puede establecer una actividad para fechas pasadas.' + CHAR(10);

    IF @nombre IS NULL
        SET @errores += 'No se puede establecer una actividad sin nombre.' + CHAR(10);

	IF @descripcion IS NULL
        SET @errores += 'No se puede establecer una actividad sin descripcion.' + CHAR(10);

    IF @costo IS NULL OR @costo <= 0
        SET @errores += 'No se puede establecer una actividad sin costo positivo.' + CHAR(10);

    IF @duracion IS NULL OR @duracion <= 0
        SET @errores += 'No se puede establecer una actividad sin duracion positiva.' + CHAR(10);

    IF @cupo IS NULL OR @cupo <= 0
        SET @errores += 'No se puede establecer una actividad sin cupo positivo.' + CHAR(10);

	IF @errores != ''
		THROW 50000, @errores, 1;

	INSERT INTO gestion.Actividad (id_parque, id_tipo, nombre, descripcion, costo, fecha, duracion, cupo, estado)
	VALUES (@id_parque, @id_tipo, @nombre, @descripcion, @costo, @fecha, @duracion, @cupo, 'Programado');
END
GO

CREATE OR ALTER PROCEDURE gestion.actividad_baja
    @nombre CHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(100);
    DECLARE @id_actividad INT = NULL;
    DECLARE @estado_actual CHAR(10);
    SET @errores = '';

    SELECT @id_actividad = id FROM gestion.Actividad WHERE nombre = @nombre;
    IF @id_actividad IS NULL
        SET @errores += 'La actividad que se desea cancelar no existe.' + CHAR(10);

    SELECT @estado_actual = estado FROM gestion.Actividad WHERE id = @id_actividad;

    IF @estado_actual IN ('Cancelado', 'Finalizado', 'En curso')
        SET @errores += 'La actividad no puede ser cancelada. Estado actual: ' + RTRIM(@estado_actual) + CHAR(10);

    IF @errores != ''
        THROW 50000, @errores, 1;

    UPDATE gestion.Actividad SET estado = 'Cancelado' WHERE id = @id_actividad;

    -- Tener en cuenta que hacer si hay entradas con actividades programadas
END
GO

CREATE OR ALTER PROCEDURE gestion.actividad_modificacion
    @nombre CHAR(50),
    @descripcion VARCHAR(100),
    @tipo CHAR(25),
    @costo DECIMAL(9,2),
    @fecha DATE,
    @duracion INT,
    @cupo INT,
	@estado CHAR(10),
    @dni_guia CHAR(8)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @errores VARCHAR(400);
    DECLARE @id_actividad INT = NULL;
    DECLARE @id_guia INT = NULL;
	DECLARE @id_tipo INT;
	DECLARE @estado_actual CHAR(10);
	
    SET @errores = '';

    SELECT @id_actividad = id FROM gestion.Actividad WHERE nombre = @nombre;
	SELECT @id_tipo = id FROM gestion.Tipo_actividad WHERE descripcion = @tipo;
 
    IF NOT EXISTS (SELECT id FROM gestion.Actividad WHERE id = @id_actividad)
        SET @errores += 'La actividad que se desea modificar no existe.' + CHAR(10);
	ELSE
	BEGIN
		SELECT @estado_actual = estado FROM gestion.Actividad WHERE id = @id_actividad;

        IF @estado_actual IN ('Cancelado', 'Finalizado', 'En curso')
            SET @errores += 'No se puede modificar una actividad que esta ' + RTRIM(@estado_actual) + '.' + CHAR(10);
    END

    SELECT @id_guia = id FROM personal.Guia WHERE dni = @dni_guia;
    IF NOT EXISTS (SELECT id FROM personal.Guia WHERE id = @id_guia)
        SET @errores += 'El guia especificado no existe.' + CHAR(10);
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT g.id FROM personal.Guia g
            INNER JOIN personal.Acreditacion a ON g.id_acreditacion = a.id
            WHERE g.id = @id_guia
              AND a.estado = 'Activo'
              AND a.fecha_vencimiento >= GETDATE()
        )
            SET @errores += 'El guia no esta autorizado a supervisar una actividad.' + CHAR(10);
    END

	IF @id_tipo IS NULL
		SET @errores += 'El tipo de actividad no es valido.' + CHAR(10);

    IF @descripcion IS NULL
        SET @errores += 'La descripcion de actividad no es valida.' + CHAR(10);

	IF @estado NOT IN ('Programado', 'Cancelado', 'Finalizado', 'En curso', 'Cupo lleno')
        SET @errores += 'El estado ingresado no es valido.' + CHAR(10);

    IF @fecha <= GETDATE()
        SET @errores += 'No se puede establecer una actividad para fechas pasadas.' + CHAR(10);
 
    IF @duracion IS NULL OR @duracion <= 0
        SET @errores += 'La duracion debe ser un valor positivo.' + CHAR(10);
 
    IF @cupo IS NULL OR @cupo <= 0
        SET @errores += 'El cupo debe ser un valor positivo.' + CHAR(10);
 
    IF @costo IS NULL OR @costo < 0
        SET @errores += 'El costo debe ser un valor positivo o 0 si es gratuita.' + CHAR(10);
 
    IF @errores != ''
        THROW 50000, @errores, 1;
 
    UPDATE gestion.Actividad SET id_tipo = @id_tipo, descripcion = @descripcion, costo = @costo, fecha = @fecha, duracion = @duracion, cupo = @cupo, estado = @estado
    WHERE id = @id_actividad;
END
GO

/*
====================================================
		ABMS DE TABLA EMPRESA
====================================================
*/

create or alter procedure concesiones.empresa_alta (@nombre varchar(25), @tipo varchar(100), @cuit varchar(15)) as begin
	-- vale la pena una funcion para ver si el cuit es valido? -> si + raiserror con un solo mensaje
    declare @errores varchar(4000) = '';

    if @cuit is not null and len(@cuit) <> 11
        set @errores = 'El cuit solo puede tener 11 caracteres.' + char(10)

    if @cuit is not null and not (@cuit like '3[034][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' or @cuit like '2[0347][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
        set @errores += 'El cuit no tiene el formato de una empresa.' + char(10)

    if @errores <> ''
        THROW 50000, @errores, 1;

	insert into concesiones.Empresa (nombre, tipo, cuit) values (@nombre, @tipo, @cuit);
end;
go

create or alter procedure concesiones.empresa_baja (@nombre varchar(25)) as begin
    declare @id int;
    declare @errores varchar(4000) = '';

    select @id = id from concesiones.Empresa where nombre=@nombre;

    if @id is null
        set @errores = 'No se encontro la empresa.' + char(10)

    if @errores <> ''
        THROW 50000, @errores, 1;

	delete from concesiones.Empresa where id=@id
end;
go

create or alter procedure concesiones.empresa_modificacion (
    @nombre varchar(25),
    @nuevo_nombre varchar(25) = null,
    @tipo varchar(100) = null,
    @cuit varchar(15) = null
) as begin
    declare @id int;
    declare @errores varchar(4000) = '';

    select @id = id from concesiones.Empresa where nombre=@nombre;

    if @id is null
        set @errores = 'No se encontro la empresa.' + char(10)

    if @nuevo_nombre is not null and @nuevo_nombre <> @nombre and exists ( select 1 from concesiones.Empresa where nombre=@nuevo_nombre)
        set @errores += 'Ya existe una empresa con ese nombre.' + char(10)

    if @cuit is not null and len(@cuit) <> 11
        set @errores += 'El cuit solo puede tener 11 caracteres.' + char(10)

    if @cuit is not null and not (@cuit like '3[034][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' or @cuit like '2[0347][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
        set @errores += 'El cuit no tiene el formato de una empresa.' + char(10)

    if @errores <> ''
        THROW 50000, @errores, 1;

	update concesiones.Empresa set nombre=isnull(@nuevo_nombre, nombre), tipo=isnull(@tipo, tipo), cuit=isnull(@cuit, cuit) where id = @id
end;
go

/*
====================================================
		ABMS DE TABLA CONCESION
====================================================
*/

-----------------------------------------------------------
-- Valida la existencia de una concesion para una empresa 
-- en un parque y en una fecha.
create or alter procedure concesiones.concesion_validacion(
    @empresa varchar(100),
    @parque varchar(100),
    @fecha_inicio date,
    @errores varchar(4000) output,
    @id_concesion int output
) as begin
    declare @id_empresa int = (select top 1 id from concesiones.Empresa where nombre = @empresa);
    declare @id_parque int = (select top 1 id from gestion.Parque where nombre = @parque);

    if @id_empresa is null
        set @errores += 'No se encontro la empresa.' + char(10);

    if @id_parque is null
        set @errores += 'No se encontro el parque.' + char(10);

    set @id_concesion = (
        select top 1 id
        from concesiones.Concesion
        where id_empresa = @id_empresa
          and id_parque = @id_parque
          and fecha_inicio = @fecha_inicio
    );

    if @id_concesion is null
        set @errores += 'No se encontro la concesion.' + char(10);
end;
go

create or alter procedure concesiones.concesion_alta(
    @empresa varchar(25),
    @parque varchar(100),
    @canon_mensual numeric(10, 2),
    @fecha_inicio date = null,
    @actividad int = null
) as begin

    declare @id_empresa int = (select top 1 id from concesiones.Empresa where nombre = @empresa);
    declare @id_parque int = (select top 1 id from gestion.Parque where nombre = @parque);
    declare @errores varchar(4000) = '';

	if @fecha_inicio is null
		set @fecha_inicio = CURRENT_TIMESTAMP;

    if @id_empresa is null
        set @errores = 'No se encontro la empresa.' + CHAR(10)

    if @id_parque is null
        set @errores += 'No se encontro el parque.' + CHAR(10)

	if @canon_mensual < 0
        set @errores += 'El canon mensual no puede ser negativo.' + CHAR(10)

    if @errores <> ''
        THROW 50000, @errores, 1;

	insert into concesiones.Concesion (fecha_inicio, canon_mensual, estado, id_empresa, id_parque, id_actividad) values (@fecha_inicio, @canon_mensual, 'ACTIVO', @id_empresa, @id_parque, @actividad)
end;
go

create or alter procedure concesiones.concesion_baja (
    @empresa varchar(100),
    @parque varchar(100),
    @fecha_inicio datetime
) as begin

    declare @id_concesion int = null;
    declare @errores varchar(4000) = '';

    execute concesiones.concesion_validacion @empresa, @parque, @fecha_inicio, @errores output, @id_concesion output;

    if @errores <> ''
        THROW 50000, @errores, 1;

	update concesiones.Concesion set estado='INACTIVO' where id = @id_concesion
end;
go

-----------------------------------------------------------
-- Modifica una concesion. Se puede especificar que valores editar
-- si se quiere invalidar la fecha de fin se tiene que pasar la fecha '1900-01-01'
create or alter procedure concesiones.concesion_modificacion(
        @empresa varchar(100),
        @parque varchar(100), 
        @fecha_inicio datetime, 
        @fecha_fin date = null,
        @estado char(10) = null, 
        @canon numeric(10, 2) = null,
        @empresa_nueva varchar(100) = null,
        @parque_nuevo varchar(100) = null,
        @actividad_nueva varchar(100) = null
    ) as begin
	
    declare @id_concesion int = null;
    declare @errores varchar(4000) = '';

    execute concesiones.concesion_validacion @empresa, @parque, @fecha_inicio, @errores output, @id_concesion output;

    declare @id_empresa int = null;
    declare @id_parque int = null;
    declare @id_actividad int = null;

    if @empresa_nueva is not null begin
        select @id_empresa = id from concesiones.Empresa where nombre = @empresa_nueva;
   
        if @id_empresa is null
            set @errores += 'No se encontro la empresa nueva.' + char(10)
    end

    if @parque_nuevo is not null begin
        select @id_parque = id from gestion.Parque where nombre = @parque_nuevo;
        if @id_parque is null
            set @errores += 'No se encontro el parque nuevo.' + char(10)
    end
    else
        select @id_parque = id from gestion.Parque where nombre = @parque;


    if @actividad_nueva is not null begin

        select @id_actividad = id from gestion.Actividad where id_parque = @id_parque and nombre=@actividad_nueva;
   
        if @id_actividad is null
            set @errores += 'No se encontro la actividad nueva.' + char(10)
    end

    
    if @errores <> ''
        THROW 50000, @errores, 1;

    update concesiones.Concesion
	set
		canon_mensual=isnull(@canon, canon_mensual),
		estado=isnull(@estado, estado),
        id_empresa=isnull(@id_empresa, id_empresa),
        id_parque=isnull(@id_parque, id_parque),
        id_actividad=isnull(@id_actividad, id_actividad),
		fecha_fin = case
            when @fecha_fin = '1900-01-01' then null
            when @fecha_fin is null then fecha_fin
            else @fecha_fin
        end where id = @id_concesion
end;
go

/*
====================================================
		ABMS DE TABLA CANON_PAGAR
====================================================
*/

create or alter procedure concesiones.canon_pagar_alta (
    @empresa varchar(25),
    @parque varchar(100),
    @fecha_inicio date,
    @fecha_generacion date = null
) as begin
    set @fecha_generacion = isnull(@fecha_generacion, getdate());
    declare @id_concesion int = null;
    declare @errores varchar(4000) = '';
    declare @periodo varchar(50) = concat(year(@fecha_generacion), '-', right('0' + cast(month(@fecha_generacion) as varchar(2)), 2));

    execute concesiones.concesion_validacion
        @empresa,
        @parque,
        @fecha_inicio,
        @errores output,
        @id_concesion output;

    if @errores <> ''
        THROW 50000, @errores, 1;

    declare @monto numeric(10, 2) = (
        select top 1 canon_mensual
        from concesiones.Concesion
        where id = @id_concesion
    );

    insert into concesiones.Canon_pagar (monto, fecha_generacion, estado, periodo, id_concesion) values (@monto, @fecha_generacion, 'PENDIENTE', @periodo, @id_concesion);
end
go

create or alter procedure concesiones.canon_pagar_baja (
    @empresa varchar(100),
    @parque varchar(100),
    @fecha_inicio date,
    @fecha_generacion date = null
) as begin
    set @fecha_generacion = isnull(@fecha_generacion, getdate());
    declare @id int;
    declare @errores varchar(4000) = '';
    declare @id_concesion int = null;

    execute concesiones.concesion_validacion
        @empresa,
        @parque,
        @fecha_inicio,
        @errores output,
        @id_concesion output;

    select top 1 @id = id
    from concesiones.Canon_pagar
    where id_concesion = @id_concesion
      and fecha_generacion = @fecha_generacion;

    if @id is null
        set @errores += 'No en encontro el canon a pagar.' + char(10);

    if @errores <> ''
        THROW 50000, @errores, 1;

    update concesiones.Canon_pagar
    set estado = 'INVALIDO'
    where id = @id;
end
go

create or alter procedure concesiones.canon_pagar_modificacion (
    @periodo varchar(50),
    @monto decimal(10, 2),
    @empresa varchar(25),
    @parque varchar(100),
    @fecha_inicio date,
    @fecha_generacion date = null
) as begin
    set @fecha_generacion = isnull(@fecha_generacion, getdate());
    declare @errores varchar(4000) = '';
    declare @id_concesion int = null;

    execute concesiones.concesion_validacion
        @empresa,
        @parque,
        @fecha_inicio,
        @errores output,
        @id_concesion output;

    if not exists (
        select 1
        from concesiones.Canon_pagar
        where id_concesion = @id_concesion
          and fecha_generacion = @fecha_generacion
    )
        set @errores += 'No en encontro el canon a pagar.' + char(10);

    if @monto < 0
        set @errores += 'El monto no puede ser negativo.' + char(10);

    if @errores <> ''
        THROW 50000, @errores, 1;

    update concesiones.Canon_pagar
    set monto = @monto,
        periodo = @periodo
    where id_concesion = @id_concesion
      and fecha_generacion = @fecha_generacion;
end
go

/*
====================================================
		ABMS DE TABLA TIPO_VISITANTE
====================================================
*/

CREATE OR ALTER PROCEDURE ventas.tipo_visitante_alta (@descripcion VARCHAR(20))
AS
BEGIN
	DECLARE @errores VARCHAR(200)
	SET @errores = ''
	IF EXISTS (SELECT 1 FROM ventas.tipo_visitante WHERE descripcion = @descripcion AND estado = 'Activo')
		SET @errores += 'El tipo de visitante ya está dado de alta. '

	IF LEN(@errores) > 0
		THROW 50000, @errores, 1

    IF EXISTS (SELECT 1 FROM ventas.tipo_visitante WHERE descripcion = @descripcion)
            UPDATE ventas.tipo_visitante
            SET estado = 'Activo'
            WHERE descripcion = @descripcion
	ELSE
        INSERT INTO ventas.tipo_visitante VALUES (@descripcion, 'Activo')
END
GO

CREATE OR ALTER PROCEDURE ventas.tipo_visitante_baja (@descripcion VARCHAR(20))
AS
BEGIN
	DECLARE @errores VARCHAR(200)
	SET @errores = ''
	IF NOT EXISTS (SELECT 1 FROM ventas.tipo_visitante WHERE descripcion = @descripcion)
		SET @errores += 'No existe el tipo de visitante. ' + CHAR(10)
    IF EXISTS (SELECT 1 FROM ventas.tipo_visitante WHERE descripcion = @descripcion AND estado = 'Inactivo')
		SET @errores += 'El tipo de visitante ya está dado de baja. '

	IF LEN(@errores) > 0
		THROW 50000, @errores, 1
	UPDATE ventas.tipo_visitante
    SET estado = 'Inactivo'
    WHERE descripcion = @descripcion
END
GO

CREATE OR ALTER PROCEDURE ventas.tipo_visitante_modificacion (@descripcion VARCHAR(20), @nueva_descripcion VARCHAR(20))
AS
BEGIN
	DECLARE @errores VARCHAR(200)
	SET @errores = ''
    IF NOT EXISTS (SELECT 1 FROM ventas.tipo_visitante WHERE descripcion = @descripcion)
		SET @errores += 'No existe el tipo de visitante.'
	IF EXISTS (SELECT 1 FROM ventas.tipo_visitante WHERE descripcion = @nueva_descripcion)
		SET @errores += 'No se puede actualizar ya que el nuevo tipo de visitante ya existe.'
	IF LEN(@errores) > 0
		THROW 50000, @errores, 1
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

CREATE OR ALTER PROCEDURE ventas.punto_de_venta_alta (@parque VARCHAR(50), @pov VARCHAR(30))
AS
BEGIN
	DECLARE @errores VARCHAR(200)
	SET @errores = ''

	DECLARE @id_parque INT;
	SET @id_parque = (SELECT id FROM gestion.parque WHERE nombre = @parque)
	IF EXISTS (SELECT 1 FROM ventas.punto_de_venta WHERE parque = @id_parque AND descripcion = @pov AND estado = 'Activo')
		SET @errores = @errores + 'El punto de venta para ese parque ya está dado de alta. '
	
	IF @errores <> ''
		THROW 50000, @errores, 1
    IF EXISTS (SELECT 1 FROM ventas.punto_de_venta WHERE parque = @id_parque AND descripcion = @pov)
	    UPDATE ventas.punto_de_venta SET estado = 'Activo' WHERE parque = @id_parque AND descripcion = @pov
    ELSE
        INSERT INTO ventas.punto_de_venta VALUES (@id_parque, @pov, 'Activo')

END
GO

CREATE OR ALTER PROCEDURE ventas.punto_de_venta_baja (@parque VARCHAR(50), @pov VARCHAR(30))
AS
BEGIN
	DECLARE @parque_id VARCHAR(50)
	SET @parque_id = (SELECT id FROM gestion.parque WHERE nombre = @parque)

	DECLARE @errores VARCHAR(200)
	SET @errores = ''

    IF NOT EXISTS (SELECT 1 FROM ventas.punto_de_venta WHERE descripcion = @pov AND parque = @parque_id)
		SET @errores += 'No existe el punto de venta. ' + CHAR(10)
	IF EXISTS (SELECT 1 FROM ventas.punto_de_venta WHERE descripcion = @pov AND parque = @parque_id AND estado = 'Activo')
		SET @errores += 'El puesto ya está dado de baja. '

	IF @errores <> ''
		THROW 50000, @errores, 1
	UPDATE ventas.punto_de_venta SET estado = 'Inactivo'
    WHERE descripcion = @pov
END
GO

CREATE OR ALTER PROCEDURE ventas.punto_de_venta_modificacion (@parque VARCHAR(50), @pov VARCHAR(30), @nueva_descripcion VARCHAR(30))
AS
BEGIN
	DECLARE @parque_id VARCHAR(50)
	SET @parque_id = (SELECT id FROM gestion.parque WHERE nombre = @parque)
	
	DECLARE @errores VARCHAR(200)
	SET @errores = ''
	IF EXISTS (SELECT 1 FROM punto_de_venta WHERE descripcion = @nueva_descripcion AND parque = @parque_id)
		SET @errores = @errores + 'El cambio de nombre no se puede realizar ya que ya existe un punto de venta con ese nombre. '

	IF @errores <> ''
		THROW 50000, @errores, 1
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

CREATE OR ALTER PROCEDURE ventas.metodo_de_pago_alta (@descripcion VARCHAR(25))
AS
BEGIN
	DECLARE @errores VARCHAR(200)
	SET @errores = ''

	IF EXISTS (SELECT 1 FROM metodo_de_pago WHERE descripcion = @descripcion AND estado = 'Activo')
		SET @errores = @errores + 'El metodo de pago ya existe. '

	IF @errores <> ''
		THROW 50000, @errores, 1
    IF EXISTS (SELECT 1 FROM ventas.metodo_de_pago WHERE descripcion = @descripcion)
        UPDATE ventas.metodo_de_pago SET estado = 'Activo' WHERE descripcion = @descripcion
	ELSE
        INSERT INTO ventas.metodo_de_pago VALUES (@descripcion, 'Activo')
END
GO

CREATE OR ALTER PROCEDURE ventas.metodo_de_pago_baja (@descripcion VARCHAR(25))
AS
BEGIN
	DECLARE @errores VARCHAR(200)
	SET @errores = ''

	IF EXISTS (SELECT 1 FROM ventas.metodo_de_pago WHERE descripcion = @descripcion AND estado = 'Inactivo')
		SET @errores += 'El punto de venta ya está dado de baja. '
    IF NOT EXISTS (SELECT 1 FROM ventas.metodo_de_pago WHERE descripcion = @descripcion)
        SET @errores += 'El punto de venta no existe'

	IF @errores <> ''
		THROW 50000, @errores, 1
	UPDATE ventas.metodo_de_pago SET estado = 'Inactivo' WHERE descripcion = @descripcion
END
GO

CREATE OR ALTER PROCEDURE ventas.metodo_de_pago_modificacion (@descripcion VARCHAR(25), @nueva_descripcion VARCHAR(25))
AS
BEGIN
    DECLARE @errores VARCHAR(200);
    SET @errores = '';

	IF NOT EXISTS (SELECT 1 FROM ventas.venta WHERE metodo_de_pago = @descripcion)
        SET @errores += 'No existe el método de pago';
    IF EXISTS (SELECT 1 FROM ventas.venta WHERE metodo_de_pago = @nueva_descripcion)
        SET @errores += 'El nuevo método de pago ya existe';

    IF @errores <> ''
		THROW 50000, @errores, 1;

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

CREATE OR ALTER PROCEDURE ventas.tipo_entrada_alta (@parque varchar(50), @tipo varchar(20), @precio DECIMAL(10,2), @vigencia DATE = NULL)
AS
BEGIN
	DECLARE @parque_id INT, @tipo_id INT
    DECLARE @errores VARCHAR(200)
	SET @errores = ''

	IF @vigencia IS NULL SET @vigencia = GETDATE() --Si no se especifica una fecha de inicio, se asume el día presente
	SET @parque_id = (SELECT id FROM gestion.parque WHERE nombre = @parque);
	SET @tipo_id = (SELECT id FROM ventas.tipo_visitante WHERE descripcion = @tipo);

    IF EXISTS ( SELECT 1 FROM ventas.entrada WHERE parque = @parque_id AND tipo = @tipo_id)
		SET @errores += 'Ya existe la entrada. Utilice modificación. ' + CHAR(10)
	IF @tipo_id IS NULL
		SET @errores += 'No existe el tipo de visitante. Debe darlo de alta para proseguir. ' + CHAR(10)
	IF @parque_id IS NULL
		SET @errores += 'No hay un parque con ese nombre.  ' + CHAR(10)

	IF @errores <> ''
		THROW 50000, @errores, 1

	INSERT INTO ventas.entrada(parque, tipo, precio, fecha_desde)
	VALUES(
		@parque_id,
		@tipo_id,
		@precio,
		@vigencia
		)
END
GO

CREATE OR ALTER PROCEDURE ventas.tipo_entrada_baja (@parque varchar(50), @tipo varchar(20))
AS
BEGIN
    DECLARE @errores VARCHAR(200)
	SET @errores = ''
	DECLARE @parque_id INT, @tipo_id INT
	SET @parque_id = (SELECT id FROM gestion.parque WHERE nombre = @parque);
	SET @tipo_id = (SELECT id FROM ventas.tipo_visitante WHERE descripcion = @tipo)

    IF NOT EXISTS ( SELECT 1 FROM ventas.entrada WHERE parque = @parque_id AND tipo = @tipo_id AND fecha_hasta IS NULL)
		SET @errores += 'No existe la entrada seleccionada. ' + CHAR(10)

    IF @errores <> ''
		THROW 50000, @errores, 1

	UPDATE ventas.entrada SET fecha_hasta = DATEADD(DAY, -1, GETDATE())
    WHERE parque = @parque_id AND tipo = @tipo_id AND fecha_hasta IS NULL
END
GO

-- MODIFICACION --
/* Modifica el precio según el parque y tipo de visitante. Cuando se modifica, el precio actual pasa al histórico.
Ej: (Iguazu, estudiante, 3000) --> (Iguazu, estudiante, 4500)
*/
CREATE OR ALTER PROCEDURE ventas.tipo_entrada_modificacion
(
	@parque varchar(50),
	@tipo varchar(20),
	@nuevo_precio DECIMAL(10,2)
)
AS
BEGIN
	DECLARE @parque_id INT, @tipo_id INT, @errores VARCHAR(200);
	SET @parque_id = (SELECT id FROM gestion.parque WHERE nombre = @parque);
	SET @tipo_id = (SELECT id FROM ventas.tipo_visitante WHERE descripcion = @tipo);

	IF NOT EXISTS ( SELECT 1 FROM ventas.entrada WHERE parque = @parque_id AND tipo = @tipo_id AND fecha_hasta IS NULL)
		SET @errores += 'No existe una entrada vigente. Debe darla de alta antes de modificarla. '

    IF @errores <> ''
        THROW 50000, @errores, 1

	BEGIN TRY
        BEGIN TRANSACTION
			EXEC ventas.tipo_entrada_baja @parque = @parque, @tipo = @tipo;
			EXEC ventas.tipo_entrada_alta @parque = @parque, @tipo = @tipo, @precio = @nuevo_precio;
		COMMIT;
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0 --IF @@TRANCOUNT > 0?
			ROLLBACK
	END CATCH
END
GO

/*
====================================================
		ABMS DE TABLA VENTAS
====================================================
*/

CREATE OR ALTER PROCEDURE ventas.venta_alta (@parque VARCHAR(50), @fecha DATE = NULL, @pov VARCHAR(25), @metodo VARCHAR(30), @id_creado INT OUTPUT)
AS
BEGIN
	IF @fecha IS NULL SET @fecha = GETDATE() --Si no se especifica fecha, asumimos que es del día
    
	DECLARE @id_parque INT, @id_pov VARCHAR(25), @id_metodo VARCHAR(25), @errores VARCHAR(200);
    SET @errores = '';
	SET @id_parque = (SELECT id FROM gestion.parque WHERE nombre = @parque)
    IF @id_parque IS NULL
        SET @errores += 'No existe el parque indicado.' + CHAR(10)
    ELSE
        SET @id_pov = (SELECT id FROM ventas.punto_de_venta WHERE descripcion = @pov AND parque = @id_parque)

    IF @id_pov IS NULL
        SET @errores = @errores + 'No existe el punto de venta indicado.' + CHAR(10)
    ELSE
       IF (SELECT estado FROM ventas.punto_de_venta WHERE id = @id_pov) = 'Inactivo'
            SET @errores = @errores + 'El punto de venta no está habilitado. ' + CHAR(10)
	SET @id_metodo = (SELECT id FROM ventas.metodo_de_pago WHERE descripcion = @metodo)
    IF (SELECT 1 FROM ventas.metodo_de_pago WHERE id = @id_metodo) IS NULL
        SET @errores = @errores + 'No existe el método de pago especificado.' + CHAR(10)
    ELSE
       IF (SELECT estado FROM ventas.metodo_de_pago WHERE id = @id_metodo) = 'Inactivo'
            SET @errores = @errores + 'El método de pago no está permitido. ' + CHAR(10);

    IF @errores <> ''
        THROW 50000, @errores, 1
    ELSE
	    INSERT INTO ventas.venta
	    VALUES(@id_parque, @fecha, @id_pov, @id_metodo, 0)
	
	SET @id_creado = (SELECT SCOPE_IDENTITY())

END
GO

CREATE OR ALTER PROCEDURE ventas.venta_baja (@venta INT)
AS
BEGIN
	--Primero tengo que eliminar los items asociados a esa venta
    DECLARE @errores VARCHAR(200)
    SET @errores = ''
    IF (SELECT 1 FROM ventas.venta WHERE id = @venta) IS NULL
       SET @errores += 'La venta indicada no existe.'

    IF @errores <> ''
        THROW 50000, @errores, 1

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

CREATE OR ALTER PROCEDURE ventas.venta_modificacion (@id_venta INT, @metodo VARCHAR(30))
AS
BEGIN
    DECLARE @errores VARCHAR(200)
    declare @id_metodo int = (SELECT top 1 id FROM ventas.metodo_de_pago WHERE descripcion = @metodo)
    SET @errores = ''
    IF (SELECT 1 FROM ventas.venta WHERE id = @id_venta) IS NULL
       SET @errores += 'La venta indicada no existe.' + char(10)

    IF @id_metodo IS NULL
       SET @errores += 'El metodo indicado no existe.' + char(10)

    IF @errores <> ''
        THROW 50000, @errores, 1

	UPDATE ventas.venta
	SET metodo_de_pago = @id_metodo
	WHERE id = @id_venta
END
GO

/*
====================================================
		ABMS DE TABLA ITEMS DE VENTA
====================================================
*/

CREATE OR ALTER PROCEDURE ventas.item_venta_alta (@venta INT, @concepto VARCHAR(50), @cantidad INT, @fecha_acceso DATE)
AS
BEGIN
	DECLARE @id_concepto INT, @precio DECIMAL(10, 2), @errores VARCHAR(200), @parque VARCHAR(50), @id_parque INT
	SET @errores = ''
    SET @id_parque = (SELECT parque FROM ventas.venta WHERE id = @venta)
    SET @parque = (SELECT nombre FROM gestion.parque WHERE id = @id_parque)
	IF @concepto IN (SELECT visitante FROM reportes.entradas_vigentes WHERE parque = @parque) 
        BEGIN
        SET @id_concepto = (SELECT id_visitante FROM reportes.entradas_vigentes WHERE parque = @parque AND visitante = @concepto)
        SET @precio = (SELECT precio FROM reportes.entradas_vigentes WHERE parque = @parque AND visitante = @concepto)
        END
    ELSE
        BEGIN
        SET @id_concepto = (SELECT id FROM gestion.Actividad WHERE nombre = @concepto)
        SET @precio = (SELECT costo FROM gestion.Actividad WHERE id = @id_concepto)
        END

    IF (SELECT 1 FROM ventas.venta WHERE id = @venta) IS NULL
       SET @errores += 'La venta indicada no existe.' + CHAR(10)
    IF (@id_concepto IS NULL)
        SET @errores += 'El concepto ingresado no existe.' + CHAR(10)
    IF @errores <> ''
        THROW 50000, @errores, 1

	BEGIN TRANSACTION
		BEGIN TRY
			INSERT INTO ventas.item_venta
			VALUES (@venta, @id_concepto, @concepto, @cantidad, @precio, @cantidad * @precio, @fecha_acceso)
			UPDATE ventas.venta
			SET total = total + (@cantidad * @precio)
			WHERE id = @venta

			COMMIT
		END TRY
		BEGIN CATCH
			IF XACT_STATE() <>0
                ROLLBACK
		END CATCH
END
GO

CREATE OR ALTER PROCEDURE ventas.item_venta_baja (@venta INT, @item INT)
AS
BEGIN
    DECLARE @errores VARCHAR(200);
    SET @errores = '';

    IF (SELECT 1 FROM ventas.item_venta WHERE id = @item) IS NULL
        SET @errores += 'No existe el item indicado'

    BEGIN TRANSACTION
	BEGIN TRY

        DECLARE @sub_total DECIMAL(10,2);
        DECLARE @precio DECIMAL(10,2);
        DECLARE @cantidad INT;

        SELECT @cantidad = cantidad, @precio = precio FROM ventas.item_venta WHERE venta = @venta AND id = @item
        
        SET @sub_total = @cantidad * @precio;

		UPDATE ventas.venta
		SET total = total - @sub_total
		WHERE id = @venta

        DELETE FROM ventas.item_venta
	    WHERE venta = @venta
	    AND
	    id = @item

		COMMIT
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <>0
            ROLLBACK
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE ventas.item_venta_modificacion (@venta INT, @item INT, @concepto INT, @nueva_cantidad INT)
AS
BEGIN
	DECLARE @subtotal_actualizado DECIMAL(10,2), @subtotal DECIMAL (10,2), @errores VARCHAR(200);;
	SET @subtotal = (SELECT subtotal FROM ventas.item_venta WHERE id = @item)
	SET @subtotal_actualizado = (SELECT precio FROM ventas.item_venta WHERE id = @item) * @nueva_cantidad

    IF (SELECT 1 FROM ventas.item_venta WHERE id = @item) IS NULL
        SET @errores += 'No existe el item indicado'

    IF @errores <> ''
        THROW 50000, @errores, 1

	BEGIN TRANSACTION
		BEGIN TRY
			UPDATE ventas.item_venta
			SET cantidad = @nueva_cantidad,
			subtotal = @nueva_cantidad * precio
			WHERE id = @item

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
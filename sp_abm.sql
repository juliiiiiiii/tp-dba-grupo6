
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

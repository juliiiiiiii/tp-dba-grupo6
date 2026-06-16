
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
	BEGIN
		SET @errores += 'El nombre del parque ya se encuentra registrado.' + CHAR(10);
	END

    IF @ubicacion IS NOT NULL AND LTRIM(RTRIM(@ubicacion)) != ''
    BEGIN
        SELECT @id_ubicacion = id FROM gestion.Ubicacion 
        WHERE UPPER(provincia) COLLATE Latin1_General_CI_AI = UPPER(@ubicacion) COLLATE Latin1_General_CI_AI;

        IF @id_ubicacion = 0
            SET @errores += 'La ubicacion del parque no es valida.' + CHAR(10);
	END

	IF @superficie <= 0
        SET @errores += 'La superficie debe ser un valor positivo.' + CHAR(10);

	IF @errores != ''
	BEGIN
		RAISERROR(@errores, 16, 1);
		RETURN;
	END

	INSERT INTO gestion.Parque (nombre, tipo, superficie, estado, id_ubicacion)
	VALUES (@nombre, @tipo, @superficie, 'Activo', @id_ubicacion);
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

    DECLARE @errores VARCHAR(50);
    SET @errores = '';

    IF EXISTS (SELECT descripcion FROM gestion.Tipo_actividad WHERE descripcion = @descripcion)
        SET @errores += 'El tipo de actividad ya existe.' + CHAR(10);

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END


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

	IF NOT EXISTS (SELECT id FROM gestion.Parque WHERE id = @id)
        SET @errores += 'El parque que se desea modificar no existe.' + CHAR(10);

    IF EXISTS (SELECT id FROM gestion.Parque WHERE nombre = @nombre AND id != @id)
        SET @errores += 'El nombre ingresado ya esta en uso por otro parque.' + CHAR(10);

    IF @ubicacion IS NOT NULL AND LTRIM(RTRIM(@ubicacion)) != ''
    BEGIN
        SELECT @id_ubicacion = id FROM gestion.Ubicacion 
        WHERE UPPER(provincia) COLLATE Latin1_General_CI_AI = UPPER(@ubicacion) COLLATE Latin1_General_CI_AI;

        IF @id_ubicacion = 0
            SET @errores += 'La ubicacion del parque no es valida.' + CHAR(10);
	END

    IF @superficie <= 0
        SET @errores += 'La superficie debe ser un valor positivo.' + CHAR(10);
 
    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END
 
    UPDATE gestion.Parque SET nombre = @nombre, tipo = @tipo, superficie = @superficie, id_ubicacion = @id_ubicacion WHERE id = @id;
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
            INNER JOIN guia.Acreditacion a ON g.id_acreditacion = a.id
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
-- Actualizar guia

CREATE OR ALTER PROCEDURE gestion.sp_actualizar_guia
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
        IF @dni NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
            SET @error += 'Ingresar dni valido.' + CHAR(10);
        ELSE
        BEGIN
            IF NOT EXISTS (SELECT id FROM gestion.Guia WHERE dni = @dni)
                SET @error += 'El dni no pertenece a un guia.' + CHAR(10);
        END    
    END

    IF @nombre IS NULL OR @apellido IS NULL OR @nombre = '' or @apellido = ''
        SET @error += 'Se debe especificar nombre y apellido del guia.' + CHAR(10);
    
    IF @error != ''
        RAISERROR(@error, 16, 1);
    ELSE
    BEGIN
        UPDATE gestion.Guia SET nombre = @nombre, apellido = @apellido WHERE dni = @dni
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


-----------------------------------------------------------
-- Crea una empresa
create or alter procedure concesiones.sp_alta_empresa (@nombre varchar(25), @tipo varchar(100), @cuit varchar(15)) as begin
	-- vale la pena una funcion para ver si el cuit es valido? -> si + raiserror con un solo mensaje
    declare @errores varchar(4000) = '';

    if @cuit is not null and len(@cuit) <> 11 begin
        set @errores = 'El cuit solo puede tener 11 caracteres.' + char(10)
    end

    if @cuit is not null and not (@cuit like '3[034][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' or @cuit like '2[0347][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') begin
        set @errores += 'El cuit no tiene el formato de una empresa.' + char(10)
    end

    if @errores <> '' begin
        raiserror(@errores, 16, 1)
        return
    end

	insert into concesiones.Empresa (nombre, tipo, cuit) values (@nombre, @tipo, @cuit);
end;
go

-----------------------------------------------------------
-- Baja de una empresa
create or alter procedure concesiones.sp_baja_empresa (@nombre varchar(25)) as begin
    declare @id int;
    declare @errores varchar(4000) = '';

    select @id = id from concesiones.Empresa where nombre=@nombre;

    if @id is null begin
        set @errores = 'No se encontro la empresa.' + char(10)
    end

    if @errores <> '' begin
        raiserror(@errores, 16, 1)
        return
    end;

	delete from concesiones.Empresa where id=@id
end;
go

-----------------------------------------------------------
-- Modifica una empresa
create or alter procedure concesiones.sp_modificacion_empresa (
    @nombre varchar(25),
    @nuevo_nombre varchar(25) = null,
    @tipo varchar(100) = null,
    @cuit varchar(15) = null
) as begin
    declare @id int;
    declare @errores varchar(4000) = '';

    select @id = id from concesiones.Empresa where nombre=@nombre;

    if @id is null begin
        set @errores = 'No se encontro la empresa.' + char(10)
    end

    if @nuevo_nombre is not null and @nuevo_nombre <> @nombre and exists ( select 1 from concesiones.Empresa where nombre=@nuevo_nombre) begin
        set @errores += 'Ya existe una empresa con ese nombre.' + char(10)
    end

    if @cuit is not null and len(@cuit) <> 11 begin
        set @errores += 'El cuit solo puede tener 11 caracteres.' + char(10)
    end

    if @cuit is not null and not (@cuit like '3[034][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' or @cuit like '2[0347][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') begin
        set @errores += 'El cuit no tiene el formato de una empresa.' + char(10)
    end

    if @errores <> '' begin
        raiserror(@errores, 16, 1)
        return
    end;

	update concesiones.Empresa set nombre=isnull(@nuevo_nombre, nombre), tipo=isnull(@tipo, tipo), cuit=isnull(@cuit, cuit) where id = @id
end;
go

-----------------------------------------------------------
-- Valida la existencia de una concesion para una empresa 
-- en un parque y en una fecha.
create or alter procedure concesiones.sp_validacion_concesion(
    @empresa varchar(100),
    @parque varchar(100),
    @fecha_inicio date,
    @errores varchar(4000) output,
    @id_concesion int output
) as begin
    declare @id_empresa int = (select top 1 id from concesiones.Empresa where nombre = @empresa);
    declare @id_parque int = (select top 1 id from gestion.Parque where nombre = @parque);

    if @id_empresa is null begin
        set @errores += 'No se encontro la empresa.' + char(10);
    end

    if @id_parque is null begin
        set @errores += 'No se encontro el parque.' + char(10);
    end

    set @id_concesion = (
        select top 1 id
        from concesiones.Concesion
        where id_empresa = @id_empresa
          and id_parque = @id_parque
          and fecha_inicio = @fecha_inicio
    );

    if @id_concesion is null begin
        set @errores += 'No se encontro la concesion.' + char(10);
    end
end;
go

-----------------------------------------------------------
-- Crea una concesion
create or alter procedure concesiones.sp_alta_concesion(
    @empresa varchar(25),
    @parque varchar(100),
    @canon_mensual numeric(10, 2),
    @fecha_inicio date = null,
    @actividad int = null
) as begin

    declare @id_empresa int = (select top 1 id from concesiones.Empresa where nombre = @empresa);
    declare @id_parque int = (select top 1 id from gestion.Parque where nombre = @parque);
    declare @errores varchar(4000) = '';

	if @fecha_inicio is null begin
		set @fecha_inicio = CURRENT_TIMESTAMP;
	end;

    if @id_empresa is null begin
        set @errores = 'No se encontro la empresa.' + CHAR(10)
    end

    if @id_parque is null begin
        set @errores += 'No se encontro el parque.' + CHAR(10)
    end

	if @canon_mensual < 0 begin
        set @errores += 'El canon mensual no puede ser negativo.' + CHAR(10)
	end

    if @errores <> '' begin
        raiserror(@errores, 16, 1)
        return
    end

	insert into concesiones.Concesion (fecha_inicio, canon_mensual, estado, id_empresa, id_parque, id_actividad) values (@fecha_inicio, @canon_mensual, 'ACTIVO', @id_empresa, @id_parque, @actividad)
end;
go

-----------------------------------------------------------
-- Invalida una concesion
create or alter procedure concesiones.sp_baja_concesion (
    @empresa varchar(100),
    @parque varchar(100),
    @fecha_inicio datetime
) as begin

    declare @id_concesion int = null;
    declare @errores varchar(4000) = '';

    execute concesiones.sp_validacion_concesion @empresa, @parque, @fecha_inicio, @errores output, @id_concesion output;

    if @errores <> '' begin
        raiserror(@errores, 16, 1)
        return
    end

	update concesiones.Concesion set estado='INACTIVO' where id = @id_concesion
end;
go

-----------------------------------------------------------
-- Modifica una concesion. Se puede especificar que valores editar
-- si se quiere invalidar la fecha de fin se tiene que pasar la fecha '1900-01-01'
create or alter procedure concesiones.sp_modificacion_concesion(
        @empresa varchar(100),
        @parque varchar(100), 
        @fecha_inicio datetime, 
        @fecha_fin date = null,
        @estado char(10) = null, 
        @canon numeric(10, 2) = null,
        @empresa_nueva varchar(100) = null,
        @parque_nuevo varchar(100) = null
    ) as begin
	
    declare @id_concesion int = null;
    declare @errores varchar(4000) = '';

    execute concesiones.sp_validacion_concesion @empresa, @parque, @fecha_inicio, @errores output, @id_concesion output;

    declare @id_empresa int = null;
    declare @id_parque int = null;

    if @empresa_nueva is not null begin
        select @id_empresa = id from concesiones.Empresa where nombre = @empresa_nueva;
   
        if @id_empresa is null begin
            set @errores += 'No se encontro la empresa nueva.' + char(10)
        end
    end

    if @parque_nuevo is not null begin
        select @id_parque = id from gestion.Parque where nombre = @parque_nuevo;
        if @id_parque is null begin
            set @errores += 'No se encontro el parque nuevo.' + char(10)
        end
    end
    
    if @errores <> '' begin
        raiserror(@errores, 16, 1)
        return
    end

    update concesiones.Concesion
	set
		canon_mensual=isnull(@canon, canon_mensual),
		estado=isnull(@estado, estado),
        id_empresa=isnull(@id_empresa, id_empresa),
        id_parque=isnull(@id_parque, id_parque),
		fecha_fin = case
            when @fecha_fin = '1900-01-01' then null
            when @fecha_fin is null then fecha_fin
            else @fecha_fin
        end where id = @id_concesion
end;
go

-----------------------------------------------------------
-- Crea un canon a pagar
create or alter procedure concesiones.sp_alta_canon_pagar (
    @fecha_generacion date,
    @periodo varchar(50),
    @empresa varchar(25),
    @parque varchar(100),
    @fecha_inicio date
) as begin
    declare @id_concesion int = null;
    declare @errores varchar(4000) = '';

    execute concesiones.sp_validacion_concesion
        @empresa,
        @parque,
        @fecha_inicio,
        @errores output,
        @id_concesion output;

    if @errores <> '' begin
        raiserror(@errores, 16, 1);
        return;
    end

    declare @monto numeric(10, 2) = (
        select top 1 canon_mensual
        from concesiones.Concesion
        where id = @id_concesion
    );

    insert into concesiones.Canon_pagar (monto, fecha_generacion, estado, periodo, id_concesion) values (@monto, @fecha_generacion, 'PENDIENTE', @periodo, @id_concesion);
end
go

-----------------------------------------------------------
-- Modifica un canon a pagar
create or alter procedure concesiones.sp_modificacion_canon_pagar (
    @fecha_generacion date,
    @periodo varchar(50),
    @monto decimal(10, 2),
    @empresa varchar(25),
    @parque varchar(100),
    @fecha_inicio date
) as begin
    declare @errores varchar(4000) = '';
    declare @id_concesion int = null;

    execute concesiones.sp_validacion_concesion
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
    ) begin
        set @errores += 'No en encontro el canon a pagar.' + char(10);
    end

    if @monto < 0 begin
        set @errores += 'El monto no puede ser negativo.' + char(10);
    end

    if @errores <> '' begin
        raiserror(@errores, 16, 1);
        return;
    end

    update concesiones.Canon_pagar
    set monto = @monto,
        periodo = @periodo
    where id_concesion = @id_concesion
      and fecha_generacion = @fecha_generacion;
end
go

-----------------------------------------------------------
-- Paga un canon de una concesion en una fecha en especifico
create or alter procedure concesiones.sp_pagar_canon (
    @fecha_pago date,
    @fecha_generacion date,
    @empresa varchar(100),
    @parque varchar(100),
    @fecha_inicio date
) as begin
    declare @id int;
    declare @errores varchar(4000) = '';
    declare @id_concesion int = null;

    execute concesiones.sp_validacion_concesion
        @empresa,
        @parque,
        @fecha_inicio,
        @errores output,
        @id_concesion output;

    select top 1 @id = id
    from concesiones.Canon_pagar
    where id_concesion = @id_concesion
      and fecha_generacion = @fecha_generacion;

    if @id is null begin
        set @errores += 'No en encontro el canon a pagar.' + char(10);
    end

    if @errores <> '' begin
        raiserror(@errores, 16, 1);
        return;
    end

    update concesiones.Canon_pagar
    set fecha_pagado = @fecha_pago,
        estado = 'PAGADO'
    where id = @id;
end
go

-----------------------------------------------------------
-- Baja de un canon a pagar
create or alter procedure concesiones.sp_baja_canon (
    @fecha_generacion date,
    @empresa varchar(100),
    @parque varchar(100),
    @fecha_inicio date
) as begin
    declare @id int;
    declare @errores varchar(4000) = '';
    declare @id_concesion int = null;

    execute concesiones.sp_validacion_concesion
        @empresa,
        @parque,
        @fecha_inicio,
        @errores output,
        @id_concesion output;

    select top 1 @id = id
    from concesiones.Canon_pagar
    where id_concesion = @id_concesion
      and fecha_generacion = @fecha_generacion;

    if @id is null begin
        set @errores += 'No en encontro el canon a pagar.' + char(10);
    end

    if @errores <> '' begin
        raiserror(@errores, 16, 1);
        return;
    end

    update concesiones.Canon_pagar
    set estado = 'INVALIDO'
    where id = @id;
end
go


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
-- Registrar ubicacion

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
        RAISERROR(@error, 16, 1);
    ELSE
    BEGIN
        INSERT INTO gestion.Ubicacion VALUES(@provincia); 
    END 
END
GO



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

CREATE OR ALTER PROCEDURE gestion.guia_alta
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

CREATE OR ALTER PROCEDURE gestion.guia_actualizar
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

CREATE OR ALTER PROCEDURE gestion.guia_asignar
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
create or alter procedure concesiones.empresa_alta (@nombre varchar(25), @tipo varchar(100), @cuit varchar(15)) as begin
	-- vale la pena una funcion para ver si el cuit es valido? -> si + raiserror con un solo mensaje
    declare @errores varchar(4000) = '';

    if @cuit is not null and len(@cuit) <> 11 begin
        set @errores = 'El cuit solo puede tener 11 caracteres.' + char(10)
    end

    if @cuit is not null and not (@cuit like '3[034][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' or @cuit like '2[0347][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') begin
        set @errores += 'El cuit no tiene el formato de una empresa.' + char(10)
    end

    if @errores <> ''
        throw 16, @errores, 1;

	insert into concesiones.Empresa (nombre, tipo, cuit) values (@nombre, @tipo, @cuit);
end;
go

-----------------------------------------------------------
-- Baja de una empresa
create or alter procedure concesiones.empresa_baja (@nombre varchar(25)) as begin
    declare @id int;
    declare @errores varchar(4000) = '';

    select @id = id from concesiones.Empresa where nombre=@nombre;

    if @id is null begin
        set @errores = 'No se encontro la empresa.' + char(10)
    end

    if @errores <> ''
        throw 16, @errores, 1;

	delete from concesiones.Empresa where id=@id
end;
go

-----------------------------------------------------------
-- Modifica una empresa
create or alter procedure concesiones.empresa_modificacion (
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

    if @errores <> ''
        throw 16, @errores, 1;

	update concesiones.Empresa set nombre=isnull(@nuevo_nombre, nombre), tipo=isnull(@tipo, tipo), cuit=isnull(@cuit, cuit) where id = @id
end;
go

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

    if @errores <> ''
        throw 16, @errores, 1;

	insert into concesiones.Concesion (fecha_inicio, canon_mensual, estado, id_empresa, id_parque, id_actividad) values (@fecha_inicio, @canon_mensual, 'ACTIVO', @id_empresa, @id_parque, @actividad)
end;
go

-----------------------------------------------------------
-- Invalida una concesion
create or alter procedure concesiones.concesion_baja (
    @empresa varchar(100),
    @parque varchar(100),
    @fecha_inicio datetime
) as begin

    declare @id_concesion int = null;
    declare @errores varchar(4000) = '';

    execute concesiones.concesion_validacion @empresa, @parque, @fecha_inicio, @errores output, @id_concesion output;

    if @errores <> ''
        throw 16, @errores, 1;

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
    else begin
        select @id_parque = id from gestion.Parque where nombre = @parque;
    end


    if @actividad_nueva is not null begin

        select @id_actividad = id from gestion.Actividad where id_parque = @id_parque and nombre=@actividad_nueva;
   
        if @id_actividad is null begin
            set @errores += 'No se encontro la actividad nueva.' + char(10)
        end
    end

    
    if @errores <> ''
        throw 16, @errores, 1;

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

-----------------------------------------------------------
-- Crea un canon a pagar
create or alter procedure concesiones.canon_pagar_alta (
    @fecha_generacion date,
    @empresa varchar(25),
    @parque varchar(100),
    @fecha_inicio date
) as begin
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
        throw 16, @errores, 1;

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
create or alter procedure concesiones.canon_pagar_modificacion (
    @fecha_generacion date,
    @periodo varchar(50),
    @monto decimal(10, 2),
    @empresa varchar(25),
    @parque varchar(100),
    @fecha_inicio date
) as begin
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
    ) begin
        set @errores += 'No en encontro el canon a pagar.' + char(10);
    end

    if @monto < 0 begin
        set @errores += 'El monto no puede ser negativo.' + char(10);
    end

    if @errores <> ''
        throw 16, @errores, 1;

    update concesiones.Canon_pagar
    set monto = @monto,
        periodo = @periodo
    where id_concesion = @id_concesion
      and fecha_generacion = @fecha_generacion;
end
go

-----------------------------------------------------------
-- Baja de un canon a pagar
create or alter procedure concesiones.canon_pagar_baja (
    @fecha_generacion date,
    @empresa varchar(100),
    @parque varchar(100),
    @fecha_inicio date
) as begin
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

    if @id is null begin
        set @errores += 'No en encontro el canon a pagar.' + char(10);
    end

    if @errores <> ''
        throw 16, @errores, 1;

    update concesiones.Canon_pagar
    set estado = 'INVALIDO'
    where id = @id;
end
go

/*
====================================================
		ABMS DE TABLA TIPO_VISITANTE
====================================================
*/
--ALTA VISITANTE--
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

--BAJA VISITANTE--


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

--MODIFICACIÓN VISITANTE--


CREATE OR ALTER PROCEDURE
ventas.tipo_visitante_modificacion (@descripcion VARCHAR(20), @nueva_descripcion VARCHAR(20))
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
--ALTA--
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
--BAJA--

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

--MODIFICACION--

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
--ALTA--
CREATE OR ALTER PROCEDURE ventas.metodo_de_pago_alta(@descripcion VARCHAR(25))
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

--BAJA--
CREATE OR ALTER PROCEDURE ventas.metodo_de_pago_baja(@descripcion VARCHAR(25))
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

--MODIFICACION--
CREATE OR ALTER PROCEDURE ventas.metodo_de_pago_modificacion(@descripcion VARCHAR(25), @nueva_descripcion VARCHAR(25))
AS
BEGIN
    DECLARE @errores VARCHAR(200);
    SET @errores = ''
	

	IF NOT EXISTS (SELECT 1 FROM ventas.venta WHERE metodo_de_pago = @descripcion)
        SET @errores += 'No existe el método de pago'
    IF EXISTS (SELECT 1 FROM ventas.venta WHERE metodo_de_pago = @nueva_descripcion)
        SET @errores += 'El nuevo método de pago ya existe'

    IF @errores <> ''
		THROW 50000, @errores, 1

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

    IF EXISTS ( SELECT 1 FROM ventas.entradas_vigentes WHERE parque = @parque AND visitante = @tipo)
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

--BAJA--
CREATE OR ALTER PROCEDURE ventas.tipo_entrada_baja (@parque varchar(50), @tipo varchar(20))
AS
BEGIN
    DECLARE @errores VARCHAR(200)
	SET @errores = ''
	DECLARE @parque_id INT, @tipo_id INT
	SET @parque_id = (SELECT id FROM gestion.parque WHERE nombre = @parque);
	SET @tipo_id = (SELECT id FROM ventas.tipo_visitante WHERE descripcion = @tipo)

    IF NOT EXISTS ( SELECT 1 FROM ventas.entradas_vigentes WHERE parque = @parque AND visitante = @tipo)
		SET @errores += 'No existe la entrada seleccionada. ' + CHAR(10)

    IF @errores <> ''
		THROW 50000, @errores, 1

	UPDATE ventas.entrada SET fecha_hasta = DATEADD(DAY, -1, GETDATE()) WHERE parque = @parque_id AND tipo = @tipo_id AND fecha_hasta IS NULL
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

	IF NOT EXISTS (SELECT 1 FROM ventas.entradas_vigentes WHERE parque = @parque AND visitante = @tipo)
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
-- Alta de ventas --

CREATE OR ALTER PROCEDURE ventas.venta_alta(@parque VARCHAR(50), @fecha DATE = NULL, @pov VARCHAR(25), @metodo VARCHAR(30), @id_creado INT OUTPUT)
AS
BEGIN
	IF @fecha IS NULL SET @fecha = GETDATE() --Si no se especifica fecha, asumimos que es del día

	DECLARE @id_parque VARCHAR(50), @id_pov VARCHAR(25), @id_metodo VARCHAR(25), @errores VARCHAR(200);

	SET @id_parque = (SELECT id FROM gestion.parque WHERE nombre = @parque)
    IF @id_parque IS NULL
        SET @errores += 'No existe el parque indicado.' + CHAR(10)
    ELSE
        SET @id_pov = (SELECT id FROM ventas.punto_de_venta WHERE descripcion = @pov AND parque = @id_parque)

    IF @id_pov IS NULL
        SET @errores += 'No existe el punto de venta indicado.' + CHAR(10)
    ELSE
       IF (SELECT estado FROM ventas.punto_de_venta) = 'Inactivo'
            SET @errores += 'El punto de venta no está habilitado. ' + CHAR(10)
	SET @id_metodo = (SELECT id FROM ventas.metodo_de_pago WHERE descripcion = @metodo)
    IF (SELECT 1 FROM ventas.metodo_de_pago WHERE id = @metodo) IS NULL
        SET @errores += 'No existe el método de pago especificado.' + CHAR(10)
    ELSE
       IF (SELECT estado FROM ventas.metodo_de_pago) = 'Inactivo'
            SET @errores += 'El método de pago no está permitido. ' + CHAR(10)
    IF @errores <> ''
        THROW 50000, @errores, 1

	INSERT INTO ventas.venta
	VALUES(@id_parque, @fecha, @id_pov, @id_metodo, 0)
	
	SET @id_creado = (SELECT SCOPE_IDENTITY())

END
GO

--BAJA--

CREATE OR ALTER PROCEDURE ventas.venta_baja(@venta INT)
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


--MODIFICACION--
CREATE OR ALTER PROCEDURE ventas.venta_modificacion(@id_venta INT, @metodo VARCHAR(30))
AS
BEGIN
    DECLARE @errores VARCHAR(200)
    SET @errores = ''
    IF (SELECT 1 FROM ventas.venta WHERE id = @id_venta) IS NULL
       SET @errores += 'La venta indicada no existe.'

    IF @errores <> ''
        THROW 50000, @errores, 1

	UPDATE ventas.venta
	SET metodo_de_pago = @metodo
	WHERE id = @id_venta
END
GO
/*
====================================================
		ABMS DE TABLA ITEMS DE VENTA
====================================================
*/

--ALTA--
CREATE OR ALTER PROCEDURE ventas.item_venta_alta(@venta INT, @concepto VARCHAR(20), @cantidad INT, @fecha_acceso DATE)
AS
BEGIN
	DECLARE @id_concepto INT, @precio DECIMAL(10, 2), @errores VARCHAR(200), @parque INT
	SET @errores = ''
    SET @parque = (SELECT parque FROM ventas.venta WHERE id = @venta)
	IF @concepto IN (SELECT visitante FROM ventas.entradas_vigentes WHERE parque = @parque)
        BEGIN
        SET @id_concepto = (SELECT id_visitante FROM ventas.entradas_vigentes WHERE parque = @parque AND visitante = @concepto)
        SET @precio = (SELECT precio FROM ventas.entradas_vigentes WHERE parque = @parque AND visitante = @concepto)
        END
    ELSE
        BEGIN
        SET @id_concepto = (SELECT id FROM gestion.Actividad WHERE nombre = @concepto)
        SET @precio = (SELECT costo FROM gestion.Actividad WHERE descripcion = @concepto)
        END
	
    IF (SELECT 1 FROM ventas.venta WHERE id = @venta) IS NULL
       SET @errores += 'La venta indicada no existe.' + CHAR(10)
    IF (@id_concepto = NULL)
        SET @errores += 'El concepto ingresado no existe.' + CHAR(10)
    
    IF @errores <> ''
        THROW 50000, @errores, 1


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
CREATE OR ALTER PROCEDURE ventas.item_venta_baja(@venta INT, @item INT)
AS
BEGIN
    DECLARE @errores VARCHAR(200);
    SET @errores = '';

    IF (SELECT 1 FROM ventas.item_venta WHERE id = @item) IS NULL
        SET @errores += 'No existe el item indicado'
    
	DELETE FROM ventas.item_venta
	WHERE venta = @venta
	AND
	id = @item
END
GO

--Modificacion--

CREATE OR ALTER PROCEDURE ventas.item_venta_modificacion(@venta INT, @item INT, @concepto INT, @nueva_cantidad INT)
AS
BEGIN
	DECLARE @subtotal_actualizado DECIMAL(10,2), @subtotal DECIMAL (10,2), @errores VARCHAR(200);;
	SET @subtotal = (SELECT subotal FROM ventas.item_id WHERE id = @item)
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

-- Universidad: Universidad de la Matanza
-- Materia: 3641 - Bases de Datos Aplicadas

-- Grupo 04
-- Integrantes:
--  De Bellis, Nahuel
--  Ocampo, Julian Rafael
--  Rodriguez, Gonzalo Ezequiel
--  Vargas, Tomas

-- Objetivo del script: Creacion de store procedure

-- Fecha: 12/06/2026

USE parques_nacionales
GO

-----------------------------------------------------------
-- Registrar especialidad

CREATE OR ALTER PROCEDURE guia.sp_registrar_especialidad
@descripcion VARCHAR(50)
AS
BEGIN
    DECLARE @error VARCHAR(70);
    SET @error = '';

    IF @descripcion IS NULL OR @descripcion = ''
        SET @error += 'Se debe especificar la descripcion de la especialidad.' + CHAR(10);
    ELSE
    BEGIN
        IF EXISTS (SELECT descripcion from guia.Especialidad WHERE descripcion = @descripcion)
        SET @error += 'La especialidad ya se encuentra registrada.' + CHAR(10);
    END

    IF @error != ''
        RAISERROR(@error, 16, 1);
    ELSE
    BEGIN
        INSERT INTO guia.Especialidad VALUES(@descripcion); 
    END 
END
GO

-----------------------------------------------------------
-- Asignarle especializacion a un guia

CREATE OR ALTER PROCEDURE guia.sp_asignar_especializacion
@dni CHAR(8),
@especialidad VARCHAR(50)
AS
BEGIN
    DECLARE @error VARCHAR(50);
    SET @error = '';

    DECLARE @id_guia INT;
    DECLARE @id_especialidad INT;

    IF @dni IS NULL
        SET @error += 'Se debe especificar el dni del guia.' + CHAR(10);
    ELSE
    BEGIN
        SET @id_guia = (SELECT id from gestion.Guia WHERE dni = @dni);
        IF @id_guia IS NULL
            SET @error += 'El dni no pertenece a ningun guia.' + CHAR(10);
    END

    IF @especialidad IS NULL
        SET @error += 'Se debe especificar la especializacion.' + CHAR(10);
    ELSE
    BEGIN
        SET @id_especialidad = (SELECT id from guia.Especialidad WHERE descripcion = @especialidad);
        IF @id_especialidad IS NULL
            SET @error += 'La especialidad no se encuentra registrada.' + CHAR(10);
    END

    IF @especialidad IS NOT NULL AND @dni IS NOT NULL
        IF EXISTS (SELECT id FROM guia.Especializado_en WHERE id_guia = @id_guia AND id_especialidad = @id_especialidad)
            SET @error += 'El guia ya tiene asignada esa especializacion.' + CHAR(10);   

    IF @error != ''
        RAISERROR(@error, 16, 1);
    ELSE
    BEGIN
        INSERT INTO guia.Especializado_en VALUES(@id_guia, @id_especialidad)
    END
END
GO

-----------------------------------------------------------
-- Actualizar acreditacion de guias

CREATE OR ALTER PROCEDURE guia.sp_actualizar_acreditacion
@dni CHAR(8),
@fecha_vencimiento_acreditacion DATE
AS
BEGIN
    DECLARE @error VARCHAR(50);
    SET @error = '';

    DECLARE @estado_acreditacion CHAR(7);
    DECLARE @id_acreditacion INT;
    DECLARE @id_guia INT;

    IF @dni IS NULL
        SET @error += 'Se debe especificar el dni del guia.' + CHAR(10);
    ELSE
    BEGIN
        SET @id_guia = (SELECT id from gestion.Guia WHERE dni = @dni);
        IF @id_guia IS NULL
            SET @error += 'El dni no pertenece a ningun guia.' + CHAR(10);
        ELSE
        BEGIN
            SET @id_acreditacion = (SELECT id_acreditacion FROM gestion.Guia WHERE id = @id_guia);
            IF @id_acreditacion IS NULL
                SET @error += 'El guia no posee una acreditacion.' + CHAR(10);
        END
    END

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
        UPDATE guia.Acreditacion SET fecha_vencimiento = @fecha_vencimiento_acreditacion, estado = @estado_acreditacion 
            WHERE id = @id_acreditacion;
    END
END
GO

-----------------------------------------------------------
-- Asignar titulo a un guia

CREATE OR ALTER PROCEDURE guia.sp_asignar_titulacion_guia
@dni CHAR(8),
@descripcion VARCHAR(80),
@institucion VARCHAR(30),
@fecha_emision DATE
AS
BEGIN
    DECLARE @error VARCHAR(150);
    SET @error = '';

    DECLARE @id_guia INT;
    DECLARE @id_titulo INT;

    IF @dni IS NULL
        SET @error += 'Se debe especificar el dni del guia.' + CHAR(10);
    ELSE
    BEGIN
        SET @id_guia = (SELECT id from gestion.Guia WHERE dni = @dni);
        IF @id_guia IS NULL
            SET @error += 'El dni no pertenece a ningun guia.' + CHAR(10);
    END

    IF @descripcion IS NULL OR @descripcion = ''
        SET @error += 'El titulo debe tener descripcion.' + CHAR(10);
    
    IF @institucion IS NULL OR @institucion = ''
        SET @error += 'El titulo debe tener una institucion.' + CHAR(10);
    
    IF @fecha_emision IS NULL OR @fecha_emision = ''
        SET @error += 'El titulo debe tener una fecha de emision.' + CHAR(10);

    IF EXISTS(
            SELECT t.id FROM guia.Titulo t INNER JOIN guia.Titulacion_guia tg on tg.id_titulo = t.id
            WHERE descripcion = @descripcion AND institucion = @institucion AND tg.id_guia = @id_guia
        )
        SET @error += 'El guia ya tiene asignada ese titulo.' + CHAR(10);   

    IF @error != ''
        RAISERROR(@error, 16, 1);
    ELSE
    BEGIN
        BEGIN TRANSACTION
            INSERT INTO guia.Titulo VALUES(@descripcion, @institucion, @fecha_emision);

            SET @id_titulo = SCOPE_IDENTITY();

            INSERT INTO guia.Titulacion_guia VALUES(@id_guia, @id_titulo);
        COMMIT
    END
END
GO

-----------------------------------------------------------
-- Actualizar titulo a un guia

CREATE OR ALTER PROCEDURE guia.sp_actualizar_titulo_guia
@dni CHAR(8),
@descripcion VARCHAR(80),
@institucion VARCHAR(30),
@fecha_emision DATE
AS
BEGIN
    DECLARE @error VARCHAR(150);
    SET @error = '';

    DECLARE @id_guia INT;
    DECLARE @id_titulo INT;

    IF @dni IS NULL
        SET @error += 'Se debe especificar el dni del guia.' + CHAR(10);
    ELSE
    BEGIN
        SET @id_guia = (SELECT id from gestion.Guia WHERE dni = @dni);
        IF @id_guia IS NULL
            SET @error += 'El dni no pertenece a ningun guia.' + CHAR(10);
    END

    IF @descripcion IS NULL OR @descripcion = ''
        SET @error += 'El titulo debe tener descripcion.' + CHAR(10);
    
    IF @institucion IS NULL OR @institucion = ''
        SET @error += 'El titulo debe tener una institucion.' + CHAR(10);
    
    IF @fecha_emision IS NULL OR @fecha_emision = ''
        SET @error += 'El titulo debe tener una fecha de emision.' + CHAR(10);
    
    IF @id_guia IS NOT NULL AND @descripcion IS NOT NULL AND @institucion IS NOT NULL
    BEGIN
        SET @id_titulo = (
                SELECT t.id FROM guia.Titulo t INNER JOIN guia.Titulacion_guia tg on tg.id_titulo = t.id
                WHERE descripcion = @descripcion AND institucion = @institucion AND tg.id_guia = @id_guia
        )
        IF @id_titulo IS NULL
            SET @error += 'El guia no tiene asignado ese titulo.' + CHAR(10);   
    END
    IF @error != ''
        RAISERROR(@error, 16, 1);
    ELSE
    BEGIN
        UPDATE guia.titulo SET fecha_emision = @fecha_emision WHERE id = @id_titulo;
    END
END
GO
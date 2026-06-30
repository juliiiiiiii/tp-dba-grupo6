
-- Universidad: Universidad de la Matanza
-- Materia: 3641 - Bases de Datos Aplicadas
 
-- Grupo 06
-- Integrantes:
--  De Bellis, Nahuel
--  Ocampo, Julian Rafael
--  Rodriguez, Gonzalo Ezequiel
--  Vargas, Tomas
 
-- Objetivo del script: Script de modificacion para aplicar cifrado de columna a los campos DNI de personal.Guardaparque y personal.Guia
-- Fecha: 30/06/2026
 
USE parques_nacionales;
GO
 
-- La columna dni_cifrado reemplaza la columna dni

IF COL_LENGTH('personal.Guardaparque', 'dni_cifrado') IS NULL
    ALTER TABLE personal.Guardaparque ADD dni_cifrado VARBINARY(256);
GO
 
UPDATE personal.Guardaparque
SET dni_cifrado = EncryptByPassPhrase('parques_nacionales_2026', dni)
WHERE dni_cifrado IS NULL;
GO

DECLARE @sql NVARCHAR(MAX) = '';
 
SELECT @sql += 'ALTER TABLE personal.Guardaparque DROP CONSTRAINT [' + cc.name + '];' + CHAR(10)
FROM sys.check_constraints cc
WHERE cc.parent_object_id = OBJECT_ID('personal.Guardaparque')
  AND cc.definition LIKE '%dni%';
 
SELECT @sql += 'ALTER TABLE personal.Guardaparque DROP CONSTRAINT [' + i.name + '];' + CHAR(10)
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c       ON ic.object_id = c.object_id  AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('personal.Guardaparque')
  AND i.is_unique_constraint = 1
  AND c.name = 'dni';
 
IF @sql != ''
    EXEC sp_executesql @sql;
GO
 
IF COL_LENGTH('personal.Guardaparque', 'dni') IS NOT NULL
    ALTER TABLE personal.Guardaparque DROP COLUMN dni;
GO
 
EXEC sp_rename 'personal.Guardaparque.dni_cifrado', 'dni', 'COLUMN';
GO
 
ALTER TABLE personal.Guardaparque ALTER COLUMN dni VARBINARY(256) NOT NULL;
GO

 
IF COL_LENGTH('personal.Guia', 'dni_cifrado') IS NULL
    ALTER TABLE personal.Guia ADD dni_cifrado VARBINARY(256);
GO
 
UPDATE personal.Guia
SET dni_cifrado = EncryptByPassPhrase('parques_nacionales_2026', dni)
WHERE dni_cifrado IS NULL;
GO
 
DECLARE @sql2 NVARCHAR(MAX) = '';
 
SELECT @sql2 += 'ALTER TABLE personal.Guia DROP CONSTRAINT [' + cc.name + '];' + CHAR(10)
FROM sys.check_constraints cc
WHERE cc.parent_object_id = OBJECT_ID('personal.Guia')
  AND cc.definition LIKE '%dni%';
 
SELECT @sql2 += 'ALTER TABLE personal.Guia DROP CONSTRAINT [' + i.name + '];' + CHAR(10)
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c       ON ic.object_id = c.object_id  AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('personal.Guia')
  AND i.is_unique_constraint = 1
  AND c.name = 'dni';
 
IF @sql2 != ''
    EXEC sp_executesql @sql2;
GO
 
IF COL_LENGTH('personal.Guia', 'dni') IS NOT NULL
    ALTER TABLE personal.Guia DROP COLUMN dni;
GO
 
EXEC sp_rename 'personal.Guia.dni_cifrado', 'dni', 'COLUMN';
GO
 
ALTER TABLE personal.Guia ALTER COLUMN dni VARBINARY(256) NOT NULL;
GO



CREATE OR ALTER PROCEDURE personal.Guardaparque_alta
    @dni  CHAR(8),
    @nombre   CHAR(30),
    @apellido CHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
 
    DECLARE @errores   VARCHAR(200) = '';
 
    IF @dni IS NULL OR @dni NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        SET @errores += 'El DNI debe ser de 8 digitos numericos.' + CHAR(10);
    ELSE
    BEGIN
        IF EXISTS (
            SELECT 1 FROM personal.Guardaparque 
            WHERE CONVERT(CHAR(8), DecryptByPassPhrase('parques_nacionales_2026', dni)) = @dni
        )
            SET @errores += 'El DNI del guardaparque ya esta registrado.' + CHAR(10);
    END
 
    IF (@nombre IS NULL OR @apellido IS NULL)
        SET @errores += 'Debe ingresar nombre y apellido.' + CHAR(10);
 
    IF @errores != ''
        THROW 50000, @errores, 1;
 
    INSERT INTO personal.Guardaparque (dni, nombre, apellido, estado)
    VALUES (EncryptByPassPhrase('parques_nacionales_2026', @dni), @nombre, @apellido, 'Inactivo');
END
GO

CREATE OR ALTER PROCEDURE personal.Guardaparque_baja
    @dni CHAR(8)
AS
BEGIN
    SET NOCOUNT ON;
 
    DECLARE @errores VARCHAR(200) = '';
    DECLARE @id INT;
 
    IF @dni IS NULL OR @dni NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        SET @errores += 'El DNI debe ser de 8 digitos numericos.' + CHAR(10);
    ELSE
    BEGIN
        SELECT @id = id FROM personal.Guardaparque 
        WHERE CONVERT(CHAR(8), DecryptByPassPhrase('parques_nacionales_2026', dni)) = @dni;
 
        IF @id IS NULL
            SET @errores += 'El guardaparque que se quiere dar de baja no existe.' + CHAR(10);
        ELSE
            IF (SELECT estado FROM personal.Guardaparque WHERE id = @id) != 'Activo'
                SET @errores += 'El guardaparque no se encuentra asignado a ningun parque.' + CHAR(10);
    END
 
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
    @dni      CHAR(8),
    @nombre   CHAR(30),
    @apellido CHAR(30),
    @estado   CHAR(8)
AS
BEGIN
    SET NOCOUNT ON;
 
    DECLARE @errores     VARCHAR(200) = '';
    DECLARE @id          INT;
 
    IF @dni IS NULL OR @dni NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        SET @errores += 'El DNI debe ser de 8 digitos numericos.' + CHAR(10);
    ELSE
    BEGIN
        SELECT @id = id FROM personal.Guardaparque 
        WHERE CONVERT(CHAR(8), DecryptByPassPhrase('parques_nacionales_2026', dni)) = @dni;
 
        IF @id IS NULL
            SET @errores += 'El guardaparque que se desea modificar no existe.' + CHAR(10);
        ELSE
        BEGIN
            IF @nombre IS NULL AND @apellido IS NULL AND @estado IS NULL
                SET @errores += 'Debe ingresar valores para modificar al guardaparque.' + CHAR(10);
            ELSE
            BEGIN
                IF @nombre IS NULL
                    SELECT @nombre = nombre FROM personal.Guardaparque WHERE id = @id;
 
                IF @apellido IS NULL
                    SELECT @apellido = apellido FROM personal.Guardaparque WHERE id = @id;
 
                IF @estado IS NOT NULL AND @estado NOT IN ('Activo', 'Inactivo')
                    SET @errores += 'Estado invalido. Los valores permitidos son: Activo o Inactivo.' + CHAR(10);
                ELSE IF @estado IS NULL
                    SELECT @estado = estado FROM personal.Guardaparque WHERE id = @id;
 
                IF @estado = 'Activo'
                AND NOT EXISTS (SELECT id_guardaparque FROM gestion.Parque_asignado WHERE id_guardaparque = @id AND fecha_egreso IS NULL)
                    SET @errores += 'No se puede establecer como activo a un guardaparque sin asignacion activa.' + CHAR(10);
            END
        END
    END
 
    IF @errores != ''
        THROW 50000, @errores, 1;
 
    UPDATE personal.Guardaparque
    SET nombre = @nombre, apellido = @apellido, estado = @estado
    WHERE id = @id;
END
GO


CREATE OR ALTER PROCEDURE personal.Guia_alta
    @dni                          CHAR(8),
    @nombre                       VARCHAR(30),
    @apellido                     VARCHAR(30),
    @fecha_vencimiento_acreditacion DATE
AS
BEGIN
    DECLARE @id_acreditacion     INT;
    DECLARE @estado_acreditacion CHAR(7);
    DECLARE @error               VARCHAR(100) = '';
 
    IF @dni IS NULL
        SET @error += 'Se debe especificar el DNI del guia.' + CHAR(10);
    ELSE
    BEGIN
        IF @dni NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
            SET @error += 'Ingresar DNI valido (8 digitos numericos).' + CHAR(10);
        ELSE
            IF EXISTS (SELECT id FROM personal.Guia WHERE CONVERT(CHAR(8), DecryptByPassPhrase('parques_nacionales_2026', dni)) = @dni)
                SET @error += 'El DNI ya pertenece a un guia.' + CHAR(10);
    END
 
    IF @nombre IS NULL OR @apellido IS NULL OR @nombre = '' OR @apellido = ''
        SET @error += 'Se debe especificar nombre y apellido del guia.' + CHAR(10);
 
    IF @fecha_vencimiento_acreditacion IS NULL
        SET @error += 'Se debe especificar fecha de vencimiento de acreditacion.' + CHAR(10);
    ELSE
    BEGIN
        IF @fecha_vencimiento_acreditacion < CAST(GETDATE() AS DATE)
            SET @estado_acreditacion = 'vencido';
        ELSE
            SET @estado_acreditacion = 'vigente';
    END
 
    IF @error != ''
        THROW 50000, @error, 1;
 
    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO personal.Acreditacion VALUES (@fecha_vencimiento_acreditacion, @estado_acreditacion);
            SET @id_acreditacion = SCOPE_IDENTITY();
            INSERT INTO personal.Guia (dni, nombre, apellido, estado, id_acreditacion)
            VALUES (EncryptByPassPhrase('parques_nacionales_2026', @dni), @nombre, @apellido, 'ACTIVO', @id_acreditacion);
        COMMIT
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE personal.Guia_baja
    @dni CHAR(8)
AS
BEGIN
    DECLARE @error       VARCHAR(100) = '';
    DECLARE @id INT;
 
    IF @dni IS NULL
        SET @error += 'Se debe especificar el DNI del guia.' + CHAR(10);
    ELSE
    BEGIN
        IF @dni NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
            SET @error += 'Ingresar DNI valido.' + CHAR(10);
        ELSE
        BEGIN
            SELECT @id = id FROM personal.Guardaparque 
            WHERE CONVERT(CHAR(8), DecryptByPassPhrase('parques_nacionales_2026', dni)) = @dni;

            IF @id IS NULL
                SET @error += 'El DNI no pertenece a un guia.' + CHAR(10);
            IF EXISTS (SELECT 1 FROM personal.Guia WHERE id = @id AND estado = 'INACTIVO')
                SET @error += 'El guia ya esta dado de baja.' + CHAR(10);
        END
    END
 
    IF @error != ''
        THROW 50000, @error, 1;
 
    UPDATE personal.Guia SET estado = 'INACTIVO'
    WHERE dni = EncryptByPassPhrase('parques_nacionales_2026', @dni);
END
GO


CREATE OR ALTER PROCEDURE personal.Guia_modificacion
    @dni      CHAR(8),
    @nombre   VARCHAR(30),
    @apellido VARCHAR(30)
AS
BEGIN
    DECLARE @error       VARCHAR(100) = '';
    DECLARE @id INT;
 
    IF @dni IS NULL
        SET @error += 'Se debe especificar el DNI del guia.' + CHAR(10);
    ELSE
    BEGIN
        IF @nombre IS NULL AND @apellido IS NULL
            SET @error += 'Se debe especificar nombre y/o apellido del guia.' + CHAR(10);
        ELSE
        BEGIN
            IF @dni NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
                SET @error += 'Ingresar DNI valido.' + CHAR(10);
            ELSE
            BEGIN
                SELECT @id = id FROM personal.Guia 
                WHERE CONVERT(CHAR(8), DecryptByPassPhrase('parques_nacionales_2026', dni)) = @dni;
                
                IF @id IS NULL
                    SET @error += 'El DNI no pertenece a un guia.' + CHAR(10);
 
                IF @nombre IS NULL
                    SELECT @nombre = nombre FROM personal.Guia WHERE dni = @dni;
                IF @apellido IS NULL
                    SELECT @apellido = apellido FROM personal.Guia WHERE dni = @dni;
            END
        END
    END
 
    IF @error != ''
        THROW 50000, @error, 1;
 
    UPDATE personal.Guia
    SET nombre = @nombre, apellido = @apellido
    WHERE CONVERT(CHAR(8), DecryptByPassPhrase('parques_nacionales_2026', dni)) = @dni;
END
GO


CREATE OR ALTER PROCEDURE personal.especialidad_asignar
    @dni         CHAR(8),
    @especialidad VARCHAR(50)
AS
BEGIN
    DECLARE @error         VARCHAR(50) = '';
    DECLARE @id_guia       INT;
    DECLARE @id_especialidad INT;
 
    IF @dni IS NULL
        SET @error += 'Se debe especificar el DNI del guia.' + CHAR(10);
    ELSE
    BEGIN
        SET @id_guia = (SELECT id FROM personal.Guia
                        WHERE CONVERT(CHAR(8), DecryptByPassPhrase('parques_nacionales_2026', dni)) = @dni)
        IF @id_guia IS NULL
            SET @error += 'El DNI no pertenece a ningun guia.' + CHAR(10);
    END
 
    IF @especialidad IS NULL
        SET @error += 'Se debe especificar la especializacion.' + CHAR(10);
    ELSE
    BEGIN
        SET @id_especialidad = (SELECT id FROM personal.Especialidad WHERE descripcion = @especialidad);
        IF @id_especialidad IS NULL
            SET @error += 'La especialidad no se encuentra registrada.' + CHAR(10);
    END
 
    IF @especialidad IS NOT NULL AND @dni IS NOT NULL
        IF EXISTS (SELECT id FROM personal.Especializado_en WHERE id_guia = @id_guia AND id_especialidad = @id_especialidad)
            SET @error += 'El guia ya tiene asignada esa especializacion.' + CHAR(10);
 
    IF @error != ''
        THROW 50000, @error, 1;
 
    INSERT INTO personal.Especializado_en VALUES (@id_guia, @id_especialidad);
END
GO

-- select * from personal.Acreditacion

CREATE OR ALTER PROCEDURE personal.acreditacion_actualizar
    @dni                          CHAR(8),
    @fecha_vencimiento_acreditacion DATE
AS
BEGIN
    DECLARE @error               VARCHAR(50) = '';
    DECLARE @estado_acreditacion CHAR(7);
    DECLARE @id_acreditacion     INT;
    DECLARE @id_guia             INT;
 
    IF @dni IS NULL
        SET @error += 'Se debe especificar el DNI del guia.' + CHAR(10);
    ELSE
    BEGIN
        SET @id_guia = (SELECT id FROM personal.Guia
                        WHERE CONVERT(CHAR(8), DecryptByPassPhrase('parques_nacionales_2026', dni)) = @dni);
        IF @id_guia IS NULL
            SET @error += 'El DNI no pertenece a ningun guia.' + CHAR(10);
        ELSE
        BEGIN
            SET @id_acreditacion = (SELECT id_acreditacion FROM personal.Guia WHERE id = @id_guia);
            IF @id_acreditacion IS NULL
                SET @error += 'El guia no posee una acreditacion.' + CHAR(10);
        END
    END
 
    IF @fecha_vencimiento_acreditacion IS NULL
        SET @error += 'Se debe especificar fecha de vencimiento de acreditacion.' + CHAR(10);
    ELSE
    BEGIN
        IF @fecha_vencimiento_acreditacion < CAST(GETDATE() AS DATE)
            SET @estado_acreditacion = 'vencido';
        ELSE
            SET @estado_acreditacion = 'vigente';
    END
 
    IF @error != ''
        THROW 50000, @error, 1;
 
    UPDATE personal.Acreditacion
    SET fecha_vencimiento = @fecha_vencimiento_acreditacion,
        estado            = @estado_acreditacion
    WHERE id = @id_acreditacion;
END
GO


CREATE OR ALTER PROCEDURE personal.titulacion_asignar
    @dni          CHAR(8),
    @descripcion  VARCHAR(80),
    @institucion  VARCHAR(30),
    @fecha_emision DATE
AS
BEGIN
    DECLARE @error   VARCHAR(150) = '';
    DECLARE @id_guia INT;
    DECLARE @id_titulo INT;
 
    IF @dni IS NULL
        SET @error += 'Se debe especificar el DNI del guia.' + CHAR(10);
    ELSE
    BEGIN
        SET @id_guia = (SELECT id FROM personal.Guia
                        WHERE CONVERT(CHAR(8), DecryptByPassPhrase('parques_nacionales_2026', dni)) = @dni);
        IF @id_guia IS NULL
            SET @error += 'El DNI no pertenece a ningun guia.' + CHAR(10);
    END
 
    IF @descripcion IS NULL OR @descripcion = ''
        SET @error += 'El titulo debe tener descripcion.' + CHAR(10);
 
    IF EXISTS (
        SELECT t.id FROM personal.Titulo t
        INNER JOIN personal.Titulacion_guia tg ON tg.id_titulo = t.id
        WHERE descripcion = @descripcion AND tg.id_guia = @id_guia
    )
        SET @error += 'El guia ya tiene asignado ese titulo.' + CHAR(10);
 
    IF @error != ''
        THROW 50000, @error, 1;
 
    BEGIN TRANSACTION
        INSERT INTO personal.Titulo VALUES (@descripcion, @institucion, @fecha_emision);
        SET @id_titulo = SCOPE_IDENTITY();
        INSERT INTO personal.Titulacion_guia VALUES (@id_guia, @id_titulo);
    COMMIT
END
GO


CREATE OR ALTER PROCEDURE personal.titulo_modificacion
    @dni          CHAR(8),
    @descripcion  VARCHAR(80),
    @institucion  VARCHAR(30),
    @fecha_emision DATE
AS
BEGIN
    DECLARE @error   VARCHAR(150) = '';
    DECLARE @id_guia INT;
    DECLARE @id_titulo INT;
 
    IF @dni IS NULL
        SET @error += 'Se debe especificar el DNI del guia.' + CHAR(10);
    ELSE
    BEGIN
        SET @id_guia = (SELECT id FROM personal.Guia
                        where CONVERT(CHAR(8), DecryptByPassPhrase('parques_nacionales_2026', dni)) = @dni);
        IF @id_guia IS NULL
            SET @error += 'El DNI no pertenece a ningun guia.' + CHAR(10);
    END
 
    IF @descripcion IS NULL OR @descripcion = ''
        SET @error += 'El titulo debe tener descripcion.' + CHAR(10);
 
    IF @id_guia IS NOT NULL AND @descripcion IS NOT NULL AND @institucion IS NOT NULL
    BEGIN
        SET @id_titulo = (
            SELECT t.id FROM personal.Titulo t
            INNER JOIN personal.Titulacion_guia tg ON tg.id_titulo = t.id
            WHERE descripcion = @descripcion AND tg.id_guia = @id_guia
        );
        IF @id_titulo IS NULL
            SET @error += 'El guia no tiene asignado ese titulo.' + CHAR(10);
    END
 
    IF @error != ''
        THROW 50000, @error, 1;
 
    UPDATE personal.Titulo
    SET fecha_emision = @fecha_emision, institucion = @institucion
    WHERE id = @id_titulo;
END
GO



CREATE OR ALTER PROCEDURE gestion.actividad_alta
    @nombre_parque VARCHAR(100),
    @dni_guia      CHAR(8),
    @nombre        CHAR(50),
    @descripcion   VARCHAR(100),
    @tipo          CHAR(25),
    @costo         DECIMAL(7,2),
    @fecha         DATE,
    @duracion      INT,
    @cupo          INT
AS
BEGIN
    SET NOCOUNT ON;
 
    DECLARE @errores   VARCHAR(300) = '';
    DECLARE @id_parque INT;
    DECLARE @id_guia   INT;
    DECLARE @id_tipo   INT;
 
    SELECT @id_parque = id FROM gestion.Parque WHERE nombre = @nombre_parque;
    IF @id_parque IS NULL
        SET @errores += 'El parque no existe.' + CHAR(10);


    SELECT @id_guia = id FROM personal.Guia
    WHERE CONVERT(CHAR(8), DecryptByPassPhrase('parques_nacionales_2026', dni)) = @dni_guia;
 
    IF @id_guia IS NULL
        SET @errores += 'El guia no existe.' + CHAR(10);
    ELSE
        IF NOT EXISTS (
            SELECT g.id FROM personal.Guia g
            INNER JOIN personal.Acreditacion a ON g.id_acreditacion = a.id
            WHERE g.id = @id_guia AND a.estado = 'vigente' AND a.fecha_vencimiento >= GETDATE()
        )
            SET @errores += 'El guia no esta autorizado (acreditacion vencida o inexistente).' + CHAR(10);
 
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


CREATE OR ALTER PROCEDURE gestion.actividad_modificacion
    @nombre      CHAR(50),
    @descripcion VARCHAR(100),
    @tipo        CHAR(25),
    @costo       DECIMAL(9,2),
    @fecha       DATE,
    @duracion    INT,
    @cupo        INT,
    @estado      CHAR(10),
    @dni_guia    CHAR(8)
AS
BEGIN
    SET NOCOUNT ON;
 
    DECLARE @errores     VARCHAR(400) = '';
    DECLARE @id_actividad INT;
    DECLARE @id_guia     INT;
    DECLARE @id_tipo     INT;
    DECLARE @estado_actual CHAR(10);
 
    SELECT @id_actividad = id FROM gestion.Actividad WHERE nombre = @nombre;
    SELECT @id_tipo      = id FROM gestion.Tipo_actividad WHERE descripcion = @tipo;
 
    IF NOT EXISTS (SELECT id FROM gestion.Actividad WHERE id = @id_actividad)
        SET @errores += 'La actividad que se desea modificar no existe.' + CHAR(10);
    ELSE
    BEGIN
        SELECT @estado_actual = estado FROM gestion.Actividad WHERE id = @id_actividad;
        IF @estado_actual IN ('Cancelado', 'Finalizado', 'En curso')
            SET @errores += 'No se puede modificar una actividad que esta ' + RTRIM(@estado_actual) + '.' + CHAR(10);
    END
 

    SELECT @id_guia = id FROM personal.Guia
    WHERE CONVERT(CHAR(8), DecryptByPassPhrase('parques_nacionales_2026', dni)) = @dni_guia;
 
    IF NOT EXISTS (SELECT id FROM personal.Guia WHERE id = @id_guia)
        SET @errores += 'El guia especificado no existe.' + CHAR(10);
    ELSE
    BEGIN

        IF NOT EXISTS (
            SELECT g.id FROM personal.Guia g
            INNER JOIN personal.Acreditacion a ON g.id_acreditacion = a.id
            WHERE g.id = @id_guia
              AND a.estado = 'vigente'
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
 
    UPDATE gestion.Actividad
    SET id_tipo = @id_tipo, descripcion = @descripcion, costo = @costo,
        fecha = @fecha, duracion = @duracion, cupo = @cupo, estado = @estado
    WHERE id = @id_actividad;
END
GO



CREATE OR ALTER PROCEDURE gestion.coordina_alta
    @dni            CHAR(8),
    @nombre_actividad VARCHAR(50),
    @nombre_parque  VARCHAR(100),
    @fecha_actividad DATETIME,
    @f_desde        DATE,
    @f_hasta        DATE
AS
BEGIN
    DECLARE @error       VARCHAR(150) = '';
    DECLARE @id_guia     INT;
    DECLARE @id_parque   INT;
    DECLARE @id_actividad INT;
 
    IF @dni IS NULL
        SET @error += 'Se debe especificar el DNI del guia.' + CHAR(10);
    ELSE
    BEGIN
        SET @id_guia = (SELECT id FROM personal.Guia
                        WHERE CONVERT(CHAR(8), DecryptByPassPhrase('parques_nacionales_2026', dni)) = @dni);
        IF @id_guia IS NULL
            SET @error += 'El DNI no pertenece a ningun guia.' + CHAR(10);
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
                    WHERE nombre = @nombre_actividad AND id_parque = @id_parque AND fecha = @fecha_actividad);
                IF @id_actividad IS NULL
                    SET @error += 'No existe una actividad con ese nombre en ese parque en esa fecha.' + CHAR(10);
            END
        END
    END
 
    IF @f_desde IS NULL OR @f_hasta IS NULL
        SET @error += 'Se debe especificar la fecha desde y fecha hasta.' + CHAR(10);
 
    IF @id_guia IS NOT NULL AND EXISTS (
        SELECT g.id FROM personal.Guia g
        INNER JOIN personal.Acreditacion a ON g.id_acreditacion = a.id
        WHERE g.id = @id_guia AND a.estado = 'vencido'
    )
        SET @error += 'El guia posee la acreditacion vencida.' + CHAR(10);
 
    IF @id_guia IS NOT NULL AND EXISTS (
        SELECT g.id FROM personal.Guia g WHERE g.id = @id_guia AND g.estado = 'INACTIVO'
    )
        SET @error += 'El guia se encuentra inactivo.' + CHAR(10);
 
    IF @id_actividad IS NOT NULL AND @f_desde IS NOT NULL AND @f_hasta IS NOT NULL AND @id_guia IS NOT NULL
        IF EXISTS (SELECT id FROM gestion.Coordina
            WHERE id_actividad = @id_actividad AND id_guia = @id_guia
              AND fecha_desde = @f_desde AND fecha_hasta = @f_hasta AND estado = 'ACTIVO')
            SET @error += 'La actividad ya se encuentra asignada al guia.' + CHAR(10);
 
    IF @error != ''
        THROW 50000, @error, 1;
 
    IF EXISTS (SELECT id FROM gestion.Coordina
        WHERE id_actividad = @id_actividad AND id_guia = @id_guia
          AND fecha_desde = @f_desde AND fecha_hasta = @f_hasta AND estado = 'INACTIVO')
        UPDATE gestion.Coordina SET estado = 'ACTIVO'
            WHERE id_actividad = @id_actividad AND id_guia = @id_guia
              AND fecha_desde = @f_desde AND fecha_hasta = @f_hasta;
    ELSE
        INSERT INTO gestion.Coordina VALUES ('ACTIVO', @id_actividad, @id_guia, @f_desde, @f_hasta);
END
GO



CREATE OR ALTER PROCEDURE gestion.coordina_baja
    @dni             CHAR(8),
    @nombre_actividad VARCHAR(50),
    @nombre_parque   VARCHAR(50),
    @fecha_actividad  DATETIME,
    @f_desde         DATE,
    @f_hasta         DATE
AS
BEGIN
    DECLARE @error       VARCHAR(150) = '';
    DECLARE @id_guia     INT;
    DECLARE @id_parque   INT;
    DECLARE @id_actividad INT;
 
    IF @dni IS NULL
        SET @error += 'Se debe especificar el DNI del guia.' + CHAR(10);
    ELSE
    BEGIN
        SET @id_guia = (SELECT id FROM personal.Guia
                        WHERE CONVERT(CHAR(8), DecryptByPassPhrase('parques_nacionales_2026', dni)) = @dni);
        IF @id_guia IS NULL
            SET @error += 'El DNI no pertenece a ningun guia.' + CHAR(10);
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
                    WHERE nombre = @nombre_actividad AND id_parque = @id_parque AND fecha = @fecha_actividad);
                IF @id_actividad IS NULL
                    SET @error += 'No existe una actividad con ese nombre en ese parque en esa fecha.' + CHAR(10);
            END
        END
    END
 
    IF @f_desde IS NULL OR @f_hasta IS NULL
        SET @error += 'Se debe especificar la fecha desde y fecha hasta.' + CHAR(10);
 
    IF @id_actividad IS NOT NULL AND @f_desde IS NOT NULL AND @f_hasta IS NOT NULL AND @id_guia IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT id FROM gestion.Coordina
            WHERE id_actividad = @id_actividad AND id_guia = @id_guia
              AND fecha_desde = @f_desde AND fecha_hasta = @f_hasta)
            SET @error += 'La actividad no se encuentra asignada al guia.' + CHAR(10);
 
        IF EXISTS (SELECT id FROM gestion.Coordina
            WHERE id_actividad = @id_actividad AND id_guia = @id_guia
              AND fecha_desde = @f_desde AND fecha_hasta = @f_hasta AND estado = 'INACTIVO')
            SET @error += 'El guia ya se encuentra dado de baja de la actividad.' + CHAR(10);
    END
 
    IF @error != ''
        THROW 50000, @error, 1;
 
    UPDATE gestion.Coordina SET estado = 'INACTIVO'
    WHERE id_actividad = @id_actividad AND id_guia = @id_guia
      AND fecha_desde = @f_desde AND fecha_hasta = @f_hasta;
END
GO

--use parcial_1
--drop database parques_nacionales

/*
SELECT
    id,
    dni                                                              AS dni_cifrado_bytes,
    CONVERT(CHAR(8), DecryptByPassPhrase('parques_nacionales_2026', dni)) AS dni_legible,
    nombre,
    apellido,
    estado
FROM personal.Guardaparque;
GO
 
SELECT
    id,
    dni                                                              AS dni_cifrado_bytes,
    CONVERT(CHAR(8), DecryptByPassPhrase('parques_nacionales_2026', dni)) AS dni_legible,
    nombre,
    apellido,
    estado
FROM personal.Guia;
GO

exec gestion.guardaparque_asignar @id_parque = 1, @id_guardaparque = 7
select * from gestion.Parque_asignado
 
-- Confirmar que los SPs modificados funcionan correctamente
-- (busqueda, alta y baja usando dni en texto plano)



PRINT '=== TEST 0: Prueba alta y baja de guardaparque ===';
BEGIN TRY
    EXEC personal.Guardaparque_alta @dni='88888888', @nombre='Test', @apellido='Cifrado'
    
    EXEC personal.Guardaparque_baja @dni='88888888'

    PRINT 'Guardaparques creados exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error inesperado en alta: ' + ERROR_MESSAGE();
END CATCH;
GO


PRINT '=== TEST 1: Altas de Guardaparques (Éxito) ===';
BEGIN TRY
    EXEC personal.Guardaparque_alta @dni = '40111222', @nombre = 'Carlos', @apellido = 'Pérez';
    
    EXEC personal.Guardaparque_alta @dni = '41333444', @nombre = 'María', @apellido = 'López';
    
    PRINT 'Guardaparques creados exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error inesperado en alta: ' + ERROR_MESSAGE();
END CATCH;
GO

select * from personal.Guardaparque


PRINT '=== TEST 2: Asignación de Parque (Activa el Estado) ===';
BEGIN TRY
    DECLARE @id_gp INT = (SELECT id FROM personal.Guardaparque WHERE CONVERT(CHAR(8), DecryptByPassPhrase('parques_nacionales_2026', dni)) = '41333444');
    
    EXEC gestion.guardaparque_asignar @id_parque = 1, @id_guardaparque = @id_gp;
    PRINT 'Guardaparque asignado correctamente (Su estado ahora debería ser Activo).';
END TRY
BEGIN CATCH
    PRINT 'Error en asignación: ' + ERROR_MESSAGE();
END CATCH;
GO



PRINT '=== TEST 3: Validaciones de Guardaparque (Errores esperados) ===';
BEGIN TRY
    EXEC personal.Guardaparque_alta @dni = '40111222', @nombre = 'Clon de Carlos', @apellido = 'Pérez';
END TRY
BEGIN CATCH
    PRINT 'Fallo esperado (Duplicado): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    EXEC personal.Guardaparque_alta @dni = '40ABC', @nombre = NULL, @apellido = NULL;
END TRY
BEGIN CATCH
    PRINT 'Fallo esperado (Múltiples errores): ' + CHAR(10) + ERROR_MESSAGE();
END CATCH;
GO


PRINT '=== TEST 4: Modificación de Guardaparque ===';
BEGIN TRY
    EXEC personal.Guardaparque_modificacion @dni = '40111222', @nombre = 'Carlos Alberto', @apellido = 'Pérez Silva', @estado = NULL;
    PRINT 'Guardaparque modificado correctamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en modificación: ' + ERROR_MESSAGE();
END CATCH;
GO



PRINT '=== TEST 5: Baja de Guardaparque ===';
BEGIN TRY
    EXEC personal.Guardaparque_baja @dni = '41333444';
    PRINT 'Guardaparque dado de baja correctamente (Asignación finalizada).';
END TRY
BEGIN CATCH
    PRINT 'Error en baja: ' + ERROR_MESSAGE();
END CATCH;
GO


PRINT '=== TEST 6: Alta de Guía con Acreditación Vigente ===';
BEGIN TRY
    EXEC personal.Guia_alta @dni = '38555666', @nombre = 'Juan', @apellido = 'Gómez', @fecha_vencimiento_acreditacion = '2027-12-31';
    PRINT 'Guía creado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en alta de guía: ' + ERROR_MESSAGE();
END CATCH;
GO

select * from personal.guia


PRINT '=== TEST 7: Asignar Especialidad y Titulación ===';
BEGIN TRY

    IF NOT EXISTS (SELECT 1 FROM personal.Especialidad WHERE descripcion = 'Trekking')
        INSERT INTO personal.Especialidad VALUES ('Trekking');

    EXEC personal.especialidad_asignar @dni = '38555666', @especialidad = 'Trekking';
    
    EXEC personal.titulacion_asignar @dni = '38555666', @descripcion = 'Guía de Alta Montaña', @institucion = 'EAAM', @fecha_emision = '2025-05-10';
    PRINT 'Especialidad y Título asignados correctamente mediante desencriptación interna.';
END TRY
BEGIN CATCH
    PRINT 'Error en asignaciones del guía: ' + ERROR_MESSAGE();
END CATCH;
GO


PRINT '=== TEST 8: Modificación y Actualización de Acreditación ===';
BEGIN TRY
    EXEC personal.Guia_modificacion @dni = '38555666', @nombre = 'Juan Ramón', @apellido = 'Gómez';
    
    EXEC personal.acreditacion_actualizar @dni = '38555666', @fecha_vencimiento_acreditacion = '2026-01-01';
    PRINT 'Datos de guía y acreditación actualizados (Acreditación ahora VENCIDA).';
END TRY
BEGIN CATCH
    PRINT 'Error en actualización: ' + ERROR_MESSAGE();
END CATCH;
GO

select * from gestion.Parque
select * from gestion.Tipo_actividad

PRINT '=== TEST 9: Intento de Alta de Actividad con Guía Vencido (Debe Fallar) ===';
BEGIN TRY
    EXEC gestion.actividad_alta 
        @nombre_parque = 'Parque Nacional Iguazu test',
        @dni_guia = '38555666', 
        @nombre = 'Paseo Inferior Guiado', 
        @descripcion = 'Caminata por las pasarelas inferiores', 
        @tipo = 'Atraccion gratuita test  ',
        @costo = 5000.00, 
        @fecha = '2026-08-15', 
        @duracion = 120, 
        @cupo = 20;
END TRY
BEGIN CATCH
    PRINT 'Fallo esperado (Guía no autorizado): ' + CHAR(10) + ERROR_MESSAGE();
END CATCH;
GO


PRINT '=== VERIFICACIÓN FINAL EN TABLAS ===';
SELECT id, 
       CONVERT(CHAR(8), DecryptByPassPhrase('parques_nacionales_2026', dni)) AS DNI_Desencriptado, 
       nombre, apellido, estado 
FROM personal.Guardaparque;

SELECT id, 
       CONVERT(CHAR(8), DecryptByPassPhrase('parques_nacionales_2026', dni)) AS DNI_Desencriptado, 
       nombre, apellido, estado 
FROM personal.Guia;
GO
*/
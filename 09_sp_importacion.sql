-- Universidad: Universidad de la Matanza
-- Materia: 3641 - Bases de Datos Aplicadas

-- Grupo 04
-- Integrantes:
--  De Bellis, Nahuel
--  Ocampo, Julian Rafael
--  Rodriguez, Gonzalo Ezequiel
--  Vargas, Tomas

-- Objetivo del script: Creacion de store procedure de importacion

-- Fecha: 15/06/2026

USE parques_nacionales
GO


-----------------------------------------------------------
-- Importar guias de un csv

-- Descargar archivo desde "https://datosabiertos.mendoza.gov.ar/dataset/profesionales-de-turismo/archivo/dc306ca1-f657-4f97-8b55-bfb9978366c1"

CREATE OR ALTER PROCEDURE gestion.importar_guias
@archivo_dir VARCHAR(70)
AS
BEGIN
    DECLARE @error VARCHAR(80);
    SET @error = '';

    CREATE TABLE #TempImport (
        nombre_y_apellido VARCHAR(50),
        domicilio VARCHAR(60),
        localidad  VARCHAR(70),
        telefono VARCHAR(30),
        titulo VARCHAR(80),
        idiomas VARCHAR(40),
        dpt VARCHAR(10),
        resolucion_inscripcion VARCHAR(10),
    );

    BEGIN TRY
        DECLARE @importar_csv NVARCHAR(200);
        DECLARE @id_max INT;
        DECLARE @id_act INT;
        
        SET @importar_csv = ' BULK INSERT #TempImport FROM ''' + @archivo_dir + ''' WITH (FIRSTROW = 2, 
        FIELDTERMINATOR = '';'', ROWTERMINATOR = ''0x0d0a'', CODEPAGE = ''1252'')'

        EXEC sp_executesql @importar_csv;

        DELETE #TempImport WHERE dpt NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]';
        DELETE #TempImport WHERE dpt IS NULL;
        DELETE #TempImport WHERE CHARINDEX(',', nombre_y_apellido) = 0;

        ALTER TABLE #TempImport ADD id INT IDENTITY(1,1) NOT NULL;

        SET @id_max =  (SELECT MAX(id) from #TempImport);
        SET @id_act = 1;
        
        DECLARE @apellido VARCHAR(50), @nombre VARCHAR(50), @dni CHAR(8), @titulo VARCHAR(80), @fecha_random DATE, @institucion VARCHAR(30);

        WHILE @id_act <= @id_max
        BEGIN
            SELECT @apellido =  LEFT(nombre_y_apellido, (CHARINDEX(',', nombre_y_apellido) - 1)),
                   @nombre = LTRIM(SUBSTRING(nombre_y_apellido, (CHARINDEX(',', nombre_y_apellido) + 1), LEN(nombre_y_apellido))), 
                   @dni = dpt, 
                   @titulo = titulo 
                   FROM #TempImport WHERE id = @id_act;
            SET @fecha_random = DATEADD( DAY, ABS(CHECKSUM(NEWID())) % (DATEDIFF(DAY, '2020-01-01', '2030-12-31') + 1), '2020-01-01');

            BEGIN TRY
                EXEC gestion.guia_alta
                    @dni = @dni,
                    @nombre = @nombre,
                    @apellido = @apellido,
                    @fecha_vencimiento_acreditacion = @fecha_random;
            END TRY
            BEGIN CATCH
                EXEC gestion.guia_actualizar
                    @dni = @dni,
                    @nombre = @nombre,
                    @apellido = @apellido;

                EXEC guia.acreditacion_actualizar
                    @dni = @dni,
                    @fecha_vencimiento_acreditacion = @fecha_random;
            END CATCH

            SET @fecha_random = DATEADD( DAY, ABS(CHECKSUM(NEWID())) % (DATEDIFF(DAY, '2000-01-01', '2026-03-31') + 1), '2000-01-01');
            SET @institucion =  case cast(FLOOR(rand() * 3) as int) when 0 then 'UNLAM' when 1 then 'UBA' ELSE 'UTN' END;

            BEGIN TRY
                EXEC guia.titulacion_asignar
                    @dni = @dni,
                    @descripcion = @titulo,
                    @institucion = @institucion,
                    @fecha_emision = @fecha_random;
            END TRY
            BEGIN CATCH
                EXEC guia.titulo_actualizar
                    @dni = @dni,
                    @descripcion = @titulo,
                    @institucion = @institucion,
                    @fecha_emision = @fecha_random;
            END CATCH

            SET @id_act += 1;
        END
    END TRY
    BEGIN CATCH
        SET @error += ERROR_MESSAGE() + char(10);
    END CATCH

    DROP TABLE #TempImport;

    IF @error != ''
        RAISERROR(@error, 16, 1);
END
GO

-----------------------------------------------------------
-- Importar provincias de un Json

-- Url de la api: "https://infra.datos.gob.ar/georef-dev/provincias.json"

CREATE OR ALTER PROCEDURE gestion.importar_provincias
AS
BEGIN
    EXEC sp_configure 'show advanced options', 1;	--Este es para poder editar los permisos avanzados.
    RECONFIGURE;
  
    EXEC sp_configure 'Ole Automation Procedures', 1;	-- Aqui habilitamos esta opcion avanzada
    RECONFIGURE;

    DECLARE @url NVARCHAR(64) = 'https://infra.datos.gob.ar/georef-dev/provincias.json'

    DECLARE @Object INT
    DECLARE @json TABLE(DATA NVARCHAR(MAX))
    DECLARE @respuesta NVARCHAR(MAX)

    EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT
    EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET', @url, 'FALSE'
    EXEC sp_OAMethod @Object, 'SEND'
    EXEC sp_OAMethod @Object, 'RESPONSETEXT', @respuesta OUTPUT , @json OUTPUT
    INSERT INTO @json EXEC sp_OAGetProperty @Object, 'RESPONSETEXT'
    
    DECLARE @jsonProv NVARCHAR(MAX) = (SELECT DATA FROM @json)

    CREATE TABLE #TempImport (
        id INT IDENTITY(1, 1) PRIMARY KEY,
        provincia  VARCHAR(50),
    );

    INSERT INTO #TempImport SELECT nombre FROM OpenJson(@jsonProv) WITH (
        provincias NVARCHAR(MAX) '$.provincias' AS JSON
    ) CROSS APPLY OpenJson(provincias) WITH (
        nombre VARCHAR(50) '$.nombre'
    )
    DECLARE @id_max INT;
    DECLARE @id_act INT;
    SET @id_max =  (SELECT MAX(id) from #TempImport);
    SET @id_act = 1;
        
    DECLARE @provincia VARCHAR(50);

    WHILE @id_act <= @id_max
    BEGIN
        SELECT @provincia = provincia FROM #TempImport WHERE id = @id_act;
        BEGIN TRY
            EXEC gestion.ubicacion_alta @provincia
        END TRY
        BEGIN CATCH
        END CATCH

        SET @id_act += 1;
    END

    DROP TABLE #TempImport
END
GO

-----------------------------------------------------------
-- Importar parques de un csv

-- Descargar archivo desde "https://sib.gob.ar/areas-protegidas"

CREATE OR ALTER PROCEDURE gestion.importar_parques
    @archivo_dir VARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;
 
    DECLARE @error VARCHAR(500) = '';
    DECLARE @sql VARCHAR(MAX);
    DECLARE @consulta VARCHAR(320);
    DECLARE @archivo_existe VARCHAR(5);
    DECLARE @tabla_archivo TABLE (linea VARCHAR(5));
 
    EXEC sp_configure 'show advanced options', 1;
    RECONFIGURE;

    EXEC sp_configure 'xp_cmdshell', 1;
    RECONFIGURE;
 
    SET @consulta = 'IF EXIST "' + @archivo_dir + '" (ECHO True) ELSE (ECHO False)';
    INSERT INTO @tabla_archivo EXEC xp_cmdshell @consulta;
    SET @archivo_existe = (SELECT TOP 1 linea FROM @tabla_archivo WHERE linea IS NOT NULL);
 
    IF @archivo_existe = 'False'
        THROW 50001, 'El archivo no existe o no se encuentra en la ruta indicada.', 1;
 
    CREATE TABLE #temp_csv (
        provincia VARCHAR(50),
        nombre VARCHAR(200),
        anio VARCHAR(5),
        region VARCHAR(250),
        superficie VARCHAR(20),
        latitud VARCHAR(10),
        longitud VARCHAR(10),
        ley VARCHAR(250),
        ecorregiones VARCHAR(250),
        categoria_intern VARCHAR(250),
        especies VARCHAR(20),
        animales VARCHAR(20),
        bacterias VARCHAR(20),
        hongos VARCHAR(20),
        plantas VARCHAR(20)
    );
 
    BEGIN TRY
        SET @sql =
            'BULK INSERT #temp_csv
             FROM ''' + @archivo_dir + '''
             WITH (
                FORMAT = ''CSV'',
                FIRSTROW = 3,
                FIELDTERMINATOR = '','',
                FIELDQUOTE = ''"'',
                ROWTERMINATOR = ''\n'',
                CODEPAGE = ''1252''
             );';
        EXEC (@sql);
    END TRY
    BEGIN CATCH
        SET @error = 'Error en BULK INSERT: ' + ERROR_MESSAGE();
        RAISERROR(@error, 16, 1);
        RETURN;
    END CATCH
 
    CREATE TABLE #errores (
        nombre VARCHAR(200),
        provincia VARCHAR(100),
        motivo VARCHAR(300)
    );
 
    INSERT INTO #errores (nombre, provincia, motivo)
    SELECT nombre, provincia, 'Nombre nulo o vacío'
    FROM #temp_csv
    WHERE LTRIM(RTRIM(ISNULL(nombre, ''))) = '';
 
    INSERT INTO #errores (nombre, provincia, motivo)
    SELECT nombre, provincia, 'Superficie nula, vacía o no positiva'
    FROM #temp_csv
    WHERE LTRIM(RTRIM(ISNULL(nombre, ''))) != ''
      AND (
            TRY_CAST(superficie AS FLOAT) IS NULL
         OR TRY_CAST(superficie AS FLOAT) <= 0
          );
 
    INSERT INTO #errores (nombre, provincia, motivo)
    SELECT nombre, provincia, 'Tipo de área protegida no reconocido según el nombre'
    FROM #temp_csv
    WHERE LTRIM(RTRIM(ISNULL(nombre, ''))) != ''
      AND nombre NOT LIKE 'Parque Nacional%'
      AND nombre NOT LIKE 'Parque Interjurisdiccional Marino Costero%'
      AND nombre NOT LIKE 'Parque Interjurisdiccional Marino%'
      AND nombre NOT LIKE 'Área Marina Protegida%'
      AND nombre NOT LIKE 'Area Marina Protegida%'
      AND nombre NOT LIKE 'Reserva Natural Silvestre%'
      AND nombre NOT LIKE 'Reserva Natural Educativa%'
      AND nombre NOT LIKE 'Reserva Natural Estricta%'
      AND nombre NOT LIKE 'Reserva Natural%'
      AND nombre NOT LIKE 'Reserva Nacional%'
      AND nombre NOT LIKE 'Monumento Natural%';
 
    CREATE TABLE #temp_parques (
        id INT IDENTITY(1,1) PRIMARY KEY,
        nombre NVARCHAR(200),
        ubicacion NVARCHAR(100),
        superficie INT,
        tipo VARCHAR(50)
    );

    INSERT INTO #temp_parques (nombre, ubicacion, superficie, tipo)
    SELECT
        LTRIM(RTRIM(nombre)),
        CASE LTRIM(RTRIM(provincia))
            WHEN 'Tierra Del Fuego' THEN 'Tierra del Fuego, Antártida e Islas del Atlántico Sur'
            ELSE NULLIF(LTRIM(RTRIM(provincia)), '')
        END,
        TRY_CAST(TRY_CAST(superficie AS FLOAT) AS INT),
        CASE
            WHEN nombre LIKE 'Parque Nacional%' THEN 'Parque nacional'
            WHEN nombre LIKE 'Parque Interjurisdiccional Marino Costero%' THEN 'Parque interjurisdiccional marino costero'
            WHEN nombre LIKE 'Parque Interjurisdiccional Marino%' THEN 'Parque interjurisdiccional marino'
            WHEN nombre LIKE 'Área Marina Protegida%'
              OR nombre LIKE 'Area Marina Protegida%' THEN 'Area marina protegida'
            WHEN nombre LIKE 'Reserva Natural Silvestre%' THEN 'Reserva natural silvestre'
            WHEN nombre LIKE 'Reserva Natural Educativa%' THEN 'Reserva natural educativa'
            WHEN nombre LIKE 'Reserva Natural Estricta%' THEN 'Reserva natural estricta'
            WHEN nombre LIKE 'Reserva Natural%' THEN 'Reserva natural'
            WHEN nombre LIKE 'Reserva Nacional%' THEN 'Reserva nacional'
            WHEN nombre LIKE 'Monumento Natural%' THEN 'Monumento natural'
        END
    FROM #temp_csv
    WHERE nombre NOT IN (SELECT ISNULL(nombre, '') FROM #errores)
      AND TRY_CAST(TRY_CAST(superficie AS FLOAT) AS INT) > 0;

    DECLARE @id_max INT = (SELECT MAX(id) FROM #temp_parques);
    DECLARE @id_act INT = 1;
    DECLARE @c_nombre NVARCHAR(200);
    DECLARE @c_ubicacion NVARCHAR(100);
    DECLARE @c_superficie INT;
    DECLARE @c_tipo VARCHAR(50);
    DECLARE @id_existente INT;

    WHILE @id_act <= @id_max
    BEGIN
        SET @id_existente = NULL;

        SELECT @c_nombre = nombre, @c_ubicacion = ubicacion, @c_superficie = superficie, @c_tipo = tipo
        FROM #temp_parques WHERE id = @id_act;

        SELECT @id_existente = id FROM gestion.Parque WHERE nombre = @c_nombre;

        IF @id_existente IS NULL
        BEGIN
            BEGIN TRY
                EXEC gestion.sp_registrar_parque
                    @nombre = @c_nombre,
                    @tipo = @c_tipo,
                    @ubicacion = @c_ubicacion,
                    @superficie = @c_superficie;
            END TRY
            BEGIN CATCH
                INSERT INTO #errores (nombre, provincia, motivo)
                VALUES (@c_nombre, @c_ubicacion, 'Error al registrar: ' + ERROR_MESSAGE());
            END CATCH
        END
        ELSE
        BEGIN
            BEGIN TRY
                EXEC gestion.sp_modificar_parque
                    @id = @id_existente,
                    @nombre = @c_nombre,
                    @tipo = @c_tipo,
                    @ubicacion = @c_ubicacion,
                    @superficie = @c_superficie;
            END TRY
            BEGIN CATCH
                INSERT INTO #errores (nombre, provincia, motivo)
                VALUES (@c_nombre, @c_ubicacion, 'Error al modificar: ' + ERROR_MESSAGE());
            END CATCH
        END
        SET @id_act += 1;
    END
 
    IF EXISTS (SELECT 1 FROM #errores)
    BEGIN
        PRINT 'Se encontraron errores de validación:';
        SELECT nombre, provincia, motivo FROM #errores ORDER BY motivo, nombre;
    END
    ELSE
        PRINT 'Importación completada sin errores de validación.';
 
    SELECT COUNT(*) AS filas_en_csv FROM #temp_csv;
    SELECT COUNT(*) AS filas_con_errores FROM #errores;
    SELECT COUNT(*) AS filas_validas FROM #temp_parques
 
    EXEC sp_configure 'xp_cmdshell', 0;
    RECONFIGURE;

    EXEC sp_configure 'show advanced options', 0;
    RECONFIGURE;

    DROP TABLE #temp_csv;
    DROP TABLE #errores;
    DROP TABLE #temp_parques;
END
GO
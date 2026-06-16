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

CREATE OR ALTER PROCEDURE gestion.sp_importar_guias
@archivo_dir varchar(70)
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
    
    EXEC sp_configure 'xp_cmdshell', 1; 
    RECONFIGURE;

    BEGIN TRY
        DECLARE @archivo_existe VARCHAR(5);
        DECLARE @importar_csv VARCHAR(150);
        DECLARE @id_max INT;
        DECLARE @id_act INT;
        DECLARE @tabla_archivo TABLE (archivo_existe VARCHAR(5));
        DECLARE @consulta varchar(150);
        SET @consulta = 'IF EXIST "' + @archivo_dir + '" (ECHO True) ELSE (ECHO False)';

        INSERT INTO @tabla_archivo EXEC xp_cmdshell @consulta
        SET @archivo_existe = (SELECT archivo_existe FROM @tabla_archivo WHERE archivo_existe IS NOT NULL)
        IF @archivo_existe = 'False'
            THROW 50001, 'El archivo no existe o no se encuentra en esa ubicacion.', 1;
        
        SET @importar_csv = ' BULK INSERT #TempImport FROM ''' + @archivo_dir + ''' WITH (FIRSTROW = 2, 
        FIELDTERMINATOR = '';'', ROWTERMINATOR = ''0x0d0a'', CODEPAGE = ''1252'')'

        EXEC (@importar_csv);

        CREATE TABLE #TempGuia (
            id INT IDENTITY(1,1) PRIMARY KEY,
            apellido VARCHAR(50),
            nombre VARCHAR(50),
            titulo VARCHAR(80),
            dni CHAR(8)
        );

        INSERT INTO #TempGuia SELECT LEFT(nombre_y_apellido, (CHARINDEX(',', nombre_y_apellido) - 1)) apellido,
                                LTRIM(SUBSTRING(nombre_y_apellido, (CHARINDEX(',', nombre_y_apellido) + 1), LEN(nombre_y_apellido))) nombre,
                                LTRIM(titulo) titulo,
                                dpt dni
                                from #TempImport 
                                where nombre_y_apellido != 'DISPONIBLE' and CHARINDEX(',', nombre_y_apellido) != 0  
                                and dpt LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        SET @id_max =  (SELECT MAX(id) from #TempGuia);
        SET @id_act = 1;
        
        DECLARE @apellido VARCHAR(50), @nombre VARCHAR(50), @dni CHAR(8), @titulo VARCHAR(80), @fecha_random DATE, @institucion VARCHAR(30);

        WHILE @id_act <= @id_max
        BEGIN
            SELECT @apellido = apellido, @nombre = nombre, @dni = dni, @titulo = titulo FROM #TempGuia WHERE id = @id_act;
            SET @fecha_random = DATEADD( DAY, ABS(CHECKSUM(NEWID())) % (DATEDIFF(DAY, '2020-01-01', '2030-12-31') + 1), '2020-01-01');

            BEGIN TRY
                EXEC gestion.sp_registrar_guia
                    @dni = @dni,
                    @nombre = @nombre,
                    @apellido = @apellido,
                    @fecha_vencimiento_acreditacion = @fecha_random;
            END TRY
            BEGIN CATCH
                EXEC gestion.sp_actualizar_guia
                    @dni = @dni,
                    @nombre = @nombre,
                    @apellido = @apellido;

                EXEC guia.sp_actualizar_acreditacion
                    @dni = @dni,
                    @fecha_vencimiento_acreditacion = @fecha_random;
            END CATCH

            SET @fecha_random = DATEADD( DAY, ABS(CHECKSUM(NEWID())) % (DATEDIFF(DAY, '2000-01-01', '2026-03-31') + 1), '2000-01-01');
            SET @institucion =  case cast(FLOOR(rand() * 3) as int) when 0 then 'UNLAM' when 1 then 'UBA' ELSE 'UTN' END;

            BEGIN TRY
                EXEC guia.sp_asignar_titulacion_guia
                    @dni = @dni,
                    @descripcion = @titulo,
                    @institucion = @institucion,
                    @fecha_emision = @fecha_random;
            END TRY
            BEGIN CATCH
                EXEC guia.sp_actualizar_titulo_guia
                    @dni = @dni,
                    @descripcion = @titulo,
                    @institucion = @institucion,
                    @fecha_emision = @fecha_random;
            END CATCH

            SET @id_act += 1;
        END

        DROP TABLE #TempGuia;
    END TRY
    BEGIN CATCH
        SET @error += ERROR_MESSAGE() + char(10);
    END CATCH

    EXEC sp_configure 'xp_cmdshell', 0; 
    RECONFIGURE;

    DROP TABLE #TempImport;

    IF @error != ''
        RAISERROR(@error, 16, 1);
END
GO

-----------------------------------------------------------
-- Importar provincias de un Json

CREATE OR ALTER PROCEDURE gestion.sp_importar_provincias
AS
BEGIN
    DECLARE @jsonProv NVARCHAR(MAX);

    SET @jsonProv = N'{"cantidad":24,"total":24,"inicio":0,"parametros":{},"provincias":[{"id":"02","nombre":"Ciudad Autónoma de Buenos Aires","nombre_completo":"Ciudad Autónoma de Buenos Aires","fuente":"IGN","categoria":"Ciudad Autónoma","centroide":{"lon":-58.445876325,"lat":-34.614442065},"iso_id":"AR-C","iso_nombre":"Ciudad Autónoma de Buenos Aires"},{"id":"58","nombre":"Neuquén","nombre_completo":"Provincia del Neuquén","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-70.119897224,"lat":-38.641982863},"iso_id":"AR-Q","iso_nombre":"Neuquén"},{"id":"74","nombre":"San Luis","nombre_completo":"Provincia de San Luis","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-66.025231271,"lat":-33.761103538},"iso_id":"AR-D","iso_nombre":"San Luis"},{"id":"82","nombre":"Santa Fe","nombre_completo":"Provincia de Santa Fe","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-60.950687277,"lat":-30.708822709},"iso_id":"AR-S","iso_nombre":"Santa Fe"},{"id":"46","nombre":"La Rioja","nombre_completo":"Provincia de La Rioja","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-67.181757581,"lat":-29.684937278},"iso_id":"AR-F","iso_nombre":"La Rioja"},{"id":"10","nombre":"Catamarca","nombre_completo":"Provincia de Catamarca","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-66.947897245,"lat":-27.335953796},"iso_id":"AR-K","iso_nombre":"Catamarca"},{"id":"90","nombre":"Tucumán","nombre_completo":"Provincia de Tucumán","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-65.36476558,"lat":-26.948283502},"iso_id":"AR-T","iso_nombre":"Tucumán"},{"id":"22","nombre":"Chaco","nombre_completo":"Provincia del Chaco","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-60.76511626,"lat":-26.386987184},"iso_id":"AR-H","iso_nombre":"Chaco"},{"id":"34","nombre":"Formosa","nombre_completo":"Provincia de Formosa","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-59.932190112,"lat":-24.895087176},"iso_id":"AR-P","iso_nombre":"Formosa"},{"id":"78","nombre":"Santa Cruz","nombre_completo":"Provincia de Santa Cruz","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-69.955761914,"lat":-48.815547183},"iso_id":"AR-Z","iso_nombre":"Santa Cruz"},{"id":"26","nombre":"Chubut","nombre_completo":"Provincia del Chubut","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-68.526736334,"lat":-43.788627139},"iso_id":"AR-U","iso_nombre":"Chubut"},{"id":"50","nombre":"Mendoza","nombre_completo":"Provincia de Mendoza","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-68.582945602,"lat":-34.630388707},"iso_id":"AR-M","iso_nombre":"Mendoza"},{"id":"30","nombre":"Entre Ríos","nombre_completo":"Provincia de Entre Ríos","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-59.201262616,"lat":-32.058927894},"iso_id":"AR-E","iso_nombre":"Entre Ríos"},{"id":"70","nombre":"San Juan","nombre_completo":"Provincia de San Juan","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-68.888159707,"lat":-30.865660702},"iso_id":"AR-J","iso_nombre":"San Juan"},{"id":"38","nombre":"Jujuy","nombre_completo":"Provincia de Jujuy","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-65.764423919,"lat":-23.319975062},"iso_id":"AR-Y","iso_nombre":"Jujuy"},{"id":"86","nombre":"Santiago del Estero","nombre_completo":"Provincia de Santiago del Estero","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-63.252626886,"lat":-27.783431882},"iso_id":"AR-G","iso_nombre":"Santiago del Estero"},{"id":"62","nombre":"Río Negro","nombre_completo":"Provincia de Río Negro","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-67.2296758,"lat":-40.405079631},"iso_id":"AR-R","iso_nombre":"Río Negro"},{"id":"18","nombre":"Corrientes","nombre_completo":"Provincia de Corrientes","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-57.80108186,"lat":-28.774204481},"iso_id":"AR-W","iso_nombre":"Corrientes"},{"id":"54","nombre":"Misiones","nombre_completo":"Provincia de Misiones","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-54.651570563,"lat":-26.875302599},"iso_id":"AR-N","iso_nombre":"Misiones"},{"id":"66","nombre":"Salta","nombre_completo":"Provincia de Salta","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-64.814158657,"lat":-24.299283896},"iso_id":"AR-A","iso_nombre":"Salta"},{"id":"14","nombre":"Córdoba","nombre_completo":"Provincia de Córdoba","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-63.801973467,"lat":-32.144799387},"iso_id":"AR-X","iso_nombre":"Córdoba"},{"id":"06","nombre":"Buenos Aires","nombre_completo":"Provincia de Buenos Aires","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-60.558477108,"lat":-36.677392076},"iso_id":"AR-B","iso_nombre":"Buenos Aires"},{"id":"42","nombre":"La Pampa","nombre_completo":"Provincia de La Pampa","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-65.447643999,"lat":-37.135065221},"iso_id":"AR-L","iso_nombre":"La Pampa"},{"id":"94","nombre":"Tierra del Fuego, Antártida e Islas del Atlántico Sur","nombre_completo":"Provincia de Tierra del Fuego, Antártida e Islas del Atlántico Sur","fuente":"IGN","categoria":"Provincia","centroide":{"lon":-50.742860676,"lat":-82.521134521},"iso_id":"AR-V","iso_nombre":"Tierra del Fuego"}]}';

    INSERT INTO gestion.Ubicacion SELECT nombre FROM OpenJson(@jsonProv) WITH (
        provincias NVARCHAR(MAX) '$.provincias' AS JSON
    ) CROSS APPLY OpenJson(provincias) WITH (
        nombre VARCHAR(50) '$.nombre'
    )
END
GO

-----------------------------------------------------------
-- Importar parques de un csv

CREATE OR ALTER PROCEDURE gestion.sp_importar_parques
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
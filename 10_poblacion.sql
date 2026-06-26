-- Universidad: Universidad de la Matanza
-- Materia: 3641 - Bases de Datos Aplicadas

-- Grupo 06
-- Integrantes:
--  De Bellis, Nahuel
--  Ocampo, Julian Rafael
--  Rodriguez, Gonzalo Ezequiel
--  Vargas, Tomas

-- Objetivo del script: Carga inicial de datos respetando foreign keys

-- Requisitos previos:
--  1. Ejecutar 01_create_db_scheme.sql
--  2. Ejecutar 02_create_tables.sql
--  3. Ejecutar 03_sp_abm.sql
--  4. Ejecutar 05_sp.sql
--  5. Ejecutar 07_creacion_views.sql para ventas.sp_alta_tipo_entrada y ventas.sp_alta_item_venta

USE parques_nacionales;
GO

SET NOCOUNT ON;
GO

-----------------------------------------------------------
-- 1. Catalogos base sin dependencias
-----------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM gestion.Ubicacion WHERE provincia = 'Misiones')
    EXEC gestion.ubicacion_alta 'Misiones';

IF NOT EXISTS (SELECT 1 FROM gestion.Ubicacion WHERE provincia = 'Santa Cruz')
    EXEC gestion.ubicacion_alta 'Santa Cruz';

IF NOT EXISTS (SELECT 1 FROM gestion.Ubicacion WHERE provincia = 'Neuquén')
    EXEC gestion.ubicacion_alta 'Neuquén';

IF NOT EXISTS (SELECT 1 FROM gestion.Ubicacion WHERE provincia = 'Río Negro')
    EXEC gestion.ubicacion_alta 'Río Negro';
GO

IF NOT EXISTS (SELECT 1 FROM gestion.Tipo_actividad WHERE descripcion = 'Senderismo')
    EXEC gestion.tipo_actividad_alta @descripcion = 'Senderismo';

IF NOT EXISTS (SELECT 1 FROM gestion.Tipo_actividad WHERE descripcion = 'Navegacion')
    EXEC gestion.tipo_actividad_alta @descripcion = 'Navegacion';

IF NOT EXISTS (SELECT 1 FROM gestion.Tipo_actividad WHERE descripcion = 'Avistaje')
    EXEC gestion.tipo_actividad_alta @descripcion = 'Avistaje';
GO

IF NOT EXISTS (SELECT 1 FROM guia.Especialidad WHERE descripcion = 'Flora autoctona')
    EXEC guia.especialidad_alta @descripcion = 'Flora autoctona';

IF NOT EXISTS (SELECT 1 FROM guia.Especialidad WHERE descripcion = 'Fauna silvestre')
    EXEC guia.especialidad_alta @descripcion = 'Fauna silvestre';

IF NOT EXISTS (SELECT 1 FROM guia.Especialidad WHERE descripcion = 'Alta montana')
    EXEC guia.especialidad_alta @descripcion = 'Alta montana';
GO

IF NOT EXISTS (SELECT 1 FROM ventas.tipo_visitante WHERE descripcion = 'Adulto')
    EXEC ventas.tipo_visitante_alta @descripcion = 'Adulto';

IF NOT EXISTS (SELECT 1 FROM ventas.tipo_visitante WHERE descripcion = 'Menor')
    EXEC ventas.tipo_visitante_alta @descripcion = 'Menor';

IF NOT EXISTS (SELECT 1 FROM ventas.tipo_visitante WHERE descripcion = 'Jubilado')
    EXEC ventas.tipo_visitante_alta @descripcion = 'Jubilado';

IF NOT EXISTS (SELECT 1 FROM ventas.tipo_visitante WHERE descripcion = 'Extranjero')
    EXEC ventas.tipo_visitante_alta @descripcion = 'Extranjero';
GO

IF NOT EXISTS (SELECT 1 FROM ventas.metodo_de_pago WHERE descripcion = 'Efectivo')
    EXEC ventas.metodo_de_pago_alta @descripcion = 'Efectivo';

IF NOT EXISTS (SELECT 1 FROM ventas.metodo_de_pago WHERE descripcion = 'Debito')
    EXEC ventas.metodo_de_pago_alta @descripcion = 'Debito';

IF NOT EXISTS (SELECT 1 FROM ventas.metodo_de_pago WHERE descripcion = 'Credito')
    EXEC ventas.metodo_de_pago_alta @descripcion = 'Credito';
GO

-----------------------------------------------------------
-- 2. Entidades maestras
-----------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM gestion.Parque WHERE nombre = 'Parque Nacional Iguazú')
    EXEC gestion.parque_alta
        @nombre = 'Parque Nacional Iguazú',
        @tipo = 'Parque nacional',
        @ubicacion = 'Misiones',
        @superficie = 67720;

IF NOT EXISTS (SELECT 1 FROM gestion.Parque WHERE nombre = 'Parque Nacional Los Glaciares')
    EXEC gestion.parque_alta
        @nombre = 'Parque Nacional Los Glaciares',
        @tipo = 'Parque nacional',
        @ubicacion = 'Santa Cruz',
        @superficie = 726927;

IF NOT EXISTS (SELECT 1 FROM gestion.Parque WHERE nombre = 'Parque Nacional Nahuel Huapi')
    EXEC gestion.parque_alta
        @nombre = 'Parque Nacional Nahuel Huapi',
        @tipo = 'Parque nacional',
        @ubicacion = 'Río Negro',
        @superficie = 717261;
GO

IF NOT EXISTS (SELECT 1 FROM gestion.Guardaparque WHERE dni = 30111222)
    EXEC gestion.guardaparque_alta @dni = 30111222, @nombre = 'Martin', @apellido = 'Perez';

IF NOT EXISTS (SELECT 1 FROM gestion.Guardaparque WHERE dni = 28444555)
    EXEC gestion.guardaparque_alta @dni = 28444555, @nombre = 'Laura', @apellido = 'Gomez';

IF NOT EXISTS (SELECT 1 FROM gestion.Guardaparque WHERE dni = 32666777)
    EXEC gestion.guardaparque_alta @dni = 32666777, @nombre = 'Sofia', @apellido = 'Romero';
GO

IF NOT EXISTS (SELECT 1 FROM gestion.Guia WHERE dni = '35111222')
    EXEC gestion.guia_alta
        @dni = '35111222',
        @nombre = 'Ana',
        @apellido = 'Lopez',
        @fecha_vencimiento_acreditacion = '2028-12-31';

IF NOT EXISTS (SELECT 1 FROM gestion.Guia WHERE dni = '36222333')
    EXEC gestion.guia_alta
        @dni = '36222333',
        @nombre = 'Carlos',
        @apellido = 'Mendez',
        @fecha_vencimiento_acreditacion = '2029-06-30';

IF NOT EXISTS (SELECT 1 FROM gestion.Guia WHERE dni = '37333444')
    EXEC gestion.guia_alta
        @dni = '37333444',
        @nombre = 'Valeria',
        @apellido = 'Suarez',
        @fecha_vencimiento_acreditacion = '2028-03-15';
GO

IF NOT EXISTS (SELECT 1 FROM concesiones.Empresa WHERE nombre = 'EcoTur')
    EXEC concesiones.empresa_alta @nombre = 'EcoTur', @tipo = 'Servicios turisticos', @cuit = '30712345678';

IF NOT EXISTS (SELECT 1 FROM concesiones.Empresa WHERE nombre = 'Patagonia Viajes')
    EXEC concesiones.empresa_alta @nombre = 'Patagonia Viajes', @tipo = 'Transporte turistico', @cuit = '30622345678';

IF NOT EXISTS (SELECT 1 FROM concesiones.Empresa WHERE nombre = 'Selva Aventura')
    EXEC concesiones.empresa_alta @nombre = 'Selva Aventura', @tipo = 'Excursiones', @cuit = '33732345678';
GO

-----------------------------------------------------------
-- 3. Relaciones directas sobre maestras
-----------------------------------------------------------

DECLARE @id_iguazu INT = (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Iguazú');
DECLARE @id_glaciares INT = (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Los Glaciares');
DECLARE @id_nahuel INT = (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Nahuel Huapi');

DECLARE @id_gp_martin INT = (SELECT id FROM gestion.Guardaparque WHERE dni = 30111222);
DECLARE @id_gp_laura INT = (SELECT id FROM gestion.Guardaparque WHERE dni = 28444555);
DECLARE @id_gp_sofia INT = (SELECT id FROM gestion.Guardaparque WHERE dni = 32666777);

IF NOT EXISTS (SELECT 1 FROM gestion.Parque_asignado WHERE id_parque = @id_iguazu AND id_guardaparque = @id_gp_martin AND fecha_egreso IS NULL)
    EXEC gestion.guardaparque_asignar @id_parque = @id_iguazu, @id_guardaparque = @id_gp_martin;

IF NOT EXISTS (SELECT 1 FROM gestion.Parque_asignado WHERE id_parque = @id_glaciares AND id_guardaparque = @id_gp_laura AND fecha_egreso IS NULL)
    EXEC gestion.guardaparque_asignar @id_parque = @id_glaciares, @id_guardaparque = @id_gp_laura;

IF NOT EXISTS (SELECT 1 FROM gestion.Parque_asignado WHERE id_parque = @id_nahuel AND id_guardaparque = @id_gp_sofia AND fecha_egreso IS NULL)
    EXEC gestion.guardaparque_asignar @id_parque = @id_nahuel, @id_guardaparque = @id_gp_sofia;
GO

IF NOT EXISTS (
    SELECT 1
    FROM guia.Titulo t
    INNER JOIN guia.Titulacion_guia tg ON tg.id_titulo = t.id
    INNER JOIN gestion.Guia g ON g.id = tg.id_guia
    WHERE g.dni = '35111222' AND t.descripcion = 'Guia de turismo'
)
    EXEC guia.titulacion_asignar
        @dni = '35111222',
        @descripcion = 'Guia de turismo',
        @institucion = 'UNLAM',
        @fecha_emision = '2021-11-20';

IF NOT EXISTS (
    SELECT 1
    FROM guia.Titulo t
    INNER JOIN guia.Titulacion_guia tg ON tg.id_titulo = t.id
    INNER JOIN gestion.Guia g ON g.id = tg.id_guia
    WHERE g.dni = '36222333' AND t.descripcion = 'Tecnico en turismo'
)
    EXEC guia.titulacion_asignar
        @dni = '36222333',
        @descripcion = 'Tecnico en turismo',
        @institucion = 'UBA',
        @fecha_emision = '2020-08-10';

IF NOT EXISTS (SELECT 1 FROM guia.Especializado_en ee INNER JOIN gestion.Guia g ON g.id = ee.id_guia INNER JOIN guia.Especialidad e ON e.id = ee.id_especialidad WHERE g.dni = '35111222' AND e.descripcion = 'Flora autoctona')
    EXEC guia.especialidad_asignar @dni = '35111222', @especialidad = 'Flora autoctona';

IF NOT EXISTS (SELECT 1 FROM guia.Especializado_en ee INNER JOIN gestion.Guia g ON g.id = ee.id_guia INNER JOIN guia.Especialidad e ON e.id = ee.id_especialidad WHERE g.dni = '36222333' AND e.descripcion = 'Alta montana')
    EXEC guia.especialidad_asignar @dni = '36222333', @especialidad = 'Alta montana';

IF NOT EXISTS (SELECT 1 FROM guia.Especializado_en ee INNER JOIN gestion.Guia g ON g.id = ee.id_guia INNER JOIN guia.Especialidad e ON e.id = ee.id_especialidad WHERE g.dni = '37333444' AND e.descripcion = 'Fauna silvestre')
    EXEC guia.especialidad_asignar @dni = '37333444', @especialidad = 'Fauna silvestre';
GO

-----------------------------------------------------------
-- 4. Actividades
-----------------------------------------------------------

DECLARE @id_iguazu INT = (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Iguazú');
DECLARE @id_glaciares INT = (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Los Glaciares');
DECLARE @id_nahuel INT = (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Nahuel Huapi');

DECLARE @id_guia_ana INT = (SELECT id FROM gestion.Guia WHERE dni = '35111222');
DECLARE @id_guia_carlos INT = (SELECT id FROM gestion.Guia WHERE dni = '36222333');
DECLARE @id_guia_valeria INT = (SELECT id FROM gestion.Guia WHERE dni = '37333444');

IF NOT EXISTS (SELECT 1 FROM gestion.Actividad WHERE nombre = 'Circuito Garganta del Diablo' AND id_parque = @id_iguazu)
    EXEC gestion.actividad_alta
        @id_parque = @id_iguazu,
        @id_guia = @id_guia_ana,
        @nombre = 'Circuito Garganta del Diablo',
        @descripcion = 'Recorrido por pasarelas principales',
        @tipo = 'Senderismo',
        @costo = 12000.00,
        @fecha = '2026-10-15',
        @duracion = 180,
        @cupo = 30;

IF NOT EXISTS (SELECT 1 FROM gestion.Actividad WHERE nombre = 'Navegacion Lago Argentino' AND id_parque = @id_glaciares)
    EXEC gestion.actividad_alta
        @id_parque = @id_glaciares,
        @id_guia = @id_guia_carlos,
        @nombre = 'Navegacion Lago Argentino',
        @descripcion = 'Excursion nautica frente a glaciares',
        @tipo = 'Navegacion',
        @costo = 35000.00,
        @fecha = '2026-11-20',
        @duracion = 240,
        @cupo = 40;

IF NOT EXISTS (SELECT 1 FROM gestion.Actividad WHERE nombre = 'Avistaje Bosque Andino' AND id_parque = @id_nahuel)
    EXEC gestion.actividad_alta
        @id_parque = @id_nahuel,
        @id_guia = @id_guia_valeria,
        @nombre = 'Avistaje Bosque Andino',
        @descripcion = 'Observacion de fauna y flora local',
        @tipo = 'Avistaje',
        @costo = 9000.00,
        @fecha = '2026-09-12',
        @duracion = 150,
        @cupo = 20;
GO

DECLARE @id_actividad_iguazu INT = (SELECT id FROM gestion.Actividad WHERE nombre = 'Circuito Garganta del Diablo');
DECLARE @id_actividad_glaciares INT = (SELECT id FROM gestion.Actividad WHERE nombre = 'Navegacion Lago Argentino');
DECLARE @id_guia_ana INT = (SELECT id FROM gestion.Guia WHERE dni = '35111222');
DECLARE @id_guia_carlos INT = (SELECT id FROM gestion.Guia WHERE dni = '36222333');

IF NOT EXISTS (SELECT 1 FROM gestion.Coordina WHERE id_actividad = @id_actividad_iguazu AND id_guia = @id_guia_ana)
    INSERT INTO gestion.Coordina (id_actividad, id_guia, fecha_desde, fecha_hasta)
    VALUES (@id_actividad_iguazu, @id_guia_ana, '2026-10-01', '2026-10-31');

IF NOT EXISTS (SELECT 1 FROM gestion.Coordina WHERE id_actividad = @id_actividad_glaciares AND id_guia = @id_guia_carlos)
    INSERT INTO gestion.Coordina (id_actividad, id_guia, fecha_desde, fecha_hasta)
    VALUES (@id_actividad_glaciares, @id_guia_carlos, '2026-11-01', '2026-11-30');
GO

-----------------------------------------------------------
-- 5. Concesiones y canones
-----------------------------------------------------------

IF NOT EXISTS (
    SELECT 1
    FROM concesiones.Concesion c
    INNER JOIN concesiones.Empresa e ON e.id = c.id_empresa
    INNER JOIN gestion.Parque p ON p.id = c.id_parque
    WHERE e.nombre = 'EcoTur' AND p.nombre = 'Parque Nacional Iguazú' AND c.fecha_inicio = '2026-07-01'
)
    EXEC concesiones.concesion_alta
        @empresa = 'EcoTur',
        @parque = 'Parque Nacional Iguazú',
        @canon_mensual = 250000.00,
        @fecha_inicio = '2026-07-01',
        @actividad = NULL;

IF NOT EXISTS (
    SELECT 1
    FROM concesiones.Concesion c
    INNER JOIN concesiones.Empresa e ON e.id = c.id_empresa
    INNER JOIN gestion.Parque p ON p.id = c.id_parque
    WHERE e.nombre = 'Patagonia Viajes' AND p.nombre = 'Parque Nacional Los Glaciares' AND c.fecha_inicio = '2026-07-01'
)
    EXEC concesiones.concesion_alta
        @empresa = 'Patagonia Viajes',
        @parque = 'Parque Nacional Los Glaciares',
        @canon_mensual = 420000.00,
        @fecha_inicio = '2026-07-01',
        @actividad = NULL;
GO

IF NOT EXISTS (
    SELECT 1
    FROM concesiones.Canon_pagar cp
    INNER JOIN concesiones.Concesion c ON c.id = cp.id_concesion
    INNER JOIN concesiones.Empresa e ON e.id = c.id_empresa
    INNER JOIN gestion.Parque p ON p.id = c.id_parque
    WHERE e.nombre = 'EcoTur' AND p.nombre = 'Parque Nacional Iguazú' AND cp.fecha_generacion = '2026-08-01'
)
    EXEC concesiones.canon_pagar_alta
        @fecha_generacion = '2026-08-01',
        @empresa = 'EcoTur',
        @parque = 'Parque Nacional Iguazú',
        @fecha_inicio = '2026-07-01';


IF NOT EXISTS (
    SELECT 1
    FROM concesiones.Canon_pagar cp
    INNER JOIN concesiones.Concesion c ON c.id = cp.id_concesion
    INNER JOIN concesiones.Empresa e ON e.id = c.id_empresa
    INNER JOIN gestion.Parque p ON p.id = c.id_parque
    WHERE e.nombre = 'Patagonia Viajes' AND p.nombre = 'Parque Nacional Los Glaciares' AND cp.fecha_generacion = '2026-08-01'
)
    EXEC concesiones.canon_pagar_alta
        @fecha_generacion = '2026-08-01',
        @empresa = 'Patagonia Viajes',
        @parque = 'Parque Nacional Los Glaciares',
        @fecha_inicio = '2026-07-01';
GO

-----------------------------------------------------------
-- 6. Ventas
-----------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM ventas.punto_de_venta pv INNER JOIN gestion.Parque p ON p.id = pv.parque WHERE p.nombre = 'Parque Nacional Iguazú' AND pv.descripcion = 'Boleteria principal')
    EXEC ventas.punto_de_venta_alta @parque = 'Parque Nacional Iguazú', @pov = 'Boleteria principal';

IF NOT EXISTS (SELECT 1 FROM ventas.punto_de_venta pv INNER JOIN gestion.Parque p ON p.id = pv.parque WHERE p.nombre = 'Parque Nacional Los Glaciares' AND pv.descripcion = 'Centro visitantes')
    EXEC ventas.punto_de_venta_alta @parque = 'Parque Nacional Los Glaciares', @pov = 'Centro visitantes';
GO

IF NOT EXISTS (SELECT 1 FROM ventas.entrada e INNER JOIN gestion.Parque p ON p.id = e.parque INNER JOIN ventas.tipo_visitante tv ON tv.id = e.tipo WHERE p.nombre = 'Parque Nacional Iguazú' AND tv.descripcion = 'Adulto' AND e.fecha_hasta IS NULL)
    EXEC ventas.tipo_entrada_alta @parque = 'Parque Nacional Iguazú', @tipo = 'Adulto', @precio = 15000.00, @vigencia = '2026-07-01';

IF NOT EXISTS (SELECT 1 FROM ventas.entrada e INNER JOIN gestion.Parque p ON p.id = e.parque INNER JOIN ventas.tipo_visitante tv ON tv.id = e.tipo WHERE p.nombre = 'Parque Nacional Iguazú' AND tv.descripcion = 'Menor' AND e.fecha_hasta IS NULL)
    EXEC ventas.tipo_entrada_alta @parque = 'Parque Nacional Iguazú', @tipo = 'Menor', @precio = 7000.00, @vigencia = '2026-07-01';

IF NOT EXISTS (SELECT 1 FROM ventas.entrada e INNER JOIN gestion.Parque p ON p.id = e.parque INNER JOIN ventas.tipo_visitante tv ON tv.id = e.tipo WHERE p.nombre = 'Parque Nacional Los Glaciares' AND tv.descripcion = 'Adulto' AND e.fecha_hasta IS NULL)
    EXEC ventas.tipo_entrada_alta @parque = 'Parque Nacional Los Glaciares', @tipo = 'Adulto', @precio = 18000.00, @vigencia = '2026-07-01';
GO

DECLARE @id_venta_iguazu INT;
DECLARE @id_venta_glaciares INT;

IF NOT EXISTS (
    SELECT 1
    FROM ventas.venta v
    INNER JOIN gestion.Parque p ON p.id = v.parque
    INNER JOIN ventas.punto_de_venta pv ON pv.id = v.punto_de_venta
    WHERE p.nombre = 'Parque Nacional Iguazú'
      AND pv.descripcion = 'Boleteria principal'
      AND v.fecha = '2026-08-10'
)
BEGIN
    EXEC ventas.venta_alta
        @parque = 'Parque Nacional Iguazú',
        @fecha = '2026-08-10',
        @pov = 'Boleteria principal',
        @metodo = 'Debito',
        @id_creado = @id_venta_iguazu OUTPUT;

    EXEC ventas.item_venta_alta
        @venta = @id_venta_iguazu,
        @concepto = 'Adulto',
        @cantidad = 2,
        @fecha_acceso = '2026-08-10';

    EXEC ventas.item_venta_alta
        @venta = @id_venta_iguazu,
        @concepto = 'Menor',
        @cantidad = 1,
        @fecha_acceso = '2026-08-10';
END

IF NOT EXISTS (
    SELECT 1
    FROM ventas.venta v
    INNER JOIN gestion.Parque p ON p.id = v.parque
    INNER JOIN ventas.punto_de_venta pv ON pv.id = v.punto_de_venta
    WHERE p.nombre = 'Parque Nacional Los Glaciares'
      AND pv.descripcion = 'Centro visitantes'
      AND v.fecha = '2026-08-11'
)
BEGIN
    EXEC ventas.venta_alta
        @parque = 'Parque Nacional Los Glaciares',
        @fecha = '2026-08-11',
        @pov = 'Centro visitantes',
        @metodo = 'Credito',
        @id_creado = @id_venta_glaciares OUTPUT;

    EXEC ventas.item_venta_alta
        @venta = @id_venta_glaciares,
        @concepto = 'Adulto',
        @cantidad = 3,
        @fecha_acceso = '2026-08-11';
END
GO

-----------------------------------------------------------
-- 7. Ampliacion para casos obligatorios de entrega
-----------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM gestion.Ubicacion WHERE provincia = 'Chubut')
    EXEC gestion.ubicacion_alta 'Chubut';
IF NOT EXISTS (SELECT 1 FROM gestion.Ubicacion WHERE provincia = 'Tierra del Fuego, Antártida e Islas del Atlántico')
    EXEC gestion.ubicacion_alta 'Tierra del Fuego, Antártida e Islas del Atlántico';
IF NOT EXISTS (SELECT 1 FROM gestion.Ubicacion WHERE provincia = 'Entre Ríos')
    EXEC gestion.ubicacion_alta 'Entre Ríos';
IF NOT EXISTS (SELECT 1 FROM gestion.Ubicacion WHERE provincia = 'Corrientes')
    EXEC gestion.ubicacion_alta 'Corrientes';
IF NOT EXISTS (SELECT 1 FROM gestion.Ubicacion WHERE provincia = 'Jujuy')
    EXEC gestion.ubicacion_alta 'Jujuy';
IF NOT EXISTS (SELECT 1 FROM gestion.Ubicacion WHERE provincia = 'Salta')
    EXEC gestion.ubicacion_alta 'Salta';
IF NOT EXISTS (SELECT 1 FROM gestion.Ubicacion WHERE provincia = 'Buenos Aires')
    EXEC gestion.ubicacion_alta 'Buenos Aires';
GO

IF NOT EXISTS (SELECT 1 FROM gestion.Parque WHERE nombre = 'Parque Nacional Lago Puelo')
    EXEC gestion.parque_alta @nombre = 'Parque Nacional Lago Puelo', @tipo = 'Parque nacional', @ubicacion = 'Chubut', @superficie = 27674;
IF NOT EXISTS (SELECT 1 FROM gestion.Parque WHERE nombre = 'Parque Nacional Tierra del Fuego, Antártida e Islas del Atlántico')
    EXEC gestion.parque_alta @nombre = 'Parque Nacional Tierra del Fuego, Antártida e Islas del Atlántico', @tipo = 'Parque nacional', @ubicacion = 'Tierra del Fuego, Antártida e Islas del Atlántico', @superficie = 68909;
IF NOT EXISTS (SELECT 1 FROM gestion.Parque WHERE nombre = 'Parque Nacional El Palmar')
    EXEC gestion.parque_alta @nombre = 'Parque Nacional El Palmar', @tipo = 'Parque nacional', @ubicacion = 'Entre Ríos', @superficie = 8500;
IF NOT EXISTS (SELECT 1 FROM gestion.Parque WHERE nombre = 'Parque Nacional Ibera')
    EXEC gestion.parque_alta @nombre = 'Parque Nacional Ibera', @tipo = 'Parque nacional', @ubicacion = 'Corrientes', @superficie = 183500;
IF NOT EXISTS (SELECT 1 FROM gestion.Parque WHERE nombre = 'Parque Nacional Calilegua')
    EXEC gestion.parque_alta @nombre = 'Parque Nacional Calilegua', @tipo = 'Parque nacional', @ubicacion = 'Jujuy', @superficie = 76306;
IF NOT EXISTS (SELECT 1 FROM gestion.Parque WHERE nombre = 'Parque Nacional Los Cardones')
    EXEC gestion.parque_alta @nombre = 'Parque Nacional Los Cardones', @tipo = 'Parque nacional', @ubicacion = 'Salta', @superficie = 64117;
IF NOT EXISTS (SELECT 1 FROM gestion.Parque WHERE nombre = 'Parque Nacional Ciervo de los Pantanos')
    EXEC gestion.parque_alta @nombre = 'Parque Nacional Ciervo de los Pantanos', @tipo = 'Parque nacional', @ubicacion = 'Buenos Aires', @superficie = 5588;
GO

DECLARE @i INT = 1;
DECLARE @dni_guardaparque INT;
DECLARE @dni_guia CHAR(8);
WHILE @i <= 17
BEGIN
    SET @dni_guardaparque = 40000000 + @i;
    SET @dni_guia = RIGHT('00000000' + CAST(41000000 + @i AS VARCHAR(8)), 8);

    IF NOT EXISTS (SELECT 1 FROM gestion.Guardaparque WHERE dni = @dni_guardaparque)
        EXEC gestion.guardaparque_alta @dni = @dni_guardaparque, @nombre = 'Guardaparque', @apellido = 'Seed';

    IF NOT EXISTS (SELECT 1 FROM gestion.Guia WHERE dni = @dni_guia)
        EXEC gestion.guia_alta @dni = @dni_guia, @nombre = 'Guia', @apellido = 'Seed', @fecha_vencimiento_acreditacion = '2029-12-31';

    SET @i += 1;
END
GO

DECLARE @id_iguazu_seed INT = (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Iguazú');
DECLARE @id_glaciares_seed INT = (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Los Glaciares');
DECLARE @id_nahuel_seed INT = (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Nahuel Huapi');
DECLARE @id_lago_puelo_seed INT = (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Lago Puelo');
DECLARE @id_tdf_seed INT = (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Tierra del Fuego, Antártida e Islas del Atlántico');
DECLARE @id_palmar_seed INT = (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional El Palmar');
DECLARE @id_ibera_seed INT = (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Ibera');
DECLARE @id_calilegua_seed INT = (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Calilegua');
DECLARE @id_cardones_seed INT = (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Los Cardones');
DECLARE @id_ciervo_seed INT = (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Ciervo de los Pantanos');
DECLARE @id_guia_01_seed INT = (SELECT id FROM gestion.Guia WHERE dni = '41000001');
DECLARE @id_guia_02_seed INT = (SELECT id FROM gestion.Guia WHERE dni = '41000002');
DECLARE @id_guia_03_seed INT = (SELECT id FROM gestion.Guia WHERE dni = '41000003');

IF NOT EXISTS (SELECT 1 FROM gestion.Actividad WHERE nombre = 'Seed Tour 01' AND id_parque = @id_iguazu_seed)
    EXEC gestion.actividad_alta @id_parque = @id_iguazu_seed, @id_guia = @id_guia_01_seed, @nombre = 'Seed Tour 01', @descripcion = 'Actividad seed para entrega', @tipo = 'Senderismo', @costo = 5250.00, @fecha = '2026-10-15', @duracion = 120, @cupo = 20;
IF NOT EXISTS (SELECT 1 FROM gestion.Actividad WHERE nombre = 'Seed Tour 02' AND id_parque = @id_iguazu_seed)
    EXEC gestion.actividad_alta @id_parque = @id_iguazu_seed, @id_guia = @id_guia_02_seed, @nombre = 'Seed Tour 02', @descripcion = 'Actividad seed para entrega', @tipo = 'Navegacion', @costo = 5500.00, @fecha = '2026-10-15', @duracion = 120, @cupo = 21;
IF NOT EXISTS (SELECT 1 FROM gestion.Actividad WHERE nombre = 'Seed Tour 03' AND id_parque = @id_iguazu_seed)
    EXEC gestion.actividad_alta @id_parque = @id_iguazu_seed, @id_guia = @id_guia_03_seed, @nombre = 'Seed Tour 03', @descripcion = 'Actividad seed para entrega', @tipo = 'Avistaje', @costo = 5750.00, @fecha = '2026-10-15', @duracion = 120, @cupo = 22;
IF NOT EXISTS (SELECT 1 FROM gestion.Actividad WHERE nombre = 'Seed Tour 04' AND id_parque = @id_glaciares_seed)
    EXEC gestion.actividad_alta @id_parque = @id_glaciares_seed, @id_guia = @id_guia_01_seed, @nombre = 'Seed Tour 04', @descripcion = 'Actividad seed para entrega', @tipo = 'Senderismo', @costo = 6000.00, @fecha = '2026-09-05', @duracion = 150, @cupo = 23;
IF NOT EXISTS (SELECT 1 FROM gestion.Actividad WHERE nombre = 'Seed Tour 05' AND id_parque = @id_nahuel_seed)
    EXEC gestion.actividad_alta @id_parque = @id_nahuel_seed, @id_guia = @id_guia_02_seed, @nombre = 'Seed Tour 05', @descripcion = 'Actividad seed para entrega', @tipo = 'Navegacion', @costo = 6250.00, @fecha = '2026-09-06', @duracion = 150, @cupo = 24;
IF NOT EXISTS (SELECT 1 FROM gestion.Actividad WHERE nombre = 'Seed Tour 06' AND id_parque = @id_lago_puelo_seed)
    EXEC gestion.actividad_alta @id_parque = @id_lago_puelo_seed, @id_guia = @id_guia_03_seed, @nombre = 'Seed Tour 06', @descripcion = 'Actividad seed para entrega', @tipo = 'Avistaje', @costo = 6500.00, @fecha = '2026-09-07', @duracion = 150, @cupo = 25;
IF NOT EXISTS (SELECT 1 FROM gestion.Actividad WHERE nombre = 'Seed Tour 07' AND id_parque = @id_tdf_seed)
    EXEC gestion.actividad_alta @id_parque = @id_tdf_seed, @id_guia = @id_guia_01_seed, @nombre = 'Seed Tour 07', @descripcion = 'Actividad seed para entrega', @tipo = 'Senderismo', @costo = 6750.00, @fecha = '2026-09-08', @duracion = 150, @cupo = 26;
IF NOT EXISTS (SELECT 1 FROM gestion.Actividad WHERE nombre = 'Seed Tour 08' AND id_parque = @id_palmar_seed)
    EXEC gestion.actividad_alta @id_parque = @id_palmar_seed, @id_guia = @id_guia_02_seed, @nombre = 'Seed Tour 08', @descripcion = 'Actividad seed para entrega', @tipo = 'Navegacion', @costo = 7000.00, @fecha = '2026-09-09', @duracion = 150, @cupo = 27;
IF NOT EXISTS (SELECT 1 FROM gestion.Actividad WHERE nombre = 'Seed Tour 09' AND id_parque = @id_ibera_seed)
    EXEC gestion.actividad_alta @id_parque = @id_ibera_seed, @id_guia = @id_guia_03_seed, @nombre = 'Seed Tour 09', @descripcion = 'Actividad seed para entrega', @tipo = 'Avistaje', @costo = 7250.00, @fecha = '2026-09-10', @duracion = 150, @cupo = 28;
IF NOT EXISTS (SELECT 1 FROM gestion.Actividad WHERE nombre = 'Seed Tour 10' AND id_parque = @id_calilegua_seed)
    EXEC gestion.actividad_alta @id_parque = @id_calilegua_seed, @id_guia = @id_guia_01_seed, @nombre = 'Seed Tour 10', @descripcion = 'Actividad seed para entrega', @tipo = 'Senderismo', @costo = 7500.00, @fecha = '2026-09-11', @duracion = 150, @cupo = 29;
IF NOT EXISTS (SELECT 1 FROM gestion.Actividad WHERE nombre = 'Seed Tour 11' AND id_parque = @id_cardones_seed)
    EXEC gestion.actividad_alta @id_parque = @id_cardones_seed, @id_guia = @id_guia_02_seed, @nombre = 'Seed Tour 11', @descripcion = 'Actividad seed para entrega', @tipo = 'Navegacion', @costo = 7750.00, @fecha = '2026-09-12', @duracion = 150, @cupo = 30;
IF NOT EXISTS (SELECT 1 FROM gestion.Actividad WHERE nombre = 'Seed Tour 12' AND id_parque = @id_ciervo_seed)
    EXEC gestion.actividad_alta @id_parque = @id_ciervo_seed, @id_guia = @id_guia_03_seed, @nombre = 'Seed Tour 12', @descripcion = 'Actividad seed para entrega', @tipo = 'Avistaje', @costo = 8000.00, @fecha = '2026-09-13', @duracion = 150, @cupo = 31;
GO

DECLARE @id_parque_actividad INT;
DECLARE @id_guia_actividad INT;
DECLARE @n INT = 13;
DECLARE @nombre_actividad VARCHAR(50);
WHILE @n <= 27
BEGIN
    SET @nombre_actividad = CONCAT('Seed Tour ', RIGHT('00' + CAST(@n AS VARCHAR(2)), 2));
    SET @id_parque_actividad = CASE (@n % 10)
        WHEN 0 THEN (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Iguazú')
        WHEN 1 THEN (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Los Glaciares')
        WHEN 2 THEN (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Nahuel Huapi')
        WHEN 3 THEN (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Lago Puelo')
        WHEN 4 THEN (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Tierra del Fuego, Antártida e Islas del Atlántico')
        WHEN 5 THEN (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional El Palmar')
        WHEN 6 THEN (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Ibera')
        WHEN 7 THEN (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Calilegua')
        WHEN 8 THEN (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Los Cardones')
        ELSE (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Ciervo de los Pantanos')
    END;
    SET @id_guia_actividad = (SELECT id FROM gestion.Guia WHERE dni = RIGHT('00000000' + CAST(41000000 + (((@n - 1) % 17) + 1) AS VARCHAR(8)), 8));

    IF NOT EXISTS (SELECT 1 FROM gestion.Actividad WHERE nombre = @nombre_actividad AND id_parque = @id_parque_actividad)
        EXEC gestion.actividad_alta
            @id_parque = @id_parque_actividad,
            @id_guia = @id_guia_actividad,
            @nombre = @nombre_actividad,
            @descripcion = 'Actividad seed para entrega',
            @tipo = 'Senderismo',
            @costo = 8000.00,
            @fecha = '2026-09-20',
            @duracion = 120,
            @cupo = 25;

    SET @n += 1;
END
GO

DECLARE @id_parque_cupo INT = (SELECT id FROM gestion.Parque WHERE nombre = 'Parque Nacional Iguazú');
DECLARE @id_guia_cupo INT = (SELECT id FROM gestion.Guia WHERE dni = '41000001');
IF NOT EXISTS (SELECT 1 FROM gestion.Actividad WHERE nombre = 'Tour Cupo Completo' AND id_parque = @id_parque_cupo)
    EXEC gestion.actividad_alta @id_parque = @id_parque_cupo, @id_guia = @id_guia_cupo, @nombre = 'Tour Cupo Completo', @descripcion = 'Caso obligatorio de cupo completo', @tipo = 'Senderismo', @costo = 7500.00, @fecha = '2026-10-15', @duracion = 120, @cupo = 1;
UPDATE gestion.Actividad SET estado = 'Cupo lleno' WHERE nombre = 'Tour Cupo Completo' AND id_parque = @id_parque_cupo;
GO

IF NOT EXISTS (SELECT 1 FROM concesiones.Empresa WHERE nombre = 'Concesionaria 01')
    EXEC concesiones.empresa_alta @nombre = 'Concesionaria 01', @tipo = 'Gastronomia', @cuit = '30780000001';
IF NOT EXISTS (SELECT 1 FROM concesiones.Empresa WHERE nombre = 'Concesionaria 02')
    EXEC concesiones.empresa_alta @nombre = 'Concesionaria 02', @tipo = 'Tienda', @cuit = '30780000002';
IF NOT EXISTS (SELECT 1 FROM concesiones.Empresa WHERE nombre = 'Concesionaria 03')
    EXEC concesiones.empresa_alta @nombre = 'Concesionaria 03', @tipo = 'Transporte', @cuit = '30780000003';
IF NOT EXISTS (SELECT 1 FROM concesiones.Empresa WHERE nombre = 'Concesionaria 04')
    EXEC concesiones.empresa_alta @nombre = 'Concesionaria 04', @tipo = 'Excursiones', @cuit = '30780000004';
IF NOT EXISTS (SELECT 1 FROM concesiones.Empresa WHERE nombre = 'Concesionaria 05')
    EXEC concesiones.empresa_alta @nombre = 'Concesionaria 05', @tipo = 'Gastronomia', @cuit = '30780000005';
IF NOT EXISTS (SELECT 1 FROM concesiones.Empresa WHERE nombre = 'Concesionaria 06')
    EXEC concesiones.empresa_alta @nombre = 'Concesionaria 06', @tipo = 'Tienda', @cuit = '30780000006';
IF NOT EXISTS (SELECT 1 FROM concesiones.Empresa WHERE nombre = 'Concesionaria 07')
    EXEC concesiones.empresa_alta @nombre = 'Concesionaria 07', @tipo = 'Excursiones', @cuit = '30780000007';
IF NOT EXISTS (SELECT 1 FROM concesiones.Empresa WHERE nombre = 'Concesionaria 08')
    EXEC concesiones.empresa_alta @nombre = 'Concesionaria 08', @tipo = 'Gastronomia', @cuit = '30780000008';
GO

IF NOT EXISTS (SELECT 1 FROM concesiones.Concesion c INNER JOIN concesiones.Empresa e ON e.id = c.id_empresa WHERE e.nombre = 'Concesionaria 01' AND c.fecha_inicio = '2026-07-01')
    EXEC concesiones.concesion_alta @empresa = 'Concesionaria 01', @parque = 'Parque Nacional Nahuel Huapi', @canon_mensual = 180000.00, @fecha_inicio = '2026-07-01', @actividad = NULL;
IF NOT EXISTS (SELECT 1 FROM concesiones.Concesion c INNER JOIN concesiones.Empresa e ON e.id = c.id_empresa WHERE e.nombre = 'Concesionaria 02' AND c.fecha_inicio = '2026-07-01')
    EXEC concesiones.concesion_alta @empresa = 'Concesionaria 02', @parque = 'Parque Nacional Lago Puelo', @canon_mensual = 160000.00, @fecha_inicio = '2026-07-01', @actividad = NULL;
IF NOT EXISTS (SELECT 1 FROM concesiones.Concesion c INNER JOIN concesiones.Empresa e ON e.id = c.id_empresa WHERE e.nombre = 'Concesionaria 03' AND c.fecha_inicio = '2026-07-01')
    EXEC concesiones.concesion_alta @empresa = 'Concesionaria 03', @parque = 'Parque Nacional Tierra del Fuego, Antártida e Islas del Atlántico', @canon_mensual = 220000.00, @fecha_inicio = '2026-07-01', @actividad = NULL;
IF NOT EXISTS (SELECT 1 FROM concesiones.Concesion c INNER JOIN concesiones.Empresa e ON e.id = c.id_empresa WHERE e.nombre = 'Concesionaria 04' AND c.fecha_inicio = '2026-07-01')
    EXEC concesiones.concesion_alta @empresa = 'Concesionaria 04', @parque = 'Parque Nacional El Palmar', @canon_mensual = 140000.00, @fecha_inicio = '2026-07-01', @actividad = NULL;
IF NOT EXISTS (SELECT 1 FROM concesiones.Concesion c INNER JOIN concesiones.Empresa e ON e.id = c.id_empresa WHERE e.nombre = 'Concesionaria 05' AND c.fecha_inicio = '2026-07-01')
    EXEC concesiones.concesion_alta @empresa = 'Concesionaria 05', @parque = 'Parque Nacional Ibera', @canon_mensual = 190000.00, @fecha_inicio = '2026-07-01', @actividad = NULL;
IF NOT EXISTS (SELECT 1 FROM concesiones.Concesion c INNER JOIN concesiones.Empresa e ON e.id = c.id_empresa WHERE e.nombre = 'Concesionaria 06' AND c.fecha_inicio = '2026-07-01')
    EXEC concesiones.concesion_alta @empresa = 'Concesionaria 06', @parque = 'Parque Nacional Calilegua', @canon_mensual = 135000.00, @fecha_inicio = '2026-07-01', @actividad = NULL;
IF NOT EXISTS (SELECT 1 FROM concesiones.Concesion c INNER JOIN concesiones.Empresa e ON e.id = c.id_empresa WHERE e.nombre = 'Concesionaria 07' AND c.fecha_inicio = '2026-07-01')
    EXEC concesiones.concesion_alta @empresa = 'Concesionaria 07', @parque = 'Parque Nacional Los Cardones', @canon_mensual = 155000.00, @fecha_inicio = '2026-07-01', @actividad = NULL;
IF NOT EXISTS (SELECT 1 FROM concesiones.Concesion c INNER JOIN concesiones.Empresa e ON e.id = c.id_empresa WHERE e.nombre = 'Concesionaria 08' AND c.fecha_inicio = '2025-01-01')
    EXEC concesiones.concesion_alta @empresa = 'Concesionaria 08', @parque = 'Parque Nacional Ciervo de los Pantanos', @canon_mensual = 120000.00, @fecha_inicio = '2025-01-01', @actividad = NULL;
EXEC concesiones.concesion_modificacion @empresa = 'Concesionaria 08', @parque = 'Parque Nacional Ciervo de los Pantanos', @fecha_inicio = '2025-01-01', @fecha_fin = '2025-12-31', @estado = 'INACTIVO';
GO

DECLARE @venta_id INT;
IF NOT EXISTS (SELECT 1 FROM ventas.venta WHERE fecha = '2026-08-12')
BEGIN
    EXEC ventas.venta_alta @parque = 'Parque Nacional Iguazú', @fecha = '2026-08-12', @pov = 'Boleteria principal', @metodo = 'Efectivo', @id_creado = @venta_id OUTPUT;
    EXEC ventas.item_venta_alta @venta = @venta_id, @concepto = 'Adulto', @cantidad = 4, @fecha_acceso = '2026-08-12';
END
IF NOT EXISTS (SELECT 1 FROM ventas.venta WHERE fecha = '2026-08-13')
BEGIN
    EXEC ventas.venta_alta @parque = 'Parque Nacional Iguazú', @fecha = '2026-08-13', @pov = 'Boleteria principal', @metodo = 'Debito', @id_creado = @venta_id OUTPUT;
    EXEC ventas.item_venta_alta @venta = @venta_id, @concepto = 'Adulto', @cantidad = 5, @fecha_acceso = '2026-08-13';
END
IF NOT EXISTS (SELECT 1 FROM ventas.venta WHERE fecha = '2026-08-14')
BEGIN
    EXEC ventas.venta_alta @parque = 'Parque Nacional Los Glaciares', @fecha = '2026-08-14', @pov = 'Centro visitantes', @metodo = 'Credito', @id_creado = @venta_id OUTPUT;
    EXEC ventas.item_venta_alta @venta = @venta_id, @concepto = 'Adulto', @cantidad = 6, @fecha_acceso = '2026-08-14';
END
IF NOT EXISTS (SELECT 1 FROM ventas.venta WHERE fecha = '2026-08-15')
BEGIN
    EXEC ventas.venta_alta @parque = 'Parque Nacional Los Glaciares', @fecha = '2026-08-15', @pov = 'Centro visitantes', @metodo = 'Efectivo', @id_creado = @venta_id OUTPUT;
    EXEC ventas.item_venta_alta @venta = @venta_id, @concepto = 'Adulto', @cantidad = 7, @fecha_acceso = '2026-08-15';
END
GO

-- Para demostrar importacion con errores parciales, ajustar esta ruta al archivo
-- incluido en el repo y ejecutar. El SP inserta filas validas y reporta invalidas.
-- EXEC gestion.sp_importar_parques @archivo_dir = 'data/parques_importacion_parcial.csv';

-----------------------------------------------------------
-- 8. Resumen de carga
-----------------------------------------------------------

SELECT 'gestion.Ubicacion' AS tabla, COUNT(*) AS cantidad FROM gestion.Ubicacion
UNION ALL SELECT 'gestion.Parque', COUNT(*) FROM gestion.Parque
UNION ALL SELECT 'gestion.Guardaparque', COUNT(*) FROM gestion.Guardaparque
UNION ALL SELECT 'gestion.Parque_asignado', COUNT(*) FROM gestion.Parque_asignado
UNION ALL SELECT 'gestion.Guia', COUNT(*) FROM gestion.Guia
UNION ALL SELECT 'gestion.Tipo_actividad', COUNT(*) FROM gestion.Tipo_actividad
UNION ALL SELECT 'gestion.Actividad', COUNT(*) FROM gestion.Actividad
UNION ALL SELECT 'gestion.Coordina', COUNT(*) FROM gestion.Coordina
UNION ALL SELECT 'guia.Acreditacion', COUNT(*) FROM guia.Acreditacion
UNION ALL SELECT 'guia.Titulo', COUNT(*) FROM guia.Titulo
UNION ALL SELECT 'guia.Especialidad', COUNT(*) FROM guia.Especialidad
UNION ALL SELECT 'guia.Especializado_en', COUNT(*) FROM guia.Especializado_en
UNION ALL SELECT 'guia.Titulacion_guia', COUNT(*) FROM guia.Titulacion_guia
UNION ALL SELECT 'concesiones.Empresa', COUNT(*) FROM concesiones.Empresa
UNION ALL SELECT 'concesiones.Concesion', COUNT(*) FROM concesiones.Concesion
UNION ALL SELECT 'concesiones.Canon_pagar', COUNT(*) FROM concesiones.Canon_pagar
UNION ALL SELECT 'ventas.tipo_visitante', COUNT(*) FROM ventas.tipo_visitante
UNION ALL SELECT 'ventas.punto_de_venta', COUNT(*) FROM ventas.punto_de_venta
UNION ALL SELECT 'ventas.metodo_de_pago', COUNT(*) FROM ventas.metodo_de_pago
UNION ALL SELECT 'ventas.entrada', COUNT(*) FROM ventas.entrada
UNION ALL SELECT 'ventas.venta', COUNT(*) FROM ventas.venta
UNION ALL SELECT 'ventas.item_venta', COUNT(*) FROM ventas.item_venta;
GO
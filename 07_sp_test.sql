-- Universidad: Universidad de la Matanza
-- Materia: Bases de Datos Aplicadas
 
-- Grupo 06
-- Integrantes:
--  De Bellis, Nahuel
--  Ocampo, Julian Rafael
--  Rodriguez, Gonzalo Ezequiel
--  Vargas, Tomas
 
-- Objetivo del script: Testing de SPs
-- Cubre alta de especialidad , actualizar acreditacion, asignacion de especialidad y titulo
 
-- Fecha: 14/06/2026

USE parques_nacionales
GO

-- ============================================================
-- SECCION 1: ALTA DE ESPECIALIDAD
-- ============================================================

PRINT '=== ALTA DE ESPECIALIDAD ===';
GO

-- TEST 1.1: Registro exitoso
PRINT '--- TEST 1.1: Registrar especialidad exitosamente ---';
EXEC personal.especialidad_alta
	@descripcion = 'Cardiologia test';
GO

-- TEST 1.2: Registro exitoso
PRINT '--- TEST 1.2: Registrar especialidad exitosamente ---';
EXEC personal.especialidad_alta
	@descripcion = 'Fauna silvestre test';
GO

-- TEST 1.3: Registro exitoso
PRINT '--- TEST 1.3: Registrar especialidad exitosamente ---';
EXEC personal.especialidad_alta
	@descripcion = 'Flora nativa test';
GO

-- TEST 1.4: Registro exitoso
PRINT '--- TEST 1.4: Registrar especialidad exitosamente ---';
EXEC personal.especialidad_alta
	@descripcion = 'Avistamiento de aves test';
GO

-- TEST 1.5: Registro exitoso
PRINT '--- TEST 1.5: Registrar especialidad exitosamente ---';
EXEC personal.especialidad_alta
	@descripcion = 'Primeros auxilios en campo test';
GO

-- TEST 1.6: Registro exitoso
PRINT '--- TEST 1.6: Registrar especialidad exitosamente ---';
EXEC personal.especialidad_alta
	@descripcion = 'Interpretacion geologica test';
GO

-- TEST 1.7: Especialidad duplicada (debe fallar)
PRINT '--- TEST 1.7: Especialidad ya registrada (debe fallar) ---';
BEGIN TRY
    EXEC personal.especialidad_alta
    @descripcion = 'Flora nativa test';
    PRINT 'FALLO - Test 1.7: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 1.7: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 1.8: Descripcion vacia (debe fallar)
PRINT '--- TEST 1.8: Descripcion vacia (debe fallar) ---';
BEGIN TRY
    EXEC personal.especialidad_alta
    @descripcion = '';
    PRINT 'FALLO - Test 1.8: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 1.8: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 1.9: Descripcion NULL (debe fallar)
PRINT '--- TEST 1.9: Descripcion NULL (debe fallar) ---';
BEGIN TRY
    EXEC personal.especialidad_alta
    @descripcion = NULL;
    PRINT 'FALLO - Test 1.9: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 1.9: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 1.10: Descripcion con solo espacios (debe fallar)
PRINT '--- TEST 1.10: Descripcion con solo espacios (debe fallar) ---';
BEGIN TRY
    EXEC personal.especialidad_alta
    @descripcion = '   ';
    PRINT 'FALLO - Test 1.10: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 1.10: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================================
-- SECCION 2: ASIGNACION DE ESPECIALIZACION
-- ============================================================

PRINT '=== ASIGNACION DE ESPECIALIZACION ===';
GO

-- TEST 2.1: Especialidad inexistente (debe fallar)
PRINT '--- TEST 2.1: Especialidad no registrada (debe fallar) ---';
BEGIN TRY
    EXEC personal.especialidad_asignar
    @dni = '25123456',
    @especialidad = 'Fauna marina test';
    PRINT 'FALLO - Test 2.1: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 2.1: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 2.2: Especialidad NULL (debe fallar)
PRINT '--- TEST 2.2: Falta especificar la especialidad (debe fallar) ---';
BEGIN TRY
    EXEC personal.especialidad_asignar
    @dni = '25123456',
    @especialidad = NULL;
    PRINT 'FALLO - Test 2.2: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 2.2: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 2.3: DNI NULL (debe fallar)
PRINT '--- TEST 2.3: Falta especificar el DNI del guia (debe fallar) ---';
BEGIN TRY
    EXEC personal.especialidad_asignar
    @dni = NULL,
    @especialidad = 'Fauna silvestre test';
    PRINT 'FALLO - Test 2.3: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 2.3: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 2.4: Asignacion exitosa
PRINT '--- TEST 2.4: Asignar especialidad exitosamente ---';
EXEC personal.especialidad_asignar
	@dni = '25123456',
	@especialidad = 'Fauna silvestre test';
GO

-- TEST 2.5: Especialidad ya asignada al guia (debe fallar)
PRINT '--- TEST 2.5: El guia ya posee esa especialidad (debe fallar) ---';
BEGIN TRY
    EXEC personal.especialidad_asignar
    @dni = '25123456',
    @especialidad = 'Fauna silvestre test';
    PRINT 'FALLO - Test 2.5: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 2.5: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 2.6: Asignacion exitosa
PRINT '--- TEST 2.6: Asignar especialidad exitosamente ---';
EXEC personal.especialidad_asignar
	@dni = '25123456',
	@especialidad = 'Flora nativa test';
GO

-- ============================================================
-- SECCION 3: ACTUALIZACION DE ACREDITACION
-- ============================================================

PRINT '=== ACTUALIZACION DE ACREDITACION ===';
GO

-- TEST 3.1: DNI NULL (debe fallar)
PRINT '--- TEST 3.1: Falta especificar el DNI del guia (debe fallar) ---';
BEGIN TRY
    EXEC personal.acreditacion_actualizar
    @dni = NULL,
    @fecha_vencimiento_acreditacion = '2026-06-15';
    PRINT 'FALLO - Test 3.1: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 3.1: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 3.2: Guia inexistente (debe fallar)
PRINT '--- TEST 3.2: DNI no pertenece a ningun guia (debe fallar) ---';
BEGIN TRY
    EXEC personal.acreditacion_actualizar
    @dni = '25128779',
    @fecha_vencimiento_acreditacion = '2026-06-15';
    PRINT 'FALLO - Test 3.2: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 3.2: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 3.3: Fecha de vencimiento NULL (debe fallar)
PRINT '--- TEST 3.3: Falta especificar la fecha de vencimiento (debe fallar) ---';
BEGIN TRY
    EXEC personal.acreditacion_actualizar
    @dni = '38912345',
    @fecha_vencimiento_acreditacion = NULL;
    PRINT 'FALLO - Test 3.3: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 3.3: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 3.4: Actualizacion exitosa
PRINT '--- TEST 3.4: Actualizar acreditacion exitosamente ---';
EXEC personal.acreditacion_actualizar
	@dni = '25123456',
	@fecha_vencimiento_acreditacion = '2027-08-12';
GO

-- ============================================================
-- SECCION 4: ASIGNACION DE TITULACION A GUIA
-- ============================================================

PRINT '=== ASIGNACION DE TITULACION A GUIA ===';
GO

-- TEST 4.1: DNI NULL (debe fallar)
PRINT '--- TEST 4.1: Falta especificar el DNI del guia (debe fallar) ---';
BEGIN TRY
    EXEC personal.titulacion_asignar
    @dni = NULL,
    @descripcion = 'Especializado en flora nativa Argentina test',
    @institucion = 'UNLAM test',
    @fecha_emision = '2020-04-15';
    PRINT 'FALLO - Test 4.1: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 4.1: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 4.2: Descripcion del titulo NULL (debe fallar)
PRINT '--- TEST 4.2: Falta especificar el titulo (debe fallar) ---';
BEGIN TRY
    EXEC personal.titulacion_asignar
    @dni = '25123456',
    @descripcion = NULL,
    @institucion = 'UNLAM test',
    @fecha_emision = '2020-04-15';
    PRINT 'FALLO - Test 4.2: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 4.2: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 4.3: Institucion NULL (debe fallar)
PRINT '--- TEST 4.3: Falta especificar la institucion (debe fallar) ---';
BEGIN TRY
    EXEC personal.titulacion_asignar
    @dni = '25123456',
    @descripcion = 'Especializado en flora nativa Argentina test',
    @institucion = NULL,
    @fecha_emision = '2020-04-15';
    PRINT 'FALLO - Test 4.3: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 4.3: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 4.4: Fecha de emision NULL (debe fallar)
PRINT '--- TEST 4.4: Falta especificar la fecha de emision (debe fallar) ---';
BEGIN TRY
    EXEC personal.titulacion_asignar
    @dni = '25123456',
    @descripcion = 'Especializado en flora nativa Argentina test',
    @institucion = 'UNLAM test',
    @fecha_emision = NULL;
    PRINT 'FALLO - Test 4.4: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 4.4: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 4.5: Asignacion exitosa
PRINT '--- TEST 4.5: Asignar titulacion exitosamente ---';
EXEC personal.titulacion_asignar
	@dni = '25123456',
	@descripcion = 'Especializado en flora nativa Argentina test',
	@institucion = 'UNLAM test',
	@fecha_emision = '2020-04-15';
GO

-- TEST 4.6: Titulo ya asignado al guia (debe fallar)
PRINT '--- TEST 4.6: El guia ya posee esa titulacion (debe fallar) ---';
BEGIN TRY
    EXEC personal.titulacion_asignar
    @dni = '25123456',
    @descripcion = 'Especializado en flora nativa Argentina test',
    @institucion = 'UNLAM test',
    @fecha_emision = '2020-09-15';
    PRINT 'FALLO - Test 4.6: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 4.6: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 4.7: Asignacion exitosa
PRINT '--- TEST 4.7: Asignar titulacion exitosamente ---';
EXEC personal.titulacion_asignar
	@dni = '25123456',
	@descripcion = 'Licensiatura en fauna silvestre Argentina test',
	@institucion = 'UBA test',
	@fecha_emision = '2024-04-25';
GO

-- ============================================================
-- SECCION 4: ACTUALIZAR TITULO A GUIA
-- ============================================================

PRINT '=== ACTUALIZAR TITULO A GUIA ===';
GO

-- TEST 5.1: DNI NULL (debe fallar)
PRINT '--- TEST 5.1: Falta especificar el DNI del guia (debe fallar) ---';
BEGIN TRY
    EXEC personal.titulo_modificacion
    @dni = NULL,
    @descripcion = 'Especializado en flora nativa Argentina test',
    @institucion = 'UNLAM test',
    @fecha_emision = '2020-04-15';
    PRINT 'FALLO - Test 5.1: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 5.1: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 5.2: Descripcion del titulo NULL (debe fallar)
PRINT '--- TEST 5.2: Falta especificar el titulo (debe fallar) ---';
BEGIN TRY
    EXEC personal.titulo_modificacion
    @dni = '25123456',
    @descripcion = NULL,
    @institucion = 'UNLAM test',
    @fecha_emision = '2020-04-15';
    PRINT 'FALLO - Test 5.2: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 5.2: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 5.3: Institucion NULL (debe fallar)
PRINT '--- TEST 5.3: Falta especificar la institucion (debe fallar) ---';
BEGIN TRY
    EXEC personal.titulo_modificacion
    @dni = '25123456',
    @descripcion = 'Especializado en flora nativa Argentina test',
    @institucion = NULL,
    @fecha_emision = '2020-04-15';
    PRINT 'FALLO - Test 5.3: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 5.3: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 5.4: Fecha de emision NULL (debe fallar)
PRINT '--- TEST 5.4: Falta especificar la fecha de emision (debe fallar) ---';
BEGIN TRY
    EXEC personal.titulo_modificacion
    @dni = '25123456',
    @descripcion = 'Especializado en flora nativa Argentina test',
    @institucion = 'UNLAM test',
    @fecha_emision = NULL;
    PRINT 'FALLO - Test 5.4: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 5.4: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 5.5: Actualizacion exitosa
PRINT '--- TEST 5.5: Asignar titulacion exitosamente ---';
EXEC personal.titulo_modificacion
	@dni = '25123456',
	@descripcion = 'Especializado en flora nativa Argentina test',
	@institucion = 'UNLAM test',
	@fecha_emision = '2012-04-15';
GO

-- TEST 5.6: Titulo no asignado al guia (debe fallar)
PRINT '--- TEST 5.6: El guia no posee esa titulacion (debe fallar) ---';
BEGIN TRY
    EXEC personal.titulo_modificacion
    @dni = '30456789',
    @descripcion = 'Especializado en flora nativa Argentina test',
    @institucion = 'UNLAM test',
    @fecha_emision = '2020-09-15';
    PRINT 'FALLO - Test 5.6: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 5.6: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- ############################################################
-- TESTS AGREGADOS: LOGICA DE NEGOCIO DE CONCESIONES Y VENTAS
-- (SPs de 05_sp.sql)
-- Cubren: concesion_registrar_gestion, canon_pagar_generar_cuota_mensual,
--         consultar_historico_canones, ingresar_venta, ingresar_ventas_masivo.
-- Se usa aislamiento con begin tran / rollback para no dejar datos.
-- Cada test es su propio batch (GO) para reutilizar variables.
-- ############################################################

-- ============================================================
-- SECCION 6: REGISTRAR GESTION DE CONCESION (concesion_registrar_gestion)
-- ============================================================

PRINT '=== REGISTRAR GESTION DE CONCESION ===';
GO
/*
    
    SELECT * FROM gestion.Parque;
    select * from concesiones.Empresa;
    select * from concesiones.Concesion;
    select * from concesiones.Canon_pagar;
 */

-------------------------------------------------------------------------------
-- TEST 6.1: Registro exitoso
-- Esperado: se crea la concesion en estado ACTIVO y su primer canon PENDIENTE.
-- NOTA: el SP no da de alta la empresa, asi que esta debe existir previamente.
-------------------------------------------------------------------------------
PRINT '--- TEST 6.1: concesion_registrar_gestion (exito) ---';
BEGIN TRAN;
BEGIN TRY
    EXEC gestion.parque_alta 'Parque Gestion 1 test', 'Nacional test', '', 100;
    EXEC concesiones.empresa_alta @nombre = 'Gestion Empresa 1 test', @tipo = 'tienda test', @cuit = '30123456789';
    DECLARE @ide INT = (SELECT TOP 1 id FROM concesiones.Empresa WHERE nombre = 'Gestion Empresa 1 test' ORDER BY id DESC);

    EXEC concesiones.concesion_registrar_gestion
        @empresa = 'Gestion Empresa 1 test',
        @tipo_empresa = 'tienda test',
        @cuit = '30123456789',
        @parque = 'Parque Gestion 1 test',
        @canon_mensual = 1000.00,
        @fecha_inicio = '2026-01-01';

    DECLARE @idc INT = (SELECT TOP 1 id FROM concesiones.Concesion WHERE id_empresa = @ide ORDER BY id DESC);

    IF EXISTS (SELECT 1 FROM concesiones.Concesion WHERE id = @idc AND RTRIM(estado) = 'ACTIVO')
       AND EXISTS (SELECT 1 FROM concesiones.Canon_pagar WHERE id_concesion = @idc AND estado = 'PENDIENTE')
        PRINT 'OK - Test 6.1: concesion ACTIVO y primer canon PENDIENTE generados.';
    ELSE
        PRINT 'FALLO - Test 6.1: no se genero la concesion o el canon esperados.';
END TRY
BEGIN CATCH
    PRINT 'FALLO - Test 6.1: error inesperado: ' + ERROR_MESSAGE();
END CATCH
IF @@trancount > 0 ROLLBACK;
GO

PRINT '--- TEST 6.2: crear y pagar canon (exito) ---';
BEGIN TRAN;
BEGIN TRY
    EXEC gestion.parque_alta 'Parque Gestion 1 test', 'Nacional test', '', 100;
    EXEC concesiones.empresa_alta @nombre = 'Gestion Empresa 1 test', @tipo = 'tienda test', @cuit = '30123456789';
    DECLARE @ide INT = (SELECT TOP 1 id FROM concesiones.Empresa WHERE nombre = 'Gestion Empresa 1 test' ORDER BY id DESC);

    EXEC concesiones.concesion_registrar_gestion
        @empresa = 'Gestion Empresa 1 test',
        @tipo_empresa = 'tienda test',
        @cuit = '30123456789',
        @parque = 'Parque Gestion 1 test',
        @canon_mensual = 1000.00,
        @fecha_inicio = '2026-01-01';

    exec concesiones.canon_pagar_abonar 
        @empresa = 'Gestion Empresa 1 test',
        @parque = 'Parque Gestion 1 test',
        @fecha_inicio = '2026-01-01',
        @fecha_pago = '2026-10-10'


    DECLARE @idc INT = (SELECT TOP 1 id FROM concesiones.Concesion WHERE id_empresa = @ide ORDER BY id DESC);

    IF EXISTS (SELECT 1 FROM concesiones.Concesion WHERE id = @idc AND RTRIM(estado) = 'ACTIVO')
       AND EXISTS (SELECT 1 FROM concesiones.Canon_pagar WHERE id_concesion = @idc AND estado != 'PENDIENTE')
        PRINT 'OK - Test 6.2: concesion ACTIVO y primer canon Pagado.';
    ELSE
        PRINT 'FALLO - Test 6.2: no se genero la concesion o el canon esperados.';
END TRY
BEGIN CATCH
    PRINT 'FALLO - Test 6.2: error inesperado: ' + ERROR_MESSAGE();
END CATCH
IF @@trancount > 0 ROLLBACK;
GO

-- ============================================================
-- SECCION 7: GENERAR CUOTA MENSUAL DE CANON (canon_pagar_generar_cuota_mensual)
-- ============================================================
-------------------------------------------------------------------------------
-- TEST 7.1: Generacion exitosa de una nueva cuota
-- Esperado: se genera un canon PENDIENTE para la fecha de generacion indicada.
-------------------------------------------------------------------------------
PRINT '--- TEST 7.1: canon_pagar_generar_cuota_mensual (exito) ---';
BEGIN TRAN;
BEGIN TRY
    EXEC gestion.parque_alta 'Parque Cuota 1 test', 'Nacional test', '', 100;
    EXEC concesiones.empresa_alta @nombre = 'Cuota Empresa 1 test', @tipo = 'tienda test', @cuit = '30123456789';
    EXEC concesiones.concesion_alta @empresa = 'Cuota Empresa 1 test', @parque = 'Parque Cuota 1 test', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';

    EXEC concesiones.canon_pagar_generar_cuota_mensual
        @empresa = 'Cuota Empresa 1 test',
        @parque = 'Parque Cuota 1 test',
        @fecha_inicio = '2026-01-01',
        @fecha_generacion = '2026-02-01';
    
    DECLARE @ide INT = (SELECT TOP 1 id FROM concesiones.Empresa WHERE nombre = 'Cuota Empresa 1 test' ORDER BY id DESC);
    DECLARE @idc INT = (SELECT TOP 1 id FROM concesiones.Concesion WHERE id_empresa = @ide ORDER BY id DESC);

    IF EXISTS (SELECT 1 FROM concesiones.Canon_pagar WHERE id_concesion = @idc AND fecha_generacion = '2026-02-01' AND estado = 'PENDIENTE')
        PRINT 'OK - Test 7.1: cuota mensual generada en estado PENDIENTE.';
    ELSE
        PRINT 'FALLO - Test 7.1: no se genero la cuota esperada.';
END TRY
BEGIN CATCH
    PRINT 'FALLO - Test 7.1: error inesperado: ' + ERROR_MESSAGE();
END CATCH
IF @@trancount > 0 ROLLBACK;
GO

-------------------------------------------------------------------------------
-- TEST 7.2: Cuota duplicada para el mismo mes (debe fallar)
-- Esperado: el SP rechaza generar dos cuotas con la misma fecha de generacion.
-------------------------------------------------------------------------------
PRINT '--- TEST 7.2: canon_pagar_generar_cuota_mensual duplicada (debe fallar) ---';
BEGIN TRAN;
BEGIN TRY
    EXEC gestion.parque_alta 'Parque Cuota 2 test', 'Nacional test', '', 100;
    EXEC concesiones.empresa_alta @nombre = 'Cuota Empresa 2 test', @tipo = 'tienda test', @cuit = '30123456789';
    EXEC concesiones.concesion_alta @empresa = 'Cuota Empresa 2 test', @parque = 'Parque Cuota 2 test', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';

    EXEC concesiones.canon_pagar_generar_cuota_mensual @empresa = 'Cuota Empresa 2 test', @parque = 'Parque Cuota 2 test', @fecha_inicio = '2026-01-01', @fecha_generacion = '2026-02-01';
    EXEC concesiones.canon_pagar_generar_cuota_mensual @empresa = 'Cuota Empresa 2 test', @parque = 'Parque Cuota 2 test', @fecha_inicio = '2026-01-01', @fecha_generacion = '2026-02-01';
    PRINT 'FALLO - Test 7.2: se esperaba error por cuota duplicada y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 7.2: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
IF @@trancount > 0 ROLLBACK;
GO

-------------------------------------------------------------------------------
-- TEST 7.3: Concesion inexistente (debe fallar)
-- Esperado: el SP rechaza la operacion porque no encuentra la concesion.
-------------------------------------------------------------------------------
PRINT '--- TEST 7.3: canon_pagar_generar_cuota_mensual con concesion inexistente (debe fallar) ---';
BEGIN TRAN;
BEGIN TRY
    EXEC gestion.parque_alta 'Parque Cuota 3 test', 'Nacional test', '', 100;
    EXEC concesiones.empresa_alta @nombre = 'Cuota Empresa 3 test', @tipo = 'tienda test', @cuit = '30123456789';

    EXEC concesiones.canon_pagar_generar_cuota_mensual @empresa = 'Cuota Empresa 3 test', @parque = 'Parque Cuota 3 test', @fecha_inicio = '2026-01-01', @fecha_generacion = '2026-02-01';
    PRINT 'FALLO - Test 7.3: se esperaba error por concesion inexistente y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 7.3: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
IF @@trancount > 0 ROLLBACK;
GO

-- ============================================================
-- SECCION 8: CONSULTAR HISTORICO DE CANONES (consultar_historico_canones)
-- ============================================================
-------------------------------------------------------------------------------
-- TEST 8.1: Consulta exitosa
-- Esperado: devuelve todos los canones de la concesion (aqui, 2).
-- Se captura el result para poder asertar la cantidad.
-------------------------------------------------------------------------------
PRINT '--- TEST 8.1: consultar_historico_canones (exito) ---';
BEGIN TRAN;
BEGIN TRY
    EXEC gestion.parque_alta 'Parque Hist 1 test', 'Nacional test', '', 100;
    EXEC concesiones.empresa_alta @nombre = 'Hist Empresa 1 test', @tipo = 'tienda test', @cuit = '30123456789';
    EXEC concesiones.concesion_alta @empresa = 'Hist Empresa 1 test', @parque = 'Parque Hist 1 test', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
    -- primer canon
    EXEC concesiones.canon_pagar_alta @fecha_generacion = '2026-01-01', @empresa = 'Hist Empresa 1 test', @parque = 'Parque Hist 1 test', @fecha_inicio = '2026-01-01';
    -- segundo canon (otro mes)
    EXEC concesiones.canon_pagar_generar_cuota_mensual @empresa = 'Hist Empresa 1 test', @parque = 'Parque Hist 1 test', @fecha_inicio = '2026-01-01', @fecha_generacion = '2026-02-01';

    DECLARE @historico TABLE (id INT, fecha_generacion DATE, periodo VARCHAR(50), monto NUMERIC(10,2), estado VARCHAR(20), fecha_pagado DATE);
    INSERT INTO @historico
    EXEC concesiones.consultar_historico_canones @empresa = 'Hist Empresa 1 test', @parque = 'Parque Hist 1 test', @fecha_inicio = '2026-01-01';

    IF (SELECT COUNT(1) FROM @historico) = 2
        PRINT 'OK - Test 8.1: el historico devolvio los 2 canones esperados.';
    ELSE
        PRINT 'FALLO - Test 8.1: el historico no devolvio la cantidad esperada de canones.';
END TRY
BEGIN CATCH
    PRINT 'FALLO - Test 8.1: error inesperado: ' + ERROR_MESSAGE();
END CATCH
IF @@trancount > 0 ROLLBACK;
GO

-- ============================================================
-- SECCION 9: INGRESO DE VENTAS POR JSON (ingresar_venta / ingresar_ventas_masivo)
-- ============================================================

PRINT '=== INGRESO DE VENTAS POR JSON (tests comentados, ver nota) ===';
GO

  -- TEST 9.1: ingresar_venta (exito) - DESCOMENTAR SOLO TRAS CORREGIR EL BUCLE INFINITO
PRINT '--- TEST 9.1: ingresar_venta (exito) ---';
BEGIN TRAN;
BEGIN TRY
    EXEC gestion.parque_alta 'Parque JSON 1 test', 'Nacional test', '', 100;
    EXEC ventas.punto_de_venta_alta @parque = 'Parque JSON 1 test', @pov = 'Caja 1 test';
    EXEC ventas.metodo_de_pago_alta @descripcion = 'Efectivo test';
    EXEC ventas.tipo_visitante_alta @descripcion = 'Adulto test';
    EXEC ventas.tipo_entrada_alta @parque = 'Parque JSON 1 test', @tipo = 'Adulto test', @precio = 5000.00, @vigencia = '2026-01-01';

    DECLARE @json NVARCHAR(MAX) = N'{
        "parque":"Parque JSON 1 test",
        "fecha":"20260301",
        "pos":"Caja 1 test",
        "metodo":"Efectivo test",
        "items":[ {"concepto":"Adulto test","fecha_acceso":"20260301","cantidad":"2","precio":"5000"} ]
    }';

    EXEC ventas.ingresar_venta @venta = @json;

    IF EXISTS (SELECT 1 FROM ventas.venta v
               JOIN gestion.Parque p ON p.id = v.parque
               WHERE p.nombre = 'Parque JSON 1 test')
        PRINT 'OK - Test 9.1: la venta del JSON se registro.';
    ELSE
        PRINT 'FALLO - Test 9.1: no se registro la venta del JSON.';
END TRY
BEGIN CATCH
    PRINT 'FALLO - Test 9.1: error inesperado: ' + ERROR_MESSAGE();
END CATCH
IF @@trancount > 0 ROLLBACK;
GO
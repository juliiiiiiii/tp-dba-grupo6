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
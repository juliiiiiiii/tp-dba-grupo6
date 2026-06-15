-- Universidad: Universidad de la Matanza
-- Materia: Bases de Datos Aplicadas
 
-- Grupo 04
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
EXEC guia.sp_registrar_especialidad
	@descripcion = 'Cardiologia';
GO

-- TEST 1.2: Registro exitoso
PRINT '--- TEST 1.2: Registrar especialidad exitosamente ---';
EXEC guia.sp_registrar_especialidad
	@descripcion = 'Fauna silvestre';
GO

-- TEST 1.3: Registro exitoso
PRINT '--- TEST 1.3: Registrar especialidad exitosamente ---';
EXEC guia.sp_registrar_especialidad
	@descripcion = 'Flora nativa';
GO

-- TEST 1.4: Registro exitoso
PRINT '--- TEST 1.4: Registrar especialidad exitosamente ---';
EXEC guia.sp_registrar_especialidad
	@descripcion = 'Avistamiento de aves';
GO

-- TEST 1.5: Registro exitoso
PRINT '--- TEST 1.5: Registrar especialidad exitosamente ---';
EXEC guia.sp_registrar_especialidad
	@descripcion = 'Primeros auxilios en campo';
GO

-- TEST 1.6: Registro exitoso
PRINT '--- TEST 1.6: Registrar especialidad exitosamente ---';
EXEC guia.sp_registrar_especialidad
	@descripcion = 'Interpretación geológica';
GO

-- TEST 1.7: Especialidad duplicada (debe fallar)
PRINT '--- TEST 1.7: Especialidad ya registrada (debe fallar) ---';
EXEC guia.sp_registrar_especialidad
	@descripcion = 'Flora nativa';
GO

-- TEST 1.8: Descripción vacía (debe fallar)
PRINT '--- TEST 1.8: Descripción vacía (debe fallar) ---';
EXEC guia.sp_registrar_especialidad
	@descripcion = '';
GO

-- TEST 1.9: Descripción NULL (debe fallar)
PRINT '--- TEST 1.9: Descripción NULL (debe fallar) ---';
EXEC guia.sp_registrar_especialidad
	@descripcion = NULL;
GO

-- TEST 1.10: Descripción con solo espacios (debe fallar)
PRINT '--- TEST 1.10: Descripción con solo espacios (debe fallar) ---';
EXEC guia.sp_registrar_especialidad
	@descripcion = '   ';
GO

-- ============================================================
-- SECCION 2: ASIGNACION DE ESPECIALIZACION
-- ============================================================

PRINT '=== ASIGNACION DE ESPECIALIZACION ===';
GO

-- TEST 2.1: Especialidad inexistente (debe fallar)
PRINT '--- TEST 2.1: Especialidad no registrada (debe fallar) ---';
EXEC guia.sp_asignar_especializacion
	@dni = '25123456',
	@especialidad = 'Fauna marina';
GO

-- TEST 2.2: Especialidad NULL (debe fallar)
PRINT '--- TEST 2.2: Falta especificar la especialidad (debe fallar) ---';
EXEC guia.sp_asignar_especializacion
	@dni = '25123456',
	@especialidad = NULL;
GO

-- TEST 2.3: DNI NULL (debe fallar)
PRINT '--- TEST 2.3: Falta especificar el DNI del guía (debe fallar) ---';
EXEC guia.sp_asignar_especializacion
	@dni = NULL,
	@especialidad = 'Fauna silvestre';
GO

-- TEST 2.4: Asignación exitosa
PRINT '--- TEST 2.4: Asignar especialidad exitosamente ---';
EXEC guia.sp_asignar_especializacion
	@dni = '25123456',
	@especialidad = 'Fauna silvestre';
GO

-- TEST 2.5: Especialidad ya asignada al guía (debe fallar)
PRINT '--- TEST 2.5: El guía ya posee esa especialidad (debe fallar) ---';
EXEC guia.sp_asignar_especializacion
	@dni = '25123456',
	@especialidad = 'Fauna silvestre';
GO

-- TEST 2.6: Asignación exitosa
PRINT '--- TEST 2.6: Asignar especialidad exitosamente ---';
EXEC guia.sp_asignar_especializacion
	@dni = '25123456',
	@especialidad = 'Flora nativa';
GO

-- ============================================================
-- SECCION 3: ACTUALIZACION DE ACREDITACION
-- ============================================================

PRINT '=== ACTUALIZACION DE ACREDITACION ===';
GO

-- TEST 3.1: DNI NULL (debe fallar)
PRINT '--- TEST 3.1: Falta especificar el DNI del guía (debe fallar) ---';
EXEC guia.sp_actualizar_acreditacion
	@dni = NULL,
	@fecha_vencimiento_acreditacion = '2026-06-15';
GO

-- TEST 3.2: Guía inexistente (debe fallar)
PRINT '--- TEST 3.2: DNI no pertenece a ningún guía (debe fallar) ---';
EXEC guia.sp_actualizar_acreditacion
	@dni = '25128779',
	@fecha_vencimiento_acreditacion = '2026-06-15';
GO

-- TEST 3.3: Fecha de vencimiento NULL (debe fallar)
PRINT '--- TEST 3.3: Falta especificar la fecha de vencimiento (debe fallar) ---';
EXEC guia.sp_actualizar_acreditacion
	@dni = '38912345',
	@fecha_vencimiento_acreditacion = NULL;
GO

-- TEST 3.4: Actualización exitosa
PRINT '--- TEST 3.4: Actualizar acreditación exitosamente ---';
EXEC guia.sp_actualizar_acreditacion
	@dni = '25123456',
	@fecha_vencimiento_acreditacion = '2027-08-12';
GO

-- ============================================================
-- SECCION 4: ASIGNACION DE TITULACION A GUIA
-- ============================================================

PRINT '=== ASIGNACION DE TITULACION A GUIA ===';
GO

-- TEST 4.1: DNI NULL (debe fallar)
PRINT '--- TEST 4.1: Falta especificar el DNI del guía (debe fallar) ---';
EXEC guia.sp_asignar_titulacion_guia
	@dni = NULL,
	@descripcion = 'Especializado en flora nativa Argentina',
	@institucion = 'UNLAM',
	@fecha_emision = '2020-04-15';
GO

-- TEST 4.2: Descripción del título NULL (debe fallar)
PRINT '--- TEST 4.2: Falta especificar el título (debe fallar) ---';
EXEC guia.sp_asignar_titulacion_guia
	@dni = '25123456',
	@descripcion = NULL,
	@institucion = 'UNLAM',
	@fecha_emision = '2020-04-15';
GO

-- TEST 4.3: Institución NULL (debe fallar)
PRINT '--- TEST 4.3: Falta especificar la institución (debe fallar) ---';
EXEC guia.sp_asignar_titulacion_guia
	@dni = '25123456',
	@descripcion = 'Especializado en flora nativa Argentina',
	@institucion = NULL,
	@fecha_emision = '2020-04-15';
GO

-- TEST 4.4: Fecha de emisión NULL (debe fallar)
PRINT '--- TEST 4.4: Falta especificar la fecha de emisión (debe fallar) ---';
EXEC guia.sp_asignar_titulacion_guia
	@dni = '25123456',
	@descripcion = 'Especializado en flora nativa Argentina',
	@institucion = 'UNLAM',
	@fecha_emision = NULL;
GO

-- TEST 4.5: Asignación exitosa
PRINT '--- TEST 4.5: Asignar titulación exitosamente ---';
EXEC guia.sp_asignar_titulacion_guia
	@dni = '25123456',
	@descripcion = 'Especializado en flora nativa Argentina',
	@institucion = 'UNLAM',
	@fecha_emision = '2020-04-15';
GO

-- TEST 4.6: Título ya asignado al guía (debe fallar)
PRINT '--- TEST 4.6: El guía ya posee esa titulación (debe fallar) ---';
EXEC guia.sp_asignar_titulacion_guia
	@dni = '25123456',
	@descripcion = 'Especializado en flora nativa Argentina',
	@institucion = 'UNLAM',
	@fecha_emision = '2020-09-15';
GO

-- TEST 4.7: Asignación exitosa
PRINT '--- TEST 4.7: Asignar titulación exitosamente ---';
EXEC guia.sp_asignar_titulacion_guia
	@dni = '25123456',
	@descripcion = 'Licensiatura en fauna silvestre Argentina',
	@institucion = 'UBA',
	@fecha_emision = '2024-04-25';
GO

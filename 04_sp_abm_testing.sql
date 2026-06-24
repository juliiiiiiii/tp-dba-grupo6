-- Universidad: Universidad de la Matanza
-- Materia: Bases de Datos Aplicadas
 
-- Grupo 04
-- Integrantes:
--  De Bellis, Nahuel
--  Ocampo, Julian Rafael
--  Rodriguez, Gonzalo Ezequiel
--  Vargas, Tomas
 
-- Objetivo del script: Testing de SPs del esquema 'gestion'
-- Cubre altas, bajas y modificaciones de Parque, Guardaparque, Parque_asignado, Actividad, Guias y asignacion de guias
 
-- Fecha: 12/06/2026
 
USE parques_nacionales;
GO
 
-- ============================================================
-- SECCION 1: ALTA DE PARQUE
-- ============================================================
 
PRINT '=== ALTA DE PARQUE ===';
GO
 SELECT * from gestion.Parque
 
-- TEST 1.1: exitoso
PRINT '--- TEST 1.1: Registrar parque exitoso ---';
EXEC gestion.parque_alta
    @nombre    = 'Parque Nacional Iguazú',
    @tipo      = 'Nacional',
    @ubicacion = 'Misiones',
    @superficie = 67620;
GO
 
-- TEST 1.2: nombre duplicado
PRINT '--- TEST 1.2: Nombre de parque duplicado (debe fallar) ---';
BEGIN TRY
    EXEC gestion.parque_alta
    @nombre    = 'Parque Nacional Iguazú',
    @tipo      = 'Nacional',
    @ubicacion = 'Misiones',
    @superficie = 67620;
    PRINT 'FALLO - Test 1.2: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 1.2: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO
 
-- ============================================================
-- SECCION 2: ALTA DE GUARDAPARQUE
-- ============================================================
 
PRINT '=== ALTA DE GUARDAPARQUE ===';
GO
 
-- TEST 2.1: exitoso
PRINT '--- TEST 2.1: Registrar guardaparque exitoso ---';
EXEC gestion.guardaparque_alta
    @dni      = 30123456,
    @nombre   = 'Carlos',
    @apellido = 'Mendez';
 
-- Evidencia
SELECT id, dni, nombre, apellido, estado FROM gestion.Guardaparque WHERE dni = 30123456;
GO
 
-- TEST 2.2: DNI duplicado
PRINT '--- TEST 2.2: DNI duplicado (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guardaparque_alta
    @dni      = 30123456,
    @nombre   = 'Otro',
    @apellido = 'Nombre';
    PRINT 'FALLO - Test 2.2: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 2.2: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO
 
-- Registrar un segundo guardaparque para tests posteriores
EXEC gestion.guardaparque_alta
    @dni      = 40999888,
    @nombre   = 'Laura',
    @apellido = 'Gomez';
GO
 
-- ============================================================
-- SECCION 3: ASIGNACION DE GUARDAPARQUE
-- ============================================================
 
PRINT '=== ASIGNACION GUARDAPARQUE-PARQUE ===';
GO
 
-- TEST 3.1: exitoso
PRINT '--- TEST 3.1: Asignacion exitosa ---';
select * from gestion.guardaparque
select * from gestion.Parque_asignado
EXEC gestion.guardaparque_asignar
    @id_parque       = 2,
    @id_guardaparque = 1;
 
-- Evidencia: asignacion creada y guardaparque en estado Activo
SELECT pa.id, pa.id_parque, pa.id_guardaparque, pa.fecha_ingreso, pa.fecha_egreso, pa.motivo
FROM gestion.Parque_asignado pa WHERE pa.id_parque = 1;
 
SELECT id, nombre, estado FROM gestion.Guardaparque WHERE id = 1;
GO
 
-- TEST 3.2: parque inexistente
PRINT '--- TEST 3.2: Parque inexistente (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guardaparque_asignar
    @id_parque       = 999,
    @id_guardaparque = 2;
    PRINT 'FALLO - Test 3.2: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 3.2: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO
 
-- TEST 3.3: guardaparque inexistente y ya hay guardaparque en ese parque
PRINT '--- TEST 3.3: Guardaparque inexistente (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guardaparque_asignar
    @id_parque       = 1,
    @id_guardaparque = 999;
    PRINT 'FALLO - Test 3.3: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 3.3: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO
 
-- TEST 3.4: parque ya tiene guardaparque activo
PRINT '--- TEST 3.4: Parque ya ocupado (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guardaparque_asignar
    @id_parque       = 1,
    @id_guardaparque = 2;
    PRINT 'FALLO - Test 3.4: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 3.4: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO
 
-- TEST 3.5: guardaparque ya asignado en otro parque
-- Primero registramos un segundo parque
EXEC gestion.parque_alta
    @nombre    = 'Parque Nahuel Huapi',
    @tipo      = 'Nacional',
    @ubicacion = 'Rio Negro',
    @superficie = 717261;
GO
 
PRINT '--- TEST 3.5: Guardaparque ya asignado en otro parque (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guardaparque_asignar
    @id_parque       = 2,
    @id_guardaparque = 1   -- guardaparque 1 ya esta asignado al parque 1;
    PRINT 'FALLO - Test 3.5: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 3.5: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO
 
-- ============================================================
-- SECCION 4: ALTA DE ACTIVIDAD & TIPO
-- ============================================================
 
PRINT '=== ALTA DE ACTIVIDAD ===';
GO
 
-- TEST 4.0: creacion de tipo actividad exitoso
EXEC gestion.tipo_actividad_alta
    @descripcion = 'Atraccion gratuita';
GO

EXEC gestion.tipo_actividad_alta
    @descripcion = 'Tour guiado';
GO

-- TEST 4.1: exitoso
PRINT '--- TEST 4.1: Registrar actividad exitosa ---';
EXEC gestion.actividad_alta
    @id_parque   = 1,
    @id_guia     = 1,
    @nombre      = 'Trekking Cataratas',
    @descripcion = 'Caminata por circuito superior',
    @tipo        = 'Tour guiado',
    @costo       = 2500.00,
    @fecha       = '2026-08-15',
    @duracion    = 180,
    @cupo        = 20;
 
-- Evidencia
SELECT a.id, a.nombre, t.descripcion AS tipo, a.costo, a.fecha, a.duracion, a.cupo, a.estado
FROM gestion.Actividad a
INNER JOIN gestion.Tipo_actividad t ON a.id_tipo = t.id
WHERE nombre = 'Trekking Cataratas';
GO
 
-- TEST 4.2: parque inexistente
PRINT '--- TEST 4.2: Parque inexistente (debe fallar) ---';
BEGIN TRY
    EXEC gestion.actividad_alta
    @id_parque   = 999,
    @id_guia     = 1,
    @nombre      = 'Test',
    @descripcion = 'Test',
    @tipo        = 'Tour guiado',
    @costo       = 0,
    @fecha       = '2026-08-15',
    @duracion    = 60,
    @cupo        = 10;
    PRINT 'FALLO - Test 4.2: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 4.2: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 4.3: guia con acreditacion vencida
PRINT '--- TEST 4.3: Guia con acreditacion vencida (debe fallar) ---';
BEGIN TRY
    EXEC gestion.actividad_alta
    @id_parque   = 1,
    @id_guia     = 2,
    @nombre      = 'Test',
    @descripcion = 'Test',
    @tipo        = 'Tour guiado',
    @costo       = 0,
    @fecha       = '2026-08-15',
    @duracion    = 60,
    @cupo        = 10;
    PRINT 'FALLO - Test 4.3: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 4.3: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO
 
-- TEST 4.4: guia con acreditacion inactiva
PRINT '--- TEST 4.4: Guia con acreditacion inactiva (debe fallar) ---';
BEGIN TRY
    EXEC gestion.actividad_alta
    @id_parque   = 1,
    @id_guia     = 3,
    @nombre      = 'Test',
    @descripcion = 'Test',
    @tipo        = 'Tour guiado',
    @costo       = 0,
    @fecha       = '2026-08-15',
    @duracion    = 60,
    @cupo        = 10;
    PRINT 'FALLO - Test 4.4: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 4.4: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO
 
-- TEST 4.5: fecha pasada
PRINT '--- TEST 4.5: Fecha pasada (debe fallar) ---';
BEGIN TRY
    EXEC gestion.actividad_alta
    @id_parque   = 1,
    @id_guia     = 1,
    @nombre      = 'Test',
    @descripcion = 'Test',
    @tipo        = 'Tour guiado',
    @costo       = 0,
    @fecha       = '2020-01-01',
    @duracion    = 60,
    @cupo        = 10;
    PRINT 'FALLO - Test 4.5: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 4.5: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO
 
-- TEST 4.6: multiples errores en una sola llamada
PRINT '--- TEST 4.6: Multiples errores acumulados (debe mostrar todos juntos) ---';
BEGIN TRY
    EXEC gestion.actividad_alta
        @id_parque   = 999, -- parque no existe
        @id_guia     = 999, -- guia no existe
        @nombre      = 'Test',
        @descripcion = 'Test',
        @tipo        = 'Tour no guiado', -- tipo invalido
        @costo       = 0,
        @fecha       = '2020-01-01', -- fecha pasada
        @duracion    = 60,
        @cupo        = 10;
    PRINT 'FALLO - Test 4.6: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 4.6: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO
 
-- ============================================================
-- SECCION 5: BAJA DE GUARDAPARQUE
-- ============================================================
 
 -- TODO: test de baja
 select * from gestion.Parque
 EXEC gestion.parque_baja
    @id   = 2;

PRINT '=== BAJA DE GUARDAPARQUE ===';
GO
 
-- TEST 5.1: exitoso (con asignacion activa, debe cerrarla automaticamente)
PRINT '--- TEST 5.1: Baja de guardaparque con asignacion activa ---';
EXEC gestion.guardaparque_baja
    @id      = 1;
 
-- Evidencia: guardaparque inactivo y asignacion cerrada con fecha_egreso
SELECT id, nombre, estado FROM gestion.Guardaparque WHERE id = 1;
SELECT id, id_guardaparque, fecha_ingreso, fecha_egreso FROM gestion.Parque_asignado WHERE id_guardaparque = 1;
GO
 
-- TEST 5.2: guardaparque inexistente
PRINT '--- TEST 5.2: Guardaparque inexistente (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guardaparque_baja
    @id      = 999;
    PRINT 'FALLO - Test 5.2: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 5.2: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO
 
-- ============================================================
-- SECCION 6: MODIFICACION DE PARQUE
-- ============================================================
 
PRINT '=== MODIFICACION DE PARQUE ===';
GO
 
-- TEST 6.1: exitoso
select * from gestion.Parque
PRINT '--- TEST 6.1: Modificar parque exitoso ---';
EXEC gestion.parque_modificacion
    @id         = 2,
    @nombre     = 'Parque Nacional Iguazú',
    @tipo       = 'Nacional',
    @ubicacion  = 'Misiones',
    @superficie = 70000;
 
-- Evidencia
SELECT id, nombre, tipo, ubicacion, superficie FROM gestion.Parque WHERE id = 1;
GO
 
-- TEST 6.2: parque inexistente
PRINT '--- TEST 6.2: Parque inexistente (debe fallar) ---';
BEGIN TRY
    EXEC gestion.parque_modificacion
    @id         = 999,
    @nombre     = 'Test',
    @tipo       = 'Test',
    @ubicacion  = 'Test',
    @superficie = 100;
    PRINT 'FALLO - Test 6.2: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 6.2: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO
 
-- TEST 6.3: nombre en uso por otro parque
PRINT '--- TEST 6.3: Nombre duplicado en modificacion (debe fallar) ---';
BEGIN TRY
    EXEC gestion.parque_modificacion
    @id         = 2,
    @nombre     = 'Parque Nacional Iguazú',  -- nombre que ya usa el parque 1
    @tipo       = 'Nacional',
    @ubicacion  = 'Rio Negro',
    @superficie = 717261;
    PRINT 'FALLO - Test 6.3: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 6.3: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO
 
-- ============================================================
-- SECCION 7: MODIFICACION DE GUARDAPARQUE
-- ============================================================
 
PRINT '=== MODIFICACION DE GUARDAPARQUE ===';
GO
 
-- TEST 7.1: exitoso
PRINT '--- TEST 7.1: Modificar guardaparque exitoso ---';
EXEC gestion.guardaparque_modificacion
    @id       = 2,
    @nombre   = 'Laura Beatriz',
    @apellido = 'Gomez',
    @estado   = 'Inactivo';
 
-- Evidencia
SELECT id, nombre, apellido, estado FROM gestion.Guardaparque WHERE id = 2;
GO
 
-- TEST 7.2: estado invalido
PRINT '--- TEST 7.2: Estado invalido (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guardaparque_modificacion
    @id       = 2,
    @nombre   = 'Laura',
    @apellido = 'Gomez',
    @estado   = 'Suspendido';
    PRINT 'FALLO - Test 7.2: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 7.2: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO
 
-- ============================================================
-- SECCION 8: MODIFICACION DE ASIGNACION
-- ============================================================
 
PRINT '=== MODIFICACION DE ASIGNACION ===';
GO
 
-- Primero reasignamos el guardaparque 1 para tener una asignacion activa
EXEC gestion.guardaparque_asignar
    @id_parque       = 1,
    @id_guardaparque = 1;
GO
 
-- TEST 8.1: cerrar asignacion exitosamente
PRINT '--- TEST 8.1: Cerrar asignacion (egreso) exitoso ---';
EXEC gestion.asignacion_modificacion
    @id           = 2,   -- la nueva asignacion
    @motivo       = 'Fin de temporada';
 
-- Evidencia: asignacion con fecha_egreso y guardaparque en Inactivo
SELECT id, id_guardaparque, fecha_ingreso, fecha_egreso, motivo FROM gestion.Parque_asignado WHERE id = 2;
SELECT id, nombre, estado FROM gestion.Guardaparque WHERE id = 1;
GO
 
-- TEST 8.2: asignacion ya cerrada
PRINT '--- TEST 8.2: Asignacion ya cerrada (debe fallar) ---';
BEGIN TRY
    EXEC gestion.asignacion_modificacion
    @id           = 2,
    @motivo       = 'Test';
    PRINT 'FALLO - Test 8.2: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 8.2: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO
 
-- ============================================================
-- SECCION 9: MODIFICACION DE ACTIVIDAD
-- ============================================================
 
PRINT '=== MODIFICACION DE ACTIVIDAD ===';
GO
 
-- TEST 9.1: exitoso
PRINT '--- TEST 9.1: Modificar actividad exitosa ---';
EXEC gestion.actividad_modificacion
    @id          = 1,
    @id_guia     = 1,
    @nombre      = 'Trekking Cataratas Actualizado',
    @descripcion = 'Caminata por circuito superior e inferior',
    @tipo        = 'Tour guiado',
    @costo       = 3000.00,
    @fecha       = '2026-09-01',
    @duracion    = 240,
    @cupo        = 25,
    @estado = 'Programado';
 
-- Evidencia
SELECT id, nombre, costo, fecha, duracion, cupo, estado FROM gestion.Actividad WHERE id = 1;
GO
 
-- TEST 9.2: guia con acreditacion vencida
PRINT '--- TEST 9.2: Cambiar guia por uno con acreditacion vencida (debe fallar) ---';
BEGIN TRY
    EXEC gestion.actividad_modificacion
    @id          = 1,
    @id_guia     = 2,
    @nombre      = 'Test',
    @descripcion = 'Test',
    @tipo        = 'Tour guiado',
    @costo       = 0,
    @fecha       = '2026-09-01',
    @duracion    = 60,
    @cupo        = 10,
    @estado = 'Programado';
    PRINT 'FALLO - Test 9.2: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 9.2: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO
 
-- TEST 9.3: multiples errores en modificacion
PRINT '--- TEST 9.3: Multiples errores en modificacion (debe mostrar todos) ---';
BEGIN TRY
    EXEC gestion.actividad_modificacion
        @id          = 999,   -- no existe
        @id_guia     = 999,   -- no existe
        @nombre      = 'Test',
        @descripcion = 'Test',
        @tipo        = 'Tour guiado',
        @costo       = -100,       -- negativo
        @fecha       = '2020-01-01', -- pasada
        @duracion    = -1,         -- invalido
        @cupo        = 0,          -- invalido
        @estado = 'En espera'; --invalido
    PRINT 'FALLO - Test 9.3: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 9.3: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================================
-- SECCION 10: BAJA DE ACTIVIDAD
-- ============================================================

PRINT '=== BAJA DE ACTIVIDAD ===';
GO

-- TEST 10.1: exitoso (cancelar actividad programada)
PRINT '--- TEST 10.1: Baja de actividad exitosa ---';
EXEC gestion.actividad_baja
    @id     = 1,
    @motivo = 'Cancelada por condiciones climaticas';

-- Evidencia: estado debe ser 'Cancelado'
SELECT id, nombre, estado FROM gestion.Actividad WHERE id = 1;
GO

-- TEST 10.2: actividad inexistente
PRINT '--- TEST 10.2: Actividad inexistente (debe fallar) ---';
BEGIN TRY
    EXEC gestion.actividad_baja
    @id     = 999,
    @motivo = 'Test';
    PRINT 'FALLO - Test 10.2: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 10.2: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 10.3: actividad ya cancelada (debe fallar)
PRINT '--- TEST 10.3: Actividad ya cancelada (debe fallar) ---';
BEGIN TRY
    EXEC gestion.actividad_baja
    @id     = 1,
    @motivo = 'Intento duplicado';
    PRINT 'FALLO - Test 10.3: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 10.3: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================================
-- SECCION 11: ALTA DE GUIA
-- ============================================================

PRINT '=== ALTA DE GUIA ===';
GO

-- TEST 11.1: Registro exitoso
PRINT '--- TEST 11.1: Registrar guía exitosamente ---';
EXEC gestion.guia_alta
    @dni = '30456789',
    @nombre = 'Lucía',
    @apellido = 'Ferreyra',
    @fecha_vencimiento_acreditacion = '2026-12-31';
GO

-- TEST 11.2: Registro exitoso
PRINT '--- TEST 11.2: Registrar guía exitosamente ---';
EXEC gestion.guia_alta
    @dni = '25123456',
    @nombre = 'Marcos',
    @apellido = 'Villanueva',
    @fecha_vencimiento_acreditacion = '2025-06-13';
GO

-- TEST 11.3: DNI duplicado (debe fallar)
PRINT '--- TEST 11.3: DNI duplicado (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_alta
    @dni = '30456789',
    @nombre = 'Lucas',
    @apellido = 'Perez',
    @fecha_vencimiento_acreditacion = '2030-03-29';
    PRINT 'FALLO - Test 11.3: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 11.3: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 11.4: DNI duplicado y nombre inválido (debe fallar)
PRINT '--- TEST 11.4: DNI duplicado y falta de nombre/apellido (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_alta
    @dni = '30456789',
    @nombre = '',
    @apellido = 'Perez',
    @fecha_vencimiento_acreditacion = '2030-03-29';
    PRINT 'FALLO - Test 11.4: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 11.4: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 11.5: Formato de DNI inválido (debe fallar)
PRINT '--- TEST 11.5: DNI con formato inválido (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_alta
    @dni = 'ABC12',
    @nombre = 'Lucas',
    @apellido = 'Perez',
    @fecha_vencimiento_acreditacion = '2030-03-29';
    PRINT 'FALLO - Test 11.5: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 11.5: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 11.6: Apellido vacío (debe fallar)
PRINT '--- TEST 11.6: Falta apellido (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_alta
    @dni = '38912345',
    @nombre = 'Lucas',
    @apellido = '',
    @fecha_vencimiento_acreditacion = '2030-03-29';
    PRINT 'FALLO - Test 11.6: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 11.6: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 11.7: Apellido NULL (debe fallar)
PRINT '--- TEST 11.7: Apellido NULL (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_alta
    @dni = '38912345',
    @nombre = 'Lucas',
    @apellido = NULL,
    @fecha_vencimiento_acreditacion = '2030-03-29';
    PRINT 'FALLO - Test 11.7: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 11.7: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 11.8: Fecha de vencimiento NULL (debe fallar)
PRINT '--- TEST 11.8: Falta fecha de vencimiento de la acreditacion (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_alta
    @dni = '38912345',
    @nombre = 'Lucas',
    @apellido = 'Perez',
    @fecha_vencimiento_acreditacion = NULL;
    PRINT 'FALLO - Test 11.8: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 11.8: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 11.9: DNI NULL (debe fallar)
PRINT '--- TEST 11.9: Falta DNI (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_alta
    @dni = NULL,
    @nombre = 'Lucas',
    @apellido = 'Perez',
    @fecha_vencimiento_acreditacion = '2030-03-29';
    PRINT 'FALLO - Test 11.9: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 11.9: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 11.10: Registro exitoso
PRINT '--- TEST 11.10: Registrar guía exitosamente ---';
EXEC gestion.guia_alta
    @dni = '38912345',
    @nombre = 'Lucas',
    @apellido = 'Perez',
    @fecha_vencimiento_acreditacion = '2030-03-29';
GO

-- ============================================================
-- SECCION 12: ACTUALIZACION DE GUIA
-- ============================================================

PRINT '=== ACTUALIZACION DE GUIA ===';
GO

-- TEST 12.1: Actalizar exitoso
PRINT '--- TEST 12.1: Actalizar guía exitosamente ---';
EXEC gestion.guia_actualizar
    @dni = '30456789',
    @nombre = 'Luciano',
    @apellido = 'Fernandez';
GO

-- TEST 12.2: Actalizar exitoso
PRINT '--- TEST 12.2: Actalizar guía exitosamente ---';
EXEC gestion.guia_actualizar
    @dni = '25123456',
    @nombre = 'Marcos',
    @apellido = 'Villanueva';
GO

-- TEST 12.3: DNI sin guia (debe fallar)
PRINT '--- TEST 12.3: DNI sin guia (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_actualizar
    @dni = '32000000',
    @nombre = 'Lucas',
    @apellido = 'Perez';
    PRINT 'FALLO - Test 12.3: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 12.3: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 12.4: Nombre inválido (debe fallar)
PRINT '--- TEST 12.4: Falta de nombre/apellido (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_actualizar
    @dni = '30456789',
    @nombre = '',
    @apellido = 'Perez';
    PRINT 'FALLO - Test 12.4: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 12.4: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 12.6: Apellido vacío (debe fallar)
PRINT '--- TEST 12.6: Falta apellido (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_actualizar
    @dni = '38912345',
    @nombre = 'Lucas',
    @apellido = '';
    PRINT 'FALLO - Test 12.6: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 12.6: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 12.7: Apellido NULL (debe fallar)
PRINT '--- TEST 12.7: Apellido NULL (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_actualizar
    @dni = '38912345',
    @nombre = 'Lucas',
    @apellido = NULL;
    PRINT 'FALLO - Test 12.7: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 12.7: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 12.8: DNI NULL (debe fallar)
PRINT '--- TEST 12.8: Falta DNI (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_actualizar
    @dni = NULL,
    @nombre = 'Lucas',
    @apellido = 'Perez';
    PRINT 'FALLO - Test 12.8: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 12.8: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================================
-- SECCION 13: ASIGNACION DE GUIA A ACTIVIDAD
-- ============================================================

PRINT '=== ASIGNACION DE GUIA A ACTIVIDAD ===';
GO

PRINT '--- TEST 13.0: Registrar actividad exitosa ---';
EXEC gestion.actividad_alta
    @id_parque   = 1,
    @id_guia     = 1,
    @nombre      = 'Trekking Cataratas',
    @descripcion = 'Caminata por circuito superior',
    @tipo        = 'Tour guiado',
    @costo       = 2500.00,
    @fecha       = '2026-08-15',
    @duracion    = 180,
    @cupo        = 20;

-- TEST 13.1: Asignación exitosa
PRINT '--- TEST 13.1: Asignar guía exitosamente ---';
EXEC gestion.guia_asignar
@dni = '30456789',
@nombre_actividad = 'Trekking Cataratas',
@nombre_parque = 'Parque Nacional Iguazú',
@fecha_actividad = '2026-06-16 00:00:00',
@f_desde = '2026-06-14',
@f_hasta = '2026-06-17';
GO

-- TEST 13.2: Actividad inexistente en el parque (debe fallar)
PRINT '--- TEST 13.2: Actividad inexistente en el parque (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_asignar
    @dni = '30456789',
    @nombre_actividad = 'Trekking Cataratas',
    @nombre_parque = 'Parque Nahuel Huapi',
    @fecha_actividad = '2026-06-16 00:00:00',
    @f_desde = '2026-06-14',
    @f_hasta = '2026-06-17';
    PRINT 'FALLO - Test 13.2: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 13.2: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO
 
 -- TEST 13.3: DNI NULL (debe fallar)
PRINT '--- TEST 13.3: Falta especificar DNI del guía (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_asignar
    @dni = NULL,
    @nombre_actividad = 'Trekking Cataratas',
    @nombre_parque = 'Parque Nacional Iguazú',
    @fecha_actividad = '2026-06-16 00:00:00.000',
    @f_desde = '2026-06-14',
    @f_hasta = '2026-06-17';
    PRINT 'FALLO - Test 13.3: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 13.3: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 13.4: Guía inexistente (debe fallar)
PRINT '--- TEST 13.4: DNI de guía inexistente (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_asignar
    @dni = '11122345',
    @nombre_actividad = 'Trekking Cataratas',
    @nombre_parque = 'Parque Nacional Iguazú',
    @fecha_actividad = '2026-06-16 00:00:00.000',
    @f_desde = '2026-06-14',
    @f_hasta = '2026-06-17';
    PRINT 'FALLO - Test 13.4: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 13.4: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 13.5: Nombre de actividad inexistente (debe fallar)
PRINT '--- TEST 13.5: Actividad inexistente (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_asignar
    @dni = '30456789',
    @nombre_actividad = 'Escalda',
    @nombre_parque = 'Parque Nacional Iguazú',
    @fecha_actividad = '2026-06-16 00:00:00.000',
    @f_desde = '2026-06-14',
    @f_hasta = '2026-06-17';
    PRINT 'FALLO - Test 13.5: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 13.5: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 13.6: Fecha de actividad incorrecta (debe fallar)
PRINT '--- TEST 13.6: Fecha de actividad inexistente (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_asignar
    @dni = '30456789',
    @nombre_actividad = 'Trekking Cataratas',
    @nombre_parque = 'Parque Nacional Iguazú',
    @fecha_actividad = '2026-06-17 00:00:00.000',
    @f_desde = '2026-06-14',
    @f_hasta = '2026-06-17';
    PRINT 'FALLO - Test 13.6: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 13.6: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 13.7: Nombre de actividad NULL (debe fallar)
PRINT '--- TEST 13.7: Falta nombre de actividad (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_asignar
    @dni = '30456789',
    @nombre_actividad = NULL,
    @nombre_parque = 'Parque Nacional Iguazú',
    @fecha_actividad = '2026-06-16 00:00:00.000',
    @f_desde = '2026-06-14',
    @f_hasta = '2026-06-17';
    PRINT 'FALLO - Test 13.7: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 13.7: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 13.8: Fecha de actividad NULL (debe fallar)
PRINT '--- TEST 13.8: Falta fecha de actividad (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_asignar
    @dni = '30456789',
    @nombre_actividad = 'Trekking Cataratas',
    @nombre_parque = 'Parque Nacional Iguazú',
    @fecha_actividad = NULL,
    @f_desde = '2026-06-14',
    @f_hasta = '2026-06-17';
    PRINT 'FALLO - Test 13.8: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 13.8: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 13.9: Fecha desde NULL (debe fallar)
PRINT '--- TEST 13.9: Falta fecha desde (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_asignar
    @dni = '30456789',
    @nombre_actividad = 'Trekking Cataratas',
    @nombre_parque = 'Parque Nacional Iguazú',
    @fecha_actividad = '2026-06-16 00:00:00.000',
    @f_desde = NULL,
    @f_hasta = '2026-06-17';
    PRINT 'FALLO - Test 13.9: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 13.9: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 13.10: Fecha hasta NULL (debe fallar)
PRINT '--- TEST 13.10: Falta fecha hasta (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_asignar
    @dni = '30456789',
    @nombre_actividad = 'Trekking Cataratas',
    @nombre_parque = 'Parque Nacional Iguazú',
    @fecha_actividad = '2026-06-16 00:00:00.000',
    @f_desde = '2026-06-14',
    @f_hasta = NULL;
    PRINT 'FALLO - Test 13.10: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 13.10: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 13.11: Asignación duplicada (debe fallar)
PRINT '--- TEST 13.11: La actividad ya está asignada al guía (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_asignar
    @dni = '30456789',
    @nombre_actividad = 'Trekking Cataratas',
    @nombre_parque = 'Parque Nacional Iguazú',
    @fecha_actividad = '2026-06-16 00:00:00.000',
    @f_desde = '2026-06-14',
    @f_hasta = '2026-06-17';
    PRINT 'FALLO - Test 13.11: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 13.11: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 13.12: Guía con acreditación vencida (debe fallar)
PRINT '--- TEST 13.12: Guía con acreditación vencida (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guia_asignar
    @dni = '25123456',
    @nombre_actividad = 'Trekking Cataratas',
    @nombre_parque = 'Parque Nacional Iguazú',
    @fecha_actividad = '2026-06-16 00:00:00.000',
    @f_desde = '2026-06-14',
    @f_hasta = '2026-06-17';
    PRINT 'FALLO - Test 13.12: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 13.12: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================================
-- SECCION 14: Canon a pagar
-- ============================================================

-------------------------------------------------------------------------------
-- Test 14.1: Alta exito
-- Esperado: se crea un canon con estado 'PENDIENTE' y fecha_pagado NULL.
-------------------------------------------------------------------------------
print '--- Test 14.1: canon_pagar_alta (exito) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Test Canon 1', 'Test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Canon Test 1', @tipo = 'tienda', @cuit = '30123456789';
    declare @e1 int = (select top 1 id from concesiones.Empresa where nombre = 'Canon Test 1' order by id desc);
    exec concesiones.concesion_alta @empresa = 'Canon Test 1', @parque = 'Parque Test Canon 1', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
    declare @c1 int = (select top 1 id from concesiones.Concesion where id_empresa = @e1 order by id desc);

    exec concesiones.canon_pagar_alta @fecha_generacion = '2026-02-01', @empresa = 'Canon Test 1', @parque = 'Parque Test Canon 1', @fecha_inicio = '2026-01-01';

    select * from concesiones.Canon_pagar where id_concesion = @c1;

    if exists (select 1 from concesiones.Canon_pagar
               where id_concesion = @c1 and estado = 'PENDIENTE' and fecha_pagado is null and monto = 1000.00)
        print 'OK - Test 14.1: canon generado en estado PENDIENTE.';
    else
        print 'FALLO - Test 14.1: no se genero el canon esperado.';
end try
begin catch
    print 'FALLO - Test 14.1: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 14.2: Modificacion exito
-- Esperado: monto = 1500.00 y periodo = 'Enero 2026 (ajustado)'.
-------------------------------------------------------------------------------
print '--- Test 14.2: canon_pagar_modificacion (exito) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Test Canon 2', 'Test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Canon Test 2', @tipo = 'tienda', @cuit = '30123456789';
    declare @e2 int = (select top 1 id from concesiones.Empresa where nombre = 'Canon Test 2' order by id desc);
    exec concesiones.concesion_alta @empresa = 'Canon Test 2', @parque = 'Parque Test Canon 2', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
    declare @c2 int = (select top 1 id from concesiones.Concesion where id_empresa = @e2 order by id desc);
    exec concesiones.canon_pagar_alta @fecha_generacion = '2026-02-01', @empresa = 'Canon Test 2', @parque = 'Parque Test Canon 2', @fecha_inicio = '2026-01-01';

    exec concesiones.canon_pagar_modificacion @fecha_generacion = '2026-02-01', @periodo = 'Enero 2026 (ajustado)', @monto = 1500.00, @empresa = 'Canon Test 2', @parque = 'Parque Test Canon 2', @fecha_inicio = '2026-01-01';

    select * from concesiones.Canon_pagar where id_concesion = @c2;

    if exists (select 1 from concesiones.Canon_pagar where id_concesion = @c2 and monto = 1500.00 and periodo = 'Enero 2026 (ajustado)')
        print 'OK - Test 14.2: canon modificado correctamente.';
    else
        print 'FALLO - Test 14.2: la modificacion no quedo como se esperaba.';
end try
begin catch
    print 'FALLO - Test 14.2: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 14.3: Pagar exito
-- Esperado: estado pasa a 'PAGADO' y fecha_pagado = '2026-02-05'.
-------------------------------------------------------------------------------
print '--- Test 14.3: canon_pagar_abonar (exito) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Test Canon 3', 'Test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Canon Test 3', @tipo = 'tienda', @cuit = '30123456789';
    declare @e3 int = (select top 1 id from concesiones.Empresa where nombre = 'Canon Test 3' order by id desc);
    exec concesiones.concesion_alta @empresa = 'Canon Test 3', @parque = 'Parque Test Canon 3', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
    declare @c3 int = (select top 1 id from concesiones.Concesion where id_empresa = @e3 order by id desc);
    exec concesiones.canon_pagar_alta @fecha_generacion = '2026-02-01', @empresa = 'Canon Test 3', @parque = 'Parque Test Canon 3', @fecha_inicio = '2026-01-01';

    exec concesiones.canon_pagar_abonar @fecha_pago = '2026-02-05', @fecha_generacion = '2026-02-01', @empresa = 'Canon Test 3', @parque = 'Parque Test Canon 3', @fecha_inicio = '2026-01-01';

    select * from concesiones.Canon_pagar where id_concesion = @c3;

    if exists (select 1 from concesiones.Canon_pagar where id_concesion = @c3 and estado = 'PAGADO' and fecha_pagado = '2026-02-05')
        print 'OK - Test 14.3: canon marcado como PAGADO.';
    else
        print 'FALLO - Test 14.3: el pago no se registro como se esperaba.';
end try
begin catch
    print 'FALLO - Test 14.3: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 14.4: Baja exito
-- Esperado: el canon queda con estado 'INVALIDO'.
-------------------------------------------------------------------------------
print '--- Test 14.4: canon_pagar_baja (exito, baja logica) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Test Canon 4', 'Test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Canon Test 4', @tipo = 'tienda', @cuit = '30123456789';
    declare @e4 int = (select top 1 id from concesiones.Empresa where nombre = 'Canon Test 4' order by id desc);
    exec concesiones.concesion_alta @empresa = 'Canon Test 4', @parque = 'Parque Test Canon 4', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
    declare @c4 int = (select top 1 id from concesiones.Concesion where id_empresa = @e4 order by id desc);
    exec concesiones.canon_pagar_alta @fecha_generacion = '2026-02-01', @empresa = 'Canon Test 4', @parque = 'Parque Test Canon 4', @fecha_inicio = '2026-01-01';

    exec concesiones.canon_pagar_baja @fecha_generacion = '2026-02-01', @empresa = 'Canon Test 4', @parque = 'Parque Test Canon 4', @fecha_inicio = '2026-01-01';

    if exists (select 1 from concesiones.Canon_pagar where id_concesion = @c4 and estado = 'INVALIDO')
        print 'OK - Test 4: el canon quedo INVALIDO (baja logica).';
    else
        print 'FALLO - Test 14.4: la baja logica no se aplico.';
end try
begin catch
    print 'FALLO - Test 14.4: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 14.5: Empresa inexistente
-- Esperado: el SP rechaza la operacion porque no encuentra la empresa.
-------------------------------------------------------------------------------
print '--- Test 14.5: canon_pagar_alta con empresa inexistente (validacion) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Test Canon 5', 'Test', '', 100.00;

    exec concesiones.canon_pagar_alta @fecha_generacion = '2026-02-01', @empresa = 'Empresa inexistente', @parque = 'Parque Test Canon 5', @fecha_inicio = '2026-01-01';
    print 'FALLO - Test 14.5: se esperaba error por empresa inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 14.5: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 14.6: Parque inexistente
-- Esperado: el SP rechaza la operacion porque no encuentra el parque.
-------------------------------------------------------------------------------
print '--- Test 14.6: canon_pagar_alta con parque inexistente (validacion) ---';
begin tran;
begin try
    exec concesiones.empresa_alta @nombre = 'Canon Test 6', @tipo = 'tienda', @cuit = '30123456789';

    exec concesiones.canon_pagar_alta @fecha_generacion = '2026-02-01', @empresa = 'Canon Test 6', @parque = 'Parque inexistente', @fecha_inicio = '2026-01-01';
    print 'FALLO - Test 14.6: se esperaba error por parque inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 14.6: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 14.7: Concesion inexistente
-- Esperado: el SP rechaza la operacion porque no encuentra la concesion para
--           la empresa, parque y fecha de inicio indicados.
-------------------------------------------------------------------------------
print '--- Test 14.7: canon_pagar_alta con concesion inexistente (validacion) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Test Canon 7', 'Test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Canon Test 7', @tipo = 'tienda', @cuit = '30123456789';

    exec concesiones.canon_pagar_alta @fecha_generacion = '2026-02-01', @empresa = 'Canon Test 7', @parque = 'Parque Test Canon 7', @fecha_inicio = '2026-01-01';
    print 'FALLO - Test 14.7: se esperaba error por concesion inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 14.7: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-- ============================================================
-- SECCION 15: Concesion
-- ============================================================

-------------------------------------------------------------------------------
-- Test 15.1: Alta exito
-- Esperado: se crea una Concesion con estado 'ACTIVO' para la empresa creada.
-------------------------------------------------------------------------------
print '--- Test 15.1: concesion_alta (exito) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Test Concesion 1', 'Test', '', 100.00;
    declare @idParque1 int = (select top 1 id from gestion.Parque where nombre = 'Parque Test Concesion 1');

    exec concesiones.empresa_alta @nombre = 'Concesionaria Test 1', @tipo = 'restaurante', @cuit = '30123456789';
    declare @idEmp1 int = (select top 1 id from concesiones.Empresa where nombre = 'Concesionaria Test 1');

    exec concesiones.concesion_alta @empresa = 'Concesionaria Test 1', @parque = 'Parque Test Concesion 1', @canon_mensual = 1500.00, @fecha_inicio = '2026-01-01';

    select * from concesiones.Concesion where id_empresa = @idEmp1;

    if exists (select 1 from concesiones.Concesion
               where id_empresa = @idEmp1
                 and id_parque = @idParque1
                 and fecha_inicio = '2026-01-01'
                 and rtrim(estado) = 'ACTIVO'
                 and canon_mensual = 1500.00)
        print 'OK - Test 15.1: concesion creada con estado ACTIVO.';
    else
        print 'FALLO - Test 15.1: no se creo la concesion esperada.';
end try
begin catch
    print 'FALLO - Test 15.1: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 15.2: Modificacion exito
-- Esperado: cambia canon, estado y fecha_fin buscando por empresa/parque/fecha.
-------------------------------------------------------------------------------
print '--- Test 15.2: sp_modificacion_concesion (exito) ---';
begin tran;
begin try
     exec gestion.parque_alta 'Parque Test Concesion 2', 'Test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Concesionaria Test 2', @tipo = 'tienda', @cuit = '30123456789';
    declare @idEmp2 int = (select top 1 id from concesiones.Empresa where nombre = 'Concesionaria Test 2' order by id desc);
    exec concesiones.concesion_alta @empresa = 'Concesionaria Test 2', @parque = 'Parque Test Concesion 2', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
    declare @idCon2 int = (select top 1 id from concesiones.Concesion where id_empresa = @idEmp2 order by id desc);

    exec concesiones.sp_modificacion_concesion @empresa = 'Concesionaria Test 2', @parque = 'Parque Test Concesion 2', @fecha_inicio = '2026-01-01', @fecha_fin = '2026-12-31', @estado = 'INACTIVO', @canon = 999.99;

    select * from concesiones.Concesion where id = @idCon2;

    if exists (select 1 from concesiones.Concesion
               where id = @idCon2
                 and canon_mensual = 999.99
                 and rtrim(estado) = 'INACTIVO'
                 and fecha_fin = '2026-12-31')
        print 'OK - Test 15.2: concesion modificada correctamente.';
    else
        print 'FALLO - Test 15.2: la modificacion no quedo como se esperaba.';
end try
begin catch
    print 'FALLO - Test 15.2: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 15.3: Baja exito
-- Esperado: la concesion queda con estado 'INACTIVO'.
-------------------------------------------------------------------------------
print '--- Test 15.3: sp_baja_concesion (exito, baja logica) ---';
begin tran;
begin try
        exec gestion.parque_alta 'Parque Test Concesion 3', 'Test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Concesionaria Test 3', @tipo = 'tienda', @cuit = '30123456789';
    declare @idEmp3 int = (select top 1 id from concesiones.Empresa where nombre = 'Concesionaria Test 3' order by id desc);
    exec concesiones.concesion_alta @empresa = 'Concesionaria Test 3', @parque = 'Parque Test Concesion 3', @canon_mensual = 1200.00, @fecha_inicio = '2026-01-01';
    declare @idCon3 int = (select top 1 id from concesiones.Concesion where id_empresa = @idEmp3 order by id desc);

    exec concesiones.sp_baja_concesion @empresa = 'Concesionaria Test 3', @parque = 'Parque Test Concesion 3', @fecha_inicio = '2026-01-01';

    if exists (select 1 from concesiones.Concesion where id = @idCon3 and estado = 'INACTIVO')
        print 'OK - Test 15.3: la concesion quedo INACTIVO (baja logica).';
    else
        print 'FALLO - Test 15.3: la baja logica no se aplico.';
end try
begin catch
    print 'FALLO - Test 15.3: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 15.4: Alta con canon mensual negativo
-- Esperado: el SP rechaza la operacion y no inserta ninguna concesion.
-------------------------------------------------------------------------------
print '--- Test 15.4: concesion_alta con canon negativo (validacion) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Test Concesion 4', 'Test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Concesionaria Test 4', @tipo = 'tienda', @cuit = '30123456789';
    declare @idEmp4 int = (select top 1 id from concesiones.Empresa where nombre = 'Concesionaria Test 4' order by id desc);

    exec concesiones.concesion_alta @empresa = 'Concesionaria Test 4', @parque = 'Parque Test Concesion 4', @canon_mensual = -50.00, @fecha_inicio = '2026-01-01';
    print 'FALLO - Test 15.4: se esperaba error por canon negativo y no ocurrio.';
end try
begin catch
    if not exists (select 1 from concesiones.Concesion where id_empresa = @idEmp4)
        print 'OK - Test 15.4: rechazado como se esperaba. Detalle: ' + error_message();
    else
        print 'FALLO - Test 15.4: se inserto una concesion pese al canon negativo.';
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 15.5: Alta con empresa inexistente
-- Esperado: el SP rechaza la operacion porque no encuentra la empresa.
-------------------------------------------------------------------------------
print '--- Test 15.5: concesion_alta con empresa inexistente (validacion) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Test Concesion 5', 'Test', '', 100.00;

    exec concesiones.concesion_alta @empresa = 'Empresa inexistente', @parque = 'Parque Test Concesion 5', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
    print 'FALLO - Test 15.5: se esperaba error por empresa inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 15.5: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 15.6: Alta con parque inexistente
-- Esperado: el SP rechaza la operacion porque no encuentra el parque.
-------------------------------------------------------------------------------
print '--- Test 15.6: concesion_alta con parque inexistente (validacion) ---';
begin tran;
begin try
    exec concesiones.empresa_alta @nombre = 'Concesionaria Test 6', @tipo = 'tienda', @cuit = '30123456789';

    exec concesiones.concesion_alta @empresa = 'Concesionaria Test 6', @parque = 'Parque inexistente', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
    print 'FALLO - Test 15.6: se esperaba error por parque inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 15.6: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 15.7: Baja con concesion inexistente
-- Esperado: el SP rechaza la operacion porque no encuentra la concesion.
-------------------------------------------------------------------------------
print '--- Test 15.7: sp_baja_concesion con concesion inexistente (validacion) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Test Concesion 7', 'Test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Concesionaria Test 7', @tipo = 'tienda', @cuit = '30123456789';

    exec concesiones.sp_baja_concesion @empresa = 'Concesionaria Test 7', @parque = 'Parque Test Concesion 7', @fecha_inicio = '2026-01-01';
    print 'FALLO - Test 15.7: se esperaba error por concesion inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 15.7: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 15.8: Modificacion con estado invalido
-- Esperado: el constraint check_estado_concesion rechaza el update.
-------------------------------------------------------------------------------
print '--- Test 15.8: sp_modificacion_concesion con estado invalido (validacion) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Test Concesion 8', 'Test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Concesionaria Test 8', @tipo = 'tienda', @cuit = '30123456789';
    exec concesiones.concesion_alta @empresa = 'Concesionaria Test 8', @parque = 'Parque Test Concesion 8', @canon_mensual = 800.00, @fecha_inicio = '2026-01-01';

    exec concesiones.sp_modificacion_concesion @empresa = 'Concesionaria Test 8', @parque = 'Parque Test Concesion 8', @fecha_inicio = '2026-01-01', @estado = 'RARO';
    print 'FALLO - Test 15.8: se esperaba error de CHECK por estado invalido y no ocurrio.';
end try
begin catch
    print 'OK - Test 15.8: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 15.9: Modificacion con empresa nueva inexistente
-- Esperado: el SP rechaza la operacion porque no encuentra la empresa nueva.
-------------------------------------------------------------------------------
print '--- Test 15.9: sp_modificacion_concesion con empresa nueva inexistente (validacion) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Test Concesion 9', 'Test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Concesionaria Test 9', @tipo = 'tienda', @cuit = '30123456789';
    exec concesiones.concesion_alta @empresa = 'Concesionaria Test 9', @parque = 'Parque Test Concesion 9', @canon_mensual = 800.00, @fecha_inicio = '2026-01-01';

    exec concesiones.sp_modificacion_concesion @empresa = 'Concesionaria Test 9', @parque = 'Parque Test Concesion 9', @fecha_inicio = '2026-01-01', @empresa_nueva = 'Empresa nueva inexistente';
    print 'FALLO - Test 15.9: se esperaba error por empresa nueva inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 15.9: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 15.10: Modificacion con parque nuevo inexistente
-- Esperado: el SP rechaza la operacion porque no encuentra el parque nuevo.
-------------------------------------------------------------------------------
print '--- Test 15.10: sp_modificacion_concesion con parque nuevo inexistente (validacion) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Test Concesion 10', 'Test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Concesionaria Test 10', @tipo = 'tienda', @cuit = '30123456789';
    exec concesiones.concesion_alta @empresa = 'Concesionaria Test 10', @parque = 'Parque Test Concesion 10', @canon_mensual = 800.00, @fecha_inicio = '2026-01-01';

    exec concesiones.sp_modificacion_concesion @empresa = 'Concesionaria Test 10', @parque = 'Parque Test Concesion 10', @fecha_inicio = '2026-01-01', @parque_nuevo = 'Parque nuevo inexistente';
    print 'FALLO - Test 15.10: se esperaba error por parque nuevo inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 15.10: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;


-- ============================================================
-- SECCION 16: Empresa
-- ============================================================


-------------------------------------------------------------------------------
-- Test 16.1: Alta exito
-- Esperado: se inserta una empresa con los datos dados. EXISTS = verdadero.
-------------------------------------------------------------------------------
print '--- Test 16.1: empresa_alta (exito) ---';
begin tran;
begin try
    exec concesiones.empresa_alta @nombre = 'Resto del Lago SA', @tipo = 'restaurante', @cuit = '30123456789';

    -- evidencia
    select * from concesiones.Empresa where nombre = 'Resto del Lago SA';

    if exists (select 1 from concesiones.Empresa where nombre = 'Resto del Lago SA' and cuit = '30123456789')
        print 'OK - Test 16.1: empresa dada de alta correctamente.';
    else
        print 'FALLO - Test 16.1: no se encontro la empresa esperada.';
end try
begin catch
    print 'FALLO - Test 16.1: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 16.2: Modificacion exito
-- Esperado: nombre cambia a 'Resto del Lago SRL'; tipo y cuit quedan igual.
-------------------------------------------------------------------------------
print '--- Test 16.2: empresa_modifiacion (exito, modificacion parcial) ---';
begin tran;
begin try
    exec concesiones.empresa_alta @nombre = 'Empresa 1', @tipo = 'restaurante', @cuit = '30123456789';
    declare @idEmp int = (select top 1 id from concesiones.Empresa where nombre = 'Empresa 1' order by id desc);

    exec concesiones.empresa_modifiacion @nombre = 'Empresa 1', @nuevo_nombre = 'Empresa 2';

    select * from concesiones.Empresa where id = @idEmp;

    if exists (select 1 from concesiones.Empresa
               where id = @idEmp and nombre = 'Empresa 2'
                 and tipo = 'restaurante' and cuit = '30123456789')
        print 'OK - Test 16.2: modificacion parcial respeto los campos no enviados.';
    else
        print 'FALLO - Test 16.2: la modificacion no quedo como se esperaba.';
end try
begin catch
    print 'FALLO - Test 16.2: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 16.3: Baja exito (delete fisico)
-- Esperado: la empresa deja de existir tras empresa_baja.
-------------------------------------------------------------------------------
print '--- Test 16.3: empresa_baja (exito) ---';
begin tran;
begin try
    exec concesiones.empresa_alta @nombre = 'Empresa a Borrar', @tipo = 'tienda', @cuit = '30999999998';
    declare @idBaja int = (select top 1 id from concesiones.Empresa where nombre = 'Empresa a Borrar' order by id desc);

    exec concesiones.empresa_baja @nombre = 'Empresa a Borrar';

    if not exists (select 1 from concesiones.Empresa where id = @idBaja)
        print 'OK - Test 16.3: la empresa fue eliminada.';
    else
        print 'FALLO - Test 16.3: la empresa todavia existe.';
end try
begin catch
    print 'FALLO - Test 16.3: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 16.4: CUIT con formato invalido
-- Esperado: el SP o el constraint check_cuit_formato rechaza el insert.
-------------------------------------------------------------------------------
print '--- Test 16.4: empresa_alta con CUIT invalido (validacion) ---';
begin tran;
begin try
    exec concesiones.empresa_alta @nombre = 'CUIT Malo', @tipo = 'tienda', @cuit = '123';
    print 'FALLO - Test 16.4: se esperaba un error de CHECK por CUIT invalido y no ocurrio.';
end try
begin catch
    print 'OK - Test 16.4: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 16.5: nombre NULL
-- Esperado: el insert falla por la restriccion NOT NULL de nombre.
-------------------------------------------------------------------------------
print '--- Test 16.5: empresa_alta con nombre NULL (validacion) ---';
begin tran;
begin try
    exec concesiones.empresa_alta @nombre = null, @tipo = 'tienda', @cuit = '30123456789';
    print 'FALLO - Test 16.5: se esperaba error por nombre NULL y no ocurrio.';
end try
begin catch
    print 'OK - Test 16.5: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 6: nombre duplicado
-- Esperado: el alta falla por la restriccion UNIQUE de nombre.
-------------------------------------------------------------------------------
print '--- Test 16.6: empresa_alta con nombre duplicado (validacion) ---';
begin tran;
begin try
    exec concesiones.empresa_alta @nombre = 'Empresa Duplicada', @tipo = 'tienda', @cuit = '30123456789';
    exec concesiones.empresa_alta @nombre = 'Empresa Duplicada', @tipo = 'tienda', @cuit = '30123456780';
    print 'FALLO - Test 16.6: se esperaba error por nombre duplicado y no ocurrio.';
end try
begin catch
    print 'OK - Test 16.6: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 16.7: Baja con empresa inexistente
-- Esperado: el SP rechaza la operacion porque no encuentra la empresa.
-------------------------------------------------------------------------------
print '--- Test 16.7: empresa_baja con empresa inexistente (validacion) ---';
begin tran;
begin try
    exec concesiones.empresa_baja @nombre = 'Empresa inexistente';
    print 'FALLO - Test 16.7: se esperaba error por empresa inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 16.7: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 8: Modificacion con empresa inexistente
-- Esperado: el SP rechaza la operacion porque no encuentra la empresa.
-------------------------------------------------------------------------------
print '--- Test 16.8: empresa_modifiacion con empresa inexistente (validacion) ---';
begin tran;
begin try
    exec concesiones.empresa_modifiacion @nombre = 'Empresa inexistente', @nuevo_nombre = 'Empresa Nueva';
    print 'FALLO - Test 16.8: se esperaba error por empresa inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 16.8: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 9: Modificacion con nombre nuevo duplicado
-- Esperado: el SP rechaza la operacion porque el nombre nuevo ya existe.
-------------------------------------------------------------------------------
print '--- Test 16.9: empresa_modifiacion con nombre duplicado (validacion) ---';
begin tran;
begin try
    exec concesiones.empresa_alta @nombre = 'Empresa Original', @tipo = 'tienda', @cuit = '30123456789';
    exec concesiones.empresa_alta @nombre = 'Empresa Existente', @tipo = 'tienda', @cuit = '30123456780';

    exec concesiones.empresa_modifiacion @nombre = 'Empresa Original', @nuevo_nombre = 'Empresa Existente';
    print 'FALLO - Test 16.9: se esperaba error por nombre duplicado y no ocurrio.';
end try
begin catch
    print 'OK - Test 16.9: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;
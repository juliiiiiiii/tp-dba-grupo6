-- Universidad: Universidad de la Matanza
-- Materia: Bases de Datos Aplicadas
 
-- Grupo 06
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
 
 exec gestion.ubicacion_alta 'Misiones test'
 exec gestion.ubicacion_alta 'Rio Negro test'

-- TEST 1.1: exitoso
PRINT '--- TEST 1.1: Registrar parque exitoso ---';
EXEC gestion.parque_alta
    @nombre    = 'Parque Nacional Iguazu test',
    @tipo      = 'Nacional test',
    @ubicacion = 'Misiones test',
    @superficie = 67620;
GO
SELECT * from gestion.Parque

 
-- TEST 1.2: nombre duplicado
PRINT '--- TEST 1.2: Nombre de parque duplicado (debe fallar) ---';
BEGIN TRY
    EXEC gestion.parque_alta
    @nombre    = 'Parque Nacional Iguazu test',
    @tipo      = 'Nacional test',
    @ubicacion = 'Misiones test',
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
EXEC personal.Guardaparque_alta
    @dni      = 30123456,
    @nombre   = 'Carlos test',
    @apellido = 'Mendez test';
 
-- Evidencia
SELECT id, dni, nombre, apellido, estado FROM personal.Guardaparque WHERE dni = 30123456;
GO
 
-- TEST 2.2: DNI duplicado
PRINT '--- TEST 2.2: DNI duplicado (debe fallar) ---';
BEGIN TRY
    EXEC personal.Guardaparque_alta
    @dni      = 30123456,
    @nombre   = 'Otro test',
    @apellido = 'Nombre test';
    PRINT 'FALLO - Test 2.2: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 2.2: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO
 
-- Registrar un segundo guardaparque para tests posteriores
EXEC personal.Guardaparque_alta
    @dni      = 40999888,
    @nombre   = 'Laura test',
    @apellido = 'Gomez test';
GO
 
-- ============================================================
-- SECCION 3: ASIGNACION DE GUARDAPARQUE
-- ============================================================
 
PRINT '=== ASIGNACION GUARDAPARQUE-PARQUE ===';
GO
 
-- TEST 3.1: exitoso
PRINT '--- TEST 3.1: Asignacion exitosa ---';
select * from personal.Guardaparque
select * from gestion.Parque_asignado
EXEC gestion.guardaparque_asignar
    @id_parque = 2,
    @id_guardaparque = 1;
 
-- Evidencia: asignacion creada y guardaparque en estado Activo
SELECT pa.id, pa.id_parque, pa.id_guardaparque, pa.fecha_ingreso, pa.fecha_egreso, pa.motivo
FROM gestion.Parque_asignado pa WHERE pa.id_parque = 1;
 
SELECT id, nombre, estado FROM personal.Guardaparque WHERE id = 1;
GO
 
-- TEST 3.2: parque inexistente
PRINT '--- TEST 3.2: Parque inexistente (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guardaparque_asignar
    @id_parque = 999,
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
    @id_parque = 1,
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
    @id_parque = 1,
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
    @nombre    = 'Parque Nahuel Huapi test',
    @tipo      = 'Nacional test',
    @ubicacion = 'Rio Negro test',
    @superficie = 717261;
GO
 
PRINT '--- TEST 3.5: Guardaparque ya asignado en otro parque (debe fallar) ---';
BEGIN TRY
    EXEC gestion.guardaparque_asignar
    @id_parque = 2,
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
    @descripcion = 'Atraccion gratuita test';
GO

EXEC gestion.tipo_actividad_alta
    @descripcion = 'Tour guiado test';
GO

-- TEST 4.1: exitoso
PRINT '--- TEST 4.1: Registrar actividad exitosa ---';
EXEC gestion.actividad_alta
    @nombre_parque = 'Parque Nacional Iguazu test',
    @dni_guia = '35111222',
    @nombre      = 'Trekking Cataratas test',
    @descripcion = 'Caminata por circuito superior test',
    @tipo        = 'Tour guiado test',
    @costo       = 2500.00,
    @fecha       = '2026-08-15',
    @duracion    = 180,
    @cupo        = 20;
 
-- Evidencia
SELECT a.id, a.nombre, t.descripcion AS tipo, a.costo, a.fecha, a.duracion, a.cupo, a.estado
FROM gestion.Actividad a
INNER JOIN gestion.Tipo_actividad t ON a.id_tipo = t.id
WHERE nombre = 'Trekking Cataratas test';
GO
 
-- TEST 4.2: parque inexistente
PRINT '--- TEST 4.2: Parque inexistente (debe fallar) ---';
BEGIN TRY
    EXEC gestion.actividad_alta
    @nombre_parque = 'Parque inexistente test',
    @dni_guia = '35111222',
    @descripcion = 'Test test',
    @tipo        = 'Tour guiado test',
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
    @nombre_parque = 'Parque Nacional Iguazu test',
    @dni_guia = '25123456',
    @descripcion = 'Test test',
    @tipo        = 'Tour guiado test',
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
    @nombre_parque = 'Parque Nacional Iguazu test',
    @dni_guia = '38912345',
    @descripcion = 'Test test',
    @tipo        = 'Tour guiado test',
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
    @nombre_parque = 'Parque Nacional Iguazu test',
    @dni_guia = '35111222',
    @descripcion = 'Test test',
    @tipo        = 'Tour guiado test',
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
        @nombre_parque = 'Parque inexistente test', -- parque no existe
        @dni_guia = '99999999', -- guia no existe
        @descripcion = 'Test test',
        @tipo        = 'Tour no guiado test', -- tipo invalido
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
    @nombre = 'Parque Nahuel Huapi test';

PRINT '=== BAJA DE GUARDAPARQUE ===';
GO
 
-- TEST 5.1: exitoso (con asignacion activa, debe cerrarla automaticamente)
PRINT '--- TEST 5.1: Baja de guardaparque con asignacion activa ---';
EXEC personal.Guardaparque_baja
    @dni = 30123456;
 
-- Evidencia: guardaparque inactivo y asignacion cerrada con fecha_egreso
SELECT id, nombre, estado FROM personal.Guardaparque WHERE id = 1;
SELECT id, id_guardaparque, fecha_ingreso, fecha_egreso FROM gestion.Parque_asignado WHERE id_guardaparque = 1;
GO
 
-- TEST 5.2: guardaparque inexistente
PRINT '--- TEST 5.2: Guardaparque inexistente (debe fallar) ---';
BEGIN TRY
    EXEC personal.Guardaparque_baja
    @dni = 99999999;
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
    @nombre     = 'Parque Nacional Iguazu test',
    @tipo       = 'Nacional test',
    @ubicacion  = 'Misiones test',
    @superficie = 70000;
 
-- Evidencia
SELECT id, nombre, tipo, ubicacion, superficie FROM gestion.Parque WHERE id = 1;
GO
 
-- TEST 6.2: parque inexistente
PRINT '--- TEST 6.2: Parque inexistente (debe fallar) ---';
BEGIN TRY
    EXEC gestion.parque_modificacion
    @nombre = 'Parque inexistente test',
    @tipo       = 'Test test',
    @ubicacion  = 'Test test',
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
    @nombre     = 'Parque Nacional Iguazu test',  -- nombre que ya usa el parque 1
    @tipo       = 'Nacional test',
    @ubicacion  = 'Rio Negro test',
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
EXEC personal.Guardaparque_modificacion
    @dni = 40999888,
    @nombre   = 'Laura Beatriz test',
    @apellido = 'Gomez test',
    @estado   = 'Inactivo';
 
-- Evidencia
SELECT id, nombre, apellido, estado FROM personal.Guardaparque WHERE id = 2;
GO
 
-- TEST 7.2: estado invalido
PRINT '--- TEST 7.2: Estado invalido (debe fallar) ---';
BEGIN TRY
    EXEC personal.Guardaparque_modificacion
    @dni = 40999888,
    @nombre   = 'Laura test',
    @apellido = 'Gomez test',
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
    @id_parque = 1,
    @id_guardaparque = 1;
GO
 
-- TEST 8.1: cerrar asignacion exitosamente
PRINT '--- TEST 8.1: Cerrar asignacion (egreso) exitoso ---';
EXEC gestion.asignacion_modificacion
    @id           = 2,   -- la nueva asignacion
    @motivo       = 'Fin de temporada test';
 
-- Evidencia: asignacion con fecha_egreso y guardaparque en Inactivo
SELECT id, id_guardaparque, fecha_ingreso, fecha_egreso, motivo FROM gestion.Parque_asignado WHERE id = 2;
SELECT id, nombre, estado FROM personal.Guardaparque WHERE id = 1;
GO
 
-- TEST 8.2: asignacion ya cerrada
PRINT '--- TEST 8.2: Asignacion ya cerrada (debe fallar) ---';
BEGIN TRY
    EXEC gestion.asignacion_modificacion
    @id           = 2,
    @motivo       = 'Test test';
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
    @nombre = 'Trekking Cataratas test',
    @dni_guia = '35111222',
    @descripcion = 'Caminata por circuito superior e inferior test',
    @tipo        = 'Tour guiado test',
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
    @nombre = 'Trekking Cataratas test',
    @dni_guia = '25123456',
    @descripcion = 'Test test',
    @tipo        = 'Tour guiado test',
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
        @nombre = 'Actividad inexistente test',
        @dni_guia = '99999999',   -- no existe
        @descripcion = 'Test test',
        @tipo        = 'Tour guiado test',
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
    @nombre = 'Trekking Cataratas Actualizado test';

-- Evidencia: estado debe ser 'Cancelado'
SELECT id, nombre, estado FROM gestion.Actividad WHERE id = 1;
GO

-- TEST 10.2: actividad inexistente
PRINT '--- TEST 10.2: Actividad inexistente (debe fallar) ---';
BEGIN TRY
    EXEC gestion.actividad_baja
    @nombre = 'Actividad inexistente test';
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
    @nombre = 'Trekking Cataratas Actualizado test';
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
PRINT '--- TEST 11.1: Registrar guia exitosamente ---';
EXEC personal.Guia_alta
    @dni = '30456789',
    @nombre = 'Lucia test',
    @apellido = 'Ferreyra test',
    @fecha_vencimiento_acreditacion = '2026-12-31';
GO

-- TEST 11.2: Registro exitoso
PRINT '--- TEST 11.2: Registrar guia exitosamente ---';
EXEC personal.Guia_alta
    @dni = '25123456',
    @nombre = 'Marcos test',
    @apellido = 'Villanueva test',
    @fecha_vencimiento_acreditacion = '2025-06-13';
GO

-- TEST 11.3: DNI duplicado (debe fallar)
PRINT '--- TEST 11.3: DNI duplicado (debe fallar) ---';
BEGIN TRY
    EXEC personal.Guia_alta
    @dni = '30456789',
    @nombre = 'Lucas test',
    @apellido = 'Perez test',
    @fecha_vencimiento_acreditacion = '2030-03-29';
    PRINT 'FALLO - Test 11.3: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 11.3: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 11.4: DNI duplicado y nombre invalido (debe fallar)
PRINT '--- TEST 11.4: DNI duplicado y falta de nombre/apellido (debe fallar) ---';
BEGIN TRY
    EXEC personal.Guia_alta
    @dni = '30456789',
    @nombre = '',
    @apellido = 'Perez test',
    @fecha_vencimiento_acreditacion = '2030-03-29';
    PRINT 'FALLO - Test 11.4: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 11.4: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 11.5: Formato de DNI invalido (debe fallar)
PRINT '--- TEST 11.5: DNI con formato invalido (debe fallar) ---';
BEGIN TRY
    EXEC personal.Guia_alta
    @dni = 'ABC12 test',
    @nombre = 'Lucas test',
    @apellido = 'Perez test',
    @fecha_vencimiento_acreditacion = '2030-03-29';
    PRINT 'FALLO - Test 11.5: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 11.5: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 11.6: Apellido vacio (debe fallar)
PRINT '--- TEST 11.6: Falta apellido (debe fallar) ---';
BEGIN TRY
    EXEC personal.Guia_alta
    @dni = '38912345',
    @nombre = 'Lucas test',
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
    EXEC personal.Guia_alta
    @dni = '38912345',
    @nombre = 'Lucas test',
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
    EXEC personal.Guia_alta
    @dni = '38912345',
    @nombre = 'Lucas test',
    @apellido = 'Perez test',
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
    EXEC personal.Guia_alta
    @dni = NULL,
    @nombre = 'Lucas test',
    @apellido = 'Perez test',
    @fecha_vencimiento_acreditacion = '2030-03-29';
    PRINT 'FALLO - Test 11.9: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 11.9: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 11.10: Registro exitoso
PRINT '--- TEST 11.10: Registrar guia exitosamente ---';
EXEC personal.Guia_alta
    @dni = '38912345',
    @nombre = 'Lucas test',
    @apellido = 'Perez test',
    @fecha_vencimiento_acreditacion = '2030-03-29';
GO

-- ============================================================
-- SECCION 12: ACTUALIZACION DE GUIA
-- ============================================================

PRINT '=== ACTUALIZACION DE GUIA ===';
GO

-- TEST 12.1: Actalizar exitoso
PRINT '--- TEST 12.1: Actalizar guia exitosamente ---';
EXEC personal.Guia_modificacion
    @dni = '30456789',
    @nombre = 'Luciano test',
    @apellido = 'Fernandez test';
GO

-- TEST 12.2: Actalizar exitoso
PRINT '--- TEST 12.2: Actalizar guia exitosamente ---';
EXEC personal.Guia_modificacion
    @dni = '25123456',
    @nombre = 'Marcos test',
    @apellido = 'Villanueva test';
GO

-- TEST 12.3: DNI sin guia (debe fallar)
PRINT '--- TEST 12.3: DNI sin guia (debe fallar) ---';
BEGIN TRY
    EXEC personal.Guia_modificacion
    @dni = '32000000',
    @nombre = 'Lucas test',
    @apellido = 'Perez test';
    PRINT 'FALLO - Test 12.3: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 12.3: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 12.4: Nombre invalido (debe fallar)
PRINT '--- TEST 12.4: Falta de nombre/apellido (debe fallar) ---';
BEGIN TRY
    EXEC personal.Guia_modificacion
    @dni = '30456789',
    @nombre = '',
    @apellido = 'Perez test';
    PRINT 'FALLO - Test 12.4: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 12.4: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 12.6: Apellido vacio (debe fallar)
PRINT '--- TEST 12.6: Falta apellido (debe fallar) ---';
BEGIN TRY
    EXEC personal.Guia_modificacion
    @dni = '38912345',
    @nombre = 'Lucas test',
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
    EXEC personal.Guia_modificacion
    @dni = '38912345',
    @nombre = 'Lucas test',
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
    EXEC personal.Guia_modificacion
    @dni = NULL,
    @nombre = 'Lucas test',
    @apellido = 'Perez test';
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
    @nombre_parque = 'Parque Nacional Iguazu test',
    @dni_guia = '35111222',
    @nombre      = 'Trekking Cataratas test',
    @descripcion = 'Caminata por circuito superior test',
    @tipo        = 'Tour guiado test',
    @costo       = 2500.00,
    @fecha       = '2026-08-15',
    @duracion    = 180,
    @cupo        = 20;

-- TEST 13.1: Asignacion exitosa
PRINT '--- TEST 13.1: Asignar guia exitosamente ---';
EXEC gestion.coordina_alta
@dni = '30456789',
@nombre_actividad = 'Trekking Cataratas test',
@nombre_parque = 'Parque Nacional Iguazu test',
@fecha_actividad = '2026-06-16 00:00:00',
@f_desde = '2026-06-14',
@f_hasta = '2026-06-17';
GO

-- TEST 13.2: Actividad inexistente en el parque (debe fallar)
PRINT '--- TEST 13.2: Actividad inexistente en el parque (debe fallar) ---';
BEGIN TRY
    EXEC gestion.coordina_alta
    @dni = '30456789',
    @nombre_actividad = 'Trekking Cataratas test',
    @nombre_parque = 'Parque Nahuel Huapi test',
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
PRINT '--- TEST 13.3: Falta especificar DNI del guia (debe fallar) ---';
BEGIN TRY
    EXEC gestion.coordina_alta
    @dni = NULL,
    @nombre_actividad = 'Trekking Cataratas test',
    @nombre_parque = 'Parque Nacional Iguazu test',
    @fecha_actividad = '2026-06-16 00:00:00.000',
    @f_desde = '2026-06-14',
    @f_hasta = '2026-06-17';
    PRINT 'FALLO - Test 13.3: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 13.3: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 13.4: Guia inexistente (debe fallar)
PRINT '--- TEST 13.4: DNI de guia inexistente (debe fallar) ---';
BEGIN TRY
    EXEC gestion.coordina_alta
    @dni = '11122345',
    @nombre_actividad = 'Trekking Cataratas test',
    @nombre_parque = 'Parque Nacional Iguazu test',
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
    EXEC gestion.coordina_alta
    @dni = '30456789',
    @nombre_actividad = 'Escalda test',
    @nombre_parque = 'Parque Nacional Iguazu test',
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
    EXEC gestion.coordina_alta
    @dni = '30456789',
    @nombre_actividad = 'Trekking Cataratas test',
    @nombre_parque = 'Parque Nacional Iguazu test',
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
    EXEC gestion.coordina_alta
    @dni = '30456789',
    @nombre_actividad = NULL,
    @nombre_parque = 'Parque Nacional Iguazu test',
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
    EXEC gestion.coordina_alta
    @dni = '30456789',
    @nombre_actividad = 'Trekking Cataratas test',
    @nombre_parque = 'Parque Nacional Iguazu test',
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
    EXEC gestion.coordina_alta
    @dni = '30456789',
    @nombre_actividad = 'Trekking Cataratas test',
    @nombre_parque = 'Parque Nacional Iguazu test',
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
    EXEC gestion.coordina_alta
    @dni = '30456789',
    @nombre_actividad = 'Trekking Cataratas test',
    @nombre_parque = 'Parque Nacional Iguazu test',
    @fecha_actividad = '2026-06-16 00:00:00.000',
    @f_desde = '2026-06-14',
    @f_hasta = NULL;
    PRINT 'FALLO - Test 13.10: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 13.10: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 13.11: Asignacion duplicada (debe fallar)
PRINT '--- TEST 13.11: La actividad ya esta asignada al guia (debe fallar) ---';
BEGIN TRY
    EXEC gestion.coordina_alta
    @dni = '30456789',
    @nombre_actividad = 'Trekking Cataratas test',
    @nombre_parque = 'Parque Nacional Iguazu test',
    @fecha_actividad = '2026-06-16 00:00:00.000',
    @f_desde = '2026-06-14',
    @f_hasta = '2026-06-17';
    PRINT 'FALLO - Test 13.11: se esperaba error y no ocurrio.';
END TRY
BEGIN CATCH
    PRINT 'OK - Test 13.11: fallo como se esperaba. Detalle: ' + ERROR_MESSAGE();
END CATCH
GO

-- TEST 13.12: Guia con acreditacion vencida (debe fallar)
PRINT '--- TEST 13.12: Guia con acreditacion vencida (debe fallar) ---';
BEGIN TRY
    EXEC gestion.coordina_alta
    @dni = '25123456',
    @nombre_actividad = 'Trekking Cataratas test',
    @nombre_parque = 'Parque Nacional Iguazu test',
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
    exec gestion.parque_alta 'Parque Test Canon 1 test', 'Test test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Canon Test 1 test', @tipo = 'tienda test', @cuit = '30123456789';
    declare @e1 int = (select top 1 id from concesiones.Empresa where nombre = 'Canon Test 1 test' order by id desc);
    exec concesiones.concesion_alta @empresa = 'Canon Test 1 test', @parque = 'Parque Test Canon 1 test', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
    declare @c1 int = (select top 1 id from concesiones.Concesion where id_empresa = @e1 order by id desc);

    exec concesiones.canon_pagar_alta @empresa = 'Canon Test 1 test', @parque = 'Parque Test Canon 1 test', @fecha_inicio = '2026-01-01';

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
    exec gestion.parque_alta 'Parque Test Canon 2 test', 'Test test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Canon Test 2 test', @tipo = 'tienda test', @cuit = '30123456789';
    declare @e2 int = (select top 1 id from concesiones.Empresa where nombre = 'Canon Test 2 test' order by id desc);
    exec concesiones.concesion_alta @empresa = 'Canon Test 2 test', @parque = 'Parque Test Canon 2 test', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
    declare @c2 int = (select top 1 id from concesiones.Concesion where id_empresa = @e2 order by id desc);
    exec concesiones.canon_pagar_alta @empresa = 'Canon Test 2 test', @parque = 'Parque Test Canon 2 test', @fecha_inicio = '2026-01-01';

    exec concesiones.canon_pagar_modificacion @periodo = 'Enero 2026 (ajustado) test', @monto = 1500.00, @empresa = 'Canon Test 2 test', @parque = 'Parque Test Canon 2 test', @fecha_inicio = '2026-01-01';

    select * from concesiones.Canon_pagar where id_concesion = @c2;

    if exists (select 1 from concesiones.Canon_pagar where id_concesion = @c2 and monto = 1500.00 and periodo = 'Enero 2026 (ajustado) test')
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
    exec gestion.parque_alta 'Parque Test Canon 3 test', 'Test test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Canon Test 3 test', @tipo = 'tienda test', @cuit = '30123456789';
    declare @e3 int = (select top 1 id from concesiones.Empresa where nombre = 'Canon Test 3 test' order by id desc);
    exec concesiones.concesion_alta @empresa = 'Canon Test 3 test', @parque = 'Parque Test Canon 3 test', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
    declare @c3 int = (select top 1 id from concesiones.Concesion where id_empresa = @e3 order by id desc);
    exec concesiones.canon_pagar_alta @empresa = 'Canon Test 3 test', @parque = 'Parque Test Canon 3 test', @fecha_inicio = '2026-01-01';

    exec concesiones.canon_pagar_abonar @fecha_pago = '2026-02-05', @empresa = 'Canon Test 3 test', @parque = 'Parque Test Canon 3 test', @fecha_inicio = '2026-01-01';

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
    exec gestion.parque_alta 'Parque Test Canon 4 test', 'Test test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Canon Test 4 test', @tipo = 'tienda test', @cuit = '30123456789';
    declare @e4 int = (select top 1 id from concesiones.Empresa where nombre = 'Canon Test 4 test' order by id desc);
    exec concesiones.concesion_alta @empresa = 'Canon Test 4 test', @parque = 'Parque Test Canon 4 test', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
    declare @c4 int = (select top 1 id from concesiones.Concesion where id_empresa = @e4 order by id desc);
    exec concesiones.canon_pagar_alta @empresa = 'Canon Test 4 test', @parque = 'Parque Test Canon 4 test', @fecha_inicio = '2026-01-01';

    exec concesiones.canon_pagar_baja @empresa = 'Canon Test 4 test', @parque = 'Parque Test Canon 4 test', @fecha_inicio = '2026-01-01';

    if exists (select 1 from concesiones.Canon_pagar where id_concesion = @c4 and estado = 'INVALIDO test')
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
    exec gestion.parque_alta 'Parque Test Canon 5 test', 'Test test', '', 100.00;

    exec concesiones.canon_pagar_alta @empresa = 'Empresa inexistente test', @parque = 'Parque Test Canon 5 test', @fecha_inicio = '2026-01-01';
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
    exec concesiones.empresa_alta @nombre = 'Canon Test 6 test', @tipo = 'tienda test', @cuit = '30123456789';

    exec concesiones.canon_pagar_alta @empresa = 'Canon Test 6 test', @parque = 'Parque inexistente test', @fecha_inicio = '2026-01-01';
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
    exec gestion.parque_alta 'Parque Test Canon 7 test', 'Test test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Canon Test 7 test', @tipo = 'tienda test', @cuit = '30123456789';

    exec concesiones.canon_pagar_alta @empresa = 'Canon Test 7 test', @parque = 'Parque Test Canon 7 test', @fecha_inicio = '2026-01-01';
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
    exec gestion.parque_alta 'Parque Test Concesion 1 test', 'Test test', '', 100.00;
    declare @idParque1 int = (select top 1 id from gestion.Parque where nombre = 'Parque Test Concesion 1 test');

    exec concesiones.empresa_alta @nombre = 'Concesionaria Test 1 test', @tipo = 'restaurante test', @cuit = '30123456789';
    declare @idEmp1 int = (select top 1 id from concesiones.Empresa where nombre = 'Concesionaria Test 1 test');

    exec concesiones.concesion_alta @empresa = 'Concesionaria Test 1 test', @parque = 'Parque Test Concesion 1 test', @canon_mensual = 1500.00, @fecha_inicio = '2026-01-01';

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
     exec gestion.parque_alta 'Parque Test Concesion 2 test', 'Test test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Concesionaria Test 2 test', @tipo = 'tienda test', @cuit = '30123456789';
    declare @idEmp2 int = (select top 1 id from concesiones.Empresa where nombre = 'Concesionaria Test 2 test' order by id desc);
    exec concesiones.concesion_alta @empresa = 'Concesionaria Test 2 test', @parque = 'Parque Test Concesion 2 test', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
    declare @idCon2 int = (select top 1 id from concesiones.Concesion where id_empresa = @idEmp2 order by id desc);

    exec concesiones.concesion_modificacion @empresa = 'Concesionaria Test 2 test', @parque = 'Parque Test Concesion 2 test', @fecha_inicio = '2026-01-01', @fecha_fin = '2026-12-31', @estado = 'INACTIVO', @canon = 999.99;

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
print '--- Test 15.3: concesion_baja (exito, baja logica) ---';
begin tran;
begin try
        exec gestion.parque_alta 'Parque Test Concesion 3 test', 'Test test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Concesionaria Test 3 test', @tipo = 'tienda test', @cuit = '30123456789';
    declare @idEmp3 int = (select top 1 id from concesiones.Empresa where nombre = 'Concesionaria Test 3 test' order by id desc);
    exec concesiones.concesion_alta @empresa = 'Concesionaria Test 3 test', @parque = 'Parque Test Concesion 3 test', @canon_mensual = 1200.00, @fecha_inicio = '2026-01-01';
    declare @idCon3 int = (select top 1 id from concesiones.Concesion where id_empresa = @idEmp3 order by id desc);

    exec concesiones.concesion_baja @empresa = 'Concesionaria Test 3 test', @parque = 'Parque Test Concesion 3 test', @fecha_inicio = '2026-01-01';

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
    exec gestion.parque_alta 'Parque Test Concesion 4 test', 'Test test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Concesionaria Test 4 test', @tipo = 'tienda test', @cuit = '30123456789';
    declare @idEmp4 int = (select top 1 id from concesiones.Empresa where nombre = 'Concesionaria Test 4 test' order by id desc);

    exec concesiones.concesion_alta @empresa = 'Concesionaria Test 4 test', @parque = 'Parque Test Concesion 4 test', @canon_mensual = -50.00, @fecha_inicio = '2026-01-01';
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
    exec gestion.parque_alta 'Parque Test Concesion 5 test', 'Test test', '', 100.00;

    exec concesiones.concesion_alta @empresa = 'Empresa inexistente test', @parque = 'Parque Test Concesion 5 test', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
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
    exec concesiones.empresa_alta @nombre = 'Concesionaria Test 6 test', @tipo = 'tienda test', @cuit = '30123456789';

    exec concesiones.concesion_alta @empresa = 'Concesionaria Test 6 test', @parque = 'Parque inexistente test', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
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
print '--- Test 15.7: concesion_baja con concesion inexistente (validacion) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Test Concesion 7 test', 'Test test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Concesionaria Test 7 test', @tipo = 'tienda test', @cuit = '30123456789';

    exec concesiones.concesion_baja @empresa = 'Concesionaria Test 7 test', @parque = 'Parque Test Concesion 7 test', @fecha_inicio = '2026-01-01';
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
    exec gestion.parque_alta 'Parque Test Concesion 8 test', 'Test test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Concesionaria Test 8 test', @tipo = 'tienda test', @cuit = '30123456789';
    exec concesiones.concesion_alta @empresa = 'Concesionaria Test 8 test', @parque = 'Parque Test Concesion 8 test', @canon_mensual = 800.00, @fecha_inicio = '2026-01-01';

    exec concesiones.concesion_modificacion @empresa = 'Concesionaria Test 8 test', @parque = 'Parque Test Concesion 8 test', @fecha_inicio = '2026-01-01', @estado = 'RARO test';
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
    exec gestion.parque_alta 'Parque Test Concesion 9 test', 'Test test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Concesionaria Test 9 test', @tipo = 'tienda test', @cuit = '30123456789';
    exec concesiones.concesion_alta @empresa = 'Concesionaria Test 9 test', @parque = 'Parque Test Concesion 9 test', @canon_mensual = 800.00, @fecha_inicio = '2026-01-01';

    exec concesiones.concesion_modificacion @empresa = 'Concesionaria Test 9 test', @parque = 'Parque Test Concesion 9 test', @fecha_inicio = '2026-01-01', @empresa_nueva = 'Empresa nueva inexistente test';
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
    exec gestion.parque_alta 'Parque Test Concesion 10 test', 'Test test', '', 100.00;

    exec concesiones.empresa_alta @nombre = 'Concesionaria Test 10 test', @tipo = 'tienda test', @cuit = '30123456789';
    exec concesiones.concesion_alta @empresa = 'Concesionaria Test 10 test', @parque = 'Parque Test Concesion 10 test', @canon_mensual = 800.00, @fecha_inicio = '2026-01-01';

    exec concesiones.concesion_modificacion @empresa = 'Concesionaria Test 10 test', @parque = 'Parque Test Concesion 10 test', @fecha_inicio = '2026-01-01', @parque_nuevo = 'Parque nuevo inexistente test';
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
    exec concesiones.empresa_alta @nombre = 'Resto del Lago SA test', @tipo = 'restaurante test', @cuit = '30123456789';

    -- evidencia
    select * from concesiones.Empresa where nombre = 'Resto del Lago SA test';

    if exists (select 1 from concesiones.Empresa where nombre = 'Resto del Lago SA test' and cuit = '30123456789')
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
print '--- Test 16.2: empresa_modificacion (exito, modificacion parcial) ---';
begin tran;
begin try
    exec concesiones.empresa_alta @nombre = 'Empresa 1 test', @tipo = 'restaurante test', @cuit = '30123456789';
    declare @idEmp int = (select top 1 id from concesiones.Empresa where nombre = 'Empresa 1 test' order by id desc);

    exec concesiones.empresa_modificacion @nombre = 'Empresa 1 test', @nuevo_nombre = 'Empresa 2 test';

    select * from concesiones.Empresa where id = @idEmp;

    if exists (select 1 from concesiones.Empresa
               where id = @idEmp and nombre = 'Empresa 2 test'
                 and tipo = 'restaurante test' and cuit = '30123456789')
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
    exec concesiones.empresa_alta @nombre = 'Empresa a Borrar test', @tipo = 'tienda test', @cuit = '30999999998';
    declare @idBaja int = (select top 1 id from concesiones.Empresa where nombre = 'Empresa a Borrar test' order by id desc);

    exec concesiones.empresa_baja @nombre = 'Empresa a Borrar test';

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
    exec concesiones.empresa_alta @nombre = 'CUIT Malo test', @tipo = 'tienda test', @cuit = '123';
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
    exec concesiones.empresa_alta @nombre = null, @tipo = 'tienda test', @cuit = '30123456789';
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
    exec concesiones.empresa_alta @nombre = 'Empresa Duplicada test', @tipo = 'tienda test', @cuit = '30123456789';
    exec concesiones.empresa_alta @nombre = 'Empresa Duplicada test', @tipo = 'tienda test', @cuit = '30123456780';
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
    exec concesiones.empresa_baja @nombre = 'Empresa inexistente test';
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
print '--- Test 16.8: empresa_modificacion con empresa inexistente (validacion) ---';
begin tran;
begin try
    exec concesiones.empresa_modificacion @nombre = 'Empresa inexistente test', @nuevo_nombre = 'Empresa Nueva test';
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
print '--- Test 16.9: empresa_modificacion con nombre duplicado (validacion) ---';
begin tran;
begin try
    exec concesiones.empresa_alta @nombre = 'Empresa Original test', @tipo = 'tienda test', @cuit = '30123456789';
    exec concesiones.empresa_alta @nombre = 'Empresa Existente test', @tipo = 'tienda test', @cuit = '30123456780';

    exec concesiones.empresa_modificacion @nombre = 'Empresa Original test', @nuevo_nombre = 'Empresa Existente test';
    print 'FALLO - Test 16.9: se esperaba error por nombre duplicado y no ocurrio.';
end try
begin catch
    print 'OK - Test 16.9: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-- ############################################################
-- TESTS AGREGADOS: ABM DE VENTAS (SPs de 03_sp_abm.sql)
-- Cubren: tipo_visitante, punto_de_venta, metodo_de_pago,
--         tipo_entrada y el flujo venta / item_venta.
-- Mismo patron de aislamiento (begin tran / rollback) que el
-- resto del archivo. Cada test es su propio batch (GO) para
-- poder reutilizar nombres de variables.
-- ############################################################

-- ============================================================
-- SECCION 17: Tipo de visitante
-- ============================================================

-------------------------------------------------------------------------------
-- Test 17.1: Alta exito
-- Esperado: se inserta el tipo de visitante en estado 'Activo'.
-------------------------------------------------------------------------------
print '--- Test 17.1: tipo_visitante_alta (exito) ---';
begin tran;
begin try
    exec ventas.tipo_visitante_alta @descripcion = 'Adulto test';

    if exists (select 1 from ventas.tipo_visitante where descripcion = 'Adulto test' and rtrim(estado) = 'Activo')
        print 'OK - Test 17.1: tipo de visitante dado de alta en estado Activo.';
    else
        print 'FALLO - Test 17.1: no se encontro el tipo de visitante esperado.';
end try
begin catch
    print 'FALLO - Test 17.1: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 17.2: Alta duplicada (validacion)
-- Esperado: el SP rechaza el alta de un tipo de visitante ya activo.
-------------------------------------------------------------------------------
print '--- Test 17.2: tipo_visitante_alta duplicado (validacion) ---';
begin tran;
begin try
    exec ventas.tipo_visitante_alta @descripcion = 'Adulto test';
    exec ventas.tipo_visitante_alta @descripcion = 'Adulto test';
    print 'FALLO - Test 17.2: se esperaba error por duplicado y no ocurrio.';
end try
begin catch
    print 'OK - Test 17.2: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 17.3: Baja exito (baja logica)
-- Esperado: el tipo de visitante queda en estado 'Inactivo'.
-------------------------------------------------------------------------------
print '--- Test 17.3: tipo_visitante_baja (exito, baja logica) ---';
begin tran;
begin try
    exec ventas.tipo_visitante_alta @descripcion = 'Menor test';
    exec ventas.tipo_visitante_baja @descripcion = 'Menor test';

    if exists (select 1 from ventas.tipo_visitante where descripcion = 'Menor test' and rtrim(estado) = 'Inactivo')
        print 'OK - Test 17.3: el tipo de visitante quedo Inactivo.';
    else
        print 'FALLO - Test 17.3: la baja logica no se aplico.';
end try
begin catch
    print 'FALLO - Test 17.3: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 17.4: Baja de tipo inexistente (validacion)
-- Esperado: el SP rechaza la baja porque el tipo no existe.
-------------------------------------------------------------------------------
print '--- Test 17.4: tipo_visitante_baja inexistente (validacion) ---';
begin tran;
begin try
    exec ventas.tipo_visitante_baja @descripcion = 'Inexistente test';
    print 'FALLO - Test 17.4: se esperaba error por tipo inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 17.4: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 17.5: Modificacion exito
-- Esperado: la descripcion cambia a la nueva.
-------------------------------------------------------------------------------
print '--- Test 17.5: tipo_visitante_modificacion (exito) ---';
begin tran;
begin try
    exec ventas.tipo_visitante_alta @descripcion = 'Jubilado test';
    exec ventas.tipo_visitante_modificacion @descripcion = 'Jubilado test', @nueva_descripcion = 'Jubilado VIP test';

    if exists (select 1 from ventas.tipo_visitante where descripcion = 'Jubilado VIP test')
       and not exists (select 1 from ventas.tipo_visitante where descripcion = 'Jubilado test')
        print 'OK - Test 17.5: tipo de visitante modificado correctamente.';
    else
        print 'FALLO - Test 17.5: la modificacion no quedo como se esperaba.';
end try
begin catch
    print 'FALLO - Test 17.5: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 17.6: Modificacion hacia una descripcion ya existente (validacion)
-- Esperado: el SP rechaza el cambio porque la nueva descripcion ya existe.
-------------------------------------------------------------------------------
print '--- Test 17.6: tipo_visitante_modificacion a descripcion existente (validacion) ---';
begin tran;
begin try
    exec ventas.tipo_visitante_alta @descripcion = 'Estudiante test';
    exec ventas.tipo_visitante_alta @descripcion = 'Extranjero test';
    exec ventas.tipo_visitante_modificacion @descripcion = 'Estudiante test', @nueva_descripcion = 'Extranjero test';
    print 'FALLO - Test 17.6: se esperaba error por descripcion duplicada y no ocurrio.';
end try
begin catch
    print 'OK - Test 17.6: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-- ============================================================
-- SECCION 18: Punto de venta
-- ============================================================

-------------------------------------------------------------------------------
-- Test 18.1: Alta exito
-- Esperado: se inserta el punto de venta en estado 'Activo' para el parque.
-------------------------------------------------------------------------------
print '--- Test 18.1: punto_de_venta_alta (exito) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque POV 1 test', 'Nacional test', '', 100;
    declare @idp int = (select top 1 id from gestion.Parque where nombre = 'Parque POV 1 test');

    exec ventas.punto_de_venta_alta @parque = 'Parque POV 1 test', @pov = 'Entrada Principal test';

    if exists (select 1 from ventas.punto_de_venta where parque = @idp and descripcion = 'Entrada Principal test' and rtrim(estado) = 'Activo')
        print 'OK - Test 18.1: punto de venta dado de alta correctamente.';
    else
        print 'FALLO - Test 18.1: no se encontro el punto de venta esperado.';
end try
begin catch
    print 'FALLO - Test 18.1: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 18.2: Alta duplicada (validacion)
-- Esperado: el SP rechaza el alta de un punto de venta ya activo en el parque.
-------------------------------------------------------------------------------
print '--- Test 18.2: punto_de_venta_alta duplicado (validacion) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque POV 2 test', 'Nacional test', '', 100;
    exec ventas.punto_de_venta_alta @parque = 'Parque POV 2 test', @pov = 'Kiosco test';
    exec ventas.punto_de_venta_alta @parque = 'Parque POV 2 test', @pov = 'Kiosco test';
    print 'FALLO - Test 18.2: se esperaba error por duplicado y no ocurrio.';
end try
begin catch
    print 'OK - Test 18.2: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 18.3: Baja exito (baja logica)
-- Esperado: el punto de venta queda en estado 'Inactivo'.
-------------------------------------------------------------------------------
print '--- Test 18.3: punto_de_venta_baja (exito, baja logica) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque POV 3 test', 'Nacional test', '', 100;
    declare @idp int = (select top 1 id from gestion.Parque where nombre = 'Parque POV 3 test');
    exec ventas.punto_de_venta_alta @parque = 'Parque POV 3 test', @pov = 'Boleteria test';

    exec ventas.punto_de_venta_baja @parque = 'Parque POV 3 test', @pov = 'Boleteria test';

    if exists (select 1 from ventas.punto_de_venta where parque = @idp and descripcion = 'Boleteria test' and rtrim(estado) = 'Inactivo')
        print 'OK - Test 18.3: el punto de venta quedo Inactivo.';
    else
        print 'FALLO - Test 18.3: la baja logica no se aplico.';
end try
begin catch
    print 'FALLO - Test 18.3: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 18.4: Modificacion exito
-- Esperado: la descripcion del punto de venta cambia a la nueva.
-------------------------------------------------------------------------------
print '--- Test 18.4: punto_de_venta_modificacion (exito) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque POV 4 test', 'Nacional test', '', 100;
    declare @idp int = (select top 1 id from gestion.Parque where nombre = 'Parque POV 4 test');
    exec ventas.punto_de_venta_alta @parque = 'Parque POV 4 test', @pov = 'Puesto Norte test';

    exec ventas.punto_de_venta_modificacion @parque = 'Parque POV 4 test', @pov = 'Puesto Norte test', @nueva_descripcion = 'Puesto Sur test';

    if exists (select 1 from ventas.punto_de_venta where parque = @idp and descripcion = 'Puesto Sur test')
        print 'OK - Test 18.4: punto de venta modificado correctamente.';
    else
        print 'FALLO - Test 18.4: la modificacion no quedo como se esperaba.';
end try
begin catch
    print 'FALLO - Test 18.4: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-- ============================================================
-- SECCION 19: Metodo de pago
-- ============================================================

-------------------------------------------------------------------------------
-- Test 19.1: Alta exito
-- Esperado: se inserta el metodo de pago en estado 'Activo'.
-------------------------------------------------------------------------------
print '--- Test 19.1: metodo_de_pago_alta (exito) ---';
begin tran;
begin try
    exec ventas.metodo_de_pago_alta @descripcion = 'Efectivo test';

    if exists (select 1 from ventas.metodo_de_pago where descripcion = 'Efectivo test' and rtrim(estado) = 'Activo')
        print 'OK - Test 19.1: metodo de pago dado de alta en estado Activo.';
    else
        print 'FALLO - Test 19.1: no se encontro el metodo de pago esperado.';
end try
begin catch
    print 'FALLO - Test 19.1: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 19.2: Alta duplicada (validacion)
-- Esperado: el SP rechaza el alta de un metodo de pago ya activo.
-------------------------------------------------------------------------------
print '--- Test 19.2: metodo_de_pago_alta duplicado (validacion) ---';
begin tran;
begin try
    exec ventas.metodo_de_pago_alta @descripcion = 'Debito test';
    exec ventas.metodo_de_pago_alta @descripcion = 'Debito test';
    print 'FALLO - Test 19.2: se esperaba error por duplicado y no ocurrio.';
end try
begin catch
    print 'OK - Test 19.2: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 19.3: Baja exito (baja logica)
-- Esperado: el metodo de pago queda en estado 'Inactivo'.
-------------------------------------------------------------------------------
print '--- Test 19.3: metodo_de_pago_baja (exito, baja logica) ---';
begin tran;
begin try
    exec ventas.metodo_de_pago_alta @descripcion = 'Credito test';
    exec ventas.metodo_de_pago_baja @descripcion = 'Credito test';

    if exists (select 1 from ventas.metodo_de_pago where descripcion = 'Credito test' and rtrim(estado) = 'Inactivo')
        print 'OK - Test 19.3: el metodo de pago quedo Inactivo.';
    else
        print 'FALLO - Test 19.3: la baja logica no se aplico.';
end try
begin catch
    print 'FALLO - Test 19.3: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 19.4: Baja de metodo inexistente (validacion)
-- Esperado: el SP rechaza la baja porque el metodo no existe.
-------------------------------------------------------------------------------
print '--- Test 19.4: metodo_de_pago_baja inexistente (validacion) ---';
begin tran;
begin try
    exec ventas.metodo_de_pago_baja @descripcion = 'Cheque inexistente test';
    print 'FALLO - Test 19.4: se esperaba error por metodo inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 19.4: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-- ============================================================
-- SECCION 20: Tipo de entrada
-- ============================================================

-------------------------------------------------------------------------------
-- Test 20.1: Alta exito
-- Esperado: queda una entrada vigente (fecha_hasta NULL) para parque+tipo.
-------------------------------------------------------------------------------
print '--- Test 20.1: tipo_entrada_alta (exito) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Entrada 1 test', 'Nacional test', '', 100;
    exec ventas.tipo_visitante_alta @descripcion = 'Adulto test';

    exec ventas.tipo_entrada_alta @parque = 'Parque Entrada 1 test', @tipo = 'Adulto test', @precio = 5000.00, @vigencia = '2026-01-01';

    if exists (select 1 from ventas.entradas_vigentes where Parque = 'Parque Entrada 1 test' and Visitante = 'Adulto test' and precio = 5000.00)
        print 'OK - Test 20.1: entrada vigente creada correctamente.';
    else
        print 'FALLO - Test 20.1: no se encontro la entrada vigente esperada.';
end try
begin catch
    print 'FALLO - Test 20.1: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 20.2: Alta con tipo de visitante inexistente (validacion)
-- Esperado: el SP rechaza el alta porque el tipo de visitante no existe.
-------------------------------------------------------------------------------
print '--- Test 20.2: tipo_entrada_alta con tipo de visitante inexistente (validacion) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Entrada 2 test', 'Nacional test', '', 100;
    exec ventas.tipo_entrada_alta @parque = 'Parque Entrada 2 test', @tipo = 'Visitante inexistente test', @precio = 3000.00;
    print 'FALLO - Test 20.2: se esperaba error por tipo de visitante inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 20.2: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 20.3: Alta duplicada (validacion)
-- Esperado: el SP rechaza el alta porque ya existe una entrada vigente.
-------------------------------------------------------------------------------
print '--- Test 20.3: tipo_entrada_alta duplicado (validacion) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Entrada 3 test', 'Nacional test', '', 100;
    exec ventas.tipo_visitante_alta @descripcion = 'Adulto test';
    exec ventas.tipo_entrada_alta @parque = 'Parque Entrada 3 test', @tipo = 'Adulto test', @precio = 5000.00, @vigencia = '2026-01-01';

    exec ventas.tipo_entrada_alta @parque = 'Parque Entrada 3 test', @tipo = 'Adulto test', @precio = 6000.00, @vigencia = '2026-02-01';
    print 'FALLO - Test 20.3: se esperaba error por entrada ya existente y no ocurrio.';
end try
begin catch
    print 'OK - Test 20.3: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 20.4: Modificacion de precio exito
-- Esperado: queda vigente el nuevo precio y la entrada anterior se cierra
--           (el historico de la entrada anterior recibe fecha_hasta).
-------------------------------------------------------------------------------
print '--- Test 20.4: tipo_entrada_modificacion (exito) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Entrada 4 test', 'Nacional test', '', 100;
    exec ventas.tipo_visitante_alta @descripcion = 'Adulto test';
    exec ventas.tipo_entrada_alta @parque = 'Parque Entrada 4 test', @tipo = 'Adulto test', @precio = 5000.00, @vigencia = '2026-01-01';

    exec ventas.tipo_entrada_modificacion @parque = 'Parque Entrada 4 test', @tipo = 'Adulto test', @nuevo_precio = 7500.00;

    if exists (select 1 from ventas.entradas_vigentes where Parque = 'Parque Entrada 4 test' and Visitante = 'Adulto test' and precio = 7500.00)
        print 'OK - Test 20.4: la entrada vigente quedo con el nuevo precio.';
    else
        print 'FALLO - Test 20.4: el nuevo precio no quedo vigente.';
end try
begin catch
    print 'FALLO - Test 20.4: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 20.5: Baja exito
-- Esperado: la entrada deja de estar vigente (se setea fecha_hasta).
-------------------------------------------------------------------------------
print '--- Test 20.5: tipo_entrada_baja (exito) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Entrada 5 test', 'Nacional test', '', 100;
    exec ventas.tipo_visitante_alta @descripcion = 'Adulto test';
    exec ventas.tipo_entrada_alta @parque = 'Parque Entrada 5 test', @tipo = 'Adulto test', @precio = 5000.00, @vigencia = '2026-01-01';

    exec ventas.tipo_entrada_baja @parque = 'Parque Entrada 5 test', @tipo = 'Adulto test';

    if not exists (select 1 from ventas.entradas_vigentes where Parque = 'Parque Entrada 5 test' and Visitante = 'Adulto test')
        print 'OK - Test 20.5: la entrada dejo de estar vigente.';
    else
        print 'FALLO - Test 20.5: la entrada sigue vigente.';
end try
begin catch
    print 'FALLO - Test 20.5: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-- ============================================================
-- SECCION 21: Venta e item_venta (flujo completo)
-- ============================================================

-------------------------------------------------------------------------------
-- Test 21.1: venta_alta exito
-- Esperado: se crea la venta con total 0 y devuelve el id por OUTPUT.
-------------------------------------------------------------------------------
print '--- Test 21.1: venta_alta (exito) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Venta 1 test', 'Nacional test', '', 100;
    exec ventas.punto_de_venta_alta @parque = 'Parque Venta 1 test', @pov = 'Caja 1 test';
    exec ventas.metodo_de_pago_alta @descripcion = 'Efectivo test';

    declare @idv int;
    exec ventas.venta_alta @parque = 'Parque Venta 1 test', @pov = 'Caja 1 test', @metodo = 'Efectivo test', @id_creado = @idv output;

    if @idv is not null and exists (select 1 from ventas.venta where id = @idv and total = 0)
        print 'OK - Test 21.1: venta creada con total 0 y id devuelto por OUTPUT.';
    else
        print 'FALLO - Test 21.1: no se creo la venta esperada.';
end try
begin catch
    print 'FALLO - Test 21.1: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 21.2: venta_alta con punto de venta inexistente (validacion)
-- Esperado: el SP rechaza la venta porque el punto de venta no existe.
-------------------------------------------------------------------------------
print '--- Test 21.2: venta_alta con punto de venta inexistente (validacion) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Venta 2 test', 'Nacional test', '', 100;
    exec ventas.metodo_de_pago_alta @descripcion = 'Efectivo test';

    declare @idv int;
    exec ventas.venta_alta @parque = 'Parque Venta 2 test', @pov = 'Caja inexistente test', @metodo = 'Efectivo test', @id_creado = @idv output;
    print 'FALLO - Test 21.2: se esperaba error por punto de venta inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 21.2: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 21.3: item_venta_alta exito + actualizacion de total
-- Esperado: se agrega el item y el total de la venta sube en cantidad*precio.
-------------------------------------------------------------------------------
print '--- Test 21.3: item_venta_alta (exito, actualiza total) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Venta 3 test', 'Nacional test', '', 100;
    exec ventas.punto_de_venta_alta @parque = 'Parque Venta 3 test', @pov = 'Caja 1 test';
    exec ventas.metodo_de_pago_alta @descripcion = 'Efectivo test';
    exec ventas.tipo_visitante_alta @descripcion = 'Adulto test';
    exec ventas.tipo_entrada_alta @parque = 'Parque Venta 3 test', @tipo = 'Adulto test', @precio = 5000.00, @vigencia = '2026-01-01';

    declare @idv int;
    exec ventas.venta_alta @parque = 'Parque Venta 3 test', @pov = 'Caja 1 test', @metodo = 'Efectivo test', @id_creado = @idv output;

    exec ventas.item_venta_alta @venta = @idv, @concepto = 'Adulto test', @cantidad = 2, @fecha_acceso = '2026-03-01';

    if exists (select 1 from ventas.item_venta where venta = @idv and cantidad = 2 and subtotal = 10000.00)
       and exists (select 1 from ventas.venta where id = @idv and total = 10000.00)
        print 'OK - Test 21.3: item agregado y total actualizado a 10000.';
    else
        print 'FALLO - Test 21.3: el item o el total no quedaron como se esperaba.';
end try
begin catch
    print 'FALLO - Test 21.3: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 21.4: item_venta_alta sobre venta inexistente (validacion)
-- Esperado: el SP rechaza el item porque la venta no existe.
-------------------------------------------------------------------------------
print '--- Test 21.4: item_venta_alta con venta inexistente (validacion) ---';
begin tran;
begin try
    exec ventas.item_venta_alta @venta = -1, @concepto = 'Adulto test', @cantidad = 1, @fecha_acceso = '2026-03-01';
    print 'FALLO - Test 21.4: se esperaba error por venta inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 21.4: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 21.5: item_venta_modificacion exito
-- Esperado: cambia la cantidad del item y el total de la venta se reajusta.
-------------------------------------------------------------------------------
print '--- Test 21.5: item_venta_modificacion (exito) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Venta 5 test', 'Nacional test', '', 100;
    exec ventas.punto_de_venta_alta @parque = 'Parque Venta 5 test', @pov = 'Caja 1 test';
    exec ventas.metodo_de_pago_alta @descripcion = 'Efectivo test';
    exec ventas.tipo_visitante_alta @descripcion = 'Adulto test';
    exec ventas.tipo_entrada_alta @parque = 'Parque Venta 5 test', @tipo = 'Adulto test', @precio = 5000.00, @vigencia = '2026-01-01';

    declare @idv int;
    exec ventas.venta_alta @parque = 'Parque Venta 5 test', @pov = 'Caja 1 test', @metodo = 'Efectivo test', @id_creado = @idv output;
    exec ventas.item_venta_alta @venta = @idv, @concepto = 'Adulto test', @cantidad = 2, @fecha_acceso = '2026-03-01';
    declare @idi int = (select top 1 id from ventas.item_venta where venta = @idv order by id desc);

    exec ventas.item_venta_modificacion @venta = @idv, @item = @idi, @concepto = 0, @nueva_cantidad = 5;

    if exists (select 1 from ventas.item_venta where id = @idi and cantidad = 5 and subtotal = 25000.00)
       and exists (select 1 from ventas.venta where id = @idv and total = 25000.00)
        print 'OK - Test 21.5: cantidad y total reajustados correctamente.';
    else
        print 'FALLO - Test 21.5: la modificacion no quedo como se esperaba.';
end try
begin catch
    print 'FALLO - Test 21.5: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 21.6: item_venta_baja exito
-- Esperado: el item se elimina de la venta.
-------------------------------------------------------------------------------
print '--- Test 21.6: item_venta_baja (exito) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Venta 6 test', 'Nacional test', '', 100;
    exec ventas.punto_de_venta_alta @parque = 'Parque Venta 6 test', @pov = 'Caja 1 test';
    exec ventas.metodo_de_pago_alta @descripcion = 'Efectivo test';
    exec ventas.tipo_visitante_alta @descripcion = 'Adulto test';
    exec ventas.tipo_entrada_alta @parque = 'Parque Venta 6 test', @tipo = 'Adulto test', @precio = 5000.00, @vigencia = '2026-01-01';

    declare @idv int;
    exec ventas.venta_alta @parque = 'Parque Venta 6 test', @pov = 'Caja 1 test', @metodo = 'Efectivo test', @id_creado = @idv output;
    exec ventas.item_venta_alta @venta = @idv, @concepto = 'Adulto test', @cantidad = 1, @fecha_acceso = '2026-03-01';
    declare @idi int = (select top 1 id from ventas.item_venta where venta = @idv order by id desc);

    exec ventas.item_venta_baja @venta = @idv, @item = @idi;

    if not exists (select 1 from ventas.item_venta where id = @idi)
        print 'OK - Test 21.6: el item fue eliminado.';
    else
        print 'FALLO - Test 21.6: el item todavia existe.';
end try
begin catch
    print 'FALLO - Test 21.6: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 21.7: venta_modificacion (cambio de metodo de pago)
-- Esperado: la venta queda asociada al nuevo metodo de pago.
-- NOTA: el SP asigna metodo_de_pago = @metodo (texto) sobre una columna INT FK,
--       por lo que este test probablemente exponga un bug de conversion.
-------------------------------------------------------------------------------
print '--- Test 21.7: venta_modificacion (exito) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Venta 7 test', 'Nacional test', '', 100;
    exec ventas.punto_de_venta_alta @parque = 'Parque Venta 7 test', @pov = 'Caja 1 test';
    exec ventas.metodo_de_pago_alta @descripcion = 'Efectivo test';
    exec ventas.metodo_de_pago_alta @descripcion = 'Debito test';

    declare @idv int;
    exec ventas.venta_alta @parque = 'Parque Venta 7 test', @pov = 'Caja 1 test', @metodo = 'Efectivo test', @id_creado = @idv output;
    declare @id_debito int = (select id from ventas.metodo_de_pago where descripcion = 'Debito test');

    exec ventas.venta_modificacion @id_venta = @idv, @metodo = 'Debito test';

    if exists (select 1 from ventas.venta where id = @idv and metodo_de_pago = @id_debito)
        print 'OK - Test 21.7: la venta quedo con el nuevo metodo de pago.';
    else
        print 'FALLO - Test 21.7: el metodo de pago no se actualizo como se esperaba.';
end try
begin catch
    print 'FALLO - Test 21.7: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 21.8: venta_baja exito
-- Esperado: se elimina la venta y sus items asociados.
-------------------------------------------------------------------------------
print '--- Test 21.8: venta_baja (exito) ---';
begin tran;
begin try
    exec gestion.parque_alta 'Parque Venta 8 test', 'Nacional test', '', 100;
    exec ventas.punto_de_venta_alta @parque = 'Parque Venta 8 test', @pov = 'Caja 1 test';
    exec ventas.metodo_de_pago_alta @descripcion = 'Efectivo test';
    exec ventas.tipo_visitante_alta @descripcion = 'Adulto test';
    exec ventas.tipo_entrada_alta @parque = 'Parque Venta 8 test', @tipo = 'Adulto test', @precio = 5000.00, @vigencia = '2026-01-01';

    declare @idv int;
    exec ventas.venta_alta @parque = 'Parque Venta 8 test', @pov = 'Caja 1 test', @metodo = 'Efectivo test', @id_creado = @idv output;
    exec ventas.item_venta_alta @venta = @idv, @concepto = 'Adulto test', @cantidad = 1, @fecha_acceso = '2026-03-01';

    exec ventas.venta_baja @venta = @idv;

    if not exists (select 1 from ventas.venta where id = @idv)
       and not exists (select 1 from ventas.item_venta where venta = @idv)
        print 'OK - Test 21.8: la venta y sus items fueron eliminados.';
    else
        print 'FALLO - Test 21.8: la venta o sus items todavia existen.';
end try
begin catch
    print 'FALLO - Test 21.8: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO

-------------------------------------------------------------------------------
-- Test 21.9: venta_baja sobre venta inexistente (validacion)
-- Esperado: el SP rechaza la baja porque la venta no existe.
-------------------------------------------------------------------------------
print '--- Test 21.9: venta_baja con venta inexistente (validacion) ---';
begin tran;
begin try
    exec ventas.venta_baja @venta = -1;
    print 'FALLO - Test 21.9: se esperaba error por venta inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 21.9: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;
GO
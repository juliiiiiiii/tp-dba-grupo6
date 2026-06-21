
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
 
-- TEST 1.1: exitoso
PRINT '--- TEST 1.1: Registrar parque exitoso ---';
EXEC gestion.sp_registrar_parque
    @nombre    = 'Parque Iguazu',
    @tipo      = 'Nacional',
    @ubicacion = 'Misiones',
    @superficie = 67620;

SELECT id, nombre, tipo, ubicacion, superficie, estado FROM gestion.Parque WHERE nombre = 'Parque Iguazu';
GO
 
-- TEST 1.2: nombre duplicado
PRINT '--- TEST 1.2: Nombre de parque duplicado (debe fallar) ---';
EXEC gestion.sp_registrar_parque
    @nombre    = 'Parque Iguazu',
    @tipo      = 'Nacional',
    @ubicacion = 'Misiones',
    @superficie = 67620;
GO
 
-- ============================================================
-- SECCION 2: ALTA DE GUARDAPARQUE
-- ============================================================
 
PRINT '=== ALTA DE GUARDAPARQUE ===';
GO
 
-- TEST 2.1: exitoso
PRINT '--- TEST 2.1: Registrar guardaparque exitoso ---';
EXEC gestion.sp_registrar_guardaparque
    @dni      = 30123456,
    @nombre   = 'Carlos',
    @apellido = 'Mendez';
 
-- Evidencia
SELECT id, dni, nombre, apellido, estado FROM gestion.Guardaparque WHERE dni = 30123456;
GO
 
-- TEST 2.2: DNI duplicado
PRINT '--- TEST 2.2: DNI duplicado (debe fallar) ---';
EXEC gestion.sp_registrar_guardaparque
    @dni      = 30123456,
    @nombre   = 'Otro',
    @apellido = 'Nombre';
GO
 
-- Registrar un segundo guardaparque para tests posteriores
EXEC gestion.sp_registrar_guardaparque
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
EXEC gestion.sp_asignar_guardaparque
    @id_parque       = 1,
    @id_guardaparque = 1;
 
-- Evidencia: asignacion creada y guardaparque en estado Activo
SELECT pa.id, pa.id_parque, pa.id_guardaparque, pa.fecha_ingreso, pa.fecha_egreso, pa.motivo
FROM gestion.Parque_asignado pa WHERE pa.id_parque = 1;
 
SELECT id, nombre, estado FROM gestion.Guardaparque WHERE id = 1;
GO
 
-- TEST 3.2: parque inexistente
PRINT '--- TEST 3.2: Parque inexistente (debe fallar) ---';
EXEC gestion.sp_asignar_guardaparque
    @id_parque       = 999,
    @id_guardaparque = 2;
GO
 
-- TEST 3.3: guardaparque inexistente y ya hay guardaparque en ese parque
PRINT '--- TEST 3.3: Guardaparque inexistente (debe fallar) ---';
EXEC gestion.sp_asignar_guardaparque
    @id_parque       = 1,
    @id_guardaparque = 999;
GO
 
-- TEST 3.4: parque ya tiene guardaparque activo
PRINT '--- TEST 3.4: Parque ya ocupado (debe fallar) ---';
EXEC gestion.sp_asignar_guardaparque
    @id_parque       = 1,
    @id_guardaparque = 2;
GO
 
-- TEST 3.5: guardaparque ya asignado en otro parque
-- Primero registramos un segundo parque
EXEC gestion.sp_registrar_parque
    @nombre    = 'Parque Nahuel Huapi',
    @tipo      = 'Nacional',
    @ubicacion = 'Rio Negro',
    @superficie = 717261;
GO
 
PRINT '--- TEST 3.5: Guardaparque ya asignado en otro parque (debe fallar) ---';
EXEC gestion.sp_asignar_guardaparque
    @id_parque       = 2,
    @id_guardaparque = 1   -- guardaparque 1 ya esta asignado al parque 1;
GO
 
-- ============================================================
-- SECCION 4: ALTA DE ACTIVIDAD & TIPO
-- ============================================================
 
PRINT '=== ALTA DE ACTIVIDAD ===';
GO
 
-- TEST 4.0: creacion de tipo actividad exitoso
EXEC gestion.sp_registrar_tipo_actividad
    @descripcion = 'Atraccion gratuita';
GO

EXEC gestion.sp_registrar_tipo_actividad
    @descripcion = 'Tour guiado';
GO

-- TEST 4.1: exitoso
PRINT '--- TEST 4.1: Registrar actividad exitosa ---';
EXEC gestion.sp_registrar_actividad
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
EXEC gestion.sp_registrar_actividad
    @id_parque   = 999,
    @id_guia     = 1,
    @nombre      = 'Test',
    @descripcion = 'Test',
    @tipo        = 'Tour guiado',
    @costo       = 0,
    @fecha       = '2026-08-15',
    @duracion    = 60,
    @cupo        = 10;
GO

-- TEST 4.3: guia con acreditacion vencida
PRINT '--- TEST 4.3: Guia con acreditacion vencida (debe fallar) ---';
EXEC gestion.sp_registrar_actividad
    @id_parque   = 1,
    @id_guia     = 2,
    @nombre      = 'Test',
    @descripcion = 'Test',
    @tipo        = 'Tour guiado',
    @costo       = 0,
    @fecha       = '2026-08-15',
    @duracion    = 60,
    @cupo        = 10;
GO
 
-- TEST 4.4: guia con acreditacion inactiva
PRINT '--- TEST 4.4: Guia con acreditacion inactiva (debe fallar) ---';
EXEC gestion.sp_registrar_actividad
    @id_parque   = 1,
    @id_guia     = 3,
    @nombre      = 'Test',
    @descripcion = 'Test',
    @tipo        = 'Tour guiado',
    @costo       = 0,
    @fecha       = '2026-08-15',
    @duracion    = 60,
    @cupo        = 10;
GO
 
-- TEST 4.5: fecha pasada
PRINT '--- TEST 4.5: Fecha pasada (debe fallar) ---';
EXEC gestion.sp_registrar_actividad
    @id_parque   = 1,
    @id_guia     = 1,
    @nombre      = 'Test',
    @descripcion = 'Test',
    @tipo        = 'Tour guiado',
    @costo       = 0,
    @fecha       = '2020-01-01',
    @duracion    = 60,
    @cupo        = 10;
GO
 
-- TEST 4.6: multiples errores en una sola llamada
PRINT '--- TEST 4.6: Multiples errores acumulados (debe mostrar todos juntos) ---';
EXEC gestion.sp_registrar_actividad
    @id_parque   = 999, -- parque no existe
    @id_guia     = 999, -- guia no existe
    @nombre      = 'Test',
    @descripcion = 'Test',
    @tipo        = 'Tour no guiado', -- tipo invalido
    @costo       = 0,
    @fecha       = '2020-01-01', -- fecha pasada
    @duracion    = 60,
    @cupo        = 10;
GO
 
-- ============================================================
-- SECCION 5: BAJA DE GUARDAPARQUE
-- ============================================================
 
PRINT '=== BAJA DE GUARDAPARQUE ===';
GO
 
-- TEST 5.1: exitoso (con asignacion activa, debe cerrarla automaticamente)
PRINT '--- TEST 5.1: Baja de guardaparque con asignacion activa ---';
EXEC gestion.sp_baja_guardaparque
    @id      = 1;
 
-- Evidencia: guardaparque inactivo y asignacion cerrada con fecha_egreso
SELECT id, nombre, estado FROM gestion.Guardaparque WHERE id = 1;
SELECT id, id_guardaparque, fecha_ingreso, fecha_egreso FROM gestion.Parque_asignado WHERE id_guardaparque = 1;
GO
 
-- TEST 5.2: guardaparque inexistente
PRINT '--- TEST 5.2: Guardaparque inexistente (debe fallar) ---';
EXEC gestion.sp_baja_guardaparque
    @id      = 999;
GO
 
-- ============================================================
-- SECCION 6: MODIFICACION DE PARQUE
-- ============================================================
 
PRINT '=== MODIFICACION DE PARQUE ===';
GO
 
-- TEST 6.1: exitoso
PRINT '--- TEST 6.1: Modificar parque exitoso ---';
EXEC gestion.sp_modificar_parque
    @id         = 1,
    @nombre     = 'Parque Nacional Iguazu',
    @tipo       = 'Nacional',
    @ubicacion  = 'Misiones, Argentina',
    @superficie = 70000;
 
-- Evidencia
SELECT id, nombre, tipo, ubicacion, superficie FROM gestion.Parque WHERE id = 1;
GO
 
-- TEST 6.2: parque inexistente
PRINT '--- TEST 6.2: Parque inexistente (debe fallar) ---';
EXEC gestion.sp_modificar_parque
    @id         = 999,
    @nombre     = 'Test',
    @tipo       = 'Test',
    @ubicacion  = 'Test',
    @superficie = 100;
GO
 
-- TEST 6.3: nombre en uso por otro parque
PRINT '--- TEST 6.3: Nombre duplicado en modificacion (debe fallar) ---';
EXEC gestion.sp_modificar_parque
    @id         = 2,
    @nombre     = 'Parque Nacional Iguazu',  -- nombre que ya usa el parque 1
    @tipo       = 'Nacional',
    @ubicacion  = 'Rio Negro',
    @superficie = 717261;
GO
 
-- ============================================================
-- SECCION 7: MODIFICACION DE GUARDAPARQUE
-- ============================================================
 
PRINT '=== MODIFICACION DE GUARDAPARQUE ===';
GO
 
-- TEST 7.1: exitoso
PRINT '--- TEST 7.1: Modificar guardaparque exitoso ---';
EXEC gestion.sp_modificar_guardaparque
    @id       = 2,
    @nombre   = 'Laura Beatriz',
    @apellido = 'Gomez',
    @estado   = 'Inactivo';
 
-- Evidencia
SELECT id, nombre, apellido, estado FROM gestion.Guardaparque WHERE id = 2;
GO
 
-- TEST 7.2: estado invalido
PRINT '--- TEST 7.2: Estado invalido (debe fallar) ---';
EXEC gestion.sp_modificar_guardaparque
    @id       = 2,
    @nombre   = 'Laura',
    @apellido = 'Gomez',
    @estado   = 'Suspendido';
GO
 
-- ============================================================
-- SECCION 8: MODIFICACION DE ASIGNACION
-- ============================================================
 
PRINT '=== MODIFICACION DE ASIGNACION ===';
GO
 
-- Primero reasignamos el guardaparque 1 para tener una asignacion activa
EXEC gestion.sp_asignar_guardaparque
    @id_parque       = 1,
    @id_guardaparque = 1;
GO
 
-- TEST 8.1: cerrar asignacion exitosamente
PRINT '--- TEST 8.1: Cerrar asignacion (egreso) exitoso ---';
EXEC gestion.sp_modificar_asignacion
    @id           = 2,   -- la nueva asignacion
    @motivo       = 'Fin de temporada';
 
-- Evidencia: asignacion con fecha_egreso y guardaparque en Inactivo
SELECT id, id_guardaparque, fecha_ingreso, fecha_egreso, motivo FROM gestion.Parque_asignado WHERE id = 2;
SELECT id, nombre, estado FROM gestion.Guardaparque WHERE id = 1;
GO
 
-- TEST 8.2: asignacion ya cerrada
PRINT '--- TEST 8.2: Asignacion ya cerrada (debe fallar) ---';
EXEC gestion.sp_modificar_asignacion
    @id           = 2,
    @motivo       = 'Test';
GO
 
-- ============================================================
-- SECCION 9: MODIFICACION DE ACTIVIDAD
-- ============================================================
 
PRINT '=== MODIFICACION DE ACTIVIDAD ===';
GO
 
-- TEST 9.1: exitoso
PRINT '--- TEST 9.1: Modificar actividad exitosa ---';
EXEC gestion.sp_modificar_actividad
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
EXEC gestion.sp_modificar_actividad
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
GO
 
-- TEST 9.3: multiples errores en modificacion
PRINT '--- TEST 9.3: Multiples errores en modificacion (debe mostrar todos) ---';
EXEC gestion.sp_modificar_actividad
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
GO

-- ============================================================
-- SECCION 10: BAJA DE ACTIVIDAD
-- ============================================================

PRINT '=== BAJA DE ACTIVIDAD ===';
GO

-- TEST 10.1: exitoso (cancelar actividad programada)
PRINT '--- TEST 10.1: Baja de actividad exitosa ---';
EXEC gestion.sp_baja_actividad
    @id     = 1,
    @motivo = 'Cancelada por condiciones climaticas';

-- Evidencia: estado debe ser 'Cancelado'
SELECT id, nombre, estado FROM gestion.Actividad WHERE id = 1;
GO

-- TEST 10.2: actividad inexistente
PRINT '--- TEST 10.2: Actividad inexistente (debe fallar) ---';
EXEC gestion.sp_baja_actividad
    @id     = 999,
    @motivo = 'Test';
GO

-- TEST 10.3: actividad ya cancelada (debe fallar)
PRINT '--- TEST 10.3: Actividad ya cancelada (debe fallar) ---';
EXEC gestion.sp_baja_actividad
    @id     = 1,
    @motivo = 'Intento duplicado';
GO

-- ============================================================
-- SECCION 11: ALTA DE GUIA
-- ============================================================

PRINT '=== ALTA DE GUIA ===';
GO

-- TEST 11.1: Registro exitoso
PRINT '--- TEST 11.1: Registrar guía exitosamente ---';
EXEC gestion.sp_registrar_guia
    @dni = '30456789',
    @nombre = 'Lucía',
    @apellido = 'Ferreyra',
    @fecha_vencimiento_acreditacion = '2026-12-31';
GO

-- TEST 11.2: Registro exitoso
PRINT '--- TEST 11.2: Registrar guía exitosamente ---';
EXEC gestion.sp_registrar_guia
    @dni = '25123456',
    @nombre = 'Marcos',
    @apellido = 'Villanueva',
    @fecha_vencimiento_acreditacion = '2025-06-13';
GO

-- TEST 11.3: DNI duplicado (debe fallar)
PRINT '--- TEST 11.3: DNI duplicado (debe fallar) ---';
EXEC gestion.sp_registrar_guia
    @dni = '30456789',
    @nombre = 'Lucas',
    @apellido = 'Perez',
    @fecha_vencimiento_acreditacion = '2030-03-29';
GO

-- TEST 11.4: DNI duplicado y nombre inválido (debe fallar)
PRINT '--- TEST 11.4: DNI duplicado y falta de nombre/apellido (debe fallar) ---';
EXEC gestion.sp_registrar_guia
    @dni = '30456789',
    @nombre = '',
    @apellido = 'Perez',
    @fecha_vencimiento_acreditacion = '2030-03-29';
GO

-- TEST 11.5: Formato de DNI inválido (debe fallar)
PRINT '--- TEST 11.5: DNI con formato inválido (debe fallar) ---';
EXEC gestion.sp_registrar_guia
    @dni = 'ABC12',
    @nombre = 'Lucas',
    @apellido = 'Perez',
    @fecha_vencimiento_acreditacion = '2030-03-29';
GO

-- TEST 11.6: Apellido vacío (debe fallar)
PRINT '--- TEST 11.6: Falta apellido (debe fallar) ---';
EXEC gestion.sp_registrar_guia
    @dni = '38912345',
    @nombre = 'Lucas',
    @apellido = '',
    @fecha_vencimiento_acreditacion = '2030-03-29';
GO

-- TEST 11.7: Apellido NULL (debe fallar)
PRINT '--- TEST 11.7: Apellido NULL (debe fallar) ---';
EXEC gestion.sp_registrar_guia
    @dni = '38912345',
    @nombre = 'Lucas',
    @apellido = NULL,
    @fecha_vencimiento_acreditacion = '2030-03-29';
GO

-- TEST 11.8: Fecha de vencimiento NULL (debe fallar)
PRINT '--- TEST 11.8: Falta fecha de vencimiento de la acreditacion (debe fallar) ---';
EXEC gestion.sp_registrar_guia
    @dni = '38912345',
    @nombre = 'Lucas',
    @apellido = 'Perez',
    @fecha_vencimiento_acreditacion = NULL;
GO

-- TEST 11.9: DNI NULL (debe fallar)
PRINT '--- TEST 11.9: Falta DNI (debe fallar) ---';
    EXEC gestion.sp_registrar_guia
    @dni = NULL,
    @nombre = 'Lucas',
    @apellido = 'Perez',
    @fecha_vencimiento_acreditacion = '2030-03-29';
GO

-- TEST 11.10: Registro exitoso
PRINT '--- TEST 11.10: Registrar guía exitosamente ---';
EXEC gestion.sp_registrar_guia
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
EXEC gestion.sp_actualizar_guia
    @dni = '30456789',
    @nombre = 'Luciano',
    @apellido = 'Fernandez';
GO

-- TEST 12.2: Actalizar exitoso
PRINT '--- TEST 12.2: Actalizar guía exitosamente ---';
EXEC gestion.sp_actualizar_guia
    @dni = '25123456',
    @nombre = 'Marcos',
    @apellido = 'Villanueva';
GO

-- TEST 12.3: DNI sin guia (debe fallar)
PRINT '--- TEST 12.3: DNI sin guia (debe fallar) ---';
EXEC gestion.sp_actualizar_guia
    @dni = '32000000',
    @nombre = 'Lucas',
    @apellido = 'Perez';
GO

-- TEST 12.4: Nombre inválido (debe fallar)
PRINT '--- TEST 12.4: Falta de nombre/apellido (debe fallar) ---';
EXEC gestion.sp_actualizar_guia
    @dni = '30456789',
    @nombre = '',
    @apellido = 'Perez';
GO

-- TEST 12.6: Apellido vacío (debe fallar)
PRINT '--- TEST 12.6: Falta apellido (debe fallar) ---';
EXEC gestion.sp_actualizar_guia
    @dni = '38912345',
    @nombre = 'Lucas',
    @apellido = '';
GO

-- TEST 12.7: Apellido NULL (debe fallar)
PRINT '--- TEST 12.7: Apellido NULL (debe fallar) ---';
EXEC gestion.sp_actualizar_guia
    @dni = '38912345',
    @nombre = 'Lucas',
    @apellido = NULL;
GO

-- TEST 12.8: DNI NULL (debe fallar)
PRINT '--- TEST 12.8: Falta DNI (debe fallar) ---';
    EXEC gestion.sp_actualizar_guia
    @dni = NULL,
    @nombre = 'Lucas',
    @apellido = 'Perez';
GO

-- ============================================================
-- SECCION 13: ASIGNACION DE GUIA A ACTIVIDAD
-- ============================================================

PRINT '=== ASIGNACION DE GUIA A ACTIVIDAD ===';
GO

PRINT '--- TEST 13.0: Registrar actividad exitosa ---';
EXEC gestion.sp_registrar_actividad
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
EXEC gestion.sp_asignar_guia
@dni = '30456789',
@nombre_actividad = 'Trekking Cataratas',
@nombre_parque = 'Parque Nacional Iguazu',
@fecha_actividad = '2026-06-16 00:00:00',
@f_desde = '2026-06-14',
@f_hasta = '2026-06-17';
GO

-- TEST 13.2: Actividad inexistente en el parque (debe fallar)
PRINT '--- TEST 13.2: Actividad inexistente en el parque (debe fallar) ---';
    EXEC gestion.sp_asignar_guia
    @dni = '30456789',
    @nombre_actividad = 'Trekking Cataratas',
    @nombre_parque = 'Parque Nahuel Huapi',
    @fecha_actividad = '2026-06-16 00:00:00',
    @f_desde = '2026-06-14',
    @f_hasta = '2026-06-17';
GO
 
 -- TEST 13.3: DNI NULL (debe fallar)
PRINT '--- TEST 13.3: Falta especificar DNI del guía (debe fallar) ---';
EXEC gestion.sp_asignar_guia
    @dni = NULL,
    @nombre_actividad = 'Trekking Cataratas',
    @nombre_parque = 'Parque Nacional Iguazu',
    @fecha_actividad = '2026-06-16 00:00:00.000',
    @f_desde = '2026-06-14',
    @f_hasta = '2026-06-17';
GO

-- TEST 13.4: Guía inexistente (debe fallar)
PRINT '--- TEST 13.4: DNI de guía inexistente (debe fallar) ---';
EXEC gestion.sp_asignar_guia
    @dni = '11122345',
    @nombre_actividad = 'Trekking Cataratas',
    @nombre_parque = 'Parque Nacional Iguazu',
    @fecha_actividad = '2026-06-16 00:00:00.000',
    @f_desde = '2026-06-14',
    @f_hasta = '2026-06-17';
GO

-- TEST 13.5: Nombre de actividad inexistente (debe fallar)
PRINT '--- TEST 13.5: Actividad inexistente (debe fallar) ---';
EXEC gestion.sp_asignar_guia
    @dni = '30456789',
    @nombre_actividad = 'Escalda',
    @nombre_parque = 'Parque Nacional Iguazu',
    @fecha_actividad = '2026-06-16 00:00:00.000',
    @f_desde = '2026-06-14',
    @f_hasta = '2026-06-17';
GO

-- TEST 13.6: Fecha de actividad incorrecta (debe fallar)
PRINT '--- TEST 13.6: Fecha de actividad inexistente (debe fallar) ---';
EXEC gestion.sp_asignar_guia
    @dni = '30456789',
    @nombre_actividad = 'Trekking Cataratas',
    @nombre_parque = 'Parque Nacional Iguazu',
    @fecha_actividad = '2026-06-17 00:00:00.000',
    @f_desde = '2026-06-14',
    @f_hasta = '2026-06-17';
GO

-- TEST 13.7: Nombre de actividad NULL (debe fallar)
PRINT '--- TEST 13.7: Falta nombre de actividad (debe fallar) ---';
EXEC gestion.sp_asignar_guia
    @dni = '30456789',
    @nombre_actividad = NULL,
    @nombre_parque = 'Parque Nacional Iguazu',
    @fecha_actividad = '2026-06-16 00:00:00.000',
    @f_desde = '2026-06-14',
    @f_hasta = '2026-06-17';
GO

-- TEST 13.8: Fecha de actividad NULL (debe fallar)
PRINT '--- TEST 13.8: Falta fecha de actividad (debe fallar) ---';
EXEC gestion.sp_asignar_guia
    @dni = '30456789',
    @nombre_actividad = 'Trekking Cataratas',
    @nombre_parque = 'Parque Nacional Iguazu',
    @fecha_actividad = NULL,
    @f_desde = '2026-06-14',
    @f_hasta = '2026-06-17';
GO

-- TEST 13.9: Fecha desde NULL (debe fallar)
PRINT '--- TEST 13.9: Falta fecha desde (debe fallar) ---';
    EXEC gestion.sp_asignar_guia
    @dni = '30456789',
    @nombre_actividad = 'Trekking Cataratas',
    @nombre_parque = 'Parque Nacional Iguazu',
    @fecha_actividad = '2026-06-16 00:00:00.000',
    @f_desde = NULL,
    @f_hasta = '2026-06-17';
GO

-- TEST 13.10: Fecha hasta NULL (debe fallar)
PRINT '--- TEST 13.10: Falta fecha hasta (debe fallar) ---';
EXEC gestion.sp_asignar_guia
    @dni = '30456789',
    @nombre_actividad = 'Trekking Cataratas',
    @nombre_parque = 'Parque Nacional Iguazu',
    @fecha_actividad = '2026-06-16 00:00:00.000',
    @f_desde = '2026-06-14',
    @f_hasta = NULL;
GO

-- TEST 13.11: Asignación duplicada (debe fallar)
PRINT '--- TEST 13.11: La actividad ya está asignada al guía (debe fallar) ---';
EXEC gestion.sp_asignar_guia
    @dni = '30456789',
    @nombre_actividad = 'Trekking Cataratas',
    @nombre_parque = 'Parque Nacional Iguazu',
    @fecha_actividad = '2026-06-16 00:00:00.000',
    @f_desde = '2026-06-14',
    @f_hasta = '2026-06-17';
GO

-- TEST 13.12: Guía con acreditación vencida (debe fallar)
PRINT '--- TEST 13.12: Guía con acreditación vencida (debe fallar) ---';
EXEC gestion.sp_asignar_guia
    @dni = '25123456',
    @nombre_actividad = 'Trekking Cataratas',
    @nombre_parque = 'Parque Nacional Iguazu',
    @fecha_actividad = '2026-06-16 00:00:00.000',
    @f_desde = '2026-06-14',
    @f_hasta = '2026-06-17';
GO
/* ============================================================
   UNLAM
   Materia: 3641 - Bases de Datos Aplicada
   TP: Sistema de Gestion de Parques Nacionales
   Integrantes:
   Archivo: Titulo.sql
   Fecha: 2026-06-12  
   ============================================================ */

create table Personal.Titulo (
    id int identity(1,1) primary key,
    descripcion varchar(100) null,
    institucion varchar(100) not null,
    fecha_emision date not null
);

create or alter procedure Personal.sp_alta_titulo
    @institucion varchar(100),
    @fe date
as begin
    insert into Personal.Titulo (institucion, fecha_emision) values (@institucion, @fe);
end;

create or alter procedure Personal.sp_baja_titulo @id int as begin
    delete from Personal.Titulo where id = @id;
end;

create or alter procedure Personal.sp_modificacion_titulo
    @id int,
    @institucion varchar(100),
    @fe date
as begin
    update Personal.Titulo set institucion = isnull(@institucion, institucion), fecha_emision = isnull(@fe, fecha_emision) where id = @id;
end;

-------------------------------------------------------------------------------
-- Test 1: Alta exito
-- Esperado: se inserta un titulo con institucion y fecha dadas.
-------------------------------------------------------------------------------
print '--- Test 1: sp_alta_titulo (exito) ---';
begin tran;
begin try
    exec Personal.sp_alta_titulo @institucion = 'Universidad de Buenos Aires', @fe = '2020-03-15';

    select * from Personal.Titulo where institucion = 'Universidad de Buenos Aires';

    if exists (select 1 from Personal.Titulo where institucion = 'Universidad de Buenos Aires' and fecha_emision = '2020-03-15')
        print 'OK - Test 1: titulo dado de alta correctamente.';
    else
        print 'FALLO - Test 1: no se encontro el titulo esperado.';
end try
begin catch
    print 'FALLO - Test 1: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 2: Modificacion exito (cambia institucion, conserva fecha con @fe = NULL)
-- Esperado: institucion cambia; fecha_emision queda igual por el isnull(...).
-------------------------------------------------------------------------------
print '--- Test 2: sp_modificacion_titulo (exito, modificacion parcial) ---';
begin tran;
begin try
    exec Personal.sp_alta_titulo @institucion = 'Universidad de Buenos Aires', @fe = '2020-03-15';
    declare @idTit int = (select top 1 id from Personal.Titulo where institucion = 'Universidad de Buenos Aires' order by id desc);

    exec Personal.sp_modificacion_titulo @id = @idTit, @institucion = 'UBA - Facultad de Ciencias', @fe = null;

    select * from Personal.Titulo where id = @idTit;

    if exists (select 1 from Personal.Titulo
               where id = @idTit and institucion = 'UBA - Facultad de Ciencias' and fecha_emision = '2020-03-15')
        print 'OK - Test 2: modificacion parcial respeto la fecha original.';
    else
        print 'FALLO - Test 2: la modificacion no quedo como se esperaba.';
end try
begin catch
    print 'FALLO - Test 2: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 3: Baja exito (delete fisico)
-- Esperado: el titulo deja de existir tras sp_baja_titulo.
-------------------------------------------------------------------------------
print '--- Test 3: sp_baja_titulo (exito) ---';
begin tran;
begin try
    exec Personal.sp_alta_titulo @institucion = 'Titulo a Borrar', @fe = '2019-12-01';
    declare @idBaja int = (select top 1 id from Personal.Titulo where institucion = 'Titulo a Borrar' order by id desc);

    exec Personal.sp_baja_titulo @id = @idBaja;

    if not exists (select 1 from Personal.Titulo where id = @idBaja)
        print 'OK - Test 3: el titulo fue eliminado.';
    else
        print 'FALLO - Test 3: el titulo todavia existe.';
end try
begin catch
    print 'FALLO - Test 3: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 4 (VALIDACION): institucion NULL (viola NOT NULL)
-- Esperado: el insert falla por la restriccion NOT NULL de institucion.
-------------------------------------------------------------------------------
print '--- Test 4: sp_alta_titulo con institucion NULL (validacion) ---';
begin tran;
begin try
    exec Personal.sp_alta_titulo @institucion = null, @fe = '2020-01-01';
    print 'FALLO - Test 4: se esperaba error por institucion NULL y no ocurrio.';
end try
begin catch
    print 'OK - Test 4: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 5 (VALIDACION): fecha_emision NULL en alta (viola NOT NULL)
-- Esperado: el insert falla por la restriccion NOT NULL de fecha_emision.
-------------------------------------------------------------------------------
print '--- Test 5: sp_alta_titulo con fecha_emision NULL (validacion) ---';
begin tran;
begin try
    exec Personal.sp_alta_titulo @institucion = 'Sin Fecha', @fe = null;
    print 'FALLO - Test 5: se esperaba error por fecha_emision NULL y no ocurrio.';
end try
begin catch
    print 'OK - Test 5: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

print '=== Fin test_Titulo.sql ===';
/* ============================================================
   UNLAM
   Materia: 3641 - Bases de Datos Aplicada
   TP: Sistema de Gestion de Parques Nacionales
   Integrantes:
   Archivo: Empresa.sql
   Fecha: 2026-06-12  
   ============================================================ */

   use parque_nacional;
if object_id('concesiones.Empresa', 'U') is null then
    create table concesiones.Empresa (
	    id int not null primary key identity(1, 1),
	    nombre varchar(25) not null unique,
	    tipo varchar(100) not null,
	    cuit varchar(15) not null unique,
        constraint check_cuit_formato check(cuit like '3[034][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' or cuit like '2[0347][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    );
end
go

-- TODO validaciones:
-- actualizar tests

-- TODO nuevo archivo de SP
create or alter procedure concesiones.sp_alta_empresa (@nombre varchar(25), @tipo varchar(100), @cuit varchar(15)) as begin
	-- vale la pena una funcion para ver si el cuit es valido? -> si + raiserror con un solo mensaje
    declare @errores varchar(4000) = '';

    if @cuit is not null and len(@cuit) <> 11 begin
        set @errores = 'El cuit solo puede tener 11 caracteres.' + char(10)
    end

    if @cuit is not null and not (@cuit like '3[034][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' or @cuit like '2[0347][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') begin
        set @errores += 'El cuit no tiene el formato de una empresa.' + char(10)
    end

    if @errores <> '' begin
        raiserror(@errores, 16, 1)
        return
    end

	insert into concesiones.Empresa (nombre, tipo, cuit) values (@nombre, @tipo, @cuit);
end;
go

create or alter procedure concesiones.sp_baja_empresa (@nombre varchar(25)) as begin
    declare @id int;
    declare @errores varchar(4000) = '';

    select @id = id from concesiones.Empresa where nombre=@nombre;

    if @id is null begin
        set @errores = 'No se encontro la empresa.' + char(10)
    end

    if @errores <> '' begin
        raiserror(@errores, 16, 1)
        return
    end;

	delete from concesiones.Empresa where id=@id
end;
go

create or alter procedure concesiones.sp_modificacion_empresa (
    @nombre varchar(25),
    @nuevo_nombre varchar(25) = null,
    @tipo varchar(100) = null,
    @cuit varchar(15) = null
) as begin
    declare @id int;
    declare @errores varchar(4000) = '';

    select @id = id from concesiones.Empresa where nombre=@nombre;

    if @id is null begin
        set @errores = 'No se encontro la empresa.' + char(10)
    end

    if @nuevo_nombre is not null and @nuevo_nombre <> @nombre and exists ( select 1 from concesiones.Empresa where nombre=@nuevo_nombre) begin
        set @errores += 'Ya existe una empresa con ese nombre.' + char(10)
    end

    if @cuit is not null and len(@cuit) <> 11 begin
        set @errores += 'El cuit solo puede tener 11 caracteres.' + char(10)
    end

    if @cuit is not null and not (@cuit like '3[034][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' or @cuit like '2[0347][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') begin
        set @errores += 'El cuit no tiene el formato de una empresa.' + char(10)
    end

    if @errores <> '' begin
        raiserror(@errores, 16, 1)
        return
    end;

	update concesiones.Empresa set nombre=isnull(@nuevo_nombre, nombre), tipo=isnull(@tipo, tipo), cuit=isnull(@cuit, cuit) where id = @id
end;
go


-------------------------------------------------------------------------------
-- Test 1: Alta exito
-- Esperado: se inserta una empresa con los datos dados. EXISTS = verdadero.
-------------------------------------------------------------------------------
print '--- Test 1: sp_alta_empresa (exito) ---';
begin tran;
begin try
    exec concesiones.sp_alta_empresa @nombre = 'Resto del Lago SA', @tipo = 'restaurante', @cuit = '30123456789';

    -- evidencia
    select * from concesiones.Empresa where nombre = 'Resto del Lago SA';

    if exists (select 1 from concesiones.Empresa where nombre = 'Resto del Lago SA' and cuit = '30123456789')
        print 'OK - Test 1: empresa dada de alta correctamente.';
    else
        print 'FALLO - Test 1: no se encontro la empresa esperada.';
end try
begin catch
    print 'FALLO - Test 1: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 2: Modificacion exito
-- Esperado: nombre cambia a 'Resto del Lago SRL'; tipo y cuit quedan igual.
-------------------------------------------------------------------------------
print '--- Test 2: sp_modificacion_empresa (exito, modificacion parcial) ---';
begin tran;
begin try
    exec concesiones.sp_alta_empresa @nombre = 'Empresa 1', @tipo = 'restaurante', @cuit = '30123456789';
    declare @idEmp int = (select top 1 id from concesiones.Empresa where nombre = 'Empresa 1' order by id desc);

    exec concesiones.sp_modificacion_empresa @nombre = 'Empresa 1', @nuevo_nombre = 'Empresa 2';

    select * from concesiones.Empresa where id = @idEmp;

    if exists (select 1 from concesiones.Empresa
               where id = @idEmp and nombre = 'Empresa 2'
                 and tipo = 'restaurante' and cuit = '30123456789')
        print 'OK - Test 2: modificacion parcial respeto los campos no enviados.';
    else
        print 'FALLO - Test 2: la modificacion no quedo como se esperaba.';
end try
begin catch
    print 'FALLO - Test 2: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 3: Baja exito (delete fisico)
-- Esperado: la empresa deja de existir tras sp_baja_empresa.
-------------------------------------------------------------------------------
print '--- Test 3: sp_baja_empresa (exito) ---';
begin tran;
begin try
    exec concesiones.sp_alta_empresa @nombre = 'Empresa a Borrar', @tipo = 'tienda', @cuit = '30999999998';
    declare @idBaja int = (select top 1 id from concesiones.Empresa where nombre = 'Empresa a Borrar' order by id desc);

    exec concesiones.sp_baja_empresa @nombre = 'Empresa a Borrar';

    if not exists (select 1 from concesiones.Empresa where id = @idBaja)
        print 'OK - Test 3: la empresa fue eliminada.';
    else
        print 'FALLO - Test 3: la empresa todavia existe.';
end try
begin catch
    print 'FALLO - Test 3: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 4: CUIT con formato invalido
-- Esperado: el SP o el constraint check_cuit_formato rechaza el insert.
-------------------------------------------------------------------------------
print '--- Test 4: sp_alta_empresa con CUIT invalido (validacion) ---';
begin tran;
begin try
    exec concesiones.sp_alta_empresa @nombre = 'CUIT Malo', @tipo = 'tienda', @cuit = '123';
    print 'FALLO - Test 4: se esperaba un error de CHECK por CUIT invalido y no ocurrio.';
end try
begin catch
    print 'OK - Test 4: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 5: nombre NULL
-- Esperado: el insert falla por la restriccion NOT NULL de nombre.
-------------------------------------------------------------------------------
print '--- Test 5: sp_alta_empresa con nombre NULL (validacion) ---';
begin tran;
begin try
    exec concesiones.sp_alta_empresa @nombre = null, @tipo = 'tienda', @cuit = '30123456789';
    print 'FALLO - Test 5: se esperaba error por nombre NULL y no ocurrio.';
end try
begin catch
    print 'OK - Test 5: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 6: nombre duplicado
-- Esperado: el alta falla por la restriccion UNIQUE de nombre.
-------------------------------------------------------------------------------
print '--- Test 6: sp_alta_empresa con nombre duplicado (validacion) ---';
begin tran;
begin try
    exec concesiones.sp_alta_empresa @nombre = 'Empresa Duplicada', @tipo = 'tienda', @cuit = '30123456789';
    exec concesiones.sp_alta_empresa @nombre = 'Empresa Duplicada', @tipo = 'tienda', @cuit = '30123456780';
    print 'FALLO - Test 6: se esperaba error por nombre duplicado y no ocurrio.';
end try
begin catch
    print 'OK - Test 6: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 7: Baja con empresa inexistente
-- Esperado: el SP rechaza la operacion porque no encuentra la empresa.
-------------------------------------------------------------------------------
print '--- Test 7: sp_baja_empresa con empresa inexistente (validacion) ---';
begin tran;
begin try
    exec concesiones.sp_baja_empresa @nombre = 'Empresa inexistente';
    print 'FALLO - Test 7: se esperaba error por empresa inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 7: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 8: Modificacion con empresa inexistente
-- Esperado: el SP rechaza la operacion porque no encuentra la empresa.
-------------------------------------------------------------------------------
print '--- Test 8: sp_modificacion_empresa con empresa inexistente (validacion) ---';
begin tran;
begin try
    exec concesiones.sp_modificacion_empresa @nombre = 'Empresa inexistente', @nuevo_nombre = 'Empresa Nueva';
    print 'FALLO - Test 8: se esperaba error por empresa inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 8: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 9: Modificacion con nombre nuevo duplicado
-- Esperado: el SP rechaza la operacion porque el nombre nuevo ya existe.
-------------------------------------------------------------------------------
print '--- Test 9: sp_modificacion_empresa con nombre duplicado (validacion) ---';
begin tran;
begin try
    exec concesiones.sp_alta_empresa @nombre = 'Empresa Original', @tipo = 'tienda', @cuit = '30123456789';
    exec concesiones.sp_alta_empresa @nombre = 'Empresa Existente', @tipo = 'tienda', @cuit = '30123456780';

    exec concesiones.sp_modificacion_empresa @nombre = 'Empresa Original', @nuevo_nombre = 'Empresa Existente';
    print 'FALLO - Test 9: se esperaba error por nombre duplicado y no ocurrio.';
end try
begin catch
    print 'OK - Test 9: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

print '=== Fin test_Empresa.sql ===';

/* ============================================================
   UNLAM
   Materia: 3641 - Bases de Datos Aplicada
   TP: Sistema de Gestion de Parques Nacionales
   Integrantes:
   Archivo: Concesion.sql
   Fecha: 2026-06-12  
   ============================================================ */

use parque_nacional;


if object_id('concesiones.Concesion', 'U') is null
    create table concesiones.Concesion (
	    id int not null primary key identity(1, 1),
	    fecha_inicio date not null,
	    fecha_fin datetime,
	    canon_mensual numeric(10, 2),
	    estado char(8) constraint check_estado_concesion check(estado = 'ACTIVO' or estado = 'INACTIVO'),
	    id_empresa int not null,
	    id_parque int not null,
	    id_actividad int null,
	    constraint fk_concesion_empresa foreign key (id_empresa) references concesiones.Empresa(id),
	    constraint fk_concesion_parque foreign key (id_parque) references concesiones.Parque(id),
	    constraint fk_concesion_actividad foreign key (id_actividad) references concesiones.Actividad(id),
        constraint uq_concesion_empresa_parque_inicio unique (id_empresa, id_parque, fecha_inicio)
    );
end
go

create or alter procedure concesiones.sp_alta_concesion(
    @empresa varchar(25),
    @parque varchar(100),
    @canon_mensual numeric(10, 2),
    @fecha_inicio date = null,
    @actividad int = null
) as begin

    declare @id_empresa int = (select top 1 id from concesiones.Empresa where nombre = @empresa);
    declare @id_parque int = (select top 1 id from concesiones.Parque where nombre = @parque);
    declare @errores varchar(4000) = '';

	if @fecha_inicio is null begin
		set @fecha_inicio = CURRENT_TIMESTAMP;
	end;

    if @id_empresa is null begin
        set @errores = 'No se encontro la empresa.' + CHAR(10)
    end

    if @id_parque is null begin
        set @errores += 'No se encontro el parque.' + CHAR(10)
    end

	if @canon_mensual < 0 begin
        set @errores += 'El canon mensual no puede ser negativo.' + CHAR(10)
	end

    if @errores <> '' begin
        raiserror(@errores, 16, 1)
        return
    end

	insert into concesiones.Concesion (fecha_inicio, canon_mensual, estado, id_empresa, id_parque, id_actividad) values (@fecha_inicio, @canon_mensual, 'ACTIVO', @id_empresa, @id_parque, @actividad)
end;
go

create or alter procedure concesiones.sp_validacion_concesion(
    @empresa varchar(100),
    @parque varchar(100),
    @fecha_inicio date,
    @errores varchar(4000) output,
    @id_concesion int output
) as begin
    declare @id_empresa int = (select top 1 id from concesiones.Empresa where nombre = @empresa);
    declare @id_parque int = (select top 1 id from concesiones.Parque where nombre = @parque);

    if @id_empresa is null begin
        set @errores += 'No se encontro la empresa.' + char(10);
    end

    if @id_parque is null begin
        set @errores += 'No se encontro el parque.' + char(10);
    end

    set @id_concesion = (
        select top 1 id
        from concesiones.Concesion
        where id_empresa = @id_empresa
          and id_parque = @id_parque
          and fecha_inicio = @fecha_inicio
    );

    if @id_concesion is null begin
        set @errores += 'No se encontro la concesion.' + char(10);
    end
end;
go

create or alter procedure concesiones.sp_baja_concesion (
    @empresa varchar(100),
    @parque varchar(100),
    @fecha_inicio datetime
) as begin

    declare @id_concesion int = null;
    declare @errores varchar(4000) = '';

    execute concesiones.sp_validacion_concesion @empresa, @parque, @fecha_inicio, @errores output, @id_concesion output;

    if @errores <> '' begin
        raiserror(@errores, 16, 1)
        return
    end

	update concesiones.Concesion set estado='INACTIVO' where id = @id_concesion
end;
go


-- si se quiere invalidar la fecha de fin se tiene que pasar la fecha '1900-01-01'
create or alter procedure concesiones.sp_modificacion_concesion(
        @empresa varchar(100),
        @parque varchar(100), 
        @fecha_inicio datetime, 
        @fecha_fin date = null,
        @estado char(10) = null, 
        @canon numeric(10, 2) = null,
        @empresa_nueva varchar(100) = null,
        @parque_nuevo varchar(100) = null
    ) as begin
	
    declare @id_concesion int = null;
    declare @errores varchar(4000) = '';

    execute concesiones.sp_validacion_concesion @empresa, @parque, @fecha_inicio, @errores output, @id_concesion output;

    declare @id_empresa int = null;
    declare @id_parque int = null;

    if @empresa_nueva is not null begin
        select @id_empresa = id from concesiones.Empresa where nombre = @empresa_nueva;
   
        if @id_empresa is null begin
            set @errores += 'No se encontro la empresa nueva.' + char(10)
        end
    end

    if @parque_nuevo is not null begin
        select @id_parque = id from concesiones.Parque where nombre = @parque_nuevo;
        if @id_parque is null begin
            set @errores += 'No se encontro el parque nuevo.' + char(10)
        end
    end
    
    if @errores <> '' begin
        raiserror(@errores, 16, 1)
        return
    end

    update concesiones.Concesion
	set
		canon_mensual=isnull(@canon, canon_mensual),
		estado=isnull(@estado, estado),
        id_empresa=isnull(@id_empresa, id_empresa),
        id_parque=isnull(@id_parque, id_parque),
		fecha_fin = case
            when @fecha_fin = '1900-01-01' then null
            when @fecha_fin is null then fecha_fin
            else @fecha_fin
        end where id = @id_concesion
end;
go

set nocount on;

if object_id('concesiones.Parque', 'U') is null
begin
    print 'SKIP - concesiones.sql: la tabla concesiones.Parque aun no existe. Estos tests corren cuando este disponible.';
    return;
end

-------------------------------------------------------------------------------
-- Test 1: Alta exito
-- Esperado: se crea una Concesion con estado 'ACTIVO' para la empresa creada.
-------------------------------------------------------------------------------
print '--- Test 1: sp_alta_concesion (exito) ---';
begin tran;
begin try
    insert into concesiones.Parque (nombre, tipo, ubicacion, superficie) values ('Parque Test Concesion 1', 'NACIONAL', 'Test', 100.00);
    declare @idParque1 int = (select top 1 id from concesiones.Parque where nombre = 'Parque Test Concesion 1');

    exec concesiones.sp_alta_empresa @nombre = 'Concesionaria Test 1', @tipo = 'restaurante', @cuit = '30123456789';
    declare @idEmp1 int = (select top 1 id from concesiones.Empresa where nombre = 'Concesionaria Test 1');

    exec concesiones.sp_alta_concesion @empresa = 'Concesionaria Test 1', @parque = 'Parque Test Concesion 1', @canon_mensual = 1500.00, @fecha_inicio = '2026-01-01';

    select * from concesiones.Concesion where id_empresa = @idEmp1;

    if exists (select 1 from concesiones.Concesion
               where id_empresa = @idEmp1
                 and id_parque = @idParque1
                 and fecha_inicio = '2026-01-01'
                 and rtrim(estado) = 'ACTIVO'
                 and canon_mensual = 1500.00)
        print 'OK - Test 1: concesion creada con estado ACTIVO.';
    else
        print 'FALLO - Test 1: no se creo la concesion esperada.';
end try
begin catch
    print 'FALLO - Test 1: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 2: Modificacion exito
-- Esperado: cambia canon, estado y fecha_fin buscando por empresa/parque/fecha.
-------------------------------------------------------------------------------
print '--- Test 2: sp_modificacion_concesion (exito) ---';
begin tran;
begin try
    insert into concesiones.Parque (nombre, tipo, ubicacion, superficie) values ('Parque Test Concesion 2', 'NACIONAL', 'Test', 100.00);

    exec concesiones.sp_alta_empresa @nombre = 'Concesionaria Test 2', @tipo = 'tienda', @cuit = '30123456789';
    declare @idEmp2 int = (select top 1 id from concesiones.Empresa where nombre = 'Concesionaria Test 2' order by id desc);
    exec concesiones.sp_alta_concesion @empresa = 'Concesionaria Test 2', @parque = 'Parque Test Concesion 2', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
    declare @idCon2 int = (select top 1 id from concesiones.Concesion where id_empresa = @idEmp2 order by id desc);

    exec concesiones.sp_modificacion_concesion @empresa = 'Concesionaria Test 2', @parque = 'Parque Test Concesion 2', @fecha_inicio = '2026-01-01', @fecha_fin = '2026-12-31', @estado = 'INACTIVO', @canon = 999.99;

    select * from concesiones.Concesion where id = @idCon2;

    if exists (select 1 from concesiones.Concesion
               where id = @idCon2
                 and canon_mensual = 999.99
                 and rtrim(estado) = 'INACTIVO'
                 and fecha_fin = '2026-12-31')
        print 'OK - Test 2: concesion modificada correctamente.';
    else
        print 'FALLO - Test 2: la modificacion no quedo como se esperaba.';
end try
begin catch
    print 'FALLO - Test 2: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 3: Baja exito
-- Esperado: la concesion queda con estado 'INACTIVO'.
-------------------------------------------------------------------------------
print '--- Test 3: sp_baja_concesion (exito, baja logica) ---';
begin tran;
begin try
    insert into concesiones.Parque (nombre, tipo, ubicacion, superficie)
    values ('Parque Test Concesion 3', 'NACIONAL', 'Test', 100.00);

    exec concesiones.sp_alta_empresa @nombre = 'Concesionaria Test 3', @tipo = 'tienda', @cuit = '30123456789';
    declare @idEmp3 int = (select top 1 id from concesiones.Empresa where nombre = 'Concesionaria Test 3' order by id desc);
    exec concesiones.sp_alta_concesion @empresa = 'Concesionaria Test 3', @parque = 'Parque Test Concesion 3', @canon_mensual = 1200.00, @fecha_inicio = '2026-01-01';
    declare @idCon3 int = (select top 1 id from concesiones.Concesion where id_empresa = @idEmp3 order by id desc);

    exec concesiones.sp_baja_concesion @empresa = 'Concesionaria Test 3', @parque = 'Parque Test Concesion 3', @fecha_inicio = '2026-01-01';

    if exists (select 1 from concesiones.Concesion where id = @idCon3 and estado = 'INACTIVO')
        print 'OK - Test 3: la concesion quedo INACTIVO (baja logica).';
    else
        print 'FALLO - Test 3: la baja logica no se aplico.';
end try
begin catch
    print 'FALLO - Test 3: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 4: Alta con canon mensual negativo
-- Esperado: el SP rechaza la operacion y no inserta ninguna concesion.
-------------------------------------------------------------------------------
print '--- Test 4: sp_alta_concesion con canon negativo (validacion) ---';
begin tran;
begin try
    insert into concesiones.Parque (nombre, tipo, ubicacion, superficie) values ('Parque Test Concesion 4', 'NACIONAL', 'Test', 100.00);

    exec concesiones.sp_alta_empresa @nombre = 'Concesionaria Test 4', @tipo = 'tienda', @cuit = '30123456789';
    declare @idEmp4 int = (select top 1 id from concesiones.Empresa where nombre = 'Concesionaria Test 4' order by id desc);

    exec concesiones.sp_alta_concesion @empresa = 'Concesionaria Test 4', @parque = 'Parque Test Concesion 4', @canon_mensual = -50.00, @fecha_inicio = '2026-01-01';
    print 'FALLO - Test 4: se esperaba error por canon negativo y no ocurrio.';
end try
begin catch
    if not exists (select 1 from concesiones.Concesion where id_empresa = @idEmp4)
        print 'OK - Test 4: rechazado como se esperaba. Detalle: ' + error_message();
    else
        print 'FALLO - Test 4: se inserto una concesion pese al canon negativo.';
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 5: Alta con empresa inexistente
-- Esperado: el SP rechaza la operacion porque no encuentra la empresa.
-------------------------------------------------------------------------------
print '--- Test 5: sp_alta_concesion con empresa inexistente (validacion) ---';
begin tran;
begin try
    insert into concesiones.Parque (nombre, tipo, ubicacion, superficie) values ('Parque Test Concesion 5', 'NACIONAL', 'Test', 100.00);

    exec concesiones.sp_alta_concesion @empresa = 'Empresa inexistente', @parque = 'Parque Test Concesion 5', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
    print 'FALLO - Test 5: se esperaba error por empresa inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 5: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 6: Alta con parque inexistente
-- Esperado: el SP rechaza la operacion porque no encuentra el parque.
-------------------------------------------------------------------------------
print '--- Test 6: sp_alta_concesion con parque inexistente (validacion) ---';
begin tran;
begin try
    exec concesiones.sp_alta_empresa @nombre = 'Concesionaria Test 6', @tipo = 'tienda', @cuit = '30123456789';

    exec concesiones.sp_alta_concesion @empresa = 'Concesionaria Test 6', @parque = 'Parque inexistente', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
    print 'FALLO - Test 6: se esperaba error por parque inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 6: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 7: Baja con concesion inexistente
-- Esperado: el SP rechaza la operacion porque no encuentra la concesion.
-------------------------------------------------------------------------------
print '--- Test 7: sp_baja_concesion con concesion inexistente (validacion) ---';
begin tran;
begin try
    insert into concesiones.Parque (nombre, tipo, ubicacion, superficie)
    values ('Parque Test Concesion 7', 'NACIONAL', 'Test', 100.00);

    exec concesiones.sp_alta_empresa @nombre = 'Concesionaria Test 7', @tipo = 'tienda', @cuit = '30123456789';

    exec concesiones.sp_baja_concesion @empresa = 'Concesionaria Test 7', @parque = 'Parque Test Concesion 7', @fecha_inicio = '2026-01-01';
    print 'FALLO - Test 7: se esperaba error por concesion inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 7: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 8: Modificacion con estado invalido
-- Esperado: el constraint check_estado_concesion rechaza el update.
-------------------------------------------------------------------------------
print '--- Test 8: sp_modificacion_concesion con estado invalido (validacion) ---';
begin tran;
begin try
    insert into concesiones.Parque (nombre, tipo, ubicacion, superficie) values ('Parque Test Concesion 8', 'NACIONAL', 'Test', 100.00);

    exec concesiones.sp_alta_empresa @nombre = 'Concesionaria Test 8', @tipo = 'tienda', @cuit = '30123456789';
    exec concesiones.sp_alta_concesion @empresa = 'Concesionaria Test 8', @parque = 'Parque Test Concesion 8', @canon_mensual = 800.00, @fecha_inicio = '2026-01-01';

    exec concesiones.sp_modificacion_concesion @empresa = 'Concesionaria Test 8', @parque = 'Parque Test Concesion 8', @fecha_inicio = '2026-01-01', @estado = 'RARO';
    print 'FALLO - Test 8: se esperaba error de CHECK por estado invalido y no ocurrio.';
end try
begin catch
    print 'OK - Test 8: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 9: Modificacion con empresa nueva inexistente
-- Esperado: el SP rechaza la operacion porque no encuentra la empresa nueva.
-------------------------------------------------------------------------------
print '--- Test 9: sp_modificacion_concesion con empresa nueva inexistente (validacion) ---';
begin tran;
begin try
    insert into concesiones.Parque (nombre, tipo, ubicacion, superficie) values ('Parque Test Concesion 9', 'NACIONAL', 'Test', 100.00);

    exec concesiones.sp_alta_empresa @nombre = 'Concesionaria Test 9', @tipo = 'tienda', @cuit = '30123456789';
    exec concesiones.sp_alta_concesion @empresa = 'Concesionaria Test 9', @parque = 'Parque Test Concesion 9', @canon_mensual = 800.00, @fecha_inicio = '2026-01-01';

    exec concesiones.sp_modificacion_concesion @empresa = 'Concesionaria Test 9', @parque = 'Parque Test Concesion 9', @fecha_inicio = '2026-01-01', @empresa_nueva = 'Empresa nueva inexistente';
    print 'FALLO - Test 9: se esperaba error por empresa nueva inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 9: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 10: Modificacion con parque nuevo inexistente
-- Esperado: el SP rechaza la operacion porque no encuentra el parque nuevo.
-------------------------------------------------------------------------------
print '--- Test 10: sp_modificacion_concesion con parque nuevo inexistente (validacion) ---';
begin tran;
begin try
    insert into concesiones.Parque (nombre, tipo, ubicacion, superficie) values ('Parque Test Concesion 10', 'NACIONAL', 'Test', 100.00);

    exec concesiones.sp_alta_empresa @nombre = 'Concesionaria Test 10', @tipo = 'tienda', @cuit = '30123456789';
    exec concesiones.sp_alta_concesion @empresa = 'Concesionaria Test 10', @parque = 'Parque Test Concesion 10', @canon_mensual = 800.00, @fecha_inicio = '2026-01-01';

    exec concesiones.sp_modificacion_concesion @empresa = 'Concesionaria Test 10', @parque = 'Parque Test Concesion 10', @fecha_inicio = '2026-01-01', @parque_nuevo = 'Parque nuevo inexistente';
    print 'FALLO - Test 10: se esperaba error por parque nuevo inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 10: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

print '=== Fin test_Concesion.sql ===';
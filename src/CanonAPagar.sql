
/* ============================================================
   UNLAM
   Materia: 3641 - Bases de Datos Aplicada
   TP: Sistema de Gestion de Parques Nacionales
   Archivo: CanonAPagar.sql
   Fecha: 2026-06-12
   ============================================================ */

use parque_nacional;
go

if object_id('concesiones.Canon_pagar', 'U') is null
begin
    create table concesiones.Canon_pagar (
        id int identity(1,1) primary key,
        monto decimal(10, 2) not null,
        fecha_generacion date not null,
        fecha_pagado date null,
        estado varchar(30) not null,
        periodo varchar(50) not null,
        id_concesion int not null,
        constraint fk_canon_concesion foreign key (id_concesion) references concesiones.Concesion(id),
        constraint uq_canon_concesion_fecha unique (id_concesion, fecha_generacion)
    );
end
go

create or alter procedure concesiones.sp_alta_canon_pagar (
    @fecha_generacion date,
    @periodo varchar(50),
    @empresa varchar(25),
    @parque varchar(100),
    @fecha_inicio date
) as begin
    declare @id_concesion int = null;
    declare @errores varchar(4000) = '';

    execute concesiones.sp_validacion_concesion
        @empresa,
        @parque,
        @fecha_inicio,
        @errores output,
        @id_concesion output;

    if @errores <> '' begin
        raiserror(@errores, 16, 1);
        return;
    end

    declare @monto numeric(10, 2) = (
        select top 1 canon_mensual
        from concesiones.Concesion
        where id = @id_concesion
    );

    insert into concesiones.Canon_pagar (monto, fecha_generacion, estado, periodo, id_concesion) values (@monto, @fecha_generacion, 'PENDIENTE', @periodo, @id_concesion);
end
go

create or alter procedure concesiones.sp_modificacion_canon_pagar (
    @fecha_generacion date,
    @periodo varchar(50),
    @monto decimal(10, 2),
    @empresa varchar(25),
    @parque varchar(100),
    @fecha_inicio date
) as begin
    declare @errores varchar(4000) = '';
    declare @id_concesion int = null;

    execute concesiones.sp_validacion_concesion
        @empresa,
        @parque,
        @fecha_inicio,
        @errores output,
        @id_concesion output;

    if not exists (
        select 1
        from concesiones.Canon_pagar
        where id_concesion = @id_concesion
          and fecha_generacion = @fecha_generacion
    ) begin
        set @errores += 'No en encontro el canon a pagar.' + char(10);
    end

    if @monto < 0 begin
        set @errores += 'El monto no puede ser negativo.' + char(10);
    end

    if @errores <> '' begin
        raiserror(@errores, 16, 1);
        return;
    end

    update concesiones.Canon_pagar
    set monto = @monto,
        periodo = @periodo
    where id_concesion = @id_concesion
      and fecha_generacion = @fecha_generacion;
end
go

create or alter procedure concesiones.sp_pagar_canon (
    @fecha_pago date,
    @fecha_generacion date,
    @empresa varchar(100),
    @parque varchar(100),
    @fecha_inicio date
) as begin
    declare @id int;
    declare @errores varchar(4000) = '';
    declare @id_concesion int = null;

    execute concesiones.sp_validacion_concesion
        @empresa,
        @parque,
        @fecha_inicio,
        @errores output,
        @id_concesion output;

    select top 1 @id = id
    from concesiones.Canon_pagar
    where id_concesion = @id_concesion
      and fecha_generacion = @fecha_generacion;

    if @id is null begin
        set @errores += 'No en encontro el canon a pagar.' + char(10);
    end

    if @errores <> '' begin
        raiserror(@errores, 16, 1);
        return;
    end

    update concesiones.Canon_pagar
    set fecha_pagado = @fecha_pago,
        estado = 'PAGADO'
    where id = @id;
end
go

create or alter procedure concesiones.sp_baja_canon (
    @fecha_generacion date,
    @empresa varchar(100),
    @parque varchar(100),
    @fecha_inicio date
) as begin
    declare @id int;
    declare @errores varchar(4000) = '';
    declare @id_concesion int = null;

    execute concesiones.sp_validacion_concesion
        @empresa,
        @parque,
        @fecha_inicio,
        @errores output,
        @id_concesion output;

    select top 1 @id = id
    from concesiones.Canon_pagar
    where id_concesion = @id_concesion
      and fecha_generacion = @fecha_generacion;

    if @id is null begin
        set @errores += 'No en encontro el canon a pagar.' + char(10);
    end

    if @errores <> '' begin
        raiserror(@errores, 16, 1);
        return;
    end

    update concesiones.Canon_pagar
    set estado = 'INVALIDO'
    where id = @id;
end
go

set nocount on;

if object_id('concesiones.Parque', 'U') is null
begin
    print 'SKIP - CanonAPAgar.sql: la tabla concesiones.Parque aun no existe. Estos tests corren cuando este disponible.';
    return;
end

-------------------------------------------------------------------------------
-- Test 1: Alta exito
-- Esperado: se crea un canon con estado 'PENDIENTE' y fecha_pagado NULL.
-------------------------------------------------------------------------------
print '--- Test 1: sp_alta_canon_pagar (exito) ---';
begin tran;
begin try
    insert into concesiones.Parque (nombre, tipo, ubicacion, superficie) values ('Parque Test Canon 1', 'NACIONAL', 'Test', 100.00);

    exec concesiones.sp_alta_empresa @nombre = 'Canon Test 1', @tipo = 'tienda', @cuit = '30123456789';
    declare @e1 int = (select top 1 id from concesiones.Empresa where nombre = 'Canon Test 1' order by id desc);
    exec concesiones.sp_alta_concesion @empresa = 'Canon Test 1', @parque = 'Parque Test Canon 1', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
    declare @c1 int = (select top 1 id from concesiones.Concesion where id_empresa = @e1 order by id desc);

    exec concesiones.sp_alta_canon_pagar @fecha_generacion = '2026-02-01', @periodo = 'Enero 2026', @empresa = 'Canon Test 1', @parque = 'Parque Test Canon 1', @fecha_inicio = '2026-01-01';

    select * from concesiones.Canon_pagar where id_concesion = @c1;

    if exists (select 1 from concesiones.Canon_pagar
               where id_concesion = @c1 and estado = 'PENDIENTE' and fecha_pagado is null and monto = 1000.00)
        print 'OK - Test 1: canon generado en estado PENDIENTE.';
    else
        print 'FALLO - Test 1: no se genero el canon esperado.';
end try
begin catch
    print 'FALLO - Test 1: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 2: Modificacion exito
-- Esperado: monto = 1500.00 y periodo = 'Enero 2026 (ajustado)'.
-------------------------------------------------------------------------------
print '--- Test 2: sp_modificacion_canon_pagar (exito) ---';
begin tran;
begin try
    insert into concesiones.Parque (nombre, tipo, ubicacion, superficie) values ('Parque Test Canon 2', 'NACIONAL', 'Test', 100.00);

    exec concesiones.sp_alta_empresa @nombre = 'Canon Test 2', @tipo = 'tienda', @cuit = '30123456789';
    declare @e2 int = (select top 1 id from concesiones.Empresa where nombre = 'Canon Test 2' order by id desc);
    exec concesiones.sp_alta_concesion @empresa = 'Canon Test 2', @parque = 'Parque Test Canon 2', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
    declare @c2 int = (select top 1 id from concesiones.Concesion where id_empresa = @e2 order by id desc);
    exec concesiones.sp_alta_canon_pagar @fecha_generacion = '2026-02-01', @periodo = 'Enero 2026', @empresa = 'Canon Test 2', @parque = 'Parque Test Canon 2', @fecha_inicio = '2026-01-01';

    exec concesiones.sp_modificacion_canon_pagar @fecha_generacion = '2026-02-01', @periodo = 'Enero 2026 (ajustado)', @monto = 1500.00, @empresa = 'Canon Test 2', @parque = 'Parque Test Canon 2', @fecha_inicio = '2026-01-01';

    select * from concesiones.Canon_pagar where id_concesion = @c2;

    if exists (select 1 from concesiones.Canon_pagar where id_concesion = @c2 and monto = 1500.00 and periodo = 'Enero 2026 (ajustado)')
        print 'OK - Test 2: canon modificado correctamente.';
    else
        print 'FALLO - Test 2: la modificacion no quedo como se esperaba.';
end try
begin catch
    print 'FALLO - Test 2: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 3: Pagar exito
-- Esperado: estado pasa a 'PAGADO' y fecha_pagado = '2026-02-05'.
-------------------------------------------------------------------------------
print '--- Test 3: sp_pagar_canon (exito) ---';
begin tran;
begin try
    insert into concesiones.Parque (nombre, tipo, ubicacion, superficie)
    values ('Parque Test Canon 3', 'NACIONAL', 'Test', 100.00);

    exec concesiones.sp_alta_empresa @nombre = 'Canon Test 3', @tipo = 'tienda', @cuit = '30123456789';
    declare @e3 int = (select top 1 id from concesiones.Empresa where nombre = 'Canon Test 3' order by id desc);
    exec concesiones.sp_alta_concesion @empresa = 'Canon Test 3', @parque = 'Parque Test Canon 3', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
    declare @c3 int = (select top 1 id from concesiones.Concesion where id_empresa = @e3 order by id desc);
    exec concesiones.sp_alta_canon_pagar @fecha_generacion = '2026-02-01', @periodo = 'Enero 2026', @empresa = 'Canon Test 3', @parque = 'Parque Test Canon 3', @fecha_inicio = '2026-01-01';

    exec concesiones.sp_pagar_canon @fecha_pago = '2026-02-05', @fecha_generacion = '2026-02-01', @empresa = 'Canon Test 3', @parque = 'Parque Test Canon 3', @fecha_inicio = '2026-01-01';

    select * from concesiones.Canon_pagar where id_concesion = @c3;

    if exists (select 1 from concesiones.Canon_pagar where id_concesion = @c3 and estado = 'PAGADO' and fecha_pagado = '2026-02-05')
        print 'OK - Test 3: canon marcado como PAGADO.';
    else
        print 'FALLO - Test 3: el pago no se registro como se esperaba.';
end try
begin catch
    print 'FALLO - Test 3: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 4: Baja exito
-- Esperado: el canon queda con estado 'INVALIDO'.
-------------------------------------------------------------------------------
print '--- Test 4: sp_baja_canon (exito, baja logica) ---';
begin tran;
begin try
    insert into concesiones.Parque (nombre, tipo, ubicacion, superficie)
    values ('Parque Test Canon 4', 'NACIONAL', 'Test', 100.00);

    exec concesiones.sp_alta_empresa @nombre = 'Canon Test 4', @tipo = 'tienda', @cuit = '30123456789';
    declare @e4 int = (select top 1 id from concesiones.Empresa where nombre = 'Canon Test 4' order by id desc);
    exec concesiones.sp_alta_concesion @empresa = 'Canon Test 4', @parque = 'Parque Test Canon 4', @canon_mensual = 1000.00, @fecha_inicio = '2026-01-01';
    declare @c4 int = (select top 1 id from concesiones.Concesion where id_empresa = @e4 order by id desc);
    exec concesiones.sp_alta_canon_pagar @fecha_generacion = '2026-02-01', @periodo = 'Enero 2026', @empresa = 'Canon Test 4', @parque = 'Parque Test Canon 4', @fecha_inicio = '2026-01-01';

    exec concesiones.sp_baja_canon @fecha_generacion = '2026-02-01', @empresa = 'Canon Test 4', @parque = 'Parque Test Canon 4', @fecha_inicio = '2026-01-01';

    if exists (select 1 from concesiones.Canon_pagar where id_concesion = @c4 and estado = 'INVALIDO')
        print 'OK - Test 4: el canon quedo INVALIDO (baja logica).';
    else
        print 'FALLO - Test 4: la baja logica no se aplico.';
end try
begin catch
    print 'FALLO - Test 4: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 5: Empresa inexistente
-- Esperado: el SP rechaza la operacion porque no encuentra la empresa.
-------------------------------------------------------------------------------
print '--- Test 5: sp_alta_canon_pagar con empresa inexistente (validacion) ---';
begin tran;
begin try
    insert into concesiones.Parque (nombre, tipo, ubicacion, superficie)
    values ('Parque Test Canon 5', 'NACIONAL', 'Test', 100.00);

    exec concesiones.sp_alta_canon_pagar @fecha_generacion = '2026-02-01', @periodo = 'Enero 2026', @empresa = 'Empresa inexistente', @parque = 'Parque Test Canon 5', @fecha_inicio = '2026-01-01';
    print 'FALLO - Test 5: se esperaba error por empresa inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 5: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 6: Parque inexistente
-- Esperado: el SP rechaza la operacion porque no encuentra el parque.
-------------------------------------------------------------------------------
print '--- Test 6: sp_alta_canon_pagar con parque inexistente (validacion) ---';
begin tran;
begin try
    exec concesiones.sp_alta_empresa @nombre = 'Canon Test 6', @tipo = 'tienda', @cuit = '30123456789';

    exec concesiones.sp_alta_canon_pagar @fecha_generacion = '2026-02-01', @periodo = 'Enero 2026', @empresa = 'Canon Test 6', @parque = 'Parque inexistente', @fecha_inicio = '2026-01-01';
    print 'FALLO - Test 6: se esperaba error por parque inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 6: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 7: Concesion inexistente
-- Esperado: el SP rechaza la operacion porque no encuentra la concesion para
--           la empresa, parque y fecha de inicio indicados.
-------------------------------------------------------------------------------
print '--- Test 7: sp_alta_canon_pagar con concesion inexistente (validacion) ---';
begin tran;
begin try
    insert into concesiones.Parque (nombre, tipo, ubicacion, superficie)
    values ('Parque Test Canon 7', 'NACIONAL', 'Test', 100.00);

    exec concesiones.sp_alta_empresa @nombre = 'Canon Test 7', @tipo = 'tienda', @cuit = '30123456789';

    exec concesiones.sp_alta_canon_pagar @fecha_generacion = '2026-02-01', @periodo = 'Enero 2026', @empresa = 'Canon Test 7', @parque = 'Parque Test Canon 7', @fecha_inicio = '2026-01-01';
    print 'FALLO - Test 7: se esperaba error por concesion inexistente y no ocurrio.';
end try
begin catch
    print 'OK - Test 7: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

print '=== Fin CanonAPagar.sql ===';
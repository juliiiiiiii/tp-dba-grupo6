/* ============================================================
   UNLAM
   Materia: 3641 - Bases de Datos Aplicada
   TP: Sistema de Gestion de Parques Nacionales
   Integrantes:
   Archivo: CanonAPagar.sql
   Fecha: 2026-06-12  
   ============================================================ */

create table Concesiones.Canon_pagar (
    id int identity(1,1) primary key,
    monto decimal(10,2) not null,
    fecha_generacion date not null,
    fecha_pagado date null,
    estado varchar(30) not null,
    periodo varchar(50) not null,
    id_concesion int not null,
    constraint fk_canon_concesion foreign key (id_concesion) references Concesiones.Concesion(id)
);

create procedure Concesiones.sp_alta_canon_pagar
    @monto decimal(10,2),
    @fecha_generacion date,
    @periodo varchar(50),
    @concesion int
as begin
    insert into Concesiones.Canon_pagar (monto, fecha_generacion, estado, periodo, id_concesion) values (@monto, @fecha_generacion, 'PENDIENTE', @periodo, @concesion);
end;

create procedure Concesiones.sp_modificacion_canon_pagar (@id int, @monto decimal(10,2), @periodo varchar(50)) as begin
    update Concesiones.Canon_pagar set monto = @monto, periodo = @periodo where id = @id;
end;

create procedure Concesiones.sp_pagar_canon (@id int, @fecha_pago date)  as begin

    update Concesiones.Canon_pagar set fecha_pagado = @fecha_pago, estado = 'PAGADO' where id = @id;
end;

create procedure Concesiones.sp_baja_canon (@id int) as begin
      update Concesiones.Canon_pagar set estado = 'INVALIDO' where id = @id;
end;

-------------------------------------------------------------------------------
-- Test 1: Alta exito
-- Esperado: se crea un canon con estado 'PENDIENTE' y fecha_pagado NULL.
-------------------------------------------------------------------------------
print '--- Test 1: sp_alta_canon_pagar (exito) ---';
begin tran;
begin try
    exec Concesiones.sp_alta_empresa @nombre = 'Canon Test 1', @tipo = 'tienda', @cuit = '30123456789';
    declare @e1 int = (select top 1 id from Concesiones.Empresa where nombre = 'Canon Test 1' order by id desc);
    exec Concesiones.sp_alta_concesion @empresa = @e1, @parque = @idParqueSeed, @canon_mensual = 1000.00;
    declare @c1 int = (select top 1 id from Concesiones.Concesion where id_empresa = @e1 order by id desc);

    exec Concesiones.sp_alta_canon_pagar @monto = 1000.00, @fecha_generacion = '2026-01-01', @periodo = 'Enero 2026', @concesion = @c1;

    select * from Concesiones.Canon_pagar where id_concesion = @c1;

    if exists (select 1 from Concesiones.Canon_pagar
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
-- Test 2: Modificacion exito (cambia monto y periodo)
-- Esperado: monto = 1500.00 y periodo = 'Enero 2026 (ajustado)'.
-------------------------------------------------------------------------------
print '--- Test 2: sp_modificacion_canon_pagar (exito) ---';
begin tran;
begin try
    exec Concesiones.sp_alta_empresa @nombre = 'Canon Test 2', @tipo = 'tienda', @cuit = '30123456789';
    declare @e2 int = (select top 1 id from Concesiones.Empresa where nombre = 'Canon Test 2' order by id desc);
    exec Concesiones.sp_alta_concesion @empresa = @e2, @parque = @idParqueSeed, @canon_mensual = 1000.00;
    declare @c2 int = (select top 1 id from Concesiones.Concesion where id_empresa = @e2 order by id desc);
    exec Concesiones.sp_alta_canon_pagar @monto = 1000.00, @fecha_generacion = '2026-01-01', @periodo = 'Enero 2026', @concesion = @c2;
    declare @k2 int = (select top 1 id from Concesiones.Canon_pagar where id_concesion = @c2 order by id desc);

    exec Concesiones.sp_modificacion_canon_pagar @id = @k2, @monto = 1500.00, @periodo = 'Enero 2026 (ajustado)';

    select * from Concesiones.Canon_pagar where id = @k2;

    if exists (select 1 from Concesiones.Canon_pagar where id = @k2 and monto = 1500.00 and periodo = 'Enero 2026 (ajustado)')
        print 'OK - Test 2: canon modificado correctamente.';
    else
        print 'FALLO - Test 2: la modificacion no quedo como se esperaba.';
end try
begin catch
    print 'FALLO - Test 2: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 3: sp_pagar_canon exito
-- Esperado: estado pasa a 'PAGADO' y fecha_pagado = '2026-02-05'.
-------------------------------------------------------------------------------
print '--- Test 3: sp_pagar_canon (exito) ---';
begin tran;
begin try
    exec Concesiones.sp_alta_empresa @nombre = 'Canon Test 3', @tipo = 'tienda', @cuit = '30123456789';
    declare @e3 int = (select top 1 id from Concesiones.Empresa where nombre = 'Canon Test 3' order by id desc);
    exec Concesiones.sp_alta_concesion @empresa = @e3, @parque = @idParqueSeed, @canon_mensual = 1000.00;
    declare @c3 int = (select top 1 id from Concesiones.Concesion where id_empresa = @e3 order by id desc);
    exec Concesiones.sp_alta_canon_pagar @monto = 1000.00, @fecha_generacion = '2026-01-01', @periodo = 'Enero 2026', @concesion = @c3;
    declare @k3 int = (select top 1 id from Concesiones.Canon_pagar where id_concesion = @c3 order by id desc);

    exec Concesiones.sp_pagar_canon @id = @k3, @fecha_pago = '2026-02-05';

    select * from Concesiones.Canon_pagar where id = @k3;

    if exists (select 1 from Concesiones.Canon_pagar where id = @k3 and estado = 'PAGADO' and fecha_pagado = '2026-02-05')
        print 'OK - Test 3: canon marcado como PAGADO.';
    else
        print 'FALLO - Test 3: el pago no se registro como se esperaba.';
end try
begin catch
    print 'FALLO - Test 3: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 4: sp_baja_canon exito (baja logica -> estado 'INVALIDO')
-- Esperado: el canon queda con estado 'INVALIDO'.
-------------------------------------------------------------------------------
print '--- Test 4: sp_baja_canon (exito, baja logica) ---';
begin tran;
begin try
    exec Concesiones.sp_alta_empresa @nombre = 'Canon Test 4', @tipo = 'tienda', @cuit = '30123456789';
    declare @e4 int = (select top 1 id from Concesiones.Empresa where nombre = 'Canon Test 4' order by id desc);
    exec Concesiones.sp_alta_concesion @empresa = @e4, @parque = @idParqueSeed, @canon_mensual = 1000.00;
    declare @c4 int = (select top 1 id from Concesiones.Concesion where id_empresa = @e4 order by id desc);
    exec Concesiones.sp_alta_canon_pagar @monto = 1000.00, @fecha_generacion = '2026-01-01', @periodo = 'Enero 2026', @concesion = @c4;
    declare @k4 int = (select top 1 id from Concesiones.Canon_pagar where id_concesion = @c4 order by id desc);

    exec Concesiones.sp_baja_canon @id = @k4;

    if exists (select 1 from Concesiones.Canon_pagar where id = @k4 and estado = 'INVALIDO')
        print 'OK - Test 4: el canon quedo INVALIDO (baja logica).';
    else
        print 'FALLO - Test 4: la baja logica no se aplico.';
end try
begin catch
    print 'FALLO - Test 4: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 5 (VALIDACION): id_concesion inexistente (viola la FK)
-- Esperado: el insert falla por fk_canon_concesion -> error capturado.
-------------------------------------------------------------------------------
print '--- Test 5: sp_alta_canon_pagar con concesion inexistente (validacion) ---';
begin tran;
begin try
    exec Concesiones.sp_alta_canon_pagar @monto = 100.00, @fecha_generacion = '2026-01-01', @periodo = 'Enero 2026', @concesion = 999999;
    print 'FALLO - Test 5: se esperaba error de FK y no ocurrio.';
end try
begin catch
    print 'OK - Test 5: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

print '=== Fin test_CanonAPAgar.sql ===';


-------------------------------------------------------------------------------
-- Test 3: Modificacion exito (cambia canon y pasa a INACTIVO)
-- Esperado: canon_mensual = 999.99 y estado = 'INACTIVO'.
-------------------------------------------------------------------------------
print '--- Test 3: sp_modificacion_concesion (exito) ---';
begin tran;
begin try
    exec Concesiones.sp_alta_empresa @nombre = 'Concesionaria Test 3', @tipo = 'tienda', @cuit = '30123456789';
    declare @idEmp3 int = (select top 1 id from Concesiones.Empresa where nombre = 'Concesionaria Test 3' order by id desc);
    exec Concesiones.sp_alta_concesion @empresa = @idEmp3, @parque = @idParqueSeed, @canon_mensual = 1000.00;
    declare @idCon3 int = (select top 1 id from Concesiones.Concesion where id_empresa = @idEmp3 order by id desc);

    exec Concesiones.sp_modificacion_concesion @id = @idCon3, @canon = 999.99, @estado = 'INACTIVO';

    select * from Concesiones.Concesion where id = @idCon3;

    if exists (select 1 from Concesiones.Concesion
               where id = @idCon3 and canon_mensual = 999.99 and rtrim(estado) = 'INACTIVO')
        print 'OK - Test 3: concesion modificada correctamente.';
    else
        print 'FALLO - Test 3: la modificacion no quedo como se esperaba.';
end try
begin catch
    print 'FALLO - Test 3: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;
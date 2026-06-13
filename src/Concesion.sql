/* ============================================================
   UNLAM
   Materia: 3641 - Bases de Datos Aplicada
   TP: Sistema de Gestion de Parques Nacionales
   Integrantes:
   Archivo: Concesion.sql
   Fecha: 2026-06-12  
   ============================================================ */

create table Concesiones.Concesion (
	id int not null primary key identity(1, 1),
	fecha_inicio date not null,
	fecha_fin date,
	canon_mensual numeric(6, 2),
	estado char(8) constraint check_estado_concesion check(estado = 'ACTIVO' or estado = 'INACTIVO'),
	id_empresa int not null,
	id_parque int not null,
	id_actividad int null,
	constraint fk_concesion_empresa foreign key (id_empresa) references Concesiones.Empresa(id),
	constraint fk_concesion_parque foreign key (id_parque) references Concesiones.Parque(id),
	constraint fk_concesion_actividad foreign key (id_actividad) references Concesiones.Actividad(id)
);

create or alter procedure Concesiones.sp_alta_concesion(@empresa int, @parque int, @canon_mensual numeric(6, 2), @fecha_inicio date = null, @actividad int = null) as begin
	if @fecha_inicio is null begin
		set @fecha_inicio = getdate();
	end;

	if @canon_mensual < 0 begin
	    print 'El canon mensual no puede ser negativo';
		return
	end

	insert into Concesiones.Concesion (fecha_inicio, canon_mensual, estado, id_empresa, id_parque, id_actividad) values (@fecha_inicio, @canon_mensual, 'ACTIVO', @empresa, @parque, @actividad) -- estado que puede ser? activo/inactivo?
end;

create or alter procedure Concesiones.sp_baja_concesion (@id int) as begin
	update Concesiones.Concesion set estado='INACTIVO' where id = @id
	-- una de las dos
	-- delete from Concesiones.Concesion where id=@id;
end;


-- si se quiere invalidar la fecha de fin se tiene que pasar la fecha '1900-01-01'
create or alter procedure Concesiones.sp_modificacion_concesion(@id int, @canon numeric(6, 2) = null, @estado char(10), @fecha_fin date = null) as begin
	update Concesiones.Concesion
	set
		canon_mensual=isnull(@canon, canon_mensual),
		estado=isnull(@estado, estado),
		fecha_fin = case
            when @fecha_fin = '1900-01-01' then null
            when @fecha_fin is null then fecha_fin
            else @fecha_fin
        end where id = @id
end;

-------------------------------------------------------------------------------
-- Test 1: Alta exito (sin fecha_inicio -> default getdate(); sin actividad)
-- Esperado: se crea una Concesion con estado 'ACTIVO' para la empresa creada.
-------------------------------------------------------------------------------
print '--- Test 1: sp_alta_concesion (exito) ---';
begin tran;
begin try
    exec Concesiones.sp_alta_empresa @nombre = 'Concesionaria Test 1', @tipo = 'restaurante', @cuit = '30123456789';
    declare @idEmp1 int = (select top 1 id from Concesiones.Empresa where nombre = 'Concesionaria Test 1' order by id desc);

    exec Concesiones.sp_alta_concesion @empresa = @idEmp1, @parque = @idParqueSeed, @canon_mensual = 1500.00;

    -- evidencia
    select * from Concesiones.Concesion where id_empresa = @idEmp1;

    if exists (select 1 from Concesiones.Concesion
               where id_empresa = @idEmp1 and rtrim(estado) = 'ACTIVO' and canon_mensual = 1500.00)
        print 'OK - Test 1: concesion creada con estado ACTIVO.';
    else
        print 'FALLO - Test 1: no se creo la concesion esperada.';
end try
begin catch
    print 'FALLO - Test 1: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 2 (VALIDACION): canon mensual negativo
-- Esperado: el SP imprime 'El canon mensual no puede ser negativo', hace
--           return y NO inserta ninguna concesion.
-------------------------------------------------------------------------------
print '--- Test 2: sp_alta_concesion con canon negativo (validacion) ---';
begin tran;
begin try
    exec Concesiones.sp_alta_empresa @nombre = 'Concesionaria Test 2', @tipo = 'tienda', @cuit = '30123456789';
    declare @idEmp2 int = (select top 1 id from Concesiones.Empresa where nombre = 'Concesionaria Test 2' order by id desc);

    exec Concesiones.sp_alta_concesion @empresa = @idEmp2, @parque = @idParqueSeed, @canon_mensual = -50.00;

    if not exists (select 1 from Concesiones.Concesion where id_empresa = @idEmp2)
        print 'OK - Test 2: no se inserto concesion con canon negativo.';
    else
        print 'FALLO - Test 2: se inserto una concesion pese al canon negativo.';
end try
begin catch
    print 'FALLO - Test 2: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;


-------------------------------------------------------------------------------
-- Test 4: Baja exito (baja logica -> estado 'INACTIVO')
-- Esperado: la concesion queda con estado 'INACTIVO' (no se borra fisicamente).
-------------------------------------------------------------------------------
print '--- Test 4: sp_baja_concesion (exito, baja logica) ---';
begin tran;
begin try
    exec Concesiones.sp_alta_empresa @nombre = 'Concesionaria Test 4', @tipo = 'tienda', @cuit = '30123456789';
    declare @idEmp4 int = (select top 1 id from Concesiones.Empresa where nombre = 'Concesionaria Test 4' order by id desc);
    exec Concesiones.sp_alta_concesion @empresa = @idEmp4, @parque = @idParqueSeed, @canon_mensual = 1200.00;
    declare @idCon4 int = (select top 1 id from Concesiones.Concesion where id_empresa = @idEmp4 order by id desc);

    exec Concesiones.sp_baja_concesion @id = @idCon4;

    if exists (select 1 from Concesiones.Concesion where id = @idCon4 and rtrim(estado) = 'INACTIVO')
        print 'OK - Test 4: la concesion quedo INACTIVO (baja logica).';
    else
        print 'FALLO - Test 4: la baja logica no se aplico.';
end try
begin catch
    print 'FALLO - Test 4: error inesperado: ' + error_message();
end catch
if @@trancount > 0 rollback;

-------------------------------------------------------------------------------
-- Test 5 (VALIDACION): estado fuera del CHECK (ACTIVO/INACTIVO)
-- Esperado: el constraint check_estado_concesion rechaza el update -> error capturado.
-------------------------------------------------------------------------------
print '--- Test 5: sp_modificacion_concesion con estado invalido (validacion) ---';
begin tran;
begin try
    exec Concesiones.sp_alta_empresa @nombre = 'Concesionaria Test 5', @tipo = 'tienda', @cuit = '30123456789';
    declare @idEmp5 int = (select top 1 id from Concesiones.Empresa where nombre = 'Concesionaria Test 5' order by id desc);
    exec Concesiones.sp_alta_concesion @empresa = @idEmp5, @parque = @idParqueSeed, @canon_mensual = 800.00;
    declare @idCon5 int = (select top 1 id from Concesiones.Concesion where id_empresa = @idEmp5 order by id desc);

    exec Concesiones.sp_modificacion_concesion @id = @idCon5, @estado = 'RARO';
    print 'FALLO - Test 5: se esperaba error de CHECK por estado invalido y no ocurrio.';
end try
begin catch
    print 'OK - Test 5: rechazado como se esperaba. Detalle: ' + error_message();
end catch
if @@trancount > 0 rollback;

print '=== Fin test_Concesion.sql ===';
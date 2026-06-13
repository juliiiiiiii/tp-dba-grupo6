/* ============================================================
   UNLAM
   Materia: 3641 - Bases de Datos Aplicada
   TP: Sistema de Gestion de Parques Nacionales
   Integrantes:
   Archivo: Empresa.sql
   Fecha: 2026-06-12  
   ============================================================ */

create table Concesiones.Empresa (
	id int not null primary key identity(1, 1),
	nombre varchar(25) not null,
	tipo varchar(100) not null,
	cuit varchar(15) constraint check_cuit_formato check(cuit like '3[034][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' or cuit like '2[0347][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') not null
);

-- TODO nuevo archivo de SP
create or alter procedure Concesiones.sp_alta_empresa (@nombre varchar(25), @tipo varchar(100), @cuit varchar(15)) as begin
	-- vale la pena una funcion para ver si el cuit es valido?
	insert into Concesiones.Empresa (nombre, tipo, cuit) values (@nombre, @tipo, @cuit);
end;

create or alter procedure Concesiones.sp_baja_empresa (@id int) as begin
	delete from Concesiones.Empresa where id=@id
end;

create or alter procedure Concesiones.sp_modificacion_empresa (@id int, @nombre varchar(25) = null, @tipo varchar(100) = null, @cuit varchar(15) = null) as begin
	update Concesiones.Empresa set nombre=isnull(@nombre, nombre), tipo=isnull(@tipo, tipo), cuit=isnull(@cuit, cuit) where id = @id
end;
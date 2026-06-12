use parque_nacional;

create table Concesiones.Empresa (
	id int not null primary key identity(1, 1),
	nombre varchar(25),
	tipo varchar(100),
	cuit varchar(15) check(cuit like '3[034][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' or cuit like '2[0347][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);

-- TODO nuevo archivo de SP
create or alter procedure Concesiones.AltaEmpresa (@nombre varchar(25), @tipo varchar(100), @cuit int) as begin
	-- vale la pena una funcion para ver si el cuit es valido?
	insert into Concesiones.Empresa (nombre, tipo, cuit) values (@nombre, @tipo, @cuit);
end;

create or alter procedure Concesiones.BajaEmpresa (@id int) as begin
	delete from Concesiones.Empresa where id=@id
end;

create or alter procedure Concesiones.ModificacionEmpresa (@id int, @nombre varchar(25) = null, @tipo varchar(100) = null, @cuit int = null) as begin
	update Concesiones.Empresa set nombre=isnull(@nombre, nombre), tipo=isnull(@tipo, tipo), cuit=isnull(@cuit, cuit) where id = @id
end;

-- TODO nuevo archivo de testing
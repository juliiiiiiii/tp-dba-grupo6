use parque_nacional;

create table Concesiones.Concesion (
	id int not null primary key identity(1, 1),
	fecha_inicio date not null,
	fecha_fin date,
	canon_mensual numeric(6, 2),
	estado char(8) check(estado = 'ACTIVO' or estado = 'INACTIVO')
);

create or alter procedure Concesiones.AltaConsecion(@canon_mensual numeric(6, 2), @fecha_inicio date = null) as begin
	if @fecha_inicio is null begin
		set @fecha_inicio = getdate();
	end;

	if @canon_mensual < 0 begin
	    print 'El canon mensual no puede ser negativo';
		return
	end

	insert into Concesiones.Empresa (fecha_inicio, canon_mensual, estado) values (@fecha_inicio, @canon_mensual, 'ACTIVO') -- estado que puede ser? activo/inactivo?
end;

create or alter procedure Concesiones.BajaConsecion (@id int) as begin
	update Concesiones.Concesion set estado='INACTIVO' where id = @id 
	-- una de las dos
	-- delete from Concesiones.Concesion where id=@id;
end;


-- si se quiere invalidar la fecha de fin se tiene que pasar la fecha '1900-01-01'
create or alter procedure Concesiones.ModificacionConsecion(@id int, @canon numeric(6, 2) = null, @estado char(10), @fecha_fin date = null) as begin
	update Concesiones.Concesion 
	set 
		canon_mensual=isnull(@canon, canon_mensual), 
		estado=isnull(@estado, estado), 
		fecha_fin = case 
            when @fecha_fin = '1900-01-01' then NULL 
            when @fecha_fin IS NULL then fecha_fin   
            else @fecha_fin 
        end where id = @id
end;

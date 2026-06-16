-- Universidad: Universidad de la Matanza
-- Materia: 3641 - Bases de Datos Aplicadas

-- Grupo 04
-- Integrantes:
--  De Bellis, Nahuel
--  Ocampo, Julian Rafael
--  Rodriguez, Gonzalo Ezequiel
--  Vargas, Tomas

-- Objetivo del script: Creacion de store procedure

-- Fecha: 12/06/2026

USE parques_nacionales
GO

-----------------------------------------------------------
-- Registrar especialidad

CREATE OR ALTER PROCEDURE guia.sp_registrar_especialidad
@descripcion VARCHAR(50)
AS
BEGIN
    DECLARE @error VARCHAR(70);
    SET @error = '';

    IF @descripcion IS NULL OR @descripcion = ''
        SET @error += 'Se debe especificar la descripcion de la especialidad.' + CHAR(10);
    ELSE
    BEGIN
        IF EXISTS (SELECT descripcion from guia.Especialidad WHERE descripcion = @descripcion)
        SET @error += 'La especialidad ya se encuentra registrada.' + CHAR(10);
    END

    IF @error != ''
        RAISERROR(@error, 16, 1);
    ELSE
    BEGIN
        INSERT INTO guia.Especialidad VALUES(@descripcion); 
    END 
END
GO

-----------------------------------------------------------
-- Asignarle especializacion a un guia

CREATE OR ALTER PROCEDURE guia.sp_asignar_especializacion
@dni CHAR(8),
@especialidad VARCHAR(50)
AS
BEGIN
    DECLARE @error VARCHAR(50);
    SET @error = '';

    DECLARE @id_guia INT;
    DECLARE @id_especialidad INT;

    IF @dni IS NULL
        SET @error += 'Se debe especificar el dni del guia.' + CHAR(10);
    ELSE
    BEGIN
        SET @id_guia = (SELECT id from gestion.Guia WHERE dni = @dni);
        IF @id_guia IS NULL
            SET @error += 'El dni no pertenece a ningun guia.' + CHAR(10);
    END

    IF @especialidad IS NULL
        SET @error += 'Se debe especificar la especializacion.' + CHAR(10);
    ELSE
    BEGIN
        SET @id_especialidad = (SELECT id from guia.Especialidad WHERE descripcion = @especialidad);
        IF @id_especialidad IS NULL
            SET @error += 'La especialidad no se encuentra registrada.' + CHAR(10);
    END

    IF @especialidad IS NOT NULL AND @dni IS NOT NULL
        IF EXISTS (SELECT id FROM guia.Especializado_en WHERE id_guia = @id_guia AND id_especialidad = @id_especialidad)
            SET @error += 'El guia ya tiene asignada esa especializacion.' + CHAR(10);   

    IF @error != ''
        RAISERROR(@error, 16, 1);
    ELSE
    BEGIN
        INSERT INTO guia.Especializado_en VALUES(@id_guia, @id_especialidad)
    END
END
GO

-----------------------------------------------------------
-- Actualizar acreditacion de guias

CREATE OR ALTER PROCEDURE guia.sp_actualizar_acreditacion
@dni CHAR(8),
@fecha_vencimiento_acreditacion DATE
AS
BEGIN
    DECLARE @error VARCHAR(50);
    SET @error = '';

    DECLARE @estado_acreditacion CHAR(7);
    DECLARE @id_acreditacion INT;
    DECLARE @id_guia INT;

    IF @dni IS NULL
        SET @error += 'Se debe especificar el dni del guia.' + CHAR(10);
    ELSE
    BEGIN
        SET @id_guia = (SELECT id from gestion.Guia WHERE dni = @dni);
        IF @id_guia IS NULL
            SET @error += 'El dni no pertenece a ningun guia.' + CHAR(10);
        ELSE
        BEGIN
            SET @id_acreditacion = (SELECT id_acreditacion FROM gestion.Guia WHERE id = @id_guia);
            IF @id_acreditacion IS NULL
                SET @error += 'El guia no posee una acreditacion.' + CHAR(10);
        END
    END

    IF @fecha_vencimiento_acreditacion IS NULL
        SET @error += 'Se debe especificar fecha de vencimiento de acriditacion.' + CHAR(10);
    ELSE
    BEGIN
        IF @fecha_vencimiento_acreditacion < CAST(GETDATE() AS DATE)
            SET @estado_acreditacion = 'vencido';
        ELSE
            SET @estado_acreditacion = 'vigente';
    END
    
    IF @error != ''
        RAISERROR(@error, 16, 1);
    ELSE
    BEGIN
        UPDATE guia.Acreditacion SET fecha_vencimiento = @fecha_vencimiento_acreditacion, estado = @estado_acreditacion 
            WHERE id = @id_acreditacion;
    END
END
GO

-----------------------------------------------------------
-- Asignar titulo a un guia

CREATE OR ALTER PROCEDURE guia.sp_asignar_titulacion_guia
@dni CHAR(8),
@descripcion VARCHAR(80),
@institucion VARCHAR(30),
@fecha_emision DATE
AS
BEGIN
    DECLARE @error VARCHAR(150);
    SET @error = '';

    DECLARE @id_guia INT;
    DECLARE @id_titulo INT;

    IF @dni IS NULL
        SET @error += 'Se debe especificar el dni del guia.' + CHAR(10);
    ELSE
    BEGIN
        SET @id_guia = (SELECT id from gestion.Guia WHERE dni = @dni);
        IF @id_guia IS NULL
            SET @error += 'El dni no pertenece a ningun guia.' + CHAR(10);
    END

    IF @descripcion IS NULL OR @descripcion = ''
        SET @error += 'El titulo debe tener descripcion.' + CHAR(10);
    
    IF @institucion IS NULL OR @institucion = ''
        SET @error += 'El titulo debe tener una institucion.' + CHAR(10);
    
    IF @fecha_emision IS NULL OR @fecha_emision = ''
        SET @error += 'El titulo debe tener una fecha de emision.' + CHAR(10);

    IF EXISTS(
            SELECT t.id FROM guia.Titulo t INNER JOIN guia.Titulacion_guia tg on tg.id_titulo = t.id
            WHERE descripcion = @descripcion AND institucion = @institucion AND tg.id_guia = @id_guia
        )
        SET @error += 'El guia ya tiene asignada ese titulo.' + CHAR(10);   

    IF @error != ''
        RAISERROR(@error, 16, 1);
    ELSE
    BEGIN
        BEGIN TRANSACTION
            INSERT INTO guia.Titulo VALUES(@descripcion, @institucion, @fecha_emision);

            SET @id_titulo = SCOPE_IDENTITY();

            INSERT INTO guia.Titulacion_guia VALUES(@id_guia, @id_titulo);
        COMMIT
    END
END
GO

-----------------------------------------------------------
-- Actualizar titulo a un guia

CREATE OR ALTER PROCEDURE guia.sp_actualizar_titulo_guia
@dni CHAR(8),
@descripcion VARCHAR(80),
@institucion VARCHAR(30),
@fecha_emision DATE
AS
BEGIN
    DECLARE @error VARCHAR(150);
    SET @error = '';

    DECLARE @id_guia INT;
    DECLARE @id_titulo INT;

    IF @dni IS NULL
        SET @error += 'Se debe especificar el dni del guia.' + CHAR(10);
    ELSE
    BEGIN
        SET @id_guia = (SELECT id from gestion.Guia WHERE dni = @dni);
        IF @id_guia IS NULL
            SET @error += 'El dni no pertenece a ningun guia.' + CHAR(10);
    END

    IF @descripcion IS NULL OR @descripcion = ''
        SET @error += 'El titulo debe tener descripcion.' + CHAR(10);
    
    IF @institucion IS NULL OR @institucion = ''
        SET @error += 'El titulo debe tener una institucion.' + CHAR(10);
    
    IF @fecha_emision IS NULL OR @fecha_emision = ''
        SET @error += 'El titulo debe tener una fecha de emision.' + CHAR(10);
    
    IF @id_guia IS NOT NULL AND @descripcion IS NOT NULL AND @institucion IS NOT NULL
    BEGIN
        SET @id_titulo = (
                SELECT t.id FROM guia.Titulo t INNER JOIN guia.Titulacion_guia tg on tg.id_titulo = t.id
                WHERE descripcion = @descripcion AND institucion = @institucion AND tg.id_guia = @id_guia
        )
        IF @id_titulo IS NULL
            SET @error += 'El guia no tiene asignado ese titulo.' + CHAR(10);   
    END
    IF @error != ''
        RAISERROR(@error, 16, 1);
    ELSE
    BEGIN
        UPDATE guia.titulo SET fecha_emision = @fecha_emision WHERE id = @id_titulo;
    END
END
GO

-----------------------------------------------------------
-- Valida la existencia de una concesion para una empresa 
-- en un parque y en una fecha.
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

-----------------------------------------------------------
-- Crea una concesion
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

-----------------------------------------------------------
-- Invalida una concesion
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

-----------------------------------------------------------
-- Modifica una concesion. Se puede especificar que valores editar
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

-----------------------------------------------------------
-- Crea un canon a pagar
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

-----------------------------------------------------------
-- Modifica un canon a pagar
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

-----------------------------------------------------------
-- Paga un canon de una concesion en una fecha en especifico
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

-----------------------------------------------------------
-- Baja de un canon a pagar
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
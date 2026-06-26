-- Universidad: Universidad de la Matanza
-- Materia: 3641 - Bases de Datos Aplicadas

-- Grupo 06
-- Integrantes:
--  De Bellis, Nahuel
--  Ocampo, Julian Rafael
--  Rodriguez, Gonzalo Ezequiel
--  Vargas, Tomas

-- Objetivo del script: Creacion de store procedure

-- Fecha: 12/06/2026

USE parques_nacionales
GO

/*
====================================================
		SP DE TABLA ESPECIALIDAZO_EN
====================================================
*/

CREATE OR ALTER PROCEDURE guia.especialidad_asignar
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

/*
====================================================
		SP DE TABLA ACREDITACION
====================================================
*/

CREATE OR ALTER PROCEDURE guia.acreditacion_actualizar
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

/*
====================================================
		SP DE TABLA TITULO/TITULACION_GUIA
====================================================
*/

CREATE OR ALTER PROCEDURE guia.titulacion_asignar
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
    
    IF @fecha_emision IS NULL OR @fecha_emision = ''
        SET @error += 'El titulo debe tener una fecha de emision.' + CHAR(10);

    IF EXISTS(
            SELECT t.id FROM guia.Titulo t INNER JOIN guia.Titulacion_guia tg on tg.id_titulo = t.id
            WHERE descripcion = @descripcion AND tg.id_guia = @id_guia
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

CREATE OR ALTER PROCEDURE guia.titulo_modificacion
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
    
    
    IF @fecha_emision IS NULL OR @fecha_emision = ''
        SET @error += 'El titulo debe tener una fecha de emision.' + CHAR(10);
    
    IF @id_guia IS NOT NULL AND @descripcion IS NOT NULL AND @institucion IS NOT NULL
    BEGIN
        SET @id_titulo = (
                SELECT t.id FROM guia.Titulo t INNER JOIN guia.Titulacion_guia tg on tg.id_titulo = t.id
                WHERE descripcion = @descripcion AND tg.id_guia = @id_guia
        )
        IF @id_titulo IS NULL
            SET @error += 'El guia no tiene asignado ese titulo.' + CHAR(10);   
    END
    IF @error != ''
        RAISERROR(@error, 16, 1);
    ELSE
    BEGIN
        UPDATE guia.titulo SET fecha_emision = @fecha_emision, institucion = @institucion WHERE id = @id_titulo;
    END
END
GO

--TODO test de estos sp:

-- Crea una concesion para una empresa y un parque en una fecha en especifico
-- Tambien crea un canon a pagar pendiente de pago en el periodo de la fecha de inicio
create or alter procedure concesiones.concesion_registrar_gestion (
    @empresa varchar(25),
    @tipo_empresa varchar(100),
    @cuit varchar(15),
    @parque varchar(100),
    @canon_mensual numeric(10, 2),
    @fecha_inicio date,
    @actividad int = null
) as begin

    declare @errores varchar(4000) = '';
    declare @id_empresa int = null;
    declare @id_parque int = null;
    declare @id_concesion int = null;

    select @id_empresa = id
    from concesiones.Empresa
    where nombre = @empresa;

    select @id_parque = id
    from gestion.Parque
    where nombre = @parque;

    if @id_parque is null begin
        set @errores += 'No se encontro el parque.' + char(10);
    end

    if @id_empresa is not null and exists (
        select 1
        from concesiones.Empresa
        where id = @id_empresa
          and cuit <> @cuit
    ) begin
        set @errores += 'Ya existe una empresa con ese nombre y otro CUIT.' + char(10);
    end

    if @id_empresa is not null and exists (
        select 1
        from concesiones.Concesion
        where id_empresa = @id_empresa
          and id_parque = @id_parque
          and fecha_inicio = @fecha_inicio
    ) begin
        set @errores += 'Ya existe una concesion para esa empresa, parque y fecha de inicio.' + char(10);
    end

    if @errores <> ''
        throw 16, @errores, 1;

    begin try
        begin tran;

        exec concesiones.concesion_alta
            @empresa = @empresa,
            @parque = @parque,
            @canon_mensual = @canon_mensual,
            @fecha_inicio = @fecha_inicio,
            @actividad = @actividad;

        select @id_concesion = id
        from concesiones.Concesion
        where id_empresa = @id_empresa
          and id_parque = @id_parque
          and fecha_inicio = @fecha_inicio;

        if @id_empresa is null or @id_concesion is null begin
            raiserror('No se pudo resolver la empresa o la concesion. No se genero el canon.', 16, 1);
        end

        exec concesiones.canon_pagar_alta
            @fecha_generacion = @fecha_inicio,
            @empresa = @empresa,
            @parque = @parque,
            @fecha_inicio = @fecha_inicio;

        commit;

        select
            @id_empresa as id_empresa,
            @id_concesion as id_concesion,
            @fecha_inicio as fecha_generacion_primer_canon;
    end try
    begin catch
        if @@trancount > 0 rollback;
        declare @mensaje_error varchar(4000) = error_message();
        throw 16, @mensaje_error, 1;
    end catch
end;
go

-- Crea un canon a pagar para una concesion en un fecha de generacion
-- por default la fecha de generacion es la actual
create or alter procedure concesiones.canon_pagar_generar_cuota_mensual (
    @empresa varchar(25),
    @parque varchar(100),
    @fecha_inicio date,
    @fecha_generacion date = getdate
) as begin
    declare @id_concesion int = null;
    declare @errores varchar(4000) = '';

    exec concesiones.concesion_validacion
        @empresa,
        @parque,
        @fecha_inicio,
        @errores output,
        @id_concesion output;

    if exists (
        select 1
        from concesiones.Canon_pagar
        where id_concesion = @id_concesion
          and fecha_generacion = @fecha_generacion
    ) begin
        set @errores += 'Ya existe un canon generado para esa concesion y mes.' + char(10);
    end

    if @errores <> ''
        throw 16, @errores, 1;

    begin try
        begin tran;

        exec concesiones.canon_pagar_alta
            @fecha_generacion = @fecha_generacion,
            @empresa = @empresa,
            @parque = @parque,
            @fecha_inicio = @fecha_inicio;

        commit;
    end try
    begin catch
        if @@trancount > 0 rollback;
        declare @mensaje_error varchar(4000) = error_message();
        raiserror(@mensaje_error, 16, 1);
        return;
    end catch
end;
go

-- Pagar siguiente canon pendiente
create or alter procedure concesiones.canon_pagar_abonar (
    @empresa varchar(25),
    @parque varchar(100),
    @fecha_inicio date,
    @fecha_pago date
) as begin
    declare @id_concesion int = null;
    declare @id_canon int = null;
    declare @errores varchar(4000) = '';

    exec concesiones.concesion_validacion
        @empresa,
        @parque,
        @fecha_inicio,
        @errores output,
        @id_concesion output;

    if @errores <> ''
        throw 16, @errores, 1;

    begin try
        begin tran;

        select top 1 @id_canon = id
        from concesiones.Canon_pagar --with (updlock, rowlock, readpast)
        where id_concesion = @id_concesion
          and estado = 'PENDIENTE'
        order by fecha_generacion;

        if @id_canon is null begin
            raiserror('No hay canones pendientes de pago.', 16, 1);
        end

        update concesiones.Canon_pagar
        set estado = 'PAGADO',
            fecha_pagado = @fecha_pago
        where id = @id_canon
          and estado = 'PENDIENTE';

        if @@rowcount <> 1 begin
            raiserror('No se pudo pagar el canon pendiente seleccionado.', 16, 1);
        end

        commit;

        select *
        from concesiones.Canon_pagar
        where id = @id_canon;
    end try
    begin catch
        if @@trancount > 0 rollback;
        declare @mensaje_error varchar(4000) = error_message();
        raiserror(@mensaje_error, 16, 1);
        return;
    end catch
end;
go

-- Pendientes de pago de una concesion
create or alter procedure concesiones.sp_consultar_canones_pendientes (
    @empresa varchar(25),
    @parque varchar(100),
    @fecha_inicio date
) as begin

    declare @id_concesion int = null;
    declare @errores varchar(4000) = '';

    exec concesiones.concesion_validacion
        @empresa,
        @parque,
        @fecha_inicio,
        @errores output,
        @id_concesion output;

    if @errores <> ''
        throw 16, @errores, 1;

    select
        cp.id,
        cp.fecha_generacion,
        cp.periodo,
        cp.monto,
        cp.estado,
        case
            when exists (
                select 1
                from concesiones.Canon_pagar posterior
                where posterior.id_concesion = cp.id_concesion
                  and posterior.fecha_generacion > cp.fecha_generacion
            ) then cast(1 as bit)
            else cast(0 as bit)
        end as atrasado
    from concesiones.Canon_pagar cp
    where cp.id_concesion = @id_concesion
      and cp.estado = 'PENDIENTE'
    order by cp.fecha_generacion;
end;
go

-- Historicos de pagos de una concesion
create or alter procedure concesiones.sp_consultar_historico_canones (
    @empresa varchar(25),
    @parque varchar(100),
    @fecha_inicio date
) as begin
    set nocount on;

    declare @id_concesion int = null;
    declare @errores varchar(4000) = '';

    exec concesiones.concesion_validacion
        @empresa,
        @parque,
        @fecha_inicio,
        @errores output,
        @id_concesion output;

    if @errores <> ''
        throw 16, @errores, 1;

    select
        cp.id,
        cp.fecha_generacion,
        cp.periodo,
        cp.monto,
        cp.estado,
        cp.fecha_pagado
    from concesiones.Canon_pagar cp
    where cp.id_concesion = @id_concesion
    order by cp.fecha_generacion;
end;
go

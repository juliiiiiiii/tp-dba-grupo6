
-- Universidad: Universidad de la Matanza
-- Materia: 3641 - Bases de Datos Aplicadas

-- Grupo 04
-- Integrantes:
--  De Bellis, Nahuel
--  Ocampo, Julian Rafael
--  Rodriguez, Gonzalo Ezequiel
--  Vargas, Tomas

-- Objetivo del script: Creacion de tablas

-- Fecha: 12/06/2026

USE parques_nacionales;
GO

IF OBJECT_ID(N'[gestion].[Ubicacion]') IS NULL
BEGIN
    CREATE TABLE gestion.Ubicacion (
        id INT IDENTITY(1,1) PRIMARY KEY,
        provincia VARCHAR(50) NOT NULL UNIQUE
    )
END
GO

IF OBJECT_ID('[gestion].[Parque]', 'U') IS NULL
BEGIN
	CREATE TABLE gestion.Parque (
		id INT IDENTITY(1,1) PRIMARY KEY,
		nombre VARCHAR(50) NOT NULL UNIQUE,
		tipo VARCHAR(50) NOT NULL,
		ubicacion VARCHAR(50) NOT NULL,
		superficie INT NOT NULL CHECK(superficie > 0),
		estado CHAR(8) NOT NULL CHECK (estado IN('Activo', 'Inactivo'))
	);
END
GO

IF OBJECT_ID('[gestion].[Guardaparque]', 'U') IS NULL
BEGIN
	CREATE TABLE gestion.Guardaparque (
		id INT IDENTITY(1,1) PRIMARY KEY,
		dni INT NOT NULL CHECK (dni >= 10000000 AND dni < 99999999),
		nombre CHAR(20) NOT NULL,
		apellido CHAR(20) NOT NULL,
		estado CHAR(8) NOT NULL CHECK (estado IN('Activo', 'Inactivo'))
	);
END
GO

IF OBJECT_ID('[gestion].[Parque_asignado]', 'U') IS NULL
BEGIN
	CREATE TABLE gestion.Parque_asignado (
		id INT IDENTITY(1,1) PRIMARY KEY,
		fecha_ingreso DATE NOT NULL,
		fecha_egreso DATE,
		motivo VARCHAR(100),
		id_parque INT NOT NULL,
		id_guardaparque INT NOT NULL,
		CONSTRAINT fk_asignacion_parque FOREIGN KEY (id_parque) REFERENCES gestion.Parque(id),
		CONSTRAINT fk_asignacion_guardaparque FOREIGN KEY (id_guardaparque) REFERENCES gestion.Guardaparque(id)
	);
END
GO

IF OBJECT_ID('[gestion].[Tipo_actividad]', 'U') IS NULL
BEGIN
	CREATE TABLE gestion.Tipo_actividad (
		id INT IDENTITY(1,1) PRIMARY KEY,
		descripcion CHAR(25) NOT NULL
	);
END
GO

IF OBJECT_ID('[gestion].[Actividad]', 'U') IS NULL
BEGIN
	CREATE TABLE gestion.Actividad (
		id INT IDENTITY(1,1) PRIMARY KEY,
		nombre CHAR(50) NOT NULL,
		descripcion VARCHAR(100) NOT NULL,
		costo DECIMAL(9,2) NOT NULL CHECK(costo >= 0),
		fecha DATETIME NOT NULL,
		duracion INT NOT NULL CHECK(duracion > 0),
		cupo INT NOT NULL CHECK(cupo > 0),
		estado CHAR(10) NOT NULL CHECK(estado IN('Programado', 'Cancelado', 'Finalizado', 'En curso', 'Cupo lleno')),
		id_parque INT NOT NULL,
		id_guia INT NOT NULL,
		id_tipo INT NOT NULL,
		CONSTRAINT fk_actividad_parque FOREIGN KEY (id_parque) REFERENCES gestion.Parque(id),
		CONSTRAINT fk_actividad_guia FOREIGN KEY (id_guia) REFERENCES gestion.Guia(id),
		CONSTRAINT fk_actividad_tipo FOREIGN KEY (id_tipo) REFERENCES gestion.Tipo_actividad(id)
	);
END
GO

IF OBJECT_ID(N'[guia].[Acreditacion]', N'U') IS NULL
BEGIN
    CREATE TABLE guia.Acreditacion (
        id INT IDENTITY(1,1) PRIMARY KEY,
        fecha_vencimiento DATE NOT NULL,
        estado CHAR(7) CHECK(estado IN ('vigente', 'vencido'))
    )
END
GO

IF OBJECT_ID(N'[guia].[Titulo]', N'U') IS NULL
BEGIN
    CREATE TABLE guia.Titulo (
        id INT IDENTITY(1,1) PRIMARY KEY,
        descripcion VARCHAR(80) NOT NULL,
        institucion VARCHAR(30) NOT NULL,
        fecha_emision DATE NOT NULL
    )
END
GO

IF OBJECT_ID(N'[guia].[Especialidad]', N'U') IS NULL
BEGIN
    CREATE TABLE guia.Especialidad (
        id INT IDENTITY(1,1) PRIMARY KEY,
        descripcion VARCHAR(50) NOT NULL UNIQUE
    )
END
GO

IF OBJECT_ID(N'[gestion].[Guia]', N'U') IS NULL 
BEGIN
    CREATE TABLE gestion.Guia (
        id INT IDENTITY(1,1) PRIMARY KEY,
        dni CHAR(8) UNIQUE NOT NULL CHECK(dni LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
        nombre VARCHAR(30) NOT NULL,
        apellido VARCHAR(30) NOT NULL,
        id_acreditacion INT REFERENCES guia.Acreditacion(id) NOT NULL UNIQUE
    )
END
GO

IF OBJECT_ID(N'[guia].[Especializado_en]', N'U') IS NULL
BEGIN
    CREATE TABLE guia.Especializado_en (
        id INT IDENTITY(1,1) PRIMARY KEY,
        id_guia INT REFERENCES gestion.Guia(id),
        id_especialidad INT REFERENCES guia.Especialidad(id)
    )
END
GO

IF OBJECT_ID(N'[guia].[Titulacion_guia]', N'U') IS NULL
BEGIN
    CREATE TABLE guia.Titulacion_guia (
        id INT IDENTITY(1,1) PRIMARY KEY,
        id_guia INT REFERENCES gestion.Guia(id),
        id_titulo INT REFERENCES guia.Titulo(id)
    )
END
GO

IF OBJECT_ID(N'[gestion].[Coordina]') IS NULL
BEGIN
    CREATE TABLE gestion.Coordina (
        id INT IDENTITY(1,1) PRIMARY KEY,
        id_actividad INT REFERENCES gestion.Actividad(id) NOT NULL,
        id_guia INT REFERENCES gestion.Guia(id) NOT NULL,
        fecha_desde DATE NOT NULL,
        fecha_hasta DATE NOT NULL
    )
END
GO

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

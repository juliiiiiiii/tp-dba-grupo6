
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

IF OBJECT_ID('[gestion].[Parque]', 'U') IS NULL
BEGIN
	CREATE TABLE gestion.Parque (
		id INT IDENTITY(1,1) PRIMARY KEY,
		nombre VARCHAR(50) NOT NULL,
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

----------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('[gestion].[Acreditacion]', 'U') IS NULL
BEGIN
	CREATE TABLE gestion.Acreditacion (
		id INT IDENTITY(1,1) PRIMARY KEY,
		fecha_vencimiento DATE NOT NULL,
		estado CHAR(8) NOT NULL CHECK(estado IN('Activo', 'Inactivo'))
	);
END
GO

IF OBJECT_ID('[gestion].[Guia]', 'U') IS NULL
BEGIN
	CREATE TABLE gestion.Guia (
		id INT IDENTITY(1,1) PRIMARY KEY,
		id_acreditacion INT NOT NULL,
		CONSTRAINT fk_acreditacion_guia FOREIGN KEY (id_acreditacion) REFERENCES gestion.Acreditacion(id)
	);
END
GO

----------------------------------------------------------------------------------------------------------------------

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
		--tipo CHAR(25) NOT NULL CHECK(tipo IN('Atraccion gratuita', 'Atraccion paga', 'Tour guiado')),
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
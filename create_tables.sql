
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
        descripcion VARCHAR(50) NOT NULL,
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

--Creación de tabla para los tipos de visitantes, los cuales definen el precio de las entradas
IF OBJECT_ID('parques_nacionales.ventas.venta','U') IS NULL
BEGIN
	CREATE TABLE ventas.tipo_visitante
	(
		id INT IDENTITY(1,1) PRIMARY KEY,
		descripcion VARCHAR(20) UNIQUE NOT NULL-- Jubilado, Menor, Adulto, Estudiante, Extranjero
	)
END
GO

--Creación de los puntos de ventas, donde se realizan las ventas en los parques
IF OBJECT_ID('parques_nacionales.ventas.venta','U') IS NULL
BEGIN
	CREATE TABLE ventas.punto_de_venta
	(
		id INT IDENTITY(1,1) PRIMARY KEY,
		parque INT NOT NULL, --El punto de venta tiene que estar asociado a algún parque
		descripcion VARCHAR(30) NOT NULL,
		CONSTRAINT fk_parque_pov FOREIGN KEY (parque) REFERENCES gestion.parque(id),
	)
END
GO

--Creación de tabla para los métodos de pago como puede ser Efectivo, débito, crédito, transferencia, etc.
IF OBJECT_ID('parques_nacionales.ventas.venta','U') IS NULL
BEGIN
	CREATE TABLE ventas.metodo_de_pago
	(
		id INT IDENTITY (1,1) PRIMARY KEY,
		descripcion VARCHAR(25) NOT NULL UNIQUE
	)
END
GO

--Creación de los tipos de entrada
IF OBJECT_ID('parques_nacionales.ventas.entrada','U') IS NULL
BEGIN
	CREATE TABLE ventas.entrada
	(
		id INT IDENTITY(1, 1) PRIMARY KEY,
		tipo INT NOT NULL, --La entrada está asociada a un tipo de estudiante
		parque INT NOT NULL, --Todas las entradas pertenecen a algún parque
		precio DECIMAL(10,2) CHECK (precio >= 0),
		fecha_desde DATE NOT NULL,
		fecha_hasta DATE, --Si es NULL, la entrada está vigente.
		CONSTRAINT fk_tipo_visitante FOREIGN KEY (tipo) REFERENCES ventas.tipo_visitante(id),
		CONSTRAINT fk_parque FOREIGN KEY (parque) REFERENCES gestion.Parque(id),
	)
END
GO

--Creación de tabla para las ventas. Cada venta puede tener varias entradas y actividades
IF OBJECT_ID('parques_nacionales.ventas.venta','U') IS NULL
BEGIN
	CREATE TABLE ventas.venta
	(
		id INT IDENTITY(1,1) PRIMARY KEY,
		parque INT NOT NULL, --No existen ventas que no estén asociada a un parque
		fecha DATE NOT NULL,
		punto_de_venta INT NOT NULL, --Tiene que haber sido realizada en algún punto
		metodo_de_pago INT,
		total DECIMAL(10,2),
		CONSTRAINT fk_venta_parque FOREIGN KEY (parque) REFERENCES gestion.parque(id),
		CONSTRAINT fk_punto_de_venta FOREIGN KEY (punto_de_venta) REFERENCES ventas.punto_de_venta(id),
		CONSTRAINT fk_metodo FOREIGN KEY (metodo_de_pago) REFERENCES ventas.metodo_de_pago(id)
	)
END
GO

--Creación de tabla para los items que van asociados a cada venta
IF OBJECT_ID('parques_nacionales.ventas.item_venta','U') IS NULL
BEGIN
	CREATE TABLE ventas.item_venta
	(
		id INT IDENTITY(1, 1) PRIMARY KEY,
		venta INT NOT NULL, --El item representa el detalle dentro de cada venta
		concepto INT NOT NULL,
		cantidad INT CHECK(cantidad > 0) NOT NULL,
		precio INT CHECK(precio >= 0) NOT NULL,
		subtotal DECIMAL (10, 2),
		fecha_acceso DATE NOT NULL,
		CONSTRAINT fk_item_a_venta FOREIGN KEY (venta) REFERENCES ventas.venta(id)
	)
END
GO

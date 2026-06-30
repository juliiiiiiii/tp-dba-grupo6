
-- Universidad: Universidad de la Matanza
-- Materia: Bases de Datos Aplicadas

-- Grupo 06
-- Integrantes:
--  De Bellis, Nahuel
--  Ocampo, Julian Rafael
--  Rodriguez, Gonzalo Ezequiel
--  Vargas, Tomas

-- Objetivo del script: Generar los roles, permisos y usuarios

-- Fecha: 27/06/2026

USE parques_nacionales;

/*
====================================================
		ROLES Y PERMISOS
====================================================
*/

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'gestion_consultas' AND type = 'R')
	CREATE ROLE gestion_consultas;

GRANT SELECT ON SCHEMA::gestion TO gestion_consultas;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'gestion_administrar' AND type = 'R')
	CREATE ROLE gestion_administrar;

GRANT SELECT, EXECUTE ON SCHEMA::gestion TO gestion_administrar;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'personal_consultas' AND type = 'R')
	CREATE ROLE personal_consultas;

GRANT SELECT ON SCHEMA::personal TO personal_consultas;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'personal_administrar' AND type = 'R')
	CREATE ROLE personal_administrar;

GRANT SELECT, EXECUTE ON SCHEMA::personal TO personal_administrar;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ventas_consultas' AND type = 'R')
	CREATE ROLE ventas_consultas;

GRANT SELECT ON SCHEMA::ventas TO ventas_consultas;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ventas_administrar' AND type = 'R')
	CREATE ROLE ventas_administrar;

GRANT SELECT, EXECUTE ON SCHEMA::ventas TO ventas_administrar;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'concesiones_consultas' AND type = 'R')
	CREATE ROLE concesiones_consultas;

GRANT SELECT ON SCHEMA::concesiones TO concesiones_consultas;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'concesiones_administrar' AND type = 'R')
	CREATE ROLE concesiones_administrar;

GRANT SELECT, EXECUTE ON SCHEMA::concesiones TO concesiones_administrar;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'importador' AND type = 'R')
	CREATE ROLE importador;

GRANT SELECT, EXECUTE ON SCHEMA::importacion TO importador;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'informe' AND type = 'R')
	CREATE ROLE informe;

GRANT SELECT, EXECUTE ON SCHEMA::reportes TO informe;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'app' AND type = 'R')
	CREATE ROLE app;

GRANT SELECT ON OBJECT::gestion.Parque TO app;
GRANT EXECUTE ON OBJECT::gestion.parque_alta TO app;
GRANT EXECUTE ON OBJECT::gestion.parque_baja TO app;
GRANT EXECUTE ON OBJECT::gestion.parque_modificacion TO app;
GO

GRANT SELECT ON OBJECT::gestion.Ubicacion TO app;
GO

/*
====================================================
		USUARIOS Y LOGINS
====================================================
*/

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'l_importador' AND type = 'S')
	CREATE LOGIN l_importador WITH PASSWORD = 'hola123', check_policy=off;

IF USER_ID('u_importador') IS NULL
	CREATE USER u_importador FOR LOGIN l_importador;

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'l_informe' AND type = 'S')
	CREATE LOGIN l_informe WITH PASSWORD = 'hola123', check_policy=off;

IF USER_ID('u_informe') IS NULL
	CREATE USER u_informe FOR LOGIN l_informe;

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'l_app' AND type = 'S')
	CREATE LOGIN l_app WITH PASSWORD = 'hola123', check_policy=off;

IF USER_ID('u_app') IS NULL
	CREATE USER u_app FOR LOGIN l_app;

/*
====================================================
		ASGINAR USUARIOS A ROLES
====================================================
*/

ALTER ROLE importador ADD MEMBER u_importador;

ALTER ROLE informe ADD MEMBER u_informe;

ALTER ROLE app ADD MEMBER u_app;
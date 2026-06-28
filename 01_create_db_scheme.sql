
-- Universidad: Universidad de la Matanza
-- Materia: Bases de Datos Aplicadas

-- Grupo 06
-- Integrantes:
--  De Bellis, Nahuel
--  Ocampo, Julian Rafael
--  Rodriguez, Gonzalo Ezequiel
--  Vargas, Tomas

-- Objetivo del script: Generar la base de datos con sus respectivos esquemas

-- Fecha: 12/06/2026

IF DB_ID('parques_nacionales') IS NULL
    CREATE DATABASE parques_nacionales;
GO

ALTER DATABASE parques_nacionales COLLATE Latin1_General_CI_AI;
GO

USE parques_nacionales;
GO

IF SCHEMA_ID('concesiones') IS NULL
	EXEC('CREATE SCHEMA concesiones');
GO

IF SCHEMA_ID('gestion') IS NULL
	EXEC('CREATE SCHEMA gestion');
GO

IF SCHEMA_ID('personal') IS NULL
	EXEC('CREATE SCHEMA personal');
GO

IF SCHEMA_ID('ventas') IS NULL
	EXEC('CREATE SCHEMA ventas');
GO

IF SCHEMA_ID('importacion') IS NULL
	EXEC('CREATE SCHEMA importacion');
GO

IF SCHEMA_ID('reportes') IS NULL
	EXEC('CREATE SCHEMA reportes');
GO
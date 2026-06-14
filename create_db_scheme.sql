
-- Universidad: Universidad de la Matanza
-- Materia: Bases de Datos Aplicadas

-- Grupo 04
-- Integrantes:
--  De Bellis, Nahuel
--  Ocampo, Julian Rafael
--  Rodriguez, Gonzalo Ezequiel
--  Vargas, Tomas

-- Objetivo del script: Generar la base de datos con sus respectivos esquemas

-- Fecha: 12/06/2026

IF NOT EXISTS(SELECT name FROM sys.databases WHERE name = '[parques_nacionales]')
	CREATE DATABASE parques_nacionales;
GO

USE parques_nacionales;

IF SCHEMA_ID('[concesiones]') IS NULL
	EXEC('CREATE SCHEMA concesiones');
GO

IF SCHEMA_ID('[gestion]') IS NULL
	EXEC('CREATE SCHEMA gestion');
GO

IF SCHEMA_ID('[guia]') IS NULL
	EXEC('CREATE SCHEMA guia');
GO

IF SCHEMA_ID('[ventas]') IS NULL
	EXEC('CREATE SCHEMA ventas');
GO
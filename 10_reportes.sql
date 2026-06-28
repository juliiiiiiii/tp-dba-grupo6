-- Universidad: Universidad de la Matanza
-- Materia: 3641 - Bases de Datos Aplicadas

-- Grupo 06
-- Integrantes:
--  De Bellis, Nahuel
--  Ocampo, Julian Rafael
--  Rodriguez, Gonzalo Ezequiel
--  Vargas, Tomas

-- Objetivo del script: Creacion de reportes

-- Fecha: 26/06/2026

USE parques_nacionales
GO

/*
============================
GENERA REPORTE EN XML DE LAS VISITAS POR MES
============================
*/
CREATE OR ALTER PROCEDURE ventas.generar_reporte_visitas_por_mes
AS
	with visitas_por_mes as
	( SELECT DISTINCT parque, mes, año, total_mes FROM ventas.visitas_anuales)
	SELECT * FROM visitas_por_mes ORDER BY parque, mes, año
	--for XML PATH('Visitantes'), ROOT('Reporte') -- o AUTO?
GO

SELECT 'Reporte de visitas por mes'
EXEC ventas.generar_reporte_visitas_por_mes
go

CREATE OR ALTER PROCEDURE ventas.generar_xml_visitas__mensuales_por_parque @parque INT, @año CHAR(4)
AS
	--SET @año = '225'; para que le pisa el parametro?

	SELECT DISTINCT p.nombre, mes, total_mes AS visitas FROM ventas.visitas_anuales v
	LEFT JOIN
	gestion.parque p
	ON v.parque = p.id
	WHERE p.id = @parque AND año = @año
	ORDER BY mes
	FOR XML PATH('Visitas'), ROOT('Reporte')
GO

CREATE OR ALTER PROCEDURE ventas.generar_reporte_visitas @parque VARCHAR(50)
AS
	SELECT
		p.nombre AS 'Parque',
		FORMAT(mes, '00') + '/' + cast(año as char(4)) as 'Mes',
		total_mes as 'Visitantes'
	FROM ventas.visitas_mensuales v
	LEFT JOIN gestion.parque p ON p.nombre = v.parque
	WHERE p.nombre = @parque
	ORDER BY parque, mes, año
	for XML AUTO -- o AUTO?
GO

select 'Reporte de visitas mensuales'
exec ventas.generar_reporte_visitas @parque='Parque Nacional El Palmar'
go

/*
============================
GENERA REPORTE EL PIVOT DE LA MATRIZ DE LAS VISITAS
============================
*/

CREATE OR ALTER PROCEDURE ventas.pivot_ventas_por_mes @año int
AS
BEGIN
	DECLARE @cadenaSQL nvarchar(max)

	SET @cadenaSQL = '
	with visitas(parque, mes, visitas) as (SELECT 
		parque, mes, visitas
		FROM ventas.visitas_anuales
		where año = ' + CAST(@año AS CHAR(4)) + ')
		SELECT * FROM visitas
		PIVOT (SUM(visitas) for mes in ('

	SELECT  @cadenaSQL =  @cadenaSQL  + '[' + CAST((mes) AS CHAR(2)) + + ']' + ','
	FROM ventas.visitas_anuales
	GROUP BY mes
	SET @cadenaSQL = left(@cadenaSQL,len(@cadenaSQL)-1)
	SET @cadenaSQL = @cadenaSQL + ')) c'
	--print(@cadenaSQL)
	execute sp_executesql @cadenaSQL;
END
go

select 'Reporte de matriz de visitas'
exec ventas.pivot_ventas_por_mes 2026
go

/*
=================
REPORTE CON API (VISITAS EN FERIADOS)
=================
----API----
---Fuente: https://api.argentinadatos.com/v1/feriados/{año}
-- API gratuita que devuelve los feriados de un año específico.
--formato:
--	"fecha": "string",
--	"tipo": "string",
--	"nombre": "string"
*/
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
go

EXEC sp_configure 'Ole Automation Procedures', 1;
RECONFIGURE
go

CREATE OR ALTER PROCEDURE ventas.api_feriados @año CHAR(4)
	AS
	DECLARE @URL NVARCHAR(250) = 'https://api.argentinadatos.com/v1/feriados/';
	SET @URL = (SELECT CONCAT(@URL, @año));

	DECLARE @Object INT;
	DECLARE @Json TABLE(DATA NVARCHAR(MAX));
	DECLARE @ResponseText NVARCHAR(MAX);
  
	EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
	EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET', @URL, 'FALSE';
	EXEC sp_OAMethod @Object, 'SEND';
	EXEC sp_OAMethod @Object, 'RESPONSETEXT', @ResponseText OUTPUT , @Json OUTPUT;
	 print @URL
	INSERT INTO @Json exec sp_OAGetProperty @Object, 'RESPONSETEXT';
  
	DECLARE @Data NVARCHAR(MAX) = (SELECT DATA FROM @Json);
	--CREATE TABLE #feriados (fecha DATE)
	SELECT * INTO ##feriados FROM OPENJSON(@Data)
	WITH
	( 
	  [Fecha] NVARCHAR(500)  '$.fecha',
	  [Tipo] NVARCHAR(500) '$.tipo',
	  [Nombre] NVARCHAR(500)  '$.nombre'
	);
GO

CREATE OR ALTER PROCEDURE ventas.ventas_en_feriados @año CHAR(4)
AS
	EXEC ventas.api_feriados @año;

	SELECT * FROM ventas.visitas_por_fecha
	WHERE YEAR(fecha) = @año
	AND fecha IN (SELECT Fecha FROM [dbo].[##feriados])
	DROP TABLE [dbo].[##feriados]
GO

select 'Reporte con API ventas de feriados'
EXEC ventas.ventas_en_feriados '2026'
go

----API----
---Fuente:  https://api.argentinadatos.com/v1/cotizaciones/dolares
-- API gratuita que .........
--formato:
--"compra": 0,
--"venta": 0,
--"casa": "string",
--"nombre": "string",
--"moneda": "string",
--"fechaActualizacion": "string"
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO

EXEC sp_configure 'Ole Automation Procedures', 1;
RECONFIGURE
GO

CREATE OR ALTER PROCEDURE ventas.api_dolares
	AS
	DECLARE @URL NVARCHAR(250) = 'https://api.argentinadatos.com/v1/cotizaciones/dolares';

	DECLARE @Object INT;
	DECLARE @Json TABLE(DATA NVARCHAR(MAX));
	DECLARE @ResponseText NVARCHAR(MAX);
  
	EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
	EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET', @URL, 'FALSE';
	EXEC sp_OAMethod @Object, 'SEND';
	EXEC sp_OAMethod @Object, 'RESPONSETEXT', @ResponseText OUTPUT , @Json OUTPUT;
	 print @URL
	INSERT INTO @Json exec sp_OAGetProperty @Object, 'RESPONSETEXT';
  
	DECLARE @Data NVARCHAR(MAX) = (SELECT DATA FROM @Json);
	IF OBJECT_ID('tempdb.dbo.##DOLARES') IS NOT NULL DROP TABLE ##dolares
	SELECT * INTO ##dolares FROM OPENJSON(@Data)
	WITH
	( 
	  [Casa] NVARCHAR(500)  '$.casa',
	  [Cotizacion] NVARCHAR(500) '$.venta',
	  [fecha] NVARCHAR(500)  '$.fecha'
	);
GO

/*
============================
GENERA REPORTE CON API DE DÓLARES PARA CONVERSIÓN DE PRECIOS
============================
*/
CREATE OR ALTER PROCEDURE ventas.evolucion_entrada_dolar(@parque VARCHAR(50), @entrada VARCHAR(20))
AS
	EXEC ventas.api_dolares
	DECLARE @parque_id INT, @entrada_id INT
	SET @parque_id = (SELECT id_parque FROM ventas.entradas_vigentes WHERE parque = @parque AND visitante = @entrada)
	SET @entrada_id = (SELECT id_visitante FROM ventas.entradas_vigentes WHERE parque = @parque AND visitante = @entrada)
	SELECT parque, tipo, precio, precio/cotizacion as [precio en dolar], cotizacion as dolar, fecha from
	ventas.entrada e
	LEFT JOIN
	##dolares d
	ON e.fecha_desde = d.fecha
	WHERE parque = @parque_id AND tipo = @entrada_id AND casa = 'oficial'
	order by fecha
GO

--EXEC ventas.evolucion_entrada_dolar @parque = 'Parque Nacional Iguazú', @entrada = 'Estudiante'
--GO

/*
=================
VENTAS POR AÑO Y PARQUE
=================
*/
CREATE OR ALTER PROCEDURE ventas.ventas_por_año @parque VARCHAR(50)
AS
BEGIN
	DECLARE @id_parque INT;
	SET @id_parque = (SELECT id FROM gestion.parque WHERE nombre = @parque);

	SELECT p.nombre, v.año, v.visitas 
	FROM ventas.ventas_por_año v --TODO: este rompe porque no existe
	LEFT JOIN gestion.parque p ON p.id = v.parque
	WHERE p.id = @id_parque
END
GO
	
--EXEC ventas.ventas_por_año 'Parque Nacional Ibera'
--go

CREATE OR ALTER PROCEDURE ventas.reporte_visitas_por_semana @parque VARCHAR(50)
AS
	DECLARE @id_parque INT;
	SET @id_parque = (SELECT id FROM gestion.Parque WHERE nombre = @parque);

	select nombre, semana, visitas
	from ventas.visitas_por_semana v
	LEFT JOIN gestion.parque p ON p.id = v.parque
	WHERE p.id = @id_parque
	order by parque, semana
GO

select 'Reporte de visitas por semana'
EXEC ventas.reporte_visitas_por_semana 'Parque Nacional Iguazú'
go

-- Ingresos por anio, mes y semana por parque
-- por semana se guarda el n° de semana del anio, capaz hay que preguntar si tiene que ser el n° semana del mes?
-- solo se generan de los registros que existen, capaz quiere mostrar todas las semanas aunque el monto sea 0?
CREATE OR ALTER PROCEDURE gestion.generar_reporte_ingresos
	@parque VARCHAR(100)
AS
BEGIN
	SELECT parque, YEAR(fecha) AS anio, MONTH(fecha) AS mes, DATEPART(WEEK, fecha) AS semana, SUM(ingresos_dia) AS ingresos_totales
	FROM gestion.ingresos_por_fecha
	WHERE parque = @parque COLLATE Latin1_General_CI_AI
	GROUP BY parque, YEAR(fecha), MONTH(fecha), DATEPART(WEEK, fecha)
	ORDER BY anio, mes, semana
	FOR XML PATH('Ingresos'), ROOT('Reporte');
END
GO

select 'Reporte ingresos por parque, mes y año.'
EXEC gestion.generar_reporte_ingresos @parque = 'parque nacional iguazu'
go

CREATE OR ALTER PROCEDURE concesiones.reporte_concesiones_por_parque 
	@parque VARCHAR(100) = null
as BEGIN 
	select p.id as parque, p.nombre as nombre, (
		select 
			c.fecha_inicio as inicio
			, e.nombre as titular
			, trim(a.nombre) as actividad
		from concesiones.Concesion as c
		join concesiones.Empresa as e on c.id_empresa=e.id
		left join gestion.Actividad as a on c.id_actividad=a.id
		where p.id=c.id_parque
		for xml path
	) as concesiones
	from gestion.Parque as p 
	where p.nombre like isnull(@parque, '%%')
end
go

select 'Reporte Parques y concesiones'
exec concesiones.reporte_concesiones_por_parque
go

create or alter procedure concesiones.deudores as
	select c.id, c.fecha_inicio, e.nombre as empresa, p.nombre as parque, cp.periodo, cp.monto
	from concesiones.Concesion as c
    JOIN concesiones.Empresa AS e ON c.id_empresa = e.id
    JOIN gestion.Parque AS p ON p.id = c.id_parque
	join concesiones.Canon_pagar as cp on cp.id_concesion = c.id
	where 
	--cp.estado = 'PENDIENTE'
	fecha_pagado is null
go

SELECT 'Reporte de Deudores'
exec concesiones.deudores;
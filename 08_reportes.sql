USE parques_nacionales
GO

/*
============================
GENERA REPORTE EN XML DE LAS VISITAS POR MES
============================
*/
CREATE OR ALTER PROCEDURE ventas.generar_reporte_visitas_por_mes
AS
	SELECT
		p.nombre AS 'Parque',
		FORMAT(mes, '00') + '/' + cast(año as char(4)) as 'Mes',
		visitas as 'Visitantes'
	FROM ventas.visitas_por_mes v
	LEFT JOIN
	gestion.parque p ON p.id = v.parque
	ORDER BY parque, mes, año
	for XML PATH('Visitantes'), ROOT('Reporte') -- o AUTO?
GO

CREATE OR ALTER PROCEDURE ventas.generar_xml_visitas__mensuales_por_parque @parque INT, @año CHAR(4)
AS
	DECLARE @parque int, @año CHAR(4)
	SET @parque = 1
	SET @año = '2025';
	SELECT DISTINCT p.nombre, mes, total_mes AS visitas FROM ventas.visitas_anuales v
	LEFT JOIN
	gestion.parque p
	ON v.parque = p.id
	WHERE p.id = @parque AND año = @año
	ORDER BY mes
	FOR XML PATH(CAST(@año AS text)), ROOT('Reporte')
GO

CREATE OR ALTER PROCEDURE ventas.generar_reporte_visitas @parque
AS
	DECLARE @parque VARCHAR(50)
	set @parque = 'Iguazu'
	SELECT
		p.nombre AS 'Parque',
		FORMAT(mes, '00') + '/' + cast(año as char(4)) as 'Mes',
		visitas as 'Visitantes'
	FROM ventas.visitas_por_mes v
	LEFT JOIN
	gestion.parque p ON p.id = v.parque
	WHERE p.nombre = @parque
	ORDER BY parque, mes, año
	for XML AUTO -- o AUTO?
GO

--EXEC sp_generar_reporte_visitas_por_mes
/*
============================
GENERA REPORTE EL PIVOT DE LA MATRIZ DE LAS VISITAS
============================
*/

CREATE OR ALTER PROCEDURE ventas.pivot_ventas_por_mes @año int
AS
	DECLARE @cadenaSQL nvarchar(max)

	SET @cadenaSQL = '
	with visitas(parque, mes, visitas) as (SELECT 
		p.nombre as Parque, mes, visitas
		FROM ventas.visitas_anuales v
		LEFT JOIN
		gestion.parque p ON p.id = v.parque
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


--exec ventas.pivot_ventas_por_mes @año = 2026

/*
=================
REPORTE CON API (VISITAS EN FERIADOS)
=================
*/

----API----
---Fuente: https://api.argentinadatos.com/v1/feriados/{año}
-- API gratuita que devuelve los feriados de un año específico.
--formato:
--	"fecha": "string",
--	"tipo": "string",
--	"nombre": "string"

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO

EXEC sp_configure 'Ole Automation Procedures', 1;
RECONFIGURE
GO


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
	EXEC api_feriados @año;

	SELECT * FROM ventas.visitas_por_fecha
	WHERE YEAR(fecha) = @año
	AND fecha IN (SELECT Fecha FROM [dbo].[##feriados])
	DROP TABLE [dbo].[##feriados]
GO

--EXEC sp_ventas_en_feriados '2026'

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
	SELECT p.nombre, v.año, v.visitas FROM
	ventas.ventas_por_año v
	LEFT JOIN
	gestion.parque p ON p.id = v.parque
	WHERE p.id = @id_parque
END
GO
	
--EXEC ventas.sp_ventas_por_año 'Ibera'


/*
=================
VENTAS POR SEMANA
=================
*/
CREATE OR ALTER VIEW ventas.visitas_por_semana
AS

	with visitas_por_semana(parque, fecha, semana, total) AS (
	select parque, fecha, datepart(week, fecha) as semana, total from ventas.visitas_por_fecha
	)
	select parque, semana, sum(total) as total_semana from visitas_por_semana group by parque, semana
GO

--exec ventas.sp_ventas_por_semana 'Glaciares'

CREATE OR ALTER PROCEDURE ventas.reporte_visitas_por_semana @parque VARCHAR(50)
AS
	DECLARE @id_parque INT;
	SET @id_parque = (SELECT id FROM gestion.parque WHERE nombre = @parque);

	select nombre, semana, total_semana
	from ventas.visitas_por_semana v
	LEFT JOIN
	gestion.parque p
	ON p.id = v.parque
	WHERE p.id = @id_parque
	order by parque, semana
GO
--EXEC ventas.reporte_visitas_por_semana 'Ibera'


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
	EXEC api_dolares
	DECLARE @parque_id INT, @entrada_id INT
	SET @parque_id = (SELECT id_parque FROM ventas.vw_entradas_vigentes WHERE parque = @parque AND visitante = @entrada)
	SET @entrada_id = (SELECT id_visitante FROM ventas.vw_entradas_vigentes WHERE parque = @parque AND visitante = @entrada)
	SELECT parque, tipo, precio, precio/cotizacion as [precio en dolar], cotizacion as dolar, fecha from
	ventas.entrada e
	LEFT JOIN
	##dolares d
	ON e.fecha_desde = d.fecha
	WHERE parque = @parque_id AND tipo = @entrada_id AND casa = 'oficial'
	order by fecha
GO
--EXEC ventas.sp_evolucion_entrada_dolar @parque = 'Iguazu', @entrada = 'Estudiante'


CREATE OR ALTER FUNCTION concesiones.identificar_concesion(@ids VARCHAR(MAX)) RETURNS TABLE AS
RETURN (
    SELECT 
        c.fecha_inicio, 
        e.nombre AS empresa, 
        p.nombre AS parque
    FROM concesiones.Concesion AS c
    JOIN concesiones.Empresa AS e ON c.id_empresa = e.id
    JOIN gestion.Parque AS p ON p.id = c.id_parque
    WHERE c.id IN (SELECT value FROM STRING_SPLIT(@ids, ','))
);
GO

-- la info de inf.* es con lo que se identifica despues las concesiones para usar los sp's
create or alter view concesiones.deudores as
select c.id, inf.fecha_inicio, inf.empresa, inf.parque, cp.periodo, cp.monto
from concesiones.Concesion as c
CROSS APPLY concesiones.identificar_concesion(CAST(c.id AS VARCHAR)) AS inf
join concesiones.Canon_pagar as cp on cp.id_concesion = c.id
where 
--cp.estado = 'PENDIENTE'
fecha_pagado is null
go

-- 'servicios prestados' se refiere a actividad? deberia agregar un nuevo campo para servicios prestados en concesion?
-- entiendo que titular se refiere a la empresa
-- otras opciones eran:
-- string_agg <- era muy manual y no me copo
-- select con joins <- no cumplia con la idea de vector que pide el reporte
create or alter view concesiones.concesiones_por_parque as
select p.id as id, p.nombre, (
    select 
        c.fecha_inicio as inicio
        , e.nombre as titular
        , trim(a.nombre) as actividad
    from concesiones.Concesion as c
    join concesiones.Empresa as e on c.id_empresa=e.id
    left join gestion.Actividad as a on c.id_actividad=a.id
    where p.id=c.id_empresa
    for json path -- for xml path
) as concesiones
from gestion.Parque as p 
go
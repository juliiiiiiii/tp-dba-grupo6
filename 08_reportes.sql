USE parques_nacionales
GO

/*
============================
GENERA REPORTE EN XML DE LAS VISITAS POR MES
============================
*/


CREATE OR ALTER PROCEDURE sp_generar_reporte_visitas_por_mes
AS
	SELECT
		p.nombre AS 'Parque',
		FORMAT(mes, '00') + '/' + cast(año as char(4)) as 'Mes',
		visitas as 'Visitantes'
	FROM ventas.vw_visitantes_por_mes v
	LEFT JOIN
	gestion.parque p ON p.id = v.parque
	ORDER BY parque, mes, año
	for XML PATH('Visitantes'), ROOT('Reporte') -- o AUTO?
GO

--EXEC sp_generar_reporte_visitas_por_mes
/*
============================
GENERA REPORTE EL PIVOT DE LA MATRIZ DE LAS VISITAS
============================
*/
CREATE OR ALTER PROCEDURE sp_pivot_ventas_por_mes
AS
	WITH ventas_por_mes(Parque, Mes, Visitas)
	AS (
		SELECT
		p.nombre AS 'Parque',
		FORMAT(MONTH(fecha), '00') + '-' + cast(YEAR(fecha) as char(4)) as 'Mes',
		total  as 'Visitas'
		FROM ventas.vw_visitas_por_fecha v
		LEFT JOIN
		gestion.parque p ON p.id = v.parque
	)
	SELECT * FROM ventas_por_mes
	PIVOT (max(visitas) for Parque in (Aconquija, Calilegua, Copo, "El Rey", Glaciares, Ibera, Iguazu)) c
--exec sp_pivot_ventas_por_mes

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


CREATE OR ALTER PROCEDURE sp_feriados @año CHAR(4)
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


CREATE OR ALTER PROCEDURE sp_ventas_en_feriados @año CHAR(4)
AS
	EXEC sp_feriados @año;

	SELECT * FROM ventas.vw_visitas_por_fecha
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

CREATE OR ALTER PROCEDURE ventas.sp_ventas_por_año @parque VARCHAR(50)
AS
BEGIN
	DECLARE @id_parque INT;
	SET @id_parque = (SELECT id FROM gestion.parque WHERE nombre = @parque);
	SELECT p.nombre, v.año, v.visitas FROM
	ventas.vw_ventas_por_año v
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
CREATE OR ALTER VIEW ventas.vw_visitas_por_semana
AS

	with visitas_por_semana(parque, fecha, semana, total) AS (
	select parque, fecha, datepart(week, fecha) as semana, total from ventas.vw_visitas_por_fecha
	)
	select parque, semana, sum(total) as total_semana from visitas_por_semana group by parque, semana
GO

--exec ventas.sp_ventas_por_semana 'Glaciares'

CREATE OR ALTER PROCEDURE ventas.reporte_visitas_por_semana @parque VARCHAR(50)
AS
	DECLARE @id_parque INT;
	SET @id_parque = (SELECT id FROM gestion.parque WHERE nombre = @parque);

	select nombre, semana, total_semana
	from ventas.vw_visitas_por_semana v
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


CREATE OR ALTER PROCEDURE sp_dolares
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

CREATE OR ALTER PROCEDURE ventas.sp_evolucion_entrada_dolar(@parque VARCHAR(50), @entrada VARCHAR(20))
AS
	EXEC sp_dolares
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

-- todo hacerlo en vistas
-- la info de inf.* es con lo que se identifica despues las concesiones para usar los sp's
select c.id, inf.fecha_inicio, inf.empresa, inf.parque, cp.periodo, cp.monto
from concesiones.Concesion as c
CROSS APPLY concesiones.identificar_concesion(CAST(c.id AS VARCHAR)) AS inf
join concesiones.Canon_pagar as cp on cp.id_concesion = c.id
where 
--cp.estado = 'PENDIENTE'
fecha_pagado is null


-- 'servicios prestados' se refiere a actividad? deberia agregar un nuevo campo para servicios prestados en concesion?
-- entiendo que titular se refiere a la empresa
-- otras opciones eran:
-- string_agg <- era muy manual y no me copo
-- select con joins <- no cumplia con la idea de vector que pide el reporte
select p.id as id, (
    select 
        c.fecha_inicio as inicio
        , e.nombre as titular
        , trim(a.nombre) as actividad
    from concesiones.Concesion as c
    join concesiones.Empresa as e on c.id_empresa=e.id
    left join gestion.Actividad as a on c.id_actividad=a.id
    where p.id=c.id_empresa and c.estado = 'ACTIVO' 
    for json path -- for xml path
)
from gestion.Parque as p 

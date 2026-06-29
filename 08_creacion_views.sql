-- Universidad: Universidad de la Matanza
-- Materia: 3641 - Bases de Datos Aplicadas

-- Grupo 06
-- Integrantes:
--  De Bellis, Nahuel
--  Ocampo, Julian Rafael
--  Rodriguez, Gonzalo Ezequiel
--  Vargas, Tomas

-- Objetivo del script: Creacion de views

-- Fecha: 26/06/2026

USE parques_nacionales
GO

CREATE OR ALTER VIEW reportes.parques
AS
	SELECT p.id, p.nombre, p.superficie, u.provincia
	FROM gestion.Parque as p
	join gestion.Ubicacion as u on u.id=p.id_ubicacion
	where estado = 'Activo'
GO

/*
=================
Genera una view que muestra las ventas con sus respectivos visitantes
=================
*/
CREATE OR ALTER VIEW reportes.ventas_con_visitantes
AS
	SELECT v.parque, p.nombre as nombre, v.id as venta, i.id AS item, v.fecha, i.concepto, i.cantidad, v.total
	FROM
	ventas.venta v 
	join gestion.Parque as p on p.id=v.parque
	LEFT JOIN ventas.item_venta i ON v.id = i.venta
	WHERE i.detalle IN (SELECT descripcion FROM ventas.tipo_visitante)
GO
select distinct nombre from reportes.ventas_con_visitantes;
select distinct parque from ventas.venta;


/*
=================
Genera una view que muestra cada venta con el total de visitantes, sin discriminar el tipo.
=================
*/
CREATE OR ALTER VIEW reportes.totales_visitas_por_venta
AS
	SELECT parque, nombre, fecha, venta, SUM(cantidad) as total FROM
	reportes.ventas_con_visitantes
	GROUP BY venta, parque, nombre, fecha
GO

/*
=================
Genera una view que muestra el total de visitantes por dia por parque y fecha
=================
*/
CREATE OR ALTER VIEW reportes.visitas_por_fecha
AS
	SELECT parque, nombre, fecha, sum(total) as total from reportes.totales_visitas_por_venta group by parque, nombre, fecha
GO


/*
=================
Genera una view que muestra el total de visitantes por dia por parque y fecha
=================
*/
CREATE OR ALTER VIEW reportes.visitas_por_semana
AS
	WITH totales_por_mes(parque, semana, mes, año, total)
	AS
	(
		SELECT
			parque,
			(SELECT DATEPART(WEEK, fecha)) as semana,
			(SELECT MONTH(fecha)) AS mes,
			(SELECT YEAR(fecha)) AS año,
			total
			FROM reportes.visitas_por_fecha
	)
	SELECT parque, semana, mes, año, sum(total) AS visitas FROM totales_por_mes group by parque, semana, mes, año
GO

CREATE OR ALTER VIEW reportes.visitas_anuales
AS
	SELECT p.nombre as parque, semana, mes, año, visitas,
	SUM(visitas) OVER (PARTITION BY parque, mes) as 'total_mes',
	SUM(visitas) OVER (PARTITION BY parque, año) as 'total_año'
	FROM reportes.visitas_por_semana v
	LEFT JOIN
	gestion.parque p
	ON p.id = v.parque
GO

CREATE OR ALTER VIEW reportes.visitas_mensuales
as
	SELECT DISTINCT parque, mes, año, total_mes FROM reportes.visitas_anuales
--SELECT * from ventas.visitas_anuales ORDER BY parque, mes, año
--SELECT DISTINCT parque, mes, año, total_mes FROM ventas.visitas_anuales ORDER BY parque, mes, año
--SELECT DISTINCT parque, año, total_año FROM ventas.visitas_anuales ORDER BY parque, año
GO
/*
===========================================
vw_entradas_vigentes: Vista sólo con las entradas que están vigentes
============================================
*/
CREATE OR ALTER VIEW reportes.entradas_vigentes
AS
	SELECT p.id AS id_parque, p.nombre AS Parque, t.id AS id_visitante, t.descripcion as Visitante, precio
	FROM ventas.entrada e
	LEFT JOIN gestion.parque p ON e.parque = p.id
	LEFT JOIN ventas.tipo_visitante t ON e.tipo = t.id
	WHERE fecha_hasta IS NULL
GO

-- Vista para filtrar los ingresos totales por parque por fecha
CREATE OR ALTER VIEW reportes.ingresos_por_fecha
AS
	WITH cte AS
	(
		SELECT id_parque, CAST(fecha AS DATE) AS fecha_operacion, costo AS monto_operacion, 'Actividad' as tipo FROM gestion.Actividad

		UNION ALL

		SELECT c.id_parque, CAST(fecha_pagado AS DATE) AS fecha_operacion, monto AS monto_operacion, 'Concesiones' as tipo FROM concesiones.Concesion c
		INNER JOIN  concesiones.Canon_pagar cp ON c.id = cp.id_concesion where cp.estado = 'PAGADO'

		UNION ALL

		SELECT parque, CAST(fecha AS DATE) AS fecha_operacion, total AS monto_operacion, 'Ventas' as tipo FROM ventas.Venta
	)

	SELECT p.nombre AS parque, cte.tipo, cte.fecha_operacion AS fecha, SUM(cte.monto_operacion) AS ingresos_dia
	FROM cte
	INNER JOIN gestion.Parque p ON p.id = cte.id_parque
	GROUP BY nombre, cte.tipo, fecha_operacion
GO

SELECT distinct parque FROM reportes.ingresos_por_fecha where tipo='Ventas'
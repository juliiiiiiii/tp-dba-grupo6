USE parques_nacionales
GO

/*
=================
Genera una view que muestra las ventas con sus respectivos visitantes
=================
*/
CREATE OR ALTER VIEW ventas.detalle_conceptos
AS
	SELECT e.id, t.descripcion as nombre
	FROM
	ventas.entrada e
	LEFT JOIN
	ventas.tipo_visitante t
	ON e.tipo = t.id
	UNION
	SELECT id, nombre
	FROM gestion.Actividad
GO


CREATE OR ALTER VIEW ventas.ventas_con_visitantes AS
	SELECT v.parque, v.id as venta, i.id AS item, v.fecha, i.concepto, i.cantidad, v.total
	FROM
	ventas.venta v
	LEFT JOIN
	ventas.item_venta i
	ON v.id = i.venta
	WHERE i.detalle IN (SELECT descripcion FROM ventas.tipo_visitante)
GO

/*
=================
Genera una view que muestra cada venta con el total de visitantes, sin discriminar el tipo.
=================
*/
CREATE OR ALTER VIEW ventas.totales_visitas_por_venta
AS
	SELECT parque, fecha, venta, SUM(cantidad) as total FROM
	ventas.ventas_con_visitantes
	GROUP BY venta, parque, fecha
GO

/*
=================
Genera una view que muestra el total de visitantes por dia por parque y fecha
=================
*/

CREATE OR ALTER VIEW ventas.visitas_por_fecha
AS
	SELECT parque, fecha, sum(total) as total from ventas.totales_visitas_por_venta group by parque, fecha
GO

/*
=================
Genera una view que muestra el total de visitantes por dia por parque y fecha
=================
*/

CREATE OR ALTER VIEW ventas.visitas_por_semana
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
			FROM ventas.visitas_por_fecha
	)
	SELECT parque, semana, mes, año, sum(total) AS visitas FROM totales_por_mes group by parque, semana, mes, año
GO
CREATE OR ALTER VIEW ventas.visitas_anuales
AS
	SELECT *,
	SUM(visitas) OVER (PARTITION BY parque, mes) as 'total_mes',
	SUM(visitas) OVER (PARTITION BY parque, año) as 'total_año'
	FROM ventas.visitas_por_semana
--SELECT * from ventas.visitas_anuales ORDER BY parque, mes, año
--SELECT DISTINCT parque, mes, año, total_mes FROM ventas.visitas_anuales ORDER BY parque, mes, año
--SELECT DISTINCT parque, año, total_año FROM ventas.visitas_anuales ORDER BY parque, año

CREATE OR ALTER VIEW ventas.visitas_por_mes
AS
	SELECT parque, mes, año, sum(visitas) FROM ventas.visitas_por_semana GROUP BY parque, mes, año
GO
/*
=================
Genera una view que muestra el total de visitantes por parque y año
=================
*/

CREATE OR ALTER VIEW ventas.visitas_por_año
AS
	SELECT parque, año, sum(visitas) as visitas FROM ventas.visitas_por_mes GROUP BY parque, año
GO

/*
===========================================
vw_entradas_vigentes: Vista sólo con las entradas que están vigentes
============================================
*/

CREATE OR ALTER VIEW ventas.entradas_vigentes
AS
	SELECT p.id AS id_parque, p.nombre AS Parque, t.id AS id_visitante, t.descripcion as Visitante, precio
	FROM ventas.entrada e
	LEFT JOIN
	gestion.parque p
	ON e.parque = p.id
	LEFT JOIN
	ventas.tipo_visitante t
	ON e.tipo = t.id
	WHERE fecha_hasta IS NULL
GO


/*
CREATE OR ALTER ventas.vw_ventas_por_semana
AS
	SELECT * FROM ventas.vw_totales_visitas
	*/


USE parques_nacionales

/*
=================
Genera una view que muestra las ventas con sus respectivos visitantes
=================
*/
GO
CREATE OR ALTER VIEW ventas.vw_ventas_con_visitantes AS
	WITH id_por_parque(id, parque) AS (SELECT id, nombre FROM gestion.parque)
	
	SELECT v.parque, v.id as venta, i.id AS item, v.fecha, i.concepto, i.cantidad, v.total
	FROM
	ventas.venta v
	LEFT JOIN
	ventas.item_venta i
	ON v.id = i.venta
	WHERE i.concepto IN (SELECT id FROM ventas.entrada)
GO

/*
=================
Genera una view que muestra cada venta con el total de visitantes, sin discriminar el tipo.
=================
*/
CREATE OR ALTER VIEW ventas.vw_totales_visitas
AS
	SELECT parque, fecha, venta, SUM(cantidad) as total FROM
	ventas.vw_ventas_con_visitantes
	GROUP BY venta, parque, fecha
GO

/*
=================
Genera una view que muestra el total de visitantes por dia por parque y fecha
=================
*/

CREATE OR ALTER VIEW ventas.vw_visitas_por_fecha
AS
	SELECT parque, fecha, sum(total) as total from ventas.vw_totales_visitas group by parque, fecha
GO

/*
=================
Genera una view que muestra el total de visitantes por dia por parque y fecha
=================
*/

CREATE OR ALTER VIEW ventas.vw_visitantes_por_mes
AS
	WITH totales_por_mes(parque, mes, año, total)
	AS
	(
		SELECT
			parque,
			(SELECT MONTH(fecha)) AS mes,
			(SELECT YEAR(fecha)) AS año,
			total
			FROM ventas.vw_visitas_por_fecha
	)
	SELECT parque, mes, año, sum(total) as visitas FROM totales_por_mes GROUP BY parque, año, mes

/*
=================
Genera una view que muestra el total de visitantes por parque y año
=================
*/

CREATE OR ALTER VIEW ventas.vw_ventas_por_año
AS
	WITH totales_por_año(parque, año, total)
	AS
	(
		SELECT parque,
			(SELECT YEAR(fecha)) AS año,
			total
		FROM ventas.vw_visitas_por_fecha
	)
	SELECT parque, año, sum(total) as visitas FROM totales_por_año GROUP BY parque, año
GO

/*
===========================================
vw_entradas_vigentes: Vista sólo con las entradas que están vigentes
============================================
*/

CREATE OR ALTER VIEW ventas.vw_entradas_vigentes
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


CREATE OR ALTER ventas.vw_ventas_por_semana
AS
	SELECT * FROM ventas.vw_totales_visitas



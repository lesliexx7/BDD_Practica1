SELECT * FROM dbo.cat_entidades;
Select * from dbo.datoscovid;

/************************************
	Consulta No.1 Listar el top 5 de las entidades con más casos confirmados por cada uno de los años 
	registrados en la base de datos. 
	Significado de los valores de los catalogos: 
	Responsable: Macias Galvan Arturo Daniel
	Comentarios: 
	
*************************************/

select top 5 cont as casos_confirmados,ENTIDAD_UM 
from(
	select ENTIDAD_UM,count(CLASIFICACION_FINAL)cont 
	from datoscovid 
	where CLASIFICACION_FINAL=3 
	group by ENTIDAD_UM
)as t1 
order by casos_confirmados desc

/************************************
	Consulta No.3 Listar el porcentaje de casos confirmados en cada una 
	de las siguientes morbilidades a nivel nacional: diabetes, obesidad e hipertensión. 
	Significado de los valores de los catalogos: 
	Responsable: Palacios Reyes Leslie Noemi
	Comentarios: 
	
*************************************/
SELECT 
    'Diabetes' AS Morbilidad,
    100.0 * SUM(CASE WHEN DIABETES = 1 THEN 1 ELSE 0 END) / COUNT(*) AS Porcentaje
FROM datoscovid
WHERE CLASIFICACION_FINAL IN (1, 2, 3)
UNION ALL
SELECT 
    'Obesidad' AS Morbilidad,
    100.0 * SUM(CASE WHEN OBESIDAD = 1 THEN 1 ELSE 0 END) / COUNT(*) AS Porcentaje
FROM datoscovid
WHERE CLASIFICACION_FINAL IN (1, 2, 3)
UNION ALL
SELECT 
    'Hipertensión' AS Morbilidad,
    100.0 * SUM(CASE WHEN HIPERTENSION = 1 THEN 1 ELSE 0 END) / COUNT(*) AS Porcentaje
FROM datoscovid
WHERE CLASIFICACION_FINAL IN (1, 2, 3);


/************************************
	Consulta No.4 Listar los municipios que no tengan casos confirmados en todas las morbilidades: 
hipertensión, obesidad, diabetes, tabaquismo. 
	Significado de los valores de los catalogos: 
	Responsable: Macias Galvan Arturo Daniel
	Comentarios: 
	
*************************************/
select distinct(MUNICIPIO_RES)
from datoscovid
where not((HIPERTENSION=1 or OBESIDAD=1 or DIABETES=1 or TABAQUISMO=1) or 
		CLASIFICACION_FINAL=1 or CLASIFICACION_FINAL=2 or CLASIFICACION_FINAL=3)


/************************************
	Consulta No.6 Listar el total de casos confirmados/sospechosos 
	por estado en cada uno de los años registrados en la base de datos. 
	Significado de los valores de los catalogos: 
	Responsable: Palacios Reyes Leslie Noemi
	Comentarios: 
*************************************/
SELECT 
    ENTIDAD_RES AS Estado,  
    YEAR(TRY_CAST(FECHA_INGRESO AS DATE)) AS Año,  
    COUNT(*) AS Total_Casos  
FROM datoscovid  
WHERE CLASIFICACION_FINAL IN (1, 2, 3)  -- 1, 2, 3 son casos confirmados o sospechosos  
AND TRY_CAST(FECHA_INGRESO AS DATE) IS NOT NULL  
GROUP BY ENTIDAD_RES, YEAR(TRY_CAST(FECHA_INGRESO AS DATE))  
ORDER BY Año, Total_Casos DESC;

/************************************
	Consulta No.7 Para el año 2020 y 2021 cuál fue el mes con más casos registrados, confirmados, 
sospechosos, por estado registrado en la base de datos. 
	Significado de los valores de los catalogos: 
	Responsable: Macias Galvan Arturo Daniel
	Comentarios: 
	
*************************************/
select distinct max(entidad) ent,FECHA_SINTOMAS 
from(
	select count(distinct ENTIDAD_UM)entidad,FECHA_SINTOMAS 
	from datoscovid 
	where (CLASIFICACION_FINAL=3 or CLASIFICACION_FINAL=6) and
			(FECHA_SINTOMAS like '2020-%' or FECHA_SINTOMAS like'2021-%')
	group by FECHA_SINTOMAS
)as t1
group by FECHA_SINTOMAS

/************************************
	Consulta No. 9.	Listar el top 3 de municipios con menos casos 
	recuperados en el año 2021. 
	Significado de los valores de los catalogos: 
	Responsable: Palacios Reyes Leslie Noemi
	Comentarios: 
*************************************/
WITH casos_recuperados AS (
    SELECT 
        ENTIDAD_RES, 
        MUNICIPIO_RES, 
        COUNT(*) AS total_recuperados
    FROM datoscovid
    WHERE YEAR(TRY_CAST(FECHA_INGRESO AS DATE)) = 2021
    AND FECHA_DEF = '9999-99-99'  -- Casos recuperados (asumimos que no han fallecido)
    GROUP BY ENTIDAD_RES, MUNICIPIO_RES
)
SELECT  TOP 3 * 
FROM casos_recuperados 
ORDER BY total_recuperados ASC, ENTIDAD_RES, MUNICIPIO_RES;

/************************************
	Consulta No.10  Listar el porcentaje de casos confirmado por género en los años 2020 y 2021.  
	Significado de los valores de los catalogos: 
	Responsable: Macias Galvan Arturo Daniel
	Comentarios: 
	
*************************************/
select SEXO,(
		COUNT(CLASIFICACION_FINAL)*100.0 / (select count (CLASIFICACION_FINAL)
												from datoscovid
												where CLASIFICACION_FINAL=3 and 
												(FECHA_SINTOMAS like '2020-%' or FECHA_SINTOMAS like'2021-%'))
)casos from datoscovid 
where CLASIFICACION_FINAL=3 and (FECHA_SINTOMAS like '2020-%' or FECHA_SINTOMAS like'2021-%') group by SEXO

/************************************
	Consulta No. 12
	Significado de los valores de los catalogos: 
	Responsable: Palacios Reyes Leslie Noemi
	Comentarios: 
*************************************/
SELECT 
    ce.entidad AS Estado,
    YEAR(TRY_CAST(dc.FECHA_INGRESO AS DATE)) AS Año,
    COUNT(*) AS Total_Casos_Negativos  
FROM dbo.datoscovid dc
JOIN dbo.cat_entidades ce ON dc.ENTIDAD_RES = ce.clave
WHERE dc.CLASIFICACION_FINAL = 7  -- Casos negativos
AND YEAR(TRY_CAST(dc.FECHA_INGRESO AS DATE)) IN (2020, 2021)
GROUP BY ce.entidad, YEAR(TRY_CAST(dc.FECHA_INGRESO AS DATE))
ORDER BY ce.entidad, Año;


/************************************
	Consulta No.13  Listar porcentajes de casos confirmados por género en el rango de edades de 20 a 30 años, 
	de 31 a 40 años, de 41 a 50 años, de 51 a 60 años y mayores a 60 años a nivel nacional.
	Significado de los valores de los catalogos: 
	Responsable: Macias Galvan Arturo Daniel
	Comentarios: 
	
*************************************/


select  distinct(select 
(
		COUNT(CLASIFICACION_FINAL)*100.0 / (select count (CLASIFICACION_FINAL)
												from datoscovid
												where CLASIFICACION_FINAL=3
												)
)from datoscovid where EDAD<=30 and EDAD>=20)anio20_30,
		(select (
		COUNT(CLASIFICACION_FINAL)*100.0 / (select count (CLASIFICACION_FINAL)
												from datoscovid
												where CLASIFICACION_FINAL=3
												)
) from datoscovid where EDAD>=31 and EDAD<=40)anio31_40,
		(select (
		COUNT(CLASIFICACION_FINAL)*100.0 / (select count (CLASIFICACION_FINAL)
												from datoscovid
												where CLASIFICACION_FINAL=3
												)
) from datoscovid where EDAD>=41 and EDAD<=50)anio41_50,
		(select (
		COUNT(CLASIFICACION_FINAL)*100.0 / (select count (CLASIFICACION_FINAL)
												from datoscovid
												where CLASIFICACION_FINAL=3
												)
) from datoscovid where EDAD>=51 and EDAD<=60)anio51_60,
		(select (
		COUNT(CLASIFICACION_FINAL)*100.0 / (select count (CLASIFICACION_FINAL)
												from datoscovid
												where CLASIFICACION_FINAL=3
												)
) from datoscovid where EDAD>60)anio60_mas
		
from datoscovid where CLASIFICACION_FINAL=3
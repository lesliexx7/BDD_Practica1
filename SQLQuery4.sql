use covidHistorico
--SELECT * FROM dbo.cat_entidades;
--Select * from dbo.datoscovid;


/************************************
	Consulta No.2 Listar el municipio con más casos confirmados recuperados por estado y por año
	Requisitos: que su estado_final=1,2 o 3 (cofirmado) que se haya recuperado (sin fecha de defuncion),ordenar por estado y por año, despues contar por municipio y mostrar el mayor por este orden
	Responsable: Legorreta Rodriguez Maria Fernanda

*************************************/
select d.ENTIDAD_UM, d.MUNICIPIO_RES, d.anio, d.total_recuperados
from (
      select
        ENTIDAD_UM, 
        MUNICIPIO_RES, 
        year(FECHA_INGRESO) anio, 
        count(*) total_recuperados
   from datoscovid
    where CLASIFICACION_FINAL in (1, 2, 3) 
    and FECHA_DEF = '9999-99-99'
    group by ENTIDAD_UM, MUNICIPIO_RES, year(FECHA_INGRESO)
) d
join (
    select ENTIDAD_UM, anio, max(total_recuperados) max_recuperados
    from (
        select 
            ENTIDAD_UM, 
            MUNICIPIO_RES, 
            year(FECHA_INGRESO) anio, 
            count(*) total_recuperados
        from datoscovid
        where CLASIFICACION_FINAL in (1, 2, 3)  
        and FECHA_DEF = '9999-99-99'
        group by ENTIDAD_UM, MUNICIPIO_RES, year(FECHA_INGRESO)
    ) x
    group by ENTIDAD_UM, anio
) m
on d.ENTIDAD_UM = m.ENTIDAD_UM 
and d.anio = m.anio 
and d.total_recuperados = m.max_recuperados
order by d.ENTIDAD_UM, d.anio;







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
	Consulta No.5 Listar los estados con más casos recuperados con neumonía
	Requisitos: tener pacientes que tengan neumonia, que no hayan fallecido y que su total sea mayor que los que si lo hicieron

*************************************/
--solucion 1
select e.entidad, count (d.ENTIDAD_UM) as Casos_recuperados
from datoscovid d
join cat_entidades e on d.ENTIDAD_UM = e.clave
where d.NEUMONIA = '1'
and d.FECHA_DEF = '9999-99-99'
group by e.entidad
order by Casos_recuperados desc

--solucion 2: verificando que haya mas casos recuperados que fallecidos
select entidad, casos_recuperados
from (
    select entidad, casos_recuperados, total_fallecidos
    from (
        select c.entidad, 
               COUNT(CASE when d.FECHA_DEF = '9999-99-99' then 1 end) as casos_recuperados,
               COUNT(CASE when d.FECHA_DEF <> '9999-99-99' then 1 end) as total_fallecidos
       from datoscovid d
        JOIN cat_entidades c on d.ENTIDAD_UM = c.clave
        where d.NEUMONIA = '1'
        group by c.entidad
    ) as conteo
    where casos_recuperados > total_fallecidos 
) as resultado
order by casos_recuperados desc;





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






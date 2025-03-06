<<<<<<< HEAD
use covidHistorico
--select * from dbo.cat_entidades;
--select * from dbo.datoscovid;

=======
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
>>>>>>> arturo

/************************************
	Consulta No.2 Listar el municipio con mÃ¡s casos confirmados recuperados por estado y por aÃ±o
	Requisitos: que su estado_final=1,2 o 3 (cofirmado) que se haya recuperado (sin fecha de defuncion),ordenar por estado y por aÃ±o, despues contar por municipio y mostrar el mayor por este orden
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
    consulta no.3 listar el porcentaje de casos confirmados en cada una 
    de las siguientes morbilidades a nivel nacional: diabetes, obesidad e hipertensiÃ³n. 
    responsable: Palacios Reyes Leslie Noemi
*************************************/
select 
    'diabetes' as morbilidad,
    100.0 * sum(case when diabetes = 1 then 1 else 0 end) / count(*) as porcentaje
from datoscovid
where clasificacion_final in (1, 2, 3)
union all
select 
    'obesidad' as morbilidad,
    100.0 * sum(case when obesidad = 1 then 1 else 0 end) / count(*) as porcentaje
from datoscovid
where clasificacion_final in (1, 2, 3)
union all
select 
    'hipertensiÃ³n' as morbilidad,
    100.0 * sum(case when hipertension = 1 then 1 else 0 end) / count(*) as porcentaje
from datoscovid
where clasificacion_final in (1, 2, 3);









/************************************
	Consulta No.5 Listar los estados con mÃ¡s casos recuperados con neumonÃ­a
	Requisitos: tener pacientes que tengan neumonia, que no hayan fallecido y que su total sea mayor que los que si lo hicieron
	Responsable: Legorreta Rodriguez Maria Fernanda

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
    Consulta no.6 listar el total de casos confirmados/sospechosos 
    por estado en cada uno de los aÃ±os registrados en la base de datos. 
    Responsable: Palacios Reyes Leslie NoemI
*************************************/
select 
    entidad_res as estado,  
    year(try_cast(fecha_ingreso as date)) as aÃ±o,  
    count(*) as total_casos  
from datoscovid  
where clasificacion_final in (1, 2, 3)  -- 1, 2, 3 son casos confirmados o sospechosos  
and try_cast(fecha_ingreso as date) is not null  
group by entidad_res, year(try_cast(fecha_ingreso as date))  
order by aÃ±o, total_casos desc;





/************************************
	Consulta No.8 Listar el municipio con menos defunciones en el mes con mas casos confirmados con neumonÃ­a en los aÃ±os 2020 y 2021
	Requisitos: tener neumonia=1, aÃ±o 2020 y aÃ±o 2021, contabilizar mes con mayor numero de confirmados, verificar cual municipio tiene menos defunciones (fecha_def<> '9999-99-99')	Significado de los valores de los catalogos
	Responsable: Legorreta Rodriguez Maria Fernanda

*************************************/
with MesMaxConfirmados as ( 
    select 
        month(FECHA_INGRESO) as mes, 
        year(FECHA_INGRESO) as anio, 
        count(*) as total_casos
    from datoscovid
    where NEUMONIA = '1'  
    and CLASIFICACION_FINAL in (1, 2, 3) 
    and year(FECHA_INGRESO) in (2020, 2021)
    group by year(FECHA_INGRESO), month(FECHA_INGRESO)
    having count(*) = (select max(total_casos) 
                       from (select count(*) as total_casos 
                             from datoscovid 
                             where NEUMONIA = '1' 
                             and CLASIFICACION_FINAL in (1, 2, 3)  
                             and year(FECHA_INGRESO) in (2020, 2021)
                             group by year(FECHA_INGRESO), month(FECHA_INGRESO)) as max_casos)
), DefuncionesPorMunicipio as (
    select ENTIDAD_UM, MUNICIPIO_RES, count(*) as total_defunciones
    from datoscovid
    where NEUMONIA = '1'
    and CLASIFICACION_FINAL in (1, 2, 3)  -- Casos confirmados
    and year(FECHA_INGRESO) = (select anio from MesMaxConfirmados)  
    and month(FECHA_INGRESO) = (select mes from MesMaxConfirmados)
    and FECHA_DEF <> '9999-99-99'  -- Solo los fallecidos
    group by ENTIDAD_UM, MUNICIPIO_RES
)
select ENTIDAD_UM, MUNICIPIO_RES, total_defunciones
from DefuncionesPorMunicipio
where total_defunciones = (select min(total_defunciones) from DefuncionesPorMunicipio);




/************************************
	Consulta No. 9.	Listar el top 3 de municipios con menos casos 
	recuperados en el aÃ±o 2021. 
	Responsable: Palacios Reyes Leslie NoemI 
*************************************/
with casos_recuperados as (
    select 
        entidad_res, 
        municipio_res, 
        count(*) as total_recuperados
    from datoscovid
    where year(try_cast(fecha_ingreso as date)) = 2021
    and fecha_def = '9999-99-99'  -- casos recuperados (asumimos que no han fallecido)
    group by entidad_res, municipio_res
)
select  top 3 * 
from casos_recuperados 
order by total_recuperados asc, entidad_res, municipio_res;

/************************************
	Consulta No.11 Listar el porcentaje de casos hospitalizados por estado en el aÃ±o 2020
	Requisitos: estar hospitalizado, fecha de ingreso en 2020, agrupar por estado el numero de casos hospitalizados, comparar el porcentaje con los casos totales por aÃ±o
	Responsable: Legorreta Rodriguez Maria Fernanda

*************************************/

with CasosPorEstado as (
    select 
        ENTIDAD_UM, 
        count(*) as total_hospitalizados
    from datoscovid
    where 
        TIPO_PACIENTE = 2 
        and year(FECHA_INGRESO) = 2020
    group by ENTIDAD_UM), 
TotalHospitalizados as (
    select 
        count(*) as total_hospitalizados_pais
    from datoscovid
    where 
        TIPO_PACIENTE = 2
        and year(FECHA_INGRESO) = 2020)
select 
    c.ENTIDAD_UM, 
    c.total_hospitalizados,
    (c.total_hospitalizados * 100.0 / t.total_hospitalizados_pais) as porcentaje_hospitalizados
from CasosPorEstado c, TotalHospitalizados t
order by porcentaje_hospitalizados desc;





/************************************
	Consulta No. 12 Listar total de casos negativos por
        estado en los aÃ±os 2020 y 2021.
	Responsable: Palacios Reyes Leslie Noemi
*************************************/
select 
    ce.entidad as estado,
    year(try_cast(dc.fecha_ingreso as date)) as aÃ±o,
    count(*) as total_casos_negativos  
from dbo.datoscovid dc
join dbo.cat_entidades ce on dc.entidad_res = ce.clave
where dc.clasificacion_final = 7  -- casos negativos
and year(try_cast(dc.fecha_ingreso as date)) in (2020, 2021)
group by ce.entidad, year(try_cast(dc.fecha_ingreso as date))
order by ce.entidad, aÃ±o;



/************************************
	Consulta No.14 Listar el rango de edad con mas casos confirmados y que fallecieron en los aÃ±os 2020 y 2021
	Requisitos: contabilizar por rango de edad, ordenar cual es mayor y menor
	Responsable: Legorreta Rodriguez Maria Fernanda
	
*************************************/
<<<<<<< HEAD
select top 1 rango_edad, count(*) as total_fallecidos
from (
    select 
        case 
            when EDAD between 0 and 9 then '0-9'
            when EDAD between 10 and 19 then '10-19'
            when EDAD between 20 and 29 then '20-29'
            when EDAD between 30 and 39 then '30-39'
            when EDAD between 40 and 49 then '40-49'
            when EDAD between 50 and 59 then '50-59'
            when EDAD between 60 and 69 then '60-69'
            when EDAD between 70 and 79 then '70-79'
            when EDAD >= 80 then '80+'
        end as rango_edad
    from datoscovid
    where FECHA_DEF <> '9999-99-99'  
	and CLASIFICACION_FINAL in ('1','2', '3') 
    and (year(FECHA_DEF) = 2020 or year(FECHA_DEF) = 2021) 
) as rango_fallecidos
group by rango_edad
order by total_fallecidos desc
=======
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
>>>>>>> arturo


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
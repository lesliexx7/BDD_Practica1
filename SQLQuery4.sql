SELECT * FROM dbo.cat_entidades;
Select * from dbo.datoscovid;
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






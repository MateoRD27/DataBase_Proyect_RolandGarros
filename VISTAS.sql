--1) Vista de Información de Jugadores

CREATE VIEW vista_jugadores AS
SELECT j.id_persona, p.nombres, p.apellidos, p.fecha_nacimiento, j.fecha_debut, j.fecha_retiro, j.peso_actual, j.altura, e.id_persona AS Entrenador, t.tipoDocumento AS Tipo_Documento
FROM jugador j
INNER JOIN persona p ON j.id_persona = p.id_persona
LEFT JOIN entrenador e ON j.id_entrenador = e.id_persona
LEFT JOIN tipo_documento_identidad t ON p.id_tipo_documento_identidad = t.id_tipo_documento_identidad;




--2)  Vista de Detalles de Arbitros Principal
CREATE OR REPLACE VIEW vista__arbitros_principales AS
SELECT
  p.id_persona,
  p.nombres,
  p.apellidos,
  p.fecha_nacimiento,
  ap.anios_experiencia
FROM arbitro_principal ap
INNER JOIN persona p ON ap.id_persona = p.id_persona;


--3)vista de patrocinadores de ediciones
CREATE OR REPLACE VIEW vista_patrocinadores_edicion AS
SELECT
    p.nombre AS nombre_patrocinador
FROM
    edicion e
JOIN
    patrocinador p ON p.id_edicion = e.id_edicion;
 



--4) vista que muestre los partidos ganados por los jugadores de una edición, junto con su altura promedio y el número total de partidos en los que participaron:
SELECT  * FROM partidos_ganados_jugadores

CREATE OR REPLACE VIEW partidos_ganados_jugadores AS
/*
    Creamos una vista llamada "partidos_ganados_jugadores" que mostrará información sobre los partidos ganados por los jugadores de una edición, junto con su altura promedio y el número total de partidos en los que participaron.
*/
SELECT 
    j.id_persona AS id_jugador, -- Seleccionamos el ID del jugador como "id_jugador".
    CONCAT(p.nombres, ' ', p.apellidos) AS nombre_jugador, -- Concatenamos los nombres y apellidos del jugador como "nombre_jugador".
    e.id_edicion, -- Seleccionamos el ID de la edición como "id_edicion".
    e.año_de_edicion, -- Seleccionamos el año de la edición como "año_de_edicion".
    COUNT(DISTINCT pa.id_partido) AS total_partidos, -- Calculamos el número total de partidos en los que participó el jugador como "total_partidos".
    SUM(CASE WHEN pa.id_jugador1 = j.id_persona THEN 1 ELSE 0 END) + -- Calculamos la cantidad de partidos ganados por el jugador cuando es jugador 1 en el partido.
    SUM(CASE WHEN pa.id_jugador2 = j.id_persona THEN 1 ELSE 0 END) AS partidos_ganados -- Calculamos la cantidad de partidos ganados por el jugador cuando es jugador 2 en el partido.
FROM 
    jugador j 
    JOIN persona p ON j.id_persona = p.id_persona -- Hacemos un JOIN con la tabla "persona" para obtener los nombres y apellidos del jugador.
    JOIN partido pa ON j.id_persona = pa.id_jugador1 OR j.id_persona = pa.id_jugador2 -- Hacemos un JOIN con la tabla "partido" para obtener los partidos en los que participó el jugador.
    JOIN edicion e ON pa.id_edicion = e.id_edicion -- Hacemos un JOIN con la tabla "edicion" para obtener la información de la edición.
GROUP BY 
    j.id_persona, p.nombres, p.apellidos, e.id_edicion, e.año_de_edicion; -- Agrupamos los resultados por ID del jugador, nombres, apellidos, ID de la edición y año de la edición.





--5) vista que muestra el número de lesiones, la descripción de las lesiones y el tiempo en que ocurrió cada una para un jugador en una edición específica:


CREATE VIEW lesiones_jugador_edicion AS

SELECT 
    j.id_persona AS id_jugador, -- Seleccionamos el ID del jugador y lo renombramos como "id_jugador".
    CONCAT(p.nombres, ' ', p.apellidos) AS nombre_jugador, -- Concatenamos los nombres y apellidos del jugador como "nombre_jugador".
    e.id_edicion, -- Seleccionamos el ID de la edición.
    e.año_de_edicion, -- Seleccionamos el año de la edición.
    COUNT(l.id_acciones) AS numero_lesiones -- Contamos el número de lesiones del jugador y lo renombramos como "numero_lesiones".
FROM 
    jugador j -- Seleccionamos de la tabla "jugador" como "j".
    JOIN persona p ON j.id_persona = p.id_persona -- Hacemos un JOIN con la tabla "persona" para obtener los nombres y apellidos del jugador.
    JOIN acciones_del_partido l ON j.id_persona = l.id_jugador -- Hacemos un JOIN con la tabla "acciones_del_partido" para obtener las lesiones del jugador.
    JOIN partido pa ON l.id_partido = pa.id_partido -- Hacemos un JOIN con la tabla "partido" para obtener la información de los partidos.
    JOIN edicion e ON pa.id_edicion = e.id_edicion -- Hacemos un JOIN con la tabla "edicion" para obtener la información de la edición.

GROUP BY 
    j.id_persona, p.nombres, p.apellidos, e.id_edicion, e.año_de_edicion; -- Agrupamos los resultados por ID del jugador, nombres y apellidos del jugador, ID de la edición y año de la edición.




--6) vista que muestra el número de faltas, el tipo de falta y las sanciones obtenidas por un jugador específico:

CREATE VIEW faltas_jugador AS

SELECT 
    j.id_persona AS id_jugador, -- Seleccionamos el ID del jugador y lo renombramos como "id_jugador".
    CONCAT(p.nombres, ' ', p.apellidos) AS nombre_jugador, -- Concatenamos los nombres y apellidos del jugador como "nombre_jugador".
    COUNT(f.id_acciones) AS numero_faltas, -- Contamos el número de faltas del jugador y lo renombramos como "numero_faltas".
    tf.descripcion AS tipo_falta, -- Seleccionamos la descripción del tipo de falta.
    s.tipo_sancion -- Seleccionamos el tipo de sanción asociada a la falta.

FROM 
    jugador j -- Seleccionamos de la tabla "jugador" como "j".
    JOIN persona p ON j.id_persona = p.id_persona -- Hacemos un JOIN con la tabla "persona" para obtener los nombres y apellidos del jugador.
    JOIN acciones_del_partido f ON j.id_persona = f.id_jugador -- Hacemos un JOIN con la tabla "acciones_del_partido" para obtener las faltas del jugador.
    JOIN falta fa ON f.id_acciones = fa.id_acciones -- Hacemos un JOIN con la tabla "falta" para obtener información sobre las faltas.
    JOIN tipo_falta tf ON fa.id_tipo_falta = tf.id_tipo_falta -- Hacemos un JOIN con la tabla "tipo_falta" para obtener la descripción del tipo de falta.
    LEFT JOIN sancion s ON tf.id_sancion = s.id_sancion -- Hacemos un LEFT JOIN con la tabla "sancion" para obtener el tipo de sanción asociada a la falta.

GROUP BY 
    j.id_persona, p.nombres, p.apellidos, tf.descripcion, s.tipo_sancion; -- Agrupamos los resultados por ID del jugador, nombres y apellidos del jugador, tipo de falta y tipo de sanción.





--7) generos de entrenadores
CREATE VIEW vista_entrenadores_generos AS
SELECT 
    e.id_persona AS id_entrenador,
    CONCAT(p.nombres, ' ', p.apellidos) AS nombre_entrenador,
    g.TipoGenero AS genero
FROM 
    entrenador e
JOIN 
    persona p ON e.id_persona = p.id_persona
JOIN 
    genero g ON e.id_genero = g.id_tipo_genero;



--8)  -- Vista para obtener el último partido de cada edición
CREATE or replace  VIEW vista_ultimo_partido_edicion AS
SELECT 
    e.id_edicion,
    e.año_de_edicion,
    e.organizador,
    p.id_partido,
    p.fecha_final,
    p.hora_final,
    ep.etapa AS etapa_del_torneo,
    es.estado_de_juego AS estado_partido,
    (SELECT nombres || ' ' || apellidos FROM persona WHERE id_persona = p.id_jugador1) AS jugador1,
    (SELECT nombres || ' ' || apellidos FROM persona WHERE id_persona = p.id_jugador2) AS jugador2,
    (SELECT nombres || ' ' || apellidos FROM persona WHERE id_persona = p.id_arbitro_principal) AS arbitro
FROM 
    edicion e
JOIN 
    partido p ON e.id_edicion = p.id_edicion
JOIN 
    etapas_del_torneo ep ON p.id_etapas_del_torneo = ep.id_etapas_del_torneo
JOIN 
    estado_del_partido es ON p.id_estado_del_partido = es.id_estado_del_partido
WHERE 
    (e.id_edicion, p.fecha_final, p.hora_final) IN (
        SELECT 
            e2.id_edicion, 
            MAX(p2.fecha_final) AS max_fecha_final, 
            MAX(p2.hora_final) AS max_hora_final
        FROM 
            edicion e2
        JOIN 
            partido p2 ON e2.id_edicion = p2.id_edicion
        GROUP BY 
            e2.id_edicion
    );


--9)  vista donde se obtiene los jugadores que más tuvieron sanciones en todas las ediciones, los entrenadores de estos y el país al que pertenecen tanto entrenador como jugador

CREATE VIEW vista_promedio_velocidad_servicio_por_edicion AS
SELECT
    e.id_edicion,
    e.año_de_edicion,
    e.organizador,
    AVG(s.velocidad_saque) AS promedio_velocidad_saque
FROM
    edicion e
JOIN
    partido p ON e.id_edicion = p.id_edicion
JOIN
    acciones_del_partido ap ON p.id_partido = ap.id_partido
JOIN
    servicio s ON ap.id_acciones = s.id_acciones
GROUP BY
    e.id_edicion, e.año_de_edicion, e.organizador;
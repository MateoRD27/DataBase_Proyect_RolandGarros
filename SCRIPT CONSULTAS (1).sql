--1) ¿Cuáles son los jugadores que debutaron después del 1 de enero de 2006?


SELECT *
FROM jugador
WHERE fecha_debut > '2006-01-01';

--2) ¿Qué jugadores tienen una altura mayor a 180 cm y un peso actual superior a 70 kg?


SELECT *
FROM jugador
WHERE altura > 180 AND peso_actual > 70;



--3) ¿Qué entrenadores nacieron antes de 1987 y entrenan a jugadores con una altura menor a 180 cm?

SELECT *
FROM entrenador e
JOIN persona p ON e.id_persona = p.id_persona
WHERE p.fecha_nacimiento < '1987-01-01'
AND e.id_persona IN (
    SELECT id_entrenador 
    FROM jugador 
    WHERE altura < 180
);



--4) ¿Cuál es la cantidad de acciones reaqlizadas por un jugador  en un partido específico?


SELECT COUNT(*) AS cantidad_acciones
FROM acciones_del_partido
WHERE id_partido = 1 and id_jugador=3;


--5) ¿Cuáles son los partidos que se den en una fecha y del estado del partido finalizado?


SELECT *
FROM partido
WHERE fecha_final = '2023-06-17' AND id_estado_del_partido =3;



--6)¿Cuáles son los partidos en los que se han producido lesiones, incluyendo el tipo de lesión y el jugador afectado?

SELECT pa.id_partido,CONCAT(p.nombres, ' ', p.apellidos) AS jugador_afectado, l.descripcion AS tipo_lesion, adp.tiempo_accion
FROM partido pa
JOIN acciones_del_partido adp ON pa.id_partido = adp.id_partido
JOIN jugador j ON adp.id_jugador = j.id_persona
JOIN persona p ON j.id_persona = p.id_persona
JOIN lesiones l ON adp.id_acciones = l.id_acciones;



--7) ¿Cuál es la cantidad de jugadores por cada nacionalidad?


SELECT pais.nombre AS nacionalidad, COUNT(*) AS cantidad_jugadores
FROM jugador j
JOIN persona p ON j.id_persona = p.id_persona
JOIN pais ON p.nacionalidad = pais.id_pais
GROUP BY pais.nombre;



--8) ¿Qué jugadores tienen nacionalidad española?


SELECT *
FROM jugador j
JOIN persona p ON j.id_persona = p.id_persona
JOIN pais pa ON p.nacionalidad = pa.id_pais
WHERE pa.nombre = 'España';


--9) ¿Cuáles son los nombres de los jugadores y el número total de partidos en los que han participado?


SELECT p.nombres, p.apellidos, COUNT(*) AS total_partidos
FROM jugador j
JOIN persona p ON j.id_persona = p.id_persona
JOIN acciones_del_partido adp ON j.id_persona = adp.id_jugador
GROUP BY p.nombres, p.apellidos
ORDER BY total_partidos DESC;


--10) ¿Cuál es la cantidad de partidos jugados por cada jugador que haya jugado más de 10 partidos y tenga una altura menor a 180 cm?


SELECT j.id_persona, p.nombres, p.apellidos, COUNT(adp.id_partido) AS cantidad_partidos
FROM jugador j
JOIN persona p ON j.id_persona = p.id_persona
JOIN acciones_del_partido adp ON j.id_persona = adp.id_jugador
WHERE j.altura < 180
GROUP BY j.id_persona, p.nombres, p.apellidos
HAVING COUNT(adp.id_partido) > 10;


--11) ¿Cuál es la velocidad promedio de saque de todos los jugadores en un partido específico?


SELECT AVG(s.velocidad_saque) AS velocidad_promedio_saque
FROM servicio s
JOIN acciones_del_partido adp ON s.id_acciones = adp.id_acciones
WHERE adp.id_partido =3;



--12) ¿Cuál es el historial de lesiones de un jugador en todos los partidos en los que ha participado?


SELECT 
    p.nombres || ' ' || p.apellidos AS jugador,
    l.descripcion AS lesion,
    pa.fecha_final,
    pa.hora_final
FROM lesiones l
JOIN acciones_del_partido adp ON l.id_acciones = adp.id_acciones
JOIN partido pa ON adp.id_partido = pa.id_partido
JOIN jugador j ON adp.id_jugador = j.id_persona
JOIN persona p ON j.id_persona = p.id_persona
WHERE adp.id_jugador = 3;


--13) ¿Cuál es la cantidad de partidos que cada jugador ha jugado en una edición específica de un torneo?

SELECT p.nombres || ' ' || p.apellidos AS jugador, COUNT(pa.id_partido) AS cantidad_partidos
FROM jugador j
JOIN persona p ON j.id_persona = p.id_persona
JOIN acciones_del_partido adp ON j.id_persona = adp.id_jugador
JOIN partido pa ON adp.id_partido = pa.id_partido
WHERE pa.id_edicion = 3
GROUP BY p.nombres, p.apellidos;



--14) ¿Cuántos puntos en total obtuvo un jugador en cada set de un partido?

SELECT s.numero_de_set, SUM(p.puntuacion) AS total_puntos
FROM puntos p
JOIN juego j ON p.id_juegos = j.id_acciones
JOIN sets_ s ON j.id_set = s.id_acciones
JOIN acciones_del_partido adp ON p.id_acciones = adp.id_acciones
WHERE adp.id_jugador = 5 AND adp.id_partido = 1
GROUP BY s.numero_de_set;



/*15) ¿Cuáles son los nombres de los jugadores que han sido sancionados durante algún partido, junto con el tipo de sanción
y la fecha del partido?*/



SELECT p.nombres, p.apellidos, s.tipo_sancion, pa.fecha_final
FROM jugador j
JOIN persona p ON j.id_persona = p.id_persona
JOIN acciones_del_partido adp ON j.id_persona = adp.id_jugador
JOIN falta f ON adp.id_acciones = f.id_acciones
JOIN tipo_falta tf ON f.id_tipo_falta = tf.id_tipo_falta
JOIN sancion s ON tf.id_sancion = s.id_sancion
JOIN partido pa ON adp.id_partido = pa.id_partido;



--16) ¿Cuáles son los nombres de los jugadores junto con la cantidad total de faltas cometidas en cada partido en el que han participado?


SELECT p.nombres, p.apellidos, COUNT(f.id_acciones) AS total_faltas
FROM jugador j
JOIN persona p ON j.id_persona = p.id_persona
JOIN acciones_del_partido adp ON j.id_persona = adp.id_jugador
JOIN falta f ON adp.id_acciones = f.id_acciones
GROUP BY p.nombres, p.apellidos, adp.id_partido;





--17) ¿Cuál es la cantidad de partidos ganados por cada jugador en una edición específica?


SELECT p.nombres, p.apellidos, COUNT(pa.id_partido) AS partidos_ganados
FROM jugador j
JOIN persona p ON j.id_persona = p.id_persona
JOIN acciones_del_partido adp ON j.id_persona = adp.id_jugador
JOIN partido pa ON adp.id_partido = pa.id_partido
JOIN estado_del_partido ep ON pa.id_estado_del_partido = ep.id_estado_del_partido
WHERE ep.estado_de_juego = 'finalizado'
AND pa.id_edicion = 3
GROUP BY p.nombres, p.apellidos;




--18) ¿cuales son todos los jugadores y entrenadores del torneo?


SELECT p.nombres, p.apellidos, 'Jugador' AS tipo_persona
FROM jugador j
JOIN persona p ON j.id_persona = p.id_persona

UNION ALL

SELECT p.nombres, p.apellidos, 'Entrenador' AS tipo_persona
FROM entrenador e
JOIN persona p ON e.id_persona = p.id_persona;




--19) ¿Cuál es la cantidad total de sets ganados por cada jugador en un partido específico?


SELECT p.nombres, p.apellidos, MAX(s.puntuacion_set) AS total_sets_ganados
FROM  jugador j
JOIN persona p ON j.id_persona = p.id_persona
JOIN acciones_del_partido adp ON j.id_persona = adp.id_jugador
LEFT JOIN sets_ s ON adp.id_acciones = s.id_acciones
WHERE adp.id_partido = 4
GROUP BY p.nombres, p.apellidos;



--20) ¿Cuál es la cantidad total de juegos ganados por cada jugador en un partido específico?

SELECT p.nombres, p.apellidos, COUNT(jg.numero_juego) AS total_juegos_ganados
FROM jugador j
JOIN persona p ON j.id_persona = p.id_persona
JOIN acciones_del_partido adp ON j.id_persona = adp.id_jugador
LEFT JOIN juego jg ON adp.id_acciones = jg.id_acciones
WHERE adp.id_partido = 5
GROUP BY p.nombres, p.apellidos;

/*21)¿cuale es el ranking de los jugador basado en su altura,
ordendos de manera descendente.*/

SELECT
    j.id_persona,
    p.nombres,
    p.apellidos,
    j.altura,
    RANK() OVER (ORDER BY altura DESC) AS ranking_altura
FROM
    persona p
JOIN
    jugador j ON p.id_persona = j.id_persona;
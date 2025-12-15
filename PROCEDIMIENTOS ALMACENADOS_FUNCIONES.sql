CREATE OR REPLACE PROCEDURE  insertar_prendas_patrocinadas(
	--datos prendas_patrocinadas 
	nombre_patrocinador varchar(100),
	jugador_id integer,
	prenda_tipo varchar(50)	
)
Language plpgsql
as $$
declare
	patrocindor_id integer;
	prenda_id integer; 
BEGIN 

	-- VERIFICA SI EL PATROCINADOR EXISTE 
	SELECT id_patrocinador INTO patrocindor_id
	FROM patrocinador
	WHERE nombre = nombre_patrocinador;
	
	if patrocindor_id is NULL then 
		INSERT INTO patrocinador (nombre)
		values (nombre_patrocinador)
		RETURNING id_patrocinador INTO patrocindor_id;
	END IF;
	
	-- VERIFICA SI LA PRENDA EXISTE Y OBTENER ID DE LA PRENDA 
	SELECT id_tipo_prendas INTO prenda_id
	FROM tipo_prendas 
	WHERE nombre = prenda_tipo;
	
	IF prenda_id IS NULL THEN 
		INSERT INTO tipo_prendas (nombre)
		values (prenda_tipo)
		RETURNING id_tipo_prendas INTO prenda_id;
	END IF;
	
	Insert into contrato (id_jugador, id_patrocinador)
	values (jugador_id, patrocindor_id);
	
	INSERT INTO prendas_patrocinadas (id_patrocinador, id_jugador, id_tipo_prenda)
	values (patrocindor_id, jugador_id, prenda_id);
END;	
$$;



-- insertar jugador y entrenador 
create or replace PROCEDURE Insertar_jugador(
	-- datos del jugador 
	altura_ numeric(15,2),
	fecha_retiro_ date,
	fecha_debut_ date,
	peso_actual_ numeric(15,2),
	
	fecha_nacimiento_ DATE,
    nombres_ VARCHAR(100),
    apellidos_ VARCHAR(100),
    nombre_pais_ VARCHAR(100),
    tipo_documento_identidad_ char(100),
    numero_identificacion_ INTEGER,
	
	-- datos entrenador 
	numero_licencia_ integer,
	genero_ varchar(100),
	
	 _p_fecha_nacimiento DATE,
     _p_nombres VARCHAR(100),
     _p_apellidos VARCHAR(100),
     _p_nombre_pais VARCHAR(100),
     _p_id_tipo_documento_identidad varchar(100),
     _p_numero_identificacion INTEGER
	
)
Language plpgsql
as $$
declare
entrenador_id INTEGER;
jugador_id INTEGER;
BEGIN

	--Verifica si el entrenador existe
	SELECT id_persona into entrenador_id
	FROM entrenador 
	WHERE numero_licencia = numero_licencia_;
	
	IF entrenador_id IS NULL THEN
	CALL insertar_entrenador(_p_fecha_nacimiento, _p_nombres,  _p_apellidos,  _p_nombre_pais,  _p_id_tipo_documento_identidad, _p_numero_identificacion,numero_licencia_, genero_ );
	end if;
	
	SELECT id_persona into entrenador_id
	FROM entrenador 
	WHERE numero_licencia = numero_licencia_;
	
	-- verifca si la persona existe 
	select id_persona into jugador_id
	from persona 
	where numero_identificacion = numero_identificacion_;
	
	if jugador_id is NULL THEN 
		CALL insertar_persona(fecha_nacimiento_, nombres_, apellidos_, nombre_pais_, tipo_documento_identidad_, numero_identificacion_);
	end if;
	
	-- obtener id de la nueva persona 
		select id_persona into jugador_id
		from persona 
		where numero_identificacion = numero_identificacion_;
		
	--insertar jugador
		insert into jugador (id_persona,id_entrenador,peso_actual,fecha_debut,fecha_retiro,altura)
		values(jugador_id , entrenador_id , peso_actual_ , fecha_debut_ , fecha_retiro_ , altura_);
END;	
$$;




------- procedimiento para insertar persona 

CREATE OR REPLACE PROCEDURE insertar_persona(
    p_fecha_nacimiento DATE,
    p_nombres VARCHAR(100),
    p_apellidos VARCHAR(100),
    p_nombre_pais VARCHAR(100),
    p_tipo_documento_identidad VARCHAR(100),
    p_numero_identificacion INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
	id_tipo_identificacion INTEGER;
    id_nacionalidad INTEGER;
BEGIN

	-- Verificar el tipo de documento
	SELECT id_tipo_documento_identidad INTO id_tipo_identificacion
	FROM tipo_documento_identidad
	WHERE tipodocumento = p_tipo_documento_identidad; 
	
	--si el Tipo doumento existe
	IF id_tipo_identificacion IS NOT NULL THEN 
		-- Verificar si el país existe en la tabla "pais"
		SELECT id_pais INTO id_nacionalidad
		FROM pais
		WHERE nombre = p_nombre_pais;

		-- Si el país no existe, insertarlo en la tabla "pais"
		IF id_nacionalidad IS NULL THEN
			INSERT INTO pais (nombre)
			VALUES (p_nombre_pais)
			RETURNING id_pais INTO id_nacionalidad;
		END IF;

		-- Insertar la persona en la tabla "persona"
		INSERT INTO persona (fecha_nacimiento, nombres, apellidos, nacionalidad, id_tipo_documento_identidad, numero_identificacion)
		VALUES (p_fecha_nacimiento, p_nombres, p_apellidos,id_nacionalidad, id_tipo_identificacion, p_numero_identificacion);
	ELSE
		RAISE NOTICE 'tipo de documento invalido'; 
	END IF;
END;
$$;



  -- procedimiento para insertar entrenador 

CREATE OR REPLACE PROCEDURE insertar_entrenador(
    e_fecha_nacimiento DATE,
    e_nombres VARCHAR(100),
    e_apellidos VARCHAR(100),
    e_nombre_pais VARCHAR(100),
    e_id_tipo_documento_identidad VARCHAR(100),
	e_numero_identificacion INTEGER,
	e_numero_licencia INTEGER,
	e_genero VARCHAR(200)
)
LANGUAGE plpgsql
AS $$
DECLARE
    genero_id INTEGER;
	persona_id INTEGER;
BEGIN

	
	
    -- Verificar el género
    SELECT id_tipo_genero INTO genero_id 
    FROM genero
    WHERE tipogenero = e_genero;

    IF genero_id IS NOT NULL THEN
		--verificar si la persona existe
		SELECT id_persona INTO persona_id
		FROM persona
		WHERE numero_identificacion = e_numero_identificacion;
		IF persona_id IS NULL THEN
			CALL insertar_persona(e_fecha_nacimiento,e_nombres,e_apellidos,e_nombre_pais,e_id_tipo_documento_identidad,e_numero_identificacion);
			-- obtenemos el id 
			SELECT id_persona INTO persona_id
			FROM persona
			WHERE numero_identificacion = e_numero_identificacion;
		END IF;
		--insertamos entrenador 
		INSERT INTO entrenador (id_persona, numero_licencia, id_genero)
		VALUES (persona_id, e_numero_licencia , genero_id);
	ELSE
		RAISE NOTICE 'género invalido'; 
	END IF;
		
END;
$$;




--insertar arbitro 

CREATE OR REPLACE PROCEDURE insertar_arbitro(
    a_fecha_nacimiento DATE,
    a_nombres VARCHAR(100),
    a_apellidos VARCHAR(100),
    a_nombre_pais VARCHAR(100),
    a_id_tipo_documento_identidad VARCHAR(100),
	a_numero_identificacion INTEGER,
	anios_de_experiencia INTEGER,
	certificacionn varchar(100)
)
LANGUAGE plpgsql
AS $$
DECLARE
	persona_id INTEGER;
	certificacion_id integer;
BEGIN

	-- se obtiene el id de la sertificacion y verificamos si existe o no 
	SELECT id_certificacion INTO certificacion_id
	FROM certificacion 
	WHERE tipo_certificacion = certificacionn;
	--verificamos y retornamos id 
	IF certificacion_id IS NULL THEN 
		INSERT INTO certificacion (tipo_certificacion)
		VALUES (certificacionn)
		RETURNING id_certificacion into certificacion_id;
	end if;
	
	-- se obtiene el id de la persona para verificar si existe 
	SELECT id_persona INTO persona_id
	FROM persona
	WHERE numero_identificacion = a_numero_identificacion;
	--verificamos 
	IF persona_id IS NULL THEN
		CALL insertar_persona(a_fecha_nacimiento,a_nombres,a_apellidos,a_nombre_pais,a_id_tipo_documento_identidad,a_numero_identificacion);
		SELECT id_persona INTO persona_id
		FROM persona
		WHERE numero_identificacion = a_numero_identificacion;
	END IF;
	-- insertamos arbitro 
		INSERT INTO arbitro_principal(id_persona,anios_experiencia, id_certificacion)
		VALUES (persona_id, anios_de_experiencia, certificacion_id);
	
END;
$$;



-- procedimiento para insertar partido 

CREATE OR REPLACE PROCEDURE insertar_partidos(
    etapa_del_torneo VARCHAR(100),
    anio_edicion INTEGER,
    organizador_edicion VARCHAR(100),
    fecha_final DATE,
    hora_final TIME,
    estado_partido VARCHAR(100),
	
	--datos de los jugador1 y de su entrenador 
	-- datos del jugador 
	_altura numeric(15,2),
	_fecha_retiro date,
	_fecha_debut date,
	_peso_actual numeric(15,2),
	_fecha_nacimiento DATE,
    _nombres VARCHAR(100),
    _apellidos VARCHAR(100),
    _nombre_pais VARCHAR(100),
    _tipo_documento_identidad char(100),
    _numero_identificacion INTEGER,
	-- datos entrenador del jugador 1
	 _numero_licenciaE integer,
	 _generoE varchar(100),
	 _fecha_nacimientoE DATE,
     _nombresE VARCHAR(100),
     _apellidosE VARCHAR(100),
     _nombre_paisE VARCHAR(100),
     _tipo_documento_identidadE varchar(100),
     _numero_identificacionE INTEGER,
	
	-- datos jugador 2 y su entrenador 
	--jugador 2
	_altura2 numeric(15,2),
	_fecha_retiro2 date,
	_fecha_debut2 date,
	_peso_actual2 numeric(15,2),
	_fecha_nacimiento2 DATE,
    _nombres2 VARCHAR(100),
    _apellidos2 VARCHAR(100),
    _nombre_pais2 VARCHAR(100),
    _tipo_documento_identidad2 char(100),
    _numero_identificacion2 INTEGER,
	--entrenador del jugador 2
     _numero_licencia2E integer,
	 _genero2E varchar(100),
	 _fecha_nacimiento2E DATE,
     _nombres2E VARCHAR(100),
     _apellidos2E VARCHAR(100),
     _nombre_pais2E VARCHAR(100),
     _tipo_documento_identidad2E varchar(100),
     _numero_identificacion2E INTEGER,
	
	--datos del arbitro---
	a_fecha_nacimiento_ DATE,
    a_nombres_ VARCHAR(100),
    a_apellidos_ VARCHAR(100),
    a_nombre_pais_ VARCHAR(100),
    a_id_tipo_documento_identidad_ VARCHAR(100),
	a_numero_identificacion_ INTEGER,
	anios_de_experiencia_ INTEGER,
	certificacionA_ varchar(100)
	
)
LANGUAGE 'plpgsql'
AS $$
DECLARE
    edicion_id INTEGER;
	partido_id INTEGER;
    etapa_torneo_id INTEGER;
    estado_del_partido_id INTEGER;
	jugador1_id INTEGER;
	jugador2_id INTEGER;
	arbitro_id  INTEGER;
	
BEGIN

	--verificar si el arbitro existe 
	select id_persona into arbitro_id
	from persona 
	where numero_identificacion =  a_numero_identificacion_;
	--si no existe el arbitro se inserta el jugador_persona y el entrenador 
	if arbitro_id is NULL then 
		CALL insertar_arbitro(a_fecha_nacimiento_, a_nombres_, a_apellidos_, a_nombre_pais_, a_id_tipo_documento_identidad_, a_numero_identificacion_, anios_de_experiencia_, certificacionA_);
	-- hacemos nuevamente la consulta para obtener el id del arbitro 
		select id_persona into arbitro_id
		from persona 
		where numero_identificacion =  a_numero_identificacion_;
	end if;

	--verificamos si el jugador 1 existe 
	select id_persona into jugador1_id
	from persona 
	where numero_identificacion =  _numero_identificacion;
	--si no existe el jugador se inserta el jugador_persona y el entrenador 
	if jugador1_id is NULL then 
		CALL insertar_jugador(_altura, _fecha_retiro, _fecha_debut, _peso_actual, _fecha_nacimiento, _nombres, _apellidos, _nombre_pais, _tipo_documento_identidad, _numero_identificacion, _numero_licenciaE, _generoE, _fecha_nacimientoE, _nombresE, _apellidosE, _nombre_paisE, _tipo_documento_identidadE, _numero_identificacionE);
		-- hacemos nuevamente la consulta para obtener el id del jugador 
		select id_persona into jugador1_id
		from persona 
		where numero_identificacion =  _numero_identificacion;
	end if;
	
	--verificamos si el jugador 2 existe 
	select id_persona into jugador2_id
	from persona 
	where numero_identificacion =  _numero_identificacion2;
	--si no existe el jugador se inserta el jugador_persona y el entrenador 
	if jugador2_id is NULL then 
		CALL insertar_jugador(_altura2, _fecha_retiro2, _fecha_debut2, _peso_actual2, _fecha_nacimiento2, _nombres2, _apellidos2, _nombre_pais2, _tipo_documento_identidad2, _numero_identificacion2, _numero_licencia2E, _genero2E, _fecha_nacimiento2E, _nombres2E, _apellidos2E, _nombre_pais2E, _tipo_documento_identidad2E, _numero_identificacion2E);
		-- hacemos nuevamente la consulta para obtener el id del jugador 
		select id_persona into jugador2_id
		from persona 
		where numero_identificacion =  _numero_identificacion2;
	END IF;
	
    -- Verificar si la edición existe, si no, insertar y obtener su ID
    SELECT id_edicion INTO edicion_id 
    FROM edicion 
    WHERE año_de_edicion = anio_edicion;
    
    IF edicion_id IS NULL THEN
        INSERT INTO edicion (id_torneo, organizador, año_de_edicion) 
        VALUES (1, organizador_edicion, anio_edicion) 
        RETURNING id_edicion INTO edicion_id;
    END IF;

    -- Verificar si la etapa del torneo existe, si no, insertar y obtener su ID
    SELECT id_etapas_del_torneo INTO etapa_torneo_id 
    FROM etapas_del_torneo 
    WHERE etapa = etapa_del_torneo;
    
    IF etapa_torneo_id IS NULL THEN
        INSERT INTO etapas_del_torneo (etapa) 
        VALUES (etapa_del_torneo) 
        RETURNING id_etapas_del_torneo INTO etapa_torneo_id;
    END IF;

    -- Verificar si el estado del partido existe, si no, insertar y obtener su ID
    SELECT id_estado_del_partido INTO estado_del_partido_id 
    FROM estado_del_partido 
    WHERE estado_de_juego = estado_partido;
    
    IF estado_del_partido_id IS NULL THEN
        INSERT INTO estado_del_partido (estado_de_juego) 
        VALUES (estado_partido) 
        RETURNING id_estado_del_partido INTO estado_del_partido_id;
    END IF;

    -- Insertar el partido con los IDs obtenidos
    INSERT INTO Partido (id_arbitro_principal, id_etapas_del_torneo, id_edicion, fecha_final,
        hora_final, id_estado_del_partido, id_jugador1, id_jugador2)
    VALUES (arbitro_id, etapa_torneo_id, edicion_id,fecha_final,hora_final, estado_del_partido_id,
			jugador1_id,jugador2_id) RETURNING id_partido INTO partido_id;
			
	CALL gestionar_partido(partido_id, jugador1_id, jugador2_id );
	CALL __insertar_accion__(jugador1_id,partido_id);
	CALL __insertar_accion__(jugador2_id,partido_id);
	

END;
$$;



-- insertar falta, tipo falta y sanciones
create or replace procedure Insertar_falta(
	acciones_id integer,
	--datos tipo falta
	descripcion_falta varchar(500),
	--datos sancion
	sancion_tipo varchar(200)
)

language plpgsql
as $$
declare
tipo_falta_id integer;
sancion_id integer;
begin

	--obtenems el id de  la sancion
	select id_sancion into sancion_id
	from sancion
	where tipo_sancion = sancion_tipo;
	
	--verificamos si la sancion existe
	IF sancion_id is NUll then
	insert into sancion (tipo_sancion)
	values (sancion_tipo)
	returning id_sancion into sancion_id;
	end if;
	
	
	--verificamos si el tipo de falta 
	select id_tipo_falta into tipo_falta_id
	from tipo_falta
	where descripcion = descripcion_falta;
	
	--verificamos si el tipo de falta existe
	if tipo_falta_id is null then 
	insert into tipo_falta(descripcion, id_sancion)
	values (descripcion_falta, sancion_id)
	returning id_tipo_falta into tipo_falta_id;
	end if;
	
	
	
	insert into falta(id_acciones,id_tipo_falta)
	values (acciones_id, tipo_falta_id);

end;
$$;


--insertar  lesion
create or replace procedure insertar_lesion(
	id_accion_partido integer,
	--datos lesion
	descripcion_lesion varchar(100)
)
language plpgsql
as $$
begin
	insert into lesiones(id_acciones,descripcion)
	values (id_accion_partido, descripcion_lesion);
end;
$$;




-- insertar efectos del servicio
create or replace procedure insertar_efectos_del_servicio(
	--para la tabla resultado del servicio 
	Resultado_servicio char(100),
	id_servicio_ integer,
	-- parametros en caso de que sea punto
	id_partido_ integer,
	id_jugador_ integer,
	-- parametros en caso de que sea falta 
	descripcion_falta varchar(500),
	--tiempo de la accion 
	tiempo_accion_ time

)
language plpgsql

as $$
declare
_id_resultado_del_servicio integer;
id_falta_ integer;
id_tipo_falta_ integer;
-- en caso de que el resultado sea ace punto o falta se añade una nueva accion porque se genera un punto 
id_nueva_accion integer;


begin
	--en caso de que sea un resultado cualquiera ace, let, falta ... 
	select id_resultado_servicio into _id_resultado_del_servicio
	from Resultado_del_servicio
	where tipo_resultado=Resultado_servicio;
	--verificamos si el tipo de resultado existe 
	if _id_resultado_del_servicio is null then 
		insert into resultado_del_servicio (tipo_resultado)
		values (Resultado_servicio)
		returning id_resultado_servicio into _id_resultado_del_servicio;
	end if;
	-- si es un ace y anota punto o si es falta, se crea una nueva accion 
	if (Resultado_servicio = 'ace')  OR (Resultado_servicio = 'falta')  then 
		insert into acciones_del_partido (id_jugador, id_partido, tiempo_accion)
		 values (id_jugador_, id_partido_, tiempo_accion_)
		 returning id_acciones into id_nueva_accion;
		 
		 	-- en el caso de que el resultado del servicio sea una falta 
			-- obtenemos el id del tipo de falta cometida 
			select id_tipo_falta into id_tipo_falta_
			from tipo_falta 
			where descripcion = descripcion_falta;
			-- si el tipo de falta no existe se inserta la nueva falta 
			-- se inserta la falta en la tabla falta
			insert into falta(id_acciones, id_tipo_falta)
			values (id_nueva_accion, id_tipo_falta_);
	end if;
	--por ultimo insertamos el efecto del servicio 
insert into efectos_del_servicio (id_resultado_servicio, id_servicio)
values (_id_resultado_del_servicio, id_servicio_);
end;
$$;


create or replace procedure insertar_servicio(
	--para llamar a insertar efectos del servicio 
	_Resultado_servicio varchar(100), --ace, let ...
	_id_partido_ integer, --
	_id_jugador_ integer, --
	_descripcion_falta varchar(500), -- hacer ramdom 
	_tiempo_accion_ time, --por parametro
	-- id de la accion del partido
	_id_accion integer,-- 
	velocidad_saque_ numeric(15,2) --por parametro 
	-- parametros en caso de que sea punto 

)
language plpgsql
as $$
begin 
	insert into servicio(id_acciones, velocidad_saque)
	values (_id_accion, velocidad_saque_);
	call insertar_efectos_del_servicio(_Resultado_servicio, _id_accion, _id_partido_, _id_jugador_, _descripcion_falta, _tiempo_accion_);
end;
$$;



CREATE OR REPLACE PROCEDURE insertar_puntos(
	accion_id INTEGER,
    p_id_partido INTEGER,
    p_id_jugador INTEGER,
	p_numero_punto INTEGER,
	p_tiempo_accion time with time zone
)
AS $$
DECLARE
    v_accion_id INTEGER;
    v_juego_id INTEGER;
    v_set_id INTEGER;
    v_puntuacion_j1 INTEGER;
    v_puntuacion_j2 INTEGER;
	v_puntuacion_S1 INTEGER;
    v_puntuacion_S2 INTEGER;
    v_numero_juego INTEGER;
    v_numero_set INTEGER;
    v_ganador_juego INTEGER;
	v_puntuacion_juego INTEGER;
    v_ganador_set INTEGER;
	v_puntuacion_set INTEGER;
    v_ganador_partido INTEGER;
    v_id_jugador1 INTEGER;
    v_id_jugador2 INTEGER;
	id_contrincante INTEGER;
	v_puntuacion_G INTEGER;
	p_puntuacion INTEGER;
BEGIN
 
IF (SELECT estado_de_juego FROM estado_del_partido
	WHERE id_estado_del_partido = (SELECT id_estado_del_partido
								 FROM partido WHERE id_partido = p_id_partido )) = 'finalizado' THEN
	raise notice '¡ERROR! PARTIDO TERMINADO';
	ELSE
		CASE p_numero_punto
		WHEN 1 THEN p_puntuacion := 15;
		WHEN 2 THEN p_puntuacion := 30;
		WHEN 3 THEN p_puntuacion := 40;
		WHEN 4 THEN p_puntuacion := 0;
	END CASE;
		v_puntuacion_juego:=0;
		v_puntuacion_set :=0;
		-- Obtener los ID de los jugadores en el partido
		SELECT id_jugador1, id_jugador2 INTO v_id_jugador1, v_id_jugador2
		FROM partido
		WHERE id_partido = p_id_partido;
 
		-- Buscar el contrincante
		IF (v_id_jugador1 != p_id_jugador) THEN
			id_contrincante := v_id_jugador1;
		ELSE
			id_contrincante := v_id_jugador2;
		END IF;
 
		-- Obtener el último set del partido actual
		SELECT s.id_acciones, s.numero_de_set
		INTO v_set_id, v_numero_set
		FROM sets_ s
		JOIN acciones_del_partido a ON s.id_acciones = a.id_acciones
		WHERE a.id_partido = p_id_partido
		ORDER BY s.numero_de_set DESC
		LIMIT 1;
 
		-- Si no hay sets, insertar el primer set
		IF v_set_id IS NULL THEN
			-- Crear una nueva acción para el nuevo set
			INSERT INTO acciones_del_partido (id_jugador, id_partido, tiempo_accion)
			VALUES (p_id_jugador, p_id_partido, p_tiempo_accion)
			RETURNING id_acciones INTO v_accion_id;
 
			INSERT INTO sets_ (id_acciones, numero_de_set, puntuacion_set)
			VALUES (v_accion_id, 1, 0)
			RETURNING id_acciones INTO v_set_id;
			v_numero_set := 1;
		END IF;
 
		-- Obtener el último juego del set actual
		SELECT j.id_acciones, j.numero_juego
		INTO v_juego_id, v_numero_juego
		FROM juego j
		WHERE j.id_set = v_set_id
		ORDER BY j.numero_juego DESC
		LIMIT 1;
 
		-- Si no hay juegos, insertar el primer juego
		IF NOT FOUND THEN
			-- Crear una nueva acción para el nuevo juego
			INSERT INTO acciones_del_partido (id_jugador, id_partido, tiempo_accion)
			VALUES (p_id_jugador, p_id_partido, p_tiempo_accion)
			RETURNING id_acciones INTO v_accion_id;
 
			INSERT INTO juego (id_acciones, id_set, numero_juego, puntuacion_game)
			VALUES (v_accion_id, v_set_id, 1, 0)
			RETURNING id_acciones INTO v_juego_id;
			v_numero_juego := 1;
		END IF;
 
		-- Insertar puntos
		INSERT INTO puntos (id_acciones, id_juegos, numero_punto, puntuacion)
		VALUES (accion_id, v_juego_id,p_numero_punto, p_puntuacion);
 
		-- obtienelos ultimos numeros de puntos	
 
		SELECT MAX(CASE WHEN a.id_jugador = p_id_jugador THEN p.numero_punto ELSE 0 END), 
			   MAX(CASE WHEN a.id_jugador = id_contrincante THEN p.numero_punto ELSE 0 END)
		INTO v_puntuacion_j1, v_puntuacion_j2
		FROM puntos p
		JOIN acciones_del_partido a ON p.id_acciones = a.id_acciones
		WHERE p.id_juegos = v_juego_id;
 
		-- Verificar si el juego ha terminado
		IF (v_puntuacion_j1 >= 4 AND (v_puntuacion_j1 - v_puntuacion_j2) >= 2) THEN
			-- Juego ganado por el jugador
			v_ganador_juego := p_id_jugador;
		ELSE
			v_ganador_juego := NULL;
		END IF;
 
		-- Insertar un nuevo juego si el juego actual ha terminado
		IF v_ganador_juego IS NOT NULL THEN
			-- Crear una nueva acción para el nuevo juego
			INSERT INTO acciones_del_partido (id_jugador, id_partido, tiempo_accion)
			VALUES (v_ganador_juego, p_id_partido, p_tiempo_accion)
			RETURNING id_acciones INTO v_accion_id;
 
			 -- obtienelos ultimos numeros de JUEGO
			SELECT MAX(CASE WHEN a.id_jugador = p_id_jugador THEN g.puntuacion_game ELSE 0 END), 
			   MAX(CASE WHEN a.id_jugador = id_contrincante THEN g.puntuacion_game ELSE 0 END)
				INTO v_puntuacion_S1, v_puntuacion_S2
				FROM juego g
				JOIN acciones_del_partido a ON g.id_acciones = a.id_acciones
				WHERE g.id_set = v_set_id;
 
 
			INSERT INTO juego (id_acciones, id_set, numero_juego, puntuacion_game)
			VALUES (v_accion_id, v_set_id, v_numero_juego + 1, v_puntuacion_S1+1);
 
 
				 IF v_puntuacion_S1 >= 5 AND ABS(v_puntuacion_S1 - v_puntuacion_S2) >= 2 THEN
					v_ganador_set := v_ganador_juego;
				ELSE
					v_ganador_set :=NULL;
				END IF;
 
		END IF;
 
		IF v_ganador_set IS NOT NULL THEN
			INSERT INTO acciones_del_partido (id_jugador, id_partido, tiempo_accion)
			VALUES (v_ganador_juego, p_id_partido, p_tiempo_accion)
			RETURNING id_acciones INTO v_accion_id;
 
			SELECT MAX(CASE WHEN a.id_jugador = p_id_jugador THEN c.puntuacion_set ELSE 0 END)
				INTO v_puntuacion_G 
				FROM sets_ c
				JOIN acciones_del_partido a ON c.id_acciones = a.id_acciones;
 
			INSERT INTO sets_ (id_acciones, numero_de_set, puntuacion_set)
			VALUES (v_accion_id, v_numero_set + 1,v_puntuacion_G +1 )
			RETURNING id_acciones INTO v_set_id;
 
				 IF v_puntuacion_G >= 2 THEN
				-- Partido ganado, actualizar el estado del partido
					UPDATE partido
					SET id_estado_del_partido = (
						SELECT id_estado_del_partido
						FROM estado_del_partido
						WHERE estado_de_juego = 'finalizado')
					WHERE id_partido = p_id_partido;
 
				END IF;
 
		END IF;
END IF;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION generar_letras_aleatorias(longitud INTEGER)
RETURNS VARCHAR AS $$
DECLARE
    resultado VARCHAR := '';
    i INTEGER;
    letra CHAR;
BEGIN
    FOR i IN 1..longitud LOOP
        letra := chr(97 + floor(random() * 26)::INTEGER);  -- Genera letras minúsculas 'a' a 'z'
        resultado := resultado || letra;
    END LOOP;
    RETURN resultado;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION palabra_aleatoria()
RETURNS VARCHAR AS $$
DECLARE
    opciones TEXT[] := ARRAY['lesion', 'falta', 'servicio'];
    resultado TEXT;
BEGIN
    resultado := opciones[ceil(random() * array_length(opciones, 1))];
    RETURN resultado;
END;
$$ LANGUAGE plpgsql;


--procedimiento para insertar accion del partido datos aleatorios 
create procedure __insertar_accion__(
	_id_jugador integer,
	_id_partido integer
	
)
language plpgsql
as $$
declare
_tipo_accion varchar(100); -- puede ser 'falta' o 'punto' o 'lesion' o 'servicio' 
 _id_accion integer;--
 --parametros para falta 
 id_tipo_falta_ integer;
 descripcion_falta_ varchar(100);
 tipo_sancion_ varchar(100);
 _id_sancion integer;
 -- para llama a insertar servicio 
 id_resultado_servicio_ integer;
 resultado_servicio_ varchar(100);
 velocidad_saque numeric(15,2);
_tiempo_accion time;
descripcion_lesion_ varchar(20);
 begin
 
 
 _tipo_accion :=palabra_aleatoria(); -- genera una accion aleatoria 
 _tiempo_accion:= current_time; -- el atual del pc
 --inserto la accion y retorno el id
 insert into acciones_del_partido (id_jugador, id_partido, tiempo_accion)
 values(_id_jugador, _id_partido, _tiempo_accion)
 returning id_acciones into _id_accion;
 
 
 -- inserto la lesion si es lesion 
 if _tipo_accion = 'lesion' then 
   		descripcion_lesion_ = generar_letras_aleatorias(20);
		--si hay lesion cambia el estado del partido 
		update partido 
		set id_estado_del_partido = 3
		where id_partido = _id_partido;
 	call insertar_lesion(_id_accion, descripcion_lesion_);
 end if;
 
 
 -- insertar falta si es falta 
 if _tipo_accion = 'falta' then
 	 id_tipo_falta_ := floor(1 + random() * 15)::integer;
	--obtenemos la descripcion de la falta 
	select descripcion, id_sancion into descripcion_falta_, _id_sancion
	from tipo_falta 
	where id_tipo_falta = id_tipo_falta_;
	-- obtenemos el tipo de sancion con el id sancion 
	select tipo_sancion into tipo_sancion_ 
	from sancion 
	where id_sancion = _id_sancion;
	--insertamos falta 
 	call Insertar_falta(_id_accion, descripcion_falta_, tipo_sancion_);
 end if;
 
 
 -- insertar  servicio 
 	if _tipo_accion = 'servicio' then 
		-- id resultado del servicio aleatorio 
	 	 id_resultado_servicio_ := floor(1 + random() * 5)::integer;
		select tipo_resultado into resultado_servicio_ 
 		from resultado_del_servicio
		where id_resultado_servicio = id_resultado_servicio_;
		
		if resultado_servicio_ ='falta'then 
			--generamos in id de falta aleatorio 
			id_tipo_falta_ := floor(1 + random() * 15)::integer;
		end if;
		--obtenemos la descripcion de la falta 
		select descripcion into descripcion_falta_
		from tipo_falta 
		where id_tipo_falta = id_tipo_falta_;
	
		velocidad_saque  := floor(10 + random() * 41)::integer;
		call insertar_servicio(resultado_servicio_, _id_partido,  _id_jugador, descripcion_falta_, _tiempo_accion, _id_accion, velocidad_saque);
	end if;
	
	
	

 end;
$$;

CREATE OR REPLACE PROCEDURE insertar__accion(
	p_id_partido INTEGER,
    p_id_jugador INTEGER,
	p_numero_punto INTEGER,
	tipo_acccion VARCHAR(100),
	tiempo_accion time with time zone
)
AS $$
DECLARE
    accion_id INTEGER;
BEGIN

	IF tipo_acccion ='punto' THEN
		INSERT INTO acciones_del_partido (id_jugador, id_partido, tiempo_accion)
		VALUES (p_id_jugador, p_id_partido, CURRENT_TIME)
		RETURNING id_acciones INTO accion_id;
		CALL insertar_puntos(accion_id, p_id_partido, p_id_jugador,p_numero_punto,tiempo_accion );
	END IF;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE PROCEDURE gestionar_partido(
    p_id_partido INTEGER,
    p_id_jugador1 INTEGER,
    p_id_jugador2 INTEGER
)
AS $$
DECLARE
    v_estado_partido varchar(100);
	v_punto INTEGER:=0;
BEGIN

    LOOP
        -- Obtener el estado actual del partido
        SELECT estado_de_juego INTO v_estado_partido
        FROM estado_del_partido
        WHERE id_estado_del_partido = (SELECT id_estado_del_partido FROM partido WHERE id_partido = p_id_partido);
 
        -- Salir del ciclo si el partido ha finalizado
        IF v_estado_partido = 'finalizado' THEN
            EXIT;
        END IF;
		CALL insertar__accion(p_id_partido,  p_id_jugador1,1,'punto',CURRENT_TIME);  -- Jugador 1 gana el primer punto,
		CALL insertar__accion(p_id_partido,  p_id_jugador2, 1 , 'punto',CURRENT_TIME);  -- Jugador 2 gana el primer punto
		CALL insertar__accion(p_id_partido,  p_id_jugador1,2,'punto',CURRENT_TIME);  -- Jugador 1 gana el segundo punto  
		CALL insertar__accion(p_id_partido,  p_id_jugador1,3,'punto',CURRENT_TIME); -- Jugador 1 gana el tercer punto
		CALL insertar__accion(p_id_partido,  p_id_jugador1,4,'punto', CURRENT_TIME);	
	
		v_punto:=+1;
		IF v_punto > 1000 THEN
            RAISE NOTICE 'Se alcanzó el límite de 1000 puntos sin finalizar el partido.';
            EXIT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


--funcion para obtener el peso promedio
CREATE OR REPLACE FUNCTION obtener_peso_promedio_jugadores()
RETURNS NUMERIC AS $$
DECLARE
    peso_promedio NUMERIC;
BEGIN
    SELECT AVG(peso_actual) INTO peso_promedio
    FROM jugador;
    
    RETURN peso_promedio;
END;
$$ LANGUAGE plpgsql;

--SELECT obtener_peso_promedio_jugadores();

CREATE OR REPLACE FUNCTION obtener_peso_promedio_por_nacionalidad()
RETURNS TABLE (
    id_persona INTEGER,
    nombres VARCHAR,
    apellidos VARCHAR,
    nacionalidad VARCHAR,
    peso_actual NUMERIC,
    altura NUMERIC,
    peso_promedio_nacionalidad NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id_persona,
        p.nombres,
        p.apellidos,
        pa.nombre AS nacionalidad,
        j.peso_actual,
        j.altura,
        AVG(j.peso_actual) OVER (PARTITION BY p.nacionalidad) AS peso_promedio_nacionalidad
    FROM 
        persona p
    JOIN 
        jugador j ON p.id_persona = j.id_persona
    JOIN 
        pais pa ON p.nacionalidad = pa.id_pais;
END;
$$ LANGUAGE plpgsql;



--SELECT * FROM obtener_peso_promedio_por_nacionalidad();


CALL insertar_partidos('Octavos de Final', 2024, 'Federación Internacional de Tenis', '2024-06-15', '14:45:00', 'por jugar', 183.4, NULL, '2016-08-18', 78.3, '1993-01-19', 'Thomas', 'Williams', 'Argentina', 'cedula de ciudadania', 77789456, 98555547, 'Masculino', '1987-11-22', 'Kevin', 'Brown', 'Argentina', 'visa', 99884477, 180.2, NULL, '2017-09-20', 76.4, '1991-03-18', 'Brian', 'Davis', 'Brasil', 'pasaporte', 11334455, 6744452, 'Masculino', '1985-05-21', 'William', 'Miller', 'Brasil', 'pasaporte', 33444455, '1984-06-19', 'Sophia', 'Wilson', 'Argentina', 'pasaporte', 55664477, 28, 'Certificado Internacional');
 
CALL insertar_partidos('Primera Ronda', 2023, 'Federación Internacional de Tenis', '2023-06-16', '08:45:00', 'por jugar', 180.1, NULL, '2016-04-14', 76.9, '1991-11-01', 'Carlos', 'Martinez', 'España', 'visa', 223460, 18918, 'Masculino', '1985-03-13', 'Henry', 'Garcia', 'España', 'pasaporte', 334571, 178.4, NULL, '2018-02-06', 75.6, '1993-01-14', 'Joseph', 'Taylor', 'Italia', 'pasaporte', 445682, 89045, 'Masculino', '1986-08-26', 'James', 'Smith', 'Italia', 'cedula de ciudadania', 556783, '1982-04-19', 'Sophia', 'Jones', 'España', 'pasaporte', 667894, 24, 'Certificado Nacional');
 
CALL insertar_partidos('Segunda Ronda', 2023, 'Federación Internacional de Tenis', '2023-06-16', '09:45:00', 'por jugar', 186.1, NULL, '2015-05-26', 79.2, '1992-05-21', 'Jacob', 'Taylor', 'Australia', 'visa', 323461, 28918, 'Masculino', '1980-12-18', 'Lucas', 'Martinez', 'Australia', 'pasaporte', 434572, 180.6, NULL, '2017-09-30', 77.3, '1991-09-15', 'James', 'Smith', 'Canadá', 'pasaporte', 545683, 89046, 'Masculino', '1983-10-20', 'David', 'Taylor', 'Canadá', 'cedula de ciudadania', 656784, '1984-11-25', 'Ava', 'Martinez', 'Australia', 'pasaporte', 767895, 26, 'Certificado Nacional');

CALL insertar_partidos('Tercera Ronda', 2023, 'Federación Internacional de Tenis', '2023-06-16', '16:45:00', 'por jugar', 184.8, NULL, '2016-08-21', 77.7, '1990-08-20', 'Benjamin', 'Taylor', 'Italia', 'visa', 423461, 38918, 'Masculino', '1979-07-28', 'Joseph', 'Martinez', 'Italia', 'pasaporte', 534572, 182.9, NULL, '2018-06-06', 75.9, '1994-11-26', 'Lucas', 'Smith', 'Alemania', 'pasaporte', 645683, 89047, 'Masculino', '1984-03-11', 'James', 'Jones', 'Alemania', 'cedula de ciudadania', 756784, '1981-12-26', 'Lily', 'Taylor', 'Italia', 'pasaporte', 867895, 25, 'Certificado Nacional');
 
CALL insertar_partidos('Cuarta Ronda', 2023, 'Federación Internacional de Tenis', '2023-06-16', '18:30:00', 'por jugar', 181.3, NULL, '2016-04-16', 76.6, '1991-11-03', 'Joseph', 'Smith', 'Francia', 'visa', 523461, 48918, 'Masculino', '1986-02-17', 'Matthew', 'Jones', 'Francia', 'pasaporte', 634572, 180.2, NULL, '2018-01-26', 75.8, '1993-04-19', 'Alexander', 'Taylor', 'Chile', 'pasaporte', 745683, 89048, 'Masculino', '1982-10-14', 'Jackson', 'Clark', 'Chile', 'cedula de ciudadania', 856784, '1984-07-11', 'Emily', 'Martinez', 'Francia', 'pasaporte', 967895, 28, 'Certificado Internacional');
 
CALL insertar_partidos('Cuartos de Final', 2023, 'Federación Internacional de Tenis', '2023-06-16', '14:30:00', 'por jugar', 187.0, NULL, '2015-09-09', 78.5, '1992-12-21', 'David', 'Jones', 'Alemania', 'visa', 623461, 58918, 'Masculino', '1975-08-22', 'Lucas', 'Taylor', 'Alemania', 'pasaporte', 734572, 181.1, NULL, '2017-11-13', 77.4, '1993-05-13', 'Benjamin', 'Smith', 'Australia', 'pasaporte', 845683, 89049, 'Masculino', '1984-12-29', 'James', 'Jones', 'Australia', 'cedula de ciudadania', 956784, '1983-11-21', 'Sophia', 'Taylor', 'Alemania', 'pasaporte', 067895, 29, 'Certificado Nacional');
 
CALL insertar_partidos('Semifinal', 2023, 'Federación Internacional de Tenis', '2023-06-16', '19:45:00', 'por jugar', 184.3, NULL, '2016-02-19', 77.1, '1991-10-11', 'Jacob', 'Martinez', 'Estados Unidos', 'visa', 723461, 68918, 'Masculino', '1980-07-23', 'Lucas', 'Jones', 'Estados Unidos', 'pasaporte', 834572, 180.3, NULL, '2018-02-27', 76.6, '1994-06-27', 'Benjamin', 'Taylor', 'Reino Unido', 'cedula de ciudadania', 945683, 89050, 'Masculino', '1981-05-21', 'David', 'Clark', 'Reino Unido', 'pasaporte', 056784, '1983-03-06', 'Lily', 'Jones', 'Estados Unidos', 'pasaporte', 167895, 28, 'Certificado Internacional');
 
CALL insertar_partidos('Final', 2023, 'Federación Internacional de Tenis', '2023-06-16', '21:30:00', 'por jugar', 186.5, NULL, '2015-09-21', 79.5, '1990-11-29', 'Daniel', 'Smith', 'Australia', 'visa', 823461, 78918, 'Masculino', '1979-05-20', 'Joseph', 'Taylor', 'Australia', 'pasaporte', 934572, 181.1, NULL, '2018-05-28', 77.2, '1993-08-11', 'James', 'Jones', 'Francia', 'pasaporte', 045683, 89051, 'Masculino', '1981-09-13', 'Matthew', 'Martinez', 'Francia', 'cedula de ciudadania', 156784, '1982-06-27', 'Lily', 'Taylor', 'Australia', 'pasaporte', 267895, 29, 'Certificado Internacional');
  
CALL insertar_partidos('Cuartos de Final', 2023, 'Federación Internacional de Tenis', '2023-06-16', '15:30:00', 'por jugar', 185.4, NULL, '2014-05-20', 78.2, '1993-02-18', 'John', 'Doe', 'Estados Unidos', 'pasaporte', 123456, 78910, 'Masculino', '1965-05-12', 'James', 'Smith', 'Estados Unidos', 'cedula de ciudadania', 234567, 182.9, '2021-11-30', '2016-08-22', 80.6, '1991-08-15', 'Robert', 'Johnson', 'Reino Unido', 'visa', 345678, 89011, 'Masculino', '1970-10-25', 'William', 'Brown', 'Reino Unido', 'pasaporte', 456789, '1978-12-30', 'Emily', 'Clark', 'Canadá', 'pasaporte', 567890, 15, 'Certificado Internacional');

CALL insertar_partidos('Semifinal', 2023, 'Federación Internacional de Tenis', '2023-06-16', '18:00:00', 'por jugar', 190.1, NULL, '2015-03-22', 85.7, '1992-07-10', 'Alex', 'Smith', 'Australia', 'visa', 223456, 88910, 'Masculino', '1975-09-15', 'Michael', 'Johnson', 'Australia', 'pasaporte', 334567, 178.3, NULL, '2017-04-20', 77.4, '1994-11-29', 'Christopher', 'Brown', 'España', 'cedula de ciudadania', 445678, 99012, 'Masculino', '1982-03-01', 'David', 'Jones', 'España', 'pasaporte', 556789, '1980-05-14', 'Isabella', 'Williams', 'Francia', 'pasaporte', 667890, 20, 'Certificado Nacional');

CALL insertar_partidos('Final', 2023, 'Federación Internacional de Tenis', '2023-06-17', '20:30:00', 'por jugar', 187.5, NULL, '2016-06-11', 79.8, '1995-01-12', 'James', 'Williams', 'Francia', 'pasaporte', 323456, 78911, 'Masculino', '1969-08-22', 'William', 'Martinez', 'Francia', 'visa', 434567, 184.2, NULL, '2018-07-08', 82.1, '1993-05-17', 'Daniel', 'Lee', 'Canadá', 'pasaporte', 545678, 89013, 'Masculino', '1978-12-11', 'Henry', 'Garcia', 'Canadá', 'cedula de ciudadania', 656789, '1974-11-28', 'Sophia', 'Martinez', 'Australia', 'pasaporte', 767890, 25, 'Certificado Internacional');

CALL insertar_partidos('Octavos de Final', 2023, 'Federación Internacional de Tenis', '2023-06-16', '13:00:00', 'por jugar', 181.7, NULL, '2014-08-15', 76.4, '1991-09-23', 'Oliver', 'Taylor', 'Italia', 'visa', 423456, 68910, 'Masculino', '1976-10-13', 'Lucas', 'Martinez', 'Italia', 'pasaporte', 534567, 183.8, '2021-09-12', '2016-11-14', 81.7, '1990-03-24', 'Liam', 'Lopez', 'Reino Unido', 'cedula de ciudadania', 645678, 89014, 'Masculino', '1971-02-05', 'Alexander', 'Wilson', 'Reino Unido', 'visa', 756789, '1975-06-23', 'Amelia', 'Gonzalez', 'Italia', 'pasaporte', 867890, 18, 'Certificado Nacional');

CALL insertar_partidos('Primera Ronda', 2023, 'Federación Internacional de Tenis', '2023-06-16', '10:00:00', 'por jugar', 186.3, NULL, '2015-11-19', 80.2, '1994-12-25', 'Ethan', 'Davis', 'Alemania', 'pasaporte', 523456, 58910, 'Masculino', '1978-05-02', 'Mason', 'Martinez', 'Alemania', 'cedula de ciudadania', 634567, 179.9, '2021-01-15', '2017-12-21', 77.9, '1992-06-16', 'Jacob', 'Anderson', 'Estados Unidos', 'visa', 745678, 89015, 'Masculino', '1985-07-30', 'Jackson', 'Moore', 'Estados Unidos', 'pasaporte', 856789, '1981-03-19', 'Mia', 'Thomas', 'Alemania', 'pasaporte', 967890, 22, 'Certificado Internacional');

CALL insertar_partidos('Segunda Ronda', 2023, 'Federación Internacional de Tenis', '2023-06-16', '11:30:00', 'por jugar', 188.6, NULL, '2016-04-18', 82.5, '1995-11-13', 'Alexander', 'Hernandez', 'Suiza', 'visa', 623456, 48910, 'Masculino', '1982-04-08', 'Sebastian', 'Martinez', 'Suiza', 'pasaporte', 734567, 186.1, NULL, '2018-03-18', 80.1, '1991-01-19', 'Benjamin', 'Martinez', 'Australia', 'cedula de ciudadania', 845678, 89016, 'Masculino', '1974-02-15', 'Matthew', 'Martinez', 'Australia', 'visa', 956789, '1980-07-12', 'Sophia', 'Martinez', 'Suiza', 'pasaporte', 067890, 24, 'Certificado Nacional');

CALL insertar_partidos('Tercera Ronda', 2023, 'Federación Internacional de Tenis', '2023-06-16', '16:45:00', 'por jugar', 180.8, NULL, '2015-08-29', 78.7, '1992-03-08', 'Elijah', 'Hernandez', 'Chile', 'pasaporte', 723456, 38910, 'Masculino', '1984-06-21', 'Joseph', 'Smith', 'Chile', 'cedula de ciudadania', 834567, 177.5, NULL, '2017-02-17', 76.5, '1993-09-14', 'James', 'Clark', 'Brasil', 'visa', 945678, 89017, 'Masculino', '1987-08-19', 'Jackson', 'Martinez', 'Brasil', 'pasaporte', 056789, '1986-01-24', 'Emma', 'Taylor', 'Chile', 'pasaporte', 167890, 26, 'Certificado Internacional');

CALL insertar_partidos('Cuarta Ronda', 2023, 'Federación Internacional de Tenis', '2023-06-16', '17:30:00', 'por jugar', 189.2, NULL, '2016-01-27', 83.9, '1994-05-22', 'Logan', 'Martinez', 'Francia', 'visa', 823456, 28910, 'Masculino', '1979-11-14', 'Lucas', 'Jones', 'Francia', 'pasaporte', 934567, 180.7, NULL, '2018-06-16', 79.4, '1990-10-26', 'Oliver', 'Brown', 'Italia', 'cedula de ciudadania', 045678, 89018, 'Masculino', '1986-12-20', 'Liam', 'Martinez', 'Italia', 'visa', 156789, '1982-04-18', 'Ava', 'Martinez', 'Francia', 'pasaporte', 267890, 28, 'Certificado Nacional');

CALL insertar_partidos('Cuartos de Final', 2023, 'Federación Internacional de Tenis', '2023-06-16', '18:45:00', 'por jugar', 182.4, NULL, '2015-10-14', 79.5, '1992-02-12', 'Mason', 'Brown', 'Reino Unido', 'pasaporte', 923456, 18910, 'Masculino', '1973-03-17', 'Daniel', 'Taylor', 'Reino Unido', 'visa', 034567, 184.6, NULL, '2017-12-19', 81.3, '1995-07-29', 'Henry', 'Wilson', 'Estados Unidos', 'cedula de ciudadania', 145678, 89019, 'Masculino', '1988-11-30', 'Matthew', 'Clark', 'Estados Unidos', 'pasaporte', 256789, '1984-09-25', 'Ella', 'Martinez', 'Reino Unido', 'pasaporte', 367890, 17, 'Certificado Internacional');

CALL insertar_partidos('Semifinal', 2023, 'Federación Internacional de Tenis', '2023-06-16', '19:30:00', 'por jugar', 188.5, NULL, '2015-07-21', 83.2, '1991-06-14', 'Lucas', 'Jones', 'Australia', 'visa', 123457, 78912, 'Masculino', '1977-04-20', 'David', 'Martinez', 'Australia', 'pasaporte', 234568, 180.9, NULL, '2017-10-24', 77.6, '1992-12-13', 'Joseph', 'Clark', 'Canadá', 'pasaporte', 345679, 89020, 'Masculino', '1989-03-10', 'Samuel', 'Smith', 'Canadá', 'cedula de ciudadania', 456780, '1983-05-27', 'Grace', 'Jones', 'Australia', 'pasaporte', 567891, 21, 'Certificado Nacional');

CALL insertar_partidos('Final', 2023, 'Federación Internacional de Tenis', '2023-06-16', '20:00:00', 'por jugar', 186.7, NULL, '2014-12-05', 81.8, '1990-10-02', 'Ethan', 'Smith', 'España', 'visa', 223457, 68912, 'Masculino', '1975-06-30', 'Matthew', 'Williams', 'España', 'pasaporte', 334568, 183.4, NULL, '2016-09-18', 79.0, '1994-08-23', 'Andrew', 'Brown', 'Francia', 'cedula de ciudadania', 445679, 89021, 'Masculino', '1980-12-01', 'David', 'Martinez', 'Francia', 'visa', 556780, '1976-07-11', 'Lily', 'Martinez', 'España', 'pasaporte', 667891, 23, 'Certificado Internacional');

CALL insertar_partidos('Octavos de Final', 2023, 'Federación Internacional de Tenis', '2023-06-16', '14:00:00', 'por jugar', 181.0, NULL, '2015-09-13', 77.3, '1993-01-14', 'Michael', 'Jones', 'Italia', 'pasaporte', 323457, 78913, 'Masculino', '1981-08-05', 'Jack', 'Taylor', 'Italia', 'visa', 434568, 178.6, NULL, '2018-01-10', 75.2, '1991-12-27', 'Alexander', 'Lopez', 'Alemania', 'cedula de ciudadania', 545679, 89022, 'Masculino', '1984-11-20', 'Liam', 'Clark', 'Alemania', 'pasaporte', 656780, '1983-03-07', 'Emily', 'Wilson', 'Italia', 'pasaporte', 767891, 19, 'Certificado Nacional');

CALL insertar_partidos('Primera Ronda', 2023, 'Federación Internacional de Tenis', '2023-06-16', '09:00:00', 'por jugar', 180.5, NULL, '2015-06-22', 76.9, '1992-11-25', 'Daniel', 'Martinez', 'Chile', 'visa', 423457, 68913, 'Masculino', '1979-10-30', 'Jackson', 'Wilson', 'Chile', 'pasaporte', 534568, 179.3, NULL, '2017-03-09', 76.1, '1994-03-18', 'James', 'Davis', 'Australia', 'cedula de ciudadania', 645679, 89023, 'Masculino', '1982-06-24', 'Benjamin', 'Martinez', 'Australia', 'visa', 756780, '1980-01-14', 'Olivia', 'Jones', 'Chile', 'pasaporte', 867891, 27, 'Certificado Internacional');

CALL insertar_partidos('Segunda Ronda', 2023, 'Federación Internacional de Tenis', '2023-06-16', '12:30:00', 'por jugar', 187.2, NULL, '2014-03-28', 80.4, '1991-08-11', 'Jacob', 'Lopez', 'Brasil', 'pasaporte', 523457, 58913, 'Masculino', '1986-09-18', 'David', 'Clark', 'Brasil', 'cedula de ciudadania', 634568, 183.1, NULL, '2018-08-21', 78.3, '1993-07-05', 'Lucas', 'Taylor', 'Francia', 'visa', 745679, 89024, 'Masculino', '1989-04-09', 'Sebastian', 'Martinez', 'Francia', 'pasaporte', 856780, '1977-05-17', 'Isabella', 'Smith', 'Brasil', 'pasaporte', 967891, 29, 'Certificado Nacional');

CALL insertar_partidos('Tercera Ronda', 2023, 'Federación Internacional de Tenis', '2023-06-16', '15:15:00', 'por jugar', 185.1, NULL, '2015-07-09', 79.7, '1992-12-30', 'Joseph', 'Martinez', 'Italia', 'cedula de ciudadania', 623457, 48913, 'Masculino', '1984-11-23', 'Henry', 'Jones', 'Italia', 'visa', 734568, 180.2, NULL, '2017-05-12', 76.9, '1991-04-03', 'James', 'Clark', 'España', 'pasaporte', 845679, 89025, 'Masculino', '1980-08-15', 'Lucas', 'Taylor', 'España', 'pasaporte', 956780, '1981-12-07', 'Emily', 'Wilson', 'Italia', 'pasaporte', 067891, 30, 'Certificado Internacional');

CALL insertar_partidos('Cuarta Ronda', 2023, 'Federación Internacional de Tenis', '2023-06-16', '18:00:00', 'por jugar', 182.8, NULL, '2016-02-22', 78.1, '1990-07-10', 'James', 'Martinez', 'Australia', 'visa', 723457, 38913, 'Masculino', '1977-06-18', 'Benjamin', 'Martinez', 'Australia', 'pasaporte', 834568, 179.4, NULL, '2018-09-26', 76.3, '1992-10-05', 'Alexander', 'Smith', 'Canadá', 'pasaporte', 945679, 89026, 'Masculino', '1983-01-20', 'David', 'Clark', 'Canadá', 'cedula de ciudadania', 056780, '1984-06-11', 'Sophia', 'Martinez', 'Australia', 'pasaporte', 167891, 24, 'Certificado Internacional');

CALL insertar_partidos('Cuartos de Final', 2023, 'Federación Internacional de Tenis', '2023-06-16', '17:00:00', 'por jugar', 187.3, NULL, '2015-04-19', 82.3, '1991-09-28', 'Henry', 'Taylor', 'Estados Unidos', 'visa', 823457, 28913, 'Masculino', '1985-10-12', 'Alexander', 'Martinez', 'Estados Unidos', 'pasaporte', 934568, 180.0, NULL, '2017-06-17', 78.4, '1993-03-02', 'James', 'Smith', 'Reino Unido', 'cedula de ciudadania', 045679, 89027, 'Masculino', '1989-05-21', 'David', 'Martinez', 'Reino Unido', 'pasaporte', 156780, '1983-11-25', 'Lily', 'Taylor', 'Estados Unidos', 'pasaporte', 267891, 27, 'Certificado Nacional');

CALL insertar_partidos('Semifinal', 2023, 'Federación Internacional de Tenis', '2023-06-16', '19:00:00', 'por jugar', 184.9, NULL, '2015-11-07', 79.6, '1990-03-24', 'Jacob', 'Smith', 'Australia', 'visa', 923457, 18913, 'Masculino', '1982-02-21', 'Lucas', 'Martinez', 'Australia', 'pasaporte', 034568, 177.2, NULL, '2018-05-13', 76.2, '1991-05-30', 'Benjamin', 'Jones', 'Francia', 'pasaporte', 145679, 89028, 'Masculino', '1980-04-17', 'Jackson', 'Taylor', 'Francia', 'cedula de ciudadania', 256780, '1981-10-28', 'Sophia', 'Martinez', 'Australia', 'pasaporte', 367891, 29, 'Certificado Internacional');

CALL insertar_partidos('Final', 2023, 'Federación Internacional de Tenis', '2023-06-16', '21:00:00', 'por jugar', 183.6, NULL, '2016-03-30', 78.5, '1993-02-18', 'Ethan', 'Martinez', 'España', 'visa', 123458, 78914, 'Masculino', '1987-04-13', 'Matthew', 'Taylor', 'España', 'pasaporte', 234569, 180.6, NULL, '2017-11-19', 77.0, '1991-07-07', 'Joseph', 'Clark', 'Italia', 'pasaporte', 345680, 89029, 'Masculino', '1986-02-23', 'Henry', 'Jones', 'Italia', 'cedula de ciudadania', 456781, '1980-08-03', 'Emma', 'Wilson', 'España', 'pasaporte', 567892, 22, 'Certificado Nacional');

CALL insertar_partidos('Octavos de Final', 2023, 'Federación Internacional de Tenis', '2023-06-16', '11:45:00', 'por jugar', 184.4, NULL, '2015-12-10', 77.8, '1994-06-12', 'James', 'Smith', 'Reino Unido', 'visa', 223458, 68914, 'Masculino', '1973-01-31', 'Liam', 'Taylor', 'Reino Unido', 'pasaporte', 334569, 182.1, NULL, '2018-08-27', 76.0, '1992-05-09', 'Joseph', 'Martinez', 'Chile', 'pasaporte', 445680, 89030, 'Masculino', '1979-12-15', 'David', 'Jones', 'Chile', 'cedula de ciudadania', 556781, '1981-03-11', 'Olivia', 'Martinez', 'Reino Unido', 'pasaporte', 667892, 23, 'Certificado Internacional');

CALL insertar_partidos('Primera Ronda', 2023, 'Federación Internacional de Tenis', '2023-06-16', '10:15:00', 'por jugar', 181.2, NULL, '2016-05-16', 79.1, '1991-07-27', 'Daniel', 'Jones', 'Australia', 'visa', 323458, 78915, 'Masculino', '1986-02-12', 'Henry', 'Martinez', 'Australia', 'pasaporte', 434569, 178.0, NULL, '2017-01-28', 76.8, '1993-11-13', 'Joseph', 'Smith', 'Canadá', 'pasaporte', 545680, 89031, 'Masculino', '1984-10-22', 'Lucas', 'Taylor', 'Canadá', 'cedula de ciudadania', 656781, '1982-05-04', 'Emily', 'Martinez', 'Australia', 'pasaporte', 767892, 25, 'Certificado Internacional');

CALL insertar_partidos('Segunda Ronda', 2023, 'Federación Internacional de Tenis', '2023-06-16', '11:00:00', 'por jugar', 183.3, NULL, '2014-07-18', 78.0, '1993-05-05', 'James', 'Smith', 'Italia', 'visa', 423458, 68915, 'Masculino', '1975-06-19', 'Jackson', 'Taylor', 'Italia', 'pasaporte', 534569, 180.4, NULL, '2016-12-14', 75.5, '1992-10-29', 'Liam', 'Martinez', 'Alemania', 'pasaporte', 645680, 89032, 'Masculino', '1977-07-16', 'David', 'Jones', 'Alemania', 'cedula de ciudadania', 756781, '1981-05-27', 'Ava', 'Martinez', 'Italia', 'pasaporte', 867892, 26, 'Certificado Internacional');

CALL insertar_partidos('Tercera Ronda', 2023, 'Federación Internacional de Tenis', '2023-06-16', '15:45:00', 'por jugar', 186.0, NULL, '2015-01-11', 79.4, '1990-12-17', 'Jacob', 'Taylor', 'España', 'visa', 523458, 58915, 'Masculino', '1980-10-31', 'Joseph', 'Smith', 'España', 'pasaporte', 634569, 183.6, NULL, '2017-07-11', 77.7, '1994-08-16', 'Benjamin', 'Martinez', 'Francia', 'pasaporte', 745680, 89033, 'Masculino', '1986-04-22', 'James', 'Jones', 'Francia', 'cedula de ciudadania', 856781, '1982-06-13', 'Lily', 'Martinez', 'España', 'pasaporte', 967892, 28, 'Certificado Internacional');

CALL insertar_partidos('Cuarta Ronda', 2023, 'Federación Internacional de Tenis', '2023-06-16', '19:45:00', 'por jugar', 184.1, NULL, '2016-06-01', 77.1, '1992-03-20', 'David', 'Smith', 'Francia', 'visa', 623458, 48915, 'Masculino', '1979-11-08', 'Matthew', 'Jones', 'Francia', 'pasaporte', 734569, 180.8, NULL, '2017-02-25', 76.5, '1991-01-31', 'Joseph', 'Taylor', 'Chile', 'pasaporte', 845680, 89034, 'Masculino', '1983-10-28', 'Jackson', 'Clark', 'Chile', 'cedula de ciudadania', 956781, '1984-02-20', 'Sophia', 'Martinez', 'Francia', 'pasaporte', 067892, 27, 'Certificado Internacional');

CALL insertar_partidos('Cuartos de Final', 2023, 'Federación Internacional de Tenis', '2023-06-16', '16:30:00', 'por jugar', 187.7, NULL, '2014-11-05', 81.4, '1993-10-14', 'Lucas', 'Jones', 'Alemania', 'visa', 723458, 38915, 'Masculino', '1974-04-16', 'Benjamin', 'Martinez', 'Alemania', 'pasaporte', 834569, 180.1, NULL, '2018-04-28', 77.2, '1991-08-22', 'Joseph', 'Smith', 'Australia', 'pasaporte', 945680, 89035, 'Masculino', '1987-12-11', 'James', 'Taylor', 'Australia', 'cedula de ciudadania', 056781, '1982-07-13', 'Olivia', 'Martinez', 'Alemania', 'pasaporte', 167892, 28, 'Certificado Nacional');

CALL insertar_partidos('Semifinal', 2023, 'Federación Internacional de Tenis', '2023-06-16', '20:30:00', 'por jugar', 182.3, NULL, '2016-01-08', 78.9, '1994-11-15', 'Daniel', 'Clark', 'Estados Unidos', 'visa', 823458, 28915, 'Masculino', '1986-01-23', 'Henry', 'Smith', 'Estados Unidos', 'pasaporte', 934569, 180.7, NULL, '2017-10-02', 77.4, '1993-09-19', 'Alexander', 'Martinez', 'Reino Unido', 'cedula de ciudadania', 045680, 89036, 'Masculino', '1980-06-05', 'David', 'Taylor', 'Reino Unido', 'pasaporte', 156781, '1983-12-10', 'Lily', 'Martinez', 'Estados Unidos', 'pasaporte', 267892, 27, 'Certificado Internacional');

CALL insertar_partidos('Final', 2023, 'Federación Internacional de Tenis', '2023-06-16', '21:30:00', 'por jugar', 186.9, NULL, '2015-10-12', 80.2, '1990-04-14', 'Jacob', 'Taylor', 'Australia', 'visa', 923458, 18915, 'Masculino', '1975-08-19', 'Lucas', 'Martinez', 'Australia', 'pasaporte', 034569, 181.3, NULL, '2018-03-15', 76.7, '1992-07-23', 'Benjamin', 'Jones', 'Francia', 'pasaporte', 145680, 89037, 'Masculino', '1981-03-01', 'Jackson', 'Taylor', 'Francia', 'cedula de ciudadania', 256781, '1983-11-22', 'Emily', 'Martinez', 'Australia', 'pasaporte', 367892, 29, 'Certificado Internacional');

CALL insertar_partidos('Octavos de Final', 2023, 'Federación Internacional de Tenis', '2023-06-16', '13:00:00', 'por jugar', 185.6, NULL, '2016-07-03', 78.4, '1993-12-05', 'James', 'Taylor', 'Chile', 'visa', 223459, 68916, 'Masculino', '1984-09-21', 'Liam', 'Smith', 'Chile', 'pasaporte', 334570, 182.5, NULL, '2018-09-12', 76.3, '1992-11-28', 'Joseph', 'Martinez', 'Australia', 'pasaporte', 445681, 89038, 'Masculino', '1978-02-26', 'David', 'Jones', 'Australia', 'cedula de ciudadania', 556782, '1982-01-19', 'Olivia', 'Smith', 'Chile', 'pasaporte', 667893, 27, 'Certificado Internacional');

CALL insertar_partidos('Primera Ronda', 2023, 'Federación Internacional de Tenis', '2023-06-16', '08:00:00', 'por jugar', 180.2, NULL, '2016-12-01', 76.7, '1991-11-01', 'Daniel', 'Martinez', 'España', 'visa', 323459, 78916, 'Masculino', '1985-03-10', 'Henry', 'Jones', 'España', 'pasaporte', 434570, 178.4, NULL, '2018-02-03', 75.9, '1993-01-11', 'Joseph', 'Taylor', 'Italia', 'pasaporte', 545681, 89039, 'Masculino', '1986-08-25', 'James', 'Smith', 'Italia', 'cedula de ciudadania', 656782, '1982-04-15', 'Sophia', 'Jones', 'España', 'pasaporte', 767893, 24, 'Certificado Nacional');

CALL insertar_partidos('Segunda Ronda', 2023, 'Federación Internacional de Tenis', '2023-06-16', '09:45:00', 'por jugar', 186.1, NULL, '2015-05-21', 79.2, '1992-05-17', 'Jacob', 'Taylor', 'Australia', 'visa', 423459, 68917, 'Masculino', '1980-12-12', 'Lucas', 'Martinez', 'Australia', 'pasaporte', 534570, 180.7, NULL, '2017-09-26', 77.1, '1991-09-09', 'James', 'Smith', 'Canadá', 'pasaporte', 645681, 89040, 'Masculino', '1983-10-15', 'David', 'Taylor', 'Canadá', 'cedula de ciudadania', 756782, '1984-11-19', 'Ava', 'Martinez', 'Australia', 'pasaporte', 867893, 26, 'Certificado Nacional');

CALL insertar_partidos('Tercera Ronda', 2023, 'Federación Internacional de Tenis', '2023-06-16', '16:15:00', 'por jugar', 184.8, NULL, '2016-08-24', 77.5, '1990-08-23', 'Benjamin', 'Taylor', 'Italia', 'visa', 523459, 58917, 'Masculino', '1979-07-31', 'Joseph', 'Martinez', 'Italia', 'pasaporte', 634570, 182.9, NULL, '2018-06-01', 75.7, '1994-11-21', 'Lucas', 'Smith', 'Alemania', 'pasaporte', 745681, 89041, 'Masculino', '1984-03-14', 'James', 'Jones', 'Alemania', 'cedula de ciudadania', 856782, '1981-12-27', 'Lily', 'Taylor', 'Italia', 'pasaporte', 967893, 25, 'Certificado Nacional');

CALL insertar_partidos('Cuarta Ronda', 2023, 'Federación Internacional de Tenis', '2023-06-16', '18:30:00', 'por jugar', 181.8, NULL, '2016-04-12', 76.6, '1991-11-07', 'Joseph', 'Smith', 'Francia', 'visa', 623459, 48917, 'Masculino', '1986-02-15', 'Matthew', 'Jones', 'Francia', 'pasaporte', 734570, 180.5, NULL, '2018-01-20', 75.8, '1993-04-15', 'Alexander', 'Taylor', 'Chile', 'pasaporte', 845681, 89042, 'Masculino', '1982-10-11', 'Jackson', 'Clark', 'Chile', 'cedula de ciudadania', 956782, '1984-07-07', 'Emily', 'Martinez', 'Francia', 'pasaporte', 067893, 28, 'Certificado Internacional');

CALL insertar_partidos('Cuartos de Final', 2023, 'Federación Internacional de Tenis', '2023-06-16', '14:30:00', 'por jugar', 187.0, NULL, '2015-09-03', 78.6, '1992-12-25', 'David', 'Jones', 'Alemania', 'visa', 723459, 38917, 'Masculino', '1975-08-19', 'Lucas', 'Taylor', 'Alemania', 'pasaporte', 834570, 181.0, NULL, '2017-11-16', 77.4, '1993-05-11', 'Benjamin', 'Smith', 'Australia', 'pasaporte', 945681, 89043, 'Masculino', '1984-12-30', 'James', 'Jones', 'Australia', 'cedula de ciudadania', 056782, '1983-11-22', 'Sophia', 'Taylor', 'Alemania', 'pasaporte', 167893, 29, 'Certificado Nacional');

CALL insertar_partidos('Semifinal', 2023, 'Federación Internacional de Tenis', '2023-06-16', '20:15:00', 'por jugar', 184.3, NULL, '2016-02-11', 77.3, '1991-10-02', 'Jacob', 'Martinez', 'Estados Unidos', 'visa', 823459, 28917, 'Masculino', '1980-07-14', 'Lucas', 'Jones', 'Estados Unidos', 'pasaporte', 934570, 180.3, NULL, '2018-02-27', 76.9, '1994-06-24', 'Benjamin', 'Taylor', 'Reino Unido', 'cedula de ciudadania', 045681, 89044, 'Masculino', '1981-05-15', 'David', 'Clark', 'Reino Unido', 'pasaporte', 156782, '1983-03-01', 'Lily', 'Jones', 'Estados Unidos', 'pasaporte', 267893, 28, 'Certificado Internacional');

CALL insertar_partidos('Final', 2023, 'Federación Internacional de Tenis', '2023-06-16', '21:00:00', 'por jugar', 186.5, NULL, '2015-09-30', 79.8, '1990-11-28', 'Daniel', 'Smith', 'Australia', 'visa', 923459, 18917, 'Masculino', '1979-05-11', 'Joseph', 'Taylor', 'Australia', 'pasaporte', 034570, 181.1, NULL, '2018-05-19', 77.2, '1993-08-18', 'James', 'Jones', 'Francia', 'pasaporte', 145681, 89045, 'Masculino', '1981-09-05', 'Matthew', 'Martinez', 'Francia', 'cedula de ciudadania', 256782, '1982-06-21', 'Lily', 'Taylor', 'Australia', 'pasaporte', 367893, 29, 'Certificado Internacional');


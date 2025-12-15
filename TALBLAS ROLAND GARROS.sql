


CREATE TABLE torneo (
	id_torneo serial primary key,
	nombre varchar(100) NOT NULL,
	fechaCreacion date NOT NULL
);

CREATE TABLE edicion (
	id_edicion serial PRIMARY KEY,
	id_torneo integer,
	Organizador varchar(100) NOT NULL,
	año_de_edicion INTEGER
);

CREATE TABLE persona (
	id_persona serial  PRIMARY KEY,
	fecha_nacimiento date NOT NULL,
	nombres varchar(100) NOT NULL,
	apellidos varchar(100) NOT NULL,
	nacionalidad integer NOT NULL,
	id_tipo_documento_identidad integer NOT NULL,
	numero_identificacion integer UNIQUE NOT NULL
);

CREATE TABLE jugador (
  id_persona integer PRIMARY KEY,
  id_entrenador integer NOT NULL,
  peso_actual numeric(15,2),
  fecha_debut date NOT NULL,
  fecha_retiro date,
  altura numeric(15,2)
);

CREATE TABLE entrenador (
  id_persona integer PRIMARY KEY,
  numero_licencia integer UNIQUE,
  id_genero integer NOT NULL
);

CREATE TABLE tipo_documento_identidad (
  id_tipo_documento_identidad serial PRIMARY KEY,
  tipoDocumento varchar(100) NOT NULL
);



CREATE TABLE pais (
  id_pais serial PRIMARY KEY,
  nombre varchar(100) NOT NULL
);

CREATE TABLE arbitro_principal (
	id_persona integer  PRIMARY KEY,
	anios_experiencia integer,
	id_disponibilidad integer,
	id_certificacion integer NOT NULL 
);

CREATE TABLE disponibilidad (
  id_disponibilidad serial PRIMARY KEY,
  disponibilidad boolean NOT NULL
);

CREATE TABLE certificacion (
  id_certificacion serial PRIMARY KEY,
  tipo_certificacion varchar(100)
);


CREATE TABLE genero (
  id_tipo_genero serial PRIMARY KEY,
  TipoGenero varchar(50) NOT NULL
);

-----
CREATE TABLE patrocinador (
  id_patrocinador serial PRIMARY KEY,
  id_edicion integer,
  nombre varchar(100) NOT NULL) ;

CREATE TABLE prendas_patrocinadas (
  id_prendas_patrocinadas serial PRIMARY KEY,
  id_patrocinador integer,
  id_jugador integer,
  id_tipo_prenda integer
);

CREATE TABLE tipo_prendas (
  id_tipo_prendas serial PRIMARY KEY,
  nombre varchar(50) NOT NULL
);

CREATE TABLE contrato (
  id_jugador integer NOT NULL,
  id_patrocinador integer NOT NULL,
  PRIMARY KEY (id_jugador, id_patrocinador)
);
--


CREATE TABLE pista (
  id_pista serial PRIMARY KEY,
  id_estadio integer NOT NULL,
  id_dimensiones integer,
  id_tipo_de_superficie integer
);

CREATE TABLE tipo_de_superficie (
  id_tipo_de_superficie serial PRIMARY KEY,
  superficie varchar(100)
);

CREATE TABLE dimensiones (
  id_dimensiones serial PRIMARY KEY,
  ancho numeric(15,2) NOT NULL,
  largo numeric(15,2) NOT NULL
);

CREATE TABLE partido (
  id_partido serial PRIMARY KEY,
  id_arbitro_principal integer NOT NULL,
  id_etapas_del_torneo integer NOT NULL,
  id_edicion integer NOT NULL,
  fecha_final date NOT NULL,
  hora_final time NOT NULL,
  id_estado_del_partido integer,
  id_jugador1 integer NOT NULL,
  id_jugador2 integer NOT NULL
);

CREATE TABLE etapas_del_torneo (
  id_etapas_del_torneo serial PRIMARY KEY,
  etapa varchar(100) NOT NULL
);

CREATE TABLE estado_del_partido (
  id_estado_del_partido serial PRIMARY KEY,
  estado_de_juego varchar(100) NOT NULL
);

CREATE TABLE programacion (
  id_programacion serial PRIMARY KEY,
  id_partido integer,
  fecha date NOT NULL,
  Hora time NOT NULL,
  id_estadio integer
);

CREATE TABLE estadio (
  id_estadio serial PRIMARY KEY,
  nombre varchar(100) NOT NULL,
  capacidad_maxima integer NOT NULL,
  ubicacion varchar(100) NOT NULL
);

CREATE TABLE acciones_del_partido (
  id_acciones serial PRIMARY KEY,
  id_jugador integer,
  id_partido integer,
  tiempo_accion time
);

CREATE TABLE sets_ (
  id_acciones integer PRIMARY KEY,
  numero_de_set integer NOT NULL,
  puntuacion_set integer NOT NULL
);

CREATE TABLE juego (
  id_acciones integer PRIMARY KEY,
  id_set integer NOT NULL,
  numero_juego integer NOT NULL,
  puntuacion_game integer NOT NULL
);

CREATE TABLE puntos (
  id_acciones integer PRIMARY KEY,
  id_juegos integer,
  numero_punto integer NOT NULL,
  puntuacion integer NOT NULL
);

CREATE TABLE falta (
  id_acciones integer PRIMARY KEY,
  id_tipo_falta integer
  
);

CREATE TABLE tipo_falta (
  id_tipo_falta serial PRIMARY KEY,
  descripcion varchar(500),
  id_sancion integer
);

CREATE TABLE sancion (
  id_sancion serial PRIMARY KEY,
  tipo_sancion varchar(100)
);


CREATE TABLE lesiones (
  id_acciones integer PRIMARY KEY,
  descripcion varchar(100)
);

CREATE TABLE servicio (
  id_acciones integer PRIMARY KEY,
  velocidad_saque numeric(15,2)
);

CREATE TABLE efectos_del_servicio (
  id_efectos_servicio serial PRIMARY KEY,
  id_resultado_servicio integer,
  id_servicio integer,
  id_falta integer
);

CREATE TABLE resultado_del_servicio (
  id_resultado_servicio serial PRIMARY KEY,
  tipo_resultado varchar(100)
);


--PERSONA
ALTER TABLE persona ADD FOREIGN KEY (nacionalidad) REFERENCES pais (id_pais);
ALTER TABLE persona ADD FOREIGN KEY (id_tipo_documento_identidad) REFERENCES tipo_documento_identidad (id_tipo_documento_identidad);


--ARBITRO
ALTER TABLE arbitro_principal ADD FOREIGN KEY (id_persona) REFERENCES persona (id_persona);

alter table arbitro_principal ADD FOREIGN KEY (id_disponibilidad) references disponibilidad (id_disponibilidad);

ALTER TABLE arbitro_principal ADD FOREIGN KEY (id_certificacion) REFERENCES certificacion (id_certificacion);


--JUGADOR

ALTER TABLE jugador ADD FOREIGN KEY (id_entrenador) REFERENCES entrenador (id_persona);

ALTER TABLE jugador ADD FOREIGN KEY (id_persona) REFERENCES persona (id_persona);


--ENTRENADOR

ALTER TABLE entrenador ADD FOREIGN KEY (id_persona) REFERENCES persona (id_persona);
ALTER TABLE entrenador ADD FOREIGN KEY (id_genero) REFERENCES genero (id_tipo_genero);


--EDICION
ALTER TABLE edicion ADD FOREIGN KEY (id_torneo) REFERENCES torneo (id_torneo); 


--PROGRAMACION

ALTER TABLE programacion ADD FOREIGN KEY (id_estadio) REFERENCES estadio (id_estadio);


ALTER TABLE programacion ADD FOREIGN KEY (id_partido) REFERENCES partido (id_partido);


--PRENDAS PATROCINADAS

ALTER TABLE prendas_patrocinadas ADD FOREIGN KEY (id_jugador) REFERENCES jugador (id_persona);

ALTER TABLE prendas_patrocinadas ADD FOREIGN KEY (id_patrocinador) REFERENCES patrocinador (id_patrocinador);

alter table prendas_patrocinadas ADD FOREIGN KEY (id_tipo_prenda) REFERENCES tipo_prendas (id_tipo_prendas);

--PATROCINADOR

ALTER TABLE patrocinador ADD FOREIGN KEY (id_edicion) REFERENCES edicion (id_edicion);

--PARTIDO

ALTER TABLE partido ADD FOREIGN KEY (id_estado_del_partido) REFERENCES estado_del_partido (id_estado_del_partido);

ALTER TABLE partido ADD FOREIGN KEY (id_jugador1) REFERENCES jugador (id_persona);

ALTER TABLE partido ADD FOREIGN KEY (id_jugador2) REFERENCES jugador (id_persona);

ALTER TABLE partido ADD FOREIGN KEY (id_etapas_del_torneo) REFERENCES etapas_del_torneo (id_etapas_del_torneo);

ALTER TABLE partido ADD FOREIGN KEY (id_edicion) REFERENCES edicion (id_edicion);

ALTER TABLE partido ADD FOREIGN KEY (id_arbitro_principal) REFERENCES arbitro_principal (id_persona);


--FALTA

ALTER TABLE falta ADD FOREIGN KEY (id_tipo_falta) REFERENCES tipo_falta (id_tipo_falta);

ALTER TABLE falta ADD FOREIGN KEY (id_acciones) REFERENCES acciones_del_partido (id_acciones);

--TIPO FALTA

ALTER TABLE tipo_falta ADD FOREIGN KEY (id_sancion) REFERENCES sancion (id_sancion );

--CONTRATO

ALTER TABLE contrato ADD FOREIGN KEY (id_jugador) REFERENCES jugador (id_persona);

ALTER TABLE contrato ADD FOREIGN KEY (id_patrocinador) REFERENCES patrocinador (id_patrocinador);


--PISTA
ALTER TABLE pista ADD FOREIGN KEY (id_dimensiones) REFERENCES dimensiones (id_dimensiones);

ALTER TABLE pista ADD FOREIGN KEY (id_tipo_de_superficie) REFERENCES tipo_de_superficie (id_tipo_de_superficie);

ALTER TABLE pista ADD FOREIGN KEY (id_estadio) REFERENCES estadio (id_estadio);

--PUNTOS
ALTER TABLE puntos ADD FOREIGN KEY (id_acciones) REFERENCES  acciones_del_partido(id_acciones);

ALTER TABLE puntos ADD FOREIGN KEY (id_juegos) REFERENCES juego (id_acciones);

--JUEGO

ALTER TABLE juego ADD FOREIGN KEY (id_set) REFERENCES sets_ (id_acciones);

ALTER TABLE  juego  ADD FOREIGN KEY (id_acciones) REFERENCES acciones_del_partido(id_acciones);

--SETS
ALTER TABLE sets_ ADD FOREIGN KEY (id_acciones) REFERENCES acciones_del_partido (id_acciones);


--ACCIONES

ALTER TABLE acciones_del_partido ADD FOREIGN KEY (id_partido) REFERENCES partido (id_partido);

ALTER TABLE acciones_del_partido ADD FOREIGN KEY (id_jugador) REFERENCES jugador (id_persona);




--EFECTOS DEL PARTIDO
ALTER TABLE efectos_del_servicio ADD FOREIGN KEY (id_resultado_servicio) REFERENCES resultado_del_servicio (id_resultado_servicio);

ALTER TABLE efectos_del_servicio ADD FOREIGN KEY (id_servicio)REFERENCES servicio (id_acciones);

ALTER TABLE efectos_del_servicio ADD FOREIGN KEY  (id_servicio) REFERENCES servicio (id_acciones);

ALTER TABLE efectos_del_servicio ADD FOREIGN KEY (id_falta) REFERENCES falta (id_acciones);


--SERVICIO

ALTER TABLE servicio  ADD FOREIGN KEY (id_acciones) REFERENCES acciones_del_partido (id_acciones);

--LESIONES

ALTER TABLE lesiones ADD FOREIGN KEY (id_acciones) REFERENCES acciones_del_partido (id_acciones);




--RESTRICCIONES

ALTER TABLE persona 
ADD CONSTRAINT fecha_nacimiento CHECK (fecha_nacimiento < CURRENT_DATE);

ALTER TABLE arbitro_principal 
ADD CONSTRAINT anios_experiencia CHECK (anios_experiencia >= 0);

ALTER TABLE estadio 
ADD CONSTRAINT capacidad_maxima CHECK (capacidad_maxima >= 0);

ALTER TABLE servicio 
ADD CONSTRAINT velocidad_saque CHECK (velocidad_saque >= 0);

ALTER TABLE jugador 
ADD CONSTRAINT peso_actual CHECK (peso_actual >= 0);

ALTER TABLE jugador 
ADD CONSTRAINT altura CHECK (altura >= 0);

ALTER TABLE entrenador 
ADD CONSTRAINT numero_licencia CHECK (numero_licencia >= 0);

ALTER TABLE dimensiones 
ADD CONSTRAINT ancho CHECK (ancho > 0);

ALTER TABLE dimensiones 
ADD CONSTRAINT largo CHECK (largo > 0);

ALTER TABLE sets_ 
ADD CONSTRAINT numero_de_set CHECK (numero_de_set > 0);

ALTER TABLE sets_ 
ADD CONSTRAINT puntuacion_set CHECK (puntuacion_set >= 0);

ALTER TABLE juego 
ADD CONSTRAINT numero_juego CHECK (numero_juego > 0);

ALTER TABLE juego 
ADD CONSTRAINT puntuacion_game CHECK (puntuacion_game >= 0);

ALTER TABLE puntos 
ADD CONSTRAINT numero_punto CHECK (numero_punto > 0);

ALTER TABLE puntos 
ADD CONSTRAINT puntuacion CHECK (puntuacion >= 0);



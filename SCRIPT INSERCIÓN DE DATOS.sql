
insert into tipo_documento_identidad (tipodocumento) 
values ('cedula de ciudadania'), ('pasaporte'), ('visa');

insert into genero (tipogenero) 
values ('Masculino'),('Femenino');



insert into tipo_de_superficie (superficie) 
values ('Arcilla');

insert into etapas_del_torneo (etapa) 
values ('Primera Ronda'),('segunda Ronda'),('tercera Ronda'),('octavos de final'),
	   ('cuartos de final'),('semifinal'),('final');
	   
insert into disponibilidad (disponibilidad)
values (true),(false);

insert into estado_del_partido (estado_de_juego)
values ('por jugar'),('en juego'),('finalizado'),('suspendido'),('descanso');

insert into tipo_prendas (nombre)
values ('camisetas'),('shorts'),('zapatillas'),('medias'),('gorras'),('chalecos'),('muñequeras'),
	   ('pantalones'),('pañoleta');


INSERT INTO estadio (nombre, capacidad_maxima, ubicacion) VALUES
('Court Philippe-Chatrier', 15225, ' Avenida Gordon Bennett ubicado en la entrada principal.'),
('Court Suzanne-Lenglen', 10068, 'Situado al sur del estadio Philippe-Chatrier'),
('Court Simonne-Mathieu', 5000, 'Ubicado en el extremo sureste del complejo');

INSERT into dimensiones (ancho, largo) values
(10.97,23.77),(11.05, 24.10),(10.99,23.87);

insert into resultado_del_servicio (tipo_resultado) values
('winner del servicio'),('let'),('saque en juego'),('ace');

insert into torneo (nombre, fechacreacion) values 
('Roland Garros', '24/05/1891');

insert into edicion(organizador, año_de_edicion, id_torneo) values 
('jeferson',2021,1),('mateo',2022,1),('luis',2023,1);

insert into patrocinador(id_edicion, nombre)
values (1, 'BNP Paribas'),(2, 'Emirates'),(3, 'Lacoste'),(1, 'Oppo'),(2, 'Peugeot'),
(3, 'Rolex'),(1, 'Engie'),(2, 'Haier'),(3, 'Infosys'),(1, 'Perrier'),(2, 'Wilson'),
(3, 'ALL - Accor Live Limitless'),(3, 'Hespéride'),(2, 'JCDecaux'),
(1, 'Lavazza'),(2, 'Magnum'),(3, 'Mastercard'),(1, 'Moët Hennessy'),
(3, 'Orange'),(2, 'Potel & Chabot'),(1, 'Renault');


INSERT INTO sancion (tipo_sancion) VALUES
('Advertencia'), -- Falta de pie-- Abuso de pelota-- Abuso de raqueta
( 'Pérdida del punto'), -- Doble falta-- Pelota fuera-- Pelota en la red-- Pase de línea-- Toque de red-- Falta en la red-- Golpe doble-- Impedir el saque---- Violación de tiempo
( 'pérdida de juego'), -- Violación de código-- Abuso verbal
( 'sancion economica'), -- Violación de coaching
( 'descalificación'); -- Conducta antideportiva

INSERT INTO tipo_falta (descripcion,id_sancion)
VALUES 
    ('Falta de pie', 1),
    ('Doble falta', 2),
    ('Violación de tiempo', 2),
    ('Violación de código', 3),
    ('Abuso de pelota',1 ),
    ('Abuso de raqueta', 1),
    ('Violación de coaching', 4),
    ('Conducta antideportiva', 5),
    ('Pelota fuera', 2),
    ('Pelota en la red', 2),
    ('Pase de línea', 2),
    ('Toque de red', 2),
    ('Falta en la red',2 ),
    ('Golpe doble', 2),
    ('Impedir el saque', 2);

insert into pista(id_estadio, id_dimensiones, id_tipo_de_superficie)
values (1,1,1),(2,2,1),(3,3,1);
	
	
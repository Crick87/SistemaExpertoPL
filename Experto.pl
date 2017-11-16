/* PRESENTACIÓN */
inicio:- nl,
	write('		Instituto Tecnológico de Celaya'),nl,
	write('		Sistema Experto: Diagnostico de Denge'),nl,nl,
	write('		Presenta:'),nl,
	write('		Francisco Jesus Oseguera Vega'),nl,
	write('		Ricardo Silis'),nl,
	write('		Gomez Razo Jorge Noel'),
	nl,nl,
	write('		Bienvenido al menu principal:'),nl,
	menu.

/* MENÚ */
menu:-
	validarArchivo,nl,
	write('		1 - Usar el Sistema Experto'),nl,
	write('		2 - Ingresar Datos a la Base de Conocimiento'),nl,
	write('		3 - Salir'),nl,
	write('		Respuesta: '),
	read(Respuesta),nl,
	validacion(Respuesta).

/* MENÚ */
menu2:-
	nl,
	write('		1 - Iniciar el diagnostico Encadenamiento Hacia Atras'),nl,
	write('		2 - Iniciar el diagnostico Encadenamiento Hacia Adelante'),nl,
	write('		Respuesta: '),
	read(Respuesta),nl,
	validacion2(Respuesta).

/* VALIDAR ARCHIVO CONOCIMIENTO */
validarArchivo :- exists_file('enf.dbs').
validarArchivo :-
    not(exists_file('enf.dbs')),
    tell('enf.dbs'),
    told,
    write('		Se ha definido el archivo enf.dbs'),nl.

/* VALIDAR RESPUESTA DE MENÚ */
validacion(Respuesta):-Respuesta=1, menu2.
validacion(Respuesta):-Respuesta=2, ingresa, menu.
validacion(Respuesta):-Respuesta=3, salida.
validacion(Respuesta):-Respuesta\=1,Respuesta\=2,
	nl,
	write('		Opción Incorrecta'),nl,menu.

/* VALIDAR RESPUESTA DE MENÚ 2*/
validacion2(Respuesta):-Respuesta=1, enfermaEHA, menu.
validacion2(Respuesta):-Respuesta=2, enfermaEHD, menu.
validacion2(Respuesta):-Respuesta\=1,Respuesta\=2,
	nl,
	write('		Opción Incorrecta'),nl,menu2.

/* DESPEDIDA */
salida:- nl, write('		Gracias, buen día!').

/* GUARDAR ARCHIVO */
save(ToFile):-
	telling(Old),
	tell(ToFile),
	listing(enfe/2),
	told,
	tell(Old).

/* INDRODCIR DATOS A LA BASE DE CONOCIMIENTO */
ingresa :-
   consult('enf.dbs'),
   fail.

ingresa:-
	asserta(si(end)),
	asserta(no(end)),
	write("		Desea introducir una enfermedad? << s/n >>"),nl,
	write("		Respuesta: "),
	read(A),
	A=s,
	/* Si introducir regresa falso, ya no se desean agregar enfermedades. */
	not(introducir),
	/* Se guarda el archivo después de que se agrega enfermedad */
	save('enf.dbs'),!,nl.

ingresa:- menu.

/* ENCADENAMIENTO HACIA ATRAS */
/* CONSULTA ARCHIVO enf.dbs */
enfermaEHA:-
   consult('enf.dbs'),
   fail.

/* EVALUACIÓN - ehd */
enfermaEHA:-
	asserta(si(end)),
	asserta(no(end)),
	nl,nl,
	write("		DIÁLOGO DE DIAGNÓSTICO"),nl,nl,
	write('		¿Qué enfermedad supones? <<minúsculas>>'),nl,nl,
	write("		Respuesta: "),
	read(O),
	preguntarEHA(O),
	purgar.

/* En el fail del predicado procesar, no se puede seguir infiriendo: */
enfermaEHA:- nl,
	write('		No se puede concluir con los sintomas presentados.'),nl,nl,
	write('		Escribe cualquier caracter, seguido de punto.'),
	read(_),
	purgar.

/* ENCADENAMIENTO HACIA ADELANTE */
/* CONSULTA ARCHIVO enf.dbs */
enfermaEHD:-
   consult('enf.dbs'),
   fail.

/* EVALUACIÓN - ehd */
enfermaEHD:-
	asserta(si(end)),
	asserta(no(end)),
	nl,nl,
	write("		DIÁLOGO DE DIAGNÓSTICO"),nl,
	write("		Responde <s/n>"),nl,
	preguntarEHD([]),
	purgar.

/* En el fail del predicado procesar, no se puede seguir infiriendo: */
enfermaEHD:- nl,
	write('		No se encuentran enfermedades con los sintomas presentados.'),nl,nl,
	write('		Escribe cualquier caracter, seguido de punto.'),
	read(_),
	purgar.

/* INTRODUCIR ENFERMEDAD */
introducir:-
	nl,nl,
	write("		Qué enfermedad desea introducir? <minúsculas>"),nl,
	write("		Respuesta: "),
	read(Object),
	Object \= "fin",nl,
	write("		Enfermedad "),
	write( Object),nl,nl,
	/* Definimos la enfermedad y una lista para los síntomas */
	atributos(Object,[]),nl,nl,
	write("		Otra enfermedad? <s/n>"),nl,!,
	write("		Respuesta: "),
	read(Q),
	Q=s,
	introducir.

/* INTRODUCIR ATRIBUTOS */
atributos(O,List):-
	write("		SINTOMA (para terminar <fin>):"),nl,
	write("		Respuesta:	"),
	read(Attribute),
	Attribute\='fin',
	add(Attribute, List, List2),
	atributos(O,List2).

/* Se agrega la enfermedad y los síntomas a la Base de Conocimiento */
atributos(O,List):- asserta(enfe(O,List)).

/* SE UNE LA LISTA DE SÍNTOMAS */
add(X,[],[X]).
add(X,[C|R],[C|R1]) :- add(X,R,R1).

/* PREGUNTAR LOS SINTOMAS DE LA ENFERMEDAD CONSULTADA - ehd */
preguntarEHA(O):-
	enfe(O,A),
	add(O,_L,_L2),
	anterioressi(A),
	anterioresno(A),
	intentar(O,A), !, nl, nl,
	upcase_atom("		[!] Tiene los sintomas presentados de ", UPtext),
	upcase_atom(O, UPsick),
	write(UPtext), write(UPsick),nl,nl.

preguntarEHD(L):-
	enfe(O,A),
	not(miembro(O,L)),
	add(O,L,L2),
	intentar(O,A),
	!,nl,nl,
	upcase_atom("		[!] Tiene los sintomas presentados de ", UPtext),
	upcase_atom(O, UPsick),
	write(UPtext), write(UPsick),nl,nl,
	write("		BUSCANDO OTRA ENFERMEDAD..."),
	read(_),
	preguntarEHD(L2).


/* OBTENER LOS SINTOMAS DE LA ENFERMEDAD CONSULTADA */
anterioressi(A):- si(T),!, xanterioressi(T,A,[]),!.

xanterioressi(end,_,_):- !.

xanterioressi(T,A,L):-
	miembro(T,A),!,
	add(T,L,L2),
	si(X), not(miembro(X,L2)),!,
	xanterioressi(X,A,L2).

anterioresno(A):- no(T),!, xanterioresno(T,A,[]),!.

xanterioresno(end,_,_):- !.

xanterioresno(T,A,L):-
	miembro(T,A),!,
	add(T,L,L2),
	no(X), 
	not(miembro(X,L2)),!,
	xanterioresno(X,A,L2).

/* LEER LOS SINTOMAS DE LA ENFERMEDAD CONSULTADA */
intentar(_O,[]).

intentar(O,[X|T]):- nl,
	write("		Sintoma: "),
	write(X),
	write("?"),nl,
	write("		Respuesta (s/n):"),
	read(Q),
	procesar(O,X,Q),!,
	intentar(O,T).

/* Si un síntoma está presente se agrega al inicio de la */
/* Base de Conocimiento, en caso contrariose termina con */
/* fail y se concluye con no inferir más.                */

procesar(_,X,s):- asserta(si(X)),!.
procesar(_,X,n):- asserta(no(X)), !, fail.

xwrite(end).
xwrite(Z):-write(Z).

/* Retract se encarga de eliminar todos los términos temporales de la BC */
purgar:- retract(si(X)), X=end, fail.
purgar:- retract(no(X)), X=end.


/* DETERMINA SI UN ELEMENTO PERTENECE A UNA LISTA */
miembro(N,[N|_]).
miembro(N,[_|T]):- miembro(N,T).


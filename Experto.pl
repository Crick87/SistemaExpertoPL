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
	write('		1 - Iniciar el diagnostico'),nl,
	write('		2 - Salir'),nl,
	write('		Respuesta: '),
	read(Respuesta),nl,
	validacion(Respuesta).

/* VALIDAR ARCHIVO CONOCIMIENTO */
validarArchivo :- exists_file('enf.dbs').
validarArchivo :-
    not(exists_file('enf.dbs')),
    tell('enf.dbs'),
    told,
    write('		Se ha definido el archivo enf.dbs'),nl.

/* VALIDAR RESPUESTA DE MENÚ */
validacion(Respuesta):-Respuesta=1, enferma, menu.
validacion(Respuesta):-Respuesta=2, salida.
validacion(Respuesta):-Respuesta\=1,Respuesta\=2,
	nl,
	write('		Opción Incorrecta'),nl,menu.

/* DESPEDIDA */
salida:- nl, write('		Gracias, buen día!').

/* GUARDAR ARCHIVO */
save(ToFile):-
	telling(Old),
	tell(ToFile),
	listing(enfe/2),
	told,
	tell(Old).

/* CONSULTA ARCHIVO enf.dbs */
enferma:-
   consult('enf.dbs'),
   fail.

/* AGREGA ENFERMEDAD */
enferma:-
	asserta(si(end)),
	asserta(no(end)),
	write("		Desea introducir información? << s/n >>"),nl,
	write("		Respuesta: "),
	read(A),
	A=s,
	/* Si introducir regresa falso, ya no se desean agregar enfermedades. */
	not(introducir),
	/* Se guarda el archivo después de que se agrega enfermedad */
	save('enf.dbs'),!,nl.

/* EVALUACIÓN - ehd */
enferma:-
	nl,nl,
	write("		DIÁLOGO DE DIAGNÓSTICO"),nl,nl,
	write('		¿Qué enfermedad supones? <<minúsculas>>'),nl,nl,
	write("		Respuesta: "),
	read(O),
	preguntar(O),
	purgar.

/* En el fail del predicado procesar, no se puede seguir infiriendo: */
enferma:-
	write('		No se puede concluir con los sintomas presentados.'),nl,nl,
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
add(X,L,[X|L]).

/* PREGUNTAR LOS SINTOMAS DE LA ENFERMEDAD CONSULTADA - ehd */
preguntar(O):-
	enfe(O,A),
	add(O,_L,_L2),
	anterioressi(A),
	anterioresno(A),
	intentar(O,A), !, nl, nl,
	upcase_atom("		[!] Tiene los sintomas presentados de ", UPtext),
	upcase_atom(O, UPsick),
	write(UPtext), write(UPsick),nl,nl.

/* OBTENER LOS SINTOMAS DE LA ENFERMEDAD CONSULTADA */
anterioressi(A):- si(T),!, xanterioressi(T,A,[]),!.

xanterioressi(end,_,_):-!.

xanterioressi(T,A,L):-
	miembro(T,A),!,
	add(T,L,L2),
	si(X), not(miembro(X,L2)),!,
	xanterioressi(X,A,L2).

anterioresno(A):- no(T),!, xanterioresno(T,A,[]),!.

xanterioresno(end,_,_):-!.

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

include "alldifferent.mzn";

% ------------------------Parametros de entrada----------------------------
enum ACTORES;
array[int,int] of int: Escenas;
array[int] of int: Duracion;
array[ACTORES, 1..2] of int: Disponibilidad;
array[int, 1..2] of int: Evitar;

% ------------------------Constantes---------------------------------------
int: n = max(rangoActores); % Número de actores.
int: m = length(Duracion); % Número de escenas
int: c = length(Evitar[..,1]); % Número de conflictos  

set of int: rangoActores = index_set(ACTORES);
set of int: rangoEscenas = 1..m;
set of int: rangoConflictos = 1..c;

int: peorCaso = sum(i in rangoActores) (sum(Duracion) * Escenas[i, m+1]);
int: mejorCaso = sum(i in rangoActores) (
			sum(k in rangoEscenas where Escenas[i, k] == 1)
				(Duracion[k]*Escenas[i,m+1])
);

int: numZeroedColumns = sum([1 | j in rangoEscenas where sum(Escenas[..,j]) == 0]);
array[1..numZeroedColumns] of rangoEscenas : zeroedColumns = [ j | j in rangoEscenas where sum(Escenas[..,j]) == 0];

% ------------------------Variables----------------------------------------

% Orden en el que deben ensayarse las escenas.
array[rangoEscenas] of var rangoEscenas: orden;

% Indices de la primera y última escena de cada actor.
array[rangoActores, 1..2] of var rangoEscenas: intervalos;

% u. de tiempo en set por cada actor
array[rangoActores] of var 0..infinity: tiemposxActor;
		
var mejorCaso..peorCaso: costo;

% Costo por escena
array[rangoEscenas] of var 0..infinity: costoxEscena;

%Escenas compartidas entre actores que se quieren evitar
array[rangoConflictos] of var int: compartido = [getTimeSpend(Evitar[i,..])| i in rangoConflictos];
% ------------------------------------------------Funciones-----------------------------------------
function var int: getLowerBound(int: actor) = 
	min([ k | k in rangoEscenas where Escenas[actor,orden[k]] == 1]);

function var int: getUpperBound(int: actor) = 
	max([ k | k in rangoEscenas where Escenas[actor, orden[k]] == 1]);
	
function var int: getTimeSpend(array[int] of int: evitan) =
  sum(i in intervalos[evitan[1],1]..intervalos[evitan[1],2])
  (intervalos[evitan[2],1] <= i /\ i <= intervalos[evitan[2],2]);

% ------------------------------------------------Restricciones-------------------------------------

% Cada escena se graba una vez.
constraint alldifferent(orden);

constraint forall(i in rangoActores)
	(tiemposxActor[i] = sum(j in intervalos[i,1]..intervalos[i,2])(Duracion[orden[j]]));

% Se verifica la matriz intervalos de acuerdo al primer y ultimo indice de la primer y ultima escena respectivamente.
constraint forall(i in rangoActores)
	(intervalos[i,1] = getLowerBound(i) /\ intervalos[i,2] = getUpperBound(i));

% Definición de costoxEscena
constraint forall(k in rangoEscenas, l in m..2)
				(costoxEscena[k] = sum(i in rangoActores) (col(Escenas,k)[i]*Escenas[i,m+1])*Duracion[k]);

constraint costo = sum(i in rangoActores) (
										sum(j in intervalos[i,1]..intervalos[i,2]) (Duracion[orden[j]])*Escenas[i,m+1]);

% Todas las escenas que valgan cero van de primero en el orden.
constraint symmetry_breaking_constraint(
	forall(k in 1..numZeroedColumns) (orden[k] = zeroedColumns[k])
);

% Forzar un orden en aquellas escenas no contiguas que sean iguales y que no sean columnas cero.
constraint symmetry_breaking_constraint(
forall(j in 1..m-1, k in j+1..m) ( 
				if Escenas[..,j] = Escenas[..,k]  /\ Duracion[j] = Duracion[k] /\ sum(Escenas[..,j]) != 0
				then orden[j] < orden[k] 
				endif
));

%Se verifica para cada actor que se cumpla sus restricciones de tiempo en set.
constraint forall(i in rangoActores)
	(if Disponibilidad[ACTORES[i],2] = 0 then 
	true
	else tiemposxActor[i] <= Disponibilidad[ACTORES[i],2] endif);
% ------------------------------------Objetivo----------------------------------------
%Escalamos el primer objetivo(costo) por un valor que sea al menos como el maximo del segundo objetivo(actores que se quieren evitar en set). El resultado seria entonces el optimo lexicografico.

var int: objetivo = costo*(c*m + 1) + sum(i in rangoConflictos)(getTimeSpend(Evitar[i,..]));

solve :: int_search(orden, smallest, indomain_min) minimize objetivo;

%solve :: int_search(orden, smallest, indomain_min) minimize costo;


output	["Orden de las escenas: \(orden)\n"] ++
	["Costo: \(costo)\n"] ++ 
	["Objetivo(costo+evitar): \(objetivo)\n"]++
	["Cantidad de escenas compartidas: \(compartido)\n"];
include "alldifferent.mzn";

% ------------------------Parametros de entrada----------------------------
enum ACTORES;
array[int,int] of int: Escenas;
array[int] of int: Duracion;

% ------------------------Constantes---------------------------------------
int: n = max(rangoActores); % Número de actores.
int: m = length(Duracion); % Número de escenas

set of int: rangoActores = index_set(ACTORES);
set of int: rangoEscenas = 1..m;

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
	
var mejorCaso..peorCaso: costo;

% ------------------------------------------------Funciones-----------------------------------------
function var int: getLowerBound(int: actor) = 
	min([ k | k in rangoEscenas where Escenas[actor,orden[k]] == 1]);

function var int: getUpperBound(int: actor) = 
	max([ k | k in rangoEscenas where Escenas[actor, orden[k]] == 1]);
	
% ------------------------------------------------Restricciones-------------------------------------

% Cada escena se graba una vez.
constraint alldifferent(orden);

% Se llena la matriz intervalos de acuerdo al primer y ultimo indice de la primer y ultima escena respectivamente.
constraint forall(i in rangoActores)
	(intervalos[i,1] = getLowerBound(i) /\ intervalos[i,2] = getUpperBound(i));


constraint costo = sum(i in rangoActores) (
			sum(j in intervalos[i,1]..intervalos[i,2]) (Duracion[orden[j]])*Escenas[i,m+1]);

% Todas las escenas que valgan cero van de primero en el orden.
constraint symmetry_breaking_constraint(
	forall(k in 1..numZeroedColumns) (orden[k] = zeroedColumns[k])
);

% Forzar un orden en aquellas escenas contiguas y no contiguas que sean iguales y que no sean columnas cero.
constraint symmetry_breaking_constraint(
forall(j in 1..m-1, k in j+1..m) ( 
				if Escenas[..,j] = Escenas[..,k] /\ Duracion[j] = Duracion[k] /\ sum(Escenas[..,j]) != 0
				then orden[k] < orden[j] 
				endif
));

% ------------------------------------Objetivo----------------------------------------

solve minimize costo;

output	["Orden de las escenas: \(orden)\n"] ++
	["Costo: \(costo)\n"]++
	["peor: \(peorCaso)\n"]++
	["mejor: \(mejorCaso)\n"];
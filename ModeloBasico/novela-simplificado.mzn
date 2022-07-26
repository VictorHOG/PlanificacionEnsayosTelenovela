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

% Costo por actor
%array[rangoActores] of var 0..max(col(Escenas,numEscenas+1))*sum(Duracion): costoxActor;

% u. de tiempo en set por cada actor
%array[rangoActores] of var 0..infinity: tiemposxActor;

% Costo total
%var int: costo = sum(i in rangoActores) (
%		(tiemposxActor[i] * Escenas[i, m+1]));
		
var mejorCaso..peorCaso: costo;

% Costo por escena
array[rangoEscenas] of var 0..infinity: costoxEscena;

% ------------------------------------------------Funciones-----------------------------------------
function var int: getLowerBound(int: actor) = 
	min([ k | k in rangoEscenas where Escenas[actor,orden[k]] == 1]);

function var int: getUpperBound(int: actor) = 
	max([ k | k in rangoEscenas where Escenas[actor, orden[k]] == 1]);
	
% ------------------------------------------------Restricciones-------------------------------------

% Cada escena se graba una vez.
constraint alldifferent(orden);

%constraint forall(i in rangoActores)
%	(tiemposxActor[i] = sum(j in intervalos[i,1]..intervalos[i,2])(Duracion[orden[j]]));

% El actor i solo se puede ir hasta que ya no le queden más escenas, con en el orden propuesto.
%constraint forall(i in rangoActores) 
%	(costoxActor[i] = tiemposxActor[i] * Escenas[i, numEscenas+1]);

% Se llena la matriz intervalos de acuerdo al primer y ultimo indice de la primer y ultima escena respectivamente.
constraint forall(i in rangoActores)
	(intervalos[i,1] = getLowerBound(i) /\ intervalos[i,2] = getUpperBound(i));

% Definición de costoxEscena
constraint forall(k in rangoEscenas, l in m..2)
				(costoxEscena[k] = sum(i in rangoActores) (col(Escenas,k)[i]*Escenas[i,m+1])*Duracion[k]);

constraint costo = sum(i in rangoActores) (
										sum(j in intervalos[i,1]..intervalos[i,2]) (Duracion[orden[j]])*Escenas[i,m+1]);

% Todas las escenas que valgan cero van de primero en el orden.
%constraint symmetry_breaking_constraint(forall(k in 1..foo) (orden[k] = temp[k]));

% -----------------------------------Objetivo-------------------------------------

solve minimize costo;
%solve :: int_search(orden, smallest, indomain_min) minimize costo;


output	["Orden de las escenas: \(orden)\n"] ++
	["Costo: \(costo)\n"]++
	["peor: \(peorCaso)\n"]++
	["mejor: \(mejorCaso)\n"]++
	["zeros: \(foo)\n"];
	%["Test: \([ k | k in rangoEscenas where Escenas[3,orden[k]] > 0])\n"]++
	%["CostoxActor: \(costoxActor)\n"]++
	%["TiempoxActor: \(tiemposxActor)\n"];
	%["CostoxEscena: \(costoxEscena)\n"];
	%509k
	%578k

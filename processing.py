import os
from minizinc import Instance, Model, Solver

def processFile(request):
    
    print("######################################################")
    print("el request")
    print(request)

    numeroEscenas = request.form.get('escenas')
    numeroActores = request.form.get('actores')
    dimension = (int(numeroEscenas)+1) * int(numeroActores)
    escenas = request.form.getlist('escena')
    duracion = request.form.getlist('duracion')

    print("numero de escenas " + numeroEscenas)
    print("numero de actores" + numeroActores)
    print( escenas)
    print(duracion)
    print("######################################################")

    #Se crea el archivo dzn con los datos ingresados
    directoryPath = "../Modelo"
    filePath = "../Modelo/Datos.dzn"

    directoryExist = os.path.exists(directoryPath)

    if (directoryExist != True):
        os.mkdir(directoryPath)
    
    file = open(filePath, "w")

    actoresFile = "ACTORES = {"
    for i in range(int(numeroActores)):
        
        if (i == int(numeroActores)-1):
            actoresFile += "Actor" + str(i+1) 
        else: actoresFile += "Actor" + str(i+1) + ", "
    actoresFile += "};\n\n"

    file.write(actoresFile)

    contador = 0
    escenasFile = "Escenas = [|"
    for i in range(int(dimension)):
        
       
        if (contador == (int(numeroEscenas)+1)):
            contador = 0   
            escenasFile += "\n|" + escenas[i] + ","
        elif (i == int(dimension)-1):
            escenasFile += escenas[i] 
        else: escenasFile += escenas[i] + ","

        contador+=1

    escenasFile += "|];\n\n"

    file.write(escenasFile)

    duracionFile = "Duracion = ["
    for i in range(int(numeroEscenas)):
        
        if (i == int(numeroEscenas)-1):
            duracionFile += duracion[i] 
        else: duracionFile += duracion[i] + ","

    duracionFile += "];\n\n"

    file.write(duracionFile)

    #Se cierra el archivo
    file.close()

#
def executeMinizinc():
    #Se carga el modelo
    modelo = Model("../Modelo/novela.mzn")
    #Se añaden los datos
    modelo.add_file("../Modelo/Datos.dzn")
    #Se selecciona el solver
    solver = Solver.lookup("gecode")
    # Crear una instancia del modelo Relleno para Gecode
    instance = Instance(solver, modelo)
    #Se ejecuta el modelo
    result = instance.solve()

    print(result)
    print(result.solution)

    return result
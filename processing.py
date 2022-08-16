import os
from minizinc import Instance, Model, Solver

def processFile(request):

    modelo = request.form.get('options')

    numeroEscenas = request.form.get('escenas')
    numeroActores = request.form.get('actores')
    dimension = (int(numeroEscenas)+1) * int(numeroActores)
    escenas = request.form.getlist('escena')
    duracion = request.form.getlist('duracion')
    disponibilidad = request.form.getlist('disponibilidad')
    evitar = request.form.getlist('evitar')

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

    #se escriben opciones para modelo 2
    if(modelo == "option2"):

        disponibilidadFile = "Disponibilidad = ["
        for i in range(int(numeroActores)):
        
            if (i == int(numeroActores)-1):
                disponibilidadFile += "\n|Actor" + str(i+1) + ", " + disponibilidad[i] + "|" 
            elif (i == 0):
                disponibilidadFile += "|Actor" + str(i+1) + ", " + disponibilidad[i] 
            else:
                disponibilidadFile += "\n|Actor" + str(i+1) + ", " + disponibilidad[i] 

        disponibilidadFile += "];\n\n"

        file.write(disponibilidadFile)

        evitarFile = "Evitar = ["
        for i in range(len(evitar)): 

            if (i % 2 == 0 and i != 0):
                evitarFile += "\n|" + evitar[i] + ","
            elif (i==0):
                evitarFile += "|" + evitar[i] + ","
            elif (i == len(evitar)-1):
                evitarFile += evitar[i] 
            else: evitarFile += evitar[i] + ","

        evitarFile += "|];"

        file.write(evitarFile)

    #Se cierra el archivo
    file.close()

#
def executeMinizinc(modelo):
    #Se carga el modelo
    if (modelo == "option2"):
        modelo = Model("../Modelo/novela-extendido.mzn")
    else: modelo = Model("../Modelo/novela-simplificado.mzn")
    
    #Se añaden los datos
    modelo.add_file("../Modelo/Datos.dzn")
    #Se selecciona el solver
    solver = Solver.lookup("gecode")
    # Crear una instancia del modelo Relleno para Gecode
    instance = Instance(solver, modelo)
    #Se ejecuta el modelo
    result = instance.solve()

    return result
from flask import Flask, render_template, request
from processing import processFile, executeMinizinc
from werkzeug.utils import secure_filename
import os

app = Flask(__name__)
app.config["UPLOAD_FOLDER"] = "../Modelo"
ALLOWED_EXTENSIONS = set(['dzn'])

@app.route('/', methods=['POST', 'GET'])
def index():
    if request.method == 'POST':
        # form_name = request.form['form-name']
        # print(form_name)
        modelo = request.form.get('options')
        print(modelo)
        form = request.form
        processFile(request)
        result = executeMinizinc(modelo)
        return render_template('index.html', result=result, form=form)
    elif request.method == 'GET':   
        return render_template('index.html')

def allowed_file(file):
    file = file.split('.')
    print(file)
    if file[1] in ALLOWED_EXTENSIONS:
        return True
    return False

@app.route('/uploadFile', methods=['POST'])
def uploadFile():

    file = request.files["uploadFile"]
    print(file, file.filename)
    filename = secure_filename(file.filename)
    print(filename)
    if file and allowed_file(filename):
        print("permitido")
        file.save(os.path.join(app.config["UPLOAD_FOLDER"], filename))
        os.remove("../Modelo/Datos.dzn")
        os.rename("../Modelo/" + filename, "../Modelo/Datos.dzn")

    with open('../Modelo/Datos.dzn') as f:
        if 'Disponibilidad' in f.read():
            print("True")
            result = executeMinizinc("option2")
        else: result = executeMinizinc("option1")

    
    return render_template('index.html', result=result)
    

if __name__ == '__main__':
    app.run(port = 3000, debug = True)
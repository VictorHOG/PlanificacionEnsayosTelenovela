from flask import Flask, render_template, request
from processing import processFile, executeMinizinc

app = Flask(__name__)

@app.route('/', methods=['POST', 'GET'])
def index():
    if request.method == 'POST':
        processFile(request)
        result = executeMinizinc()
        return render_template('index.html', result=result)
    elif request.method == 'GET':   
        return render_template('index.html')

if __name__ == '__main__':
    app.run(port = 3000, debug = True)
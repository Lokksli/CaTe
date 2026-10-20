# importing flask
from flask import Flask, request, render_template, jsonify, session
from flask import send_from_directory
import os
import subprocess
import json


# creating a session
app = Flask("Max", template_folder="templates", static_folder="static")

# routes
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/temperature')
def temperature():
    return send_from_directory('templates', 'temperature.html')

@app.route('/temperature_files/<path:filename>')
def temperature_files(filename):
    return send_from_directory('templates/temperature_files', filename)

@app.route('/daily_average_temperature', methods=['POST'])
def daily_average_temperature():
    data = request.get_json()
    daily_average = data.get('daily_average', False)
    start_year = data.get('start_year')
    end_year = data.get('end_year')
    start_year = "1993" if not start_year.isnumeric() or not(int(start_year) >= 1993 and int(start_year) <= int(end_year)) else start_year 
    end_year = "2026" if not end_year.isnumeric() or not(int(end_year) <= 2026 and int(end_year) >= int(start_year)) else end_year
    print(start_year)
    print(end_year)

    mode = 'daily' if daily_average else 'raw'

    result = subprocess.run(
        ['Rscript', 'main.R', mode, start_year, end_year],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        return jsonify({'error': result.stderr}), 500

    with open('templates/stats.json') as f:
        stats = json.load(f)

    return jsonify({
        'url': '/temperature',
        'stats': stats
    })


# hosting a website
app.run(host='0.0.0.0', port=5000, debug=True)
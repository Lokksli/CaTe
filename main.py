# importing flask
from flask import Flask, request, render_template, jsonify, session
from flask import send_from_directory
import os
import subprocess
import json


# creating a session
app = Flask("Max", template_folder="templates", static_folder="static") # Creating app

# routes
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/temperature') 
def temperature():
    return send_from_directory('templates', 'temperature.html')

@app.route('/temperature_files/<path:filename>') # Route for plotly html widget
def temperature_files(filename):
    return send_from_directory('templates/temperature_files', filename)

@app.route('/start_year_comparison')            # Start year comparison route
def start_year_comparison():
    return send_from_directory('templates', 'start_year_comp.html')

@app.route('/start_year_comp_files/<path:filename>') # Start year route for plotly
def start_year_comparison_files(filename):
    return send_from_directory('templates/start_year_comp_files', filename)

@app.route('/end_year_comparison')            # End year comparison route
def end_year_comparison():
    return send_from_directory('templates', 'end_year_comp.html')

@app.route('/end_year_comp_files/<path:filename>') # End year route for plotly
def end_year_comparison_files(filename):
    return send_from_directory('templates/end_year_comp_files', filename)



@app.route('/daily_average_temperature', methods=['POST']) # Changing graphic
def daily_average_temperature():
    data = request.get_json()
    daily_average = data.get('daily_average', False)
    start_year = str(data.get('start_year'))
    end_year =  str(data.get('end_year'))

    if not start_year.isnumeric() or not end_year.isnumeric():                                      # Checking if data is correct
        start_year = "1993"
        end_year = "2025"
    elif (int(start_year) > int(end_year)) or int(start_year) < 1993 or int(end_year) >  2025:
        start_year = "1993"
        end_year = "2025"
    else:
        start_year = start_year
        end_year = end_year

    
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


@app.route('/compare_years', methods=['POST']) # Generating a graphic for years comparison
def compare_years():
    data = request.get_json()
    start_year = str(data.get('start_year_comparison'))
    end_year = str(data.get('end_year_comparison'))
    mode = 'daily'

    if not start_year.isnumeric() or not end_year.isnumeric():                                      # Checking if data is correct
        start_year = "1993"
        end_year = "2025"
    elif (int(start_year) > int(end_year)) or int(start_year) < 1993 or int(end_year) >  2025:
        start_year = "1993"
        end_year = "2025"
    else:
        start_year = start_year
        end_year = end_year

    print(start_year)
    print(end_year)

    result = subprocess.run(
        ['Rscript', 'year_comparison.R', mode, start_year, end_year],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        return jsonify({'error': result.stderr}), 500


    return jsonify({
        'url_start_year': '/start_year_comparison',
        'url_end_year': '/end_year_comparison'
    })




# hosting a website
app.run(host='0.0.0.0', port=5000, debug=True)
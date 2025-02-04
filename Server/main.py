from flask import Flask, request, jsonify
import uuid
from datetime import datetime

app = Flask(__name__)

# Store player data
players = {}

@app.route('/', methods=['POST'])
def update_player():
    print("Updating player...")

    try:
        # Get the raw data from the "body" field (URL-encoded)
        if not request.form.get("body"):
            return "Invalid request: 'body' field missing.", 400
        
        raw_data = request.form["body"]

        # Extract map_id, x, y, guid from the raw data
        data_dict = dict(item.split(',') for item in raw_data.split('\n'))
        map_id = data_dict.get('map_id')
        x = data_dict.get('x')
        y = data_dict.get('y')
        rot = data_dict.get('rot')
        guid = data_dict.get('guid')

        # print(f"Map ID: {map_id}, X: {x}, Y: {y}, Rot: {rot}, GUID: {guid}")
        
        if not guid:
            guid = str(uuid.uuid4())

        players[guid] = {
            'guid': guid,
            'map_id': map_id,
            'x': x,
            'y': y, 
            'rot': rot
        }
        print(f"Player data: {players[guid]}")

        csv_data = ""

        # Filter players by map_id, excluding the requesting player
        filtered_players = [player for player in players.values() if player['map_id'] == map_id and player['guid'] != guid]
        print(f"Filtered players: {filtered_players}")
        for player in filtered_players:
            csv_data += f"{player['guid']},{player['map_id']},{player['x']},{player['y']},{player['rot']}\n"

        return csv_data, 200, {'Content-Type': 'text/csv'}
    
    except Exception as e:
        return "Error: " + str(e), 500


@app.route('/guid', methods=['GET'])
def generate_guid():
    """
    Generate and return a new GUID.
    """
    new_guid = str(uuid.uuid4())
    print(f"Generated GUID: {new_guid}")
    return new_guid, 200, {'Content-Type': 'text/plain'}


@app.route('/mystery_gift', methods=['GET'])
def mystery_gift():
    """
    Return a mystery gift.
    """
    with open("gifts.csv", "r") as file:
        gifts = file.readlines()
        gift = gifts[-1]

        # Remove time medata from the gift
        gift = gift.split(',')[2:]

        return ','.join(gift), 200, {'Content-Type': 'text/csv'}
    

@app.route('/is_mystery_gift_available', methods=['GET'])
def is_mystery_gift_available():
    """
    Check if a mystery gift is available.
    """
    time_param = request.args.get('time', default='0') 

    if time_param == '0':
        last_mg_time = datetime.min
    else:
        # Deal with ruby's time.now format.
        last_mg_time = datetime.strptime(time_param, '%Y-%m-%d %H:%M:%S %z')

    with open("gifts.csv", "r") as file:
        gifts = file.readlines()
        gift = gifts[-1]

        bounds = gift.split(',')[:2]
        start_date = datetime.strptime(bounds[0], '%Y-%m-%d').replace(tzinfo=last_mg_time.tzinfo)
        end_date = datetime.strptime(bounds[1], '%Y-%m-%d').replace(tzinfo=last_mg_time.tzinfo)

        can_mystery_gift = start_date > last_mg_time and datetime.now() <= end_date
        # return str(can_mystery_gift), 200, {'Content-Type': 'text/plain'}
        return str(True), 200, {'Content-Type': 'text/plain'}


@app.route('/clear', methods=['GET'])
def clear_players():
    """
    Clear all players from memory
    """
    print("Clearing players...")
    players.clear()
    return jsonify({'status': 'All players cleared.'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000, debug=True)

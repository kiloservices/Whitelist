from flask import Flask, request, jsonify
import json
import os

app = Flask(__name__)

# Load keys from environment variable or use default for testing
VALID_KEYS = {
    "PlushyBear1010": {"hwid": None, "script_id": "1"},
    "TestKey123": {"hwid": None, "script_id": "1"}
}

@app.route('/validate', methods=['POST'])
def validate():
    try:
        # Get data from request
        data = request.get_json()
        if not data:
            return jsonify({'status': 'error', 'reason': 'No data provided'})
        
        user_key = data.get('key')
        user_hwid = data.get('hwid')
        script_id = data.get('script_id', '1')
        
        # Check if key exists
        if user_key not in VALID_KEYS:
            return jsonify({'status': 'invalid', 'reason': 'Invalid key'})
        
        key_data = VALID_KEYS[user_key]
        
        # HWID locking
        if key_data.get('hwid') is None:
            # First time use - lock it (in memory only)
            VALID_KEYS[user_key]['hwid'] = user_hwid
            print(f"Key {user_key} locked to HWID: {user_hwid}")
        elif key_data['hwid'] != user_hwid:
            return jsonify({'status': 'invalid', 'reason': 'HWID mismatch'})
        
        # Return success with a simple script
        script_content = """
-- Your protected script
print("Successfully loaded whitelisted script!")
game.Players.PlayerAdded:Connect(function(player)
    print(player.Name .. " joined with whitelist access!")
end)
"""
        
        return jsonify({'status': 'valid', 'script': script_content})
    
    except Exception as e:
        print(f"Error: {str(e)}")
        return jsonify({'status': 'error', 'reason': str(e)})

@app.route('/')
def home():
    return "Whitelist server is running!"

@app.route('/test')
def test():
    return jsonify({'status': 'online', 'message': 'Server is working!'})

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 10000))
    app.run(host='0.0.0.0', port=port)

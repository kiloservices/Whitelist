from flask import Flask, request, jsonify
import json
import os

app = Flask(__name__)

# Load keys from environment variable (set this in Render dashboard)
KEYS_JSON = os.environ.get('KEYS', '{}')
VALID_KEYS = json.loads(KEYS_JSON)

@app.route('/validate', methods=['POST'])
def validate():
    data = request.get_json()
    user_key = data.get('key')
    user_hwid = data.get('hwid')
    script_id = data.get('script_id', '1')
    
    # Check if key exists
    if user_key not in VALID_KEYS:
        return jsonify({'status': 'invalid', 'reason': 'Invalid key'})
    
    key_data = VALID_KEYS[user_key]
    
    # HWID locking
    if key_data.get('hwid') is None:
        # First time use - lock it
        VALID_KEYS[user_key]['hwid'] = user_hwid
        # In a real app, save this back to a database
    elif key_data['hwid'] != user_hwid:
        return jsonify({'status': 'invalid', 'reason': 'HWID mismatch'})
    
    # Read the actual Lua script
    try:
        with open(f'scripts/{script_id}.lua', 'r') as file:
            script_content = file.read()
        return jsonify({'status': 'valid', 'script': script_content})
    except:
        return jsonify({'status': 'invalid', 'reason': 'Script not found'})

@app.route('/')
def home():
    return "Whitelist server is running!"

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 10000))
    app.run(host='0.0.0.0', port=port)

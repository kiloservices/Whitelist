import os
from flask import Flask, request, jsonify
import json

app = Flask(__name__)

# --- !!! YOU MUST EDIT THIS SECTION !!! ---
# This is your simple "database". In a real app, use a real database.
# Format: "user_key": {"hwid": None or "actual_hwid", "script_id": "1"}
VALID_KEYS = {
    "PlushyBear1010": {"hwid": None, "script_id": "1"},  # <-- CHANGE THIS KEY
    "YourNewKeyHere": {"hwid": None, "script_id": "1"},   # <-- ADD YOUR KEYS
}
# --- END OF SECTION TO EDIT ---

# This function simulates fetching your actual Roblox script from a "file"
def get_script_content(script_id):
    """In a real project, you might fetch this from a raw GitHub URL or a file."""
    if script_id == "1":
        # This is the actual script that will be LOADED AND RUN in Roblox
        return """
-- YOUR ROBLOX SCRIPT STARTS HERE --
print("Whitelist successful! Your script is now running.")
--[[
    Put your entire game script here.
    For example:
    game.Players.PlayerAdded:Connect(function(player)
        player:LoadCharacter()
    end)
]]
-- YOUR ROBLOX SCRIPT ENDS HERE --
        """
    else:
        return None

@app.route('/validate', methods=['POST'])
def validate():
    # 1. Get the data sent from your Roblox loader
    data = request.get_json()
    user_key = data.get('key')
    user_hwid = data.get('hwid')
    script_id = data.get('script_id')

    # 2. Check if the key exists in our "database"
    key_data = VALID_KEYS.get(user_key)

    if not key_data:
        return jsonify({'status': 'invalid', 'reason': 'Invalid key'})

    # 3. Check HWID (Hardware ID) locking
    stored_hwid = key_data.get('hwid')

    if stored_hwid is None:
        # First time this key is used - lock it to this HWID
        VALID_KEYS[user_key]['hwid'] = user_hwid
        print(f"Key {user_key} locked to HWID: {user_hwid}")
    elif stored_hwid != user_hwid:
        # Key is already locked to a DIFFERENT computer
        return jsonify({'status': 'invalid', 'reason': 'HWID mismatch'})

    # 4. If all checks pass, get the script and send it back
    script_content = get_script_content(script_id)

    if script_content:
        return jsonify({'status': 'valid', 'script': script_content})
    else:
        return jsonify({'status': 'invalid', 'reason': 'Script not found'})

@app.route('/')
def home():
    return "Roblox Whitelist Server is Running!"

# This is required for Render to run the server
if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)

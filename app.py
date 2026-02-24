from flask import Flask, request, jsonify
import json
import os

app = Flask(__name__)

# Your valid keys - you can edit these
VALID_KEYS = {
    "PlushyBear1010": {"hwid": None, "script_id": "1"},
    "TestKey123": {"hwid": None, "script_id": "1"},
    "VIPMember456": {"hwid": None, "script_id": "1"}
}

@app.route('/validate', methods=['POST'])
def validate():
    try:
        # Get data from Roblox
        data = request.get_json()
        
        if not data:
            return jsonify({'status': 'error', 'reason': 'No data provided'})
        
        user_key = data.get('key')
        user_hwid = data.get('hwid')
        script_id = data.get('script_id', '1')
        
        print(f"Validation attempt - Key: {user_key}, HWID: {user_hwid}")
        
        # Check if key exists
        if user_key not in VALID_KEYS:
            return jsonify({'status': 'invalid', 'reason': 'Invalid key'})
        
        key_data = VALID_KEYS[user_key]
        
        # HWID locking
        if key_data.get('hwid') is None:
            # First time use - lock to this HWID
            VALID_KEYS[user_key]['hwid'] = user_hwid
            print(f"Key {user_key} locked to HWID: {user_hwid}")
        elif key_data['hwid'] != user_hwid:
            return jsonify({'status': 'invalid', 'reason': 'Key already in use on another device'})
        
        # Your protected script (this is what runs in Roblox)
        script_content = """
-- =====================================================
-- YOUR PROTECTED ROBLOX SCRIPT STARTS HERE
-- =====================================================

print("✅ Whitelist verified! Loading script...")

-- Your actual game code below
game.Players.PlayerAdded:Connect(function(player)
    print(player.Name .. " joined the game!")
    
    -- Example: Give them a tool or do something
    player:LoadCharacter()
    
    -- Chat message
    game:GetService("Chat"):Chat(player.Character.Head, "Welcome to the game!")
end)

-- Example function
local function onPlayerAdded(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
    
    local coins = Instance.new("NumberValue")
    coins.Name = "Coins"
    coins.Value = 100
    coins.Parent = leaderstats
end

game.Players.PlayerAdded:Connect(onPlayerAdded)

print("✅ Script loaded successfully!")

-- =====================================================
-- YOUR PROTECTED ROBLOX SCRIPT ENDS HERE
-- =====================================================
"""
        
        return jsonify({'status': 'valid', 'script': script_content})
        
    except Exception as e:
        print(f"Server error: {str(e)}")
        return jsonify({'status': 'error', 'reason': 'Server error'})

@app.route('/')
def home():
    return "Whitelist server is running!"

@app.route('/test')
def test():
    return jsonify({'status': 'online', 'message': 'Server is working!'})

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 10000))
    app.run(host='0.0.0.0', port=port)

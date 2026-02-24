local key = script_key
local HttpService = game:GetService("HttpService")

-- Function to get a reliable HWID
local function getReliableHWID()
    -- Method 1: Try RbxAnalyticsService (most common)
    local success, result = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    
    if success and result and result ~= "" then
        return result
    end
    
    -- Method 2: Try UserInputService
    success, result = pcall(function()
        return game:GetService("UserInputService"):GetUserId()
    end)
    
    if success and result and result ~= 0 then
        return "UIS_" .. result
    end
    
    -- Method 3: Use Players service
    success, result = pcall(function()
        local player = game.Players.LocalPlayer
        if player then
            return "PLAYER_" .. player.UserId .. "_" .. player.Name
        end
        return nil
    end)
    
    if success and result then
        return result
    end
    
    -- Method 4: Combine multiple identifiers
    local identifiers = {}
    
    -- Try to get various IDs
    pcall(function()
        table.insert(identifiers, game.GameId)
    end)
    
    pcall(function()
        table.insert(identifiers, game.PlaceId)
    end)
    
    pcall(function()
        table.insert(identifiers, game.JobId)
    end)
    
    pcall(function()
        local player = game.Players.LocalPlayer
        if player then
            table.insert(identifiers, player.UserId)
        end
    end)
    
    -- If we have any identifiers, combine them
    if #identifiers > 0 then
        return "COMBINED_" .. HttpService:JSONEncode(identifiers)
    end
    
    -- Final fallback: random but persistent ID using crypto
    return "FALLBACK_" .. game:GetService("HttpService"):GenerateGUID(false)
end

local hwid = getReliableHWID()

-- Send to your server
local success, response = pcall(function()
    return HttpService:PostAsync(
        "https://whitelist-p1kc.onrender.com/validate",
        HttpService:JSONEncode({ 
            key = key, 
            hwid = hwid, 
            script_id = "1" 
        }),
        Enum.HttpContentType.ApplicationJson
    )
end)

if not success then
    return error("Failed to connect to authentication server")
end

local data = HttpService:JSONDecode(response)

if data.status == "valid" then
    -- Load the protected script
    local loadSuccess, loadError = loadstring(data.script)
    if loadSuccess then
        loadSuccess()
    else
        error("Failed to load script: " .. tostring(loadError))
    end
else
    error("Authentication failed: " .. (data.reason or "Invalid key"))
end

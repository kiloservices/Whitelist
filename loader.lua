local HttpService = game:GetService("HttpService")

-- User must define before running:
-- script_key = "TESTKEY123"

local hwid = "executor-generated-hwid"

local response = game:HttpPost(
    "https://whitelist-610z.onrender.com",
    HttpService:JSONEncode({
        key = script_key,
        hwid = hwid
    }),
    Enum.HttpContentType.ApplicationJson
)

local data = HttpService:JSONDecode(response)

if not data.success then
    warn("Invalid key or HWID! " .. (data.message or ""))
    return
end

-- NOTE:
-- Executors need an AES decryption function here.
-- For testing, you can temporarily send plaintext from server instead.

loadstring(data.script)()

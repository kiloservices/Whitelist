import express from "express";
import fs from "fs";

const app = express();
app.use(express.json());

// 🔑 Simple in-memory license system
let licenses = {
    "PlushyBear1010": { hwid: null, script_id: "1" }
};

// /validate endpoint (called by loader)
app.post("/validate", (req, res) => {
    const { key, hwid, script_id } = req.body;
    const user = licenses[key];

    if (!user) return res.json({ status: "invalid" });
    if (user.script_id !== script_id) return res.json({ status: "no_access" });
    if (user.hwid && user.hwid !== hwid) return res.json({ status: "hwid_mismatch" });

    if (!user.hwid) user.hwid = hwid;

    // Read the real Roblox script
    const script = fs.readFileSync(`./scripts/${script_id}.lua`, "utf8");

    res.json({
        status: "valid",
        script: script
    });
});

// /loader/:id endpoint (what Roblox loads)
app.get("/loader/:id", (req, res) => {
    const script_id = req.params.id;

    res.type("text/plain").send(`
local key = script_key
local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
local HttpService = game:GetService("HttpService")

local response = game:HttpPost(
    "https://whitelist-p1kc.onrender.com/validate",
    HttpService:JSONEncode({ key = key, hwid = hwid, script_id = "${script_id}" }),
    Enum.HttpContentType.ApplicationJson
)

local data = HttpService:JSONDecode(response)

if data.status == "valid" then
    loadstring(data.script)()
else
    error("Authentication failed")
end
    `);
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(\`Server running on port \${PORT}\`));

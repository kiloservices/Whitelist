import express from "express";
import fs from "fs";

const app = express();
app.use(express.json());

let licenses = {
    "PlushyBear1010": { hwid: null, script_id: "1" }
};

app.post("/validate", (req, res) => {
    const { key, hwid, script_id } = req.body;
    const user = licenses[key];
    if (!user) return res.json({ status: "invalid" });
    if (user.script_id !== script_id) return res.json({ status: "no_access" });
    if (user.hwid && user.hwid !== hwid) return res.json({ status: "hwid_mismatch" });
    if (!user.hwid) user.hwid = hwid;

    let script = "";
    try {
        script = fs.readFileSync(`./scripts/${script_id}.lua`, "utf8");
    } catch (err) {
        return res.json({ status: "script_not_found" });
    }

    res.json({ status: "valid", script });
});

app.get("/loader/:id", (req, res) => {
    const script_id = req.params.id;
    res.type("text/plain").send(`
local key = script_key
local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
local HttpService = game:GetService("HttpService")

local response = HttpService:PostAsync(
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

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

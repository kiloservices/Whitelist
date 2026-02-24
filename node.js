app.get("/loader/:id", (req, res) => {
    res.type("text/plain").send(`
        local key = script_key
        local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
        local HttpService = game:GetService("HttpService")

        local response = game:HttpPost(
            "https://whitelist-p1kc.onrender.com",
            HttpService:JSONEncode({
                key = key,
                hwid = hwid,
                script_id = "${req.params.id}"
            }),
            Enum.HttpContentType.ApplicationJson
        )

        local data = HttpService:JSONDecode(response)

        if data.status == "valid" then
            loadstring(data.script)()
        else
            error("Authentication failed")
        end
    `)
})

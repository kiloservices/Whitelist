const express = require("express");
const fetch = require("node-fetch");
const app = express();

// === YOUR VALID KEYS ===
const VALID_KEYS = [
  "PlushyBear1010",
  "AnotherKey123",
  // Add more keys here
];

// === YOUR SCRIPT URL (raw GitHub URL with token for private repos) ===
const SCRIPT_URL = "https://raw.githubusercontent.com/YOURUSERNAME/YOURREPO/main/script.lua";
// For private repos, append: ?token=YOUR_GITHUB_PAT

app.get("/loader/:version", async (req, res) => {
  const key = req.query.key;
  const version = req.params.version;

  if (!key || !VALID_KEYS.includes(key)) {
    // Return a Lua error so the executor shows it
    return res.status(403).send(`error("❌ Invalid or missing key. Purchase a key at discord.gg/YOURDISCORD")`);
  }

  try {
    const scriptRes = await fetch(SCRIPT_URL);
    if (!scriptRes.ok) throw new Error("Failed to fetch script");
    const scriptContent = await scriptRes.text();
    res.setHeader("Content-Type", "text/plain");
    res.send(scriptContent);
  } catch (e) {
    res.status(500).send(`error("⚠️ Server error, try again later.")`);
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Whitelist API running on port ${PORT}`));

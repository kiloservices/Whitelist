import express from "express";

const app = express();
app.use(express.json());

let licenses = {
    "PlushyBear1010": { hwid: null },
};

app.post("/validate", (req, res) => {
    const { key, hwid } = req.body;

    if (!licenses[key]) {
        return res.json({ status: "invalid" });
    }

    if (licenses[key].hwid && licenses[key].hwid !== hwid) {
        return res.json({ status: "hwid_mismatch" });
    }

    if (!licenses[key].hwid) {
        licenses[key].hwid = hwid;
    }

    res.json({
        status: "valid",
        script: "print('Authorized user loaded script')"
    });
});

app.listen(3000, () => console.log("Server running"));

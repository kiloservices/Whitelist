# main.py
from fastapi import FastAPI
from pydantic import BaseModel
from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes
import base64
import os

app = FastAPI()

# ----------------------------
# In-memory license storage (replace with DB later)
licenses = {
    "TESTKEY123": {"hwid": None}
}

# Example script stored server-side
SCRIPT_CONTENT = 'print("Executor script running successfully!")'

SECRET_KEY = b"12345678901234567890123456789012"  # 32 bytes for AES-256

# ----------------------------
# Request model
class VerifyRequest(BaseModel):
    key: str
    hwid: str


# ----------------------------
# AES Encrypt Function
def encrypt_script(text: str):
    cipher = AES.new(SECRET_KEY, AES.MODE_CBC)
    padded_text = text + (16 - len(text) % 16) * chr(16 - len(text) % 16)
    encrypted = cipher.encrypt(padded_text.encode())
    return base64.b64encode(cipher.iv).decode() + ":" + base64.b64encode(encrypted).decode()


# ----------------------------
@app.post("/verify")
def verify_license(data: VerifyRequest):
    key = data.key
    hwid = data.hwid

    if key not in licenses:
        return {"success": False, "message": "Invalid key"}

    if licenses[key]["hwid"] is None:
        licenses[key]["hwid"] = hwid  # bind HWID first time

    if licenses[key]["hwid"] != hwid:
        return {"success": False, "message": "HWID mismatch"}

    encrypted_script = encrypt_script(SCRIPT_CONTENT)
    return {"success": True, "script": encrypted_script}


# ----------------------------
@app.get("/loader.lua")
def get_loader():
    with open("loader.lua", "r") as f:
        return f.read()

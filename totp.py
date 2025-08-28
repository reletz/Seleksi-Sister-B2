import pyotp
import base64
import os
from dotenv import load_dotenv

load_dotenv()

def totp():
  secret_key = os.getenv('TOTP_KEY')
  totp = pyotp.TOTP(base64.b32encode(secret_key.encode()))
  current_totp = totp.now()
  return current_totp

if __name__ == "__main__":
  print(totp())
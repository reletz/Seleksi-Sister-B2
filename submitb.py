import requests
import os
from totp import totp
import base64
from signature import create_string_signature
from dotenv import load_dotenv

load_dotenv()

TAHAP = 2
USER = os.getenv('USER')
GITHUB_URL = 'https://github.com/reletz/Seleksi-Sister-B2/tree/main'
URL_MATH = os.getenv('MATH_URL')
URL_SUBMIT = os.getenv('SUBMIT_B_URL')
PRIVATE_KEY = os.getenv('PRIVATE_KEY_FILE')

def submitb():
  response_math = requests.get(URL_MATH)
  
  if response_math.status_code != 200:
    print(f"Status: {response_math.status_code}, Response: {response_math.text}")
    return False

  data = response_math.json()
  question_string = data['question']
  math_problem = question_string.split('||')[0]
  math_answer = eval(math_problem)
  
  totp_code = totp()
  string_signature = create_string_signature(GITHUB_URL, PRIVATE_KEY)
  signature_b64 = base64.b64encode(string_signature)

  form_data = {
    "github_url": GITHUB_URL,
    "totp_code": totp_code,
    "math_question": question_string,
    "math_answer": math_answer,
    "signature": signature_b64.decode(),
    "tahap": TAHAP,
  }

  print("Mengirim jawaban...")
  try:
    response_submit = requests.post(URL_SUBMIT, params={"username": USER}, json=form_data)

    print(f"Status Code Pengiriman: {response_submit.status_code}")
    print(f"Response Pengiriman: {response_submit.text}")

    return response_submit.status_code == 200

  except requests.exceptions.RequestException as e:
    print(f"Terjadi error saat request: {e}")
    return False

if __name__ == "__main__":
  submitb()
import requests
import base64
import os
from dotenv import load_dotenv
from totp import totp

load_dotenv()

USERNAME = os.getenv('USERNAME')
PASSWORD = os.getenv('PASSWORD')
URL_MATH = os.getenv('MATH_URL')
URL_UPDATE_KEY = os.getenv('UPDATE_URL')
PUBLIC_KEY_FILE = os.getenv('PUBLIC_KEY_FILE')

def update_public_key():
    with open(PUBLIC_KEY_FILE, "rb") as f:
        public_key = f.read()
    public_key_b64 = base64.b64encode(public_key).decode('utf-8')
    print(f"Kunci publik baru (base64): {public_key_b64[:30]}...")

    print("\nMeminta soal matematika untuk otentikasi...")
    try:
        response_math = requests.get(URL_MATH)
        if response_math.status_code != 200:
            print(f"Gagal mendapatkan soal: {response_math.text}")
            return
        
        data_math = response_math.json()
        question_string = data_math['question']
        math_problem = question_string.split('||')[0]
        math_answer = eval(math_problem)

    except requests.RequestException as e:
        print(f"Error saat meminta soal: {e}")
        return

    update_payload = {
        "username": USERNAME,
        "password": PASSWORD,
        "totp_code": totp(),
        "math_question": question_string,
        "math_answer": math_answer,
        "new_public_key": public_key_b64
    }

    print("\nMengirim request untuk update public key...")
    try:
        response_update = requests.post(URL_UPDATE_KEY, json=update_payload)
        
        print(f"\n--- HASIL UPDATE KUNCI ---")
        print(f"Status Code: {response_update.status_code}")
        print(f"Response: {response_update.text}")
        
        if response_update.status_code == 200:
            print("\nSUKSES! Kunci publik berhasil diperbarui di server.")
            print("Sekarang kamu bisa menggunakan 'private_shake.key' untuk membuat signature.")
        else:
            print("\nGAGAL! Kunci publik tidak berhasil diperbarui.")

    except requests.RequestException as e:
        print(f"Error saat mengirim request update: {e}")

if __name__ == "__main__":
    update_public_key()

import os
from dotenv import load_dotenv

load_dotenv()
PUBLIC_KEY_FILE = os.getenv('PUBLIC_KEY_FILE')
PRIVATE_KEY_FILE = os.getenv('PRIVATE_KEY_FILE')

def generate_sphincs_keys():
  """Menghasilkan dan menyimpan pasangan kunci SPHINCS+."""
  try:
    import pqcrypto.sign.sphincs_shake_256s_simple as sphincs
    public_key, private_key = sphincs.generate_keypair()
    
    with open(PUBLIC_KEY_FILE, "wb") as f:
      f.write(public_key)
    with open(PRIVATE_KEY_FILE, "wb") as f:
      f.write(private_key)
        
    print("Kunci SHAKE baru berhasil dibuat dan disimpan.")
    return public_key, private_key
  except Exception as e:
    print(f"Terjadi error: {e}")
    return None, None

if __name__ == "__main__":
  generate_sphincs_keys()
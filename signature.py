from pqcrypto.sign.sphincs_shake_256s_simple import sign
def create_pdf_signature(file_path, private_key_path):
  with open(private_key_path, "rb") as f:
    private_key = f.read()

  with open(file_path, "rb") as f:
    file_content = f.read()
      
  signed_hash = sign(private_key, file_content);
  return signed_hash

def create_string_signature(link, private_key_path):
  with open(private_key_path, "rb") as f:
    private_key = f.read()
      
  signed_hash = sign(private_key, link.encode());
  return signed_hash
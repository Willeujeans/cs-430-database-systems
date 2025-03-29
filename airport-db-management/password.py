import hashlib

def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()

password = "your password"
hashed_password = hash_password(password)
print("SHA-256 hashed password:", hashed_password)

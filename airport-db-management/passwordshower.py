import hashlib
print(hashlib.sha256('yourpassword'.encode()).hexdigest())
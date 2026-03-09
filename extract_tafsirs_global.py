import urllib.request
import json
import ssl

url = "https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/editions.min.json"
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
response = urllib.request.urlopen(req, context=ctx)
data = json.loads(response.read().decode())

print("--- Searching for specific Tafsirs globally ---")
for key, meta in data.items():
    name = meta.get('name', '').lower()
    author = meta.get('author', '').lower()
    
    if any(kw in name or kw in author for kw in ['kathir', 'sadi', 'tabari', 'qurtubi', 'baghawi', 'muyassar', 'jalal']):
        print(f"ID: {key}")
        print(f"Name: {meta.get('name')}")
        print(f"Author: {meta.get('author')}")
        print(f"Language: {meta.get('language')}")
        print("-" * 30)

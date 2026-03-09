import json
import urllib.request

url = "https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/editions.min.json"
response = urllib.request.urlopen(url)
data = json.loads(response.read().decode())

arabic_tafsirs = []
for key, meta in data.items():
    lang = meta.get('language', '').lower()
    name_val = meta.get('name', '').lower()
    author = meta.get('author', '').lower()
    
    # Heuristics for Tafsir
    keywords = ['tafsir', 'tafseer', 'jalaladdinalmah', 'kathir', 'sadi', 'tabari', 'qurtubi', 'baghawi', 'muyassar', 'mukhtasar']
    is_tafsir = any(kw in f"{name_val} {author}" for kw in keywords)
    
    if (lang == 'arabic' or lang == 'ar' or key.startswith('ara-')) and is_tafsir:
        arabic_tafsirs.append({
            'id': key.replace('_', '-'),
            'name': meta.get('name'),
            'author': meta.get('author')
        })

print(json.dumps(arabic_tafsirs, indent=2, ensure_ascii=False))

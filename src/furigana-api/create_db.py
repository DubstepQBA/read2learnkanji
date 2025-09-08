import json
import sqlite3
import os

print("Starting database creation...")

# Path to the JSON file
base_dir = os.path.dirname(os.path.abspath(__file__))
json_path = os.path.join(base_dir, '..', '..', 'src', 'furigana-api', 'jmdict_all_eng.json')
db_path = os.path.join(base_dir, 'jmdict.db')

# Connect to the SQLite database (this will create the file if it doesn't exist)
conn = sqlite3.connect(db_path)
c = conn.cursor()

# Create table with separate fields for kanji and kana forms to allow quick lookups
c.execute('''
    CREATE TABLE IF NOT EXISTS words (
        id INTEGER PRIMARY KEY,
        kanji_form TEXT,
        kana_form TEXT,
        translations TEXT
    )
''')
conn.commit()

# Read and process the JSON data
with open(json_path, 'r', encoding='utf-8') as f:
    jmdict = json.load(f).get("words", [])

    data_to_insert = []
    print(f"Found {len(jmdict)} entries to process. This may take a few minutes...")
    for entry in jmdict:
        if not isinstance(entry, dict):
            continue

        translations = [
            gloss.get("text", "")
            for sense in entry.get("sense", [])
            for gloss in sense.get("gloss", [])
            if gloss.get("lang") == "eng"
        ]
        
        main_translation = "/".join(translations[:3])

        # We will create an entry for each kanji form and a separate one for each kana form
        kanji_forms = [kf.get("text") for kf in entry.get("kanji", [])]
        kana_forms = [kf.get("text") for kf in entry.get("kana", [])]

        if kanji_forms:
            for kf in kanji_forms:
                data_to_insert.append((kf, None, main_translation))
        if kana_forms:
            for naf in kana_forms:
                data_to_insert.append((None, naf, main_translation))

# Insert all data at once for efficiency
c.executemany("INSERT INTO words (kanji_form, kana_form, translations) VALUES (?, ?, ?)", data_to_insert)
conn.commit()
conn.close()

print("Database created successfully! The file 'jmdict.db' is ready to use.")
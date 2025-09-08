import sqlite3
import json
import os
import re

db_path = 'jmdict.db'
json_path = 'jmdict_common_eng.json'

if os.path.exists(db_path):
    os.remove(db_path)
    print(f"Existing database file '{db_path}' removed.")

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

cursor.execute('''
CREATE TABLE words (
    kanji_form TEXT,
    kana_form TEXT,
    translations TEXT
)
''')
conn.commit()

try:
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    to_insert = []
    
    # Process the 'words' list from the JSON data
    for word_entry in data.get('words', []):
        kanji_form = None
        # Find the common kanji form
        common_kanji = [k['text'] for k in word_entry.get('kanji', []) if k.get('common')]
        if common_kanji:
            kanji_form = common_kanji[0]
        elif word_entry.get('kanji'):
            kanji_form = word_entry['kanji'][0]['text']

        kana_form = None
        # Find the common kana form
        common_kana = [k['text'] for k in word_entry.get('kana', []) if k.get('common')]
        if common_kana:
            kana_form = common_kana[0]
        elif word_entry.get('kana'):
            kana_form = word_entry['kana'][0]['text']

        translations = []
        # Collect all English translations from all senses
        for sense in word_entry.get('sense', []):
            for gloss in sense.get('gloss', []):
                if gloss.get('lang') == 'eng':
                    translations.append(gloss.get('text'))
        
        # Join the translations into a single string
        translations_str = " | ".join(translations)

        to_insert.append((kanji_form, kana_form, translations_str))

    insert_query = "INSERT INTO words (kanji_form, kana_form, translations) VALUES (?, ?, ?)"
    cursor.executemany(insert_query, to_insert)
    conn.commit()
    
    print(f"Loaded {len(to_insert)} words and successfully inserted into the database.")

except FileNotFoundError:
    print(f"Error: The file '{json_path}' was not found.")
except Exception as e:
    print(f"An error occurred: {e}")
finally:
    conn.close()
import re
import mysql.connector

def run():
    print("Connecting...")
    conn = mysql.connector.connect(
        host="institutoj17.sg-host.com",
        user="ubr7awxothprf",
        password="ISUJ123/2026",
        database="dbg4rp1niwrzmg"
    )
    cursor = conn.cursor()

    print("Fetching banco_id...")
    cursor.execute("SELECT id FROM bancos_preguntas LIMIT 1")
    row = cursor.fetchone()
    if not row:
        print("No banco_id found!")
        return
    banco_id = row[0]

    # Clean existing questions
    cursor.execute("DELETE FROM preguntas")
    
    # Read database_setup.php
    with open('../Server/PHP_API/database_setup.php', 'r', encoding='utf-8') as f:
        content = f.read()

    # Find all insertQuestion calls
    # Format: $insertQuestion('¿Pregunta?', [ ['Op1', false], ['Op2', true], ... ]);
    pattern = r"\$insertQuestion\(\s*'([^']+)'\s*,\s*\[\s*(.+?)\s*\]\s*\);"
    matches = re.findall(pattern, content, re.DOTALL)
    
    print(f"Found {len(matches)} questions.")
    
    for q_text, options_block in matches:
        cursor.execute("INSERT INTO preguntas (banco_id, texto_pregunta) VALUES (%s, %s)", (banco_id, q_text))
        pid = cursor.lastrowid
        
        # Options format: ['1998', false], ['2002', true], ...
        opt_pattern = r"\['([^']+)'\s*,\s*(true|false)\s*\]"
        opts = re.findall(opt_pattern, options_block)
        for opt_text, opt_is_correct in opts:
            is_correct = 1 if opt_is_correct == 'true' else 0
            cursor.execute("INSERT INTO respuestas (pregunta_id, texto_respuesta, es_correcta) VALUES (%s, %s, %s)", (pid, opt_text, is_correct))

    conn.commit()
    print("Inserted all questions successfully!")
    cursor.close()
    conn.close()

if __name__ == '__main__':
    run()

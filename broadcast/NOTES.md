## 1. Architektur
- **Client (cX)**: Testtreiber von Maelstrom. Sendet Anfragen (`init`, `broadcast`, `read`, `broadcast_ok`).  
- **Node (nX)**: Unsere eigene Implementierung. Verarbeitet Nachrichten, speichert Zustand, kommuniziert mit Nachbarn.  
- **Nachrichtenfluss**: JSON über STDIN/STDOUT.  

---

## 2. Nachrichtentypen
### Vom Client -> Node
- `init` -> Node antwortet `init_ok`.  
- `topology` -> Node speichert Nachbarn, antwortet `topology_ok`.  
- `broadcast` -> Node speichert Wert, verbreitet an Nachbarn, antwortet `broadcast_ok`.  
- `read` -> Node antwortet mit `read_ok` und allen gespeicherten Werten.  

### Zwischen Nodes
- `broadcast` -> Gossip, **kein `msg_id`**, daher keine Antwort nötig.  
- `broadcast_ok` -> ACK für Gossip, um Nachricht als zugestellt zu markieren.  

---

## 3. Wichtige Felder
- `msg_id`: Sequenznummer, **wird vom Absender vergeben**.  
- `in_reply_to`: Verweist auf `msg_id` der ursprünglichen Anfrage.  
- `src` / `dest`: IDs von Sender und Empfänger.  

---

## 4. Fehlerbilder
- **`{:src missing-required-key}`** -> Antwort ohne `src` oder `dest`.  
- **`CaseClauseError`** -> Nachrichtentyp im `process/…` nicht behandelt.  
- **Timeout bei GenServer** -> blockierende Aufrufe (`call`) nicht aufgelöst.  

---

## 5. Resilienz / Partitionen
- Netzwerk kann Nachrichten **fallen lassen** (Partition).  
- Lösung:  
  - Jeder Gossip erhält `msg_id`.  
  - Empfänger sendet `broadcast_ok`.  
  - Sender wiederholt Nachricht, bis ACK kommt.  

---
```mermaid
sequenceDiagram
    participant C as Client (cX)
    participant N1 as Node (n1)
    participant N2 as Node (n2)

    C->>N1: init (msg_id=1)
    N1-->>C: init_ok (in_reply_to=1)

    C->>N1: topology (msg_id=2)
    N1-->>C: topology_ok (in_reply_to=2)

    C->>N1: broadcast (msg_id=3, message=42)
    N1-->>C: broadcast_ok (in_reply_to=3)

    N1->>N2: broadcast (no msg_id, message=42)
    N2-->>N1: broadcast_ok (msg_id=4, in_reply_to=3)

    C->>N1: read (msg_id=5)
    N1-->>C: read_ok (in_reply_to=5, messages=[42])
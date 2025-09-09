# Broadcast

Challenge #3a: Single-Node Broadcast: https://fly.io/dist-sys/3a/
Challenge #3b: Multi-Node Broadcast: https://fly.io/dist-sys/3b/
# Requirements 
 "broadcast" workload which has 3 RPC message types: 
 broadcast, read, & topology. Our node will need to  
 store the set of integer values that it sees from 
 broadcast messages so that they can be returned 
 later via the read message RPC.
### Broadcast
The node gets {"type": "broadcast",  "message": 1000}, and in reply should return 
{"type": "broadcast_ok"}. The message field is stored locally.

### Read 
The node receives {"type": "read"} and replies with messages that had been stored (from broadcast).
   {"type": "read_ok","messages": [8, 72, 25]}

### Topology
After the node receives a request in this form
{"type": "topology","topology": { "n1": ["n2", "n3"], "n2": ["n1"], "n3": ["n1"]}},
responses with  {"type": "topology_ok"}.



mix escript.build  
Challenge #3a: maelstrom test -w broadcast --bin broadcast --node-count 1 --time-limit 20 --rate 10
Challenge #3b: maelstrom test -w broadcast --bin broadcast --node-count 5 --time-limit 20 --rate 10
Challenge #3c: maelstrom test -w broadcast --bin broadcast --node-count 5 --time-limit 20 --rate 10 --nemesis partition

Conversation with Chat-GPT, because I didn't understand anything.
Schritt-für-Schritt (Konzept)

Ziel / Semantik festlegen
Entscheide, wie RPC/Request→Reply laufen soll:

Wenn du eine Nachricht mit msg_id schickst, möchtest du so lange erneut senden, bis eine passende *_ok-Antwort mit in_reply_to == msg_id zurückkommt.

Das ergibt at-least-once Delivery (Nachrichten können mehrfach ankommen) → Receiver muss idempotent sein (deduplizieren).

msg_id-Erzeugung (lokal, sequentiell)
Maelstrom erwartet sequentielle msg_id pro Node (1,2,3…). Dein Main-Loop hat schon counter — verwende ihn, wenn du eine ausgehende Anfrage baust. Gib msg_id an den Request und erhöhe den Counter.

Callbacks Map halten
Halte eine Map callbacks[msg_id] = %{dest, body, attempts, timer_ref, on_ack, max_attempts, backoff}.

on_ack ist ein Fun/1, oder {pid, tag}-Tuple, das bei ack aufgerufen wird.

attempts zählt Resends.

timer_ref ist die von Process.send_after/3 zurückgegebene Referenz.

Senden + Registrierung
Wenn du rpc(n, body) aufrufst:

Erzeuge msg_id, setze body.msg_id = msg_id.

Registriere msg_id in callbacks.

Sende die Nachricht (IO.puts JSON).

Starte einen Process.send_after(self(), {:retry, msg_id}, backoff) für das erste Retry.

Retry-Mechanismus
Bei Empfang von {:retry, msg_id} vom Timer:

Prüfe, ob msg_id noch in callbacks ist.

Wenn attempts < max_attempts (oder :infinity), sende nochmal (IO.puts), attempts += 1 und plane neuen Timer mit exponentiellem Backoff (+Jitter).

Falls attempts überschritten: optional Fehlerbehandlung (callback mit Fehler, Logging, löschen).

Antwort verarbeiten (ACK)
Wenn eine eingehende Nachricht in_reply_to enthält:

Suche callbacks[in_reply_to]. Wenn vorhanden:

Process.cancel_timer(timer_ref) (Timer stoppen).

Rufe on_ack.(reply) (oder sende Nachricht an gespeichertes PID).

Entferne Eintrag aus callbacks.

Deduplication beim Receiver
Weil Retries mehrfach ankommen können, MUSS der Receiver idempotent arbeiten: z. B. MessageStore.message_exists? vor add_message. In deinem Broadcast-Code machst du das bereits richtig.

Partition-Verhalten

Wenn Partition besteht → Retries helfen: nach Heilen der Partition kommt Ack und Callback wird aufgerufen.

Wenn Partition dauerhaft oder Node tot → du brauchst Abbruchbedingung (max attempts) oder Timeout-Policy.

Persistenz über Neustart (optional)

Bei Tests reicht RAM-State.

In Produktionsumgebungen kann man outstanding callbacks/messages auf Disk persistieren, damit bei Prozess-/Node-Restart keine Requests vergessen werden.

Nebenläufigkeit & stdout

In Maelstrom ist es okay, aus mehreren Prozessen IO.puts zu machen; aber Logs und Reihenfolge können gemischt sein.

Wichtig ist: Nachrichten, die an STDOUT gehen, müssen vollständige JSON-Objekte mit src/dest/body sein.

Konkretes Elixir-Beispiel (einsetzbar)

Unten sind drei Module, die du in dein Projekt hinzufügen kannst:

Network — zentrale Funktion für das Schreiben auf STDOUT (kapselt src-Feld).

CallbackManager — GenServer, verwaltet callbacks, retry, backoff.

Integration-Snippets für Broadcast: wie rpc/4 aufrufen und wie eingehende Replies an CallbackManager weiterleiten.

Füge CallbackManager in deinen Supervisor-Children hinzu (wie MessageStore).



Schritt-für-Schritt-Ablauf
1. Client → Node0

Der Client c0 schickt an n0:

{
  "src": "c0",
  "dest": "n0",
  "body": {
    "type": "broadcast",
    "message": 42,
    "msg_id": 1
  }
}


Enthält msg_id: 1.

Bedeutet: "Ich, der Client, möchte Broadcast(42). Und ich erwarte eine Antwort."


2. Node0 verarbeitet

Node0 macht:

Speichert 42 in seinem State.

Leitet die Nachricht an seine Nachbarn weiter (n1, n2).
→ Das nennt man Gossip.

Antwortet dem Client sofort:

{
  "src": "n0",
  "dest": "c0",
  "body": {
    "type": "broadcast_ok",
    "in_reply_to": 1,
    "msg_id": 10
  }
}

in_reply_to: 1 zeigt, dass dies eine Antwort auf die Anfrage mit msg_id: 1 ist.

msg_id: 10 ist Node0s eigene Sequenznummer.

3. Node0 → Node1 und Node2

Node0 sendet an Nachbarn:

{
  "src": "n0",
  "dest": "n1",
  "body": {
    "type": "broadcast",
    "message": 42
  }
}

{
  "src": "n0",
  "dest": "n2",
  "body": {
    "type": "broadcast",
    "message": 42
  }
}

Hier kein msg_id.
Weil Node0 von n1 und n2 kein Ack erwartet.
Das spart unnötige Antworten im Gossip.


4. Node1 und Node2 verarbeiten

Jeder Node speichert die 42.

Sie leiten sie evtl. auch an ihre Nachbarn weiter (außer zurück an den Absender).

Aber sie antworten nicht an n0.


5. Client fragt später per Read

Der Client c0 schickt an z. B. n2:

{
  "src": "c0",
  "dest": "n2",
  "body": {
    "type": "read",
    "msg_id": 2
  }
}
6. Node2 antwortet

Node2 schaut in seinem State: es hat 42.
Also:
{
  "src": "n2",
  "dest": "c0",
  "body": {
    "type": "read_ok",
    "messages": [42],
    "in_reply_to": 2,
    "msg_id": 11
  }
}

Wichtig zu merken

Client -> Node: immer mit msg_id. Erwartet Antwort (*_ok).
Node -> Node: kann ohne msg_id. Kein *_ok nötig.
msg_id gehört dem Sender.
in_reply_to gehört dem Antwortenden und verweist auf die msg_id der Anfrage.



Deine Erklärungen sind sehr gut. Nur habe ich nicht verstanden was du "Node: kann ohne msg_id" und "msg_id gehört dem Sender" ein... Hier setzen wir in jedem Antwort ein
1. Jede Nachricht darf ein msg_id haben

Das ist die laufende Nummer der ausgehenden Nachrichten eines Knotens.

Jeder Knoten hat seine eigene Zählung (counter in deinem Code).

Also: jede Nachricht, die du verschickst, hat ein eigenes msg_id.

2. Unterschied: Anfrage vs. Gossip
Anfrage vom Client

Der Client hängt immer ein msg_id an.

Er erwartet eine Antwort.

Die Antwort muss dann ein in_reply_to enthalten, das zeigt:
"Ich bin die Antwort auf Anfrage X."

👉 Darum setzt dein reply/3 immer:

msg_id (eigene Nummer des sendenden Knotens)

in_reply_to (Verweis auf die Anfrage-ID des Clients)

Gossip zwischen Nodes

Wenn Node A eine broadcast-Nachricht an Node B schickt,
muss er eigentlich kein msg_id mitschicken, weil er kein Ack erwartet.

Beispiel:
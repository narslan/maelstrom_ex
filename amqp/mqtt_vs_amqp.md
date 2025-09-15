# Vergleich: MQTT vs. AMQP

| **Eigenschaft**        | **MQTT** 🛰️ | **AMQP** 📦 |
|-------------------------|--------------|-------------|
| **Protokolltyp**        | Spezielles **Pub/Sub-Protokoll** | Generisches **Messaging-Protokoll** |
| **Primitive**           | `CONNECT`, `SUBSCRIBE`, `PUBLISH`, `UNSUBSCRIBE` | Frames, Exchanges, Queues, Bindings |
| **Pub/Sub**             | **Im Protokoll eingebaut** – `SUBSCRIBE` auf ein Topic ist Teil der Spezifikation | **Nicht Teil des Protokolls** – wird durch Broker-Konzepte (z. B. fanout exchange + queue bindings) nachgebildet |
| **Routing**             | Einfaches Topic-Matching (`/sensor/temp`) | Mächtiges Routing via Exchanges (`direct`, `fanout`, `topic`, `headers`) |
| **QoS (Delivery)**      | 0 = at most once, 1 = at least once, 2 = exactly once | Ack/Nack, Transaktionen, persistente Queues – sehr flexibel |
| **Nachrichtenmodell**   | Leichtgewichtig, nur `topic`-basierte Pub/Sub | Vollständig: Point-to-Point, Pub/Sub, Work Queues, RPC usw. |
| **Zielgruppe**          | IoT, mobile Geräte, ressourcenschwache Clients | Enterprise Messaging, komplexe Systeme |
| **Overhead**            | Sehr gering (perfekt für constrained devices) | Schwergewichtiger (Frame-basiert, mehr Metadaten) |
| **Broker-Beispiele**    | Mosquitto, HiveMQ, EMQX | RabbitMQ, Apache Qpid, ActiveMQ (mit AMQP) |

---

## Fazit

- **MQTT = Pub/Sub first** → Alles dreht sich um Topics und Nachrichten zwischen Publisher und Subscriber.  
- **AMQP = Messaging-Baukasten** → Mit den primitiven Bausteinen kannst du *Pub/Sub nachbauen*, aber auch Work-Queues, Load-Balancing, Routing, RPC usw.

1. Was AMQP ist

AMQP (Advanced Message Queuing Protocol) ist in erster Linie ein Wire-Level-Protokoll – also eine Spezifikation, wie Nachrichten zwischen Clients und Broker transportiert werden.
Es definiert u.a.:

wie Frames aufgebaut sind

wie Nachrichten bestätigt werden

wie Queues, Exchanges und Bindings modelliert sind


2. Beispiel

In MQTT:
Client A SUBSCRIBE /topic/sensors
Client B PUBLISH /topic/sensors
→ Der Broker verteilt automatisch an alle Subscriber.

In AMQP:

Du legst einen fanout exchange an.

Subscriber binden ihre Queue an den Exchange.

Publisher schickt Nachrichten an den Exchange.
→ Ergebnis ist funktional gleich, aber es ist kein Protokoll-Primitive, sondern ein Pattern auf Basis der AMQP-Bausteine.


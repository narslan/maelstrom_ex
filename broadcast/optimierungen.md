Optimierungen 

Optimierungsschritte
1. Topologie optimieren

Standardmäßig nutzt man Full Mesh: jeder Node kennt alle anderen → riesige Redundanz.

Versuch stattdessen:

Baum (spanning tree): jeder Node hat nur wenige Eltern/Kinder → jede Nachricht macht weniger Hops.

Ring mit Abzweigungen: senkt msgs-per-op dramatisch.

In Maelstrom kannst du die Nachbarschaft über --topology steuern oder in deinem Code die Neighbors-Liste so filtern, dass nicht jeder Node mit allen anderen spricht.

2. ACK-Strategie vereinfachen

Im aktuellen Code:

d. h. du trackst jedes gesendete Paket und wartest auf broadcast_ok.
AckManager.track(msg_id, neighbor, body)
In der Maelstrom-Doku steht aber:

„We don’t actually need to send broadcast_ok for every retransmission. Once a node has a message, we don’t care about further delivery acknowledgements.“

Das heißt:

Du musst nicht jedes Paket mit ACKs bestätigen.

Stattdessen reicht: nur initiale Anfrage vom Client bestätigen.

Alle internen Gossip-Nachrichten laufen unbestätigt → spart 30–50 % Nachrichten.

3. Anti-Entropy / Periodisches Gossip

Statt jede Nachricht sofort an alle Nachbarn zu pushen:

Push einmal an die Nachbarn.

Falls ein Nachbar eine Nachricht verpasst, bekommt er sie später bei einem periodischen Gossip („hey, hier ist meine aktuelle Menge an Nachrichten“).

Das verringert msgs-per-op nochmal stark, weil du nicht so aggressiv retransmittest.

4. Datenstrukturen verbessern

Wenn dein MessageStore ein normales Map ist, könnte das Lookup (message_exists?) relativ teuer werden, besonders bei tausenden Nachrichten.

Verwende MapSet (O(1) Lookup) oder ETS (noch schneller für große Mengen).

Geringere CPU-Zeit → kürzere Latenzen.

5. Parallelisierung

Prüfe, ob deine Stream-Pipelines blockierend sind.

Eventuell lohnt es sich, Nachrichtenversand in Task.async oder über einen GenServer zu parallelisieren.

Das kann Latenzen pro Nachricht senken, wenn dein Node aktuell synchron zu viel macht.

Konkrete Empfehlung für dein Ziel

msgs-per-op runter auf 30:

Bau auf message_exists?/1 auf, aber schalte ACK-Tracking für Gossip-Nachrichten ab.

Überlege, die Topologie von „vollständig verbunden“ auf „Baum“ oder „Ring“ zu reduzieren.

stable median latency < 400 ms:

Optimier den MessageStore (MapSet oder ETS).

Entferne unnötige ACKs → weniger Overhead → geringere Antwortzeiten.

Falls nötig: periodisches Gossip mit kleinem Intervall (reduziert Staus).
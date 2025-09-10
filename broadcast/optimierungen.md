Anti-Entropy effizienter machen

Statt komplette Nachrichtenlisten zu schicken → nur Deltas oder Hashes (z. B. Bloomfilter oder Digest-Ansatz).

Ziel: weniger Bandbreite, weniger Overhead, bessere Latenzen bei Partitionen.

Persistente Nachbarschaften weiter optimieren

Experimentieren: feste Ring-Topologie vs. zufällige Shortcuts.

Schauen, ob eine dynamische Auswahl (nicht immer die gleichen 2–3 Nachbarn) bessere Verbreitungsgeschwindigkeit bringt.

Failure/Partition Recovery robuster machen

Nach Partitionen: gezieltes Sync (statt blind alle Nachrichten).

Kandidat: "Pull"-Mechanismus → Node fragt Nachbarn explizit nach fehlenden Nachrichten.
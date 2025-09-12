
mix escript.build
maelstrom test -w g-counter --bin gcounter --time-limit 20 --rate 10
# Gcounter

Frage: Am Ende einer Dokumentation von Maelstrom ( "Counters") wird gesagt: "We've successfully built an AP counter service!". 
Ich dachte immer die CRDT dienen dazu, 
Konsistenz zu erzielen, nicht unbedingt die Verfügbarkeit.

ChatGPT: 

1. AP vs. CP im CAP-Theorem

  CP (Consistency + Partition tolerance):
  Das System garantiert strikte Konsistenz auch bei Partitionen, dafür kann es unverfügbar werden (z. B. Blockieren von Writes bis Partition vorbei ist).

  AP (Availability + Partition tolerance):
  Das System garantiert, dass jede Anfrage irgendwann eine Antwort bekommt, auch wenn Partitionen bestehen. Dafür nimmt man in Kauf, dass die Antworten zunächst nicht konsistent sind (z. B. ein Read sieht noch nicht alle Updates).

2. CRDTs und "AP"

1. CRDTs (Conflict-free Replicated Data Types) wurden genau dafür entworfen:
- Sie machen es möglich, dass alle Nodes immer Writes akzeptieren (keine Sperre, keine Koordination). -> hohe Availability.

- Partitionen sind tolerierbar, weil die Updates später durch Merges zusammengeführt werden.

- Am Ende (nach genügend Kommunikation) garantieren sie eventual consistency.

Das ist ein AP-Verhalten: auch wenn eine Partition vorliegt, kannst du weiter „add“ oder „increment“ machen; die Knoten nehmen es an, und später, nach Merge, stimmt wieder alles.

3. Warum nicht CP?

Um CP bei einem Counter zu erreichen, müsstest du z. B. bei jedem Increment sicherstellen, dass alle Replikate sofort denselben Wert sehen (Linearizierbarkeit).
Das würde bedeuten:

- Quorum-Protokolle,

- Paxos/Raft-ähnliche Leader-Mechanismen,

- Blockieren, wenn keine Mehrheit erreichbar ist.

Das opfert Availability bei Partitionen.

- CRDT-basierte Counters in Maelstrom sind AP: immer verfügbar, aber nur „eventual consistent“.

- CP-Counter wäre ein völlig anderes Design: „strong consistency“, aber dann müssen Writes bei Partitionen fehlschlagen oder warten.

Frage: Als "eventual consistent" meinen wir dass das System später Konsistenz erreicht, nicht wahr?

Genau 👍

„Eventual consistency“ bedeutet:

Jetzt, während Partitionen oder Verzögerungen: verschiedene Nodes können unterschiedliche Stände haben (z. B. Counter auf n1 = 5, auf n2 = 8).

Später, nachdem alle Nachrichten durch Anti-Entropy/Replication wieder geflossen sind: alle Nodes erreichen denselben Zustand (n1 = n2 = 8).

Also:

keine Garantie über wann sie gleich sind,

aber die Garantie, dass sie irgendwann gleich sind, solange Kommunikation wieder möglich wird.
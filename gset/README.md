# Gset

## Was ist ein CRDT?

Ein CRDT ist ein Datentyp für verteilte Systeme, der sicherstellt, dass alle Replikate durch bloßes Austauschen von Informationen irgendwann denselben Zustand erreichen, ohne globale Locks oder Konsensus.

Beispiele:

- G-Set (Grow-only Set): du kannst nur Elemente hinzufügen; Merge = Union.

- PN-Counter: du kannst hoch- und runterzählen; Merge = komponentenweise Maximum.

- OR-Set (Observed-Remove Set): erlaubt auch das Entfernen von Elementen, mit etwas Buchhaltung.

- LWW-Register (Last-Writer-Wins): ein Wert, der durch Timestamp dominiert wird.


## Lektionen aus der G-Set Aufgabe

1. Nicht immer optimieren – manchmal reicht "brute force":
- Statt mühsam rauszufinden, wer welche Elemente schon kennt, schicken wir regelmäßig den gesamten Zustand an unsere Nachbarn.
- Das ist ineffizient, aber robust. Egal ob Nachrichten verloren gehen oder Partitionen auftreten: späterer Sync bringt alle wieder auf denselben Stand.

2. Das Prinzip „Union“ als Konfliktlösung:
  Bei Sets gibt es keine Reihenfolge oder Konflikte.
  Die Regel lautet: Mein Set = Union(Mein Set, Dein Set)
  Damit wird kein Element jemals „vergessen“ oder überschrieben.

3. CRDT Grundgedanke sichtbar:
Das Set in dieser Aufgabe ist ein ganz einfaches CRDT:
- Conflict-Free Replicated Data Type

- mathematisch so gebaut, dass das Zusammenführen von Zuständen immer zu einem korrekten Ergebnis führt

- Eigenschaften: assoziativ, kommutativ, idempotent
  egal in welcher Reihenfolge du Nachrichten empfängst
  egal wie oft du dasselbe Element siehst
  das Endergebnis ist immer konsistent


- Bei der Counter-Aufgabe geht es wieder um dasselbe Muster.

- Statt Set hast du hier ein Counter-CRDT, meist in der Form:

- Jeder Knoten hat seinen eigenen Zählerteil.

- Der globale Wert ist die Summe aller Teile.

- Beim Merge nimmst du das Maximum von jedem Knotenstand, nicht die Summe (sonst würdest du Doppeltzählungen bekommen).

Das Schema ist dasselbe:

- Zustand speichern

- regelmäßig replizieren

- lokale Operationen casten

- Merge-Operation idempotent halten
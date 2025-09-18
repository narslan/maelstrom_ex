Newroz: Ich setze mich jetzt mit txn-list-append und künftig mit  weiteren Workloads. Das Ziel ist ein Key-Value Store implementieren, welches verteilt und transaktional sei. Dabei wollen wir "strict serializability" der Transaktionen zu schaffen.

CAP & Design-Tradeoffs: 
strikte Serialisierbarkeit (linearizability) + Partition-Toleranz ist nur erreichbar wenn du unter Partitionen Verfügbarkeit opferst (CP).
CRDTs sind AP (verfügbar + eventual consistency).

Eventual Consistency vs Strict/Linearizable:

Eventual: akzeptiere Writes lokal, replikation heilt später (Anti-Entropy / full set / delta / digest).
	Replication patterns:

	Full push (Anti-Entropy): simpel, robust, teuer.

	Digest / pull: effizient, verlangt zusätzliche protocol steps.

	Leader/quorum (Raft/Paxos): für strong guarantees.
	
Strict serializability: jede Transaktion sieht eine Serien-Order wie bei einer single-threaded Ausführung -> erfordert Koordination (Sequencer / Leader / consensus).
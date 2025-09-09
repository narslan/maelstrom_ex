# Broadcast

Challenge #3a: Single-Node Broadcast: https://fly.io/dist-sys/3a/
Challenge #3b: Multi-Node Broadcast: https://fly.io/dist-sys/3b/
Challenge #3c: Fault Tolerant Broadcast: https://fly.io/dist-sys/3b/
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


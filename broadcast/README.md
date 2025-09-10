# Broadcast

Challenge #3a: Single-Node Broadcast: https://fly.io/dist-sys/3a/
Challenge #3b: Multi-Node Broadcast: https://fly.io/dist-sys/3b/
Challenge #3c: Fault Tolerant Broadcast: https://fly.io/dist-sys/3c/
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

### Usage: 
mix escript.build  
Challenge #3a: maelstrom test -w broadcast --bin broadcast --node-count 1 --time-limit 20 --rate 10
Challenge #3b: maelstrom test -w broadcast --bin broadcast --node-count 5 --time-limit 20 --rate 10
Challenge #3c: maelstrom test -w broadcast --bin broadcast --node-count 5 --time-limit 20 --rate 10 --nemesis partition


# Performence improvements 
Challenge #3d: Efficient Broadcast, Part I: https://fly.io/dist-sys/3d/

## Requirements: 
- Messages-per-operation is below 30
- Median latency is below 400ms
- Maximum latency is below 600ms

Test with:
```edn
 maelstrom test -w broadcast --bin broadcast --node-count 25 --time-limit 20 --rate 100 --latency 100
```
This means maelstrom generates 20 x 100 = 2000 requests (client requests) per seconds.
:msgs-per-op 91.452805 means, that we exchanged 91 messages per operation.
Results without any optimizations:
Messages-per-operation: 91.452805
Median latency:  459 ms
Maximum latency: 797 ms

## Improvements: 
### Overhead Optimization, Limiting Fanout

Problem: We broadcast a message back to the server which sent it to us. 
Solution: We add a check up to skip sending a broadcast back to the server which sent it to us.

Results:

```edn
 maelstrom test -w broadcast --bin broadcast --node-count 25 --time-limit 20 --rate 100 --latency 100
Messages-per-operation: 68.28761
Median latency:  451 ms
Maximum latency: 787 ms
```
Fazit: Reduction in messages-per-operation (~%20).

###  Not to send ACK Messages in internode Communication.
"We don’t actually need to send broadcast_ok for gossip messages… once a node has a message, we don’t care about further delivery acknowledgements"

Messages-per-operation: 26.9332
Median latency:  459 ms
Maximum latency: 797 ms
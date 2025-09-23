# Uniqe Id Generation

Challenge #2: Unique ID Generation https://fly.io/dist-sys/2/

In this challenge, we build a globally unique ID generator.

# Requirements 
- It should continue to operate even in the face of network partitions. (Partition tolerant)

```sh
mix escript.build  
./maelstrom test -w unique-ids --bin uniq_id --time-limit 30 --rate 1000 --node-count 3 --availability total --nemesis partition
```
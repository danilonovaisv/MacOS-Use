# Graph Report - raw  (2026-09-16)

## Corpus Check
- 51 files · ~77,998 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 7 file(s) not represented in the graph (top: (none) 7)

## Summary
- 271 nodes · 390 edges · 21 communities (10 shown, 11 thin omitted)
- Extraction: 94% EXTRACTED · 6% INFERRED · 0% AMBIGUOUS · INFERRED: 22 edges (avg confidence: 0.92)
- Token cost: 15,000 input · 3,200 output

## Community Hubs (Navigation)
- Standard Library Utilities
- Micrograd Autograd Engine
- nanoGPT Training & Benchmarks
- Core Math & Introspection
- minGPT BPE Tokenizer
- Attention Mechanisms & Literature
- minGPT Transformer Architecture
- minGPT Adder Experiment
- minGPT Character Generation
- Micrograd Visual Artifacts
- Package Setup & Distribution
- minGPT Generation & Inference
- Bandit Algorithms & Recommendation

## God Nodes (most connected - your core abstractions)
1. `Value` - 24 edges
2. `CfgNode` - 18 edges
3. `GPT` - 15 edges
4. `GPT` - 13 edges
5. `Trainer` - 12 edges
6. `AdditionDataset` - 10 edges
7. `CharDataset` - 10 edges
8. `Neuron` - 8 edges
9. `BPETokenizer` - 8 edges
10. `Layer` - 7 edges

## Surprising Connections (you probably didn't know these)
- `Micrograd Computation Graph (Root)` --references--> `Value`  [INFERRED]
  gout.svg → micrograd/micrograd/engine.py
- `FlashAttention Algorithm` --semantically_similar_to--> `Scaled Dot-Product Attention`  [INFERRED] [semantically similar]
  flashattention.pdf → attention.pdf
- `minGPT PyTorch Implementation` --references--> `Transformer Architecture`  [INFERRED]
  minGPT/README.md → attention.pdf
- `nanoGPT Training & Fine-Tuning` --references--> `FlashAttention Algorithm`  [INFERRED]
  nanoGPT/README.md → flashattention.pdf
- `Binary Classification Decision Surface` --semantically_similar_to--> `Moon Dataset Decision Boundary`  [INFERRED] [semantically similar]
  moon_mlp.png → micrograd/moon_mlp.png

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Transformer Evolution & Efficient Attention** — attention_transformer, flashattention_algorithm, flashattention2_algorithm, nanogpt_readme_overview [INFERRED 0.85]

## Communities (21 total, 11 thin omitted)

### Community 0 - "Standard Library Utilities"
Cohesion: 0.06
Nodes (31): ast, collections, json, GPT, Full definition of a GPT Language Model, all of it in this single file.…, Initialize a pretrained GPT model by copying over the weights from a…, This long function is unfortunately doing something very simple and is being…, Simple training loop; Boilerplate that could apply to any arbitrary neural… (+23 more)

### Community 1 - "Micrograd Autograd Engine"
Cohesion: 0.06
Nodes (12): stores a single scalar value and its gradient, Value, _backward(), build_topo(), Layer, MLP, Module, Neuron (+4 more)

### Community 2 - "nanoGPT Training & Benchmarks"
Cohesion: 0.09
Nodes (20): contextlib, datasets, A much shorter version of train.py for benchmarking, Prepare the Shakespeare dataset for character-level language modeling. So…, GPTConfig, Sample from a trained model, estimate_loss(), get_batch() (+12 more)

### Community 3 - "Core Math & Introspection"
Cohesion: 0.08
Nodes (15): dataclasses, inspect, math, Block, CausalSelfAttention, GPT, LayerNorm, MLP (+7 more)

### Community 4 - "minGPT BPE Tokenizer"
Cohesion: 0.08
Nodes (21): BPETokenizer, bytes_to_unicode(), Encoder, get_encoder(), get_file(), get_pairs(), bpe is short for Byte Pair Encoder. It translates arbitrary utf-8 strings into…, string goes in, list of integers comes out (+13 more)

### Community 5 - "Attention Mechanisms & Literature"
Cohesion: 0.10
Nodes (22): Multi-Head Attention, Positional Encoding, Scaled Dot-Product Attention, Transformer Architecture, FlashAttention-2, Work Partitioning & Parallelism, FlashAttention Algorithm, IO-Aware Attention (+14 more)

### Community 6 - "minGPT Transformer Architecture"
Cohesion: 0.20
Nodes (6): Block, CausalSelfAttention, NewGELU, Implementation of the GELU activation function currently in Google BERT repo…, A vanilla multi-head masked self-attention layer with a projection at the end.…, an unassuming Transformer block

### Community 7 - "minGPT Adder Experiment"
Cohesion: 0.22
Nodes (3): AdditionDataset, Dataset, Creates n-digit addition problems. For example, if n=2, then an example…

### Community 8 - "minGPT Character Generation"
Cohesion: 0.22
Nodes (3): CharDataset, Dataset, Emits batches of characters

### Community 9 - "Micrograd Visual Artifacts"
Cohesion: 0.40
Nodes (5): Micrograd Computation Graph (DAG), Moon Dataset Decision Boundary, Micrograd Mascot Image, Micrograd Engine & Neural Net, Binary Classification Decision Surface

## Knowledge Gaps
- **20 isolated node(s):** `Positional Encoding`, `IO-Aware Attention`, `Tiling and Softmax Recomputation`, `Work Partitioning & Parallelism`, `CoCoB Bandit Framework` (+15 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 146 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **11 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Value` connect `Micrograd Autograd Engine` to `Micrograd Visual Artifacts`?**
  _High betweenness centrality (0.188) - this node is a cross-community bridge._
- **Why does `CfgNode` connect `Standard Library Utilities` to `minGPT Character Generation`, `minGPT Adder Experiment`?**
  _High betweenness centrality (0.091) - this node is a cross-community bridge._
- **Why does `GPT` connect `Standard Library Utilities` to `minGPT Generation & Inference`, `minGPT BPE Tokenizer`, `minGPT Transformer Architecture`?**
  _High betweenness centrality (0.082) - this node is a cross-community bridge._
- **Are the 3 inferred relationships involving `Value` (e.g. with `Neuron` and `Micrograd Engine & Neural Net`) actually correct?**
  _`Value` has 3 INFERRED edges - model-reasoned connections that need verification._
- **Are the 4 inferred relationships involving `CfgNode` (e.g. with `GPT` and `Trainer`) actually correct?**
  _`CfgNode` has 4 INFERRED edges - model-reasoned connections that need verification._
- **Are the 4 inferred relationships involving `GPT` (e.g. with `CfgNode` and `get_config()`) actually correct?**
  _`GPT` has 4 INFERRED edges - model-reasoned connections that need verification._
- **Are the 3 inferred relationships involving `Trainer` (e.g. with `CfgNode` and `get_config()`) actually correct?**
  _`Trainer` has 3 INFERRED edges - model-reasoned connections that need verification._
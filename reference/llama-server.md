# `llama-server` Exhaustive Technical Reference Guide

## Abstract

This document serves as an exhaustive, graduate-level technical reference for `llama-server`, the high-performance HTTP model serving daemon provided by the `llama.cpp` ecosystem. It meticulously dissects the entirety of its command-line interface parameters. The analysis is highly pedantic, catering specifically to infrastructure engineers, HPC (High-Performance Computing) systems administrators, and machine learning researchers who require absolute, granular control over large language model (LLM) inference topologies, memory allocation strategies, and stochastic sampling mathematics. **Every single flag** present in the daemon's schema is cataloged and demystified herein.

---

## 1. Systemic Execution & Administrative Directives

These parameters dictate the fundamental execution states, telemetry output, and diagnostic verbosity of the server daemon.

*   `-h, --help, --usage`: Instantiates the immediate termination of the process, emitting the standard usage schema to stdout.
*   `--version`: Outputs the compiled version heuristics and specific build architecture parameters before terminating.
*   `--license`: Exposes the source code licensing agreements and immediate dependency acknowledgments.
*   `-cl, --cache-list`: Enumerates the inventory of model artifacts currently resident within the systemic cache hierarchy.
*   `--completion-bash`: Synthesizes and emits a source-able Bash completion script, facilitating CLI tab-completion dynamics for `llama.cpp` implementations.
*   `--verbose-prompt`: Forces the system to dump a verbose, token-by-token evaluation of the prompt before executing auto-regressive generation (default: false).
*   `--log-disable`: Completely suppresses the internal logging engine, effectively silencing `stderr` and `stdout` telemetry.
*   `--log-file FNAME`: Redirects the standard telemetry stream to a specified persistent file artifact `FNAME`.
*   `--log-colors [on|off|auto]`: Mandates the employment of ANSI escape sequence color coding in the log stream. `auto` applies heuristics to determine if the output target is a TTY.
*   `-v, --verbose, --log-verbose`: Maximizes the log verbosity to absolute infinity, instrumental for deep topological debugging.
*   `-lv, --verbosity, --log-verbosity N`: Establishes a strict threshold for the telemetry stream: `0` (generic), `1` (error), `2` (warning), `3` (info), `4` (debug) (default: 3).
*   `--log-prefix`: Prefixes all generated log messages with contextual categorization strings.
*   `--log-timestamps`: Integrates high-precision chronometric timestamps into every log message payload.
*   `--perf, --no-perf`: Dictates the collection and emission of internal `libllama` micro-benchmarking performance timings (default: false).

## 2. Hardware Orchestration and CPU Affinity Management

These flags strictly govern POSIX thread (pthread) spawning, busy-wait polling strategies, and core-level affinity masks, crucial for mitigating context-switching latency in multi-core and NUMA architectures.

*   `-t, --threads N`: Defines the absolute integer count of CPU threads mobilized during the auto-regressive generation phase. `-1` employs automatic hardware query deduction.
*   `-tb, --threads-batch N`: Allocates the thread count explicitly dedicated to the computationally dense prefill (prompt processing) batch operations.
*   `-C, --cpu-mask M`: Imposes an arbitrarily long hexadecimal CPU affinity mask, strictly pinning generation threads to precise logical cores.
*   `-Cr, --cpu-range lo-hi`: A complementary syntactical sugar to `--cpu-mask`, allowing the definition of CPU affinity via integer ranges.
*   `--cpu-strict <0|1>`: Rigidly enforces the aforementioned CPU placement directives, circumventing OS-level scheduler migrations (default: 0).
*   `--prio N`: Modulates the underlying process/thread scheduling priority. Scale ranges from `-1` (low) to `3` (realtime).
*   `--poll <0...100>`: Determines the aggressiveness of the busy-wait polling loop when anticipating thread work. High polling (`100`) minimizes dispatch latency at the cost of maximum power consumption.
*   `-Cb, --cpu-mask-batch M`: The affinity mask equivalent dedicated purely to the batch processing thread pool.
*   `-Crb, --cpu-range-batch lo-hi`: The CPU range descriptor for the batch processing thread pool.
*   `--cpu-strict-batch <0|1>`: The strict enforcement toggle for batch processing thread placement.
*   `--prio-batch N`: Scheduling priority mapping specifically for batch threads.
*   `--poll-batch <0|1>`: The aggressive polling toggle dedicated to the batch processing lifecycle.
*   `--numa TYPE`: Executes complex Non-Uniform Memory Access (NUMA) mitigations. `distribute` spreads execution across memory nodes, `isolate` traps execution within the instantiation node, and `numactl` blindly defers to external CPU maps.
*   `-td, --threads-draft N`: The integer count of threads allocated for evaluating the smaller speculative decoding draft model.
*   `-tbd, --threads-batch-draft N`: The thread count allocated for the batch processing phase of the speculative draft model.
*   `--threads-http N`: Defines the concurrency pool size for parsing and responding to asynchronous HTTP requests independent of the inference thread pools.

## 3. Context, Batching, and KV Cache Topologies

These configurations mathematically bound the latent context constraints and the memory architecture of the Key-Value cache.

*   `-c, --ctx-size N`: The absolute scalar dimension of the maximum sequence context. `0` inherits the pre-defined architectural limit encoded within the GGUF model metadata.
*   `-n, --predict, --n-predict N`: Restricts the maximum integer count of tokens the model is permitted to auto-regressively generate per request. `-1` denotes infinity (until `EOS`).
*   `-b, --batch-size N`: The logical maximum volume of tokens the server can aggregate across independent requests before dispatching a parallelized compute execution.
*   `-ub, --ubatch-size N`: The physical micro-batch threshold. This defines the atomized matrix size dispatched natively to the backend BLAS implementation.
*   `--keep N`: Preserves a specified block of `N` initial prompt tokens from being purged during forced context-window truncation/shifting.
*   `--swa-full`: Forces the allocation of a comprehensive Sliding Window Attention (SWA) cache, bypassing memory-conserving sparse allocations.
*   `-fa, --flash-attn [on|off|auto]`: Mandates the employment of Dao-style Flash Attention kernels, yielding mathematical equivalence but drastically reducing intermediate memory staging (VRAM I/O).
*   `-kvo, --kv-offload, -nkvo, --no-kv-offload`: A critical toggle dictating whether the massive, stateful Key-Value cache is pushed into the high-bandwidth VRAM of parallel accelerators or relegated to system RAM.
*   `-ctk, --cache-type-k TYPE`: The numerical precision assigned to the Key cache. Values span `f32`, `f16`, `bf16`, and various quantizations (`q8_0`, `q4_0`, `iq4_nl`, etc.).
*   `-ctv, --cache-type-v TYPE`: The respective numerical precision assigned to the Value cache.
*   `-ctkd, --cache-type-k-draft TYPE`: The specific Key cache precision allocated to the speculative draft model.
*   `-ctvd, --cache-type-v-draft TYPE`: The specific Value cache precision allocated to the speculative draft model.
*   `-dt, --defrag-thold N`: **[DEPRECATED]** Historically used to govern the fragmentation threshold before triggering a KV cache defragmentation sweep.
*   `--cache-prompt, --no-cache-prompt`: Enables stateful prompt caching, preserving the computed KV matrices of common prompt prefixes across distinct HTTP requests.
*   `--cache-reuse N`: Specifies the minimal contiguous chunk size (in tokens) necessary to merit a KV shift operation to reuse a cached prompt segment.
*   `--context-shift, --no-context-shift`: Facilitates infinite generative loops by purging older token context blocks and rolling the context window forward seamlessly rather than halting generation upon exhaustion.
*   `-cd, --ctx-size-draft N`: Specifies a distinct prompt context dimension explicitly for the speculative draft model.

## 4. VRAM Allocation and Multi-GPU Parallelism

This cluster strictly governs how tensors are spatially distributed across high-performance compute accelerators (GPUs).

*   `-ngl, --gpu-layers, --n-gpu-layers N`: Dictates the precise scalar count of transformer blocks to migrate from system RAM into accelerator VRAM. Supports `auto` for VRAM capacity estimation and `all` for complete migration.
*   `-sm, --split-mode {none,layer,row}`: Selects the spatial distribution paradigm for multi-GPU arrays. `layer` implements sequential tensor parallelism (sharding distinct layers to distinct GPUs). `row` shards individual weight matrices mathematically across GPUs.
*   `-ts, --tensor-split N0,N1,N2,...`: A comma-delimited proportionality vector explicitly dictating the asymmetric distribution of VRAM allocation across enumerated accelerator devices (e.g., `3,1`).
*   `-mg, --main-gpu INDEX`: Designates the primary orchestrator GPU responsible for intermediate aggregations, residual states, and KV storage when `split-mode` is `row` or `none`.
*   `-dev, --device <dev1,dev2,..>`: A precise string constraint binding inference execution to explicitly declared device indices (e.g., bypassing a specific GPU).
*   `--list-devices`: Scans the system buses and emits a structured list of compatible accelerator devices before terminating.
*   `-fit, --fit [on|off]`: An automatic heuristic engine that aggressively down-scales parameters (like context size) to forcibly fit the model within hard VRAM constraints to prevent Out-Of-Memory (OOM) aborts.
*   `-fitt, --fit-target MiB0,MiB1,MiB2,...`: Defines the safety margin padding (in Megabytes) left unallocated by the `--fit` algorithm for each targeted GPU.
*   `-fitc, --fit-ctx N`: Establishes the absolute minimal context window threshold the `--fit` mechanism is allowed to scale down to before failing gracefully.
*   `-ngld, --gpu-layers-draft, --n-gpu-layers-draft N`: Determines the number of VRAM-resident transformer layers specifically for the speculative draft model.
*   `-devd, --device-draft <dev1,dev2,..>`: Offloads the draft model to a completely distinct physical accelerator array, physically isolating draft compute from main compute.

## 5. Weights, Models, and Latent Space Manipulation

Parameters handling the ingestion, patching, overriding, and mapping of internal parameter weights from persistent storage or remote repositories.

*   `-m, --model FNAME`: The primary filesystem path traversing to the quantized GGUF model artifact.
*   `-mu, --model-url MODEL_URL`: Ingests model weights via an HTTP/HTTPS stream buffer directly into execution.
*   `-dr, --docker-repo [<repo>/]<model>[:quant]`: Fetches model artifacts utilizing the Docker Hub repository registry protocols.
*   `-hf, -hfr, --hf-repo <user>/<model>[:quant]`: Dynamically resolves and pulls model weights utilizing the Hugging Face hub API topology.
*   `-hfd, -hfrd, --hf-repo-draft <user>/<model>[:quant]`: Dynamically pulls the speculative decoding draft model from the Hugging Face hub.
*   `-hff, --hf-file FILE`: Bypasses default quantization selections and forces the retrieval of a specific file nomenclature from the specified Hugging Face repository.
*   `-hft, --hf-token TOKEN`: The Bearer authentication token necessary for traversing gated or private Hugging Face repositories.
*   `-md, --model-draft FNAME`: The local filesystem path pointing to the secondary, smaller GGUF file used for speculative hypotheses.
*   `--offline`: Severely restricts network egress, forcing the system to rely strictly on locally cached artifacts and preventing hub telemetry.
*   `-ot, --override-tensor <tensor name pattern>=<buffer type>,...`: A highly volatile flag allowing dynamic runtime patching of specific tensor arrays into defined buffer types (e.g., forcing a specific weight array into FP32).
*   `-otd, --override-tensor-draft <tensor...>`: Applies the tensor override schema directly to the speculative draft model.
*   `--override-kv KEY=TYPE:VALUE,...`: Mutates the fundamental GGUF Key-Value metadata header upon instantiation. Examples include injecting `tokenizer.ggml.add_bos_token=bool:false`.
*   `--lora FNAME`: Dynamically injects Low-Rank Adaptation (LoRA) matrices into the resident weights at runtime, mathematically patching the linear projections.
*   `--lora-scaled FNAME:SCALE,...`: Injects LoRA matrices while applying an explicit scalar multiplier to the adapter weights before summation.
*   `--lora-init-without-apply`: Pre-loads the LoRA adapters into memory but deliberately delays their mathematical application until explicitly commanded via a POST request to `/lora-adapters`.
*   `--control-vector FNAME`: Loads and applies a latent activation control vector to steer model alignment dynamically.
*   `--control-vector-scaled FNAME:SCALE,...`: Applies the control vector manipulated by a precise intensity scalar.
*   `--control-vector-layer-range START END`: Restricts the mathematical application of the control vector to an explicitly bounded range of intermediate transformer layers.
*   `-cmoe, --cpu-moe`: Intercepts the routing of Mixture of Experts (MoE) gating and forces all constituent expert weights to remain pinned in system RAM, preventing VRAM overflow in massive multi-expert models.
*   `-ncmoe, --n-cpu-moe N`: Specifically forces only the first `N` layers of MoE weights to remain in system RAM.
*   `-cmoed, --cpu-moe-draft`, `-ncmoed, --n-cpu-moe-draft N`: Applies the CPU-bound MoE routing directives directly to the speculative draft model.
*   `--repack, -nr, --no-repack`: Toggles the internal weight repacking routines optimized for target backend memory layouts (default: enabled).
*   `--mlock`: Issues a strict POSIX `mlock()` syscall, forcing the entire loaded model artifact to remain physically pinned in RAM, totally circumventing OS swap partitions.
*   `--mmap, --no-mmap`: Leverages the zero-copy `mmap()` syscall to map the file directly into virtual memory. Disabling this enforces a slower, manual memory load which mitigates page faults on memory-starved deployments.
*   `-dio, --direct-io, -ndio, --no-direct-io`: Circumvents the operating system's page cache layer entirely via `O_DIRECT`, streaming data linearly from NVMe directly to RAM/VRAM buffers.
*   `--no-host`: Bypasses standard host buffer allocation, streamlining operations for highly customized external buffer managers.
*   `--op-offload, --no-op-offload`: Dictates whether host-bound tensor operations (non-matrix-multiplication ops) should be iteratively offloaded to compute devices.
*   `--check-tensors`: Enforces rigorous computational validity checks against model tensors during initialization, explicitly searching for `NaN` or `Inf` anomalies.
*   `--embd-gemma-default`, `--fim-qwen-1.5b-default`, `--fim-qwen-3b-default`, `--fim-qwen-7b-default`, `--fim-qwen-7b-spec`, `--fim-qwen-14b-spec`, `--fim-qwen-30b-default`, `--gpt-oss-20b-default`, `--gpt-oss-120b-default`, `--vision-gemma-4b-default`, `--vision-gemma-12b-default`: A suite of absolute macro flags that automatically orchestrate the download, configuration, and structural instantiation of deeply specific ecosystem models.

## 6. RoPE Scaling and Positional Embedding Dynamics

Parameters manipulating the mathematical extrapolation or interpolation of sequence positions when context limits exceed training topologies.

*   `--rope-scaling {none,linear,yarn}`: Selects the fundamental algorithmic approach to contextual expansion: standard linear interpolation or advanced YaRN interpolation.
*   `--rope-scale N`: A simplistic linear multiplicative scalar expanding the context threshold boundary.
*   `--rope-freq-base N`: Overrides the base sinusoidal frequency parameter used within Neural Tangent Kernel (NTK) aware scaling architectures.
*   `--rope-freq-scale N`: Operates as an inverse scalar (factor of `1/N`) mapping dimensional embeddings into higher frequencies.
*   `--yarn-orig-ctx N`: Defines the original, pre-trained context domain necessary for the YaRN algorithm to identify interpolation boundaries.
*   `--yarn-ext-factor N`: A highly specific extrapolation mix multiplier; `0.0` mandates absolute interpolation, while higher numbers map boundary values to extrapolated curves.
*   `--yarn-attn-factor N`: Scales the attention magnitude or adjustments made against $\sqrt{d_k}$ parameters to counter entropy dispersion.
*   `--yarn-beta-slow N`, `--yarn-beta-fast N`: Dimensional correction coefficients for high and low YaRN dimensions, strictly managing interpolation banding.

## 7. Probabilistic Sampling and Constraint Algorithms

These directives control the non-deterministic statistical distribution and mathematical truncation of token logit arrays prior to token selection.

*   `--samplers SAMPLERS`: An explicit, semicolon-delimited execution pipeline dictating the sequential order in which sampling algorithms manipulate the logit distribution (e.g., `penalties;top_k;temperature`).
*   `-s, --seed SEED`: Injects a deterministic integer into the Random Number Generator (RNG) engine. `-1` relies on atmospheric system entropy.
*   `--sampler-seq, --sampling-seq SEQUENCE`: Provides a simplified, single-character string sequence mapping to define the sampling pipeline (e.g., `edskypmxt`).
*   `--ignore-eos`: Statistically nullifies the End-Of-Sequence (EOS) token by asserting infinite negative logit bias against it, forcing unbounded generation.
*   `--temp, --temperature N`: Modulates the Boltzmann temperature ($T$). As $T \rightarrow 0$, distribution approaches deterministic argmax.
*   `--dynatemp-range N`, `--dynatemp-exp N`: Introduces dynamic temperature fluctuation mapped algorithmically to the intrinsic entropy of the momentary logit distribution state.
*   `--top-k N`: Truncates the probability mass entirely, leaving only the $k$ highest-probability tokens.
*   `--top-p N`: Implements Nucleus Sampling by severing the lowest-probability tokens iteratively until the cumulative probability mass equals $P$.
*   `--min-p N`: Truncates any token whose absolute probability evaluates to less than $P_{max} \times N$ (where $P_{max}$ is the apex token's probability).
*   `--top-nsigma, --top-n-sigma N`: Discards tokens whose probability falls beyond $N$ standard deviations from the distribution mean.
*   `--xtc-probability N`, `--xtc-threshold N`: XTC (eXclude Top Choice) Sampling modifiers; probabilistically filters or penalizes tokens above a specific threshold to enforce variance.
*   `--typical, --typical-p N`: Enforces Locally Typical Sampling by favoring tokens whose information content closely matches the expected entropy of the sequence.
*   `--repeat-last-n N`: The look-back sequence length bounded to analyze context for upcoming penalizations.
*   `--repeat-penalty N`: A multiplicative division algorithm applied to the logits of tokens that have previously appeared in the defined look-back window.
*   `--presence-penalty N`: Applies a rigid, static additive deduction against the logits of previously materialized tokens.
*   `--frequency-penalty N`: Applies an additive logit deduction that scales linearly based on the exact frequency count of a token's prior occurrences.
*   `--dry-multiplier N`, `--dry-base N`, `--dry-allowed-length N`, `--dry-penalty-last-n N`: Implements DRY (Don't Repeat Yourself) sampling logic, calculating complex back-off penalties aggressively targeting sequence loops explicitly defined by a given length boundary.
*   `--dry-sequence-breaker STRING`: Provides semantic string delimiters (like `\n` or `:`) that reset the DRY penalty accumulators.
*   `--adaptive-target N`, `--adaptive-decay N`: Drives Adaptive Nucleus Sampling by programmatically shifting the target sequence probability over time based on an exponential decay curve.
*   `--mirostat N`, `--mirostat-lr N`, `--mirostat-ent N`: Engages the Mirostat (Version 1 or 2) control theory algorithm. Mirostat continuously monitors distribution cross-entropy, dynamically modulating probability to adhere to a target entropy (`tau`) via a learning rate (`eta`), rendering traditional Top-K/P truncations obsolete.
*   `-l, --logit-bias TOKEN_ID(+/-)BIAS`: Manually forces a mathematical integer addition or subtraction against the raw logit of a explicitly identified vocabulary `TOKEN_ID`.
*   `--grammar GRAMMAR`, `--grammar-file FNAME`: Injects a rigid Backus-Naur Form (BNF) grammar parser directly into the logit selection pipeline, guaranteeing output conformity to strict syntax structures.
*   `-j, --json-schema SCHEMA`, `-jf, --json-schema-file FILE`: Forces output constraints via a generalized JSON Schema structural definition, implemented internally as dynamic BNF.
*   `-bs, --backend-sampling`: Re-routes probability sampling algorithms natively into the compute backend architecture (GPU) rather than executing on the host CPU.

## 8. Continuous Batching & Server Slot Administration

High-throughput server orchestration paradigms managing HTTP request queues and isolated memory states.

*   `-np, --parallel N`: Declares the absolute upper bound of concurrent server "slots". Each slot isolates an independent contextual generation trajectory.
*   `-cb, --cont-batching, -nocb, --no-cont-batching`: Activates continuous (dynamic) batching iteration. This continuously ejects completed queries from the active batch and injects new queued queries simultaneously, avoiding static batch blocking delays.
*   `-kvu, --kv-unified, -no-kvu, --no-kv-unified`: Merges all independent slot KV buffers into a single contiguous unified buffer architecture to drastically mitigate memory fragmentation.
*   `-sps, --slot-prompt-similarity SIMILARITY`: Implements a mathematical vector distance threshold (from `0.0` to `1.0`). If a new prompt prefix overlaps sufficiently with an existing slot's cached KV prefix, the server bypasses prefilling and immediately hijacks the existing slot context.
*   `-ctxcp, --ctx-checkpoints, --swa-checkpoints N`: Sets the absolute maximum density of internal context state checkpoints to generate and preserve within the execution slot logic.
*   `-cpent, --checkpoint-every-n-tokens N`: Dictates the stride length (in tokens) between generating subsequent context checkpoints during the prefill processing pipeline.
*   `-cram, --cache-ram N`: A hard byte-constraint (in MiB) capping the systemic expansion of the overall cache infrastructure.
*   `--slot-save-path PATH`: Specifies the absolute filesystem path target for persisting serialized binary dumps of the active KV cache slot states.
*   `-lcs, --lookup-cache-static FNAME`: Injects a static, immutable lookup cache mapping array.
*   `-lcd, --lookup-cache-dynamic FNAME`: Points to a dynamic lookup mapping dictionary actively mutated during auto-regressive generation.

## 9. Speculative Decoding Frameworks

Orchestrating multi-model latency mitigations where lightweight models hypothesize sequences that larger models verify iteratively in massive parallel blocks.

*   `--draft, --draft-n, --draft-max N`: The absolute maximum token count the draft model is permitted to heuristically project ahead of the verification model.
*   `--draft-min, --draft-n-min N`: The minimum threshold of speculative tokens required before invoking the verification batch.
*   `--draft-p-min P`: Dictates the minimum greedy probability threshold the draft model must satisfy to permit a speculative token into the verification queue.
*   `--spec-replace TARGET DRAFT`: An explicit string replacement mapping enabling the architectural compatibility alignment between dissimilar target and draft vocabulary models.
*   `--spec-type [none|ngram-cache|ngram-simple|ngram-map-k|ngram-map-k4v|ngram-mod]`: When an external neural draft model is absent, this engages heuristic, statistical caching algorithms (e.g., $N$-gram sequence mapping) to serve as the speculative drafting engine.
*   `--spec-ngram-size-n N`: Defines the scalar dimension $N$ for the $N$-gram prefix lookup window.
*   `--spec-ngram-size-m N`: Defines the scalar dimension $M$ for the $M$-gram speculative generation window.
*   `--spec-ngram-min-hits N`: The mathematical minimal collision threshold necessary within the $N$-gram map to trigger a successful speculative projection.

## 10. HTTP Network Binding & API Endpoint Management

Controls for the asynchronous network event loop, socket routing, and security authentication protocols.

*   `--host HOST`, `--port PORT`: Defines the strictly bound IPv4/IPv6 interface and TCP port. Supports mapping directly to `*.sock` references for low-latency Inter-Process Communication via UNIX domain sockets.
*   `--path PATH`: Points the internal HTTP multiplexer to a static directory payload to serve Web UI assets natively.
*   `--api-prefix PREFIX`: Enforces an arbitrary string prefix upon all RESTful API routes (e.g., mapping routes beneath `/v2/internal/`).
*   `--api-key KEY`, `--api-key-file FNAME`: Enforces rudimentary HTTP Bearer token validation using explicit string arrays or newline-delimited external files.
*   `--ssl-key-file FNAME`, `--ssl-cert-file FNAME`: Maps the respective PEM-encoded cryptographic key and certificate artifacts to instantiate encrypted TLS termination natively.
*   `-to, --timeout N`: Enforces a hard read/write synchronization timeout scalar (in seconds) across the HTTP socket layer.
*   `--sleep-idle-seconds SECONDS`: Establishes an inactivity countdown trigger that forces the server into a computationally suspended low-power sleep state.
*   `--metrics`: Instantiates and exposes a dedicated `/metrics` REST endpoint configured for standard Prometheus telemetry scraping logic.
*   `--props`: Exposes the dangerously powerful `POST /props` endpoint, allowing dynamic, on-the-fly mutations of the global runtime properties schema.
*   `--slots, --no-slots`: Controls the exposition of the slot-monitoring telemetry via the API mapping logic.

## 11. Multimodal Projection, Web UI, and Formatting

Configurations extending the base LLM into vision, acoustic parsing, agentic tool orchestration, and complex metadata templating.

*   `-mm, --mmproj FILE`, `-mmu, --mmproj-url URL`: Ingests the multimodal projection weight matrix, mathematically bridging disparate latent spaces (e.g., a ViT embedding) directly into the LLM's primary text dimension.
*   `--mmproj-auto, --no-mmproj, --no-mmproj-auto`: Automatically attempts to locate and integrate a projector file matching the base model repository.
*   `--mmproj-offload, --no-mmproj-offload`: Forces the spatial projection operations directly into the VRAM of compute accelerators.
*   `--image-min-tokens N`, `--image-max-tokens N`: Strictly defines sequence dimension constraints explicitly applied to vision inputs to prevent context window saturation from exceedingly high-resolution visual inputs.
*   `-mv, --model-vocoder FNAME`, `-hfv, -hfrv, --hf-repo-v <user>/<model>[:quant]`, `-hffv, --hf-file-v FILE`: Instructs the ingestion of specific vocoder neural weights necessary to materialize Text-To-Speech (TTS) matrices into audible acoustic outputs.
*   `--tts-use-guide-tokens`: Prompts the TTS architecture to leverage embedded structural guide tokens to heavily influence the acoustic intonation and cadence.
*   `-a, --alias STRING`: Injects a custom nomenclature string utilized across the OpenAI-compatible `/v1/models` route mapping.
*   `--tags STRING`: A comma-delimited metadata array appended for informational aggregation contexts.
*   `--webui-config JSON`, `--webui-config-file PATH`: Enforces a pre-ordained JSON layout over the internal Web UI logic, overriding client-side defaults.
*   `--webui-mcp-proxy, --no-webui-mcp-proxy`: Evaluates an experimental MCP CORS proxy pass-through mechanism—fundamentally insecure outside of tightly trusted environments.
*   `--webui, --no-webui`: Entirely enables or purges the internal HTTP Web UI server logic.
*   `--embedding, --embeddings`: Locks the server architecture exclusively into embedding generation mode, rejecting all auto-regressive generation queries.
*   `--rerank, --reranking`: Activates the cross-encoder re-ranking endpoints.
*   `--models-dir PATH`, `--models-preset PATH`, `--models-max N`, `--models-autoload, --no-models-autoload`: Parameters explicitly governing router-server topologies, managing concurrent model multiplexing and automatic hot-swapping schemas.
*   `--jinja, --no-jinja`: Enables the advanced Python Jinja templating parser engine to evaluate structural system prompts natively.
*   `--chat-template JINJA_TEMPLATE`, `--chat-template-file JINJA_TEMPLATE_FILE`: Overrides the GGUF header's native template assumption with a rigidly defined string layout (e.g., `chatml`, `llama3`) or reads identical logic from an external file artifact.
*   `--chat-template-kwargs STRING`: Accepts a rigidly formatted JSON string to inject dynamic, arbitrary variable declarations into the Jinja rendering pipeline.
*   `--reasoning-format FORMAT`: Imposes an extraction schema onto specific intermediary agentic outputs (like DeepSeek `<think>` tokens), explicitly determining whether reasoning blocks are dumped raw or mapped out specifically into distinct `reasoning_content` JSON payloads.
*   `--reasoning-budget N`: Exerts a mathematical constraint upon the depth and token length the internal reasoning routines are allowed to evaluate.
*   `--prefill-assistant, --no-prefill-assistant`: Manipulates the parsing behavior of requests where the final message originates from the `assistant` role, dictating whether to trigger auto-regressive continuation (prefill) or treat it strictly as terminal context.
*   `-r, --reverse-prompt PROMPT`: Establishes a rigid, string-matched halting condition that acts identical to an EOS token trigger.
*   `-sp, --special`: Exposes special tokens (such as `BOS`, `EOS`, or `<|im_start|>`) natively in the generated HTTP string payload.
*   `--warmup, --no-warmup`: Executes a silent, empty compute graph operation upon instantiation to explicitly prime GPU caches and force internal JIT kernel compilations before network exposure.
*   `--spm-infill`: Modifies architectural structural generation targeting from the default Prefix/Suffix/Middle paradigm into the explicit Suffix/Prefix/Middle (SPM) architecture commonly leveraged by distinct codebase completion models.
*   `-e, --escape, --no-escape`: Toggles standard regular expression parsing mechanisms over string variables (e.g., translating literal `\n` to native newlines).
*   `--pooling {none,mean,cls,last,rank}`: Mandates the mathematical aggregation pooling architecture specifically applied during embedding calculations, collapsing latent dimensional arrays into singular dense vectors via mathematical means.
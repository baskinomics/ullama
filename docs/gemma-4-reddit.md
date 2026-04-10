---
title: "Gemma 4 on Llama.cpp should be stable now"
source: "https://www.reddit.com/r/LocalLLaMA/comments/1sgl3qz/gemma_4_on_llamacpp_should_be_stable_now/"
author:
  - "[[ilintar]]"
published: 2026-04-09
created: 2026-04-09
description: "Reddit is where millions of people gather for conversations about the things they care about, in over 100,000 subreddit communities."
tags:
  - "clippings"
---
With the merging of [https://github.com/ggml-org/llama.cpp/pull/21534](https://github.com/ggml-org/llama.cpp/pull/21534), all of the fixes to known Gemma 4 issues in Llama.cpp have been resolved. I've been running Gemma 4 31B on Q5 quants for some time now with no issues.

Runtime hints:

- remember to run with \`--chat-template-file\` with the interleaved template Aldehir has prepared (it's in the llama.cpp code under models/templates)
- I strongly encourage running with \`--cache-ram 2048 -ctxcp 2\` to avoid system RAM problems
- running KV cache with Q5 K and Q4 V has shown no large performance degradation, of course YMMV

Have fun :)

(oh yeah, important remark - when I talk about llama.cpp here, I mean the \*source code\*, not the releases which lag behind - this refers to the code built from current master)

Important note about building: DO NOT currently use CUDA 13.2 as it is CONFIRMED BROKEN (the NVidia people are on the case already) and will generate builds that will not work correctly.

---

## Comments

> **tiffanytrashcan** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of5qaex/) · 53 points
> 
> This should be important to note as well! **Do not use CUDA 13.2** or you'll see broken/unstable behaviour still.
> 
> [https://www.reddit.com/r/unsloth/comments/1sgl0wh/do\_not\_use\_cuda\_132\_to\_run\_models/](https://www.reddit.com/r/unsloth/comments/1sgl0wh/do_not_use_cuda_132_to_run_models/)
> 
> > **ilintar** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of5qcdt/) · 15 points
> > 
> > Yes, good call. Will edit the post.
> > 
> > > **danielhanchen** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of5rskz/) · 5 points
> > > 
> > > Thanks for all the fixes as well!
> 
> > **a\_beautiful\_rhind** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of60e6e/) · 2 points
> > 
> > I'm using 13.2 driver with 12.6 nvcc and runtime. I didn't see any breakage on *other* models but gemma was still unstable as of yesterday.
> > 
> > **ambient\_temp\_xeno** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of5rs3u/) · 3 points
> > 
> > My spider sense already taught me not to use 13x instead of 12x because if it ain't broke don't fix it.
> > 
> > > **finevelyn** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of5syim/) · 9 points
> > > 
> > > The official llama.cpp cuda13 docker image uses 13.1.1 instead of 13.2, and it gave me some speed boost compared to 12.x on 50-series RTX cards.
> > > 
> > > **FinBenton** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of5uyyn/) · 7 points
> > > 
> > > 13.0 has been good to me through various random projects so far.

> **ambient\_temp\_xeno** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of5rnw6/) · 17 points
> 
> We have to manually add that template jinja? >\_< Oh well better safe than sorry.
> 
> \--chat-template-file google-gemma-4-31B-it-interleaved.jinja
> 
> Other top tips are manually set --min-p 0.0 as the hard coded default of llama.cpp is actually on (0.05)
> 
> Set slots to -np 1 (unless you actually need more slots) to save ram.
> 
> > **ilintar** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of5rptz/) · 9 points
> > 
> > Yes, the official template is the non-interleaved one, don't ask me why :)
> > 
> > > **FinBenton** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of5v79d/) · 6 points
> > > 
> > > Whats that supposed to do? I have just used the default --jinja with no issues for my use.
> > > 
> > > > **ilintar** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of5vq11/) · 9 points
> > > > 
> > > > The interleaved template preserves the last reasoning before a tool call in the message history, leading to better agentic flow.
> > > > 
> > > > > **Far-Low-4705** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6d0vx/) · 2 points
> > > > > 
> > > > > Was Gemma 4 trained with native interleaved thinking? Maybe they released the non interleaved thinking chat template because that’s what Gemma was trained with??
> > > > > 
> > > > > > **ilintar** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6dr0b/) · 1 points
> > > > > > 
> > > > > > Yes and they stated so in their docs, that's what the template was based on.
> > > > 
> > > > > **AppealSame4367** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6b231/) · 1 points
> > > > > 
> > > > > Compiled latest version and used "--chat-template-file google-gemma-4-31B-it-interleaved.jinja"
> > > > > 
> > > > > error while handling argument "--chat-template-file": error: failed to open file 'google-gemma-4-31B-it-interleaved.jinja'
> > > > > 
> > > > > usage:
> > > > > 
> > > > > \--chat-template-file JINJA\_TEMPLATE\_FILE
> > > > > 
> > > > > set custom jinja chat template file (default: template taken from
> > > > > 
> > > > > model's metadata)
> > > > > 
> > > > > if suffix/prefix are specified, template will be disabled
> > > > > 
> > > > > only commonly used templates are accepted (unless --jinja is set
> > > > > 
> > > > > before this flag):
> > > > > 
> > > > > list of built-in templates:
> > > > > 
> > > > > bailing, bailing-think, bailing2, chatglm3, chatglm4, chatml,
> > > > > 
> > > > > command-r, deepseek, deepseek-ocr, deepseek2, deepseek3, exaone-moe,
> > > > > 
> > > > > exaone3, exaone4, falcon3, gemma, gigachat, glmedge, gpt-oss, granite,
> > > > > 
> > > > > granite-4.0, grok-2, hunyuan-dense, hunyuan-moe, hunyuan-ocr, kimi-k2,
> > > > > 
> > > > > llama2, llama2-sys, llama2-sys-bos, llama2-sys-strip, llama3, llama4,
> > > > > 
> > > > > megrez, minicpm, mistral-v1, mistral-v3, mistral-v3-tekken,
> > > > > 
> > > > > mistral-v7, mistral-v7-tekken, monarch, openchat, orion,
> > > > > 
> > > > > pangu-embedded, phi3, phi4, rwkv-world, seed\_oss, smolvlm, solar-open,
> > > > > 
> > > > > vicuna, vicuna-orca, yandex, zephyr
> > > > > 
> > > > > (env: LLAMA\_ARG\_CHAT\_TEMPLATE\_FILE)
> > > > > 
> > > > > > **ambient\_temp\_xeno** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6cp3h/) · 1 points
> > > > > > 
> > > > > > I just copied the google-gemma-4-31B-it-interleaved.jinja file into the llama.cpp folder on windows. On linux you can put it in the build/bin folder.
> > > > > > 
> > > > > > > **Far-Low-4705** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6gkcd/) · 1 points
> > > > > > > 
> > > > > > > I just put the full path to the file in llama.cpp/models/template/filename.jinja and it still gave me the same error, not sure what’s wrong
> > > > > 
> > > > > > **Far-Low-4705** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6gd23/) · 1 points
> > > > > > 
> > > > > > Same here, not sure how this flag works

> **Chromix\_** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of5qrbe/) · 17 points
> 
> Very useful to have that "how to run it properly at the current point in time" in one place.
> 
> A tiny addition would be that the audio capabilities seem to suffer [when going below Q5](https://github.com/ggml-org/llama.cpp/pull/21599).

> **MoodRevolutionary748** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of5xvaq/) · 8 points
> 
> Flash attention on Vulkan is still broken though
> 
> > **ilintar** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of5yi0t/) · 4 points
> > 
> > Yeah, heard about that one, I haven't really used Vulkan much lately so I forgot about it. Hopefully it'll get fixed soon.
> > 
> > **RandomTrollface** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of645xq/) · 2 points
> > 
> > What do you mean? Can't seem to find the llama.cpp issue about this. Am using the Vulkan backend mainly so definitely want to know if there are upcoming fixes.
> > 
> > > **MoodRevolutionary748** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of66gij/) · 1 points
> > > 
> > > [https://github.com/ggml-org/llama.cpp/issues/21336](https://github.com/ggml-org/llama.cpp/issues/21336)

> **No\_Lingonberry1201** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of5xuwo/) · 7 points
> 
> I spent so much time compiling llama.cpp these past few days I just made a cronjob to automatically pull the latest version and recompile it once a day.
> 
> > **tessellation** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6396x/) · 2 points
> > 
> > I have a kbd shortcut for this, thx ccache
> > 
> > **ea\_man** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6gbhy/) · 1 points
> > 
> > Debian Sid should do that for you.

> **Lolzyyy** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of648em/) · 5 points
> 
> does it support audio input for the 2/4b models yet ?
> 
> > **muxxington** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6hjku/) · 2 points
> > 
> > Nope.  
> > [https://github.com/ggml-org/llama.cpp/issues/21325](https://github.com/ggml-org/llama.cpp/issues/21325)

> **cviperr33** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of5tdef/) · 5 points
> 
> So much valuable info in this post , thank you for taking the time to post it !

> **grumd** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of5ucrk/) · 2 points
> 
> Just curious about context checkpoints, I haven't tried changing that parameter yet, how does it affect prompt reprocessing? Is it enough to have just 2 checkpoints to avoid it rereading the whole prompt?
> 
> > **ilintar** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of5vvtf/) · 2 points
> > 
> > On non-hybrid, non-iSWA models you don't need the checkpoints at all since you can use KV cache truncation.
> > 
> > On iSWA models having checkpoints is useful, but you can probably do with less than in case of hybrid models.

> **Barubiri** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of63klb/) · 2 points
> 
> Vision working?
> 
> > **jld1532** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of67m4f/) · 1 points
> > 
> > Not for me on 26B. It'll run on 4B, but you get 4B answers, so...
> > 
> > **createthiscom** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6bfsa/) · 1 points
> > 
> > image processing was working with A26B and A31B in commit `15f786` from Apr 7th 2026 for me. Startup commands for reference (you need mmproj for it to work):
> > 
> > ./build/bin/llama-server \\
> >     --model  /data2/gemma-4-26B-A4B-it-GGUF/gemma-4-26B-A4B-it-UD-Q8\_K\_XL.gguf \\
> >         --mmproj /data2/gemma-4-26B-A4B-it-GGUF/mmproj-BF16.gguf \\
> >     --image-max-tokens 1120 \\
> >     --alias gemma-4-26B-A4B-it-UD-Q8\_K\_XL \\
> >     --numa numactl \\
> >     --threads 32 \\
> >     --ctx-size 262144 \\
> >     --n-gpu-layers 62 \\
> >     -ot "blk\\.\*\\.ffn\_.\*=CUDA0" \\
> >     -ot exps=CPU \\
> >     -ub 4096 -b 4096 \\
> >     --seed 3407 \\
> >     --temp 1.0 \\
> >     --top-p 0.95 \\
> >     --top-k 64 \\
> >     --log-colors on \\
> >     --flash-attn on \\
> >     --host 0.0.0.0 \\
> >     --prio 2 \\
> >     --jinja \\
> >     --port 11434./build/bin/llama-server \\
> >     --model  /data2/gemma-4-31B-it-GGUF/gemma-4-31B-it-UD-Q8\_K\_XL.gguf \\
> >         --mmproj /data2/gemma-4-31B-it-GGUF/mmproj-BF16.gguf \\
> >     --image-max-tokens 1120 \\
> >     --alias gemma-4-31B-it-UD-Q8\_K\_XL \\
> >     --numa numactl \\
> >     --threads 32 \\
> >     --ctx-size 262144 \\
> >     --n-gpu-layers 62 \\
> >     -ot "blk\\.\*\\.ffn\_.\*=CUDA0" \\
> >     -ot exps=CPU \\
> >     -ub 4096 -b 4096 \\
> >     --seed 3407 \\
> >     --temp 1.0 \\
> >     --top-p 0.95 \\
> >     --top-k 64 \\
> >     --log-colors on \\
> >     --flash-attn on \\
> >     --host 0.0.0.0 \\
> >     --prio 2 \\
> >     --jinja \\
> >     --port 11434
> > 
> > I don't think audio works yet though.

> **Sensitive\_Pop4803** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6b50d/) · 2 points
> 
> How is it stable if I have to micromanage the Cuda version

> **Thigh\_Clapper** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6bap3/) · 3 points
> 
> Is the template needed for e2/4b, or only the 31b?
> 
> > **coder543** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6hrhe/) · 1 points
> > 
> > Also worth mentioning the e4b (and probably e2b) chat templates are different by 3 lines from the 26B and 31B built in chat templates, so I’m not sure the override would apply as cleanly to those without another interleaved chat template in the llama.cpp repo [u/ilintar](https://www.reddit.com/user/ilintar/)

> **cryyingboy** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of5z8pf/) · 3 points
> 
> gemma 4 going from broken to daily driver in a week, llamacpp devs are built different.

> **mr\_Owner** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of62yes/) · 1 points
> 
> I have had zero issues with cuda 13.x packages from llama cpp

> **koygocuren** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6840j/) · 1 points
> 
> How can i find the interleaved template?
> 
> > **Strong-Ad-6289** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of69ht1/) · 1 points
> > 
> > [https://github.com/ggml-org/llama.cpp/tree/master/models/templates](https://github.com/ggml-org/llama.cpp/tree/master/models/templates)

> **createthiscom** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6a7zz/) · 1 points
> 
> I'll have to retest 26B with the aider polyglot now that this change has been merged. I was running commit \`15f786\` previously and A31B was performing significantly better than A26B:
> 
> [https://discord.com/channels/1131200896827654144/1489301998393233641/1491666033319215174](https://discord.com/channels/1131200896827654144/1489301998393233641/1491666033319215174)

> **kmp11** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6b86r/) · 1 points
> 
> Stable? yes, Optimized? no... a 25GB model should not require 75GB of VRAM + RAM.

> **coder543** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6frtc/) · 1 points
> 
> >  remember to run with `--chat-template-file` with the interleaved template Aldehir has prepared (it's in the llama.cpp code under models/templates)
> 
> Strange that the official ggml-org ggufs have not been updated to embed this on hugging face?

> **Guilty\_Rooster\_6708** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6ftq6/) · 1 points
> 
> I am using the 26B MoE. Should I use the chat template jinja gemma-4-31B-it-interleaved based on the post?
> 
> > **ilintar** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6g7ar/) · 2 points
> > 
> > For agentic stuff yes.
> > 
> > > **Guilty\_Rooster\_6708** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6gm54/) · 1 points
> > > 
> > > Thanks. The model will still be thinking if I use the template right?
> > > 
> > > Also, are you using Q5 K and Q4 V because attention rot has been added to llama cpp? I must have missed that update, but isn’t it applicable to only Q8 and Q4 cache?

> **Voxandr** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6g1zb/) · 1 points
> 
> Thats cool!! i am gonna try .

> **JohnMason6504** · [2026-04-09](https://reddit.com/r/LocalLLaMA/comments/1sgl3qz/comment/of6hf6p/) · 2 points
> 
> The asymmetric KV cache quant recommendation is the real gem here. Keys carry the attention score distribution so quantization noise there propagates multiplicatively through softmax. Values just get weighted-summed after attention is computed so they tolerate more aggressive compression. Q5 keys with Q4 values is not arbitrary -- it maps directly to where precision loss actually distorts output.
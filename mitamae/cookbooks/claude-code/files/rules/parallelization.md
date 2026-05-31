# 並列化と subagent

タスクを受けたら最初に「**並列化できる subtask は何か**」「**subagent に投げて main context を空けられるか**」を洗い出してから動く。default は subagent 優先 / 並列優先。

## 判断

- **互いに独立な 2+ task** → Agent tool で 1 message 内に並列 dispatch (independent search、multi-scenario eval、multi-model 比較など)
- **大量探索・grep・解析 (3+ query 規模)** → `general-purpose` / `Explore` subagent に投げ、main は要約だけ受け取る
- **bias-free 評価** (skill / prompt / 自分の生成物の検証) → 新規 subagent。「自分で再読」は禁じ手
- **Long-running batch** (Bash の 10 分上限を超える等) → subagent dispatch か `run_in_background` + `Monitor`

## 避けるべき

- 直列依存 (前 task の結果が次 task 入力) を無理に並列化する
- 1-step / short lookup を subagent に投げる (overhead がコストに見合わない)
- subagent と main で同じ作業を二重で走らせる

# 🚀 AI + 图表 OSINT 情报分析系统

一个基于 **Docker + 本地大模型（Ollama）+ 多源RSS** 构建的
👉 实时情报采集、分析、可视化系统

---

# 🧠 项目功能

## ✅ 核心能力

* 🌐 多源新闻采集（国内 + 国外）
* 🧠 AI 自动分析（本地大模型）
* 🏷️ 自动分类（AI / 芯片 / 安全 / 国际等）
* ⚠️ 风险评估（低 / 中 / 高）
* 📊 数据可视化（分类 / 来源 / 风险）
* 🔎 搜索 + 筛选
* 🔄 实时刷新

---

## 🤖 AI结构化输出

系统自动生成：

```json
{
  "summary": "一句话摘要",
  "impact": "可能影响",
  "risk": "低/中/高",
  "action": "建议动作"
}
```

---

# 🏗️ 系统架构

```text
crawler   → 采集RSS
    ↓
redis     → 消息队列
    ↓
analyzer  → AI分析（Ollama）
    ↓
postgres  → 数据存储
    ↓
api       → 页面展示（FastAPI）
```

---

# 🧰 技术栈

| 类型  | 技术                      |
| --- | ----------------------- |
| 容器  | Docker / Docker Compose |
| 后端  | Python / FastAPI        |
| 数据  | Redis + PostgreSQL      |
| AI  | Ollama（本地大模型）           |
| 前端  | HTML + Chart.js         |
| 数据源 | RSS Feed                |

---

# ⚙️ 环境要求

```text
Ubuntu 22.04 / 24.04
Docker
Docker Compose
（推荐）NVIDIA GPU
```

---

# 数据库密码配置

仓库不保存数据库密码。首次启动前，在项目目录创建本地配置：

```bash
cp -n .env.example .env
chmod 600 .env
nano .env
```

将 `POSTGRES_PASSWORD` 设置为新生成的强密码，再执行下方 Docker Compose 命令。
`.env` 已加入忽略规则，不要提交；`.env.example` 仅保留空密码占位。
Compose 使用 `POSTGRES_PASSWORD` 配置数据库，并把相同值以 `PG_PASSWORD` 注入 API 和 analyzer。
直接运行 API 时必须设置 `PG_PASSWORD` 环境变量。
Ollama 地址可通过 `.env` 中的 `OLLAMA_URL` 配置，默认使用 Docker 主机地址。

已有数据库的数据卷不会因为修改 `.env` 自动更换密码。
请先备份数据库，用 `docker compose exec postgres psql -U osint -d osintdb`
进入数据库，再用交互命令 `\password osint` 设置新密码，
同步更新 `.env` 后重建 API 和 analyzer 容器。
不要为更换密码删除数据卷。过去公开过的密码应更换，即使已从当前文件移除。
Redis 和 PostgreSQL 的主机端口仅绑定 `127.0.0.1`，容器之间仍使用服务名通信。
页面默认只允许本机访问 `http://127.0.0.1:7000`。需要远程访问时，优先使用 SSH 隧道或带认证的 HTTPS 反向代理。
确需在受控网络直接监听时，可在 `.env` 显式设置 `OSINT_BIND_ADDRESS`；此页面没有内置登录验证，不应直接暴露到公网。

# 🚀 一键启动

```bash
git clone https://github.com/ywx920/local-ai-osint-dashboard.git osint-system
cd osint-system

cp -n .env.example .env
chmod 600 .env
nano .env  # 设置 POSTGRES_PASSWORD 后继续

sudo docker compose build
sudo docker compose up -d
```

---

# 🌐 访问系统

```text
http://127.0.0.1:7000
```

---

# 🧠 本地大模型接入（Ollama）

## 1️⃣ 安装

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

---

## 2️⃣ 启动服务

```bash
ollama serve
```

---

## 3️⃣ 拉取模型

```bash
ollama pull qwen2.5:7b
```

---

## 4️⃣ 修改监听地址（关键）

```bash
sudo systemctl edit ollama
```

若仅在主机直接调用，保留 Ollama 的本机监听即可。容器需要访问主机服务时，使用明确的受控接口并限制来源到 Docker 网络；不要把无认证的 Ollama 接口直接公开到公网。
将下方占位符替换为实际受控接口地址后写入：

```ini
[Service]
Environment="OLLAMA_HOST=<Docker 可访问的受控接口地址>:11434"
```

应用：

```bash
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

---

# 📰 新闻源配置

文件：

```bash
crawler/crawler.py
```

示例：

```python
SOURCES = [
    ("Hacker News", "https://hnrss.org/frontpage"),
    ("36氪", "https://36kr.com/feed"),
]
```

---

## 🔄 修改后生效

```bash
sudo docker compose restart crawler
```

---

# ⏱️ 刷新频率

```python
time.sleep(60)
```

单位：秒

---

# 🛠️ 常见问题

---

## ❗ Docker 无法拉镜像

编辑：

```bash
/etc/docker/daemon.json
```

添加：

```json
{
  "registry-mirrors": ["https://docker.m.daocloud.io"]
}
```

---

## ❗ GitHub push 失败

使用 SSH：

```bash
ssh-keygen -t ed25519
git remote set-url origin git@github.com:ywx920/local-ai-osint-dashboard.git
git push
```

---

## ❗ AI 调用失败

检查：

```bash
ss -lntp | grep 11434
```

---

## ❗ analyzer 报错缺少 requests

```text
ModuleNotFoundError: requests
```

👉 在 requirements.txt 添加：

```text
requests
```

---

# 📊 当前能力

```text
✔ 实时数据采集
✔ AI分析
✔ 风险评估
✔ 可视化
✔ 多源融合
```

---

# 🚀 后续规划

* [ ] 🚨 告警系统（高风险自动提示）
* [ ] 📈 趋势分析（热点检测）
* [ ] 🧠 事件聚类
* [ ] 🔔 Webhook/通知
* [ ] 🌍 分布式采集

---

# 👨‍💻 作者

wx-osint

---

# ⭐ 项目意义

```text
本项目用于学习：
✔ AI工程
✔ Linux系统
✔ Docker部署
✔ 数据流设计
✔ 本地大模型应用
```

---

# 📌 License

MIT

`fix_osint.sh` 会先校验 Compose 配置，再重建并启动本项目；不会重复插入 YAML，也不会重启宿主机 Docker 服务。
Dockerfile 的 HTTPS 软件源保留证书校验；各构建目录已排除本地凭据文件。

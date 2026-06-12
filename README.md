# pick10-legal

Pick10 App Store legal pages — hosted on Cloudflare Pages at `https://pick10.lx06.com`.

## Pages

| File | URL | App Store 用途 |
|------|-----|----------------|
| `index.html` | `/` | 法律文档索引 |
| `support.html` | `/support` 或 `/support.html` | **Support URL**（技术支持） |
| `privacy.html` | `/privacy` 或 `/privacy.html` | **Privacy Policy URL**（隐私政策） |
| `terms.html` | `/terms.html` | 应用内用户协议 |
| `app-ads.txt` | `/app-ads.txt` | **AdMob** app-ads.txt 验证（根目录纯文本） |

## App Store Connect 填写

| 字段 | URL |
|------|-----|
| Privacy Policy URL | `https://pick10.lx06.com/privacy` |
| Support URL | `https://pick10.lx06.com/support` |
| App Store | [https://apps.apple.com/us/app/pick10/id6776469249](https://apps.apple.com/us/app/pick10/id6776469249) |

## Deploy — 方式 A（GitHub + Cloudflare Pages）

### Step 1: 创建 GitHub 仓库

在 https://github.com/new 创建仓库：

- Repository name: `pick10-legal`
- Public
- **不要**勾选 "Add a README"（本地已有 commit）

## 一键部署

```bash
cd pick10-legal
./deploy-github.sh
```

自定义提交说明：

```bash
./deploy-github.sh "Update privacy policy"
```

脚本会自动：暂存变更 → 提交 → SSH 推送 GitHub → 等待 Cloudflare 部署生效。

### Step 3: Cloudflare Pages 连接 GitHub

1. 打开 [Cloudflare Dashboard](https://dash.cloudflare.com) → **Workers & Pages**
2. **Create** → **Pages** → **Connect to Git**
3. 选择 GitHub 账号，选中仓库 `pick10-legal`
4. 构建设置：
   - **Framework preset**: None
   - **Build command**: *(留空)*
   - **Build output directory**: `/`
5. **Save and Deploy**
6. **Custom domains** → **Set up a custom domain** → 输入 `pick10.lx06.com`
7. 等待 DNS 生效（lx06.com 已在 CF，通常几分钟内完成）

### Step 4: 验证

```bash
# app-ads.txt — 应返回一行纯文本
curl https://pick10.lx06.com/app-ads.txt

# App Store 链接 — 用无 .html 路径，直接 200
curl -I https://pick10.lx06.com/support
curl -I https://pick10.lx06.com/privacy

# 带 .html 会 308 跳转到上面路径（Cloudflare Pretty URLs，浏览器正常）
curl -I https://pick10.lx06.com/support.html   # → 308 location: /support
```

AdMob 会从 App Store **Support URL** 的域名抓取 `app-ads.txt`（域名须为 `pick10.lx06.com`）。`support.html` 返回 308 不影响 AdMob 验证。

## Local preview

```bash
cd pick10-legal
python3 -m http.server 8080
# open http://localhost:8080
```

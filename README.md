# pick10-legal

Pick10 App Store legal pages — hosted on Cloudflare Pages at `https://pick10.lx06.com`.

## Pages

| File | URL | App Store 用途 |
|------|-----|----------------|
| `index.html` | `/` | 法律文档索引 |
| `support.html` | `/support.html` | **Support URL**（技术支持） |
| `privacy.html` | `/privacy.html` | **Privacy Policy URL**（隐私政策） |
| `terms.html` | `/terms.html` | 应用内用户协议 |

## App Store Connect 填写

| 字段 | URL |
|------|-----|
| Privacy Policy URL | `https://pick10.lx06.com/privacy.html` |
| Support URL | `https://pick10.lx06.com/support.html` |

## Deploy — 方式 A（GitHub + Cloudflare Pages）

### Step 1: 创建 GitHub 仓库

在 https://github.com/new 创建仓库：

- Repository name: `pick10-legal`
- Public
- **不要**勾选 "Add a README"（本地已有 commit）

### Step 2: 推送到 GitHub

```bash
cd pick10-legal
chmod +x deploy-github.sh
./deploy-github.sh
# 或指定其他 remote：
# ./deploy-github.sh https://github.com/YOUR_USER/pick10-legal.git main
```

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
curl -I https://pick10.lx06.com/privacy.html
curl -I https://pick10.lx06.com/support.html
```

## Local preview

```bash
cd pick10-legal
python3 -m http.server 8080
# open http://localhost:8080
```

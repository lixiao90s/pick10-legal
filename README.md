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

## Deploy (Cloudflare Pages)

1. Push this folder to GitHub repo `pick10-legal`
2. Cloudflare → Workers & Pages → Create → Connect to Git
3. Build command: *(empty)* | Output directory: `/`
4. Custom domain: `pick10.lx06.com`

## Local preview

```bash
cd pick10-legal
python3 -m http.server 8080
# open http://localhost:8080
```

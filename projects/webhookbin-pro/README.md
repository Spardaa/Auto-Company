# WebhookBin Pro

Privacy-first webhook testing tool. Deploy to Cloudflare Workers in one click.

## Features

- 🔒 **100% Self-Hosted** - Your data never leaves your Cloudflare account
- 🚀 **One-Click Deploy** - No Docker, no Kubernetes
- ⚡ **Lightning Fast** - Edge-deployed on Cloudflare's global network
- 🔍 **Full Inspection** - View headers, body, query params
- 📊 **Persistent History** - Search through past requests
- 🛡️ **Compliance Ready** - GDPR, HIPAA, SOC2 compatible

## Quick Deploy

### Option 1: Deploy Button (Coming Soon)

Click "Deploy to Cloudflare Workers" button on the landing page.

### Option 2: Manual Deploy

```bash
# 1. Clone the repo
git clone https://github.com/Spardaa/webhookbin-pro.git
cd webhookbin-pro

# 2. Install wrangler (requires Node.js 20+)
npm install -g wrangler

# 3. Login to Cloudflare
wrangler login

# 4. Create D1 database
wrangler d1 create webhookbin-pro
# Copy the database_id to wrangler.toml

# 5. Initialize database schema
wrangler d1 execute webhookbin-pro --file=schema.sql

# 6. Deploy
wrangler deploy
```

## Usage

### Create an Endpoint

```bash
curl -X POST https://your-worker.workers.dev/api/endpoints
```

Response:
```json
{
  "id": "abc123",
  "url": "https://your-worker.workers.dev/abc123"
}
```

### Receive Webhooks

Any request to `https://your-worker.workers.dev/abc123` will be captured:

```bash
curl -X POST https://your-worker.workers.dev/abc123 \
  -H "Content-Type: application/json" \
  -d '{"event": "user.created", "data": {"id": 123}}'
```

### View Dashboard

Open `https://your-worker.workers.dev/` in your browser to see all endpoints and requests.

## API Reference

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/endpoints` | Create new endpoint |
| GET | `/api/endpoints` | List all endpoints |
| GET | `/api/endpoints/:id` | Get endpoint + requests |
| DELETE | `/api/endpoints/:id` | Delete endpoint |
| ANY | `/:id/*` | Capture webhook request |

## Pricing

- **Self-Hosted**: $29 one-time (includes lifetime updates)
- **Cloud Tier** (Coming Soon): $9/month

## License

MIT License - See LICENSE file for details.

---

Built by [Auto Company](https://github.com/Spardaa)

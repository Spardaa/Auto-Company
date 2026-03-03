/**
 * WebhookBin Pro - Cloudflare Worker
 * Privacy-first webhook testing tool
 */

// Generate random endpoint ID
function generateId(length = 8) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

// Parse headers to JSON
function headersToJson(headers) {
  const obj = {};
  headers.forEach((value, key) => {
    obj[key] = value;
  });
  return JSON.stringify(obj);
}

// CORS headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
};

// Handle OPTIONS preflight
function handleOptions() {
  return new Response(null, {
    status: 204,
    headers: corsHeaders
  });
}

// JSON response helper
function jsonResponse(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...corsHeaders
    }
  });
}

// HTML response helper
function htmlResponse(html) {
  return new Response(html, {
    headers: {
      'Content-Type': 'text/html; charset=utf-8',
      ...corsHeaders
    }
  });
}

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const path = url.pathname;

    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return handleOptions();
    }

    // Route: Dashboard (root)
    if (path === '/' || path === '') {
      return htmlResponse(getDashboardHTML());
    }

    // Route: Create new endpoint
    if (path === '/api/endpoints' && request.method === 'POST') {
      const id = generateId();
      const name = url.searchParams.get('name') || `Endpoint ${id.slice(0, 4)}`;

      await env.DB.prepare(
        'INSERT INTO endpoints (id, name) VALUES (?, ?)'
      ).bind(id, name).run();

      return jsonResponse({
        id,
        name,
        url: `${url.origin}/${id}`,
        message: 'Endpoint created successfully'
      }, 201);
    }

    // Route: List endpoints
    if (path === '/api/endpoints' && request.method === 'GET') {
      const result = await env.DB.prepare(
        'SELECT * FROM endpoints ORDER BY created_at DESC LIMIT 50'
      ).all();

      return jsonResponse(result.results);
    }

    // Route: Get endpoint info
    const endpointMatch = path.match(/^\/api\/endpoints\/([a-z0-9]+)$/);
    if (endpointMatch && request.method === 'GET') {
      const endpointId = endpointMatch[1];
      const endpoint = await env.DB.prepare(
        'SELECT * FROM endpoints WHERE id = ?'
      ).bind(endpointId).first();

      if (!endpoint) {
        return jsonResponse({ error: 'Endpoint not found' }, 404);
      }

      const requests = await env.DB.prepare(
        'SELECT * FROM requests WHERE endpoint_id = ? ORDER BY received_at DESC LIMIT 100'
      ).bind(endpointId).all();

      return jsonResponse({
        endpoint,
        requests: requests.results
      });
    }

    // Route: Delete endpoint
    const deleteMatch = path.match(/^\/api\/endpoints\/([a-z0-9]+)$/);
    if (deleteMatch && request.method === 'DELETE') {
      const endpointId = deleteMatch[1];

      await env.DB.prepare('DELETE FROM requests WHERE endpoint_id = ?')
        .bind(endpointId).run();

      await env.DB.prepare('DELETE FROM endpoints WHERE id = ?')
        .bind(endpointId).run();

      return jsonResponse({ message: 'Endpoint deleted' });
    }

    // Route: Catch-all webhook endpoint (receives webhooks)
    const webhookMatch = path.match(/^\/([a-z0-9]+)(\/.*)?$/);
    if (webhookMatch) {
      const endpointId = webhookMatch[1];
      const subPath = webhookMatch[2] || '/';

      // Check if endpoint exists, create if not (auto-create mode)
      let endpoint = await env.DB.prepare(
        'SELECT * FROM endpoints WHERE id = ?'
      ).bind(endpointId).first();

      if (!endpoint) {
        await env.DB.prepare(
          'INSERT INTO endpoints (id, name) VALUES (?, ?)'
        ).bind(endpointId, `Auto-created ${endpointId}`).run();
      }

      // Capture the request
      const body = await request.text();
      const headers = headersToJson(request.headers);

      await env.DB.prepare(`
        INSERT INTO requests (endpoint_id, method, path, query_string, headers, body, content_type, ip_address, user_agent)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      `).bind(
        endpointId,
        request.method,
        subPath,
        url.search.substring(1),
        headers,
        body,
        request.headers.get('content-type') || '',
        request.headers.get('cf-connecting-ip') || '',
        request.headers.get('user-agent') || ''
      ).run();

      // Update endpoint stats
      await env.DB.prepare(`
        UPDATE endpoints SET request_count = request_count + 1, last_request_at = CURRENT_TIMESTAMP WHERE id = ?
      `).bind(endpointId).run();

      // Return success with request details
      return jsonResponse({
        success: true,
        endpoint: endpointId,
        method: request.method,
        path: subPath,
        timestamp: new Date().toISOString()
      });
    }

    // 404 for everything else
    return jsonResponse({ error: 'Not found' }, 404);
  }
};

// Dashboard HTML (inline for single-file deployment)
function getDashboardHTML() {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>WebhookBin Pro Dashboard</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    :root {
      --bg: #0a0a0a; --fg: #fafafa; --muted: #888;
      --accent: #22c55e; --card: #141414; --border: #262626;
    }
    body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; background: var(--bg); color: var(--fg); padding: 20px; }
    .container { max-width: 1200px; margin: 0 auto; }
    h1 { margin-bottom: 8px; }
    .subtitle { color: var(--muted); margin-bottom: 24px; }
    .card { background: var(--card); border: 1px solid var(--border); border-radius: 8px; padding: 20px; margin-bottom: 16px; }
    .endpoint-url { font-family: monospace; background: var(--bg); padding: 12px; border-radius: 4px; margin: 12px 0; word-break: break-all; }
    .btn { background: var(--accent); color: var(--bg); border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; font-weight: 600; }
    .btn:hover { opacity: 0.9; }
    .btn-secondary { background: transparent; border: 1px solid var(--border); color: var(--fg); }
    .request { border-left: 3px solid var(--accent); padding-left: 16px; margin: 12px 0; }
    .request-meta { font-size: 0.85rem; color: var(--muted); }
    .method { display: inline-block; padding: 2px 8px; border-radius: 4px; font-size: 0.75rem; font-weight: 600; }
    .method-GET { background: #22c55e20; color: #22c55e; }
    .method-POST { background: #3b82f620; color: #3b82f6; }
    .method-PUT { background: #f59e0b20; color: #f59e0b; }
    .method-DELETE { background: #ef444420; color: #ef4444; }
    pre { background: var(--bg); padding: 12px; border-radius: 4px; overflow-x: auto; font-size: 0.85rem; }
    .empty { text-align: center; padding: 40px; color: var(--muted); }
    .tabs { display: flex; gap: 8px; margin-bottom: 16px; }
    .tab { padding: 8px 16px; border-radius: 6px; cursor: pointer; background: var(--card); border: 1px solid var(--border); }
    .tab.active { background: var(--accent); color: var(--bg); border-color: var(--accent); }
  </style>
</head>
<body>
  <div class="container">
    <h1>🔗 WebhookBin Pro</h1>
    <p class="subtitle">Privacy-first webhook testing. Your data stays in your Cloudflare account.</p>

    <div class="card">
      <h3>Create New Endpoint</h3>
      <p style="color: var(--muted); margin: 8px 0;">Get a unique URL to receive webhooks</p>
      <button class="btn" onclick="createEndpoint()">+ Create Endpoint</button>
    </div>

    <div id="endpoints" class="card">
      <h3>Your Endpoints</h3>
      <div id="endpoints-list">Loading...</div>
    </div>

    <div id="requests" class="card" style="display: none;">
      <h3>Requests</h3>
      <div id="requests-list"></div>
    </div>
  </div>

  <script>
    const API = '';
    let currentEndpoint = null;

    async function loadEndpoints() {
      const res = await fetch(API + '/api/endpoints');
      const endpoints = await res.json();
      const list = document.getElementById('endpoints-list');

      if (endpoints.length === 0) {
        list.innerHTML = '<div class="empty">No endpoints yet. Create one above!</div>';
        return;
      }

      list.innerHTML = endpoints.map(e => \`
        <div class="endpoint-url" onclick="selectEndpoint('\${e.id}')">
          <strong>\${e.name}</strong><br>
          <span style="color: var(--accent)">\${window.location.origin}/\${e.id}</span>
          <span style="color: var(--muted)"> · \${e.request_count} requests</span>
        </div>
      \`).join('');
    }

    async function createEndpoint() {
      const res = await fetch(API + '/api/endpoints', { method: 'POST' });
      const data = await res.json();
      await loadEndpoints();
      selectEndpoint(data.id);
    }

    async function selectEndpoint(id) {
      currentEndpoint = id;
      const res = await fetch(API + '/api/endpoints/' + id);
      const data = await res.json();

      const requestsDiv = document.getElementById('requests');
      const list = document.getElementById('requests-list');
      requestsDiv.style.display = 'block';

      if (data.requests.length === 0) {
        list.innerHTML = '<div class="empty">No requests yet. Send a webhook to the URL above!</div>';
        return;
      }

      list.innerHTML = data.requests.map(r => \`
        <div class="request">
          <span class="method method-\${r.method}">\${r.method}</span>
          <span>\${r.path}</span>
          <div class="request-meta">\${new Date(r.received_at).toLocaleString()} · \${r.ip_address}</div>
          <details style="margin-top: 8px;">
            <summary style="cursor: pointer; color: var(--accent)">View Details</summary>
            <pre>\${JSON.stringify({
              headers: JSON.parse(r.headers || '{}'),
              body: r.body,
              query: r.query_string
            }, null, 2)}</pre>
          </details>
        </div>
      \`).join('');
    }

    // Initial load
    loadEndpoints();

    // Auto-refresh every 5 seconds when viewing an endpoint
    setInterval(() => {
      if (currentEndpoint) selectEndpoint(currentEndpoint);
    }, 5000);
  </script>
</body>
</html>`;
}

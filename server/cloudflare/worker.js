// Cloudflare Worker 模板：飞书多维表“新增记录”
// 环境变量（在 Cloudflare Dashboard 中配置）：
// - FEISHU_APP_ID
// - FEISHU_APP_SECRET
// - FEISHU_APP_TOKEN  （基座 app_token，如 WySnb6n0YaWKIDse09Ocoh2rnSd）
// - FEISHU_TABLE_ID   （数据表 table_id）
// - API_KEY           （可选：客户端调用的鉴权）
// 注意：不要把密钥写进客户端或提交到仓库！

let cachedToken = null; // { token: string, expireAt: epoch_ms }

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    if (url.pathname === '/health') {
      try {
        const token = await getTenantToken(env);
        return new Response(JSON.stringify({ ok: true, tokenPresent: Boolean(token) }), {
          headers: { 'Content-Type': 'application/json' },
          status: 200,
        });
      } catch (e) {
        return new Response(JSON.stringify({ ok: false, message: String(e) }), {
          headers: { 'Content-Type': 'application/json' },
          status: 500,
        });
      }
    }
    if (url.pathname === '/feishu/record' && request.method === 'POST') {
      if (env.API_KEY) {
        const key = request.headers.get('X-Api-Key') || '';
        if (key !== env.API_KEY) {
          return new Response(JSON.stringify({ ok: false, message: 'unauthorized' }), { status: 401 });
        }
      }
      try {
        const body = await request.json();
        const type = String(body.type ?? '').trim();
        const amount = Number(body.amount ?? 0);
        const dateMs = Number(body.timestamp ?? Date.now());
        const operatorName = String(body.operator ?? '').trim();
        if (!type || Number.isNaN(amount)) {
          return new Response(JSON.stringify({ ok: false, message: 'invalid payload' }), { status: 400 });
        }
        const token = await getTenantToken(env);
        const result = await createBitableRecord(env, token, type, amount, dateMs, operatorName);
        const status = result.ok ? 200 : (result.status || 500);
        return new Response(JSON.stringify(result), {
          headers: { 'Content-Type': 'application/json' },
          status,
        });
      } catch (e) {
        return new Response(JSON.stringify({ ok: false, message: String(e) }), { status: 500 });
      }
    }
    return new Response('ok');
  },
};

async function getTenantToken(env) {
  const now = Date.now();
  if (cachedToken && cachedToken.expireAt - now > 30 * 60 * 1000) {
    return cachedToken.token;
  }
  const resp = await fetch('https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
    body: JSON.stringify({
      app_id: env.FEISHU_APP_ID,
      app_secret: env.FEISHU_APP_SECRET,
    }),
  });
  const data = await resp.json();
  if (data.code !== 0) {
    throw new Error(`get token failed: ${data.code} ${data.msg}`);
  }
  cachedToken = {
    token: data.tenant_access_token,
    expireAt: now + (data.expire || 7200) * 1000,
  };
  return cachedToken.token;
}

async function createBitableRecord(env, token, type, amount, dateMs, operatorName) {
  const appToken = env.FEISHU_APP_TOKEN;
  const tableId = env.FEISHU_TABLE_ID;
  const url = `https://open.feishu.cn/open-apis/bitable/v1/apps/${appToken}/tables/${tableId}/records`;
  const resp = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      Authorization: `Bearer ${token}`,
    },
    // 根据“新增记录”接口要求，单条新增使用顶层 fields
    body: JSON.stringify({
      fields: Object.assign({
        '类型': type,
        '金额': amount,
        '日期': dateMs,
      }, operatorName ? { '操作人员': operatorName } : {}),
    }),
  });
  if (resp.status >= 200 && resp.status < 300) {
    const data = await resp.json().catch(() => ({}));
    return { ok: true, status: resp.status, data };
  }
  const text = await resp.text();
  console.log('feishu create record failed:', resp.status, text);
  let data;
  try { data = JSON.parse(text); } catch { data = { raw: text }; }
  return { ok: false, status: resp.status, data };
}

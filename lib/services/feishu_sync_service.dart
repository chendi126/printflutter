import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class FeishuSyncService {
  // TODO: 将此地址替换为你部署的 Cloudflare/Vercel 函数地址，例如：
  // https://your-worker.example.workers.dev/feishu/record
  static String endpoint = 'https://kuuuuprint.qinshihuangshibanian.workers.dev/feishu/record';

  // TODO: 可选的后端 API Key，用于简单鉴权
  static String apiKey = '';
  static http.Client _client = _buildClient();
  static bool _direct = false;
  static String _appId = '';
  static String _appSecret = '';
  static String _appToken = '';
  static String _tableId = '';
  static String _openBase = 'https://open.feishu.cn'; // 可切换为 https://open.larksuite.com

  static http.Client _buildClient() {
    final hc = HttpClient();
    hc.connectionTimeout = const Duration(seconds: 10);
    hc.findProxy = HttpClient.findProxyFromEnvironment;
    return IOClient(hc);
  }

  static void setProxy(String proxyUrl) {
    final hc = HttpClient();
    hc.connectionTimeout = const Duration(seconds: 10);
    hc.findProxy = (uri) => 'PROXY $proxyUrl';
    _client = IOClient(hc);
  }

  static void enableDirect({
    required String appId,
    required String appSecret,
    required String appToken,
    required String tableId,
  }) {
    _direct = true;
    _appId = appId;
    _appSecret = appSecret;
    _appToken = appToken;
    _tableId = tableId;
  }

  static void setOpenBase(String base) {
    _openBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  }

  static Future<void> sendRecord({
    required String type,
    required double amount,
    int? timestampMs,
    String? operatorName,
  }) async {
    if (endpoint.isEmpty && !_direct) return;
    if (endpoint.isEmpty && _direct) {
      await _sendDirect(type: type, amount: amount, timestampMs: timestampMs, operatorName: operatorName);
      return;
    }
    final uri = Uri.parse(endpoint);
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      if (apiKey.isNotEmpty) 'X-Api-Key': apiKey,
    };
    final body = jsonEncode({
      'type': type,
      'amount': amount,
      if (timestampMs != null) 'timestamp': timestampMs,
      if (operatorName != null && operatorName.isNotEmpty) 'operator': operatorName,
    });
    const attempts = 3;
    var delay = const Duration(milliseconds: 500);
    for (var i = 0; i < attempts; i++) {
      try {
        final resp = await _client
            .post(uri, headers: headers, body: body)
            .timeout(const Duration(seconds: 10));
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          return;
        }
        if (kDebugMode) {
          debugPrint('FeishuSync status=${resp.statusCode} body=${resp.body}');
        }
      } catch (e) {
        if (i == attempts - 1 && kDebugMode) {
          debugPrint('FeishuSync error=$e');
        }
      }
      await Future.delayed(delay);
      delay *= 2;
    }
  }

  static Future<void> _sendDirect({
    required String type,
    required double amount,
    int? timestampMs,
    String? operatorName,
  }) async {
    const attempts = 3;
    var delay = const Duration(milliseconds: 500);
    for (var i = 0; i < attempts; i++) {
      try {
        final token = await _getTenantToken();
        final ok = await _createRecord(token, type, amount, timestampMs, operatorName);
        if (ok) return;
      } catch (e) {
        if (i == attempts - 1 && kDebugMode) {
          debugPrint('FeishuDirect error=$e');
        }
      }
      await Future.delayed(delay);
      delay *= 2;
    }
  }

  static Future<String> _getTenantToken() async {
    Future<Map<String, dynamic>> requestToken(String base) async {
      final uri = Uri.parse('$base/open-apis/auth/v3/tenant_access_token/internal');
      final resp = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({'app_id': _appId, 'app_secret': _appSecret}),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }

    // 首选当前基域名
    var data = await requestToken(_openBase);
    // 若参数无效且当前是 feishu.cn，则自动尝试 larksuite.com（常见为区域弄错）
    if (data['code'] == 10003 && _openBase.contains('feishu.cn')) {
      final altBase = 'https://open.larksuite.com';
      if (kDebugMode) {
        debugPrint('FeishuDirect token fallback to $altBase due to code=10003');
      }
      data = await requestToken(altBase);
      if (data['code'] == 0) {
        _openBase = altBase;
      }
    }
    if (data['code'] != 0) {
      throw Exception('token code=${data['code']} msg=${data['msg']}');
    }
    return data['tenant_access_token'] as String;
  }

  static Future<bool> _createRecord(String token, String type, double amount, int? timestampMs, String? operatorName) async {
    final uri = Uri.parse('$_openBase/open-apis/bitable/v1/apps/${_appToken}/tables/${_tableId}/records');
    final resp = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'fields': {
          '类型': type,
          '金额': amount,
          if (timestampMs != null) '日期': timestampMs,
          if (operatorName != null && operatorName.isNotEmpty) '操作人员': operatorName,
        }
      }),
    ).timeout(const Duration(seconds: 10));
    if (resp.statusCode >= 200 && resp.statusCode < 300) return true;
    if (kDebugMode) {
      debugPrint('FeishuDirect status=${resp.statusCode} body=${resp.body}');
    }
    return false;
  }
}

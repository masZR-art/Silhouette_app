import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class AppUser {
  const AppUser({required this.id, required this.name, required this.email});
  final String id;
  final String name;
  final String email;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
  );
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthService {
  static const _baseUrl = 'https://chat.silh0uette.space';
  static const _tokenKey = 'silhouette_desktop_token';
  static const _storage = FlutterSecureStorage();
  String? _token;

  Future<AppUser?> restoreSession() async {
    _token = await _storage.read(key: _tokenKey);
    if (_token == null) {
      return null;
    }
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/auth/me'),
        headers: _headers,
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['user'] != null) {
        return AppUser.fromJson(data['user'] as Map<String, dynamic>);
      }
    } catch (_) {}
    await _storage.delete(key: _tokenKey);
    _token = null;
    return null;
  }

  Future<AppUser> emailAuth({
    required String email,
    required String password,
    String? name,
    String? code,
  }) async {
    final signup = name != null;
    final response = await http.post(
      Uri.parse('$_baseUrl/api/desktop-auth/${signup ? 'signup' : 'login'}'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
        if (signup) 'name': name.trim(),
        if (signup) 'code': code?.trim(),
      }),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw AuthException(_friendlyError(data['error'] as String?));
    }
    return _accept(data);
  }

  Future<void> sendEmailCode(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/email-code'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'email': email.trim()}),
    );
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw AuthException(_friendlyError(data['error'] as String?));
    }
  }

  Future<AppUser> googleAuth() async {
    final start = await http.post(
      Uri.parse('$_baseUrl/api/desktop-auth/start'),
    );
    if (start.statusCode != 201) {
      throw const AuthException('暂时无法启动 Google 登录');
    }
    final data = jsonDecode(start.body) as Map<String, dynamic>;
    final launched = await launchUrl(
      Uri.parse(data['browserUrl'] as String),
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      throw const AuthException('无法打开系统浏览器');
    }
    final deadline = DateTime.now().add(const Duration(minutes: 10));
    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(seconds: 2));
      final uri = Uri.parse('$_baseUrl/api/desktop-auth/poll').replace(
        queryParameters: {
          'id': data['id'] as String,
          'secret': data['secret'] as String,
        },
      );
      final response = await http.get(uri);
      if (response.statusCode == 202) {
        continue;
      }
      if (response.statusCode == 200) {
        return _accept(jsonDecode(response.body) as Map<String, dynamic>);
      }
      throw const AuthException('授权已失效，请重新尝试');
    }
    throw const AuthException('登录等待超时，请重新尝试');
  }

  Future<void> logout() async {
    if (_token != null) {
      try {
        await http.post(
          Uri.parse('$_baseUrl/api/auth/logout'),
          headers: _headers,
        );
      } catch (_) {}
    }
    _token = null;
    await _storage.delete(key: _tokenKey);
  }

  Map<String, String> get _headers => {'authorization': 'Bearer $_token'};

  Future<AppUser> _accept(Map<String, dynamic> data) async {
    _token = data['token'] as String;
    await _storage.write(key: _tokenKey, value: _token);
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  String _friendlyError(String? error) => switch (error) {
    'INVALID_LOGIN' => '邮箱或密码不正确',
    'EMAIL_EXISTS' => '该邮箱已经注册',
    'INVALID_SIGNUP' => '请填写有效信息，密码至少 10 位',
    'INVALID_EMAIL_CODE' => '验证码不正确或已过期',
    'SMTP_NOT_CONFIGURED' => '邮件服务尚未配置',
    'CODE_RATE_LIMIT' => '发送过于频繁，请稍后再试',
    'EMAIL_SEND_FAILED' => '验证码邮件发送失败',
    _ => '连接服务器失败，请稍后再试',
  };
}

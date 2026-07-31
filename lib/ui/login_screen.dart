import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.auth,
    required this.onSignedIn,
    required this.onToggleTheme,
  });
  final AuthService auth;
  final ValueChanged<AppUser> onSignedIn;
  final VoidCallback onToggleTheme;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  late final AnimationController _logoAnimation;
  bool _signup = false;
  bool _busy = false;
  bool _obscure = true;
  int _signupStep = 1;
  int _codeCooldown = 0;
  Timer? _codeTimer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _logoAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoAnimation.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _code.dispose();
    _codeTimer?.cancel();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_signup && _signupStep == 1) {
      setState(() {
        _signupStep = 2;
        _error = null;
      });
      return;
    }
    await _run(
      () => widget.auth.emailAuth(
        email: _email.text,
        password: _password.text,
        name: _signup ? _name.text : null,
        code: _signup ? _code.text : null,
      ),
    );
  }

  Future<void> _sendCode() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.auth.sendEmailCode(_email.text);
      if (!mounted) return;
      setState(() => _codeCooldown = 60);
      _codeTimer?.cancel();
      _codeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || _codeCooldown <= 1) {
          timer.cancel();
          if (mounted) setState(() => _codeCooldown = 0);
        } else {
          setState(() => _codeCooldown--);
        }
      });
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = '无法连接服务器，请检查网络');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _run(Future<AppUser> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      widget.onSignedIn(await action());
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = '无法连接服务器，请检查网络');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _BackdropPainter(dark))),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton.filledTonal(
              onPressed: widget.onToggleTheme,
              tooltip: '切换明暗主题',
              icon: Icon(
                dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(36, 28, 36, 26),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _logoAnimation,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, -3 + _logoAnimation.value * 6),
                        child: child,
                      ),
                      child: Container(
                        width: 82,
                        height: 82,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF9D5BE8,
                              ).withValues(alpha: .24),
                              blurRadius: 28,
                            ),
                          ],
                        ),
                        child: SvgPicture.asset('assets/silhouette-mark.svg'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Silhouette',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _signup ? '创建你的剪影账户' : '登录以连接到 Silhouette',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (_signup && _signupStep == 1) ...[
                      TextFormField(
                        controller: _name,
                        enabled: !_busy,
                        decoration: const InputDecoration(
                          labelText: '显示名称',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (value) => (value?.trim().length ?? 0) < 2
                            ? '请输入至少 2 个字符'
                            : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (!_signup || _signupStep == 1) ...[
                      TextFormField(
                        controller: _email,
                        enabled: !_busy,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: '电子邮箱',
                          prefixIcon: Icon(Icons.alternate_email),
                        ),
                        validator: (value) =>
                            value != null && value.contains('@')
                            ? null
                            : '请输入有效邮箱',
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _password,
                        enabled: !_busy,
                        obscureText: _obscure,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: '密码',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _obscure ? '显示密码' : '隐藏密码',
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        validator: (value) =>
                            (value?.length ?? 0) < 10 ? '密码至少需要 10 位' : null,
                      ),
                    ] else ...[
                      TextFormField(
                        initialValue: _email.text,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: '电子邮箱',
                          prefixIcon: Icon(Icons.alternate_email),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: TextFormField(
                                controller: _code,
                                enabled: !_busy,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                decoration: InputDecoration(
                                  labelText: '验证码',
                                  counterText: '',
                                  prefixIcon: Transform.translate(
                                    offset: const Offset(-4, 0),
                                    child: const Icon(
                                      Icons.verified_outlined,
                                      size: 24,
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 48,
                                  ),
                                  isDense: true,
                                  constraints: const BoxConstraints.tightFor(
                                    height: 58,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 16,
                                  ),
                                ),
                                validator: (value) => value?.trim().length == 6
                                    ? null
                                    : '请输入 6 位验证码',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 124,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: _busy || _codeCooldown > 0
                                  ? null
                                  : _sendCode,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                _codeCooldown > 0
                                    ? '${_codeCooldown}s'
                                    : '发送验证码',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _busy
                              ? null
                              : () => setState(() {
                                  _signupStep = 1;
                                  _error = null;
                                }),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('返回上一步'),
                        ),
                      ),
                    ],
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _signup
                                  ? (_signupStep == 1 ? '下一步' : '创建账户')
                                  : 'Sign in',
                            ),
                    ),
                    if (!_signup || _signupStep == 1) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('或'),
                          ),
                          Expanded(
                            child: Divider(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _run(widget.auth.googleAuth),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Text(
                          'G',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7DA6F8),
                          ),
                        ),
                        label: const Text('继续使用 Google'),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => setState(() {
                                _signup = !_signup;
                                _signupStep = 1;
                                _error = null;
                              }),
                        child: Text(
                          _signup ? '已有账户？ Sign in' : '没有账户？ Sign up',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter(this.dark);
  final bool dark;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(.75, -.8),
        radius: 1.15,
        colors: dark
            ? const [Color(0x332A1245), Color(0xFF09070C)]
            : const [Color(0xFFE8DDF4), Color(0xFFF4F1F6)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) =>
      oldDelegate.dark != dark;
}

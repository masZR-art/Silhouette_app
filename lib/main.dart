import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'services/auth_service.dart';
import 'ui/login_screen.dart';
import 'ui/main_shell.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  const options = WindowOptions(
    size: Size(460, 650),
    minimumSize: Size(430, 610),
    maximumSize: Size(540, 760),
    center: true,
    title: 'Silhouette',
    backgroundColor: Colors.transparent,
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  final preferences = await SharedPreferences.getInstance();
  runApp(SilhouetteApp(preferences: preferences));
}

class SilhouetteApp extends StatefulWidget {
  const SilhouetteApp({super.key, required this.preferences});
  final SharedPreferences preferences;

  @override
  State<SilhouetteApp> createState() => _SilhouetteAppState();
}

class _SilhouetteAppState extends State<SilhouetteApp> {
  final AuthService _auth = AuthService();
  AppUser? _user;
  bool _checkingSession = true;
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.preferences.getBool('light_theme') == true
        ? ThemeMode.light
        : ThemeMode.dark;
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final user = await _auth.restoreSession();
    if (!mounted) return;
    setState(() {
      _user = user;
      _checkingSession = false;
    });
    if (user != null) await _showMainWindow();
  }

  Future<void> _showMainWindow() async {
    await windowManager.setMaximumSize(const Size(1920, 1200));
    await windowManager.setMinimumSize(const Size(900, 620));
    await windowManager.setSize(const Size(1120, 760), animate: true);
    await windowManager.center(animate: true);
  }

  Future<void> _signedIn(AppUser user) async {
    setState(() => _user = user);
    await _showMainWindow();
  }

  Future<void> _logout() async {
    await _auth.logout();
    setState(() => _user = null);
    await windowManager.setMinimumSize(const Size(430, 610));
    await windowManager.setMaximumSize(const Size(540, 760));
    await windowManager.setSize(const Size(460, 650), animate: true);
    await windowManager.center(animate: true);
  }

  void _toggleTheme() {
    final light = _themeMode != ThemeMode.light;
    widget.preferences.setBool('light_theme', light);
    setState(() => _themeMode = light ? ThemeMode.light : ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Silhouette',
      theme: buildSilhouetteTheme(Brightness.light),
      darkTheme: buildSilhouetteTheme(Brightness.dark),
      themeMode: _themeMode,
      home: _checkingSession
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _user == null
          ? LoginScreen(
              auth: _auth,
              onSignedIn: _signedIn,
              onToggleTheme: _toggleTheme,
            )
          : MainShell(
              user: _user!,
              onLogout: _logout,
              onToggleTheme: _toggleTheme,
            ),
    );
  }
}

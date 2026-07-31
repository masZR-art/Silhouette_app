import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/auth_service.dart';

class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onToggleTheme,
  });
  final AppUser user;
  final VoidCallback onLogout;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(right: BorderSide(color: colors.outlineVariant)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/silhouette-mark.svg', width: 38),
                      const SizedBox(width: 11),
                      const Text(
                        'Silhouette',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                const SizedBox(height: 14),
                _NavItem(
                  icon: Icons.chat_bubble_outline,
                  label: '聊天',
                  selected: true,
                ),
                const _NavItem(icon: Icons.mail_outline, label: '私密消息'),
                const _NavItem(icon: Icons.link, label: '链接'),
                const Spacer(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colors.primaryContainer,
                    child: Text(user.name.characters.first.toUpperCase()),
                  ),
                  title: Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: onToggleTheme,
                        tooltip: '切换主题',
                        icon: const Icon(Icons.contrast),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: onLogout,
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('退出'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: colors.outlineVariant),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        '聊天',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.lock_outline, size: 18),
                      SizedBox(width: 7),
                      Text('端到端加密', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Icon(
                            Icons.mark_chat_read_outlined,
                            size: 34,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '登录成功，后续内容开发中',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '欢迎回来，${user.name}',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });
  final IconData icon;
  final String label;
  final bool selected;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
    child: ListTile(
      selected: selected,
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: .55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      leading: Icon(icon),
      title: Text(label),
    ),
  );
}

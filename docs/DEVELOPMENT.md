# Development Guide

## Milestones

1. Native Windows shell, navigation, theme, and localization.
2. HTTPS API client and account session.
3. WebSocket signaling protocol.
4. WebRTC DataChannel and connection states.
5. AES-256-GCM message packets and read receipts.
6. Chunked P2P attachments up to 10 MB.
7. Secure local room list and deep links.
8. Message and URL features.
9. System-browser Google OAuth.
10. Tests, code signing, and installer.

## Rules

- Do not use WebView or embed the production website.
- Keep UI, networking, storage, and cryptography in separate modules.
- Do not log room keys, OAuth tickets, complete invitation URLs, message text, or attachment data.
- Use a new 12-byte nonce for every AES-GCM packet.
- Use WebSocket only for offer, answer, ICE, presence, and room coordination.
- Do not add TURN unless the product privacy policy is explicitly changed.
- Do not store chat history.

## Commands

```powershell
flutter pub get
dart format .
flutter analyze
flutter test
flutter run -d windows
flutter build windows --release
```

## Branches

- `main`: stable and buildable.
- Feature work: `feature/short-description`.
- Fixes: `fix/short-description`.

Keep commits small and run analyze and tests before pushing.

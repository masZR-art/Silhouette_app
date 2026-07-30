# Silhouette for Windows

Native Flutter client for Silhouette private messages, encrypted URL sharing, and WebRTC P2P chat.

This repository contains the Windows client. It is not an Electron application and does not embed the Silhouette website.

## Current Status

The project is in the initial Windows-native development phase. The first milestone is the application shell and design system.

## Requirements

- Windows 10 or Windows 11 x64
- Flutter Stable 3.44 or newer
- Visual Studio 2022 with **Desktop development with C++**
- Windows 10/11 SDK
- VS Code with the Flutter extension

## Setup

```powershell
flutter doctor -v
flutter pub get
flutter run -d windows
```

## Quality Checks

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build windows --release
```

## Architecture

```text
Flutter native UI
  -> HTTPS API: account and encrypted one-time payloads
  -> WebSocket: WebRTC signaling only
  -> WebRTC DataChannel: encrypted messages, receipts, and attachments
```

Chat content, attachments, and room keys must never be sent to the signaling server. New developers should start with the [Beginner Tutorial](docs/BEGINNER_TUTORIAL.md), then read the [Development Guide](docs/DEVELOPMENT.md) and [Security Policy](SECURITY.md).

## Production Service

`https://chat.silh0uette.space`

## License

Copyright (c) 2026 Silhouette. No license has been granted yet. Add an explicit license before accepting external code contributions.

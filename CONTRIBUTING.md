# Contributing

Silhouette is currently maintained as a security-sensitive application.

1. Create a branch from `main`.
2. Keep changes limited to one feature or fix.
3. Do not commit credentials, room links, user data, generated builds, or `.env` files.
4. Run formatting, static analysis, and tests.
5. Explain security and privacy effects in the pull request.

```powershell
dart format .
flutter analyze
flutter test
```

Security vulnerabilities must be reported privately according to `SECURITY.md`, not through a public issue.

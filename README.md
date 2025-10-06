# bajetimor_sqlite

## Android CI Build (Signed AAB)

Use the included GitHub Actions workflow to build a signed Android App Bundle without setting up the local Android SDK.

### Prerequisites
- Ensure your keystore exists locally at `android/app/release-key.jks` and you know:
  - Keystore password
  - Key alias
  - Key password
- Confirm `android/app/build.gradle.kts` is configured for release signing (already wired to use `android/key.properties`).

### Add GitHub Secrets
Add these repository secrets in GitHub → Settings → Secrets and variables → Actions:
- `RELEASE_KEYSTORE_BASE64` – Base64 of `android/app/release-key.jks`
- `RELEASE_KEYSTORE_PASSWORD` – Keystore password
- `RELEASE_KEY_ALIAS` – Key alias
- `RELEASE_KEY_PASSWORD` – Key password

To generate the Base64 value on Windows PowerShell (run at repo root):

```
Set-Location bajetimor_sqlite
$path = "android/app/release-key.jks"
[Convert]::ToBase64String([IO.File]::ReadAllBytes($path)) | Set-Content -NoNewline -Encoding ascii "release-key.jks.base64"
Get-Content "release-key.jks.base64" | Clip
```

This writes the Base64 to `release-key.jks.base64` and copies it to your clipboard; paste into the `RELEASE_KEYSTORE_BASE64` secret.

### Trigger the Workflow
- Go to GitHub → Actions → "Build Android AAB" → Run workflow.
- The workflow installs Android SDK packages, reconstructs the keystore and `key.properties` from secrets, and builds the signed AAB.
- Download artifact from the workflow run: `bajetimor-signed-aab` → `app-release.aab`.

### Notes
- CI removes `android/local.properties` to use the runner’s SDK.
- If the workflow fails on dependencies, run `flutter pub outdated` locally and adjust constraints in `pubspec.yaml` before re-running.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

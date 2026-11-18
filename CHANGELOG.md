# Changelog

## 2.7.1 (18.11.2026)

- Added the Android 14 `specialUse` foreground service type and required permission.
- Made native timeouts cancellable on Android and iOS; `clearTimeout` and `clearInterval` now cancel pending native callbacks.
- Improved background timer listener cleanup when restarting or stopping the timer.
- Updated the Android foreground service notification and lifecycle handling.

## 2.7.0 (17.11.2026)

- Fixed background timer behavior on Android 14.
- Replaced direct timer execution with a `Foreground Service`.
- Added a notification channel and persistent notification to keep the service active.
- Added wake lock management to prevent timer interruptions.
- Added support for `FOREGROUND_SERVICE_DATA_SYNC` and notification permissions.
- Improved timer lifecycle handling when starting and stopping the service.

## 2.6.0 (04.09.2025)

- [Typescript Support](https://github.com/boterop/react-native-background-timer/pull/20)

## 2.5.2 (16.08.2024)

- Fixes issue #13

## 2.5.1 (27.04.2024)

- Update scope to correct installations

## 2.5.0 (27.04.2024)

- Remove NativeEventEmitter warning
- Create auto-release and CI

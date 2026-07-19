# DIAGRAM
```
                         
                         ┌──────────────────────────┐
                         │      Global Workflows    │
                         │ dependency-review.yml    │
                         │ labeler.yml              │
                         │ stale.yml                │
                         │ release.yml              │
                         └──────────────┬───────────┘
                                        │
                                        ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                              Platform Workflows                            │
├────────────────────────────────────────────────────────────────────────────┤
│  flutter.yml   ← Dart, packages, plugins/lib                               │
│  android.yml   ← plugins/android, packages/android                         │
│  ios.yml       ← plugins/ios, packages/ios                                 │
│  macos.yml     ← plugins/macos                                             │
│  windows.yml   ← plugins/windows                                           │
│  linyx.yml     ← plugins/linux                                             │
│  web.yml       ← plugins/web                                               │
│  programs.yml  ← programs/**                                               │
└────────────────────────────────────────────────────────────────────────────┘
```

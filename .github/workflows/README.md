CI/CD Architecture

This repository uses a platform‑specific CI/CD system designed for a Melos‑managed, multi‑platform Flutter mono‑repo. Each platform has its own workflow, triggered only when relevant files change. This keeps CI fast, accurate, and prevents cross‑platform breakage.
Global Workflows

These run for all pull requests:

    dependency-review.yml — scans dependency changes

    labeler.yml — auto‑labels PRs

    stale.yml — manages stale issues/PRs

    release.yml — handles releases

Platform Workflows

Each platform has its own workflow:
Platform	Workflow	Trigger Paths
Flutter/Dart	flutter.yml	**/*.dart, packages/**, plugins/**/lib/**
Android	android.yml	plugins/**/android/**, packages/**/android/**
iOS	ios.yml	plugins/**/ios/**, packages/**/ios/**
macOS	macos.yml	plugins/**/macos/**
Windows	windows.yml	plugins/**/windows/**
Linux	linux.yml	plugins/**/linux/**
Web	web.yml	plugins/**/web/**
Programs	programs.yml	programs/**
Why Platform‑Specific Workflows?

Flutter plugins contain native code for multiple platforms. A change in one platform must not break another. Platform‑specific workflows ensure:

    Android changes build Android only

    iOS changes build iOS only

    Web changes build Web only

    Dart changes run Flutter tests

    Programs run generators only

This prevents unnecessary builds and ensures platform correctness.

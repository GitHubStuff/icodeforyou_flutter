# Swift Package Manager (SPM) replaces CocoaPods in Flutter apps

## History

This would typically create template_app with CocoaPods in iOS and MacOS platforms.

```zsh
% flutter create --org com.icodeforyou template_app
```

This would typically create template_app with CocoaPods in iOS and MacOS platforms.

This was suppose to moot/promoted in Flutter 3.44+, and even older packages should try
to promote their existing cococapods to SPM... but *Google* being kinda **Microsofty**
that doesn't always work. 🤮

## Solution

Adjust FVM...

```zsh
fvm flutter config --enable-swift-package-manager
```

This should be "one-and-done" and you will in SPM bliss.

### WARNING ⚠️

Mason is the go-forward, but still make find yourself creating packages, plugins, apps
in the terminal with:

```zsh
flutter create  --org com.icodeforyou -i swift island_control_ios
```

and forgetting the ***fvm*** prefix!

```zsh
fvm flutter create --org com.icodeforyou island_control_ios
```


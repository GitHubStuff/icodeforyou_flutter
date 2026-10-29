# Creating a flutter plug-in

## If there is NOT a brick template

```zsh
<uri> = com.icodeforyou
% fvm flutter create --template=plugin --platforms=ios --org <uri> --ios-language swift <plugin-name>
% fvm flutter create --template=plugin --platforms=ios --org <uri> <plugin-name> # defaults to swift

% fvm flutter create --template=plugin --platforms=android --org <uri> --android-language kotlin <name>
% fvm flutter create --template=plugin --platforms=android --org <uri> <name> # defaults to kotlin

% fvm flutter create --template=plugin --platforms=android,ios,macos,linux,windows,web --org <uri>
   --android-language kotlin --ios-language swift my_plugin
% fvm flutter create --template=plugin --platforms=android,ios,macos,linux,windows,web swift my_plugin
% # defaults to swift and kotlin
```

### Making the iOS-plugin brick

Create a raw template from the command line

```zsh
fvm flutter create --template=plugin --platforms=ios --org com.icodeforyou template_ios
```

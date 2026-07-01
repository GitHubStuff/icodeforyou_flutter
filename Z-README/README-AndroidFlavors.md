# AndroidFlavors.md

Android release identifiers use three common labels:

```txt
Version number → user-facing Android version
API level      → developer-facing SDK level
Codename       → dessert/internal release name
```
w
---

## Android Versions, Codenames, and API Levels

| Android Version | Codename / Name | API Level |
|---:|---|---:|
| Android 1.0 | No public codename | 1 |
| Android 1.1 | Petit Four | 2 |
| Android 1.5 | Cupcake | 3 |
| Android 1.6 | Donut | 4 |
| Android 2.0 | Eclair | 5 |
| Android 2.0.1 | Eclair | 6 |
| Android 2.1 | Eclair | 7 |
| Android 2.2 | Froyo | 8 |
| Android 2.3 | Gingerbread | 9 |
| Android 2.3.3 | Gingerbread | 10 |
| Android 3.0 | Honeycomb | 11 |
| Android 3.1 | Honeycomb | 12 |
| Android 3.2 | Honeycomb | 13 |
| Android 4.0 | Ice Cream Sandwich | 14 |
| Android 4.0.3 | Ice Cream Sandwich | 15 |
| Android 4.1 | Jelly Bean | 16 |
| Android 4.2 | Jelly Bean | 17 |
| Android 4.3 | Jelly Bean | 18 |
| Android 4.4 | KitKat | 19 |
| Android 4.4W | KitKat Watch | 20 |
| Android 5.0 | Lollipop | 21 |
| Android 5.1 | Lollipop | 22 |
| Android 6.0 | Marshmallow | 23 |
| Android 7.0 | Nougat | 24 |
| Android 7.1 | Nougat | 25 |
| Android 8.0 | Oreo | 26 |
| Android 8.1 | Oreo | 27 |
| Android 9 | Pie | 28 |
| Android 10 | Quince Tart | 29 |
| Android 11 | Red Velvet Cake | 30 |
| Android 12 | Snow Cone | 31 |
| Android 12L | Snow Cone v2 | 32 |
| Android 13 | Tiramisu | 33 |
| Android 14 | Upside Down Cake | 34 |
| Android 15 | Vanilla Ice Cream | 35 |
| Android 16 | Baklava | 36 |

---

## Practical Usage

### In Kotlin / Android code

```kotlin
if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
    // Android 11 / API 30+
}
```

### Common constants

| Constant | Android Version | API |
|---|---:|---:|
| `Build.VERSION_CODES.Q` | Android 10 | 29 |
| `Build.VERSION_CODES.R` | Android 11 | 30 |
| `Build.VERSION_CODES.S` | Android 12 | 31 |
| `Build.VERSION_CODES.S_V2` | Android 12L | 32 |
| `Build.VERSION_CODES.TIRAMISU` | Android 13 | 33 |
| `Build.VERSION_CODES.UPSIDE_DOWN_CAKE` | Android 14 | 34 |
| `Build.VERSION_CODES.VANILLA_ICE_CREAM` | Android 15 | 35 |

---

## Rule of Thumb

```txt
Users talk in Android versions.
Developers code against API levels.
Codenames are mostly historical/internal labels.
```

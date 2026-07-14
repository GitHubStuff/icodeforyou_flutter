# AndroidFlavors.md

Android release identifiers use three common labels:

```txt
Version number → user-facing Android version
API level      → developer-facing SDK level
Codename       → dessert/internal release name
```
w
---
 In Kotlin / Android code

```kotlin
if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
    // Android 11 / API 30+
}
```

Using an imported `Build` class:

```kotlin
import android.os.Build

if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.BAKLAVA) {
    // Android 16 / API 36+
}
```

### Recent `Build.VERSION_CODES` constants

| Constant                                | Android Version | API Level |
| --------------------------------------- | --------------: | --------: |
| `Build.VERSION_CODES.M`                 |     Android 6.0 |        23 |
| `Build.VERSION_CODES.N`                 |     Android 7.0 |        24 |
| `Build.VERSION_CODES.N_MR1`             |     Android 7.1 |        25 |
| `Build.VERSION_CODES.O`                 |     Android 8.0 |        26 |
| `Build.VERSION_CODES.O_MR1`             |     Android 8.1 |        27 |
| `Build.VERSION_CODES.P`                 |       Android 9 |        28 |
| `Build.VERSION_CODES.Q`                 |      Android 10 |        29 |
| `Build.VERSION_CODES.R`                 |      Android 11 |        30 |
| `Build.VERSION_CODES.S`                 |      Android 12 |        31 |
| `Build.VERSION_CODES.S_V2`              |     Android 12L |        32 |
| `Build.VERSION_CODES.TIRAMISU`          |      Android 13 |        33 |
| `Build.VERSION_CODES.UPSIDE_DOWN_CAKE`  |      Android 14 |        34 |
| `Build.VERSION_CODES.VANILLA_ICE_CREAM` |      Android 15 |        35 |
| `Build.VERSION_CODES.BAKLAVA`           |      Android 16 |        36 |
| `Build.VERSION_CODES.CINNAMON_BUN`      |      Android 17 |        37 |

### All `Build.VERSION_CODES` constants

| Constant                                     | Android Version | API Level |
| -------------------------------------------- | --------------: | --------: |
| `Build.VERSION_CODES.BASE`                   |     Android 1.0 |         1 |
| `Build.VERSION_CODES.BASE_1_1`               |     Android 1.1 |         2 |
| `Build.VERSION_CODES.CUPCAKE`                |     Android 1.5 |         3 |
| `Build.VERSION_CODES.DONUT`                  |     Android 1.6 |         4 |
| `Build.VERSION_CODES.ECLAIR`                 |     Android 2.0 |         5 |
| `Build.VERSION_CODES.ECLAIR_0_1`             |   Android 2.0.1 |         6 |
| `Build.VERSION_CODES.ECLAIR_MR1`             |     Android 2.1 |         7 |
| `Build.VERSION_CODES.FROYO`                  |     Android 2.2 |         8 |
| `Build.VERSION_CODES.GINGERBREAD`            |     Android 2.3 |         9 |
| `Build.VERSION_CODES.GINGERBREAD_MR1`        |   Android 2.3.3 |        10 |
| `Build.VERSION_CODES.HONEYCOMB`              |     Android 3.0 |        11 |
| `Build.VERSION_CODES.HONEYCOMB_MR1`          |     Android 3.1 |        12 |
| `Build.VERSION_CODES.HONEYCOMB_MR2`          |     Android 3.2 |        13 |
| `Build.VERSION_CODES.ICE_CREAM_SANDWICH`     |     Android 4.0 |        14 |
| `Build.VERSION_CODES.ICE_CREAM_SANDWICH_MR1` |   Android 4.0.3 |        15 |
| `Build.VERSION_CODES.JELLY_BEAN`             |     Android 4.1 |        16 |
| `Build.VERSION_CODES.JELLY_BEAN_MR1`         |     Android 4.2 |        17 |
| `Build.VERSION_CODES.JELLY_BEAN_MR2`         |     Android 4.3 |        18 |
| `Build.VERSION_CODES.KITKAT`                 |     Android 4.4 |        19 |
| `Build.VERSION_CODES.KITKAT_WATCH`           |    Android 4.4W |        20 |
| `Build.VERSION_CODES.LOLLIPOP`               |     Android 5.0 |        21 |
| `Build.VERSION_CODES.LOLLIPOP_MR1`           |     Android 5.1 |        22 |
| `Build.VERSION_CODES.M`                      |     Android 6.0 |        23 |
| `Build.VERSION_CODES.N`                      |     Android 7.0 |        24 |
| `Build.VERSION_CODES.N_MR1`                  |     Android 7.1 |        25 |
| `Build.VERSION_CODES.O`                      |     Android 8.0 |        26 |
| `Build.VERSION_CODES.O_MR1`                  |     Android 8.1 |        27 |
| `Build.VERSION_CODES.P`                      |       Android 9 |        28 |
| `Build.VERSION_CODES.Q`                      |      Android 10 |        29 |
| `Build.VERSION_CODES.R`                      |      Android 11 |        30 |
| `Build.VERSION_CODES.S`                      |      Android 12 |        31 |
| `Build.VERSION_CODES.S_V2`                   |     Android 12L |        32 |
| `Build.VERSION_CODES.TIRAMISU`               |      Android 13 |        33 |
| `Build.VERSION_CODES.UPSIDE_DOWN_CAKE`       |      Android 14 |        34 |
| `Build.VERSION_CODES.VANILLA_ICE_CREAM`      |      Android 15 |        35 |
| `Build.VERSION_CODES.BAKLAVA`                |      Android 16 |        36 |
| `Build.VERSION_CODES.CINNAMON_BUN`           |      Android 17 |        37 |

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

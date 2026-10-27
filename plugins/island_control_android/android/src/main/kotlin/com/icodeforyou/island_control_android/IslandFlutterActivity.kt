// plugins/island_control_android/android/src/main/kotlin/com/icodeforyou/island_control_android/IslandFlutterActivity.kt
package com.icodeforyou.island_control_android

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

/**
 * A [FlutterActivity] whose island is set before the first frame is drawn,
 * so there is no visible change between the launch window and Flutter.
 *
 * Apps extend this instead of [FlutterActivity]:
 *
 * ```kotlin
 * class MainActivity : IslandFlutterActivity()
 * ```
 *
 * Override [isIslandHiddenAtLaunch] to start with the island shown.
 */
open class IslandFlutterActivity : FlutterActivity() {

    /** Whether the island is hidden when the activity is created. */
    protected open val isIslandHiddenAtLaunch: Boolean = true

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Island(window).setHidden(isIslandHiddenAtLaunch)
    }
}
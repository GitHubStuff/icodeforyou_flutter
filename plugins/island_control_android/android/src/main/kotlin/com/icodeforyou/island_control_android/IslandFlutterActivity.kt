// plugins/island_control_android/android/src/main/kotlin/com/icodeforyou/island_control_android/IslandFlutterActivity.kt
// Versiona 0.0.2-beta
package com.icodeforyou.island_control_android

import io.flutter.embedding.android.FlutterActivity

/**
 * A [FlutterActivity] whose island is set the moment its window is attached,
 * before the first frame is drawn, so there is no visible change between the
 * launch window and Flutter.
 *
 * The island is set from [onAttachedToWindow] rather than `onCreate`: inset
 * animation control (see [Island]) needs an attached window, and a request
 * made before attachment is silently cancelled by the system.
 *
 * Apps extend this instead of [FlutterActivity]:
 *
 * ```kotlin
 * class MainActivity : IslandFlutterActivity()
 * ```
 *
 * Override [isIslandHiddenAtLaunch] to `false` to start with the island shown.
 */
open class IslandFlutterActivity : FlutterActivity() {

    /** Whether the island is hidden when the activity's window is attached. */
    protected open val isIslandHiddenAtLaunch: Boolean = true

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        Island(window).setHidden(isIslandHiddenAtLaunch)
    }
}
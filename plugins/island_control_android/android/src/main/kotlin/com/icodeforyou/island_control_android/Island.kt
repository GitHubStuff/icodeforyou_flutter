/* plugins/island_control_android/android/src/main/kotlin/com/icodeforyou/island_control_android/Island.kt */
// Version 0.0.7+1
package com.icodeforyou.island_control_android

import android.view.Window
import android.view.WindowInsets
import android.view.WindowInsetsAnimationControlListener
import android.view.WindowInsetsAnimationController
import android.view.WindowInsetsController

/**
 * Shows or hides the status bar ("island") of [window] without animation.
 *
 * Uses inset animation control with an immediate finish rather than
 * [WindowInsetsController.hide]/[WindowInsetsController.show], because on
 * API 36+ targets a plain hide is always animated by the system, and the
 * legacy fullscreen window flag is no longer honoured for the app window.
 *
 * Requires the window to be attached: call from `Activity.onAttachedToWindow`
 * or later. Called earlier, the system cancels the request.
 */
class Island(private val window: Window) {

    /** Hides the island when [isHidden] is `true`, shows it otherwise. Instant. */
    fun setHidden(isHidden: Boolean) {
        val controller = window.insetsController ?: return
        window.setDecorFitsSystemWindows(false)
        controller.systemBarsBehavior =
            WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        controller.setSystemBarsAppearance(0, WindowInsetsController.APPEARANCE_LIGHT_STATUS_BARS)
        controller.controlWindowInsetsAnimation(
            WindowInsets.Type.statusBars(),
            NO_DURATION,
            null,
            null,
            InstantListener(shown = !isHidden),
        )
    }

    /** Finishes the inset animation the moment it is ready, in its final state. */
    private class InstantListener(private val shown: Boolean) :
        WindowInsetsAnimationControlListener {

        override fun onReady(controller: WindowInsetsAnimationController, types: Int) {
            controller.finish(shown)
        }

        override fun onFinished(controller: WindowInsetsAnimationController) = Unit

        override fun onCancelled(controller: WindowInsetsAnimationController?) = Unit
    }

    private companion object {
        const val NO_DURATION = 0L
    }
}
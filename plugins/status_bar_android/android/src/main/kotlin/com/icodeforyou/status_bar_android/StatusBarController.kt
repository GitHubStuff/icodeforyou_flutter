// plugins/status_bar_android/android/src/main/kotlin/com/icodeforyou/status_bar_android/StatusBarController.kt
// Version: 0.0.1-a StatusBarAndroid

package com.icodeforyou.status_bar_android

import android.os.CancellationSignal
import android.view.Window
import android.view.WindowInsets
import android.view.WindowInsetsAnimationControlListener
import android.view.WindowInsetsAnimationController
import android.view.WindowInsetsController

/**
 * Shows or hides the status bar of a [StatusBar] with no transition.
 *
 * [WindowInsetsController.hide] and [WindowInsetsController.show] always
 * run the system's fade animation. Taking control of the animation via
 * [WindowInsetsController.controlWindowInsetsAnimation] and finishing it
 * in `onReady` snaps the bar to its end state in a single frame.
 *
 * Before touching the bar, the window is put edge-to-edge
 * ([Window.setDecorFitsSystemWindows] `false`). Otherwise the decor view
 * resizes when the bar goes and the whole Flutter view re-lays out;
 * edge-to-edge means only the top inset changes. On Android 15+ the
 * platform already enforces edge-to-edge and the call is a no-op.
 *
 * If the system refuses control (window not yet attached, no focus),
 * the listener falls back to the animated API so the call still takes
 * effect.
 *
 * No Android API is touched at class-initialisation time; the class must
 * stay mockable in plain JVM unit tests where `android.jar` is stubbed.
 */
class StatusBarController(private val window: Window) {

    /**
     * Hides the status bar when [isHidden] is `true`, shows it otherwise.
     *
     * While hidden, a swipe from the top edge reveals the bar
     * transiently; it hides again on its own.
     *
     * @return `true` if the request was issued to the window; `false` if
     * the window has no [WindowInsetsController] yet (its decor view is
     * not attached), in which case nothing was done and the caller must
     * report the failure rather than assume success.
     */
    fun setVisibility(isHidden: Boolean): Boolean {
        val insetsController = window.insetsController ?: return false
        val statusBarType = WindowInsets.Type.statusBars()

        ensureEdgeToEdge()

        insetsController.systemBarsBehavior =
            WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE

        insetsController.controlWindowInsetsAnimation(
            statusBarType,
            INSTANT_DURATION_MS,
            null,
            CancellationSignal(),
            InstantFinishListener(
                shown = !isHidden,
                statusBarType = statusBarType,
                fallback = insetsController,
            ),
        )
        return true
    }

    /**
     * Lets the window content extend under the system bars so a change
     * in status bar visibility changes the inset, not the view size.
     * Idempotent; safe to call on every toggle.
     *
     * [Window.setDecorFitsSystemWindows] is deprecated from API 35, where
     * Android 15 enforces edge-to-edge and the call does nothing. On this
     * plugin's floor, API 30 through 34, it is the only platform API (no
     * `androidx`) that turns edge-to-edge on, so it stays.
     */
    @Suppress("DEPRECATION")
    private fun ensureEdgeToEdge() {
        window.setDecorFitsSystemWindows(false)
    }

    /**
     * Finishes the controlled animation immediately in [onReady], and
     * falls back to the animated API if control is cancelled.
     */
    private class InstantFinishListener(
        private val shown: Boolean,
        private val statusBarType: Int,
        private val fallback: WindowInsetsController,
    ) : WindowInsetsAnimationControlListener {

        override fun onReady(
            controller: WindowInsetsAnimationController,
            types: Int,
        ) {
            controller.finish(shown)
        }

        override fun onFinished(
            controller: WindowInsetsAnimationController,
        ) = Unit

        override fun onCancelled(
            controller: WindowInsetsAnimationController?,
        ) {
            if (shown) {
                fallback.show(statusBarType)
            } else {
                fallback.hide(statusBarType)
            }
        }
    }

    private companion object {
        /** Zero-length animation: the end state is applied in one frame. */
        const val INSTANT_DURATION_MS: Long = 0L
    }
}
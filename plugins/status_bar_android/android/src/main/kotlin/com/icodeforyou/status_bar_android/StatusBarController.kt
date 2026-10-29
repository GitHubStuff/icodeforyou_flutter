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
 * Shows or hides the status bar of a [Window] with no transition.
 *
 * [WindowInsetsController.hide] and [WindowInsetsController.show] always
 * run the system's fade animation. Taking control of the animation via
 * [WindowInsetsController.controlWindowInsetsAnimation] and finishing it
 * in `onReady` snaps the bar to its end state in a single frame.
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
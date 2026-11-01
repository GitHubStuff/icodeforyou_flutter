// plugins/status_bar_android/android/src/test/kotlin/com/icodeforyou/status_bar_android/StatusBarControllerTest.kt
// Version: 0.0.1-a StatusBarAndroid

package com.icodeforyou.status_bar_android

import android.os.CancellationSignal
import android.view.Window
import android.view.WindowInsets
import android.view.WindowInsetsAnimationControlListener
import android.view.WindowInsetsAnimationController
import android.view.WindowInsetsController
import org.mockito.ArgumentCaptor
import org.mockito.ArgumentMatchers.any
import org.mockito.ArgumentMatchers.anyInt
import org.mockito.ArgumentMatchers.anyLong
import org.mockito.ArgumentMatchers.eq
import org.mockito.ArgumentMatchers.isNull
import org.mockito.Mockito.inOrder
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.mockito.Mockito.verifyNoInteractions
import org.mockito.Mockito.verifyNoMoreInteractions
import org.mockito.Mockito.`when`
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/**
 * Unit tests for [StatusBarController].
 *
 * [Window] and [WindowInsetsController] are Mockito mocks. The two
 * platform calls the controller makes that cannot be mocked —
 * `WindowInsets.Type.statusBars()` and `CancellationSignal()` — are
 * `android.jar` stubs; `isReturnDefaultValues = true` in
 * `build.gradle.kts` makes them return defaults instead of throwing.
 * Run from `example/android/`: `./gradlew testDebugUnitTest`.
 *
 * `Window.setDecorFitsSystemWindows` is deprecated from API 35; the
 * controller still calls it for API 30–34 (see its doc comment), so the
 * tests that verify the call suppress the same warning.
 */
internal class StatusBarControllerTest {

    private lateinit var window: Window
    private lateinit var insetsController: WindowInsetsController
    private lateinit var animationController: WindowInsetsAnimationController
    private lateinit var controller: StatusBarController

    @BeforeTest
    fun setUp() {
        window = mock(Window::class.java)
        insetsController = mock(WindowInsetsController::class.java)
        animationController = mock(WindowInsetsAnimationController::class.java)
        `when`(window.insetsController).thenReturn(insetsController)

        controller = StatusBarController(window)
    }

    @Test
    @Suppress("DEPRECATION")
    fun setVisibility_withoutInsetsController_returnsFalseAndTouchesNothing() {
        `when`(window.insetsController).thenReturn(null)

        val issued = controller.setVisibility(isHidden = true)

        assertFalse(issued)
        verify(window, never()).setDecorFitsSystemWindows(false)
        verifyNoInteractions(insetsController)
    }

    @Test
    fun setVisibility_withInsetsController_returnsTrue() {
        val issued = controller.setVisibility(isHidden = true)

        assertTrue(issued)
    }

    @Test
    @Suppress("DEPRECATION")
    fun setVisibility_putsWindowEdgeToEdgeBeforeControllingInsets() {
        controller.setVisibility(isHidden = true)

        val order = inOrder(window, insetsController)
        order.verify(window).setDecorFitsSystemWindows(false)
        order.verify(insetsController).controlWindowInsetsAnimation(
            anyInt(),
            anyLong(),
            isNull(),
            any(CancellationSignal::class.java),
            any(WindowInsetsAnimationControlListener::class.java),
        )
    }

    @Test
    fun setVisibility_setsTransientBarsBySwipe() {
        controller.setVisibility(isHidden = true)

        verify(insetsController).setSystemBarsBehavior(
            WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE,
        )
    }

    @Test
    fun setVisibility_requestsZeroDurationControlOfStatusBars() {
        controller.setVisibility(isHidden = true)

        verify(insetsController).controlWindowInsetsAnimation(
            eq(WindowInsets.Type.statusBars()),
            eq(0L),
            isNull(),
            any(CancellationSignal::class.java),
            any(WindowInsetsAnimationControlListener::class.java),
        )
    }

    @Test
    fun setVisibility_hidden_onReady_finishesHidden() {
        val listener = captureListener(isHidden = true)

        listener.onReady(animationController, WindowInsets.Type.statusBars())

        verify(animationController).finish(false)
        verifyNoMoreInteractions(animationController)
    }

    @Test
    fun setVisibility_visible_onReady_finishesShown() {
        val listener = captureListener(isHidden = false)

        listener.onReady(animationController, WindowInsets.Type.statusBars())

        verify(animationController).finish(true)
        verifyNoMoreInteractions(animationController)
    }

    @Test
    fun setVisibility_hidden_onCancelled_fallsBackToAnimatedHide() {
        val listener = captureListener(isHidden = true)

        listener.onCancelled(null)

        verify(insetsController).hide(WindowInsets.Type.statusBars())
        verify(insetsController, never()).show(anyInt())
    }

    @Test
    fun setVisibility_visible_onCancelled_fallsBackToAnimatedShow() {
        val listener = captureListener(isHidden = false)

        listener.onCancelled(null)

        verify(insetsController).show(WindowInsets.Type.statusBars())
        verify(insetsController, never()).hide(anyInt())
    }

    @Test
    fun setVisibility_onFinished_doesNothing() {
        val listener = captureListener(isHidden = true)

        listener.onFinished(animationController)

        verifyNoInteractions(animationController)
    }

    /**
     * Issues `setVisibility(isHidden)` and returns the listener the
     * controller handed to [WindowInsetsController.controlWindowInsetsAnimation].
     */
    private fun captureListener(
        isHidden: Boolean,
    ): WindowInsetsAnimationControlListener {
        val captor =
            ArgumentCaptor.forClass(WindowInsetsAnimationControlListener::class.java)

        controller.setVisibility(isHidden)

        verify(insetsController).controlWindowInsetsAnimation(
            anyInt(),
            anyLong(),
            isNull(),
            any(CancellationSignal::class.java),
            captor.capture(),
        )
        return captor.value
    }
}

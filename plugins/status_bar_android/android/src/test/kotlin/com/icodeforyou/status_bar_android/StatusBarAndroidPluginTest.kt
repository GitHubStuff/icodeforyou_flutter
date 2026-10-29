// plugins/status_bar_android/android/src/test/kotlin/com/icodeforyou/status_bar_android/StatusBarAndroidPluginTest.kt
// Version: 0.0.1-a StatusBarAndroid

package com.icodeforyou.status_bar_android

import android.app.Activity
import android.view.Window
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import org.mockito.ArgumentMatchers.anyBoolean
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.mockito.Mockito.verifyNoMoreInteractions
import org.mockito.Mockito.`when`
import kotlin.test.BeforeTest
import kotlin.test.Test

/**
 * Unit tests for the channel contract of [StatusBarAndroidPlugin].
 *
 * The [StatusBarController] is replaced by a mock through the injectable
 * factory, so no real [Window] is needed. Run from `example/android/`:
 * `./gradlew testDebugUnitTest`.
 */
internal class StatusBarAndroidPluginTest {

    private lateinit var controller: StatusBarController
    private lateinit var window: Window
    private lateinit var binding: ActivityPluginBinding
    private lateinit var result: Result
    private lateinit var plugin: StatusBarAndroidPlugin

    @BeforeTest
    fun setUp() {
        controller = mock(StatusBarController::class.java)
        `when`(controller.setVisibility(anyBoolean())).thenReturn(true)

        window = mock(Window::class.java)
        result = mock(Result::class.java)

        val activity = mock(Activity::class.java)
        `when`(activity.window).thenReturn(window)

        binding = mock(ActivityPluginBinding::class.java)
        `when`(binding.activity).thenReturn(activity)

        plugin = StatusBarAndroidPlugin { controller }
    }

    @Test
    fun unknownMethod_reportsNotImplemented() {
        plugin.onAttachedToActivity(binding)

        plugin.onMethodCall(MethodCall("bogus", null), result)

        verify(result).notImplemented()
        verifyNoMoreInteractions(result)
    }

    @Test
    fun setVisibility_withoutActivity_reportsNoActivity() {
        plugin.onMethodCall(setVisibilityCall(isHidden = true), result)

        verify(result).error(
            StatusBarAndroidPlugin.ERROR_NO_ACTIVITY,
            "No activity is attached.",
            null,
        )
        verify(controller, never()).setVisibility(anyBoolean())
    }

    @Test
    fun setVisibility_afterDetach_reportsNoActivity() {
        plugin.onAttachedToActivity(binding)
        plugin.onDetachedFromActivity()

        plugin.onMethodCall(setVisibilityCall(isHidden = true), result)

        verify(result).error(
            StatusBarAndroidPlugin.ERROR_NO_ACTIVITY,
            "No activity is attached.",
            null,
        )
        verify(controller, never()).setVisibility(anyBoolean())
    }

    @Test
    fun setVisibility_missingArgument_reportsInvalidArgument() {
        plugin.onAttachedToActivity(binding)

        plugin.onMethodCall(
            MethodCall(StatusBarAndroidPlugin.METHOD_SET_VISIBILITY, null),
            result,
        )

        verify(result).error(
            StatusBarAndroidPlugin.ERROR_INVALID_ARGUMENT,
            "'isHidden' must be a non-null Boolean.",
            null,
        )
        verify(controller, never()).setVisibility(anyBoolean())
    }

    @Test
    fun setVisibility_hidden_delegatesAndSucceeds() {
        plugin.onAttachedToActivity(binding)

        plugin.onMethodCall(setVisibilityCall(isHidden = true), result)

        verify(controller).setVisibility(isHidden = true)
        verify(result).success(null)
        verifyNoMoreInteractions(result)
    }

    @Test
    fun setVisibility_visible_delegatesAndSucceeds() {
        plugin.onAttachedToActivity(binding)

        plugin.onMethodCall(setVisibilityCall(isHidden = false), result)

        verify(controller).setVisibility(isHidden = false)
        verify(result).success(null)
        verifyNoMoreInteractions(result)
    }

    @Test
    fun setVisibility_controllerCannotAct_reportsNoInsetsController() {
        `when`(controller.setVisibility(anyBoolean())).thenReturn(false)
        plugin.onAttachedToActivity(binding)

        plugin.onMethodCall(setVisibilityCall(isHidden = true), result)

        verify(controller).setVisibility(isHidden = true)
        verify(result).error(
            StatusBarAndroidPlugin.ERROR_NO_INSETS_CONTROLLER,
            "The window has no insets controller yet.",
            null,
        )
        verifyNoMoreInteractions(result)
    }

    @Test
    fun setVisibility_afterConfigChangeReattach_delegates() {
        plugin.onAttachedToActivity(binding)
        plugin.onDetachedFromActivityForConfigChanges()
        plugin.onReattachedToActivityForConfigChanges(binding)

        plugin.onMethodCall(setVisibilityCall(isHidden = true), result)

        verify(controller).setVisibility(isHidden = true)
        verify(result).success(null)
    }

    private fun setVisibilityCall(isHidden: Boolean): MethodCall =
        MethodCall(
            StatusBarAndroidPlugin.METHOD_SET_VISIBILITY,
            mapOf(StatusBarAndroidPlugin.ARG_IS_HIDDEN to isHidden),
        )
}
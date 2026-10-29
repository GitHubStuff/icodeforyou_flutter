package com.icodeforyou.status_bar_android

// plugins/status_bar_android/android/src/main/kotlin/com/icodeforyou/status_bar_android/StatusBarAndroidPlugin.kt
// Version 0.0.1-a StatusBarAndroid

import android.view.Window
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Flutter entry point for `status_bar_android`.
 *
 * Owns the method channel and the activity lifecycle, and delegates the
 * actual window work to a [StatusBarController]. The controller factory is
 * injectable so the channel contract can be unit-tested without a real
 * [Window].
 */
class StatusBarAndroidPlugin internal constructor(
    private val controllerFactory: (Window) -> StatusBarController,
) : FlutterPlugin, ActivityAware, MethodCallHandler {

    /** Production constructor used by the Flutter plugin registrant. */
    constructor() : this(::StatusBarController)

    private var channel: MethodChannel? = null
    private var controller: StatusBarController? = null

    // --- FlutterPlugin ---------------------------------------------------

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME).also {
            it.setMethodCallHandler(this)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    // --- ActivityAware ---------------------------------------------------

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        controller = controllerFactory(binding.activity.window)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        controller = null
    }

    override fun onReattachedToActivityForConfigChanges(
        binding: ActivityPluginBinding,
    ) {
        controller = controllerFactory(binding.activity.window)
    }

    override fun onDetachedFromActivity() {
        controller = null
    }

    // --- MethodCallHandler -----------------------------------------------

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            METHOD_SET_VISIBILITY -> setVisibility(call, result)
            else -> result.notImplemented()
        }
    }

    private fun setVisibility(call: MethodCall, result: Result) {
        val activeController = controller
        if (activeController == null) {
            result.error(ERROR_NO_ACTIVITY, "No activity is attached.", null)
            return
        }

        val isHidden = call.argument<Boolean>(ARG_IS_HIDDEN)
        if (isHidden == null) {
            result.error(
                ERROR_INVALID_ARGUMENT,
                "'$ARG_IS_HIDDEN' must be a non-null Boolean.",
                null,
            )
            return
        }

        activeController.setVisibility(isHidden = isHidden)
        result.success(null)
    }

    companion object {
        /** Method channel name; must match the Dart side. */
        const val CHANNEL_NAME = "status_bar_android"

        /** Method name; must match the Dart side. */
        const val METHOD_SET_VISIBILITY = "setVisibility"

        /** Argument key; must match the Dart side. */
        const val ARG_IS_HIDDEN = "isHidden"

        /** Error code when no activity is attached to the engine. */
        const val ERROR_NO_ACTIVITY = "NO_ACTIVITY"

        /** Error code when the method arguments are malformed. */
        const val ERROR_INVALID_ARGUMENT = "INVALID_ARGUMENT"
    }
}
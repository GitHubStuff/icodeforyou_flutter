/* plugins/island_control_android/android/src/main/kotlin/com/icodeforyou/island_control_android/IslandControlAndroidPlugin.kt */
package com.icodeforyou.island_control_android

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** Bridges the `island_control_android` method channel to [Island]. */
class IslandControlAndroidPlugin :
    FlutterPlugin,
    ActivityAware,
    MethodCallHandler {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            METHOD_SET_ISLAND -> setIsland(call, result)
            else -> result.notImplemented()
        }
    }

    private fun setIsland(call: MethodCall, result: Result) {
        val isHidden = call.argument<Boolean>(ARG_IS_HIDDEN)
        if (isHidden == null) {
            result.error(ERROR_ARGUMENT, "'$ARG_IS_HIDDEN' must be a Boolean", null)
            return
        }
        val window = activity?.window
        if (window == null) {
            result.error(ERROR_NO_ACTIVITY, "No activity attached", null)
            return
        }
        Island(window).setHidden(isHidden)
        result.success(null)
    }

    private companion object {
        const val CHANNEL_NAME = "island_control_android"
        const val METHOD_SET_ISLAND = "setIsland"
        const val ARG_IS_HIDDEN = "isHidden"
        const val ERROR_ARGUMENT = "argument"
        const val ERROR_NO_ACTIVITY = "no_activity"
    }
}
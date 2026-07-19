// plugins/status_bar_chameleon/android/src/main/kotlin/com/icodeforyou/status_bar_chameleon/StatusBarChameleonPlugin.kt
package com.icodeforyou.status_bar_chameleon

import android.animation.ValueAnimator
import android.app.Activity
import android.os.Build
import android.view.WindowInsets
import android.view.WindowInsetsAnimationController
import android.view.WindowInsetsAnimationControlListener
import android.view.animation.LinearInterpolator
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class StatusBarChameleonPlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    ActivityAware {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var runningAnimator: ValueAnimator? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(
            binding.binaryMessenger,
            "status_bar_chameleon/status_bar"
        )
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "setStatusBarHidden") {
            result.notImplemented()
            return
        }

        val hidden = call.argument<Boolean>("hidden") ?: false
        val durationMs = (call.argument<Number>("durationMs") ?: 0).toLong()

        val act = activity
        if (act == null) {
            result.error("NO_ACTIVITY", "Activity is null", null)
            return
        }

        // API 30+ supports manual animation control; below that, instant only.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && durationMs > 0) {
            animateStatusBar(act, hidden, durationMs, result)
        } else {
            setStatusBarImmediate(act, hidden)
            result.success(null)
        }
    }

    private fun setStatusBarImmediate(act: Activity, hidden: Boolean) {
        val window = act.window
        val controller = WindowInsetsControllerCompat(window, window.decorView)
        if (hidden) {
            controller.hide(WindowInsetsCompat.Type.statusBars())
        } else {
            controller.show(WindowInsetsCompat.Type.statusBars())
        }
    }

    private fun animateStatusBar(
        act: Activity,
        hidden: Boolean,
        durationMs: Long,
        result: MethodChannel.Result,
    ) {
        runningAnimator?.cancel()
        runningAnimator = null

        val window = act.window
        val rootInsetsController = window.decorView.windowInsetsController
        if (rootInsetsController == null) {
            setStatusBarImmediate(act, hidden)
            result.success(null)
            return
        }

        rootInsetsController.controlWindowInsetsAnimation(
            WindowInsets.Type.statusBars(),
            -1L, // we drive the timing ourselves
            LinearInterpolator(),
            null,
            object : WindowInsetsAnimationControlListener {
                override fun onReady(
                    controller: WindowInsetsAnimationController,
                    types: Int,
                ) {
                    val shown = controller.shownStateInsets.top.toFloat()
                    val from = if (hidden) shown else 0f
                    val to = if (hidden) 0f else shown

                    val animator = ValueAnimator.ofFloat(from, to).apply {
                        duration = durationMs
                        interpolator = LinearInterpolator()
                        addUpdateListener { va ->
                            val v = va.animatedValue as Float
                            // setInsetsAndAlpha wants top inset 0..shown
                            controller.setInsetsAndAlpha(
                                android.graphics.Insets.of(0, v.toInt(), 0, 0),
                                1f,
                                if (shown == 0f) 1f else v / shown,
                            )
                        }
                        addListener(object : android.animation.AnimatorListenerAdapter() {
                            override fun onAnimationEnd(animation: android.animation.Animator) {
                                controller.finish(!hidden) // finish in target state
                                runningAnimator = null
                            }
                            override fun onAnimationCancel(animation: android.animation.Animator) {
                                controller.finish(!hidden)
                                runningAnimator = null
                            }
                        })
                    }
                    runningAnimator = animator
                    animator.start()
                    result.success(null)
                }

                override fun onFinished(controller: WindowInsetsAnimationController) {
                    // no-op
                }

                override fun onCancelled(controller: WindowInsetsAnimationController?) {
                    runningAnimator?.cancel()
                    runningAnimator = null
                }
            }
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        runningAnimator?.cancel()
        runningAnimator = null
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }
}
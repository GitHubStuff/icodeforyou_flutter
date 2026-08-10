// plugins/status_bar_chameleon/android/src/main/kotlin/com/icodeforyou/status_bar_chameleon/StatusBarChameleonPlugin.kt
package com.icodeforyou.status_bar_chameleon

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ValueAnimator
import android.app.Activity
import android.graphics.Insets
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
        applyBehavior(controller, hidden)
        if (hidden) {
            controller.hide(WindowInsetsCompat.Type.statusBars())
        } else {
            controller.show(WindowInsetsCompat.Type.statusBars())
        }
    }

    // FIXED (defect 3): behavior was never managed. Hidden bars get
    // swipe-transient behavior (user can peek them); shown bars get the
    // default restored, so a later show is a full, persistent bar instead
    // of a degraded transient one.
    private fun applyBehavior(controller: WindowInsetsControllerCompat, hidden: Boolean) {
        controller.systemBarsBehavior = if (hidden) {
            WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        } else {
            WindowInsetsControllerCompat.BEHAVIOR_DEFAULT
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
        // Behavior applies to the window state, not the animation; set it
        // up front so the end state is correct even if the animation is
        // cancelled midway.
        applyBehavior(WindowInsetsControllerCompat(window, window.decorView), hidden)

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
                // FIXED (defect 1): result must be answered on every exit
                // path exactly once, or the Dart await hangs forever.
                private var resultSent = false

                // FIXED (defect 2): finish() may only be called once, and
                // never after the controller is cancelled.
                private var controllerDone = false

                private fun sendResultOnce() {
                    if (!resultSent) {
                        resultSent = true
                        result.success(null)
                    }
                }

                private fun finishOnce(controller: WindowInsetsAnimationController) {
                    if (!controllerDone) {
                        controllerDone = true
                        // finish() throws if the controller was already
                        // cancelled by the system between our check and the
                        // call; that race is unwinnable, so absorb it.
                        try {
                            controller.finish(!hidden)
                        } catch (_: IllegalStateException) {
                            // System already settled the animation; the
                            // window behavior set above still stands.
                        }
                    }
                }

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
                                Insets.of(0, v.toInt(), 0, 0),
                                1f,
                                if (shown == 0f) 1f else v / shown,
                            )
                        }
                        addListener(object : AnimatorListenerAdapter() {
                            override fun onAnimationEnd(animation: Animator) {
                                finishOnce(controller)
                                runningAnimator = null
                            }

                            override fun onAnimationCancel(animation: Animator) {
                                finishOnce(controller)
                                runningAnimator = null
                            }
                        })
                    }
                    runningAnimator = animator
                    animator.start()
                    sendResultOnce()
                }

                override fun onFinished(controller: WindowInsetsAnimationController) {
                    // Covers system-side completion; harmless double-call
                    // protection via the flags.
                    sendResultOnce()
                }

                override fun onCancelled(controller: WindowInsetsAnimationController?) {
                    // FIXED (defect 1): this path previously never answered
                    // the channel — the single worst bug in the file.
                    controllerDone = true // system killed it; finish() is now illegal
                    runningAnimator?.cancel()
                    runningAnimator = null
                    // The animation died, but the requested end state must
                    // still land: apply it immediately.
                    activity?.let { setStatusBarImmediate(it, hidden) }
                    sendResultOnce()
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
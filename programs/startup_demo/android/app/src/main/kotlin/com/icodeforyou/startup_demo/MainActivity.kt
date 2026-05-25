package com.icodeforyou.startup_demo

import android.graphics.Color
import android.os.Bundle
import android.view.WindowInsets
import android.view.WindowInsetsController
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        window.statusBarColor = Color.BLACK
        window.navigationBarColor = Color.BLACK

        /// Fades out the status bar after launch
        /// Not a good user experience, but interesting

        // if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
        //     window.insetsController?.hide(WindowInsets.Type.statusBars())
        //     window.insetsController?.systemBarsBehavior =
        //         WindowInsetsController.BEHAVIOR_DEFAULT
        // }
    }
}
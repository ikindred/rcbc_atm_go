package com.example.rcbc_atm_go

import com.example.rcbc_atm_go.topwise.TopwiseChannel
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private lateinit var topwiseChannel: TopwiseChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        topwiseChannel = TopwiseChannel(applicationContext)
        topwiseChannel.register(flutterEngine)
    }
}

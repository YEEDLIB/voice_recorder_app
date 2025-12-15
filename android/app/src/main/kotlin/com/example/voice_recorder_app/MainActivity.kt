package com.example.voice_recorder_app

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.voice_recorder_app.services.RecordingForegroundService

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.voice_recorder.app/service"
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startForegroundService" -> {
                        val filePath = call.argument<String>("filePath")
                        val duration = call.argument<Int>("duration") ?: 0
                        
                        val intent = Intent(this, RecordingForegroundService::class.java).apply {
                            action = RecordingForegroundService.ACTION_START
                            putExtra(RecordingForegroundService.EXTRA_FILE_PATH, filePath)
                            putExtra(RecordingForegroundService.EXTRA_DURATION, duration)
                        }
                        
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        
                        result.success(true)
                    }
                    
                    "stopForegroundService" -> {
                        val intent = Intent(this, RecordingForegroundService::class.java).apply {
                            action = RecordingForegroundService.ACTION_STOP
                        }
                        stopService(intent)
                        result.success(true)
                    }
                    
                    "checkBatteryOptimization" -> {
                        result.success(isIgnoringBatteryOptimizations())
                    }
                    
                    "requestIgnoreBatteryOptimizations" -> {
                        requestIgnoreBatteryOptimizations()
                        result.success(true)
                    }
                    
                    "isIgnoringBatteryOptimizations" -> {
                        result.success(isIgnoringBatteryOptimizations())
                    }
                    
                    else -> result.notImplemented()
                }
            }
    }
    
    private fun isIgnoringBatteryOptimizations(): Boolean {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            powerManager.isIgnoringBatteryOptimizations(packageName)
        } else {
            true
        }
    }
    
    private fun requestIgnoreBatteryOptimizations() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                data = Uri.parse("package:$packageName")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(intent)
        }
    }
}
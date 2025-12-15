package com.example.voice_recorder_app.workers

import android.content.Context
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.Data
import androidx.work.WorkerParameters
import kotlinx.coroutines.delay
import java.util.Date

class ScheduledRecordingWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {
    
    override suspend fun doWork(): Result {
        return try {
            // Get recording parameters
            val filePath = inputData.getString("file_path")
            val duration = inputData.getLong("duration", 0)
            
            Log.d("ScheduledRecording", "Starting scheduled recording: $filePath")
            
            // Start recording via foreground service
            val intent = Intent(applicationContext, RecordingForegroundService::class.java).apply {
                action = RecordingForegroundService.ACTION_START
                putExtra(RecordingForegroundService.EXTRA_FILE_PATH, filePath)
                putExtra(RecordingForegroundService.EXTRA_DURATION, duration)
            }
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                applicationContext.startForegroundService(intent)
            } else {
                applicationContext.startService(intent)
            }
            
            // Wait for recording duration
            if (duration > 0) {
                delay(duration)
                
                // Stop recording
                val stopIntent = Intent(applicationContext, RecordingForegroundService::class.java).apply {
                    action = RecordingForegroundService.ACTION_STOP
                }
                applicationContext.stopService(stopIntent)
            }
            
            Result.success()
        } catch (e: Exception) {
            Log.e("ScheduledRecording", "Error in scheduled recording", e)
            Result.failure()
        }
    }
}
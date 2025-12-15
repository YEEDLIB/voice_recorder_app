package com.example.voice_recorder_app.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import com.example.voice_recorder_app.workers.ScheduledRecordingWorker
import java.util.concurrent.TimeUnit

class BootCompletedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED || 
            intent.action == "android.intent.action.QUICKBOOT_POWERON") {
            
            // Reschedule all pending recordings
            rescheduleRecordings(context)
        }
    }

    private fun rescheduleRecordings(context: Context) {
        // In production, load scheduled recordings from storage
        // and reschedule them using WorkManager
        
        val workManager = WorkManager.getInstance(context)
        
        // Example: Check and reschedule next recording
        val recordingRequest = OneTimeWorkRequest.Builder(ScheduledRecordingWorker::class.java)
            .setInitialDelay(1, TimeUnit.MINUTES) // Adjust based on your logic
            .build()
            
        workManager.enqueueUniqueWork(
            "reschedule_recordings",
            ExistingWorkPolicy.REPLACE,
            recordingRequest
        )
    }
}
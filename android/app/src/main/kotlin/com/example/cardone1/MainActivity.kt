package com.example.cardone1

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import kotlin.random.Random
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import android.Manifest
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat



class MainActivity: FlutterActivity() {

    var eventData : String?=""
    private val REQUEST_LOCATION_PERMISSION = 1



    private val broadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if(intent.action == "my-event"){
                eventData = intent.getStringExtra("event-data")
                Log.d("MyService","New file added is : $eventData")
                // Handle the event data here
            }
        }
    }

    override fun onStart() {
        super.onStart()
        LocalBroadcastManager.getInstance(this)
                .registerReceiver(broadcastReceiver, IntentFilter("my-event"))
    }

    override fun onStop() {
        super.onStop()
        // LocalBroadcastManager.getInstance(this).unregisterReceiver(broadcastReceiver)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "example.com/channel").setMethodCallHandler {
            call, result ->
            if(call.method == "autoUpload") {
                val intent = Intent(this, MyService::class.java)
                startService(intent)
                print(" observer service started")
                if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                    // You already have the permission, do your work
                    val intent2 = Intent(this, MyService::class.java)
                    startService(intent2)
                    // val intent3 = Intent(this, Service2::class.java)
                    // startForegroundService(intent3)
                } else {
                    // You don't have the permission, request it
                    ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), REQUEST_LOCATION_PERMISSION)

                }


                result.success(eventData)


            }
            else {
                result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        when (requestCode) {
            REQUEST_LOCATION_PERMISSION -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    // Permission was granted
                    // Do your work here
                    val intent2 = Intent(this, MyService::class.java)
                    startService(intent2)
                    // val intent3 = Intent(this, Service2::class.java)
                    // startForegroundService(intent3)

                } else {
                    // Permission was denied
                    // Show an error message or do something else
                }
            }
        }
    }

}

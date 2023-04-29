package com.example.cardone1;



import android.app.Service;
import android.content.Intent;
import android.os.Environment;
import android.os.IBinder;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import java.io.File;
import java.nio.file.FileSystems;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardWatchEventKinds;
import java.nio.file.WatchEvent;
import java.nio.file.WatchKey;
import java.nio.file.WatchService;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import android.location.Location;
import android.location.LocationManager;
import android.content.Context;
import android.location.LocationListener;
import android.os.Bundle;
import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Looper;










public class MyService extends Service {
    int count=0;
    double latitude;
    double longitude;



    ScheduledExecutorService myschedule_executor;
    private LocalBroadcastManager broadcaster;

//    private Location getLocation() {
//        LocationManager locationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
//        LocationListener locationListener = new LocationListener() {
//            @Override
//            public void onLocationChanged(Location location) {
//                locationManager.removeUpdates(this); // Stop listening to location updates
//                // Do something with the location data
//            }
//
//            @Override
//            public void onStatusChanged(String provider, int status, Bundle extras) {
//            }
//
//            @Override
//            public void onProviderEnabled(String provider) {
//            }
//
//            @Override
//            public void onProviderDisabled(String provider) {
//            }
//        };
//
//        Location location = null;
//
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//            if (checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED
//                    && checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
//                // Permissions not granted, handle it
//                return null;
//            }
//        }
//        Looper.prepare();
//        // Request location updates
//        locationManager.requestSingleUpdate(LocationManager.GPS_PROVIDER, locationListener, null);
//        location = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
//        Looper.loop();
//        return location;
//    }



    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Intent broadcastIntent = new Intent("my-event");
        broadcaster = LocalBroadcastManager.getInstance(this);




        myschedule_executor = Executors.newScheduledThreadPool(1);
        myschedule_executor.scheduleAtFixedRate(new Runnable() {
            @Override
            public void run() {
                //MainActivity.textView.setText("Current Time: " + new Date());
                System.out.println("hello"+(count++));
                System.out.println(Environment.getExternalStorageDirectory());

                try{

                    Path folder = Paths.get(Environment.getExternalStorageDirectory()+"/DCIM/Camera"); // replace with your folder path
                    WatchService watchService = FileSystems.getDefault().newWatchService();

                    folder.register(watchService, StandardWatchEventKinds.ENTRY_CREATE);

                    while (true) {
                        WatchKey key = watchService.take();

                        for (WatchEvent<?> event : key.pollEvents()) {
                            WatchEvent.Kind<?> kind = event.kind();

                            if (kind == StandardWatchEventKinds.OVERFLOW) {
                                continue;
                            }

                            WatchEvent<Path> ev = (WatchEvent<Path>) event;
                            Path filename = ev.context();

                            File file = new File(folder.toString() + "\\" + filename.toString());
                            String name = file.getName();
                            String s=file.getAbsolutePath().replace("\\","/");
                            broadcastIntent.putExtra("event-data", s);

                            broadcaster.sendBroadcast(broadcastIntent);
                            System.out.println("New file added: " + name);






                        }

                        boolean valid = key.reset();
                        if (!valid) {
                            break;
                        }
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }



            }
        }, 1, 1, TimeUnit.SECONDS);

        return super.onStartCommand(intent, flags, startId);
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        myschedule_executor.shutdown();
    }
}


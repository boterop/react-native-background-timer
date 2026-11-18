package io.boterop.timer;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;

public class BackgroundTimerService extends Service {
    private static final String CHANNEL_ID = "BackgroundTimerChannel";
    private static final int NOTIFICATION_ID = 1;
    private Handler handler;
    private Runnable tick;
    private int delay;

    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannel();
        handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        delay = intent == null ? 0 : Math.max(0, intent.getIntExtra("delayMs", 0));
        if (tick != null) handler.removeCallbacks(tick);
        startForeground(NOTIFICATION_ID, createNotification());
        tick = new Runnable() {
            @Override public void run() {
                BackgroundTimerModule.emitEvent("backgroundTimer", null);
                if (delay > 0) handler.postDelayed(this, delay);
            }
        };
        handler.postDelayed(tick, delay);
        return START_STICKY;
    }

    @Override public IBinder onBind(Intent intent) { return null; }

    @Override public void onDestroy() {
        if (tick != null) handler.removeCallbacks(tick);
        stopForeground(true);
        super.onDestroy();
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID,
                    "Background Timer", NotificationManager.IMPORTANCE_LOW);
            getSystemService(NotificationManager.class).createNotificationChannel(channel);
        }
    }

    private Notification createNotification() {
        Notification.Builder builder = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
                ? new Notification.Builder(this, CHANNEL_ID) : new Notification.Builder(this);
        return builder.setContentTitle("Background Timer Running")
                .setContentText("Timer is active in background")
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setOngoing(true)
                .build();
    }
}

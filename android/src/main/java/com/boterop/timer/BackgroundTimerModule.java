package io.boterop.timer;

import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import androidx.core.content.ContextCompat;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class BackgroundTimerModule extends ReactContextBaseJavaModule {
    private static ReactApplicationContext reactApplicationContext;
    private final Handler handler = new Handler(Looper.getMainLooper());
    private final Map<Integer, Runnable> timeouts = new ConcurrentHashMap<>();
    public BackgroundTimerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        reactApplicationContext = reactContext;
    }

    @Override
    public String getName() {
        return "RNBackgroundTimer";
    }

    static void emitEvent(String eventName, Object data) {
        ReactApplicationContext context = reactApplicationContext;
        if (context != null && context.hasActiveCatalystInstance()) {
            context.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, data);
        }
    }

    @ReactMethod
    public void start(final int delay) {
        Intent intent = new Intent(reactApplicationContext, BackgroundTimerService.class);
        intent.putExtra("delayMs", Math.max(0, delay));
        ContextCompat.startForegroundService(reactApplicationContext, intent);
    }

    @ReactMethod
    public void stop() {
        reactApplicationContext.stopService(new Intent(reactApplicationContext, BackgroundTimerService.class));
    }

    @ReactMethod
    public void setTimeout(final int id, final double timeout) {
        clearTimeout(id);
        Runnable timeoutRunnable = new Runnable() {
            @Override
            public void run() {
                timeouts.remove(id);
                if (reactApplicationContext.hasActiveCatalystInstance()) {
                    reactApplicationContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                            .emit("backgroundTimer.timeout", id);
                }
            }
        };
        timeouts.put(id, timeoutRunnable);
        handler.postDelayed(timeoutRunnable, Math.max(0L, (long) timeout));
    }

    @ReactMethod
    public void clearTimeout(final int id) {
        Runnable timeoutRunnable = timeouts.remove(id);
        if (timeoutRunnable != null) {
            handler.removeCallbacks(timeoutRunnable);
        }
    }

    @ReactMethod
    public void addListener(String eventName) {}

    @ReactMethod
    public void removeListeners(Integer count) {}
}

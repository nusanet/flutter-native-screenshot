package net.bengkelrobot.flutter_native_screenshot;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.os.Build;
import android.util.Log;
import android.view.PixelCopy;
import android.view.View;
import android.view.Window;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileOutputStream;
import java.util.Date;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterNativeScreenshotPlugin
 */
public class FlutterNativeScreenshotPlugin
        implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private static final String TAG = "FNSPlugin";

    private Context context;
    private MethodChannel channel;
    private Activity activity;
    private Object renderer;


    // Default constructor for old registrar
    public FlutterNativeScreenshotPlugin() {
    } // FlutterNativeScreenshotPlugin()

    // Condensed logic to initialize the plugin
    private void initPlugin(Context context, BinaryMessenger messenger, Activity activity,
                            Object renderer) {
        this.context = context;
        this.activity = activity;
        this.renderer = renderer;

        this.channel = new MethodChannel(messenger, "flutter_native_screenshot");
        this.channel.setMethodCallHandler(this);
    } // initPlugin()

    // New v2 listener methods
    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        this.channel.setMethodCallHandler(null);
        this.channel = null;
        this.context = null;
    } // onDetachedFromEngine()

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        Log.println(Log.INFO, TAG, "Using *NEW* registrar method!");

        initPlugin(
                flutterPluginBinding.getApplicationContext(),
                flutterPluginBinding.getBinaryMessenger(),
                null,
                flutterPluginBinding.getFlutterEngine().getRenderer()
        ); // initPlugin()
    } // onAttachedToEngine()

    // Old v1 register method removed



    // Activity condensed methods
    private void attachActivity(ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
    } // attachActivity()

    private void detachActivity() {
        this.activity = null;
    } // attachActivity()


    // Activity listener methods
    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        attachActivity(binding);
    } // onAttachedToActivity()

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        detachActivity();
    } // onDetachedFromActivityForConfigChanges()

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        attachActivity(binding);
    } // onReattachedToActivityForConfigChanges()

    @Override
    public void onDetachedFromActivity() {
        detachActivity();
    } // onDetachedFromActivity()


    // MethodCall, manage stuff coming from Dart
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (!call.method.equals("takeScreenshot")) {
            Log.println(Log.ERROR, TAG, "Method not implemented!");
            result.notImplemented();
            return;
        }
        takeScreenshot(result);
    } // onMethodCall()

    // Own functions, plugin specific functionality
    private String getScreenshotName() {
        java.text.SimpleDateFormat sf = new java.text.SimpleDateFormat("yyyyMMddHHmmss");
        String sDate = sf.format(new Date());

        return "flutter_native_screenshot-" + sDate + ".png";
    } // getScreenshotName()

    private String getScreenshotPath() {
        String pathTemporary = context.getCacheDir().getPath();
        Log.println(Log.INFO, TAG, "path temporary: " + pathTemporary);

        String dirPath = pathTemporary + "/" + getScreenshotName();

        Log.println(Log.INFO, TAG, "Built ScreeshotPath: " + dirPath);

        return dirPath;
    } // getScreenshotPath()

    private String writeBitmap(Bitmap bitmap) {
        try {
            String path = getScreenshotPath();
            File imageFile = new File(path);
            FileOutputStream oStream = new FileOutputStream(imageFile);

            bitmap.compress(Bitmap.CompressFormat.PNG, 100, oStream);
            oStream.flush();
            oStream.close();

            return path;
        } catch (Exception ex) {
            Log.println(Log.ERROR, TAG, "Error writing bitmap: " + ex.getMessage());
        }

        return null;
    } // writeBitmap()

    private void takeScreenshot(@NonNull Result result) {
        Log.println(Log.INFO, TAG, "Taking screenshot");

        if (this.activity == null) {
            Log.println(Log.ERROR, TAG, "Activity is null, cannot take screenshot.");
            result.error("NO_ACTIVITY", "Activity is not available.", null);
            return;
        }

        try {
            View view = this.activity.getWindow().getDecorView().getRootView();

            Bitmap bitmap = Bitmap.createBitmap(view.getWidth(), view.getHeight(), Bitmap.Config.ARGB_8888);

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                // Use PixelCopy for API 26+
                Window window = this.activity.getWindow();
                final Result finalResult = result;
                android.os.HandlerThread handlerThread = new android.os.HandlerThread("PixelCopyThread");
                handlerThread.start();

                final Bitmap finalBitmap = bitmap;
                PixelCopy.request(window, finalBitmap, new PixelCopy.OnPixelCopyFinishedListener() {
                    @Override
                    public void onPixelCopyFinished(int copyResult) {
                        if (copyResult == PixelCopy.SUCCESS) {
                            String path = writeBitmap(finalBitmap);
                            if (path != null && !path.isEmpty()) {
                                finalResult.success(path);
                            } else {
                                finalResult.error("WRITE_ERROR", "Failed to write bitmap to file.", null);
                            }
                        } else {
                            finalResult.error("PIXEL_COPY_ERROR", "PixelCopy failed with result: " + copyResult, null);
                        }
                        handlerThread.quitSafely();
                    }
                }, new android.os.Handler(handlerThread.getLooper()));
            } else {
                // Fallback for older APIs: use drawing cache
                view.setDrawingCacheEnabled(true);
                view.buildDrawingCache();
                Bitmap cacheBitmap = view.getDrawingCache();

                if (cacheBitmap == null) {
                    Log.println(Log.ERROR, TAG, "The bitmap cannot be created.");
                    result.error("BITMAP_ERROR", "Failed to capture bitmap from view.", null);
                    return;
                }

                Bitmap copy = cacheBitmap.copy(Bitmap.Config.ARGB_8888, false);
                view.setDrawingCacheEnabled(false);

                String path = writeBitmap(copy);
                if (path == null || path.isEmpty()) {
                    Log.println(Log.ERROR, TAG, "The bitmap cannot be written, invalid path.");
                    result.error("WRITE_ERROR", "Failed to write bitmap to file.", null);
                    return;
                }

                result.success(path);
            }
        } catch (Exception ex) {
            Log.println(Log.ERROR, TAG, "Error taking screenshot: " + ex.getMessage());
            result.error("SCREENSHOT_ERROR", "Error taking screenshot: " + ex.getMessage(), null);
        }
    } // takeScreenshot()
}

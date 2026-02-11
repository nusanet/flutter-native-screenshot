package net.bengkelrobot.flutter_native_screenshot;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.util.Log;
import android.view.View;
import android.view.Window;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

import java.io.File;
import java.io.FileOutputStream;
import java.util.Date;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.renderer.FlutterRenderer;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
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

    private boolean ssError = false;
    private String ssPath;

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
        takeScreenshotOld();
        result.success(ssPath);

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
            Log.println(Log.INFO, TAG, "Error writing bitmap: " + ex.getMessage());
        }

        return null;
    } // writeBitmap()

    private void reloadMedia() {
        try {
            Intent intent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
            File file = new File(this.ssPath);
            Uri uri = Uri.fromFile(file);

            intent.setData(uri);
            this.activity.sendBroadcast(intent);
        } catch (Exception ex) {
            Log.println(Log.INFO, TAG, "Error reloading media lib: " + ex.getMessage());
        }
    } // reloadMedia()

    private void takeScreenshotOld() {
        Log.println(Log.INFO, TAG, "Trying to take screenshot [old way]");

        try {
            View view = this.activity.getWindow().getDecorView().getRootView();

            view.setDrawingCacheEnabled(true);

            Bitmap bitmap = null;
            if (this.renderer.getClass() == FlutterRenderer.class) {
                bitmap = ((FlutterRenderer) this.renderer).getBitmap();
            }

            if (bitmap == null) {
                this.ssError = true;
                this.ssPath = null;

                Log.println(Log.INFO, TAG, "The bitmap cannot be created :(");

                return;
            } // if

            view.setDrawingCacheEnabled(false);

            String path = writeBitmap(bitmap);
            if (path == null || path.isEmpty()) {
                this.ssError = true;
                this.ssPath = null;

                Log.println(Log.INFO, TAG, "The bitmap cannot be written, invalid path.");

                return;
            } // if

            this.ssError = false;
            this.ssPath = path;

            reloadMedia();
        } catch (Exception ex) {
            Log.println(Log.INFO, TAG, "Error taking screenshot: " + ex.getMessage());
        }
    } // takeScreenshot()
}

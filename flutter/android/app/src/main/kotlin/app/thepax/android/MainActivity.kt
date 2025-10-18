package app.thepax.android

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.webkit.WebView

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Enable WebView debugging (can be disabled in production if needed)
        WebView.setWebContentsDebuggingEnabled(true)
    }
}
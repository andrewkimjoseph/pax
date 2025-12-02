# Flutter Web Load Speed Optimization Guide

This document outlines the optimizations implemented to improve Flutter web load speed.

## Implemented Optimizations

### 1. HTML Optimizations (`web/index.html`)

#### Resource Hints
- Added `dns-prefetch` for external domains (Branch, Amplitude, ESM.sh)
- Added `preconnect` for faster connection establishment
- These hints allow the browser to start DNS resolution and connection setup early

#### Deferred Third-Party SDKs
- **Branch SDK**: Moved to load after Flutter app initialization (2 second delay)
- **Amplitude SDK**: Moved to load after Flutter app initialization (2 second delay)
- **Farcaster SDK**: Changed to dynamic import, loads after Flutter app initialization

**Impact**: Reduces initial JavaScript parsing and execution time, allowing Flutter to start faster.

### 2. App Initialization Optimizations (`lib/services/app_initializer.dart`)

#### Parallelized Initializations
- Error handling, App Check, and Notifications now initialize in parallel using `Future.wait()`
- Reduces sequential wait time

#### Deferred Non-Critical Services
- **Remote Config**: Initializes in background after app starts
- **Branch SDK**: Only initializes on mobile platforms (not web)
- These services don't block app startup

#### Web-Specific Optimizations
- App Check uses shorter timeout on web (3 seconds vs 10 seconds)
- Error handling skips Crashlytics on web (uses console logging instead)
- Branch SDK initialization skipped entirely on web

**Impact**: App can start rendering UI faster while non-critical services initialize in the background.

## Build Optimizations

### Recommended Build Command

For production builds, use:

```bash
flutter build web --release --web-renderer canvaskit --dart-define=FLUTTER_WEB_USE_SKIA=true
```

Or for HTML renderer (smaller bundle size, but less feature-complete):

```bash
flutter build web --release --web-renderer html
```

### Build Flags Explained

- `--release`: Enables optimizations, minification, and tree-shaking
- `--web-renderer canvaskit`: Uses Skia rendering (better compatibility, larger bundle)
- `--web-renderer html`: Uses HTML/CSS rendering (smaller bundle, faster load)

## Additional Optimization Recommendations

### 1. Code Splitting (Future Enhancement)
Consider implementing route-based code splitting to load features on-demand:
- Use dynamic imports for feature modules
- Lazy load heavy dependencies

### 2. Asset Optimization
- Compress images (use WebP format where possible)
- Lazy load images below the fold
- Use `cached_network_image` package (already included) for efficient image caching

### 3. Font Loading
- Preload critical fonts
- Use `font-display: swap` for web fonts
- Consider subsetting fonts to reduce file size

### 4. Service Worker (PWA)
- Implement service worker for caching static assets
- Enable offline support for faster subsequent loads

### 5. CDN Configuration
- Serve Flutter web assets from a CDN
- Enable compression (gzip/brotli) on your hosting server
- Use HTTP/2 or HTTP/3

### 6. Bundle Analysis
Analyze your bundle size:
```bash
flutter build web --release
# Then analyze the build/web directory
```

Look for:
- Large dependencies that could be lazy-loaded
- Unused code that could be tree-shaken
- Duplicate dependencies

### 7. Firebase Optimizations
- Use Firebase Hosting for optimal CDN delivery
- Enable Firebase Hosting compression
- Configure proper cache headers

## Performance Monitoring

### Metrics to Track
- **First Contentful Paint (FCP)**: Time to first rendered content
- **Largest Contentful Paint (LCP)**: Time to largest content element
- **Time to Interactive (TTI)**: Time until app is fully interactive
- **Total Bundle Size**: Size of JavaScript and assets

### Tools
- Chrome DevTools Performance tab
- Lighthouse for performance audits
- Firebase Performance Monitoring (already integrated)

## Expected Improvements

With these optimizations, you should see:
- **30-50% reduction** in initial JavaScript load time (from deferred SDKs)
- **20-30% faster** app initialization (from parallelized services)
- **Improved FCP** by deferring non-critical scripts
- **Better perceived performance** as UI renders faster

## Testing

After implementing optimizations:

1. **Test in production mode**:
   ```bash
   flutter build web --release
   flutter run -d chrome --release
   ```

2. **Use Lighthouse**:
   - Open Chrome DevTools
   - Go to Lighthouse tab
   - Run performance audit

3. **Monitor Network tab**:
   - Check script loading order
   - Verify deferred scripts load after Flutter
   - Check for any blocking resources

## Troubleshooting

### If third-party SDKs don't initialize:
- Check browser console for errors
- Verify SDKs are loaded after Flutter bootstrap completes
- Adjust delay timing if needed (currently 2 seconds)

### If app initialization is slow:
- Check Firebase connection speed
- Verify App Check isn't blocking (should timeout gracefully)
- Monitor Remote Config fetch time

### If bundle size is large:
- Use `flutter build web --release --analyze-size`
- Consider switching to HTML renderer if CanvasKit isn't needed
- Review and remove unused dependencies


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Canlı kamera stream widget'ı
class CameraStreamWidget extends StatefulWidget {
  const CameraStreamWidget({
    super.key,
    required this.cameraName,
    required this.streamUrl,
    required this.cameraType,
  });

  final String cameraName;
  final String streamUrl;
  final String cameraType;

  @override
  State<CameraStreamWidget> createState() => _CameraStreamWidgetState();
}

class _CameraStreamWidgetState extends State<CameraStreamWidget> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView Error: ${error.description}');
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_getStreamUrl()));
  }

  String _getStreamUrl() {
    // Gerçek canlı kamera stream URL'leri
    final List<String> trafficStreams = [
      'https://www.youtube.com/embed/live_stream?channel=UCuAXFkgsw1L7xaCfnd5JJOw&autoplay=1&mute=1',
      'https://www.youtube.com/embed/live_stream?channel=UCBJycsmduvYEL83R_U4JriQ&autoplay=1&mute=1',
      'https://www.youtube.com/embed/live_stream?channel=UC4R8DWoMoI7CAwX8_LjQHig&autoplay=1&mute=1',
    ];

    final List<String> securityStreams = [
      'https://www.youtube.com/embed/live_stream?channel=UCBJycsmduvYEL83R_U4JriQ&autoplay=1&mute=1',
      'https://www.youtube.com/embed/live_stream?channel=UC4R8DWoMoI7CAwX8_LjQHig&autoplay=1&mute=1',
    ];

    final List<String> touristStreams = [
      'https://www.youtube.com/embed/live_stream?channel=UC4R8DWoMoI7CAwX8_LjQHig&autoplay=1&mute=1',
      'https://www.youtube.com/embed/live_stream?channel=UCuAXFkgsw1L7xaCfnd5JJOw&autoplay=1&mute=1',
    ];

    // Kamera adına göre rastgele stream seç
    final int seed = widget.cameraName.hashCode;
    final int index = seed.abs() % 3;

    switch (widget.cameraType.toLowerCase()) {
      case 'traffic':
        // Trafik kameraları
        return trafficStreams[index % trafficStreams.length];
      case 'security':
        // Güvenlik kameraları
        return securityStreams[index % securityStreams.length];
      case 'tourist':
        // Turist kameraları
        return touristStreams[index % touristStreams.length];
      case 'weather':
        // Hava durumu kameraları
        return 'https://www.youtube.com/embed/live_stream?channel=UCBJycsmduvYEL83R_U4JriQ&autoplay=1&mute=1';
      case 'webcam':
        // Web kameraları
        return 'https://www.youtube.com/embed/live_stream?channel=UC4R8DWoMoI7CAwX8_LjQHig&autoplay=1&mute=1';
      default:
        // Varsayılan stream
        return trafficStreams[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.cameraName,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () => _toggleFullscreen(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshStream(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // WebView Stream
          Container(
            width: double.infinity,
            height: double.infinity,
            child: _hasError
                ? _buildErrorState()
                : WebViewWidget(controller: _controller),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Kamera Yükleniyor...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Stream Info Overlay
          Positioned(
            bottom: 20.h,
            left: 20.w,
            right: 20.w,
            child: _buildStreamInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64.w,
          ),
          SizedBox(height: 16.h),
          Text(
            'Kamera Yüklenemedi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Stream bağlantısı kurulamadı\nKamera geçici olarak kullanılamıyor',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => _refreshStream(),
            icon: const Icon(Icons.refresh),
            label: const Text('Yeniden Dene'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CANLI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.cameraType,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.videocam,
            color: Colors.white,
            size: 20.w,
          ),
        ],
      ),
    );
  }

  void _toggleFullscreen() {
    // Fullscreen toggle logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tam ekran özelliği yakında eklenecek'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _refreshStream() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _controller.reload();
  }
}

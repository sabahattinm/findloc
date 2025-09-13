import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../bloc/live_camera_bloc.dart';
import '../../../../core/domain/entities/live_camera_entity.dart';

/// Widget for displaying camera stream
class CameraStreamWidget extends StatefulWidget {
  const CameraStreamWidget({
    super.key,
    required this.camera,
  });

  final LiveCameraEntity camera;

  @override
  State<CameraStreamWidget> createState() => _CameraStreamWidgetState();
}

class _CameraStreamWidgetState extends State<CameraStreamWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      // Get stream URL from BLoC
      context.read<LiveCameraBloc>().add(
        LoadCameraStream(cameraId: widget.camera.id),
      );
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  void _setupVideoController(String streamUrl) {
    _controller = VideoPlayerController.networkUrl(Uri.parse(streamUrl));
    _controller!.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller!.play();
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LiveCameraBloc, LiveCameraState>(
      listener: (context, state) {
        if (state is LiveCameraStreamLoaded) {
          _setupVideoController(state.streamUrl);
        } else if (state is LiveCameraError) {
          setState(() {
            _hasError = true;
          });
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildVideoPlayer(context),
            ),
            _buildControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              widget.camera.cameraType.icon,
              style: TextStyle(fontSize: 16.w),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.camera.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.camera.cameraType.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context) {
    if (_hasError) {
      return _buildErrorState(context);
    }

    if (!_isInitialized || _controller == null) {
      return _buildLoadingState(context);
    }

    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
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
            'Kamera yükleniyor...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.w,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Kamera yüklenemedi',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Lütfen daha sonra tekrar deneyin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _hasError = false;
                _isInitialized = false;
              });
              _initializeVideoPlayer();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                if (_controller!.value.isPlaying) {
                  _controller!.pause();
                } else {
                  _controller!.play();
                }
              });
            },
            icon: Icon(
              _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              size: 32.w,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _controller!.setVolume(_controller!.value.volume > 0 ? 0.0 : 1.0);
              });
            },
            icon: Icon(
              _controller!.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
              size: 24.w,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _controller!.setPlaybackSpeed(
                  _controller!.value.playbackSpeed == 1.0 ? 2.0 : 1.0,
                );
              });
            },
            icon: Text(
              '${_controller!.value.playbackSpeed}x',
              style: TextStyle(
                fontSize: 16.w,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

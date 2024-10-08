import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraViewer extends StatefulWidget {
  final CameraDescription camera;

  const CameraViewer({super.key, required this.camera});
  @override
  State<CameraViewer> createState() => _CameraViewerState();
}

class _CameraViewerState extends State<CameraViewer> with WidgetsBindingObserver {
  CameraController? controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    try {
      await controller!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return Container();
    }
    return Column(
      children: [
        IconButton(
          onPressed: () {
            final isPaused = controller?.value.isPreviewPaused ?? false;

            if (isPaused) {
              controller?.resumePreview();
            } else {
              controller?.pausePreview();
            }
          },
          icon: const Icon(Icons.camera),
        ),
        AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: CameraPreview(controller!),
        ),
      ],
    );
  }
}

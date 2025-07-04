// lib/video_record_page.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'cloudinary_service.dart'; // Ajusta la ruta si la tienes en otro folder

class VideoRecorderPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const VideoRecorderPage({super.key, required this.cameras});
  @override
  _VideoRecorderPageState createState() => _VideoRecorderPageState();
}

class _VideoRecorderPageState extends State<VideoRecorderPage> {
  CameraController? _controller;
  bool _cameraInitialized = false;
  bool _isRecording = false;

  XFile? _recordedFile;
  VideoPlayerController? _videoController;

  bool _isUploading = false;

  @override
  void dispose() {
    _controller?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  /// 1) Inicializa cámara
  Future<void> _initializeCamera() async {
    if (!kIsWeb) {
      await Permission.camera.request();
      await Permission.microphone.request();
    }
    final cam = CameraController(
      widget.cameras.first,
      ResolutionPreset.high,
      enableAudio: true,
    );
    await cam.initialize();
    if (!mounted) return;
    setState(() {
      _controller = cam;
      _cameraInitialized = true;
    });
  }

  /// 2) Empieza a grabar
  Future<void> _startRecording() async {
    if (_controller != null && !_isRecording) {
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  /// 3) Detiene grabación y prepara preview
  Future<void> _stopRecording() async {
    if (_controller != null && _isRecording) {
      final file = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _recordedFile = file;
      });

      // Crea VideoPlayerController para previsualizar
      _videoController = kIsWeb
        ? VideoPlayerController.network(file.path)
        : VideoPlayerController.file(File(file.path));

      await _videoController!.initialize();
      _videoController!
        ..setLooping(true)
        ..play(); // Auto-play
      setState(() {});
    }
  }

  /// 4) Volver a grabar: limpia preview y reinicia cámara
  Future<void> _reRecord() async {
    await _videoController?.pause();
    await _videoController?.dispose();
    await _controller?.dispose();

    setState(() {
      _recordedFile = null;
      _videoController = null;
      _controller = null;
      _cameraInitialized = false;
    });

    await _initializeCamera();
  }

  /// 5) Subir a Cloudinary
  Future<void> _upload() async {
    if (_recordedFile == null) return;
    setState(() => _isUploading = true);
    final url = await CloudinaryService.uploadVideo(_recordedFile!);
    setState(() => _isUploading = false);

    if (url != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vídeo subido: $url')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al subir el vídeo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grabadora de Video')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: _recordedFile == null
                ? _buildCameraPreview()
                : _buildVideoPreview(),
            ),

            if (_isUploading) ...[
              const SizedBox(height: 8),
              const CircularProgressIndicator(),
              const SizedBox(height: 4),
              const Text('Subiendo vídeo a la nube…'),
            ],

            const SizedBox(height: 12),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_cameraInitialized || _controller == null) {
      return Container(
        color: Colors.black12,
        alignment: Alignment.center,
        child: const Text('Cámara apagada'),
      );
    }
    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: CameraPreview(_controller!),
    );
  }

  Widget _buildVideoPreview() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: VideoPlayer(_videoController!),
    );
  }

  Widget _buildButtons() {
    // Modo cámara
    if (_recordedFile == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: _cameraInitialized ? null : _initializeCamera,
            child: const Text('Abrir Cámara'),
          ),
          ElevatedButton(
            onPressed: (_cameraInitialized && !_isRecording)
                ? _startRecording
                : null,
            child: const Text('Grabar'),
          ),
          ElevatedButton(
            onPressed: (_isRecording) ? _stopRecording : null,
            child: const Text('Detener'),
          ),
        ],
      );
    }

    // Modo preview
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _isUploading ? null : _reRecord,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          child: const Text('Volver a grabar'),
        ),
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _upload,
          icon: const Icon(Icons.send),
          label: const Text('Enviar'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
        ),
      ],
    );
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:camera/camera.dart';

class CloudinaryService {
  static const _cloudName = 'dwpwvucet';
  static const _uploadPreset = 'flutter_cloud';

  /// Recibe un XFile de camera o file_picker
  static Future<String?> uploadVideo(XFile videoFile) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/video/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = _uploadPreset;

    if (kIsWeb) {
      // Web: leemos bytes del XFile
      final Uint8List data = await videoFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          data,
          filename: videoFile.name,
        ),
      );
    } else {
      // Móvil/desktop: usamos File.fromPath
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          videoFile.path,
          filename: path.basename(videoFile.path),
        ),
      );
    }

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (streamed.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['secure_url'];
      } else {
        debugPrint('Cloudinary error ${streamed.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception uploading to Cloudinary: $e');
      return null;
    }
  }
}

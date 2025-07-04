import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'video_record_page.dart';

class InstructionPage extends StatelessWidget {
  final List<CameraDescription> cameras;

  const InstructionPage({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: const Text('Instrucciones'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Instrucciones para la grabación',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Por favor, grabe un video corto donde se muestre tomando su medicamento para la tuberculosis. Asegúrese de que su rostro y el medicamento sean claramente visibles durante la grabación.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Icon(Icons.medication, size: 100, color: Colors.deepPurple),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.videocam),
              label: const Text('Siguiente: Grabar video'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoRecorderPage(cameras: cameras),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

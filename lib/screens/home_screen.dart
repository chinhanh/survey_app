import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'survey_screen.dart';
import '../services/database_service.dart';
import '../models/survey.dart';

class HomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  const HomeScreen({required this.cameras, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kh?o sát Ban công')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<List<Survey>>(
              future: DatabaseService().getSurveys(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                return Text('S? d? án: ${snapshot.data!.length}');
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SurveyScreen(cameras: cameras),
                ),
              ),
              child: const Text('T?o báo cáo kh?o sát m?i'),
            ),
            ElevatedButton(
              onPressed: () {}, // Thêm màn hình l?ch s? sau
              child: const Text('L?ch s? d? án'),
            ),
          ],
        ),
      ),
    );
  }
}


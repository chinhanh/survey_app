import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_painter/image_painter.dart';
import 'package:uuid/uuid.dart';
import '../models/survey.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class SurveyScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const SurveyScreen({required this.cameras, super.key});

  @override
  _SurveyScreenState createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _area, _sunDirection, _plantType, _need, _budget;
  XFile? _image;
  final _imagePainterController = ImagePainterController();

  Future<void> _takePicture() async {
    final controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    await controller.initialize();
    final image = await controller.takePicture();
    final annotatedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImagePainter.file(
          File(image.path),
          controller: _imagePainterController,
        ),
      ),
    );
    if (annotatedImage != null) {
      setState(() => _image = XFile(annotatedImage.path));
    }
  }

  Future<void> _saveAndExport() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final survey = Survey(
        id: const Uuid().v4(),
        area: _area!,
        sunDirection: _sunDirection!,
        plantType: _plantType ?? '',
        need: _need!,
        budget: _budget!,
        imagePath: _image?.path,
      );

      await DatabaseService().saveSurvey(survey);
      final pdfFile = await PdfService.generatePdf(survey);

      final email = Email(
        body: 'Ðính kèm báo cáo kh?o sát',
        subject: 'Báo cáo kh?o sát ban công',
        recipients: ['your_email@example.com'], // Thay b?ng email c?a b?n
        attachmentPaths: [pdfFile.path],
        isHTML: false,
      );
      try {
        await FlutterEmailSender.send(email);
      } catch (e) {
        print('Error sending email: $e');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Báo cáo dã du?c luu và g?i')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kh?o sát m?i')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ElevatedButton(
              onPressed: _takePicture,
              child: const Text('Ch?p ?nh hi?n tr?ng'),
            ),
            if (_image != null) Image.file(File(_image!.path), height: 200),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Di?n tích (m²)'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Vui lòng nh?p di?n tích' : null,
              onSaved: (value) => _area = value,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Hu?ng n?ng'),
              items: ['B?c', 'Nam', 'Ðông', 'Tây']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              validator: (value) => value == null ? 'Vui lòng ch?n hu?ng n?ng' : null,
              onChanged: (value) => _sunDirection = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Lo?i cây hi?n có (tùy ch?n)'),
              onSaved: (value) => _plantType = value,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Nhu c?u'),
              items: ['Ti?u c?nh', 'Ch? ng?i', 'Tr?ng rau', 'K?t h?p']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              validator: (value) => value == null ? 'Vui lòng ch?n nhu c?u' : null,
              onChanged: (value) => _need = value,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Ngân sách'),
              items: ['Du?i 10tr', '10-30tr', 'Trên 30tr']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              validator: (value) => value == null ? 'Vui lòng ch?n ngân sách' : null,
              onChanged: (value) => _budget = value,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAndExport,
              child: const Text('Xu?t báo cáo'),
            ),
          ],
        ),
      ),
    );
  }
}


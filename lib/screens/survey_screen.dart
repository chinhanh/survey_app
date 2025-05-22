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
        body: '��nh k�m b�o c�o kh?o s�t',
        subject: 'B�o c�o kh?o s�t ban c�ng',
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
        const SnackBar(content: Text('B�o c�o d� du?c luu v� g?i')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kh?o s�t m?i')),
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
              decoration: const InputDecoration(labelText: 'Di?n t�ch (m�)'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Vui l�ng nh?p di?n t�ch' : null,
              onSaved: (value) => _area = value,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Hu?ng n?ng'),
              items: ['B?c', 'Nam', '��ng', 'T�y']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              validator: (value) => value == null ? 'Vui l�ng ch?n hu?ng n?ng' : null,
              onChanged: (value) => _sunDirection = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Lo?i c�y hi?n c� (t�y ch?n)'),
              onSaved: (value) => _plantType = value,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Nhu c?u'),
              items: ['Ti?u c?nh', 'Ch? ng?i', 'Tr?ng rau', 'K?t h?p']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              validator: (value) => value == null ? 'Vui l�ng ch?n nhu c?u' : null,
              onChanged: (value) => _need = value,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Ng�n s�ch'),
              items: ['Du?i 10tr', '10-30tr', 'Tr�n 30tr']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              validator: (value) => value == null ? 'Vui l�ng ch?n ng�n s�ch' : null,
              onChanged: (value) => _budget = value,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAndExport,
              child: const Text('Xu?t b�o c�o'),
            ),
          ],
        ),
      ),
    );
  }
}


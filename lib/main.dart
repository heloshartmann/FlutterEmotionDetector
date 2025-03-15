import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

void main() {
  runApp(EmotionDetectionApp());
}

class EmotionDetectionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FaceDetectionScreen(),
    );
  }
}

class FaceDetectionScreen extends StatefulWidget {
  @override
  _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  File? _image;
  final picker = ImagePicker();
  final FaceDetector faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true, 
    ),
  );
  String _faceMessage = "Nenhum rosto detectado";

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _faceMessage = "Processando...";
      });
      await _detectFaces();
    }
  }

  Future<void> _detectFaces() async {
    if (_image == null) return;
    final inputImage = InputImage.fromFile(_image!);
    final List<Face> faces = await faceDetector.processImage(inputImage);

    setState(() {
      if (faces.isNotEmpty) {
        _faceMessage = "${faces.length} rosto(s) detectado(s):\n";
        for (var face in faces) {
          String emotion = _detectEmotion(face);
          _faceMessage += "$emotion\n";
        }
      } else {
        _faceMessage = "Nenhum rosto detectado";
      }
    });
  }

  String _detectEmotion(Face face) {
    if (face.smilingProbability != null) {
      double smileProb = face.smilingProbability!;
      if (smileProb > 0.7) {
        return "Feliz";
      } else if (smileProb < 0.3) {
        return "Triste";
      }
    }
    return "Neutro";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detector de Emoções')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _image != null
              ? Image.file(_image!, height: 300)
              : Icon(Icons.image, size: 100, color: Colors.grey),
          SizedBox(height: 20),
          Text(_faceMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _getImage(ImageSource.camera),
                child: Text('Tirar Foto'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => _getImage(ImageSource.gallery),
                child: Text('Escolher da Galeria'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
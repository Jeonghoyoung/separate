import 'package:flutter/material.dart';
import 'package:your_app/widgets/file_picker_widget.dart';
import 'package:your_app/services/file_uploader.dart';
import 'package:your_app/services/audio_player_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocal Remover',
      home: Scaffold(
        appBar: AppBar(title: Text('Vocal Remover')),
        body: FileUploadPage(),
      ),
    );
  }
}

class FileUploadPage extends StatefulWidget {
  @override
  _FileUploadPageState createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  final FileUploader _fileUploader = FileUploader('http://127.0.0.1:5000/upload');
  final AudioPlayerService _audioPlayerService = AudioPlayerService();
  String? _resultUrl;

  void _onFilePicked(String filePath) async {
    var resultUrl = await _fileUploader.uploadFile(File(filePath));
    setState(() {
      _resultUrl = resultUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilePickerWidget(onFilePicked: _onFilePicked),
        if (_resultUrl != null)
          ElevatedButton(
            onPressed: () => _audioPlayerService.playAudio(_resultUrl!),
            child: const Text('재생'),
          ),
      ],
    );
  }
}

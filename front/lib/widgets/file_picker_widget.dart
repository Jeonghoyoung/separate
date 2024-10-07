import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FilePickerWidget extends StatefulWidget {
  final Function(String) onFilePicked;

  const FilePickerWidget({Key? key, required this.onFilePicked}) : super(key: key);

  @override
  _FilePickerWidgetState createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  String? _filePath;

  void _pickFile() async {
    String? pickedFile = await FilePicker.platform.pickFiles()?.then((result) {
      return result?.files.single.path;
    });

    if (pickedFile != null) {
      setState(() {
        _filePath = pickedFile;
      });
      widget.onFilePicked(pickedFile);  // 선택된 파일 경로 전달
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _pickFile,
      child: const Text('파일 선택'),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:html' as html;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Separator',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _youtubeUrlController = TextEditingController();
  bool _isLoading = false;
  String _status = '';
  String? _currentJobId;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _dio.options.baseUrl = 'http://localhost:5000';
  }

  Future<void> _uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'mp4'],
      );

      if (result != null) {
        setState(() {
          _isLoading = true;
          _status = 'Uploading file...';
          _currentJobId = null;
        });

        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;

        FormData formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(file.path, filename: fileName),
        });

        Response response = await _dio.post('/upload', data: formData);

        setState(() {
          _status = 'File processed successfully!';
          _currentJobId = response.data['job_id'];
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
        _currentJobId = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _processYouTubeUrl() async {
    if (_youtubeUrlController.text.isEmpty) {
      setState(() {
        _status = 'Please enter a YouTube URL';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _status = 'Processing YouTube URL...';
        _currentJobId = null;
      });

      Response response = await _dio.post('/youtube', data: {
        'url': _youtubeUrlController.text,
      });

      setState(() {
        _status = 'YouTube audio processed successfully!';
        _currentJobId = response.data['job_id'];
      });
    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
        _currentJobId = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _downloadResults() {
    if (_currentJobId != null) {
      html.window.open('http://localhost:5000/download/${_currentJobId}', '_blank');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 헤더 카드
                    Card(
                      elevation: 0,
                      color: Colors.white.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Icon(Icons.music_note, size: 48, color: Colors.blue),
                            const SizedBox(height: 16),
                            const Text(
                              'Audio Separator',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Separate vocals from music',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 메인 컨텐츠 카드
                    Card(
                      elevation: 0,
                      color: Colors.white.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 파일 업로드 섹션
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Upload Audio File',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: _isLoading ? null : _uploadFile,
                                    icon: const Icon(Icons.upload_file),
                                    label: const Text('Choose File'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),
                            const Text(
                              'OR',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // YouTube URL 섹션
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'YouTube URL',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _youtubeUrlController,
                                    decoration: InputDecoration(
                                      hintText: 'Paste YouTube URL here',
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(Icons.link),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: _isLoading ? null : _processYouTubeUrl,
                                    icon: const Icon(Icons.youtube_searched_for),
                                    label: const Text('Process URL'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 상태 및 다운로드 카드
                    if (_isLoading || _status.isNotEmpty || _currentJobId != null)
                      Card(
                        elevation: 0,
                        color: Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              if (_isLoading)
                                const Column(
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                  ],
                                ),
                              if (_status.isNotEmpty)
                                Text(
                                  _status,
                                  style: const TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              if (_currentJobId != null) ...[
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _downloadResults,
                                  icon: const Icon(Icons.download),
                                  label: const Text('Download Separated Files'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
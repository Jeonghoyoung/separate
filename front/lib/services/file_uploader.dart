import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FileUploader {
  final String uploadUrl;

  FileUploader(this.uploadUrl);

  Future<String?> uploadFile(File file) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final result = String.fromCharCodes(responseData);
        return jsonDecode(result)['result_url']; // 결과 URL 반환
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }
}

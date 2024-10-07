# Flutter와 Python(Flask API) 통합 테스트

Flutter 프론트엔드와 Python 백엔드(Flask API)의 통합 테스트를 진행하는 방법에 대한 설명입니다.

## 1. Flask API 테스트

### 1.1 로컬 테스트

1. **Flask 서버 실행**:
   ```bash
   export FLASK_APP=app.py
   export FLASK_ENV=development  # 개발 모드 활성화
   flask run
   ```

2. 테스트 방법:

- Postman이나 cURL을 사용하여 API를 테스트합니다.

```bash
curl -X POST http://127.0.0.1:5000/upload -F 'file=@path/to/your/audiofile.mp3'
```

3. Unit 테스트
- unittest 모듈을 사용하여 API의 각 기능을 테스트합니다.

```python
import unittest
from app import app

class FlaskTestCase(unittest.TestCase):
    def test_file_upload(self):
        tester = app.test_client(self)
        response = tester.post(
            '/upload', 
            content_type='multipart/form-data',
            data=dict(file=(open('test_audio.mp3', 'rb'), 'test_audio.mp3'))
        )
        self.assertEqual(response.status_code, 200)

if __name__ == '__main__':
    unittest.main()

```

### 1.2 Falsk 테스트 완료후
	- Flask 서버가 정상적으로 작동하는지 확인한 후, Flutter와의 통합을 시작합니다.

## 2. Flutter 앱 테스트

### 2.1 단위테스트

1. 의존성 추가: pubspec.yaml에 필요한 패키지를 추가합니다.
```bash
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.0.0  # Mocking을 위한 라이브러리

```

2. HTTP 요청 Mocking 및 테스트
```bash
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  group('File Upload Tests', () {
    test('Upload file to Flask API', () async {
      final client = MockClient();
      when(client.post(
        Uri.parse('http://127.0.0.1:5000/upload'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{"result_url": "http://example.com/result.mp3"}', 200));

      var result = await uploadFile(client);  // uploadFile은 실제 업로드 함수
      expect(result, 'http://example.com/result.mp3');
    });
  });
}
```
### 2.2 위젯 테스트
- UI 구성 요소를 테스트합니다.
```bash
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/main.dart';

void main() {
   testWidgets('File Picker Test', (WidgetTester tester) async {
     await tester.pumpWidget(MyApp());

     final pickFileButton = find.text('파일 선택');
     expect(pickFileButton, findsOneWidget);

     await tester.tap(pickFileButton);
     await tester.pump();
   });
}

```

### 2.3 통합 테스트
1. Flask 서버 실행: 로컬에서 Flask 서버를 실행합니다.
2. Flutter 통합 테스트 실행: Flutter 앱에서 실제 API 호출이 성공적으로 이루어지는지 테스트합니다.

```bash
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Flutter + Flask Integration Test', () async {
    var result = await uploadFile(http.Client());
    expect(result, isNotNull);
    expect(result, contains('http://'));
  });
}

```

## 3. 테스트 전략 요약
1. Flask API 테스트:

	- Postman이나 cURL을 사용하여 API 기능을 테스트합니다.
	- unittest로 Flask API의 단위 테스트 작성합니다.

2. Flutter 단위 테스트:

	- http 모듈을 Mocking하여 네트워크 통신을 모사합니다.
	- 파일 선택, 업로드 등의 각 UI 기능을 단위 테스트합니다.

3. Flutter + Flask 통합 테스트:

	- 로컬에서 Flask 서버를 실행한 후, 실제 네트워크 통신을 통해 Flutter와 Flask 간의 상호작용 테스트합니다.

## 이러한 방식으로 단계별로 테스트를 진행하면 Flutter 프론트엔드와 Flask 백엔드 간의 통합된 동작을 검증할 수 있습니다.

import 'package:flutter/material.dart';

class ResultDisplayWidget extends StatelessWidget {
  final String resultUrl;

  const ResultDisplayWidget({Key? key, required this.resultUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('처리된 오디오 URL: $resultUrl'),
        // 추가적인 결과 표시 UI 구현 가능
      ],
    );
  }
}

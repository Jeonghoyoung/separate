# app.py
from flask import Flask, request, send_file, jsonify
from flask_cors import CORS
import os
from werkzeug.utils import secure_filename
import demucs.separate
from pytubefix import YouTube
import numpy as np
import soundfile as sf
import librosa
import zipfile
from io import BytesIO

app = Flask(__name__)
CORS(app)

UPLOAD_FOLDER = 'uploads'
SEPARATED_FOLDER = 'separated'
ALLOWED_EXTENSIONS = {'mp3', 'wav', 'mp4'}

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)
if not os.path.exists(SEPARATED_FOLDER):
    os.makedirs(SEPARATED_FOLDER)


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def create_zip_file(files):
    memory_file = BytesIO()
    with zipfile.ZipFile(memory_file, 'w', zipfile.ZIP_DEFLATED) as zf:
        for file_type, file_path in files.items():
            if os.path.exists(file_path):
                # ZIP 파일 내 경로를 간단하게 만들기
                arcname = f"{file_type}.mp3"
                zf.write(file_path, arcname)
    memory_file.seek(0)
    return memory_file


@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        filepath = os.path.join(UPLOAD_FOLDER, filename)
        file.save(filepath)

        # 음원 분리 처리
        separated_paths = separate_audio(filepath)
        job_id = os.path.splitext(filename)[0]

        return jsonify({
            'message': 'File uploaded and separated successfully',
            'job_id': job_id
        })

    return jsonify({'error': 'Invalid file type'}), 400


@app.route('/youtube', methods=['POST'])
def process_youtube():
    data = request.get_json()
    youtube_url = data.get('url')

    if not youtube_url:
        return jsonify({'error': 'No YouTube URL provided'}), 400

    try:
        # YouTube 동영상에서 오디오 추출
        yt = YouTube(youtube_url)
        audio_stream = yt.streams.filter(only_audio=True).first()

        # 임시 파일로 저장
        filename = f"{yt.title}.mp4"
        safe_filename = secure_filename(filename)
        download_path = os.path.join(UPLOAD_FOLDER, safe_filename)
        audio_stream.download(filename=download_path)

        # 음원 분리 처리
        separated_paths = separate_audio(download_path)
        job_id = os.path.splitext(safe_filename)[0]

        return jsonify({
            'message': 'YouTube audio processed successfully',
            'job_id': job_id
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500


def separate_audio(input_path):
    try:
        # Demucs를 사용하여 음원 분리
        output_path = os.path.join(SEPARATED_FOLDER, os.path.splitext(os.path.basename(input_path))[0])
        demucs.separate.main(["--mp3", "--two-stems=vocals", "-n", "htdemucs", input_path, "-o", output_path])

        # 분리된 파일 경로 반환
        separated_files = {
            'vocals': os.path.join(output_path, 'htdemucs', os.path.basename(input_path), 'vocals.mp3'),
            'no_vocals': os.path.join(output_path, 'htdemucs', os.path.basename(input_path), 'no_vocals.mp3')
        }

        return separated_files

    except Exception as e:
        raise Exception(f"Error during audio separation: {str(e)}")


@app.route('/download/<job_id>')
def download_results(job_id):
    try:
        # 분리된 파일들의 실제 경로 찾기
        search_path = os.path.join(SEPARATED_FOLDER, job_id, 'htdemucs')
        # 실제 파일 찾기
        files_dir = None
        for root, dirs, files in os.walk(search_path):
            if 'vocals.mp3' in files and 'no_vocals.mp3' in files:
                files_dir = root
                break

        if not files_dir:
            raise Exception("Separated files not found")

        files = {
            'vocals': os.path.join(files_dir, 'vocals.mp3'),
            'no_vocals': os.path.join(files_dir, 'no_vocals.mp3')
        }

        # 파일 존재 확인
        for file_path in files.values():
            if not os.path.exists(file_path):
                raise Exception(f"File not found: {file_path}")

        # ZIP 파일 생성
        memory_file = BytesIO()
        with zipfile.ZipFile(memory_file, 'w', zipfile.ZIP_DEFLATED) as zf:
            for file_type, file_path in files.items():
                if os.path.exists(file_path):
                    # 파일 크기 확인
                    file_size = os.path.getsize(file_path)
                    print(f"Adding {file_type}.mp3 ({file_size} bytes) from {file_path}")

                    # 파일을 ZIP에 추가
                    zf.write(file_path, f"{file_type}.mp3")

        # 파일 포인터를 시작으로 되돌리기
        memory_file.seek(0)

        # ZIP 파일 크기 확인
        zip_size = memory_file.getbuffer().nbytes
        print(f"Created ZIP file size: {zip_size} bytes")

        return send_file(
            memory_file,
            mimetype='application/zip',
            as_attachment=True,
            download_name=f'{job_id}_separated.zip'
        )

    except Exception as e:
        print(f"Error during download: {str(e)}")
        return jsonify({'error': str(e)}), 404


if __name__ == '__main__':
    app.run(debug=True)
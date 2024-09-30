import os
import subprocess
import streamlit as st
import zipfile
from pytubefix import YouTube
from pytubefix.cli import on_progress
from pathlib import Path


# pip install --upgrade pytubefix


def download_video(url):
    # YouTube 객체 생성
    yt = YouTube(url, on_progress_callback=on_progress)
    # 최고 해상도 스트림 다운로드
    ys = yt.streams.get_highest_resolution()
    ys.download(filename='test.mp4')
    return 'test.mp4'


def mp4_to_wav(mp4_file, wav_file):
    # MP4 -> WAV 변환
    command = ['ffmpeg', '-i', mp4_file, wav_file]
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0:
        st.error(f"FFmpeg error: {result.stderr}")


def separate_audio(input_path, save):
    command = ['demucs',  input_path, '--out', save]
    result = subprocess.run(command, capture_output=True, text=True)
    st.spinner('##### separating #####')
    if result.returncode != 0:
        st.error(f"Demucs error: {result.stderr}")


# Streamlit 시작
st.title("Audio Separator")

# 파일 업로드 또는 URL 입력
uploaded_file = st.file_uploader("동영상 파일 업로드", type=["mp4"])
youtube_url = st.text_input("YouTube Video URL")

# 동영상 확인 버튼
if st.button("동영상 확인"):
    if youtube_url:
        video_file = download_video(youtube_url)
    elif uploaded_file:
        video_file = uploaded_file
    else:
        st.error("동영상을 업로드하거나 URL을 입력하세요.")
        video_file = None

    if video_file:
        st.video(video_file)

# 음원 분리 버튼
if st.button('음원 분리'):
    if youtube_url:
        video_file = download_video(youtube_url)
    elif uploaded_file:
        video_file = uploaded_file.name
        with open(video_file, 'wb') as f:
            f.write(uploaded_file.read())
    else:
        st.error("동영상을 업로드하거나 URL을 입력하세요.")
        video_file = None
    if video_file:
        # MP4 -> WAV 변환
        wav_file = 'test.wav'
        mp4_to_wav(video_file, wav_file)

        # 진행상황 프로그레스 바 추가
        progress_bar = st.progress(0)

        # 음원 분리 실행
        separate_audio(wav_file, './')

        # 분리된 음원 파일 압축
        zip_filename = "separated_audio.zip"
        with zipfile.ZipFile(zip_filename, 'w') as zipf:
            for root, _, files in os.walk("./htdemucs/test"):
                for file in files:
                    if file.endswith('wav'):
                        zipf.write(os.path.join(root, file), arcname=file)

        # 다운로드 버튼 제공
        with open(zip_filename, "rb") as f:
            st.download_button("분리된 음원 다운로드", data=f, file_name=zip_filename)

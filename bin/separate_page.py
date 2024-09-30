import os
import subprocess
import streamlit as st
import zipfile
from pytubefix import YouTube
from pytubefix.cli import on_progress

# pip install --upgrade pytubefix


def download_video(url):
    # 객체 생성
    yt = YouTube(url, on_progress_callback=on_progress)

    # 다운로드 실행
    ys = yt.streams.get_highest_resolution()
    ys.download()

def mp4_to_wav(mp4_file, wav_file):
    # MP4 -> WAV 변환
    command = ['ffmpeg', '-i', mp4_file, wav_file]
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0:
        st.error(f"FFmpeg error: {result.stderr}")


def separate_audio(input_path, save):
    command = ['demucs',  input_path, '--out', save]
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0:
        st.error(f"Demucs error: {result.stderr}")


st.title("Audio Separator")
youtube_url = st.text_input("YouTube Video URL")

download_youtube_file = st.button("Download")
separate_but = st.button('음원 분리')
wav_but = st.button('음원파일 다운로드')
if youtube_url:
    # try:

    if download_youtube_file:
        yt = YouTube(youtube_url, on_progress_callback=on_progress)
        # 다운로드 실행
        ys = yt.streams.get_highest_resolution()
        ys.download(filename='test.mp4')
        st.success("Video downloaded successfully!")

    if separate_but:
        mp4_to_wav(f'test.mp4', f'test.wav')
        # separated_dir = os.path.join(".", f'{ys.title}.mp4')
        separate_audio(f'test.wav', './')
        zip_filename = f"test.zip"

        with zipfile.ZipFile(zip_filename, 'w') as zipf:
            for root, _, files in os.walk(f"./htdemucs/test"):
                for file in files:
                    if os.path.basename(file).endswith('wav'):
                        zipf.write(os.path.join(root, file), arcname=file)

        with open(zip_filename, "rb") as f:
            st.download_button("Download Separated Audio", data=f, file_name=zip_filename)
    # except:
    #     st.error('다시 시도하세요')
    #     # subprocess.run(["pip", "install", "--upgrade", "pytubefix"], check=True)
    #     print()







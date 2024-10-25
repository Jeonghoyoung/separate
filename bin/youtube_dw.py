from pytubefix import YouTube
from pytubefix.cli import on_progress
from pydub import AudioSegment

# pip install --upgrade pytubefix
def download_video(url):
    # 객체 생성
    yt = YouTube(url, on_progress_callback=on_progress)

    # 다운로드 실행
    # ys = yt.streams.get_highest_resolution()
    ys = yt.streams.filter(only_audio=True).first()

    ys.download()


if __name__ == '__main__':
    url = "https://www.youtube.com/watch?v=SEKB7DTsFz8"
    download_video(url)

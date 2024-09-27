import subprocess

# MP4 -> WAV 변환
def mp4_to_wav(mp4_file, wav_file):
    command = ['ffmpeg', '-i', mp4_file, wav_file]
    subprocess.run(command)

# 변환 실행
mp4_to_wav('./Queen - Bohemian Rhapsody(가사번역).mp4', 'queen.wav')
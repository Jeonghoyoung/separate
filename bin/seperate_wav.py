import subprocess

def separate_audio(input_path, save):
    command = ['demucs',  input_path, '--out', save]
    subprocess.run(command)


if __name__ == '__main__':
    separate_audio('./queen.wav', './')
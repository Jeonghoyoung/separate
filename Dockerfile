FROM python:3.10.13-slim

### SET ENV
RUN apt-get update && apt-get install -y tzdata ffmpeg
ENV TZ=Asia/Seoul
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV VIRTUAL_HOST separate.test.com
ENV VIRTUAL_PORT 8501
ENV LETSENCRYPT_HOST separate.test.com
ARG DEBIAN_FRONTEND=noninteractive

#RUN mkdir /app
WORKDIR /app

RUN apt-get update && \
    apt-get install -y build-essential curl software-properties-common git && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app
RUN pip3 install -U pip setuptools wheel
RUN pip3 install -r requirements.txt
EXPOSE 8501

COPY app.py /app
#COPY streamlit_v3.py /app
#COPY task_util.py /app
#COPY database.py /app

HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health

ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
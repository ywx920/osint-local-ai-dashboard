FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -i https://mirrors.aliyun.com/pypi/simple/ -r requirements.txt
COPY crawler.py .
CMD ["python", "crawler.py"]

FROM debian:stable-slim
EXPOSE 9000

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        pkg-config \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        git \
        build-essential \
        default-libmysqlclient-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV VENV_PATH=/opt/venv
RUN python3 -m venv $VENV_PATH

ENV PATH="$VENV_PATH/bin:$PATH"

WORKDIR /app

RUN git clone --recursive --depth 1 https://github.com/izzatbey/MISP-Taxii-Server .

RUN git pull

RUN pip install --no-cache-dir --upgrade pip

RUN pip install --no-cache-dir -r REQUIREMENTS.txt

COPY ./config/config.yaml /app/config/config.yaml

ENV OPENTAXII_CONFIG=/app/config/config.yaml
ENV PYTHONPATH=.

RUN opentaxii-sync-data config/data-configuration.yaml

RUN python3 setup.py install

# Add the run script
COPY ./docker-run.sh ./run.sh
RUN chmod +x ./docker-run.sh

# Default command
CMD ["/bin/sh", "/docker-run.sh"]
# CMD ["opentaxii-run-dev"]
# BBB-Translation-Bot

BBB-Translation-Bot is a tool designed to enhance communication in BigBlueButton (BBB) meetings by providing real-time transcription and translation services. Utilizing OpenAI's cutting-edge [Whisper](https://github.com/openai/whisper) technology, the bot joins a BBB meeting's audio channel and transcribes/translates spoken words into text, seamlessly integrating the transcripts into BBB's closed captions feature.

# Getting Started

Follow these simple steps to quickly set up the BBB-Translation-Bot.

## Prerequisites

### Hardware
Thsi setup was testet with a Nvidia RTX 2070 and RTX 3070 GPU. The GPU is used for the transcription and translation of the audio stream.

### Docker with GPU support
Ensure Docker with GPU support is installed on your system:

```bash
sudo apt-get update && sudo apt-get upgrade -y
curl -sSL https://get.docker.com | sh
sudo apt-get install nvidia-container-runtime
which nvidia-container-runtime-hook
sudo systemctl restart docker
docker run -it --rm --gpus all ubuntu nvidia-smi # Test GPU support
```

### Installation
1. Clone the repository:
```bash
git clone https://github.com/ITLab-CC/bbb-translation-bot
cd bbb-translation-bot
```

2. Configure the bot:
Copy the example configuration file and modify it according to your preferences:
```bash
cp .env_example .env
```

3. Launch the bot:
With Docker, you can easily start the bot:
```bash	
docker-compose up -d
```

# Development Setup
To set up the environment for development purposes, follow the instructions below.
## Server Setup
1. Install Nvidia drivers for Ubuntu:
Refer to the official [Nvidia documentation](https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html#ubuntu-lts):
```bash
sudo apt-get install linux-headers-$(uname -r)
distribution=$(. /etc/os-release;echo $ID$VERSION_ID | sed -e 's/\.//g')
wget https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/cuda-keyring_1.0-1_all.deb
sudo dpkg -i cuda-keyring_1.0-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda-drivers
sudo reboot now
```

2. Install Python dependencies:
```bash
cd server
sudo apt update
sudo apt install python3-pip python3-dev ffmpeg -y
pip3 install -r requirements-server.txt --no-cache-dir
```

3. Run the server:
```bash
python3 server.py
```

## Client Setup
1. Install Golang:
Follow the official [Golang installation guide](https://go.dev/doc/install):
```bash
cd client
sudo apt update
wget https://go.dev/dl/go1.21.3.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.3.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
```

2. Install Go dependencies:
```bash
go get .
```

3. Run the client:
```bash
go run .
```

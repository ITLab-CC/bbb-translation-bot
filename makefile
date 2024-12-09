.PHONY: install install-dev build run run-dev run-dev-docker stop stop-dev stop-dev-docker

# Define flags
IS_WSL := $(shell grep -qi microsoft /proc/version && echo yes || echo no)

all: install

install:
ifeq ($(IS_WSL), yes)
	@./setup.sh --wsl --check || sudo ./setup.sh --wsl
else
	@./setup.sh --simple-setup --check || sudo ./setup.sh --simple-setup
endif
	@echo "All dependencies are installed"

install-dev:
ifeq ($(IS_WSL), yes)
	@./setup.sh --wsl --check || sudo ./setup.sh --wsl
else
	@./setup.sh --ubuntu22 --check || sudo ./setup.sh --ubuntu22
endif
	@echo "All dependencies are installed"

build:
	@if [ ! "$$(ls -A transcription-service)" ]; then \
		git submodule update --init --recursive; \
	fi
	@if [ ! "$$(ls -A changeset-grpc)" ]; then \
		git submodule update --init --recursive; \
		cd changeset-grpc/etherpad-lite; \
		src/bin/installDeps.sh; \
		cd ..; \
		npm install; \
	fi

	@cd bot && go mod tidy
	
	@cd transcription-service && if [ ! -d ".venv" ]; then \
		python3 -m venv .venv && \
		bash -c "source .venv/bin/activate && pip install -r requirements.txt && deactivate"; \
	fi

generate-env-files:
	@if [ ! -f .env -o ! -f .env-dev -o ! -f .env-dev-docker ]; then \
		./generate-env.sh; \
	fi


run: generate-env-files install stop
	@docker compose up -d

run-dev: generate-env-files install-dev stop build
	@screen -dmS bot bash -c "cd bot && set -a && source ../.env-dev && set +a && go run . 2>&1 | tee ../logs/bot.log"
	@screen -dmS changeset-grpc bash -c "cd changeset-grpc && set -a && source ../.env-dev && set +a && npm run start 2>&1 | tee ../logs/changeset-grpc.log"
	@screen -dmS transcription-service bash -c "cd transcription-service && source .venv/bin/activate && set -a && source ../.env-dev && set +a && python main.py 2>&1 | tee ../logs/transcription-service.log"
	@screen -dmS translation-service bash -c "docker compose -f docker-compose-dev.yml up translation-service 2>&1 | tee logs/translation-service.log"
	@screen -dmS prometheus bash -c "docker compose -f docker-compose-dev.yml up prometheus  2>&1 | tee logs/prometheus.log"

run-dev-docker: generate-env-files install-dev stop
	@docker compose -f docker-compose-dev.yml up -d --build

stop: stop-dev stop-dev-docker
	@docker compose down

stop-dev:
	@for service in bot changeset-grpc transcription-service; do \
		screen -ls | grep ".$$service" | awk '{print $$1}' | while read session; do \
			echo "Stopping screen session $$session..."; \
			screen -S $$session -X quit; \
		done; \
	done
	@echo "Stopping translation-service..."; docker compose -f docker-compose-dev.yml down translation-service
	@echo "Stopping prometheus..."; docker compose -f docker-compose-dev.yml down prometheus

stop-dev-docker:
	@docker compose -f docker-compose-dev.yml down

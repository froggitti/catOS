#!/usr/bin/env bash

CURRENT_BUILDER="vic-standalone-builder-7"

set -e

if [[ "$(uname -a)" == *"Darwin"* ]]; then
	echo "Installing required Go stuff..."
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest
	export PATH="$PATH:$HOME/go/bin"
	./project/victor/scripts/victor_build_release.sh "$@"
	echo
	echo -e "\033[1;32mComplete.\033[0m"
	echo
else
	mkdir -p build/cache
	mkdir -p build/gocache
	mkdir -p build/usercache
	if [[ -z $(docker images -q $CURRENT_BUILDER) ]]; then
		docker build \
		--build-arg DIR_PATH="$(pwd)" \
		--build-arg USER_NAME=$USER \
		--build-arg UID=$(id -u $USER) \
		--build-arg GID=$(id -u $USER) \
		-t $CURRENT_BUILDER \
		build/
	else
		echo "Reusing $CURRENT_BUILDER"
	fi
	docker run --rm -it \
		-v $(pwd)/anki-deps:/home/$USER/.anki \
		-v $(pwd):$(pwd) \
		-v $(pwd)/build/cache:/home/$USER/.ccache \
		-v $(pwd)/build/gocache:/home/$USER/go \
		-v $(pwd)/build/usercache:/home/$USER/.cache \
		$CURRENT_BUILDER bash -c \
		"cd $(pwd) && \
		./project/victor/scripts/victor_build_release.sh $@ && \
		echo && \
		echo -e \"\e[1;32mComplete.\e[0m\" && \
		echo"
fi

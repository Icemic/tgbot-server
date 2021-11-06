FROM debian:bullseye

RUN apt update && apt install -y build-essential git libssl-dev zlib1g-dev cmake gperf
RUN mkdir data && cd data && git clone --recursive https://github.com/tdlib/telegram-bot-api.git && cd telegram-bot-api && mkdir build
RUN cd /data/telegram-bot-api/build && cmake -DCMAKE_BUILD_TYPE=Release -DTD_ENABLE_LTO=ON ..
RUN cd /data/telegram-bot-api/build && cmake --build . --target install -j2

FROM debian:bullseye

ENV API_ID ''
ENV API_HASH ''
ENV VERBOSITY_LEVEL 0

RUN apt update && apt install -y libssl-dev zlib1g && mkdir /data

WORKDIR /data
COPY --from=0 /usr/local/bin/telegram-bot-api /usr/local/bin

EXPOSE 8081 8082

CMD telegram-bot-api --local --api-id=$API_ID --api-hash=$API_HASH --dir=/data --http-port=8081 --http-stat-port=8082 --log=/data/logs/logs.log --verbosity=$VERBOSITY_LEVEL

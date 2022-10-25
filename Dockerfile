FROM ubuntu AS git
WORKDIR /sui
RUN apt update && apt install git -y
RUN git clone https://github.com/MystenLabs/sui.git /sui
RUN git checkout devnet

# build image
FROM rust:1.64 AS build

WORKDIR /sui
COPY --from=git /sui .
RUN apt update && apt install -y --no-install-recommends \
    tzdata \
    ca-certificates \
    build-essential \
    pkg-config \
    clang \
    cmake
RUN cargo build -j6 --release

# runtime image
FROM debian:bullseye-slim AS app

WORKDIR /sui
COPY --from=build /sui/target/release/{sui,sui-node,sui-faucet} .

CMD ["sui-node"]

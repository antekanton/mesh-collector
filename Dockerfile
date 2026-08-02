# STEP 1
FROM perl:5.40-slim AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    protobuf-compiler \
    libprotobuf-dev \
    cmake \
    autoconf automake libtool curl make g++ unzip pkg-config wget \
    libmariadb-dev libmariadb-dev-compat \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v21.12/protobuf-cpp-3.21.12.tar.gz \
    && tar -xzf protobuf-cpp-3.21.12.tar.gz \
    && cd protobuf-3.21.12 \
    && ./configure --prefix=/usr \
    && make -j$(nproc) \
    && make install \
    && ldconfig

RUN cpanm --notest \
    IO::Socket::INET \
    IO::Socket::Multicast \
    Crypt::OpenSSL::AES \
    MIME::Base64 \
    DBI \
    DBD::MariaDB \
    Google::ProtocolBuffers::Dynamic

WORKDIR /app
RUN git clone https://github.com/meshtastic/protobufs.git \
    && cp protobufs/meshtastic/mesh.proto protobufs/mesh.proto

# STEP 2
FROM perl:5.40-slim

RUN apt-get update && apt-get install -y \
    libssl-dev \
    libmariadb-dev \
    libprotobuf-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/lib/perl5 /usr/local/lib/perl5
COPY --from=builder /usr/lib/*/libprotobuf* /usr/lib/
COPY --from=builder /usr/bin/protoc /usr/bin/
COPY --from=builder /app/protobufs /app/protobufs

WORKDIR /app
COPY ./src .
RUN chmod +x multicast.pl

CMD ["perl", "./multicast.pl"]
FROM ubuntu:20.04 AS builder

# Install any dependencies we need here, like the C toolchain.
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install --assume-yes --no-install-recommends \
      build-essential cmake
RUN apt-get install --assume-yes --no-install-recommends libfuse-dev
RUN apt-get install --assume-yes --no-install-recommends pkg-config

WORKDIR /build
COPY . ./
RUN mkdir -p build && cd build \
 && cmake .. \
 && make && make install

FROM ubuntu:20.04

RUN apt-get update && apt-get install --assume-yes --no-install-recommends libfuse2

# Get the installed libraries and applications from the earlier stage.
COPY --from=builder /usr/local/ /usr/local/

USER root
WORKDIR /workdir

# Regenerate the shared-library cache.
RUN ldconfig

ENTRYPOINT ["longnamefs"]

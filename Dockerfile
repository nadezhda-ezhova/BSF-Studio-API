FROM keymetrics/pm2:latest-alpine

# Prepare system
ARG REQUIRE="sudo build-base linux-headers bash"
RUN apk update && apk upgrade
RUN apk add --no-cache ${REQUIRE}

# Set MPICH options
ARG MPICH_VERSION="3.3"
ARG MPICH_CONFIGURE_OPTIONS="--disable-fortran"
ARG MPICH_MAKE_OPTIONS

# Prepare folder
RUN mkdir /tmp/mpich-src
WORKDIR /tmp/mpich-src

# Download MPICH sources
RUN wget http://www.mpich.org/static/downloads/${MPICH_VERSION}/mpich-${MPICH_VERSION}.tar.gz
RUN tar xfz mpich-${MPICH_VERSION}.tar.gz
WORKDIR /tmp/mpich-src/mpich-${MPICH_VERSION}

# Build MPICH
RUN ls
RUN ./configure ${MPICH_CONFIGURE_OPTIONS}
RUN make ${MPICH_MAKE_OPTIONS}

# Install MPICH
RUN make install

# Test MPICH installation
RUN mkdir /tmp/samples
WORKDIR /tmp/samples
COPY samples .
RUN bash test.sh
RUN rm -rf /tmp/samples

# Cleanup
WORKDIR /
RUN rm -rf /tmp/*

# Prepare app dir
WORKDIR /var/www
RUN mkdir src
RUN mkdir samples

# Install dependencies
COPY package.json .
COPY yarn.lock .
RUN yarn install

# Copy app files
COPY Dockerfile .
COPY pm2.json .
COPY src ./src
COPY samples ./samples


# Make app available from outside
EXPOSE 3000

CMD [ "pm2-runtime", "start", "pm2.json" ]

FROM rocker/r-ver:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        libv8-dev  \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

RUN install2.r --error \
        R6 \
        jsonlite \
        jsonvalidate \
        plumber \
        remotes \
        testthat \
        thor

RUN installGithub.r \
        ropensci/jsonvalidate \
        reside-ic/pkgapi

COPY . /src
RUN R CMD INSTALL /src && \
    Rscript -e 'mintr:::write_script("/usr/bin")'

EXPOSE 8888

ENTRYPOINT ["/usr/bin/mintr"]

FROM rocker/r-ver:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        libv8-dev  \
        && apt-get clean \
        && apt-get install -y pandoc \
        && rm -rf /var/lib/apt/lists/*

RUN install2.r --error \
        R6 \
        glue \
        jsonlite \
        jsonvalidate \
        plumber \
        remotes \
        testthat \
        thor

RUN installGithub.r \
        ropensci/jsonvalidate \
        reside-ic/porcelain

WORKDIR /mintr

COPY . /src

RUN for f in /src/inst/json/*.md; do pandoc $f  -t html -o ${f%.*}.html; done;

RUN R CMD INSTALL /src && \
        Rscript -e 'mintr:::write_script("/usr/bin")' && \
        Rscript -e 'mintr:::mintr_db_docker("data")'

EXPOSE 8888

ENTRYPOINT ["/usr/bin/mintr"]

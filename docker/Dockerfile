FROM rocker/r-ver:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        libv8-dev \
        libglpk-dev \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

RUN install2.r --error \
        commonmark \
        R6 \
        glue \
        jsonlite \
        jsonvalidate \
        plumber \
        remotes \
        testthat \
        thor \
        dplyr \
        tidyr \
        ROI.plugin.glpk

RUN installGithub.r \
        ropensci/jsonvalidate \
        reside-ic/porcelain \
        r-opt/rmpk \
        r-opt/ROIoptimizer

WORKDIR /mintr

COPY . /src

RUN R CMD INSTALL /src && \
        Rscript -e 'mintr:::write_script("/usr/bin")' && \
        Rscript -e 'mintr:::mintr_db_docker("data")'

EXPOSE 8888

ENTRYPOINT ["/usr/bin/mintr"]

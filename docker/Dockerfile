FROM rocker/r-ver:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        libv8-dev \
        libglpk-dev \
        curl \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

COPY docker/install_packages /usr/local/bin/

RUN install_packages \
        --repo=https://mrc-ide.r-universe.dev \
        # --repo=https://r-opt.r-universe.dev \
        R6 \
        ROI.plugin.glpk \
        # ROIoptimizer \
        commonmark \
        dplyr \
        glue \
        jsonlite \
        jsonvalidate \
        plumber \
        porcelain \
        remotes \
        # rmpk \
        testthat \
        tidyr

RUN Rscript -e 'remotes::install_github(c("r-opt/ROIoptimizer", "r-opt/rmpk", "CosmoNaught/MINTer"))'
RUN Rscript -e 'MINTer::initialize_python()'

WORKDIR /mintr

COPY . /src

RUN R CMD INSTALL /src && \
        Rscript -e 'mintr:::write_script("/usr/bin")' && \
        Rscript -e 'mintr:::mintr_db_download("data")'

EXPOSE 8888

ENTRYPOINT ["/usr/bin/mintr"]

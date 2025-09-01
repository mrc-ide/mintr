FROM rocker/r-ver:latest

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        libv8-dev \
        libglpk-dev \
        && rm -rf /var/lib/apt/lists/*

# Configure repos (mrc-ide + CRAN)
RUN echo 'options(repos = c(mrcide="https://mrc-ide.r-universe.dev", CRAN="https://cloud.r-project.org"))' >> /usr/local/lib/R/etc/Rprofile.site

# Install python dependencies
COPY --from=ghcr.io/astral-sh/uv:0.8.14 /uv /uvx /bin/
RUN uv venv /opt/venv
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN uv pip install torch numpy pandas scikit-learn

# Pre-install R deps from DESCRIPTION for better caching
WORKDIR /src
COPY ./DESCRIPTION /src/
RUN Rscript -e 'install.packages("remotes"); remotes::install_deps("/src", dependencies = TRUE)'

# Copy the rest of the source and install the package
COPY . /src
RUN R CMD INSTALL /src

# Runtime setup using the installed package
WORKDIR /mintr
RUN Rscript -e 'mintr:::write_script("/usr/bin")' && \
        Rscript -e 'mintr:::mintr_db_download("data")'

EXPOSE 8888

ENTRYPOINT ["/usr/bin/mintr"]
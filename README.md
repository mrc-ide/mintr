## mintr

<!-- badges: start -->
[![Project Status: Concept – Minimal or no implementation has been done yet, or the repository is only intended to be a limited example, demo, or proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
[![Codecov test coverage](https://codecov.io/gh/mrc-ide/mintr/graph/badge.svg)](https://app.codecov.io/gh/mrc-ide/mintr)
[![R-CMD-check](https://github.com/mrc-ide/mintr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mrc-ide/mintr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Run from docker with:

```
docker run --rm -p 8888:8888 ghcr.io/mrc-ide/mintr
```

Note that at present both `POST` endpoints accept *any* json object as as body (it does however have to be an object following [the spec](inst/schema/Data.schema.json)).  We'll either tighten this later via the schema or do validation in the target functions.

```
curl http://localhost:8888/graph/prevalence/config
curl http://localhost:8888/table/impact/config
curl -X POST -H "Content-Type: application/json" --data "{}" http://localhost:8888/graph/prevalence/data
curl -X POST -H "Content-Type: application/json" --data "{}" http://localhost:8888/table/impact/data
```

See the [spec](inst/schema/spec.md) for more details.

## Updating data

(This is historic and will never happen again)

The basic flow of data coming in:

1. New raw (ish) data will come from the science team, recently at `\\fi--didenas1.dide.ic.ac.uk\malaria\Arran\malaria_projects\MINT\1_ModelSimulations\output\malariasimulation_runs\remove_peak_irs_increase_population`. It's really very slow to work with these against the network drive so it's good to copy these locally on your machine for processing.
1. Edit `inst/data_version` to create a new data version - should be an ISO date (`YYYYMMDD`). Typically this date should match the date of the raw data files.
1. Edit the top of `scripts/import` to reflect the new data
1. Run `./scripts/import path/to/data path/to/output` to produce a file `<date>.tar`
1. Upload that file as a new Github release in the in the `mrc-ide/mintr` repository. The release name should follow `data-YYYMMDD`, using the same date from the `data_version` file.
1. Build a new Docker image. This will download the new data set from GitHub and embed it into the image.

## Get going with local development

After cloning the repository, ensure you have all R package dependencies with

```
./scripts/install_deps
```

Running the package's tests (using `devtools::test()` or through RStudio) for the first time will download the dataset off GitHub and store them in `tests/testthat/data`. Subsequent runs will re-use that data.

## Emulator

(This is historic and will not be used in the next version)

mintr supports an optional experimental "emulator" mode, in which a machine-learning model is used instead of precomputing data.
mintr does not execute the model itself. The pre-trained emulator model is exposed by mintr's API. The frontend loads and executes the model directly in the browser.

Since this feature is still under active development, the docker image does not contain any of the artefacts required to use the emulator.
Instead they need to be bind-mounted onto the container and enabled with a command line argument:

```
docker run --rm -p 8888:8888 -v /path/to/emulator:/emulator ghcr.io/mrc-ide/mintr --emulator=/emulator
```

## Deployment

Deployment on the DIDE network is descrbed in the [Knowledge Base article](https://mrc-ide.myjetbrains.com/youtrack/articles/mrc-A-10/MINT---mintr#server)

## License

MIT © Imperial College of Science, Technology and Medicine

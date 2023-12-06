## mintr

<!-- badges: start -->
[![Project Status: Concept – Minimal or no implementation has been done yet, or the repository is only intended to be a limited example, demo, or proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
[![R build status](https://github.com/mrc-ide/mintr/workflows/R-CMD-check/badge.svg)](https://github.com/mrc-ide/mintr/actions)
[![Codecov test coverage](https://codecov.io/gh/mrc-ide/mintr/branch/master/graph/badge.svg)](https://codecov.io/gh/mrc-ide/mintr?branch=master)
<!-- badges: end -->

Run from docker with:

```
docker run --rm -p 8888:8888 mrcide/mintr:v0.1.0
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

## Browser tests

Browser tests are included (in `tests/e2e`) in order to test config changes made in mintr are rendered correctly in MINT. To run browser tests locally:
1. Install [Playwright](https://playwright.dev/docs/intro#installing-playwright)
2. Run mintr and MINT in docker with `./docker/run_app` - this runs the mintr docker image pushed for the current git SHA, and the master branch of MINT. Change the line `export MINT_BRANCH=master` to run a different MINT branch. 
3. Run `npx playwright test` from `tests/e2e`

The browser tests are also run as part of the BuildKite pipeline, in a docker container built from `docker/test-e2e.dockerfile` using config from `tests/e2e/playwright.docker.config.ts`


## Deployment

Deployment on the DIDE network is descrbed in the [Knowledge Base article](https://mrc-ide.myjetbrains.com/youtrack/articles/mrc-A-10/MINT---mintr#server)


## License

MIT © Imperial College of Science, Technology and Medicine

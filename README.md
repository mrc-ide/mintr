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
1. Edit `inst/version` to create a new data version - should be an ISO date (`YYYYMMDD`). Typically this date should match the date of the raw data files.
1. Edit the top of `scripts/import` to reflect the new data
1. Run `./scripts/import path/to/data path/to/output` to produce a file `<date>.tar`
1. Copy that file to the network share (recent versions are about 500MB)
1. RDP to `fi--didex1` and copy the tar file to `C:\xampp\htdocs\mrcdata\mint\<date>.tar`
1. Rerun the tests in the package, which will pull down the most recent version

Note that the script will avoid downloading the files if they are already present in destination directory, so do not update files on the server without renaming them.

Then, if needed, adjust the code in `R/import.R` which processes and loads the data. You will need to delete the database at `tests/testthat/data` (all files not in the dated directories should be deleted).

The core data required to build the database, after passing through the import scripts are a few 10s of MB and are baked into the docker image. When the docker container starts, it will inflate this database into the actual data needed. This process will take a few seconds on image startup, but that's worth it for the reduced image size.

## Get going with local development

After cloning the repository, ensure you have all R package dependencies with

```
./scripts/install_deps
```

You will need a copy of the data. Run `./scripts/import` which will download, process and import the mintr database in `tests/testthat/data`, which will then be available for tests.

## Browser tests

Browser tests are included (in `tests/e2e`) in order to test config changes made in mintr are rendered correctly in MINT. To run browser tests locally:
1. Install [Playwright](https://playwright.dev/docs/intro#installing-playwright)
2. Run mintr and MINT in docker with `./docker/run_app` - this runs the latest mintr docker image pushed for the current branch, and the master branch of MINT. Change the line `export MINT_BRANCH=master` to run a different MINT branch. 
3. Run `npx playwright test` from `tests/e2e`

The browser tests are also run as part of the BuildKite pipeline, in a docker container built from `docker/test-e2e.dockerfile` using config from `tests/e2e/playwright.docker.config.ts`


## Deployment

Deployment on the DIDE network is descrbed in the [Knowledge Base article](https://mrc-ide.myjetbrains.com/youtrack/articles/mrc-A-10/MINT---mintr#server)


## License

MIT © Imperial College of Science, Technology and Medicine

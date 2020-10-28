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

This will evolve as the upstream data changes and as our needs change. We store the raw data from the science team on mrcdata.dide.ic.ac.uk and pull them in when building the docker images or when building a database for testing.  They will expand into the actual mint database, which is much larger than the rds but faster to read.

1. Acquire new data from the science team; this will come as a number of .rds files, the largest of which will be quite large.
2. Copy these files onto a network-accessible share (e.g. for Rich `~/net/home/mint`)
3. RDP to `fi--didex1` and copy these files into `C:\xampp\htdocs\mrcdata\mint\<date>` where `<date>` is YYYYMMDD (just to keep things tidy)
4. Update the paths in `inst/data.json` to reflect the new data

Note that the script will avoid downloading the files if they are already present in destination directory, so do not update files on the server without renaming them.

Then, if needed, adjust the code in `R/import.R` which processes and loads the data. You will need to delete the database at `tests/testthat/data` (all files not in the dated directories should be deleted).

The core data required to build the database, after passing through the import scripts are a few 10s of MB and are baked into the docker image. When the docker container starts, it will inflate this database into the actual data needed. This process will take a few seconds on image startup, but that's worth it for the reduced image size.

## Get going with local development

After cloning the repository, ensure you have all R package dependencies with

```
./scripts/install_deps
```

You will need a copy of the data. Run `./scripts/import` which will download, process and import the mintr database in `tests/testthat/data`, which will then be available for tests.

## License

MIT © Imperial College of Science, Technology and Medicine

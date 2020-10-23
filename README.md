## mintr

<!-- badges: start -->
[![Project Status: Concept – Minimal or no implementation has been done yet, or the repository is only intended to be a limited example, demo, or proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
[![Travis build status](https://travis-ci.com/mrc-ide/mintr.svg?branch=master)](https://travis-ci.com/mrc-ide/mintr)
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

This will evolve as the upstream data changes and as our needs change. These scripts will create rds files that can be used to initialise the app. We'll store these either on mrcdata.dide.ic.ac.uk or as github release artefacts and pull them in fairly automatically during deployment.  They will expand into the actual mint database, which is much larger than the rds but faster to read.

1. Acquire new data from the science team; this will come as a number of .rds files, the largest of which will be quite large.
2. Copy these files onto a network-accessible share (e.g. for Rich `~/net/home/mint`)
3. RDP to `fi--didex1` and copy these files into `C:\xampp\htdocs\mrcdata\mint\<date>` where `<date>` is YYYYMMDD (just to keep things tidy)
4. Update the paths in `inst/data.json` to reflect the new data

Note that the script will avoid downloading the files if they are already present in the `import` directory, so do not update files on the server without renaming them.

Then, if needed, adjust the code in R/import.R which processes and loads the data. You will need to delete the database at `tests/testthat/data` (all files not in the dated directories should be deleted).

## License

MIT © Imperial College of Science, Technology and Medicine

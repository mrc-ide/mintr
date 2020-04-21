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

Note that at present both `POST` endpoints accept *any* json as a body so long as it exists.

```
curl http://localhost:8888/graph/prevalence/config
curl http://localhost:8888/table/impact/config
curl -X POST -H "Content-Type: application/json" --data "{}" http://localhost:8888/graph/prevalence/data
curl -X POST -H "Content-Type: application/json" --data "{}" http://localhost:8888/table/impact/data
```

See the [spec](inst/schema/spec.md) for more details.

## License

MIT © Imperial College of Science, Technology and Medicine

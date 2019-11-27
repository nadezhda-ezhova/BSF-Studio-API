# BSF-Studio-API
_Don't forget to update application version number in **package.json** before push new version into repo_

## Init project
```
git clone git@github.com:scepion1d/BSF-MRA36-API.git api
cd ./api
git submodule update --init --recursive
```

## Update project sources
```
git pull origin master
git submodule update --recursive --remote
```

## Build image
```
make build
```
## Run container
```
make run
```

## Deploy app to cluster
```
make publish-version && make deploy
```

## Sample routes
```
http://localhost/samples/grav_mr
http://localhost/samples/jac_m
```

## Sample request

Content-Type: **multipart/form-data**

Body format:
```
src: <src.cpp>
src: <src.h>
...
src: <src.cpp>
```

# node-reverse-tunnel-service
Creates reverse ssh tunnel to beekeeper



# create deb package
```bash
docker run -ti --rm -v `pwd`:/workdir -w /workdir ubuntu:20.04 /bin/bash -c 'apt-get update && apt-get install -y git && ./release.sh'
```

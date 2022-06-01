# puma-phased-restart-bundler-error

See https://github.com/puma/puma/issues/2843
This project reproduces an issue related to phased restarts in Puma. Perhaps related to bundler and the global system gems.

## Usage
```
docker build -t puma-restart-error .
docker run -it puma-restart-error
```


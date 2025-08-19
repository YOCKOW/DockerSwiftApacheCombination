# What is `DockerSwiftApacheCombination`?

This repository includes container image which enables you to run CGI programs written in Swift via Apache HTTP Web Server. 


## Packages

You can fetch the built container images from `ghcr.io/yockow/swift-de-cgi`.  
See its [Versions](https://github.com/YOCKOW/DockerSwiftApacheCombination/pkgs/container/swift-de-cgi/versions).

### Tag List

|              | Swift 6.0.3                | Swift 6.1.2                |
|--------------|----------------------------|----------------------------|
| Ubuntu 22.04 | `Swift_6.0.3-jammy-latest` | `Swift_6.1.2-jammy-latest` |
| Ubuntu 24.04 | `Swift_6.0.3-noble-latest` | `Swift_6.1.2-noble-latest` |


## How to use

As a default, [tools/entrypoint](tools/entrypoint) is used as `ENTRYPOINT` program.

You can run the cntainer image just as an HTTP server:

```console
# docker run -it -d --rm -p 60080:80 ghcr.io/yockow/swift-de-cgi:Swift_6.1.2-noble-latest
# curl localhost:60080
<html><body><h1>It works!</h1></body></html>
```

You can specify `httpd.conf`:

```console
# docker run -it -d --rm -v /path/to/my/web:/home/swifche/web -p 80:80 ghcr.io/yockow/swift-de-cgi:Swift_6.1.2-noble-latest httpd -f /home/swifche/web/httpd.conf
```

### User/Group

This container has a user named `swifche` and a group named `swifche`.
You can run the container image with changing group ID of `swifche` via the environment variable `WWW_GROUP_ID`.
It may be convenient when you want to mount your own volume to the container and share a group ID.


## Notice

The image is based on [`swift:slim`](https://hub.docker.com/layers/library/swift/slim/images/sha256-9d105459cce7309770f0686bdeb44d5dce73ffbd441106e3e2ae74b176a59b81). You will need other container images (e.g. [`swift:latest`](https://hub.docker.com/layers/library/swift/latest/images/sha256-b3cfba744a0d0697f7225c0f6486dd6b24f2963b0aef5e2f0d54a17da6a1d3b6)) to build your Swift programs.

You can see an example at [GitHub.com/YOCKOW/Eutardigrada.YOCKOW.jp](https://GitHub.com/YOCKOW/Eutardigrada.YOCKOW.jp)


# License

MIT License.  
See "LICENSE.txt" for more information.

## Caveat

Whereas this repository itself is licensed under MIT License, the deployed container image contains some other open source softwares.
Their license files are in the directory at `/licenses` and you can see them by executing `show-licenses` in the container.

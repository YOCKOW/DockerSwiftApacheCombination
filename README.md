# What is `DockerSwiftApacheCombination`?

This repository includes container image which enables you to run CGI programs written in Swift via Apache HTTP Web Server. 


## Packages

You can fetch the built container images from `ghcr.io/yockow/swift-de-cgi`.  
See its [Versions](https://github.com/YOCKOW/DockerSwiftApacheCombination/pkgs/container/swift-de-cgi/versions).

### Tag List

|              | Swift 6.2.4                   | Swift 6.3.3                   | Swift 6.4.0                   |
|--------------|-------------------------------|-------------------------------|-------------------------------|
| Ubuntu 24.04 | `Swift_6.2.4-noble-latest`    | `Swift_6.3.3-noble-latest`    | `Swift_6.4.0-noble-latest`    |
| Ubuntu 26.04 | n/a                           | n/a                           | `Swift_6.4.0-resolute-latest` |
| Debian 12.12 | `Swift_6.2.4-bookworm-latest` | `Swift_6.3.3-bookworm-latest` | `Swift_6.4.0-bookworm-latest` |


## How to use

As a default, [tools/entrypoint](tools/entrypoint) is used as `ENTRYPOINT` program.

You can run the container image just as an HTTP server:

```console
# docker run -it -d --rm -p 60080:80 ghcr.io/yockow/swift-de-cgi:Swift_6.4.0-resolute-latest
# curl localhost:60080
<html><body><h1>It works!</h1></body></html>
```

You can specify `httpd.conf`:

```console
# docker run -it -d --rm -v /path/to/my/web:/home/swifche/web -p 80:80 ghcr.io/yockow/swift-de-cgi:Swift_6.4.0-resolute-latest httpd -f /home/swifche/web/httpd.conf
```

### User/Group

This container has a user named `swifche` and a group named `swifche`.
You can run the container image with changing group ID of `swifche` via the environment variable `WWW_GROUP_ID`.
It may be convenient when you want to mount your own volume to the container and share a group ID.


## Notice

The image is based on `swift:slim`. You will need other container images (e.g. `swift:latest`) to build your Swift programs.

You can see an example at [GitHub.com/YOCKOW/Eutardigrada.YOCKOW.jp](https://GitHub.com/YOCKOW/Eutardigrada.YOCKOW.jp)


# License

MIT License.  
See "LICENSE.txt" for more information.

## Caveat

Whereas this repository itself is licensed under MIT License, the deployed container image contains some other open source softwares.
Their license files are in the directory at `/licenses` and you can see them by executing `show-licenses` in the container.

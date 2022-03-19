# kong-a-thon

Hacking on Kong

## Agenda

Let's deploy Kong and configure a service while documenting the experience.

Here are the discrete goals:

* Install Kong Enterprise free mode on Kubernetes using Helm
* Expose an API of your choice
* Secure API with Key Auth
* Apply a rate limit of 10 requests per minute

## Prerequisites

* [jq](https://stedolan.github.io/jq/) for JSON processing
* A running [Docker](https://www.docker.com/) if using a local K8s cluster
* [k3d](https://k3d.io/v5.3.0/) if using a local K8s cluster

## Usage

The repo uses a `Makefile` to automate steps.

The initial goal is to install Kong onto K8s via Helm, so we can deploy a local K8s cluster using k3d if we need one:

```
make cluster
```

The rest of the commands will use the current K8s context configured in `kubectl`.
 
```
make kong
```

## Build Experience

The following are notes on my 'developer experience' while building this in the style of a friction log.

* First search term: `kong install free with helm`.
	* Top hit is https://docs.konghq.com/gateway/2.7.x/install-and-run/helm/
	* I'm warned that this isn't the latest version. <span style="color:yellow">Ideally I'd get results for something like `latest` in the URL path</span>. Once I arrived I was directed to the latest (which is still a static version `2.8.x` in the path)
  *  

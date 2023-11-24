# Sample Go Application for a Webserver

This Repo may consists some examples and leading instructions on how to use argo Workflows,
in combination with in-cluster builders, like Kaniko.

## This repo is under active development - proceed with caution.

## How to use this repository

This sample-application unfolds its full potential within the combinated usage
of ArgoCD Workflows, GitHub Actions, ChartMuseum (in-cluster), and in-cluster GitHub Action Runners.

That being said:
Covering the configuration and deployment of these is NOT covered within this repository, since this is not a how-to getting started guide on kubernetes.

This repository contains a simple sample-application, that can be used AS-IS with the above mentioned tools.

## Whats inside

### /.argo
This contains the argocd Workflow definitions for in-cluster builds, publish and release stages.
Edit as you need, or emit.

### /.github
GitHub Actions are used for the in-cluster GitHub Action controller.
This may not be edited, emit if not needed.

### /charts
Template Helm Chart definition, which will be later overwritten and managed by argoCD itself.
Edit to your needs.

### /cmd
Contains your Go programs entrypoint 'main.go'.
This one is a fairly straight forward use-case of an minimalistic webserver using only the standard library.

We do serve to handlers:
One: / 
Second: /version

Like so:
```
http.HandleFunc("/", greet)
http.HandleFunc("/version", version)
```

Which will serve these functions:

```
func version(w http.ResponseWriter, r *http.Request) {
	info, ok := debug.ReadBuildInfo()
	if !ok {
		http.Error(w, "no build information available", 500)
		return
	}

	fmt.Fprintf(w, "<!DOCTYPE html>\n<pre>\n")
	fmt.Fprintf(w, "%s\n", html.EscapeString(info.String()))
}

func greet(w http.ResponseWriter, r *http.Request) {
	name := strings.Trim(r.URL.Path, "/")
	if name == "" {
		name = "Gopher"
	}

	fmt.Fprintf(w, "<!DOCTYPE html>\n")
	fmt.Fprintf(w, "%s, %s!\n", *greeting, html.EscapeString(name))
}
```

### Dockerfile
Within this Dockerfile, we use the golang:latest Container Image as a Builder
```
FROM golang:latest AS builder
```

Our final container will be 'FROM scratch' with proper user management
```
COPY <<EOF /etc/group
root:x:0:
nonroot:x:55061:
EOF

COPY <<EOF /etc/passwd
root:x:0:0:root:/root:/sbin/nologin
nonroot:x:55061:55061:nonroot:/home/nonroot:/sbin/nologin
EOF
```

Lastly we will copy the binary - build with/from our builder
```
COPY --from=builder $WORKDIR/sample-application .
```
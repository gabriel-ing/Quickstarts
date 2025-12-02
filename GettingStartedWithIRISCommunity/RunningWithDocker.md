## Running with Docker

The easiest way to get started using InterSystems IRIS Community Edition is to use Docker. Docker is a containerization framework that runs software in a standardized environment. In this way, the install process is the same for all operating systems. 

### 1. Install Docker

Docker can be downloaded from their [website](https://docs.docker.com/get-started/get-docker/). 

### 2. Download and Run the InterSystems IRIS Community Edition

The process of downloading and running the InterSystems IRIS Community Edition can be performed by a single command: 

```bash
docker run --name my-iris --publish 52773:52773 --publish 1972:1972 -d intersystems/iris-community:latest-em
```
To break this down: 
- `run` is the docker command to run an image. It will search for the container locally, before then searching online with the `docker pull` command. Therefore, the `pull` command does not need to be run separately.
- `intersystem/iris-community:latest-em` is the main parameter of the run command. This is the location of the InterSystems IRIS Community Edition within the docker hub, which is the market place for container images. 
    - `latest-em` is a tag for the version being downloaded, `em` stands for extended maintenance. You can also specify a version number, e.g. `2025.1` or `latest-cd` for the latest version in continuous development.
- `--name my-iris` gives your container the name my-iris, you can change this to anything you want, but it's useful to make it something memorable.
- `publish` maps your local ports to the container ports (local:container). InterSystems IRIS sends binary data on Port 1972 and uses Port 52773 for web-server data.  If you have something running locally on ports 52773 or 1972, you can map the container ports to different ports. 
- `-d` flag detaches your terminal so you can continue to use it. 

You can start using InterSystems IRIS through the management portal at http://localhost:52773/csp/sys/%25CSP.Portal.Home.zen 

The default username is `_SYSTEM` and password is `SYS`; you will be prompted to change this password after logging in.

You can then start an IRIS terminal with: 

```bash
docker exec -it my-iris iris session iris
```
or a bash terminal with: 
```bash
docker exec -it my-iris bash
```

#### InterSystems IRIS for Health Community Edition

To download the health-care specific version of our core product, InterSystems IRIS for Health Community edition, the above command changes to: 

```bash
docker run --name my-iris --publish 52773:52773 --publish 1972:1972 -d intersystems/iris-health-community:latest-em
```
The usage is identical to what is covered above, but this edition contains healthcare specific libraries, including the ability to [set up a FHIR server](../FHIRServer/CreateAFHIRSeverIn5Minutes.md)

And there you have it, a fully functional local version of InterSystems IRIS Community Edition to start exploring. To set-up your development environment see [Setting Up your development environment](../DevelopmentEnvironment/Development%20Environment%20Set-up.md).
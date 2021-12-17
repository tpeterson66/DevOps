# Traefik

General notes on Traefik load balancer/ingress.

### Labels

```bash
traefik.http.routers.<router_name>.rule
<docker_service>.<protocol>.<Traefik_configuration>.<router_name>.rule
```

## Use Cases

- 2 billion downloads
- 30k+ stars
- 500+ contribuitors
- Top 10 most popular image from Docekr Hub

General Use Cases and Features:

- Reverse Proxy - Routing and load balancing - L4-L7
- API Gateway - Control routes to different apps, supports middleware and authentication
- Load Balancing  - Round Robin, Lowest connections, health checks
- Certificate Management - Manage SSL certificates dynamically using LetsEncrypt
- Kubernetes Ingress

Other products from Traefik

- Traefik EE - Enterprise version of Traefik used to run large clusters or many clusters
- Traefik CE - Comunity Edition
- Meash - Service Mesh for Kubernetes
- Traefik Piolt - SaaS control platform

## Traefik Background

- Tons of reverse proxies but none were dynamic
- Created by Emile Vauge in 2015
- Microservices are dynamic which requires dynamic configurations
- Watches the orchestrator for new events
- Written in GoLang - Very small binary and very small image as well
- Purpose built Edge Router - The front door to your environment
    - Intercepts incoming requests and routes the reqeuests
    - Define logic to determin which service recieves the requests based on path, host, headers, and more.
- Automatically discovers services and configurations
- Native Integration with AWS, Kuberenetes, Docker, Mesos, Nomad, and many more
- Automatically syncronizes configuration changes in real-time, no restarts, no down-time

Auto Discovery:

- Traefik pulls the configuration information directly from the service
- Traefik attaches information to the request to route to the correct service
- When new services are started, Traefik detects the new service and routes

## Traefik Providers

- A provider links an infrastructure component (orchestrator, container engine, Key-value store, or file) to Traefik
- Configure traefik to connect to the provider
- Traefik detects configuration changes and events from the provider

List includes:
- Docker (Orchestrator) - Using labels - <docs.traefik.io/providers/docker>
- kubernetes (Orchestrator) - Custom resource or Ingress
- Consul Catalog (Orchestrator) Using Labels
- Marathon (Orchestrator) - Using Labels
- Rancher (Orchestrator) - Using Labels
- File (manual) - TOML/YAML format
- Consul (kv)
- Etcd (kv)
- Redis (kv)
- ZooKeeper (kv)

## 01-Notes

```YAML
version: '3'

services:
  traefik:
    # The latest official supported Traefik docker image
    image: traefik:v2.3
    # Enables the Traefik Dashboard and tells Traefik to listen to docker
    # --providers tell Traefik to connect to the Docker provider
    # enable --log.level=INFO so we can see what Traefik is doing in the log files
    command: --api.insecure=true --providers.docker --log.level=INFO
    ports:
      # Exposes port 80 for incomming web requests
      - "80:80"
      # The Web UI port http://0.0.0.0:8080 (enabled by --api.insecure=true)
      - "8080:8080"
    volumes:
      # So that Traefik can listen to the Docker events
      - /var/run/docker.sock:/var/run/docker.sock

# Add the whoami service
  whoami:
     # A container that exposes an API to show its IP address
     image: containous/whoami
     # We set a label to tell Traefik to assign a hostname to the new service
     labels:
       - "traefik.http.routers.whoami.rule=Host(`whoami.docker.localhost`)
```

```bash
docker-compose up -d traefik

# Verify the container started 
docker ps
docker logs <container id>

# Start up the whoami
docker-compose up -d whoami

docker ps
docker logs <whoami container id>

# Check that traefik routed the request
curl http://whoami.docker.localhost
curl -H Host:whoami.docker.localhost 127.0.0.1 # more advanced

#######
Hostname: 9a6823a7c42a
IP: 127.0.0.1
IP: 172.18.0.3
RemoteAddr: 172.18.0.2:49538
GET / HTTP/1.1
Host: whoami.docker.localhost
User-Agent: curl/7.68.0
Accept: */*
Accept-Encoding: gzip
X-Forwarded-For: 172.18.0.1
X-Forwarded-Host: whoami.docker.localhost
X-Forwarded-Port: 80
X-Forwarded-Proto: http
X-Forwarded-Server: f11e03796135
X-Real-Ip: 172.18.0.1
#######

# Scale the containers to 2 containers
docker-compose scale whoami=3

# Validate with docker ps
docker ps

# Re-run the curl command to see the round robin routing
curl -H Host:whoami.docker.localhost 127.0.0.1 # more advanced

# Scale back down to 1
docker-compose scale whoami=1

# check with docker ps
docker ps

# check with CURL to ensure traefik is not routing to those endpoints
curl -H Host:whoami.docker.localhost 127.0.0.1 # more advanced
```

## Traefik Configurations

- Static configurations vs. Dynamic Configurations
- Static configuration includes entrypoints, provider connection information, etc. - loaded at the statup of the service.
- Dynamic configuration includes routers, services, middleware, certifications, etc. - These are reloaded automatically
- There are three different, MUTUALLY EXCLUSIVE options for static configuration. You can only use ONE at a time.
    - Configuration File - Either YAML or TOML file - /etc/traefik/traefik.yaml or /etc/traefik/traefik.toml
    - In the command line arguments - Passed at the or in docker compose/docker run command line
    - as envrionment variables - Easier to read and can be tokenized through automation, can also be passed through docker-compose or YAML

### Docker Provider Configuration

- defaults are good enough to get started
- Start small and increment the configuration
- Port detection 
    - if the container exposes a port, then traefik uses it for internal communications
    - If a container exposes muiltiple ports or no ports at all, then a label should define which port to use
- ExposedByDefault - false - to ensure new containers are not automatically exposed
- Should implement certificates between Traefik and the orchestrator using TLS
- Limit the docker api access
- Use best practices for securing docker
- Review the docker api access documentation - run docker bench to check security standards

Dynamic Configurations  - Labels

- by attaching labels to a service/container, we can:
    - define routers
    - define middlewares
    - update configurations of services

### Entrypoint configurations

Used to define which ports or hosts are able to ingress to Traefik. Rules can be added to rewrite requests to other hosts or entrypoints.

- Can be defined using TOML, YAML, and CLI
- Define which ports to listen for incoming connections
- redirect connections from http -> https
- Forward header configuration
- Override default tls with user-defined TLS

### Load Balancing and Routing

How the incoming requests flow through Traefik is determined by the below components
- Providers - discovery the services that live on your infrastructure including their IP, health, etc.
- Entrypoints - Listen for incoming traffic, simple ports
- Routers - Analyse the requests (host, path, headers, ssl)
- Services - forward the requests to your services (Load Balancing)
- Middlewares - May update the request to make decisions based on the request (authentication, rate limiting, headers)

### Routers
Connecting requests to services!

- Router defaults
    - Traefik creates, for each container, a corresponding service and router
    - The service automatically gets a server per instance of the container, and the router automatically gets a rule defined by defaultRule (if no rule for it was defined in labels).
    - by default, routers will accept all requests from all defined entrypoints, using a label can determin specific routers if required

Router Configurations:

https://docs.traefik.io/routing/routers
https://docs.traefik.com/routing/providers/docker/#routers
```bash
- traefik.http.routers.<routers_name>.rule
    - "traefik.http.routers.myrule.rule=Host(`example.com`)"
- traefik.http.routers.<routers_name>.entrypoints
    - "traefik.http.routers.myrule.entrypoints=ep1,ep2"
- traefik.http.routers.<routers_name>.service
    - "traefik.http.routers.myrule.service=myservice"
- traefik.http.routers.<routers_name>.tls
    - "traefik.http.routers.myrule.tls=true" # default is false, when true, only accepts TLS connections
```

Tips:
- to set the value of a rule, use backticks or escaped double quotes = \"
- single quotes are not accepted as values in GoLangs string literals
- Example = "traefik.http.routers.whoami.rule=host(`whoami.localhost`)"

### Services

Configures how to reach the application

- Each service has its own load balancer
- Load Balancers can load balance requests between multiple instances of your application
- The target of the load balancer is called a server
- Only Round Robin Load Balancing is available using the same server
- Load Balancers can be configured with Health Checks to monitor the health of the server
    - health probes can use tcp port, http, or specific path
- A service can be assigned to one or more routers

```bash
traefik.http.services.<service_name>.loadbalancer.server.port
    - "traefik.http.services.myservice.loadbalancer.server.port=8080"
traefik.http.services.<service_name>.loadbalancer.server.passhostheader
    - "traefik.http.services.myservice.loadbalancer.server.passhostheader=true"
traefik.http.services.<service_name>.loadbalancer.server.healthcheck.path
    - "traefik.http.services.myservice.loadbalancer.server.healthcheck.path=/foo"
traefik.http.services.<service_name>.loadbalancer.server.healthcheck.port
    - "traefik.http.services.myservice.loadbalancer.server.healthcheck.port=8080"
```

Docker Specific Configuration options
- traefik.enable=true - overrides the exposedbydefault setting
- traefik.docker.network - overrids the default network used by traefik
- traefik.docker-lbswarm - enables swarms built-in load balancer and stops using traefik

TCP/UDP routers and services are also available using labels
- Enabled with Labels
- Follows the same principals as HTTP
- contains less configuration options
- Still requires an entrypoint
- Services are configured just for the connections between

Simple configuration with minimal amount of configuration allow Traeik to dynamically build the configuration.

```yaml
# Add the catapp service
  catapp:
     image: mikesir87/cats:1.0
     labels:
       - "traefik.enable=true"
       - "traefik.http.routers.catapp.rule=Host(`catapp.localhost`)"
       - "traefik.http.routers.catapp.entrypoints=web"
```


## Troubleshooting

```bash
# Show all services deployed
docker service ls

# check the logs for a service
docker service logs <service_name>

# Common error message
# traefik_traefik.1.tut3xrkwl4n6@traefik    | time="2021-12-17T01:41:00Z" level=error msg="the service \"catapp@docker\" does not exist" routerName=catapp@docker entryPointName=web
```

Issue where Traefic router is unhappy - check the flow to identify the problem. In this case, the service is unavailable, identify the correct name of the service or create the service. In this case, Traefik could not reach the application on the default port of 80 and was throwing an error. Updating the service port resolved the issue.

## HTTPS and TLS

- Default Certificate - If not certificate is provided by Traefik and uses the self-signed certificate
- User defined - Provded certificates directly to Trafeik which will then be applied to the maching endpoints
    - bring your own certifcates installed and manage your own certificates
    - Can be added to the dynamic configuration using the file provider
    - Can also be added to static configuration - but only loaded at startup
    - Entrypoint matching - traefik will automatically match the entrypoint request with the certificate
    - TLS Configurations - you have TLS configuration options to manage the TLS connection (TLS Version, timeout, etc.)
- Automated - Traefik uses letsencrypt to generate certificates automatically on a per request basis
    - LetsEncrypt validates your control of the domain name using a challenge
    - HTTP challenge - LetsEncrypt gives a token to Traefik which is then served back to Lets Encrypt for verification
        http://<yourdomain>/.well-known/acme-challenge/<token>
    - DNS Challenge - Traefik uses your dns providers API to place a DNS TXT record in your domain records to verify ownership
    - TLS challenge - Performs a handshake between traefik and Lets encrypt on port 443.


```yaml
tls:
    certificates:
        - certFile: /path/to/cert/domain.cert
          keyFile: /path/to/key/key.pem

```

### HTTP Challenge


```yaml
# traefik.yml
# API and dashboard configuration
api:
  # Dashboard
  #
  #
  dashboard: true
  insecure: true

# Docker configuration backend
providers:
  docker:
    exposedByDefault: false

# Traefik Logging
log:
  level: INFO

# Entrypoint
entryPoints:
  web:
    address: ":80"
  websecure:
    address: ":443"

# Challenge HTTP
certificatesResolvers:
  myresolver:
    acme:
      email: tpeterson66@gmail.com 
      storage: acme.json
      httpChallenge:
        entryPoint: web
```

```yaml
# docker-compose.yml
version: '3'

services:
  traefik:
    # The latest official supported Traefik docker image
    image: traefik:v2.3
    # Enables the Traefik Dashboard and tells Traefik to listen to docker
    # enable --log.level=INFO so we can see what Traefik is doing in the log files
    ports:
      # Exposes port 80 for incomming web requests
      - "80:80"
      - "443:443"
      # The Web UI port http://0.0.0.0:8080 (enabled by --api.insecure=true)
      - "8080:8080"
    volumes:
      # So that Traefik can listen to the Docker events
      - /var/run/docker.sock:/var/run/docker.sock
      # Copies the Let's Encrypt certificate locally for ease of backing up
      - ./letsencrypt:/letsencrypt
       # Mounts the Traefik static configuration inside the Traefik container
      - ./traefik.http.yml:/etc/traefik/traefik.yml

# Add the catapp service
  catapp:
     image: mikesir87/cats:1.0
     labels:
       - "traefik.enable=true"
       - "traefik.http.routers.catapp.rule=Host(`cats.tpeterson.io`)"
       - "traefik.http.routers.catapp.service=catapp"
       - "traefik.http.services.catapp.loadbalancer.server.port=5000"
       - "traefik.http.routers.catapp.entrypoints=websecure"
       - "traefik.http.routers.catapp.tls.certresolver=myresolver"
```

### TLS Challenge

```bash
# Same as HTTP, only a different resolver
certificatesResolvers:
  myresolver:
    acme:
      email: cats.tpeterson.io  
      storage: acme.json
      tlsChallenge: true
        # # used during the challenge
        # entryPoint: web
```

### DNS Challenge

Probably the most common as its more automated and instant. Requires additional configuration depending on the provider. Typically requires environment variables to be defined.

```yaml
# docker-compose.yml
version: '3'

services:
  traefik:
    # The latest official supported Traefik docker image
    image: traefik:v2.3
    # Enables the Traefik Dashboard and tells Traefik to listen to docker
    # enable --log.level=INFO so we can see what Traefik is doing in the log files
    ports:
      # Exposes port 80 for incomming web requests
      - "80:80"
      - "443:443"
      # The Web UI port http://0.0.0.0:8080 (enabled by --api.insecure=true)
      - "8080:8080"
    volumes:
      # So that Traefik can listen to the Docker events
      - /var/run/docker.sock:/var/run/docker.sock
      # Copies the Let's Encrypt certificate locally for ease of backing up
      - ./letsencrypt:/letsencrypt
       # Mounts the Traefik static configuration inside the Traefik container
      - ./traefik.dns.yml:/etc/traefik/traefik.yml
    environment:
      - "DO_AUTH_TOKEN=<Your Super Secret Digital Ocean Token Goes here>"

# Add the catapp service
  catapp:
     image: mikesir87/cats:1.0
     labels:
       - "traefik.enable=true"
       - "traefik.http.routers.catapp.rule=Host(`your_domain_here`)"
       - "traefik.http.routers.catapp.service=catapp"
       - "traefik.http.services.catapp.loadbalancer.server.port=5000"
       - "traefik.http.routers.catapp.entrypoints=websecure"
       - "traefik.http.routers.catapp.tls.certresolver=myresolver"
```

## Middleware
 
- Middlewares connect to routers - One or more middlewares can connect to one or more routers
- Intercepts requests - the middleware transforms the requests before they are sent to a service
- failures result in a 401 error
- types of middlewares
    - authentication - handles user/service authentication
    - content modifier - manages the served content
    - middleware tool - middleware management
    - path modifier  - configures the handling of the url structure
    - request lifecycle - applies rules to service requests
    - security - secures access to the service
- Steps to configure
    - Create middleware - define it
    - router <-> middleware - connect the router to the middleware
    - Gotchya - Most examples show creating the middleware and not connecting it to a router
- Labels
    - traefik.http.middleware.<name>.role

### Middleware Labs

BasicAuth - Add basic authentication to services
compress - enables gzip compression on served content
errorPage - Displays custom error pages for 400/500 errors
rateLimit - Configure the number of allowed requests to the service
redirectScheme - Rewrite http request to https


#### BasicAuth

```yaml
version: '3'

services:
  traefik:
    # The latest official supported Traefik docker image
    image: traefik:v2.3
    # Enables the Traefik Dashboard and tells Traefik to listen to docker
    # enable --log.level=INFO so we can see what Traefik is doing in the log files
    ports:
      # Exposes port 80 for incomming web requests
      - "80:80"
      - "443:443"
      # The Web UI port http://0.0.0.0:8080 (enabled by --api.insecure=true)
      - "8080:8080"
    volumes:
      # So that Traefik can listen to the Docker events
      - /var/run/docker.sock:/var/run/docker.sock
       # Mounts the Traefik static configuration inside the Traefik container
      - ./traefik.yml:/etc/traefik/traefik.yml

# Add the catapp service
  catapp:
     image: mikesir87/cats:1.0
     labels:
       - "traefik.enable=true"
  # Routers
       - "traefik.http.routers.catapp.rule=Host(`cats.tpeterson.io`)"
       - "traefik.http.routers.catapp.service=catapp"
       - "traefik.http.routers.catapp.entrypoints=web"
       - "traefik.http.routers.catapp.middlewares=test-auth"
  # Services
       - "traefik.http.services.catapp.loadbalancer.server.port=5000"
  # Middleware BasicAuth
       - "traefik.http.middlewares.test-auth.basicauth.users=traefik:$$apr1$$.zPbdVg8$$LcHeyCZElH.JfxkxxlMPI.,user2:$$apr1$$XDrP1Fb1$$SZqSEjvNYW44vgJgI3iEP0"
       # user1: traefik password: training
       # user2: user2 password: test123
       # Create hash password -> echo $(htpasswd -nb user2 test123) | sed -e s/\\$/\\$\\$/g
```

### Compress

Simple, just need to add the label

```yaml
labels:
    - "traefik.http.middlewares.test-compress.compress=true" # enable the middleware
    - "traefik.http.routers.catapp.middlewares=test-auth,test-compress" # add it back to the router, very important and names must match!
```

### Error Pages

```yaml
labels:
    - "traefik.http.middlewares.test-errorpages.errors.status=400-599" # takes a range, can have a differnt page for different pages...
    - "traefik.http.middlewares.test-errorpages.errors.service=error"
    - "traefik.http.middlewares.test-errorpages.errors.query=/{status}.html"
    - "traefik.http.routers.catapp.middlewares=test-auth,test-compress,test-errorpages" # make sure you add it to the routers as well... This is important and must match
```

```yaml
version: '3'

services:
  traefik:
    # The latest official supported Traefik docker image
    image: traefik:v2.3
    # Enables the Traefik Dashboard and tells Traefik to listen to docker
    # enable --log.level=INFO so we can see what Traefik is doing in the log files
    ports:
      # Exposes port 80 for incomming web requests
      - "80:80"
      - "443:443"
      # The Web UI port http://0.0.0.0:8080 (enabled by --api.insecure=true)
      - "8080:8080"
    volumes:
      # So that Traefik can listen to the Docker events
      - /var/run/docker.sock:/var/run/docker.sock
       # Mounts the Traefik static configuration inside the Traefik container
      - ./traefik.yml:/etc/traefik/traefik.yml

# Add the catapp service
  catapp:
     image: mikesir87/cats:1.0
     labels:
       - "traefik.enable=true"
  # Routers
       - "traefik.http.routers.catapp.rule=Host(`catapp.localhost`)"
       - "traefik.http.routers.catapp.service=catapp"
       - "traefik.http.routers.catapp.entrypoints=web"
       - "traefik.http.routers.catapp.middlewares=test-auth,test-compress,test-errorpages"
  # Services
       - "traefik.http.services.catapp.loadbalancer.server.port=5000"
  # Middleware BasicAuth
       - "traefik.http.middlewares.test-auth.basicauth.users=traefik:$$apr1$$.zPbdVg8$$LcHeyCZElH.JfxkxxlMPI.,user2:$$apr1$$XDrP1Fb1$$SZqSEjvNYW44vgJgI3iEP0"
       # user1: traefik password: training
       # user2: user2 password: test123
       # Create hash password -> echo $(htpasswd -nb user2 test123) | sed -e s/\\$/\\$\\$/g
  # Compress Middleware
       - "traefik.http.middlewares.test-compress.compress=true"
  # Error Pages Middleware
       - "traefik.http.middlewares.test-errorpages.errors.status=400-599"
       - "traefik.http.middlewares.test-errorpages.errors.service=error"
       - "traefik.http.middlewares.test-errorpages.errors.query=/{status}.html"

# Error Page service
  error:
    image: guillaumebriday/traefik-custom-error-pages
    labels:
        - "traefik.enable=true"
        - "traefik.http.routers.error.rule=Host(`error.localhost`)"
        - "traefik.http.routers.error.service=error"
        - "traefik.http.services.error.loadbalancer.server.port=80"
        - "traefik.http.routers.error.entrypoints=web"

```

### Rate limiting

- Average - Maximum rate, in requests/second for a given source
- Period - Time time period
    - rate = average / period
- sources - Headers, IPs or hosts

```yaml

labels:
    - "traefik.http.middlewares.test-ratelimit.ratelimit.average=2" # enable middleware
    - "traefik.http.routers.catapp.middlewares=test-auth,test-compress,test-errorpages,test-ratelimit" # make sure its added to the routers
```

### Redirect Schemas - http->https

Can be done globally by configuring traefik itself. Here is the full configuration - which has everything else as well.

```yaml
version: '3'

services:
  traefik:
    # The latest official supported Traefik docker image
    image: traefik:v2.3
    # Enables the Traefik Dashboard and tells Traefik to listen to docker
    # enable --log.level=INFO so we can see what Traefik is doing in the log files
    ports:
      # Exposes port 80 for incomming web requests
      - "80:80"
      - "443:443"
      # The Web UI port http://0.0.0.0:8080 (enabled by --api.insecure=true)
      - "8080:8080"
    volumes:
      # So that Traefik can listen to the Docker events
      - /var/run/docker.sock:/var/run/docker.sock
      # Copies the Let's Encrypt certificate locally for ease of backing up
      - ./letsencrypt:/letsencrypt
       # Mounts the Traefik static configuration inside the Traefik container
      - ./traefik.http.yml:/etc/traefik/traefik.yml

# Add the catapp service
  catapp:
     image: mikesir87/cats:1.0
     labels:
       - "traefik.enable=true"
  # Routers
       - "traefik.http.routers.catapp.rule=Host(`cats.tpeterson.io`)"
       - "traefik.http.routers.catapp.entrypoints=web"
       - "traefik.http.routers.catapp.middlewares=test-redirectscheme"
       - "traefik.http.routers.catapp-secure.rule=Host(`cats.tpeterson.io`)"
       - "traefik.http.routers.catapp-secure.entrypoints=websecure"
       - "traefik.http.routers.catapp-secure.tls.certresolver=myresolver"
       - "traefik.http.routers.catapp-secure.middlewares=test-auth,test-compress,test-errorpages,test-ratelimit"
  # Services
       - "traefik.http.services.catapp-secure.loadbalancer.server.port=5000"
  # Middleware BasicAuth
       - "traefik.http.middlewares.test-auth.basicauth.users=traefik:$$apr1$$.zPbdVg8$$LcHeyCZElH.JfxkxxlMPI.,user2:$$apr1$$XDrP1Fb1$$SZqSEjvNYW44vgJgI3iEP0"
       # user1: traefik password: training
       # user2: user2 password: test123
       # Create hash password -> echo $(htpasswd -nb user2 test123) | sed -e s/\\$/\\$\\$/g
  # Compress Middleware
       - "traefik.http.middlewares.test-compress.compress=true"
  # Error Pages Middleware
       - "traefik.http.middlewares.test-errorpages.errors.status=400-599"
       - "traefik.http.middlewares.test-errorpages.errors.service=error"
       - "traefik.http.middlewares.test-errorpages.errors.query=/{status}.html"
  # Rate Limit Middleware
       - "traefik.http.middlewares.test-ratelimit.ratelimit.average=2"
  # Redirect Scheme HTTP -> HTTPS
       - "traefik.http.middlewares.test-redirectscheme.redirectscheme.scheme=https"
       - "traefik.http.middlewares.test-redirectscheme.redirectscheme.permanent=true"

  # Error Page service
  error:
    image: guillaumebriday/traefik-custom-error-pages
    labels:
          - "traefik.enable=true"
          - "traefik.http.routers.error.rule=Host(`errors.tpeterson.io`)"
          - "traefik.http.routers.error.service=error"
          - "traefik.http.services.error.loadbalancer.server.port=80"
          # - traefik.frontend.rule=PathPrefixStrip:/wait
          - "traefik.http.routers.error.entrypoints=web"
```

### Obervability

- Traefik Logs - Configure log level and storage path
    - what is logged - traefik logs everything including start up, configuration, events, shutdowns, service info, etc.
    - Where can I store the logs - with the filePath configuration we determine the location of the logs
    - Log format - change the format of logs. Standard is "common" option is "json"
    - log level - determine the verbosity of logging using level - debug, panic, fatal, error, warn, and info, default is error
- Access logs - who is accessing the services connected to traefik and which service
    - configuration - filepath, format, bufferingSize
    - filtering - log only certain status codes, retry attempts, or minDuration
    - Limiting the fields/include headers - manage what headers to keep, drop, redact
    - log rotation - rotate logs based on USR1 signal
    - time zone, by default, Traefik uses UTC, but this can be changed
- metrics/monitoring - emable metrics for monitoring
- tracing - enable tracing to visulize communication flow
- monioring outputs -
    - alerts - tell a human to take action or something happening or about to happen
    - tickets - tell a human that action is required but not right away
    - logging - stored for diagnostics or forensics
- Operational models
    - Manual - user initiated, interactive, command-line tools, simple scripts, checklist and process driven
    - Reactive - Hardware centric data colletion, simple metric and log collection, silod tools and information, manual analysis and remediation.
    - Proactive - application-centric data collection, end-to-end observability, key metrics and thresholds well understood, semi-automated analysis and remediation
- Users care about 3 things
    - availability - is MY system online
    - Latency  - Does it take a long time to access an application
    - Reliability - Can the user rely on the application

#### Traefik Logs

System logs are managed in the static configuration.

```yaml
################################################################
# Traefik Logging -  DEBUG, PANIC, FATAL, ERROR, WARN, and INFO (DEFAULT is ERROR)
################################################################
# enable system logging
log:
  level: INFO

################################################################
# Access Logging
################################################################
# enable Access logs
accessLog: {}
#Configuring Multiple Filters
# accessLog:
#   filters:    
#     statusCodes:
#       - "404"
#     retryAttempts: true
#     minDuration: "10ms"
```


### Metrics

- Supports
    - DataDog
    - InfluxDB
    - Prometheus
    - StatsD
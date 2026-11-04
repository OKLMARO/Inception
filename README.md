This project has been created as part of the 42 curriculum by oamairi

## Description

Inception is a system administration (DevOps) project that consists of deploying a complete and secure web infrastructure in a virtual machine, using Docker and Docker Compose.

The objective is to build, without using pre-built images, an environment composed of three independent services, each isolated in its own container:

NGINX — single infrastructure entry point, serving the site exclusively in HTTPS (TLSv1.2/1.3) on port 443.

WordPress + PHP-FPM — web application running WordPress, communicating with NGINX via FastCGI and with the database via the internal Docker network.

MariaDB — database management system storing all site content.

Each Docker image is built from a custom Dockerfile, based on a bookworm. Persistent data (site database and files) are kept in named Docker volumes, stored on the host machine in /home/login/data. Sensitive information (passwords, identifiers) is isolated from the rest of the code.

The whole is managed by a Makefile allowing to build, launch and clean the infrastructure in one command.


## Instructions
```
make
make down
make stop
make start
make clean
make fclean
make re
```
## Resources

```
Video Tuto :
https://www.youtube.com/watch?v=SXB6KJ4u5vg
https://www.youtube.com/watch?v=cWkmqZPWwiw
https://www.youtube.com/watch?v=dWcoIxRfs8Y

Doc :
https://www.ibm.com/docs/en/rpa/23.0.x?topic=environment-create-ssl-certificate
https://mariadb.com/docs/server/clients-and-utilities/deployment-tools/mariadb-install-db
https://mariadb.com/docs/server/clients-and-utilities/administrative-tools/mariadb-admin
https://docs.openssl.org/master/man1/openssl-req/
https://manpages.debian.org/experimental/gettext-base/envsubst.1.en.html
https://developer.wordpress.org/cli/commands/core/download/
https://developer.wordpress.org/cli/commands/config/create/
https://developer.wordpress.org/cli/commands/core/is-installed/
https://developer.wordpress.org/cli/commands/core/install/
https://developer.wordpress.org/cli/commands/user/create/
```

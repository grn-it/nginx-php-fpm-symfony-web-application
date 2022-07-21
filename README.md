# Nginx, PHP-FPM, Symfony Web Application

Project contains configured and ready to use Nginx, PHP-FPM, Symfony Web Application split into docker containers.

## How To Use
1. Clone this repository
```bash
git clone https://github.com/grn-it/nginx-php-fpm-symfony-web-application
```

2. Run containers
```bash
docker-compose up -d
```

3. Install Symfony Web Application
```bash
docker-compose exec symfony-web-application make install uid=$(id -u)
```

4. Open in browser ```http://127.0.0.1:8000``` to see installed Symfony Web Application

<br>

## Setting file permissions for reading, writing and executing

Explains how permissions for Nginx, PHP-FPM, Symfony Web Application containers were configured in this project.  
No action required.

### Host and Symfony Web Application
User inside the Symfony Web Application container and on host machine (outside the container) are in most cases different.  
Inside Symfony Web Application container `root` user is used.  
On host machine usually work under home user.  

Once Symfony Web Application is installed, user on host machine will not be able to write files, because they are owned by `root`.  
To solve this problem, [ACL](https://en.wikipedia.org/wiki/Access-control_list) is used, which gives permission to home user of host machine to write files that do not belong to him (because they belong to `root`).

Permissions are granted by these commands:  
```bash
setfacl -dR -m u:$(uid):rwX .
setfacl -R -m u:$(uid):rwX .
```

`$(uid)` is user id that was automatically obtained when running Symfony Web Application install command in step 4.  
After executing this command, home user of host machine will be given permissions to read, write and execute existing and future files located in project directory.

### PHP-FPM and Symfony Web Application
User in Symfony Web Application container is `root`.  
User under which PHP-FPM works is `www-data`.  
User `www-data` needs to give permissions to read, write and execute for `var` directory, in which log and cache files are located.  

Permissions are granted by these commands:
```bash
setfacl -dR -m u:www-data:rwX var
setfacl -R -m u:www-data:rwX var
```

Also need permissions to `public` folder to execute `index.php` and to save files received from user.  
Permissions are granted by these commands:
```bash
setfacl -dR -m u:www-data:rwX public
setfacl -R -m u:www-data:rwX public
```

### Nginx and Symfony Web Application
User running in Symfony Web Application container is `root`.  
User under which Nginx is running is `nginx`.  
`nginx` user only needs read access to files in `public` directory.  By default all users have read permissions for `public` directory, so no additional permissions are required.  

Сommands for setting permissions are located in [Makefile](https://github.com/grn-it/nginx-php-fpm-symfony-web-application/blob/main/Makefile).

More details in Symfony documentation [Setting up or Fixing File Permissions](https://symfony.com/doc/current/setup/file_permissions.html)

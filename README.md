# Nginx, PHP-FPM, Symfony Web Application

The project contains configured and ready to use Nginx, PHP-FPM, Symfony Web Application split into docker containers.

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

## How problem with the rights to read, edit and execute files was solved

### Host and Symfony Web Application
User inside the Symfony Web Application container and on host machine (outside the container) are in most cases different.  
Inside Symfony Web Application container `root` user is used.  
On host machine usually work under home user.  

Once Symfony Web Application is installed user on host machine will not be able to edit files, because they are owned by `root`.  
To solve this problem, [ACL](https://en.wikipedia.org/wiki/Access-control_list) is used, which gives permission to the home user of the host machine to edit files that do not belong to him (because they belong to `root`).

Permission is issued using these commands:  
```bash
setfacl -dR -m u:$(uid):w .
setfacl -R -m u:$(uid):w .
```

`$(uid)` is the user id that was automatically obtained when running the Symfony Web Application install command in step 4.  
After executing this command, home user of host machine will be given permissions to read, edit and execute existing and future files located in project directory.

### PHP-FPM and Symfony Web Application
User in Symfony Web Application container is `root`.  
User under which PHP-FPM works is `www-data`.  
User `www-data` needs to give rights to read, edit and execute for `var` directory, in which log and cache files are located, otherwise there will be a write permission error in this folder and application will not start.  

To solve this problem following commands were executed:
```bash
setfacl -dR -m u:www-data:rwX var
setfacl -R -m u:www-data:rwX var
```

Also in future you may need write permissions to `public` folder to save files received from the user.  
For this, the following commands were executed:
```bash
setfacl -dR -m u:www-data:w public
setfacl -R -m u:www-data:w public
```

### Nginx and Symfony Web Application
User running in Symfony Web Application container is `root`.  
User under which Nginx is running is `nginx`.  
`nginx` user only needs read access to files in `public` directory.  By default all users have read permissions for `public` directory, so no additional permissions are required.  

Permissions editing commands are located in [Makefile](https://github.com/grn-it/nginx-php-fpm-symfony-web-application/blob/main/Makefile).

More details in Symfony documentation [Setting up or Fixing File Permissions](https://symfony.com/doc/current/setup/file_permissions.html)

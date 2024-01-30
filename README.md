# Local Test Site with Docker

This repository is for testing local site without nginx proxy.

## Instructions

Run `setup.sh`: this will create all required file and folders

```bash
bash setup.sh
```

## WordPress Installation

Now go to `http://local-docker-site.test:8080` in your browser. Here is the WordPress config for installation:

```
Database name: wordpress
Username: root
Password: root
Database Host: mysql
```
Geonames database importer (MySQL)
==================================

As it's stated on their [site](http://www.geonames.org/), GeoNames geographical database covers all countries and contains over eight million placenames that are available for download free of charge. This database is available for download free of charge under a creative commons attribution license.

This importer script downloads all the tables available on Geonames.org and imports them into local MySQL database. Also it can be used to keep local database up to date by synchronizing it with Geonames.org. When running with a special option it downloads daily diff's and applies them to current database.


Usage
-----

The basics of this script are quite simple:

```sh
importer.sh [OPTIONS] <action>
```

Where **\<action\>** can be one of the following:

* `config` --- register database parameters (mysql user's password will be prompted to save the file)
* `init` --- initializes local MySQL database
* `import` --- downloads geonames data and imports them into local database
* `update` --- updates database (usually should run daily by cron)
* `empty`--- empty tables

Options are:

* `-u <user>` --- username to access database
* `-h <host>` --- MySQL server address (default: `localhost`)
* `-r <port>` --- MySQL server port (default: `3306`)
* `-n <database>` --- MySQL database name (default: `geonames`)


Examples
--------

To register database parameters;

```sh
importer.sh -u geonames -h localhost config
Enter password: secret
```

To create local database `geonames`:

```sh
importer.sh init
```

To import geonames data into local `geonames` database:

```sh
importer.sh import
```

To apply yesterday's changes in geonames.org to local database `geonames`:

```sh
importer.sh update
```


To flush all geonames tables into local database:

```sh
importer.sh empty
```


License
-------

**Geonames database importer** is Copyright © 2014 Ilya Konyukhov. It is free software and may be redistributed under the terms specified in the [LICENSE](https://github.com/ilkon/geonames-mysql-importer/blob/master/LICENSE) file.

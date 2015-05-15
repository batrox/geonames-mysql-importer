#!/bin/sh
# Bash script for importing geodata from geonames.org to MySQL database


DB_HOST="localhost"
DB_PORT=3306
DB_NAME="geo_geonames"
DB_USERNAME="root"
CONFIG_NAME="geonames-mysql-importer"

BASE_URL="http://download.geonames.org/export/dump"


usage() {
    PN=`basename "$0"`
    echo >&2 "Usage: $PN [OPTIONS] <action>"
    echo >&2 " Where <action>:"
    echo >&2 "    config            Register database parameters (mysql user's password will be prompted to save the file)"
    echo >&2 "    init              Initialize geonames database"
    echo >&2 "    import            Import geonames database"
    echo >&2 "    update            Update database (usually should run daily by cron)"
    echo >&2 "    empty             Empty tables"
    echo >&2 " Config options:"
    echo >&2 "    -u <user>         Username to access database"
    echo >&2 "    -h <host>         MySQL server address (default: $DB_HOST)"
    echo >&2 "    -r <port>         MySQL server port (default: $DB_PORT)"
    echo >&2 "    -n <database>     MySQL database name (default: $DB_NAME)"
    echo >&2 ""

    exit 1
}

checkConfig() {
    if [[ -n $(mysql_config_editor print --login-path=$CONFIG_NAME) ]]; then
        return 1;
    fi

    return 0;
}

config() {
    if [ -z "${DB_USERNAME}" ]; then
        echo 'DB_USERNAME is required'
        exit 1
    fi

    if [ -z "${DB_HOST}" ]; then
        echo 'DB_HOST is required'
        exit 1
    fi

    if [ -z "${DB_PORT}" ]; then
        echo 'DB_PORT is required'
        exit 1
    fi

    mysql_config_editor set --login-path=$CONFIG_NAME --host=$DB_HOST --port=$DB_PORT --user=$DB_USERNAME --password
}

init() {
    echo >&2 "Creating database $DB_NAME..."
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USERNAME" -p"$DB_PASSWORD" -Bse "DROP DATABASE IF EXISTS $DB_NAME;"
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USERNAME" -p"$DB_PASSWORD" -Bse "CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8;"
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USERNAME" -p"$DB_PASSWORD" $DB_NAME < sql/db_schema.sql

    echo >&2 "Done"
    exit 0
}

import() {
    if checkConfig; then
        echo "You have to call 'config' action first to register database parameters"
        exit
    fi

    FILES_TO_DOWNLOAD="admin1CodesASCII.txt admin2Codes.txt allCountries.zip alternateNames.zip countryInfo.txt featureCodes_en.txt hierarchy.zip timeZones.txt"
    FILES_TO_UNZIP="allCountries.zip alternateNames.zip hierarchy.zip"

    TODAY=`date +%F`
    echo >&2 "Creating directory $TODAY..."
    mkdir -p "var/$TODAY"

    cp -v continentCodes.txt "var/$TODAY/"

    cd "var/$TODAY"

    for FILE in $FILES_TO_DOWNLOAD; do
        echo >&2 "Downloading $FILE..."
        wget -c "$BASE_URL/$FILE"
    done
    for FILE in $FILES_TO_UNZIP; do
        echo >&2 "Unzipping $FILE..."
        unzip "$FILE"
    done

    echo >&2 "Importing geonames into database $DB_NAME..."
    mysql --login-path=$CONFIG_NAME --local-infile=1 $DB_NAME < ../../sql/import.sql

    echo >&2 "Adding indexes on the tables in database $DB_NAME..."
    mysql --login-path=$CONFIG_NAME $DB_NAME < ../../sql/add_indexes.sql

    echo >&2 "Done"
    cd ..

    exit 0
}

empty() {
    if checkConfig; then
        echo "You have to call 'config' action first to register database parameters"
        exit
    fi

    echo "Emptying tables"
    mysql --login-path=$CONFIG_NAME $DB_NAME < sql/truncate_tables.sql

}

update() {
    if checkConfig; then
        echo "You have to call 'config' action first to register database parameters"
        exit
    fi

    case $(uname) in
        Darwin|FreeBSD|NetBSD|DragonFLy) YESTERDAY=`date -v -1d +"%Y-%m-%d"` ;;
        *) YESTERDAY=`date --date='1 day ago' +%F` ;;
    esac

    FILES_TO_DOWNLOAD="modifications-$YESTERDAY.txt deletes-$YESTERDAY.txt alternateNamesModifications-$YESTERDAY.txt alternateNamesDeletes-$YESTERDAY.txt"

    TODAY=`date +%F`
    echo >&2 "Creating directory $TODAY..."
    mkdir -p "var/$TODAY" && cd "var/$TODAY"

    for FILE in $FILES_TO_DOWNLOAD; do
        echo >&2 "Downloading $FILE..."
        wget -c "$BASE_URL/$FILE"
    done

    echo >&2 "Deleting old names..."
    cat "deletes-$YESTERDAY.txt" | cut -f1 | while read ID; do
        mysql --login-path=$CONFIG_NAME -Bse "DELETE FROM geo_geoname WHERE id = $ID" $DB_NAME
    done

    echo >&2 "Applying changes to names..."
    cat "modifications-$YESTERDAY.txt" | cut -f1 | while read ID; do
        mysql --login-path=$CONFIG_NAME -Bse "DELETE FROM geo_geoname WHERE id = $ID" $DB_NAME
    done

    echo >&2 "Deleting old alternate names..."
    cat "alternateNamesDeletes-$YESTERDAY.txt" | cut -f1 | while read ID; do
        mysql  --login-path=$CONFIG_NAME -Bse "DELETE FROM geo_alternate_name WHERE id = $ID" $DB_NAME
    done

    echo >&2 "Applying changes to alternate names..."
    cat "alternateNamesModifications-$YESTERDAY.txt" | cut -f1 | while read ID; do
        mysql  --login-path=$CONFIG_NAME -Bse "DELETE FROM geo_alternate_name WHERE id = $ID" $DB_NAME
    done

    mysql  --login-path=$CONFIG_NAME --local-infile=1 -Bse "LOAD DATA LOCAL INFILE 'alternateNamesModifications-$YESTERDAY.txt' INTO TABLE geo_alternate_name CHARACTER SET 'utf8'" $DB_NAME

    echo >&2 "Done"
    cd ..

    exit 0
}

# Main procedure
cd "$( dirname "$0" )"

while getopts "u:p:h:r:n:" opt; do
    case $opt in
        u) DB_USERNAME=$OPTARG ;;
        p) DB_PASSWORD=$OPTARG ;;
        h) DB_HOST=$OPTARG ;;
        r) DB_PORT=$OPTARG ;;
        n) DB_NAME=$OPTARG ;;
        \?) usage ;;            # unknown flag
    esac
done
shift `expr $OPTIND - 1`

if [ $# -eq 1 ]; then
    case $1 in
        init)   init ;;
        import) import ;;
        update) update ;;
        empty) empty ;;
        config) config ;;
        *)      usage ;;        # unknown command
    esac
else
    usage
fi

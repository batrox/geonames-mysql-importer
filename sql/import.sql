SET autocommit=0;
SET unique_checks=0;
SET foreign_key_checks=0;

LOAD DATA LOCAL INFILE 'iso-languagecodes.txt'
INTO TABLE geo_language
CHARACTER SET 'utf8mb4'
IGNORE 1 LINES
(iso_639_3, iso_639_2, code, name);

LOAD DATA LOCAL INFILE 'admin1CodesASCII.txt'
INTO TABLE geo_admin1
CHARACTER SET 'utf8mb4'
(code, name, name_ascii, geoname_id);

LOAD DATA LOCAL INFILE 'admin2Codes.txt'
INTO TABLE geo_admin2
CHARACTER SET 'utf8mb4'
(code, name, name_ascii, geoname_id);

LOAD DATA LOCAL INFILE 'hierarchy.txt'
INTO TABLE geo_hierarchy
CHARACTER SET 'utf8mb4'
(parent_id, child_id, feature_code);

LOAD DATA LOCAL INFILE 'featureCodes_en.txt'
INTO TABLE geo_feature
CHARACTER SET 'utf8mb4'
(code, name, description);

LOAD DATA LOCAL INFILE 'timeZones.txt'
INTO TABLE geo_timezone
CHARACTER SET 'utf8mb4'
IGNORE 1 LINES
(country_code, id, gmt_offset, dst_offset, raw_offset);

LOAD DATA LOCAL INFILE 'countryInfo.txt'
INTO TABLE geo_country
CHARACTER SET 'utf8mb4'
IGNORE 51 LINES
(code, iso_alpha3, iso_numeric, fips_code, name, capital, area, population, continent, tld, currency, currency_name, phone_prefix, postal_code_format, postal_code_regex, languages, geoname_id, neighbours, equivalent_fips_code);

LOAD DATA LOCAL INFILE 'continentCodes.txt'
INTO TABLE geo_continent
CHARACTER SET 'utf8mb4'
FIELDS TERMINATED BY ','
(code, name, geoname_id);

LOAD DATA LOCAL INFILE 'allCountries.txt'
INTO TABLE geo_geoname
CHARACTER SET 'utf8mb4'
(id, name, name_ascii, alternate_names, latitude, longitude, feature_class, feature_code, country, cc2, admin1, admin2, admin3, admin4, population, elevation, gtopo30, timezone, mod_date);

LOAD DATA LOCAL INFILE 'alternateNames.txt'
INTO TABLE geo_alternate_name
CHARACTER SET 'utf8mb4'
(id, geoname_id, language_code, name, is_preferred, is_short, is_colloquial, is_historic);


COMMIT;
SET unique_checks=1;
SET foreign_key_checks=1;

DROP DATABASE IF EXISTS zotero_master;
DROP DATABASE IF EXISTS zotero_shards;
DROP DATABASE IF EXISTS zotero_ids;

CREATE DATABASE zotero_master;
CREATE DATABASE zotero_shards;
CREATE DATABASE zotero_ids;

DROP USER IF EXISTS 'zotero'@'%';

CREATE USER 'zotero'@'%' IDENTIFIED BY 'foobar';

GRANT SELECT, INSERT, UPDATE, DELETE ON zotero_master.* TO 'zotero'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON zotero_shards.* TO 'zotero'@'%';
GRANT SELECT, INSERT, DELETE ON zotero_ids.* TO 'zotero'@'%';

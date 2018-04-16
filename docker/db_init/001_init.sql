DROP DATABASE IF EXISTS zotero_master;
DROP DATABASE IF EXISTS zotero_shards;
DROP DATABASE IF EXISTS zotero_ids;

CREATE DATABASE zotero_master;
CREATE DATABASE zotero_shards;
CREATE DATABASE zotero_ids;

DROP USER zotero@localhost;;

CREATE USER zotero@localhost IDENTIFIED BY 'foobar';;

GRANT SELECT, INSERT, UPDATE, DELETE ON zotero_master.* TO zotero@localhost;;
GRANT SELECT, INSERT, UPDATE, DELETE ON zotero_shards.* TO zotero@localhost;;
GRANT SELECT,INSERT,DELETE ON zotero_ids.* TO zotero@localhost;;

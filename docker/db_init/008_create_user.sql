--GET HashedPassword
--php - $hash = SHA0("sometext" . "password");
--bash - echo -n 'sometextpassword' |sha1sum -
--3004da815ba3e3eaef9ecd8b6b7f76df3a7b9c3b

use zotero_master;
-- SELECT shardID FROM shards ORDER BY items ASC LIMIT 10; 
-- with new db will be 1

INSERT INTO libraries (libraryType, shardID) VALUES ('user',1);
-- returns libraryID 1 

use zotero_shards;

INSERT INTO shardLibraries (libraryID, libraryType) VALUES (1,'user');

use zotero_master;

INSERT INTO users (userID, libraryID, username) VALUES (101, 1, 'jezmckinley');

update users set password='38275779e4145c1454d329aa76e57b44b51350ad' where userid=101;

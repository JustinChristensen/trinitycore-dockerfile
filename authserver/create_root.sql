START TRANSACTION;
INSERT INTO account(id, username, sha_pass_hash) VALUES(1, 'ROOT', '1C824D428CD9D03A7682BD156D172841774DF99F');
INSERT INTO realmcharacters (realmid, acctid, numchars) SELECT realmlist.id, account.id, 0 FROM realmlist, account LEFT JOIN realmcharacters ON acctid = account.id WHERE acctid IS NULL;
INSERT INTO account_access (id, gmlevel, RealmID) VALUES (1, 3, -1);
COMMIT;

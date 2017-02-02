SELECT * FROM NGSTAR_Auth.tbl_lockout;
SELECT * FROM NGSTAR_Auth.password_history;
SELECT * FROM NGSTAR_Auth.users;
SELECT * FROM NGSTAR_Auth.user_password_history;
SELECT * FROM NGSTAR_Auth.role;
SELECT * FROM NGSTAR_Auth.user_role;
SELECT * FROM NGSTAR_Auth.role;

INSERT INTO NGSTAR_Auth.tbl_lockout VALUES (1, 'test01', 0, NULL, NULL);
INSERT INTO NGSTAR_Auth.tbl_lockout VALUES (2, 'test02', 0, NULL, NULL);
INSERT INTO NGSTAR_Auth.tbl_lockout VALUES (3, 'test03', 0, NULL, NULL);

INSERT INTO NGSTAR_Auth.password_history VALUES (1, 'test01', '{CRYPT}$2a$14$2pPCcgR.FuNgRDOIGzMxnuA74QHevh0QWEupYYcghJ9j/bOLVo/Ji', NULL);
INSERT INTO NGSTAR_Auth.password_history VALUES (2, 'test02', '{CRYPT}$2a$14$KNkheDcDPQjeWtdSimHYDOtAyhidsBuk5J5YwBjQthpX4K2kkKARu', NULL);
INSERT INTO NGSTAR_Auth.password_history VALUES (3, 'test03', '{CRYPT}$2a$14$g8bRLOGc/xJLaTrvzznI3uU78h7HcGBKaf8ZWUWSrI9BvCIa12etO', NULL);

INSERT INTO NGSTAR_Auth.users VALUES (1, 'test01', 'Mypass1!', 't01@na.com', 'Joe',  'Doe', 1, 'Test', 'Test', 'Test',NULL,0, 1);
INSERT INTO NGSTAR_Auth.users VALUES (2, 'test02', 'Mypass2!', 't02@na.com', 'Jane', 'Doe', 1, 'Test', 'Test', 'Test',NULL,0, 2);
INSERT INTO NGSTAR_Auth.users VALUES (3, 'test03', 'Mypass3!', 't03@na.com', 'James','Doe', 0, 'Test', 'Test', 'Test',NULL,0, 3);

INSERT INTO NGSTAR_Auth.user_password_history VALUES (1, 1);
INSERT INTO NGSTAR_Auth.user_password_history VALUES (2, 2);
INSERT INTO NGSTAR_Auth.user_password_history VALUES (3, 3);

INSERT INTO NGSTAR_Auth.role VALUES (0, 'none');
INSERT INTO NGSTAR_Auth.role VALUES (1, 'user');
INSERT INTO NGSTAR_Auth.role VALUES (2, 'admin');
INSERT INTO NGSTAR_Auth.user_role VALUES (1, 2);
INSERT INTO NGSTAR_Auth.user_role VALUES (2, 1);
INSERT INTO NGSTAR_Auth.user_role VALUES (3, 0);

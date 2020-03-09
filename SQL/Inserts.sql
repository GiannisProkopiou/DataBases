use publishing_house;

insert into newspaper values
("Ta Nea", NULL, "Kostas"),
("Kathimerini", NULL, "Giorgos"),
("Makelio", NULL, "Giannis");

insert into paper values
(NULL, '2019-02-23', default, "Ta Nea", NULL, NULL),
(NULL, '2019-02-23', default, "Kathimerini", NULL, NULL),
(NULL, '2019-04-23', default, "Ta Nea", NULL, NULL),
(NULL, '2019-03-23', default, "Kathimerini", NULL, NULL),
(NULL, '2019-01-23', default, "Makelio", NULL, NULL),
(NULL, '2019-06-23', default, "Ta Nea", NULL, NULL),
(NULL, '2019-07-23', default, "Makelio", NULL, NULL),
(NULL, '2019-05-23', default, "Kathimerini", NULL, NULL),
(NULL, '2019-09-23', default, "Makelio", NULL, NULL);

insert into journalist values
("daminlillard@gmail.com","Damian","Lillard",'2018-06-28', NULL, "Kathimerini", default,  5, "A single sheet in a codex is a leaf, and each side of a leaf is a page."),
("midlet@yahoo.gr","Khris","Middleton",'2017-02-24',NULL,"Kathimerini", 'Editor_In_Chief', 3, "A book is a medium for recording"),
("harrisbar@hotmail.com","Harrison","Barnes",'2019-09-09',NULL,"Kathimerini", default,  8, "As an intellectual object, a book is prototypically a composition "),
("ibakserge@gmail.com","Serge","Ibaka",'2019-03-20',NULL,"Kathimerini", default, 2, "and a still considerable, though not so extensive, investment of time to read."),
("terryroz@outlook.com","Terry","Rozier",'2018-01-12',NULL,"Kathimerini", default, 0, "The intellectual content in a physical book need not be a composition"),
("jerlamb@yahoo.gr","Jeremy","Lamb",'2019-12-25',NULL,"Ta Nea", default, 15,"or photographs, or such things as crossword puzzles or cut-out dolls."),
("lowkyl@yahoo.gr","Kyle","Lowry",'2018-11-10',NULL,"Ta Nea", default, 4,"restricted sense, a book is a self-sufficient section"),
("griff19@gmail.com","Blake","Griffin",'2017-12-01',NULL,"Ta Nea", default, 5,"Although in ordinary academic parlance a monograph"),
("lavinj@gmail.com","Jach","Lavin",'2019-02-25',NULL,"Makelio", 'Editor_In_Chief', 3,"books or a book lover is a bibliophile or colloquially,"),
("aldrich@outlook.com","Lamarcus","Aldrich",'2018-10-05',NULL,"Makelio", default, 7,"supports for extended written compositions or records");

insert into administrative values
("gasolm@gmail.com","Marc","Gasol",'2016-11-01',NULL,"Makelio", NULL,  NULL, NULL, NULL),
("barton_will@gmail.com","Will","Barton",'2018-12-04',NULL,"Makelio", NULL,  NULL, NULL, NULL),
("embid33@yahoo.gr","Joel","Embid",'2019-01-12',NULL,"Makelio", NULL,  NULL, NULL, NULL),
("derfav@hotmail.com","Derrick","Favors",'2019-03-23',NULL,"Ta Nea", NULL,  NULL, NULL, NULL),
("balllon@gmail.com","Lonzo","Ball",'2019-06-03',NULL,"Ta Nea", NULL,  NULL, NULL, NULL);

insert into category values
("Political", NULL, NULL),
("Econimics", NULL, NULL),
("Social", NULL, NULL),
("Cosmic", NULL, NULL),
("Sports", NULL, NULL),
("Football", NULL, "Sports"),
("Basketball", NULL, "Sports"),
("Soccer", NULL, "Sports"),
("Internal", NULL, "Political"),
("External", NULL, "Political"),
("Public People", NULL, "Social");

insert into article values
("1111111111","qqqqqqqqqqqqq", 		NULL, 1, NULL, NULL, 3, NULL, NULL),
("2222222222","wwwwwwwwwwwwww", 	NULL, 1, NULL, NULL, 5, NULL, NULL),
("3333333333","rrrrrrrrrrrrrrrr", 	NULL, 1, NULL, NULL, 2, NULL, NULL),
("4444444444","333333333333333333", NULL, 1, NULL, NULL, 6, NULL, NULL),
("5555555555","ffffffffffffff", 	NULL, 1, NULL, NULL, 2, NULL, NULL),
("6666666666","gggggggggggggg", 	NULL, 1, NULL, NULL, 3, NULL, NULL),
("7777777777","vvvvvvvvvvvvvv", 	NULL, 1, NULL, NULL, 1, NULL, NULL),
("8888888888","rrrrrrrrrrrrr", 		NULL, 1, NULL, NULL, 4, NULL, NULL),
("9999999999","nnnnnnnnnnnn", 		NULL, 1, NULL, NULL, 2, NULL, NULL),
("0000000000","mmmmmmmmmmmmmmmmmm", NULL, 1, NULL, NULL, 3, NULL, NULL);

insert into journalist_submit values
("midlet@yahoo.gr","1111111111", NULL),
("midlet@yahoo.gr","2222222222", NULL),
("midlet@yahoo.gr","3333333333", NULL),
("lavinj@gmail.com","4444444444", NULL),
("lavinj@gmail.com","5555555555", NULL),
("lavinj@gmail.com","6666666666", NULL),
("terryroz@outlook.com","7777777777", NULL),
("daminlillard@gmail.com","8888888888", NULL),
("terryroz@outlook.com","9999999999", NULL),
("aldrich@outlook.com","0000000000", NULL);
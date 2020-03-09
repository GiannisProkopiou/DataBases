drop database if exists publishing_house;
create database publishing_house;
use publishing_house;

create table if not exists newspaper(
	newspaper_name varchar(100) default 'unknown' not null,
    newspapers_publishing_frequency enum('Daily', 'Weekly', 'Monthly') null,
    owner varchar(50) default 'unknown' not null,
    primary key (newspaper_name)
);

/*
create table if not exists worker(
	email varchar(50) default 'unknown'  not null,
    name varchar(50) default 'unknown' not null,
    surname varchar(50) default 'unknown' not null,
    date_of_recruitment date not null,
    salary float null,    
    workers_newspaper varchar(100) default 'unknown' not null,
    primary key (email),
    constraint works_on
    foreign key (workers_newspaper) references newspaper(nname)
    on delete cascade on update cascade
);
*/

create table if not exists paper(
	paper_no int not null,
    paper_publish_date datetime not null,
    no_of_pages int default 30 not null,
    paper_newspaper varchar(100) default 'unknown' not null,
    paper_copies int null,
    paper_returned_copies int null,
    primary key (paper_no, paper_newspaper),
    constraint issues 
    foreign key (paper_newspaper) references newspaper(newspaper_name)
    on delete cascade on update cascade
);

create table if not exists journalist(
	journalists_email varchar(50) default 'unknown'  not null,
    journalists_name varchar(50) default 'unknown' not null,
    journalists_surname varchar(50) default 'unknown' not null,
    journalists_date_of_recruitment date not null,
    journalists_salary float null,    
    journalists_newspaper varchar(100) default 'unknown' not null,
    journalists_position enum('Journalist', 'Editor_In_Chief') default 'Journalist' not null,    
    journalists_work_experience int not null,
    journalists_brief_cv text not null,
    primary key (journalists_email),
    constraint journalist_works_on
    foreign key (journalists_newspaper) references newspaper(newspaper_name)
    on delete cascade on update cascade
);

create table if not exists administrative(
	administratives_email varchar(50) default 'unknown'  not null,
    administratives_name varchar(50) default 'unknown' not null,
    administratives_surname varchar(50) default 'unknown' not null,
    administratives_date_of_recruitment date not null,
    administratives_salary float null,    
    administratives_newspaper varchar(100) default 'unknown' not null,

	administratives_duties enum('Secretary', 'Logistics') null,
    administratives_adress_street varchar(50) default 'unknown'null,
    administratives_adress_no int null,
    administratives_adress_city varchar(50) default 'unknown' null,
    primary key (administratives_email),
    constraint administrative_works_on
    foreign key (administratives_newspaper) references newspaper(newspaper_name)
    on delete cascade on update cascade
);

create table if not exists telephone(
	ad_email varchar(50) default 'unknown' not null,
    ad_telephone char(10) default 'unknown_no' not null, 
    primary key (ad_telephone, ad_email),
    foreign key (ad_email) references administrative(administratives_email)
    on delete cascade on update cascade
);

/*
create table if not exists publisher(
	pub_email varchar(50) default 'unknown' not null,
    primary key (pub_email),
    foreign key (pub_email) references worker(email)
    on delete cascade on update cascade
);
*/

create table if not exists category(
    category_name varchar(100) default 'unknown' not null,
    category_description text null,
    parent_category varchar(100) null,
    primary key (category_name),
    constraint parenting
    foreign key (parent_category) references category(category_name)
    on delete cascade on update cascade
);

create table if not exists article(
	article_path varchar(200) not null,
    article_title text not null,
    article_summary mediumtext null,
    article_paper_no int null,
    article_category varchar(100) null,
    article_state enum('accepted','rejected','to_be_revised') null,
    article_length int not null,
    article_starting_page int null,
    article_date_of_acceptance date null,
    primary key (article_path),
    constraint publish
    foreign key (article_paper_no) references paper(paper_no)
    on delete cascade on update cascade,
    constraint belongs_to_cat
    foreign key (article_category) references category(category_name)
    on delete cascade on update cascade
);

create table if not exists key_word(
	article_keyword_path varchar(200) not null,
    word varchar(50) default 'unknown' not null,
    primary key (article_keyword_path, word),
    foreign key (article_keyword_path) references article(article_path)
    on delete cascade on update cascade
);

create table if not exists journalist_submit(
	sub_email varchar(50) not null,
    sub_article_path varchar(200) not null,
    sub_date datetime null,
    primary key (sub_email, sub_article_path),
    constraint jur_sub
		foreign key (sub_email) references journalist(journalists_email)
		on delete cascade on update cascade,
    constraint art_sub
		foreign key (sub_article_path) references article(article_path)
		on delete cascade on update cascade
);
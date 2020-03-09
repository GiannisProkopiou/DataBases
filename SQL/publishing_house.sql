-- phpMyAdmin SQL Dump
-- version 5.0.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 11, 2020 at 08:26 PM
-- Server version: 10.4.11-MariaDB
-- PHP Version: 7.4.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `publishing_house`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `change_newspaper_frequency` (IN `my_email` VARCHAR(50), IN `newfrequency` VARCHAR(50))  BEGIN

declare newspapertofind varchar(50);

select publishers_newspaper into newspapertofind  from publisher where publishers_email = my_email;
UPDATE newspaper
SET newspapers_publishing_frequency = newfrequency
WHERE newspaper_name = newspapertofind ;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `change_newspaper_name` (IN `my_email` VARCHAR(50), IN `newname` VARCHAR(50))  BEGIN

declare newspapertofind varchar(50);

select publishers_newspaper into newspapertofind  from publisher where publishers_email = my_email;
UPDATE newspaper
SET newspaper_name = newname
WHERE newspaper_name = newspapertofind ;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `change_newspaper_owner` (IN `my_email` VARCHAR(50), IN `newowner` VARCHAR(50))  BEGIN

declare newspapertofind varchar(50);

select publishers_newspaper into newspapertofind  from publisher where publishers_email = my_email;
UPDATE newspaper
SET newspapers_owner = newowner
WHERE newspaper_name = newspapertofind ;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `declare_paper_copies` (IN `my_email` VARCHAR(50), IN `my_number` INT)  BEGIN

declare newspapertofind varchar(50);

select publishers_newspaper into newspapertofind  from publisher where publishers_email = my_email;
UPDATE paper
SET paper_copies = my_number
WHERE paper_newspaper = newspapertofind ;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `declare_paper_returned_copies` (IN `my_number` INT, IN `returned_no` INT, IN `my_email` VARCHAR(50))  BEGIN

declare newspapertofind varchar(50);

select administratives_newspaper into newspapertofind  from administrative where administratives_email = my_email;
UPDATE paper
SET paper_returned_copies = returned_no
WHERE paper_newspaper = newspapertofind and paper_no = my_number ;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `find_spendings` (IN `my_email` VARCHAR(50), IN `start_date` DATE, IN `end_date` DATE, OUT `my_sumtotal` INT)  BEGIN

declare newspapertofind varchar(50);
declare emailtofind varchar(50);
declare datetofind DATE;
declare positiontofind varchar(50);
declare salarytofind int;
declare finishedFlag int;
declare monthsworked int;
declare totalsalary int;
declare salarysum int;

DECLARE journalist_cursor CURSOR FOR 
 select journalists_email,journalists_position,journalists_date_of_recruitment,journalists_salary from journalist where journalists_newspaper = newspapertofind and journalists_date_of_recruitment <= end_date;
 
 DECLARE administrative_cursor CURSOR FOR 
 select administratives_email,administratives_duties,administratives_date_of_recruitment,administratives_salary from administrative where administratives_newspaper = newspapertofind and administratives_date_of_recruitment <= end_date;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET finishedFlag=1;

DROP TABLE IF EXISTS spendings; 
Create table spendings(email varchar(50),position varchar(50),recruitment DATE,salary int,monthsworked int,totalsalary int);

select administratives_newspaper into newspapertofind  from administrative where administratives_email = my_email;

OPEN journalist_cursor;
 
FETCH journalist_cursor INTO emailtofind,positiontofind,datetofind,salarytofind;

OPEN administrative_cursor;
 
SET finishedFlag=0;
 
WHILE (finishedFlag=0) DO
set monthsworked =  month( datetofind - start_date);
set totalsalary = (monthsworked * salarytofind);
INSERT INTO spendings(email,position,recruitment,salary,monthsworked,totalsalary)
    VALUES(emailtofind,positiontofind,datetofind,salarytofind,monthsworked,totalsalary);
FETCH journalist_cursor INTO emailtofind,positiontofind,datetofind,salarytofind;
 END WHILE;
 
CLOSE journalist_cursor; 
SET finishedFlag=0;

FETCH administrative_cursor INTO emailtofind,positiontofind,datetofind,salarytofind;

WHILE (finishedFlag=0) DO
set monthsworked = month( datetofind - start_date);
set totalsalary = (monthsworked * salarytofind);
INSERT INTO spendings (email,position,recruitment,salary,monthsworked,totalsalary)
    VALUES (emailtofind,positiontofind,datetofind,salarytofind,monthsworked,totalsalary);
FETCH administrative_cursor INTO emailtofind,positiontofind,datetofind,salarytofind;
 END WHILE;
 
CLOSE administrative_cursor; 

select sum(totalsalary) from spendings into salarysum;
set my_sumtotal = salarysum;
select * from spendings;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `new_salary` (IN `my_journalist` VARCHAR(50))  begin
	
    declare my_salary float;
	declare experience int;
    declare rec_month int;
    declare rec_year int;
    declare cur_month int;
    declare cur_year int;
    declare cur_date date;
    declare i int;
    
    set my_salary = 650;
    set i = 0;    
    
    select curdate() into cur_date;
    select month(cur_date) into cur_month;
    select year(cur_date) into cur_year;
    
    select journalists_work_experience into experience from journalist where my_journalist = journalists_email;
    select month(journalists_date_of_recruitment) into rec_month from journalist
		where my_journalist = journalists_email;
	select year(journalists_date_of_recruitment) into rec_year from journalist
		where my_journalist = journalists_email;
	
	set experience = experience + ((cur_year - rec_year) * 12) + (cur_month - rec_month);
      
    while (i <= experience) do
        set my_salary = (my_salary * 1.005);
		set i = i + 1;
    end while;
    
    update journalist
		set journalists_salary = my_salary
        where journalists_email = my_journalist;


end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `paper_info` (IN `my_newspaper` VARCHAR(100), `my_paper` INT)  begin

	declare not_found_article int;
    declare my_article varchar(200);
    declare my_length int;
    declare my_number int;
	
	declare articles cursor for
    select article_path from article 
		inner join paper on article.article_paper_no = paper.paper_no
		inner join newspaper on paper_newspaper = newspaper_name
		where article.article_paper_no = my_paper and paper_newspaper = my_newspaper;    
    declare continue handler for not found set not_found_article = 1;

    open articles;
    set not_found_article = 0;

 /*   fetch articles into my_article;*/
    while (not_found_article = 0) do

		select article_title, article_date_of_acceptance from article where article_path = my_article;
        
        select journalists_name, journalists_surname, journalists_email from journalist
			inner join journalist_submit on journalists_email = sub_email
            where journalists_email = sub_email and my_article = sub_article_path;    
               
        fetch articles into my_article;
    end while; 
    
    select sum(article_length) into my_length from article 
		inner join journalist_submit on sub_article_path = article_path
        inner join journalist on journalists_email = sub_email
		where article.article_paper_no = my_paper and journalists_newspaper = my_newspaper;    
        
	select no_of_pages into my_number from paper
		where paper_no = my_paper and paper_newspaper = my_newspaper;
	
    if (my_number - my_length > 1) then
		select 'This Paper is not full!';
	end if;
    
    close articles;
    
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sales` ()  BEGIN

declare p_number int(11);
declare newspaper varchar(50);
declare copies varchar(50);
declare returned varchar(50);
declare finishedFlag int;
declare sales int;

DECLARE paper_cursor CURSOR FOR 
 SELECT paper_no ,paper_newspaper,paper_copies,paper_returned_copies FROM paper;
 
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finishedFlag=1;
 
DROP TABLE IF EXISTS output; 
Create table output(p_number int(11) NOT NULL, newspaper varchar(50), copies varchar(50),returned varchar(50),sales int);

 OPEN paper_cursor;
 
 SET finishedFlag=0;
 
FETCH paper_cursor INTO p_number,newspaper,copies,returned;

WHILE (finishedFlag=0) DO
set sales = copies - returned;
#SELECT p_number,newspaper,copies,returned,sales;
INSERT INTO output (p_number, newspaper, copies,returned,sales)
    VALUES (p_number, newspaper, copies,returned,sales);
FETCH paper_cursor INTO p_number,newspaper,copies,returned;
 END WHILE;
 
CLOSE paper_cursor; 
select * from output;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `administrative`
--

CREATE TABLE `administrative` (
  `administratives_email` varchar(50) NOT NULL DEFAULT 'unknown',
  `administratives_name` varchar(50) NOT NULL DEFAULT 'unknown',
  `administratives_surname` varchar(50) NOT NULL DEFAULT 'unknown',
  `administratives_date_of_recruitment` date NOT NULL,
  `administratives_salary` float DEFAULT NULL,
  `administratives_newspaper` varchar(100) NOT NULL DEFAULT 'unknown',
  `administratives_duties` enum('Secretary','Logistics') DEFAULT NULL,
  `administratives_adress_street` varchar(50) DEFAULT 'unknown',
  `administratives_adress_no` int(11) DEFAULT NULL,
  `administratives_adress_city` varchar(50) DEFAULT 'unknown'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `administrative`
--

INSERT INTO `administrative` (`administratives_email`, `administratives_name`, `administratives_surname`, `administratives_date_of_recruitment`, `administratives_salary`, `administratives_newspaper`, `administratives_duties`, `administratives_adress_street`, `administratives_adress_no`, `administratives_adress_city`) VALUES
('balllon@gmail.com', 'Lonzo', 'Ball', '2019-06-03', 650, 'Ta Nea', NULL, NULL, NULL, NULL),
('barton_will@gmail.com', 'Will', 'Barton', '2018-12-04', 650, 'Makelio', NULL, NULL, NULL, NULL),
('derfav@hotmail.com', 'Derrick', 'Favors', '2019-03-23', 650, 'Ta Nea', NULL, NULL, NULL, NULL),
('embid33@yahoo.gr', 'Joel', 'Embid', '2019-01-12', 650, 'Makelio', NULL, NULL, NULL, NULL),
('gasolm@gmail.com', 'Marc', 'Gasol', '2016-11-01', 650, 'Makelio', NULL, NULL, NULL, NULL);

--
-- Triggers `administrative`
--
DELIMITER $$
CREATE TRIGGER `set_administratives_salary` BEFORE INSERT ON `administrative` FOR EACH ROW begin
	set NEW.administratives_salary = 650;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `article`
--

CREATE TABLE `article` (
  `article_path` varchar(200) NOT NULL,
  `article_title` text NOT NULL,
  `article_summary` mediumtext DEFAULT NULL,
  `article_paper_no` int(11) DEFAULT NULL,
  `article_category` varchar(100) DEFAULT NULL,
  `article_state` enum('accepted','rejected','to_be_revised') DEFAULT NULL,
  `article_length` int(11) NOT NULL,
  `article_starting_page` int(11) DEFAULT NULL,
  `article_date_of_acceptance` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `article`
--

INSERT INTO `article` (`article_path`, `article_title`, `article_summary`, `article_paper_no`, `article_category`, `article_state`, `article_length`, `article_starting_page`, `article_date_of_acceptance`) VALUES
('0000000000', 'mmmmmmmmmmmmmmmmmm', NULL, 1, NULL, 'to_be_revised', 3, NULL, NULL),
('1111111111', 'qqqqqqqqqqqqq', NULL, 1, NULL, 'accepted', 3, NULL, NULL),
('2222222222', 'wwwwwwwwwwwwww', NULL, 1, NULL, 'accepted', 5, NULL, NULL),
('3333333333', 'rrrrrrrrrrrrrrrr', NULL, 1, NULL, 'accepted', 2, NULL, NULL),
('4444444444', '333333333333333333', NULL, 1, NULL, 'accepted', 6, NULL, NULL),
('5555555555', 'ffffffffffffff', NULL, 1, NULL, 'accepted', 2, NULL, NULL),
('6666666666', 'gggggggggggggg', NULL, 1, NULL, 'accepted', 3, NULL, NULL),
('7777777777', 'vvvvvvvvvvvvvv', NULL, 1, NULL, 'to_be_revised', 1, NULL, NULL),
('8888888888', 'rrrrrrrrrrrrr', NULL, 1, NULL, 'to_be_revised', 4, NULL, NULL),
('9999999999', 'nnnnnnnnnnnn', NULL, 1, NULL, 'to_be_revised', 2, NULL, NULL),
('dsadsada', 'Glarakis', 'aasasas', NULL, 'Econimics', 'accepted', 28, NULL, NULL),
('Ταυτότητα.jpg', 'Kalimera Ellada 2', 'aff11111111111111111111111', NULL, 'Econimics', 'to_be_revised', 26, NULL, NULL);

--
-- Triggers `article`
--
DELIMITER $$
CREATE TRIGGER `fit_error` BEFORE UPDATE ON `article` FOR EACH ROW begin
	declare my_pages int;
	declare my_number int;
	declare my_journalist varchar(50);
	declare my_newspaper varchar(100); 
	declare my_paper int;
    
	if(NEW.article_state = "accepted") then
		if (NEW.article_paper_no is not null) then
		
			select journalists_email into my_journalist from journalist
				inner join journalist_submit on journalists_email = sub_email
				where NEW.article_path = sub_article_path;
				
			select journalists_newspaper into my_newspaper from journalist
				where journalists_email = my_journalist;
				
			select article_paper_no into my_paper from article
				where article_path = NEW.article_path;
			
			select sum(article_length) into my_pages from article 
				inner join journalist_submit on sub_article_path = article_path
				inner join journalist on journalists_email = sub_email
				where article.article_paper_no = my_paper and journalists_newspaper = my_newspaper;    
				
			select no_of_pages into my_number from paper
				where paper_no = my_paper and paper_newspaper = my_newspaper;
			
			if (my_pages > my_number) then
				SIGNAL SQLSTATE VALUE '45000'
				SET MESSAGE_TEXT = 'The article does not  fit to this paper!';
			else
				set NEW.article_starting_page = my_pages - NEW.article_length;
			end if;
		end if;
	end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

CREATE TABLE `category` (
  `category_name` varchar(100) NOT NULL DEFAULT 'unknown',
  `category_description` text DEFAULT NULL,
  `parent_category` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `category`
--

INSERT INTO `category` (`category_name`, `category_description`, `parent_category`) VALUES
('Basketball', NULL, 'Sports'),
('Cosmic', NULL, NULL),
('Econimics', NULL, NULL),
('External', NULL, 'Political'),
('Football', NULL, 'Sports'),
('Internal', NULL, 'Political'),
('Political', NULL, NULL),
('Public People', NULL, 'Social'),
('Soccer', NULL, 'Sports'),
('Social', NULL, NULL),
('Sports', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `journalist`
--

CREATE TABLE `journalist` (
  `journalists_email` varchar(50) NOT NULL DEFAULT 'unknown',
  `journalists_name` varchar(50) NOT NULL DEFAULT 'unknown',
  `journalists_surname` varchar(50) NOT NULL DEFAULT 'unknown',
  `journalists_date_of_recruitment` date NOT NULL,
  `journalists_salary` float DEFAULT NULL,
  `journalists_newspaper` varchar(100) NOT NULL DEFAULT 'unknown',
  `journalists_position` enum('Journalist','Editor_In_Chief') NOT NULL DEFAULT 'Journalist',
  `journalists_work_experience` int(11) NOT NULL,
  `journalists_brief_cv` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `journalist`
--

INSERT INTO `journalist` (`journalists_email`, `journalists_name`, `journalists_surname`, `journalists_date_of_recruitment`, `journalists_salary`, `journalists_newspaper`, `journalists_position`, `journalists_work_experience`, `journalists_brief_cv`) VALUES
('aldrich@outlook.com', 'Lamarcus', 'Aldrich', '2018-10-05', 650, 'Makelio', 'Journalist', 7, 'supports for extended written compositions or records'),
('daminlillard@gmail.com', 'Damian', 'Lillard', '2018-06-28', 650, 'Kathimerini', 'Journalist', 5, 'A single sheet in a codex is a leaf, and each side of a leaf is a page.'),
('george@gmail.com', 'George', 'Glarakis', '2020-02-11', 650, 'Kathimerini', 'Editor_In_Chief', 7, 'wggegwege'),
('griff19@gmail.com', 'Blake', 'Griffin', '2017-12-01', 650, 'Ta Nea', 'Journalist', 5, 'Although in ordinary academic parlance a monograph'),
('harrisbar@hotmail.com', 'Harrison', 'Barnes', '2019-09-09', 650, 'Kathimerini', 'Journalist', 8, 'As an intellectual object, a book is prototypically a composition '),
('ibakserge@gmail.com', 'Serge', 'Ibaka', '2019-03-20', 650, 'Kathimerini', 'Journalist', 2, 'and a still considerable, though not so extensive, investment of time to read.'),
('jerlamb@yahoo.gr', 'Jeremy', 'Lamb', '2019-12-25', 650, 'Ta Nea', 'Journalist', 15, 'or photographs, or such things as crossword puzzles or cut-out dolls.'),
('lavinj@gmail.com', 'Jach', 'Lavin', '2019-02-25', 650, 'Makelio', 'Editor_In_Chief', 3, 'books or a book lover is a bibliophile or colloquially,'),
('lowkyl@yahoo.gr', 'Kyle', 'Lowry', '2018-11-10', 650, 'Ta Nea', 'Journalist', 4, 'restricted sense, a book is a self-sufficient section'),
('midlet@yahoo.gr', 'Khris', 'Middleton', '2017-02-24', 650, 'Kathimerini', 'Editor_In_Chief', 3, 'A book is a medium for recording'),
('terryroz@outlook.com', 'Terry', 'Rozier', '2018-01-12', 650, 'Kathimerini', 'Journalist', 0, 'The intellectual content in a physical book need not be a composition');

--
-- Triggers `journalist`
--
DELIMITER $$
CREATE TRIGGER `set_journalists_salary` BEFORE INSERT ON `journalist` FOR EACH ROW begin
	set NEW.journalists_salary = 650;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `journalist_submit`
--

CREATE TABLE `journalist_submit` (
  `sub_email` varchar(50) NOT NULL,
  `sub_article_path` varchar(200) NOT NULL,
  `sub_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `journalist_submit`
--

INSERT INTO `journalist_submit` (`sub_email`, `sub_article_path`, `sub_date`) VALUES
('aldrich@outlook.com', '0000000000', NULL),
('daminlillard@gmail.com', '8888888888', NULL),
('daminlillard@gmail.com', 'dsadsada', '2020-02-11 20:43:37'),
('george@gmail.com', 'Ταυτότητα.jpg', '2020-02-11 21:10:03'),
('lavinj@gmail.com', '4444444444', NULL),
('lavinj@gmail.com', '5555555555', NULL),
('lavinj@gmail.com', '6666666666', NULL),
('midlet@yahoo.gr', '1111111111', NULL),
('midlet@yahoo.gr', '2222222222', NULL),
('midlet@yahoo.gr', '3333333333', NULL),
('midlet@yahoo.gr', 'dsadsada', '2020-02-11 20:43:37'),
('terryroz@outlook.com', '7777777777', NULL),
('terryroz@outlook.com', '9999999999', NULL);

--
-- Triggers `journalist_submit`
--
DELIMITER $$
CREATE TRIGGER `auto_accept` BEFORE INSERT ON `journalist_submit` FOR EACH ROW begin
	declare my_email varchar(50);
    declare my_newspaper varchar(100);
    declare my_position enum('Journalist', 'Editor_In_Chief');
    
	select journalists_email into my_email from journalist
		where NEW.sub_email = journalists_email;
        
	select journalists_position into my_position from journalist
		where journalists_email = my_email;
	
	if (my_position = 'Journalist') then
		update article
			set article_state = 'to_be_revised' 
            where article_path = NEW.sub_article_path;    
	elseif (my_position = 'Editor_In_Chief') then
		update article
			set article_state = 'accepted'
            where article_path = NEW.sub_article_path;    
    end if;

end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `key_word`
--

CREATE TABLE `key_word` (
  `article_keyword_path` varchar(200) NOT NULL,
  `word` varchar(50) NOT NULL DEFAULT 'unknown'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `key_word`
--

INSERT INTO `key_word` (`article_keyword_path`, `word`) VALUES
('dsadsada', 'casdsds'),
('dsadsada', 'fefwef'),
('dsadsada', 'fewfwe'),
('Ταυτότητα.jpg', 'gia'),
('Ταυτότητα.jpg', 'giorgo'),
('Ταυτότητα.jpg', 'lene'),
('Ταυτότητα.jpg', 'me');

-- --------------------------------------------------------

--
-- Table structure for table `newspaper`
--

CREATE TABLE `newspaper` (
  `newspaper_name` varchar(100) NOT NULL DEFAULT 'unknown',
  `newspapers_publishing_frequency` enum('Daily','Weekly','Monthly') DEFAULT NULL,
  `owner` varchar(50) NOT NULL DEFAULT 'unknown'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `newspaper`
--

INSERT INTO `newspaper` (`newspaper_name`, `newspapers_publishing_frequency`, `owner`) VALUES
('Kathimerini', NULL, 'Giorgos'),
('Makelio', NULL, 'Giannis'),
('Ta Nea', NULL, 'Kostas');

-- --------------------------------------------------------

--
-- Table structure for table `output`
--

CREATE TABLE `output` (
  `p_number` int(11) NOT NULL,
  `newspaper` varchar(50) DEFAULT NULL,
  `copies` varchar(50) DEFAULT NULL,
  `returned` varchar(50) DEFAULT NULL,
  `sales` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `output`
--

INSERT INTO `output` (`p_number`, `newspaper`, `copies`, `returned`, `sales`) VALUES
(1, 'Kathimerini', NULL, NULL, NULL),
(1, 'Makelio', NULL, NULL, NULL),
(1, 'Ta Nea', NULL, NULL, NULL),
(2, 'Kathimerini', NULL, NULL, NULL),
(2, 'Makelio', NULL, NULL, NULL),
(2, 'Ta Nea', NULL, NULL, NULL),
(3, 'Makelio', NULL, NULL, NULL),
(3, 'Ta Nea', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `paper`
--

CREATE TABLE `paper` (
  `paper_no` int(11) NOT NULL,
  `paper_publish_date` datetime NOT NULL,
  `no_of_pages` int(11) NOT NULL DEFAULT 30,
  `paper_newspaper` varchar(100) NOT NULL DEFAULT 'unknown',
  `paper_copies` int(11) DEFAULT NULL,
  `paper_returned_copies` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `paper`
--

INSERT INTO `paper` (`paper_no`, `paper_publish_date`, `no_of_pages`, `paper_newspaper`, `paper_copies`, `paper_returned_copies`) VALUES
(1, '2019-02-23 00:00:00', 30, 'Kathimerini', NULL, NULL),
(1, '2019-01-23 00:00:00', 30, 'Makelio', NULL, NULL),
(1, '2019-02-23 00:00:00', 30, 'Ta Nea', NULL, NULL),
(2, '2019-03-23 00:00:00', 30, 'Kathimerini', NULL, NULL),
(2, '2019-07-23 00:00:00', 30, 'Makelio', NULL, NULL),
(2, '2019-04-23 00:00:00', 30, 'Ta Nea', NULL, NULL),
(3, '2019-09-23 00:00:00', 30, 'Makelio', NULL, NULL),
(3, '2019-06-23 00:00:00', 30, 'Ta Nea', NULL, NULL);

--
-- Triggers `paper`
--
DELIMITER $$
CREATE TRIGGER `numbering_pages` BEFORE INSERT ON `paper` FOR EACH ROW begin
	declare num int;
    select count(*) into num from paper 
		where paper_newspaper = NEW.paper_newspaper;
	set NEW.paper_no = num + 1;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `publisher`
--

CREATE TABLE `publisher` (
  `publishers_email` varchar(50) NOT NULL,
  `publishers_name` varchar(50) NOT NULL DEFAULT 'unknown',
  `publishers_surname` varchar(50) NOT NULL DEFAULT 'unknown',
  `publishers_newspaper` varchar(50) NOT NULL DEFAULT 'unknown',
  `publishers_position` varchar(50) NOT NULL DEFAULT 'unknown'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `publisher`
--

INSERT INTO `publisher` (`publishers_email`, `publishers_name`, `publishers_surname`, `publishers_newspaper`, `publishers_position`) VALUES
('thpub@gmail.com', 'ThirdPublisher', 'thridson', 'Espresso', 'Publisher'),
('sdasdsd', 'Glarakis', 'Gkiasas', 'Kathimerini', 'Publisher');

-- --------------------------------------------------------

--
-- Table structure for table `spendings`
--

CREATE TABLE `spendings` (
  `email` varchar(50) DEFAULT NULL,
  `position` varchar(50) DEFAULT NULL,
  `recruitment` date DEFAULT NULL,
  `salary` int(11) DEFAULT NULL,
  `monthsworked` int(11) DEFAULT NULL,
  `totalsalary` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `spendings`
--

INSERT INTO `spendings` (`email`, `position`, `recruitment`, `salary`, `monthsworked`, `totalsalary`) VALUES
('griff19@gmail.com', 'Journalist', '2017-12-01', 650, NULL, NULL),
('jerlamb@yahoo.gr', 'Journalist', '2019-12-25', 650, 10, 6500),
('lowkyl@yahoo.gr', 'Journalist', '2018-11-10', 650, 9, 5850),
('balllon@gmail.com', NULL, '2019-06-03', 650, NULL, NULL),
('derfav@hotmail.com', NULL, '2019-03-23', 650, 1, 650);

-- --------------------------------------------------------

--
-- Table structure for table `telephone`
--

CREATE TABLE `telephone` (
  `ad_email` varchar(50) NOT NULL DEFAULT 'unknown',
  `ad_telephone` char(10) NOT NULL DEFAULT 'unknown_no'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `users_username` varchar(50) NOT NULL DEFAULT 'unknown',
  `users_surname` varchar(50) NOT NULL DEFAULT 'unknown',
  `users_password` varchar(50) NOT NULL,
  `users_email` varchar(50) NOT NULL DEFAULT 'unknown',
  `users_position` text NOT NULL DEFAULT '\'unknown\'',
  `users_newspaper` varchar(50) NOT NULL DEFAULT 'uknown'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`users_username`, `users_surname`, `users_password`, `users_email`, `users_position`, `users_newspaper`) VALUES
('FirstJournalist', 'firstson', 'first', 'firstjou@gmail.com', 'journalist', ''),
('FifthAdmin', 'fifthson', 'fifth', 'fithadmin@gmail.com', 'Administrative', 'Ta Nea'),
('FourthJournalist', 'fourthson', 'fourth', 'fourthjou@gmail.com', 'Journalist', ''),
('SecondAdmin', 'secondson', 'second', 'secadm@gmail.com', '\'unknown\'', ''),
('ThirdPublisher', 'thridson', 'third', 'thpub@gmail.com', '\'unknown\'', ''),
('George', 'Glarakis', '123456', 'george@gmail.com', 'Journalist', 'Kathimerini'),
('Glarakis', 'Gkiasas', '1234', 'sdasdsd', 'Publisher', 'Kathimerini');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `administrative`
--
ALTER TABLE `administrative`
  ADD PRIMARY KEY (`administratives_email`),
  ADD KEY `administrative_works_on` (`administratives_newspaper`);

--
-- Indexes for table `article`
--
ALTER TABLE `article`
  ADD PRIMARY KEY (`article_path`),
  ADD KEY `publish` (`article_paper_no`),
  ADD KEY `belongs_to_cat` (`article_category`);

--
-- Indexes for table `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`category_name`),
  ADD KEY `parenting` (`parent_category`);

--
-- Indexes for table `journalist`
--
ALTER TABLE `journalist`
  ADD PRIMARY KEY (`journalists_email`),
  ADD KEY `journalist_works_on` (`journalists_newspaper`);

--
-- Indexes for table `journalist_submit`
--
ALTER TABLE `journalist_submit`
  ADD PRIMARY KEY (`sub_email`,`sub_article_path`),
  ADD KEY `art_sub` (`sub_article_path`);

--
-- Indexes for table `key_word`
--
ALTER TABLE `key_word`
  ADD PRIMARY KEY (`article_keyword_path`,`word`);

--
-- Indexes for table `newspaper`
--
ALTER TABLE `newspaper`
  ADD PRIMARY KEY (`newspaper_name`);

--
-- Indexes for table `paper`
--
ALTER TABLE `paper`
  ADD PRIMARY KEY (`paper_no`,`paper_newspaper`),
  ADD KEY `issues` (`paper_newspaper`);

--
-- Indexes for table `telephone`
--
ALTER TABLE `telephone`
  ADD PRIMARY KEY (`ad_telephone`,`ad_email`),
  ADD KEY `ad_email` (`ad_email`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `administrative`
--
ALTER TABLE `administrative`
  ADD CONSTRAINT `administrative_works_on` FOREIGN KEY (`administratives_newspaper`) REFERENCES `newspaper` (`newspaper_name`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `article`
--
ALTER TABLE `article`
  ADD CONSTRAINT `belongs_to_cat` FOREIGN KEY (`article_category`) REFERENCES `category` (`category_name`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `publish` FOREIGN KEY (`article_paper_no`) REFERENCES `paper` (`paper_no`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `category`
--
ALTER TABLE `category`
  ADD CONSTRAINT `parenting` FOREIGN KEY (`parent_category`) REFERENCES `category` (`category_name`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `journalist`
--
ALTER TABLE `journalist`
  ADD CONSTRAINT `journalist_works_on` FOREIGN KEY (`journalists_newspaper`) REFERENCES `newspaper` (`newspaper_name`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `journalist_submit`
--
ALTER TABLE `journalist_submit`
  ADD CONSTRAINT `art_sub` FOREIGN KEY (`sub_article_path`) REFERENCES `article` (`article_path`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `jur_sub` FOREIGN KEY (`sub_email`) REFERENCES `journalist` (`journalists_email`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `key_word`
--
ALTER TABLE `key_word`
  ADD CONSTRAINT `key_word_ibfk_1` FOREIGN KEY (`article_keyword_path`) REFERENCES `article` (`article_path`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `paper`
--
ALTER TABLE `paper`
  ADD CONSTRAINT `issues` FOREIGN KEY (`paper_newspaper`) REFERENCES `newspaper` (`newspaper_name`) ON DELETE CASCADE ON UPDATE CASCADE;
  
  ALTER TABLE `users`
  ADD CONSTRAINT `users_journalist` FOREIGN KEY (`users_email`) REFERENCES `journalist` (`journalists_email`) ON DELETE CASCADE ON UPDATE CASCADE;
  
  ALTER TABLE `users`
  ADD CONSTRAINT `user_administartive` FOREIGN KEY (`users_email`) REFERENCES `journalist` (`administratives_email`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `telephone`
--
ALTER TABLE `telephone`
  ADD CONSTRAINT `telephone_ibfk_1` FOREIGN KEY (`ad_email`) REFERENCES `administrative` (`administratives_email`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

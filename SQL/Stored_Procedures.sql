use publishing_house;
drop procedure if exists paper_info;
drop procedure if exists new_salary;
drop trigger if exists set_journalists_salary;
drop trigger if exists set_administratives_salary;
drop trigger if exists auto_accept;
drop trigger if exists fit_error;
drop trigger if exists numbering_pages;

delimiter $

create procedure paper_info(IN my_newspaper varchar(100), my_paper int) 
begin

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
    
end$


create procedure new_salary(IN my_journalist varchar(50))
begin
	
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


end$

create trigger set_journalists_salary
before insert on journalist
for each row
begin
	set NEW.journalists_salary = 650;
end$

create trigger set_administratives_salary
before insert on administrative
for each row
begin
	set NEW.administratives_salary = 650;
end$

create trigger auto_accept
before insert on journalist_submit
for each row 
begin
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

end$ 


create trigger fit_error
before update on article
for each row
begin
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
end$

create trigger numbering_pages
before insert on paper
for each row
begin
	declare num int;
    select count(*) into num from paper 
		where paper_newspaper = NEW.paper_newspaper;
	set NEW.paper_no = num + 1;
end$

delimiter ;


CREATE TABLE FRANCHISE(
    franchise_name varchar2(50),
    CONSTRAINT pk_franchise PRIMARY KEY(franchise_name)
);



CREATE TABLE CUSTOMER(
    customer_id number,
    customer_name varchar2(50),
    CONSTRAINT pk_customer PRIMARY KEY(customer_id)
);

CREATE TABLE BRANCH(
    branch_id number,
    branch_name varchar2(50),
    franchise_name varchar2(50),
    CONSTRAINT pk_branch PRIMARY KEY(branch_id),
    CONSTRAINT fk_branch_franchise FOREIGN KEY(franchise_name) REFERENCES FRANCHISE(franchise_name)
);


CREATE TABLE CHEF(
    chef_id number,
    branch_id number,
    chef_name varchar2(50),
    menu_id number,
    CONSTRAINT pk_chef PRIMARY KEY(chef_id),
    CONSTRAINT fk_chef_branch FOREIGN KEY(branch_id) REFERENCES BRANCH(branch_id),
    CONSTRAINT fk_chef_menu FOREIGN KEY(menu_id) REFERENCES MENU(menu_id),
);


CREATE TABLE MENU(
    menu_id number,
    menu_name varchar2(50),
    cuisine_id number,
    main_ingredients varchar2(100),
    price number,
    calorie_count,
    CONSTRAINT pk_menu PRIMARY KEY(menu_id),
    CONSTRAINT fk_menu_cuisine FOREIGN KEY(cuisine_id) REFERENCES CUISINE(cuisine_id)
);


CREATE TABLE CUISINE(
    cuisine_id number,
    cuisine_name varchar2(50),
    CONSTRAINT pk_cuisine PRIMARY KEY(cuisine_id)
);


CREATE TABLE PREF_CUISINE(
    customer_id number,
    cuisine_id number,,
    CONSTRAINT pk_pref_cuisine PRIMARY KEY(customer_id,cuisine_id)
);


CREATE TABLE RATING(
    rating_id number,
    customer_id number,
    cuisine_id number,
    rating number,
    CONSTRAINT pk_rating PRIMARY KEY(rating_id),
    CONSTRAINT fk_rating_customer FOREIGN KEY(customer_id) REFERENCES CUSTOMER(customer_id),
    CONSTRAINT fk_rating_cuisine FOREIGN KEY(cuisine_id) REFERENCES CUISINE(cuisine_id)
);

CREATE TABLE FRANCHISE_CUSTOMER(
    customer_id number,
    franchise_id number,
    CONSTRAINT pk_franchise_customer PRIMARY KEY(customer_id,menu_id),
     CONSTRAINT fk_franchise_customer_customer FOREIGN KEY(customer_id) REFERENCES CUSTOMER(customer_id),
      CONSTRAINT fk_franchise_customer_franchise FOREIGN KEY(franchise_id) REFERENCES FRANCHISE(franchise_id)
);


CREATE TABLE CHEF_MENU(
    chef_id number,
    menu_id number,
    CONSTRAINT pk_chef_menu PRIMARY KEY(chef_id,menu_id),
     CONSTRAINT fk_chef_menu_chef FOREIGN KEY(chef_id) REFERENCES CHEF(chef_id),
      CONSTRAINT fk_chef_menu_menu FOREIGN KEY(menu_id) REFERENCES MENU(menu_id)
);


CREATE TABLE FRANCHISE_MENU(
    franchise_id number,
    menu_id number,
    CONSTRAINT pk_franchise_menu PRIMARY KEY(franchise_id,menu_id),
     CONSTRAINT fk_franchise_menu_franchise FOREIGN KEY(franchise_id) REFERENCES FRANCHISE(franchise_id),
      CONSTRAINT fk_franchise_menu_menu FOREIGN KEY(menu_id) REFERENCES MENU(menu_id)
);


CREATE TABLE ORDER(
    order_id number,
    customer_id number,
    cuisine_id number,
    CONSTRAINT pk_order PRIMARY KEY(order_id),
    CONSTRAINT fk_customer_order FOREIGN KEY(customer_id) REFERENCES CUSTOMER(customer_id),
    CONSTRAINT fk_order_cuisine FOREIGN KEY(cuisine_id) REFERENCES CUISINE(cuisine_id)
);





select count(*), franchise_name from FRANCHISE
GROUP BY franchise_name;


select avg(rating), cuisine_name
from RATING, CUISINE
WHERE RATING.cuisine_id=CUISINE.cuisine_id
GROUP BY cuisine_name;
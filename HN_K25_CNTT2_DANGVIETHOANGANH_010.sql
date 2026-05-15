create database manager;
use manager;

create table Customers(
	customer_id varchar(10) primary key,
    full_name varchar(100) not null,
    phone_number varchar(11) not null unique,
    email varchar(50) not null,
    join_date date not null default(current_date())
);

create table Insurance_Packages(
	package_id varchar(10) primary key,
	package_name varchar(100) not null check(package_name in('Sức khỏe', 'Ô tô', 'Nhân thọ', 'Du lịch', 'Tai nạn')),
    max_limit decimal(10, 2) not null check(max_limit > 0),
    base_premium decimal(10, 2) not null check(base_premium > 0)
);

create table Policies(
	policy_id varchar(10) primary key,
    customer_id varchar(10) not null,
    FOREIGN KEY(customer_id) references Customers(customer_id),
    package_id varchar(10) not null,
    FOREIGN KEY(package_id) references Insurance_Packages(package_id),
    start_date date not null,
    end_date date not null,
    status varchar(20) not null check(status in('Active', 'Expired', 'Cancelled'))
);

create table Claims(
	claim_id varchar(10) primary key,
    policy_id varchar(10) not null,
    FOREIGN KEY(policy_id) references Policies(policy_id),
    claim_date date not null default(current_date()),
    claim_amount decimal(10, 2) not null check(claim_amount > 0),
     status varchar(20) not null check(status in('Pending','Approved','Rejected'))
);

create table Claim_Processing_Log(
	log_id varchar(10) primary key,
    claim_id varchar(10) not null,
    FOREIGN KEY(claim_id) references Claims(claim_id),
    action_detail text not null,
    recorded_at datetime not null default(CURRENT_TIMESTAMP())
);

-- 1.2: Insert

insert into Customers(customer_id, full_name, phone_number, email, join_date)
values
	('C001', 'Nguyen Hoang Long', '0901112223', 'long.nh@gmail.com', '2024-01-15'),
 	('C002', 'Tran Thi Kim Anh', '0988877766', 'anh.tk@yahoo.com', '2024-03-10'),
	('C003', 'Le Hoang Nam', '0903334445', 'nam.lh@outlook.com', '2025-05-20'),
	('C004', 'Pham Minh Duc', '0355556667', 'duc.pm@gmail.com', '2025-08-12'),
	('C005', 'Hoang Thu Thao', '0779998881', 'thao.ht@gmail.com', '2026-01-01');
    
inse
   


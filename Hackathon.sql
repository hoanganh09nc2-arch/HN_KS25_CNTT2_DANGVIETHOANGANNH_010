CREATE DATABASE  Insurance;
USE Insurance;

CREATE TABLE Customers (
	customer_id VARCHAR(10) PRIMARY KEY,
	full_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(10) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    join_date DATE NOT NULL DEFAULT (CURRENT_DATE)
);

CREATE TABLE  Insurance_Packages (
	package_id VARCHAR(10) PRIMARY KEY,
    package_name VARCHAR(100) NOT NULL,
    max_limit DECIMAL(12,2) NOT NULL CHECK (max_limit > 0),
    base_premium DECIMAL(12,2) NOT NULL CHECK (base_premium > 0)
);

CREATE TABLE Policies  (
	policy_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10) NOT NULL,
    package_id VARCHAR(10) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(50) CHECK(status IN ('Active', 'Expired', 'Cancelled')),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (package_id) REFERENCES Insurance_Packages(package_id)
);

CREATE TABLE Claims (
	claim_id VARCHAR(10) PRIMARY KEY,
    policy_id VARCHAR(10) NOT NULL,
    claim_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    claim_amount DECIMAL(12,2)  NOT NULL CHECK (claim_amount > 0),
    status VARCHAR(50) NOT NULL CHECK (status IN ('Pending', 'Approved', 'Rejected')) DEFAULT 'Pending',
    FOREIGN KEY (policy_id) REFERENCES Policies(policy_id)
);

CREATE TABLE  Claim_Processing_Log (
	log_id VARCHAR(10) PRIMARY KEY,
    claim_id VARCHAR(10) NOT NULL,
    action_detail TEXT NOT NULL,
    recorded_at DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    processor VARCHAR(30) NOT NULL,
    FOREIGN KEY (claim_id) REFERENCES Claims(claim_id)
);

INSERT INTO Customers
VALUE
	('C001','Nguyen Hoang Long','0901112223','long.nh@gmail.com','2024-01-15'),
    ('C002','Tran Thi Kim Anh','0988877766','anh.tk@yahoo.com','2024-03-10'),
    ('C003','Le Hoang Nam','0903334445','nam.lh@outlook.com','2025-05-20'),
    ('C004','Pham Minh Duc','0355556667','duc.pm@gmail.com','2025-08-12'),
    ('C005','Hoang Thu Thao','0779998881','thao.ht@gmail.com','2026-01-01');
    
    
INSERT INTO Insurance_Packages
VALUE
	('PKG01','Bảo hiểm Sức khỏe Gold',500000000,5000000),
    ('PKG02','Bảo hiểm Ô tô Liberty',1000000000,15000000),
    ('PKG03','Bảo hiểm Nhân thọ An Bình',2000000000,25000000),
    ('PKG04','Bảo hiểm Du lịch Quốc tế',100000000,1000000),
    ('PKG05','Bảo hiểm Tai nạn 24/7',200000000,2500000);
    
INSERT INTO Policies
VALUE
	 ('POL101','C001','PKG01','2024-01-15','2025-01-15','Expired'),
     ('POL102','C002','PKG02','2024-03-10','2026-03-10','Active'),
     ('POL103','C003','PKG03','2025-05-20','2035-05-20','Active'),
     ('POL104','C004','PKG04','2025-08-12','2025-09-12','Expired'),
     ('POL105','C005','PKG01','2026-01-01','2027-01-01','Active');
     
INSERT INTO Claims
VALUE
	('CLM901','POL102','2024-06-15',12000000,'Approved'),
    ('CLM902','POL103','2025-10-20',50000000,'Pending'),
    ('CLM903','POL101','2024-11-05',5500000,'Approved'),
    ('CLM904','POL105','2026-01-15',2000000,'Rejected'),
    ('CLM905','POL102','2025-02-10',120000000,'Approved');
    
INSERT INTO Claim_Processing_Log
VALUE
	('L001','CLM901','Đã nhận hồ sơ hiện trường','2024-06-15 09:00','Admin_01'),
    ('L002','CLM901','Chấp nhận bồi thường xe tai nạn','2024-06-20 14:30','Admin_01'),
    ('L003','CLM902','Đang thẩm định hồ sơ bệnh án','2025-10-21 10:00','Admin_02'),
    ('L004','CLM904','Từ chối do lỗi cố ý của khách hàng','2026-01-16 16:00','Admin_03'),
    ('L005','CLM905','Đã thanh toán qua chuyển khoản','2025-02-15 08:30','Accountant_01');

-- CAU 1
UPDATE Insurance_Packages
SET base_premium = base_premium * 1.15
WHERE max_limit > 500000000;

-- CAU 2
DELETE FROM Claim_Processing_Log
WHERE DATE(recorded_at) < '2025-06-20';

-- PHAN 2
-- CAU 1:
SELECT * FROM Policies
WHERE status = 'Active' AND YEAR(end_date) = 2026;

-- CAU 2
SELECT full_name,email FROM Customers
WHERE full_name LIKE '%Hoang%' AND YEAR(join_date) >= 2025;

-- CAU 3
SELECT * FROM Claims
ORDER BY claim_amount DESC
LIMIT 3 OFFSET 1;

-- PHAN 3
-- CAU 1
SELECT c.full_name, ip.package_name, p.start_date, cl.claim_amount 
FROM  Policies p
LEFT JOIN Claims cl ON p.policy_id = cl.policy_id
LEFT JOIN Customers c ON c.customer_id = p.customer_id
LEFT JOIN Insurance_Packages ip ON ip.package_id = p.package_id;

-- CAU 2
SELECT c.full_name,SUM(cl.claim_amount) AS claim_amount
FROM Claims cl
JOIN Policies p ON p.policy_id = cl.policy_id
JOIN Customers c ON c.customer_id = p.customer_id
WHERE cl.status = 'Approved'
GROUP BY c.full_name
HAVING SUM(cl.claim_amount) > 5000000;

-- CAU 3
SELECT ip.package_name, COUNT(p.package_id)
FROM Policies p 
JOIN Insurance_Packages ip ON p.package_id = ip.package_id
GROUP BY (ip.package_name)
ORDER BY COUNT(p.package_id) DESC
LIMIT 1;

-- PHAN 4
-- CAU 1
CREATE INDEX idx_policy_status_date ON Policies (status,start_date);

-- CAU 2
CREATE VIEW vw_customer_summary AS
SELECT c.full_name,COUNT(p.package_id),SUM(ip.base_premium)
FROM Policies p 
JOIN Customers c ON c.customer_id = p.customer_id
JOIN Insurance_Packages ip ON p.package_id = ip.package_id
GROUP BY c.full_name;

-- PHAN 5
-- CAU 1
DELIMITER //
CREATE TRIGGER trg_after_claim_approved
AFTER UPDATE ON Claim_Processing_Log FOR EACH ROW
BEGIN
	IF status = 'Approved' THEN 
    INSERT INTO Claim_Processing_Log (log_id,claim_id,action_detail,recorded_at,processor)
    VALUE
		(NEW.log_id,claim_id,'Payment processed to customer',NEW.recorded_at,NEW.processor);
        END IF;

END //
DELIMITER ;
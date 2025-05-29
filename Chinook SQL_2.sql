-- DROP TABLES IF THEY ALREADY EXIST
DROP TABLE IF EXISTS PlaylistTrack, InvoiceLine, Invoice, Customer, Employee, Track, Playlist, MediaType, Genre, Album, Artist;
-- CREATE TABLE: Artist
CREATE TABLE Artist (
    ArtistId INT PRIMARY KEY,
    Name VARCHAR(120)
);
-- CREATE TABLE: Album
CREATE TABLE Album (
    AlbumId INT PRIMARY KEY,
    Title VARCHAR(160),
    ArtistId INT,
    FOREIGN KEY (ArtistId) REFERENCES Artist(ArtistId)
);
-- CREATE TABLE: Customer
CREATE TABLE Customer (
    CustomerId INT PRIMARY KEY,
    FirstName VARCHAR(40),
    LastName VARCHAR(40),
    Company VARCHAR(80),
    Address VARCHAR(70),
    City VARCHAR(40),
    State VARCHAR(40),
    Country VARCHAR(40),
    PostalCode VARCHAR(10),
    Phone VARCHAR(24),
    Fax VARCHAR(24),
    Email VARCHAR(60),
    SupportRepId INT
);
-- CREATE TABLE: Employee
CREATE TABLE Employee (
    EmployeeId INT PRIMARY KEY,
    LastName VARCHAR(20),
    FirstName VARCHAR(20),
    Title VARCHAR(30),
    ReportsTo INT,
    BirthDate DATETIME,
    HireDate DATETIME,
    Address VARCHAR(70),
    City VARCHAR(40),
    State VARCHAR(40),
    Country VARCHAR(40),
    PostalCode VARCHAR(10),
    Phone VARCHAR(24),
    Fax VARCHAR(24),
    Email VARCHAR(60)
);
-- CREATE TABLE: Genre
CREATE TABLE Genre (
    GenreId INT PRIMARY KEY,
    Name VARCHAR(120)
);
-- CREATE TABLE: Invoice
CREATE TABLE Invoice (
    InvoiceId INT PRIMARY KEY,
    CustomerId INT,
    InvoiceDate DATETIME,
    BillingAddress VARCHAR(70),
    BillingCity VARCHAR(40),
    BillingState VARCHAR(40),
    BillingCountry VARCHAR(40),
    BillingPostalCode VARCHAR(10),
    Total DECIMAL(10,2)
);
-- CREATE TABLE: InvoiceLine
CREATE TABLE InvoiceLine (
    InvoiceLineId INT PRIMARY KEY,
    InvoiceId INT,
    TrackId INT,
    UnitPrice DECIMAL(10,2),
    Quantity INT
);
-- CREATE TABLE: MediaType
CREATE TABLE MediaType (
    MediaTypeId INT PRIMARY KEY,
    Name VARCHAR(120)
);
-- CREATE TABLE: Playlist
CREATE TABLE Playlist (
    PlaylistId INT PRIMARY KEY,
    Name VARCHAR(120)
);
-- CREATE TABLE: PlaylistTrack (Many-to-Many Relationship)
CREATE TABLE PlaylistTrack (
    PlaylistId INT,
    TrackId INT,
    PRIMARY KEY (PlaylistId, TrackId)
);
-- CREATE TABLE: Track
CREATE TABLE Track (
    TrackId INT PRIMARY KEY,
    Name VARCHAR(200),
    AlbumId INT,
    MediaTypeId INT,
    GenreId INT,
    Composer VARCHAR(220),
    Milliseconds INT,
    Bytes INT,
    UnitPrice DECIMAL(10,2)
);
-- NOTE: Make sure your CSV files are placed in MySQL's secure folder:
LOAD DATA INFILE '/var/lib/mysql-files/Artist.csv'
INTO TABLE Artist
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
                            
LOAD DATA INFILE '/var/lib/mysql-files/Album.csv'
INTO TABLE Album
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/var/lib/mysql-files/Customer.csv'
INTO TABLE Customer
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/var/lib/mysql-files/Employee.csv'
INTO TABLE Employee
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/var/lib/mysql-files/Genre.csv'
INTO TABLE Genre
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/var/lib/mysql-files/Invoice.csv'
INTO TABLE Invoice
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/var/lib/mysql-files/InvoiceLine.csv'
INTO TABLE InvoiceLine
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/var/lib/mysql-files/MediaType.csv'
INTO TABLE MediaType
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/var/lib/mysql-files/Playlist.csv'
INTO TABLE Playlist
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/var/lib/mysql-files/PlaylistTrack.csv'
INTO TABLE PlaylistTrack
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/var/lib/mysql-files/Track.csv'
INTO TABLE Track
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
  -- KPI :
  # Total Revenue Generated
  SELECT 
    ROUND(SUM(Total), 2) AS Total_Revenue
FROM Invoice;
     # Top 5 Customers by Revenue
     SELECT 
    c.CustomerId,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    ROUND(SUM(i.Total), 2) AS Revenue
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
ORDER BY Revenue DESC
LIMIT 5;
    # Top 5 Selling Tracks
    SELECT 
    t.TrackId,
    t.Name AS TrackName,
    SUM(il.Quantity) AS TotalSold
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
GROUP BY t.TrackId
ORDER BY TotalSold DESC
LIMIT 5;
       # Most Popular Genre by Total Tracks Sold
       SELECT 
    g.Name AS Genre,
    SUM(il.Quantity) AS TotalSold
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.GenreId
ORDER BY TotalSold DESC
LIMIT 1;
    # Employee Performance - Revenue by Sales Rep
       SELECT 
    e.EmployeeId,
    CONCAT(e.FirstName, ' ', e.LastName) AS SalesRep,
    ROUND(SUM(i.Total), 2) AS TotalRevenue
FROM Employee e
JOIN Customer c ON e.EmployeeId = c.SupportRepId
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY e.EmployeeId
ORDER BY TotalRevenue DESC;
  # Revenue by Country 
  SELECT 
    BillingCountry,
    ROUND(SUM(Total), 2) AS Revenue
FROM Invoice
GROUP BY BillingCountry
ORDER BY Revenue DESC;
  # Monthly Revenue Trend
  SELECT 
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS Month,
    ROUND(SUM(Total), 2) AS Revenue
FROM Invoice
GROUP BY Month
ORDER BY Month;


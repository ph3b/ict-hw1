CREATE TABLE Medication (
    isBrand tinyint(1),
    manufacturer varchar(100)
);

CREATE TABLE CodeableConcept (
    id int,
    text varchar(100)
)

CREATE TABLE Address (
    id int, # P key
    use  enum('home', 'work', 'temp', 'old'), #h ome | work | temp | old - purpose of this address
    type enum('postal', 'physical', 'both'), # postal | physical | both
    text varchar(100), # Text representation of the address
    line varchar(100), # Street name, number, direction & P.O. Box etc.
    city varchar(100), # Name of city, town etc.
    district varchar(100), # District name (aka county)
    state varchar(100), # Sub-unit of country (abbreviations ok)
    postalCode varchar(100), # Postal code for area
    country varchar(100), # Country (can be ISO 3166 3 letter code)
    start int,
    end int
)

CREATE TABLE ContactPoint (
    system enum('phone', 'fax', 'email', 'page', 'other', # C? phone | fax | email | pager | other
    value varchar(100), # The actual contact point details
    use enum('home', 'work', 'temp', 'old', 'mobile', # home | work | temp | old | mobile - purpose of this contact point
    rank int, # Specify preferred order of use (1 = highest)
    start int,
    end int
)

CREATE TABLE Coding (
    system varchar(100),
    version varchar(100),
    code varchar(100),
    display varchar(100),
    userSelected varchar
)

CREATE TABLE Contact (
    id int, #P Key
    purpose INT,
    name INT, # Foregin key to HumanName(id),
    address INT # Foregin key to Address(id)

)

CREATE TABLE Contact.ContactPoint (
    contact_id INT,
    contactPoint_id INT
)

CREATE TABLE Identifier (
    use enum('usual', 'official', 'temp', 'secondary'), # usual | official | temp | secondary (If known)
    type Int, # Description of identifier - Foreign key CodeableConcept(id)
    system varchar(100), # The namespace for the identifier
    value varchar(100), # The value that is unique
    start int,
    assigner varchar(100)
)

CREATE TABLE HumanName (
    id int,
    _use enum('usual', 'official', 'temp', 'nickname', 'anonymous', 'old', 'maiden'),
    text varchar(50),
    family varchar(50),
    given varchar(50),
    prefix varchar(50),
    suffix varchar(50),
    start int(20),
    end int(20)
)

CREATE TABLE Package (
    id int, # Pkey
    container int # Foreign key CodeableConcept(id)
)

CREATE TABLE Package.content (
    packageId int, #Pkey package
    amount int,
    item int # Fkey medication
)

CREATE TABLE Product (
    id int, # Pkey Medication(id)
    form int, # Fkey CodeableConcept(id)
)

CREATE TABLE Product.ingredient (
    productId int, # Fkey Product(id)
    item int, # Fkey Medication(id),
    amount int
)

CREATE TABLE Product.batch (
    productId int, # Fkey Product(id)
    lotNumber varchar(100),
    expirationDate int
)
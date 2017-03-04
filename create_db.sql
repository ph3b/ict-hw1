CREATE TABLE Medication (
    id int,
    isBrand tinyint(1),
    manufacturer varchar(100),
    Primary key(id)
);

CREATE TABLE CodeableConcept (
    id int,
    text varchar(100),
    Primary key(id)
);

CREATE TABLE `CodeableConcept.coding` (
    codeableConceptId int, # Fkey CodeableConcept
    system varchar(100),
    version varchar(100),
    code varchar(100),
    display varchar(100),
    userSelected varchar(100),
    Foreign key(codeableConceptId) REFERENCES CodeableConcept(id)
);

CREATE TABLE `Medication.package` (
    medicationId int,
    container int, # Foreign key CodeableConcept(id)
    Foreign key(medicationid) references Medication(id),
    Foreign key(container) references CodeableConcept(id)
);

CREATE TABLE `Package.content` (
    packageId int, #Pkey package
    amount int,
    item int, # Fkey medication
    Foreign key(packageId) references `Medication.package`(medicationId)
);

CREATE TABLE `Medication.product` (
    medicationId int,
    id int, # Pkey
    packageId int, # Pkey Medication(id)
    form int, # Fkey CodeableConcept(id)
    Foreign key(medicationId) references Medication(id)
);

CREATE TABLE `Product.ingredient` (
    productId int, # Fkey Product(id)
    item int, # Fkey Medication(id),
    numerator int,
    denominator int,
    Foreign key(productId) references `Medication.product`(medicationId)
);

CREATE TABLE `Product.batch` (
    productId int, # Fkey Product(id)
    lotNumber varchar(100),
    expirationDate int,
    Foreign key(productId) references `Medication.product`(medicationId)
)
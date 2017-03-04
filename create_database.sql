CREATE DATABASE  IF NOT EXISTS `healthict` 
USE `healthict`;

DROP TABLE IF EXISTS `CodeableConcept`;

CREATE TABLE `CodeableConcept` (
  `id` int(11) NOT NULL,
  `text` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `CodeableConceptcoding`;

CREATE TABLE `CodeableConceptcoding` (
  `codeableConceptId` int(11) NOT NULL,
  `system` varchar(100) DEFAULT NULL,
  `version` varchar(100) DEFAULT NULL,
  `code` varchar(100) DEFAULT NULL,
  `display` varchar(100) DEFAULT NULL,
  `userSelected` varchar(100) DEFAULT NULL,
  KEY `codeableconcept_idx` (`codeableConceptId`),
  CONSTRAINT `codeableconcept` FOREIGN KEY (`codeableConceptId`) REFERENCES `CodeableConcept` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

DROP TABLE IF EXISTS `Medication`;
  `id` varchar(100) NOT NULL,
  `isBrand` tinyint(1) DEFAULT NULL,
  `manufacturer` varchar(100) DEFAULT NULL,
  `codeId` int(11) DEFAULT NULL,
  `productId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `MedicationPackage`;
CREATE TABLE `MedicationPackage` (
  `container` int(11) DEFAULT NULL,
  `id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `container_codeable_fk_idx` (`container`),
  CONSTRAINT `container_codeable_fk` FOREIGN KEY (`container`) REFERENCES `CodeableConcept` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

DROP TABLE IF EXISTS `Medicationproduct`;

CREATE TABLE `Medicationproduct` (
  `id` int(11) NOT NULL,
  `form` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `form_codeableconcept_idx` (`form`),
  CONSTRAINT `form_codeableconcept` FOREIGN KEY (`form`) REFERENCES `CodeableConcept` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

DROP TABLE IF EXISTS `PackageContent`;
CREATE TABLE `PackageContent` (
  `packageId` varchar(100) NOT NULL,
  `amount` int(11) DEFAULT NULL,
  `item` varchar(100) DEFAULT NULL,
  `amount_numerator_value` int(11) DEFAULT NULL,
  `amount_numerator_system` varchar(45) DEFAULT NULL,
  `amount_numerator_code` varchar(45) DEFAULT NULL,
  `amount_denominator_value` int(11) DEFAULT NULL,
  `amount_denominator_system` varchar(45) DEFAULT NULL,
  `amount_denominator_code` varchar(45) DEFAULT NULL,
  KEY `packageId` (`packageId`)
);

DROP TABLE IF EXISTS `ProductBatch`;

CREATE TABLE `ProductBatch` (
  `productId` int(11) DEFAULT NULL,
  `lotNumber` varchar(100) DEFAULT NULL,
  `expirationDate` varchar(100) DEFAULT NULL,
  KEY `batch_product_fk` (`productId`),
  CONSTRAINT `batch_product_fk` FOREIGN KEY (`productId`) REFERENCES `Medicationproduct` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS `ProductIngredient`;

CREATE TABLE `ProductIngredient` (
  `productId` int(11) NOT NULL,
  `item` varchar(100) DEFAULT NULL,
  `amount_numerator_value` int(11) DEFAULT NULL,
  `amount_numerator_system` varchar(100) DEFAULT NULL,
  `amount_numerator_code` varchar(45) DEFAULT NULL,
  `amount_denominator_value` varchar(45) DEFAULT NULL,
  `amount_denominator_system` varchar(100) DEFAULT NULL,
  `amount_denominator_code` varchar(45) DEFAULT NULL,
  KEY `productId` (`productId`)
);

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `NGSTAR` DEFAULT CHARACTER SET utf8 ;
USE `NGSTAR` ;

-- -----------------------------------------------------
-- Table `NGSTAR`.`tbl_Loci`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NGSTAR`.`tbl_Loci` ;

CREATE TABLE IF NOT EXISTS `NGSTAR`.`tbl_Loci` (
  `loci_id` INT(11) NOT NULL AUTO_INCREMENT,
  `loci_name` VARCHAR(45) NULL DEFAULT NULL,
  `sequence_length` INT(11) NULL DEFAULT NULL,
  `is_allele_type_int` TINYINT(1) NULL DEFAULT NULL,
  `is_onishi_type` TINYINT(1) NULL DEFAULT NULL,
  PRIMARY KEY (`loci_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 7
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `NGSTAR`.`tbl_Metadata`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NGSTAR`.`tbl_Metadata` ;

CREATE TABLE IF NOT EXISTS `NGSTAR`.`tbl_Metadata` (
  `metadata_id` INT(11) NOT NULL AUTO_INCREMENT,
  `country` VARCHAR(45) NULL DEFAULT NULL,
  `patient_gender` CHAR(1) NULL DEFAULT NULL,
  `patient_age` TINYINT(4) NULL DEFAULT NULL,
  `epi_data` TEXT NULL DEFAULT NULL,
  `beta_lactamase` VARCHAR(45) NULL DEFAULT NULL,
  `curator_comment` TEXT NULL DEFAULT NULL,
  `mics_determined_by` VARCHAR(45) NULL DEFAULT NULL,
  `collection_date` DATE NULL DEFAULT NULL,
  `amr_markers` TEXT NULL,
  PRIMARY KEY (`metadata_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 9588
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `NGSTAR`.`tbl_Allele`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NGSTAR`.`tbl_Allele` ;

CREATE TABLE IF NOT EXISTS `NGSTAR`.`tbl_Allele` (
  `allele_id` INT(11) NOT NULL AUTO_INCREMENT,
  `allele_type` DECIMAL(7,3) NULL DEFAULT NULL,
  `allele_sequence` TEXT NULL DEFAULT NULL,
  `loci_id` INT(11) NOT NULL,
  `metadata_id` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`allele_id`),
  INDEX `fk_tbl_Allele_1_idx` (`loci_id` ASC),
  INDEX `fk_tbl_Allele_tbl_Metadata1_idx` (`metadata_id` ASC),
  CONSTRAINT `fk_tbl_Allele_1`
    FOREIGN KEY (`loci_id`)
    REFERENCES `NGSTAR`.`tbl_Loci` (`loci_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_tbl_Allele_tbl_Metadata1`
    FOREIGN KEY (`metadata_id`)
    REFERENCES `NGSTAR`.`tbl_Metadata` (`metadata_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 8225
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `NGSTAR`.`tbl_SequenceType`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NGSTAR`.`tbl_SequenceType` ;

CREATE TABLE IF NOT EXISTS `NGSTAR`.`tbl_SequenceType` (
  `seq_type_id` INT(11) NOT NULL AUTO_INCREMENT,
  `seq_type_value` INT(11) NULL DEFAULT NULL,
  `metadata_id` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`seq_type_id`),
  UNIQUE INDEX `seq_type_value` (`seq_type_value` ASC),
  INDEX `fk_tbl_SequenceType_tbl_Metadata1_idx` (`metadata_id` ASC),
  CONSTRAINT `fk_tbl_SequenceType_tbl_Metadata1`
    FOREIGN KEY (`metadata_id`)
    REFERENCES `NGSTAR`.`tbl_Metadata` (`metadata_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 945
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `NGSTAR`.`tbl_Allele_SequenceType`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NGSTAR`.`tbl_Allele_SequenceType` ;

CREATE TABLE IF NOT EXISTS `NGSTAR`.`tbl_Allele_SequenceType` (
  `allele_id` INT(11) NOT NULL,
  `seq_type_id` INT(11) NOT NULL,
  PRIMARY KEY (`allele_id`, `seq_type_id`),
  INDEX `fk_tbl_Allele_SequenceType_1_idx` (`allele_id` ASC),
  INDEX `fk_tbl_Allele_SequenceType_2_idx` (`seq_type_id` ASC),
  CONSTRAINT `fk_tbl_Allele_SequenceType_1`
    FOREIGN KEY (`allele_id`)
    REFERENCES `NGSTAR`.`tbl_Allele` (`allele_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_tbl_Allele_SequenceType_2`
    FOREIGN KEY (`seq_type_id`)
    REFERENCES `NGSTAR`.`tbl_SequenceType` (`seq_type_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `NGSTAR`.`tbl_IsolateClassification`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NGSTAR`.`tbl_IsolateClassification` ;

CREATE TABLE IF NOT EXISTS `NGSTAR`.`tbl_IsolateClassification` (
  `classification_id` INT(11) NOT NULL AUTO_INCREMENT,
  `classification_name` VARCHAR(100) NULL DEFAULT NULL,
  `classification_code` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`classification_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 14
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `NGSTAR`.`tbl_Loci_Scheme`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NGSTAR`.`tbl_Loci_Scheme` ;

CREATE TABLE IF NOT EXISTS `NGSTAR`.`tbl_Loci_Scheme` (
  `loci_id` INT(11) NOT NULL,
  `scheme_id` INT(11) NOT NULL,
  PRIMARY KEY (`loci_id`, `scheme_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `NGSTAR`.`tbl_MIC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NGSTAR`.`tbl_MIC` ;

CREATE TABLE IF NOT EXISTS `NGSTAR`.`tbl_MIC` (
  `mic_id` INT(11) NOT NULL AUTO_INCREMENT,
  `antimicrobial_name` VARCHAR(75) NULL DEFAULT NULL,
  PRIMARY KEY (`mic_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 9
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `NGSTAR`.`tbl_Metadata_MIC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NGSTAR`.`tbl_Metadata_MIC` ;

CREATE TABLE IF NOT EXISTS `NGSTAR`.`tbl_Metadata_MIC` (
  `metadata_id` INT(11) NOT NULL,
  `mic_id` INT(11) NOT NULL,
  `mic_comparator` CHAR(2) NULL DEFAULT NULL,
  `mic_value` FLOAT NULL DEFAULT NULL,
  `interpretation_value` TEXT NULL DEFAULT NULL,
  PRIMARY KEY (`metadata_id`, `mic_id`),
  INDEX `fk_tbl_Metadata_MIC_1_idx` (`metadata_id` ASC),
  INDEX `fk_tbl_Metadata_MIC_2_idx` (`mic_id` ASC),
  CONSTRAINT `fk_tbl_Metadata_MIC_1`
    FOREIGN KEY (`metadata_id`)
    REFERENCES `NGSTAR`.`tbl_Metadata` (`metadata_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_tbl_Metadata_MIC_2`
    FOREIGN KEY (`mic_id`)
    REFERENCES `NGSTAR`.`tbl_MIC` (`mic_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `NGSTAR`.`tbl_Scheme`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NGSTAR`.`tbl_Scheme` ;

CREATE TABLE IF NOT EXISTS `NGSTAR`.`tbl_Scheme` (
  `scheme_id` INT(11) NOT NULL AUTO_INCREMENT,
  `scheme_name` VARCHAR(45) NULL DEFAULT NULL,
  `bacterial_species` VARCHAR(75) NULL DEFAULT NULL,
  PRIMARY KEY (`scheme_id`),
  UNIQUE INDEX `scheme_name_UNIQUE` (`scheme_name` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `NGSTAR`.`tbl_Metadata_IsolateClassification`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NGSTAR`.`tbl_Metadata_IsolateClassification` ;

CREATE TABLE IF NOT EXISTS `NGSTAR`.`tbl_Metadata_IsolateClassification` (
  `metadata_id` INT(11) NOT NULL,
  `classification_id` INT(11) NOT NULL,
  PRIMARY KEY (`metadata_id`, `classification_id`),
  INDEX `fk_tbl_Metadata_IsolateClassification_2_idx` (`classification_id` ASC),
  CONSTRAINT `fk_tbl_Metadata_IsolateClassification_1`
    FOREIGN KEY (`metadata_id`)
    REFERENCES `NGSTAR`.`tbl_Metadata` (`metadata_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_tbl_Metadata_IsolateClassification_2`
    FOREIGN KEY (`classification_id`)
    REFERENCES `NGSTAR`.`tbl_IsolateClassification` (`classification_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `NGSTAR`.`tbl_AminoAcidPositions`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NGSTAR`.`tbl_AminoAcidPositions` ;

CREATE TABLE IF NOT EXISTS `NGSTAR`.`tbl_AminoAcidPositions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `loci_id` INT NOT NULL,
  `amino_acid_position` INT NOT NULL,
  `amino_acid_char` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC),
  CONSTRAINT `fk_tbl_AminoAcidPositions_1`
    FOREIGN KEY (`loci_id`)
    REFERENCES `NGSTAR`.`tbl_Loci` (`loci_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `NGSTAR`.`tbl_Onishi`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NGSTAR`.`tbl_Onishi` ;

CREATE TABLE IF NOT EXISTS `NGSTAR`.`tbl_Onishi` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `loci_id` INT NOT NULL,
  `onishi_type` VARCHAR(100) NULL,
  `mosaic` VARCHAR(45) NOT NULL,
  `amino_acid_profile` VARCHAR(83) NULL,
  INDEX `loci_id_idx` (`loci_id` ASC),
  PRIMARY KEY (`id`),
  UNIQUE INDEX `tbl_Onishicol_UNIQUE` (`id` ASC),
  CONSTRAINT `loci_id`
    FOREIGN KEY (`loci_id`)
    REFERENCES `NGSTAR`.`tbl_Loci` (`loci_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


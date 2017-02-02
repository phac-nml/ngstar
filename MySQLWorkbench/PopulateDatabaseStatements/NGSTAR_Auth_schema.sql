SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `NGSTAR_Auth` DEFAULT CHARACTER SET utf8 ;
USE `NGSTAR_Auth` ;

-- -----------------------------------------------------
-- Table `NGSTAR_Auth`.`role`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NGSTAR_Auth`.`role` ;

CREATE TABLE IF NOT EXISTS `NGSTAR_Auth`.`role` (
  `id` INT(11) NOT NULL,
  `role` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `NGSTAR_Auth`.`tbl_lockout`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NGSTAR_Auth`.`tbl_lockout` ;

CREATE TABLE IF NOT EXISTS `NGSTAR_Auth`.`tbl_lockout` (
  `lockout_id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(45) NOT NULL,
  `failed_attempt_count` INT NULL DEFAULT 0,
  `first_failed_attempt_timestamp` DATETIME NULL DEFAULT NULL,
  `lockout_timestamp` DATETIME NULL,
  PRIMARY KEY (`lockout_id`),
  UNIQUE INDEX `username_UNIQUE` (`username` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `NGSTAR_Auth`.`users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NGSTAR_Auth`.`users` ;

CREATE TABLE IF NOT EXISTS `NGSTAR_Auth`.`users` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(45) NOT NULL,
  `password` TEXT NULL DEFAULT NULL,
  `email_address` VARCHAR(45) NOT NULL,
  `first_name` VARCHAR(45) NULL DEFAULT NULL,
  `last_name` VARCHAR(45) NULL DEFAULT NULL,
  `active` TINYINT(1) NULL DEFAULT NULL,
  `institution_name` VARCHAR(45) NULL,
  `institution_city` VARCHAR(45) NULL,
  `institution_country` VARCHAR(45) NULL,
  `time_since_password_change` DATETIME NULL,
  `lockout_status` TINYINT(1) NULL,
  `lockout_id` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `username` (`username` ASC),
  UNIQUE INDEX `email_address_UNIQUE` (`email_address` ASC),
  INDEX `fk_users_1_idx` (`lockout_id` ASC),
  CONSTRAINT `fk_users_1`
    FOREIGN KEY (`lockout_id`)
    REFERENCES `NGSTAR_Auth`.`tbl_lockout` (`lockout_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 8
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `NGSTAR_Auth`.`user_role`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NGSTAR_Auth`.`user_role` ;

CREATE TABLE IF NOT EXISTS `NGSTAR_Auth`.`user_role` (
  `user_id` INT(11) NOT NULL,
  `role_id` INT(11) NOT NULL,
  PRIMARY KEY (`user_id`, `role_id`),
  INDEX `fk_user_role_1_idx` (`user_id` ASC),
  INDEX `fk_user_role_2_idx` (`role_id` ASC),
  CONSTRAINT `fk_user_role_1`
    FOREIGN KEY (`user_id`)
    REFERENCES `NGSTAR_Auth`.`users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_user_role_2`
    FOREIGN KEY (`role_id`)
    REFERENCES `NGSTAR_Auth`.`role` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `NGSTAR_Auth`.`password_reset_requests`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NGSTAR_Auth`.`password_reset_requests` ;

CREATE TABLE IF NOT EXISTS `NGSTAR_Auth`.`password_reset_requests` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `token` TEXT NULL,
  `timestamp` DATETIME NULL,
  `user_id` INT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_password_reset_requests_1_idx` (`user_id` ASC),
  CONSTRAINT `fk_password_reset_requests_1`
    FOREIGN KEY (`user_id`)
    REFERENCES `NGSTAR_Auth`.`users` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `NGSTAR_Auth`.`password_history`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NGSTAR_Auth`.`password_history` ;

CREATE TABLE IF NOT EXISTS `NGSTAR_Auth`.`password_history` (
  `password_history_id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(45) NULL,
  `used_password` TEXT NULL,
  `password_timestamp` DATETIME NULL,
  PRIMARY KEY (`password_history_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `NGSTAR_Auth`.`user_password_history`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NGSTAR_Auth`.`user_password_history` ;

CREATE TABLE IF NOT EXISTS `NGSTAR_Auth`.`user_password_history` (
  `user_id` INT(11) NOT NULL,
  `password_history_id` INT(11) NOT NULL,
  PRIMARY KEY (`user_id`, `password_history_id`),
  INDEX `fk_user_password_history_idx` (`password_history_id` ASC),
  CONSTRAINT `fk_user_password_history`
    FOREIGN KEY (`password_history_id`)
    REFERENCES `NGSTAR_Auth`.`password_history` (`password_history_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `NGSTAR_Auth`.`users` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


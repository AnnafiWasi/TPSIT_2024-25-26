-- ============================================================
-- brawlstars.sql — Struttura del database (vuoto, senza dati)
-- ============================================================

CREATE DATABASE IF NOT EXISTS `brawlstars`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `brawlstars`;

-- --------------------------------------------------------
-- Tabella: brawlers
-- --------------------------------------------------------
CREATE TABLE `brawlers` (
    `id`   INT(10) UNSIGNED NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Tabella: starpowers
-- --------------------------------------------------------
CREATE TABLE `starpowers` (
    `id`         INT(10) UNSIGNED NOT NULL,
    `brawler_id` INT(10) UNSIGNED NOT NULL,
    `name`       VARCHAR(150) NOT NULL,
    PRIMARY KEY (`id`),
    CONSTRAINT `fk_sp_brawler` FOREIGN KEY (`brawler_id`) REFERENCES `brawlers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Tabella: gadgets
-- --------------------------------------------------------
CREATE TABLE `gadgets` (
    `id`         INT(10) UNSIGNED NOT NULL,
    `brawler_id` INT(10) UNSIGNED NOT NULL,
    `name`       VARCHAR(150) NOT NULL,
    PRIMARY KEY (`id`),
    CONSTRAINT `fk_gadget_brawler` FOREIGN KEY (`brawler_id`) REFERENCES `brawlers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Tabella: brawler_build_combination
-- --------------------------------------------------------
CREATE TABLE `brawler_build_combination` (
    `id`          INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `brawler_id`  INT(10) UNSIGNED NOT NULL,
    `starpower_id` INT(10) UNSIGNED DEFAULT NULL,
    `gadget_id`   INT(10) UNSIGNED DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_combo` (`brawler_id`, `starpower_id`, `gadget_id`),
    CONSTRAINT `fk_combo_brawler`   FOREIGN KEY (`brawler_id`)   REFERENCES `brawlers`   (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_combo_starpower` FOREIGN KEY (`starpower_id`) REFERENCES `starpowers` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_combo_gadget`    FOREIGN KEY (`gadget_id`)    REFERENCES `gadgets`    (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Tabella: users (primary key = tag)
-- --------------------------------------------------------
CREATE TABLE `users` (
    `tag`                VARCHAR(20) NOT NULL,
    `name`               VARCHAR(100) NOT NULL,
    `trophies`           INT(10) UNSIGNED NOT NULL DEFAULT 0,
    `highestTrophies`    INT(10) UNSIGNED NOT NULL DEFAULT 0,
    `totalPrestigeLevel` INT(10) UNSIGNED NOT NULL DEFAULT 0,
    `expLevel`           INT(10) UNSIGNED NOT NULL DEFAULT 0,
    `victories_3vs3`     INT(10) UNSIGNED NOT NULL DEFAULT 0,
    `soloVictories`      INT(10) UNSIGNED NOT NULL DEFAULT 0,
    `duoVictories`       INT(10) UNSIGNED NOT NULL DEFAULT 0,
    `club`               VARCHAR(150) DEFAULT NULL,
    `club_tag`           VARCHAR(20)  DEFAULT NULL,
    `last_update`        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `created_at`         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Tabella: user_combination (usa tag al posto di user_id)
-- --------------------------------------------------------
CREATE TABLE `user_combination` (
    `id`             INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_tag`       VARCHAR(20) NOT NULL,
    `combination_id` INT(10) UNSIGNED NOT NULL,
    `saved_at`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_user_combo` (`user_tag`, `combination_id`),
    CONSTRAINT `fk_uc_user`  FOREIGN KEY (`user_tag`)       REFERENCES `users`                    (`tag`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_uc_combo` FOREIGN KEY (`combination_id`) REFERENCES `brawler_build_combination` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Tabella: user_follows (usa tag direttamente)
-- --------------------------------------------------------
CREATE TABLE `user_follows` (
    `id`          INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `my_tag`      VARCHAR(20) NOT NULL,
    `tag_followed` VARCHAR(20) NOT NULL,
    `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_follow` (`my_tag`, `tag_followed`),
    CONSTRAINT `fk_follows_me`       FOREIGN KEY (`my_tag`)       REFERENCES `users` (`tag`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_follows_followed` FOREIGN KEY (`tag_followed`) REFERENCES `users` (`tag`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

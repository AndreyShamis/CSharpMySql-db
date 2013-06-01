/*
Navicat MySQL Data Transfer

Source Server         : 10.0.0.7
Source Server Version : 50161
Source Host           : 10.0.0.7:3306
Source Database       : hw

Target Server Type    : MYSQL
Target Server Version : 50161
File Encoding         : 65001

Date: 2012-08-04 15:47:28
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `tbl_answer`
-- ----------------------------
DROP TABLE IF EXISTS `tbl_answer`;
CREATE TABLE `tbl_answer` (
  `id_answer` int(11) NOT NULL AUTO_INCREMENT,
  `id_subject` text COLLATE utf8_bin NOT NULL,
  `id_data` longtext COLLATE utf8_bin NOT NULL,
  `id_question` int(11) NOT NULL,
  `id_language` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `id_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id_best_answer` tinyint(1) NOT NULL DEFAULT '0',
  `id_date_rank` varchar(30) COLLATE utf8_bin DEFAULT NULL,
  `id_owner_rank` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_answer`,`id_question`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- ----------------------------
-- Table structure for `tbl_answer_rank`
-- ----------------------------
DROP TABLE IF EXISTS `tbl_answer_rank`;
CREATE TABLE `tbl_answer_rank` (
  `id_answer` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `id_question` int(11) NOT NULL,
  PRIMARY KEY (`id_answer`,`id_user`,`id_question`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


-- ----------------------------
-- Table structure for `tbl_best_answer_rank`
-- ----------------------------
DROP TABLE IF EXISTS `tbl_best_answer_rank`;
CREATE TABLE `tbl_best_answer_rank` (
  `id_answer` int(11) NOT NULL,
  `id_rank` tinyint(1) NOT NULL DEFAULT '0',
  `id_question` int(11) NOT NULL,
  PRIMARY KEY (`id_answer`,`id_question`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- ----------------------------
-- Table structure for `tbl_category`
-- ----------------------------
DROP TABLE IF EXISTS `tbl_category`;
CREATE TABLE `tbl_category` (
  `id_category` int(11) NOT NULL,
  `id_name` varchar(100) COLLATE utf8_bin NOT NULL,
  `id_parent` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- ----------------------------
-- Table structure for `tbl_funs`
-- ----------------------------
DROP TABLE IF EXISTS `tbl_funs`;
CREATE TABLE `tbl_funs` (
  `id_self` int(11) NOT NULL,
  `id_other` int(11) NOT NULL,
  PRIMARY KEY (`id_self`,`id_other`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
-- ----------------------------
-- Table structure for `tbl_question`
-- ----------------------------
DROP TABLE IF EXISTS `tbl_question`;
CREATE TABLE `tbl_question` (
  `id_question` int(11) NOT NULL AUTO_INCREMENT,
  `id_subject` text COLLATE utf8_bin NOT NULL,
  `id_data` longtext COLLATE utf8_bin NOT NULL,
  `id_user` int(11) NOT NULL,
  `id_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id_language` int(11) NOT NULL,
  `id_category` int(11) NOT NULL,
  `id_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0 - is open; 5 - is closed-resolved',
  PRIMARY KEY (`id_question`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- ----------------------------
-- Table structure for `tbl_question_rank`
-- ----------------------------
DROP TABLE IF EXISTS `tbl_question_rank`;
CREATE TABLE `tbl_question_rank` (
  `id_question` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `id_date` varchar(30) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id_question`,`id_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- ----------------------------
-- Table structure for `tbl_remark`
-- ----------------------------
DROP TABLE IF EXISTS `tbl_remark`;
CREATE TABLE `tbl_remark` (
  `id_remark` int(11) NOT NULL AUTO_INCREMENT,
  `id_subject` text COLLATE utf8_bin NOT NULL,
  `id_data` longtext COLLATE utf8_bin NOT NULL,
  `id_question` int(11) NOT NULL,
  `id_date` varchar(30) COLLATE utf8_bin NOT NULL,
  `id_language` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  PRIMARY KEY (`id_remark`),
  KEY `id_question` (`id_question`,`id_user`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- ----------------------------
-- Table structure for `tbl_thumb`
-- ----------------------------
DROP TABLE IF EXISTS `tbl_thumb`;
CREATE TABLE `tbl_thumb` (
  `id_answer` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `id_up_down` tinyint(1) NOT NULL DEFAULT '0' COMMENT '1-is up; and 2- is down',
  PRIMARY KEY (`id_answer`,`id_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- ----------------------------
-- Table structure for `tbl_users`
-- ----------------------------
DROP TABLE IF EXISTS `tbl_users`;
CREATE TABLE `tbl_users` (
  `id_user` int(11) NOT NULL AUTO_INCREMENT,
  `id_firstname` varchar(50) COLLATE utf8_bin NOT NULL,
  `id_lastname` varchar(50) COLLATE utf8_bin NOT NULL,
  `id_email` varchar(80) COLLATE utf8_bin NOT NULL,
  `id_score` int(11) NOT NULL DEFAULT '0',
  `id_rank` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_user`)
) ENGINE=InnoDB AUTO_INCREMENT=80090 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

DROP TRIGGER IF EXISTS `update_user_score_on_answer`;
DELIMITER ;;
CREATE TRIGGER `update_user_score_on_answer` AFTER INSERT ON `tbl_answer` FOR EACH ROW BEGIN
   UPDATE `tbl_users` SET id_score=id_score+1   WHERE  tbl_users.id_user=NEW.id_user;
END
;;
DELIMITER ;
DROP TRIGGER IF EXISTS `update_question_status`;
DELIMITER ;;
CREATE TRIGGER `update_question_status` AFTER INSERT ON `tbl_answer_rank` FOR EACH ROW BEGIN

   UPDATE `tbl_question` 
   SET id_status='1' 
   WHERE 
   `tbl_question`.`id_question` 
   =NEW.`id_question`;

END
;;
DELIMITER ;
DROP TRIGGER IF EXISTS `update_user_score_on_question`;
DELIMITER ;;
CREATE TRIGGER `update_user_score_on_question` BEFORE INSERT ON `tbl_question` FOR EACH ROW BEGIN
   UPDATE `tbl_users` SET id_score=id_score+2   WHERE  tbl_users.id_user=NEW.id_user;
END
;;
DELIMITER ;

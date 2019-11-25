CREATE TABLE IF NOT EXISTS `reddit_olap_dwh`.`dim_date` (
  `date_key` int(8) NOT NULL,
  `date` date NOT NULL,
  `day_number` char(12) NOT NULL,
  `month_number` tinyint(3) NOT NULL,
  `year4` smallint(5) NOT NULL,
  `quarter_name` char(2) NOT NULL,
  `quarter_number` tinyint(3) NOT NULL,
  PRIMARY KEY (`date_key`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1
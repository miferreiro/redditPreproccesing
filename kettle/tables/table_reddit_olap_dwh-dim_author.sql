CREATE TABLE IF NOT EXISTS reddit_olap_dwh.`dim_author` (
  `author_key` int(8) NOT NULL AUTO_INCREMENT,
  `author_name` varchar(64) DEFAULT NULL,
  `author_is_employee` boolean DEFAULT NULL,
  `author_pref_show_snoovatar` boolean DEFAULT NULL,
  `author_created` date DEFAULT NULL,
  `author_has_subscribed` boolean DEFAULT NULL,
  `author_hide_from_robots` boolean DEFAULT NULL,
  `author_link_karma` int(8) DEFAULT NULL,
  `author_comment_karma` int(8) DEFAULT NULL,
  `author_is_gold` boolean DEFAULT NULL,
  `author_is_mod` boolean DEFAULT NULL,
  `author_verified` boolean DEFAULT NULL,
  `author_has_verified_email`  boolean DEFAULT NULL,
  `author_over_18`  boolean DEFAULT NULL,
  `author_subscribers` int(8) DEFAULT NULL,
  `author_is_suspended` boolean DEFAULT NULL,
  PRIMARY KEY (`author_key`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=latin1
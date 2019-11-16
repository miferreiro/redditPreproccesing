CREATE TABLE reddit_olap_dwh.`fact_reddit` (
  `comment_key` int(8) NOT NULL,
  `author_key` int(8) NOT NULL,
  `reddit_date_key` int(8) NOT NULL,
  `subreddit_key` int(8) NOT NULL,
  `count_comments` int(8) DEFAULT NULL,
  `reddit_last_update` datetime DEFAULT NULL,
  `reddit_id` int(11) DEFAULT NULL,
  KEY `dim_comment_fact_reddit_fk` (`comment_key`),
  KEY `dim_author_fact_reddit_fk` (`author_key`),
  KEY `dim_date_fact_reddit_fk` (`reddit_date_key`),
  KEY `dim_subreddit_fact_reddit_fk` (`subreddit_key`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1
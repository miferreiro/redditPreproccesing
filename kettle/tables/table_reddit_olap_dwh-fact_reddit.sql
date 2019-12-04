CREATE TABLE IF NOT EXISTS reddit_olap_dwh.`fact_reddit` (
  `date_key` int(8) DEFAULT NULL,
  `comment_key` int(8) NOT NULL,
  `author_key` int(8) NOT NULL,
  `subreddit_key` int(8) NOT NULL,
  `comment_controversiality` int(8) DEFAULT NULL,
  `comment_gilded` int(8) DEFAULT NULL,
  `comment_reply_delay` int(8) DEFAULT NULL,
  `comment_score` int(8) DEFAULT NULL,
  `comment_total_awards_received` int(8) DEFAULT NULL,
  `subreddit_active_user_count` int(8) DEFAULT NULL,
  `subreddit_accounts_active` int(8) DEFAULT NULL,
  `subreddit_subscribers` int(8) DEFAULT NULL,
  `subreddit_comment_score_hide_mins` int(8) DEFAULT NULL,
  `author_link_karma` int(8) DEFAULT NULL,
  `author_comment_karma` int(8) DEFAULT NULL,
  `author_subscribers` int(8) DEFAULT NULL,
  PRIMARY KEY (date_key, comment_key, author_key, subreddit_key),
  FOREIGN KEY (date_key) REFERENCES dim_date(date_key), 
  FOREIGN KEY (comment_key) REFERENCES dim_comment(comment_key),
  FOREIGN KEY (author_key) REFERENCES dim_author(author_key),
  FOREIGN KEY (subreddit_key) REFERENCES dim_subreddit(subreddit_key)	
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
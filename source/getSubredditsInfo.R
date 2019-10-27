non_recs <- function(x)  x[!sapply(x, is.recursive)]
sources <- c("configurations/pkgChecker.R", "util/authentication.R", "util/write_csv.R", "util/read_csv.R", "util/refresh.R")
for (s in sources) suppressMessages(source(s))
if (file.exists(".httr-oauth") &&
    difftime(Sys.time(), file.info(".httr-oauth")$mtime, units = c("mins")) > 60) file.remove(".httr-oauth")

configuration.file <- read.ini("configurations/configurations_subreddits.ini")
subreddits <- c("Fitness", "nutrition", "bodyweightfitness", "homegym",
                "xxfitness", "loseit", "sugarlifestyleforum", "getdisciplined", "ketogains",
                "stopdrinkingfitness", "weightroom", "bodybuilding")
#to get permament token: adds on url &duration=permanent
token <<- authentication(configuration.file$reddit$client.id, configuration.file$reddit$client.secret)
num.max.request <<- 60
num.request <<- 0
num <<- 1
flag <<- Sys.time()
base <- configuration.file$reddit$base
endbase <- configuration.file$reddit$endbase
initial.auth <<- Sys.time()
message("[INFO] Num subreddits to preprocess: ", length(subreddits))

lapply(subreddits, function(subreddit, token) {

  if (difftime(Sys.time(), initial.auth, units = c("mins")) > 59) {
    message(white("[INFO] Refreshing... (", Sys.time(), ")"))
    cred <- refresh(token$endpoint, token$app, token$credentials,
                    token$params$user_params, token$params$use_basic_auth,
                    config_init = token$params$config_init)
    if (is.null(cred)) {
      remove_cached_token(token)
    } else {
      token$credentials <<- cred
      token$cache()
    }
    message(green("[INFO] Refreshing...(", Sys.time(), ")"))
    initial.auth <<- Sys.time()
  }

  response <- httr::GET(paste0(base, subreddit, endbase),
                        add_headers(Authorization = paste("bearer", token$credentials$access_token),
                                    "User-Agent" = "plin21"))
  content <- jsonlite::fromJSON(httr::content(response, as = "text", encoding = "UTF-8"))

  if (length(content$data) == 0) {
    message(red("[ERROR] Imposible obtains data from:", subreddit, "Checking next subreddit"))
    print(httr::content(response, as = "text", encoding = "UTF-8"))
    break
  }

  if (is.null(content$data$user_flair_background_color)) content$data$user_flair_background_color <- NA
  if (is.null(content$data$submit_text_html)) content$data$submit_text_html <- NA
  if (is.null(content$data$header_img)) content$data$header_img <- NA
  if (is.null(content$data$user_flair_template_id)) content$data$user_flair_template_id <- NA
  if (is.null(content$data$header_title)) content$data$header_title <- NA
  if (is.null(content$data$wls)) content$data$wls <- NA
  if (is.null(content$data$link_flair_position)) content$data$link_flair_position <- NA
  if (is.null(content$data$is_enrolled_in_new_modmail)) content$data$is_enrolled_in_new_modmail <- NA
  if (is.null(content$data$submit_text_label)) content$data$submit_text_label <- NA
  if (is.null(content$data$is_crosspostable_subreddit)) content$data$is_crosspostable_subreddit <- NA
  if (is.null(content$data$notification_level)) content$data$notification_level <- NA
  if (is.null(content$data$link_flair_enabled)) content$data$link_flair_enabled <- NA
  if (is.null(content$data$suggested_comment_sort)) content$data$suggested_comment_sort <- NA
  if (is.null(content$data$user_flair_text)) content$data$user_flair_text <- NA
  if (is.null(content$data$submit_link_label)) content$data$submit_link_label <- NA
  if (is.null(content$data$user_flair_text_color)) content$data$user_flair_text_color <- NA
  if (is.null(content$data$user_flair_css_class)) content$data$user_flair_css_class <- NA
  if (is.null(content$data$whitelist_status)) content$data$whitelist_status <- NA
  if (!is.null(content$data$created) &&
      !is.POSIXct(content$data$created)) content$data$created <- lubridate::as_datetime(content$data$created, tz = "CET")
  if (!is.null(content$data$created_utc) &&
      !is.POSIXct(content$data$created_utc)) content$data$created_utc <- lubridate::as_datetime(content$data$created_utc, tz = "CET")

  info.subreddits.data <- data.frame(matrix(ncol = 0, nrow = 0))

  info.subreddits.data[1, "user_flair_background_color"] <- content$data$user_flair_background_color
  info.subreddits.data[1, "submit_text_html"] <- content$data$submit_text_html
  info.subreddits.data[1, "restrict_posting"] <- content$data$restrict_posting
  info.subreddits.data[1, "user_is_banned"] <- content$data$user_is_banned
  info.subreddits.data[1, "free_form_reports"] <- content$data$free_form_reports
  info.subreddits.data[1, "wiki_enabled"] <- content$data$wiki_enabled
  info.subreddits.data[1, "user_is_muted"] <- content$data$user_is_muted
  info.subreddits.data[1, "user_can_flair_in_sr"] <- content$data$user_can_flair_in_sr
  info.subreddits.data[1, "display_name"] <- content$data$display_name
  info.subreddits.data[1, "header_img"] <- content$data$header_img
  info.subreddits.data[1, "title"] <- content$data$title
  info.subreddits.data[1, "primary_color"] <- content$data$primary_color
  info.subreddits.data[1, "active_user_count"] <- content$data$active_user_count
  info.subreddits.data[1, "icon_img"] <- content$data$icon_img
  info.subreddits.data[1, "display_name_prefixed"] <- content$data$display_name_prefixed
  info.subreddits.data[1, "accounts_active"] <- content$data$accounts_active
  info.subreddits.data[1, "public_traffic"] <- content$data$public_traffic
  info.subreddits.data[1, "subscribers"] <- content$data$subscribers
  info.subreddits.data[1, "name"] <- content$data$name
  info.subreddits.data[1, "quarantine"] <- content$data$quarantine
  info.subreddits.data[1, "hide_ads"] <- content$data$hide_ads
  info.subreddits.data[1, "emojis_enabled"] <- content$data$emojis_enabled
  info.subreddits.data[1, "advertiser_category"] <- content$data$advertiser_category
  info.subreddits.data[1, "public_description"] <- content$data$public_description
  info.subreddits.data[1, "comment_score_hide_mins"] <- content$data$comment_score_hide_mins
  info.subreddits.data[1, "user_has_favorited"] <- content$data$user_has_favorited
  info.subreddits.data[1, "user_flair_template_id"] <- content$data$user_flair_template_id
  info.subreddits.data[1, "community_icon"] <- content$data$community_icon
  info.subreddits.data[1, "banner_background_image"] <- content$data$banner_background_image
  info.subreddits.data[1, "original_content_tag_enabled"] <- content$data$original_content_tag_enabled
  info.subreddits.data[1, "submit_text"] <- content$data$submit_text
  info.subreddits.data[1, "description_html"] <- content$data$description_html
  info.subreddits.data[1, "spoilers_enabled"] <- content$data$spoilers_enabled
  info.subreddits.data[1, "header_title"] <- content$data$header_title
  info.subreddits.data[1, "user_flair_position"] <- content$data$user_flair_position
  info.subreddits.data[1, "all_original_content"] <- content$data$all_original_content
  info.subreddits.data[1, "has_menu_widget"] <- content$data$has_menu_widget
  info.subreddits.data[1, "is_enrolled_in_new_modmail"] <- content$data$is_enrolled_in_new_modmail
  info.subreddits.data[1, "key_color"] <- content$data$key_color
  info.subreddits.data[1, "can_assign_user_flair"] <- content$data$can_assign_user_flair
  info.subreddits.data[1, "created"] <- content$data$created
  info.subreddits.data[1, "wls"] <- content$data$wls
  info.subreddits.data[1, "show_media_preview"] <- content$data$show_media_preview
  info.subreddits.data[1, "submission_type"] <- content$data$submission_type
  info.subreddits.data[1, "user_is_subscriber"] <- content$data$user_is_subscriber
  info.subreddits.data[1, "disable_contributor_requests"] <- content$data$disable_contributor_requests
  info.subreddits.data[1, "allow_videogifs"] <- content$data$allow_videogifs
  info.subreddits.data[1, "user_flair_type"] <- content$data$user_flair_type
  info.subreddits.data[1, "collapse_deleted_comments"] <- content$data$collapse_deleted_comments
  info.subreddits.data[1, "public_description_html"] <- content$data$public_description_html
  info.subreddits.data[1, "allow_videos"] <- content$data$allow_videos
  info.subreddits.data[1, "is_crosspostable_subreddit"] <- content$data$is_crosspostable_subreddit
  info.subreddits.data[1, "notification_level"] <- content$data$notification_level
  info.subreddits.data[1, "can_assign_link_flair"] <- content$data$can_assign_link_flair
  info.subreddits.data[1, "accounts_active_is_fuzzed"] <- content$data$accounts_active_is_fuzzed
  info.subreddits.data[1, "submit_text_label"] <- content$data$submit_text_label
  info.subreddits.data[1, "link_flair_position"] <- content$data$link_flair_position
  info.subreddits.data[1, "user_sr_flair_enabled"] <- content$data$user_sr_flair_enabled
  info.subreddits.data[1, "user_flair_enabled_in_sr"] <- content$data$user_flair_enabled_in_sr
  info.subreddits.data[1, "allow_discovery"] <- content$data$allow_discovery
  info.subreddits.data[1, "user_sr_theme_enabled"] <- content$data$user_sr_theme_enabled
  info.subreddits.data[1, "link_flair_enabled"] <- content$data$link_flair_enabled
  info.subreddits.data[1, "subreddit_type"] <- content$data$subreddit_type
  info.subreddits.data[1, "suggested_comment_sort"] <- content$data$suggested_comment_sort
  info.subreddits.data[1, "banner_img"] <- content$data$banner_img
  info.subreddits.data[1, "user_flair_text"] <- content$data$user_flair_text
  info.subreddits.data[1, "banner_background_color"] <- content$data$banner_background_color
  info.subreddits.data[1, "show_media"] <- content$data$show_media
  info.subreddits.data[1, "id"] <- content$data$id
  info.subreddits.data[1, "user_is_moderator"] <- content$data$user_is_moderator
  info.subreddits.data[1, "over18"] <- content$data$over18
  info.subreddits.data[1, "description"] <- content$data$description
  info.subreddits.data[1, "submit_link_label"] <- content$data$submit_link_label
  info.subreddits.data[1, "user_flair_text_color"] <- content$data$user_flair_text_color
  info.subreddits.data[1, "restrict_commenting"] <- content$data$restrict_commenting
  info.subreddits.data[1, "user_flair_css_class"] <- content$data$user_flair_css_class
  info.subreddits.data[1, "allow_images"] <- content$data$allow_images
  info.subreddits.data[1, "lang"] <- content$data$lang
  info.subreddits.data[1, "whitelist_status"] <- content$data$whitelist_status
  info.subreddits.data[1, "url"] <- content$data$url
  info.subreddits.data[1, "created_utc"] <- content$data$created_utc
  info.subreddits.data[1, "mobile_banner_image"] <- content$data$mobile_banner_image
  info.subreddits.data[1, "user_is_contributor"] <- content$data$user_is_contributor

  write_csv(info.subreddits.data,
            file.path("data", "subreddits", paste0("subreddits_info.csv")))


  message("[INFO] Quering (", num, " - ", Sys.time(), ") -> ", paste0(base, subreddit, endbase),
          " to ", file.path("data", "subreddits", paste0("subreddits_info.csv")))
  num <<- num + 1
  num.request <<- num.request + 1
}, token)

# b <- read_csv("data/subreddits/subreddits_info.csv")
# View(b)

refresh <- function(endpoint, app, credentials, user_params = NULL,
                             use_basic_auth = FALSE, config_init) {
  if (is.null(credentials$refresh_token)) {
    stop("Refresh token not available", call. = FALSE)
  }

  refresh_url <- endpoint$access
  req_params <- list(
    refresh_token = credentials$refresh_token,
    client_id = app$key,
    grant_type = "refresh_token"
  )

  if (!is.null(user_params)) {
    req_params <- utils::modifyList(user_params, req_params)
  }

  if (isTRUE(use_basic_auth)) {
    print(refresh_url)
    response <- POST(refresh_url,
                     body = req_params, encode = "form",
                     authenticate(app$key, app$secret, type = "basic"), config = config_init
    )
  } else {
    req_params$client_secret <- app$secret
    response <- POST(refresh_url, body = req_params, encode = "form", config = config_init)
  }

  err <- find_oauth2.0_error(response)
  if (!is.null(err)) {
    lines <- c(
      paste0("Unable to refresh token: ", err$error),
      err$error_description,
      err$error_uri
    )
    warning(paste(lines, collapse = "\n"), call. = FALSE)
    return(NULL)
  }

  stop_for_status(response)
  refresh_data <- content(response)
  utils::modifyList(credentials, refresh_data)
}

find_oauth2.0_error = function (response)
{

  oauth2.0_error_codes <- c(
    400,
    401
  )

  oauth2.0_errors <- c(
    "invalid_request",
    "invalid_client",
    "invalid_grant",
    "unauthorized_client",
    "unsupported_grant_type",
    "invalid_scope"
  )

  if (!status_code(response) %in% oauth2.0_error_codes) {
    return(NULL)
  }
  content <- content(response)
  if (!content$error %in% oauth2.0_errors) {
    return(NULL)
  }
  list(error = content$error, error_description = content$error_description,
       error_uri = content$error_uri)
}
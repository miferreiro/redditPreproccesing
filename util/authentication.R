authentication = function(client.id, client.secret) {
  oauth2.0_token(
    endpoint = oauth_endpoint(
      base_url = "https://www.reddit.com/api/v1",
      authorize = "authorize",
      access = "access_token"
    ),
    app = oauth_app("Reddit collection data",
                    client.id,
                    client.secret),
    scope = c("read", "save"),
    use_basic_auth = TRUE,
    config_init = user_agent("plin21")
  )
}
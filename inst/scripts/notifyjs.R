
# download notify.js into 'inst/app/www/notify.js'
download.file(
  "https://raw.githubusercontent.com/jpillora/notifyjs/master/dist/notify.js",
  "inst/app/www/notify.js"
)

# to add to app run this:
htmltools::htmlDependency(
  "notifyjs",
  version = "0.1.0",
  src = fs::path_package("app/www", package = "jimstemplates"),
  script = "notify.js"
)

# in app run logic like so - ui

actionButton(
  "a",
  "Action",
  onclick = "$.notify('Hello World');"
)

# custom handler

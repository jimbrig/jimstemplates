server <- function(input, output, session) {

  shiny::callModule(
    polished::profile_module,
    "profile"
  )

}

polished::secure_server(server)

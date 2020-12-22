
#  ------------------------------------------------------------------------
#
# Title : UI
#    By : {{author}}
#  Date : {{today}}
#
#  ------------------------------------------------------------------------

header <- shinydashboard::dashboardHeader(
  title = "{{app_name}}",
  polished::profile_module_ui("profile")
)

sidebar <- shinydashboard::dashboardSidebar(
  shinydashboard::sidebarMenu(
    id = "menu"
  )
)

body <- shinydashboard::dashboardBody(
  tags$head(
    tags$link(
      rel = "shortcut icon",
      type = "image/png",
      href = "https://res.cloudinary.com/dxqnb8xjb/image/upload/v1510505618/tychobra-logo-blue_d2k9vt.png"
    ),
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  shinyjs::useShinyjs()
)

ui <- shinydashboard::dashboardPage(
  header, sidebar, body,
  title = "{{app_name}}",
  skin = "black"
)

polished::secure_ui(
  ui,
  sign_in_page_ui = sign_in_page()
)

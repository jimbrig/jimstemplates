#' Polished Sign in Page
#'
#' @return HTML
#' @export
#'
#' @importFrom polished sign_in_ui_default
sign_in_page <- function() {
  polished::sign_in_ui_default(
    color = "#006CB5",
    company_name = "Tychobra",
    logo_top = tags$img(
      src = "images/tychobra_logo_white.png",
      alt = "Tychobra Logo",
      style = "width: 125px; margin-top: 30px; margin-bottom: 30px;"
    ),
    logo_bottom = tags$div(
      style = "background-color: #FFF; width: 300px;",
      tags$img(
        src = "images/tychobra_logo_blue_co_name.png",
        alt = "Tychobra Logo",
        style = "width: 200px; margin-bottom: 15px; padding-top: 15px;"
      )
    ),
    icon_href = "images/tychobra_icon_blue.png",
    background_image = "images/milky_way.jpeg"
  )
}
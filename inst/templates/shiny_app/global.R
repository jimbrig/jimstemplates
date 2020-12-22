
#  ------------------------------------------------------------------------
#
# Title : Global Script
#    By : {{author}}
#  Date : {{today}}
#
#  ------------------------------------------------------------------------

# Library Packages --------------------------------------------------------
library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinyWidgets)
library(purrr)
library(lubridate)
library(tibble)
library(dplyr)
library(DT)
library(config)
library(polished)

app_config <- config::get()

polished::global_sessions_config(
  app_name = app_config$app_name,
  api_key = app_config$api_key
)

# Source Functions --------------------------------------------------------
purrr::walk(fs::dir_ls("R"), source)

# Global Options ----------------------------------------------------------
options(shiny.autoload.r = TRUE)
options(scipen = 999)
options(dplyr.summarise.inform = FALSE)

# Data --------------------------------------------------------------------

#' Create an `open_pkgdown` function
#'
#' @param pkgname package name
#' @param create logical - should pkgdown be created?
#' @param ...
#'
#' @inheritDotParams usethis::use_template
#'
#' @return invisible
#' @export
#'
#' @importFrom usethis use_template ui_done ui_code ui_todo ui_info
use_open_pkgdown <- function(pkgname = NULL, save_as = "R/open_pkgdown.R", Rcreate = FALSE, ...) {

  if (is.null(pkgname)) pkgname <- read.dcf("DESCRIPTION")[1, "Package"]

  template_file <- system.file(
    "templates/open_docs_template.R",
    package = "jimstemplates"
  )

  usethis::use_template(
    "open_pkgdown_template.R",
    save_as = save_as,
    data = list(
      "pkgname" = pkgname
    ),
    package = "jimstemplates"
  )

  usethis::ui_done(
    paste0("Function created. You can add in your package documentation to open pkgdown site using: ", usethis::ui_code(paste0(pkgname, "::open_pkgdown()"))))
  usethis::ui_todo("Run 'devtools::document()'")

  if (!create) {
    return(pkgname)
    } else {
      usethis::ui_info("Creating pkgdown...")
      build_pkgdown()
    }
}



#' Build pkgdown site and move to inst
#'
#' If "docs" is not in "inst" folder, it will not be available to the users
#'
#' @param move Logical. Whether to move the "docs" folder in "inst" to be kept in the package
#' @param clean_before Logical. Whether to empty the "docs" and "inst/docs" prior to build site
#' @param clean_after Logical. Whether to remove the original "docs" folder at the root of the project
#' @param yml path to custom "_pkgdown.yml" file
#' @param favicon path to favicon
#' @param ... Other parameters needed by [pkgdown::build_site()]
#'
#' @inheritParams pkgdown::build_site
#'
#' @export
#'
#' @importFrom cli rule
#' @importFrom pkgdown build_site as_pkgdown
#' @importFrom usethis use_build_ignore
#' @importFrom utils browseURL
build_pkgdown <- function(move = TRUE,
                          clean_before = TRUE,
                          clean_after = TRUE,
                          yml, favicon,
                          preview = NA,
                          ...) {

  if (!missing(yml)) {
    if (yml != "_pkgdown.yml") {
      file.copy(yml, "_pkgdown.yml", overwrite = TRUE)
    }
    usethis::use_build_ignore("_pkgdown.yml")
  }

  if (isTRUE(clean_before)) {
    unlink("docs", recursive = TRUE)
    unlink("inst/docs", recursive = TRUE)
  }

  usethis::use_build_ignore("docs")
  pkgdown::build_site(..., preview = FALSE)

  if (!missing(favicon)) {
    ext <- strsplit(favicon, "\\.")[[1]]
    ext <- ext[length(ext)]
    file.copy(favicon, paste0("docs/favicon.", ext), overwrite = TRUE)
  }

  if (isTRUE(move)) {
    files <- list.files("docs", recursive = TRUE)
    invisible(
      lapply(file.path("inst/docs", sort(unique(dirname(files)))),
             function(x) if (!dir.exists(x)) dir.create(x, recursive = TRUE, showWarnings = FALSE))
    )
    file.copy(file.path("docs", files), file.path("inst","docs", files), overwrite = TRUE)
  }

  if (isTRUE(clean_after)) {
    unlink("docs", recursive = TRUE)
  }

  if (is.na(preview)) {
    preview <- interactive()
  }
  if (preview) {
    pkg <- pkgdown::as_pkgdown(".")
    cli::rule("Previewing site")
    utils::browseURL(file.path(pkg$src_path, "inst", "docs", "index.html"))
  }
}




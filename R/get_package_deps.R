#' Get R Package Dependencies
#'
#' This function takes a path to a directory and parses the code from all
#' `.R` and `.Rmd` files, retrieving any detected package dependencies, and
#' optionally outputs a `deps.yaml` and `deps.R` file.
#'
#' @param path path to directory
#' @param write_yaml logical - should `deps.yaml` be created?
#' @param write_r logical - should `deps.R` be created?
#' @param include_versions logical - should package versions and github referenced be included?
#'
#' @return silently returns a data.frame with R package details
#' @export
#'
#' @importFrom cli cli_alert_warning cat_bullet
#' @importFrom dplyr bind_rows mutate select
#' @importFrom purrr safely map_depth pluck map flatten_chr compact
#' @importFrom rlang set_names
#' @importFrom yaml write_yaml
get_package_deps <- function(path = getwd(),
                             write_yaml = TRUE,
                             write_r = TRUE,
                             include_versions = TRUE) {

  # get package dependencies based off supplied directory
  # first detect any R scripts or RMD files
  files <- list.files(
    path = path,
    pattern = "^.*\\.R$|^.*\\.Rmd$",
    full.names = TRUE,
    recursive = TRUE
  )

  # loop through files gathering packages using `parse_packages`
  pkg_names_init <- lapply(files, purrr::safely(parse_packages))

  browser()

  pkg_names <- purrr::map_depth(pkg_names_init, 1, purrr::pluck, "result") %>%
    purrr::map(function(x) {
      if (length(x) == 0) return(NULL) else return(x)
    }) %>%
    purrr::flatten_chr() %>%
    unique() %>%
    purrr::map(purrr::possibly(packageDescription, otherwise = NA_character_)) %>%
    purrr::map_depth(1, purrr::pluck, "Package") %>%
    purrr::compact() %>%
    purrr::flatten_chr()

  if (length(pkg_names) == 0) {
    cli::cli_alert_warning("warning: no packages found in specified directory")
    return(invisible(NULL))
  }

  hold <- lapply(pkg_names, purrr::safely(get_package_details, quiet = FALSE)) %>%
    rlang::set_names(pkg_names)

  out <- purrr::map_depth(hold, 1, purrr::pluck, "result") %>%
    purrr::map(function(x) {
      if (length(x) == 0) return(NULL) else return(x)
    }) %>%
    purrr::compact()

  df <- dplyr::bind_rows(out) %>%
    dplyr::mutate(
      Repository = ifelse(is.na(Repository), "Github", Repository),
      install_cmd = ifelse(
        Repository == "CRAN",
        paste0("remotes::install_version(", shQuote(Package), ", version = ", shQuote(Version), ")"),
        paste0("remotes::install_github(", shQuote(paste0(GithubUsername, "/", Package)), ", ref = ", shQuote(GithubSHA1), ")")
      )
    )

  if (write_yaml) {
    yaml::write_yaml(out, fs::path(path, "deps.yaml"))
    cli::cat_bullet(
      "Created file `deps.yaml`.",
      bullet = "tick",
      bullet_col = "green"
    )
  }

  if (write_r) {
    txt <- paste0("options(repos = c(CRAN = 'https://packagemanager.rstudio.com/all/latest'))\ninstall.packages('remotes')\n",
                  paste(df$install_cmd, collapse = "\n"))
    cat(txt, file = fs::path(path, "deps.R"))
    cli::cat_bullet(
      "Created file `deps.R`.",
      bullet = "tick",
      bullet_col = "green"
    )
  }

  out_df <- df %>% dplyr::select(package = Package, src = Repository, version = Version, install_cmd)

  return(invisible(out_df))

}

#' @keywords internal
#' @noRd
get_package_details <- function(pkg_name) {
  pkg_d <- packageDescription(pkg_name)
  is.cran <- !is.null(pkg_d$Repository) && pkg_d$Repository ==
    "CRAN"
  is.github <- !is.null(pkg_d$GithubRepo)
  is.base <- !is.null(pkg_d$Priority) && pkg_d$Priority ==
    "base"
  if (!is.cran & !is.github & !is.base)
    stop("CRAN or GitHub info for ", pkg_name, " not found. Other packages repos are not supported.",
         call. = FALSE)
  if (is.cran)
    return(pkg_d[c("Package", "Repository", "Version")])
  if (is.github)
    return(pkg_d[c("Package", "GithubUsername",
                   "GithubRepo", "GithubRef", "GithubSHA1")])
}

#' @keywords internal
#' @noRd
#' @importFrom purrr map
parse_packages <- function(fl) {

  lns <- get_lines(fl)

  rgxs <- list(
    library = "(?<=(library\\()|(library\\([\"']{1}))[[:alnum:]|.]+",
    require = "(?<=(require\\()|(require\\([\"']{1}))[[:alnum:]|.]+",
    colon = "[[:alnum:]|.]*(?=:{2,3})"
  )

  found_pkgs <- purrr::map(rgxs, finder, lns = lns) %>% unlist() %>%
    unique()

  found_pkgs <- found_pkgs[!found_pkgs %in% c("", " ")]

  return(found_pkgs)

}

#' @keywords internal
#' @noRd
#' @importFrom formatR tidy_source
#' @importFrom knitr purl
get_lines <- function(file_name) {

  if (grepl(".Rmd", file_name, fixed = TRUE)) {
    tmp.file <- tempfile()
    knitr::purl(input = file_name,
                output = tmp.file,
                quiet = TRUE)
    file_name <- tmp.file
  }

  lns <- tryCatch(
    formatR::tidy_source(
      file_name,
      comment = FALSE,
      blank = FALSE,
      arrow = TRUE,
      brace.newline = TRUE,
      output = FALSE
    )$text.mask,
    error = function(e) {
      message(paste("Could not parse R code in:",
                    file_name))
      message("   Make sure you are specifying the right file name")
      message("   and check for syntax errors")
      stop("", call. = FALSE)
    }
  )
  if (is.null(lns)) {
    stop("No parsed text available", call. = FALSE)
  }

  return(lns)

}

#' @keywords internal
#' @noRd
finder <- function(rgx, lns) {
  regmatches(lns, gregexpr(rgx, lns, perl = TRUE)) %>% unlist()
}



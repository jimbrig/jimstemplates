

#' Create Dockerfile from
#'
#' @param path defaults to getwd()
#' @param base_image base image for `FROM` in Dockerfile
#' @param app_config app config, defaults to `default`
#' @param maintainer maintainer - defaults to `fullname` from [whoami::whoami()]
#' @param date date - defaults to [base::Sys.Date()]
#' @param packages R package dependencies returned from [get_package_deps()]
#' @param sysreqs logical - should sysreqs be included in image (via [get_sysreqs()])
#' @param additional_r_commands any additional r commands to include in image
#'
#' @return
#' @export
#'
#' @importFrom usethis use_template
create_dockerfile <- function(path = getwd(),
                              base_image = "merlinoa/shiny_run_custom",
                              app_config = "default",
                              mainainer = whoami::whoami()["fullname"],
                              date = Sys.Date(),
                              additional_r_commands = NULL) {

  pkgdeps <- get_package_deps(path)
  packages <- pkgdeps$package

  sysreqs <- get_sysreqs(packages)

  system_deps_string <- paste(paste0("  ", sysreqs), collapse = " \\ \n")

  sysreqs_out <- paste0(
    "RUN apt-get update && apt-get install -y \\ \n",
    system_deps_string
  )

  usethis::use_template(
    "Dockerfile",
    save_as = as.character(fs::path_rel(path = fs::path(path, "Dockerfile"))),
    data = list(base_image = base_image,
                app_config = app_config,
                maintianer = maintainer,
                # date = as.character(date),
                sysreqs = sysreqs_out,
                additional_r_commands = additional_r_commands),
    package = "jimstemplates"
  )

  out <- list(
    package_deps = pkgdeps,
    sysreqs = sysreqs
  )

  return(invisible(out))
}

#' Create .dockerignore from template
#'
#' @param open logical - open file?
#'
#' @export
#'
#' @importFrom usethis use_template
create_dockerignore <- function(open = TRUE) {

  usethis::use_template(
    "dockerignore",
    save_as = ".dockerignore",
    ignore = FALSE,
    open = open,
    package = "jimstemplates"
  )

}

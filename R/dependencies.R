#' #' Create a Dockerfile for  Shiny App
#' #'
#' #' Build a container containing your Shiny App.
#' #'
#' #' @inheritParams  add_module
#' #' @param path path to the DESCRIPTION file to use as an input.
#' #' @param output name of the Dockerfile output.
#' #' @param from The FROM of the Dockerfile. Default is FROM rocker/r-ver:
#' #'     with `R.Version()$major` and `R.Version()$minor`.
#' #' @param as The AS of the Dockerfile. Default it NULL.
#' #' @param port The `options('shiny.port')` on which to run the Shiny App.
#' #'     Default is 80.
#' #' @param host The `options('shiny.host')` on which to run the Shiny App.
#' #'    Default is 0.0.0.0.
#' #' @param sysreqs boolean to check the system requirements
#' #' @param repos character vector, the base URL of the repositories
#' #' @param expand boolean, if `TRUE` each system requirement will be known his own RUN line
#' #' @param open boolean, default is `TRUE` open the Dockerfile file
#' #' @param build_golem_from_source  boolean, if `TRUE` no tar.gz Package is created and the Dockerfile directly mount the source folder to build it
#' #' @param update_tar_gz boolean, if `TRUE` and build_golem_from_source is also `TRUE` an updated tar.gz Package is created
#' #' @param extra_sysreqs extra debian system requirements as character vector. Will be installed with apt-get install
#' #' @export
#' #' @rdname dockerfiles
#' #' @importFrom usethis use_build_ignore
#' #' @importFrom desc desc_get_deps
#' #' @importFrom dockerfiler Dockerfile
#' #' @importFrom rstudioapi navigateToFile isAvailable
#' #' @importFrom fs path path_file
#' #' @examples
#' #' \donttest{
#' #' # Add a standard Dockerfile
#' #' if (interactive()){
#' #'    add_dockerfile()
#' #' }
#' #' # Add a Dockerfile for ShinyProxy
#' #' if (interactive()){
#' #'     add_dockerfile_shinyproxy()
#' #' }
#' #' # Add a Dockerfile for Heroku
#' #' if (interactive()){
#' #'     add_dockerfile_heroku()
#' #' }
#' #'}
#' #'@return The `{dockerfiler}` object, invisibly.
#' add_dockerfile <- function(path = getwd(),
#'                            output = "Dockerfile",
#'                            pkg = get_golem_wd(),
#'                            from = paste0(
#'                              "rocker/r-ver:",
#'                              R.Version()$major,".",
#'                              R.Version()$minor),
#'                            as = NULL,
#'                            port = 80,
#'                            host = "0.0.0.0",
#'                            sysreqs = TRUE,
#'                            repos = c(CRAN="https://cran.rstudio.com/"),
#'                            expand = FALSE,
#'                            open = TRUE,
#'                            update_tar_gz = TRUE,
#'                            build_golem_from_source = TRUE,
#'                            extra_sysreqs = NULL) {
#'
#'
#'
#' }
#'
#'
#'   desc_path <- fs::path(path, "DESCRIPTION")
#'   if (fs::file_exists(desc_path)) {
#'     usethis::ui_info("Detected a DESCRIPTION file to use for package dependencies.")
#'     deps <- get_deps.pkg(path = desc_path)
#'   }
#'
#'
#'
#'
#'
#'
#'   where <- fs::path(pkg, output)
#'
#'   #if ( !check_file_exist(where) ) return(invisible(FALSE))
#'
#'   usethis::use_build_ignore(path_file(where))
#'
#'   dock <- dock_from_desc(
#'     path = path,
#'     FROM = from,
#'     AS = as,
#'     sysreqs = sysreqs,
#'     repos = repos,
#'     expand = expand,
#'     build_golem_from_source = build_golem_from_source,
#'     update_tar_gz = update_tar_gz,
#'     extra_sysreqs = extra_sysreqs
#'   )
#'
#'   dock$EXPOSE(port)
#'
#'   dock$CMD(
#'     sprintf(
#'       "R -e \"options('shiny.port'=%s,shiny.host='%s');%s::run_app()\"",
#'       port,
#'       host,
#'       read.dcf(path)[1]
#'     )
#'   )
#'
#'   dock$write(output)
#'
#'   if (open) {
#'     if (rstudioapi::isAvailable()) {
#'       rstudioapi::navigateToFile(output)
#'     } else {
#'       try(file.edit(output))
#'     }
#'   }
#'   alert_build(
#'     path = path,
#'     output =  output,
#'     build_golem_from_source = build_golem_from_source
#'   )
#'
#'   return(invisible(dock))
#'
#' }
#'
#' #' @export
#' #' @rdname dockerfiles
#' #' @importFrom fs path path_file
#' add_dockerfile_shinyproxy <- function(
#'   path = "DESCRIPTION",
#'   output = "Dockerfile",
#'   pkg = get_golem_wd(),
#'   from = paste0(
#'     "rocker/r-ver:",
#'     R.Version()$major,".",
#'     R.Version()$minor
#'   ),
#'   as = NULL,
#'   sysreqs = TRUE,
#'   repos = c(CRAN="https://cran.rstudio.com/"),
#'   expand = FALSE,
#'   open = TRUE,
#'   update_tar_gz = TRUE,
#'   build_golem_from_source = TRUE,
#'   extra_sysreqs = NULL
#' ){
#'
#'   where <- path(pkg, output)
#'
#'   #if ( !check_file_exist(where) ) return(invisible(FALSE))
#'
#'   usethis::use_build_ignore(output)
#'
#'   dock <- dock_from_desc(
#'     path = path,
#'     FROM = from,
#'     AS = as,
#'     sysreqs = sysreqs,
#'     repos = repos,
#'     expand = expand,
#'     build_golem_from_source = build_golem_from_source,
#'     update_tar_gz = update_tar_gz,
#'     extra_sysreqs = extra_sysreqs
#'   )
#'
#'   dock$EXPOSE(3838)
#'   dock$CMD(sprintf(
#'     " [\"R\", \"-e\", \"options('shiny.port'=3838,shiny.host='0.0.0.0');%s::run_app()\"]",
#'     read.dcf(path)[1]
#'   ))
#'   dock$write(output)
#'
#'   if (open) {
#'     if (rstudioapi::isAvailable()) {
#'       rstudioapi::navigateToFile(output)
#'     } else {
#'       try(file.edit(output))
#'     }
#'   }
#'   alert_build(
#'     path,
#'     output,
#'     build_golem_from_source = build_golem_from_source
#'   )
#'
#'   return(invisible(dock))
#'
#' }
#'
#' #' @export
#' #' @rdname dockerfiles
#' #' @importFrom fs path path_file
#' add_dockerfile_heroku <- function(
#'   path = "DESCRIPTION",
#'   output = "Dockerfile",
#'   pkg = get_golem_wd(),
#'   from = paste0(
#'     "rocker/r-ver:",
#'     R.Version()$major,".",
#'     R.Version()$minor
#'   ),
#'   as = NULL,
#'   sysreqs = TRUE,
#'   repos = c(CRAN="https://cran.rstudio.com/"),
#'   expand = FALSE,
#'   open = TRUE,
#'   update_tar_gz = TRUE,
#'   build_golem_from_source = TRUE,
#'   extra_sysreqs = NULL
#' ){
#'   where <- path(pkg, output)
#'
#'   #if ( !check_file_exist(where) )  return(invisible(FALSE))
#'
#'   usethis::use_build_ignore(output)
#'
#'   dock <- dock_from_desc(
#'     path = path,
#'     FROM = from,
#'     AS = as,
#'     sysreqs = sysreqs,
#'     repos = repos,
#'     expand = expand,
#'     build_golem_from_source = build_golem_from_source,
#'     update_tar_gz = update_tar_gz,
#'     extra_sysreqs = extra_sysreqs
#'   )
#'
#'   dock$CMD(
#'     sprintf(
#'       "R -e \"options('shiny.port'=$PORT,shiny.host='0.0.0.0');%s::run_app()\"",
#'       read.dcf(path)[1]
#'     )
#'   )
#'   dock$write(output)
#'
#'   alert_build(
#'     path = path,
#'     output =  output,
#'     build_golem_from_source = build_golem_from_source
#'   )
#'
#'   apps_h <- gsub(
#'     "\\.", "-",
#'     sprintf(
#'       "%s-%s",
#'       read.dcf(path)[1],
#'       read.dcf(path)[1,][['Version']]
#'     )
#'   )
#'
#'   cat_rule( "From your command line, run:" )
#'   cat_line("heroku container:login")
#'   cat_line(
#'     sprintf("heroku create %s", apps_h)
#'   )
#'   cat_line(
#'     sprintf("heroku container:push web --app %s", apps_h)
#'   )
#'   cat_line(
#'     sprintf("heroku container:release web --app %s", apps_h)
#'   )
#'   cat_line(
#'     sprintf("heroku open --app %s", apps_h)
#'   )
#'   cat_red_bullet("Be sure to have the heroku CLI installed.")
#'   cat_red_bullet(
#'     sprintf("You can replace %s with another app name.", apps_h)
#'   )
#'   if (open) {
#'     if (rstudioapi::isAvailable()) {
#'       rstudioapi::navigateToFile(output)
#'     } else {
#'       try(file.edit(output))
#'     }
#'   }
#'   usethis::use_build_ignore(files = output)
#'   return(invisible(dock))
#'
#' }
#'
#' alert_build <- function(
#'   path,
#'   output,
#'   build_golem_from_source
#' ){
#'   cat_created(output, "Dockerfile")
#'   if ( ! build_golem_from_source ){
#'     cat_red_bullet(
#'       sprintf(
#'         "Be sure to keep your %s_%s.tar.gz file (generated using `pkgbuild::build(vignettes = FALSE)` ) in the same folder as the %s file generated",
#'         read.dcf(path)[1],
#'         read.dcf(path)[1,][['Version']],
#'         basename(output)
#'       )
#'     )
#'   }
#' }
#'
#' #' Create Dockerfile from DESCRIPTION
#' #
#' #' @param path path to the DESCRIPTION file to use as an input.
#' #'
#' #' @param FROM The FROM of the Dockerfile. Default is FROM rocker/r-ver:
#' #'     with `R.Version()$major` and `R.Version()$minor`.
#' #' @param AS The AS of the Dockerfile. Default it NULL.
#' #' @param sysreqs boolean to check the system requirements
#' #' @param repos character vector, the base URL of the repositories
#' #' @param expand boolean, if `TRUE` each system requirement will be known his own RUN line
#' #' @param update_tar_gz boolean, if `TRUE` and build_golem_from_source is also `TRUE` an updated tar.gz Package is created
#' #' @param build_golem_from_source  boolean, if `TRUE` no tar.gz Package is created and the Dockerfile directly mount the source folder to build it
#' #' @param extra_sysreqs extra debian system requirements as character vector. Will be installed with apt-get install
#' #'
#' #' @importFrom utils installed.packages packageVersion
#' #' @importFrom remotes dev_package_deps
#' #' @importFrom desc desc_get_deps desc_get
#' #' @importFrom usethis use_build_ignore
#' #' @noRd
#' dock_from_desc <- function(
#'   path = "DESCRIPTION",
#'   FROM = paste0(
#'     "rocker/r-ver:",
#'     R.Version()$major,".",
#'     R.Version()$minor
#'   ),
#'   AS = NULL,
#'   sysreqs = TRUE,
#'   repos = c(CRAN="https://cran.rstudio.com/"),
#'   expand = FALSE,
#'   update_tar_gz = TRUE,
#'   build_golem_from_source = TRUE,
#'   extra_sysreqs = NULL
#' ){
#'
#'   packages <- desc::desc_get_deps(path)$package
#'   packages <- packages[packages != "R"] # remove R
#'   packages <- packages[ !packages %in% c(
#'     "base", "boot", "class", "cluster",
#'     "codetools", "compiler", "datasets",
#'     "foreign", "graphics", "grDevices",
#'     "grid", "KernSmooth", "lattice", "MASS",
#'     "Matrix", "methods", "mgcv", "nlme",
#'     "nnet", "parallel", "rpart", "spatial",
#'     "splines", "stats", "stats4", "survival",
#'     "tcltk", "tools", "utils"
#'   )] # remove base and recommended
#'
#'   if (sysreqs){
#'     # please wait during system requirement calculation
#'     cli::cat_bullet(
#'       "Please wait while we compute system requirements...",
#'       bullet = "info",
#'       bullet_col = "green"
#'     ) # TODO animated version ?
#'     system_requirement <- unique(
#'       get_sysreqs(packages = packages)
#'     )
#'     cat_green_tick("Done") # TODO animated version ?
#'
#'   } else{
#'     system_requirement <- NULL
#'   }
#'
#'   sr <- desc::desc_get(file = path,keys = "SystemRequirements" )
#'
#'   if ( length(extra_sysreqs)>0 ){
#'     system_requirement <- unique(c(system_requirement,extra_sysreqs))
#'   } else if (!is.na(sr))   {
#'     message(paste("the DESCRIPTION file contains the SystemRequirements bellow: ",sr))
#'     message(paste("please check the Dockerfile created and if needed pass extra sysreqs using the extra_sysreqs param"))
#'
#'   }
#'
#'   remotes_deps <- remotes::package_deps(packages)
#'   packages_on_cran <-
#'     intersect(remotes_deps$package[remotes_deps$is_cran],packages)
#'
#'   packages_not_on_cran <-
#'     setdiff(packages,packages_on_cran)
#'
#'   packages_with_version <-  data.frame(
#'     package=remotes_deps$package,
#'     installed=remotes_deps$installed,
#'     stringsAsFactors = FALSE
#'   )
#'   packages_with_version <- packages_with_version[
#'     packages_with_version$package %in% packages_on_cran,
#'   ]
#'
#'   packages_on_cran <-  set_name(
#'     packages_with_version$installed,
#'     packages_with_version$package
#'   )
#'
#'   dock <- dockerfiler::Dockerfile$new(FROM = FROM, AS = AS)
#'
#'   if (length(system_requirement)>0){
#'     if ( !expand ){
#'       dock$RUN(
#'         paste(
#'           "apt-get update && apt-get install -y ",
#'           paste(system_requirement, collapse = " "),
#'           "&& rm -rf /var/lib/apt/lists/*"
#'         )
#'       )
#'     } else {
#'       dock$RUN("apt-get update")
#'       for ( sr in system_requirement ){
#'         dock$RUN( paste("apt-get install -y ", sr) )
#'       }
#'       dock$RUN("rm -rf /var/lib/apt/lists/*")
#'     }
#'   }
#'
#'
#'   repos_as_character <- paste(capture.output(dput(repos)),collapse = "")
#'   repos_as_character <-  gsub(pattern = '\"',replacement = '\'',x=repos_as_character)
#'
#'
#'   dock$RUN(
#'     sprintf(
#'       "echo \"options(repos = %s, download.file.method = 'libcurl')\" >> /usr/local/lib/R/etc/Rprofile.site",
#'       repos_as_character
#'     )
#'   )
#'
#'   dock$RUN("R -e 'install.packages(\"remotes\")'")
#'
#'   if ( length(packages_on_cran>0)){
#'     ping <- mapply(function(dock, ver, nm){
#'       res <- dock$RUN(
#'         sprintf(
#'           "Rscript -e 'remotes::install_version(\"%s\",upgrade=\"never\", version = \"%s\")'",
#'           nm,
#'           ver
#'         )
#'       )
#'     },
#'     ver = packages_on_cran,
#'     nm = names(packages_on_cran),
#'     MoreArgs = list(dock = dock)
#'     )
#'   }
#'
#'   if ( length(packages_not_on_cran > 0)){
#'
#'     nn <-
#'       as.data.frame(do.call(rbind,
#'                             lapply(remotes_deps$remote[!remotes_deps$is_cran],
#'                                    function(.) {
#'                                      .[c('repo', 'username', 'sha')]
#'                                    })))
#'
#'     nn <- sprintf(
#'       "%s/%s@%s",
#'       nn$username,
#'       nn$repo,
#'       nn$sha
#'     )
#'
#'
#'     pong <- mapply(function(dock, ver, nm){
#'       res <- dock$RUN(
#'         sprintf(
#'           "Rscript -e 'remotes::install_github(\"%s\")'",
#'           ver
#'         )
#'       )
#'     },
#'     ver = nn,
#'     MoreArgs = list(dock = dock)
#'     )
#'   }
#'
#'   if ( !build_golem_from_source){
#'
#'     if ( update_tar_gz ){
#'       old_version <- list.files(
#'         pattern = sprintf("%s_.+.tar.gz", read.dcf(path)[1]),
#'         full.names = TRUE
#'       )
#'
#'       if ( length(old_version) > 0){
#'         lapply(old_version, file.remove)
#'         lapply(old_version, unlink, force = TRUE)
#'         cat_red_bullet(
#'           sprintf(
#'             "%s were removed from folder",
#'             paste(old_version, collapse = ', ')
#'           )
#'         )
#'       }
#'
#'
#'       if (isTRUE(requireNamespace("pkgbuild", quietly = TRUE))) {
#'         out <- pkgbuild::build(path = ".", dest_path = ".", vignettes = FALSE)
#'         if (missing(out)){
#'           cat_red_bullet("Error during tar.gz building"          )
#'
#'         } else {
#'           usethis::use_build_ignore(files = out)
#'           cat_green_tick(
#'             sprintf(
#'               " %s_%s.tar.gz created.",
#'               read.dcf(path)[1],
#'               read.dcf(path)[1,][['Version']]
#'             )
#'           )
#'         }
#'
#'       } else {
#'         stop("please install {pkgbuild}")
#'       }
#'
#'
#'     }
#'     # we use an already built tar.gz file
#'
#'     dock$COPY(
#'       from = paste0(read.dcf(path)[1], "_*.tar.gz"),
#'       to = "/app.tar.gz"
#'     )
#'     dock$RUN("R -e 'remotes::install_local(\"/app.tar.gz\",upgrade=\"never\")'")
#'     dock$RUN("rm /app.tar.gz")
#'   } else {
#'     dock$RUN("mkdir /build_zone")
#'     dock$ADD(from = ".",to =  "/build_zone")
#'     dock$WORKDIR("/build_zone")
#'     dock$RUN("R -e 'remotes::install_local(upgrade=\"never\")'")
#'     dock$RUN("rm -rf /build_zone")
#'   }
#'   # Add a dockerignore
#'   docker_ignore_add()
#'
#'   dock
#' }
#'
#' docker_ignore_add <- function(
#'   pkg = get_golem_wd()
#' ){
#'   path <- fs::path(
#'     pkg,
#'     ".dockerignore"
#'   )
#'
#'   if (!fs::file_exists(
#'     path
#'   )){
#'     fs::file_create(path)
#'   }
#'   write_ignore <- function(content){
#'     write(content, path, append = TRUE)
#'   }
#'   for (i in c(
#'     ".RData",
#'     ".Rhistory",
#'     ".git",
#'     ".gitignore",
#'     "manifest.json",
#'     "rsconnect/",
#'     "Rproj.user"
#'   )) {
#'     write_ignore(i)
#'   }
#'
#' }
#'
#'
#'
#'
#'
#'
#'
#'
#'
#' # if (sysreqs)
#' #
#' #   sysdeps <- {
#' #     # please wait during system requirement calculation
#' #     cli::cat_bullet(
#' #       "Please wait while we compute system requirements...",
#' #       bullet = "info",
#' #       bullet_col = "green"
#' #     ) # TODO animated version ?
#' #     system_requirement <- unique(
#' #       get_sysreqs(packages = packages)
#' #     )
#' #     cat_green_tick("Done") # TODO animated version ?
#' #
#' #   } else{
#' #     system_requirement <- NULL
#' #   }
#' #
#' # docker_txt <- paste0(
#' #   "FROM merlinoa/shiny_run_custom\n\nARG R_CONFIG_ACTIVE=default\n\n"
#' # )
#'
#'
#' # get_package_deps()
#'
#' #' @keywords internal
#' #' @noRd
#' #' @importFrom utils sessionInfo
#' detach_packages <- function() {
#'
#'   all_attached <- paste("package:",
#'                         names(utils::sessionInfo()$otherPkgs),
#'                         sep = "")
#'
#'   suppressWarnings(
#'     invisible(
#'       lapply(
#'         all_attached, detach, character.only = TRUE, unload = TRUE
#'       )
#'     )
#'   )
#'
#' }
#'
#' get_deps_full <- function(...) {
#'
#'   deps <- get_deps()
#'
#'   lapply(deps, get_package_details)
#'
#' }
#'
#' # bind_rows for df
#' # yaml::write_yaml
#' # R script using create_deps_r()
#'
#'
#'
#'
#'
#' #' Get Package Dependencies from DESCRIPTION or directory parsing
#' #'
#' #' @param path current projects root path; defaults to your current working
#' #'   directory.
#' #' @param dput logical
#' #' @param field Depends, Imports, or Suggests
#' #'
#' #' @return character vector of package names
#' #'
#' #' @importFrom stringr str_replace_all str_trim
#' #' @importFrom stats setNames
#' #'
#' #' @keywords internal
#' #' @noRd
#' #'
#' #' @examples
#' #' \dontrun{
#' #' get_deps()
#' #' }
#' #' @importFrom fs dir_ls path
#' get_deps <- function(directory = getwd(), ...) {
#'
#'   if ("DESCRIPTION" %in% basename(fs::dir_ls(directory))) {
#'     hold <- get_deps.pkg(path = fs::path(directory, "DESCRIPTION"))
#'     return(hold)
#'   } else {
#'     hold <- get_deps.dir(directory)
#'     return(hold)
#'   }
#'
#' }
#'
#' #' @keywords internal
#' #' @noRd
#' get_deps.dir <- function(directory = getwd()) {
#'
#'   fls <- list.files(
#'     path = directory,
#'     pattern = "^.*\\.R$|^.*\\.Rmd$",
#'     full.names = TRUE,
#'     recursive = TRUE
#'   )
#'
#'   pkg_names <- unlist(sapply(fls, parse_packages))
#'   pkg_names <- unique(pkg_names)
#'
#'   if (length(pkg_names) == 0) {
#'     message("warning: no packages found in specified directory")
#'     return(invisible(NULL))
#'   }
#'
#'   return(unname(pkg_names))
#'
#' }
#'
#'
#' #' @keywords internal
#' #' @noRd
#' #' @importFrom stats setNames
#' #' @importFrom stringr str_replace_all str_trim
#' get_deps.pkg <- function(path = "DESCRIPTION",
#'                          dput = FALSE,
#'                          field = c("Depends", "Imports", "Suggests")) {
#'
#'   init <- read.dcf(path)
#'
#'   hold <- init[, intersect(colnames(init), field)] %>%
#'     gsub(pattern = "\n", replacement = "") %>%
#'     strsplit(",") %>%
#'     unlist() %>%
#'     stats::setNames(NULL)
#'
#'   out <- hold[!grepl("^R [(]", hold)] %>%
#'     stringr::str_replace_all("\\(.+\\)", "") %>%
#'     stringr::str_trim() %>%
#'     unique() %>%
#'     sort()
#'
#'   if (!dput) return(out)
#'
#'   dput(out)
#'
#' }
#'
#'
#'
#'
#'
#'
#'
#' #' @keywords internal
#' #' @noRd
#' #' @importFrom desc description
#' #' @importFrom glue glue glue_collapse
#' #' @importFrom remotes install_github
#' #' @importFrom utils file.edit
#' create_deps_r <- function(path = "DESCRIPTION",
#'                           field = c("Depends",
#'                                     "Imports"),
#'                           to = "inst/dependencies.R",
#'                           open_file = TRUE,
#'                           ignore_base = TRUE) {
#'
#'   if (!dir.exists(dirname(to))) {
#'     dir.create(dirname(to),
#'                recursive = TRUE,
#'                showWarnings = FALSE)
#'     dir_to <- normalizePath(dirname(to))
#'   } else {
#'     dir_to <- normalizePath(dirname(to))
#'   }
#'
#'   ll <- get_deps.pkg()
#'
#'   if (isTRUE(ignore_base)) {
#'     to_remove <-
#'       which(lapply(ll, packageDescription, field = "Priority") == "base")
#'     if (length(to_remove) > 0) {
#'       ll <- ll[-to_remove]
#'     }
#'   }
#'
#'   desc <- desc::description$new(path)
#'   remotes_orig <- desc$get_remotes()
#'
#'   if (length(remotes_orig) != 0) {
#'     remotes_orig_pkg <- gsub("^.*/", "", remotes_orig)
#'     ll <- ll[!ll %in% remotes_orig_pkg]
#'     inst_remotes <- remotes_orig
#'     w.github <- !grepl("\\(", remotes_orig)
#'     inst_remotes[w.github] <-
#'       glue("remotes::install_github('{remotes_orig[w.github]}')")
#'     inst_remotes[!w.github] <- remotes_orig[!w.github]
#'     remotes_content <-
#'       paste(
#'         "# Remotes ----",
#'         "install.packages(\"remotes\")",
#'         paste(inst_remotes, collapse = "\n"),
#'         sep = "\n"
#'       )
#'   }
#'   else {
#'     remotes_content <- "# No Remotes ----"
#'   }
#'   if (length(ll) != 0) {
#'     content <-
#'       glue::glue(
#'         "*{remotes_content}*\n# Attachments ----\nto_install <- c(\"*{glue::glue_collapse(as.character(ll), sep=\"\\\", \\\"\")}*\")\n  for (i in to_install) {\n    message(paste(\"looking for \", i))\n    if (!requireNamespace(i)) {\n      message(paste(\"     installing\", i))\n      install.packages(i)\n    }\n  }\n\n",
#'         .open = "*{",
#'         .close = "}*"
#'       )
#'   }
#'   else {
#'     content <- glue::glue(
#'       "*{remotes_content}*\n# No attachments ----\n      \n\n",
#'       .open = "*{",
#'       .close = "}*"
#'     )
#'   }
#'
#'   file <- file.path(dir_to, basename(to))
#'   file.create(file)
#'   cat(content, file = file)
#'
#'   if (open_file) {
#'     utils::file.edit(file, editor = "internal")
#'   }
#' }

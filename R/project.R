#' #' create_project
#' #'
#' #' This function create an R project
#' #'
#' #' @param path A path. If it exists, it is used.
#' #'   If it does not exist, it is created, provided that the parent path exists.
#' #' @param git If TRUE, initialize git.
#' #'
#' #' @return Path to the newly created project or package, invisibly.
#' #'
#' #' @export
#' create_project <- function(path, git = TRUE) {
#'   old_project <- usethis::proj_set(path, force = TRUE)
#'   on.exit(usethis::proj_set(old_project), add = TRUE)
#'
#'   dir.create(
#'     path = usethis::proj_path(),
#'     recursive = TRUE, showWarnings = FALSE, mode = "0775"
#'   )
#'
#'   usethis::use_directory("R")
#'   usethis::use_directory("docs")
#'   usethis::use_directory("data")
#'   usethis::use_directory("outputs")
#'   usethis::use_directory("reports")
#'   usethis::use_directory("logs")
#'
#'   rproj <- c(
#'     "Version: 1.0",
#'     "",
#'     "RestoreWorkspace: No",
#'     "SaveWorkspace: No",
#'     "AlwaysSaveHistory: No",
#'     "",
#'     "EnableCodeIndexing: Yes",
#'     "UseSpacesForTab: Yes",
#'     "NumSpacesForTab: 2",
#'     "Encoding: UTF-8",
#'     "",
#'     "RnwWeave: knitr",
#'     "LaTeX: pdfLaTeX",
#'     "",
#'     "AutoAppendNewline: Yes",
#'     "",
#'     "QuitChildProcessesOnExit: Yes"
#'   )
#'   writeLines(rproj, con = usethis::proj_path(paste0(basename(path), ".Rproj")))
#'
#'   gitignore <- c(
#'     ".Rhistory",
#'     ".RData",
#'     ".Rproj.user",
#'     "**.RData",
#'     "**.Rdata",
#'     "**.Ruserdata",
#'     "**.rdb",
#'     "**.rdx",
#'     "**.glo",
#'     "**.ist",
#'     "**.out",
#'     "**.nav",
#'     "**.log",
#'     "**.bbl",
#'     "**.blg",
#'     "**.aux",
#'     "**.toc",
#'     "**.snm",
#'     "outputs",
#'     "logs"
#'   )
#'   writeLines(gitignore, con = usethis::proj_path(".gitignore"))
#'
#'   usethis::use_readme_md(open = FALSE)
#'   if (git) {
#'     git2r::init(usethis::proj_get())
#'     git2r::add(usethis::proj_get(), "*")
#'     git2r::commit(repo = usethis::proj_get(), message = "Init project", all = TRUE)
#'   }
#'
#'   invisible(usethis::proj_get())
#' }
#'
#'
#' #' Create new project scaffolding
#' #'
#' #' Create all the scaffolding for a new project in a new directory.
#' #' The scaffolding includes a README file, different folders to hold raw data,
#' #' analyses, etc, and optionally also \code{testthat} infrastructure.
#' #' Also, optionally, set a private or public GitHub repo with continuous
#' #' integration (Travis-CI, GitHub Actions...).
#' #'
#' #' @param name Character. Name of the new project. Could be a path,
#' #'   e.g. \code{"~/myRcode/newproj"}. A new folder will be created with that name.
#' #' @param github Logical. Create GitHub repository? Note this requires some
#' #'   working infrastructure like \code{git} and a \code{GITHUB_PAT}.
#' #'  See instructions here \url{https://usethis.r-lib.org/articles/articles/usethis-setup.html}.
#' #' @param private.repo Logical. Default is TRUE.
#' #' @param ci Logical. Use continuous integration in your GitHub repository?
#' #'   Current options are "none" (default), "travis" (uses Travis-CI),
#' #'   "circle" (uses Circle-CI), "appveyor" (uses AppVeyor), or "gh-actions"
#' #'   (uses GitHub Actions).
#' #' @param makefile Logical. If TRUE, adds a template \code{makefile.R} file to
#' #'   the project.
#' #' @param pipe Logical. Use magrittr's pipe in your package?
#' #' @param testthat Logical. Add testthat infrastructure?
#' #' @param verbose Print verbose output in the console while creating the new project? Default is FALSE.
#' #' @param open.project Logical. If TRUE (the default) will open the newly created Rstudio project in a new session.
#' #'
#' #' @return A new directory with R package structure, slightly modified.
#' #' @export
#' #' @details If using \code{github = TRUE}, you will be asked if you want to
#' #'   commit some files. Reply positively to continue.
#' #'
#' #' @examples
#' #' \dontrun{
#' #' library("template")
#' #' new_project("myproject")
#' #' new_project("myproject", github = TRUE, private.repo = TRUE)
#' #' }
#' new_project <- function(name,
#'                         github = FALSE,
#'                         private.repo = TRUE,
#'                         ci = "none",
#'                         makefile = TRUE,
#'                         pipe = TRUE,
#'                         testthat = FALSE,
#'                         verbose = FALSE,
#'                         open.project = TRUE) {
#'
#'   if (!isTRUE(verbose)) {
#'     options(usethis.quiet = TRUE)
#'   }
#'
#'   usethis::create_package(name, open = FALSE)
#'   usethis::proj_set(name, force = TRUE)
#'
#'   usethis::use_package_doc(open = FALSE)
#'   usethis::use_readme_rmd(open = FALSE)
#'   usethis::use_data_raw(open = FALSE)
#'
#'   if (isTRUE(pipe)) {
#'     usethis::use_pipe()
#'   }
#'
#'   if (isTRUE(testthat)) {
#'     usethis::use_testthat()
#'   }
#'
#'   # Add folders
#'   dir.create(file.path(name, "data"))
#'   dir.create(file.path(name, "analyses"))
#'   dir.create(file.path(name, "manuscript"))
#'
#'   # Add makefile.R
#'   if (isTRUE(makefile)) {
#'     file.copy(from = system.file("makefile",
#'                                  "makefile.R",
#'                                  package = "jimstemplates"),
#'               to = usethis::proj_get())
#'   }
#'
#'
#'   usethis::use_build_ignore(c("analyses", "manuscript", "makefile.R"))
#'
#'
#'   if (isTRUE(github)) {
#'     usethis::use_git()
#'     usethis::use_github(private = private.repo)
#'     # usethis::use_github_links(name)
#'
#'     ## Continuous integration services
#'     stopifnot(ci %in% c("none", "travis", "gh-actions", "circle", "appveyor"))
#'
#'     if (ci == "travis") {
#'       usethis::use_travis()
#'       #usethis::use_travis_badge()
#'     }
#'
#'     if (ci == "gh-actions") {
#'       usethis::use_github_actions()
#'       # usethis::use_github_action_check_release()
#'       #usethis::use_github_actions_badge()
#'     }
#'
#'     if (ci == "circle") {
#'       usethis::use_circleci()
#'     }
#'
#'     if (ci == "appveyor") {
#'       usethis::use_appveyor()
#'     }
#'
#'   }
#'
#'   # Open Rstudio project in new session at the end?
#'   if (isTRUE(open.project)) {
#'     if (rstudioapi::isAvailable()) {
#'       rstudioapi::openProject(name, newSession = TRUE)
#'     }
#'   }
#'
#' }
#'
#' #' html_report
#' #'
#' #' These are simple wrappers of the output format functions like rmarkdown::html_document(),
#' #' and they added the capability of numbering figures/tables/equations/theorems
#' #' and cross-referencing them. See References for the syntax. Note you can also cross-reference
#' #' sections by their ID's using the same syntax when sections are numbered.
#' #' In case you want to enable cross reference in other formats, use markdown_document2
#' #' with base_format argument.
#' #'
#' #' @inheritParams rmarkdown::html_document
#' #' @inheritParams bookdown::html_document2
#' #' @param ... Arguments to be passed to a specific output format function `rmarkdown::html_document`
#' #'
#' #' @return R Markdown output format to pass to render
#' #' @export
#' html_report <- function(
#'   toc_depth = 3,
#'   fig_width = 6.3,
#'   fig_height = 4.7,
#'   number_sections = TRUE,
#'   self_contained = TRUE,
#'   mathjax = "default",
#'   df_print = "kable",
#'   code_download = TRUE,
#'   ...
#' ) {
#'   bookdown::html_document2(
#'     toc = TRUE,
#'     toc_float = list(collapse = FALSE),
#'     theme = "simplex",
#'     toc_depth = toc_depth,
#'     fig_width = fig_width,
#'     fig_height = fig_height,
#'     number_sections = number_sections,
#'     self_contained = self_contained,
#'     mathjax = mathjax,
#'     df_print = df_print,
#'     code_download = code_download,
#'     ...
#'   )
#' }
#'
#' #' powerpoint_presentation
#' #'
#' #' Format for converting from R Markdown to a PowerPoint presentation. Pandoc v2.0.5 or above is required.
#' #'
#' #' @inheritParams rmarkdown::powerpoint_presentation
#' #' @param ... Arguments to be passed to a specific output format function `rmarkdown::powerpoint_presentation`
#' #'
#' #' @return R Markdown output format to pass to render
#' #' @export
#' powerpoint_presentation <- function(fig_width = 5.94, fig_height =  3.30, ...) {
#'   template <- system.file("rmarkdown/templates/powerpoint/resources", "template.pptx", package = "mctemplates")
#'   rmarkdown::powerpoint_presentation(reference_doc = template, ...)
#' }
#'
#' #' .Rprofile configuration as a function
#' #'
#' #' @param given A character string with the given names.
#' #' @param family A character string with the family name.
#' #' @param email A character string giving an e-mail address.
#' #' @param orcid A chracter string giving an ORCID.
#' #' @param .Renviron Path to the `.Renviron` file.
#' #' @param LANGUAGE Environment variable for language.
#' #' @param R_LIBS_USER Environment variable for user library.
#' #' @param R_MAX_NUM_DLLS Environment variable for the maximum number of DLLs to be loaded.
#' #' @param TZ Environment variable for time zone.
#' #' @param GITHUB_PAT Environment variable for GitHub access token.
#' #' @param GITLAB_PAT Environment variable for GitLab access token.
#' #'
#' #' @return NULL
#' #' @export
#' mcprofile <- function(
#'   given = NULL,
#'   family = NULL,
#'   email = NULL,
#'   orcid = NULL,
#'   .Renviron = "~/.Renviron",
#'   LANGUAGE = NULL,
#'   R_LIBS_USER = NULL,
#'   R_MAX_NUM_DLLS = NULL,
#'   TZ = NULL,
#'   GITHUB_PAT = NULL,
#'   GITLAB_PAT = NULL
#' ) {
#'   set_option <- function(x) {
#'     cli::cat_line(
#'       glue::glue(.sep = " ",
#'                  "{crayon::green(clisymbols::symbol$tick)}",
#'                  "{crayon::green(x)} set to {crayon::blue(options(x))}"
#'       )
#'     )
#'   }
#'
#'   cli::cat_line(crayon::white(cli::rule(
#'     left = paste(crayon::bold("Load"), crayon::blue(".Rprofile")),
#'     right = crayon::blue(paste0("Version ", utils::packageVersion("mctemplates"))),
#'     width = 80
#'   )))
#'
#'   if (.Platform$OS.type == "unix" & !is.null(LANGUAGE)) {
#'     cli::cat_line(
#'       glue::glue(
#'         '{crayon::red(clisymbols::symbol$bullet)} Set {crayon::blue("locales")}'
#'       )
#'     )
#'     invisible(lapply(
#'       X = c(
#'         "LC_ALL", "LC_CTYPE", "LC_TIME", "LC_COLLATE", "LC_MONETARY",
#'         "LC_MESSAGES", "LC_PAPER", "LC_MEASUREMENT"
#'       ),
#'       FUN = Sys.setlocale, locale = LANGUAGE
#'     ))
#'     cli::cat_line(
#'       glue::glue(.sep = " ",
#'                  "{crayon::green(clisymbols::symbol$tick)}",
#'                  "{crayon::green('locales')} set to {crayon::blue(LANGUAGE)}"
#'       )
#'     )
#'   }
#'
#'   cli::cat_line(
#'     glue::glue(
#'       '{crayon::red(clisymbols::symbol$bullet)} Write & load {crayon::blue(".Renviron")}'
#'     )
#'   )
#'   env_var <- c(
#'     if (!is.null(LANGUAGE)) glue::glue("LANGUAGE='{LANGUAGE}'"),
#'     if (!is.null(R_MAX_NUM_DLLS)) glue::glue("R_MAX_NUM_DLLS={R_MAX_NUM_DLLS}"),
#'     if (!is.null(GITHUB_PAT)) glue::glue("GITHUB_PAT={GITHUB_PAT}"),
#'     if (!is.null(GITLAB_PAT)) glue::glue("GITLAB_PAT={GITLAB_PAT}"),
#'     if (!is.null(TZ)) glue::glue("TZ='{TZ}'"),
#'     if (!is.null(R_LIBS_USER)) glue::glue("R_LIBS_USER={R_LIBS_USER}")
#'   )
#'   cat(env_var, sep = "\n", file = .Renviron)
#'   readRenviron(path = .Renviron)
#'   for (ienv in readLines(.Renviron)) {
#'     if (grepl("^GIT", ienv)) ienv <- gsub("(.*=).*", "\\1=XXXXXXXX", ienv)
#'     cli::cat_line(
#'       glue::glue(.sep = " ",
#'                  "{crayon::blue(clisymbols::symbol$info)}",
#'                  "{crayon::green(gsub('=.*$', '', ienv))}",
#'                  "set to {crayon::blue(gsub('^.*=', '', ienv))}"
#'       )
#'     )
#'   }
#'
#'   cli::cat_line(glue::glue('{crayon::red(clisymbols::symbol$bullet)} Set options'))
#'   options(menu.graphics = FALSE)
#'   set_option("menu.graphics")
#'
#'   options(width = 120)
#'   set_option("width")
#'
#'   options(reprex.advertise = FALSE)
#'   set_option("reprex.advertise")
#'
#'   options(error = rlang::entrace)
#'   cli::cat_line(
#'     glue::glue(.sep = " ",
#'                '{crayon::green(clisymbols::symbol$tick)}',
#'                '{crayon::green("error")} set to {crayon::blue("rlang::entrace")}'
#'     )
#'   )
#'
#'   options(rlang_backtrace_on_error = "branch")
#'   set_option("rlang_backtrace_on_error")
#'
#'   if (nchar(system.file(package = "prompt", lib.loc = c(Sys.getenv("R_LIBS"), Sys.getenv("R_LIBS_USER")))) != 0) {
#'     prompt::set_prompt(prompt::prompt_git)
#'     cli::cat_line(
#'       glue::glue(.sep = " ",
#'                  '{crayon::green(clisymbols::symbol$tick)}',
#'                  '{crayon::green("prompt")} set to {crayon::blue("prompt::prompt_git")}'
#'       )
#'     )
#'   }
#'
#'   options(usethis.protocol = "https")
#'   set_option("usethis.protocol")
#'
#'   if (!is.null(given) & !is.null(family)) {
#'     options(usethis.full_name = paste(given, family))
#'     set_option("usethis.full_name")
#'   }
#'
#'   if (is.null(given) | is.null(family)) {
#'     options(usethis.description = list(Version = "0.0.0.9000"))
#'   } else {
#'     options(usethis.description = list(
#'       `Authors@R` = glue::glue('person(given = "{given}", family = "{family}", role = c("aut", "cre"), email = "{email}", comment = c(ORCID = "{orcid}"))'),
#'       Version = "0.0.0.9000"
#'     ))
#'   }
#'   cli::cat_line(
#'     glue::glue(
#'       '{crayon::green(clisymbols::symbol$tick)} {crayon::green("usethis.description")}'
#'     )
#'   )
#'   for (idesc in names(options('usethis.description')[[1]])) {
#'     temp <- options('usethis.description')[[1]][[idesc]]
#'     cli::cat_line(
#'       glue::glue(.sep = " ",
#'                  "  {crayon::blue(clisymbols::symbol$info)} {crayon::green(idesc)}",
#'                  "set to {crayon::blue(if (nchar(temp) > 12) '...' else temp)}"
#'       )
#'     )
#'   }
#'
#'   cli::cat_line(glue::glue('{crayon::red(clisymbols::symbol$bullet)} Load packages'))
#'   invisible(lapply(
#'     X = c("devtools", "usethis", "testthat", "reprex", "git2r"),
#'     FUN = function(x) {
#'       if (require(x, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)) {
#'         cli::cat_line(
#'           glue::glue(
#'             "{crayon::green(clisymbols::symbol$tick)} {crayon::blue(x)}"
#'           )
#'         )
#'       } else {
#'         cli::cat_line(
#'           glue::glue(
#'             "{crayon::red(clisymbols::symbol$cross)} {crayon::blue(x)}"
#'           )
#'         )
#'       }
#'     }
#'   ))
#'
#'   cli::cat_line(crayon::white(cli::rule(width = 80)))
#'   invisible()
#' }
#'
#' #' theme_black
#' #'
#' #' @param base_size base font size
#' #' @param base_family base font family
#' #' @param base_line_size base size for line elements
#' #' @param base_rect_size base size for rect elements
#' #'
#' #' @export
#' #' @import ggplot2
#' theme_black <- function(
#'   base_size = 11,
#'   base_family = "",
#'   base_line_size = base_size / 22,
#'   base_rect_size = base_size / 22
#' ) {
#'   half_line <- base_size / 2
#'   bc <- c("grey20", "grey50", "white")
#'   ggplot2::theme(
#'     line = ggplot2::element_line(
#'       colour = bc[3],
#'       size = base_line_size,
#'       linetype = 1,
#'       lineend = "butt"
#'     ),
#'     rect = ggplot2::element_rect(
#'       fill = bc[1],
#'       colour = bc[3],
#'       size = base_rect_size,
#'       linetype = 1
#'     ),
#'     text = ggplot2::element_text(
#'       family = base_family,
#'       face = "plain",
#'       colour = bc[3],
#'       size = base_size,
#'       lineheight = 0.9,
#'       hjust = 0.5,
#'       vjust = 0.5,
#'       angle = 0,
#'       margin = ggplot2::margin(),
#'       debug = FALSE
#'     ),
#'     title = NULL,
#'     aspect.ratio = NULL,
#'
#'     axis.title = NULL,
#'     axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = half_line), vjust = 1),
#'     axis.title.x.top = ggplot2::element_text(margin = ggplot2::margin(b = half_line), vjust = 0),
#'     axis.title.x.bottom = NULL,
#'     axis.title.y = ggplot2::element_text(angle = 90, margin = ggplot2::margin(r = half_line), vjust = 1),
#'     axis.title.y.left = NULL,
#'     axis.title.y.right = ggplot2::element_text(angle = -90, margin = ggplot2::margin(l = half_line), vjust = 0),
#'     axis.text = ggplot2::element_text(size = ggplot2::rel(0.8), colour = bc[3]),
#'     axis.text.x = ggplot2::element_text(margin = ggplot2::margin(t = 0.8 * half_line / 2), vjust = 1),
#'     axis.text.x.top = ggplot2::element_text(margin = ggplot2::margin(b = 0.8 * half_line / 2), vjust = 0),
#'     axis.text.x.bottom = NULL,
#'     axis.text.y = ggplot2::element_text(margin = ggplot2::margin(r = 0.8 * half_line / 2), hjust = 1),
#'     axis.text.y.left = NULL,
#'     axis.text.y.right = ggplot2::element_text(margin = ggplot2::margin(l = 0.8 * half_line / 2), hjust = 0),
#'     axis.ticks = ggplot2::element_line(colour = bc[3]),
#'     axis.ticks.x = NULL,
#'     axis.ticks.x.top = NULL,
#'     axis.ticks.x.bottom = NULL,
#'     axis.ticks.y = NULL,
#'     axis.ticks.y.left = NULL,
#'     axis.ticks.y.right = NULL,
#'     axis.ticks.length = ggplot2::unit(half_line / 2, "pt"),
#'     axis.ticks.length.x = NULL,
#'     axis.ticks.length.x.top = NULL,
#'     axis.ticks.length.x.bottom = NULL,
#'     axis.ticks.length.y = NULL,
#'     axis.ticks.length.y.left = NULL,
#'     axis.ticks.length.y.right = NULL,
#'     axis.line = ggplot2::element_blank(),
#'     axis.line.x = NULL,
#'     axis.line.x.top = NULL,
#'     axis.line.x.bottom = NULL,
#'     axis.line.y = NULL,
#'     axis.line.y.left = NULL,
#'     axis.line.y.right = NULL,
#'
#'     legend.background = ggplot2::element_rect(fill = bc[1], colour = NA),
#'     legend.margin = ggplot2::margin(half_line, half_line, half_line, half_line),
#'     legend.spacing = ggplot2::unit(2 * half_line, "pt"),
#'     legend.spacing.x = NULL,
#'     legend.spacing.y = NULL,
#'     legend.key = ggplot2::element_rect(fill = bc[1], colour = bc[3]),
#'     legend.key.size = ggplot2::unit(1.2, "lines"),
#'     legend.key.height = NULL,
#'     legend.key.width = NULL,
#'     legend.text = ggplot2::element_text(size = ggplot2::rel(0.8)),
#'     legend.text.align = NULL,
#'     legend.title = ggplot2::element_text(hjust = 0),
#'     legend.title.align = NULL,
#'     legend.position = "right",
#'     legend.direction = NULL,
#'     legend.justification = "center",
#'     legend.box = NULL,
#'     legend.box.just = NULL,
#'     legend.box.margin = ggplot2::margin(0, 0, 0, 0, "cm"),
#'     legend.box.background = ggplot2::element_blank(),
#'     legend.box.spacing = ggplot2::unit(2 * half_line, "pt"),
#'
#'     panel.background = ggplot2::element_rect(fill = bc[1], colour = NA),
#'     panel.border = ggplot2::element_rect(fill = NA, colour = bc[3], size = 0.5, linetype = "solid"),
#'     panel.spacing = ggplot2::unit(half_line, "pt"),
#'     panel.spacing.x = NULL,
#'     panel.spacing.y = NULL,
#'     panel.grid = ggplot2::element_line(colour = bc[2]),
#'     panel.grid.major = ggplot2::element_line(colour = bc[2]),
#'     panel.grid.minor = ggplot2::element_line(colour = bc[2], size = ggplot2::rel(0.5)),
#'     panel.grid.major.x = NULL,
#'     panel.grid.major.y = NULL,
#'     panel.grid.minor.x = NULL,
#'     panel.grid.minor.y = NULL,
#'     panel.ontop = FALSE,
#'
#'     plot.background = ggplot2::element_rect(colour = bc[1]),
#'     plot.title = ggplot2::element_text(
#'       size = ggplot2::rel(1.2),
#'       face = "bold",
#'       hjust = 0,
#'       vjust = 1,
#'       margin = ggplot2::margin(b = half_line)
#'     ),
#'     plot.title.position = "plot",
#'     plot.subtitle = ggplot2::element_text(
#'       hjust = 0,
#'       vjust = 1,
#'       margin = ggplot2::margin(b = half_line)
#'     ),
#'     plot.caption = ggplot2::element_text(
#'       size = ggplot2::rel(0.8),
#'       hjust = 1, vjust = 1,
#'       margin = ggplot2::margin(t = half_line)
#'     ),
#'     plot.caption.position = "plot",
#'     plot.tag = ggplot2::element_text(size = ggplot2::rel(1.2), hjust = 0.5, vjust = 0.5),
#'     plot.tag.position = "topleft",
#'     plot.margin = ggplot2::margin(half_line, half_line, half_line, half_line),
#'
#'     strip.background = ggplot2::element_rect(fill = bc[1], colour = bc[3]),
#'     strip.background.x = NULL,
#'     strip.background.y = NULL,
#'     strip.placement = "inside",
#'     strip.placement.x = NULL,
#'     strip.placement.y = NULL,
#'     strip.text = ggplot2::element_text(
#'       colour = bc[3],
#'       size = ggplot2::rel(0.8),
#'       margin = ggplot2::margin(0.8 * half_line, 0.8 * half_line, 0.8 * half_line, 0.8 * half_line)
#'     ),
#'     strip.text.x = NULL,
#'     strip.text.y = ggplot2::element_text(angle = -90),
#'     strip.switch.pad.grid = ggplot2::unit(half_line / 2, "pt"),
#'     strip.switch.pad.wrap = ggplot2::unit(half_line / 2, "pt"),
#'
#'     complete = TRUE
#'   )
#' }
#'
#'
#' #' @rdname theme_black
#' #' @export
#' theme_black_md <- function(
#'   base_size = 11,
#'   base_family = "",
#'   base_line_size = base_size / 22,
#'   base_rect_size = base_size / 22
#' ) {
#'   half_line <- base_size / 2
#'   bc <- c("grey20", "grey50", "white")
#'   theme_black(base_size, base_family, base_line_size, base_rect_size) +
#'     ggplot2::theme(
#'       # text = ggtext::element_markdown(
#'       #   family = base_family,
#'       #   face = "plain",
#'       #   colour = bc[3],
#'       #   size = base_size,
#'       #   lineheight = 0.9,
#'       #   hjust = 0.5,
#'       #   vjust = 0.5,
#'       #   angle = 0,
#'       #   margin = ggplot2::margin(),
#'       #   debug = FALSE
#'       # ),
#'       axis.title.x = ggtext::element_markdown(margin = ggplot2::margin(t = half_line), vjust = 1),
#'       axis.title.x.top = ggtext::element_markdown(margin = ggplot2::margin(b = half_line), vjust = 0),
#'       axis.title.y = ggtext::element_markdown(angle = 90, margin = ggplot2::margin(r = half_line), vjust = 1),
#'       axis.title.y.right = ggtext::element_markdown(angle = -90, margin = ggplot2::margin(l = half_line), vjust = 0),
#'       axis.text = ggtext::element_markdown(size = ggplot2::rel(0.8), colour = bc[3]),
#'       axis.text.x = ggtext::element_markdown(margin = ggplot2::margin(t = 0.8 * half_line / 2), vjust = 1),
#'       axis.text.x.top = ggtext::element_markdown(margin = ggplot2::margin(b = 0.8 * half_line / 2), vjust = 0),
#'       axis.text.y = ggtext::element_markdown(margin = ggplot2::margin(r = 0.8 * half_line / 2), hjust = 1),
#'       axis.text.y.right = ggtext::element_markdown(margin = ggplot2::margin(l = 0.8 * half_line / 2), hjust = 0),
#'
#'       legend.text = ggtext::element_markdown(size = ggplot2::rel(0.8)),
#'       legend.title = ggtext::element_markdown(hjust = 0),
#'
#'       plot.title = ggtext::element_markdown(
#'         size = ggplot2::rel(1.2),
#'         face = "bold",
#'         hjust = 0,
#'         vjust = 1,
#'         margin = ggplot2::margin(b = half_line)
#'       ),
#'       plot.subtitle = ggtext::element_markdown(
#'         hjust = 0,
#'         vjust = 1,
#'         margin = ggplot2::margin(b = half_line)
#'       ),
#'       plot.caption = ggtext::element_markdown(
#'         size = ggplot2::rel(0.8),
#'         hjust = 1, vjust = 1,
#'         margin = ggplot2::margin(t = half_line)
#'       ),
#'       plot.tag = ggtext::element_markdown(size = ggplot2::rel(1.2), hjust = 0.5, vjust = 0.5),
#'
#'       strip.text = ggtext::element_markdown(
#'         colour = bc[3],
#'         size = ggplot2::rel(0.8),
#'         margin = ggplot2::margin(0.8 * half_line, 0.8 * half_line, 0.8 * half_line, 0.8 * half_line)
#'       ),
#'       strip.text.y = ggtext::element_markdown(angle = -90)
#'     )
#' }
#'
#'
#' #' Explicitly draw plot
#' #'
#' #' Generally, you do not need to print or plot a ggplot2 plot explicitly: the
#' #' default top-level print method will do it for you. You will, however, need
#' #' to call `print()` explicitly if you want to draw a plot inside a
#' #' function or for loop.
#' #'
#' #' @param x plot to display
#' #' @param newpage draw new (empty) page first?
#' #' @param vp viewport to draw plot in
#' #' @param ... other arguments not used by this method
#' #' @keywords hplot
#' #' @return Invisibly returns the result of [ggplot_build()], which
#' #'   is a list with components that contain the plot itself, the data,
#' #'   information about the scales, panels etc.
#' #' @export
#' #' @method print ggplot
#' print.ggplot <- function(x, newpage = is.null(vp), vp = NULL, ...) {
#'   bg_fill <- ggplot2::calc_element("plot.background", ggplot2:::plot_theme(x))$fill
#'
#'   ggplot2::set_last_plot(x)
#'   if (newpage) {
#'     grid::grid.newpage()
#'   }
#'   grid::grid.rect(gp = grid::gpar(fill = bg_fill, col = bg_fill))
#'   grDevices::recordGraphics(
#'     requireNamespace("ggplot2", quietly = TRUE),
#'     list(),
#'     getNamespace("ggplot2")
#'   )
#'   data <- ggplot2::ggplot_build(x)
#'   gtable <- ggplot2::ggplot_gtable(data)
#'   if (is.null(vp)) {
#'     grid::grid.draw(gtable)
#'   } else {
#'     if (is.character(vp)) {
#'       grid::seekViewport(vp)
#'     } else {
#'       grid::pushViewport(vp)
#'     }
#'     grid::grid.draw(gtable)
#'     grid::upViewport()
#'   }
#'
#'   invisible(x)
#' }
#'
#' #' @rdname print.ggplot
#' #' @method plot ggplot
#' #' @export
#' plot.ggplot <- print.ggplot
#'
#' #' ggsave
#' #'
#' #' @inheritParams ggplot2::ggsave
#' #' @export
#' ggsave <- function(
#'   filename,
#'   plot = ggplot2::last_plot(),
#'   device = NULL,
#'   path = NULL,
#'   scale = 1,
#'   width = NA,
#'   height = NA,
#'   units = c("in", "cm", "mm"),
#'   dpi = 300,
#'   limitsize = TRUE,
#'   ...
#' ) {
#'   bg_fill <- ggplot2::calc_element("plot.background", ggplot2:::plot_theme(plot))$fill
#'   ggplot2::ggsave(
#'     filename = filename,
#'     plot = plot,
#'     device = device,
#'     path = path,
#'     scale = scale,
#'     width = width,
#'     height = height,
#'     units = units,
#'     dpi = dpi,
#'     limitsize = limitsize,
#'     bg = bg_fill,
#'     ...
#'   )
#' }
#'
#' #' compute_brightness
#' #'
#' #' @param colour vector of any of the three kinds of R color specifications,
#' #'     *i.e.*, either a color name (as listed by colors()),
#' #'     a hexadecimal string of the form "#rrggbb" or "#rrggbbaa" (see rgb).
#' #'
#' #' @keywords internal
#' compute_brightness <- function(colour) {
#'   ((sum(range(grDevices::col2rgb(colour)))) * 100 * 0.5) / 255
#' }
#'
#'
#' #' dark_mode
#' #'
#' #' @param .theme a theme (a list of theme elements)
#' #' @keywords internal
#' dark_mode <- function(.theme) {
#'   stopifnot(is.theme(.theme))
#'   geom_names <- utils::apropos("^Geom", ignore.case = FALSE)
#'   geoms <- list()
#'   namespaces <- loadedNamespaces()
#'   for (namespace in namespaces) {
#'     geoms_in_namespace <- mget(
#'       x = geom_names,
#'       envir = asNamespace(namespace),
#'       ifnotfound = list(NULL)
#'     )
#'     for (geom_name in geom_names) {
#'       if (ggplot2::is.ggproto(geoms_in_namespace[[geom_name]])) {
#'         geoms[[geom_name]] <- geoms_in_namespace[[geom_name]]
#'       }
#'     }
#'   }
#'   pick_colour <- c("white", "black")[(compute_brightness(.theme$plot.background$colour) > 50) + 1]
#'   for (geom in geoms) {
#'     stopifnot(ggplot2::is.ggproto(geom))
#'     if (!is.null(geom$default_aes$fill) && !is.na(geom$default_aes$fill)) {
#'       geom$default_aes$fill <- pick_colour
#'     }
#'     if (!is.null(geom$default_aes$colour) && !is.na(geom$default_aes$colour)) {
#'       geom$default_aes$colour <- pick_colour
#'     }
#'     if (inherits(geom, "GeomBoxplot") | inherits(geom, "GeomLabel")) {
#'       geom$default_aes$fill <- .theme$plot.background$colour
#'     }
#'   }
#'
#'   invisible(.theme)
#' }
#'
#' deploy_site <- function(
#'   input = ".",
#'   dir_list = NULL,
#'   ssh_id = Sys.getenv("id_rsa", ""),
#'   repo_slug = Sys.getenv("TRAVIS_REPO_SLUG", ""),
#'   commit_message = "",
#'   output_format = NULL,
#'   output_file = "index.html",
#'   verbose = FALSE,
#'   ...
#' ) {
#'   if (!nzchar(ssh_id)) {
#'     stop("No deploy key found, please setup with `travis::use_travis_deploy()`",
#'          call. = FALSE
#'     )
#'   }
#'   if (!nzchar(repo_slug)) {
#'     stop("No repo detected, please supply one with `repo_slug`",
#'          call. = FALSE
#'     )
#'   }
#'   cli::rule("Deploying site", line = 2)
#'   ssh_id_file <- "~/.ssh/id_rsa"
#'   cli::rule("Setting up SSH id", line = 1)
#'   cli::cat_line("Copying private key to: ", ssh_id_file)
#'   pkgdown:::write_lines(rawToChar(openssl::base64_decode(ssh_id)), ssh_id_file)
#'   cli::cat_line("Setting private key permissions to 0600")
#'   fs::file_chmod(ssh_id_file, "0600")
#'
#'   dest_dir <- fs::dir_create(fs::file_temp())
#'   on.exit(fs::dir_delete(dest_dir))
#'   pkgdown:::github_clone(dest_dir, repo_slug)
#'   rmarkdown::render(
#'     input = input,
#'     output_dir = dest_dir,
#'     output_format = output_format,
#'     output_file = output_file
#'   )
#'   if (!is.null(dir_list)) {
#'     sapply(
#'       X = dir_list,
#'       FUN = file.copy,
#'       to = dest_dir,
#'       overwrite = TRUE,
#'       recursive = TRUE
#'     )
#'   }
#'   commit_message <- sprintf("Built site for %s: %s@%s", commit_message, Sys.Date(), substr(Sys.getenv("TRAVIS_COMMIT"), 1, 7))
#'   pkgdown:::github_push(dest_dir, commit_message)
#'   cli::rule("Deploy completed", line = 2)
#' }
#'
#' usethis::create_tidy_package("mypackage")
#'
#'
#' usethis::use_news_md(open = FALSE)
#' usethis::edit_file("README.Rmd")
#' rmarkdown::render("README.Rmd",  encoding = 'UTF-8')
#' unlink("README.html")
#'
#' usethis::edit_file(".github/SUPPORT.md")
#'
#' usethis::use_git()
#' usethis::use_github()
#' usethis::use_tidy_ci()
#' usethis::use_appveyor()
#'
#' usethis::use_pkgdown()
#' usethis::use_pkgdown_travis()
#'
#' #' @title FUNCTION_TITLE
#' #' @description FUNCTION_DESCRIPTION
#' #' @param x PARAM_DESCRIPTION
#' #' @return OUTPUT_DESCRIPTION
#' #' @details DETAILS
#' #' @examples
#' #' \dontrun{
#' #' if(interactive()){
#' #'  #EXAMPLE1
#' #'  }
#' #' }
#' #' @rdname duplicated2
#' #' @export
#' duplicated2 <- function(x) {
#'   if (sum(dup <- duplicated(x)) == 0) {
#'     return(dup)
#'   }
#'   if (class(x) %in% c("data.frame", "matrix")) {
#'     duplicated(rbind(x[dup, ], x))[-(1:sum(dup))]
#'   } else {
#'     duplicated(c(x[dup], x))[-(1:sum(dup))]
#'   }
#' }
#'
#' #' @title FUNCTION_TITLE
#' #' @description FUNCTION_DESCRIPTION
#' #' @param FUN PARAM_DESCRIPTION
#' #' @param ... PARAM_DESCRIPTION
#' #' @return OUTPUT_DESCRIPTION
#' #' @details DETAILS
#' #' @rdname hijack
#' #' @export
#' hijack <- function(fun, ...) {
#'   .fun <- fun
#'   args <- list(...)
#'   invisible(lapply(seq_along(args), function(i) {
#'     formals(.fun)[[names(args)[i]]] <<- args[[i]]
#'   }))
#'   .fun
#' }
#'
#' require(rlang)
#' knit_print.video_file <- function(x, options, ...) {
#'   if (grepl('\\.(mp4)|(webm)|(ogg)$', x, ignore.case = TRUE)) {
#'     knitr::knit_print(
#'       htmltools::browsable(
#'         as_html_video(x, width = get_chunk_width(options), autoplay = get_chunk_autoplay(options))
#'       ),
#'       options,
#'       ...
#'     )
#'   } else {
#'     warning('The video format doesn\'t support HTML', call. = FALSE)
#'     invisible(NULL)
#'   }
#' }
#'
#' as_html_video <- function(x, width = NULL, autoplay = TRUE) {
#'   if (!requireNamespace("base64enc", quietly = TRUE)) {
#'     stop('The base64enc package is required for showing video')
#'   }
#'   if (!requireNamespace("htmltools", quietly = TRUE)) {
#'     stop('The htmltools package is required for showing video')
#'   }
#'   format <- tolower(sub('^.*\\.(.+)$', '\\1', x))
#'   htmltools::HTML(paste0(
#'     '<video controls', if (autoplay) ' autoplay' else '',
#'     if (is.null(width)) '' else paste0(' width="', width, '"'),
#'     '><source src="data:video/',
#'     format,
#'     ';base64,',
#'     base64enc::base64encode(x),
#'     '" type="video/mp4"></video>'
#'   ))
#' }
#'
#' get_chunk_autoplay <- function(options) {
#'   options$autoplay %||% TRUE
#' }
#'
#' #' @title FUNCTION_TITLE
#' #' @description FUNCTION_DESCRIPTION
#' #' @param from PARAM_DESCRIPTION
#' #' @param subject PARAM_DESCRIPTION
#' #' @param to PARAM_DESCRIPTION
#' #' @param body PARAM_DESCRIPTION
#' #' @param attachment PARAM_DESCRIPTION
#' #' @return OUTPUT_DESCRIPTION
#' #' @details DETAILS
#' #' @rdname mail
#' #' @export
#' mail <- function (from, subject, to, body, attachment) {
#'   if (missing(subject)) {
#'     eMailSubject <- '-s "(no subject)"'
#'   } else {
#'     eMailSubject <- paste0('-s "', subject, '"')
#'   }
#'   if (missing(to)) {
#'     stop('"to" is missing!')
#'   }
#'   if (missing(body)) {
#'     eMailBody <- 'echo "" |'
#'   } else {
#'     eMailBody <-  paste0('echo "', body, '" |')
#'   }
#'   if (missing(attachment)) {
#'     eMailJoint <- ""
#'   } else {
#'     toAttach <- sapply(seq_along(attachment), function(attach) {
#'       return(!system(paste("test -f", attachment[attach])))
#'     })
#'     if (any(toAttach)) {
#'       eMailJoint <- paste(paste0("-a", attachment[toAttach]), collapse = " ")
#'     } else {
#'       eMailJoint <- ""
#'     }
#'   }
#'   if (missing(from)) {
#'     eMailFrom <- ""
#'   } else {
#'     eMailFrom <- paste("-r", from)
#'   }
#'
#'   system(paste(eMailBody, 'mail', eMailFrom, eMailSubject, eMailJoint, to))
#' }
#'
#' #' format_pval
#' #'
#' #' @param x [numeric] A numeric vector.
#' #' @param thresh [numeric]
#' #' @param digits [numeric] How many significant digits are to be used.
#' #' @param eps [numeric] A numerical tolerance.
#' #' @param math_format [logical]
#' #' @param na.form [character] Character representation of NAs.
#' #' @param ... [misc] Further arguments to be passed to [format()] such as nsmall.
#' #'
#' #' @return A character vector.
#' #' @export
#' format_pval <- function(
#'   x,
#'   thresh = 10^-2,
#'   math_format = FALSE,
#'   digits = max(1L, getOption("digits") - 2L),
#'   eps = .Machine$double.eps,
#'   na.form = "NA",
#'   ...
#' ) {
#'
#'   format_thresh <- function(x, thresh, digits, ...) {
#'     if (x>=thresh) {
#'       format(round(x, digits = digits), ...)
#'     } else {
#'       format(x, digits = digits, scientific = TRUE, ...)
#'     }
#'   }
#'
#'   if ((has_na <- any(ina <- is.na(x)))) {
#'     x <- x[!ina]
#'   }
#'   r <- character(length(is0 <- x < eps))
#'   if (any(!is0)) {
#'     rr <- x <- x[!is0]
#'     expo <- floor(log10(ifelse(x > 0, x, 1e-50)))
#'     fixp <- expo >= -3 | (expo == -4 & digits > 1)
#'     if (any(fixp)) {
#'       rr[fixp] <- format_thresh(
#'         x = x[fixp],
#'         thresh = thresh,
#'         digits = digits,
#'         ...
#'       )
#'     }
#'     if (any(!fixp)) {
#'       rr[!fixp] <- format_thresh(
#'         x = x[!fixp],
#'         thresh = thresh,
#'         digits = digits,
#'         ...
#'       )
#'     }
#'     r[!is0] <- rr
#'   }
#'
#'   if (any(is0)) {
#'     digits <- max(1L, digits - 2L)
#'     if (any(!is0)) {
#'       nc <- max(nchar(rr, type = "w"))
#'       if (digits > 1L && digits + 6L > nc) {
#'         digits <- max(1L, nc - 7L)
#'       }
#'       sep <- if (digits == 1L && nc <= 6L) "" else " "
#'     } else {
#'       sep <- if (digits == 1) "" else " "
#'     }
#'     r[is0] <- paste("<", format(eps, digits = digits, ...), sep = sep)
#'   }
#'
#'   if (has_na) {
#'     rok <- r
#'     r <- character(length(ina))
#'     r[!ina] <- rok
#'     r[ina] <- na.form
#'   }
#'
#'   if (math_format) {
#'     r <- gsub("e", " %*% 10^", r)
#'   }
#'
#'   r
#' }
#'
#'
#' #' capitalise
#' #'
#' #' @param x [character]
#' #'
#' #' @return character
#' #' @export
#' capitalise <- function(x) {
#'   s <- strsplit(x, " ")
#'   sapply(s, function(S) {
#'     paste(toupper(substring(S, 1, 1)), substring(S, 2), sep = "", collapse = " ")
#'   })
#' }
#'
#'
#' #' pretty_kable
#' #'
#' #' @param data [data.frame] An R object, typically a matrix or data frame.
#' #' @param font_size [numeric]
#' #' @param format_args [list]
#' #' @param col.names [character] A character vector of column names to be used in the table.
#' #' @param pval_cols [character]
#' #' @param full_width [logical]
#' #' @param echo [logical]
#' #' @param ... [misc]
#' #'
#' #' @return kable
#' #' @export
#' pretty_kable <- function (
#'   data,
#'   font_size = 12,
#'   format_args = list(scientific = -1, digits = 3, big.mark = ","),
#'   col.names = NA,
#'   pval_cols = NULL,
#'   full_width,
#'   echo = TRUE,
#'   ...
#' ) {
#'
#'   if (!is.null(pval_cols)) {
#'     data[, pval_cols] <- format_pval(
#'       x = data[, pval_cols],
#'       digits = format_args$digits
#'     )
#'   }
#'   colnames(data) <- capitalise(colnames(data))
#'
#'   out <- if (knitr::is_latex_output()) {
#'     options(knitr.table.format = "latex")
#'     output <- knitr::kable(x = data, booktabs = TRUE, format.args = format_args, col.names = col.names, ...)
#'     kableExtra::kable_styling(
#'       kable_input = output,
#'       latex_options = c("striped", "hold_position"),
#'       full_width = ifelse(missing(full_width), FALSE, full_width),
#'       position = "center",
#'       font_size = font_size
#'     )
#'   } else {
#'     options(knitr.table.format = "html")
#'     output <- knitr::kable(x = data, format.args = format_args, col.names = col.names, ...)
#'     kableExtra::kable_styling(
#'       kable_input = output,
#'       bootstrap_options = c("striped", "hover", "condensed", "responsive"),
#'       full_width = ifelse(missing(full_width), TRUE, full_width),
#'       position = "center",
#'       font_size = font_size
#'     )
#'   }
#'
#'   if (echo) print(out)
#'
#'   invisible(out)
#' }
#'
#' #' se
#' #'
#' #' @param x [numeric] A numeric vector or an R object which is coercible to one by as.double(x).
#' #' @param na.rm [logical] Should missing values be removed?
#' #'
#' #' @return numeric
#' #' @export
#' se <- function(x, na.rm = TRUE) {
#'   sqrt(
#'     (mean(x^2, na.rm = na.rm) - mean(x, na.rm = na.rm)^2) / sum(!is.na(x))
#'   )
#' }
#'
#'
#' #' row_se
#' #'
#' #' @inheritParams se
#' #'
#' #' @return numeric
#' #' @export
#' row_se <- function(x, na.rm = TRUE) {
#'   if (na.rm) {
#'     n <- rowSums(!is.na(x))
#'   } else {
#'     n <- nrow(x)
#'   }
#'   rowVar <- rowMeans(x * x, na.rm = na.rm) - (rowMeans(x, na.rm = na.rm))^2
#'   sqrt(rowVar / n)
#' }
#'
#' #' col_se
#' #'
#' #' @inheritParams se
#' #'
#' #' @return numeric
#' #' @export
#' col_se <- function(x, na.rm = TRUE) {
#'   if (na.rm) {
#'     n <- colSums(!is.na(x))
#'   } else {
#'     n <- nrow(x)
#'   }
#'   colVar <- colMeans(x * x, na.rm = na.rm) - (colMeans(x, na.rm = na.rm))^2
#'   sqrt(colVar / n)
#' }
#'
#' #' row_sd
#' #'
#' #' @inheritParams se
#' #'
#' #' @return numeric
#' #' @export
#' row_sd <- function(x, na.rm = TRUE) {
#'   if (na.rm) {
#'     n <- rowSums(!is.na(x))
#'   } else {
#'     n <- ncol(x)
#'   }
#'   rowVar <- rowMeans(x * x, na.rm = na.rm) - (rowMeans(x, na.rm = na.rm))^2
#'   sqrt(rowVar * n / (n - 1))
#' }
#'
#' #' col_sd
#' #'
#' #' @inheritParams se
#' #'
#' #' @return numeric
#' #' @export
#' col_sd <- function(x, na.rm = TRUE) {
#'   if (na.rm) {
#'     n <- colSums(!is.na(x))
#'   } else {
#'     n <- nrow(x)
#'   }
#'   colVar <- colMeans(x * x, na.rm = na.rm) - (colMeans(x, na.rm = na.rm))^2
#'   sqrt(colVar * n / (n - 1))
#' }

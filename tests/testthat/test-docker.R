context("Test docker or Dockerfile related function.")

pattern <- "aaa"

scoped_temporary_project <- function(dir = fs::file_temp(pattern = pattern),
                                     env = parent.frame(),
                                     rstudio = FALSE) {
  scoped_temporary_thing(dir, env, rstudio, "project")
}

test_that("use_docker creates a Dockerfile", {
  dir <- fs::path_rel(fs::path_package(package = "jimstemplates", "testapp"))
  dockermeta <- create_dockerfile(path = dir)
  pkgdeps <- get_package_deps(path = dir)
  sysreqs <- get_sysreqs(pkgdeps$package)
  testthat::expect_equal(dockermeta$package_deps, pkgdeps)
  testthat::expect_equal(dockermeta$sysreqs, sysreqs)
  testthat::expect_true(file.exists(fs::path(dir, "Dockerfile")))
  testthat::expect_true(file.exists(fs::path(dir, "deps.yaml")))
  testthat::expect_true(file.exists(fs::path(dir, "deps.R")))
})

# test_that("use_docker_packages fails if there is no Dockerfile",{
#   scoped_temporary_project()
#   expect_oops(use_docker_packages("here"))
# })
#
# test_that("use_docker_packages warns about github packages",{
#   scoped_temporary_project()
#   use_docker()
#   # should warn about no github=TRUE
#   expect_warning(use_docker_packages("r-lib/usethis@b2e894e", open = FALSE),
#                  "github = TRUE")
#   # should warn about missing fixed version
#   expect_error(
#     use_docker_packages("r-lib/usethis",
#                         github = TRUE,
#                         open = FALSE),
#     "fixed version",
#     class = "usethis_error"
#   )
#   # shouldn't warn about anything
#   expect_warning(use_docker_packages("r-lib/usethis@b2e894e",
#                                      github = TRUE,
#                                      open = FALSE),
#                  NA)
#   expect_warning(use_docker_packages("usethis",
#                                      github = TRUE,
#                                      open = FALSE),
#                  NA)
# })
#
# test_that("docker_entry_install returns only characters", {
#   expect_length(docker_entry_install("test",
#                                      "installGithub.r"), 2L)
#
#   expect_length(docker_entry_install(c("test", "another_test"),
#                                      "installGithub.r"), 3L)
#
#   expect_identical(docker_entry_install("test",
#                                         "installGithub.r"),
#                    c("RUN installGithub.r \\ ", "  test"))
#
#   expect_identical(docker_entry_install(c("test", "another_test"),
#                                         "installGithub.r"),
#                    c("RUN installGithub.r \\ ", "  test \\ ", "  another_test"))
# })
#
# test_that("use_docker_packages actually adds them to the Dockerfile", {
#   scoped_temporary_package()
#   use_docker()
#   use_docker_packages(c("test1", "test2"))
#   dockerfile <- readLines("Dockerfile")
#   expect_match(dockerfile, "test1", all = FALSE)
#   expect_match(dockerfile, "test2", all = FALSE)
# })
#
# test_that("docker entry only appends stuff", {
#   scoped_temporary_package()
#   use_docker()
#   dockerfile1 <- readLines("Dockerfile")
#   docker_entry("test", write = TRUE, open = TRUE, append = TRUE)
#   dockerfile2 <- readLines("Dockerfile")
#   expect_identical(dockerfile1, dockerfile2[-length(dockerfile2)])
#   expect_identical(dockerfile2[length(dockerfile2)], "test")
#
#   dockerfile3 <- docker_entry("test", write = FALSE, open = TRUE, append = TRUE)
#   expect_identical(dockerfile3, c(dockerfile2, "test"))
# })
#
# test_that("docker_get extracts correct lines", {
#   scoped_temporary_project()
#   use_docker()
#   # cat(dockerfile, file = "Dockerfile")
#   expect_identical(docker_get_packages(),
#                    c("anytime", "dplyr", "lubridate", "readr", "usethis"))
# })
#
#
#
#
# scoped_temporary_thing <- function(dir = fs::file_temp(pattern = pattern),
#                                    env = parent.frame(),
#                                    rstudio = FALSE,
#                                    thing = c("package", "project")) {
#   thing <- match.arg(thing)
#   if (fs::dir_exists(dir)) {
#     ui_stop("Target {usethis::ui_code('dir')} {usethis::ui_path(dir)} already exists.")
#   }
#
#   old_project <- usethis:::proj$cur
#   ## Can't schedule a deferred project reset if calling this from the R
#   ## console, which is useful when developing tests
#   if (identical(env, globalenv())) {
#     usethis::ui_done("Switching to a temporary project!")
#     if (!is.null(old_project)) {
#       command <- paste0('proj_set(\"', old_project, '\")')
#       usethis::ui_todo(
#         "Restore current project with: {usethis::ui_code(command)}"
#       )
#     }
#   } else {
#     withr::defer({
#       withr::with_options(
#         list(usethis.quiet = TRUE),
#         usethis::proj_set(old_project, force = TRUE)
#       )
#       setwd(old_project)
#       fs::dir_delete(dir)
#     }, envir = env)
#   }
#
#   withr::local_options(list(usethis.quiet = TRUE))
#   switch(
#     thing,
#     package = usethis::create_package(dir, rstudio = rstudio, open = FALSE,
#                                       check_name = FALSE),
#     project = usethis::create_project(dir, rstudio = rstudio, open = FALSE)
#   )
#   usethis::proj_set(dir)
#   setwd(dir)
#   invisible(dir)
# }
#
#

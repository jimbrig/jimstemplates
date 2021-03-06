% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dockerfile.R
\name{create_dockerfile}
\alias{create_dockerfile}
\title{Create Dockerfile from Template}
\usage{
create_dockerfile(
  base_image = "merlinoa/shiny_run_custom",
  app_config = "default",
  mainainer = whoami::whoami()["fullname"],
  date = Sys.Date(),
  packages = get_package_deps()[["package"]],
  additional_r_commands = NULL
)
}
\arguments{
\item{base_image}{base image for \code{FROM} in Dockerfile}

\item{app_config}{app config, defaults to \code{default}}

\item{date}{date - defaults to \code{\link[base:Sys.time]{base::Sys.Date()}}}

\item{packages}{R package dependencies returned from \code{\link[=get_package_deps]{get_package_deps()}}}

\item{additional_r_commands}{any additional r commands to include in image}

\item{maintainer}{maintainer - defaults to \code{fullname} from \code{\link[whoami:whoami]{whoami::whoami()}}}

\item{sysreqs}{logical - should sysreqs be included in image (via \code{\link[=get_sysreqs]{get_sysreqs()}})}
}
\value{

}
\description{
Create Dockerfile from Template
}

#' Open local version of pkgdown site for {{pkgname}}
#'
#' @importFrom utils browseURL
#'
#' @export
open_docs <- function() {

  guide_path <- system.file('docs/index.html', package = '{{pkgname}}')

  if (guide_path == "") {
    stop('There is no pkgdown site in ', 'docs/index.html')
  }

  utils::browseURL(paste0('file://', guide_path))

}

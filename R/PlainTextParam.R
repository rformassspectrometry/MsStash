#' @title Store contents of MS objects as plain text files
#'
#' @name PlainTextParam
#'
#' @aliases PlainTextParam-class
#'
#' @export
#'
#' @family MS object export and import formats.
#'
#' @description
#'
#' The `saveMsObject()` and `readMsObject()` methods with the `PlainTextParam`
#' option enable users to save/load different type of mass spectrometry (MS)
#' object as a collections of plain text files in/from a specified folder.
#' This folder, defined with the `path` parameter, will be created by the
#' `saveMsObject()` function. Writing data to a folder that contains already
#' exported data will result in an error.
#'
#' For `PlainTextParam` all data is expected to be exported to plain text files,
#' where possible as tabulator delimited text files.
#'
#' To support writing/reading with `PlainTextParam`, the `saveMsData()` and
#' `readMsData()` methods have to be implemented for the respective class.
#'
#' See the package vignette for example implementations and details.
#'
#' @param path For `PlainTextParam()`: `character(1)`, defining where the files
#'   are going to be stored/ should be loaded from. The default is
#'   `path = tempdir()`.
#'
#' @return For `PlainTextParam()`: a `PlainTextParam` class. `saveMsObject()`
#' does not return anything but saves the object to collections of different
#' plain text files to a folder. The `readMsObject()` method returns the
#' restored data as an instance of the class specified with parameter `object`.
#'
#' @author Philippine Louail, Johannes Rainer
#'
#' @importFrom methods new
#'
#' @importClassesFrom ProtGenerics Param
#'
#' @examples
#'
#' ## Create a PlainTextParam object
#' p <- PlainTextParam()
#' p
#'
#' ## For example implementations and details see the package vignette
NULL

#' @noRd
#'
#' @export
setClass("PlainTextParam",
         slots = c(path = "character"),
         contains = "Param",
         prototype = prototype(
             path = character()),
         validity = function(object) {
             msg <- NULL
             if (length(object@path) != 1)
                 msg <- c("'path' has to be a character string of length 1")
             msg
         })

#' @rdname PlainTextParam
#'
#' @export
PlainTextParam <- function(path = tempdir()) {
    new("PlainTextParam", path = path)
}

#' @include PlainTextParam.R
#'
#' @title Store MS data objects using the alabaster framework
#'
#' @aliases AlabasterParam-class
#'
#' @name AlabasterParam
#'
#' @family MS object export and import formats.
#'
#' @description
#'
#' The [*alabaster* framework](https://github.com/ArtifactDB/alabaster.base)
#' provides the methodology to save R objects to on-disk representations/
#' storage modes which are programming language independent (in contrast to
#' e.g. R's RDS files). By using standard file formats such as JSON and HDF5,
#' alabaster ensures that the data can also be read and imported by other
#' programming languages such as Python or Javascript. This improves
#' interoperability between application ecosystems.
#'
#' The *alabaster* package defines the [alabaster.base::saveObject()] and
#' [alabaster.base::readObject()] methods that have to be implemented for
#' specific data classes to enable saving to or reading from alabaster-based
#' file formats.
#'
#' In addition, the *MsStash* package defines the `AlabasterParam` which can be
#' used to write or read MS objects using the `saveMsObject()` and
#' `readMsObject()` methods in alabaster format. This allows additional
#' configurations and customizations to the export or import process. It is
#' thus for example possible to specify the path to the original MS data files
#' for *on-disk* MS representations such as the `Spectra::MsBackendMzR` which
#' enables to import a stored object even if either the object or the original
#' MS data files have been moved to a different directory or file system.
#'
#' In order to enable alabaster-based import/export, the respective methods have
#' to be implemented for the class. See the package vignette for examples and
#' details.
#'
#' @details
#'
#' Importantly, it is only possible to save **one object in one directory**. To
#' overwrite an existing stored object in a folder, that folder has to be
#' deleted beforehand.
#'
#' @param path `character(1)` with the name of the directory where the MS data
#'     object should be saved to or from which it should be restored.
#'     Importantly, path should point to a **new** folder, i.e. a directory
#'     that **does not already exist**.
#'
#' @return For `AlabasterParam()`: an instance of `AlabasterParam` class. For
#'     `readObject()` the exported object in the specified path (depending on
#'     the type of object defined in the *OBJECT* file in the path. For
#'     `readMsObject()` the exported data object, defined with the function's
#'     first parameter, from the specified path. `saveObject()` and
#'     `saveMsObject()` don't return anything.
#'
#' @author Johannes Rainer, Philippine Louail
#'
#' @examples
#'
#' ## Create an AlabasterParam object
#' a <- AlabasterParam(path = tempdir())
#' a
#'
#' ## See the package vignette for example implementation and usage.
NULL

#' @noRd
#'
#' @export
setClass("AlabasterParam",
         contains = "PlainTextParam")

#' @rdname AlabasterParam
#'
#' @export
AlabasterParam <- function(path = tempdir()) {
    new("AlabasterParam", path = path)
}

# Storage Modes of MS Data Objects

## Introduction

Data objects in R can be serialized to disk in R’s *Rds* format using
the base R [`save()`](https://rdrr.io/r/base/save.html) function and
re-imported using the [`load()`](https://rdrr.io/r/base/load.html)
function. This R-specific binary data format can however not be used or
read by other programming languages preventing thus the exchange of R
data objects between software or programming languages. The *MsStash*
package defines basic classes and generic methods to export and import
mass spectrometry data objects in various storage formats aiming to
facilitate data exchange between software. This includes, among other
formats, also storage of data objects using Bioconductor’s
*[alabaster.base](https://bioconductor.org/packages/3.23/alabaster.base)*
package.

For export or import of MS data objects, the
[`saveMsObject()`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)
and
[`readMsObject()`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)
functions can be used. For
[`saveMsObject()`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md),
the first parameter is the MS data object that should be stored, for
[`readMsObject()`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)
it defines type of MS object that should be restored (returned). The
second parameter `param` defines and configures the storage format of
the MS data. The currently supported formats and the respective
parameter objects are:

- `PlainTextParam`: storage of data in (a custom) plain text file
  format.
- `AlabasterParam`: storage of MS data using Bioconductor’s
  *[alabaster.base](https://bioconductor.org/packages/3.23/alabaster.base)*
  framework based files in HDF5 and JSON format.

These storage formats are described in more details in the following
sections.

An example use of these functions and parameters:
`saveMsObject(x, param = PlainTextParam(storage_path))` to store an MS
data object assigned to a variable `x` to a directory `storage_path`
using the plain text file format. To restore the data (assuming `x` was
an instance of a `MsExperiment` class):
`readMsObject(MsExperiment(), param = PlainTextParam(storage_path))`.

## Installation

The package can be installed with the *BiocManager* package. To install
*BiocManager* use `install.packages("BiocManager")` and, after that,
`BiocManager::install("RforMassSpectrometry/MsStash")` to install this
package.

## Example implementations

To illustrate how the save/read functionality can be implemented for a
specific data class, we first define a simple toy R S4 object to
represent the data from a single mass spectrum. This `MySpectrum` class
contains slots to hold the spectrum’s *m/z* and intensity values as well
as some (limited) metadata.

``` r

#' Class definition
setClass("MySpectrum",
         slots = c(mz = "numeric",
                   intensity = "numeric",
                   rtime = "numeric",
                   msl = "integer"),
         prototype = prototype(
             mz = numeric(),
             intensity = numeric(),
             rtime = numeric(),
             msl = integer()))

#' Default constructor function
MySpectrum <- function(mz = numeric(), intensity = numeric(),
                       rtime = numeric(), msl = integer()) {
    stopifnot(length(mz) == length(intensity))
    if (length(mz) && !length(rtime)) rtime <- NA_real_
    if (length(mz) && !length(msl)) msl <- NA_integer_
    new("MySpectrum", mz = mz, intensity = intensity, rtime = rtime,
        msl = as.integer(msl))
}
```

We can now create an example `MySpectrum` object.

``` r

s <- MySpectrum(c(1.4, 1.6, 1.9, 2.56), c(123.1, 1235.3, 12.45, 51.5))
s
```

    ## An object of class "MySpectrum"
    ## Slot "mz":
    ## [1] 1.40 1.60 1.90 2.56
    ## 
    ## Slot "intensity":
    ## [1]  123.10 1235.30   12.45   51.50
    ## 
    ## Slot "rtime":
    ## [1] NA
    ## 
    ## Slot "msl":
    ## [1] NA

### Suggested properties of implemented methods

To ensure consistency, the
[`saveMsObject()`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)
should:

- first create the directory to which the data should be exported
  (defined by param `path`).
- throw an error if the directory exists or contains already an exported
  object (avoiding thus accidental overwriting and eventual data
  corruption/inconsistencies).

Both methods support also `...`, hence, if needed, additional parameters
can be added to an implementation of the generic method if needed.

### `PlainTextParam`

Storage of MS data objects in *plain* text format aims to support an
easy exchange of data, and in particular analysis results, with external
software, such as
[MS-DIAL](https://systemsomicslab.github.io/compms/msdial/main.html) or
[mzmine3](http://mzmine.github.io/download.md). In most cases, the data
is stored as tabulator delimited text files simplifying the use of the
data and results across multiple programming languages, or their import
into spreadsheet applications. MS data objects stored in plain text
format can also be fully re-imported into R providing thus an
alternative, and more flexible, object serialization approach than the R
internal *Rds*/*RData* format.

We implement a
[`saveMsObject()`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)
method for our `MySpectrum` class and the `PlainTextParam`. This
function first creates the required directory and throws an error if an
result file is already stored there. Then it exports the data: for our
example we store the data of the object into a single text file in a
custom format we define: the metadata if first written to the file, one
line per metadata item followed by the *m/z* and intensity values, each
*m/z*-intensity pair in one line separated by a tabulator.

``` r

library(MsStash)
setMethod("saveMsObject", signature(object = "MySpectrum",
                                    param = "PlainTextParam"),
          function(object, param) {
              dir.create(path = param@path, recursive = TRUE,
                         showWarnings = FALSE)
              fl <- file.path(param@path, "my_spectrum.txt")
              if (file.exists(fl))
                  stop("Overwriting an existing result object is not ",
                       "supported.")
              ## Write the type of object as a comment followed by the
              ## metadata.
              writeLines(c(paste0("# ", class(object)[1L]),
                           paste0("rtime:", object@rtime),
                           paste0("msl:", object@msl)), con = fl)
              ## Write the peak data, i.e. m/z and intensity values
              write.table(cbind(object@mz, object@intensity), file = fl,
                          sep = "\t", append = TRUE, col.names = FALSE,
                          row.names = FALSE)
          })
```

We next export our example object `s` with the `saveMsData()` method to
a temporary folder.

``` r

p <- PlainTextParam(path = file.path(tempdir(), "text_format"))
saveMsObject(s, p)
```

The data was thus exported to this text file. The individual lines are:

``` r

readLines(file.path(p@path, "my_spectrum.txt"))
```

    ## [1] "# MySpectrum" "rtime:NA"     "msl:NA"       "1.4\t123.1"   "1.6\t1235.3" 
    ## [6] "1.9\t12.45"   "2.56\t51.5"

We next implement the
[`readMsObject()`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)
method for this class. This function will read the text file content and
assign the imported values to the different slots of the `MySpectrum`
class.

``` r

setMethod("readMsObject", signature(object = "MySpectrum",
                                    param = "PlainTextParam"),
          function(object, param) {
              fl <- file.path(param@path, "my_spectrum.txt")
              if (!file.exists(fl))
                  stop("my_spectrum.txt not found in the provided path")
              l <- readLines(fl, n = 3) # read the comment and the metadata
              p <- read.table(fl, sep = "\t", skip = 3)
              MySpectrum(
                  mz = p[, 1L], intensity = p[, 2L],
                  rtime = suppressWarnings(
                      as.numeric(sub("rtime:", "", l[2], fixed = TRUE))),
                  msl = suppressWarnings(
                      as.integer(sub("msl:", "", l[3], fixed = TRUE))))
          })
```

We can now restore our `MySpectrum` object with the
[`readMsObject()`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)
method from the exported text file:

``` r

p <- PlainTextParam(path = file.path(tempdir(), "text_format"))
b <- readMsObject(MySpectrum(), p)
b
```

    ## An object of class "MySpectrum"
    ## Slot "mz":
    ## [1] 1.40 1.60 1.90 2.56
    ## 
    ## Slot "intensity":
    ## [1]  123.10 1235.30   12.45   51.50
    ## 
    ## Slot "rtime":
    ## [1] NA
    ## 
    ## Slot "msl":
    ## [1] NA

### `AlabasterParam`

The [alabaster framework](https://github.com/ArtifactDB/alabaster.base)
and related Bioconductor package
*[alabaster.base](https://bioconductor.org/packages/3.23/alabaster.base)*
implements methods to save a variety of R/Bioconductor objects to
on-disk representations based on standard file formats like HDF5 and
JSON. This ensures that Bioconductor objects can be easily read from
other languages like Python and Javascript. With `AlabasterParam`,
*MsStash* supports export of MS data objects into these storage formats.

## Session information

``` r

sessionInfo()
```

    ## R Under development (unstable) (2026-04-19 r89916)
    ## Platform: x86_64-pc-linux-gnu
    ## Running under: Ubuntu 24.04.4 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
    ## LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
    ## 
    ## locale:
    ##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
    ##  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
    ##  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
    ##  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
    ##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    ## [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
    ## 
    ## time zone: UTC
    ## tzcode source: system (glibc)
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ## [1] MsStash_0.0.1    BiocStyle_2.39.0
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] cli_3.6.6           knitr_1.51          rlang_1.2.0        
    ##  [4] xfun_0.57           ProtGenerics_1.43.0 otel_0.2.0         
    ##  [7] textshaping_1.0.5   jsonlite_2.0.0      htmltools_0.5.9    
    ## [10] ragg_1.5.2          sass_0.4.10         rmarkdown_2.31     
    ## [13] evaluate_1.0.5      jquerylib_0.1.4     fastmap_1.2.0      
    ## [16] yaml_2.3.12         lifecycle_1.0.5     bookdown_0.46      
    ## [19] BiocManager_1.30.27 compiler_4.7.0      fs_2.1.0           
    ## [22] htmlwidgets_1.6.4   systemfonts_1.3.2   digest_0.6.39      
    ## [25] R6_2.6.1            bslib_0.10.0        tools_4.7.0        
    ## [28] pkgdown_2.2.0.9000  cachem_1.1.0        desc_1.4.3

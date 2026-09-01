# Storage Modes of MS Data Objects

## Introduction

Data objects in R can be serialized to disk in R’s *Rds* format using
the base R [`save()`](https://rdrr.io/r/base/save.html) function and
re-imported using the [`load()`](https://rdrr.io/r/base/load.html)
function. This R-specific binary data format can however not be used or
read by other programming languages preventing thus the exchange of R
data objects between software or programming languages. The *MsStash*
package defines basic classes and generic methods to export and import
mass spectrometry (MS) data objects in various storage formats aiming to
facilitate data exchange between software. This includes, among other
formats, also storage of data objects using Bioconductor’s
*[alabaster.base](https://bioconductor.org/packages/3.24/alabaster.base)*
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
  *[alabaster.base](https://bioconductor.org/packages/3.24/alabaster.base)*
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
`BiocManager::install("MsStash")` to install this package.

## Example implementations

To illustrate how the save/read functionality can be implemented for a
specific data class, we first define a simple toy R S4 object to
represent the data from a single mass spectrum. This `MySpectrum` class
contains slots to hold the spectrum’s *m/z* and intensity values as well
as some (limited) metadata.

`#' Class definition`` ``setClass``(``"MySpectrum"``,`` `` slots ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``mz ``=`` ``"numeric"``,`` `` intensity ``=`` ``"numeric"``,`` `` rtime ``=`` ``"numeric"``,`` `` msl ``=`` ``"integer"``)``,`` `` prototype ``=`` ``prototype``(`` `` mz ``=`` `[`numeric`](https://rdrr.io/r/base/numeric.html)`(``)``,`` `` intensity ``=`` `[`numeric`](https://rdrr.io/r/base/numeric.html)`(``)``,`` `` rtime ``=`` `[`numeric`](https://rdrr.io/r/base/numeric.html)`(``)``,`` `` msl ``=`` `[`integer`](https://rdrr.io/r/base/integer.html)`(``)``)``)`` `` ``#' Default constructor function`` ``MySpectrum`` ``<-`` ``function``(``mz`` ``=`` `[`numeric`](https://rdrr.io/r/base/numeric.html)`(``)``, ``intensity`` ``=`` `[`numeric`](https://rdrr.io/r/base/numeric.html)`(``)``,`` `` ``rtime`` ``=`` `[`numeric`](https://rdrr.io/r/base/numeric.html)`(``)``, ``msl`` ``=`` `[`integer`](https://rdrr.io/r/base/integer.html)`(``)``)`` ``{`` `` `[`stopifnot`](https://rdrr.io/r/base/stopifnot.html)`(`[`length`](https://rdrr.io/r/base/length.html)`(``mz``)`` ``==`` `[`length`](https://rdrr.io/r/base/length.html)`(``intensity``)``)`` `` ``if`` ``(`[`length`](https://rdrr.io/r/base/length.html)`(``mz``)`` ``&&`` ``!`[`length`](https://rdrr.io/r/base/length.html)`(``rtime``)``)`` ``rtime`` ``<-`` ``NA_real_`` `` ``if`` ``(`[`length`](https://rdrr.io/r/base/length.html)`(``mz``)`` ``&&`` ``!`[`length`](https://rdrr.io/r/base/length.html)`(``msl``)``)`` ``msl`` ``<-`` ``NA_integer_`` `` ``new``(``"MySpectrum"``, mz ``=`` ``mz``, intensity ``=`` ``intensity``, rtime ``=`` ``rtime``,`` `` msl ``=`` `[`as.integer`](https://rdrr.io/r/base/integer.html)`(``msl``)``)`` ``}`

We can now create an example `MySpectrum` object.

`s`` ``<-`` ``MySpectrum``(`[`c`](https://rdrr.io/r/base/c.html)`(``1.4``, ``1.6``, ``1.9``, ``2.56``)``, `[`c`](https://rdrr.io/r/base/c.html)`(``123.1``, ``1235.3``, ``12.45``, ``51.5``)``)`` ``s`

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

[`library`](https://rdrr.io/r/base/library.html)`(`[`MsStash`](https://github.com/RforMassSpectrometry/MsStash)`)`

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

`#' Write example class to a plain text file`` ``setMethod``(``"saveMsObject"``, ``signature``(``object ``=`` ``"MySpectrum"``,`` `` param ``=`` ``"PlainTextParam"``)``,`` `` ``function``(``object``, ``param``)`` ``{`` `` `[`dir.create`](https://rdrr.io/r/base/files2.html)`(``path ``=`` ``param``@``path``, recursive ``=`` ``TRUE``,`` `` showWarnings ``=`` ``FALSE``)`` `` ``fl`` ``<-`` `[`file.path`](https://rdrr.io/r/base/file.path.html)`(``param``@``path``, ``"my_spectrum.txt"``)`` `` ``if`` ``(`[`file.exists`](https://rdrr.io/r/base/files.html)`(``fl``)``)`` `` `[`stop`](https://rdrr.io/r/base/stop.html)`(``"Overwriting an existing result object is not "``,`` `` ``"supported."``)`` `` ``## Write the type of object as a comment followed by the`` `` ``## metadata.`` `` `[`writeLines`](https://rdrr.io/r/base/writeLines.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``"# "``, `[`class`](https://rdrr.io/r/base/class.html)`(``object``)``[``1L``]``)``,`` `` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"rtime:"``, ``object``@``rtime``)``,`` `` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"msl:"``, ``object``@``msl``)``)``, con ``=`` ``fl``)`` `` ``## Write the peak data, i.e. m/z and intensity values`` `` `[`write.table`](https://rdrr.io/r/utils/write.table.html)`(`[`cbind`](https://rdrr.io/r/base/cbind.html)`(``object``@``mz``, ``object``@``intensity``)``, file ``=`` ``fl``,`` `` sep ``=`` ``"\t"``, append ``=`` ``TRUE``, col.names ``=`` ``FALSE``,`` `` row.names ``=`` ``FALSE``)`` `` ``}``)`

We next export our example object `s` with the `saveMsData()` method to
a temporary folder.

`p`` ``<-`` `[`PlainTextParam`](https://rformassspectrometry.github.io/MsStash/reference/PlainTextParam.md)`(``path ``=`` `[`file.path`](https://rdrr.io/r/base/file.path.html)`(`[`tempdir`](https://rdrr.io/r/base/tempfile.html)`(``)``, ``"text_format"``)``)`` `[`saveMsObject`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)`(``s``, ``p``)`

The data was thus exported to this text file. The individual lines are:

[`readLines`](https://rdrr.io/r/base/readLines.html)`(`[`file.path`](https://rdrr.io/r/base/file.path.html)`(``p``@``path``, ``"my_spectrum.txt"``)``)`

    ## [1] "# MySpectrum" "rtime:NA"     "msl:NA"       "1.4\t123.1"   "1.6\t1235.3" 
    ## [6] "1.9\t12.45"   "2.56\t51.5"

We next implement the
[`readMsObject()`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)
method for this class. This function will read the text file content and
assign the imported values to the different slots of the `MySpectrum`
class.

`#' Read example object from plain text file storage format`` ``setMethod``(``"readMsObject"``, ``signature``(``object ``=`` ``"MySpectrum"``,`` `` param ``=`` ``"PlainTextParam"``)``,`` `` ``function``(``object``, ``param``)`` ``{`` `` ``fl`` ``<-`` `[`file.path`](https://rdrr.io/r/base/file.path.html)`(``param``@``path``, ``"my_spectrum.txt"``)`` `` ``if`` ``(``!`[`file.exists`](https://rdrr.io/r/base/files.html)`(``fl``)``)`` `` `[`stop`](https://rdrr.io/r/base/stop.html)`(``"my_spectrum.txt not found in the provided path"``)`` `` ``l`` ``<-`` `[`readLines`](https://rdrr.io/r/base/readLines.html)`(``fl``, n ``=`` ``3``)`` ``# read the comment and the metadata`` `` ``p`` ``<-`` `[`read.table`](https://rdrr.io/r/utils/read.table.html)`(``fl``, sep ``=`` ``"\t"``, skip ``=`` ``3``)`` `` ``MySpectrum``(`` `` mz ``=`` ``p``[``, ``1L``]``, intensity ``=`` ``p``[``, ``2L``]``,`` `` rtime ``=`` `[`suppressWarnings`](https://rdrr.io/r/base/warning.html)`(`` `` `[`as.numeric`](https://rdrr.io/r/base/numeric.html)`(`[`sub`](https://rdrr.io/r/base/grep.html)`(``"rtime:"``, ``""``, ``l``[``2``]``, fixed ``=`` ``TRUE``)``)``)``,`` `` msl ``=`` `[`suppressWarnings`](https://rdrr.io/r/base/warning.html)`(`` `` `[`as.integer`](https://rdrr.io/r/base/integer.html)`(`[`sub`](https://rdrr.io/r/base/grep.html)`(``"msl:"``, ``""``, ``l``[``3``]``, fixed ``=`` ``TRUE``)``)``)``)`` `` ``}``)`

We can now restore our `MySpectrum` object with the
[`readMsObject()`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)
method from the exported text file:

`p`` ``<-`` `[`PlainTextParam`](https://rformassspectrometry.github.io/MsStash/reference/PlainTextParam.md)`(``path ``=`` `[`file.path`](https://rdrr.io/r/base/file.path.html)`(`[`tempdir`](https://rdrr.io/r/base/tempfile.html)`(``)``, ``"text_format"``)``)`` ``b`` ``<-`` `[`readMsObject`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)`(``MySpectrum``(``)``, ``p``)`` ``b`

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
*[alabaster.base](https://bioconductor.org/packages/3.24/alabaster.base)*
implements methods to save a variety of R/Bioconductor objects to
on-disk representations based on standard file formats like HDF5 and
JSON. This ensures that Bioconductor objects can be easily read from
other languages like Python and Javascript. With `AlabasterParam`,
*MsStash* provides a parameter class to configure saving MS data objects
in the *alabaster* storage format.

To enable writing in this format a
[`saveMsObject()`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)
method should be implemented for the MS data object and
`AlabasterParam`. To enable full *alabaster* support it is also
suggested to implement the
[`alabaster.base::saveObject`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)
method, a validation method and a function to read from an alabaster
format. For more details refer also to the package vignette of the
*[alabaster.base](https://bioconductor.org/packages/3.24/alabaster.base)*
package, in particular chapter 5 *Extending to new classes*.

We below define a
[`saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)
method. The generic for this method is defined in the *alabaster.base*
package. While it would be possible to simply save the data as simple
text files as we did above, we use *alabaster*’s strategy to allow
storage of more complex objects (such as S4 objects in the individual
slots). This uses
[`altSaveObject()`](https://rdrr.io/pkg/alabaster.base/man/altSaveObject.html)
and
[`altReadObject()`](https://rdrr.io/pkg/alabaster.base/man/altReadObject.html)
to save individual slots or parent/child classes in sub-directories of
`path`. For each of these classes, a
[`saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)
needs to be defined.

[`library`](https://rdrr.io/r/base/library.html)`(`[`alabaster.base`](https://github.com/ArtifactDB/alabaster.base)`)`` `` ``setMethod``(``"saveObject"``, ``"MySpectrum"``, ``function``(``x``, ``path``, ``...``)`` ``{`` `` ``## Create the directory where to save the data`` `` `[`dir.create`](https://rdrr.io/r/base/files2.html)`(``path ``=`` ``path``, recursive ``=`` ``TRUE``, showWarnings ``=`` ``FALSE``)`` `` ``## Create an "object" file; this defines the type of object stored in path`` `` `[`saveObjectFile`](https://rdrr.io/pkg/alabaster.base/man/readObjectFile.html)`(``path``, ``"my_spectrum"``)`` `` ``## save each slot into it's own directory`` `` `[`altSaveObject`](https://rdrr.io/pkg/alabaster.base/man/altSaveObject.html)`(``x``@``mz``, path ``=`` `[`file.path`](https://rdrr.io/r/base/file.path.html)`(``path``, ``"mz"``)``)`` `` `[`altSaveObject`](https://rdrr.io/pkg/alabaster.base/man/altSaveObject.html)`(``x``@``intensity``, path ``=`` `[`file.path`](https://rdrr.io/r/base/file.path.html)`(``path``, ``"intensity"``)``)`` `` `[`altSaveObject`](https://rdrr.io/pkg/alabaster.base/man/altSaveObject.html)`(``x``@``rtime``, path ``=`` `[`file.path`](https://rdrr.io/r/base/file.path.html)`(``path``, ``"retention_time"``)``)`` `` `[`altSaveObject`](https://rdrr.io/pkg/alabaster.base/man/altSaveObject.html)`(``x``@``msl``, path ``=`` `[`file.path`](https://rdrr.io/r/base/file.path.html)`(``path``, ``"ms_level"``)``)`` ``}``)`

We next need to implement a *validation function* for the stash
(directory). For our example we simply check that the `path` contains
the expected sub-directories with the object’s content. This function
needs then to be registered with the
[`registerValidateObjectFunction()`](https://rdrr.io/pkg/alabaster.base/man/validateObject.html)
method for our class.

`#' Define a helper function to check that the folder contains all`` ``#' expected sub-directories.`` ``validateMySpectrum`` ``<-`` ``function``(``path``, ``metadata``)`` ``{`` `` ``if`` ``(``!`[`dir.exists`](https://rdrr.io/r/base/files2.html)`(``path``)``)`` `` `[`stop`](https://rdrr.io/r/base/stop.html)`(``"Directory "``, ``path``, ``" does not exist"``)`` `` ``req_dir`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"mz"``, ``"intensity"``, ``"retention_time"``, ``"ms_level"``)`` `` ``if`` ``(`[`any`](https://rdrr.io/r/base/any.html)`(``miss`` ``<-`` ``!`[`dir.exists`](https://rdrr.io/r/base/files2.html)`(`[`file.path`](https://rdrr.io/r/base/file.path.html)`(``path``, ``req_dir``)``)``)``)`` `` `[`stop`](https://rdrr.io/r/base/stop.html)`(``"Required directories "``,`` `` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"\""``, ``req_dir``[``miss``]``, ``"\""``, collapse ``=`` ``", "``)``,`` `` ``" not found in "``, ``path``)`` ``}`` `` ``#' Register the validation function`` `[`registerValidateObjectFunction`](https://rdrr.io/pkg/alabaster.base/man/validateObject.html)`(``"my_spectrum"``, ``validateMySpectrum``)`

    ## NULL

Finally we define the function to read the data back from the stash. We
then register this function with *alabaster*’s
[`registerReadObjectFunction()`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)
function.

`#' Define a function that can read from an alabaster-based serialization`` ``` #' of `MySpectrum` objects ``` ``readMySpectrum`` ``<-`` ``function``(``path``, ``metadata``, ``...``)`` ``{`` `` ``validateMySpectrum``(``path``)`` `` ``## Read the data from individual sub-directories`` `` ``mz`` ``<-`` `[`altReadObject`](https://rdrr.io/pkg/alabaster.base/man/altReadObject.html)`(`[`file.path`](https://rdrr.io/r/base/file.path.html)`(``path``, ``"mz"``)``)`` `` ``int`` ``<-`` `[`altReadObject`](https://rdrr.io/pkg/alabaster.base/man/altReadObject.html)`(`[`file.path`](https://rdrr.io/r/base/file.path.html)`(``path``, ``"intensity"``)``)`` `` ``rtime`` ``<-`` `[`altReadObject`](https://rdrr.io/pkg/alabaster.base/man/altReadObject.html)`(`[`file.path`](https://rdrr.io/r/base/file.path.html)`(``path``, ``"retention_time"``)``)`` `` ``msl`` ``<-`` `[`altReadObject`](https://rdrr.io/pkg/alabaster.base/man/altReadObject.html)`(`[`file.path`](https://rdrr.io/r/base/file.path.html)`(``path``, ``"ms_level"``)``)`` `` ``MySpectrum``(``mz ``=`` ``mz``, intensity ``=`` ``int``, rtime ``=`` ``rtime``, msl ``=`` ``msl``)`` ``}`` `` ``#' Register the read function`` `[`registerReadObjectFunction`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)`(``"my_spectrum"``, ``readMySpectrum``)`

Registration of the validation and read functions is generally done in
the extension package’s `onLoad()` function.

With these functions defined and registered, we can store an instance of
`MySpectrum` directly with *alabaster*’s
[`saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)
method:

`#' Define the path where we want to export out data`` ``p`` ``<-`` `[`file.path`](https://rdrr.io/r/base/file.path.html)`(`[`tempdir`](https://rdrr.io/r/base/tempfile.html)`(``)``, ``"alabaster_export"``)`` `` ``#' Save the object`` `[`saveObject`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)`(``s``, path ``=`` ``p``)`

This saved the object’s content to the directory specified with `path`.
The content of this folder is:

[`library`](https://rdrr.io/r/base/library.html)`(`[`fs`](https://fs.r-lib.org)`)`` `[`dir_tree`](https://fs.r-lib.org/reference/dir_tree.html)`(``p``)`

    ## /tmp/Rtmpp8SYWc/alabaster_export
    ## ├── OBJECT
    ## ├── _environment.json
    ## ├── intensity
    ## │   ├── OBJECT
    ## │   └── contents.h5
    ## ├── ms_level
    ## │   ├── OBJECT
    ## │   └── contents.h5
    ## ├── mz
    ## │   ├── OBJECT
    ## │   └── contents.h5
    ## └── retention_time
    ##     ├── OBJECT
    ##     └── contents.h5

We can read the serialized object again as a `MySpectrum` object:

`b`` ``<-`` `[`readObject`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)`(``p``)`` ``b`

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

We next implement the
[`saveMsObject()`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)
and
[`readMsObject()`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)
methods for `MySpectrum` and `AlabasterParam`. These can simply re-use
the functions implemented above.

`#' Write example class to a plain text file`` ``setMethod``(``"saveMsObject"``, ``signature``(``object ``=`` ``"MySpectrum"``,`` `` param ``=`` ``"AlabasterParam"``)``,`` `` ``function``(``object``, ``param``)`` ``{`` `` ``if`` ``(`[`file.exists`](https://rdrr.io/r/base/files.html)`(`[`file.path`](https://rdrr.io/r/base/file.path.html)`(``param``@``path``, ``"OBJECT"``)``)``)`` `` `[`stop`](https://rdrr.io/r/base/stop.html)`(``"'path' contains already an MS data stash. Overwriting"``,`` `` ``" is not supported. Please remove 'path' first."``)`` `` `[`saveObject`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)`(``object``, ``param``@``path``)`` `` ``}``)`` `` ``#' Read example object from plain text file storage format`` ``setMethod``(``"readMsObject"``, ``signature``(``object ``=`` ``"MySpectrum"``,`` `` param ``=`` ``"AlabasterParam"``)``,`` `` ``function``(``object``, ``param``)`` ``{`` `` ``readMySpectrum``(``param``@``path``)`` `` ``}``)`

We can now stash our MS object in either the text file-based format
(`PlainTextParam`) or the alabaster-based format (`AlabasterParam`).
Below we write it using the alabaster approach.

`p`` ``<-`` `[`file.path`](https://rdrr.io/r/base/file.path.html)`(`[`tempdir`](https://rdrr.io/r/base/tempfile.html)`(``)``, ``"alabaster_format_2"``)`` ``ap`` ``<-`` `[`AlabasterParam`](https://rformassspectrometry.github.io/MsStash/reference/AlabasterParam.md)`(``p``)`` `` `[`saveMsObject`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)`(``s``, ``ap``)`

To read the data back we can then use
[`readMsObject()`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)
specifying in addition the type of object we want to read.

`b`` ``<-`` `[`readMsObject`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)`(``MySpectrum``(``)``, ``ap``)`` ``b`

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

## Session information

[`sessionInfo`](https://rdrr.io/r/utils/sessionInfo.html)`(``)`

    ## R version 4.6.1 (2026-06-24)
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
    ## [1] fs_2.1.0              alabaster.base_1.13.2 MsStash_0.99.0       
    ## [4] BiocStyle_2.41.0     
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] jsonlite_2.0.0           compiler_4.6.1           BiocManager_1.30.27     
    ##  [4] crayon_1.5.3             Rcpp_1.1.2               rhdf5filters_1.25.4     
    ##  [7] jquerylib_0.1.4          systemfonts_1.3.2        textshaping_1.0.5       
    ## [10] yaml_2.3.12              fastmap_1.2.0            R6_2.6.1                
    ## [13] generics_0.1.4           ProtGenerics_1.45.0      knitr_1.51              
    ## [16] BiocGenerics_0.59.12     htmlwidgets_1.6.4        tibble_3.3.1            
    ## [19] bookdown_0.48            desc_1.4.3               pillar_1.11.1           
    ## [22] bslib_0.12.0             rlang_1.3.0              cachem_1.1.0            
    ## [25] xfun_0.60                sass_0.4.10              otel_0.2.0              
    ## [28] cli_3.6.6                magrittr_2.0.5           pkgdown_2.2.1.9000      
    ## [31] Rhdf5lib_2.1.0           digest_0.6.39            alabaster.schemas_1.13.0
    ## [34] rhdf5_2.57.12            lifecycle_1.0.5          vctrs_0.7.3             
    ## [37] S4Vectors_0.51.9         glue_1.8.1               evaluate_1.0.5          
    ## [40] ragg_1.5.2               stats4_4.6.1             rmarkdown_2.31          
    ## [43] pkgconfig_2.0.3          tools_4.6.1              htmltools_0.5.9

# Store contents of MS objects as plain text files

The
[`saveMsObject()`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)
and
[`readMsObject()`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)
methods with the `PlainTextParam` option enable users to save/load
different type of mass spectrometry (MS) object as a collections of
plain text files in/from a specified folder. This folder, defined with
the `path` parameter, will be created by the
[`saveMsObject()`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)
function. Writing data to a folder that contains already exported data
will result in an error.

For `PlainTextParam` all data is expected to be exported to plain text
files, where possible as tabulator delimited text files.

To support writing/reading with `PlainTextParam`, the `saveMsData()` and
`readMsData()` methods have to be implemented for the respective class.

See the package vignette for example implementations and details.

## Usage

``` r
PlainTextParam(path = tempdir())
```

## Arguments

- path:

  For `PlainTextParam()`: `character(1)`, defining where the files are
  going to be stored/ should be loaded from. The default is
  `path = tempdir()`.

## Value

For `PlainTextParam()`: a `PlainTextParam` class.
[`saveMsObject()`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)
does not return anything but saves the object to collections of
different plain text files to a folder. The
[`readMsObject()`](https://rformassspectrometry.github.io/MsStash/reference/saveMsObject.md)
method returns the restored data as an instance of the class specified
with parameter `object`.

## See also

Other MS object export and import formats.:
[`AlabasterParam`](https://rformassspectrometry.github.io/MsStash/reference/AlabasterParam.md)

## Author

Philippine Louail, Johannes Rainer

## Examples

``` r

## Create a PlainTextParam object
p <- PlainTextParam()
p
#> Object of class:  PlainTextParam 
#>  Parameters:
#>  - path: [1] "/tmp/Rtmpn0D31d"

## For example implementations and details see the package vignette
```

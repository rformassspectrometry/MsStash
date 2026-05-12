# MsStash

*Store your mass spectrometry result objects in a safe place*

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check-bioc](https://github.com/RforMassSpectrometry/MsStash/workflows/R-CMD-check-bioc/badge.svg)](https://github.com/RforMassSpectrometry/MsStash/actions?query=workflow%3AR-CMD-check-bioc)
[![codecov](https://codecov.io/gh/rformassspectrometry/MsStash/graph/badge.svg?token=D8zjkGdgnY)](https://codecov.io/gh/rformassspectrometry/MsStash)
[![:name status badge](https://rformassspectrometry.r-universe.dev/badges/:name)](https://rformassspectrometry.r-universe.dev/)
[![license](https://img.shields.io/badge/license-Artistic--2.0-brightgreen.svg)](https://opensource.org/licenses/Artistic-2.0)

---

## Overview

**MsStash** provides flexible, language-agnostic import and export capabilities
for mass spectrometry (MS) data objects in R. It facilitates interoperability
by supporting various open file formats such as JSON, HDF5, plain text, and
domain-specific standards like **mzTab-M** or **MetaboLights** archives.

While R’s native `save()`/`load()` functions allow object serialization, they
rely on R-specific binary formats, making cross-platform data exchange
difficult. **MsStash** addresses this by introducing standardized file formats
and programmatic interfaces, simplifying integration between R-based tools and
external software ecosystems.

---

## Key Features

- 📦 Export/import **MS analysis results objects** across interoperable file
   formats
- 🧩 Modular design via S4 **parameter classes** and generic methods
- 🔄 Integration with [Bioconductor](https://bioconductor.org) packages like
   **Spectra**, **MsExperiment**, **xcms**, and **alabaster.base**
- 🔧 Support for plain text, JSON+HDF5, mzTab-M, and MetaboLights repository
   data

---

## Package Architecture

### Generic Methods

- `saveMsObject(object, param)`
- `readMsObject(object, param)`

These methods delegate the actual file handling based on the class of the
supplied `param` object (e.g., `PlainTextParam`, `AlabasterParam`).

### Parameter Classes

Each format can be configured with their respective S4 class:

| Class               | Purpose                                  |
|---------------------|------------------------------------------|
| `PlainTextParam`     | Text-based tabular storage               |
| `AlabasterParam`     | HDF5/JSON archival via alabaster         |
| `mzTabParam`         | Export to mzTab-M (MS metabolomics)      |
| `MetaboLightsParam`  | Import from MetaboLights repository      |

Implementation of the import/export methods for individual MS data structures
are implemented in the corresponding R packages.

---

## Supported Formats

### ✅ Plain Text (`PlainTextParam`)
- Tab-delimited export/import for key objects:

### ✅ Alabaster (`AlabasterParam`)
- Structured archival using HDF5 and JSON (via
  [`alabaster.base`](https://doi.org/doi:10.18129/B9.bioc.alabaster.base))

---

## Planned Features & Contributions Welcome

Future development directions include:

- 🔄 **Import mzTab-M** into `SummarizedExperiment`
- 🔄 **Import mzTab-M** into `QFeatures`
- 🔄 **Generic ISA-tab** import integration (if justified)

We welcome and encourage contributions — see below for how to get involved!

---

## Contributing

We appreciate contributions of all kinds — from bug fixes and tests to
documentation and new format support.

If you're planning to contribute:

1. Read our [contribution guidelines](https://rformassspectrometry.github.io/RforMassSpectrometry/articles/RforMassSpectrometry.html#contributions)
2. Follow the [RforMassSpectrometry style guide](https://rformassspectrometry.github.io/RforMassSpectrometry/articles/RforMassSpectrometry.html)
3. Fork the repo, create a branch, implement your changes, and submit a pull
   request
4. For new formats, implement:
   - A `*Param` S4 class
   - A `readMsObject()` and/or `saveMsObject()` method
   - Tests in `tests/testthat/`
---

## License

This package is licensed under the **Artistic 2.0 License**:
📄 [https://opensource.org/licenses/Artistic-2.0](https://opensource.org/licenses/Artistic-2.0)

Documentation (manuals, vignettes) is licensed under **CC BY-SA 4.0**:
📄 [https://creativecommons.org/licenses/by-sa/4.0/](https://creativecommons.org/licenses/by-sa/4.0/)


---

# Funding information

Part of this work was funded by the **European Union** under the
**HORIZON-MSCA-2021** project **101073062: HUMAN – Harmonising and Unifying
Blood Metabolic Analysis Networks**, by the **Autonomous Province of
Bolzano** under the **MetaRbolomics4Galaxy** project (CUP: D53C25001030003) from
the *Joint Projects South Tyrol–Germany 2025* funding program and by the DFG
grant
no. [564004112](https://gepris.dfg.de/gepris/projekt/564004112?language=en).

![EU Logo](https://github.com/rformassspectrometry/Metabonaut/raw/main/vignettes/images/EULogo.jpg)


![funding](https://github.com/rformassspectrometry/MsBackendMassIVE/raw/main/man/figures/SuedDFG-60.png)

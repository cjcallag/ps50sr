`{ps50sr}`
================

-   [Installation](#installation)
-   [Launching App](#launching-app)

<!-- badges: start -->

[![Depends](https://img.shields.io/badge/Depends-GNU_R%3E=3.5-blue.svg)](https://www.r-project.org/)
<!-- badges: end -->

**{ps50sr}** is a repository for the applications and tools developed by
this author in support of the Council of State Government Justice
Center.

## Installation

The R installation can be accomplished using **{remotes}**:

``` r
if(!requireNamespace("remotes")) install.packages("remotes")
remotes::install_github("cjcallag/ps50sr")
```

## Launching App

Launching can be done programmatically like so:

``` r
escaexplorer::launch_app(app = "ps50sr-dashboard",
                         use_browser = TRUE)
```

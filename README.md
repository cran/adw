## Angular Distance Weighting Interpolation

The irregularly-spaced data are interpolated onto regular
latitude-longitude grids by weighting each station according to its
distance and angle from the center of a search radius.

## Reference

Caesar, J., L. Alexander, and R. Vose, 2006: Large-scale changes in
observed daily maximum and minimum temperatures: Creation and analysis
of a new gridded data set. Journal of Geophysical Research, 111,
<https://doi.org/10.1029/2005JD006280>.

## Installation

Install the latest CRAN release via command:

    install.packages("adw")

The **development** version can be installed from GitHub
(<https://github.com/PanfengZhang/adw>) using:

    install.packages("remotes")
    remotes::install_github("PanfengZhang/adw")

## Usage

### load packages and data

    library(ggplot2)
    library(sf)
    library(terra)
    library(adw)
    da <- read.csv("./inst/extdata/henan_temperature.csv")
    head(da)

    ##      lon   lat value
    ## 1 113.82 36.07  26.5
    ## 2 114.40 36.05  27.3
    ## 3 112.92 35.12  23.5
    ## 4 114.18 35.62  29.2
    ## 5 112.63 35.08  23.6
    ## 6 113.08 35.15  24.5

    urlmap <- "https://geo.datav.aliyun.com/areas_v3/bound/410000.json"
    hmap <- read_sf(urlmap) |> st_cast('MULTILINESTRING')
    ggplot() +
      geom_sf(data = hmap) +
      geom_point(data = da, aes(x = lon, y = lat, colour = value), 
                 pch = 17, size = 2.5) +
      scale_colour_fermenter(palette = "YlOrRd",
                             direction = 1,
                             breaks = seq(from = 25, to = 32, by = 1),
                             limits = c(0, 100),
                             name = expression("\u00B0C")) +
      ggtitle("Irregularly-spaced data points (temperature)") +
      theme_bw() +
      theme(axis.title = element_blank(),
            legend.key.width = unit(0.5,"cm"),
            legend.key.height = unit(1.5, "cm"),
            plot.title = element_text(hjust = 0.5, size = 11))

![](README_files/figure-markdown_strict/unnamed-chunk-3-1.png)

### Interpolation

The irregularly-spaced data are interpolated onto regular
latitude-longitude grids.

**Usuage 1**. The parameter *e**x**t**e**n**t* in the *a**d**w* function
is a *S**p**a**t**V**e**c**t**o**r* object, and the coordinate reference
system of the object is WGS1984 (EPSG: 4326).

    hmap_terra <- terra::vect(urlmap)
    ds <- adw(da, extent = hmap_terra, gridsize = 0.1, cdd = 1e5)
    head(ds)

    ##        lon      lat    value
    ## 1 115.3105 31.43345 33.13984
    ## 2 114.7105 31.53345 32.54283
    ## 3 114.8105 31.53345 32.83359
    ## 4 114.9105 31.53345 33.02109
    ## 5 115.0105 31.53345 33.07372
    ## 6 115.3105 31.53345 33.12438

    ggplot() +
      geom_raster(data = ds, aes(x = lon, y = lat, fill = value)) +
      geom_sf(data = hmap) +
      scale_fill_fermenter(palette = "YlOrRd",
                           direction = 1,
                           breaks = seq(from = 25, to = 32, by = 1),
                           limits = c(0, 100),
                           name = expression("\u00B0C"),
                           na.value = "white") +
      ggtitle("Angular distance weighting interpolation") +
      theme_bw() +
      theme(axis.title = element_blank(),
            legend.key.width = unit(0.5,"cm"),
            legend.key.height = unit(1.5, "cm"),
            plot.title = element_text(hjust = 0.5, size = 11))

![](README_files/figure-markdown_strict/unnamed-chunk-4-1.png)

It can be seen that the interpolated grid values outside the polygon has
been removed.

**Usuage 2**. The parameter *e**x**t**e**n**t* is a numeric vector of
length 4 in the order \[xmin, xmax, ymin, ymax\].

    ds <- adw(da, extent = c(110.36, 116.65, 31.38, 36.37), gridsize = 0.1, cdd = 1e5)
    head(ds)

    ##      lon   lat value
    ## 1 110.41 31.43    NA
    ## 2 110.51 31.43    NA
    ## 3 110.61 31.43    NA
    ## 4 110.71 31.43    NA
    ## 5 110.81 31.43    NA
    ## 6 110.91 31.43    NA

    ggplot() +
      geom_raster(data = ds, aes(x = lon, y = lat, fill = value)) +
      geom_sf(data = hmap) +
      scale_fill_fermenter(palette = "YlOrRd",
                           direction = 1,
                           breaks = seq(from = 25, to = 32, by = 1),
                           limits = c(0, 100),
                           name = expression("\u00B0C"),
                           na.value = "white") +
      ggtitle("Angular distance weighting interpolation") +
      theme_bw() +
      theme(axis.title = element_blank(),
            legend.key.width = unit(0.5,"cm"),
            legend.key.height = unit(1.5, "cm"),
            plot.title = element_text(hjust = 0.5, size = 11))

![](README_files/figure-markdown_strict/unnamed-chunk-5-1.png)

There are some interpolated values outside the polygon boundary, and
these values can be removed by the method of **mask**, which will not be
repeated here.

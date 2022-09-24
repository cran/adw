#' @title Angular Distance Weighting Interpolation.
#' @description
#' The irregularly-spaced data are interpolated onto regular latitude-longitude 
#' grids by weighting each station according to its distance and angle from the 
#' center of a search radius.
#' @param ds a input dataframe which contains the column names of lon, lat, value.
#' @param extent a extent numeric vector of length 4 in the order c(xmin, xmax, ymin, ymax);
#' or a SpatVector polygons object, assume that the coordinate reference system 
#' is WGS1984 (EPSG: 4326); if extent is a NULL value (i.e. no extent is inputted), 
#' the extent vector will be calculated from the input data.
#' @param gridsize the grid size (resolution). units: degree.
#' @param cdd correlation decay distance, i.e. the maximum search radius. 
#' unit: meter. default value: 1e6.
#' @param m is used to adjust the weighting function further, higher values of m
#' increase the rate at which the weight decays with distance. default value 4.
#' @param nmin the minimum number of observation points required to interpolate 
#' a grid within the search radius (i.e. cdd); if the number of stations within 
#' the search ridius (cdd) is less than nmin, a missing value will be generated  
#' to fill this grid. default value 3.
#' @param nmax The number of nearest points within the search radius to use for 
#' interpolation. default value 10.
#' @param maskON Logical value; whether to mask (remove) grids that are outside 
#' the SpatVector polygon (extent). default TRUE. Parameter 'maskON' only works 
#' when the class of parameter 'extent' is 'SpatVector'. 
#' @return a regular latitude-longitude dataframe grid (interpoled values).
#' @references Caesar, J., L. Alexander, and R. Vose, 2006: Large-scale changes in observed daily maximum and minimum temperatures: Creation and analysis of a new gridded data set. Journal of Geophysical Research, 111, https://doi.org/10.1029/2005JD006280.
#' @examples
#' set.seed(2)
#' dd <- data.frame(lon = runif(100, min = 110, max = 117),
#'                  lat = runif(100, min = 31, max = 37),
#'                  value = runif(100, min = -10, max = 10))
#' head(dd)
#' 
#' # example 1
#' grd <- adw(dd, extent = c(110, 117, 31, 37), gridsize = 0.5, cdd = 1e5)
#' head(grd)
#' 
#' # example 2
#' urlmap <- "https://geo.datav.aliyun.com/areas_v3/bound/410000.json"
#' hmap <- terra::vect(urlmap) # return a 'SpatVector' object.
#' grd <- adw(dd, extent = hmap, gridsize = 0.5, cdd = 1e5)
#' head(grd)
#' 
#' @importFrom terra ext vect mask buffer distance crds
#' @importFrom geosphere bearing
#' @importFrom methods is
#' @export
#' 

adw <- function(ds, extent = NULL, gridsize = 1, cdd = 1e6, 
                      m = 4, nmin = 3, nmax = 10, maskON = TRUE) {
  if (is(extent, "vector")) {
    xmin = extent[1]
    xmax = extent[2]
    ymin = extent[3]
    ymax = extent[4]
  } else if (is(extent, "SpatVector")) {
    bbox <- terra::ext(extent)
    xmin = bbox[1]
    xmax = bbox[2]
    ymin = bbox[3]
    ymax = bbox[4]
  } else {
    xmin <- min(ds$lon)
    xmax <- max(ds$lon)
    ymin <- min(ds$lat)
    ymax <- max(ds$lat)
  }
  dg <- expand.grid(lon = seq(xmin+gridsize/2, xmax, gridsize), 
                    lat = seq(ymin+gridsize/2, ymax, gridsize)) |>
    terra::vect(crs = "+proj=longlat +datum=WGS84", keepgeom = TRUE)
  if (is(extent, "SpatVector") & maskON) {
    dg <- terra::mask(dg, extent)
  }
  dg[, "value"] <- NA
  ngrds <- nrow(dg)
  ds <- terra::vect(ds, geom = c("lon", "lat"), crs = "+proj=longlat +datum=WGS84")
  for (j in 1:ngrds) {
    circle <- terra::buffer(dg[j,], width = cdd)
    dx <- terra::mask(ds, circle)
    npts <- nrow(dx)  # station points numbers in the searh radius
    if (npts > nmax) {
      dx[, "distance"] <- terra::distance(dg[j,], dx)[1,]
      dx <- dx[order(dx$distance),]
      dx <- dx[1:nmax, ]
      r <- exp(1)^(-dx$distance/cdd)
      f <- r^m
      theta <- geosphere::bearing(terra::crds(dg[j,]), terra::crds(dx)) * pi / 180
      alpha <- rep(NA, nmax)
      for (k in 1:nmax) {
        diffTheta <- theta[-k] - theta[k]
        alpha[k] <- sum(f[-k] * (1 - cos(diffTheta))) / sum(f[-k])
      }
      w <- f * (1 + alpha)
      dg[j, "value"] <- sum(dx$value * w) / sum(w)
    } else if (npts >= nmin & npts <= nmax) {
      dx[, "distance"] <- terra::distance(dg[j,], dx)[1,]
      r <- exp(1)^(-dx$distance/cdd)
      f <- r^m
      theta <- geosphere::bearing(terra::crds(dg[j,]), terra::crds(dx)) * pi / 180
      alpha <- rep(NA, npts)
      for (k in 1:npts) {
        diffTheta <- theta[-k] - theta[k]
        alpha[k] <- sum(f[-k] * (1 - cos(diffTheta))) / sum(f[-k])
      }
      w <- f * (1 + alpha)
      dg[j, "value"] <- sum(dx$value * w) / sum(w)
    } else {
      next
    }
  }
  dg <- as.data.frame(dg)
  return(dg)
}

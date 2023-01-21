# r <- terra::rast("~/stasi/gis/LMI/LMI_Haedarlikan_DEM_16bit/LMI_Haedarlikan_DEM_16bit.tif")
# trial <- create_viewshed(lon = -21.755394, lat = 64.236082, r = r)

# TODO: See if things can be speeded up by running things not in memory

#' Create a viewshed for a point
#'
#' The processing takes a while, normally run this via nohup
#'
#' @param lon longitude in decimal degrees
#' @param lat latitute in decimal degress
#' @param r a terra raster containing ... model
#' @param dx the radius in kilometers
#' @param observer the height of the vindmill in meters
#' @param target the height of the observer in meters
#' @param curvcoef earth curvature and light refraction parameter
#' @param dTolerance value use to simplify the polygon returned
#' @param return_sf return an sf-object (default TRUE), if FALSE returns a terra raster
#'
#' @return an sf-polygon or a terra raster
#' @export
#'
create_viewshed <- function(lon, lat, r, dx = 90, observer = 180, target = 1.5, curvcoef = 0.13, dTolerance = 10, return_sf = TRUE) {
  pt <-
    sf::st_point(c(lon, lat)) |>
    sf::st_sfc(crs = 4326) |>
    sf::st_transform(crs = sf::st_crs(r))
  dx <- dx * 1e3  # km to meters
  buffer <-
    pt |>
    sf::st_buffer(dist =  dx)

  # crop the raster
  xy <- pt |> sf::st_coordinates()
  dx <- dx * 1.02
  e <- terra::ext(xy[[1]] - dx, # xmin
                  xy[[1]] + dx, # xmax
                  xy[[2]] - dx, # ymin
                  xy[[2]] + dx) # ymax
  v <-
    r |>
    terra::crop(e) |>
    terra::viewshed(loc = xy,
                    observer = observer,
                    target = target,
                    curvcoef = curvcoef)

  if(!return_sf) {
    return(v)
  } else {
    po <-
      v |>
      terra::as.polygons() |>
      sf::st_as_sf()  |>
      dplyr::filter(viewshed == 1) |>
      sf::st_make_valid()  |>
      # sf::st_simplify(dTolerance = dTolerance) |>
      sf::st_intersection(buffer)
    return(po)
  }
}



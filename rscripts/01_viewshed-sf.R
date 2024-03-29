# run as: nohup R < rscripts/01_viewshed-sf.R --vanilla > viewshed-sf.log &
source("R/create_viewshed.R")
d <-
  readxl::read_excel("data-raw/Natturukortid_gagnagrunnur_fyrir_vefsja.xlsx") |>
  janitor::clean_names() |>
  dplyr::rename(lat = x5,
                lon = x6) |>
  dplyr::filter(orka == "Vindorka") |>
  sf::st_as_sf(coords = c("lon", "lat"),
               crs = 4326,
               remove = FALSE) |>
  dplyr::select(virkjun = titill, lon, lat)
fn <-
  janitor::make_clean_names(d$virkjun)  |>
  stringr::str_replace_all("_", "-") |>
  stringr::str_replace("^t-", "t") |>
  stringr::str_replace("-t-", "-t")

r <- terra::rast("data-raw/LMI_DEM.tif")
for(i in 1:nrow(d)) {
  print(i)
  create_viewshed(d$lon[i], d$lat[i], r = r) |>
    dplyr::mutate(virkjun = d$virkjun[i],
                  vn = fn[i]) |>
    sf::st_write(paste0("data/",
                        stringr::str_pad(i, width = 2, pad = "0"),
                        "_viewshed-sf_",
                        fn[i],
                        ".gpkg"),
                 delete_layer = TRUE)
}

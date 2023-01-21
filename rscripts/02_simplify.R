library(sf)
library(tidyverse)
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

fil <- paste0("data/", dir("data", pattern = ".gpkg"))

for(i in 1:length(fil)) {
  print(i)
  sf::read_sf(fil[i]) |>
    select(-viewshed) |>
    st_cast("POLYGON") |>
    mutate(area = as.numeric(st_area(geom))) |>
    select(virkjun, area, vn) |>
    arrange(desc(area)) |>
    filter(area >= 10 * 1e6) |>
    st_simplify(dTolerance = 7) |>
    sf::st_write(paste0("data/simplified/",
                        stringr::str_pad(i, width = 2, pad = "0"),
                        "_viewshed-sf_",
                        fn[i],
                        ".gpkg"),
                 delete_layer = TRUE)
}





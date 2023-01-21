library(leaflet)
m <-
  leaflet() |>
  addTiles(group = "base") %>%
  setView(-20, 64, zoom = 7) |>
  addWMSTiles(baseUrl = "https://gis.lmi.is/geoserver/wms",
              layers = "LMI_hillshade",
              group = "hillshade",
              options = WMSTileOptions(format="image/png"
                                       #, transparent  = TRUE
                                       #, crs = "EPSG:3057"
                                       #, opacity = 0.1
                                       )
              ) |>
  addLayersControl(baseGroups = c("base", "hillshade"),
                   # overlayGroups = c(pt.last$name, "Botnlag", paste("Hafís", YMD)),
                   options = layersControlOptions(collapsed = FALSE))
m
# htmlwidgets::saveWidget(m, "m.html")

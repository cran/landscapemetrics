## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----load_libraries_hidden, eval=TRUE, echo=FALSE, message=FALSE, results='hide'----
library(landscapemetrics)
library(raster)
library(dplyr)

## ---- message=FALSE------------------------------------------------------
# Import raster
landscape_raster <- landscape
# for local file: raster("pathtoyourraster/raster.asc")
# ... or any other raster file type, geotiff, ...

# Calculate e.g. perimeter of all patches
lsm_p_perim(landscape_raster)

## ---- message=FALSE------------------------------------------------------
# Calculate metric
result <- lsm_c_dcad(landscape)

# Left join with abbreviation tibble
result_full_name <- left_join(x = result, 
                                     y = lsm_abbreviations_names, 
                                     by = "metric")
# Show results
result_full_name

## ---- message=FALSE------------------------------------------------------
# All patch IDs of class 2 with an ENN > 2.5
subsample_patches <- landscape %>% 
    lsm_p_enn() %>%
    dplyr::filter(class == 2 & value > 2.5) %>%
    dplyr::pull(id)

# Show results
subsample_patches

## ---- message=FALSE------------------------------------------------------
# bind results from different metric functions
patch_metrics <- bind_rows(
  lsm_p_cai(landscape),
  lsm_p_circle(landscape),
  lsm_p_enn(landscape)
  )
# look at the results
patch_metrics 

## ---- message=FALSE------------------------------------------------------
calculate_metrics(landscape, what = c("lsm_c_pland", "lsm_l_ta", "lsm_l_te"))

## ---- message=FALSE------------------------------------------------------

# bind results from different metric functions
patch_metrics <- bind_rows(
  lsm_p_cai(landscape),
  lsm_p_circle(landscape),
  lsm_p_enn(landscape)
  )
# look at the results
patch_metrics_full_names <- dplyr::left_join(x = patch_metrics,
                                             y = lsm_abbreviations_names, 
                                             by = "metric")
patch_metrics_full_names

## ------------------------------------------------------------------------
calculate_metrics(landscape, what = c("lsm_c_pland", "lsm_l_ta", "lsm_l_te"), 
              full_name = TRUE)



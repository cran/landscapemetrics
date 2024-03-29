test_that("pad_raster can handle all raster inputs", {

    landscape_matrix <- terra::as.matrix(landscape, wide = TRUE)

    expect_type(pad_raster(landscape), "list")
    expect_type(pad_raster(landscape_stack), "list")
    expect_type(pad_raster(landscape_list), "list")
    expect_type(pad_raster(landscape_matrix, return_raster = FALSE, to_disk = FALSE), "list")
})

test_that("pad_raster adds correct number of rows/cols", {

    result_a <- pad_raster(landscape, pad_raster_cells = 1, global = TRUE)[[1]]

    result_b <- pad_raster(landscape, pad_raster_cells = 5, global = TRUE)[[1]]

    # original landscape is 30 x 30 and adding 1 rows/cols in each direction
    expect_equal(object = terra::nrow(result_a), expected = 32)
    expect_equal(object = terra::nrow(result_a), expected = 32)

    # original landscape is 30 x 30 and adding 5 rows/cols in each direction
    expect_equal(object = terra::nrow(result_b), expected = 40)
    expect_equal(object = terra::nrow(result_b), expected = 40)
})

test_that("pad_raster can add different padding values", {

    result <- pad_raster(landscape, pad_raster_value = NA)[[1]]

    expect_true(anyNA(terra::values(result, mat = FALSE)))
})

test_that("pad_raster can return RasterLayer and matrix", {

    raster_layer <- pad_raster(landscape)[[1]]

    mat <- pad_raster(landscape, return_raster = FALSE)[[1]]

    expect_s4_class(object = raster_layer, class = "SpatRaster")

    expect_true(is.matrix(mat))

})

test_that("pad_raster can return write to disk", {

    result <- pad_raster(landscape, to_disk = TRUE)

    expect_false(object = terra::inMemory(result[[1]]))
})

test_that("pad_raster returns warning for matrix and return_raster = TRUE", {

    expect_warning(object = pad_raster(landscape_matrix, return_raster = TRUE),
                   regexp = "'return_raster = TRUE' or 'to_disk = TRUE' not able for matrix input.")

    expect_warning(object = pad_raster(landscape_matrix, to_disk = TRUE),
                   regexp = "'return_raster = TRUE' or 'to_disk = TRUE' not able for matrix input.")
})


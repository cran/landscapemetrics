context("get_patches")

class_1_landscape_4 <- get_patches(landscape, 1, 4)
class_1_landscape_8 <- get_patches(landscape, 1, 8)
all_classes_landscape_4 <- get_patches(landscape, "all", 4)
all_classes_landscape_8 <- get_patches(landscape, "all", 8)

test_that("get_patches runs and returns a list", {
    expect_is(class_1_landscape_4, "list")
    expect_is(class_1_landscape_8, "list")
    expect_is(all_classes_landscape_4, "list")
    expect_is(all_classes_landscape_4, "list")

    expect_is(class_1_landscape_4[[1]][[1]], "RasterLayer")
    expect_is(all_classes_landscape_4[[1]][[1]], "RasterLayer")

    expect_true(length(all_classes_landscape_4[[1]]) == 3)
})

test_that("get_patches can handle all raster inputs", {
    expect_is(get_patches(landscape), "list")
    expect_is(get_patches(landscape_stack), "list")
    expect_is(get_patches(landscape_brick), "list")
    expect_is(get_patches(landscape_list), "list")
})

test_that("get_patches labels the patches correctly", {
    expect_true(length(get_unique_values(class_1_landscape_8[[1]], simplify = TRUE)) == 9)
    expect_true(length(get_unique_values(class_1_landscape_4[[1]], simplify = TRUE)) == 11)
    expect_true(length(which(class_1_landscape_4[[1]][[1]]@data@values == 6)) == 63)
    expect_true(length(which(class_1_landscape_8[[1]][[1]]@data@values == 6)) == 14)
})

context("landscape level lsm_l_mesh metric")

landscapemetrics_landscape_landscape_value <- lsm_l_mesh(landscape)

test_that("lsm_l_mesh is typestable", {
    expect_is(lsm_l_mesh(landscape), "tbl_df")
    expect_is(lsm_l_mesh(landscape_stack), "tbl_df")
    expect_is(lsm_l_mesh(landscape_brick), "tbl_df")
    expect_is(lsm_l_mesh(landscape_list), "tbl_df")
})

test_that("lsm_l_mesh returns the desired number of columns", {
    expect_equal(ncol(landscapemetrics_landscape_landscape_value), 6)
})

test_that("lsm_l_mesh returns in every column the correct type", {
    expect_type(landscapemetrics_landscape_landscape_value$layer, "integer")
    expect_type(landscapemetrics_landscape_landscape_value$level, "character")
    expect_type(landscapemetrics_landscape_landscape_value$class, "integer")
    expect_type(landscapemetrics_landscape_landscape_value$id, "integer")
    expect_type(landscapemetrics_landscape_landscape_value$metric, "character")
    expect_type(landscapemetrics_landscape_landscape_value$value, "double")
})


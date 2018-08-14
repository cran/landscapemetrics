context("landscape level gyrate_sd metric")

# fragstats_landscape_landscape_gyrate_sd <- fragstats_landscape_landscape$GYRATE_SD
landscapemetrics_landscape_landscape_gyrate_sd <- lsm_l_gyrate_sd(landscape)
#
# test_that("lsm_l_gyrate_sd results are equal to fragstats", {
#     expect_true(all(fragstats_landscape_landscape_gyrate_sd %in%
#                         round(landscapemetrics_landscape_landscape_gyrate_sd$value, 4)))
# })

test_that("lsm_l_gyrate_sd is typestable", {
    expect_is(landscapemetrics_landscape_landscape_gyrate_sd, "tbl_df")
    expect_is(lsm_l_gyrate_sd(landscape_stack), "tbl_df")
    expect_is(lsm_l_gyrate_sd(list(landscape, landscape)), "tbl_df")
})

test_that("lsm_l_gyrate_sd returns the desired number of columns", {
    expect_equal(ncol(landscapemetrics_landscape_landscape_gyrate_sd), 6)
})

test_that("lsm_l_gyrate_sd returns in every column the correct type", {
    expect_type(landscapemetrics_landscape_landscape_gyrate_sd$layer, "integer")
    expect_type(landscapemetrics_landscape_landscape_gyrate_sd$level, "character")
    expect_type(landscapemetrics_landscape_landscape_gyrate_sd$class, "integer")
    expect_type(landscapemetrics_landscape_landscape_gyrate_sd$id, "integer")
    expect_type(landscapemetrics_landscape_landscape_gyrate_sd$metric, "character")
    expect_type(landscapemetrics_landscape_landscape_gyrate_sd$value, "double")
})
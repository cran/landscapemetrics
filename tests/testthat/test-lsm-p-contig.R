context("patch level lsm_p_contig metric")

landscapemetrics_patch_landscape_value <- lsm_p_contig(landscape)

test_that("lsm_p_contig is typestable", {
    expect_is(lsm_p_contig(landscape), "tbl_df")
    expect_is(lsm_p_contig(landscape_stack), "tbl_df")
    expect_is(lsm_p_contig(landscape_brick), "tbl_df")
    expect_is(lsm_p_contig(landscape_list), "tbl_df")
})

test_that("lsm_p_contig returns the desired number of columns", {
    expect_equal(ncol(landscapemetrics_patch_landscape_value), 6)
})

test_that("lsm_p_contig returns in every column the correct type", {
    expect_type(landscapemetrics_patch_landscape_value$layer, "integer")
    expect_type(landscapemetrics_patch_landscape_value$level, "character")
    expect_type(landscapemetrics_patch_landscape_value$class, "integer")
    expect_type(landscapemetrics_patch_landscape_value$id, "integer")
    expect_type(landscapemetrics_patch_landscape_value$metric, "character")
    expect_type(landscapemetrics_patch_landscape_value$value, "double")
})



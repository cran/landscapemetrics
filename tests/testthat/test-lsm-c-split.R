landscapemetrics_class_landscape_value <- lsm_c_split(landscape)

test_that("lsm_c_split is typestable", {
    expect_s3_class(lsm_c_split(landscape), "tbl_df")
    expect_s3_class(lsm_c_split(landscape_stack), "tbl_df")
    expect_s3_class(lsm_c_split(landscape_list), "tbl_df")
})

test_that("lsm_c_split returns the desired number of columns", {
    expect_equal(ncol(landscapemetrics_class_landscape_value), 6)
})

test_that("lsm_c_split returns in every column the correct type", {
    expect_type(landscapemetrics_class_landscape_value$layer, "integer")
    expect_type(landscapemetrics_class_landscape_value$level, "character")
    expect_type(landscapemetrics_class_landscape_value$class, "integer")
    expect_type(landscapemetrics_class_landscape_value$id, "integer")
    expect_type(landscapemetrics_class_landscape_value$metric, "character")
    expect_type(landscapemetrics_class_landscape_value$value, "double")
})

test_that("lsm_c_split equals FRAGSTATS", {
    lsm_landscape <- lsm_c_split(landscape) |> dplyr::pull(value)
    lsm_augusta <- lsm_c_split(augusta_nlcd) |> dplyr::pull(value)

    fs_landscape <- dplyr::filter(fragstats_class, LID == "landscape", metric == "split") |> dplyr::pull(value)
    fs_augusta <- dplyr::filter(fragstats_class, LID == "augusta_nlcd", metric == "split") |> dplyr::pull(value)

    expect_true(test_relative(obs = lsm_landscape, exp = fs_landscape, tolerance = tol_rel))
    expect_true(test_relative(obs = lsm_augusta, exp = fs_augusta, tolerance = tol_rel))
})

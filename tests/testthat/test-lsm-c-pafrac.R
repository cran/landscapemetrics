landscapemetrics_class_landscape_value <- lsm_c_pafrac(landscape, verbose = FALSE)

test_that("lsm_c_pafrac is typestable", {

    expect_s3_class(lsm_c_pafrac(landscape,
                           verbose = FALSE), "tbl_df")
    expect_s3_class(lsm_c_pafrac(landscape_stack,
                           verbose = FALSE), "tbl_df")
    expect_s3_class(lsm_c_pafrac(landscape_list,
                           verbose = FALSE), "tbl_df")
})

test_that("lsm_c_pafrac returns the desired number of columns", {

    expect_equal(ncol(landscapemetrics_class_landscape_value), 6)
})

test_that("lsm_c_pafrac returns in every column the correct type", {

    expect_type(landscapemetrics_class_landscape_value$layer, "integer")
    expect_type(landscapemetrics_class_landscape_value$level, "character")
    expect_type(landscapemetrics_class_landscape_value$class, "integer")
    expect_type(landscapemetrics_class_landscape_value$id, "integer")
    expect_type(landscapemetrics_class_landscape_value$metric, "character")
    expect_type(landscapemetrics_class_landscape_value$value, "double")
})

test_that("lsm_c_pafrac throws warning for less than 10 patches",  {

    expect_warning(lsm_c_pafrac(landscape_uniform),
                   regexp = "Class 1: PAFRAC = NA for class with < 10 patches",
                   fixed = TRUE)
})

test_that("lsm_c_pafrac equals FRAGSTATS", {
    lsm_landscape <- lsm_c_pafrac(landscape) |> dplyr::pull(value)
    lsm_augusta <- lsm_c_pafrac(augusta_nlcd) |> dplyr::pull(value)

    fs_landscape <- dplyr::filter(fragstats_class, LID == "landscape", metric == "pafrac") |> dplyr::pull(value)
    fs_augusta <- dplyr::filter(fragstats_class, LID == "augusta_nlcd", metric == "pafrac") |> dplyr::pull(value)

    expect_true(test_relative(obs = lsm_landscape, exp = fs_landscape, tolerance = tol_rel))
    expect_true(test_relative(obs = lsm_augusta, exp = fs_augusta, tolerance = tol_rel))
})

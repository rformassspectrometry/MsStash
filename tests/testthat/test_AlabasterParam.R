test_that("AlabasterParam works", {
    a <- AlabasterParam()
    expect_s4_class(a, "AlabasterParam")
})

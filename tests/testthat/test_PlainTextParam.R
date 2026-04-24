test_that("PlainTextParam works", {
    p <- PlainTextParam()
    expect_s4_class(p, "PlainTextParam")
    expect_equal(p@path, tempdir())

    p <- PlainTextParam("other_path")
    expect_equal(p@path, "other_path")

    expect_error(PlainTextParam(c("a", "b")), "length 1")
})

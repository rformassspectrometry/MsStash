test_that("saveMsObject can be implemented", {
    setClass("DummyClass",
             slots = c(content = "list"),
             prototype = prototype(content = list()))
    setMethod("saveMsObject", signature(object = "DummyClass",
                                        param = "PlainTextParam"),
              function(object, param, ...) {
                  message("saveMsObject for DummyClass")
              })
    expect_message(saveMsObject(new("DummyClass"), PlainTextParam()),
                   "saveMsObject for DummyClass")
})

test_that("readMsObject can be implemented", {
    setClass("DummyClass",
             slots = c(content = "list"),
             prototype = prototype(content = list()))
    setMethod("readMsObject", signature(object = "DummyClass",
                                        param = "PlainTextParam"),
              function(object, param, ...) {
                  message("readMsObject for DummyClass")
              })
    expect_message(readMsObject(new("DummyClass"), PlainTextParam()),
                   "readMsObject for DummyClass")
})

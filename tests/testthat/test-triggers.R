test_that("[Online] Test Build Triggers",{
  skip_on_travis()
  skip_on_cran()
  cloudbuild <- system.file("cloudbuild/cloudbuild.yaml",
                            package = "googleCloudRunner")

  bb <- cr_build_make(cloudbuild)

  gh_trigger <- cr_buildtrigger_repo("MarkEdmondson1234/googleCloudRunner")
  cs_trigger <- cr_buildtrigger_repo("github_markedmondson1234_googlecloudrunner",
                                     type = "cloud_source")

  # build with in-line build code
  gh_inline <- cr_buildtrigger(bb, name = "bt-github-inline", trigger = gh_trigger)

  # build pointing to cloudbuild.yaml within the GitHub repo
  gh_file <- cr_buildtrigger("inst/cloudbuild/cloudbuild.yaml",
                             name = "bt-github-file", trigger = gh_trigger)

  cs_file <- cr_buildtrigger("inst/cloudbuild/cloudbuild.yaml",
                             name = "bt-cs-file", trigger = cs_trigger)

  # build inline with trigger source
  cloudbuild_rmd <- system.file("cloudbuild/cloudbuild_rmd.yml",
                                package = "googleCloudRunner")
  b_rmd <- cr_build_make(cloudbuild_rmd)
  gh_source_inline <- cr_buildtrigger(b_rmd,
                                      name = "bt-github-source",
                                      trigger = gh_trigger)
  cs_source_inline <- cr_buildtrigger(b_rmd,
                                      name = "bt-cs-source",
                                      trigger = cs_trigger)
  Sys.sleep(5)
  the_list <- cr_buildtrigger_list()
  expect_true("bt-github-inline" %in% the_list$buildTriggerName)
  expect_true("bt-github-file" %in% the_list$buildTriggerName)
  expect_true("bt-cs-file" %in% the_list$buildTriggerName)
  expect_true("bt-github-source" %in% the_list$buildTriggerName)
  expect_true("bt-cs-source" %in% the_list$buildTriggerName)

  cr_buildtrigger_delete("bt-github-inline")
  cr_buildtrigger_delete("bt-github-file")
  cr_buildtrigger_delete("bt-cs-file")
  cr_buildtrigger_delete("bt-github-source")
  cr_buildtrigger_delete("bt-cs-source")

  Sys.sleep(5)
  the_list2 <- cr_buildtrigger_list()

  expect_false("bt-github-inline" %in% the_list2$buildTriggerName)
  expect_false("bt-github-file" %in% the_list2$buildTriggerName)
  expect_false("bt-cs-file" %in% the_list2$buildTriggerName)
  expect_false("bt-github-source" %in% the_list2$buildTriggerName)
  expect_false("bt-cs-source" %in% the_list2$buildTriggerName)

  info <- cr_buildtrigger_get("0a3cade0-425f-4adc-b86b-14cde51af674")
  expect_equal(info$name, "package-checks")

})

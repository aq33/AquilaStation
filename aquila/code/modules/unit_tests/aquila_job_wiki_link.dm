// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - the job welcome linked to BeeStation's wiki search with the Polish job name; it must point at our wiki page for the job
/datum/unit_test/aquila_job_wiki_link

/datum/unit_test/aquila_job_wiki_link/Run()
	var/old_wikiurl = CONFIG_GET(string/wikiurl)
	CONFIG_SET(string/wikiurl, "https://aqnsv13.miraheze.org/wiki")

	var/barber_url = job_wiki_url(JOB_NAME_BARBER)
	var/engineer_url = job_wiki_url(JOB_NAME_CHIEFENGINEER)
	var/unknown_url = job_wiki_url("Nieistniejące stanowisko")
	CONFIG_SET(string/wikiurl, null)
	var/no_wiki_url = job_wiki_url(JOB_NAME_BARBER)
	CONFIG_SET(string/wikiurl, old_wikiurl)

	TEST_ASSERT(barber_url == "https://aqnsv13.miraheze.org/wiki/Gimmick", "Barber links to [barber_url]")
	TEST_ASSERT(engineer_url == "https://aqnsv13.miraheze.org/wiki/Chief_Engineer", "Chief Engineer links to [engineer_url]")
	TEST_ASSERT(unknown_url == "https://aqnsv13.miraheze.org/wiki/Jobs", "A job without a wiki page links to [unknown_url]")
	TEST_ASSERT(isnull(no_wiki_url), "Without WIKIURL the job welcome still got a link: [no_wiki_url]")

	// Every job a player can join as gets its own page, not the job list fallback
	for(var/datum/job/job as anything in SSjob.occupations)
		TEST_ASSERT(GLOB.job_wiki_pages[job.title], "Job [job.title] has no wiki page in GLOB.job_wiki_pages")

#undef TEST_ASSERT

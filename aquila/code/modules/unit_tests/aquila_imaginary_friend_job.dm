// Makra TEST_ASSERT są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc test modularny ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - wygląd wyimaginowanego przyjaciela nie losuje SI ani cyborga (aquila/code/datums/brain_damage/imaginary_friend_job.dm).
/// Objaw: aquila_surgery_tg_advanced padał losowo na „dynamic preview is unsupported” z /datum/job/ai/equip().
/datum/unit_test/aquila_imaginary_friend_job

/datum/unit_test/aquila_imaginary_friend_job/Run()
	TEST_ASSERT(SSjob.GetJobType(/datum/job/ai), "Brak profesji SI na liście, test nic by nie sprawdził")
	for(var/i in 1 to 300)
		var/datum/job/job = imaginary_friend_preview_job()
		TEST_ASSERT(job, "Brak profesji do wyglądu wyimaginowanego przyjaciela")
		TEST_ASSERT(!istype(job, /datum/job/ai) && !istype(job, /datum/job/cyborg), "Wylosowano profesję bez podglądu: [job.type]")

#undef TEST_ASSERT

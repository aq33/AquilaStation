// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - Citationinator trafia tam, gdzie gracze go szukają: do SecTecha (lista z aquila/code/modules/vending/security.dm)
/// i do plecaka stroju, którego naprawdę używa praca oficera ochrony (NSV13 nadpisuje go na /datum/outfit/job/security)
/datum/unit_test/aquila_citationinator

/datum/unit_test/aquila_citationinator/Run()
	var/obj/machinery/vending/security/vendor = allocate(/obj/machinery/vending/security)
	TEST_ASSERT(vendor.products[/obj/item/citationinator], "SecTech nie sprzedaje Citationinatora")

	var/datum/job/security_officer/job = new
	var/datum/outfit/outfit = new job.outfit
	TEST_ASSERT(outfit.backpack_contents && outfit.backpack_contents[/obj/item/citationinator],"Strój oficera ochrony ([job.outfit]) nie ma Citationinatora w plecaku")

#undef TEST_ASSERT

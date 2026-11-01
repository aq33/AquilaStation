// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - zapis ticketów do bazy: tabela tworzy się sama (albo jest jasne, że bazy nie ma), a zapis nie wywala runtime'u
/datum/unit_test/aquila_ticket_db_log

/datum/unit_test/aquila_ticket_db_log/Run()
	var/ready = ticket_db_ready()
	TEST_ASSERT(ready == !!GLOB.ticket_table_ready, "ticket_db_ready() and GLOB.ticket_table_ready disagree")
	if(!SSdbcore.IsConnected())
		TEST_ASSERT(!ready, "The ticket table is reported ready without a database")
	SSblackbox.LogAhelp(1, "Unit Test", "aquila_ticket_db_log", null, "unittest")

#undef TEST_ASSERT

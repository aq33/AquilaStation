// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - sieć transmisji TV: start transmisji dopisuje sieć do telewizora i Spess.tv, stop ją zdejmuje
/datum/unit_test/aquila_spesstv

/datum/unit_test/aquila_spesstv/Run()
	var/obj/machinery/computer/security/telescreen/entertainment/tv = allocate(/obj/machinery/computer/security/telescreen/entertainment)
	var/datum/computer_file/program/secureye/spesstv/program = new
	var/test_net = "aquila_unit_test_net"

	TEST_ASSERT(!(test_net in tv.network), "Telewizor ma sieć testową przed startem transmisji")
	TEST_ASSERT(tv.speakers, "Telewizor nie ma głośników")
	TEST_ASSERT(tv.speakers.can_receive(FREQ_ENTERTAINMENT, list(0)), "Głośniki telewizora nie odbierają kanału rozrywkowego")
	TEST_ASSERT(!tv.speakers.can_receive(FREQ_CENTCOM, list(0)), "Głośniki telewizora odbierają kanał Centrali")

	start_broadcasting_network(test_net)
	TEST_ASSERT(test_net in tv.network, "Start transmisji nie dopisał sieci do telewizora")
	TEST_ASSERT(test_net in tv.live_networks, "Telewizor nie oznaczył sieci jako nadającej na żywo")
	TEST_ASSERT(test_net in program.network, "Start transmisji nie dopisał sieci do Spess.tv")

	// Dwóch nadawców w jednej sieci: zatrzymanie jednego nie gasi sieci
	var/datum/second_source = new
	start_broadcasting_network(test_net, null, second_source)
	stop_broadcasting_network(test_net)
	TEST_ASSERT(test_net in tv.network, "Zatrzymanie jednego nadawcy zgasiło sieć, w której nadaje drugi")
	stop_broadcasting_network(test_net, null, second_source)
	qdel(second_source)
	TEST_ASSERT(!(test_net in tv.network), "Stop transmisji nie zdjął sieci z telewizora")
	TEST_ASSERT(!length(tv.live_networks), "Telewizor nadal pokazuje transmisję na żywo")
	TEST_ASSERT(!(test_net in program.network), "Stop transmisji nie zdjął sieci ze Spess.tv")
	TEST_ASSERT(CAMERANET_NETWORK_THUNDERDOME in tv.network, "Telewizor zgubił stałą sieć Thunderdome")

	qdel(program)

#undef TEST_ASSERT

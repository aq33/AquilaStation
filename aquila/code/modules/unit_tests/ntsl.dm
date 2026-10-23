// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b].[message ? " [message]" : ""]") }

/// AQUILA - NTSL: Polish text survives the scanner and string functions, scripts edit and block signals, loops and broadcast() are capped, sleep() is gone
/datum/unit_test/ntsl

/datum/unit_test/ntsl/Run()
	var/obj/machinery/telecomms/server/server = allocate(/obj/machinery/telecomms/server)
	var/datum/TCS_Compiler/compiler = server.Compiler

	var/list/errors = compiler.Compile({"def process_signal(sig){
	if(sig.job == "Blokada"){
		sig.pass = false;
		return sig;
	}
	sig.content = replace(sig.content, "żółw", "ŻÓŁW") + " " + tostring(length("zażółć")) + " " + reverse("łąka");
	sig.source = upper("ąę") + substr("źdźbło", 2, 4);
	return sig;
}"})
	TEST_ASSERT(!length(errors), "A valid script with Polish letters did not compile: [length(errors) ? jointext(errors, "; ") : ""]")

	var/datum/signal/subspace/vocal/signal = make_signal("Duży żółw.", "Kucharz")
	compiler.Run(signal)
	TEST_ASSERT(!signal.data["reject"], "A script that returns sig rejected the message")
	TEST_ASSERT(findtext(signal.data["message"], "Duży ŻÓŁW. 6 akął"), "Polish text was mangled: [signal.data["message"]] [script_errors(server)]")
	TEST_ASSERT_EQUAL(signal.data["name"], "ĄĘdź", "Polish source name was mangled")

	var/datum/signal/subspace/vocal/blocked = make_signal("Cześć", "Blokada")
	compiler.Run(blocked)
	TEST_ASSERT(blocked.data["reject"], "sig.pass = false did not block the message")

	// break/continue in loops, an elseif after a returning if, ceil() on whole numbers
	errors = compiler.Compile({"def process_signal(sig){
	if(sig.job == "Pierwszy"){
		return sig;
	} elseif(sig.job == "Drugi"){
		sig.pass = false;
		return sig;
	}
	n = 0;
	while(1){
		n += 1;
		if(n >= 3){
			break;
		}
	}
	odd = 0;
	for(i = 0; i < 6; i += 1){
		if(i % 2 == 0){
			continue;
		}
		odd += 1;
	}
	sig.content = tostring(n) + " " + tostring(odd) + " " + tostring(ceil(2)) + " " + tostring(ceil(2.5));
	return sig;
}"})
	TEST_ASSERT(!length(errors), "The control flow script did not compile")
	compiler.Run(make_signal("x", "Pierwszy"))
	var/datum/signal/subspace/vocal/second = make_signal("x", "Drugi")
	compiler.Run(second)
	TEST_ASSERT(second.data["reject"], "An elseif stayed skipped after the if branch returned on the previous message")
	var/datum/signal/subspace/vocal/flow = make_signal("x", "Kucharz")
	compiler.Run(flow)
	TEST_ASSERT_EQUAL(flow.data["message"], "3 3 2 3", "break/continue/ceil gave wrong results [script_errors(server)]")

	// A runaway loop stops at the iteration cap and broadcast() at its own cap
	errors = compiler.Compile({"def process_signal(sig){
	while(1){
		broadcast(signal("spam", channels.common));
	}
	return sig;
}"})
	TEST_ASSERT(!length(errors), "The loop script did not compile")
	compiler.Run(make_signal("pętla", "Kucharz"))
	TEST_ASSERT_EQUAL(compiler.broadcasts_left, 0, "broadcast() was not capped in a loop")

	// sleep() is not exposed, so a script can't hold radio messages
	errors = compiler.Compile({"def process_signal(sig){
	sleep(600);
	return sig;
}"})
	TEST_ASSERT(!length(errors), "The sleep script did not compile")
	var/started = world.time
	var/datum/signal/subspace/vocal/slept = make_signal("czekaj", "Kucharz")
	compiler.Run(slept)
	TEST_ASSERT_EQUAL(world.time, started, "A script call to sleep() delayed the message")

/datum/unit_test/ntsl/proc/script_errors(obj/machinery/telecomms/server/server)
	var/list/out = list()
	for(var/datum/comm_log_entry/entry in server.log_entries)
		out += entry.parameters["message"]
	return jointext(out, "; ")

/datum/unit_test/ntsl/proc/make_signal(message, job)
	var/mob/living/carbon/human/speaker = allocate(/mob/living/carbon/human)
	var/obj/item/radio/radio = allocate(/obj/item/radio)
	var/atom/movable/virtualspeaker/virt = new(null, speaker, radio)
	virt.job = job
	var/datum/signal/subspace/vocal/signal = new(radio, FREQ_COMMON, virt, /datum/language/common, message, list(), list())
	return signal

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL

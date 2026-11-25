// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - wyrzut rdzenia (E9): brak dostępu blokuje, anulowanie zatrzymuje odliczanie, wyrzut opróżnia komorę napędu burzowego, RBMK i supermaterii
/datum/unit_test/aquila_core_ejection

/datum/unit_test/aquila_core_ejection/Run()
	var/turf/T = run_loc_floor_bottom_left
	var/turf/sm_turf = locate(T.x + 2, T.y, T.z)

	var/mob/living/carbon/human/ce = allocate(/mob/living/carbon/human, T)
	var/obj/item/card/id/ce_card = allocate(/obj/item/card/id, T)
	ce_card.access = list(ACCESS_CE)
	ce.put_in_hands(ce_card)
	var/mob/living/carbon/human/captain = allocate(/mob/living/carbon/human, T)
	var/obj/item/card/id/captain_card = allocate(/obj/item/card/id, T)
	captain_card.access = list(ACCESS_CAPTAIN)
	captain.put_in_hands(captain_card)
	var/mob/living/carbon/human/engineer = allocate(/mob/living/carbon/human, T)
	var/obj/item/card/id/engineer_card = allocate(/obj/item/card/id, T)
	engineer_card.access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP)
	engineer.put_in_hands(engineer_card)

	// Napęd burzowy
	var/obj/machinery/atmospherics/components/binary/stormdrive_reactor/stormdrive = allocate(/obj/machinery/atmospherics/components/binary/stormdrive_reactor, T)
	stormdrive.control_rods += new /obj/item/control_rod(stormdrive)
	var/datum/component/core_ejection/ejection = stormdrive.GetComponent(/datum/component/core_ejection)
	TEST_ASSERT(ejection, "Stormdrive has no core ejection component")
	var/start_state = stormdrive.state

	TEST_ASSERT(!ejection.start_ejection(engineer), "An engineer without CE or captain access started a core ejection")
	TEST_ASSERT(!ejection.eject_timer, "A refused core ejection still started the countdown")

	TEST_ASSERT(ejection.start_ejection(ce), "The chief engineer could not start a core ejection")
	TEST_ASSERT(ejection.eject_timer, "Core ejection started without a countdown timer")
	TEST_ASSERT(!ejection.start_ejection(ce), "A second core ejection started while one was counting down")
	TEST_ASSERT(!ejection.cancel_ejection(engineer), "An engineer without access cancelled a core ejection")
	TEST_ASSERT(ejection.eject_timer, "A refused cancel still stopped the countdown")
	TEST_ASSERT(ejection.cancel_ejection(captain), "The captain could not cancel a core ejection")
	TEST_ASSERT(!ejection.eject_timer, "Cancelled core ejection left the countdown timer running")
	TEST_ASSERT(stormdrive.state == start_state, "Cancelled core ejection changed the stormdrive state to [stormdrive.state]")
	TEST_ASSERT(length(stormdrive.control_rods) == 1, "Cancelled core ejection removed the control rods")

	TEST_ASSERT(ejection.start_ejection(captain), "The captain could not start a core ejection")
	stormdrive.heat = 500
	cleanup_ejected(run_ejection(ejection))
	TEST_ASSERT(stormdrive.state == 7, "Ejected stormdrive is in state [stormdrive.state] instead of REACTOR_STATE_REFIT (7)")
	TEST_ASSERT(!length(stormdrive.control_rods), "Ejected stormdrive still has its control rods")
	TEST_ASSERT(stormdrive.heat == 0, "Ejected stormdrive still has heat [stormdrive.heat]")
	TEST_ASSERT(!ejection.start_ejection(ce), "Core ejection started on a stormdrive with no core")

	// RBMK
	var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/rbmk = allocate(/obj/machinery/atmospherics/components/trinary/nuclear_reactor, T)
	rbmk.fuel_rods += new /obj/item/fuel_rod(rbmk)
	rbmk.fuel_rods += new /obj/item/fuel_rod(rbmk)
	rbmk.temperature = 300
	ejection = rbmk.GetComponent(/datum/component/core_ejection)
	TEST_ASSERT(ejection, "RBMK has no core ejection component")
	TEST_ASSERT(!ejection.start_ejection(engineer), "An engineer without access started an RBMK core ejection")
	TEST_ASSERT(ejection.start_ejection(ce), "The chief engineer could not start an RBMK core ejection")
	cleanup_ejected(run_ejection(ejection))
	TEST_ASSERT(!length(rbmk.fuel_rods), "Ejected RBMK still has [length(rbmk.fuel_rods)] fuel rods")
	TEST_ASSERT(!rbmk.slagged, "Ejected RBMK is slagged and cannot be refuelled")
	TEST_ASSERT(rbmk.temperature == 0, "Ejected RBMK still has temperature [rbmk.temperature]")
	TEST_ASSERT(!ejection.start_ejection(ce), "Core ejection started on an RBMK with no fuel rods")

	// Supermateria
	var/obj/machinery/power/supermatter_crystal/shard/crystal = allocate(/obj/machinery/power/supermatter_crystal/shard, sm_turf)
	ejection = crystal.GetComponent(/datum/component/core_ejection)
	TEST_ASSERT(ejection, "Supermatter has no core ejection component")
	crystal.final_countdown = TRUE
	TEST_ASSERT(!ejection.start_ejection(ce), "Core ejection started on a supermatter that is already delaminating")
	crystal.final_countdown = FALSE
	TEST_ASSERT(ejection.start_ejection(ce), "The chief engineer could not start a supermatter core ejection")
	cleanup_ejected(run_ejection(ejection))
	TEST_ASSERT(QDELETED(crystal), "Ejected supermatter crystal is still in the chamber")

/// Kończy odliczanie od razu, bez czekania 30 s
/datum/unit_test/aquila_core_ejection/proc/run_ejection(datum/component/core_ejection/ejection)
	deltimer(ejection.eject_timer)
	return ejection.finish_ejection()

/// Rdzeń wyrzucony na overmapę nie może wybuchnąć przy okręcie w trakcie kolejnych testów
/datum/unit_test/aquila_core_ejection/proc/cleanup_ejected(result)
	if(istype(result, /obj/structure/space_mine/ejected_core))
		qdel(result)

#undef TEST_ASSERT

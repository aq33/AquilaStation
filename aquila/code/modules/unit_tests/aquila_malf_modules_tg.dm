// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Moduły zbuntowanej SI z tg: zdalny emag, zakłócenie interkomów, zmiana głosu
/datum/unit_test/aquila_malf_modules_tg

/datum/unit_test/aquila_malf_modules_tg/Run()
	var/mob/living/carbon/human/brain_holder = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/silicon/ai/ai = allocate(/mob/living/silicon/ai, run_loc_floor_bottom_left, null, brain_holder)

	// Zdalny emag: zamknięta szafka zostaje wyłamana i zużywa jeden ładunek
	var/datum/action/innate/ai/ranged/aq_remote_emag/emag = new
	emag.Grant(ai)
	var/obj/structure/closet/secure_closet/closet = allocate(/obj/structure/closet/secure_closet, get_step(get_step(run_loc_floor_bottom_left, NORTH), NORTH))
	TEST_ASSERT(emag.try_emag(ai, closet), "Zdalny emag szafki się nie udał")
	TEST_ASSERT(closet.broken && !closet.locked, "Szafka po zdalnym emagu dalej jest zamknięta")
	TEST_ASSERT(emag.uses == 6, "Zdalny emag zużył [7 - emag.uses] ładunków zamiast jednego")
	// Drugi raz na tej samej szafce nic się nie dzieje i ładunek zostaje
	TEST_ASSERT(!emag.try_emag(ai, closet), "Zdalny emag drugi raz zadziałał na wyłamanej szafce")
	TEST_ASSERT(emag.uses == 6, "Nieudany zdalny emag zużył ładunek")
	// Człowieka nie da się zemagować, a konsola IFF (zadanie zdrajcy) i prom ewakuacyjny są na czarnej liście
	TEST_ASSERT(!emag.try_emag(ai, brain_holder), "Zdalny emag zadziałał na człowieku")
	TEST_ASSERT(GLOB.aq_malf_emag_blacklist[/obj/machinery/computer/iff_console], "Konsola IFF nie jest na czarnej liście zdalnego emagu")
	TEST_ASSERT(GLOB.aq_malf_emag_blacklist[/obj/machinery/computer/emergency_shuttle], "Konsola promu ewakuacyjnego nie jest na czarnej liście zdalnego emagu")
	TEST_ASSERT(emag.uses == 6, "Odrzucony cel zużył ładunek")

	// Zakłócenie interkomów: bez ochrony słuchu drgawki, w nausznikach nic
	var/obj/item/radio/intercom/intercom = allocate(/obj/item/radio/intercom, run_loc_floor_bottom_left)
	TEST_ASSERT(intercom in GLOB.aq_intercoms, "Nowy interkom nie trafił na listę interkomów")
	var/turf/next_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/mob/living/carbon/human/deaf_victim = allocate(/mob/living/carbon/human, next_turf)
	var/mob/living/carbon/human/protected = allocate(/mob/living/carbon/human, next_turf)
	protected.equip_to_slot_or_del(new /obj/item/clothing/ears/earmuffs(protected), ITEM_SLOT_EARS)
	intercom.on = FALSE
	TEST_ASSERT(!intercom.aq_malf_blast(), "Wyłączony interkom zagrał")
	TEST_ASSERT(!deaf_victim.jitteriness, "Wyłączony interkom oszołomił człowieka")
	intercom.on = TRUE
	TEST_ASSERT(intercom.aq_malf_blast(), "Włączony interkom nie zagrał")
	TEST_ASSERT(deaf_victim.jitteriness > 0, "Człowiek bez ochrony słuchu nie drży po huku")
	TEST_ASSERT(!protected.jitteriness, "Nauszniki nie ochroniły przed hukiem")
	qdel(intercom)
	TEST_ASSERT(!(intercom in GLOB.aq_intercoms), "Usunięty interkom został na liście interkomów")

	// Zmiana głosu: radio pokazuje podane imię, pusty tekst przywraca własne
	var/real_voice = ai.GetVoice()
	ai.aq_set_fake_voice("Kapitan")
	TEST_ASSERT(ai.GetVoice() == "Kapitan", "Po zmianie głosu SI mówi jako [ai.GetVoice()]")
	var/atom/movable/virtualspeaker/speaker = new(null, ai, ai.radio)
	var/radio_name = speaker.name
	qdel(speaker)
	TEST_ASSERT(radio_name == "Kapitan", "W radiu SI podpisuje się jako [radio_name]")
	ai.aq_set_fake_voice("")
	TEST_ASSERT(ai.GetVoice() == real_voice, "Pusty tekst nie przywrócił głosu SI")
	// Utrata modułu przywraca własny głos
	var/datum/action/innate/ai/aq_voice_changer/voice_action = new
	voice_action.Grant(ai)
	ai.aq_set_fake_voice("Mostek")
	qdel(voice_action)
	TEST_ASSERT(ai.GetVoice() == real_voice, "Po utracie modułu SI dalej mówi cudzym głosem")
	qdel(emag)

#undef TEST_ASSERT

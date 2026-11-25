// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b][message ? ": [message]" : ""]") }

/// Cechy z grupy „zmysły” (aquila/code/datums/traits/extra/zmysly.dm): każda daje zapowiedziany efekt i schodzi bez śladu
/datum/unit_test/aquila_quirks_extra_zmysly
	/// Ile razy posiadacz Chrapania zachrapał
	var/snores = 0

/datum/unit_test/aquila_quirks_extra_zmysly/Run()
	var/turf/open/floor = run_loc_floor_bottom_left
	var/static/list/quirk_types = list(
		/datum/quirk/bald, /datum/quirk/shifty_eyes, /datum/quirk/clumsy, /datum/quirk/illiterate, /datum/quirk/photophobia,
		/datum/quirk/softspoken, /datum/quirk/throwingarm, /datum/quirk/anosmia, /datum/quirk/scarred_eye,
		/datum/quirk/touchy, /datum/quirk/fluoride_stare, /datum/quirk/keen_nose, /datum/quirk/snoring,
		/datum/quirk/life_savings, /datum/quirk/dirty, /datum/quirk/pet_owner, /datum/quirk/colorist,
	)
	// Każda cecha jest w oknie postaci, dodaje się z efektami startowymi i zdejmuje
	for(var/quirk_type in quirk_types)
		var/datum/quirk/quirk_path = quirk_type
		TEST_ASSERT(SSquirks.quirks[initial(quirk_path.name)] == quirk_type, "[quirk_type] is not registered under its name")
		var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human, floor)
		TEST_ASSERT(H.add_quirk(quirk_type, TRUE), "[quirk_type] could not be added")
		TEST_ASSERT(H.has_quirk(quirk_type), "[quirk_type] was not added")
		TEST_ASSERT(H.remove_quirk(quirk_type), "[quirk_type] could not be removed")
		TEST_ASSERT(!H.has_quirk(quirk_type), "[quirk_type] was not removed")
		strip_spawned(H)

	// Łysina: goła głowa, peruka z dawną fryzurą, smutek bez nakrycia głowy
	var/mob/living/carbon/human/bald = allocate(/mob/living/carbon/human, floor)
	bald.hair_style = "Business Hair"
	bald.add_quirk(/datum/quirk/bald, TRUE)
	TEST_ASSERT_EQUAL(bald.hair_style, "Bald", "Smooth-Headed did not shave the head")
	var/obj/item/clothing/head/wig/wig = bald.head
	TEST_ASSERT(istype(wig), "Smooth-Headed did not put a wig on the head")
	TEST_ASSERT_EQUAL(wig.hair_style, "Business Hair", "The wig does not have the old hairstyle")
	var/datum/component/mood/mood = bald.GetComponent(/datum/component/mood)
	TEST_ASSERT(istype(mood?.mood_events["bad_hair_day"], /datum/mood_event/aq_confident_mane), "Wearing the wig gives no confidence")
	bald.dropItemToGround(wig)
	TEST_ASSERT(istype(mood.mood_events["bad_hair_day"], /datum/mood_event/aq_bald), "An uncovered bald head gives no bad moodlet")
	qdel(wig)
	bald.remove_quirk(/datum/quirk/bald)
	TEST_ASSERT_EQUAL(bald.hair_style, "Business Hair", "Losing Smooth-Headed did not bring the hair back")
	TEST_ASSERT(!mood.mood_events["bad_hair_day"], "Losing Smooth-Headed left the hair moodlet")

	// Traity: Rozbiegane Oczy, Niezdara, Analfabeta, Cichy Głos, Dotykalski, Czuły Nos
	var/mob/living/carbon/human/traits = allocate(/mob/living/carbon/human, floor)
	TEST_ASSERT(traits.is_literate(), "The test human cannot read before the quirk")
	traits.add_quirk(/datum/quirk/shifty_eyes)
	traits.add_quirk(/datum/quirk/clumsy)
	traits.add_quirk(/datum/quirk/illiterate)
	traits.add_quirk(/datum/quirk/softspoken)
	TEST_ASSERT(HAS_TRAIT(traits, TRAIT_SHIFTY_EYES), "Shifty Eyes gave no trait")
	TEST_ASSERT(HAS_TRAIT(traits, TRAIT_CLUMSY), "Clumsy gave no clumsiness")
	TEST_ASSERT(!traits.is_literate(), "Illiterate can still read")
	TEST_ASSERT(HAS_TRAIT(traits, TRAIT_WHISPER_ONLY), "Soft-Spoken does not force a whisper")
	traits.remove_quirk(/datum/quirk/illiterate)
	TEST_ASSERT(traits.is_literate(), "Losing Illiterate did not bring reading back")

	// Światłowstręt: oczy gorzej znoszą błysk, po utracie wracają do normy
	var/mob/living/carbon/human/photophobe = allocate(/mob/living/carbon/human, floor)
	var/obj/item/organ/eyes/eyes = photophobe.getorganslot(ORGAN_SLOT_EYES)
	var/normal_protection = eyes.flash_protect
	photophobe.add_quirk(/datum/quirk/photophobia)
	TEST_ASSERT_EQUAL(eyes.flash_protect, max(normal_protection - 1, -1), "Photophobia did not weaken the eyes")
	photophobe.remove_quirk(/datum/quirk/photophobia)
	TEST_ASSERT_EQUAL(eyes.flash_protect, normal_protection, "Losing Photophobia did not restore the eyes")

	// Mocny Rzut: rzut leci o 2 pola dalej
	var/mob/living/carbon/human/thrower = allocate(/mob/living/carbon/human, floor)
	thrower.add_quirk(/datum/quirk/throwingarm)
	var/obj/item/toy/crayon/red/crayon = allocate(/obj/item/toy/crayon/red, floor)
	thrower.put_in_active_hand(crayon)
	thrower.throw_item(locate(floor.x + 6, floor.y, floor.z))
	var/datum/thrownthing/throw_data = SSthrowing.processing[crayon]
	TEST_ASSERT(throw_data, "The crayon was not thrown")
	TEST_ASSERT_EQUAL(throw_data.maxrange, initial(crayon.throw_range) + 2, "Throwing Arm did not add range")
	SSthrowing.processing -= crayon
	qdel(throw_data)

	// Anosmia: dym nie pachnie; Czuły Nos: zapach trzymanego pojemnika przy oglądaniu
	for(var/datum/pollution/old_pollution as anything in SSpollution.all_polution.Copy())
		qdel(old_pollution)
	var/mob/living/carbon/human/sniffer = allocate(/mob/living/carbon/human, floor)
	floor.pollute_turf(/datum/pollutant/smoke, 200)
	TEST_ASSERT(floor.pollution?.smell_act(sniffer), "A normal nose did not smell thick smoke")
	sniffer.add_quirk(/datum/quirk/anosmia)
	TEST_ASSERT(!floor.pollution.smell_act(sniffer), "Anosmia still smells smoke")
	floor.pollution.scrub_amount(INFINITY)
	sniffer.remove_quirk(/datum/quirk/anosmia)
	sniffer.add_quirk(/datum/quirk/keen_nose)
	var/obj/item/reagent_containers/glass/beaker/beaker = allocate(/obj/item/reagent_containers/glass/beaker, floor)
	beaker.reagents.add_reagent(/datum/reagent/consumable/orangejuice, 20)
	TEST_ASSERT(!findtext(jointext(beaker.examine(sniffer), " "), "Wąchasz"), "Keen Nose smells a beaker that is not held")
	sniffer.put_in_active_hand(beaker)
	TEST_ASSERT(findtext(jointext(beaker.examine(sniffer), " "), "Wąchasz"), "Keen Nose does not smell a held open beaker")

	// Okaleczone Oko: krótkowzroczność z własnego źródła i opaska
	var/mob/living/carbon/human/pirate = allocate(/mob/living/carbon/human, floor)
	pirate.add_quirk(/datum/quirk/scarred_eye, TRUE)
	TEST_ASSERT(HAS_TRAIT_FROM(pirate, TRAIT_NEARSIGHT, SCARRED_EYE_TRAIT), "Scarred Eye did not blur the vision")
	TEST_ASSERT(istype(pirate.glasses, /obj/item/clothing/glasses/eyepatch), "Scarred Eye gave no eyepatch")
	pirate.remove_quirk(/datum/quirk/scarred_eye)
	TEST_ASSERT(!HAS_TRAIT(pirate, TRAIT_NEARSIGHT), "Losing Scarred Eye left the nearsightedness")

	// Dotykalski: Shift+klik z daleka jest blokowany, z bliska nie
	var/mob/living/carbon/human/toucher = allocate(/mob/living/carbon/human, floor)
	toucher.add_quirk(/datum/quirk/touchy)
	var/obj/item/far_item = allocate(/obj/item/toy/crayon/blue, locate(floor.x + 3, floor.y, floor.z))
	var/obj/item/near_item = allocate(/obj/item/toy/crayon/green, floor)
	var/list/shift_click = list(SHIFT_CLICK = "1")
	TEST_ASSERT(SEND_SIGNAL(toucher, COMSIG_MOB_CLICKON, far_item, shift_click) & COMSIG_MOB_CANCEL_CLICKON, "Touchy can examine from afar")
	TEST_ASSERT(!(SEND_SIGNAL(toucher, COMSIG_MOB_CLICKON, near_item, shift_click) & COMSIG_MOB_CANCEL_CLICKON), "Touchy cannot examine an adjacent item")
	TEST_ASSERT(!(SEND_SIGNAL(toucher, COMSIG_MOB_CLICKON, far_item, list()) & COMSIG_MOB_CANCEL_CLICKON), "Touchy blocks plain clicks")

	// Bez Powiek: brak powiek, oczy wysychają, sól fizjologiczna je nawilża
	var/mob/living/carbon/human/starer = allocate(/mob/living/carbon/human, floor)
	starer.add_quirk(/datum/quirk/fluoride_stare)
	TEST_ASSERT(HAS_TRAIT(starer, TRAIT_NO_EYELIDS), "Fluoride Stare left the eyelids")
	var/datum/quirk/fluoride_stare/stare = locate() in starer.roundstart_quirks
	var/obj/item/organ/eyes/dry_eyes = starer.getorganslot(ORGAN_SLOT_EYES)
	stare.last_wet = world.time - 10 MINUTES
	stare.on_process(2)
	TEST_ASSERT(dry_eyes.damage > 0, "Dry eyes took no damage")
	var/datum/reagent/medicine/salglu_solution/saline = new
	saline.reaction_mob(starer, TOUCH, 5)
	qdel(saline)
	TEST_ASSERT_EQUAL(stare.last_wet, world.time, "Saline did not wet the eyes")
	starer.remove_quirk(/datum/quirk/fluoride_stare)
	TEST_ASSERT(!HAS_TRAIT(starer, TRAIT_NO_EYELIDS), "Losing Fluoride Stare did not bring the eyelids back")

	// Chrapanie: śpiący chrapie
	var/mob/living/carbon/human/sleeper = allocate(/mob/living/carbon/human, floor)
	sleeper.add_quirk(/datum/quirk/snoring)
	RegisterSignal(sleeper, COMSIG_MOB_EMOTE, PROC_REF(on_emote))
	var/datum/quirk/snoring/snoring = locate() in sleeper.roundstart_quirks
	snoring.on_process(1)
	TEST_ASSERT_EQUAL(snores, 0, "An awake snorer snored")
	sleeper.SetSleeping(20 SECONDS)
	snoring.on_process(1000)
	TEST_ASSERT_EQUAL(snores, 1, "A sleeping snorer did not snore")
	UnregisterSignal(sleeper, COMSIG_MOB_EMOTE)

	// Oszczędności Życia: +25% wypłaty
	var/datum/bank_account/account = new("Test", SSjob.GetJob(JOB_NAME_ASSISTANT))
	account.paycheck_amount = 100
	account.payday(1, TRUE)
	TEST_ASSERT_EQUAL(account.account_balance, 100, "A normal payday paid a bonus")
	account.aq_life_savings = TRUE
	account.payday(1, TRUE)
	TEST_ASSERT_EQUAL(account.account_balance, 225, "Life Savings did not add a quarter of the paycheck")
	qdel(account)

	// Brudas: mycie zdejmuje brud i psuje humor, brud wraca
	var/mob/living/carbon/human/slob = allocate(/mob/living/carbon/human, floor)
	slob.add_quirk(/datum/quirk/dirty)
	var/datum/quirk/dirty/dirty = locate() in slob.roundstart_quirks
	TEST_ASSERT(findtext(jointext(slob.examine(slob), " "), "cała w brudzie"), "Dirty is not visible on examine")
	slob.set_hygiene(HYGIENE_LEVEL_DISGUSTING)
	slob.set_hygiene(HYGIENE_LEVEL_CLEAN)
	TEST_ASSERT(dirty.cleaned, "A shower did not clean the slob")
	var/datum/component/mood/slob_mood = slob.GetComponent(/datum/component/mood)
	TEST_ASSERT(istype(slob_mood.mood_events["dirty_quirk_washed"], /datum/mood_event/aq_dirty_washed), "Being washed did not upset the slob")
	dirty.redirty()
	TEST_ASSERT(!dirty.cleaned, "The dirt did not come back")
	TEST_ASSERT(!slob_mood.mood_events["dirty_quirk_washed"], "Getting dirty again did not clear the moodlet")

	// Właściciel Zwierzaka: zwierzak w zamkniętym transporterze
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, floor)
	owner.add_quirk(/datum/quirk/pet_owner, TRUE)
	var/obj/item/pet_carrier/carrier = locate() in owner.held_items
	if(!carrier)
		carrier = locate() in floor
	TEST_ASSERT(carrier, "Pet Owner gave no pet carrier")
	TEST_ASSERT_EQUAL(length(carrier.occupants), 1, "The pet carrier is empty")
	TEST_ASSERT(!carrier.open, "The pet carrier is open")
	var/mob/living/pet = carrier.occupants[1]
	TEST_ASSERT(REF(owner) in pet.faction, "The pet is not friends with its owner")
	strip_spawned(owner)

	// Kolorysta: farba w sprayu
	var/mob/living/carbon/human/colorist = allocate(/mob/living/carbon/human, floor)
	colorist.add_quirk(/datum/quirk/colorist, TRUE)
	var/obj/item/dyespray/spray = locate() in colorist.held_items
	TEST_ASSERT(spray, "Colorist gave no hair dye spray")
	qdel(spray)

/// Usuwa przedmioty i zwierzaki z efektów startowych, żeby nie zostały po teście
/datum/unit_test/aquila_quirks_extra_zmysly/proc/strip_spawned(mob/living/carbon/human/H)
	for(var/obj/item/pet_carrier/carrier in H.GetAllContents() + H.loc.contents)
		for(var/mob/living/pet in carrier.occupants)
			qdel(pet)
	for(var/obj/item/spawned in H.held_items + H.get_equipped_items(TRUE))
		qdel(spawned)

/datum/unit_test/aquila_quirks_extra_zmysly/proc/on_emote(mob/source, datum/emote/emote)
	SIGNAL_HANDLER
	if(emote.key == "snore")
		snores++

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL

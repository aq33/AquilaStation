// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b][message ? ": [message]" : ""]") }

/// Cechy z grupy „nastrój”: każda się dodaje i usuwa, daje swój trait i zapowiedziany efekt
/datum/unit_test/aquila_quirks_extra_nastroj

/// Człowiek z nastrojem (w configu testów nastrój może być wyłączony)
/datum/unit_test/aquila_quirks_extra_nastroj/proc/make_human()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	if(!human.GetComponent(/datum/component/mood))
		human.AddComponent(/datum/component/mood)
	return human

/datum/unit_test/aquila_quirks_extra_nastroj/proc/mood_event(mob/living/target, category)
	var/datum/component/mood/mood = target.GetComponent(/datum/component/mood)
	return mood?.get_event(category)

/datum/unit_test/aquila_quirks_extra_nastroj/proc/give_quirk(mob/living/carbon/human/target, quirk_type)
	target.add_quirk(quirk_type)
	return locate(quirk_type) in target.roundstart_quirks

/datum/unit_test/aquila_quirks_extra_nastroj/Run()
	var/list/quirk_types = list(
		/datum/quirk/monophobia, /datum/quirk/claustrophobia, /datum/quirk/gamer, /datum/quirk/clown_enjoyer,
		/datum/quirk/mime_fan, /datum/quirk/poster_boy, /datum/quirk/cursed,
		/datum/quirk/evil, /datum/quirk/transhumanist, /datum/quirk/body_purist, /datum/quirk/pyromania,
		/datum/quirk/pyrophobia, /datum/quirk/kleptomaniac, /datum/quirk/joker, /datum/quirk/extrovert,
		/datum/quirk/introvert, /datum/quirk/bad_touch, /datum/quirk/snob, /datum/quirk/nervous,
	)
	// Każda cecha jest w oknie preferencji, ma ikonę, dodaje się i usuwa razem ze swoim traitem
	for(var/datum/quirk/quirk_type as anything in quirk_types)
		TEST_ASSERT_EQUAL(SSquirks.quirks[initial(quirk_type.name)], quirk_type, "[quirk_type] is not registered under its name")
		TEST_ASSERT(initial(quirk_type.icon), "[quirk_type] has no icon")
		var/mob/living/carbon/human/subject = make_human()
		TEST_ASSERT(give_quirk(subject, quirk_type), "[quirk_type] could not be added")
		var/trait = initial(quirk_type.mob_trait)
		if(trait)
			TEST_ASSERT(HAS_TRAIT(subject, trait), "[quirk_type] did not give [trait]")
		TEST_ASSERT(subject.remove_quirk(quirk_type), "[quirk_type] could not be removed")
		TEST_ASSERT(!subject.has_quirk(quirk_type), "[quirk_type] stayed after removal")
		if(trait)
			TEST_ASSERT(!HAS_TRAIT_FROM(subject, trait, ROUNDSTART_TRAIT), "[quirk_type] left [trait] behind")
		qdel(subject)

	// Wykluczenia trafiły do listy okna preferencji
	var/found_exclusion = FALSE
	for(var/list/group as anything in SSquirks.quirk_blacklist)
		if((initial(/datum/quirk/extrovert::name) in group) && (initial(/datum/quirk/introvert::name) in group))
			found_exclusion = TRUE
	TEST_ASSERT(found_exclusion, "Extrovert and introvert can be picked together")

	// Monofobia i kleptomania to urazy mózgu
	var/mob/living/carbon/human/lonely = make_human()
	give_quirk(lonely, /datum/quirk/monophobia)
	TEST_ASSERT(lonely.has_trauma_type(/datum/brain_trauma/severe/monophobia), "Monophobia gave no trauma")
	lonely.remove_quirk(/datum/quirk/monophobia)
	TEST_ASSERT(!lonely.has_trauma_type(/datum/brain_trauma/severe/monophobia), "Monophobia trauma stayed after removal")

	var/mob/living/carbon/human/thief = make_human()
	give_quirk(thief, /datum/quirk/kleptomaniac)
	var/datum/brain_trauma/severe/kleptomaniac/klepto = thief.has_trauma_type(/datum/brain_trauma/severe/kleptomaniac)
	TEST_ASSERT(klepto, "Kleptomania gave no trauma")
	// Ręce muszą być wolne. Uraz działa już w Life(), więc kleptoman mógł coś podnieść, zanim test tu doszedł.
	for(var/obj/item/held in thief.held_items)
		qdel(held)
	allocate(/obj/item/pen, get_step(thief, EAST))
	TEST_ASSERT(klepto.steal_from_ground(), "The kleptomaniac found nothing to take")
	// Kleptoman bierze losową rzecz z sąsiednich pól, a obok mogą leżeć rzeczy z wcześniejszych części testu
	var/list/taken = thief.held_items - null
	TEST_ASSERT(length(taken) == 1, "The kleptomaniac did not pick up anything")

	// Klaustrofobia: w szafce panika, na podłodze spokój
	var/mob/living/carbon/human/boxed = make_human()
	var/datum/quirk/claustrophobia/claustrophobia = give_quirk(boxed, /datum/quirk/claustrophobia)
	var/obj/structure/closet/locker = allocate(/obj/structure/closet, run_loc_floor_bottom_left)
	boxed.forceMove(locker)
	claustrophobia.on_process(1)
	TEST_ASSERT(mood_event(boxed, "claustrophobia"), "Claustrophobia did not panic inside a locker")
	boxed.forceMove(run_loc_floor_bottom_left)
	claustrophobia.on_process(1)
	TEST_ASSERT(!mood_event(boxed, "claustrophobia"), "Claustrophobia stayed after leaving the locker")

	// Gracz: dieta, wygrana na automacie, przegrana
	var/mob/living/carbon/human/gamer = make_human()
	give_quirk(gamer, /datum/quirk/gamer)
	var/obj/item/organ/tongue/tongue = gamer.getorganslot(ORGAN_SLOT_TONGUE)
	TEST_ASSERT_EQUAL(tongue.liked_food, JUNKFOOD, "The gamer does not crave junk food")
	var/obj/machinery/computer/arcade/battle/arcade = allocate(/obj/machinery/computer/arcade/battle, get_step(gamer, NORTH))
	arcade.enemy_hp = 0
	arcade.arcade_action(gamer)
	TEST_ASSERT(mood_event(gamer, "gamer_won"), "Winning on the arcade did not please the gamer")
	SEND_SIGNAL(gamer, COMSIG_MOB_LOST_VIDEOGAME)
	TEST_ASSERT(mood_event(gamer, "gamer_lost"), "Losing did not upset the gamer")
	for(var/obj/item/prize in get_turf(arcade))
		qdel(prize)

	// Przypinki: nastrój po przypięciu do munduru, tylko u fana
	var/mob/living/carbon/human/clown_fan = make_human()
	give_quirk(clown_fan, /datum/quirk/clown_enjoyer)
	var/obj/item/clothing/under/color/grey/uniform = allocate(/obj/item/clothing/under/color/grey)
	TEST_ASSERT(clown_fan.equip_to_slot_if_possible(uniform, ITEM_SLOT_ICLOTHING, disable_warning = TRUE), "Could not dress the clown fan")
	var/obj/item/clothing/accessory/clown_enjoyer_pin/clown_pin = allocate(/obj/item/clothing/accessory/clown_enjoyer_pin)
	clown_pin.attach(uniform, clown_fan)
	TEST_ASSERT(mood_event(clown_fan, "clown_enjoyer_pin"), "The clown pin did not cheer up the clown fan")
	clown_pin.detach(uniform, clown_fan)
	TEST_ASSERT(!mood_event(clown_fan, "clown_enjoyer_pin"), "The clown pin mood stayed after unpinning")
	var/mob/living/carbon/human/mime_fan = make_human()
	var/datum/quirk/mime_fan/mime_quirk = give_quirk(mime_fan, /datum/quirk/mime_fan)
	mime_quirk.on_spawn()
	TEST_ASSERT(mime_fan.is_holding_item_of_type(/obj/item/clothing/accessory/mime_fan_pin), "The mime fan got no pin")

	// Plakaciarz: pudełko plakatów, a powieszony plakat poprawia nastrój widzom
	var/mob/living/carbon/human/poster_boy = make_human()
	var/datum/quirk/poster_boy/poster_quirk = give_quirk(poster_boy, /datum/quirk/poster_boy)
	poster_quirk.on_spawn()
	var/obj/item/storage/box/posterbox/box = poster_boy.is_holding_item_of_type(/obj/item/storage/box/posterbox)
	TEST_ASSERT(box, "The poster boy got no box of posters")
	TEST_ASSERT_EQUAL(length(box.contents), 3, "The box does not hold three posters")
	var/obj/structure/sign/poster/quirk/poster = allocate(/obj/structure/sign/poster/quirk, get_step(poster_boy, EAST))
	poster_boy.mind_initialize()
	poster.on_seen(poster_boy)
	TEST_ASSERT(mood_event(poster_boy, "poster_mood"), "Seeing the poster did not cheer anyone up")

	// Przeklęty: omen, a groźne poślizgnięcie rani głowę
	var/mob/living/carbon/human/cursed = make_human()
	give_quirk(cursed, /datum/quirk/cursed)
	var/datum/component/omen/omen = cursed.GetComponent(/datum/component/omen)
	TEST_ASSERT(omen, "Cursed gave no omen")
	omen.luck_mod = 100
	SEND_SIGNAL(cursed, COMSIG_ON_CARBON_SLIP)
	TEST_ASSERT(cursed.getOrganLoss(ORGAN_SLOT_BRAIN) > 0, "A cursed slip did not hurt the head")
	cursed.remove_quirk(/datum/quirk/cursed)
	TEST_ASSERT(!cursed.GetComponent(/datum/component/omen), "The omen stayed after removing the quirk")
	TEST_ASSERT(!HAS_TRAIT(cursed, TRAIT_CURSED), "TRAIT_CURSED stayed after removing the quirk")

	// Z gruntu zły: empata widzi zło w oczach
	var/mob/living/carbon/human/villain = make_human()
	give_quirk(villain, /datum/quirk/evil)
	var/mob/living/carbon/human/empath = make_human()
	ADD_TRAIT(empath, TRAIT_EMPATH, TRAIT_GENERIC)
	var/seen_evil = FALSE
	for(var/line in villain.examine(empath))
		if(findtext("[line]", "ciemność"))
			seen_evil = TRUE
	TEST_ASSERT(seen_evil, "An empath did not see the evil")

	// Transhumanista: robotyczna kończyna i nastrój od ciała oraz otoczenia
	var/mob/living/carbon/human/transhumanist = make_human()
	var/datum/quirk/transhumanist/transhumanist_quirk = give_quirk(transhumanist, /datum/quirk/transhumanist)
	TEST_ASSERT(istype(mood_event(transhumanist, "transhumanist_bodypart"), /datum/mood_event/completely_organic), "A fully organic transhumanist is not miserable")
	transhumanist_quirk.on_spawn()
	var/robotic_limbs = 0
	for(var/obj/item/bodypart/limb as anything in transhumanist.bodyparts)
		if(limb.bodytype & BODYTYPE_ROBOTIC)
			robotic_limbs++
	TEST_ASSERT_EQUAL(robotic_limbs, 1, "The transhumanist did not start with one robotic limb")
	TEST_ASSERT(!istype(mood_event(transhumanist, "transhumanist_bodypart"), /datum/mood_event/completely_organic), "The robotic limb did not change the body mood")
	var/mob/living/carbon/human/organic = make_human()
	organic.forceMove(get_step(transhumanist, NORTH))
	transhumanist_quirk.on_process(1)
	// Inni ludzie z tego testu też stoją obok, więc wystarczy dowolny zły nastrój od organicznych
	var/datum/mood_event/people_mood = mood_event(transhumanist, "transhumanist_people")
	TEST_ASSERT(people_mood && people_mood.mood_change < 0, "Organic neighbours did not annoy the transhumanist")

	// Purysta ciała: każda sztuczna część to -10 nastroju
	var/mob/living/carbon/human/purist = make_human()
	var/datum/quirk/body_purist/purist_quirk = give_quirk(purist, /datum/quirk/body_purist)
	TEST_ASSERT(!mood_event(purist, "body_purist"), "A natural body upset the body purist")
	var/obj/item/bodypart/l_arm/robot/robot_arm = new(purist)
	var/obj/item/bodypart/old_arm = purist.get_bodypart(BODY_ZONE_L_ARM)
	robot_arm.replace_limb(purist)
	qdel(old_arm)
	purist_quirk.check_cybernetics()
	var/datum/mood_event/purist_mood = mood_event(purist, "body_purist")
	TEST_ASSERT(purist_mood, "A robotic arm did not upset the body purist")
	TEST_ASSERT_EQUAL(purist_mood.mood_change, -10, "Wrong body purist mood for one robotic part")

	// Piromania i pirofobia: ogień obok zmienia nastrój, piroman lepiej znosi gorąco
	var/obj/item/lighter/lighter = allocate(/obj/item/lighter, run_loc_floor_bottom_left)
	lighter.lit = TRUE
	var/mob/living/carbon/human/pyro = make_human()
	var/datum/quirk/pyromania/pyromania = give_quirk(pyro, /datum/quirk/pyromania)
	TEST_ASSERT(pyro.physiology.heat_mod < 1, "Pyromania did not lower heat damage")
	pyromania.on_process(1)
	var/datum/mood_event/pyro_mood = mood_event(pyro, "pyromania_fire")
	TEST_ASSERT(pyro_mood && pyro_mood.mood_change > 0, "A lit lighter did not please the pyromaniac")
	pyro.remove_quirk(/datum/quirk/pyromania)
	TEST_ASSERT(abs(pyro.physiology.heat_mod - 1) < 0.01, "Removing pyromania did not restore heat damage")
	var/mob/living/carbon/human/firefearer = make_human()
	var/datum/quirk/pyrophobia/pyrophobia = give_quirk(firefearer, /datum/quirk/pyrophobia)
	pyrophobia.on_process(1)
	var/datum/mood_event/fear_mood = mood_event(firefearer, "pyrophobia")
	TEST_ASSERT(fear_mood && fear_mood.mood_change < 0, "A lit lighter did not scare the pyrophobe")
	lighter.lit = FALSE
	pyrophobia.on_process(1)
	TEST_ASSERT(!mood_event(firefearer, "pyrophobia"), "The fear stayed without fire")

	// Snob: bałagan psuje humor
	var/mob/living/carbon/human/snob = make_human()
	var/datum/quirk/snob/snob_quirk = give_quirk(snob, /datum/quirk/snob)
	for(var/i in 1 to 10)
		allocate(/obj/item/trash/chips, run_loc_floor_bottom_left)
	snob_quirk.ticks_left = 0
	snob_quirk.on_process(1)
	TEST_ASSERT(istype(mood_event(snob, "area_beauty"), /datum/mood_event/horridroom), "A pile of trash did not bother the snob")

	// Niechęć do dotyku: stojąc unika przytulenia, a gdy nie może (leży), przytulas drażni zamiast cieszyć
	var/mob/living/carbon/human/untouchable = make_human()
	give_quirk(untouchable, /datum/quirk/bad_touch)
	var/mob/living/carbon/human/hugger = make_human()
	hugger.zone_selected = BODY_ZONE_CHEST
	untouchable.help_shake_act(hugger)
	TEST_ASSERT(!mood_event(untouchable, "hug"), "Someone who hates touch did not dodge a hug")
	TEST_ASSERT(!mood_event(untouchable, "bad_touch"), "A dodged hug still upset someone who hates touch")
	untouchable.Paralyze(10 SECONDS)
	untouchable.help_shake_act(hugger)
	TEST_ASSERT(mood_event(untouchable, "bad_touch"), "A touch that could not be dodged did not upset someone who hates touch")
	TEST_ASSERT(!mood_event(untouchable, "hug"), "Someone who hates touch enjoyed a hug")
	untouchable.SetParalyzed(0)
	untouchable.remove_quirk(/datum/quirk/bad_touch)
	untouchable.help_shake_act(hugger)
	TEST_ASSERT(mood_event(untouchable, "hug"), "A hug without the touch aversion did not land")

	// Nerwowy: atak paniki
	var/mob/living/carbon/human/nervous = make_human()
	var/datum/quirk/nervous/nervous_quirk = give_quirk(nervous, /datum/quirk/nervous)
	nervous_quirk.freak_out()
	TEST_ASSERT(mood_event(nervous, "nervous"), "Freaking out did not upset the nervous one")
	TEST_ASSERT(nervous.IsStun(), "Freaking out did not stun the nervous one")

	// Afekt pseudobulbarny: karta niepełnosprawności
	var/mob/living/carbon/human/joker = make_human()
	var/datum/quirk/joker/joker_quirk = give_quirk(joker, /datum/quirk/joker)
	joker_quirk.on_spawn()
	TEST_ASSERT(joker.is_holding_item_of_type(/obj/item/paper/joker), "Pseudobulbar affect gave no card")

	// Introwertyk nie cieszy się barem
	var/mob/living/carbon/human/introvert = make_human()
	give_quirk(introvert, /datum/quirk/introvert)
	var/area/crew_quarters/bar/bar_area = GLOB.areas_by_type[/area/crew_quarters/bar]
	if(bar_area)
		TEST_ASSERT(!bar_area.mood_check(introvert), "The bar still cheers up an introvert")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL

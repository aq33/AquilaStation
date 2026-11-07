// Kopie makr z code/modules/unit_tests/_unit_tests.dm (tam są #undef na końcu)
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - strzał z broni palnej zostawia dym (zanieczyszczenie) na kafelku strzelca, broń na piankę nie
/datum/unit_test/aquila_gun_smoke_pollution

/datum/unit_test/aquila_gun_smoke_pollution/Run()
	var/turf/open/shooter_turf = run_loc_floor_bottom_left
	var/turf/open/toy_turf = locate(shooter_turf.x + 2, shooter_turf.y, shooter_turf.z)
	TEST_ASSERT(isopenturf(toy_turf), "No open turf 2 tiles east of the test room corner")
	QDEL_NULL(shooter_turf.pollution)
	QDEL_NULL(toy_turf.pollution)

	var/mob/living/carbon/human/shooter = allocate(/mob/living/carbon/human, shooter_turf)
	var/obj/item/gun/ballistic/automatic/pistol/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	shooter.put_in_hands(gun)
	var/turf/target = locate(shooter_turf.x, shooter_turf.y + 2, shooter_turf.z)
	gun.process_fire(target, shooter, FALSE)
	TEST_ASSERT(shooter_turf.pollution?.pollutants[/datum/pollutant/smoke] >= gun.gun_smoke_pollution, "Pistol shot left no gun smoke on the shooter's tile")

	var/mob/living/carbon/human/toy_shooter = allocate(/mob/living/carbon/human, toy_turf)
	var/obj/item/gun/ballistic/automatic/toy/pistol/toy = allocate(/obj/item/gun/ballistic/automatic/toy/pistol)
	toy_shooter.put_in_hands(toy)
	toy.process_fire(target, toy_shooter, FALSE)
	TEST_ASSERT(!toy_turf.pollution?.pollutants[/datum/pollutant/smoke], "Foam pistol left gun smoke")

	QDEL_NULL(shooter_turf.pollution)

/// AQUILA - karta ID w slocie ID rysuje się na postaci, a każda karta ze zwykłym sprite'em ma swój stan na postaci
/datum/unit_test/aquila_id_worn_overlay

/datum/unit_test/aquila_id_worn_overlay/Run()
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/clothing/under/color/grey/jumpsuit = allocate(/obj/item/clothing/under/color/grey)
	TEST_ASSERT(wearer.equip_to_slot_if_possible(jumpsuit, ITEM_SLOT_ICLOTHING), "Could not put on a jumpsuit (the ID slot needs one)")
	var/obj/item/card/id/captains_spare/card = allocate(/obj/item/card/id/captains_spare)
	TEST_ASSERT(wearer.equip_to_slot_if_possible(card, ITEM_SLOT_ID), "Could not put the ID card in the ID slot")
	var/mutable_appearance/id_overlay = wearer.overlays_standing[ID_LAYER]
	TEST_ASSERT(id_overlay, "No ID overlay on a human wearing an ID card")
	TEST_ASSERT(id_overlay.icon_state in icon_states(id_overlay.icon), "ID overlay state '[id_overlay.icon_state]' missing in [id_overlay.icon]")

	var/list/worn_states = icon_states('aquila/icons/mob/clothing/id.dmi')
	var/list/missing = list()
	for(var/obj/item/card/id/card_type as anything in typesof(/obj/item/card/id))
		if(initial(card_type.icon) != 'nsv13/icons/obj/card.dmi' || initial(card_type.worn_icon))
			continue
		var/state = initial(card_type.worn_icon_state) || initial(card_type.icon_state)
		if(!(state in worn_states))
			missing |= state
	TEST_ASSERT(!length(missing), "ID card states without a worn sprite in aquila/icons/mob/clothing/id.dmi: [jointext(missing, ", ")]")

/// AQUILA - examine człowieka w układzie tg: tytuł w zakładce ramki, ubranie, pod kreską stan, bez widocznych znaczników sekcji
/datum/unit_test/aquila_examine_layout

/datum/unit_test/aquila_examine_layout/Run()
	var/mob/living/carbon/human/viewer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/examined = allocate(/mob/living/carbon/human, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	examined.equipOutfit(/datum/outfit/job/assistant)
	examined.adjustBruteLoss(30)

	var/html = viewer.aq_examine_html(examined, examined.examine(viewer))
	TEST_ASSERT(findtext(html, "fieldset_legend"), "Human examine has no title tab: [html]")
	TEST_ASSERT(!findtext(html, "aq_examine_mark"), "Section markers leaked into the examine output")
	var/clothes_at = findtext(html, "Ma na sobie")
	var/status_at = findtext(html, ">Stan<")
	TEST_ASSERT(clothes_at, "Uniform line missing from examine")
	TEST_ASSERT(status_at > clothes_at, "Health section (with brute damage) is not under its own line after the clothing")
	TEST_ASSERT(findtext(html, "siniaki", status_at), "Brute damage line is not in the health section")

	// Przedmiot bez znaczników: tytuł w zakładce, opis w ramce
	var/obj/item/stack/sheet/iron/sheet = allocate(/obj/item/stack/sheet/iron)
	html = viewer.aq_examine_html(sheet, sheet.examine(viewer))
	TEST_ASSERT(findtext(html, "fieldset_legend"), "Item examine has no title tab: [html]")

/// AQUILA - wojna gangów: zawsze dwa gangi (jeden kandydat to za mało), limit werbunku, przejęcie dominatorem jako cel
/datum/unit_test/aquila_gang_war

/datum/unit_test/aquila_gang_war/Run()
	var/list/saved_possible = GLOB.possible_gangs.Copy()
	var/list/saved_gangs = GLOB.gangs.Copy()

	// Jeden kandydat: tryb nie startuje
	var/datum/game_mode/gang/mode = new
	var/datum/mind/lonely = new("lonely")
	mode.antag_candidates = list(lonely)
	TEST_ASSERT(!mode.pre_setup(), "Gang war started with a single boss candidate")
	qdel(mode)

	// Wielu kandydatów: dokładnie dwóch szefów
	mode = new
	var/list/candidates = list()
	for(var/i in 1 to 6)
		candidates += new /datum/mind("candidate [i]")
	mode.antag_candidates = candidates.Copy()
	TEST_ASSERT(mode.pre_setup(), "Gang war did not start with six candidates")
	TEST_ASSERT_EQUAL(length(mode.gangboss_candidates), 2, "Gang war picked a wrong number of gang bosses")
	qdel(mode)

	// Limit werbunku i cel
	var/mob/living/carbon/human/boss = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	boss.mind_initialize()
	var/datum/antagonist/gang/boss/boss_datum = boss.mind.add_antag_datum(/datum/antagonist/gang/boss)
	var/datum/team/gang/gang = boss_datum.gang
	TEST_ASSERT(gang, "Gang boss has no gang")
	TEST_ASSERT(locate(/datum/objective/gang_dominate) in boss_datum.objectives, "Gang boss has no dominator objective")
	// Limit nie spada poniżej minimum: zapełniamy gang do limitu członkami dodanymi jak przez admina
	gang.update_gang_cap()
	var/members_needed = gang.gang_cap - length(gang.living_members())
	for(var/i in 1 to members_needed)
		var/mob/living/carbon/human/member = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
		member.mind_initialize()
		member.mind.add_antag_datum(/datum/antagonist/gang, gang)
	TEST_ASSERT_EQUAL(length(gang.living_members()), gang.gang_cap, "Gang was not filled up to its cap")
	TEST_ASSERT(!gang.can_recruit(), "Full gang can still recruit")
	var/mob/living/carbon/human/recruit = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	recruit.mind_initialize()
	var/obj/item/pen/gang/pen = allocate(/obj/item/pen/gang)
	TEST_ASSERT(!pen.add_gangster(boss, gang, recruit.mind), "Recruitment pen ignored the gang cap")
	TEST_ASSERT(!recruit.mind.has_antag_datum(/datum/antagonist/gang), "Recruit joined a full gang")

	var/time = gang.determine_domination_time()
	TEST_ASSERT(time >= 180 && time <= 480, "Domination time [time] s outside 3-8 minutes")
	var/datum/objective/gang_dominate/objective = locate() in gang.objectives
	TEST_ASSERT(!objective.check_completion(), "Dominator objective complete before any takeover")
	gang.dominated = TRUE
	TEST_ASSERT(objective.check_completion(), "Dominator objective not complete after a takeover")

	boss.mind.remove_antag_datum(/datum/antagonist/gang)
	for(var/datum/team/gang/G in GLOB.gangs - saved_gangs)
		qdel(G)
	GLOB.possible_gangs = saved_possible
	GLOB.gangs = saved_gangs

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL

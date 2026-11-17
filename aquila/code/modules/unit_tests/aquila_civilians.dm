/// AQUILA - cywile i rozpoznanie (aquila/code/modules/overmap/civilians.dm): AI Nanotrasen nie bierze cywila na cel, a
/// Syndykat tak; trafienie neutralnego cywila przez okręt gracza obniża reputację (raz na przerwę), kupiec bierze drożej
/// i przy złej reputacji nie handluje; fałszywy IFF trzyma się z daleka i pada z bliska albo po strzale; nierozpoznany
/// kontakt pokazuje klasę wielkości.
/datum/unit_test/aquila_civilians
	var/list/old_standing
	var/old_fake_chance

/datum/unit_test/aquila_civilians/Run()
	old_standing = GLOB.civilian_standing.Copy()
	old_fake_chance = GLOB.civilian_fake_iff_chance
	var/fail = check_ai_targeting() || check_penalty() || check_traders() || check_fake_iff()
	if(fail)
		return Fail(fail)

/datum/unit_test/aquila_civilians/Destroy()
	if(old_standing)
		GLOB.civilian_standing = old_standing
	if(!isnull(old_fake_chance))
		GLOB.civilian_fake_iff_chance = old_fake_chance
	return ..()

/datum/unit_test/aquila_civilians/proc/check_ai_targeting()
	var/obj/structure/overmap/civ = allocate(/obj/structure/overmap/nanotrasen/mining_cruiser/aquila_hex_freighter/civilian/independent, run_loc_floor_bottom_left)
	var/obj/structure/overmap/syndicate/ai/gunboat/morale_test/hunter = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test, run_loc_floor_bottom_left)
	var/obj/structure/overmap/syndicate/ai/gunboat/morale_test/escort = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test, run_loc_floor_bottom_left)
	hunter.faction = "syndicate"
	escort.faction = "nanotrasen"
	if(civ.is_sensor_visible(escort) >= SENSOR_VISIBILITY_TARGETABLE)
		return "AI Nanotrasen może wziąć neutralnego cywila na cel"
	if(civ.is_sensor_visible(hunter) < SENSOR_VISIBILITY_TARGETABLE)
		return "AI Syndykatu nie widzi cywila tuż obok jako celu"
	if(!findtext(escort.get_contact_label(civ, FALSE), "("))
		return "Nierozpoznany kontakt nie pokazuje klasy wielkości ([escort.get_contact_label(civ, FALSE)])"

/datum/unit_test/aquila_civilians/proc/check_penalty()
	var/obj/structure/overmap/civ = allocate(/obj/structure/overmap/nanotrasen/mining_cruiser/aquila_hex_freighter/civilian/independent, run_loc_floor_bottom_left)
	var/obj/structure/overmap/syndicate/ai/gunboat/morale_test/player = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test, run_loc_floor_bottom_left)
	player.faction = "nanotrasen"
	player.ai_controlled = FALSE
	GLOB.civilian_standing["unaligned"] = 100
	var/obj/item/projectile/bullet/light_cannon_round/shot = allocate(/obj/item/projectile/bullet/light_cannon_round, run_loc_floor_bottom_left)
	shot.overmap_firer = player
	civ.bullet_act(shot)
	if(GLOB.civilian_standing["unaligned"] != 95)
		return "Trafienie neutralnego cywila nie obniżyło reputacji o 5 ([GLOB.civilian_standing["unaligned"]])"
	civ.bullet_act(shot)
	if(GLOB.civilian_standing["unaligned"] != 95)
		return "Drugie trafienie zaraz po pierwszym znowu obniżyło reputację"
	// Wrogi transportowiec się nie liczy
	civ.faction = "syndicate"
	civ.civilian_next_penalty = 0
	civ.bullet_act(shot)
	if(GLOB.civilian_standing["unaligned"] != 95)
		return "Trafienie wrogiego transportowca obniżyło reputację"

/datum/unit_test/aquila_civilians/proc/check_traders()
	var/datum/trader/shallowstone/independent/trader = new
	GLOB.civilian_standing["unaligned"] = 100
	if(trader.civilian_price_mult() != 1)
		return "Kupiec bierze drożej przy pełnej reputacji"
	GLOB.civilian_standing["unaligned"] = 0
	if(trader.civilian_price_mult() != 1.5)
		return "Przy zerowej reputacji mnożnik cen to [trader.civilian_price_mult()] zamiast 1,5"
	if(trader.refuses_trade())
		return "Kupiec odmawia handlu przy reputacji 0"
	GLOB.civilian_standing["unaligned"] = -1
	if(!trader.refuses_trade())
		return "Kupiec handluje przy ujemnej reputacji"
	qdel(trader)

/datum/unit_test/aquila_civilians/proc/check_fake_iff()
	GLOB.civilian_fake_iff_chance = 100
	var/obj/structure/overmap/syndicate/ai/gunboat/morale_test/raider = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test, run_loc_floor_bottom_left)
	GLOB.civilian_fake_iff_chance = 0
	if(!raider.fake_iff_name)
		return "Wrogi okręt nie dostał fałszywego IFF przy szansie 100%"
	var/obj/structure/overmap/syndicate/ai/gunboat/morale_test/player = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test, locate(run_loc_floor_bottom_left.x + 12, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	player.faction = "nanotrasen"
	player.ai_controlled = FALSE
	var/fake = raider.fake_iff_name
	if(player.get_contact_label(raider, TRUE) != fake)
		return "Z daleka rozpoznany wróg z fałszywym IFF nie nadaje cywilnej nazwy"
	// okręty overmapy nie przechodzą przez forceMove w pokoju testowym: drugi okręt gracza od razu obok
	var/obj/structure/overmap/syndicate/ai/gunboat/morale_test/near = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test, run_loc_floor_bottom_left)
	near.faction = "nanotrasen"
	near.ai_controlled = FALSE
	if(near.get_contact_label(raider, TRUE) != raider.name || raider.fake_iff_name)
		return "Z bliska fałszywy IFF nie został zdemaskowany (odległość [overmap_dist(near, raider)])"
	// strzał też demaskuje
	raider.fake_iff_name = fake
	raider.fire_projectile(/obj/item/projectile/bullet/light_cannon_round, player)
	if(raider.fake_iff_name)
		return "Strzał nie zdemaskował fałszywego IFF"

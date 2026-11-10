// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Boarder do testów: bez skalowania trudnością overmapy, AI zatrzymane, sterujemy nim ręcznie
/mob/living/carbon/human/ai_boarder/aquila_test
	difficulty_override = TRUE
	knpc_traits = NONE
	outfit = list(/datum/outfit/job/assistant)

/mob/living/carbon/human/ai_boarder/aquila_test/Initialize(mapload)
	. = ..()
	STOP_PROCESSING(SSfastprocess, GetComponent(/datum/component/knpc))

/// AQUILA - boarder woli strzelającego do niego wroga od bliższego, który nic nie robi
/datum/unit_test/aquila_knpc_target_prefers_shooter

/datum/unit_test/aquila_knpc_target_prefers_shooter/Run()
	var/turf/base = run_loc_floor_bottom_left
	var/mob/living/carbon/human/ai_boarder/aquila_test/boarder = allocate(/mob/living/carbon/human/ai_boarder/aquila_test, locate(base.x + 1, base.y + 1, base.z))
	var/mob/living/carbon/human/idle = allocate(/mob/living/carbon/human, locate(base.x + 3, base.y + 1, base.z))
	var/mob/living/carbon/human/shooter = allocate(/mob/living/carbon/human, locate(base.x + 5, base.y + 1, base.z))
	var/datum/component/knpc/ai = boarder.GetComponent(/datum/component/knpc)
	TEST_ASSERT(ai, "Boarder has no knpc component")
	TEST_ASSERT_EQUAL(ai.pick_target(list(idle, shooter)), idle, "Without other information the closest enemy should be picked")
	ai.current_target = null
	LAZYSET(ai.recent_shooters, WEAKREF(shooter), world.time + 10 SECONDS)
	TEST_ASSERT_EQUAL(ai.pick_target(list(idle, shooter)), shooter, "An enemy that just shot the boarder should be picked over a closer idle one")

/// AQUILA - boarder z bronią palną odsuwa się od wroga, który podszedł za blisko, zamiast iść na niego
/datum/unit_test/aquila_knpc_keeps_distance

/datum/unit_test/aquila_knpc_keeps_distance/Run()
	var/turf/base = run_loc_floor_bottom_left
	var/mob/living/carbon/human/ai_boarder/aquila_test/boarder = allocate(/mob/living/carbon/human/ai_boarder/aquila_test, locate(base.x + 3, base.y + 1, base.z))
	var/mob/living/carbon/human/enemy = allocate(/mob/living/carbon/human, locate(base.x + 1, base.y + 1, base.z))
	var/obj/item/gun/ballistic/automatic/pistol/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	boarder.put_in_active_hand(gun)
	TEST_ASSERT(gun.can_shoot(), "Test pistol cannot shoot")
	var/datum/component/knpc/ai = boarder.GetComponent(/datum/component/knpc)
	ai.next_move = 0
	ai.tactical_move(enemy)
	TEST_ASSERT_EQUAL(get_dist(boarder, enemy), 3, "Armed boarder 2 tiles from the enemy should step back to 3 tiles")
	TEST_ASSERT(!length(ai.path), "Armed boarder in range should not keep a path towards the enemy")
	enemy.Paralyze(20 SECONDS)
	ai.next_move = 0
	ai.tactical_move(enemy)
	TEST_ASSERT_EQUAL(ai.dest, get_turf(enemy), "Armed boarder does not walk up to an incapacitated enemy (ID theft, cuffing)")

/// AQUILA - przy krytycznym zdrowiu medipen wygrywa z walką, przy lekkich ranach nie
/datum/unit_test/aquila_knpc_heals_in_combat

/datum/unit_test/aquila_knpc_heals_in_combat/Run()
	var/mob/living/carbon/human/ai_boarder/aquila_test/boarder = allocate(/mob/living/carbon/human/ai_boarder/aquila_test, run_loc_floor_bottom_left)
	var/obj/item/reagent_containers/hypospray/medipen/survival/pen = allocate(/obj/item/reagent_containers/hypospray/medipen/survival)
	boarder.put_in_inactive_hand(pen)
	var/datum/component/knpc/ai = boarder.GetComponent(/datum/component/knpc)
	var/datum/ai_goal/human/heal_self/heal = locate() in ai.ai_goals
	var/datum/ai_goal/human/engage_targets/engage = locate() in ai.ai_goals
	TEST_ASSERT(heal && engage, "Missing heal_self or engage_targets goal")
	boarder.adjustBruteLoss(boarder.maxHealth * 0.4)
	TEST_ASSERT(heal.check_score(ai) < engage.score, "Lightly wounded boarder should keep fighting instead of healing")
	// Obrażenia rozkładają się na kończyny z limitem, więc dobijamy do progu toksynami
	boarder.adjustToxLoss(boarder.health - boarder.maxHealth * 0.3, forced = TRUE)
	TEST_ASSERT(boarder.health <= boarder.maxHealth * 0.35, "Could not wound the test boarder enough (health [boarder.health])")
	TEST_ASSERT(heal.check_score(ai) > engage.score, "Badly wounded boarder with a medipen should heal even in combat (health [boarder.health], score [heal.check_score(ai)])")

/// AQUILA - boarder wyważający drzwi przebija się przez śluzę bez dostępu, hakujący otwiera ją panelem
/datum/unit_test/aquila_knpc_door_breach

/datum/unit_test/aquila_knpc_door_breach/Run()
	var/turf/base = run_loc_floor_bottom_left
	var/turf/door_turf = locate(base.x + 2, base.y + 1, base.z)
	var/mob/living/carbon/human/ai_boarder/aquila_test/boarder = allocate(/mob/living/carbon/human/ai_boarder/aquila_test, locate(base.x + 1, base.y + 1, base.z))
	var/datum/component/knpc/ai = boarder.GetComponent(/datum/component/knpc)
	var/obj/machinery/door/airlock/door = allocate(/obj/machinery/door/airlock, door_turf)
	door.req_access = list(ACCESS_CAPTAIN)
	TEST_ASSERT(!door.allowed(boarder), "Test boarder should not have access to the test airlock")
	TEST_ASSERT_EQUAL(ai.path_access_card(), boarder.wear_id, "A boarder without breach traits should plan paths with its own ID")

	boarder.knpc_traits = KNPC_IS_DOOR_BASHER
	var/obj/item/card/id/breach_card = ai.path_access_card()
	TEST_ASSERT(breach_card && (ACCESS_CAPTAIN in breach_card.access), "A door basher should plan paths through any station door")
	for(var/i in 1 to 30)
		if(!door.density)
			break
		ai.path = list(door_turf)
		ai.next_door_action = 0
		TEST_ASSERT(ai.handle_blocking_door(), "Door basher did not act on an airlock it has no access to")
	TEST_ASSERT(!door.density, "Door basher failed to force the airlock open in 30 hits")

	door.close()
	door.obj_integrity = door.max_integrity
	ai.path = list(door_turf)
	ai.next_door_action = world.time + 10 SECONDS
	ai.tries = 0
	ai.next_move = 0
	TEST_ASSERT(ai.handle_blocking_door(), "Door basher between hits should keep waiting at the door")
	TEST_ASSERT(ai.next_path_step() == FALSE && ai.tries == 0, "Door basher between hits walked into the door (tries [ai.tries])")
	door.open(2)

	door.close()
	door.obj_integrity = door.max_integrity
	TEST_ASSERT(door.density, "Test airlock did not close again")
	boarder.knpc_traits = KNPC_IS_DOOR_HACKER
	ai.path = list(door_turf)
	ai.next_door_action = 0
	TEST_ASSERT(ai.handle_blocking_door(), "Door hacker did not act on an airlock it has no access to")
	TEST_ASSERT(ai.hacking_door, "Door hacker did not start hacking")
	ai.path = list() // walka albo odwrót skasowały trasę przez drzwi
	TEST_ASSERT(!ai.handle_blocking_door(), "Door hacker without a path through the door still stands at it")
	TEST_ASSERT(!ai.hacking_door, "Hacking was not cancelled when the path changed")
	ai.finish_door_hack(WEAKREF(door))
	TEST_ASSERT(door.density, "A cancelled hack still opened the airlock")

	ai.path = list(door_turf)
	ai.next_door_action = 0
	TEST_ASSERT(ai.handle_blocking_door() && ai.hacking_door, "Door hacker did not restart hacking")
	ai.finish_door_hack(WEAKREF(door))
	TEST_ASSERT(!ai.hacking_door, "Hacking flag stayed set after the hack finished")
	TEST_ASSERT(!door.density, "Door hacker failed to open the airlock")

/// AQUILA - boarder nie rzuca odłamkowego, gdy sam jest w zasięgu wybuchu, a hukowy tylko z ochroną oczu i uszu
/datum/unit_test/aquila_knpc_grenade_safety

/datum/unit_test/aquila_knpc_grenade_safety/Run()
	var/turf/base = run_loc_floor_bottom_left
	var/mob/living/carbon/human/ai_boarder/aquila_test/boarder = allocate(/mob/living/carbon/human/ai_boarder/aquila_test, locate(base.x + 1, base.y + 1, base.z))
	var/mob/living/carbon/human/enemy = allocate(/mob/living/carbon/human, locate(base.x + 5, base.y + 1, base.z))
	var/mob/living/carbon/human/enemy_two = allocate(/mob/living/carbon/human, locate(base.x + 5, base.y + 2, base.z))
	var/datum/component/knpc/ai = boarder.GetComponent(/datum/component/knpc)
	TEST_ASSERT(!boarder.faction_check_mob(enemy), "Test enemy is in the boarder's faction")
	var/obj/item/grenade/frag/frag = allocate(/obj/item/grenade/frag)
	boarder.put_in_active_hand(frag)
	var/list/enemies = list(enemy, enemy_two)
	TEST_ASSERT(!ai.try_throw_grenade(enemy, enemies), "Boarder threw a frag grenade 4 tiles away while standing in its blast radius")
	TEST_ASSERT(!frag.active, "Frag grenade got primed although it was not thrown")

	var/obj/item/grenade/flashbang/flash = allocate(/obj/item/grenade/flashbang)
	boarder.put_in_inactive_hand(flash)
	ai.next_grenade = 0
	TEST_ASSERT(!ai.try_throw_grenade(enemy, enemies), "Boarder without eye and ear protection threw a flashbang at itself")

	boarder.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/advanced(boarder), ITEM_SLOT_EYES)
	var/obj/item/old_ears = boarder.ears
	if(old_ears)
		qdel(old_ears)
	boarder.equip_to_slot_or_del(new /obj/item/radio/headset/syndicate/alt(boarder), ITEM_SLOT_EARS)
	TEST_ASSERT(boarder.get_eye_protection() >= 1 && boarder.get_ear_protection() >= 1, "Test boarder is still unprotected (eyes [boarder.get_eye_protection()], ears [boarder.get_ear_protection()], species [boarder.dna?.species?.type], glasses [boarder.glasses?.type], eye organ [boarder.getorganslot(ORGAN_SLOT_EYES)?.type])")
	var/obj/structure/barricade/wooden/blocker = allocate(/obj/structure/barricade/wooden, locate(base.x + 3, base.y + 1, base.z))
	ai.next_grenade = 0
	TEST_ASSERT(!ai.try_throw_grenade(enemy, enemies), "Boarder threw a grenade into a barricade standing on its path")
	qdel(blocker)
	ai.next_grenade = 0
	TEST_ASSERT(ai.try_throw_grenade(enemy, enemies), "Protected boarder did not throw a flashbang at a group of enemies")
	TEST_ASSERT(flash.active && !boarder.is_holding(flash), "The thrown grenade should be the primed flashbang")
	TEST_ASSERT(!frag.active && boarder.is_holding(frag), "The frag grenade should stay unthrown in hand")
	qdel(flash) // nie wybucha w kolejnych testach

/// AQUILA - strzelec idzie za murek między nim a wrogiem i zostaje tam, zamiast cofać się na otwartym polu
/datum/unit_test/aquila_knpc_takes_cover

/datum/unit_test/aquila_knpc_takes_cover/Run()
	var/turf/base = run_loc_floor_bottom_left
	var/turf/cover_spot = locate(base.x + 2, base.y + 1, base.z)
	var/mob/living/carbon/human/ai_boarder/aquila_test/boarder = allocate(/mob/living/carbon/human/ai_boarder/aquila_test, locate(base.x + 1, base.y + 1, base.z))
	var/mob/living/carbon/human/enemy = allocate(/mob/living/carbon/human, locate(base.x + 5, base.y + 1, base.z))
	allocate(/obj/structure/barricade, locate(base.x + 3, base.y + 1, base.z))
	var/obj/item/gun/ballistic/automatic/pistol/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	boarder.put_in_active_hand(gun)
	var/datum/component/knpc/ai = boarder.GetComponent(/datum/component/knpc)
	TEST_ASSERT(ai.turf_gives_cover(cover_spot, enemy), "The tile behind the barricade does not count as cover")
	TEST_ASSERT(!ai.turf_gives_cover(get_turf(boarder), enemy), "An open tile counts as cover")
	ai.next_move = 0
	ai.tactical_move(enemy)
	TEST_ASSERT_EQUAL(ai.cover_turf, cover_spot, "Armed boarder did not pick the tile behind the barricade as cover")
	TEST_ASSERT_EQUAL(ai.dest, cover_spot, "Armed boarder is not heading to its cover")
	boarder.forceMove(cover_spot)
	ai.tactical_move(enemy)
	TEST_ASSERT_EQUAL(get_turf(boarder), cover_spot, "Boarder left its cover")
	TEST_ASSERT(!length(ai.path), "Boarder in cover should hold position")

/// AQUILA - boarder z opaską zakuwa nieprzytomnego wroga, a zakuty przestaje być celem
/datum/unit_test/aquila_knpc_cuffs_prisoner

/datum/unit_test/aquila_knpc_cuffs_prisoner/Run()
	var/turf/base = run_loc_floor_bottom_left
	var/mob/living/carbon/human/ai_boarder/aquila_test/boarder = allocate(/mob/living/carbon/human/ai_boarder/aquila_test, locate(base.x + 1, base.y + 1, base.z))
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, locate(base.x + 2, base.y + 1, base.z))
	var/obj/item/restraints/handcuffs/cable/zipties/ties = allocate(/obj/item/restraints/handcuffs/cable/zipties)
	boarder.put_in_inactive_hand(ties)
	var/datum/component/knpc/ai = boarder.GetComponent(/datum/component/knpc)
	var/datum/ai_goal/human/engage_targets/engage = locate() in ai.ai_goals
	TEST_ASSERT(victim in engage.get_aggressors(ai), "An uncuffed enemy should be a target")
	victim.SetUnconscious(20 SECONDS)
	TEST_ASSERT(ai.try_cuff(victim), "Boarder with zipties did not try to cuff an unconscious enemy")
	for(var/i in 1 to 80)
		if(victim.handcuffed)
			break
		sleep(1)
	TEST_ASSERT(victim.handcuffed, "Boarder failed to cuff the unconscious enemy")
	TEST_ASSERT(!ai.cuffing, "Cuffing flag stayed set")
	victim.SetUnconscious(0)
	TEST_ASSERT(!(victim in engage.get_aggressors(ai)), "A cuffed enemy should not be a target")

/// AQUILA - po walce boarder zabiera z martwego ciała magazyn do swojej broni
/datum/unit_test/aquila_knpc_scavenges_magazine

/datum/unit_test/aquila_knpc_scavenges_magazine/Run()
	var/turf/base = run_loc_floor_bottom_left
	var/mob/living/carbon/human/ai_boarder/aquila_test/boarder = allocate(/mob/living/carbon/human/ai_boarder/aquila_test, locate(base.x + 1, base.y + 1, base.z))
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human, locate(base.x + 2, base.y + 1, base.z))
	var/obj/item/gun/ballistic/automatic/pistol/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	boarder.put_in_active_hand(gun)
	var/obj/item/ammo_box/magazine/m10mm/mag = allocate(/obj/item/ammo_box/magazine/m10mm)
	TEST_ASSERT(body.equip_to_slot_or_del(new /obj/item/storage/backpack(body), ITEM_SLOT_BACK), "Could not give the body a backpack")
	TEST_ASSERT(SEND_SIGNAL(body.back, COMSIG_TRY_STORAGE_INSERT, mag, null, TRUE, TRUE), "Could not put the magazine in the body's backpack")
	body.death()
	var/datum/component/knpc/ai = boarder.GetComponent(/datum/component/knpc)
	var/datum/ai_goal/human/scavenge/scavenge = locate() in ai.ai_goals
	TEST_ASSERT(scavenge, "Missing scavenge goal")
	TEST_ASSERT(scavenge.check_score(ai) > 0, "Boarder does not want the magazine of its own gun from a body next to it")
	scavenge.action(ai)
	TEST_ASSERT(mag in boarder.GetAllContents(), "Boarder did not take the magazine from the body (magazine is in [mag.loc])")
	TEST_ASSERT(!(mag in body.GetAllContents()), "The magazine is still on the body")

/// AQUILA - magazyn, który ktoś żywy (tu kolega boardera) podniósł, zanim boarder doszedł, nie jest mu zabierany
/datum/unit_test/aquila_knpc_no_looting_the_living

/datum/unit_test/aquila_knpc_no_looting_the_living/Run()
	var/turf/base = run_loc_floor_bottom_left
	var/mob/living/carbon/human/ai_boarder/aquila_test/boarder = allocate(/mob/living/carbon/human/ai_boarder/aquila_test, locate(base.x + 1, base.y + 1, base.z))
	var/mob/living/carbon/human/crew = allocate(/mob/living/carbon/human, locate(base.x + 2, base.y + 1, base.z))
	var/obj/item/gun/ballistic/automatic/pistol/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	boarder.put_in_active_hand(gun)
	var/obj/item/ammo_box/magazine/m10mm/mag = allocate(/obj/item/ammo_box/magazine/m10mm, get_turf(boarder)) // pod nogami: pokój testowy jest ciemny, view() widzi tylko najbliższe pola
	var/datum/component/knpc/ai = boarder.GetComponent(/datum/component/knpc)
	var/datum/ai_goal/human/scavenge/scavenge = locate() in ai.ai_goals
	crew.faction = boarder.faction.Copy() // przy wrogu w zasięgu boarder w ogóle nie zbiera, więc żywy właściciel jest tu swój
	TEST_ASSERT(scavenge.check_score(ai) > 0, "Boarder does not want a magazine of its gun lying nearby")
	TEST_ASSERT_EQUAL(ai.loot_target?.resolve(), mag, "Boarder picked something else than the magazine")
	TEST_ASSERT(crew.put_in_hands(mag), "Crew member could not pick up the magazine")
	ai.next_loot_search = world.time + 1 MINUTES // bez ponownego szukania: sprawdzamy tylko zapamiętany cel
	TEST_ASSERT(!scavenge.check_score(ai), "Boarder still wants a magazine held by a living crew member")
	scavenge.action(ai)
	TEST_ASSERT(crew.is_holding(mag), "Boarder took the magazine from a living crew member")

/// AQUILA - nieosiągalny jeniec jest pomijany tylko przez minutę, także przez uzbrojonego boardera
/datum/unit_test/aquila_knpc_unreachable_prisoner_expires

/datum/unit_test/aquila_knpc_unreachable_prisoner_expires/Run()
	var/turf/base = run_loc_floor_bottom_left
	var/mob/living/carbon/human/ai_boarder/aquila_test/boarder = allocate(/mob/living/carbon/human/ai_boarder/aquila_test, locate(base.x + 1, base.y + 1, base.z))
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, locate(base.x + 2, base.y + 1, base.z))
	var/obj/item/gun/ballistic/automatic/pistol/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	boarder.put_in_active_hand(gun)
	victim.SetUnconscious(20 SECONDS)
	var/datum/component/knpc/ai = boarder.GetComponent(/datum/component/knpc)
	var/datum/ai_goal/human/secure_prisoner/secure = locate() in ai.ai_goals
	TEST_ASSERT_EQUAL(secure.find_prisoner(ai), victim, "Unconscious enemy next to the boarder is not picked as a prisoner")
	LAZYOR(ai.unreachable_items, WEAKREF(victim))
	ai.unreachable_items_reset_at = world.time + 1 MINUTES
	ai.expire_unreachable()
	TEST_ASSERT(!secure.find_prisoner(ai), "A prisoner marked unreachable is still picked")
	ai.unreachable_items_reset_at = world.time - 1
	ai.expire_unreachable()
	TEST_ASSERT_EQUAL(secure.find_prisoner(ai), victim, "An armed boarder never forgets an unreachable prisoner")

/// AQUILA - boarder bez kajdanek nie zdejmuje ich z rąk zakutych zwłok
/datum/unit_test/aquila_knpc_no_cuffs_from_corpse

/datum/unit_test/aquila_knpc_no_cuffs_from_corpse/Run()
	var/turf/base = run_loc_floor_bottom_left
	var/mob/living/carbon/human/ai_boarder/aquila_test/boarder = allocate(/mob/living/carbon/human/ai_boarder/aquila_test, locate(base.x + 1, base.y + 1, base.z))
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human, locate(base.x + 2, base.y + 1, base.z))
	var/obj/item/restraints/handcuffs/cuffs = allocate(/obj/item/restraints/handcuffs)
	cuffs.forceMove(body)
	body.handcuffed = cuffs
	body.update_handcuffed()
	TEST_ASSERT(body.handcuffed, "Could not cuff the test body")
	body.death()
	var/datum/component/knpc/ai = boarder.GetComponent(/datum/component/knpc)
	TEST_ASSERT(!ai.find_cuffs(), "Test boarder already has cuffs")
	TEST_ASSERT(!ai.find_loot(), "Boarder wants the handcuffs on a corpse's wrists")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL

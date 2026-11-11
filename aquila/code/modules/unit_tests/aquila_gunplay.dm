// AQUILA - rework strzelania (aquila/code/modules/gunplay): silnik pocisku tg, tryby ognia, odrzut, stan broni,
// niewypały, IFF drużyn, osłony, rykoszety, dodatki.
// Makra TEST_ASSERT są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc test ma własne kopie.
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Czeka (maks. 5 s), aż ofiara dostanie obrażenia
/datum/unit_test/proc/aq_wait_for_damage(mob/living/victim)
	for(var/i in 1 to 50)
		if(victim.getBruteLoss() + victim.getFireLoss() > 0)
			return TRUE
		sleep(1)
	return FALSE

/// Silnik pocisku: kula leci z prędkością z `speed` (ds na kratkę) i nadrabia lag; trafienie zostawia ślad i usuwa kulę w następnym ticku
/datum/unit_test/aquila_gunplay_projectile_engine

/datum/unit_test/aquila_gunplay_projectile_engine/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/far = locate(start.x, start.y + 3, start.z)
	TEST_ASSERT(isopenturf(far), "No open turf 3 tiles north of the test room corner")

	// Lag: pocisk o prędkości 1 ds/kratkę, który „przespał” 2 ds, w jednym process() przelatuje 2 kratki
	var/obj/item/projectile/bullet/c9mm/lagged = allocate(/obj/item/projectile/bullet/c9mm, start)
	lagged.speed = 1
	lagged.range = 50
	lagged.firer = null
	lagged.fire(0) // na północ
	TEST_ASSERT(lagged.movement_vector, "Fired projectile has no movement vector")
	var/turf/after_fire = get_turf(lagged)
	lagged.last_projectile_move = world.time - 2
	lagged.overrun = 0
	lagged.process()
	var/turf/after_lag = get_turf(lagged)
	// Przy przeciążonym ticku (TICK_CHECK) silnik odkłada resztę drogi na następny tick jako dług (overrun), więc liczymy go razem
	var/moved_tiles = after_lag ? after_lag.y - after_fire.y : 0
	var/owed_tiles = round(lagged.overrun / world.icon_size)
	TEST_ASSERT(moved_tiles + owed_tiles == 2, "Projectile delayed by 2 ds moved [moved_tiles] tiles (+[owed_tiles] owed) instead of 2")
	qdel(lagged)

	// set_pixel_speed() z overmapu NSV13 to mnożnik prędkości
	var/obj/item/projectile/bullet/c9mm/overmap_like = allocate(/obj/item/projectile/bullet/c9mm, start)
	overmap_like.set_pixel_speed(4)
	TEST_ASSERT_EQUAL(overmap_like.pixel_speed_multiplier, 2, "set_pixel_speed(4) should double the speed like the old 2 px engine")
	qdel(overmap_like)

	// Trafienie: kula z pistoletu trafia cel 3 kratki dalej
	var/mob/living/carbon/human/shooter = allocate(/mob/living/carbon/human, start)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, far)
	var/obj/item/gun/ballistic/automatic/pistol/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	shooter.put_in_hands(gun)
	gun.spread = 0
	gun.set_firemode(AQ_FIREMODE_SEMI)
	gun.chambered.misfire_chance = 0 // fabryczne 0,3% niewypału robiło losowo czerwone CI
	gun.process_fire(victim, shooter, FALSE)
	TEST_ASSERT(aq_wait_for_damage(victim), "Pistol shot did not hit the target 3 tiles away with the tg projectile engine")

/// Hitscan na silniku tg: wiązka trafia od razu i zostawia smugę
/datum/unit_test/aquila_gunplay_hitscan

/datum/unit_test/aquila_gunplay_hitscan/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/far = locate(start.x, start.y + 3, start.z)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, far)
	var/obj/item/projectile/beam/laser/beam = allocate(/obj/item/projectile/beam/laser, start)
	TEST_ASSERT(beam.hitscan, "Our laser beam should be hitscan (aquila beams.dm)")
	beam.original = victim
	beam.fire(0)
	// Zwykle trafia od razu; przy przeciążonym ticku (TICK_CHECK) hitscan kończy lot w następnym ticku, jak w tg
	TEST_ASSERT(aq_wait_for_damage(victim), "Hitscan beam did not hit the target 3 tiles north")

/// Tryby ognia, bezpiecznik i przypadkowy wystrzał
/datum/unit_test/aquila_gunplay_firemodes

/datum/unit_test/aquila_gunplay_firemodes/Run()
	var/obj/item/gun/ballistic/automatic/c20r/unrestricted/smg = allocate(/obj/item/gun/ballistic/automatic/c20r/unrestricted)
	TEST_ASSERT_EQUAL(smg.aq_firemode, AQ_FIREMODE_SAFE, "New gun should start on safety")
	TEST_ASSERT((AQ_FIREMODE_BURST in smg.aq_firemodes) && (AQ_FIREMODE_AUTO in smg.aq_firemodes), "C-20r should offer burst and full auto")
	smg.set_firemode(AQ_FIREMODE_BURST)
	TEST_ASSERT(smg.burst_size > 1, "Burst mode did not restore burst_size")
	smg.set_firemode(AQ_FIREMODE_SEMI)
	TEST_ASSERT_EQUAL(smg.burst_size, 1, "Single fire left burst_size above 1")
	smg.cycle_firemode()
	TEST_ASSERT_EQUAL(smg.aq_firemode, AQ_FIREMODE_BURST, "Cycling from single fire should go to burst")

	// Osobny klawisz bezpiecznika: zabezpiecza i wraca do ostatniego trybu
	smg.set_firemode(AQ_FIREMODE_AUTO)
	smg.toggle_safety()
	TEST_ASSERT_EQUAL(smg.aq_firemode, AQ_FIREMODE_SAFE, "Safety toggle did not put the gun on safety")
	smg.toggle_safety()
	TEST_ASSERT_EQUAL(smg.aq_firemode, AQ_FIREMODE_AUTO, "Safety toggle did not return to the last fire mode")

	// Bez gracza (NPC) bezpiecznik nie blokuje, z klientem by blokował; na bezpieczniku broń zostawia swoją serię (NPC strzelają seriami)
	var/mob/living/carbon/human/npc = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	smg.set_firemode(AQ_FIREMODE_SAFE)
	TEST_ASSERT(!smg.safety_blocks(npc), "Safety should not block NPCs without a client")
	TEST_ASSERT_EQUAL(smg.burst_size, initial(smg.burst_size), "Safety reset the gun's burst size, NPCs would lose burst fire")

	// Przycisk trybu M-90 idzie przez wybierak (własne burst_select() M-90 nie woła ..())
	var/obj/item/gun/ballistic/automatic/m90/m90 = allocate(/obj/item/gun/ballistic/automatic/m90)
	m90.burst_select()
	TEST_ASSERT(m90.aq_firemode != AQ_FIREMODE_SAFE, "M-90 fire-mode button did not change the fire selector")

	// Przypadkowy wystrzał odbezpieczonej broni zużywa nabój
	smg.set_firemode(AQ_FIREMODE_SEMI)
	var/obj/item/projectile/chambered_bullet = smg.chambered?.BB
	TEST_ASSERT(chambered_bullet, "C-20r has no chambered bullet")
	smg.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(!smg.accidental_discharge(null), "Gun discharged with nobody to authorise its firing pin")
	TEST_ASSERT(smg.accidental_discharge(npc), "Unsafe gun did not discharge")
	TEST_ASSERT(chambered_bullet.fired, "Accidental discharge did not fire the chambered bullet")
	smg.set_firemode(AQ_FIREMODE_SAFE)
	TEST_ASSERT(!smg.accidental_discharge(npc), "Gun on safety discharged by accident")
	QDEL_NULL(smg.pin)
	smg.set_firemode(AQ_FIREMODE_SEMI)
	TEST_ASSERT(!smg.accidental_discharge(npc), "Gun without a firing pin discharged by accident")

/// Odrzut, zużycie i przegrzanie po strzale; zestaw konserwacji czyści broń
/datum/unit_test/aquila_gunplay_recoil_wear

/datum/unit_test/aquila_gunplay_recoil_wear/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/far = locate(start.x, start.y + 2, start.z)
	var/mob/living/carbon/human/shooter = allocate(/mob/living/carbon/human, start)
	var/obj/item/gun/ballistic/automatic/pistol/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	shooter.put_in_hands(gun)
	gun.set_firemode(AQ_FIREMODE_SEMI)
	gun.chambered.misfire_chance = 0
	gun.process_fire(far, shooter, FALSE)
	TEST_ASSERT(shooter.aq_recoil > 0, "Shot added no recoil to the shooter")
	TEST_ASSERT(gun.gun_wear > 0, "Shot added no wear to the gun")
	var/recoil_after_shot = shooter.aq_recoil
	sleep(5)
	TEST_ASSERT(shooter.aq_recoil < recoil_after_shot, "Recoil did not decay over time")

	// Stan techniczny osłabia pocisk: 0% stanu = połowa obrażeń
	gun.gun_wear = 100
	var/obj/item/projectile/test_bullet = allocate(/obj/item/projectile/bullet/c9mm, start)
	var/base_damage = test_bullet.damage
	gun.on_projectile_before_fire(gun, test_bullet, far)
	TEST_ASSERT(test_bullet.damage <= base_damage * 0.5 + 0.01, "Fully worn gun should halve projectile damage (got [test_bullet.damage] of [base_damage])")

	var/obj/item/gun_maintenance_kit/kit = allocate(/obj/item/gun_maintenance_kit)
	gun.gun_heat = 0
	var/old_uses = kit.uses
	kit.finish_cleaning(gun, shooter)
	TEST_ASSERT(gun.gun_wear < 100 && kit.uses == old_uses - 1, "Maintenance kit did not clean the gun")

	// Przegrzanie broni energetycznej blokuje strzał
	var/obj/item/gun/energy/laser/laser_gun = allocate(/obj/item/gun/energy/laser)
	laser_gun.gun_heat = laser_gun.max_heat - 1
	laser_gun.add_heat()
	TEST_ASSERT(laser_gun.overheated, "Energy gun did not overheat at max heat")
	TEST_ASSERT(!laser_gun.process_fire(far, shooter, FALSE), "Overheated gun still fired")

/// Niewypał: nabój zostaje w komorze bez pocisku, strzał nie pada
/datum/unit_test/aquila_gunplay_misfire

/datum/unit_test/aquila_gunplay_misfire/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/mob/living/carbon/human/shooter = allocate(/mob/living/carbon/human, start)
	var/obj/item/gun/ballistic/automatic/pistol/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	shooter.put_in_hands(gun)
	gun.set_firemode(AQ_FIREMODE_SEMI)
	var/obj/item/ammo_casing/casing = gun.chambered
	TEST_ASSERT(casing, "Pistol has nothing chambered")
	casing.misfire_chance = 100
	var/rounds_in_magazine = gun.get_ammo(FALSE)
	gun.before_firing(locate(start.x, start.y + 2, start.z), shooter)
	// 10% niewypałów to przewlekły wystrzał, który oddaje pocisk po pół sekundy; oba warianty zostawiają łuskę bez pocisku teraz
	TEST_ASSERT(!casing.BB, "Misfired casing still holds its projectile")
	TEST_ASSERT_EQUAL(gun.chambered, casing, "Misfired casing left the chamber")
	TEST_ASSERT_EQUAL(gun.get_ammo(FALSE), rounds_in_magazine, "Misfire should not touch the magazine (the dud stays chambered until racked)")

/// IFF drużyny: kula omija osobę ze smyczą drużyny strzelca, ale trafia ją, gdy to kliknięty cel
/datum/unit_test/aquila_gunplay_iff

/datum/unit_test/aquila_gunplay_iff/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/datum/squad/squad = GLOB.squad_manager?.squads?[1]
	TEST_ASSERT(squad, "No squads for the IFF test")
	var/mob/living/carbon/human/friend = allocate(/mob/living/carbon/human, start)
	var/mob/living/carbon/human/stranger = allocate(/mob/living/carbon/human, start)
	var/obj/item/clothing/neck/squad/lanyard = allocate(/obj/item/clothing/neck/squad, start, squad)
	lanyard.squad = squad
	friend.equip_to_slot_or_del(lanyard, ITEM_SLOT_NECK)
	TEST_ASSERT_EQUAL(friend.wear_neck, lanyard, "Could not put the squad lanyard on")

	var/obj/item/projectile/bullet/c9mm/bullet = allocate(/obj/item/projectile/bullet/c9mm, start)
	bullet.iff_squad = squad
	bullet.original = stranger
	TEST_ASSERT(!bullet.can_hit_target(friend, FALSE, TRUE), "IFF bullet would hit a squadmate wearing the lanyard")
	TEST_ASSERT(bullet.can_hit_target(stranger, TRUE, TRUE), "IFF bullet would not hit a stranger")
	bullet.original = friend
	TEST_ASSERT(bullet.can_hit_target(friend, TRUE, TRUE), "IFF bullet should hit a squadmate clicked directly")

/// Osłony: przewrócony stół zatrzymuje kulę od frontu, a sam stół obrywa
/datum/unit_test/aquila_gunplay_cover

/datum/unit_test/aquila_gunplay_cover/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/table_turf = locate(start.x, start.y + 2, start.z)
	var/turf/behind = locate(start.x, start.y + 3, start.z)
	TEST_ASSERT(isopenturf(behind), "No open turf 3 tiles north of the test room corner")
	var/obj/structure/table/table = allocate(/obj/structure/table, table_turf)
	TEST_ASSERT(table.flip_state_prefix, "Plain table should be flippable")
	table.set_flipped(TRUE, SOUTH) // osłania od południa, czyli od strzelca
	TEST_ASSERT(table.flipped && (table.flags_1 & ON_BORDER_1), "Table did not flip into a border object")
	TEST_ASSERT(findtext(table.icon_state, "tableflip"), "Flipped table has no Paradise flip sprite ([table.icon_state])")
	table.projectile_cover_pass = 0 // zawsze zatrzymuje
	var/integrity_before = table.obj_integrity
	var/mob/living/carbon/human/hider = allocate(/mob/living/carbon/human, behind)
	var/obj/item/projectile/bullet/c9mm/bullet = allocate(/obj/item/projectile/bullet/c9mm, start)
	bullet.original = hider
	bullet.aq_from_gun = TRUE // osłony liczą się tylko dla kul z broni ręcznej
	bullet.fire(0)
	for(var/i in 1 to 30)
		if(QDELETED(bullet) || bullet.deletion_queued)
			break
		sleep(1)
	TEST_ASSERT(hider.getBruteLoss() == 0, "Bullet went through a flipped table with 0% pass chance")
	TEST_ASSERT(table.obj_integrity < integrity_before, "Flipped table did not take the hit")
	table.set_flipped(FALSE)
	TEST_ASSERT(!table.flipped && !(table.flags_1 & ON_BORDER_1), "Table did not stand back up")

/// Dodatki: dwa celowniki się wykluczają (poprawiony błąd z Yoga), chwyt zmniejsza odrzut
/datum/unit_test/aquila_gunplay_attachments

/datum/unit_test/aquila_gunplay_attachments/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/gun/ballistic/automatic/pistol/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	var/base_spread = gun.aq_attachment_accuracy
	var/obj/item/attachment/scope/holo/holo = allocate(/obj/item/attachment/scope/holo)
	var/obj/item/attachment/scope/simple/simple = allocate(/obj/item/attachment/scope/simple)
	var/obj/item/attachment/grip/vertical/grip = allocate(/obj/item/attachment/grip/vertical)
	user.put_in_hands(holo)
	TEST_ASSERT(gun.try_attach(holo, user), "Could not attach a holographic sight")
	TEST_ASSERT_EQUAL(gun.aq_attachment_accuracy, base_spread + holo.accuracy, "Sight did not add accuracy")
	TEST_ASSERT(gun.spread >= 0, "Sight made the gun's base spread negative (adds inaccuracy in process_fire)")
	user.put_in_hands(grip)
	TEST_ASSERT(gun.try_attach(grip, user), "Could not attach a grip next to the sight")
	TEST_ASSERT(gun.recoil_multiplier < 1, "Grip did not reduce recoil")
	user.put_in_hands(simple)
	TEST_ASSERT(!gun.try_attach(simple, user), "Two sights on one gun (Yogstation &= slot bug)")
	holo.on_detach(gun, user)
	TEST_ASSERT_EQUAL(gun.aq_attachment_accuracy, base_spread, "Removing the sight did not restore accuracy")
	TEST_ASSERT(gun.try_attach(simple, user), "Sight slot stayed taken after removing the other sight")

/// Kule zostawiają dziury w naszych ścianach (Paradise), a rykoszet zależy od kąta: prosto w ścianę nigdy, po stycznej czasem
/datum/unit_test/aquila_gunplay_wall_hits

/datum/unit_test/aquila_gunplay_wall_hits/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/wall_spot = locate(start.x, start.y + 2, start.z)
	var/old_type = wall_spot.type
	var/turf/closed/wall/wall = wall_spot.ChangeTurf(/turf/closed/wall)
	var/dents = 0
	for(var/i in 1 to 8)
		var/obj/item/projectile/bullet/c9mm/bullet = new(start)
		bullet.aq_from_gun = TRUE
		bullet.ricochets_max = 0
		bullet.fire(0)
		for(var/j in 1 to 20)
			if(QDELETED(bullet))
				break
			sleep(1)
	dents = LAZYLEN(wall.dent_decals)
	var/head_on = 0
	var/grazing = 0
	var/obj/item/projectile/bullet/c9mm/probe = new(start)
	probe.aq_from_gun = TRUE
	probe.aq_angle_ricochet = TRUE // jak setup_fired_projectile() dla kuli z broni
	probe.forceMove(locate(start.x, start.y + 1, start.z))
	for(var/i in 1 to 40)
		probe.Angle = 0 // prosto w ścianę od południa
		if(probe.check_ricochet(wall))
			head_on++
		probe.Angle = 82 // prawie równolegle do ściany
		if(probe.check_ricochet(wall))
			grazing++
	var/grazing_angle = probe.get_grazing_angle(wall)
	qdel(probe)
	wall.ChangeTurf(old_type)
	TEST_ASSERT(dents > 0, "Eight bullets into a wall left no bullet holes")
	TEST_ASSERT_EQUAL(head_on, 0, "A bullet fired straight into the wall ricocheted")
	TEST_ASSERT(grazing > 0, "A bullet at 82 degrees (grazing angle [grazing_angle]) never ricocheted in 40 tries")

/// Ściany spoza /turf/closed/wall (nieniszczalne w komorze testowej) też dostają dziury i odbijają kule
/datum/unit_test/aquila_gunplay_indestructible_wall_hits

/datum/unit_test/aquila_gunplay_indestructible_wall_hits/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/wall_spot = locate(start.x, start.y + 2, start.z)
	var/old_type = wall_spot.type
	var/turf/closed/wall = wall_spot.ChangeTurf(/turf/closed/indestructible/riveted)
	for(var/i in 1 to 8)
		var/obj/item/projectile/bullet/c9mm/bullet = new(start)
		bullet.aq_from_gun = TRUE
		bullet.ricochets_max = 0
		bullet.fire(0)
		for(var/j in 1 to 20)
			if(QDELETED(bullet))
				break
			sleep(1)
	var/holes = LAZYLEN(wall.aq_bullet_holes)
	var/obj/item/projectile/bullet/c9mm/probe = new(start)
	probe.aq_from_gun = TRUE
	probe.aq_angle_ricochet = TRUE // jak setup_fired_projectile() dla kuli z broni
	probe.forceMove(locate(start.x, start.y + 1, start.z))
	var/flag_ok = probe.check_ricochet_flag(wall)
	var/grazing = 0
	for(var/i in 1 to 40)
		probe.Angle = 82
		if(probe.check_ricochet(wall))
			grazing++
	qdel(probe)
	wall.ChangeTurf(old_type)
	TEST_ASSERT(holes > 0, "Eight bullets into an indestructible wall left no bullet holes")
	TEST_ASSERT(flag_ok, "Indestructible wall is not hard enough for ricochets")
	TEST_ASSERT(grazing > 0, "A bullet at 82 degrees never ricocheted off an indestructible wall in 40 tries")

/// Pocisk z okrętu NSV13 przejmuje przesunięcie okrętu (do 31 px). Przesunięcie ≥17 px w stronę lotu dawało w silniku tg
/// zerową odległość do krawędzi w kółko: pocisk przeskakiwał cały rząd mapy w jednym ticku
/datum/unit_test/aquila_gunplay_projectile_offset

/datum/unit_test/aquila_gunplay_projectile_offset/Run()
	var/turf/start = run_loc_floor_top_right
	var/obj/item/projectile/bullet/shot = new(start)
	shot.pixel_x = 20
	shot.speed = 10 // wolno: fire() robi tylko pierwszy krok
	shot.fire(270) // na zachód
	TEST_ASSERT(!QDELETED(shot), "Projectile with a ship-like pixel offset vanished on fire")
	var/tiles_flown = start.x - shot.x
	TEST_ASSERT(tiles_flown >= 0 && tiles_flown <= 2, "Projectile with a 20 px offset jumped [tiles_flown] tiles on its first step")
	TEST_ASSERT(abs(shot.pixel_x) <= world.icon_size, "Projectile pixel offset ran away to [shot.pixel_x]")
	TEST_ASSERT_EQUAL(shot.y, start.y, "Projectile fired west changed row")
	qdel(shot)

/// Samobójstwo mnoży obrażenia naboju ×5 przed strzałem; zablokowany strzał (przegrzanie) nie może zostawić mnożnika
/datum/unit_test/aquila_gunplay_suicide_blocked

/datum/unit_test/aquila_gunplay_suicide_blocked/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/gun/energy/laser/laser_gun = allocate(/obj/item/gun/energy/laser)
	user.put_in_hands(laser_gun)
	laser_gun.set_firemode(AQ_FIREMODE_SEMI)
	var/obj/item/projectile/loaded = laser_gun.chambered?.BB
	TEST_ASSERT(loaded, "Laser gun has no chambered projectile")
	var/base_damage = loaded.damage
	laser_gun.overheated = TRUE
	laser_gun.handle_suicide(user, user, null, TRUE)
	TEST_ASSERT_EQUAL(loaded.damage, base_damage, "Blocked suicide shot left the x5 damage on the chambered projectile")

/// Ogień ciągły: rozłączony gracz (bez klienta nie ma puszczenia przycisku) nie strzela dalej
/datum/unit_test/aquila_gunplay_full_auto

/datum/unit_test/aquila_gunplay_full_auto/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/far = locate(start.x, start.y + 3, start.z)
	var/mob/living/carbon/human/shooter = allocate(/mob/living/carbon/human, start)
	var/obj/item/gun/ballistic/automatic/c20r/unrestricted/smg = allocate(/obj/item/gun/ballistic/automatic/c20r/unrestricted)
	shooter.put_in_hands(smg)
	smg.set_firemode(AQ_FIREMODE_AUTO)
	TEST_ASSERT(smg.autofire_component, "C-20r has no full-auto component")
	var/rounds_before = smg.get_ammo(TRUE)
	TEST_ASSERT(smg.autofire_component.start_firing(far, null, shooter), "Full auto did not start")
	smg.autofire_component.next_shot = 0
	smg.autofire_component.process()
	TEST_ASSERT(!smg.autofire_component.autofire_target, "Full auto kept firing for a shooter without a client")
	TEST_ASSERT_EQUAL(smg.get_ammo(TRUE), rounds_before, "Full auto fired for a shooter without a client")
	TEST_ASSERT(smg.get_autofire_delay() > 0, "Full auto delay is not positive")

/// Licznik amunicji: po broni energetycznej zwykła broń wraca do zwykłego tła z cyframi
/datum/unit_test/aquila_gunplay_ammo_hud

/datum/unit_test/aquila_gunplay_ammo_hud/Run()
	var/atom/movable/screen/aq_ammo_counter/hud = new
	var/obj/item/gun/energy/laser/laser_gun = allocate(/obj/item/gun/energy/laser)
	var/obj/item/gun/ballistic/automatic/pistol/pistol = allocate(/obj/item/gun/ballistic/automatic/pistol)
	laser_gun.fill_ammo_hud(hud)
	TEST_ASSERT(findtext(hud.icon_state, "eammo_counter"), "Energy gun did not show the battery counter")
	pistol.fill_ammo_hud(hud)
	TEST_ASSERT_EQUAL(hud.icon_state, "backing", "Ballistic counter kept the energy background")
	TEST_ASSERT(!hud.maptext, "Ballistic counter kept the energy percentage text")
	qdel(hud)

/// Rozrzut broni (odrzut, ruch) przesuwa śrut i naboje z variance, zamiast znikać (wcześniej pellet_cloud i fire_casing go nadpisywały)
/datum/unit_test/aquila_gunplay_pellet_spread

/datum/unit_test/aquila_gunplay_pellet_spread/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/far = locate(start.x, start.y + 3, start.z) // na północ: kąt 0
	var/mob/living/carbon/human/shooter = allocate(/mob/living/carbon/human, start)

	var/obj/item/ammo_casing/shotgun/buckshot/shell = allocate(/obj/item/ammo_casing/shotgun/buckshot, start)
	shell.misfire_chance = 0
	TEST_ASSERT(shell.fire_casing(far, shooter, null, 0, TRUE, null, 60), "Buckshot did not fire")
	var/datum/component/pellet_cloud/cloud = shell.GetComponent(/datum/component/pellet_cloud)
	TEST_ASSERT(cloud && length(cloud.pellets), "Buckshot made no pellets")
	for(var/obj/item/projectile/pellet as anything in cloud.pellets)
		TEST_ASSERT(pellet.original_angle >= 50 && pellet.original_angle <= 70, "Pellet flew at [pellet.original_angle]° instead of the gun's 60° spread ± half the shell's variance")

	var/obj/item/ammo_casing/c9mm/single = allocate(/obj/item/ammo_casing/c9mm, start)
	single.misfire_chance = 0
	single.variance = 10
	single.randomspread = TRUE
	var/obj/item/projectile/bullet = single.BB
	TEST_ASSERT(single.fire_casing(far, shooter, null, 0, TRUE, null, 60), "9 mm round did not fire")
	TEST_ASSERT(bullet.original_angle >= 54 && bullet.original_angle <= 66, "Single bullet with variance flew at [bullet.original_angle]° instead of the gun's 60° spread ± its variance")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL

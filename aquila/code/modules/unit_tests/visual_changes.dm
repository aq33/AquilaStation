// Makra asercji z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc ten test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - efekty wizualne z Monkestation: zgodność wsteczna eksplozji, limit cząsteczek, odłamki z trafień
/datum/unit_test/visual_changes
	var/old_explosion_enabled
	var/old_explosion_max
	var/old_impact_enabled
	var/old_impact_max

/datum/unit_test/visual_changes/Run()
	old_explosion_enabled = GLOB.explosion_particles_enabled
	old_explosion_max = GLOB.explosion_particles_max
	old_impact_enabled = GLOB.impact_particles_enabled
	old_impact_max = GLOB.impact_particles_max
	GLOB.explosion_particles_enabled = TRUE
	GLOB.impact_particles_enabled = TRUE
	var/turf/spot = run_loc_floor_bottom_left

	// Stare wywołanie bez promienia: dawna animacja, bez cząsteczek i bez miejsca w limicie
	var/active_before = GLOB.explosion_particles_active
	var/obj/effect/temp_visual/explosion/old_style = new(spot)
	TEST_ASSERT(!old_style.has_particles, "Explosion without a radius got particles")
	TEST_ASSERT_EQUAL(old_style.icon_state, "explosion", "Explosion without a radius lost its sprite")
	TEST_ASSERT_EQUAL(old_style.duration, 8, "Explosion without a radius changed its duration")
	TEST_ASSERT_EQUAL(GLOB.explosion_particles_active, active_before, "Explosion without a radius took a particle slot")
	qdel(old_style)
	var/obj/effect/temp_visual/explosion/fast/fast = new(spot, 3, COLOR_WHITE)
	TEST_ASSERT(!fast.has_particles, "Fast explosion got particles")
	qdel(fast)

	// Z promieniem: cząsteczki i miejsce w limicie, po usunięciu miejsce wraca
	var/obj/effect/temp_visual/explosion/boom = new(spot, 3, COLOR_WHITE, FALSE, TRUE)
	TEST_ASSERT(boom.has_particles, "Explosion with a radius got no particles")
	TEST_ASSERT(boom.smoke_wave?.particles && boom.explosion_smoke?.particles && boom.sparks?.particles, "Explosion particle holders are missing")
	TEST_ASSERT(boom.smoke_wave in boom.vis_contents, "Particle holder is not shown on the explosion")
	TEST_ASSERT_EQUAL(GLOB.explosion_particles_active, active_before + 1, "Explosion with particles did not take a slot")
	var/obj/effect/abstract/particle_holder/holder = boom.smoke_wave
	qdel(boom)
	TEST_ASSERT(QDELETED(holder), "Particle holder outlived its explosion")
	TEST_ASSERT_EQUAL(GLOB.explosion_particles_active, active_before, "Explosion did not free its slot")

	// Limit: ponad GLOB.explosion_particles_max zostaje sama stara animacja
	GLOB.explosion_particles_max = active_before + 1
	var/obj/effect/temp_visual/explosion/first = new(spot, 2, COLOR_WHITE)
	var/obj/effect/temp_visual/explosion/second = new(spot, 2, COLOR_WHITE)
	TEST_ASSERT(first.has_particles, "First explosion under the cap got no particles")
	TEST_ASSERT(!second.has_particles, "Explosion over the cap got particles")
	TEST_ASSERT_EQUAL(second.icon_state, "explosion", "Explosion over the cap lost its sprite")
	qdel(first)
	qdel(second)
	GLOB.explosion_particles_max = old_explosion_max

	// Przełącznik: SSexplosions nie dokłada wtedy żadnego efektu
	GLOB.explosion_particles_enabled = FALSE
	explosion_particles_visual(spot, 3, 1, 2, 3)
	TEST_ASSERT(!(locate(/obj/effect/temp_visual/explosion) in spot), "Disabled explosion particles still spawned a visual")
	GLOB.explosion_particles_enabled = TRUE
	explosion_particles_visual(spot, 3, 0, 0, 3)
	var/obj/effect/temp_visual/explosion/from_subsystem = locate() in spot
	TEST_ASSERT(from_subsystem?.has_particles, "Explosion visual for SSexplosions has no particles")
	qdel(from_subsystem)

	// Odłamki z trafienia: dwa nośniki na trafionym atomie, sprzątane po czasie
	var/obj/structure/table/wood/table = allocate(/obj/structure/table/wood, spot)
	var/obj/item/projectile/bullet/bullet = allocate(/obj/item/projectile/bullet, spot)
	var/impact_before = GLOB.impact_particles_active
	var/vis_before = length(table.vis_contents)
	spawn_impact_debris(table, bullet, DEBRIS_WOOD, -10, 5)
	TEST_ASSERT_EQUAL(GLOB.impact_particles_active, impact_before + 1, "Impact did not take a particle slot")
	TEST_ASSERT_EQUAL(length(table.vis_contents), vis_before + 2, "Impact did not add smoke and debris")
	var/list/impact_holders = table.vis_contents.Copy(vis_before + 1)
	remove_impact_particles(impact_holders[1], impact_holders[2])
	TEST_ASSERT_EQUAL(GLOB.impact_particles_active, impact_before, "Impact did not free its slot")
	TEST_ASSERT_EQUAL(length(table.vis_contents), vis_before, "Impact holders stayed on the table")

	// Pocisk energii: sam dymek, bez odłamków
	bullet.flag = "energy"
	spawn_impact_debris(table, bullet, DEBRIS_WOOD, -10, 5)
	TEST_ASSERT_EQUAL(length(table.vis_contents), vis_before + 1, "Energy impact made debris")
	impact_holders = table.vis_contents.Copy(vis_before + 1)
	remove_impact_particles(impact_holders[1], null)

	// Limit trafień
	GLOB.impact_particles_max = GLOB.impact_particles_active
	spawn_impact_debris(table, bullet, DEBRIS_WOOD, -10, 5)
	TEST_ASSERT_EQUAL(length(table.vis_contents), vis_before, "Impact over the cap made particles")

	// Dymek z lufy tylko w broni palnej
	var/obj/item/gun/gun_type = /obj/item/gun/energy/laser
	TEST_ASSERT(!initial(gun_type.gun_smoke_particles), "Laser gun smokes")
	gun_type = /obj/item/gun/ballistic/automatic/pistol
	TEST_ASSERT(initial(gun_type.gun_smoke_particles), "Pistol does not smoke")
	gun_type = /obj/item/gun/ballistic/automatic/toy
	TEST_ASSERT(!initial(gun_type.gun_smoke_particles), "Toy gun smokes")

/datum/unit_test/visual_changes/Destroy()
	GLOB.explosion_particles_enabled = old_explosion_enabled
	GLOB.explosion_particles_max = old_explosion_max
	GLOB.impact_particles_enabled = old_impact_enabled
	GLOB.impact_particles_max = old_impact_max
	return ..()

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL

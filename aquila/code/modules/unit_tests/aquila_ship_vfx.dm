/// AQUILA - efekty okrętów (aquila/code/modules/overmap/modules/ship_vfx.dm): rufa sprite'a jest pod środkiem, dziób nad nim,
/// emiter wyłomu znika, gdy moduł przestaje być rozszczelniony, a na overmapie skok FTL zostawia smugę i błysk, obrót włącza
/// dyszę manewrową z właściwej burty, a odpalenie torpedy dym.
/datum/unit_test/aquila_ship_vfx

/datum/unit_test/aquila_ship_vfx/Run()
	var/obj/structure/overmap/ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	var/list/stern = ship.vfx_sprite_point(-1, 0)
	var/list/bow = ship.vfx_sprite_point(1, 0)
	var/list/centre = ship.vfx_sprite_point(0, 0)
	if(!stern || !bow || !centre)
		return Fail("Brak obrysu sprite'a fregaty przeciwlotniczej")
	if(!(stern[2] < centre[2] && centre[2] < bow[2]))
		return Fail("Rufa [stern[2]], środek [centre[2]] i dziób [bow[2]] nie leżą kolejno w górę sprite'a")
	var/obj/effect/ship_vfx_emitter/emitter = ship.vfx_emitter("breach_1", /particles/ship_breach_gas, centre)
	if(!emitter || !(emitter in ship.vis_contents) || !emitter.particles)
		return Fail("Emiter wyłomu nie trafił do vis_contents okrętu albo nie ma cząsteczek")
	// BYOND nie obraca przesunięcia emitera razem z okrętem: emiter stoi w środku klatki, a rufa jest w cząsteczkach
	var/list/disp = ship.overmap_display_bounds()
	var/obj/effect/ship_vfx_emitter/trail = ship.vfx_emitter("test_stern", /particles/ship_engine_trail, stern)
	if(trail.pixel_x != disp[1] / 2 - world.icon_size / 2 || trail.pixel_y != disp[2] / 2 - world.icon_size / 2)
		return Fail("Emiter smugi stoi w ([trail.pixel_x], [trail.pixel_y]) zamiast w środku klatki okrętu")
	ship.remove_vfx("test_stern")
	ship.remove_vfx("breach_1")
	if(!QDELETED(emitter) || LAZYACCESS(ship.vfx_emitters, "breach_1"))
		return Fail("Usunięty emiter wyłomu został przy okręcie")
	var/list/overmap_levels = SSmapping.levels_by_trait(ZTRAIT_OVERMAP)
	if(!length(overmap_levels))
		return
	ship.forceMove(locate(120, 120, overmap_levels[1]))
	ship.ftl_vfx(FALSE)
	if(!(locate(/obj/effect/temp_visual/overmap_ftl_streak) in get_turf(ship)) || !(locate(/obj/effect/temp_visual/overmap_ftl_flash) in range(3, ship)))
		return Fail("Skok FTL nie zostawił smugi albo błysku")
	ship.vfx_last_angle = 0
	ship.angle = 20
	ship.update_vfx()
	var/obj/effect/ship_vfx_emitter/rcs = LAZYACCESS(ship.vfx_emitters, "rcs_l")
	if(!rcs?.particles?.spawning || LAZYACCESS(ship.vfx_emitters, "rcs_r"))
		return Fail("Obrót w prawo nie włączył dyszy manewrowej z lewej burty (i tylko jej)")
	ship.update_vfx()
	if(rcs.particles.spawning)
		return Fail("Dysza manewrowa dmucha dalej, choć okręt przestał się obracać")
	var/obj/item/projectile/torp = ship.fire_projectile(/obj/item/projectile/guided_munition/torpedo, locate(140, 120, overmap_levels[1]))
	QDEL_NULL(torp)
	if(!(locate(/obj/effect/temp_visual/overmap_launch_smoke) in range(3, ship)))
		return Fail("Odpalenie torpedy nie zostawiło dymu")

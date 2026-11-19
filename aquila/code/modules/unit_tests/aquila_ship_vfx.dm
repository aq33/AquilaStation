/// AQUILA - efekty okrętów (aquila/code/modules/overmap/modules/ship_vfx.dm): rufa sprite'a jest pod środkiem, dziób nad nim,
/// a emiter wyłomu znika, gdy moduł przestaje być rozszczelniony.
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
	ship.remove_vfx("breach_1")
	if(!QDELETED(emitter) || LAZYACCESS(ship.vfx_emitters, "breach_1"))
		return Fail("Usunięty emiter wyłomu został przy okręcie")

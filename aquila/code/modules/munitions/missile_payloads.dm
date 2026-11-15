// AQUILA - nowe ładunki pocisków (rework systemów okrętu, etap D; wzorowane na ładunkach Baystation 12:
// code/modules/overmap/projectiles/missiles/equipment/payload/emp.dm, diffuser.dm i sensor.dm).
// Głowica zostaje fizyczną częścią jak dotąd: drukuje się ją w protolacie uzbrojenia i wkłada do obudowy.
// - EMP dla rakiet (torpeda zakłócająca już jest): słabsza wersja torpedy zakłócającej, impuls po przekazaniu do wnętrza.
// - Dyfuzor tarcz (torpeda i rakieta): przed pochłonięciem trafienia drenuje część tarczy celu, sam rani słabo.
// - Sonda czujnikowa (torpeda i rakieta): nie rani; tam, gdzie spadnie albo skończy lot, zostaje boja, która przez
//   kilka minut pokazuje DRADIS-om okrętu kontakty w swoim zasięgu, z dokładnym położeniem.
// Różnice względem Baya: u nas tarcza to jedna pula integralności okrętu, więc dyfuzor drenuje procent puli,
// a nie przełącza segmentów; sonda nie potrzebuje ogniwa i nie ma ustawianego zasięgu.

/// Ile czasu boja sondy nadaje dane
#define SENSOR_PROBE_LIFETIME (3 MINUTES)
/// Zasięg boi sondy (pola overmapy)
#define SENSOR_PROBE_RANGE 12

/// Jaka część pełnej tarczy celu znika przy trafieniu (0 = pocisk nie jest dyfuzorem)
/obj/item/projectile/var/aq_shield_diffuse = 0
/// Pocisk z sondą: przy trafieniu w okręt zostawia boję
/obj/item/projectile/var/aq_sensor_probe = FALSE

/obj/structure/overmap/bullet_act(obj/item/projectile/P)
	if(P.aq_shield_diffuse && shields)
		aq_diffuse_shields(P.aq_shield_diffuse)
	// Przed ..(): tarcza pochłania trafienie i kończy bullet_act, zanim dojdzie do spec_overmap_hit()
	if(P.aq_sensor_probe)
		P.drop_sensor_probe(get_turf(src))
	return ..()

/// Drenuje tarczę okrętu (generator, PDSR albo tarcza myśliwca) o część jej pełnej integralności
/obj/structure/overmap/proc/aq_diffuse_shields(fraction)
	var/list/state
	var/datum/holder = shields
	if(istype(holder, /obj/machinery/shield_generator))
		var/obj/machinery/shield_generator/generator = holder
		state = generator.shield
	else if(istype(holder, /obj/machinery/atmospherics/components/trinary/defence_screen_reactor))
		var/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/reactor = holder
		state = reactor.shield
		reactor.shield["stability"] = max(0, reactor.shield["stability"] - round(80 * fraction))
		reactor.check_stability()
	else if(istype(holder, /datum/component/overmap_shields))
		var/datum/component/overmap_shields/fighter_shields = holder
		state = fighter_shields.shield
	if(!state)
		return FALSE
	var/drain = state["max_integrity"] * fraction
	state["integrity"] = max(0, state["integrity"] - drain)
	new /obj/effect/temp_visual/overmap_shield_hit(src, src)
	relay('nsv13/sound/effects/ship/damage/shield_hit2.ogg', "<span class='warning'>Tarcza okrętu migocze: coś rozprasza jej pole!</span>")
	return TRUE

/// Zakłócenie systemów celu jak przy torpedzie zakłócającej (projectiles_fx.dm), ze słabszymi liczbami
/proc/aq_disrupt_overmap(obj/structure/overmap/target, amount, cap, fighter_amount)
	if(target.ai_controlled)
		if(target.disruption <= cap)
			target.disruption = min(target.disruption + amount, cap)
		return
	if(istype(target, /obj/structure/overmap/small_craft))
		target.disruption += fighter_amount
		return
	target.add_sensor_profile_penalty(100, 10 SECONDS)

// ---------------------------------------------------------------- EMP (rakieta)

/obj/item/ship_weapon/parts/missile/warhead/emp
	name = "głowica rakiety zakłócającej NTM-E"
	desc = "Lekka głowica EMP do rakiety. Słabsza niż torpeda zakłócająca, ale rakieta leci szybciej i trudniej ją zestrzelić."
	icon_state = "warhead_disruption"
	color = "#9fd3ff"
	build_path = /obj/item/ship_weapon/ammunition/missile/emp

/obj/item/ship_weapon/ammunition/missile/emp
	name = "rakieta zakłócająca NTM-E 230 mm"
	desc = "Rakieta z głowicą EMP. Zakłóca systemy celu i po przebiciu wywołuje impuls elektromagnetyczny na pokładzie."
	color = "#9fd3ff"
	projectile_type = /obj/item/projectile/guided_munition/missile/emp

/obj/item/projectile/guided_munition/missile/emp
	name = "rakieta zakłócająca"
	color = "#9fd3ff"
	damage = 80

/obj/item/projectile/guided_munition/missile/emp/spec_overmap_hit(obj/structure/overmap/target)
	if(length(target.occupying_levels))
		return // Wnętrze załatwia detonate()
	aq_disrupt_overmap(target, 10, 20, 15)

/obj/item/projectile/guided_munition/missile/emp/detonate(atom/target)
	empulse(get_turf(target), 3, 8)
	explosion(target, 0, 1, 3, 2)

// ---------------------------------------------------------------- dyfuzor tarcz

/obj/item/ship_weapon/parts/missile/warhead/diffuser
	name = "głowica torpedy z dyfuzorem tarcz NTP-D"
	desc = "Jednorazowy emiter fal antyfazowych. Tuż przed uderzeniem rozprasza dużą część tarczy celu; sama torpeda rani słabo."
	icon_state = "warhead_disruption"
	color = "#7fb2ff"
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/diffuser

/obj/item/ship_weapon/ammunition/torpedo/diffuser
	name = "torpeda z dyfuzorem tarcz NTP-D 530 mm"
	desc = "Torpeda, która rozprasza połowę tarczy celu tuż przed trafieniem. Najlepiej odpalić ją przed salwą zwykłych torped."
	icon_state = "disruption"
	color = "#7fb2ff"
	projectile_type = /obj/item/projectile/guided_munition/torpedo/diffuser

/obj/item/projectile/guided_munition/torpedo/diffuser
	name = "torpeda z dyfuzorem"
	icon_state = "torpedo_disruptor"
	color = "#7fb2ff"
	damage = 60
	aq_shield_diffuse = 0.5

/obj/item/projectile/guided_munition/torpedo/diffuser/detonate(atom/target)
	explosion(target, 0, 0, 2, 3)

/obj/item/ship_weapon/parts/missile/warhead/diffuser_missile
	name = "głowica rakiety z dyfuzorem tarcz NTM-D"
	desc = "Mniejszy emiter fal antyfazowych do rakiety. Rozprasza mniej tarczy niż torpeda, ale rakieta szybciej dolatuje."
	icon_state = "warhead_highvelocity"
	color = "#7fb2ff"
	build_path = /obj/item/ship_weapon/ammunition/missile/diffuser

/obj/item/ship_weapon/ammunition/missile/diffuser
	name = "rakieta z dyfuzorem tarcz NTM-D 230 mm"
	desc = "Rakieta, która rozprasza trzecią część tarczy celu tuż przed trafieniem."
	color = "#7fb2ff"
	projectile_type = /obj/item/projectile/guided_munition/missile/diffuser

/obj/item/projectile/guided_munition/missile/diffuser
	name = "rakieta z dyfuzorem"
	color = "#7fb2ff"
	damage = 40
	aq_shield_diffuse = 0.3

/obj/item/projectile/guided_munition/missile/diffuser/detonate(atom/target)
	explosion(target, 0, 0, 1, 2)

// ---------------------------------------------------------------- sonda czujnikowa

/obj/item/ship_weapon/parts/missile/warhead/sensor_probe
	name = "głowica sondy czujnikowej NTP-S"
	desc = "Zestaw czujników z nadajnikiem. Torpeda z nią nie rani, a tam, gdzie spadnie albo skończy lot, zostawia boję, która przez kilka minut przesyła okrętowi obraz okolicy."
	icon_state = "warhead_probe"
	color = "#9cffb0"
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/sensor_probe

/obj/item/ship_weapon/ammunition/torpedo/sensor_probe
	name = "torpeda z sondą czujnikową NTP-S 530 mm"
	desc = "Nieuzbrojona torpeda, która zostawia boję czujnikową. Boja pokazuje na DRADIS-ach okrętu kontakty w swoim zasięgu, z dokładnym położeniem."
	icon_state = "probe"
	color = "#9cffb0"
	projectile_type = /obj/item/projectile/guided_munition/torpedo/sensor_probe

/obj/item/projectile/guided_munition/torpedo/sensor_probe
	name = "torpeda z sondą"
	icon_state = "probe"
	color = "#9cffb0"
	damage = 0
	projectile_relaying_allowed = FALSE
	aq_sensor_probe = TRUE

/obj/item/projectile/guided_munition/torpedo/sensor_probe/on_range()
	drop_sensor_probe(get_turf(src))
	return ..()

/obj/item/projectile/guided_munition/torpedo/sensor_probe/detonate(atom/target)
	return

/obj/item/ship_weapon/parts/missile/warhead/sensor_probe_missile
	name = "głowica rakiety z sondą czujnikową NTM-S"
	desc = "Mniejsza sonda czujnikowa do rakiety. Rakieta dolatuje dalej i szybciej niż torpeda, a boja działa tak samo."
	icon_state = "warhead_probe"
	color = "#9cffb0"
	build_path = /obj/item/ship_weapon/ammunition/missile/sensor_probe

/obj/item/ship_weapon/ammunition/missile/sensor_probe
	name = "rakieta z sondą czujnikową NTM-S 230 mm"
	desc = "Nieuzbrojona rakieta, która zostawia boję czujnikową."
	color = "#9cffb0"
	projectile_type = /obj/item/projectile/guided_munition/missile/sensor_probe

/obj/item/projectile/guided_munition/missile/sensor_probe
	name = "rakieta z sondą"
	color = "#9cffb0"
	damage = 0
	projectile_relaying_allowed = FALSE
	aq_sensor_probe = TRUE

/obj/item/projectile/guided_munition/missile/sensor_probe/on_range()
	drop_sensor_probe(get_turf(src))
	return ..()

/obj/item/projectile/guided_munition/missile/sensor_probe/detonate(atom/target)
	return

/// Zostawia boję sondy dla okrętu, który wystrzelił pocisk
/obj/item/projectile/proc/drop_sensor_probe(turf/where)
	if(!where || QDELETED(src))
		return
	var/obj/structure/overmap/owner = overmap_firer
	if(!istype(owner))
		return
	if(locate(/obj/effect/overmap_sensor_probe) in where)
		return
	new /obj/effect/overmap_sensor_probe(where, owner)

GLOBAL_LIST_EMPTY(overmap_sensor_probes)

/// Boja sondy czujnikowej na overmapie
/obj/effect/overmap_sensor_probe
	name = "boja czujnikowa"
	desc = "Mała boja z nadajnikiem, która przesyła okrętowi obraz okolicy."
	icon = 'nsv13/icons/obj/projectiles_nsv.dmi'
	icon_state = "probe"
	color = "#9cffb0"
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	var/faction
	var/datum/weakref/owner_ref
	var/range = SENSOR_PROBE_RANGE

/obj/effect/overmap_sensor_probe/Initialize(mapload, obj/structure/overmap/owner)
	. = ..()
	if(owner)
		faction = owner.faction
		owner_ref = WEAKREF(owner)
		owner.relay(null, "<span class='notice'>Boja czujnikowa nadaje. Kontakty w jej zasięgu widać na DRADIS przez [SENSOR_PROBE_LIFETIME / (1 MINUTES)] min.</span>")
	GLOB.overmap_sensor_probes += src
	QDEL_IN(src, SENSOR_PROBE_LIFETIME)

/obj/effect/overmap_sensor_probe/Destroy()
	GLOB.overmap_sensor_probes -= src
	return ..()

/// Czy boja tej frakcji widzi dany okręt
/obj/effect/overmap_sensor_probe/proc/reveals(obj/structure/overmap/target)
	return target.z == z && overmap_dist(src, target) <= range

/// Boje sond, które nadają dla tego okrętu (tej samej frakcji)
/obj/structure/overmap/proc/get_own_sensor_probes()
	. = list()
	for(var/obj/effect/overmap_sensor_probe/probe as anything in GLOB.overmap_sensor_probes)
		if(probe.faction == faction && probe.z == z)
			. += probe

/// DRADIS: boje i kontakty w ich zasięgu, z dokładnym położeniem
/obj/machinery/computer/ship/dradis/ui_data(mob/user)
	. = ..()
	var/list/data = .
	if(!linked)
		return
	var/list/probes = linked.get_own_sensor_probes()
	if(!length(probes))
		return
	var/list/blips = data["ships"]
	if(!islist(blips))
		return
	var/list/shown = list()
	for(var/list/blip as anything in blips)
		if(blip["id"])
			shown[blip["id"]] = blip
	for(var/obj/effect/overmap_sensor_probe/probe as anything in probes)
		blips[++blips.len] = list("x" = probe.x, "y" = probe.y, "colour" = "#9cffb0", "name" = "Boja czujnikowa", "opacity" = 1, "alignment" = "nanotrasen", "id" = "probe_\ref[probe]")
		for(var/obj/structure/overmap/OM as anything in GLOB.overmap_objects)
			if(OM == linked || OM.faction == linked.faction || istype(OM, /obj/structure/overmap/asteroid) || !probe.reveals(OM))
				continue
			var/id = "\ref[OM]"
			var/list/existing = shown[id]
			if(existing)
				// Kontakt już był, ale boja zna jego dokładne położenie
				existing["x"] = OM.x
				existing["y"] = OM.y
				existing -= "uncertainty"
				existing["opacity"] = 1
				continue
			var/list/blip = list("x" = OM.x, "y" = OM.y, "colour" = "#FF0000", "name" = "Kontakt z boi", "opacity" = 1, "alignment" = "unaligned", "id" = id)
			blips[++blips.len] = blip
			shown[id] = blip

// ---------------------------------------------------------------- receptury

/datum/design/emp_missile_warhead
	name = "Głowica rakiety zakłócającej"
	desc = "Lekka głowica EMP do rakiety."
	id = "emp_missile_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 500, /datum/material/copper = 1000, /datum/material/gold = 1000, /datum/material/uranium = 3000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/emp
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/diffuser_warhead
	name = "Głowica torpedy z dyfuzorem tarcz"
	desc = "Emiter fal antyfazowych do torpedy."
	id = "diffuser_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 1000, /datum/material/copper = 1500, /datum/material/gold = 1000, /datum/material/diamond = 250)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/diffuser
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/diffuser_missile_warhead
	name = "Głowica rakiety z dyfuzorem tarcz"
	desc = "Mniejszy emiter fal antyfazowych do rakiety."
	id = "diffuser_missile_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 500, /datum/material/copper = 1000, /datum/material/gold = 500, /datum/material/diamond = 100)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/diffuser_missile
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/sensor_probe_warhead
	name = "Głowica torpedy z sondą czujnikową"
	desc = "Sonda z nadajnikiem do torpedy."
	id = "sensor_probe_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 2000, /datum/material/copper = 1000, /datum/material/silver = 500, /datum/material/gold = 500)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/sensor_probe
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/sensor_probe_missile_warhead
	name = "Głowica rakiety z sondą czujnikową"
	desc = "Mniejsza sonda z nadajnikiem do rakiety."
	id = "sensor_probe_missile_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1500, /datum/material/copper = 500, /datum/material/silver = 250, /datum/material/gold = 250)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/sensor_probe_missile
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

// Sondy z amunicją kierowaną II, EMP i dyfuzory z prototypem głowicy zakłócającej
/datum/techweb_node/advanced_torpedo_components/New()
	. = ..()
	design_ids += list("sensor_probe_warhead", "sensor_probe_missile_warhead")

/datum/techweb_node/prototype_disruption_warheads/New()
	. = ..()
	design_ids += list("emp_missile_warhead", "diffuser_warhead", "diffuser_missile_warhead")

#undef SENSOR_PROBE_LIFETIME
#undef SENSOR_PROBE_RANGE

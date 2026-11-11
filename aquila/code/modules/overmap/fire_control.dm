/// AQUILA - konsola taktyczna (strzelca) z ekranem kontroli ognia, jak stanowisko rozpoznania (sensor_console.dm):
/// obraz sensorów okrętu na większy dystans, cele od operatora, pancerz celu i akcje namierz / wyceluj / przestań
/// śledzić / wywołaj. Strzelec dalej siedzi na stanowisku i strzela na overmapie (tactical.dm); to okno go uzupełnia.
/// Myśliwce i małe jednostki zostają przy starym oknie (TacticalConsole), bo nie mają ćwiartek pancerza.

/// Co ile można wywoływać okręt z konsoli taktycznej (jak z DRADIS)
#define FIRE_CONTROL_HAIL_COOLDOWN (10 SECONDS)
/// Zasięg wywołania, jak w DRADIS
#define FIRE_CONTROL_HAIL_RANGE 50
/// Zasięg dział niekierowanych na przeskalowanej overmapie (overmap_scale.dm: 50 -> 25 pól)
#define FIRE_CONTROL_GUN_RANGE 25

/obj/machinery/computer/ship/tactical
	/// AQUILA - kiedy można znowu wywołać okręt z tej konsoli
	var/next_fire_control_hail = 0

/// Czy ten okręt dostaje okno kontroli ognia (duże okręty z ćwiartkami pancerza)
/obj/machinery/computer/ship/tactical/proc/uses_fire_control()
	return linked && !istype(linked, /obj/structure/overmap/small_craft)

// Pełne nadpisanie (LEGACY_OVERRIDES.md): okno kontroli ognia zamiast TacticalConsole dla dużych okrętów
/obj/machinery/computer/ship/tactical/ui_interact(mob/user, datum/tgui/ui)
	if(!uses_fire_control())
		return ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FireControl", "Konsola taktyczna")
		ui.open()
		ui.set_autoupdate(TRUE)

/// Stan pancerza ćwiartek i kadłuba okrętu w procentach: list(dziób lewa, dziób prawa, rufa lewa, rufa prawa, kadłub)
/obj/structure/overmap/proc/get_armour_report()
	var/list/report = list()
	for(var/quadrant in list("forward_port", "forward_starboard", "aft_port", "aft_starboard"))
		var/list/armour = armour_quadrants?[quadrant]
		report += (armour && armour["max_armour"]) ? round(100 * armour["current_armour"] / armour["max_armour"]) : 0
	report += max_integrity ? round(100 * obj_integrity / max_integrity) : 0
	return report

/// Kontakty dla strzelca: to, co widzą sensory okrętu (ze stanowiskiem rozpoznania: kamera, teleskop, podczerwień,
/// radar), bez limitu dwóch zasięgów DRADIS. Pozycje niepewnych kontaktów jak na DRADIS i stanowisku.
/obj/structure/overmap/proc/get_fire_control_contacts(display_range)
	. = list()
	for(var/obj/structure/overmap/OM as anything in current_system?.system_contents)
		if(!istype(OM) || QDELETED(OM) || OM == src || OM.z != z || istype(OM, /obj/structure/overmap/asteroid))
			continue
		var/painted = !!LAZYFIND(target_painted, OM)
		var/friendly = OM.faction == faction
		if(!painted && !friendly && OM.is_sensor_visible(src) < SENSOR_VISIBILITY_FAINT)
			continue
		var/identified = friendly || painted || is_contact_identified(OM, display_range)
		var/dx = (OM.x + OM.offset.a) - (x + offset.a)
		var/dy = (OM.y + OM.offset.e) - (y + offset.e)
		var/uncertainty = 0
		if(!identified && GLOB.sensor_signature_enabled)
			uncertainty = get_contact_uncertainty(OM)
			var/list/error = get_sensor_offset(OM, uncertainty)
			dx = OM.x + error[1] - x
			dy = OM.y + error[2] - y
		if(abs(dx) > world.maxx / 2)
			dx -= dx > 0 ? world.maxx : -world.maxx
		if(abs(dy) > world.maxy / 2)
			dy -= dy > 0 ? world.maxy : -world.maxy
		var/list/contact = list(
			"id" = "\ref[OM]",
			"name" = get_contact_label(OM, identified),
			"number" = get_contact_number(OM),
			"dx" = round(dx, 0.01),
			"dy" = round(dy, 0.01),
			"vx" = uncertainty ? 0 : round(OM.velocity.a - velocity.a, 0.01),
			"vy" = uncertainty ? 0 : round(OM.velocity.e - velocity.e, 0.01),
			"uncertainty" = round(uncertainty, 0.5),
			"hostile" = !friendly,
			"identified" = identified,
			"locking_us" = !!(LAZYFIND(OM.target_painted, src) || (OM.ai_controlled && OM.last_target == src)),
			"painted" = painted,
			"locked" = target_lock == OM,
			"designation" = LAZYACCESS(designated_targets, OM),
			"targetable" = painted || OM.is_sensor_visible(src) >= SENSOR_VISIBILITY_TARGETABLE,
		)
		if(painted)
			contact["armour"] = OM.get_armour_report()
		. += list(contact)

/obj/machinery/computer/ship/tactical/ui_data(mob/user)
	. = ..()
	var/list/data = .
	if(!uses_fire_control())
		return
	linked.prune_designations()
	var/range = linked.sensor_console ? linked.sensor_console.base_sensor_range : SENSOR_RANGE_DEFAULT
	data["fire_control"] = TRUE
	data["own_armour"] = linked.get_armour_report()
	data["heading"] = round(linked.angle)
	data["turn"] = round(linked.angular_velocity, 0.1)
	data["contacts"] = linked.get_fire_control_contacts(range)
	data["objects"] = linked.get_scope_objects(range)
	data["gun_range"] = FIRE_CONTROL_GUN_RANGE
	data["hail_range"] = FIRE_CONTROL_HAIL_RANGE
	data["gunner"] = !!linked.gunner

/obj/machinery/computer/ship/tactical/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(. || !linked || !(action in list("fc_lockon", "fc_fire_target", "fc_dump", "fc_hail")))
		return
	var/obj/structure/overmap/target = locate(params["id"])
	if(!istype(target) || QDELETED(target) || target == linked || target.z != linked.z)
		return TRUE
	switch(action)
		if("fc_lockon")
			if(!LAZYFIND(linked.target_painted, target))
				linked.start_lockon(target)
		if("fc_fire_target")
			if(LAZYFIND(linked.target_painted, target))
				linked.select_target(target)
		if("fc_dump")
			if(LAZYFIND(linked.target_painted, target))
				linked.dump_lock(target)
		if("fc_hail")
			if(world.time < next_fire_control_hail || overmap_dist(target, linked) > FIRE_CONTROL_HAIL_RANGE)
				return TRUE
			next_fire_control_hail = world.time + FIRE_CONTROL_HAIL_COOLDOWN
			target.try_hail(usr, linked)
	return TRUE

#undef FIRE_CONTROL_HAIL_COOLDOWN
#undef FIRE_CONTROL_HAIL_RANGE
#undef FIRE_CONTROL_GUN_RANGE

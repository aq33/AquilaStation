// AQUILA - kuźnia amunicji: komponent niesiony przez wyrób, a przy strzale przez pocisk.
// Na przedmiocie (nabój, pocisk działowy, głowica, torpeda) zmienia nazwę, kolor i examine.
// Na pocisku (/obj/item/projectile) od razu przelicza statystyki i obsługuje efekty trafienia.

#define MUNITION_QUALITY_FILTER "munition_quality"

/datum/component/forged_munition
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/munition_material/material
	var/datum/munition_quality/quality
	var/datum/munition_filler/filler
	/// Pokryta w galwanizerze zwykła amunicja, a nie wyrób z kuźni
	var/galvanized = FALSE
	/// Fabryczny pocisk z cargo (AP, HE, APHE): bez klasy i bez kary klasy I
	var/factory = FALSE
	/// Cechy materiału i wypełnienia razem: typ -> /datum/munition_trait
	var/list/traits

/datum/component/forged_munition/Initialize(datum/munition_material/material, datum/munition_quality/quality, datum/munition_filler/filler, galvanized = FALSE, factory = FALSE)
	if(!isatom(parent) || !material || !quality)
		return COMPONENT_INCOMPATIBLE
	src.material = material
	src.quality = quality
	src.filler = filler
	src.galvanized = galvanized
	src.factory = factory
	traits = merge_munition_traits(list(), material.traits)
	if(filler)
		merge_munition_traits(traits, filler.traits)
	if(istype(parent, /obj/item/projectile))
		apply_to_projectile(parent)
		RegisterSignal(parent, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(on_projectile_hit))
		return
	var/atom/A = parent
	A.name = "[A.name] ([label()])"
	if(material.color_tint && !istype(A, /obj/item/ammo_box))
		A.add_atom_colour(material.color_tint, FIXED_COLOUR_PRIORITY)
	apply_quality_look(A, quality)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/forged_munition/Destroy(force, silent)
	var/atom/A = parent
	if(istype(A))
		A.remove_filter(MUNITION_QUALITY_FILTER)
	return ..()

/datum/component/forged_munition/proc/get_trait(trait_type)
	return traits[trait_type]

/// "uran, AP, klasa III"
/datum/component/forged_munition/proc/label()
	var/list/parts = list(material.name)
	if(filler)
		parts += filler.short_name
	if(!galvanized && !factory)
		parts += "klasa [quality.roman]"
	return jointext(parts, ", ")

/datum/component/forged_munition/proc/damage_mult()
	. = material.damage_mult * quality.bonus
	if(filler)
		. *= filler.damage_mult

/datum/component/forged_munition/proc/armour_pen_add()
	. = material.armour_pen_add
	if(filler)
		. += filler.armour_pen_add

/datum/component/forged_munition/proc/apply_to_projectile(obj/item/projectile/P)
	P.damage = round(P.damage * damage_mult(), 0.1)
	P.armour_penetration = P.armour_penetration + armour_pen_add()
	// Model grubości pancerza: typ pocisku zastępuje przebicie, rdzeń je przesuwa
	if(!isnull(P.aq_penetration))
		if(filler?.penetration)
			P.aq_penetration = filler.penetration
		P.aq_penetration += material.armour_pen_add
	if(P.speed > 0)
		P.speed = P.speed / material.speed_mult
	var/integrity = material.integrity_mult * quality.bonus
	if(integrity != 1 && P.max_integrity)
		P.max_integrity = round(P.max_integrity * integrity)
		P.obj_integrity = P.max_integrity

/datum/component/forged_munition/proc/on_projectile_hit(obj/item/projectile/source, atom/movable/firer, atom/target, angle)
	SIGNAL_HANDLER
	if(QDELETED(target))
		return
	// Statki obsługuje forged_munition_overmap_hit() z bullet_act; bez tego efekty odpalałyby się dwa razy
	if(istype(target, /obj/structure/overmap))
		return
	for(var/key in traits)
		var/datum/munition_trait/T = traits[key]
		T.on_hit(source, target, src)

/datum/component/forged_munition/proc/on_overmap_hit(obj/structure/overmap/target)
	for(var/key in traits)
		var/datum/munition_trait/T = traits[key]
		T.on_overmap_hit(parent, target, src)

/datum/component/forged_munition/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(factory)
		examine_list += "<span class='notice'>Fabryczny pocisk: <b>[material.name]</b>.</span>"
	else if(galvanized)
		examine_list += "<span class='notice'>Pokryto w galwanizerze: <b>[material.name]</b>.</span>"
	else
		examine_list += "<span class='notice'>Wykuto w kuźni amunicji: <b>[material.name]</b>, klasa [quality.roman] ([quality.name]).</span>"
	var/list/stats = list("obrażenia ×[round(damage_mult(), 0.01)]")
	var/pen = armour_pen_add()
	if(pen)
		stats += "przebicie [pen > 0 ? "+" : ""][pen]"
	if(material.speed_mult != 1)
		stats += "prędkość ×[material.speed_mult]"
	examine_list += "<span class='notice'>[jointext(stats, ", ")].</span>"
	if(filler)
		examine_list += "<span class='notice'>Typ pocisku: [filler.name] ([filler.short_name]). [filler.desc]</span>"
		if(filler.penetration)
			examine_list += "<span class='notice'>[aq_penetration_text(filler.penetration + material.armour_pen_add, damage_mult())]</span>"
	if(material.special_desc)
		examine_list += "<span class='notice'>[material.special_desc]</span>"
	for(var/line in trait_lines())
		examine_list += "<span class='notice'>[line]</span>"

/// "Radioaktywna: napromieniowuje trafionych." dla każdej cechy, która coś robi
/datum/component/forged_munition/proc/trait_lines()
	. = list()
	for(var/key in traits)
		var/datum/munition_trait/T = traits[key]
		. += "[capitalize(T.name)]: [T.describe()]"

/// Przenosi właściwości z amunicji, głowicy albo łuski na nowy obiekt. Woła się z punktów wpięcia w kodzie upstreamu.
/proc/transfer_forged_munition(atom/source, atom/target)
	if(!source || !target)
		return
	var/datum/component/forged_munition/F = source.GetComponent(/datum/component/forged_munition)
	if(F)
		target.AddComponent(/datum/component/forged_munition, F.material, F.quality, F.filler, F.galvanized, F.factory)
	// Projekt pocisku (missile_design.dm): przy składaniu wynika z przerobionych części w obudowie, w której leży głowica
	if(source.GetComponent(/datum/component/missile_design))
		transfer_missile_design(source, target)
	else if(istype(source.loc, /obj/item/ship_weapon/ammunition))
		apply_missile_parts_design(source.loc, target)

/// Woła się z /obj/structure/overmap/bullet_act, zanim pocisk zostanie przekazany do wnętrza statku.
/proc/forged_munition_overmap_hit(obj/item/projectile/P, obj/structure/overmap/target)
	var/datum/component/forged_munition/F = P.GetComponent(/datum/component/forged_munition)
	F?.on_overmap_hit(target)

/// Bluespace w powłoce: zanim tarcza pochłonie trafienie, czwarta część obrażeń idzie prosto w kadłub
/obj/structure/overmap/bullet_act(obj/item/projectile/P)
	var/datum/component/forged_munition/F = P.GetComponent(/datum/component/forged_munition)
	var/datum/munition_trait/shield_bypass/bypass = F?.get_trait(/datum/munition_trait/shield_bypass)
	if(bypass && aq_shields_up())
		take_damage(round(aq_hit_damage(P) * 0.25 * bypass.power), P.damage_type, aq_hit_armor_flag(P), FALSE)
	return ..()

/// Czy tarcza okrętu jest podniesiona i ma czym pochłaniać (te same rodzaje tarcz co aq_diffuse_shields)
/obj/structure/overmap/proc/aq_shields_up()
	var/list/state
	var/datum/holder = shields
	if(istype(holder, /obj/machinery/shield_generator))
		var/obj/machinery/shield_generator/generator = holder
		if(!generator.active || generator.cloaked)
			return FALSE
		state = generator.shield
	else if(istype(holder, /obj/machinery/atmospherics/components/trinary/defence_screen_reactor))
		var/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/reactor = holder
		if(!reactor.active)
			return FALSE
		state = reactor.shield
	else if(istype(holder, /datum/component/overmap_shields))
		var/datum/component/overmap_shields/fighter_shields = holder
		if(!fighter_shields.active)
			return FALSE
		state = fighter_shields.shield
	return state && state["integrity"] > 0

// ---------------------------------------------------------------- wygląd jakości


/// Klasa IV błyszczy, klasa V delikatnie świeci. Wspólne dla wyrobów i części.
/proc/apply_quality_look(atom/A, datum/munition_quality/quality)
	A.remove_filter(MUNITION_QUALITY_FILTER)
	switch(quality?.level)
		if(3)
			A.add_filter(MUNITION_QUALITY_FILTER, 2, outline_filter(1, "#ffffff40"))
		if(4)
			A.add_filter(MUNITION_QUALITY_FILTER, 2, outline_filter(1, "#ffd86680"))

#undef MUNITION_QUALITY_FILTER

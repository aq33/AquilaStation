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
	/// Cechy materiału i wypełnienia razem: typ -> /datum/munition_trait
	var/list/traits

/datum/component/forged_munition/Initialize(datum/munition_material/material, datum/munition_quality/quality, datum/munition_filler/filler, galvanized = FALSE)
	if(!isatom(parent) || !material || !quality)
		return COMPONENT_INCOMPATIBLE
	src.material = material
	src.quality = quality
	src.filler = filler
	src.galvanized = galvanized
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
	if(!galvanized)
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
	if(galvanized)
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
		examine_list += "<span class='notice'>Wypełnienie: [filler.name]. [filler.desc]</span>"
	if(material.special_desc)
		examine_list += "<span class='notice'>[material.special_desc]</span>"
	for(var/line in trait_lines())
		examine_list += "<span class='notice'>[line]</span>"

/// "Radioaktywna: napromieniowuje trafionych." dla każdej cechy, która coś robi
/datum/component/forged_munition/proc/trait_lines()
	. = list()
	for(var/key in traits)
		var/datum/munition_trait/T = traits[key]
		if(istype(T, /datum/munition_trait/emp) && filler)
			continue // opisane przy wypełnieniu
		. += "[capitalize(T.name)]: [T.describe()]"

/// Przenosi właściwości z amunicji, głowicy albo łuski na nowy obiekt. Woła się z punktów wpięcia w kodzie upstreamu.
/proc/transfer_forged_munition(atom/source, atom/target)
	if(!source || !target)
		return
	var/datum/component/forged_munition/F = source.GetComponent(/datum/component/forged_munition)
	if(F)
		target.AddComponent(/datum/component/forged_munition, F.material, F.quality, F.filler, F.galvanized)

/// Woła się z /obj/structure/overmap/bullet_act, zanim pocisk zostanie przekazany do wnętrza statku.
/proc/forged_munition_overmap_hit(obj/item/projectile/P, obj/structure/overmap/target)
	var/datum/component/forged_munition/F = P.GetComponent(/datum/component/forged_munition)
	F?.on_overmap_hit(target)

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

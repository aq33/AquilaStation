// AQUILA - kuźnia amunicji: komponent niesiony przez wyrób, a przy strzale przez pocisk.
// Na przedmiocie (nabój, pocisk działowy, głowica, torpeda) zmienia nazwę, kolor i examine.
// Na pocisku (/obj/item/projectile) od razu przelicza statystyki i obsługuje efekty trafienia.

/datum/component/forged_munition
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/munition_material/material
	var/datum/munition_quality/quality
	var/datum/munition_filler/filler

/datum/component/forged_munition/Initialize(datum/munition_material/material, datum/munition_quality/quality, datum/munition_filler/filler)
	if(!isatom(parent) || !material || !quality)
		return COMPONENT_INCOMPATIBLE
	src.material = material
	src.quality = quality
	src.filler = filler
	if(istype(parent, /obj/item/projectile))
		apply_to_projectile(parent)
		RegisterSignal(parent, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(on_projectile_hit))
		return
	var/atom/A = parent
	A.name = "[A.name] ([label()])"
	if(material.color_tint && !istype(A, /obj/item/ammo_box))
		A.add_atom_colour(material.color_tint, FIXED_COLOUR_PRIORITY)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/// "uran, AP, klasa III"
/datum/component/forged_munition/proc/label()
	var/list/parts = list(material.name)
	if(filler)
		parts += filler.short_name
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
	material.on_hit(source, target)
	filler?.on_hit(source, target, material)

/datum/component/forged_munition/proc/on_overmap_hit(obj/structure/overmap/target)
	material.on_overmap_hit(parent, target)
	filler?.on_overmap_hit(parent, target, material)

/datum/component/forged_munition/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
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

/// Przenosi właściwości z amunicji, głowicy albo łuski na nowy obiekt. Woła się z punktów wpięcia w kodzie upstreamu.
/proc/transfer_forged_munition(atom/source, atom/target)
	if(!source || !target)
		return
	var/datum/component/forged_munition/F = source.GetComponent(/datum/component/forged_munition)
	if(F)
		target.AddComponent(/datum/component/forged_munition, F.material, F.quality, F.filler)

/// Woła się z /obj/structure/overmap/bullet_act, zanim pocisk zostanie przekazany do wnętrza statku.
/proc/forged_munition_overmap_hit(obj/item/projectile/P, obj/structure/overmap/target)
	var/datum/component/forged_munition/F = P.GetComponent(/datum/component/forged_munition)
	F?.on_overmap_hit(target)

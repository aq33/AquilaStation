// AQUILA - kuźnia amunicji: klasy jakości (na wzór smithingu z Paradise) i wypełnienia.

GLOBAL_LIST_INIT(munition_qualities, init_munition_qualities())

/proc/init_munition_qualities()
	. = list()
	for(var/path in typesof(/datum/munition_quality))
		.[path] = new path

/proc/get_munition_quality(quality_type)
	return GLOB.munition_qualities[quality_type]

/// Jakość wybiera się na formie. Bonus mnoży obrażenia i wytrzymałość pocisku, przebicie i prędkość daje tylko materiał.
/datum/munition_quality
	var/name = "standardowa"
	/// Numer klasy do nazw wyrobów
	var/roman = "I"
	var/bonus = 1
	var/material_mult = 1
	/// Mnożnik cykli młota
	var/work_mult = 1

/datum/munition_quality/improved
	name = "ulepszona"
	roman = "II"
	bonus = 1.05
	material_mult = 1.5
	work_mult = 2

/datum/munition_quality/enhanced
	name = "wzmocniona"
	roman = "III"
	bonus = 1.1
	material_mult = 2
	work_mult = 3

/datum/munition_quality/superior
	name = "wyborowa"
	roman = "IV"
	bonus = 1.15
	material_mult = 3
	work_mult = 4.5

/datum/munition_quality/masterwork
	name = "mistrzowska"
	roman = "V"
	bonus = 1.2
	material_mult = 4
	work_mult = 6

GLOBAL_LIST_INIT(munition_fillers, init_munition_fillers())

/proc/init_munition_fillers()
	. = list()
	for(var/path in subtypesof(/datum/munition_filler))
		.[path] = new path

/proc/get_munition_filler(filler_type)
	return GLOB.munition_fillers[filler_type]

/datum/munition_filler
	var/name = "nic"
	/// Skrót do nazw wyrobów
	var/short_name = "?"
	var/desc
	var/damage_mult = 1
	var/armour_pen_add = 0

/datum/munition_filler/proc/on_hit(obj/item/projectile/P, atom/target, datum/munition_material/material)
	return

/datum/munition_filler/proc/on_overmap_hit(obj/item/projectile/P, obj/structure/overmap/target, datum/munition_material/material)
	return

/datum/munition_filler/he
	name = "ładunek odłamkowo-burzący"
	short_name = "HE"
	desc = "Więcej obrażeń, trochę słabsze przebicie."
	damage_mult = 1.15
	armour_pen_add = -5

/datum/munition_filler/ap
	name = "rdzeń przeciwpancerny"
	short_name = "AP"
	desc = "Dużo lepsze przebicie kosztem obrażeń."
	damage_mult = 0.9
	armour_pen_add = 20

/datum/munition_filler/incendiary
	name = "ładunek zapalający"
	short_name = "Z"
	desc = "Podpala cel i kadłub trafionego statku."
	damage_mult = 0.95

/datum/munition_filler/incendiary/on_hit(obj/item/projectile/P, atom/target, datum/munition_material/material)
	if(isliving(target))
		var/mob/living/L = target
		L.adjust_fire_stacks(2)
		L.IgniteMob()

/datum/munition_filler/incendiary/on_overmap_hit(obj/item/projectile/P, obj/structure/overmap/target, datum/munition_material/material)
	if(target.ai_controlled || istype(target, /obj/structure/overmap/small_craft))
		target.hullburn += 10
		target.hullburn_power = max(target.hullburn_power, 6)

/datum/munition_filler/emp
	name = "ładunek EMP"
	short_name = "EMP"
	desc = "Zakłóca elektronikę celu. Ze srebra i miedzi działa mocniej."
	damage_mult = 0.8

/datum/munition_filler/emp/proc/strength(datum/munition_material/material)
	if(istype(material, /datum/munition_material/silver) || istype(material, /datum/munition_material/copper))
		return 1.5
	return 1

/datum/munition_filler/emp/on_hit(obj/item/projectile/P, atom/target, datum/munition_material/material)
	target.emp_act(strength(material) > 1 ? EMP_HEAVY : EMP_LIGHT)

/datum/munition_filler/emp/on_overmap_hit(obj/item/projectile/P, obj/structure/overmap/target, datum/munition_material/material)
	var/power = round(10 * strength(material))
	if(target.ai_controlled)
		if(target.disruption <= (power * 2))
			target.disruption = min(target.disruption + power, power * 2)
		return
	if(istype(target, /obj/structure/overmap/small_craft))
		target.disruption += round(25 * strength(material))
		return
	target.add_sensor_profile_penalty(150, 10 SECONDS)

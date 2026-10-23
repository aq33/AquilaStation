// AQUILA - kuźnia amunicji: klasy jakości (na wzór smithingu z Paradise) i wypełnienia.

GLOBAL_LIST_INIT(munition_qualities, init_munition_qualities())

/proc/init_munition_qualities()
	. = list()
	for(var/path in typesof(/datum/munition_quality))
		.[path] = new path

/proc/get_munition_quality(quality_type)
	return GLOB.munition_qualities[quality_type]

/// Klasy od najniższej
/proc/munition_quality_levels()
	return typesof(/datum/munition_quality)

/// Klasa o tyle stopni niżej, nie niżej niż I
/proc/lower_munition_quality(datum/munition_quality/quality, steps)
	var/list/levels = munition_quality_levels()
	var/index = clamp(levels.Find(quality.type) - steps, 1, length(levels))
	return get_munition_quality(levels[index])

/// Docelową klasę wybiera się na formie, a ostateczną daje kucie na kowadle.
/// Bonus mnoży obrażenia i wytrzymałość pocisku, przebicie i prędkość daje tylko materiał.
/datum/munition_quality
	var/name = "standardowa"
	/// Numer klasy do nazw wyrobów
	var/roman = "I"
	/// 0 dla klasy I, 4 dla klasy V
	var/level = 0
	var/bonus = 1
	var/material_mult = 1
	/// Mnożnik długości kucia na kowadle
	var/work_mult = 1

/datum/munition_quality/improved
	name = "ulepszona"
	roman = "II"
	level = 1
	bonus = 1.05
	material_mult = 1.5
	work_mult = 2

/datum/munition_quality/enhanced
	name = "wzmocniona"
	roman = "III"
	level = 2
	bonus = 1.1
	material_mult = 2
	work_mult = 3

/datum/munition_quality/superior
	name = "wyborowa"
	roman = "IV"
	level = 3
	bonus = 1.15
	material_mult = 3
	work_mult = 4.5

/datum/munition_quality/masterwork
	name = "mistrzowska"
	roman = "V"
	level = 4
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
	var/list/trait_types
	/// Cechy: typ -> /datum/munition_trait
	var/list/traits

/datum/munition_filler/New()
	. = ..()
	traits = list()
	for(var/path in trait_types)
		traits[path] = new path

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
	trait_types = list(/datum/munition_trait/incendiary/filler)

/datum/munition_filler/emp
	name = "ładunek EMP"
	short_name = "EMP"
	desc = "Zakłóca elektronikę celu. Ze srebra i miedzi działa mocniej."
	damage_mult = 0.8
	trait_types = list(/datum/munition_trait/emp)

// AQUILA - kuźnia amunicji: cechy materiałów i wypełnień (na wzór /datum/material_trait z Monkestation).
// Każdy materiał i każde wypełnienie ma listę cech. Stop dostaje cechy obu składników ze słabszą siłą.

/datum/munition_trait
	var/name = "cecha"
	/// Opis do examine i analizatora
	var/desc
	/// Siła cechy: 1 w czystym materiale, mniej w stopie
	var/power = 1

/datum/munition_trait/New(power = 1)
	src.power = power

/// Kopia cechy o innej sile (dla stopów)
/datum/munition_trait/proc/scaled(mult)
	return new type(power * mult)

/// Jak cecha z tym samym typem już jest, zostaje mocniejsza
/datum/munition_trait/proc/merge(datum/munition_trait/other)
	return other.power > power ? other : src

/datum/munition_trait/proc/describe()
	if(power >= 1)
		return desc
	return "[desc] (słabiej, [round(power * 100)]%)"

/// Efekt przy trafieniu w moba lub obiekt
/datum/munition_trait/proc/on_hit(obj/item/projectile/P, atom/target, datum/component/forged_munition/forged)
	return

/// Efekt przy trafieniu w statek na overmapie
/datum/munition_trait/proc/on_overmap_hit(obj/item/projectile/P, obj/structure/overmap/target, datum/component/forged_munition/forged)
	return

/// Zbiera cechy z kilku list w jedną, mocniejsza wygrywa
/proc/merge_munition_traits(list/into, list/traits, mult = 1)
	for(var/key in traits)
		var/datum/munition_trait/T = traits[key]
		var/datum/munition_trait/copy = mult == 1 ? T : T.scaled(mult)
		var/datum/munition_trait/existing = into[T.type]
		into[T.type] = existing ? existing.merge(copy) : copy
	return into

// ---------------------------------------------------------------- cechy

/datum/munition_trait/holy
	name = "srebrzysta"
	desc = "Dodatkowo rani kultystów i wampiry."

/datum/munition_trait/holy/on_hit(obj/item/projectile/P, atom/target, datum/component/forged_munition/forged)
	if(!isliving(target))
		return
	var/mob/living/L = target
	if(IS_CULTIST(L) || IS_VAMPIRE(L))
		L.apply_damage(P.damage * 0.5 * power, BRUTE, P.def_zone)
		to_chat(L, "<span class='userdanger'>Srebro pali cię od środka!</span>")

/datum/munition_trait/radioactive
	name = "radioaktywna"
	desc = "Napromieniowuje trafionych."

/datum/munition_trait/radioactive/on_hit(obj/item/projectile/P, atom/target, datum/component/forged_munition/forged)
	if(isliving(target))
		var/mob/living/L = target
		L.apply_effect(round(30 * power), EFFECT_IRRADIATE)

/datum/munition_trait/incendiary
	name = "zapalająca"
	desc = "Podpala cel i kadłub trafionego statku."
	/// Ile fire_stacks przy sile 1
	var/fire_stacks = 1
	/// Ile hullburn przy sile 1
	var/hullburn = 5
	var/hullburn_power = 4

/datum/munition_trait/incendiary/scaled(mult)
	var/datum/munition_trait/incendiary/copy = ..()
	copy.fire_stacks = fire_stacks
	copy.hullburn = hullburn
	copy.hullburn_power = hullburn_power
	return copy

/datum/munition_trait/incendiary/merge(datum/munition_trait/other)
	var/datum/munition_trait/incendiary/I = other
	return (I.fire_stacks * I.power > fire_stacks * power) ? I : src

/datum/munition_trait/incendiary/on_hit(obj/item/projectile/P, atom/target, datum/component/forged_munition/forged)
	if(isliving(target))
		var/mob/living/L = target
		L.adjust_fire_stacks(max(round(fire_stacks * power), 1))
		L.IgniteMob()

/datum/munition_trait/incendiary/on_overmap_hit(obj/item/projectile/P, obj/structure/overmap/target, datum/component/forged_munition/forged)
	if(target.ai_controlled || istype(target, /obj/structure/overmap/small_craft))
		target.hullburn += round(hullburn * power)
		target.hullburn_power = max(target.hullburn_power, round(hullburn_power * power))

/// Mocniejsza wersja z wypełnienia
/datum/munition_trait/incendiary/filler
	fire_stacks = 2
	hullburn = 10
	hullburn_power = 6

/datum/munition_trait/honk
	name = "klaunowska"
	desc = "HONK. Czasem przewraca trafionego."

/datum/munition_trait/honk/on_hit(obj/item/projectile/P, atom/target, datum/component/forged_munition/forged)
	playsound(get_turf(target), 'sound/items/bikehorn.ogg', 50, TRUE)
	if(isliving(target) && prob(25 * power))
		var/mob/living/L = target
		L.Knockdown(1 SECONDS)

/datum/munition_trait/honk/on_overmap_hit(obj/item/projectile/P, obj/structure/overmap/target, datum/component/forged_munition/forged)
	playsound(target, 'sound/items/bikehorn.ogg', 100, TRUE)

/// Przewodzący materiał wzmacnia ładunek EMP. Sama nic nie robi.
/datum/munition_trait/conductive
	name = "przewodząca"
	desc = "Wzmacnia ładunek EMP."

/datum/munition_trait/emp
	name = "EMP"
	desc = "Zakłóca elektronikę celu. Z przewodzącym materiałem działa mocniej."

/datum/munition_trait/emp/proc/strength(datum/component/forged_munition/forged)
	. = power
	var/datum/munition_trait/conductive/C = forged?.get_trait(/datum/munition_trait/conductive)
	if(C)
		. *= 1 + 0.5 * C.power

/datum/munition_trait/emp/on_hit(obj/item/projectile/P, atom/target, datum/component/forged_munition/forged)
	target.emp_act(strength(forged) > 1 ? EMP_HEAVY : EMP_LIGHT)

/datum/munition_trait/emp/on_overmap_hit(obj/item/projectile/P, obj/structure/overmap/target, datum/component/forged_munition/forged)
	var/strength = strength(forged)
	var/amount = round(10 * strength)
	if(target.ai_controlled)
		if(target.disruption <= (amount * 2))
			target.disruption = min(target.disruption + amount, amount * 2)
		return
	if(istype(target, /obj/structure/overmap/small_craft))
		target.disruption += round(25 * strength)
		return
	target.add_sensor_profile_penalty(150, 10 SECONDS)

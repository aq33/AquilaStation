// AQUILA - kuźnia amunicji: cechy materiałów (na wzór /datum/material_trait z Monkestation).
// Każdy materiał ma listę cech, czyli efekt specjalny. Korpus z rdzeniem i powłoką bierze cechy powłoki.

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
	desc = "Napromieniowuje trafionych, a w okręcie wroga zabija załogę trafionego modułu."

/datum/munition_trait/radioactive/on_hit(obj/item/projectile/P, atom/target, datum/component/forged_munition/forged)
	if(isliving(target))
		var/mob/living/L = target
		SSradiation.irradiate(L, intensity = 30 * power * RAD_LEGACY_TO_INTENSITY)

/// Okręt AI (moduły, ship_modules.dm): promieniowanie zabija część załogi trafionego modułu i trochę w sąsiednich
/datum/munition_trait/radioactive/on_overmap_hit(obj/item/projectile/P, obj/structure/overmap/target, datum/component/forged_munition/forged)
	var/datum/ship_module/module = target.special_warhead_module(P)
	var/datum/ship_modules/modules = target.ship_modules
	if(!module || !modules)
		return
	module.crew_lost = min(1, module.crew_lost + 0.25 * power)
	for(var/datum/ship_module/near as anything in modules.neighbours(module))
		near.crew_lost = min(1, near.crew_lost + 0.08 * power)
	modules.apply_effects()

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

/// Srebro: impuls EMP przy trafieniu w okręt (tylko overmapa: amunicja ręczna z powłoką nie EMP-uje celu)
/datum/munition_trait/emp
	name = "EMP"
	desc = "Mocny impuls EMP: zakłóca systemy trafionego okrętu."

/// Miedź: ta sama cecha z połową siły
/datum/munition_trait/emp/weak
	desc = "Słaby impuls EMP: krócej zakłóca systemy trafionego okrętu."

/datum/munition_trait/emp/weak/New(power = 0.5)
	return ..(power)

/datum/munition_trait/emp/on_overmap_hit(obj/item/projectile/P, obj/structure/overmap/target, datum/component/forged_munition/forged)
	var/strength = power
	var/amount = round(10 * strength)
	if(target.ai_controlled)
		if(target.disruption <= (amount * 2))
			target.disruption = min(target.disruption + amount, amount * 2)
		return
	if(istype(target, /obj/structure/overmap/small_craft))
		target.disruption += round(25 * strength)
		return
	target.add_sensor_profile_penalty(150, 10 SECONDS)

/// Tytan: odporność na obronę punktową bierze się z integrity_mult materiału, cecha tylko to opisuje
/datum/munition_trait/hardened
	name = "utwardzona"
	desc = "Pocisk trudno zestrzelić obroną punktową."

/// Złoto: odłamki ranią kadłub mocniej, gdy ćwiartka nie ma już płyt pancerza
/datum/munition_trait/shrapnel
	name = "odłamkowa"
	desc = "Gdy trafiona ćwiartka okrętu nie ma już płyt pancerza, odłamki ranią kadłub o czwartą część mocniej."

/datum/munition_trait/shrapnel/on_overmap_hit(obj/item/projectile/P, obj/structure/overmap/target, datum/component/forged_munition/forged)
	if(target.use_armour_quadrants)
		var/list/quad = target.armour_quadrants[target.projectile_quadrant_impact(P)]
		if(quad && quad["current_armour"] > 0)
			return
	// Od obrażeń po modelu grubości pancerza: pocisk, który się odbił, nie sypie odłamkami w kadłub
	target.take_damage(round(target.aq_hit_damage(P) * 0.25 * power), P.damage_type, target.aq_hit_armor_flag(P), FALSE)

/// Diament: zdziera płyty pancerza ćwiartki ponad zwykłe trafienie
/datum/munition_trait/armor_strip
	name = "zdzierająca"
	desc = "Zdziera z trafionej ćwiartki okrętu dodatkowe płyty pancerza (czwartą część obrażeń)."

/datum/munition_trait/armor_strip/on_overmap_hit(obj/item/projectile/P, obj/structure/overmap/target, datum/component/forged_munition/forged)
	if(!target.use_armour_quadrants)
		return
	var/list/quad = target.armour_quadrants[target.projectile_quadrant_impact(P)]
	if(!quad)
		return
	quad["current_armour"] = max(quad["current_armour"] - round(target.aq_hit_damage(P) * 0.25 * power), 0)
	target.update_quadrants()

/// Bluespace: część obrażeń przechodzi przez podniesioną tarczę (aq_bluespace_shield_bypass w bullet_act okrętu)
/datum/munition_trait/shield_bypass
	name = "przenikająca"
	desc = "Czwarta część obrażeń przechodzi przez tarczę okrętu prosto w kadłub."

// AQUILA - kuźnia amunicji: wkładki do pancerza (własne sprite'y w armor_insert.dmi: płyta balistyczna, ciężka i lekka, ze stanem rozgrzanym).
// Odlew w piecu łukowym z wybranego materiału lub stopu, potem kucie pod młotem mechanicznym. Wykuta wkładka jest gotowa:
// wkłada się ją do kamizelki, pancerza albo hardsuitu (jedna na ubranie), a wyjmuje śrubokrętem.
// Ochronę i wytrzymałość daje materiał (tabela niżej), klasa jakości mnoży obie. Ciężki materiał spowalnia.
// Trafienia w części ciała zakryte przez pancerz zużywają wkładkę: ochrona spada co ćwierć wytrzymałości, a zniszczona pęka.

/// Ochrona ciężkiej wkładki z materiału (lekka daje AQ_INSERT_LIGHT_MULT) i mnożnik wytrzymałości
GLOBAL_LIST_INIT(aq_insert_profiles, list(
	/datum/material/iron = list("melee" = 10, "bullet" = 15, "laser" = 5, "bomb" = 5, "durability" = 1),
	/datum/material/copper = list("melee" = 8, "bullet" = 10, "laser" = 10, "energy" = 5, "durability" = 0.8),
	/datum/material/titanium = list("melee" = 15, "bullet" = 20, "laser" = 10, "bomb" = 5, "durability" = 1.5),
	/datum/material/silver = list("melee" = 5, "bullet" = 10, "laser" = 15, "energy" = 10, "durability" = 0.7),
	/datum/material/gold = list("melee" = 5, "bullet" = 10, "laser" = 20, "energy" = 15, "durability" = 0.6),
	/datum/material/uranium = list("melee" = 15, "bullet" = 25, "bomb" = 10, "rad" = 30, "durability" = 1.4),
	/datum/material/plasma = list("melee" = 5, "bullet" = 5, "laser" = 15, "fire" = 30, "durability" = 0.6),
	/datum/material/diamond = list("melee" = 20, "bullet" = 30, "laser" = 15, "bomb" = 5, "durability" = 2),
	/datum/material/bluespace = list("melee" = 10, "bullet" = 15, "laser" = 10, "energy" = 15, "durability" = 1),
	/datum/material/bananium = list("melee" = 10, "bullet" = 5, "bomb" = 15, "durability" = 3),
))

/// Lekka wkładka: tyle ochrony, wytrzymałości i spowolnienia co ciężka
#define AQ_INSERT_LIGHT_MULT 0.6
/// Wytrzymałość ciężkiej wkładki z żelaza klasy I
#define AQ_INSERT_BASE_INTEGRITY 100
/// Gęstość, od której materiał spowalnia (żelazo ma 14), i spowolnienie na punkt gęstości ponad nią
#define AQ_INSERT_SLOWDOWN_DENSITY 15
#define AQ_INSERT_SLOWDOWN_PER_DENSITY 0.01

/// Profil wkładki z materiału; stop to średnia składników
/datum/munition_material/proc/insert_profile()
	return GLOB.aq_insert_profiles[material_type] || GLOB.aq_insert_profiles[/datum/material/iron]

/datum/munition_material/alloy/insert_profile()
	var/list/first_profile = first.insert_profile()
	var/list/second_profile = second.insert_profile()
	. = list()
	for(var/key in first_profile | second_profile)
		.[key] = (first_profile[key] + second_profile[key]) / 2

/obj/item/munition_part/body/armor_insert
	name = "wkładka pancerza"
	desc = "Płyta do włożenia w kamizelkę, pancerz albo hardsuit. Zużywa się od trafień."
	icon = 'aquila/icons/obj/munitions_forge/armor_insert.dmi'
	icon_state = "insert_heavy"
	forge_standalone = TRUE
	hammer_time = 3
	material_amount = MINERAL_MATERIAL_AMOUNT * 3
	/// Udział ochrony, wytrzymałości i spowolnienia ciężkiej wkładki
	var/size_mult = 1
	var/insert_integrity = 0
	var/insert_max_integrity = 0

/obj/item/munition_part/body/armor_insert/Initialize(mapload)
	. = ..()
	update_icon()

// Barwa materiału obejmuje płytę, a kolorowy pasek (stan _stripe) zostaje czytelny dzięki RESET_COLOR
/obj/item/munition_part/body/armor_insert/update_overlays()
	. = ..()
	if(forge_heat)
		return
	var/mutable_appearance/stripe = mutable_appearance(icon, "[initial(icon_state)]_stripe")
	stripe.appearance_flags = RESET_COLOR
	. += stripe

/obj/item/munition_part/body/armor_insert/light
	name = "lekka wkładka pancerza"
	desc = "Cienka płyta do kamizelki, pancerza albo hardsuitu. Chroni słabiej niż ciężka, ale prawie nie waży."
	icon_state = "insert_light"
	hammer_time = 2
	material_amount = MINERAL_MATERIAL_AMOUNT * 2
	size_mult = AQ_INSERT_LIGHT_MULT

/obj/item/munition_part/body/armor_insert/heavy
	name = "ciężka wkładka pancerza"
	desc = "Gruba płyta do kamizelki, pancerza albo hardsuitu. Chroni najlepiej, ale z ciężkiego metalu spowalnia."

/obj/item/munition_part/body/armor_insert/forging_finished(datum/munition_quality/final_quality, accuracy)
	..()
	insert_max_integrity = round(AQ_INSERT_BASE_INTEGRITY * size_mult * insert_durability_mult() * quality.bonus)
	insert_integrity = insert_max_integrity

/obj/item/munition_part/body/armor_insert/proc/insert_durability_mult()
	var/list/profile = material?.insert_profile()
	return profile ? profile["durability"] : 1

/// Ochrona przy danym zużyciu: pełna, 3/4, 1/2 albo 1/4 (co ćwierć wytrzymałości, żeby nie tworzyć datumu pancerza co trafienie)
/obj/item/munition_part/body/armor_insert/proc/insert_armor()
	. = list()
	if(!material || !insert_max_integrity)
		return
	var/wear_factor = insert_wear_step() / 4
	var/list/profile = material.insert_profile()
	for(var/key in profile)
		if(key == "durability")
			continue
		var/rating = round(profile[key] * size_mult * quality.bonus * wear_factor)
		if(rating)
			.[key] = rating

/// Ile ćwierci ochrony zostało (4 = cała, 0 = pęknięta)
/obj/item/munition_part/body/armor_insert/proc/insert_wear_step()
	if(!insert_max_integrity)
		return 0
	return CEILING(4 * insert_integrity / insert_max_integrity, 1)

/obj/item/munition_part/body/armor_insert/proc/insert_slowdown()
	if(!material)
		return 0
	return round(max(0, material.density - AQ_INSERT_SLOWDOWN_DENSITY) * AQ_INSERT_SLOWDOWN_PER_DENSITY * size_mult, 0.01)

/obj/item/munition_part/body/armor_insert/examine(mob/user)
	. = ..()
	if(!is_finished())
		return
	var/list/parts = list()
	for(var/key in insert_armor())
		parts += "[aq_armor_key_pl(key)] +[insert_armor()[key]]"
	. += "<span class='notice'>Ochrona: [length(parts) ? jointext(parts, ", ") : "żadna"].</span>"
	. += "<span class='notice'>Wytrzymałość: [insert_integrity]/[insert_max_integrity].</span>"
	var/slow = insert_slowdown()
	if(slow)
		. += "<span class='warning'>Ciężka: spowalnia o [slow].</span>"

/// Polska nazwa rodzaju ochrony do opisów
/proc/aq_armor_key_pl(key)
	var/static/list/names = list("melee" = "wręcz", "bullet" = "pociski", "laser" = "lasery", "energy" = "energia", "bomb" = "wybuchy", "rad" = "promieniowanie", "fire" = "ogień")
	return names[key] || key

/// Zużycie od trafienia; TRUE, gdy wkładka pękła
/obj/item/munition_part/body/armor_insert/proc/take_insert_damage(amount)
	insert_integrity = max(0, insert_integrity - amount)
	return !insert_integrity

// ---------------------------------------------------------------- slot w pancerzu

/obj/item/clothing/suit
	/// Czy ubranie ma slot na wkładkę pancerza
	var/aq_insert_slot = FALSE
	var/obj/item/munition_part/body/armor_insert/aq_insert
	/// Ochrona (datum pancerza) i spowolnienie dodane przez wkładkę, do zdjęcia przy wymianie albo zużyciu
	var/datum/armor/aq_insert_armor_applied
	var/aq_insert_slowdown_applied = 0

/obj/item/clothing/suit/armor
	aq_insert_slot = TRUE
/obj/item/clothing/suit/ship/peacekeeper
	aq_insert_slot = TRUE
/obj/item/clothing/suit/ship/squad
	aq_insert_slot = TRUE
/obj/item/clothing/suit/space/hardsuit
	aq_insert_slot = TRUE

/obj/item/clothing/suit/Destroy()
	if(aq_insert)
		aq_insert.forceMove(drop_location())
		aq_remove_insert_effects()
		aq_insert = null
	return ..()

/obj/item/clothing/suit/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == aq_insert)
		aq_remove_insert_effects()
		aq_insert = null

/obj/item/clothing/suit/examine(mob/user)
	. = ..()
	if(!aq_insert_slot)
		return
	if(aq_insert)
		. += "<span class='notice'>Ma włożoną [aq_insert.name] ([aq_insert.insert_integrity]/[aq_insert.insert_max_integrity]). Wyjmiesz ją śrubokrętem.</span>"
	else
		. += "<span class='notice'>Ma kieszeń na wkładkę pancerza z kuźni.</span>"

/obj/item/clothing/suit/attackby(obj/item/I, mob/user, params)
	if(aq_insert_slot && istype(I, /obj/item/munition_part/body/armor_insert))
		aq_try_insert(I, user)
		return TRUE
	return ..()

/obj/item/clothing/suit/screwdriver_act(mob/living/user, obj/item/tool)
	if(!aq_insert)
		return ..()
	to_chat(user, "<span class='notice'>Zaczynasz wyjmować [aq_insert] z [src]...</span>")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 50) || !aq_insert)
		return TRUE
	var/obj/item/munition_part/body/armor_insert/removed = aq_insert
	removed.forceMove(drop_location()) // Exited zdejmuje efekty
	user.put_in_hands(removed)
	to_chat(user, "<span class='notice'>Wyjmujesz [removed] z [src].</span>")
	return TRUE

/obj/item/clothing/suit/proc/aq_try_insert(obj/item/munition_part/body/armor_insert/insert, mob/user)
	if(!insert.is_finished())
		to_chat(user, "<span class='warning'>[insert] trzeba jeszcze wykuć pod młotem mechanicznym.</span>")
		return FALSE
	if(insert.forge_heat)
		to_chat(user, "<span class='warning'>[insert] jest jeszcze gorąca!</span>")
		return FALSE
	if(aq_insert)
		to_chat(user, "<span class='warning'>W [src] jest już wkładka. Wyjmij ją śrubokrętem.</span>")
		return FALSE
	to_chat(user, "<span class='notice'>Wsuwasz [insert] do [src]...</span>")
	if(!do_after(user, 3 SECONDS, target = src) || aq_insert || !user.is_holding(insert))
		return FALSE
	if(!user.transferItemToLoc(insert, src))
		return FALSE
	aq_insert = insert
	aq_apply_insert_effects()
	to_chat(user, "<span class='notice'>Wkładasz [insert] do [src].</span>")
	playsound(src, 'sound/items/ratchet.ogg', 40, TRUE)
	return TRUE

/obj/item/clothing/suit/proc/aq_apply_insert_effects()
	aq_remove_insert_effects()
	if(!aq_insert)
		return
	var/list/ratings = aq_insert.insert_armor()
	if(length(ratings))
		aq_insert_armor_applied = getArmor(arglist(ratings))
		armor = armor.attachArmor(aq_insert_armor_applied)
	aq_insert_slowdown_applied = aq_insert.insert_slowdown()
	slowdown += aq_insert_slowdown_applied
	aq_update_wearer()

/obj/item/clothing/suit/proc/aq_remove_insert_effects()
	if(aq_insert_armor_applied)
		armor = armor.detachArmor(aq_insert_armor_applied)
	aq_insert_armor_applied = null
	if(aq_insert_slowdown_applied)
		slowdown = max(0, slowdown - aq_insert_slowdown_applied)
		aq_insert_slowdown_applied = 0
		aq_update_wearer()

/obj/item/clothing/suit/proc/aq_update_wearer()
	var/mob/living/carbon/human/wearer = loc
	if(istype(wearer) && wearer.wear_suit == src)
		wearer.update_equipment_speed_mods()

/obj/item/clothing/suit/equipped(mob/user, slot)
	. = ..()
	if(aq_insert_slot && (slot & ITEM_SLOT_OCLOTHING))
		RegisterSignal(user, COMSIG_MOB_APPLY_DAMGE, PROC_REF(aq_insert_on_damage), override = TRUE)

/obj/item/clothing/suit/dropped(mob/user)
	. = ..()
	if(aq_insert_slot)
		UnregisterSignal(user, COMSIG_MOB_APPLY_DAMGE)

/// Trafienie w zakrytą część ciała zużywa wkładkę (obrażenia przed pancerzem, tylko fizyczne i od oparzeń)
/obj/item/clothing/suit/proc/aq_insert_on_damage(mob/living/carbon/human/source, damage, damagetype, def_zone)
	SIGNAL_HANDLER
	if(!aq_insert || damage <= 0 || source.wear_suit != src || !(damagetype == BRUTE || damagetype == BURN))
		return
	var/zone = check_zone(def_zone)
	if(isbodypart(def_zone))
		var/obj/item/bodypart/hit_part = def_zone
		zone = hit_part.body_zone
	if(!(body_zone2cover_flags(zone) & body_parts_covered))
		return
	var/old_wear = aq_insert.insert_wear_step()
	if(aq_insert.take_insert_damage(damage))
		var/obj/item/munition_part/body/armor_insert/broken = aq_insert
		to_chat(source, "<span class='warning'>[broken] w [src] pęka!</span>")
		playsound(source, 'sound/effects/glassbr1.ogg', 40, TRUE)
		qdel(broken) // Exited zdejmuje efekty
		return
	if(aq_insert.insert_wear_step() != old_wear)
		aq_apply_insert_effects()

#undef AQ_INSERT_LIGHT_MULT
#undef AQ_INSERT_BASE_INTEGRITY
#undef AQ_INSERT_SLOWDOWN_DENSITY
#undef AQ_INSERT_SLOWDOWN_PER_DENSITY

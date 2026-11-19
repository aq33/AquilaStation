// AQUILA - rany robotyczne na naszym lekkim systemie ran (aquila/code/modules/wounds/).
// Pomysł z Nova Sector/Effigy/Shiptest (modular_nova/modules/medical/code/wounds/synth/, local/code/datums/wounds/blunt_robotic_base.dm,
// code/datums/wounds/robotic/): robotyczne kończyny (protezy, IPC) zamiast złamań i krwawienia dostają luźne śruby i wgniecenia,
// postrzępione i przecięte przewody, przegrzane obwody i wypaczoną blachę. Liczby i kroki leczenia są nasze, krótsze niż w Novie:
// - uderzenia: luźne śruby (śrubokręt) <- wgniecenie obudowy (spawarka) <- zgniecione serwa (klucz),
// - cięcia i postrzały: postrzępione przewody (kabel) <- przecięte przewody (kabel x3),
// - oparzenia: przegrzane obwody (gaśnica, potem stygnie sama) <- wypaczona blacha (spawarka).
// Cięższa rana po naprawie zamienia się w lżejszą. Narzędziem leczy się bez trybu walki, celując w kończynę.
// Kołki i protezy kinetyczne (limb_types.dm) nie mają ran: nie są ani organiczne, ani robotyczne.

// --- Losowanie ---

/// Rodzaje ran robotycznych od najlżejszej
/proc/aq_robotic_wound_types(wound_type)
	switch(wound_type)
		if(WOUND_AQ_ROBOTIC_BLUNT)
			return list(/datum/wound/aq_robotic/blunt/loose, /datum/wound/aq_robotic/blunt/dent, /datum/wound/aq_robotic/blunt/crushed)
		if(WOUND_AQ_ROBOTIC_ELECTRIC)
			return list(/datum/wound/aq_robotic/electric/frayed, /datum/wound/aq_robotic/electric/severed)
		if(WOUND_AQ_ROBOTIC_HEAT)
			return list(/datum/wound/aq_robotic/heat/overheat, /datum/wound/aq_robotic/heat/warped)

/// Rodzaj rany organicznej -> rodzaj rany robotycznej
/proc/aq_robotic_wound_kind(wound_type)
	switch(wound_type)
		if(WOUND_BLUNT)
			return WOUND_AQ_ROBOTIC_BLUNT
		if(WOUND_SLASH, WOUND_PIERCE)
			return WOUND_AQ_ROBOTIC_ELECTRIC
		if(WOUND_BURN)
			return WOUND_AQ_ROBOTIC_HEAT

/mob/living/carbon/check_wounding(obj/item/bodypart/limb, damage, wound_type, wound_bonus = 0, bare_wound_bonus = 0, atom/wound_source)
	if(limb && !IS_ORGANIC_LIMB(limb) && (limb.bodytype & BODYTYPE_ROBOTIC) && !limb.is_pseudopart)
		return aq_check_robotic_wounding(limb, damage, wound_type, wound_bonus, bare_wound_bonus, wound_source)
	return ..()

/// Ten sam rzut co w _wounds.dm, tylko na rany robotyczne
/mob/living/carbon/proc/aq_check_robotic_wounding(obj/item/bodypart/limb, damage, wound_type, wound_bonus = 0, bare_wound_bonus = 0, atom/wound_source)
	if(wound_bonus == CANT_WOUND || damage < WOUND_MINIMUM_DAMAGE || QDELETED(limb) || limb.owner != src || (status_flags & GODMODE))
		return
	var/kind = aq_robotic_wound_kind(wound_type)
	if(!kind)
		return
	var/roll = rand(1, max(1, round(min(damage, WOUND_MAX_CONSIDERED_DAMAGE) ** WOUND_DAMAGE_EXPONENT)))
	roll += wound_bonus
	if(bare_wound_bonus && !is_limb_covered(limb))
		roll += bare_wound_bonus
	for(var/datum/wound/other as anything in limb.wounds)
		roll += other.threshold_penalty
	var/datum/wound/existing = limb.get_wound(kind)
	if(existing)
		roll += existing.series_threshold_penalty
	var/chosen
	for(var/datum/wound/path as anything in aq_robotic_wound_types(kind))
		if(roll >= initial(path.threshold))
			chosen = path
	if(!chosen)
		return
	var/datum/wound/chosen_wound = chosen
	if(existing)
		if(initial(chosen_wound.severity) <= existing.severity)
			return
		existing.replaced = TRUE
		qdel(existing)
	var/datum/wound/new_wound = new chosen()
	new_wound.wound_source_is_projectile = isprojectile(wound_source)
	new_wound.apply_wound(limb)
	return new_wound

// --- Rany ---

/datum/wound/aq_robotic
	name = "uszkodzenie protezy"
	/// TOOL_X albo typ przedmiotu, którym się to naprawia
	var/repair_tool
	/// Ile sztuk stosu zużywa naprawa
	var/repair_amount = 1
	var/repair_time = 4 SECONDS
	/// Na co zamienia się rana po naprawie (null = znika)
	var/repaired_into
	/// Szansa na sekundę, że ręka upuści przedmiot
	var/drop_chance = 0

/datum/wound/aq_robotic/wound_effects(delta_time)
	if(treated)
		return
	if(drop_chance && limb.held_index && DT_PROB(drop_chance, delta_time))
		var/obj/item/held = victim.get_item_for_held_index(limb.held_index)
		if(held && victim.dropItemToGround(held))
			to_chat(victim, "<span class='danger'>Proteza ([limb.name]) zacina się i upuszczasz [held]!</span>")

/// Czy przedmiot pasuje do naprawy (narzędzie po tool_behaviour albo typ)
/datum/wound/aq_robotic/proc/is_repair_tool(obj/item/item)
	if(!repair_tool || !item)
		return FALSE
	if(ispath(repair_tool))
		return istype(item, repair_tool)
	return item.tool_behaviour == repair_tool

/datum/wound/aq_robotic/can_treat_with(obj/item/item)
	return is_repair_tool(item)

/datum/wound/aq_robotic/treat(obj/item/item, mob/user)
	var/self = user == victim
	user.visible_message("<span class='notice'>[user] zaczyna naprawiać [lowertext(name)] ([limb.name]) [victim].</span>", \
		"<span class='notice'>Zaczynasz naprawiać [lowertext(name)] ([limb.name])[self ? "" : " [victim]"].</span>")
	item.play_tool_sound(victim)
	if(!do_mob(user, victim, self ? repair_time * 1.5 : repair_time))
		return FALSE
	if(QDELETED(src) || !use_repair_item(item, user))
		return FALSE
	user.visible_message("<span class='green'>[user] naprawia [lowertext(name)] ([limb.name]) [victim].</span>", "<span class='green'>Naprawiasz [lowertext(name)] ([limb.name]).</span>")
	finish_repair()
	return TRUE

/datum/wound/aq_robotic/proc/use_repair_item(obj/item/item, mob/user)
	if(istype(item, /obj/item/stack))
		var/obj/item/stack/stack = item
		return stack.use(repair_amount)
	if(item.tool_behaviour == TOOL_WELDER)
		return item.use_tool(victim, user, 0, 1)
	if(istype(item, /obj/item/extinguisher))
		if(item.reagents.total_volume < 5)
			to_chat(user, "<span class='warning'>[item] jest pusta!</span>")
			return FALSE
		item.reagents.remove_any(5)
		playsound(victim, 'sound/effects/extinguish.ogg', 50, TRUE)
	return TRUE

/// Naprawa zamienia ranę w lżejszą albo ją usuwa
/datum/wound/aq_robotic/proc/finish_repair()
	if(repaired_into)
		replace_with(repaired_into)
	else
		replaced = TRUE // naprawiona proteza nie zostawia blizny
		qdel(src)

/datum/wound/aq_robotic/get_scan_text()
	var/status = treated ? " (zabezpieczone, naprawia się)" : ""
	return "[capitalize(limb.name)]: <b>[name]</b>[status]. [treat_text]"

// Uderzenia

/datum/wound/aq_robotic/blunt
	wound_type = WOUND_AQ_ROBOTIC_BLUNT

/datum/wound/aq_robotic/blunt/loose
	name = "Luźne śruby"
	desc = "Śruby w obudowie protezy się poluzowały"
	examine_desc = "poluzowaną, grzechoczącą obudowę"
	treat_text = "Dokręć śrubokrętem."
	severity = WOUND_SEVERITY_MODERATE
	threshold = 35
	threshold_penalty = 5
	series_threshold_penalty = 15
	repair_tool = TOOL_SCREWDRIVER
	repair_time = 3 SECONDS
	drop_chance = 0.5
	limp_slowdown = 0.5

/datum/wound/aq_robotic/blunt/dent
	name = "Wgniecenie obudowy"
	desc = "Obudowa protezy wgniata się i blokuje stawy"
	examine_desc = "mocno wgniecioną obudowę"
	treat_text = "Wyklep i zaspawaj spawarką, potem dokręć śruby."
	severity = WOUND_SEVERITY_SEVERE
	threshold = 60
	threshold_penalty = 15
	series_threshold_penalty = 30
	repair_tool = TOOL_WELDER
	repaired_into = /datum/wound/aq_robotic/blunt/loose
	drop_chance = 2
	limp_slowdown = 2
	treated_limp_slowdown = 0.5

/datum/wound/aq_robotic/blunt/crushed
	name = "Zgniecione serwa"
	desc = "Serwa protezy zgniatają się i przestają słuchać"
	examine_desc = "zgniecioną kończynę z wystającymi serwami"
	treat_text = "Wyprostuj szkielet kluczem, potem spawarka i śrubokręt."
	severity = WOUND_SEVERITY_CRITICAL
	threshold = 110
	threshold_penalty = 25
	repair_tool = TOOL_WRENCH
	repair_time = 5 SECONDS
	repaired_into = /datum/wound/aq_robotic/blunt/dent
	limp_slowdown = 4
	treated_limp_slowdown = 1

/datum/wound/aq_robotic/blunt/crushed/on_apply()
	if(limb.aq_is_extremity())
		ADD_TRAIT(limb, TRAIT_PARALYSIS, REF(src))
		limb.update_disabled()

/datum/wound/aq_robotic/blunt/crushed/Destroy()
	if(limb)
		REMOVE_TRAIT(limb, TRAIT_PARALYSIS, REF(src))
		if(limb.owner)
			limb.update_disabled()
	return ..()

// Przewody

/datum/wound/aq_robotic/electric
	wound_type = WOUND_AQ_ROBOTIC_ELECTRIC
	/// Szansa na sekundę, że przewody sypną iskrami i porażą właściciela
	var/shock_chance = 1
	var/shock_damage = 1

/datum/wound/aq_robotic/electric/wound_effects(delta_time)
	. = ..()
	if(treated || !DT_PROB(shock_chance, delta_time))
		return
	do_sparks(2, FALSE, victim)
	limb.receive_damage(0, shock_damage)
	to_chat(victim, "<span class='danger'>Przewody w protezie ([limb.name]) iskrzą i kopią prądem!</span>")
	if(severity >= WOUND_SEVERITY_SEVERE)
		victim.Jitter(4)
		if(limb.held_index)
			var/obj/item/held = victim.get_item_for_held_index(limb.held_index)
			if(held)
				victim.dropItemToGround(held)

/datum/wound/aq_robotic/electric/frayed
	name = "Postrzępione przewody"
	desc = "Przewody w protezie strzępią się i iskrzą"
	examine_desc = "wystające, postrzępione przewody"
	treat_text = "Wymień przewody kablem."
	severity = WOUND_SEVERITY_MODERATE
	threshold = 35
	series_threshold_penalty = 15
	repair_tool = /obj/item/stack/cable_coil
	repair_time = 3 SECONDS
	shock_chance = 1
	shock_damage = 1

/datum/wound/aq_robotic/electric/severed
	name = "Przecięte przewody"
	desc = "Przewody w protezie są przecięte i zwierają"
	examine_desc = "przecięte, zwierające przewody"
	treat_text = "Wymień przewody (trzy odcinki kabla)."
	severity = WOUND_SEVERITY_SEVERE
	threshold = 65
	threshold_penalty = 15
	repair_tool = /obj/item/stack/cable_coil
	repair_amount = 3
	repair_time = 5 SECONDS
	repaired_into = /datum/wound/aq_robotic/electric/frayed
	shock_chance = 3
	shock_damage = 2
	limp_slowdown = 1

// Przegrzanie

/datum/wound/aq_robotic/heat
	wound_type = WOUND_AQ_ROBOTIC_HEAT
	/// Oparzeń kończyny na sekundę, póki rana nie jest schłodzona
	var/burn_rate = 0.2

/datum/wound/aq_robotic/heat/wound_effects(delta_time)
	. = ..()
	if(treated)
		return
	limb.receive_damage(0, burn_rate * delta_time)

/datum/wound/aq_robotic/heat/overheat
	name = "Przegrzane obwody"
	desc = "Obwody w protezie przegrzewają się"
	examine_desc = "rozgrzaną do czerwoności obudowę"
	treat_text = "Schłodź gaśnicą, potem ostygnie sama."
	severity = WOUND_SEVERITY_SEVERE
	threshold = 80
	threshold_penalty = 10
	series_threshold_penalty = 30
	repair_tool = /obj/item/extinguisher
	repair_time = 3 SECONDS
	heal_time = 1 MINUTES

/// Schłodzone obwody stygną same przez minutę
/datum/wound/aq_robotic/heat/overheat/finish_repair()
	treated = TRUE
	heal_time = 1 MINUTES

/datum/wound/aq_robotic/heat/overheat/can_treat_with(obj/item/item)
	return !treated && ..()

/datum/wound/aq_robotic/heat/warped
	name = "Wypaczona blacha"
	desc = "Blacha protezy wypacza się od żaru"
	examine_desc = "wypaczoną, nadtopioną blachę"
	treat_text = "Wyprostuj spawarką, potem schłodź."
	severity = WOUND_SEVERITY_CRITICAL
	threshold = 140
	threshold_penalty = 20
	repair_tool = TOOL_WELDER
	repair_time = 5 SECONDS
	repaired_into = /datum/wound/aq_robotic/heat/overheat
	burn_rate = 0.5
	drop_chance = 1
	limp_slowdown = 2

// --- Narzędzia na ludziach ---

/// Naprawa rany robotycznej narzędziem (bez trybu walki). Zwraca TRUE, gdy kliknięcie zostało obsłużone.
/obj/item/proc/aq_robotics_tool_act(mob/living/carbon/patient, mob/living/user)
	if(!iscarbon(patient) || !isliving(user) || user.combat_mode || (patient in user.do_afters))
		return FALSE
	var/obj/item/bodypart/limb = patient.get_bodypart(check_zone(user.zone_selected))
	if(!limb)
		return FALSE
	for(var/datum/wound/aq_robotic/wound in limb.wounds)
		if(wound.can_treat_with(src))
			INVOKE_ASYNC(wound, TYPE_PROC_REF(/datum/wound, treat), src, user)
			return TRUE
	return FALSE

/obj/item/screwdriver/attack(mob/living/M, mob/living/user)
	if(aq_robotics_tool_act(M, user))
		return
	return ..()

/obj/item/weldingtool/attack(mob/living/carbon/human/H, mob/user)
	if(aq_robotics_tool_act(H, user))
		return
	return ..()

/obj/item/stack/cable_coil/attack(mob/living/carbon/human/H, mob/user)
	if(aq_robotics_tool_act(H, user))
		return
	return ..()

/obj/item/wrench/attack(mob/living/M, mob/living/user)
	if(aq_robotics_tool_act(M, user))
		return
	return ..()

/obj/item/extinguisher/attack(mob/living/M, mob/living/user)
	if(aq_robotics_tool_act(M, user))
		return
	return ..()

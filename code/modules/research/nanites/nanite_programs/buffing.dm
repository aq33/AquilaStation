//Programs that buff the host in generally passive ways.

/datum/nanite_program/nervous
	name = "Wsparcie nerwów"
	desc = "Nanity działają jak drugi układ nerwowy, skracając czas ogłuszenia nosiciela."
	use_rate = 1.5
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/nanite_program/nervous/enable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.stun_mod *= 0.5

/datum/nanite_program/nervous/disable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.stun_mod *= 2

/datum/nanite_program/adrenaline
	name = "Zastrzyk adrenaliny"
	desc = "Po aktywacji nanity wywołują wyrzut adrenaliny, który pozwala nosicielowi przekroczyć zwykłe granice możliwości ciała."
	can_trigger = TRUE
	trigger_cost = 20
	trigger_cooldown = 1200
	rogue_types = list(/datum/nanite_program/toxic, /datum/nanite_program/nerve_decay)

/datum/nanite_program/adrenaline/on_trigger()
	to_chat(host_mob, "<span class='notice'>Czujesz nagły przypływ energii!</span>")
	host_mob.SetAllImmobility(0)
	host_mob.adjustStaminaLoss(-75)
	host_mob.set_resting(FALSE)
	host_mob.update_mobility()

/datum/nanite_program/hardening
	name = "Utwardzenie skóry"
	desc = "Nanity tworzą pod skórą nosiciela siatkę, która chroni go przed ciosami i pociskami."
	use_rate = 0.5
	rogue_types = list(/datum/nanite_program/skin_decay)

//TODO on_hit effect that turns skin grey for a moment

/datum/nanite_program/hardening/enable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.armor.melee += 30
		H.physiology.armor.bullet += 30

/datum/nanite_program/hardening/disable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.armor.melee -= 30
		H.physiology.armor.bullet -= 30

/datum/nanite_program/refractive
	name = "Refrakcyjna powłoka skóry"
	desc = "Nanity tworzą na skórze nosiciela błonę, która osłabia trafienia laserów i broni energetycznej."
	use_rate = 0.50
	rogue_types = list(/datum/nanite_program/skin_decay)

/datum/nanite_program/refractive/enable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.armor.laser += 30
		H.physiology.armor.energy += 30

/datum/nanite_program/refractive/disable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.armor.laser -= 30
		H.physiology.armor.energy -= 30

/datum/nanite_program/coagulating
	name = "Szybkie krzepnięcie"
	desc = "Gdy nosiciel jest ranny, nanity wywołują szybkie krzepnięcie, drastycznie ograniczając krwawienie."
	use_rate = 0.10
	rogue_types = list(/datum/nanite_program/suffocating)

/datum/nanite_program/coagulating/enable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.bleed_mod *= 0.1

/datum/nanite_program/coagulating/disable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.bleed_mod *= 10

/datum/nanite_program/conductive
	name = "Przewodnictwo elektryczne"
	desc = "Nanity działają jak uziemienie dla porażeń prądem, chroniąc nosiciela. Porażenia wciąż mogą uszkodzić same nanity."
	use_rate = 0.20
	program_flags = NANITE_SHOCK_IMMUNE
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/nanite_program/conductive/enable_passive_effect()
	. = ..()
	ADD_TRAIT(host_mob, TRAIT_SHOCKIMMUNE, "nanites")

/datum/nanite_program/conductive/disable_passive_effect()
	. = ..()
	REMOVE_TRAIT(host_mob, TRAIT_SHOCKIMMUNE, "nanites")

/datum/nanite_program/mindshield
	name = "Bariera umysłowa"
	desc = "Póki są aktywne, nanity tworzą wokół mózgu nosiciela ochronną błonę, która osłania go przed nienaturalnymi wpływami."
	use_rate = 0.40
	rogue_types = list(/datum/nanite_program/brain_decay, /datum/nanite_program/brain_misfire)

/datum/nanite_program/mindshield/enable_passive_effect()
	. = ..()
	if(!host_mob.mind.has_antag_datum(/datum/antagonist/rev, TRUE)) //won't work if on a rev, to avoid having implanted revs.
		ADD_TRAIT(host_mob, TRAIT_MINDSHIELD, "nanites")
		host_mob.sec_hud_set_implants()

/datum/nanite_program/mindshield/disable_passive_effect()
	. = ..()
	REMOVE_TRAIT(host_mob, TRAIT_MINDSHIELD, "nanites")
	host_mob.sec_hud_set_implants()

/datum/nanite_program/haste
	name = "Wstrzyknięcie amfetaminy"
	desc = "Po aktywacji nanity syntetyzują amfetaminę, która chwilowo przyspiesza bieg nosiciela."
	can_trigger = TRUE
	trigger_cost = 10
	trigger_cooldown = 1200
	rogue_types = list(/datum/nanite_program/toxic, /datum/nanite_program/nerve_decay)

/datum/nanite_program/haste/on_trigger()
	to_chat(host_mob, "<span class='notice'>Twoje ciało wydaje się lżejsze, a nogi rozluźnione!</span>")
	host_mob.set_resting(FALSE)
	host_mob.reagents.add_reagent(/datum/reagent/medicine/amphetamine, 3)

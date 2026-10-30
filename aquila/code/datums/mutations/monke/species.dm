// AQUILA - port z Monkestation2.0 (code/datums/mutations/species/floran.dm)
// W źródle to natywna mutacja Floran, ale sama mutacja nie ma ograniczenia rasy. U nas nie ma Floran, więc jest w puli dla wszystkich.

/datum/mutation/spores
	name = "Pory pieczarkowców" // Pory, nie spory!
	desc = "Pradawna mutacja z DNA floran, dzięki której nosiciel wydziela zarodniki."
	quality = POSITIVE
	difficulty = 12
	text_gain_indication = "<span class='notice'>Twoje pory stają się dziwnie wrażliwe..?</span>"
	instability = 30
	action_path = /datum/action/cooldown/spell/monke_spores
	energy_coeff = 1

/datum/action/cooldown/spell/monke_spores
	name = "Uwolnij zarodniki"
	desc = "Wypuść porami swoją krew w postaci mgiełki."
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "smoke"
	sound = 'sound/effects/smoke.ogg'
	cooldown_time = 1 MINUTES
	spell_requirements = NONE
	antimagic_flags = NONE

/datum/action/cooldown/spell/monke_spores/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return
	if(!isliving(owner))
		return FALSE

/datum/action/cooldown/spell/monke_spores/cast(mob/living/cast_on)
	. = ..()
	// Bez krwi pory wypuszczają grzybowy halucynogen
	var/blood_path = cast_on.get_blood_id()
	var/list/blood_data
	var/amount = 15
	if(blood_path)
		blood_data = cast_on.get_blood_data(blood_path)
		amount = min(cast_on.blood_volume, 15)
		cast_on.blood_volume = max(cast_on.blood_volume - amount, 0)
	else
		blood_path = /datum/reagent/drug/mushroomhallucinogen
	if(amount <= 0)
		return
	var/range = round(sqrt(amount / 2))

	var/datum/reagents/spore_reagents = new(amount)
	spore_reagents.add_reagent(blood_path, amount, blood_data)
	var/datum/effect_system/smoke_spread/chem/smoke = new
	smoke.set_up(spore_reagents, range, get_turf(cast_on), silent = TRUE)
	smoke.start()
	qdel(spore_reagents)
	cast_on.visible_message("<span class='warning'>Z porów [cast_on] bucha gęsta mgiełka!</span>", "<span class='notice'>Wypuszczasz zarodniki przez pory.</span>")

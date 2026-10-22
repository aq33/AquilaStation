// AQUILA - port z tgstation (code/datums/mutations/active.dm)
// tg wstrzykuje pumpup, synaptizine i determination. U nas nie ma pumpup ani determination:
// pumpup -> efedryna (szybkość i odporność na ogłuszenie), determination pominięte.

/datum/mutation/adrenaline_rush
	name = "Adrenaline Rush"
	desc = "The subject gains the ability to trigger their body's adrenaline response at will."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Czujesz się nakręcony!</span>"
	instability = 25
	action_path = /datum/action/cooldown/spell/adrenaline
	energy_coeff = 1
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/adrenaline_rush/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	update_power()

/datum/mutation/adrenaline_rush/modify()
	. = ..()
	update_power()

/datum/mutation/adrenaline_rush/proc/update_power()
	var/datum/action/cooldown/spell/adrenaline/to_modify = action_power
	if(!istype(to_modify))
		return
	to_modify.adrenaline_amount = 10 * GET_MUTATION_POWER(src)
	to_modify.comedown_amount = 7 / GET_MUTATION_SYNCHRONIZER(src)

/datum/action/cooldown/spell/adrenaline
	name = "Adrenaline!"
	desc = "Pobudź się i wyciśnij z ciała wszystko, co się da!"
	icon_icon = 'aquila/icons/mutations/tg/actions.dmi'
	button_icon_state = "adrenaline"
	cooldown_time = 2 MINUTES
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = NONE
	antimagic_flags = NONE
	/// Ile jednostek każdego dobrego reagenta
	var/adrenaline_amount = 10
	/// Ile jednostek każdego złego reagenta po wszystkim
	var/comedown_amount = 7

/datum/action/cooldown/spell/adrenaline/is_valid_target(atom/cast_on)
	return iscarbon(cast_on)

/datum/action/cooldown/spell/adrenaline/cast(mob/living/carbon/cast_on)
	. = ..()
	to_chat(cast_on, "<span class='userdanger'>Czujesz przypływ sił! Czas DZIAŁAĆ!</span>")
	cast_on.reagents.add_reagent(/datum/reagent/medicine/ephedrine, adrenaline_amount)
	cast_on.reagents.add_reagent(/datum/reagent/medicine/synaptizine, adrenaline_amount)
	addtimer(CALLBACK(src, PROC_REF(get_tired), cast_on), 25 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

/datum/action/cooldown/spell/adrenaline/proc/get_tired(mob/living/carbon/cast_on)
	if(QDELETED(cast_on))
		return
	to_chat(cast_on, "<span class='danger'>Przypływ adrenaliny ustępuje mdłościom i głębokiemu zmęczeniu mięśni.</span>")
	cast_on.reagents.add_reagent(/datum/reagent/peaceborg/tire, comedown_amount)
	cast_on.reagents.add_reagent(/datum/reagent/peaceborg/confuse, comedown_amount)
	cast_on.set_dizzy_if_lower(10 SECONDS)

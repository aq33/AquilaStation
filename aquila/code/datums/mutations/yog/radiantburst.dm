// AQUILA - port z Yogstation (code/datums/mutations/radiantburst.dm)

/datum/mutation/radiantburst
	name = "Radiant Burst"
	desc = "A mutation hidden deep within ethereal genetic code that allows you to blind people nearby."
	quality = POSITIVE
	difficulty = 12
	locked = TRUE
	text_gain_indication = "<span class='notice'>Światło wzbiera w tobie! Ach, co za rozkosz.</span>"
	text_lose_indication = "<span class='notice'>Cień wraca na twoje nocne niebo.</span>"
	action_path = /datum/action/cooldown/spell/aoe/radiantburst
	instability = 30
	power_coeff = 1 // większy zasięg
	synchronizer_coeff = 1 // nie oślepia siebie
	energy_coeff = 1 // krótsze odnowienie
	conflicts = list(/datum/mutation/glow, /datum/mutation/glow/anti)

/datum/mutation/radiantburst/modify()
	if(modified || !owner)
		return
	..()
	var/datum/action/cooldown/spell/aoe/radiantburst/burst = action_power
	if(!istype(burst))
		return
	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		burst.safe = TRUE
	if(GET_MUTATION_POWER(src) > 1)
		burst.bonus_strength += 1 // mocniej pali darkspawny i mocniej oślepia
		burst.aoe_radius += 1

/datum/action/cooldown/spell/aoe/radiantburst
	name = "Radiant Burst"
	desc = "You release all the light that is within you."
	icon_icon = 'icons/mob/actions/actions_clockcult.dmi'
	button_icon_state = "Kindle"
	aoe_radius = 5
	antimagic_flags = NONE
	spell_requirements = NONE
	cooldown_time = 15 SECONDS
	sound = 'sound/magic/blind.ogg'
	/// Nie oślepia rzucającego
	var/safe = FALSE
	var/bonus_strength = 0

/datum/action/cooldown/spell/aoe/radiantburst/cast(atom/cast_on)
	. = ..()
	if(!safe && iscarbon(owner))
		var/mob/living/carbon/dummy = owner
		dummy.flash_act(3 + bonus_strength) // światło jest W TOBIE, więc oślepia
	owner.visible_message("<span class='warning'>[owner] wypuszcza z siebie oślepiające światło.</span>", "<span class='notice'>Wypuszczasz całe światło, które w tobie jest.</span>")
	owner.color = LIGHT_COLOR_HOLY_MAGIC
	animate(owner, color = null, time = 0.5 SECONDS)

/datum/action/cooldown/spell/aoe/radiantburst/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/mob/living/carbon/human/nearby in view(aoe_radius, center))
		if(nearby == owner)
			continue
		things += nearby
	return things

/datum/action/cooldown/spell/aoe/radiantburst/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(!can_see(victim, caster))
		return
	var/mob/living/carbon/human/hurt = victim
	hurt.flash_act(1 + bonus_strength) // siła 1, więc okulary chronią, chyba że wzmocnione
	if(isdarkspawn(hurt))
		hurt.adjustFireLoss(bonus_strength ? 30 : 20)
		to_chat(hurt, "<span class='userdanger'>Oślepiające światło cię pali!</span>")
		playsound(hurt, 'sound/weapons/sear.ogg', 75, TRUE)

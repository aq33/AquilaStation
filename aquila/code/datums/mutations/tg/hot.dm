// AQUILA - port z tgstation (code/datums/mutations/hot.dm), wzorem nasza kriokineza (code/datums/mutations/cold.dm)

/datum/mutation/cindikinesis
	name = "Popiołokineza"
	desc = "Pacjent potrafi na zawołanie wyciągnąć z powietrza ciepło i stworzyć kupkę popiołu."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Twoja dłoń wydaje się ciepła.</span>"
	instability = 10
	difficulty = 10
	synchronizer_coeff = 1
	locked = TRUE
	action_path = /datum/action/cooldown/spell/conjure_item/ash

/datum/action/cooldown/spell/conjure_item/ash
	name = "Stwórz popiół"
	desc = "Skupia siły pirokinetyczne, żeby stworzyć popiół. Przydatne do niczego."
	icon_icon = 'aquila/icons/mutations/tg/actions.dmi'
	button_icon_state = "ash"
	cooldown_time = 5 SECONDS
	spell_requirements = NONE
	antimagic_flags = NONE
	item_type = /obj/effect/decal/cleanable/ash
	delete_old = FALSE

// Podtyp kriokinezy (tak go używają inne porty), ale z własną zdolnością
/datum/mutation/cryokinesis/pyrokinesis
	name = "Pirokineza"
	desc = "Pacjent potrafi czerpać z otoczenia energię i na zawołanie wystrzelić rozgrzany pocisk."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Twoja dłoń jest gorąca!</span>"
	instability = 25
	difficulty = 12
	synchronizer_coeff = 1
	energy_coeff = 1
	locked = TRUE
	power = null // nie dziedziczy starego zaklęcia kriokinezy
	action_path = /datum/action/cooldown/spell/pointed/tg_projectile/pyro

/datum/action/cooldown/spell/pointed/tg_projectile/pyro
	name = "Promień ognia"
	desc = "Wystrzeliwuje rozgrzany pocisk w cel."
	icon_icon = 'aquila/icons/mutations/tg/actions.dmi'
	button_icon_state = "firebeam"
	cast_range = 9
	cooldown_time = 30 SECONDS
	spell_requirements = NONE
	antimagic_flags = NONE
	active_msg = "Skupiasz swoją pirokinezę!"
	deactive_msg = "Ochładzasz się."
	projectile_type = /obj/item/projectile/temp/pyro

/obj/item/projectile/temp/pyro
	name = "gorący promień"
	icon = 'aquila/icons/mutations/tg/projectiles.dmi'
	icon_state = "firebeam"
	range = 9
	temperature = 500

/obj/item/projectile/temp/pyro/on_hit(atom/target, blocked = 0)
	. = ..()
	if(isobj(target))
		var/obj/hit_obj = target
		if(!(hit_obj.resistance_flags & ON_FIRE))
			hit_obj.fire_act(temperature)
		return
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.adjust_fire_stacks(2)
		living_target.ignite_mob()

/obj/item/projectile/temp/pyro/on_range()
	var/turf/location = get_turf(src)
	if(isopenturf(location))
		new /obj/effect/hotspot(location)
		location.hotspot_expose(700, 50, 1)
	return ..()

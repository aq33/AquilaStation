/*
	Use this to set the substrate of a tray
	Don't worry about putting a limit on how many times we can use this, that's silly.
	Just use it to swap the substrate of a tray that isn't currently growing a plant
*/

/obj/item/substrate_bag
	name = "worek z podłożem"
	desc = "Worek sypkiego podłoża. Jego zapach wypełnia całe pomieszczenie."
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "substrate_bag"
	///What substrate does this bag contain
	var/substrate = /datum/plant_subtrate

/obj/item/substrate_bag/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/datum/component/planter/tray_component = target.GetComponent(/datum/component/planter)
	if(!tray_component)
		return
	if(length(tray_component.plants))
		to_chat(user, span_warning("Nie możesz zmienić podłoża ([target]), dopóki rosną w nim rośliny!"))
		return
	if(!do_after(user, 2.3 SECONDS, target = target))
		return
	to_chat(user, "<span class='notice'>Wsypujesz podłoże do: [target].</span>")
	playsound(src, 'sound/effects/shovel_dig.ogg', 60)
	tray_component.set_substrate(substrate)

/*
	Generic presets for botany
*/

/obj/item/substrate_bag/dirt
	name = "worek z podłożem (ziemia)"
	icon_state = "substrate_dirt"
	substrate = /datum/plant_subtrate/dirt

/obj/item/substrate_bag/clay
	name = "worek z podłożem (glina)"
	icon_state = "substrate_clay"
	substrate = /datum/plant_subtrate/clay

/obj/item/substrate_bag/sand
	name = "worek z podłożem (piasek)"
	icon_state = "substrate_sand"
	substrate = /datum/plant_subtrate/sand

/obj/item/substrate_bag/debris
	name = "worek z podłożem (gruz)"
	icon_state = "substrate_debris"
	substrate = /datum/plant_subtrate/debris

/obj/item/substrate_bag/fairy
	name = "worek z tajemniczym podłożem"
	icon_state = "substrate_fairy"
	substrate = /datum/plant_subtrate/fairy

// AQUILA - Dym i zapachy, port z Monkestation 2.0
/obj/item/air_refresher
	name = "odświeżacz powietrza"
	desc = "Butelka wypełniona przesadnie intensywnym zapachem, z wygodnym ciśnieniowym rozpylaczem."
	icon = 'aquila/icons/monke/pollution/air_refresher.dmi'
	icon_state = "air_refresher"
	item_state = "cleaner"
	worn_icon_state = "spraybottle"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON
	var/uses_remaining = 20

/obj/item/air_refresher/examine(mob/user)
	. = ..()
	if(uses_remaining)
		. += "Zostało psiknięć: [uses_remaining]."
	else
		. += "Jest pusty."

/obj/item/air_refresher/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(uses_remaining <= 0)
		to_chat(user, span_warning("[src] jest pusty!"))
		return
	var/turf/open/aimed_turf = get_turf(target)
	if(!istype(aimed_turf) || isspaceturf(aimed_turf))
		return
	uses_remaining--
	aimed_turf.pollute_turf(/datum/pollutant/fragrance/air_refresher, 200)
	user.visible_message(span_notice("[user] psika dookoła z [src]."), span_notice("Psikasz dookoła z [src]."))
	user.changeNext_move(CLICK_CD_RANGE*2)
	playsound(aimed_turf, 'sound/effects/spray2.ogg', 50, TRUE, -6)

/// Janitor machine that slowly filters smoke and smells out of the tile it stands on
/obj/machinery/pollution_scrubber
	name = "oczyszczacz powietrza"
	desc = "Filtruje powietrze i usuwa z niego dym oraz zapachy. Przykręć go kluczem i włącz ręką."
	icon = 'aquila/icons/monke/pollution/pollution_scrubber.dmi'
	icon_state = "scrubber"
	density = TRUE
	anchored = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OFFLINE
	var/scrub_amount = 2
	var/on = FALSE

/obj/machinery/pollution_scrubber/examine(mob/user)
	. = ..()
	. += span_notice("Jest [on ? "włączony" : "wyłączony"][anchored ? "" : " i nieprzykręcony"].")
	if(machine_stat & NOPOWER)
		. += span_warning("Nie ma zasilania.")

/obj/machinery/pollution_scrubber/interact(mob/user)
	. = ..()
	on = !on
	balloon_alert(user, on ? "włączony" : "wyłączony")
	update_icon()

/obj/machinery/pollution_scrubber/wrench_act(mob/living/user, obj/item/tool)
	default_unfasten_wrench(user, tool)
	return TRUE

/obj/machinery/pollution_scrubber/update_icon_state()
	icon_state = on ? "scrubber_on" : "scrubber"
	return ..()

/obj/machinery/pollution_scrubber/process()
	if(!on || !anchored || machine_stat)
		return
	var/turf/open/open_turf = get_turf(src)
	if(!istype(open_turf) || !open_turf.pollution)
		return
	open_turf.pollution.scrub_amount(scrub_amount)
	use_power(active_power_usage)

/obj/structure/closet/jcloset/PopulateContents()
	..()
	new /obj/item/air_refresher(src)
	new /obj/item/air_refresher(src)

/datum/supply_pack/service/pollution_scrubber
	name = "Oczyszczacz powietrza"
	desc = "Przenośny oczyszczacz, który filtruje dym i zapachy z pomieszczenia. Przykręć go kluczem i włącz. Dorzucamy dwa odświeżacze powietrza."
	cost = 1200
	access_budget = ACCESS_JANITOR
	contains = list(/obj/machinery/pollution_scrubber,
					/obj/item/air_refresher,
					/obj/item/air_refresher)
	crate_name = "skrzynia z oczyszczaczem powietrza"
	crate_type = /obj/structure/closet/crate/large

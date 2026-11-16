// AQUILA - automatyczna kroplówka (AquilaMed 5), port z tgstation (code/modules/plumbing/plumbers/iv_drip.dm,
// code/datums/components/plumbing/automated_iv.dm), sprite'y z icons/obj/medical/iv_drip.dmi (CC-BY-SA 3.0).
// Kroplówka podłączona do kanalizacji chemicznej: z rur od południa (czerwone złącze) bierze płyny i wstrzykuje je
// pacjentowi, a w trybie pobierania oddaje krew do rur na północ (niebieskie złącze). Stawia się ją konstruktorem
// instalacji i przykręca kluczem. Różnica: u nas kroplówka trzyma płyny we wbudowanym pojemniku, którego nie da się wyjąć.

/// Modes of the core IV drip (code/game/machinery/iv_drip.dm undefines its own)
#define AQ_IV_TAKING 0
#define AQ_IV_INJECTING 1

/obj/machinery/iv_drip/plumbing
	name = "automatyczna kroplówka"
	desc = "Kroplówka podłączona do kanalizacji chemicznej. Płyny z rur (czerwone złącze) wstrzykuje pacjentowi, a pobraną krew oddaje do rur (niebieskie złącze). Przykręć ją kluczem, żeby działała."
	icon = 'aquila/icons/obj/medical/iv_plumbing.dmi'
	icon_state = "plumb"
	density = TRUE
	can_convert = FALSE

/obj/machinery/iv_drip/plumbing/Initialize(mapload, layer)
	beaker = new /obj/item/reagent_containers/glass/iv_plumbing_reservoir(src)
	reagents = beaker.reagents // komponent instalacji pracuje na zbiorniku kroplówki
	. = ..()
	AddComponent(/datum/component/plumbing/automated_iv, layer)

/obj/machinery/iv_drip/plumbing/Destroy()
	reagents = null
	return ..()

/obj/machinery/iv_drip/plumbing/update_icon()
	. = ..()
	cut_overlays()
	if(attached)
		icon_state = mode ? "plumb_injecting" : "plumb_donating"
	else
		icon_state = mode ? "plumb_injectidle" : "plumb_donateidle"
	// Złącza rur: komponent dopisuje je w update_overlays(). Nie przez update_appearance(), bo ta woła update_icon() (rekurencja).
	var/list/connectors = update_overlays()
	if(length(connectors))
		add_overlay(connectors)

/obj/machinery/iv_drip/plumbing/attackby(obj/item/W, mob/user, params)
	if(is_type_in_typecache(W, drip_containers) || IS_EDIBLE(W))
		to_chat(user, "<span class='warning'>[src] bierze płyny z rur, nie z pojemników.</span>")
		return
	return ..()

/obj/machinery/iv_drip/plumbing/eject_beaker()
	to_chat(usr, "<span class='warning'>Zbiornika [src] nie da się wyjąć.</span>")

/obj/machinery/iv_drip/plumbing/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/machinery/iv_drip/plumbing/plunger_act(obj/item/plunger/P, mob/living/user, reinforced)
	to_chat(user, "<span class='notice'>Przepychasz [src]...</span>")
	if(!do_after(user, 3 SECONDS, target = src))
		return TRUE
	reagents.reaction(get_turf(src), TOUCH)
	reagents.clear_reagents()
	to_chat(user, "<span class='notice'>Zbiornik [src] jest pusty.</span>")
	return TRUE

/// Built-in reservoir of the automated IV drip
/obj/item/reagent_containers/glass/iv_plumbing_reservoir
	name = "zbiornik kroplówki"
	volume = 100
	reagent_flags = OPENCONTAINER

/// Takes reagents from the ducts while injecting and gives blood to them while drawing (tg automated_iv)
/datum/component/plumbing/automated_iv
	demand_connects = SOUTH
	supply_connects = NORTH
	distinct_reagent_cap = 3

/datum/component/plumbing/automated_iv/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/iv_drip/plumbing))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/automated_iv/can_give(amount, reagent, datum/ductnet/net)
	var/obj/machinery/iv_drip/plumbing/drip = parent
	return ..() && drip.mode == AQ_IV_TAKING

/datum/component/plumbing/automated_iv/send_request(dir)
	var/obj/machinery/iv_drip/plumbing/drip = parent
	if(drip.mode == AQ_IV_INJECTING)
		return ..()

#undef AQ_IV_TAKING
#undef AQ_IV_INJECTING

/// Recykler złomu z wraków: kredyty dla zaopatrzenia, połowa tego dla gracza, materiały na podłogę
/obj/machinery/shipbreaker
	name = "recykler złomu"
	desc = "Drogi kruszarko-przetapiacz złomu okrętowego. Wrzuć albo przepchnij na niego złom z wraku."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-o0"
	layer = ABOVE_ALL_MOB_LAYER
	density = TRUE
	circuit = /obj/item/circuitboard/machine/shipbreaker
	idle_power_usage = 50
	active_power_usage = 200
	var/item_recycle_sound = 'sound/items/welder.ogg'
	/// Ile kredytów przerobił od początku rundy
	var/reclaimed = 0

/obj/machinery/shipbreaker/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/material_container, list(/datum/material/iron, /datum/material/glass, /datum/material/silver, /datum/material/plasma, /datum/material/gold, /datum/material/diamond, /datum/material/uranium, /datum/material/titanium, /datum/material/bluespace), INFINITY, FALSE, null, null, null, TRUE)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	update_icon()

/obj/machinery/shipbreaker/update_icon()
	. = ..()
	icon_state = "grinder-o[(machine_stat & (BROKEN|NOPOWER)) ? 0 : 1]"

/obj/machinery/shipbreaker/power_change()
	. = ..()
	update_icon()

/obj/machinery/shipbreaker/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Przerobiono złom wart <b>[reclaimed]</b> kr.</span>"

/obj/machinery/shipbreaker/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(anchored && isitem(mover))
		return TRUE

/obj/machinery/shipbreaker/proc/on_entered(datum/source, atom/movable/entering)
	SIGNAL_HANDLER
	if(entering == src)
		return
	INVOKE_ASYNC(src, PROC_REF(recycle_scrap), entering)

/obj/machinery/shipbreaker/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/scrap))
		if(!user.transferItemToLoc(I, loc))
			return TRUE
		return TRUE
	if(default_deconstruction_screwdriver(user, "grinder-oOpen", "grinder-o0", I))
		return TRUE
	if(default_unfasten_wrench(user, I))
		return TRUE
	if(default_deconstruction_crowbar(I))
		return TRUE
	return ..()

/obj/machinery/shipbreaker/proc/recycle_scrap(atom/movable/morsel)
	if(QDELETED(morsel) || morsel.loc != loc || !anchored)
		return
	if(machine_stat & (BROKEN|NOPOWER))
		return
	if(!istype(morsel, /obj/item/stack/scrap))
		if(isitem(morsel))
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		return
	var/obj/item/stack/scrap/scrap = morsel
	var/reward = scrap.amount * scrap.scrap_value
	reclaimed += reward
	playsound(src, item_recycle_sound, 50 + scrap.amount, TRUE)
	use_power(active_power_usage)
	var/datum/bank_account/budget = SSeconomy.get_dep_account(ACCOUNT_CAR)
	budget?.adjust_money(reward)
	var/mob/living/carbon/human/payee = get_mob_by_ckey(scrap.fingerprintslast)
	var/datum/bank_account/payee_account = istype(payee) ? payee.get_bank_account() : null
	if(payee_account)
		var/payout = round(reward * 0.5)
		payee_account.adjust_money(payout)
		payee_account.bank_card_talk("Przerobiono złom z wraku. Wypłata: [payout] kr.")
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	if(materials.insert_item(scrap))
		materials.retrieve_all(drop_location())
	playsound(src, 'sound/machines/ping.ogg', 50, FALSE)
	if(!QDELETED(scrap))
		qdel(scrap)

/obj/item/circuitboard/machine/shipbreaker
	name = "recykler złomu (płytka maszyny)"
	icon_state = "supply"
	build_path = /obj/machinery/shipbreaker
	req_components = list(/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

/datum/design/board/shipbreaker
	name = "Machine Design (Recykler złomu)"
	desc = "Płytka recyklera złomu z wraków."
	id = "shipbreaker_recycler"
	build_path = /obj/item/circuitboard/machine/shipbreaker
	category = list("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_ENGINEERING

/datum/techweb_node/engineering/New()
	. = ..()
	design_ids += "shipbreaker_recycler"

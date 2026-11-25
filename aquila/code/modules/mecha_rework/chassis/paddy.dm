// AQUILA - APLU "Paddy" (tg, code/modules/vehicles/mecha/working/ripley.dm): lekki mech ochrony na bazie Ripleya MK-I
// z wbudowaną celą na zatrzymanych i syrenami. Budowa jak w tg: zwykły Ripley MK-I + zestaw konwersji Paddy z fabrykatora.
// Do Paddy pasuje chwytak hydrauliczny na ludzi (zakłada opaski i wkłada do celi).

/obj/mecha/working/ripley/aq_paddy
	name = "\improper APLU \"Paddy\""
	desc = "Podtyp APLU \"Paddy\": przerobiony Ripley MK-I do lekkiej służby w ochronie. Ma celę na zatrzymanych i syreny."
	icon = 'aquila/icons/mecha/aq_mecha.dmi'
	icon_state = "paddy"
	silicon_icon_state = "paddy-empty"
	step_in = 3
	// Rodzina Ripleya bierze krok z ciśnienia (update_pressure w ripley.dm), nie ze step_in
	fast_pressure_step_in = 2
	slow_pressure_step_in = 3
	max_integrity = 250
	deflect_chance = 15
	armor = list("melee" = 40, "bullet" = 20, "laser" = 10, "energy" = 20, "bomb" = 40, "bio" = 0, "rad" = 20, "fire" = 100, "acid" = 100, "stamina" = 0)
	wreckage = /obj/structure/mecha_wreckage/aq_paddy
	operation_req_access = list(ACCESS_SECURITY)
	internals_req_access = list(ACCESS_MECH_SECURITY)
	aq_max_equip_by_category = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 4, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 1)
	var/sirens = FALSE
	var/datum/action/innate/mecha/aq_sirens/sirens_action = new

/obj/mecha/working/ripley/aq_paddy/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/jail_cell/cell = new(src)
	cell.attach(src)

/obj/mecha/working/ripley/aq_paddy/Destroy()
	. = ..()
	QDEL_NULL(sirens_action)

/obj/mecha/working/ripley/aq_paddy/GrantActions(mob/living/user, human_occupant = 0)
	. = ..()
	sirens_action.Grant(user, src)

/obj/mecha/working/ripley/aq_paddy/RemoveActions(mob/living/user, human_occupant = 0)
	. = ..()
	sirens_action.Remove(user)

/obj/mecha/working/ripley/aq_paddy/update_icon()
	. = ..()
	cut_overlay(mutable_appearance(icon, "paddy_sirens"))
	if(sirens)
		add_overlay(mutable_appearance(icon, "paddy_sirens"))

/obj/mecha/working/ripley/aq_paddy/proc/toggle_sirens()
	sirens = !sirens
	set_light_color(sirens ? LIGHT_COLOR_RED : initial(light_color))
	if(sirens)
		playsound(src, 'sound/items/weeoo1.ogg', 60, TRUE)
	update_icon()
	occupant_message("Syreny: [sirens ? "włączone" : "wyłączone"].")

/datum/action/innate/mecha/aq_sirens
	name = "Syreny"
	button_icon_state = "mech_lights_on"

/datum/action/innate/mecha/aq_sirens/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	var/obj/mecha/working/ripley/aq_paddy/P = chassis
	if(istype(P))
		P.toggle_sirens()

/obj/structure/mecha_wreckage/aq_paddy
	name = "wrak Paddy"
	icon = 'aquila/icons/mecha/aq_mecha.dmi'
	icon_state = "paddy-broken"

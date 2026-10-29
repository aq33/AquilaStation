// Karta Undercover I.D. dla detektywa (port Monke `monkestation/code/modules/security/code/undercover_id.dm`).
// Karta agenta, którą może fałszować każdy, ale bez kopiowania dostępów z innych kart.

/obj/item/card/id/syndicate/undercover
	name = "karta pod przykrywką"
	desc = "Najskrytsze marzenie detektywa Nanotrasenu: karta pod przykrywką. Zmienia nazwisko i wygląd, ale nie kopiuje cudzych dostępów. Multitoolem można zablokować przebranie."
	icon_state = "id"
	hud_state = JOB_HUD_UNKNOWN
	anyone = TRUE
	access = list(
		ACCESS_SEC_DOORS,
		ACCESS_COURT,
		ACCESS_FORENSICS_LOCKERS,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_SECURITY,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_SECURITY,
		ACCESS_WEAPONS,
	)
	/// Czy przebranie jest zablokowane multitoolem. Zablokowana karta działa jak zwykła karta ID.
	var/disguise_locked = FALSE

// Bez kopiowania dostępów z przyłożonej karty.
/obj/item/card/id/syndicate/undercover/afterattack(obj/item/O, mob/user, proximity)
	if(istype(O, /obj/item/card/id))
		return
	return ..()

/obj/item/card/id/syndicate/undercover/can_forge(mob/user, first_use_unlock = FALSE)
	if(disguise_locked)
		return FALSE
	return ..()

/obj/item/card/id/syndicate/undercover/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour != TOOL_MULTITOOL)
		return ..()
	disguise_locked = !disguise_locked
	if(disguise_locked)
		actions -= chameleon_action
		if(ismob(loc))
			chameleon_action.Remove(loc)
		SStgui.close_uis(src)
	else
		actions |= chameleon_action
		if(ismob(loc))
			chameleon_action.Grant(loc)
	balloon_alert(user, disguise_locked ? "przebranie zablokowane" : "przebranie odblokowane")
	log_game("[key_name(user)] has [disguise_locked ? "locked" : "unlocked"] the disguise of the undercover ID ([name]) with [W]")
	return TRUE

/obj/item/card/id/syndicate/undercover/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Przebranie jest [disguise_locked ? "zablokowane" : "odblokowane"]. Przełączasz je <b>multitoolem</b>.</span>"

/obj/structure/closet/secure_closet/detective/PopulateContents()
	..()
	new /obj/item/card/id/syndicate/undercover(src)

// Przepustka nie dopisuje dostępów do Undercover I.D.: karta ma stały zestaw.
/obj/item/card/id/pass/afterattack(atom/target, mob/user, proximity)
	if(proximity && istype(target, /obj/item/card/id/syndicate/undercover))
		to_chat(user, "<span class='warning'>[target] nie przyjmuje dodatkowych dostępów.</span>")
		return
	return ..()

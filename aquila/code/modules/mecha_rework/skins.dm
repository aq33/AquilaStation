// AQUILA - skiny mechów wybierane przez robotyka. Skin to osobny plik .dmi ze stanami nazwanymi jak stany podwozia
// ("gygax", "gygax-open", "gygax-broken"), więc podmiana zmiennej icon działa z całą logiką rdzenia (initial(icon_state)).
// Wybór: menu kołowe dla osoby, która skończyła budowę mecha. Skiny antagowe tylko dla podwozi antagów.
// Sprite'y złożone z oryginałów (Bay i Aurora: warstwy części w jeden stan) skryptem, źródła w aquila/icons/mecha/ATTRIBUTION.md.

/datum/aq_mecha_skin
	var/name
	var/icon
	/// icon_state podwozia, do którego pasuje (initial(icon_state))
	var/base_state
	var/pixel_x = 0
	var/antag_only = FALSE

/datum/aq_mecha_skin/proc/fits(obj/mecha/M)
	if(initial(M.icon_state) != base_state)
		return FALSE
	if(antag_only != M.aq_antag_chassis)
		return FALSE
	return TRUE

/datum/aq_mecha_skin/brigand
	name = "Brigand"
	icon = 'aquila/icons/mecha/skins/brigand.dmi'
	base_state = "durand"

/datum/aq_mecha_skin/redstar
	name = "Redstar"
	icon = 'aquila/icons/mecha/skins/redstar.dmi'
	base_state = "durand"

/datum/aq_mecha_skin/clip_paladin
	name = "CLIP Paladin"
	icon = 'aquila/icons/mecha/skins/clip_paladin.dmi'
	base_state = "durand"

/datum/aq_mecha_skin/irmg_basenji
	name = "IRMG Basenji"
	icon = 'aquila/icons/mecha/skins/irmg_basenji.dmi'
	base_state = "gygax"

/datum/aq_mecha_skin/maid
	name = "M.A.I.D"
	icon = 'aquila/icons/mecha/skins/maid.dmi'
	base_state = "gygax"

/datum/aq_mecha_skin/serenity
	name = "Serenity"
	icon = 'aquila/icons/mecha/skins/serenity.dmi'
	base_state = "odysseus"

/datum/aq_mecha_skin/dark_odysseus
	name = "Mroczny Odyseusz"
	icon = 'aquila/icons/mecha/skins/dark_odysseus.dmi'
	base_state = "odysseus"

/datum/aq_mecha_skin/imperion
	name = "Imperion"
	icon = 'aquila/icons/mecha/skins/imperion.dmi'
	base_state = "phazon"

/datum/aq_mecha_skin/janus
	name = "Janus"
	icon = 'aquila/icons/mecha/skins/janus.dmi'
	base_state = "phazon"

/datum/aq_mecha_skin/dark_phazon
	name = "Mroczny Phazon"
	icon = 'aquila/icons/mecha/skins/dark_phazon.dmi'
	base_state = "phazon"

/datum/aq_mecha_skin/honkzon
	name = "Honkzon"
	icon = 'aquila/icons/mecha/skins/honkzon.dmi'
	base_state = "honker"

/datum/aq_mecha_skin/cluwne
	name = "H.O.N.K. Cluwne"
	icon = 'aquila/icons/mecha/skins/cluwne.dmi'
	base_state = "honker"

/datum/aq_mecha_skin/big_bess
	name = "APLU Big Bess"
	icon = 'aquila/icons/mecha/skins/big_bess.dmi'
	base_state = "ripley"

/datum/aq_mecha_skin/cargo_ripley
	name = "APLU Cargo Ripley"
	icon = 'aquila/icons/mecha/skins/cargo_ripley.dmi'
	base_state = "ripley"
	pixel_x = -8

/datum/aq_mecha_skin/power_loader
	name = "Ładowarka RPL-Y"
	icon = 'aquila/icons/mecha/skins/power_loader.dmi'
	base_state = "ripley"

/datum/aq_mecha_skin/carrion_crawler
	name = "Carrion Crawler"
	icon = 'aquila/icons/mecha/skins/carrion_crawler.dmi'
	base_state = "clarke"
	pixel_x = -8

/datum/aq_mecha_skin/exploration
	name = "Mech eksploracyjny"
	icon = 'aquila/icons/mecha/skins/exploration.dmi'
	base_state = "clarke"
	pixel_x = -8

GLOBAL_LIST_INIT(aq_mecha_skins, init_aq_mecha_skins())

/proc/init_aq_mecha_skins()
	. = list()
	for(var/path in subtypesof(/datum/aq_mecha_skin))
		. += new path

/obj/mecha
	/// Podwozie antagonistów (tylko skiny antagowe)
	var/aq_antag_chassis = FALSE
	/// Nałożony skin
	var/datum/aq_mecha_skin/aq_skin

/obj/mecha/combat/gygax/dark
	aq_antag_chassis = TRUE

/obj/mecha/combat/honker/dark
	aq_antag_chassis = TRUE

/obj/mecha/combat/marauder/mauler
	aq_antag_chassis = TRUE

/obj/mecha/working/ripley/deathripley
	aq_antag_chassis = TRUE

/obj/mecha/proc/aq_available_skins()
	. = list()
	for(var/datum/aq_mecha_skin/S as anything in GLOB.aq_mecha_skins)
		if(S.fits(src))
			. += S

/obj/mecha/proc/aq_apply_skin(datum/aq_mecha_skin/S)
	aq_skin = S
	if(S)
		icon = S.icon
		pixel_x = S.pixel_x
	else
		icon = initial(icon)
		pixel_x = initial(pixel_x)
	update_icon()

/// Menu kołowe ze skinami dla budującego
/obj/mecha/proc/aq_offer_skin(mob/user)
	var/list/skins = aq_available_skins()
	if(!length(skins) || !user?.client)
		return
	var/list/choices = list("Standardowy" = image(icon = initial(icon), icon_state = initial(icon_state) + "-open"))
	var/list/by_name = list()
	for(var/datum/aq_mecha_skin/S as anything in skins)
		choices[S.name] = image(icon = S.icon, icon_state = initial(icon_state) + "-open")
		by_name[S.name] = S
	var/choice = show_radial_menu(user, src, choices, require_near = TRUE, tooltips = TRUE)
	if(!choice || QDELETED(src))
		return
	aq_apply_skin(by_name[choice])
	if(by_name[choice])
		to_chat(user, "<span class='notice'>Malujesz [src] w barwy: [choice].</span>")

/// Kto skończył budowę (ustawiane na czas spawn_result, czytane w CheckParts)
GLOBAL_DATUM(aq_mecha_builder, /mob)

/datum/component/construction/mecha
	/// Ostatni, kto wykonał krok budowy
	var/mob/aq_last_user

/datum/component/construction/mecha/check_step(obj/item/I, mob/living/user)
	aq_last_user = user
	return ..()

/datum/component/construction/mecha/spawn_result()
	GLOB.aq_mecha_builder = aq_last_user
	. = ..()
	GLOB.aq_mecha_builder = null

/datum/component/construction/mecha/Destroy()
	aq_last_user = null
	return ..()

/obj/mecha/CheckParts(list/parts_list)
	. = ..()
	var/mob/builder = GLOB.aq_mecha_builder
	if(builder)
		INVOKE_ASYNC(src, PROC_REF(aq_offer_skin), builder)

/// Wrak dostaje skin mecha (zmienna ustawiana na czas obj_destruction)
GLOBAL_VAR(aq_wreck_skin_icon)

/obj/mecha/obj_destruction(damage_flag)
	if(aq_skin)
		GLOB.aq_wreck_skin_icon = aq_skin.icon
	. = ..()
	GLOB.aq_wreck_skin_icon = null

/obj/structure/mecha_wreckage/Initialize(mapload, mob/living/silicon/ai/AI_pilot)
	. = ..()
	if(GLOB.aq_wreck_skin_icon)
		icon = GLOB.aq_wreck_skin_icon

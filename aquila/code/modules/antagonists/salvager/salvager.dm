// Złomiarze: port mechaniki salvagerów z Goonstation (kod pisany od nowa według ich działania, sprite'y Goona
// w aquila/icons/goonstation/ na CC BY-NC-SA 3.0). Nie żądają okupu i nie porywają ludzi: rozbierają okręt
// reklamatorem i sprzedają złom w terminalu S.R.O.K.A. na swoim statku. Każdy złomiarz zbiera własne punkty
// i wydaje je w tym samym terminalu na sprzęt. Na okręt lecą kapsułami desantowymi, wracają teleporterem ręcznym.

/// Ile punktów złomu musi zebrać cała załoga złomiarzy
#define SALVAGER_TARGET_POINTS 15000

/datum/antagonist/pirate/salvager
	name = "Złomiarz"
	roundend_category = "złomiarze"
	antagpanel_category = "Salvager"
	/// Punkty do wydania w terminalu S.R.O.K.A.
	var/salvager_points = 0
	/// Wszystkie zarobione punkty (cel drużyny i podsumowanie rundy)
	var/salvager_points_earned = 0
	ui_name = "AntagInfoSalvager"

/datum/antagonist/pirate/salvager/greet()
	to_chat(owner, "<span class='boldannounce'>Jesteś złomiarzem!</span>")
	to_chat(owner, "<B>Okręt w pobliżu jest pełen maszyn, które ktoś musi rozebrać. Wybierz miejsce lądowania w konsoli kapsuł desantowych, rozbieraj okręt reklamatorem i wracaj teleporterem ręcznym. Złom sprzedawaj w terminalu S.R.O.K.A. i kupuj w nim sprzęt. Nie jesteście mordercami: walczcie, gdy musicie, ale zysk jest w złomie.</B>")
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Złomiarz",
		"Rozbieraj okręt reklamatorem, sprzedawaj złom w terminalu S.R.O.K.A. i kupuj w nim sprzęt.")

/datum/antagonist/pirate/salvager/create_team(datum/team/pirate/salvager/new_team)
	if(istype(new_team))
		crew = new_team
		return
	for(var/datum/antagonist/pirate/salvager/S in GLOB.antagonists)
		if(S.owner && S.crew)
			crew = S.crew
			return
	crew = new /datum/team/pirate/salvager
	crew.forge_objectives()

/// Dopisuje punkty za sprzedany złom
/datum/antagonist/pirate/salvager/proc/add_salvage_points(amount)
	if(amount <= 0)
		return
	salvager_points += amount
	salvager_points_earned += amount

// Okno roli: punkty zmieniają się w trakcie rundy, więc są w ui_data z autoodświeżaniem (jak w oknie gangu)
/datum/antagonist/pirate/salvager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, ui_name, name)
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/antagonist/pirate/salvager/ui_data(mob/user)
	var/list/data = list()
	data["points"] = salvager_points
	data["earned"] = salvager_points_earned
	var/datum/team/pirate/salvager/team = crew
	var/datum/objective/salvage_points/goal = istype(team) ? (locate() in team.objectives) : null
	data["crew_points"] = istype(team) ? team.total_points() : salvager_points_earned
	data["goal"] = goal?.target_amount || SALVAGER_TARGET_POINTS
	var/list/members = list()
	if(istype(team))
		for(var/datum/mind/M in team.members)
			var/datum/antagonist/pirate/salvager/S = M.has_antag_datum(/datum/antagonist/pirate/salvager)
			members += list(list(
				"name" = M.name,
				"earned" = S?.salvager_points_earned || 0,
				"alive" = considered_alive(M),
				"you" = M == owner,
			))
	data["crew"] = members
	return data

/proc/get_salvager_datum(mob/user)
	return user?.mind?.has_antag_datum(/datum/antagonist/pirate/salvager)

/// Własna preferencja roli: antagoniści są u nas opt-in, a złomiarze nie powinni wymagać włączonych piratów
/datum/role_preference/midround_ghost/salvager
	name = "Złomiarz"
	antag_datum = /datum/antagonist/pirate/salvager

/datum/team/pirate/salvager
	name = "Załoga złomiarzy"

/datum/team/pirate/salvager/forge_objectives()
	var/datum/objective/salvage_points/salvage = new
	salvage.team = src
	salvage.update_explanation_text()
	objectives += salvage
	for(var/datum/mind/M in members)
		var/datum/antagonist/pirate/P = M.has_antag_datum(/datum/antagonist/pirate)
		if(P)
			P.objectives |= objectives

/// Wszystkie punkty zarobione przez załogę
/datum/team/pirate/salvager/proc/total_points()
	. = 0
	for(var/datum/mind/M in members)
		var/datum/antagonist/pirate/salvager/S = M.has_antag_datum(/datum/antagonist/pirate/salvager)
		if(S)
			. += S.salvager_points_earned

/datum/team/pirate/salvager/roundend_report()
	var/list/parts = list()
	parts += "<span class='header'>Złomiarze:</span>"
	var/all_dead = TRUE
	for(var/datum/mind/M in members)
		if(considered_alive(M))
			all_dead = FALSE
		var/datum/antagonist/pirate/salvager/S = M.has_antag_datum(/datum/antagonist/pirate/salvager)
		parts += "[printplayer(M)]: złom za [S?.salvager_points_earned || 0] pkt"
	var/datum/objective/salvage_points/goal = locate() in objectives
	parts += "Razem: [total_points()]/[goal?.target_amount || SALVAGER_TARGET_POINTS] pkt"
	if(goal?.check_completion() && !all_dead)
		parts += "<span class='greentext big'>Złomiarze odnieśli sukces!</span>"
	else
		parts += "<span class='redtext big'>Złomiarze ponieśli porażkę.</span>"
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/objective/salvage_points
	explanation_text = "Rozbierzcie okręt i sprzedajcie złom."
	target_amount = SALVAGER_TARGET_POINTS

/datum/objective/salvage_points/update_explanation_text()
	explanation_text = "Sprzedajcie w terminalu S.R.O.K.A. złom za [target_amount] punktów (razem cała załoga)."

/datum/objective/salvage_points/check_completion()
	var/datum/team/pirate/salvager/crew = team
	return ..() || (istype(crew) && crew.total_points() >= target_amount)

///////////////////
// Załoga: losowy wygląd, ubranie pasażera na gapę i sprzęt złomiarza (jak w Goonie)
///////////////////

/obj/effect/mob_spawn/human/pirate/salvager
	name = "kriosleeper złomiarza"
	desc = "Kriosleeper oklejony taśmą i zapachem smaru."
	mob_name = "złomiarz"
	mob_species = /datum/species/human
	outfit = /datum/outfit/salvager
	short_desc = "Jesteś złomiarzem."
	flavour_text = "Wasza S.R.O.K.A. trzyma się kursu okrętu. Rozbierajcie jego maszyny i sprzedawajcie złom. Zabijanie załogi nie jest celem."
	assignedrole = "Salvager"
	rank = "Złomiarz"

/obj/effect/mob_spawn/human/pirate/salvager/special(mob/living/new_spawn)
	new_spawn.fully_replace_character_name(new_spawn.real_name, "[rank] [pick(GLOB.last_names_male)]")
	new_spawn.mind.add_antag_datum(/datum/antagonist/pirate/salvager)

/obj/effect/mob_spawn/human/pirate/salvager/captain
	rank = "Brygadzista"

/datum/outfit/salvager
	name = "Złomiarz"
	uniform = /obj/item/clothing/under/color/grey
	suit = /obj/item/clothing/suit/jacket
	mask = /obj/item/clothing/mask/gas
	gloves = /obj/item/clothing/gloves/color/yellow
	glasses = /obj/item/clothing/glasses/salvager
	shoes = /obj/item/clothing/shoes/magboots
	ears = /obj/item/radio/headset/syndicate/alt
	id = /obj/item/card/id/pirate
	back = /obj/item/storage/backpack/salvager
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double
	l_pocket = /obj/item/salvager_hand_tele
	backpack_contents = list(
		/obj/item/storage/box/salvager_frame_compartment = 1,
		/obj/item/clothing/head/helmet/space/eva = 1,
		/obj/item/clothing/suit/space/eva = 1,
		/obj/item/salvage_reclaimer = 1,
		/obj/item/storage/belt/utility/full = 1,
		/obj/item/weldingtool = 1,
	)

// Ubranie pasażera na gapę jest losowe, jak w Goonie
/datum/outfit/salvager/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	uniform = pick(/obj/item/clothing/under/color/grey, /obj/item/clothing/under/color/brown, /obj/item/clothing/under/color/darkblue, /obj/item/clothing/under/rank/cargo/tech)
	suit = pick(/obj/item/clothing/suit/jacket, /obj/item/clothing/suit/jacket/leather, /obj/item/clothing/suit/hazardvest)

/datum/outfit/salvager/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	H.faction |= "pirate"

#undef SALVAGER_TARGET_POINTS

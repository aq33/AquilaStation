// Złomiarze: wariant kosmicznych piratów wzorowany na salvagerach z Goonstation (kod pisany od nowa według opisu mechaniki).
// Nie żądają okupu i nie porywają ludzi: rozbierają okręt reklamatorem i sprzedają złom przez platformę na swoim statku.
// Statek pojawia się w pustej przestrzeni, dociera do okrętu promem albo teleporterem do własnego nadajnika.

/// Ile kredytów złomu musi zebrać załoga złomiarzy
#define SALVAGER_TARGET_VALUE 15000

/datum/antagonist/pirate/salvager
	name = "Złomiarz"
	roundend_category = "złomiarze"
	antagpanel_category = "Salvager"

/datum/antagonist/pirate/salvager/greet()
	to_chat(owner, "<span class='boldannounce'>Jesteś złomiarzem!</span>")
	to_chat(owner, "<B>Okręt w pobliżu jest pełen maszyn, które ktoś musi rozebrać. Postaw nadajnik na pokładzie, teleportuj się, rozbieraj maszyny reklamatorem i sprzedawaj złom na platformie statku. Nie jesteście mordercami: walczcie, gdy musicie, ale zysk jest w złomie.</B>")
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Złomiarz",
		"Rozbieraj maszyny okrętu reklamatorem i sprzedawaj złom na platformie swojego statku.")

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

/datum/team/pirate/salvager
	name = "Załoga złomiarzy"

/datum/team/pirate/salvager/forge_objectives()
	var/datum/objective/loot/salvage/salvage = new
	salvage.team = src
	for(var/obj/machinery/computer/piratepad_control/salvage/P in GLOB.machines)
		salvage.cargo_hold = P
		break
	salvage.update_explanation_text()
	objectives += salvage
	for(var/datum/mind/M in members)
		var/datum/antagonist/pirate/P = M.has_antag_datum(/datum/antagonist/pirate)
		if(P)
			P.objectives |= objectives

/datum/team/pirate/salvager/roundend_report()
	var/list/parts = list()
	parts += "<span class='header'>Złomiarze:</span>"
	var/all_dead = TRUE
	for(var/datum/mind/M in members)
		if(considered_alive(M))
			all_dead = FALSE
	parts += printplayerlist(members)
	var/datum/objective/loot/salvage/S = locate() in objectives
	if(S)
		parts += "Sprzedany złom: [S.get_loot_value()]/[S.target_value] kredytów"
	if(S?.check_completion() && !all_dead)
		parts += "<span class='greentext big'>Złomiarze odnieśli sukces!</span>"
	else
		parts += "<span class='redtext big'>Złomiarze ponieśli porażkę.</span>"
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/objective/loot/salvage
	explanation_text = "Rozbierzcie maszyny okrętu i sprzedajcie złom."
	target_value = SALVAGER_TARGET_VALUE

/datum/objective/loot/salvage/update_explanation_text()
	explanation_text = "Sprzedajcie na platformie swojego statku złom wart [target_value] kredytów."

///////////////////
// Załoga
///////////////////

/obj/effect/mob_spawn/human/pirate/salvager
	name = "sleeper złomiarza"
	desc = "Kriosleeper oklejony taśmą i zapachem smaru."
	mob_name = "złomiarz"
	mob_species = /datum/species/human
	outfit = /datum/outfit/salvager
	short_desc = "Jesteś złomiarzem."
	flavour_text = "Wasz statek trzyma się kursu okrętu. Rozbierajcie jego maszyny i sprzedawajcie złom. Zabijanie załogi nie jest celem."
	assignedrole = "Salvager"
	rank = "Złomiarz"

/obj/effect/mob_spawn/human/pirate/salvager/special(mob/living/new_spawn)
	new_spawn.fully_replace_character_name(new_spawn.real_name, "[rank] [pick(GLOB.last_names_male)]")
	new_spawn.mind.add_antag_datum(/datum/antagonist/pirate/salvager)

/obj/effect/mob_spawn/human/pirate/salvager/captain
	rank = "Brygadzista"
	outfit = /datum/outfit/salvager/captain

/datum/outfit/salvager
	name = "Złomiarz"
	uniform = /obj/item/clothing/under/rank/cargo/miner
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/color/yellow
	belt = /obj/item/storage/belt/utility/full
	glasses = /obj/item/clothing/glasses/meson
	ears = /obj/item/radio/headset/syndicate/alt
	id = /obj/item/card/id/pirate
	back = /obj/item/storage/backpack/industrial
	r_pocket = /obj/item/salvage_beacon
	backpack_contents = list(
		/obj/item/salvage_reclaimer = 1,
		/obj/item/storage/box/survival = 1,
	)

/datum/outfit/salvager/captain
	name = "Złomiarz - brygadzista"
	ears = /obj/item/radio/headset/syndicate/alt/leader
	backpack_contents = list(
		/obj/item/salvage_reclaimer = 1,
		/obj/item/storage/box/survival = 1,
		/obj/item/salvage_beacon = 1,
	)

/datum/outfit/salvager/post_equip(mob/living/carbon/human/H)
	H.faction |= "pirate"

#undef SALVAGER_TARGET_VALUE

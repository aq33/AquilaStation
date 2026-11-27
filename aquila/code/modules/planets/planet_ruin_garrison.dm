// AQUILA - obsada ruin na planecie zależna od frakcji, która trzyma układ. Ruiny mają ludzi wpisanych na sztywno w mapę
// (piraci, Syndykat, Rosjanie, ochrona NT). Po wczytaniu ruiny w układzie Syndykatu, piratów albo bloku NT ludzie z mapy
// zamieniają się (z szansą PLANET_GARRISON_CHANCE, cała ruina naraz) na żołnierzy tej frakcji z tym samym rodzajem
// broni (wręcz, broń krótka, pistolet maszynowy, strzelba) i w wersji próżniowej, jeśli oryginał jej potrzebował.
// Frakcja bez danej broni daje najbliższą broń dystansową: piraci mają tylko laser, ochrona NT nie ma strzelby
// (dostaje pistolet maszynowy). W układach NT, SolGov i WhiteRapids siedzi ochrona NT, która strzela dopiero zaatakowana.
// Układy niczyje i wrogie zostają z obsadą z mapy, fauna i automaty zawsze zostają.

/// Szansa, że ruina w układzie frakcji jest obsadzona przez tę frakcję (reszta zostaje dzikimi lokatorami z mapy)
#define PLANET_GARRISON_CHANCE 75

/datum/planet_surface/load_ruin(datum/map_template/ruin/ruin, turf/where, centered)
	. = ..()
	if(.)
		planet_garrison_ruin(ruin.get_affected_turfs(where, centered), planet?.current_system?.owner, PLANET_GARRISON_CHANCE, "[planet] [ruin.name]")

/// Rola żołnierza z mapy: "melee", "ranged", "smg" albo "shotgun"
/proc/planet_garrison_role(mob/living/basic/trooper/trooper)
	var/path = "[trooper.type]"
	if(findtext(path, "/shotgun") || findtext(path, "/trooper/russian/ranged/trooper"))
		return "shotgun"
	if(findtext(path, "/smg"))
		return "smg"
	if(findtext(path, "/ranged"))
		return "ranged"
	return "melee"

/// Typ żołnierza frakcji na miejsce danego (null: zostaje oryginał)
/proc/planet_garrison_type(mob/living/basic/trooper/trooper, owner)
	var/space = !initial(trooper.unsuitable_atmos_damage)
	var/role = planet_garrison_role(trooper)
	var/list/table
	switch(owner)
		if("syndicate")
			table = space ? list(
				"melee" = /mob/living/basic/trooper/syndicate/melee/space,
				"ranged" = /mob/living/basic/trooper/syndicate/ranged/space,
				"smg" = /mob/living/basic/trooper/syndicate/ranged/smg/space,
				"shotgun" = /mob/living/basic/trooper/syndicate/ranged/shotgun/space,
			) : list(
				"melee" = /mob/living/basic/trooper/syndicate/melee,
				"ranged" = /mob/living/basic/trooper/syndicate/ranged,
				"smg" = /mob/living/basic/trooper/syndicate/ranged/smg,
				"shotgun" = /mob/living/basic/trooper/syndicate/ranged/shotgun,
			)
		if("pirate")
			// Piraci strzelają tylko z lasera (nie ma pirackich sprite'ów z inną bronią)
			table = space ? list(
				"melee" = /mob/living/basic/trooper/pirate/melee/space,
				"ranged" = /mob/living/basic/trooper/pirate/ranged/space,
				"smg" = /mob/living/basic/trooper/pirate/ranged/space,
				"shotgun" = /mob/living/basic/trooper/pirate/ranged/space,
			) : list(
				"melee" = /mob/living/basic/trooper/pirate/melee,
				"ranged" = /mob/living/basic/trooper/pirate/ranged,
				"smg" = /mob/living/basic/trooper/pirate/ranged,
				"shotgun" = /mob/living/basic/trooper/pirate/ranged,
			)
		if("nanotrasen", "solgov", "whiterapids")
			if(space) // ochrona NT nie ma skafandrów
				return null
			table = list(
				"melee" = /mob/living/basic/trooper/nanotrasen/peaceful,
				"ranged" = /mob/living/basic/trooper/nanotrasen/ranged/peaceful,
				"smg" = /mob/living/basic/trooper/nanotrasen/ranged/smg/peaceful,
				"shotgun" = /mob/living/basic/trooper/nanotrasen/ranged/smg/peaceful, // ochrona NT nie ma strzelby
			)
	if(!table)
		return null
	var/new_type = table[role]
	if(!new_type || istype(trooper, new_type))
		return null
	return new_type

/// Zamienia ludzi z mapy ruiny na żołnierzy frakcji układu. Zwraca liczbę podmienionych.
/proc/planet_garrison_ruin(list/turfs, owner, chance, log_name)
	. = 0
	if(!owner || !prob(chance))
		return
	for(var/turf/T as anything in turfs)
		for(var/mob/living/basic/trooper/trooper in T)
			if(trooper.stat == DEAD || trooper.client || trooper.mind)
				continue
			var/new_type = planet_garrison_type(trooper, owner)
			if(!new_type)
				continue
			var/mob/living/basic/trooper/replacement = new new_type(T)
			replacement.setDir(trooper.dir)
			qdel(trooper)
			.++
	if(.)
		log_game("Planet ruin [log_name] garrison: [.] troopers replaced for [owner]")

#undef PLANET_GARRISON_CHANCE

// Mapa taktyczna drużyn w oknach TGUI (pager i konsola XO). Podkład to plan poziomu (ściany, podłogi, korytarze,
// drzwi, okna i obszary) wysyłany jako JSON i rysowany przez okno z siatką sektorów; generowany na żądanie także
// dla poziomów spoza okrętu: wrogich okrętów, map abordażu, stacji z misji. Kropki członków i znaczniki rysuje okno.

/// Poziom -> nazwa assetu JSON z planem poziomu
GLOBAL_LIST_EMPTY(squad_map_assets)
/// Poziom -> list(origin_x, origin_y, width, height): wycinek poziomu, na którym coś jest
GLOBAL_LIST_EMPTY(squad_map_bounds)
/// Poziom -> world.time wygenerowania (mapy spoza okrętu odświeżamy, bo poziom bywa używany ponownie)
GLOBAL_LIST_EMPTY(squad_map_generated_at)
/// Poziomy w trakcie generowania
GLOBAL_LIST_EMPTY(squad_map_generating)

#define SQUAD_MAP_REFRESH_TIME (10 MINUTES)
/// Margines wokół zabudowy na wyciętej mapie (w polach)
#define SQUAD_MAP_MARGIN 4
/// Bok sektora siatki mapy taktycznej (w polach); okno liczy sektory tak samo (SquadTacticalMap.tsx)
#define SQUAD_MAP_SECTOR 10

/// Nazwa assetu mapy poziomu albo null, gdy dopiero się generuje (wtedy zleca generowanie)
/proc/aq_squad_map_asset(z)
	if(!isnum(z) || z < 1 || z > world.maxz)
		return null
	var/key = "[z]"
	var/asset_name = GLOB.squad_map_assets[key]
	var/is_station = is_station_level(z)
	if(asset_name && (is_station || world.time - GLOB.squad_map_generated_at[key] < SQUAD_MAP_REFRESH_TIME))
		return asset_name
	if(!GLOB.squad_map_generating[key])
		GLOB.squad_map_generating[key] = TRUE
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(aq_generate_squad_map), z)
	return asset_name

/// Rodzaj pola na planie pokładu (znak w napisie "tiles"; okno rysuje go swoim kolorem)
/proc/aq_squad_map_tile(turf/tile)
	if(!tile || isspaceturf(tile) || istype(tile, /turf/open/openspace))
		return "."
	if(isclosedturf(tile))
		return "w"
	if(locate(/obj/machinery/door) in tile)
		return "d"
	if((locate(/obj/structure/window) in tile) || (locate(/obj/structure/grille) in tile))
		return "g"
	if(istype(tile.loc, /area/hallway))
		return "c"
	return "f"

/// Plan pokładu zapisany jako asset JSON dla okien
/proc/aq_generate_squad_map(z)
	var/key = "[z]"
	var/list/layout = aq_build_squad_map_layout(z)
	var/asset_name = "aq_squadmap_[z]_[world.time].json"
	var/file_name = "data/aq_squadmap/[asset_name]"
	fdel(file_name)
	text2file(json_encode(layout), file_name)
	SSassets.transport.register_asset(asset_name, fcopy_rsc(file_name))
	fdel(file_name)
	GLOB.squad_map_bounds[key] = list(layout["origin_x"], layout["origin_y"], layout["width"], layout["height"])
	GLOB.squad_map_assets[key] = asset_name
	GLOB.squad_map_generated_at[key] = world.time
	GLOB.squad_map_generating -= key

/// Plan poziomu: prostokąt z zabudową (bez pustego kosmosu), rodzaje pól i obszary
/proc/aq_build_squad_map_layout(z)
	var/min_x = world.maxx
	var/min_y = world.maxy
	var/max_x = 1
	var/max_y = 1
	for(var/x in 1 to world.maxx)
		for(var/y in 1 to world.maxy)
			var/turf/tile = locate(x, y, z)
			if(!tile || isspaceturf(tile) || istype(tile, /turf/open/openspace))
				continue
			min_x = min(min_x, x)
			min_y = min(min_y, y)
			max_x = max(max_x, x)
			max_y = max(max_y, y)
		CHECK_TICK
	if(min_x > max_x)
		min_x = 1
		min_y = 1
		max_x = world.maxx
		max_y = world.maxy
	min_x = max(1, min_x - SQUAD_MAP_MARGIN)
	min_y = max(1, min_y - SQUAD_MAP_MARGIN)
	max_x = min(world.maxx, max_x + SQUAD_MAP_MARGIN)
	max_y = min(world.maxy, max_y + SQUAD_MAP_MARGIN)
	// Wiersze od góry (największe y), w wierszu od lewej; obszar pola to indeks w "areas" zapisany jednym
	// albo dwoma znakami ASCII (od "#", z pominięciem odwrotnego ukośnika), żeby plik był mały
	var/list/tile_rows = list()
	var/list/area_ids = list()
	var/list/area_names = list()
	var/list/area_cells = list()
	// kolor działu z holomapy (bez przezroczystości) i suma pozycji pól, z której okno liczy środek podpisu
	var/list/area_colours = list()
	var/list/area_sums = list()
	for(var/y in max_y to min_y step -1)
		var/list/row = list()
		for(var/x in min_x to max_x)
			var/turf/tile = locate(x, y, z)
			var/tile_char = aq_squad_map_tile(tile)
			row += tile_char
			var/area/tile_area = tile?.loc
			if(tile_char == "." || !tile_area || istype(tile_area, /area/space))
				area_cells += 0
				continue
			if(!area_ids[tile_area])
				area_names += format_text(tile_area.name)
				area_ids[tile_area] = length(area_names)
				area_colours += tile_area.holomap_color ? lowertext(copytext(tile_area.holomap_color, 1, 8)) : null
				area_sums += list(list(0, 0, 0))
			var/area_index = area_ids[tile_area]
			area_cells += area_index
			var/list/sums = area_sums[area_index]
			sums[1] += x - min_x
			sums[2] += max_y - y
			sums[3]++
		tile_rows += jointext(row, "")
		CHECK_TICK
	var/area_width = length(area_names) < 90 ? 1 : 2
	var/list/area_chars = list()
	for(var/cell in area_cells)
		area_chars += area_width == 1 ? aq_squad_map_code(cell) : "[aq_squad_map_code(round(cell / 90))][aq_squad_map_code(cell % 90)]"
	return list(
		"origin_x" = min_x,
		"origin_y" = min_y,
		"width" = max_x - min_x + 1,
		"height" = max_y - min_y + 1,
		"tiles" = jointext(tile_rows, ""),
		"areas" = area_names,
		"area_colours" = area_colours,
		"area_centres" = aq_squad_map_centres(area_sums),
		"area_width" = area_width,
		"area_grid" = jointext(area_chars, ""),
	)

/// Środki obszarów na planie: list(kolumna, wiersz, liczba pól) dla każdego obszaru
/proc/aq_squad_map_centres(list/area_sums)
	. = list()
	for(var/list/sums as anything in area_sums)
		. += list(list(round(sums[1] / sums[3]), round(sums[2] / sums[3]), sums[3]))

/// Liczba 0-89 jako jeden znak ASCII od "#" bez odwrotnego ukośnika (bezpieczny w JSON)
/proc/aq_squad_map_code(number)
	var/code = 35 + number
	if(code >= 92)
		code++
	return ascii2text(code)

/// Sektor siatki mapy taktycznej ("C2"): kolumny co 10 pól od lewej krawędzi planu, wiersze od góry
/proc/aq_squad_sector(turf/target)
	if(!target)
		return null
	var/list/bounds = GLOB.squad_map_bounds["[target.z]"]
	if(!bounds)
		aq_squad_map_asset(target.z) // plan jeszcze nie powstał: zlecamy, następny rozkaz będzie miał sektor
		return null
	var/column = round((target.x - bounds[1]) / SQUAD_MAP_SECTOR)
	var/row = round((bounds[2] + bounds[4] - 1 - target.y) / SQUAD_MAP_SECTOR)
	if(column < 0 || row < 0 || column > 25)
		return null
	return "[ascii2text(65 + column)][row + 1]"

/// Nazwa poziomu dla gracza
/proc/aq_squad_level_name(z)
	if(is_station_level(z))
		var/list/station_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
		return "Okręt, pokład [max(1, station_levels.Find(z))]"
	var/datum/space_level/level = SSmapping.z_list[z]
	return level?.name || "Poziom [z]"

/// Dane mapy dla okna: wybrany poziom, lista dostępnych, URL podkładu i przesunięcie współrzędnych
/proc/aq_squad_map_data(mob/user, selected_z, list/extra_levels)
	var/list/levels = list()
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		levels |= z
	var/turf/user_turf = get_turf(user)
	if(user_turf)
		levels |= user_turf.z
	for(var/z in extra_levels)
		levels |= z
	if(!selected_z || !(selected_z in levels))
		selected_z = user_turf ? user_turf.z : (length(levels) ? levels[1] : null)
	var/list/level_data = list()
	for(var/z in levels)
		level_data += list(list("z" = z, "name" = aq_squad_level_name(z)))
	var/asset_name = selected_z ? aq_squad_map_asset(selected_z) : null
	var/url = null
	if(asset_name && user?.client)
		SSassets.transport.send_assets(user.client, asset_name)
		url = SSassets.transport.get_asset_url(asset_name)
	var/list/bounds = selected_z ? GLOB.squad_map_bounds["[selected_z]"] : null
	return list(
		"z" = selected_z,
		"levels" = level_data,
		"url" = url,
		"origin_x" = bounds ? bounds[1] : 1,
		"origin_y" = bounds ? bounds[2] : 1,
		"width" = bounds ? bounds[3] : world.maxx,
		"height" = bounds ? bounds[4] : world.maxy,
		"user_x" = user_turf?.x,
		"user_y" = user_turf?.y,
		"user_z" = user_turf?.z,
	)

/// Glif CM dla funkcji (blipy mapy taktycznej z CM-SS13, CC BY-SA 3.0)
GLOBAL_LIST_INIT(squad_blip_glyphs, list(
	SQUAD_POSITION_LEADER = "leader",
	SQUAD_POSITION_MEDIC = "medic",
	SQUAD_POSITION_ENGINEER = "engi",
	SQUAD_POSITION_SOLDIER = "private",
))
/// Pamięć gotowych blipów: "kolor|funkcja|martwy" -> data URI
GLOBAL_LIST_EMPTY(squad_blip_cache)

/// Blip członka na mapę: tło w kolorze drużyny, glif funkcji, przy śmierci czerwony pasek
/proc/aq_squad_blip(colour, position, dead)
	var/key = "[colour]|[position]|[dead]"
	if(GLOB.squad_blip_cache[key])
		return GLOB.squad_blip_cache[key]
	var/icon/blip = icon('aquila/icons/squads/map_blips.dmi', "background")
	if(colour)
		blip.Blend(colour, ICON_MULTIPLY)
	blip.Blend(icon('aquila/icons/squads/map_blips.dmi', GLOB.squad_blip_glyphs[position] || "private"), ICON_OVERLAY)
	if(dead)
		blip.Blend(icon('aquila/icons/squads/map_blips.dmi', "undefibbable", frame = 1), ICON_OVERLAY)
	var/uri = "data:image/png;base64,[icon2base64(blip)]"
	GLOB.squad_blip_cache[key] = uri
	return uri

/// Stan członka drużyny (SQUAD_STATUS_*)
/mob/living/carbon/human/proc/aq_squad_status()
	if(stat == DEAD)
		return SQUAD_STATUS_DEAD
	if(!client)
		return SQUAD_STATUS_SSD
	if(stat != CONSCIOUS || health <= crit_threshold)
		return SQUAD_STATUS_CRITICAL
	if(health < maxHealth * 0.75)
		return SQUAD_STATUS_INJURED
	return SQUAD_STATUS_OK

/proc/squad_status_pl(status)
	switch(status)
		if(SQUAD_STATUS_OK)
			return "Sprawny"
		if(SQUAD_STATUS_INJURED)
			return "Ranny"
		if(SQUAD_STATUS_CRITICAL)
			return "Ciężko ranny"
		if(SQUAD_STATUS_DEAD)
			return "Martwy"
		if(SQUAD_STATUS_SSD)
			return "Bez kontaktu"
	return status

/// Czy kamera w pancerzu drużyny nadaje (pancerz musi być założony)
/mob/living/carbon/human/proc/aq_has_squad_bodycam()
	return istype(wear_suit, /obj/item/clothing/suit/ship/squad)

/datum/squad/proc/aq_member_data(mob/living/carbon/human/member)
	var/turf/member_turf = get_turf(member)
	var/area/member_area = get_area(member)
	var/status = member.aq_squad_status()
	var/position = member.get_squad_position()
	var/datum/squad_loan/loan = get_squad_loan(member)
	return list(
		"ref" = REF(member),
		"name" = member.real_name,
		"rank" = member.compose_rank(),
		"job" = member.mind?.assigned_role,
		"position" = position,
		"base_position" = member.squad_position,
		"position_name" = squad_position_pl(position),
		"leader" = (leader == member),
		"status" = status,
		"status_name" = squad_status_pl(status),
		"blip" = aq_squad_blip(colour, position, status == SQUAD_STATUS_DEAD),
		"health" = member.maxHealth ? round(max(member.health, 0) / member.maxHealth * 100) : 0,
		"pager" = member.aq_has_squad_pager(),
		"cam" = member.aq_has_squad_bodycam(),
		"kit" = loan?.kit_name,
		"missing" = loan ? loan.outstanding_names() : list(),
		"x" = member_turf?.x,
		"y" = member_turf?.y,
		"z" = member_turf?.z,
		"area" = member_area ? format_text(member_area.name) : null,
	)

/datum/squad/proc/aq_markers_data()
	. = list()
	for(var/marker_type in aq_markers)
		var/datum/aq_squad_marker/marker = aq_markers[marker_type]
		if(!marker.target_turf)
			continue
		var/area/marker_area = get_area(marker.target_turf)
		. += list(list(
			"type" = marker_type,
			"label" = squad_marker_pl(marker_type),
			"icon" = aq_squad_marker_icon(marker_type),
			"x" = marker.target_turf.x,
			"y" = marker.target_turf.y,
			"z" = marker.target_turf.z,
			"area" = marker_area ? format_text(marker_area.name) : null,
			"placer" = marker.placer_name,
			"time_left" = round(max(0, marker.expires_at - world.time) / 10),
		))

/datum/squad/proc/aq_squad_data(include_members = TRUE)
	var/list/members_data = list()
	if(include_members)
		for(var/mob/living/carbon/human/member as anything in members)
			members_data += list(aq_member_data(member))
	return list(
		"id" = REF(src),
		"name" = name,
		"colour" = colour,
		"role" = role,
		"role_name" = squad_role_pl(role),
		"desc" = desc,
		"secondary_objective" = secondary_objective,
		"access_enabled" = access_enabled,
		"weapons_clearance" = weapons_clearance,
		"hidden" = hidden,
		"heavy_armor" = aq_heavy_armor,
		"leader" = leader ? REF(leader) : null,
		"leader_name" = leader?.real_name,
		"members" = members_data,
		"markers" = aq_markers_data(),
	)

/// Poziomy, na których są członkowie i znaczniki drużyny (do wyboru na mapie)
/datum/squad/proc/aq_active_levels()
	. = list()
	for(var/mob/living/carbon/human/member as anything in members)
		var/turf/member_turf = get_turf(member)
		if(member_turf)
			. |= member_turf.z
	for(var/marker_type in aq_markers)
		var/datum/aq_squad_marker/marker = aq_markers[marker_type]
		if(marker.target_turf)
			. |= marker.target_turf.z

/// Obrazek znacznika (TGMC) do mapy w oknie
GLOBAL_LIST_EMPTY(squad_marker_icon_cache)

/proc/aq_squad_marker_icon(marker_type)
	if(!GLOB.squad_marker_icon_cache[marker_type])
		var/icon/marker_icon = icon('aquila/icons/squads/markers.dmi', "marker_[marker_type]", SOUTH, 1)
		GLOB.squad_marker_icon_cache[marker_type] = "data:image/png;base64,[icon2base64(marker_icon)]"
	return GLOB.squad_marker_icon_cache[marker_type]

/proc/aq_marker_types_data()
	. = list()
	for(var/marker_type in SQUAD_MARKER_TYPES)
		. += list(list("type" = marker_type, "label" = squad_marker_pl(marker_type)))

/// Stawia znacznik z kliknięcia na mapie; sprawdza współrzędne
/datum/squad/proc/aq_place_marker_from_map(mob/living/placer, list/params, from_console)
	var/x = text2num(params["x"])
	var/y = text2num(params["y"])
	var/z = text2num(params["z"])
	if(!isnum(x) || !isnum(y) || !isnum(z) || z < 1 || z > world.maxz)
		return FALSE
	var/turf/target_turf = locate(clamp(x, 1, world.maxx), clamp(y, 1, world.maxy), z)
	if(!target_turf)
		return FALSE
	return !!aq_place_marker(placer, target_turf, params["marker"], from_console)

#undef SQUAD_MAP_REFRESH_TIME
#undef SQUAD_MAP_MARGIN
#undef SQUAD_MAP_SECTOR

// aq33/AquilaStation#651 - bossowie SSV Fist of Sol i SGV Alicorn jako nemezis wojny na mapie hex (war_nemesis.dm)

/datum/test_chamber_kit/pr_651
	name = "Nemezis: Fist of Sol i Alicorn"
	pr = "aq33/AquilaStation#651"
	description = "Zestaw stawia obu bossów z ich stałymi dowódcami dwa kafle od okrętu (normalnie stoją w Romulusie i Veneto). Napęd naładuj zestawem mapy FTL. Testuj na konsoli nawigacji na mostku. \
		1) Romb bossa ma w nazwie dowódcę: SSV Fist of Sol (Admirał Lucan „Młot Sol” Draven), SGV Alicorn (Admirał Seraphine „Miliard” Vael). \
		2) Skocz do bossa: zakładka „Dowódcy” pokazuje go z dopiskiem „Nemezis” i jego cechami. Alicorn leci sam (bez niszczyciela Syndykatu), maskuje się i wypuszcza myśliwce Rattlesnake. \
		3) Zniszcz bossa: dowódca ucieka (ranny, wróci) albo ginie. Ranny po 15–25 min wraca z odbudowanym okrętem do swojego układu (Romulus albo Veneto) i jest ogłoszenie wywiadu, z zemstą, jeśli pokonał go okręt. \
		4) Poległy nemezis nie wraca do końca kampanii, a ranny wraca też po restarcie rundy. Floty bossów nie są pod sztabem: nie ruszają się z układu."

/datum/test_chamber_kit/pr_651/setup(list/spawned, list/turfs, turf/center, mob/user)
	if(!user || !GLOB.hex_war)
		return
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	var/datum/hex/here = main?.current_hex()
	if(!here)
		return
	var/list/spots = list()
	for(var/datum/hex/H as anything in GLOB.hexmap.hexes_in_range(here, 2))
		if(GLOB.hexmap.distance(here, H) == 2 && !H.system && !GLOB.hexmap.blocks(H))
			spots += H
	for(var/id in GLOB.hex_nemeses)
		if(!length(spots))
			break
		var/datum/hex/spot = spots[1]
		spots -= spot
		var/datum/hex_commander/C = GLOB.hex_war.nemesis_commander(id)
		var/datum/fleet/F = GLOB.hexmap.system_for(spot).spawn_fleet(GLOB.hex_nemeses[id]["fleet"])
		if(!F)
			continue
		C.status = HEX_CMD_ACTIVE
		C.take_fleet(F)
		to_chat(user, "<span class='notice'>Flota [F.name] stoi dwa kafle od okrętu.</span>")

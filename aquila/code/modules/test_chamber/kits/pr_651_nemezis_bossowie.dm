// aq33/AquilaStation#651 - bossowie SSV Fist of Sol, SGV Alicorn i Komitet Powitalny Dolos jako nemezis wojny na mapie hex (war_nemesis.dm)

/datum/test_chamber_kit/pr_651
	name = "Nemezis: Fist of Sol, Alicorn i Komitet Powitalny Dolos"
	pr = "aq33/AquilaStation#651"
	description = "Zestaw stawia trzech bossów z ich stałymi dowódcami dwa kafle od okrętu (normalnie stoją w Romulusie, Veneto i Dolos Remnants; zestaw zabiera ich stamtąd, a powtórzony usuwa poprzednią kopię). Napęd naładuj zestawem mapy FTL. Testuj na konsoli nawigacji na mostku. 		1) Romb bossa ma w nazwie dowódcę: SSV Fist of Sol (Admirał Lucan „Młot Sol” Draven), SGV Alicorn (Admirał Seraphine „Miliard” Vael), Komitet Powitalny Dolos (Admirał Silas „Grabarz” Kertesz, 8 okrętów). 		2) Skocz do bossa: zakładka „Dowódcy” pokazuje go z dopiskiem „Nemezis” i jego cechami. Alicorn leci sam (bez niszczyciela Syndykatu), maskuje się i wypuszcza myśliwce Rattlesnake. 		3) Zniszcz bossa: dowódca ucieka (ranny, wróci) albo ginie. Ranny po 15–25 min wraca z odbudowanym okrętem do swojego układu (Romulus, Veneto albo Dolos Remnants) i jest ogłoszenie wywiadu, z zemstą, jeśli pokonał go okręt. 		4) Poległy nemezis nie wraca do końca kampanii, a ranny wraca też po restarcie rundy. Fist of Sol i Alicorn nie są pod sztabem i nie ruszają się z układu. 		5) Pościg Komitetu: skocz na kafel obok niego albo przeleć przez taki kafel. Wywiad ogłasza pościg, a flota co 1–3 min idzie kafel za okrętem (także na kafel, na którym okręt stoi). Po 4 skokach, po ucieczce bramą do innego sektora albo gdy okręt zniknie, przerywa pościg (ogłoszenie) i wraca do Dolos Remnants, a tam znowu czeka. W czasie walki z okrętem w jednym kafelku nie odlatuje. 		6) W Oasis Fidei nie ma już floty Pozostałość. W trybie trudnym (Szturm na Dolos) celem w Dolos Remnants jest Komitet: nie poluje, a pod nieobecność rannego albo poległego dowódcy w Dolos stoi jego flota bez dowódcy."

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
		// Boss z układu (albo z poprzedniego użycia zestawu) znika: jeden dowódca dowodzi jedną flotą
		var/datum/fleet/old = C.fleet
		if(old && !QDELETED(old))
			old.commander = null
			old.hex_war_dispose()
		var/datum/fleet/F = GLOB.hexmap.system_for(spot).spawn_fleet(GLOB.hex_nemeses[id]["fleet"])
		if(!F)
			continue
		C.status = HEX_CMD_ACTIVE
		C.take_fleet(F)
		to_chat(user, "<span class='notice'>Flota [F.name] stoi dwa kafle od okrętu.</span>")

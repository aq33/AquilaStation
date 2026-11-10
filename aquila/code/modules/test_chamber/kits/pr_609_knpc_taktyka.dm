// aq33/AquilaStation#609 - taktyka boarderów KNPC

/datum/test_chamber_kit/pr_609
	name = "PR 609: taktyka boarderów KNPC - walka"
	pr = "aq33/AquilaStation#609"
	description = "Dwóch syndykatów z pistoletami: każdy ma w plecaku granat hukowy i zaawansowane okulary, jeden ma też w kieszeni granat odłamkowy. Wyjdź z aghosta jako człowiek z bronią (albo zespawnuj sobie ciało) i walcz z nimi. \
	1) Podejdź na 1-2 pola do uzbrojonego syndykata → oczekiwane: cofa się na 3+ pola i strzela, a nie idzie na ciebie; czasem robi unik w bok. \
	2) Stań 3-7 pól od nich przy drugim celu (zwykłym człowieku obok) → oczekiwane: rzucają hukowy („Hukowy!”) i sami nie padają od błysku; odłamkowy leci tylko z 5+ pól i nigdy, gdy w promieniu 4 pól od ciebie stoi drugi syndykat (najwyżej jeden granat na 20 s na boardera). \
	3) Schowaj się za ścianą komory → oczekiwane: nie strzelają w ścianę, tylko idą tam, gdzie cię widzieli. \
	4) Strzel do dalszego syndykata, gdy bliżej stoi zwykły człowiek → oczekiwane: obaj biorą na cel ciebie (strzelającego), nie człowieka. \
	5) Wezwanie wsparcia: odpowiada najwyżej 3 najbliższych boarderów."
	items = list(
		/mob/living/carbon/human/ai_boarder/syndicate/pistol = 2,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_609/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	for(var/mob/living/carbon/human/ai_boarder/syndicate/knpc in spawned)
		var/obj/item/old_pocket = knpc.r_store
		if(old_pocket)
			knpc.dropItemToGround(old_pocket)
		knpc.equip_to_slot_or_del(new /obj/item/grenade/frag(knpc), ITEM_SLOT_RPOCKET)
		break

/datum/test_chamber_kit/pr_609_medic
	name = "PR 609: ranni boarderzy KNPC i medyk"
	pr = "aq33/AquilaStation#609"
	description = "Trzech syndykatów: A ciężko ranny z medipenem, B ciężko ranny bez medipena, C zdrowy z medipenem. \
	1) Pokaż się im z bronią → oczekiwane: A od razu wstrzykuje sobie medipen, mimo walki. \
	2) B (bez medipena) → oczekiwane: krzyczy „Jestem ranny, wycofuję się!” i idzie do najbliższego przytomnego kolegi; przy nim walczy dalej. \
	3) C → oczekiwane: gdy nie stoisz tuż obok niego, podchodzi do B i wstrzykuje mu medipen („Trzymaj się!”). \
	4) Negatyw: A z HP powyżej 35% → oczekiwane: walczy, nie leczy się w walce."
	items = list(
		/mob/living/carbon/human/ai_boarder/syndicate/pistol = 3,
	)

/datum/test_chamber_kit/pr_609_medic/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/list/boarders = list()
	for(var/mob/living/carbon/human/ai_boarder/knpc in spawned)
		boarders += knpc
	if(length(boarders) < 3)
		return
	var/mob/living/carbon/human/ai_boarder/wounded_pen = boarders[1]
	var/mob/living/carbon/human/ai_boarder/wounded_no_pen = boarders[2]
	var/mob/living/carbon/human/ai_boarder/medic = boarders[3]
	wounded_pen.real_name = "A (ranny z medipenem)"
	wounded_no_pen.real_name = "B (ranny bez medipena)"
	medic.real_name = "C (medyk)"
	for(var/mob/living/carbon/human/ai_boarder/knpc as anything in boarders)
		knpc.name = knpc.real_name
	for(var/obj/item/reagent_containers/hypospray/medipen/survival/pen in wounded_no_pen.GetAllContents())
		qdel(pen)
	wounded_pen.adjustToxLoss(wounded_pen.health - wounded_pen.maxHealth * 0.25, forced = TRUE)
	wounded_no_pen.adjustToxLoss(wounded_no_pen.health - wounded_no_pen.maxHealth * 0.25, forced = TRUE)
	medic.forceMove(turfs[min(length(turfs), 8)])

/// Boarder zamknięty w celi ze ścian, wyjście przez śluzę z dostępem kapitana, za nią unieruchomiony człowiek
/datum/test_chamber_kit/pr_609_door
	name = "PR 609: Syndykat hakuje śluzę"
	pr = "aq33/AquilaStation#609"
	description = "Syndykat zamknięty w celi ze ścian, jedyne wyjście to śluza z dostępem kapitana (na wschód), 3 pola za nią sparaliżowany człowiek. \
	1) Obserwuj → oczekiwane: syndykat idzie do śluzy, „zdejmuje osłonę panelu” i po ok. 10 s otwiera ją z iskrami, potem atakuje człowieka. \
	2) Zarygluj śluzę (bolt) przed końcem hakowania → oczekiwane: hakowanie i tak ją odrygluje i otworzy. \
	3) Zaspawaj śluzę → oczekiwane: haker nie hakuje spawanych drzwi, tylko je wyważa (uderzenia co 1,5 s). \
	Reset komory usuwa ściany i śluzę."
	items = list(
		/mob/living/carbon/human/ai_boarder/syndicate/pistol = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_609_door/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/mob/living/carbon/human/ai_boarder/boarder = locate() in spawned
	var/mob/living/carbon/human/victim
	for(var/mob/living/carbon/human/H in spawned)
		if(!istype(H, /mob/living/carbon/human/ai_boarder))
			victim = H
	if(!boarder || !victim)
		return
	boarder.forceMove(center)
	for(var/dir in GLOB.alldirs)
		var/turf/T = get_step(center, dir)
		if(!T)
			continue
		if(dir == EAST)
			var/obj/machinery/door/airlock/door = new(T)
			door.req_access = list(ACCESS_CAPTAIN)
			continue
		T.ChangeTurf(/turf/closed/wall)
	var/turf/victim_turf = get_ranged_target_turf(center, EAST, 4)
	if(victim_turf && !victim_turf.density)
		victim.forceMove(victim_turf)
	victim.Paralyze(120 SECONDS)

/datum/test_chamber_kit/pr_609_door/pirate
	name = "PR 609: pirat wyważa śluzę"
	description = "Pirat zamknięty w celi ze ścian, jedyne wyjście to śluza z dostępem kapitana (na wschód), 3 pola za nią sparaliżowany człowiek. \
	1) Obserwuj → oczekiwane: pirat bije w śluzę co 1,5 s i po kilkunastu sekundach ją wyważa („wyważa śluzę”), potem atakuje człowieka. \
	2) Zarygluj śluzę → oczekiwane: bije dalej, aż ją zniszczy. \
	Reset komory usuwa ściany i śluzę."
	items = list(
		/mob/living/carbon/human/ai_boarder/space_pirate/pistol = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_609_cover
	name = "PR 609: boarder KNPC chowa się za murkiem"
	pr = "aq33/AquilaStation#609"
	description = "Syndykat z pistoletem i dwa murki z worków z piaskiem 2 pola na wschód od środka. Stań z bronią kilka pól na wschód od murków. 	1) Obserwuj → oczekiwane: syndykat idzie za najbliższy murek (murek między nim a tobą) i stamtąd strzela, nie cofa się na otwarte pole. 	2) Strzelaj do niego → oczekiwane: część twoich pocisków trafia w murek. 	3) Obejdź murek z boku → oczekiwane: syndykat zmienia osłonę albo wraca do zwykłego trzymania dystansu. 	Uwaga: stoły nie są osłoną (pociski przez nie przelatują), więc boarder ich nie szuka."
	items = list(
		/mob/living/carbon/human/ai_boarder/syndicate/pistol = 1,
		/obj/structure/barricade/sandbags = 2,
	)

/datum/test_chamber_kit/pr_609_cover/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/list/barricades = list()
	for(var/obj/structure/barricade/B in spawned)
		barricades += B
	var/turf/first = get_ranged_target_turf(center, EAST, 2)
	if(length(barricades) >= 2 && first)
		var/obj/structure/barricade/one = barricades[1]
		var/obj/structure/barricade/two = barricades[2]
		one.forceMove(first)
		two.forceMove(get_step(first, NORTH))
	var/mob/living/carbon/human/ai_boarder/boarder = locate() in spawned
	boarder?.forceMove(get_ranged_target_turf(center, WEST, 1))

/datum/test_chamber_kit/pr_609_loot
	name = "PR 609: boarder KNPC zakuwa i zbiera sprzęt"
	pr = "aq33/AquilaStation#609"
	description = "Syndykat z pistoletem (ma 2 opaski zaciskowe), obok nieprzytomny człowiek i martwy człowiek z plecakiem: 3 magazyny 10 mm i medipen. Nie pokazuj się syndykatowi z bronią. 	1) Obserwuj → oczekiwane: syndykat podchodzi do nieprzytomnego i zakłada mu opaskę („Mam jeńca!”); zakutego potem nie bije. 	2) → oczekiwane: przeszukuje martwego i zabiera magazyny (najwyżej 4 zapasowe) do plecaka, medipen tylko, jeśli swój zużył. 	3) Pokaż się z bronią w trakcie → oczekiwane: przerywa zbieranie i walczy."
	items = list(
		/mob/living/carbon/human/ai_boarder/syndicate/pistol = 1,
		/mob/living/carbon/human = 2,
	)

/datum/test_chamber_kit/pr_609_loot/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/list/humans = list()
	for(var/mob/living/carbon/human/H in spawned)
		if(!istype(H, /mob/living/carbon/human/ai_boarder))
			humans += H
	if(length(humans) < 2)
		return
	var/mob/living/carbon/human/prisoner = humans[1]
	var/mob/living/carbon/human/body = humans[2]
	prisoner.real_name = "nieprzytomny"
	prisoner.name = prisoner.real_name
	prisoner.SetUnconscious(3 MINUTES)
	body.real_name = "martwy z magazynami"
	body.name = body.real_name
	body.equip_to_slot_or_del(new /obj/item/storage/backpack(body), ITEM_SLOT_BACK)
	for(var/i in 1 to 3)
		new /obj/item/ammo_box/magazine/m10mm(body.back)
	new /obj/item/reagent_containers/hypospray/medipen/survival(body.back)
	body.death()

// aq33/AquilaStation#331 - morph: cele "zjedz X rzeczy" / "zjedz X zwłok" (port Yogstation#13996)

/datum/test_chamber_kit/pr_331
	name = "PR 331: zamień mnie w morpha z celami"
	pr = "aq33/AquilaStation#331"
	description = "Przenosi cię do morpha i daje antaga Morf (trzeba być człowiekiem w komorze; stare ciało zostaje na arenie - wrócisz przez aghost i Assume direct control). \
	Na starcie ma przyjść wiadomość z celami: zjedz 20-60 rzeczy i/lub 2-6 zwłok, plus przeżyj. Zjedz rzeczy z podłogi i zwłoki: liczniki Things eaten / Corpses eaten w status tabie. \
	Wypluj przedmiot i zjedz go znowu - licznik NIE może wzrosnąć drugi raz. Wyniki widać też w raporcie końca rundy."
	items = list(
		/mob/living/simple_animal/hostile/morph = 1,
		/obj/item/food/donut = 10,
		/obj/item/screwdriver = 5,
		/obj/item/paper = 10,
		/mob/living/carbon/monkey = 3,
	)

/datum/test_chamber_kit/pr_331/setup(list/spawned, list/turfs, turf/center, mob/user)
	// Martwe małpy do celu "zjedz zwłoki"
	for(var/mob/living/carbon/monkey/corpse in spawned)
		corpse.death()
	var/mob/living/carbon/human/H = user
	if(!istype(H) || !H.mind)
		to_chat(user, "<span class='warning'>Musisz być człowiekiem w komorze, żeby wejść w morpha. Morph i tak leży na arenie.</span>")
		return
	var/mob/living/simple_animal/hostile/morph/morph = locate() in spawned
	if(!morph)
		return
	var/datum/mind/player_mind = H.mind
	player_mind.transfer_to(morph)
	player_mind.add_antag_datum(/datum/antagonist/morph)

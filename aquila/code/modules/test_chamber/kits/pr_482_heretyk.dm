/datum/test_chamber_kit/pr_482
	name = "Heretyk z tg (8 ścieżek)"
	pr = "aq33/AquilaStation#482"
	description = "Zestaw tworzy 6 ludzi: 1) „heretyk testowy” (30 punktów wiedzy), 2) „ofiara testowa” (w krytyku, już na liście celów Living Heart), 3) człowiek bez heretyka, 4-6) martwi (trzy ciała na wniebowstąpienie). Przejmij heretyka. \
	1) Okno heretyka → kup ścieżkę Ash (Nightwatcher's Secret) → oczekiwane: punkty spadają o koszt, w drzewie odblokowują się kolejne węzły, ścieżki nie da się zmienić (negatyw: druga ścieżka jest zablokowana). \
	2) Mansus Grasp w drugiej ręce + długopis na podłodze → oczekiwane: po ok. 20 s runa transmutacji. Połóż na runie nóż i zapałkę, użyj runy → oczekiwane: powstaje Ashen Blade (w Ash możesz mieć tylko dwa; trzeci rytuał odmawia). \
	3) Mansus Grasp na człowieku bez heretyka (nr 3) → oczekiwane: cel widzi „Jasne zielone światło straszliwie pali ci oczy!” i dostaje uszkodzenie oczu oraz Mark ścieżki; trafienie Ashen Blade wyzwala Mark i zwraca 75% czasu odnowienia Grasp. \
	4) Negatyw: człowiek nr 3 (bez heretyka) uderza zwykłym sickly_blade (leży obok) → oczekiwane: „Czujesz, jak puls obcego intelektu uderza w twój umysł!”, 5 s paraliżu i brak obrażeń; heretyk tym samym ostrzem bije normalnie. Naszyjnik focus u nr 3 nie daje żadnego efektu. \
	5) Living Heartbeat (akcja serca) → oczekiwane: lista celów z „ofiarą testową”, strzałka wskazuje ją. Połóż ofiarę na runie, użyj Hunt and Sacrifice → oczekiwane: +2 punkty wiedzy, ofiara trafia do wymiaru Mansusa (sen, potem powrót z klątwą albo śmierć). Negatyw: człowiek nr 3 (nie jest celem) na runie → „rytuał nieudany, brak ofiary!”. \
	6) Wpływy: Debug → spawn /obj/effect/heretic_influence i wysysanie ręką → oczekiwane: dodatkowy punkt wiedzy. Lock: chwyt na drzwiach i konsolach stacji otwiera je. \
	7) Wniebowstąpienie: cele pojawiają się dopiero po wyborze ścieżki, więc oznacz je jako ukończone w Antag Panelu (bez tego rytuał odmawia: „Przed wniebowstąpieniem musisz wykonać wszystkie cele”). Wykup węzły do ostatniego rytuału ścieżki i ułóż na runie 3 martwych ludzi (nr 4-6) → oczekiwane: ogłoszenie i przemiana. Jeśli pojawi się „Za wcześnie”, to limit z configu minimum_ascension_time (oczekiwane na świeżej rundzie; zmień config albo czas, żeby przejść dalej). \
	8) Przywołańce (np. Rust Walker: kałuża wymiocin, 10 żelaza, 15 kabla; Ash Spirit: popiół, książka, ognisko) i szaleńcy Moon wymagają ducha: wymaga ducha, który zgłosi się w ankiecie, bez niego rytuał kończy się „brak duchów”."
	items = list(
		/mob/living/carbon/human = 6,
		/obj/item/pen = 1,
		/obj/item/kitchen/knife = 3,
		/obj/item/match = 2,
		/obj/item/book = 1,
		/obj/item/candle = 3,
		/obj/item/food/grown/poppy = 2,
		/obj/item/food/grown/harebell = 1,
		/obj/item/clothing/under/color/grey = 1,
		/obj/item/codex_cicatrix = 1,
		/obj/item/clothing/neck/heretic_focus = 1,
		/obj/item/melee/sickly_blade = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/stack/sheet/iron/fifty = 1,
	)

/datum/test_chamber_kit/pr_482/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/list/humans = list()
	for(var/mob/living/carbon/human/person in spawned)
		humans += person
	if(length(humans) < 6)
		return
	var/mob/living/carbon/human/heretic_mob = humans[1]
	var/mob/living/carbon/human/victim = humans[2]
	heretic_mob.mind_initialize()
	var/datum/antagonist/heretic/heretic_datum = heretic_mob.mind.add_antag_datum(/datum/antagonist/heretic)
	heretic_mob.name = "heretyk testowy"
	heretic_mob.real_name = heretic_mob.name
	victim.name = "ofiara testowa"
	victim.real_name = victim.name
	var/mob/living/carbon/human/plain = humans[3]
	plain.name = "człowiek bez heretyka"
	plain.real_name = plain.name
	for(var/i in 4 to 6)
		var/mob/living/carbon/human/corpse = humans[i]
		corpse.name = "ciało na wniebowstąpienie [i - 3]"
		corpse.real_name = corpse.name
		corpse.death()
	if(!heretic_datum)
		return
	heretic_datum.adjust_knowledge_points(29)
	// Cele Living Heart ustawiamy ręcznie, bo losowanie bierze tylko ludzi z umysłem i pracą załogi
	heretic_datum.add_sacrifice_target(victim)
	// Ofiara do rytuału musi być co najmniej w krytyku
	victim.adjustOxyLoss(victim.maxHealth + 10)

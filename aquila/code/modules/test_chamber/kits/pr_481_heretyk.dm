/datum/test_chamber_kit/pr_481
	name = "Heretyk z tg (8 ścieżek)"
	pr = "aq33/AquilaStation#481"
	description = "Pierwszy człowiek jest heretykiem z 30 punktami wiedzy (przejmij go albo daj heretyka sobie przez Antag Panel i dodaj punkty komendą Adjust Knowledge Points). \
		Otwórz okno heretyka: wybierz ścieżkę, kup wiedzę z drzewa, draftów i sklepu. Mansus Grasp w drugiej ręce + długopis na podłodze = runa; sprawdź rytuały \
		(ostrze z noża, Codex z książki, żywe serce, wiedza poboczna). Living heart: cele ofiarne, ofiara drugiego człowieka (wymiar Mansusa, powrót z klątwą). \
		Wpływy: Debug -> spawn /obj/effect/heretic_influence i wysysanie. Ostrze i naszyjnik leżą obok - weź je też człowiekiem bez heretyka (kary); szaty zrób rytuałem. \
		Lock: chwyt na drzwiach i konsolach stacji. Wniebowstąpienie wymaga ukończenia celów (oznacz je jako ukończone w Antag Panelu)."
	items = list(
		/mob/living/carbon/human = 3,
		/obj/item/pen = 1,
		/obj/item/kitchen/knife = 3,
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

/datum/test_chamber_kit/pr_481/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/heretic_mob = locate() in spawned
	if(!heretic_mob)
		return
	heretic_mob.mind_initialize()
	var/datum/antagonist/heretic/heretic_datum = heretic_mob.mind.add_antag_datum(/datum/antagonist/heretic)
	heretic_datum?.adjust_knowledge_points(29)
	heretic_mob.name = "heretyk testowy"
	heretic_mob.real_name = heretic_mob.name

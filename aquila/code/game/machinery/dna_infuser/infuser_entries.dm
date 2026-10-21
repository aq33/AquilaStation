// AQUILA - port z tgstation (code/game/machinery/dna_infuser/infuser_entries/*.dm)
// Tylko zestawy pasujące do statku: szczur, karp, karaluch, gondola, mucha + żartobliwe tier 0.

/*
 * Tier 0: dostępne od początku - kosmetyka, rasy, mucha (kara za odrzucone DNA).
 */
/datum/infuser_entry/fly
	name = "Odrzucone"
	infuse_mob_name = "odrzucona istota"
	desc = "Z jakiegoś powodu, gdy ciało odrzuca DNA, kwaśnieje ono i kończy jako muchopodobny bałagan genetyczny."
	threshold_desc = "bałagan w DNA bierze górę i stajesz się pełnoprawnym muchoczłowiekiem."
	qualities = list(
		"bzycząca mowa",
		"picie wymiocin",
		"organy, których nikt nie rozpozna",
		"to zły pomysł",
	)
	output_organs = list(
		/obj/item/organ/appendix/fly,
		/obj/item/organ/eyes/fly,
		/obj/item/organ/heart/fly,
		/obj/item/organ/lungs/fly,
		/obj/item/organ/stomach/fly,
		/obj/item/organ/tongue/fly,
	)
	infusion_desc = "muchowato"
	tier = DNA_MUTANT_TIER_ZERO

/datum/infuser_entry/vulpini
	name = "Lis"
	infuse_mob_name = "lisowate"
	desc = "Lisy są dziś rzadkie przez szał na \"lisie uszy\" w 2555 roku. No i dlatego, że jako cywilizacja kosmiczna dawno zniszczyliśmy ich siedliska, ale to dotyczy większości zwierząt."
	threshold_desc = DNA_INFUSION_NO_THRESHOLD
	qualities = list(
		"oj, no weź",
		"przynosisz WSTYD wszystkim genetykom",
		"mam nadzieję, że było warto",
	)
	input_obj_or_mob = list(
		/mob/living/simple_animal/pet/fox,
	)
	output_organs = list(
		/obj/item/organ/ears/cat/fox,
	)
	infusion_desc = "niewybaczalnie"
	tier = DNA_MUTANT_TIER_ZERO

/datum/infuser_entry/mothroach
	name = "Ćmokaraluch"
	infuse_mob_name = "ćmokaraluchowate"
	desc = "Najpierw zmieszali DNA ćmy i karalucha, żeby zrobić ćmokaralucha, a teraz mieszamy ćmokaralucha z humanoidem, żeby zrobić ćmoczłowieka?"
	threshold_desc = DNA_INFUSION_NO_THRESHOLD
	qualities = list(
		"oczy wrażliwe na jasne światło",
		"trzepoczesz, gdy mówisz",
		"skrzydła, które nie uniosą nawet twojej wagi",
		"mam nadzieję, że było warto",
	)
	input_obj_or_mob = list(
		/mob/living/simple_animal/mothroach,
	)
	output_organs = list(
		/obj/item/organ/infuser_feature/moth_antennae,
		/obj/item/organ/wings/moth,
		/obj/item/organ/eyes/moth,
		/obj/item/organ/tongue/moth,
	)
	infusion_desc = "puchato"
	tier = DNA_MUTANT_TIER_ZERO

/datum/infuser_entry/lizard
	name = "Jaszczurka"
	infuse_mob_name = "jaszczurkowate"
	desc = "Okazuje się, że wszczepienie większości humanoidów DNA jaszczurki daje cechy zadziwiająco podobne do jaszczuroludzi. Co za dziwny zbieg okoliczności."
	threshold_desc = DNA_INFUSION_NO_THRESHOLD
	qualities = list(
		"długie ogony",
		"ozdobne rogi",
		"estetyczne pyski",
		"szczerze mówiąc niewiele",
	)
	input_obj_or_mob = list(
		/mob/living/simple_animal/hostile/lizard,
	)
	output_organs = list(
		/obj/item/organ/infuser_feature/lizard_horns,
		/obj/item/organ/infuser_feature/lizard_frills,
		/obj/item/organ/infuser_feature/lizard_snout,
		/obj/item/organ/tail/lizard,
		/obj/item/organ/tongue/lizard,
	)
	infusion_desc = "łuskowato"
	tier = DNA_MUTANT_TIER_ZERO

/datum/infuser_entry/felinid
	name = "Kot"
	infuse_mob_name = "kotowate"
	desc = "WSZYSCY SPOKÓJ! Niczego tym wpisem nie sugeruję. Naprawdę dziwi nas, że felinidzi to ludzie z domieszką kociego DNA?"
	threshold_desc = DNA_INFUSION_NO_THRESHOLD
	qualities = list(
		"niech zgadnę, jesteś wielkim fanem tych japońskich robotów turystycznych",
	)
	input_obj_or_mob = list(
		/mob/living/simple_animal/pet/cat,
	)
	output_organs = list(
		/obj/item/organ/ears/cat,
		/obj/item/organ/tail/cat,
	)
	infusion_desc = "domowo"
	tier = DNA_MUTANT_TIER_ZERO

/datum/infuser_entry/penguin
	name = "Pingwin"
	infuse_mob_name = "pingwin"
	desc = "Szczerze, z DNA pingwina niewiele dało się wyciągnąć, poza tym, że śmiesznie chodzą."
	threshold_desc = DNA_INFUSION_NO_THRESHOLD
	qualities = list(
		"kołyszesz się, gdy chodzisz",
	)
	input_obj_or_mob = list(
		/mob/living/simple_animal/pet/penguin,
	)
	output_organs = list(
		/obj/item/organ/ears/penguin,
	)
	infusion_desc = "kołysząco"
	tier = DNA_MUTANT_TIER_ZERO

/datum/infuser_entry/plants
	name = "Roślina"
	infuse_mob_name = "hybryda roślinna"
	desc = "Hydroponika od dawna interesuje się wszczepianiem ludzkiego DNA w rośliny, tworząc ludzi-strąki. \
		Wielu naukowców nie chciało dać się prześcignąć tym hipisom, więc spróbowali odwrotnie - z mało ciekawym skutkiem."
	threshold_desc = DNA_INFUSION_NO_THRESHOLD
	qualities = list(
		"zielone organy",
		"poza tym niewiele, szczerze mówiąc",
	)
	input_obj_or_mob = list(
		/obj/item/food/grown,
		/obj/item/grown,
	)
	output_organs = list(
		/obj/item/organ/appendix/pod,
		/obj/item/organ/ears/pod,
		/obj/item/organ/eyes/pod,
		/obj/item/organ/heart/pod,
		/obj/item/organ/liver/pod,
		/obj/item/organ/lungs/pod,
		/obj/item/organ/stomach/pod,
		/obj/item/organ/tongue/podperson,
	)
	infusion_desc = "botanicznie"
	tier = DNA_MUTANT_TIER_ZERO

/*
 * Tier 1: dostępne od początku, z bonusem po przekroczeniu progu.
 */
/datum/infuser_entry/carp
	name = "Karp"
	infuse_mob_name = "kosmokarpiowate"
	desc = "Karpiomutanci są świetnie przygotowani do długich wypraw w głęboki kosmos. Właściwie to nie potrafią bez nich wytrzymać!"
	threshold_desc = "uczysz się, jak napędzać się w próżni. Jak ryba!"
	qualities = list(
		"wielkie szczęki, wielkie zęby",
		"pływanie w kosmosie to żaden problem",
		"stawianie czoła każdemu problemowi po powrocie na statek",
		"wieczna chęć podróży",
	)
	input_obj_or_mob = list(
		/mob/living/simple_animal/hostile/carp,
	)
	excluded_input = list(
		/mob/living/simple_animal/hostile/carp/holocarp,
		/mob/living/simple_animal/hostile/carp/eyeball,
	)
	output_organs = list(
		/obj/item/organ/brain/carp,
		/obj/item/organ/fangs/carp,
		/obj/item/organ/heart/carp,
		/obj/item/organ/lungs/carp,
		/obj/item/organ/tongue/carp,
	)
	infusion_desc = "koczowniczo"
	tier = DNA_MUTANT_TIER_ONE
	status_effect_type = /datum/status_effect/organ_set_bonus/carp

/datum/infuser_entry/rat
	name = "Szczur"
	infuse_mob_name = "gryzoń"
	desc = "Kruchy, mały, ser-decznie gotowy stawić czoła światu. Łatwo się nafaszerować szczurzym DNA, ale czy to najlepszy wybór?"
	threshold_desc = "stajesz się na tyle gibki, by przeciskać się przez wentylację."
	qualities = list(
		"serowe teksty",
		"zje wszystko",
		"ciągle chce jeść wszystko",
		"kruchy, ale szybki",
	)
	input_obj_or_mob = list(
		/obj/item/food/deadmouse,
		/mob/living/simple_animal/mouse,
		/mob/living/simple_animal/hostile/rat,
	)
	output_organs = list(
		/obj/item/organ/eyes/night_vision/rat,
		/obj/item/organ/heart/rat,
		/obj/item/organ/stomach/rat,
		/obj/item/organ/tongue/rat,
	)
	infusion_desc = "płochliwie"
	tier = DNA_MUTANT_TIER_ONE
	status_effect_type = /datum/status_effect/organ_set_bonus/rat

/datum/infuser_entry/roach
	name = "Karaluch"
	infuse_mob_name = "karaluch"
	desc = "Widać, że lubisz klasykę literatury. Zapewniamy, że wszczepienie DNA karalucha \
		nie sprawi, że nie wstaniesz z łóżka. Te stworzenia są niesamowicie odporne na wiele rzeczy, \
		na które ludzie są wrażliwi, i możemy to wykorzystać! Kto nie chciałby przeżyć wybuchu atomowego? \
		UWAGA: rozdeptane karaluchy nie nadają się do infusera, to chyba oczywiste. Spróbuj spryskać je pestycydem z botaniki!"
	threshold_desc = "eksplozje nie rozerwą cię na strzępy, zyskujesz też ogromną odporność na wirusy i promieniowanie."
	qualities = list(
		"odporność na ciosy w plecy",
		"zdrowsze organy",
		"szybko przechodzi ci obrzydzenie",
		"przetrwasz atomową apokalipsę",
		"trudniej ci się podnieść po przewróceniu",
		"unikaj toksyn za wszelką cenę",
		"zawsze chętny na przekąskę",
	)
	input_obj_or_mob = list(
		/mob/living/simple_animal/cockroach,
	)
	output_organs = list(
		/obj/item/organ/heart/roach,
		/obj/item/organ/stomach/roach,
		/obj/item/organ/liver/roach,
		/obj/item/organ/appendix/roach,
	)
	infusion_desc = "kafkowsko" // Gregor Samsa !!
	tier = DNA_MUTANT_TIER_ONE
	status_effect_type = /datum/status_effect/organ_set_bonus/roach

/*
 * Tier 2: odblokowywane po pełnym bonusie z wpisu tieru 1.
 */
/datum/infuser_entry/gondola
	name = "Gondola"
	infuse_mob_name = "gondolowate"
	desc = "Gondole, rzadkie stworzenia, które wolą obserwować niż działać, mają sporo ciekawych cech do wykorzystania. No wiesz. Zen, spokój, szczęście... olewanie szalejącego pożaru plazmy..."
	threshold_desc = "przestają cię obchodzić niemal wszystkie warunki otoczenia!"
	qualities = list(
		"uspokajasz ludzi przytulasami",
		"wchodzisz w błogi stan zen",
		"za słaby, by podnieść cokolwiek większego od długopisu",
		"przestaje cię obchodzić temperatura... ciśnienie, atmosfera... właściwie cokolwiek...",
	)
	input_obj_or_mob = list(
		/obj/item/food/meat/slab/gondola,
	)
	output_organs = list(
		/obj/item/organ/heart/gondola,
		/obj/item/organ/tongue/gondola,
		/obj/item/organ/liver/gondola,
	)
	infusion_desc = "obserwująco"
	tier = DNA_MUTANT_TIER_TWO
	status_effect_type = /datum/status_effect/organ_set_bonus/gondola

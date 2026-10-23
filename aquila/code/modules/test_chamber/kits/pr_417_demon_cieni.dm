// aq33/AquilaStation#417 - demon cieni z Paradise zamiast koszmara

/datum/test_chamber_kit/pr_417
	name = "PR 417: demon cieni"
	pr = "aq33/AquilaStation#417"
	description = "Zestaw gasi lampy w komorze na 5 minut, żeby demon nie spłonął. Wejście w demona: Aghost i kliknij powiadomienie „Można sterować” (albo Spawners) - po wejściu dostajesz antagonistę z celami. \
	Drugi admin albo ty po wyjściu z ciała sprawdza efekty. W ciemności demon jest półprzezroczysty, szybszy i się leczy; na świetle (włączona latarka) dostaje obrażenia i alert. \
	Cienisty pełz: wejście w cień i przejście przez ścianę, wyjście tylko na ciemne pole. Cień-hak w człowieka z latarką (najpierw ją włącz): 40 obrażeń, przyciągnięcie i zgaszona latarka; hak w ścianę przyciąga demona, flara się wypala. \
	Cios gasi światło w przedmiotach. Zwłoki owiń w kokon (4 s) - kokon gasi światła wokół, Alt+klik włącza dźwięki wabiące. Demoniczny szept do człowieka. \
	Serce ciemności: zjedzone daje cień-hak."
	items = list(
		/mob/living/simple_animal/shadow_demon/test_chamber = 1,
		/mob/living/carbon/human = 2,
		/obj/item/flashlight = 2,
		/obj/item/flashlight/flare = 1,
		/obj/item/flashlight/seclite = 1,
		/obj/item/organ/heart/shadow_demon = 1,
	)

/datum/test_chamber_kit/pr_417/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	// Jeden człowiek martwy na kokon, drugi z latarką w ręku (zgaszoną, żeby nie parzyła demona bez gracza)
	var/killed = FALSE
	for(var/mob/living/carbon/human/human in spawned)
		if(!killed)
			human.real_name = "zwłoki na kokon"
			human.name = human.real_name
			human.death()
			killed = TRUE
			continue
		human.real_name = "człowiek z latarką"
		human.name = human.real_name
		var/obj/item/flashlight/light = new(human)
		human.put_in_hands(light)
	// Ciemność w komorze, inaczej demon bez gracza spłonie w ~10 s
	for(var/obj/machinery/light/lamp in range(20, center))
		if(GLOB.test_chamber?.contains(lamp))
			lamp.extinguish_light()

/// Demon z komory: do przejęcia przez duchy, z antagonistą po wejściu gracza
/mob/living/simple_animal/shadow_demon/test_chamber/Initialize(mapload)
	. = ..()
	set_playable(ROLE_SHADOW_DEMON)

/mob/living/simple_animal/shadow_demon/test_chamber/Login()
	. = ..()
	if(mind && !mind.has_antag_datum(/datum/antagonist/shadow_demon))
		mind.add_antag_datum(/datum/antagonist/shadow_demon)

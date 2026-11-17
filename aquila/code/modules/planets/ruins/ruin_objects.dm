// AQUILA: typy potrzebne ruinom planet wulkanicznych z Shiptesta (kod AGPLv3, grafiki CC BY-SA 3.0), bez odpowiednika u nas.

/// Pies Kliki Ramziego (Shiptest: /mob/living/simple_animal/hostile/asteroid/wolf/hound/ramzi). Bez szarży wilka,
/// zwykły basic mob walczący wręcz. Frakcja Syndykatu, bo Klikę Ramziego grają u nas żołnierze Syndykatu.
/mob/living/basic/mining/ramzi_hound
	name = "rajzehund"
	desc = "Kundel rodem z Sol. Rajzehundy słyną z terytorialności, dużych rozmiarów i lojalności. Ten na pewno nie jest lojalny wobec ciebie."
	icon = 'aquila/icons/planets/ruins/ramzi_hound.dmi'
	icon_state = "hound"
	icon_living = "hound"
	icon_dead = "hound_dead"
	pixel_x = -4
	base_pixel_x = -4
	mob_size = MOB_SIZE_HUMAN
	faction = list(FACTION_SYNDICATE)
	maxHealth = 75
	health = 75
	speed = 1
	obj_damage = 15
	melee_damage = 7
	sharpness = SHARP_EDGED
	attack_verb_continuous = "gryzie"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	speak_emote = list("warczy", "szczeka")
	friendly_verb_continuous = "obwąchuje"
	butcher_results = list(/obj/item/food/meat/slab = 2, /obj/item/stack/sheet/bone = 2)
	kill_count = FALSE
	ai_controller = /datum/ai_controller/basic_controller/simple_hostile

/obj/item/reagent_containers/glass/bottle/nitroglycerin
	name = "butelka: nitrogliceryna"
	label_name = "nitroglycerin"
	desc = "Mała butelka nitrogliceryny. Lepiej nią nie potrząsać."
	list_reagents = list(/datum/reagent/nitroglycerin = 30)

/obj/item/paper/fluff/ruins/planet_lava/holdout/goodbye
	name = "zawilgocone pożegnanie"
	default_raw_text = "Mamo,<br><br>Tu twoja córka, Marianne. Nie sądzę, żeby to do ciebie dotarło. Chyba pogodziłam się z tym, jak to się skończy. Huk strzelających wieżyczek wwiercił mi się w głowę, kiedy patrzę na resztki jedzenia i wody pitnej.<br><br>Miałaś rację. Jestem głupia, jestem idiotką i jestem nikim. Chciałam robić to co ty, walczyć z ludźmi, którzy nas skrzywdzili. Myślałam, że w Republice się poddałaś i że muszę spełnić marzenie, którego, jak sądziłam, chciałaś. Teraz, kiedy Klika próbuje wyważyć nasze drzwi, nie wiem, czy jeszcze w to wierzę.<br><br>Kocham cię."

/obj/item/paper/fluff/ruins/planet_lava/holdout/hurrah
	name = "wściekle nabazgrana notatka"
	default_raw_text = "Mogą mieć satysfakcję, że nas zagłodzili, ale niech mnie szlag, jeśli oddam tym pieprzonym zdrajcom nasze zapasy. Jeszcze jedno wybuchowe hurra, a potem odejdę na własnych warunkach."

/obj/item/paper/fluff/ruins/planet_lava/holdout/besieged
	name = "nieudolnie napisana notatka"
	default_raw_text = "Kapitan zostawiła mnie, żebym pilnował, jak głodzimy Twardogłowych w placówce. Uważam, że to tchórz, i jeśli zdobędę bazę z samymi tępakami, których zostawiła, porucznik na pewno poprze mnie w przewrocie."

/// Puste automaty oblężonego bastionu: obrońcy wyjedli wszystko
/obj/machinery/vending/cola/planet_lava_holdout
	products = list(
		/obj/item/reagent_containers/food/drinks/soda_cans/cola = 0,
		/obj/item/reagent_containers/food/drinks/soda_cans/space_up = 0,
		/obj/item/reagent_containers/glass/waterbottle = 0,
	)
	contraband = list()
	premium = list()

/obj/machinery/vending/snack/planet_lava_holdout
	products = list(
		/obj/item/food/spacetwinkie = 0,
		/obj/item/food/candy = 0,
		/obj/item/food/chips = 0,
		/obj/item/food/energybar = 0,
	)
	contraband = list()
	premium = list()

// Posadzki betonowe (Shiptest code/game/turfs/open/floor/conc_floor.dm) bez schnięcia, odcisków i kształtowania:
// w ruinach beton jest suchy od początku.
/turf/open/floor/concrete
	name = "betonowa posadzka"
	desc = "Zimna, goła betonowa posadzka."
	icon = 'aquila/icons/planets/ruins/concrete.dmi'
	icon_state = "conc_smooth_1"
	base_icon_state = "conc_smooth"
	broken_states = list("concdam_1", "concdam_2", "concdam_3", "concdam_4")
	floor_tile = null
	/// Losuje jeden z czterech wariantów tekstury
	var/has_variation = TRUE

/turf/open/floor/concrete/Initialize(mapload)
	. = ..()
	if(has_variation && !broken && !burnt)
		icon_state = "[base_icon_state]_[rand(1, 4)]"

/turf/open/floor/concrete/slab_1
	icon_state = "conc_slab_1"
	has_variation = FALSE

/turf/open/floor/concrete/slab_4
	icon_state = "conc_slab_4"
	has_variation = FALSE

/turf/open/floor/concrete/pavement
	name = "pas nawierzchni"
	desc = "Gorąca, chropowata nawierzchnia. Lepsza na drogi niż zwykły beton, bo pojazdy jeżdżą po niej ciszej."
	icon_state = "pavement_1"
	base_icon_state = "pavement"

// Odmiany z atmosferą planety, na zewnątrz ruin
/turf/open/floor/concrete/lava
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/floor/concrete/slab_1/lava
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/floor/concrete/pavement/lava
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

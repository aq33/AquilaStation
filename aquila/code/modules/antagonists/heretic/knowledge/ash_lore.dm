/datum/heretic_knowledge_tree_column/ash
	route = PATH_ASH
	ui_bgr = "node_ash"
	complexity = "Łatwa"
	complexity_color = COLOR_GREEN
	icon = list(
		"icon" = 'aquila/icons/obj/weapons/khopesh.dmi',
		"state" = "ash_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"Ścieżka Popiołu to ogień, mobilność i brutalne unieszkodliwianie pojedynczych przeciwników.",
		"Wybierz ją, jeśli dopiero zaczynasz grę heretykiem albo lubisz styl „uderz i uciekaj”.",
	)
	pros = list(
		"Bardzo silna już od początku ścieżki.",
		"Łatwy dostęp do zaklęć ruchu i poszerzonego widzenia.",
		"Bardzo mocny efekt znaku.",
	)
	cons = list(
		"Poza zdolnościami startowymi słabsza od większości ścieżek.",
		"Brakuje jej wytrzymałości w długich starciach.",
		"Polega na szybkim i mocnym ataku, zanim przeciwnicy zdążą przygotować obronę.",
	)
	tips = list(
		"Twój Mansus Grasp na chwilę oślepia i nakłada znak, który po aktywacji ostrzem wycieńcza przeciwnika do upadku. Znak może przeskoczyć na pobliskich wrogów.",
		"Wybór tej ścieżki daje odporność na obrażenia od wysokiej temperatury. Pamiętaj jednak, że twoje ubrania nadal mogą spłonąć! Jeśli chcesz się chronić przed własnym ogniem, noś Scorched Mantle.",
		"Scorched Mantle utrzymuje cię w płomieniach i chroni przed ich skutkami. Wbiegaj w grupy wrogów i roznoś ogień daleko i szeroko.",
		"Nie lekceważ Mask of Madness. Powoli wyczerpuje wrogów i wywołuje u nich halucynacje.",
		"Podpalaj jak najwięcej wrogów! Nightwatcher's Rebirth leczy cię i skraca swój czas odnowienia za każdą wyssaną ofiarę.",
		"Wniebowstąpienie daje pełną odporność na zagrożenia środowiska, nawet na bomby! Nadal jednak jesteś podatny na zwykłą broń. Nie bądź zbyt pewny siebie.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_ash
	knowledge_tier1 = /datum/heretic_knowledge/spell/ash_passage
	guaranteed_side_tier1 = /datum/heretic_knowledge/medallion
	knowledge_tier2 = /datum/heretic_knowledge/spell/fire_blast
	guaranteed_side_tier2 = /datum/heretic_knowledge/rifle
	robes = /datum/heretic_knowledge/armor/ash
	knowledge_tier3 = /datum/heretic_knowledge/nightwatchers_lantern
	guaranteed_side_tier3 = /datum/heretic_knowledge/summon/ashy
	blade = /datum/heretic_knowledge/blade_upgrade/ash
	knowledge_tier4 = /datum/heretic_knowledge/spell/flame_birth
	ascension = /datum/heretic_knowledge/ultimate/ash_final

/datum/heretic_knowledge/limited_amount/starting/base_ash
	name = "Nightwatcher's Secret"
	desc = "Otwiera przed tobą Ścieżkę Popiołu.<br>\
		Pozwala tworzyć Ashen Blade. \
		Naraz możesz mieć tylko dwa."
	transmute_text = "Przemień zapałkę i nóż."
	gain_text = "Straż Miejska zna swoją wartę. Jeśli zapytasz ich nocą, może opowiedzą ci o popielnej latarni."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/match = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/ash)
	research_tree_icon_path = 'aquila/icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "ash_blade"
	mark_type = /datum/status_effect/eldritch/ash
	eldritch_passive = /datum/status_effect/heretic_passive/ash

/datum/heretic_knowledge/limited_amount/starting/base_ash/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	if(target.is_blind())
		return

	if(!target.getorganslot(ORGAN_SLOT_EYES))
		return

	to_chat(target, span_danger("Jasne zielone światło straszliwie pali ci oczy!"))
	target.adjust_organ_loss(ORGAN_SLOT_EYES, 15)
	target.set_eye_blur_if_lower(20 SECONDS)

/datum/heretic_knowledge/limited_amount/starting/base_ash/trigger_mark(mob/living/source, mob/living/target)
	. = ..()
	if(!.)
		return

	// Also refunds 75% of charge!
	var/datum/action/cooldown/spell/touch/mansus_grasp/grasp = locate() in source.actions
	if(grasp)
		grasp.next_use_time -= round(grasp.cooldown_time*0.75)
		grasp.update_cooldown_text()
		grasp.build_all_button_icons()

/datum/heretic_knowledge/spell/ash_passage
	name = "Ashen Passage"
	desc = "Daje ci Ashen Passage, zaklęcie, które pozwala wyjść poza rzeczywistość \
		i przebyć krótki dystans, przenikając przez ściany."
	gain_text = "Wiedział, jak kroczyć między planami."
	action_to_add = /datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash
	cost = 2
	drafting_tier = 5
	max_charges = 6
	focus_recharge_amount = 0.15
	holywater_drain_amount = 0.15

/datum/heretic_knowledge/spell/fire_blast
	name = "Volcano Blast"
	desc = "Daje ci Volcano Blast, zaklęcie, które po krótkim ładowaniu wystrzeliwuje wiązkę energii \
		w pobliskiego wroga, podpalając go i parząc. Jeśli cel się nie ugasi, \
		wiązka przeskoczy na kolejny cel."
	gain_text = "Żaden ogień nie był dość gorący, by ich na nowo rozpalić. Żaden ogień nie był dość jasny, by ich ocalić. Żaden ogień nie jest wieczny."
	action_to_add = /datum/action/cooldown/spell/charged/beam/fire_blast
	cost = 2
	research_tree_icon_frame = 7
	max_charges = 3
	focus_recharge_amount = 0.33
	holywater_drain_amount = 0.16

/datum/heretic_knowledge/armor/ash
	desc = "Stwórz Scorched Mantle.<br>\
		Daje pełną ochronę przed ogniem i sam z siebie wytwarza kolejne płomienie."
	transmute_text = "Przemień stół (albo strój), maskę i zapałkę."
	gain_text = "Straż trwa tak, jak upadła, rozsypując się w proch. \
		A jednak wiatry wiejące przez miasto wzywają ich z powrotem do służby - wzbity w powietrze pył, dryfująca sylwetka poległych."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash)
	research_tree_icon_state = "ash_armor"
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/match = 1,
	)

/datum/heretic_knowledge/nightwatchers_lantern
	name = "Nightwatcher's Lantern"
	desc = "Stwórz płonącą latarnię.<br>\
		Płonąca latarnia to jaskrawe światło, które rani oczy i z czasem otumania tych, którzy zbyt długo na nią patrzą. \
		Ochrona oczu osłabia ten efekt, a wzmacnia go to, że latarnia jest jedynym źródłem światła w pobliżu."
	transmute_text = "Przemień lampę, latarnię albo latarkę ochrony, parę oczu, flasha i cztery zapalone świece."
	gain_text = "Nocny Strażnik nie zapuszczał się w ciemność. To byłoby głupie, nawet Straż o tym wiedziała. \
		Jego latarnia płonęła światłem, które mogło spalić słońce."
	cost = 2
	result_atoms = list(/obj/item/flashlight/lantern/heretic)
	// AQUILA - świece z tg (flashlight/flare/candle) to u nas /obj/item/candle
	required_atoms = list(
		list(/obj/item/flashlight/lamp, /obj/item/flashlight/lantern, /obj/item/flashlight/seclite) = 1,
		/obj/item/organ/eyes = 1,
		/obj/item/assembly/flash = 1,
		/obj/item/candle = 4,
	)
	research_tree_icon_path = 'icons/obj/lighting.dmi'
	research_tree_icon_state = "lantern"

/datum/heretic_knowledge/nightwatchers_lantern/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/candle/candle in atoms)
		if(!candle.lit)
			atoms -= candle

/datum/heretic_knowledge/nightwatchers_lantern/prepare_atom_for_ritual_test(atom/what)
	. = ..()
	if(istype(what, /obj/item/candle))
		var/obj/item/candle/candle = what
		candle.light()

/datum/heretic_knowledge/blade_upgrade/ash
	name = "Fiery Blade"
	desc = "Twoje ostrze podpala wrogów przy każdym ciosie."
	gain_text = "Wrócił z ostrzem w dłoni i ciął, i ciął, a z nieba padał popiół. \
		Jego miasto, ludzie, których przysięgał strzec... i strzegł ich wzrokiem, gdy wszyscy spłonęli na popiół."

	research_tree_icon_path = 'aquila/icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_ash"

/datum/heretic_knowledge/blade_upgrade/ash/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	target.adjust_fire_stacks(1)
	target.ignite_mob()

/datum/heretic_knowledge/spell/flame_birth
	name = "Nightwatcher's Rebirth"
	desc = "Daje ci Nightwatcher's Rebirth, zaklęcie, które cię gasi \
		i pali wszystkich pobliskich pogan, którzy właśnie płoną, lecząc cię za każdą ofiarę.<br>\
		Ofiary w stanie krytycznym od razu giną."
	gain_text = "Przed ogniem nie było ucieczki, a jednak w jego zwęglonym ciele tliło się życie. \
		Nocny Strażnik był człowiekiem szczególnym, zawsze czuwającym."
	action_to_add = /datum/action/cooldown/spell/aoe/fiery_rebirth
	cost = 2
	research_tree_icon_frame = 5
	is_final_knowledge = TRUE
	max_charges = 3
	focus_recharge_amount = 0.33
	holywater_drain_amount = 0.16

/datum/heretic_knowledge/ultimate/ash_final
	name = "Ashlord's Rite"
	desc = "Rytuał wniebowstąpienia Ścieżki Popiołu.<br>\
		Po jego ukończeniu stajesz się zwiastunem płomieni i zyskujesz dwie zdolności.<br>\
		Cascade, która tworzy wokół ciebie ogromny, rosnący pierścień ognia, \
		oraz Oath of Flame, przez którą w trakcie chodzenia otacza cię pierścień płomieni.<br>\
		Stajesz się też odporny na ogień, próżnię i podobne zagrożenia środowiska."
	transmute_text = "Przemień 3 płonące albo zwęglone zwłoki."
	gain_text = "Straż jest martwa, Nocny Strażnik spłonął razem z nią. Lecz jego ogień płonie wiecznie, \
		bo Nocny Strażnik dał ludzkości ten rytuał! Jego spojrzenie trwa, bo teraz jestem jednym z płomieniami, \
		UJRZYJCIE MOJE WNIEBOWSTĄPIENIE, POPIELNA LATARNIA ZNÓW PŁONIE!"

	ascension_achievement = /datum/award/achievement/misc/ash_ascension
	announcement_text = "%SPOOKY% Lękajcie się pożogi, bo Władca Popiołu, %NAME%, dostąpił wniebowstąpienia! Płomienie pochłoną wszystko! %SPOOKY%"
	announcement_sound = 'aquila/sound/music/antag/heretic/ascend_ash.ogg'
	/// A static list of all traits we apply on ascension.
	var/static/list/traits_to_apply = list(
		TRAIT_BOMBIMMUNE,
		TRAIT_NOBREATH,
		TRAIT_NOFIRE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
	)

/datum/heretic_knowledge/ultimate/ash_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return

	if(sacrifice.on_fire)
		return TRUE
	// AQUILA - u nas spalone ciało dostaje husk ze źródła "burn" (BURN to u nas "fire")
	if(HAS_TRAIT_FROM(sacrifice, TRAIT_HUSK, "burn"))
		return TRUE
	return FALSE

/datum/heretic_knowledge/ultimate/ash_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	var/datum/action/cooldown/spell/fire_sworn/circle_spell = new(user.mind)
	circle_spell.Grant(user)

	var/datum/action/cooldown/spell/fire_cascade/big/screen_wide_fire_spell = new(user.mind)
	screen_wide_fire_spell.Grant(user)

	var/datum/action/cooldown/spell/charged/beam/fire_blast/existing_beam_spell = locate() in user.actions
	if(existing_beam_spell)
		existing_beam_spell.max_beam_bounces *= 2 // Double beams
		existing_beam_spell.beam_duration *= 0.66 // Faster beams
		existing_beam_spell.cooldown_time *= 0.66 // Lower cooldown

	var/datum/action/cooldown/spell/aoe/fiery_rebirth/fiery_rebirth = locate() in user.actions
	fiery_rebirth?.cooldown_time *= 0.16

	user.add_traits(traits_to_apply, type)

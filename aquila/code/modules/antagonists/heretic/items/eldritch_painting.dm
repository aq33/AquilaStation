// The basic eldritch painting
/obj/item/wallframe/painting/eldritch
	name = "The Blank Canvas: A Study in Default Subtypes"
	desc = "Niemożliwy obraz z niemożliwej farby. Nie powinien istnieć w tej rzeczywistości."
	icon = 'aquila/icons/obj/signs.dmi'
	resistance_flags = FLAMMABLE
	flags_1 = NONE
	icon_state = "eldritch_painting_debug"
	result_path = /obj/structure/sign/painting/eldritch
	materials = list()

/obj/structure/sign/painting/eldritch
	name = "The Blank Canvas: A Study in Default Subtypes"
	desc = "Niemożliwy obraz z niemożliwej farby. Nie powinien istnieć w tej rzeczywistości."
	icon = 'aquila/icons/obj/signs.dmi'
	icon_state = "eldritch_painting_debug"
	resistance_flags = FLAMMABLE
	buildable_sign = FALSE
	// Set to false since we don't want this to persist
	persistence_id = null
	/// The trauma the painting applies
	var/applied_status_effect = /datum/status_effect/eldritch_painting
	/// The text that shows up when you cross the paintings path
	var/text_to_display = "Niektórych rzeczy nie powinny oglądać śmiertelne oczy..."
	/// The range of the paintings effect
	var/range = 7

/obj/structure/sign/painting/eldritch/Initialize(mapload, dir, building)
	. = ..()
	if(ispath(applied_status_effect))
		var/static/list/connections = list(COMSIG_ATOM_ENTERED = PROC_REF(apply_status_effect))
		AddComponent(/datum/component/connect_range, src, connections, range, FALSE)

// AQUILA - nasza rama zmienia ikonę zależnie od płótna, a tu obraz jest w ikonie
/obj/structure/sign/painting/eldritch/update_icon_state()
	. = ..()
	icon_state = initial(icon_state)

/obj/structure/sign/painting/eldritch/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/canvas))
		return
	return ..()

/obj/structure/sign/painting/eldritch/proc/apply_status_effect(datum/source, mob/living/carbon/viewer)
	SIGNAL_HANDLER
	if(!isliving(viewer) || !can_see(viewer, src, range))
		return
	if(isnull(viewer.mind) || !viewer.get_mood() || IS_UNCONSCIOUS_OR_CRIT(viewer) || viewer.is_blind())
		return
	if(viewer.has_status_effect(applied_status_effect))
		return
	if(IS_HERETIC(viewer))
		return
	if(viewer.can_block_magic(MAGIC_RESISTANCE_MOON))
		return
	if(viewer.reagents?.has_reagent(/datum/reagent/water/holywater))
		return
	to_chat(viewer, span_notice(text_to_display))
	viewer.apply_status_effect(applied_status_effect)
	INVOKE_ASYNC(viewer, TYPE_PROC_REF(/mob, emote), "scream")
	to_chat(viewer, span_hypnophrase("Twój umysł ulega! Obraz zostawia ślad na twojej psychice."))

/obj/structure/sign/painting/eldritch/wirecutter_act(mob/living/user, obj/item/I)
	if(!user.can_block_magic(MAGIC_RESISTANCE_MOON))
		user.add_mood_event("ripped_eldritch_painting", /datum/mood_event/eldritch_painting)
		to_chat(user, span_hypnophrase("Coś swędzi cię w mózgu. Śmieje się z ciebie..."))
	qdel(src)
	return TRUE

// On examine eldritch paintings give a trait so their effects can not be spammed
/obj/structure/sign/painting/eldritch/examine(mob/user)
	. = ..()
	if(!iscarbon(user))
		return
	if(HAS_TRAIT(user, TRAIT_ELDRITCH_PAINTING_EXAMINE))
		return

	ADD_TRAIT(user, TRAIT_ELDRITCH_PAINTING_EXAMINE, REF(src))
	addtimer(TRAIT_CALLBACK_REMOVE(user, TRAIT_ELDRITCH_PAINTING_EXAMINE, REF(src)), 3 MINUTES)
	addtimer(CALLBACK(src, PROC_REF(examine_effects), user), 0.2 SECONDS)

/obj/structure/sign/painting/eldritch/proc/examine_effects(mob/living/carbon/examiner)
	if(IS_HERETIC(examiner))
		to_chat(examiner, span_notice("Cóż za zajmujący obraz!"))
	else
		to_chat(examiner, span_notice("Co za dziwny obraz..."))

// The Sister and He Who Wept eldritch painting
/obj/item/wallframe/painting/eldritch/weeping
	name = "\improper The Sister and He Who Wept"
	desc = "Piękny obraz przedstawiający urodziwą damę siedzącą obok Niego. On płacze. Jeszcze Go zobaczysz."
	icon_state = "eldritch_painting_weeping"
	result_path = /obj/structure/sign/painting/eldritch/weeping

/obj/structure/sign/painting/eldritch/weeping
	name = "\improper The Sister and He Who Wept"
	desc = "Piękny obraz przedstawiający urodziwą damę siedzącą obok Niego. On płacze. Jeszcze Go zobaczysz. Można go zdjąć nożycami do drutu."
	icon_state = "eldritch_painting_weeping"
	applied_status_effect = /datum/status_effect/eldritch_painting/weeping
	text_to_display = "Co za piękno! Co za smutek!"

/obj/structure/sign/painting/eldritch/weeping/examine_effects(mob/living/carbon/examiner)
	if(!IS_HERETIC(examiner))
		to_chat(examiner, span_hypnophrase("Wytchnienie, na razie..."))
		examiner.clear_mood_event("eldritch_weeping")
		examiner.add_mood_event("weeping_withdrawal", /datum/mood_event/eldritch_painting/weeping_withdrawal)
		return

	to_chat(examiner, span_notice("Samo patrzenie na niego oczyszcza ci umysł."))
	examiner.hallucination = 0
	examiner.add_mood_event("heretic_eldritch_painting", /datum/mood_event/eldritch_painting/weeping_heretic)

// The First Desire painting, using a lot of the painting/eldritch framework
/obj/item/wallframe/painting/eldritch/desire
	name = "\improper The Feast of Desire"
	desc = "Obraz wystawnej uczty. Choć składa się wyłącznie z gnijącego mięsa i rozkładających się organów, jedzenie wygląda bardzo apetycznie."
	icon_state = "eldritch_painting_desire"
	result_path = /obj/structure/sign/painting/eldritch/desire

/obj/structure/sign/painting/eldritch/desire
	name = "\improper The Feast of Desire"
	desc = "Obraz wystawnej uczty. Choć składa się wyłącznie z gnijącego mięsa i rozkładających się organów, jedzenie wygląda bardzo apetycznie. Można go zdjąć nożycami do drutu."
	icon_state = "eldritch_painting_desire"
	applied_status_effect = /datum/status_effect/eldritch_painting/desire
	text_to_display = "Od samego patrzenia na ten obraz robię się głodny..."

// The special examine interaction for this painting
/obj/structure/sign/painting/eldritch/desire/examine_effects(mob/living/carbon/examiner)
	if(!IS_HERETIC(examiner))
		// Gives them some nutrition
		examiner.adjust_nutrition(50)
		to_chat(examiner, span_warning("Czujesz piekący ból w żołądku!"))
		examiner.adjustOrganLoss(ORGAN_SLOT_STOMACH, 5)
		to_chat(examiner, span_notice("Czujesz się mniej głodny."))
		to_chat(examiner, span_warning("Zanim znów zgłodniejesz, lepiej zgromadź surowe mięso i organy."))
		examiner.add_mood_event("respite_eldritch_hunger", /datum/mood_event/eldritch_painting/desire_examine)
		return

	// A list made of the organs and bodyparts the heretic can get
	var/static/list/random_bodypart_or_organ = list(
		/obj/item/organ/brain,
		/obj/item/organ/lungs,
		/obj/item/organ/eyes,
		/obj/item/organ/ears,
		/obj/item/organ/heart,
		/obj/item/organ/liver,
		/obj/item/organ/stomach,
		/obj/item/organ/appendix,
		/obj/item/bodypart/l_arm,
		/obj/item/bodypart/r_arm,
		/obj/item/bodypart/l_leg,
		/obj/item/bodypart/r_leg
	)
	var/organ_or_bodypart_to_spawn = pick(random_bodypart_or_organ)
	new organ_or_bodypart_to_spawn(drop_location())
	to_chat(examiner, span_notice("Z obrazu wypełza kawałek ciała i plaska o podłogę."))
	to_chat(examiner, span_warning("Pustka krzyczy!"))
	// Adds a negative mood event to our heretic
	examiner.add_mood_event("heretic_eldritch_hunger", /datum/mood_event/eldritch_painting/desire_heretic)

// Great chaparral over rolling hills, this one doesn't have the sensor type
/obj/item/wallframe/painting/eldritch/vines
	name = "\improper Great Chaparral Over Rolling Hills"
	desc = "Obraz przedstawiający ogromną gęstwinę. Tętni życiem i zdaje się napierać na ramę."
	icon_state = "eldritch_painting_vines"
	result_path = /obj/structure/sign/painting/eldritch/vines

/obj/structure/sign/painting/eldritch/vines
	name = "\improper Great Chaparral Over Rolling Hills"
	desc = "Obraz przedstawiający ogromną gęstwinę. Tętni życiem i zdaje się napierać na ramę. Można go zdjąć nożycami do drutu."
	icon_state = "eldritch_painting_vines"
	applied_status_effect = null
	// AQUILA - u nas mutacje pnączy podaje się jako gotowe obiekty; agresywne rozrastanie i utwardzenie zamienione na pożeranie pnączy i zdrewnienie
	var/static/list/mutation_types = list(
		/datum/spacevine_mutation/vine_eating,
		/datum/spacevine_mutation/fire_proof,
		/datum/spacevine_mutation/woodening,
		/datum/spacevine_mutation/thorns,
		/datum/spacevine_mutation/toxicity,
	)
	// Poppy and harebell are used in heretic rituals
	var/list/items_to_spawn = list(
		/obj/item/food/grown/poppy,
		/obj/item/food/grown/harebell,
	)

/obj/structure/sign/painting/eldritch/vines/Initialize(mapload, dir, building)
	. = ..()
	if(!mapload)
		spawn_vines(get_turf(src))

/// Sieje kudzu z mocnymi mutacjami
/obj/structure/sign/painting/eldritch/vines/proc/spawn_vines(turf/location)
	var/list/mutations = list()
	for(var/mutation_type in mutation_types)
		mutations += new mutation_type()
	new /datum/spacevine_controller(location, mutations, 0, 10)

/obj/structure/sign/painting/eldritch/vines/examine_effects(mob/living/carbon/examiner)
	if(!IS_HERETIC(examiner))
		spawn_vines(get_turf(examiner))
		to_chat(examiner, span_hypnophrase("Na chwilę zastygasz, wpatrzony w pnącza na obrazie."))
		to_chat(examiner, span_notice("Czujesz, jak coś wije się wokół ciebie."))
		return

	var/item_to_spawn = pick(items_to_spawn)
	to_chat(examiner, span_notice("Na chwilę zastygasz, wpatrzony w chaotyczne wzory pnączy."))
	to_chat(examiner, span_notice("Czujesz, jak pod tobą zbiera się i rozkwita życie."))
	new item_to_spawn(examiner.drop_location())
	examiner.add_mood_event("heretic_vines", /datum/mood_event/eldritch_painting/heretic_vines)


// Lady out of gates, gives a brain trauma causing the person to scratch themselves
/obj/item/wallframe/painting/eldritch/beauty
	name = "\improper Lady of the Gate"
	desc = "Obraz nieziemskiej istoty. Cienka, porcelanowa skóra jest ciasno naciągnięta na dziwną budowę kości. Ma w sobie osobliwe piękno."
	icon_state = "eldritch_painting_beauty"
	result_path = /obj/structure/sign/painting/eldritch/beauty

/obj/structure/sign/painting/eldritch/beauty
	name = "\improper Lady of the Gate"
	desc = "Obraz nieziemskiej istoty. Cienka, porcelanowa skóra jest ciasno naciągnięta na dziwną budowę kości. Ma w sobie osobliwe piękno. Można go zdjąć nożycami do drutu."
	icon_state = "eldritch_painting_beauty"
	applied_status_effect = /datum/status_effect/eldritch_painting/beauty
	text_to_display = "Latarnia czystości - prawdziwy świat wydaje się przy niej taki przyziemny i niedoskonały..."
	/// List of reagents to add to heretics on examine, set to mutadone by default to remove mutations
	var/list/reagents_to_add = list(/datum/reagent/medicine/mutadone = 5)

// The special examine interaction for this painting
/obj/structure/sign/painting/eldritch/beauty/examine_effects(mob/living/carbon/examiner)
	if(!examiner.has_dna())
		return

	if(!IS_HERETIC(examiner))
		to_chat(examiner, span_hypnophrase("Nie jesteś jeszcze czysty."))
		examiner.easy_randmut(NEGATIVE + MINOR_NEGATIVE)
		return

	to_chat(examiner, span_notice("Zrzucasz swoje niedoskonałości."))
	examiner.reagents.add_reagent_list(reagents_to_add)

// Climb over the rusted mountain, gives a brain trauma causing the person to randomly rust tiles beneath them
/obj/item/wallframe/painting/eldritch/rust
	name = "\improper Master of the Rusted Mountain"
	desc = "Obraz dziwnej istoty wspinającej się na rdzawą górę. Pociągnięcia pędzla są nienaturalne i niepokojące."
	icon_state = "eldritch_painting_rust"
	result_path = /obj/structure/sign/painting/eldritch/rust

/obj/structure/sign/painting/eldritch/rust
	name = "\improper Master of the Rusted Mountain"
	desc = "Obraz dziwnej istoty wspinającej się na rdzawą górę. Pociągnięcia pędzla są nienaturalne i niepokojące. Można go zdjąć nożycami do drutu."
	icon_state = "eldritch_painting_rust"
	applied_status_effect = /datum/status_effect/eldritch_painting/rusting
	text_to_display = "Rdza rozkłada. Mistrz się wspina. Woła. Ty odpowiadasz..."

// The special examine interaction for this painting
/obj/structure/sign/painting/eldritch/rust/examine_effects(mob/living/carbon/examiner)
	if(!IS_HERETIC(examiner))
		to_chat(examiner, span_hypnophrase("Czujesz rdzę. Zgniliznę."))
		examiner.add_mood_event("rusted_examine", /datum/mood_event/eldritch_painting/rust_examine)
		return

	to_chat(examiner, span_notice("Obraz napełnia cię determinacją."))
	examiner.add_mood_event("rusted_examine", /datum/mood_event/eldritch_painting/rust_heretic_examine)

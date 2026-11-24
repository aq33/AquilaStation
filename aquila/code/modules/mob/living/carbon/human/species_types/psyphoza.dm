// Psyfoza z BeeStation-Hornet (code/modules/mob/living/carbon/human/species_types/psyphoza.dm).
// Ślepy grzybowy humanoid, który widzi otoczenie zmysłem psychicznym. U Bee ślepota i zmysł opierają się
// na nowym systemie ślepoty (status effect, blind_sense, płaszczyzna ANTI_PSYCHIC). U nas: zwykła ślepota
// (TRAIT_BLIND) z własną nakładką ekranu, a podświetlenie psychiczne to nakładki na płaszczyźnie pełnoekranowej.
/// Jak długo trwa wzmocniony zmysł po impulsie
#define PSYPHOZA_SENSE_TIME (10 SECONDS)
/// Ile razy rośnie pierścień podświetlenia przy impulsie
#define PSYPHOZA_SENSE_SCALE 2.28

/datum/species/psyphoza
	name = "\improper Psyfoza"
	id = SPECIES_PSYPHOZA
	sexes = FALSE
	default_color = "FFFFFF" // kapelusz ma własne kolory, kolor mutanta je mnoży
	species_traits = list(MUTCOLORS_PARTSONLY, AGENDER, NOEYESPRITES)
	inherent_traits = list(TRAIT_PSYCHIC_SENSE)
	mutant_bodyparts = list(FEATURE_PSYPHOZA_CAP)
	default_features = list(FEATURE_PSYPHOZA_CAP = "Portobello", "body_size" = "Normal")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP
	species_language_holder = /datum/language_holder/psyphoza
	exotic_blood = /datum/reagent/drug/mushroomhallucinogen
	allow_numbers_in_name = TRUE
	inert_mutation = /datum/mutation/spores
	meat = /obj/item/food/meat/slab/human/mutant/psyphoza
	use_skintones = FALSE
	burnmod = 1.25 // U Bee burn_modifier 1.25 na każdej kończynie
	mutant_brain = /obj/item/organ/brain/psyphoza
	mutanteyes = /obj/item/organ/eyes/psyphoza
	mutanttongue = /obj/item/organ/tongue/psyphoza
	// Głowa pod kapeluszem jest niska, więc to, co nosi się na głowie, siedzi niżej (u Bee offset_y -2/-3)
	offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,-2), OFFSET_EARS = list(0,-3), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,-2), OFFSET_HEAD = list(0,-2), OFFSET_FACE = list(0,-2), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0), OFFSET_RIGHT_HAND = list(0,0), OFFSET_LEFT_HAND = list(0,0))

	species_chest = /obj/item/bodypart/chest/psyphoza
	species_head = /obj/item/bodypart/head/psyphoza
	species_l_arm = /obj/item/bodypart/l_arm/psyphoza
	species_r_arm = /obj/item/bodypart/r_arm/psyphoza
	species_l_leg = /obj/item/bodypart/l_leg/psyphoza
	species_r_leg = /obj/item/bodypart/r_leg/psyphoza

/mob/living/carbon/human/species/psyphoza
	race = /datum/species/psyphoza

// Pliki w pojedynczych cudzysłowach trafiają do .rsc, więc działają też po tools/deploy.sh (ten nie kopiuje aquila/strings)
GLOBAL_LIST_INIT(psyphoza_first_names, splittext(trim(file2text('aquila/strings/names/psyphoza_first.txt')), "\n"))
GLOBAL_LIST_INIT(psyphoza_last_names, splittext(trim(file2text('aquila/strings/names/psyphoza_last.txt')), "\n"))

/datum/species/psyphoza/random_name(gender, unique, lastname, attempts)
	for(var/i in 1 to (unique ? (attempts || 10) : 1))
		. = "[pick(GLOB.psyphoza_first_names)] [lastname || pick(GLOB.psyphoza_last_names)]"
		if(!unique || !findname(.))
			return

/datum/species/psyphoza/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	if(ishuman(C))
		bee_sanitize_features(C)
	return ..()

/// U Bee: każdy narkotyk uzupełnia krew psyfozy
/datum/species/psyphoza/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	. = ..()
	if(.)
		return
	if(istype(chem, /datum/reagent/drug) && H.blood_volume < BLOOD_VOLUME_NORMAL)
		H.blood_volume = min(H.blood_volume + chem.volume * 15, BLOOD_VOLUME_NORMAL)

/datum/species/psyphoza/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	. = ..()
	bee_add_feature_overlays(H, list(FEATURE_PSYPHOZA_CAP), forced_colour)

/datum/species/psyphoza/get_species_description()
	return "Psyfozy to pozazmysłowy, a zarazem niedozmysłowy gatunek grzybowych humanoidów, \
		znany z odporności na sztuczki magiczne oparte na zasłanianiu i na zręczność rąk."

/datum/species/psyphoza/get_species_lore()
	return list(
		"Psyfozy, żywy dowód poczucia humoru matki natury, wykształciły potężne i mistyczne zdolności psychiczne, \
			które niemal całkowicie niweczy fakt, że są zupełnie ślepe i w poruszaniu się po otoczeniu \
			polegają wyłącznie na swoich zdolnościach psychicznych.",
		"Kultura psyfoz jest głęboko zakorzeniona w przesądach, mistycyzmie i okultyzmie. Wierzą, \
			że kształt kapelusza głęboko wpływa na bieg życia, a jego rozmiar, barwa i kształt decydują o tym, \
			ile szczęścia lub pecha ich spotka.",
		"Niefortunny przesąd, że „mięso” i „krew” psyfoz zawierają potężne psychodeliki, sprawił, że wiele z nich \
			stało się celem polowań bogatych ekscentryków, którzy chcą skosztować ich ciała i sami poznać prawdę. \
			Na nieszczęście dla psyfoz ten przesąd jest całkowicie prawdziwy...",
		"Choć większość psyfoz porzuciła najbardziej zabobonne idee przodków, niektórzy członkowie niższych kast \
			wciąż kurczowo się ich trzymają. Te wierzenia mocno wpływają na ich kulturę, przez co zachowanie \
			typowych psyfoz i niższych kast bardzo się różni.",
	)

/datum/species/psyphoza/create_pref_unique_perks()
	return list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "lightbulb",
			SPECIES_PERK_NAME = "Psychika",
			SPECIES_PERK_DESC = "Psyfozy mają zdolności psychiczne i wyczuwają to, czego inni nie dostrzegą.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "biohazard",
			SPECIES_PERK_NAME = "Współzależność od narkotyków",
			SPECIES_PERK_DESC = "Każdy przyjęty narkotyk uzupełnia krew psyfozy.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "eye",
			SPECIES_PERK_NAME = "Ślepota",
			SPECIES_PERK_DESC = "Psyfozy są ślepe i poza najbliższym otoczeniem widzą tylko to, co wyczują zmysłem psychicznym.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "eye",
			SPECIES_PERK_NAME = "Ostrzeżenie o epilepsji",
			SPECIES_PERK_DESC = "Ten gatunek ma efekty, które mogą źle działać na osoby z padaczką!",
		),
	)

// Części ciała: gotowe kolory, bez barwienia kolorem mutanta (u Bee should_draw_greyscale = FALSE)
/obj/item/bodypart/head/psyphoza
	is_dimorphic = FALSE
	static_icon = 'aquila/icons/mob/species/psyphoza/bodyparts.dmi'
	icon = 'aquila/icons/mob/species/psyphoza/bodyparts.dmi'
	limb_id = SPECIES_PSYPHOZA
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE

/obj/item/bodypart/chest/psyphoza
	is_dimorphic = FALSE
	static_icon = 'aquila/icons/mob/species/psyphoza/bodyparts.dmi'
	icon = 'aquila/icons/mob/species/psyphoza/bodyparts.dmi'
	limb_id = SPECIES_PSYPHOZA
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE

/obj/item/bodypart/l_arm/psyphoza
	static_icon = 'aquila/icons/mob/species/psyphoza/bodyparts.dmi'
	icon = 'aquila/icons/mob/species/psyphoza/bodyparts.dmi'
	limb_id = SPECIES_PSYPHOZA
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE

/obj/item/bodypart/r_arm/psyphoza
	static_icon = 'aquila/icons/mob/species/psyphoza/bodyparts.dmi'
	icon = 'aquila/icons/mob/species/psyphoza/bodyparts.dmi'
	limb_id = SPECIES_PSYPHOZA
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE

/obj/item/bodypart/l_leg/psyphoza
	static_icon = 'aquila/icons/mob/species/psyphoza/bodyparts.dmi'
	icon = 'aquila/icons/mob/species/psyphoza/bodyparts.dmi'
	limb_id = SPECIES_PSYPHOZA
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE

/obj/item/bodypart/r_leg/psyphoza
	static_icon = 'aquila/icons/mob/species/psyphoza/bodyparts.dmi'
	icon = 'aquila/icons/mob/species/psyphoza/bodyparts.dmi'
	limb_id = SPECIES_PSYPHOZA
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE

// Organy

/obj/item/organ/brain/psyphoza
	name = "mózg psyfozy"
	desc = "Bulgocze energią psychiczną... nie, czekaj... to krew."
	color = "#ff00ee"

/obj/item/organ/tongue/psyphoza
	name = "grzybowy język"
	desc = "Czarny i spleśniały."
	icon = 'aquila/icons/mob/species/psyphoza/organs.dmi'
	icon_state = "tonguepsyphoza"
	say_mod = "klika"
	color = "#1b1b1b"
	liked_food = RAW | GROSS
	disliked_food = DAIRY

/obj/item/organ/tongue/psyphoza/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_base.Copy()
	languages_possible[/datum/language/sonus] = TRUE

/datum/language_holder/psyphoza
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/sonus = list(LANGUAGE_ATOM),
								/datum/language/sylvan = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
							/datum/language/sonus = list(LANGUAGE_ATOM),
							/datum/language/sylvan = list(LANGUAGE_ATOM))

/// Język psyfoz z Bee (sonus.dm): kliknięcia i niesłyszalne gwizdy
/datum/language/sonus
	name = "Sonus"
	desc = "Zbiór kliknięć i niesłyszalnych gwizdów, którym porozumiewają się istoty pozazmysłowe."
	speech_verb = "klika"
	ask_verb = "klika pytająco"
	exclaim_verb = "gwiżdże"
	key = "j" // U Bee "f", u nas zajęte
	space_chance = 20
	syllables = list(
		"sa", "sá", "se", "sé", "si", "sí", "so", "só", "sö", "su", "sú", "sy", "sý", // gwizdy
		"ta", "tá", "te", "té", "ti", "tí", "to", "tó", "tö", "tu", "tú", "ty", "tý", // kliknięcia
	)
	icon = 'aquila/icons/mob/species/psyphoza/language.dmi'
	icon_state = "sonus"
	default_priority = 90

/// Oczy psyfozy: właściciel jest ślepy, ale dostaje zmysł psychiczny
/obj/item/organ/eyes/psyphoza
	name = "oczy psyfozy"
	desc = "Przewodniki energii psychicznej, ledwie przypominające oczy."
	icon = 'aquila/icons/mob/species/psyphoza/organs.dmi'
	icon_state = "psyphoza_eyeballs"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

/obj/item/organ/eyes/psyphoza/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = FALSE, initialising)
	. = ..()
	psyphoza_blind(M)
	RegisterSignal(M, COMSIG_MOVABLE_HEAR, PROC_REF(on_hear), override = TRUE)
	for(var/action_type in list(/datum/action/cooldown/psyphoza_sense, /datum/action/innate/psyphoza_visual, /datum/action/innate/psyphoza_texture, /datum/action/innate/psyphoza_auto))
		if(locate(action_type) in M.actions)
			continue
		var/datum/action/action = new action_type(src)
		action.Grant(M)

/obj/item/organ/eyes/psyphoza/Remove(mob/living/carbon/M, special = FALSE)
	UnregisterSignal(M, COMSIG_MOVABLE_HEAR)
	for(var/datum/action/action as anything in M.actions.Copy())
		if(action.target == src)
			qdel(action)
	M.clear_fullscreen("psychic_highlight", FALSE)
	M.clear_fullscreen("psychic_mask", FALSE)
	M.cure_blind(PSYPHOZA_BLINDNESS_SOURCE)
	if(istype(M.screens["blind"], /atom/movable/screen/fullscreen/blind/psychic))
		if(HAS_TRAIT(M, TRAIT_BLIND) || M.eye_blind)
			M.overlay_fullscreen("blind", /atom/movable/screen/fullscreen/blind)
		else
			M.clear_fullscreen("blind", FALSE)
	return ..()

/// Pełne leczenie zdejmuje każdą ślepotę, więc oczy zakładają ją z powrotem
/obj/item/organ/eyes/psyphoza/on_life()
	. = ..()
	if(owner?.stat >= UNCONSCIOUS) // nieprzytomna psyfoza nie widzi nic, jak każda inna rasa
		if(!istype(owner.screens["blind"], /atom/movable/screen/fullscreen/blind) || istype(owner.screens["blind"], /atom/movable/screen/fullscreen/blind/psychic))
			owner.clear_fullscreen("psychic_mask", FALSE)
			owner.clear_fullscreen("psychic_highlight", FALSE)
			owner.overlay_fullscreen("blind", /atom/movable/screen/fullscreen/blind)
		return
	if(owner && (!HAS_TRAIT_FROM(owner, TRAIT_BLIND, PSYPHOZA_BLINDNESS_SOURCE) || !istype(owner.screens["blind"], /atom/movable/screen/fullscreen/blind/psychic)))
		psyphoza_blind(owner)

/// Ślepota z psychiczną nakładką zamiast czarnej
/obj/item/organ/eyes/psyphoza/proc/psyphoza_blind(mob/living/carbon/M)
	M.become_blind(PSYPHOZA_BLINDNESS_SOURCE)
	M.overlay_fullscreen("blind", /atom/movable/screen/fullscreen/blind/psychic)
	M.overlay_fullscreen("psychic_mask", /atom/movable/screen/fullscreen/psychic_mask)
	M.overlay_fullscreen("psychic_highlight", /atom/movable/screen/fullscreen/psychic_highlight)

/// Impuls psychiczny: większy zasięg podświetlenia na 10 sekund i sylwetki żywych istot w pobliżu, także za ścianami
/obj/item/organ/eyes/psyphoza/proc/psychic_pulse()
	if(!owner || owner.stat != CONSCIOUS)
		return FALSE
	if(istype(owner.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/helmet))
		to_chat(owner, "<span class='warning'>W hełmie nie możesz użyć swoich zmysłów!</span>")
		return FALSE
	var/atom/movable/screen/fullscreen/blind/psychic/blind_screen = owner.screens["blind"]
	if(istype(blind_screen))
		// Zmiana koloru zamiast przezroczystości, inaczej odsłoniłoby to prawdziwe otoczenie
		animate(blind_screen, color = COLOR_BLACK)
		animate(blind_screen, color = blind_screen.origin_color, time = PSYPHOZA_SENSE_TIME, easing = SINE_EASING, flags = EASE_IN)
	var/atom/movable/screen/fullscreen/psychic_mask/mask = owner.screens["psychic_mask"]
	if(istype(mask))
		var/matrix/bigger = matrix()
		bigger.Scale(PSYPHOZA_SENSE_SCALE)
		animate(mask, transform = bigger)
		animate(mask, transform = matrix(), time = PSYPHOZA_SENSE_TIME, easing = SINE_EASING, flags = EASE_IN)
	for(var/mob/living/nearby in urange(9, owner, TRUE))
		if(nearby == owner)
			continue
		psychic_ping(nearby)
	return TRUE

/// Biała sylwetka istoty widoczna przez nakładkę ślepoty, gasnąca przez 5 sekund
/obj/item/organ/eyes/psyphoza/proc/psychic_ping(atom/movable/target)
	var/client/viewer = owner?.client
	var/turf/target_turf = get_turf(target)
	if(!viewer || !target_turf)
		return
	var/image/silhouette = image(loc = target_turf)
	silhouette.appearance = target.appearance
	silhouette.loc = target_turf
	silhouette.dir = target.dir
	silhouette.plane = FULLSCREEN_PLANE
	silhouette.layer = BLIND_LAYER + 0.2
	silhouette.appearance_flags = KEEP_TOGETHER | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	silhouette.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	silhouette.color = list(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 1,1,1,0)
	silhouette.transform = target.transform
	viewer.images += silhouette
	animate(silhouette, alpha = 0, time = 5 SECONDS, easing = QUAD_EASING, flags = EASE_IN)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(psyphoza_remove_image), viewer, silhouette), 5 SECONDS)

/proc/psyphoza_remove_image(client/viewer, image/silhouette)
	viewer?.images -= silhouette

/// U Bee słyszany mówca też zapala się na chwilę (blind_sense)
/obj/item/organ/eyes/psyphoza/proc/on_hear(datum/source, list/hearing_args)
	SIGNAL_HANDLER
	var/atom/movable/speaker = hearing_args[HEARING_SPEAKER]
	if(!isliving(speaker) || speaker == owner || !owner || owner.stat != CONSCIOUS)
		return
	var/obj/item/organ/ears/ears = owner.getorganslot(ORGAN_SLOT_EARS)
	if(ears?.deaf)
		return
	var/dist = get_dist(owner, speaker)
	if(dist > 1 && dist <= 8)
		psychic_ping(speaker)

// Nakładki ekranu (u Bee icons/hud/fullscreen/psychic.dmi)

/// Ślepota psyfozy: ciemna tekstura z dziurą na najbliższe otoczenie
/atom/movable/screen/fullscreen/blind/psychic
	icon = 'aquila/icons/mob/species/psyphoza/psychic.dmi'
	icon_state = "trip"
	/// Kolor, do którego tekstura wraca po impulsie
	var/origin_color = "#111"
	var/texture_index = 1

/atom/movable/screen/fullscreen/blind/psychic/Initialize(mapload)
	. = ..()
	color = origin_color
	filters += filter(type = "radial_blur", size = 0.0125)

/atom/movable/screen/fullscreen/blind/psychic/proc/cycle_textures()
	texture_index = texture_index % 3 + 1
	color = origin_color
	switch(texture_index)
		if(1)
			icon_state = "trip"
		if(2)
			icon_state = "trip_static"
		if(3)
			icon_state = "trip_static_hole"
			color = COLOR_BLACK

/// Pierścień, w którym widać podświetlenie. Rośnie przy impulsie. Rysowany tylko jako maska.
/atom/movable/screen/fullscreen/psychic_mask
	icon = 'aquila/icons/mob/species/psyphoza/psychic.dmi'
	icon_state = "mask_small"
	layer = BLIND_LAYER
	render_target = "*psyphoza_mask"

/// Bez skalowania do szerokiego ekranu: maska i podświetlenie muszą pokrywać się 1:1 ze światem
/atom/movable/screen/fullscreen/psychic_mask/update_for_view(client_view)
	return

/// Kształty z płaszczyzny gry w pierścieniu maski, w kolorach tęczy
/atom/movable/screen/fullscreen/psychic_highlight
	icon = 'aquila/icons/mob/species/psyphoza/psychic.dmi'
	icon_state = "trip"
	layer = BLIND_LAYER + 0.1
	var/visual_index = 1
	var/texture_index = 1

/atom/movable/screen/fullscreen/psychic_highlight/Initialize(mapload)
	. = ..()
	filters += filter(type = "alpha", render_source = GAME_PLANE_RENDER_TARGET)
	filters += filter(type = "alpha", render_source = "*psyphoza_mask")
	filters += filter(type = "bloom", size = 2, threshold = rgb(85, 85, 85))
	filters += filter(type = "radial_blur", size = 0.0125)
	rainbow()

/atom/movable/screen/fullscreen/psychic_highlight/update_for_view(client_view)
	return

/atom/movable/screen/fullscreen/psychic_highlight/proc/rainbow()
	color = COLOR_RED
	animate(src, color = COLOR_YELLOW, time = 1 SECONDS, loop = -1)
	animate(color = "#00FF00", time = 1 SECONDS)
	animate(color = COLOR_CYAN, time = 1 SECONDS)
	animate(color = COLOR_BLUE, time = 1 SECONDS)
	animate(color = COLOR_MAGENTA, time = 1 SECONDS)
	animate(color = COLOR_RED, time = 1 SECONDS)

/// Tęcza albo własny kolor
/atom/movable/screen/fullscreen/psychic_highlight/proc/cycle_visuals(mob/user)
	visual_index = visual_index % 2 + 1
	animate(src)
	if(visual_index == 1)
		rainbow()
		return
	var/new_color = tgui_color_picker(user, "Wybierz kolor zmysłu psychicznego", "Kolor zmysłu", COLOR_WHITE)
	if(QDELETED(src))
		return
	color = new_color || COLOR_WHITE

/atom/movable/screen/fullscreen/psychic_highlight/proc/cycle_textures()
	texture_index = texture_index % 3 + 1
	switch(texture_index)
		if(1)
			icon_state = "trip"
		if(2)
			icon_state = "trip_static"
		if(3)
			icon_state = "trip_static_white"

// Akcje

/datum/action/cooldown/psyphoza_sense
	name = "Zmysł psychiczny"
	desc = "Wyczuj psychicznie otoczenie."
	icon_icon = 'aquila/icons/mob/species/psyphoza/actions.dmi'
	button_icon_state = "activate_psychic"
	cooldown_time = 1 SECONDS
	/// Czy impuls powtarza się sam
	var/auto_sense = FALSE

/datum/action/cooldown/psyphoza_sense/Trigger()
	if(!owner || !..())
		return FALSE
	var/obj/item/organ/eyes/psyphoza/eyes = target
	if(!istype(eyes) || !eyes.psychic_pulse())
		return FALSE
	StartCooldown()
	return TRUE

/datum/action/cooldown/psyphoza_sense/proc/auto_sense_loop()
	if(!auto_sense || QDELETED(src) || !owner)
		return
	if(!owner.stat)
		Trigger()
	addtimer(CALLBACK(src, PROC_REF(auto_sense_loop)), cooldown_time + 1, TIMER_UNIQUE) // szybkie wł./wył. nie mnoży pętli

/datum/action/innate/psyphoza_visual
	name = "Zmień zmysł psychiczny"
	desc = "Zmień wygląd swojego zmysłu psychicznego."
	icon_icon = 'aquila/icons/mob/species/psyphoza/actions.dmi'
	button_icon_state = "change_color"

/datum/action/innate/psyphoza_visual/Activate()
	var/atom/movable/screen/fullscreen/psychic_highlight/highlight = owner?.screens["psychic_highlight"]
	if(istype(highlight))
		highlight.cycle_visuals(owner)

/datum/action/innate/psyphoza_texture
	name = "Zmień teksturę psychiczną"
	desc = "Zmień teksturę swojego zmysłu psychicznego."
	icon_icon = 'aquila/icons/mob/species/psyphoza/actions.dmi'
	button_icon_state = "change_texture"

/datum/action/innate/psyphoza_texture/Activate()
	var/atom/movable/screen/fullscreen/psychic_highlight/highlight = owner?.screens["psychic_highlight"]
	if(istype(highlight))
		highlight.cycle_textures()
	var/atom/movable/screen/fullscreen/blind/psychic/blind_screen = owner?.screens["blind"]
	if(istype(blind_screen))
		blind_screen.cycle_textures()

/datum/action/innate/psyphoza_auto
	name = "Samoczynny zmysł psychiczny"
	desc = "Przełącz samoczynne impulsy zmysłu psychicznego."
	icon_icon = 'aquila/icons/mob/species/psyphoza/actions.dmi'
	button_icon_state = "change_generic"

/datum/action/innate/psyphoza_auto/Activate()
	var/datum/action/cooldown/psyphoza_sense/sense = locate() in owner?.actions
	if(!sense)
		return
	sense.auto_sense = !sense.auto_sense
	if(sense.auto_sense)
		to_chat(owner, "<span class='notice'>Twój zmysł psychiczny sam wysyła impulsy.</span>")
	else
		to_chat(owner, "<span class='notice'>Od teraz sam wysyłasz impulsy zmysłu psychicznego.</span>")
	sense.auto_sense_loop()

// Krzyk psyfozy (U Bee get_scream_sound)
/datum/emote/living/carbon/human/scream/get_sound(mob/living/user)
	if(ispsyphoza(user) && !user.mind?.miming)
		return pick_emote_sound(user, list('aquila/sound/voice/psyphoza/psyphoza_scream_1.ogg', 'aquila/sound/voice/psyphoza/psyphoza_scream_2.ogg'))
	return ..()

#undef PSYPHOZA_SENSE_TIME
#undef PSYPHOZA_SENSE_SCALE

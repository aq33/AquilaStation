// AQUILA - efekty drinków z tg (tgstation/tgstation, code/modules/reagents/chemistry/reagents/drinks), przeniesione na nasze API.
//
// Przeliczenie dawek: tg woła on_mob_life co 2 s z seconds_per_tick = 2 i metabolization_ratio = REM_tg * zmetabolizowana objętość.
// U nas on_mob_life jest raz na Life() (co ~2 s), metabolization_rate jest na tyknięcie, a REM = 1.
// Dla reagenta z metabolization_rate = R (na tyknięcie) w tg wychodzi metabolization_ratio = 2.5 * R i ratio * seconds_per_tick = 5 * R
// (domyślny napój 0.4 -> 2, alkohol 0.2 -> 1). Czasy statusów z tg (dziesiąte sekundy) przelicza tg_compat.dm.

/// tg: metabolization_ratio
#define AQ_TG_DRINK_RATIO (2.5 * metabolization_rate)
/// tg: metabolization_ratio * seconds_per_tick
#define AQ_TG_DRINK_RATIO_SPT (5 * metabolization_rate)
/// tg: seconds_per_tick (jedno nasze tyknięcie Life())
#define AQ_TG_DRINK_SPT 2
/// Czas z tg (dziesiąte sekundy) na liczbę naszych tyknięć Life() (jak TG_TIME_TO_LIFE_TICKS z tg_compat.dm, który jest tam #undef)
#define AQ_TG_DRINK_TICKS(time) (CEILING((time) / 20, 1))

/// Ostatnie słowo: niedawno delektował się drinkiem w ciszy
#define TRAIT_HAD_LAST_WORD "had_last_word"
/// Brzytwa piechura: niedawno skaleczył się w wargę
#define TRAIT_HAD_FOOTSOLDIERS_RAZOR "had_footsoldiers_razor"
/// Farstar Amrita: już poczęstował istotę z gwiazd
#define TRAIT_FARSTAR_SHARED "farstar_shared"

// --- Pomocnicze typy (w tg osobne pliki: mood_events/drink_events.dm, status_effects/neutral.dm) ---

/datum/mood_event/aq_wellcheers
	description = "<span class='nicegreen'>Co za smaczna puszka Wellcheers! Słony, winogronowy smak świetnie poprawia humor.</span>\n"
	mood_change = 3
	timeout = 7 MINUTES

/datum/mood_event/aq_farstar_shared
	description = "<span class='nicegreen'>Czuję wdzięczność płynącą skądś bardzo, bardzo daleko.</span>\n"
	mood_change = 3
	timeout = 10 MINUTES

/// tg: cherenkov_radiation - niebieska poświata i rzadkie cząstki jądrowe
/datum/status_effect/aq_cherenkov_radiation
	id = "aq_cherenkov_radiation"
	alert_type = null
	on_remove_on_mob_delete = TRUE
	var/obj/effect/dummy/lighting_obj/moblight/mob_light_obj

/datum/status_effect/aq_cherenkov_radiation/on_apply()
	mob_light_obj = owner.mob_light(2, 4, "#33ddff")
	return TRUE

/datum/status_effect/aq_cherenkov_radiation/tick()
	if(prob(3))
		owner.fire_nuclear_particle()

/datum/status_effect/aq_cherenkov_radiation/on_remove()
	QDEL_NULL(mob_light_obj)

/datum/status_effect/aq_cherenkov_radiation/be_replaced()
	QDEL_NULL(mob_light_obj)
	return ..()

/// tg: thirsty_gazer - istota z gwiazd, którą widzi tylko pijący Farstar Amritę
/obj/effect/client_image_holder/aq_thirsty_gazer
	name = "???"
	desc = "Wygląda na... spragnioną?"
	image_icon = 'aquila/icons/mob/nonhuman-player/96x96eldritch_mobs.dmi'
	image_state = "star_gazer"
	image_pixel_x = -32
	alpha = 0

/obj/effect/client_image_holder/aq_thirsty_gazer/Initialize(mapload, list/mobs_which_see_us)
	. = ..()
	animate(src, alpha = 80, time = 3 SECONDS, easing = CIRCULAR_EASING|EASE_IN, flags = ANIMATION_PARALLEL)

/obj/effect/client_image_holder/aq_thirsty_gazer/generate_image()
	var/image/created = ..()
	created.filters += filter(type = "wave", x = 2, size = 4)
	return created

/obj/effect/client_image_holder/aq_thirsty_gazer/attackby(obj/item/W, mob/user, params)
	if(!istype(W, /obj/item/reagent_containers/food/drinks/drinkingglass))
		return ..()
	if(W.reagents.get_reagent_amount(/datum/reagent/consumable/ethanol/farstar_amrita) < 5) // dobry gospodarz podaje w porządnym szkle, co najmniej 5u
		to_chat(user, span_notice("Masz wrażenie, że czegoś brakuje..."))
		return TRUE

	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user) // heretyk dostaje za to punkt wiedzy
	if(heretic_datum)
		heretic_datum.adjust_knowledge_points(1)
		to_chat(user, "[span_hear("Słyszysz szept...")] [span_mansus("DOWÓD WDZIĘCZNOŚCI.")]")

	playsound(src, 'sound/items/drink.ogg', rand(10, 50), TRUE)
	to_chat(user, span_notice("Mrugasz. Nic tu nie ma i nigdy nie było. A jednak czujesz, że nawiązała się jakaś więź, a twoja szklanka jest jakby lżejsza."))
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.add_mood_event("farstar_shared", /datum/mood_event/aq_farstar_shared)
	ADD_TRAIT(user, TRAIT_FARSTAR_SHARED, /datum/reagent/consumable/ethanol/farstar_amrita)
	W.reagents.remove_reagent(/datum/reagent/consumable/ethanol/farstar_amrita, 5)
	qdel(src)
	return TRUE

// --- Napoje bezalkoholowe ---

/datum/reagent/consumable/mintextract/on_mob_life(mob/living/carbon/M)
	. = ..()
	// AQ: w tg otyła postać od razu wybucha; u nas tylko mdłości i wymioty, bo ekstrakt jest w dyspenserze baru
	if(HAS_TRAIT(M, TRAIT_FAT) && prob(10))
		to_chat(M, span_warning("Ten miętowy listek to było o jeden kęs za dużo..."))
		M.adjust_disgust(10)
		if(prob(50))
			M.vomit(20)

/datum/reagent/consumable/sol_dry/on_mob_life(mob/living/carbon/M)
	M.adjust_disgust(-2.5 * AQ_TG_DRINK_RATIO_SPT)
	return ..()

/datum/reagent/consumable/wellcheers/on_mob_life(mob/living/carbon/M)
	. = ..()
	M.drowsyness = max(M.drowsyness + AQ_TG_DRINK_TICKS(1.5 SECONDS * AQ_TG_DRINK_RATIO_SPT), 0)
	var/datum/component/mood/mood = M.get_mood()
	if(!mood)
		return
	switch(mood.sanity_level)
		if(1 to 2) // tg: SANITY_LEVEL_GREAT to SANITY_LEVEL_NEUTRAL
			M.adjust_brute_loss(-0.75 * AQ_TG_DRINK_RATIO_SPT, updating_health = FALSE)
			. = TRUE
		if(3 to 4) // tg: SANITY_LEVEL_DISTURBED to SANITY_LEVEL_UNSTABLE
			M.add_mood_event("wellcheers", /datum/mood_event/aq_wellcheers)
		if(5 to 6) // tg: SANITY_LEVEL_CRAZY to SANITY_LEVEL_INSANE
			M.adjust_stamina_loss(1.5 * AQ_TG_DRINK_RATIO_SPT, updating_stamina = FALSE)
			. = TRUE

/datum/reagent/consumable/roy_rogers/on_mob_life(mob/living/carbon/M)
	M.set_jitter_if_lower(6 SECONDS * AQ_TG_DRINK_RATIO_SPT)
	M.drowsyness = max(M.drowsyness - AQ_TG_DRINK_TICKS(5 SECONDS * AQ_TG_DRINK_RATIO_SPT), 0)
	M.adjust_bodytemperature(-2.5 * AQ_TG_DRINK_RATIO_SPT * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	return ..()

/datum/reagent/consumable/shirley_temple/on_mob_life(mob/living/carbon/M)
	M.adjust_disgust(-1.5 * AQ_TG_DRINK_RATIO_SPT)
	return ..()

/datum/reagent/consumable/agua_fresca/on_mob_life(mob/living/carbon/M)
	. = ..()
	M.adjust_bodytemperature(-4 * AQ_TG_DRINK_RATIO_SPT * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	if(M.getToxLoss() && DT_PROB(10, AQ_TG_DRINK_SPT))
		M.adjust_tox_loss(-0.25 * AQ_TG_DRINK_RATIO, updating_health = FALSE)
		. = TRUE

/datum/reagent/consumable/cinderella/on_mob_life(mob/living/carbon/M)
	. = ..()
	M.adjust_disgust(-2.5 * AQ_TG_DRINK_RATIO_SPT)

/datum/reagent/consumable/cucumberlemonade/on_mob_life(mob/living/carbon/M)
	. = ..()
	M.adjust_bodytemperature(-4 * AQ_TG_DRINK_RATIO_SPT * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	if(M.getToxLoss() && DT_PROB(10, AQ_TG_DRINK_SPT))
		M.adjust_tox_loss(-0.25 * AQ_TG_DRINK_RATIO, updating_health = FALSE)
		. = TRUE

/datum/reagent/consumable/mississippi_queen/on_mob_life(mob/living/carbon/M)
	. = ..()
	switch(current_cycle)
		if(11 to 21)
			M.adjust_dizzy(2 SECONDS * AQ_TG_DRINK_RATIO_SPT)
		if(21 to 31)
			if(DT_PROB(15, AQ_TG_DRINK_SPT))
				M.adjust_confusion(2 SECONDS * AQ_TG_DRINK_RATIO)
		if(31 to 201)
			M.adjust_hallucinations(30 SECONDS * AQ_TG_DRINK_RATIO_SPT)

/datum/reagent/consumable/t_letter/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(!M.mind?.miming)
		return
	M.silent = max(M.silent, MIMEDRINK_SILENCE_DURATION)
	M.drowsyness = max(M.drowsyness - AQ_TG_DRINK_TICKS(3 SECONDS * AQ_TG_DRINK_RATIO_SPT), 0)
	M.AdjustSleeping(-2 SECONDS * AQ_TG_DRINK_RATIO_SPT)
	if(M.getToxLoss() && DT_PROB(25, AQ_TG_DRINK_SPT))
		M.adjust_tox_loss(-1 * AQ_TG_DRINK_RATIO, updating_health = FALSE)
		. = TRUE

// --- Alkohole ---

/datum/reagent/consumable/ethanol/aperitivo/on_mob_life(mob/living/carbon/M)
	. = ..()
	M.adjust_nutrition(-1 * REM)
	M.overeatduration = 0

/datum/reagent/consumable/ethanol/pina_olivada/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(DT_PROB(8, AQ_TG_DRINK_SPT))
		M.manual_emote(pick("wykasłuje trochę oleju", "z trudem przełyka gulę w gardle", "krztusi się", "lekko się dławi"))
	if(DT_PROB(3, AQ_TG_DRINK_SPT))
		var/static/list/messages = list(
			"Okropny posmak oblepia ci usta.",
			"Masz wrażenie, że zaraz udławisz się olejem w gardle.",
			"Czujesz, że nadchodzi zgaga.",
			"Chce ci się wymiotować, ale wiesz, że nic nie wyjdzie przez zator w przełyku.",
			"Gardło czuje się okropnie.",
		)
		to_chat(M, span_notice(pick(messages)))

/datum/reagent/consumable/ethanol/helianthus/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(DT_PROB(5, AQ_TG_DRINK_SPT))
		M.adjust_hallucinations_up_to(4 SECONDS * AQ_TG_DRINK_RATIO, 48 SECONDS)

/datum/reagent/consumable/ethanol/gin_garden/on_mob_life(mob/living/carbon/M)
	. = ..()
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT * AQ_TG_DRINK_RATIO_SPT, BODYTEMP_NORMAL)

/datum/reagent/consumable/ethanol/suffering_bastard/on_mob_life(mob/living/carbon/M)
	. = ..()
	M.adjust_disgust(-5 * AQ_TG_DRINK_RATIO_SPT) // usuwa obrzydzenie, jak Sol Dry
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -0.5 * AQ_TG_DRINK_RATIO_SPT * normalise_creation_purity()) // bardzo powoli leczy mózg
	. = TRUE

/datum/reagent/consumable/ethanol/hot_toddy/on_mob_life(mob/living/carbon/M)
	. = ..()
	M.adjust_bodytemperature(25 * TEMPERATURE_DAMAGE_COEFFICIENT * AQ_TG_DRINK_RATIO_SPT, 0, BODYTEMP_NORMAL)

/datum/reagent/consumable/ethanol/blue_blazer/on_mob_life(mob/living/carbon/M)
	. = ..()
	M.adjust_bodytemperature(25 * TEMPERATURE_DAMAGE_COEFFICIENT * AQ_TG_DRINK_RATIO_SPT, 0, BODYTEMP_NORMAL)

/datum/reagent/consumable/ethanol/bartenders_handshake/on_mob_life(mob/living/carbon/M)
	. = ..()
	// tg: cecha wątroby barmana (TRAIT_BARTENDER_METABOLISM); u nas barman ma TRAIT_SOMMELIER
	if(HAS_TRAIT(M, TRAIT_SOMMELIER))
		M.heal_bodypart_damage(1 * REM, 1 * REM, updating_health = FALSE)
		. = TRUE
	else
		M.adjust_disgust(2 * REM)

/datum/reagent/consumable/ethanol/garibaldi/on_mob_life(mob/living/carbon/M)
	. = ..()
	// tg: status rev_resilience (cechy na 5 s, odświeżane co tyknięcie); u nas cechy trzyma sam napój
	if(is_revolutionary(M))
		if(!HAS_TRAIT_FROM(M, TRAIT_FEARLESS, type))
			to_chat(M, span_warning("Czujesz, jak wzbiera w tobie rewolucyjny duch! Nic, czym rzucą w ciebie ciemiężcy, nie zrani twojej dumy!"))
			M.add_traits(list(TRAIT_HARDLY_WOUNDED, TRAIT_ANALGESIA, TRAIT_FEARLESS), type)
	else
		garibaldi_remove_resilience(M)

/datum/reagent/consumable/ethanol/garibaldi/on_mob_end_metabolize(mob/living/L)
	. = ..()
	garibaldi_remove_resilience(L)

/datum/reagent/consumable/ethanol/garibaldi/proc/garibaldi_remove_resilience(mob/living/L)
	if(!HAS_TRAIT_FROM(L, TRAIT_FEARLESS, type))
		return
	L.remove_traits(list(TRAIT_HARDLY_WOUNDED, TRAIT_ANALGESIA, TRAIT_FEARLESS), type)
	to_chat(L, span_notice("Rewolucyjny zapał słabnie. Oby nikt cię teraz nie postrzelił w stopę..."))

/datum/reagent/consumable/ethanol/last_word/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0, obj/item/bodypart/affecting)
	. = ..()
	// Na pierwszy łyk raz na 5 minut wycisza na 5 sekund. Tylko przy piciu.
	if(method != INGEST || !iscarbon(M) || HAS_TRAIT(M, TRAIT_HAD_LAST_WORD))
		return
	ADD_TRAIT(M, TRAIT_HAD_LAST_WORD, type)
	to_chat(M, span_notice("Przez chwilę w milczeniu delektujesz się drinkiem..."))
	M.set_silence_if_lower(5 SECONDS)
	addtimer(TRAIT_CALLBACK_REMOVE(M, TRAIT_HAD_LAST_WORD, type), 300 SECONDS)

/datum/reagent/consumable/ethanol/negroni/on_mob_life(mob/living/carbon/M)
	. = ..()
	M.overeatduration = max(M.overeatduration - 20, 0)

/datum/reagent/consumable/ethanol/nuclear_daiquiri_thermo/on_mob_add(mob/living/L)
	. = ..()
	L.apply_status_effect(/datum/status_effect/aq_cherenkov_radiation) // niebieska poświata i rzadkie cząstki jądrowe

/datum/reagent/consumable/ethanol/nuclear_daiquiri_thermo/on_mob_delete(mob/living/L)
	. = ..()
	L.remove_status_effect(/datum/status_effect/aq_cherenkov_radiation)

/datum/reagent/consumable/ethanol/nuclear_daiquiri_thermo/on_mob_life(mob/living/carbon/M)
	. = ..()
	M.set_drugginess(AQ_TG_DRINK_TICKS(100 SECONDS * AQ_TG_DRINK_RATIO_SPT))
	M.set_jitter_if_lower(20 SECONDS * AQ_TG_DRINK_RATIO_SPT)
	M.set_dizzy_if_lower(10 SECONDS * AQ_TG_DRINK_RATIO_SPT)

/datum/reagent/consumable/ethanol/poets_dream/on_mob_metabolize(mob/living/L)
	. = ..()
	L.apply_status_effect(/datum/status_effect/grouped/heretic_dreams, type)

/datum/reagent/consumable/ethanol/poets_dream/on_mob_end_metabolize(mob/living/L)
	. = ..()
	L.remove_status_effect(/datum/status_effect/grouped/heretic_dreams, type)

/datum/reagent/consumable/ethanol/spritz/on_mob_life(mob/living/carbon/M)
	. = ..()
	M.overeatduration = max(M.overeatduration - 20, 0)

/datum/reagent/consumable/ethanol/stone_cold_stout/on_mob_metabolize(mob/living/L)
	. = ..()
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	H.physiology.brute_mod *= 0.8
	H.physiology.burn_mod *= 0.8

/datum/reagent/consumable/ethanol/stone_cold_stout/on_mob_end_metabolize(mob/living/L)
	. = ..()
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	H.physiology.brute_mod *= 1.25
	H.physiology.burn_mod *= 1.25

/datum/reagent/consumable/ethanol/footsoldiers_razor/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0, obj/item/bodypart/affecting)
	. = ..()
	// Pijący kaleczy się przy pierwszym łyku, potem minuta przerwy.
	if(method != INGEST || !iscarbon(M) || HAS_TRAIT(M, TRAIT_HAD_FOOTSOLDIERS_RAZOR))
		return
	ADD_TRAIT(M, TRAIT_HAD_FOOTSOLDIERS_RAZOR, type)
	to_chat(M, span_warning("Kaleczysz sobie wargę czymś ostrym!"))
	M.playsound_local(M, 'sound/weapons/slice.ogg', 50, TRUE)
	M.bleed(5)
	M.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
	addtimer(TRAIT_CALLBACK_REMOVE(M, TRAIT_HAD_FOOTSOLDIERS_RAZOR, type), 60 SECONDS)

/datum/reagent/consumable/ethanol/footsoldiers_razor/on_mob_metabolize(mob/living/L)
	. = ..()
	L.crit_threshold -= 20

/datum/reagent/consumable/ethanol/footsoldiers_razor/on_mob_end_metabolize(mob/living/L)
	. = ..()
	L.crit_threshold += 20

/// Istota z gwiazd stojąca za pijącym (tg: var gazer; nazwa z aq_, żeby nie zderzyć się ze zmiennymi z generatora)
/datum/reagent/consumable/ethanol/farstar_amrita/var/obj/effect/client_image_holder/aq_thirsty_gazer/aq_gazer

/datum/reagent/consumable/ethanol/farstar_amrita/proc/create_gazer(mob/living/drinker)
	if(HAS_TRAIT(drinker, TRAIT_FARSTAR_SHARED)) // kto już jedną poczęstował, nowych nie widzi
		return
	var/turf/gazer_source = get_step(drinker, REVERSE_DIR(drinker.dir)) || get_turf(drinker) // tuż za pijącym
	aq_gazer = new /obj/effect/client_image_holder/aq_thirsty_gazer(gazer_source, drinker)
	if(QDELETED(aq_gazer))
		aq_gazer = null
		return
	RegisterSignal(aq_gazer, COMSIG_QDELETING, PROC_REF(on_gazer_deleted))

/datum/reagent/consumable/ethanol/farstar_amrita/proc/on_gazer_deleted()
	SIGNAL_HANDLER
	aq_gazer = null

/datum/reagent/consumable/ethanol/farstar_amrita/on_mob_add(mob/living/L)
	. = ..()
	create_gazer(L)

/datum/reagent/consumable/ethanol/farstar_amrita/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(aq_gazer && (get_dist(M, aq_gazer) >= 7 || aq_gazer.z != M.z)) // znika, gdy odejdziesz za daleko
		QDEL_NULL(aq_gazer)
	if(!aq_gazer && DT_PROB(20, AQ_TG_DRINK_SPT)) // i nieprzewidywalnie pojawia się nowa
		create_gazer(M)

/datum/reagent/consumable/ethanol/farstar_amrita/on_mob_delete(mob/living/L)
	. = ..()
	QDEL_NULL(aq_gazer)

/datum/reagent/consumable/ethanol/lunacy/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(CANNOT_HALLUCINATE(M)) // tg: TRAIT_HALLUCINATION_IMMUNE
		return
	M.cause_hallucination(/datum/hallucination/delusion/preset/heretic, "delusion/preset/moon hallucination caused by Lunacy cocktail", duration = 4 SECONDS)
	M.adjust_hallucinations_up_to(4 SECONDS * AQ_TG_DRINK_RATIO_SPT, 10 SECONDS)

/datum/reagent/consumable/ethanol/emptiest_glass/on_mob_metabolize(mob/living/L)
	. = ..()
	if(!L.hud_used)
		return
	var/atom/movable/plane_master_controller/game_plane_master_controller = L.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.add_filter("emptiest_glass_filter", 10, color_matrix_filter(list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0)))
	var/static/list/col_filter_muted = list(0.7,0.15,0.15,0, 0.15,0.7,0.15,0, 0.15,0.15,0.7,0, 0,0,0,1, 0,0,0,0)
	for(var/filter in game_plane_master_controller.get_filters("emptiest_glass_filter"))
		animate(filter, color = col_filter_muted, time = 5 SECONDS, easing = CIRCULAR_EASING)

/datum/reagent/consumable/ethanol/emptiest_glass/on_mob_life(mob/living/carbon/M)
	. = ..()
	var/turf/open/drinker_turf = get_turf(M)
	if(istype(drinker_turf) && !isspaceturf(drinker_turf))
		drinker_turf.TakeTemperature(-10)

	if(DT_PROB(2.5, AQ_TG_DRINK_SPT))
		to_chat(M, span_warning(pick("Czujesz chłód.", "Czujesz pustkę.")))
		M.emote(pick("pale", "shiver"))
		if(prob(20)) // bardzo mała szansa na chłód pustki
			M.apply_status_effect(/datum/status_effect/void_chill, 1)
			to_chat(M, span_warning("Słyszysz odległą pieśń..."))

/datum/reagent/consumable/ethanol/emptiest_glass/on_mob_end_metabolize(mob/living/L)
	. = ..()
	if(!L.hud_used)
		return
	var/atom/movable/plane_master_controller/game_plane_master_controller = L.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.remove_filter("emptiest_glass_filter")

/datum/reagent/consumable/ethanol/bitters_soda/on_mob_life(mob/living/carbon/M)
	. = ..()
	M.adjust_disgust(-2.5 * AQ_TG_DRINK_RATIO_SPT)

#undef AQ_TG_DRINK_RATIO
#undef AQ_TG_DRINK_RATIO_SPT
#undef AQ_TG_DRINK_SPT
#undef AQ_TG_DRINK_TICKS
#undef TRAIT_HAD_LAST_WORD
#undef TRAIT_HAD_FOOTSOLDIERS_RAZOR
#undef TRAIT_FARSTAR_SHARED

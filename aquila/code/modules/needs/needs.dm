// AQUILA - progi nawodnienia i najedzenia oraz krótkie skutki tego, co postać zjadła i wypiła.
// Kary zaczynają się dopiero przy alercie, który gracz widzi i naprawia jedną czynnością (zjeść, wypić), a premie są większe niż kary.
// Nic tu nie zadaje obrażeń (głód i pragnienie bez obrażeń, AQ#497). Liczone co Life (2 s), bez hooka w core.
// Skutki reagentów (cukier, kofeina, sól, tłuszcz, białko) są w food_effects.dm, urozmaicenie w food_variety.dm, wrzody w stomach_ulcer.dm.

/// Jaką część THIRST_FACTOR oddaje sól na tick: woda zostaje w ciele
#define AQ_SALT_THIRST_REFUND 0.3
/// Jaką część HUNGER_FACTOR oddaje tłuszcz na tick: dłużej syci
#define AQ_FAT_HUNGER_REFUND 0.25
/// Dodatkowy rozrzut broni (stopnie), gdy ręce drżą z głodu
#define AQ_STARVING_TREMOR_SPREAD 3
/// Ile „cukru” we krwi daje zastrzyk energii
#define AQ_SUGAR_RUSH_LOAD 5
/// Ile „cukru” znika na tick
#define AQ_SUGAR_DECAY 0.1

/mob/living/carbon/human
	/// Ostatni mnożnik regeneracji staminy z potrzeb, żeby ruszać pulę tylko przy zmianie
	var/aq_needs_regen_mult = 1
	var/aq_next_growl = 0
	var/aq_next_parched_blur = 0
	/// Senność po obiedzie: do kiedy
	var/aq_food_coma_until = 0
	/// Czy w poprzednim ticku postać była przejedzona (senność tylko przy przejściu progu)
	var/aq_was_overfed = FALSE
	/// Cukier wchłonięty niedawno
	var/aq_sugar_load = 0
	var/aq_sugar_rush_until = 0
	var/aq_sugar_crash_until = 0
	/// Czy spadek cukru był już zgłoszony
	var/aq_sugar_crash_told = TRUE
	var/aq_caffeine_until = 0
	var/aq_salt_until = 0
	var/aq_fat_until = 0
	/// Ręce drżą z głodu
	var/aq_starving_tremor = FALSE

/datum/actionspeed_modifier/aq_starving
	multiplicative_slowdown = 0.25
	id = "aq_starving"

/datum/mood_event/aq_hydrated
	description = "<span class='nicegreen'>Dobrze się nawodniłem.</span>\n"
	mood_change = 3

/datum/mood_event/aq_dehydrated
	description = "<span class='warning'>Boli mnie głowa, chce mi się pić.</span>\n"
	mood_change = -5

/datum/mood_event/aq_parched
	description = "<span class='boldwarning'>Zasycham!</span>\n"
	mood_change = -10

/mob/living/carbon/human/Life()
	. = ..()
	if(QDELETED(src) || notransform)
		return
	aq_handle_needs()

/// Skutki potrzeb na ten tick
/mob/living/carbon/human/proc/aq_handle_needs()
	if(stat == DEAD)
		aq_set_starving_tremor(FALSE)
		aq_set_needs_regen(1)
		return
	var/mult = 1
	if(!HAS_TRAIT(src, TRAIT_NOTHIRST))
		mult *= aq_hydration_effects()
	if(!HAS_TRAIT(src, TRAIT_NOHUNGER) && !HAS_TRAIT(src, TRAIT_POWERHUNGRY))
		mult *= aq_nutrition_effects()
	else
		aq_set_starving_tremor(FALSE)
	mult *= aq_food_buff_effects()
	aq_set_needs_regen(mult)
	aq_handle_ulcer()

/// Nawodnienie: mnożnik regeneracji staminy. Sól zatrzymuje wodę.
/mob/living/carbon/human/proc/aq_hydration_effects()
	. = 1
	if(world.time < aq_salt_until && hydration > 0 && hydration < HYDRATION_LEVEL_TURGID)
		adjust_hydration(THIRST_FACTOR * physiology.thirst_mod * AQ_SALT_THIRST_REFUND)
	switch(hydration)
		if(HYDRATION_LEVEL_HYDRATED to HYDRATION_LEVEL_TURGID)
			. = 1.1
		if(HYDRATION_LEVEL_PARCHED to HYDRATION_LEVEL_DEHYDRATED)
			. = 0.85
		if(-INFINITY to HYDRATION_LEVEL_PARCHED)
			. = 0.7
			if(world.time >= aq_next_parched_blur && prob(5))
				aq_next_parched_blur = world.time + 1 MINUTES
				blur_eyes(3)
				to_chat(src, "<span class='warning'>Mroczki przed oczami. Musisz się czegoś napić.</span>")

/// Najedzenie: mnożnik regeneracji staminy, burczenie w brzuchu, drżenie rąk, gojenie siniaków. Tłuszcz dłużej syci.
/mob/living/carbon/human/proc/aq_nutrition_effects()
	. = 1
	if(world.time < aq_fat_until && nutrition > 0 && nutrition < NUTRITION_LEVEL_FULL)
		adjust_nutrition(HUNGER_FACTOR * physiology.hunger_mod * AQ_FAT_HUNGER_REFUND)
	if(HAS_TRAIT_FROM(src, TRAIT_FAT, OBESITY))
		. *= 0.85 // zadyszka
	var/overfed = nutrition > NUTRITION_LEVEL_FULL
	if(overfed && !aq_was_overfed)
		aq_food_coma_until = world.time + 2 MINUTES
		to_chat(src, "<span class='notice'>Po takim posiłku robi ci się sennie.</span>")
	aq_was_overfed = overfed
	if(world.time < aq_food_coma_until)
		. *= 0.8
	// Dobrze najedzony (przyspieszony metabolizm z handle_digestion): siniaki goją się trochę szybciej
	if(metabolism_efficiency > 1 && getBruteLoss())
		heal_bodypart_damage(0.1, 0, 0)
	if(nutrition < NUTRITION_LEVEL_HUNGRY && nutrition >= NUTRITION_LEVEL_STARVING && world.time >= aq_next_growl && prob(5))
		aq_next_growl = world.time + 3 MINUTES
		audible_message("<span class='notice'>Słychać, jak [src] burczy w brzuchu.</span>", hearing_distance = 3, self_message = "<span class='notice'>Burczy ci w brzuchu.</span>")
	aq_set_starving_tremor(nutrition < NUTRITION_LEVEL_STARVING)

/// Krótkie skutki tego, co postać zjadła i wypiła: zastrzyk i spadek cukru, kofeina
/mob/living/carbon/human/proc/aq_food_buff_effects()
	. = 1
	if(aq_sugar_load >= AQ_SUGAR_RUSH_LOAD && world.time >= aq_sugar_rush_until)
		aq_sugar_load = 0
		aq_sugar_rush_until = world.time + 2 MINUTES
		aq_sugar_crash_until = aq_sugar_rush_until + 2 MINUTES
		aq_sugar_crash_told = FALSE
		to_chat(src, "<span class='notice'>Cukier uderza ci do głowy, masz siłę na wszystko!</span>")
	aq_sugar_load = max(aq_sugar_load - AQ_SUGAR_DECAY, 0)
	if(world.time < aq_sugar_rush_until)
		. *= 1.25
	else if(world.time < aq_sugar_crash_until)
		. *= 0.9
		if(!aq_sugar_crash_told)
			aq_sugar_crash_told = TRUE
			to_chat(src, "<span class='notice'>Cukier opada i robisz się trochę ospały.</span>")
	if(world.time < aq_caffeine_until)
		. *= 1.1

/mob/living/carbon/human/proc/aq_set_needs_regen(mult)
	mult = round(mult, 0.01)
	if(mult == aq_needs_regen_mult || !stamina)
		return
	aq_needs_regen_mult = mult
	if(mult == 1)
		stamina.remove_regen_multiplier("aq_needs")
	else
		stamina.add_regen_multiplier("aq_needs", mult)

/// Drżenie rąk z głodu: dłuższe czynności i większy rozrzut broni
/mob/living/carbon/human/proc/aq_set_starving_tremor(state)
	if(state == aq_starving_tremor)
		return
	aq_starving_tremor = state
	if(state)
		add_actionspeed_modifier(/datum/actionspeed_modifier/aq_starving)
		to_chat(src, "<span class='warning'>Ręce drżą ci z głodu.</span>")
	else
		remove_actionspeed_modifier(/datum/actionspeed_modifier/aq_starving)

/mob/living/carbon/human/get_move_spread_penalty()
	. = ..()
	if(aq_starving_tremor)
		. += AQ_STARVING_TREMOR_SPREAD

/// Moodlet nawodnienia obok moodletu najedzenia
/datum/component/mood/HandleNutrition(mob/living/L)
	. = ..()
	aq_handle_hydration_mood(L)

/datum/component/mood/proc/aq_handle_hydration_mood(mob/living/L)
	if(HAS_TRAIT(L, TRAIT_NOTHIRST))
		clear_event(null, "aq_hydration")
		return
	switch(L.hydration)
		if(HYDRATION_LEVEL_TURGID to INFINITY)
			clear_event(null, "aq_hydration")
		if(HYDRATION_LEVEL_HYDRATED to HYDRATION_LEVEL_TURGID)
			add_event(null, "aq_hydration", /datum/mood_event/aq_hydrated)
		if(HYDRATION_LEVEL_DEHYDRATED to HYDRATION_LEVEL_HYDRATED)
			clear_event(null, "aq_hydration")
		if(HYDRATION_LEVEL_PARCHED to HYDRATION_LEVEL_DEHYDRATED)
			add_event(null, "aq_hydration", /datum/mood_event/aq_dehydrated)
		else
			add_event(null, "aq_hydration", /datum/mood_event/aq_parched)

/mob/living/carbon/human/fully_heal(admin_revive = FALSE)
	. = ..()
	aq_sugar_load = 0
	aq_sugar_rush_until = 0
	aq_sugar_crash_until = 0
	aq_food_coma_until = 0
	aq_set_starving_tremor(FALSE)

#undef AQ_SALT_THIRST_REFUND
#undef AQ_FAT_HUNGER_REFUND
#undef AQ_STARVING_TREMOR_SPREAD
#undef AQ_SUGAR_RUSH_LOAD
#undef AQ_SUGAR_DECAY

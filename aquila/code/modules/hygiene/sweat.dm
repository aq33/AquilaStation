// AQUILA - pot przy wysiłku. Sprint, zamachy i upał wyciskają z postaci pot: widać kroplę nad głową i opis przy oględzinach,
// pot zabiera trochę wody (nawodnienie) i po wyschnięciu obniża higienę. Szmatą da się go zebrać z siebie albo z kogoś
// (poza combat mode), a z gorącego potu w zlewce zostaje sól. Prysznic i mydło zmywają pot.

/// Najwięcej potu na skórze (jednostki reagentu)
#define SWEAT_MAX 10
/// Ile potu daje jedna jednostka zużytej staminy (pełny sprint do zadyszki ok. 150 staminy = 6 jednostek)
#define SWEAT_PER_STAMINA 0.04
/// Ile potu na tick Life przybywa w upale
#define SWEAT_HEAT_GAIN 0.4
/// O ile ponad normę musi wzrosnąć temperatura ciała, żeby postać się pociła
#define SWEAT_HEAT_THRESHOLD 8
/// Ile potu wysycha na tick Life (2 s), z pełnego ok. minuty
#define SWEAT_EVAPORATION 0.3
/// Od tylu jednostek pot widać
#define SWEAT_VISIBLE 3
/// Od tylu jednostek postać jest zlana potem
#define SWEAT_SOAKED 7
/// Ile nawodnienia kosztuje jednostka potu
#define SWEAT_HYDRATION_COST 1
/// Ile higieny zabiera jednostka wyschniętego potu
#define SWEAT_HYGIENE_COST 0.5
/// Najmniej potu, który da się zebrać szmatą
#define SWEAT_WIPE_MIN 1

/mob/living/carbon/human
	/// Pot na skórze, w jednostkach reagentu /datum/reagent/sweat
	var/sweat = 0
	COOLDOWN_DECLARE(sweat_drop_cooldown)

/// Wysiłek opłacony staminą (sprint, zamach, szczekanie Fiona). Obrażenia staminy od ciosów się nie liczą.
/mob/living/proc/exert(stamina_cost)
	return

/mob/living/carbon/human/exert(stamina_cost)
	if(stamina_cost > 0)
		add_sweat(stamina_cost * SWEAT_PER_STAMINA)

/mob/living/carbon/human/proc/can_sweat()
	return stat != DEAD && (mob_biotypes & MOB_ORGANIC) && !HAS_TRAIT(src, TRAIT_NOBREATH)

/mob/living/carbon/human/proc/add_sweat(amount)
	if(amount <= 0 || !can_sweat() || sweat >= SWEAT_MAX)
		return
	var/added = min(amount, SWEAT_MAX - sweat)
	var/was_visible = sweat >= SWEAT_VISIBLE
	sweat += added
	if(!HAS_TRAIT(src, TRAIT_NOTHIRST))
		adjust_hydration(-added * SWEAT_HYDRATION_COST)
	if(sweat >= SWEAT_VISIBLE && (!was_visible || COOLDOWN_FINISHED(src, sweat_drop_cooldown)))
		COOLDOWN_START(src, sweat_drop_cooldown, 20 SECONDS)
		flick_overlay_view(image('icons/effects/overlay_effects.dmi', src, "sweatdrop", ABOVE_MOB_LAYER), src, 2 SECONDS)

/// Zabiera pot ze skóry i zwraca, ile zabrano
/mob/living/carbon/human/proc/remove_sweat(amount)
	. = min(amount, sweat)
	sweat -= .

/mob/living/carbon/human/Life()
	. = ..()
	if(QDELETED(src) || notransform || IsInStasis())
		return
	if(bodytemperature > BODYTEMP_NORMAL + SWEAT_HEAT_THRESHOLD)
		add_sweat(SWEAT_HEAT_GAIN)
	if(sweat > 0)
		var/dried = remove_sweat(SWEAT_EVAPORATION)
		adjust_hygiene(-dried * SWEAT_HYGIENE_COST)

/mob/living/carbon/human/clean_blood(datum/source, strength)
	. = ..()
	sweat = 0

/mob/living/carbon/human/examine(mob/user)
	. = ..()
	if(stat == DEAD || sweat < SWEAT_VISIBLE || get_dist(user, src) > 3)
		return
	if(sweat >= SWEAT_SOAKED)
		. += "<span class='notice'>Ta osoba jest zlana potem.</span>"
	else
		. += "<span class='notice'>Ta osoba jest spocona.</span>"

/obj/item/reagent_containers/glass/rag
	/// Ile trwa ocieranie potu
	var/sweat_wipe_time = 2 SECONDS

/// Szmata poza combat mode zbiera pot z siebie albo z kogoś, jeśli jest pusta albo ma w sobie tylko pot
/obj/item/reagent_containers/glass/rag/afterattack(atom/A, mob/user, proximity)
	if(!proximity || !ishuman(A) || user.combat_mode || !(src in user))
		return ..()
	var/mob/living/carbon/human/sweaty = A
	if(sweaty.sweat < SWEAT_WIPE_MIN || reagents.holder_full())
		return ..()
	if(reagents.total_volume && !(length(reagents.reagent_list) == 1 && reagents.has_reagent(/datum/reagent/sweat)))
		return ..()
	if(sweaty == user)
		user.visible_message("<span class='notice'>[user] ociera pot z czoła za pomocą [src].</span>", "<span class='notice'>Ocierasz pot z czoła za pomocą [src].</span>")
	else
		user.visible_message("<span class='notice'>[user] ociera pot z [sweaty] za pomocą [src].</span>", "<span class='notice'>Ocierasz pot z [sweaty] za pomocą [src].</span>")
	if(!do_after(user, sweat_wipe_time, target = sweaty))
		return
	var/wiped = sweaty.remove_sweat(reagents.maximum_volume - reagents.total_volume)
	if(wiped > 0)
		reagents.add_reagent(/datum/reagent/sweat, wiped)
		to_chat(user, "<span class='notice'>[capitalize(src.name)] nasiąka potem.</span>")

/datum/reagent/sweat
	name = "Pot"
	description = "Słona woda wyciśnięta wysiłkiem. Po podgrzaniu zostaje z niej sól."
	color = "#e9e5cf"
	taste_description = "słony pot"
	taste_mult = 2

/datum/reagent/sweat/on_mob_life(mob/living/carbon/M)
	M.adjust_disgust(3)
	return ..()

/// Podgrzany pot odparowuje do soli
/datum/chemical_reaction/sweat_salt
	results = list(/datum/reagent/consumable/sodiumchloride = 1)
	required_reagents = list(/datum/reagent/sweat = 5)
	required_temp = 374
	reaction_flags = REACTION_INSTANT

#undef SWEAT_MAX
#undef SWEAT_PER_STAMINA
#undef SWEAT_HEAT_GAIN
#undef SWEAT_HEAT_THRESHOLD
#undef SWEAT_EVAPORATION
#undef SWEAT_VISIBLE
#undef SWEAT_SOAKED
#undef SWEAT_HYDRATION_COST
#undef SWEAT_HYGIENE_COST
#undef SWEAT_WIPE_MIN

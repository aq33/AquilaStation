// AQUILA - Prawdziwa forma zmiennokształtnego, port z Goonstation (Horror Form):
// goonstation/code/modules/antagonists/changeling/abilities/abomination.dm (forma, powrót, Horrific Scream),
// abilities/devour.dm (Devour) i mutantrace /datum/mutantrace/abomination z code/datums/mutantraces.dm.
// Grafiki: goonstation icons/mob/abomination.dmi (stan "abomination") i icons/ui/ability_icons/changeling.dmi
// (stany "horror", "scream", "devour"), licencja CC BY-NC-SA 3.0, autorzy: Goonstation (https://github.com/goonstation/goonstation).
// Aquila jest projektem niekomercyjnym.
// Różnice względem Goona:
// - u nas forma to osobny mob (simple_animal), a ciało człowieka czeka w nim nietknięte razem z całym ekwipunkiem
//   i wraca przy powrocie; w Goonie to mutantrace na tym samym ciele, a nasze ciało ludzkie nie ma sprite'ów 32x48;
// - punkty DNA Goona przeliczone na chemikalia x2: próg wejścia i koszt powrotu 30 (Goon 15), forma spala 2 na cykl
//   życia (Goon 1), pożarcie daje 20 chemikaliów (Goon 10 punktów);
// - odporność na brute 0,5 zamiast 0,2 przy 400 pkt zdrowia, leczenie 20 pkt na cykl (Goon 10 na 100 pkt), w ogniu zwykle bez leczenia;
// - pożeranie bez stopniowego odgryzania kończyn w trakcie; ciało znika jak w Goonie, ale rzeczy ofiary zostają na podłodze;
// - posoka bez rozrzucania (zwykłe flaki na kafelku), bo rozrzucane flaki w testach bez grawitacji sypią runtime.

#define TRUE_FORM_CHEM_THRESHOLD 30
#define TRUE_FORM_CHEM_DRAIN 2
#define TRUE_FORM_DEVOUR_CHEMS 20
#define TRUE_FORM_HEAL 20

/datum/action/changeling/true_form
	name = "Prawdziwa forma"
	desc = "Zrzucamy przebranie i ukazujemy naszą prawdziwą formę. Wymaga co najmniej 30 chemikaliów, które forma stale spala."
	helptext = "Po kilku sekundach przemiany stajemy się wytrzymałym plugastwem o potężnym ataku wręcz, odpornym na ogłuszenie, z mocami Przerażający wrzask i Pożarcie. Ekwipunek zostaje schowany w ciele, a kajdanki pękają. Powrót do ludzkiej postaci kosztuje 30 chemikaliów i chwilowo nas powala, a bez nich tracimy przytomność."
	icon_icon = 'aquila/icons/mob/changeling/true_form_actions.dmi'
	button_icon_state = "horror"
	chemical_cost = 0
	dna_cost = 3
	req_human = 1
	/// Trwa przemiana, drugie kliknięcie nic nie robi
	var/transforming = FALSE

/datum/action/changeling/true_form/sting_action(mob/living/carbon/human/user)
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(transforming)
		to_chat(user, "<span class='warning'>Już się przemieniamy!</span>")
		return FALSE
	if(changeling.chem_charges < TRUE_FORM_CHEM_THRESHOLD)
		to_chat(user, "<span class='warning'>Jesteśmy zbyt słabi, by utrzymać tę formę.</span>")
		return FALSE
	if(tgui_alert(user, "Czy na pewno chcemy ukazać prawdziwą formę?", "Prawdziwa forma", list("Tak", "Nie")) != "Tak")
		return FALSE
	if(QDELETED(user) || user.stat || user.notransform)
		return FALSE
	..()
	transforming = TRUE
	. = contort(user)
	transforming = FALSE

/// Kilkusekundowa przemiana: ciało się wykręca, nikt go nie utrzyma
/datum/action/changeling/true_form/proc/contort(mob/living/carbon/human/user)
	user.visible_message("<span class='danger'>[user] zaczyna się potwornie wykręcać!</span>", "<span class='changeling'>Nasze ciało zaczyna się rozrywać...</span>")
	log_combat(user, user, "zaczyna przemianę w prawdziwą formę zmiennokształtnego")
	if(user.pulledby)
		to_chat(user.pulledby, "<span class='warning'>[user] wyrywa ci się z uchwytu!</span>")
		user.pulledby.stop_pulling()
	user.Knockdown(5 SECONDS)
	user.Jitter(50)
	playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
	if(!do_after(user, 3 SECONDS, FALSE, user))
		to_chat(user, "<span class='warning'>Przemiana została przerwana!</span>")
		return FALSE
	if(!changeling_enter_true_form(user))
		return FALSE
	return TRUE

/// Zamienia zmiennokształtnego w prawdziwą formę. Zwraca nowego moba albo null.
/proc/changeling_enter_true_form(mob/living/carbon/human/user)
	var/turf/spot = get_turf(user)
	if(!spot || !user.mind)
		return null
	var/list/cuffs = list()
	if(user.handcuffed)
		cuffs += user.handcuffed
	if(user.legcuffed)
		cuffs += user.legcuffed
	if(length(cuffs))
		user.uncuff()
		for(var/obj/item/cuff as anything in cuffs)
			user.visible_message("<span class='danger'>[user] rozrywa [cuff]!</span>")
			qdel(cuff)
	if(user.pulledby)
		user.pulledby.stop_pulling()
	user.stop_pulling()
	user.buckled?.unbuckle_mob(user, TRUE)
	user.SetKnockdown(0)
	user.jitteriness = 0

	var/mob/living/simple_animal/hostile/changeling_true_form/form = new(spot)
	form.store_body(user)
	user.mind.transfer_to(form)
	form.visible_message("<span class='userdanger'>Ciało [user] rozpada się w [pick("wygłodniałą", "bełkoczącą", "wrzeszczącą")] masę kończyn i zębów!</span>")
	log_combat(form, form, "przybiera prawdziwą formę zmiennokształtnego")
	new /obj/effect/decal/cleanable/blood/gibs(spot)
	form.setDir(SOUTH)
	playsound(form, 'sound/effects/screech.ogg', 60, TRUE)
	return form

/mob/living/simple_animal/hostile/changeling_true_form
	name = "plugastwo"
	real_name = "plugastwo"
	desc = "Kłębowisko kończyn, kłów i mięsa, które jeszcze przed chwilą udawało człowieka."
	icon = 'aquila/icons/mob/changeling/true_form.dmi'
	icon_state = "abomination"
	icon_living = "abomination"
	icon_dead = "abomination"
	mob_biotypes = list(MOB_ORGANIC)
	speak_emote = list("skrzeczy")
	speak_chance = 0
	AIStatus = AI_OFF
	combat_mode = TRUE
	combat_mode_indicator = TRUE
	del_on_death = TRUE
	status_flags = NONE
	move_resist = MOVE_FORCE_STRONG
	pull_force = MOVE_FORCE_STRONG
	speed = 1
	see_in_dark = 8

	maxHealth = 400
	health = 400
	damage_coeff = list(BRUTE = 0.5, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	melee_damage = 25
	obj_damage = 60
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	attacktext = "rozszarpuje"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	response_help = "dotyka"
	response_disarm = "odpycha"
	response_harm = "uderza"

	/// Ludzkie ciało zmiennokształtnego, schowane w formie razem z ekwipunkiem
	var/mob/living/carbon/human/stored_body
	/// Ostatni próg ostrzeżenia o kończących się chemikaliach
	var/warned_at
	var/datum/action/innate/changeling_true_form_revert/revert_action
	var/datum/action/cooldown/changeling_true_form_scream/scream_action
	var/datum/action/cooldown/changeling_true_form_devour/devour_action

/mob/living/simple_animal/hostile/changeling_true_form/Initialize(mapload)
	. = ..()
	revert_action = new
	revert_action.Grant(src)
	scream_action = new
	scream_action.Grant(src)
	devour_action = new
	devour_action.Grant(src)

/mob/living/simple_animal/hostile/changeling_true_form/Destroy()
	if(stored_body)
		var/datum/mind/our_mind = mind
		var/mob/living/carbon/human/body = release_body()
		if(our_mind && !QDELETED(body))
			our_mind.transfer_to(body)
	QDEL_NULL(revert_action)
	QDEL_NULL(scream_action)
	QDEL_NULL(devour_action)
	return ..()

/mob/living/simple_animal/hostile/changeling_true_form/proc/get_changeling()
	return mind?.has_antag_datum(/datum/antagonist/changeling)

/mob/living/simple_animal/hostile/changeling_true_form/proc/store_body(mob/living/carbon/human/body)
	stored_body = body
	body.status_flags |= GODMODE
	body.notransform = TRUE
	body.forceMove(src)
	RegisterSignal(body, COMSIG_PARENT_QDELETING, PROC_REF(on_body_deleted))

/// Wypuszcza ludzkie ciało na podłogę i zwraca je
/mob/living/simple_animal/hostile/changeling_true_form/proc/release_body()
	var/mob/living/carbon/human/body = stored_body
	if(!body)
		return null
	stored_body = null
	UnregisterSignal(body, COMSIG_PARENT_QDELETING)
	body.status_flags &= ~GODMODE
	body.notransform = FALSE
	body.forceMove(drop_location() || get_turf(src))
	return body

/mob/living/simple_animal/hostile/changeling_true_form/proc/on_body_deleted(datum/source)
	SIGNAL_HANDLER
	stored_body = null

/mob/living/simple_animal/hostile/changeling_true_form/get_stat_tab_status()
	var/list/tab_data = ..()
	var/datum/antagonist/changeling/changeling = get_changeling()
	if(changeling)
		tab_data["Chemikalia"] = GENERATE_STAT_TEXT("[round(changeling.chem_charges)]/[changeling.chem_storage]")
	return tab_data

/mob/living/simple_animal/hostile/changeling_true_form/Life()
	. = ..()
	if(stat == DEAD || QDELETED(src))
		return
	handle_true_form()

/// Leczenie i spalanie chemikaliów co cykl życia; przy braku chemikaliów wymusza powrót
/mob/living/simple_animal/hostile/changeling_true_form/proc/handle_true_form()
	var/datum/antagonist/changeling/changeling = get_changeling()
	if(!changeling)
		to_chat(src, "<span class='userdanger'>Nie możemy utrzymać tej formy!</span>")
		revert_to_human()
		return
	if(!(on_fire && prob(90)))
		adjustHealth(-TRUE_FORM_HEAL)
	changeling.chem_charges = max(0, changeling.chem_charges - TRUE_FORM_CHEM_DRAIN)
	if(changeling.chem_charges <= 0)
		to_chat(src, "<span class='userdanger'>Nie możemy utrzymać tej formy!</span>")
		revert_to_human()
		return
	if(changeling.chem_charges <= 10 && warned_at != 10)
		warned_at = 10
		to_chat(src, "<span class='userdanger'>Nasze chemikalia prawie się wyczerpały!</span>")
	else if(changeling.chem_charges <= 20 && !warned_at)
		warned_at = 20
		to_chat(src, "<span class='warning'>Nie utrzymamy tej formy dużo dłużej!</span>")

/// Powrót do ludzkiej postaci z losową wchłoniętą tożsamością
/mob/living/simple_animal/hostile/changeling_true_form/proc/revert_to_human()
	var/datum/antagonist/changeling/changeling = get_changeling()
	var/datum/mind/our_mind = mind
	var/mob/living/carbon/human/body = release_body()
	if(!body)
		qdel(src)
		return null
	visible_message("<span class='danger'>[src] zwija się z obrzydliwym mlaśnięciem i znów przybiera ludzki kształt!</span>")
	if(our_mind)
		our_mind.transfer_to(body)
	if(!changeling || changeling.chem_charges < TRUE_FORM_CHEM_THRESHOLD)
		to_chat(body, "<span class='userdanger'>Nie mieliśmy dość sił, by bezpiecznie wrócić, i tracimy przytomność!</span>")
		body.Unconscious(10 SECONDS)
	else
		to_chat(body, "<span class='warning'>Wracamy do pierwotnej postaci. Jesteśmy osłabieni.</span>")
		body.Knockdown(5 SECONDS)
	if(changeling)
		changeling.chem_charges = max(changeling.chem_charges - TRUE_FORM_CHEM_THRESHOLD, 0)
		if(length(changeling.stored_profiles))
			changeling_transform(body, pick(changeling.stored_profiles))
	log_combat(body, body, "wraca z prawdziwej formy zmiennokształtnego")
	qdel(src)
	return body

/mob/living/simple_animal/hostile/changeling_true_form/death(gibbed)
	if(stored_body)
		var/datum/mind/our_mind = mind
		var/mob/living/carbon/human/body = release_body()
		visible_message("<span class='danger'>[src] rozpada się, odsłaniając zmasakrowane ludzkie ciało!</span>")
		new /obj/effect/decal/cleanable/blood/gibs(get_turf(src))
		if(our_mind)
			our_mind.transfer_to(body)
		body.death()
	return ..()

/// Prawy przycisk (albo intencja rozbrajania): odepchnięcie, powalenie albo odcięcie kończyny jak w Goonie
/mob/living/simple_animal/hostile/changeling_true_form/resolve_right_click_attack(atom/target, list/modifiers)
	if(!iscarbon(target) || target == src || !Adjacent(target))
		return ..()
	var/mob/living/carbon/victim = target
	do_attack_animation(victim)
	changeNext_move(CLICK_CD_MELEE)
	if(prob(25))
		var/obj/item/bodypart/limb = victim.get_bodypart(pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(limb && limb.dismember())
			victim.visible_message("<span class='danger'>[src] tnie [victim] ostrą krawędzią chitynowej macki i odcina [limb]!</span>", "<span class='userdanger'>[src] odcina ci [limb]!</span>")
			playsound(victim, 'sound/weapons/slice.ogg', 50, TRUE)
			victim.Stun(2 SECONDS)
			log_combat(src, victim, "odcina kończynę (prawdziwa forma zmiennokształtnego)")
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(prob(30))
		victim.Knockdown(2 SECONDS)
		victim.visible_message("<span class='danger'>[src] powala [victim] potężną macką!</span>", "<span class='userdanger'>[src] powala cię potężną macką!</span>")
	else
		var/obj/item/held = victim.get_active_held_item()
		if(held && victim.dropItemToGround(held))
			victim.visible_message("<span class='danger'>[src] wytrąca [held] z rąk [victim]!</span>", "<span class='userdanger'>[src] wytrąca ci [held] z rąk!</span>")
		else
			victim.visible_message("<span class='danger'>[src] odpycha [victim] macką!</span>", "<span class='userdanger'>[src] odpycha cię macką!</span>")
	playsound(victim, 'sound/weapons/punchmiss.ogg', 50, TRUE)
	log_combat(src, victim, "odpycha (prawdziwa forma zmiennokształtnego)")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Pożarcie ofiary: DNA do zapasu, chemikalia, ciało rozszarpane, rzeczy na podłodze
/mob/living/simple_animal/hostile/changeling_true_form/proc/devour(mob/living/carbon/human/victim)
	var/datum/antagonist/changeling/changeling = get_changeling()
	if(changeling && victim.has_dna() && !changeling.has_dna(victim.dna) && !isipc(victim) \
		&& !HAS_TRAIT(victim, TRAIT_BADDNA) && !HAS_TRAIT(victim, TRAIT_HUSK) && !(NO_DNA_COPY in victim.dna.species.species_traits))
		changeling.add_new_profile(victim)
		changeling.trueabsorbs++
		changeling.chem_charges = min(changeling.chem_charges + TRUE_FORM_DEVOUR_CHEMS, changeling.chem_storage)
	visible_message("<span class='danger'><b>[src] łapczywie pożera [victim]!</b></span>", "<span class='notice'>Pożeramy [victim]!</span>")
	playsound(src, 'sound/items/eatfood.ogg', 50, TRUE)
	log_combat(src, victim, "pożera (prawdziwa forma zmiennokształtnego)")
	// jak w Goonie ciało znika w paszczy (ghostize + qdel), ale ekwipunek ofiary zostaje na podłodze
	victim.unequip_everything()
	new /obj/effect/decal/cleanable/blood/gibs(get_turf(victim))
	victim.ghostize(FALSE)
	qdel(victim)

/datum/action/innate/changeling_true_form_revert
	name = "Ludzka postać"
	desc = "Wracamy do ludzkiej postaci jednej z wchłoniętych ofiar. Kosztuje 30 chemikaliów i chwilowo nas powala; bez nich tracimy przytomność."
	background_icon_state = "bg_changeling"
	icon_icon = 'aquila/icons/mob/changeling/true_form_actions.dmi'
	button_icon_state = "horror"

/datum/action/innate/changeling_true_form_revert/Activate()
	var/mob/living/simple_animal/hostile/changeling_true_form/form = owner
	if(!istype(form))
		return
	if(tgui_alert(form, "Czy na pewno chcemy wrócić do ludzkiej postaci?", "Ludzka postać", list("Tak", "Nie")) != "Tak")
		return
	if(QDELETED(form) || form.stat == DEAD)
		return
	form.revert_to_human()

/datum/action/cooldown/changeling_true_form_scream
	name = "Przerażający wrzask"
	desc = "Przeraźliwy wrzask, który oszałamia i napełnia grozą wszystkich wokół."
	background_icon_state = "bg_changeling"
	icon_icon = 'aquila/icons/mob/changeling/true_form_actions.dmi'
	button_icon_state = "scream"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 10 SECONDS

/datum/action/cooldown/changeling_true_form_scream/Trigger()
	if(!..())
		return FALSE
	var/mob/living/user = owner
	scream(user)
	StartCooldown()
	return TRUE

/datum/action/cooldown/changeling_true_form_scream/proc/scream(mob/living/user)
	user.visible_message("<span class='danger'><b>[user] wydaje ogłuszający wrzask! Sam ten dźwięk napełnia cię grozą!</b></span>")
	playsound(user, 'sound/effects/screech.ogg', 80, TRUE)
	log_combat(user, user, "wrzeszczy (prawdziwa forma zmiennokształtnego)")
	for(var/mob/living/victim in viewers(user))
		if(victim == user)
			continue
		victim.drowsyness = max(victim.drowsyness, 5)
		victim.confused = max(victim.confused, 3)
		victim.Jitter(5)
		if(iscarbon(victim))
			var/mob/living/carbon/carbon_victim = victim
			var/obj/item/organ/ears/ears = carbon_victim.getorganslot(ORGAN_SLOT_EARS)
			ears?.adjustEarDamage(rand(0, 2), 0)

/datum/action/cooldown/changeling_true_form_devour
	name = "Pożarcie"
	desc = "Pożeramy ciągniętego człowieka i przejmujemy jego DNA. Trzeba przez chwilę stać w miejscu."
	background_icon_state = "bg_changeling"
	icon_icon = 'aquila/icons/mob/changeling/true_form_actions.dmi'
	button_icon_state = "devour"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 5 SECONDS

/datum/action/cooldown/changeling_true_form_devour/Trigger()
	if(!..())
		return FALSE
	var/mob/living/simple_animal/hostile/changeling_true_form/form = owner
	if(!istype(form))
		return FALSE
	var/mob/living/carbon/human/victim = form.pulling
	if(!ishuman(victim) || !form.Adjacent(victim))
		to_chat(form, "<span class='warning'>Najpierw musimy pochwycić i ciągnąć człowieka.</span>")
		return FALSE
	if(HAS_TRAIT(victim, TRAIT_HUSK))
		to_chat(form, "<span class='warning'>To ciało zostało już wyssane...</span>")
		return FALSE
	StartCooldown()
	to_chat(form, "<span class='notice'>Musimy przez chwilę pozostać w bezruchu...</span>")
	victim.visible_message("<span class='danger'>[form] wbija kły w [victim]!</span>", "<span class='userdanger'>[form] zaczyna cię pożerać!</span>")
	if(!do_after(form, 5 SECONDS, FALSE, victim) || form.pulling != victim || !form.Adjacent(victim))
		to_chat(form, "<span class='warning'>Przerwano nam ucztę!</span>")
		return FALSE
	form.devour(victim)
	return TRUE

#undef TRUE_FORM_CHEM_THRESHOLD
#undef TRUE_FORM_CHEM_DRAIN
#undef TRUE_FORM_DEVOUR_CHEMS
#undef TRUE_FORM_HEAL

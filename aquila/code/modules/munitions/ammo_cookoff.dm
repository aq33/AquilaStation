/**
 * AQUILA - przegrzewanie się amunicji okrętowej (cook-off), wzorowane na Aurorze (_ship_ammunition.dm, longbow_ammo.dm).
 *
 * Rozbudowa /datum/component/volatile z nsv13 (bez dublowania komponentu):
 * - /obj/fire_act nie wysyła COMSIG_ATOM_FIRE_ACT, więc burn_act z nsv13 nigdy nie działał. Amunicja i worki prochu
 *   przekazują teraz ogień same; liczy się dopiero pożar od AQ_COOKOFF_MIN_TEMPERATURE (200°C).
 * - wybuch (ex_act) odpala sąsiednią amunicję z szansą, z opóźnieniem i z globalnym limitem łańcucha;
 * - postrzał powyżej AQ_COOKOFF_BULLET_MIN_DAMAGE, rzut i upadek odpalają amunicję wrażliwą na uderzenia (volatile_when_hit);
 * - każdy wybuch komponentu (też z uderzenia i z nsv13) idzie przez ostrzeżenie: syk, dym, komunikat i 2–4 s zapasu.
 *   Wyjęta z ognia albo ugaszona amunicja stygnie i nie wybucha.
 * Abstrakcyjne magazyny okrętów AI (aquila/code/modules/overmap/modules/ship_modules.dm) są osobne i tu nieruszane.
 */

#define AQ_COOKOFF_MIN_TEMPERATURE (T0C + 200)
#define AQ_COOKOFF_BULLET_MIN_DAMAGE 5
#define AQ_COOKOFF_MIN_DELAY (2 SECONDS)
#define AQ_COOKOFF_MAX_DELAY (4 SECONDS)
/// Jak długo po ostatnim kontakcie z ogniem amunicja uchodzi za wciąż grzaną.
#define AQ_COOKOFF_HEAT_MEMORY (2 SECONDS)
/// Okno i limit wybuchów łańcuchowych (od cudzego wybuchu), żeby jeden strzał nie wysadził całego statku.
#define AQ_COOKOFF_CHAIN_WINDOW (10 SECONDS)
#define AQ_COOKOFF_CHAIN_MAX 4

#define AQ_COOKOFF_CAUSE_HEAT "heat"
#define AQ_COOKOFF_CAUSE_BLAST "blast"
#define AQ_COOKOFF_CAUSE_HIT "hit"

GLOBAL_VAR_INIT(aquila_cookoff_chain_window_start, 0)
GLOBAL_VAR_INIT(aquila_cookoff_chain_count, 0)

/datum/component/volatile
	/// Trwa odliczanie do wybuchu.
	var/cooking_off = FALSE
	/// Przyczyna trwającego odliczania (AQ_COOKOFF_CAUSE_*).
	var/cookoff_cause
	var/cookoff_timer
	/// Odliczanie się skończyło, explode() może naprawdę wybuchnąć.
	var/cookoff_ready = FALSE
	/// Ostatni kontakt z ogniem o temperaturze od progu.
	var/last_heat_time = -INFINITY
	/// Tick, w którym obsłużono ex_act albo fire_act. Obrażenia z tego samego ticka nie losują drugi raz przez damage_react.
	var/handled_exposure_tick = -1

/datum/component/volatile/Initialize(volatility = 1, volatile_when_hit = FALSE, explosion_scale = 1)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE || QDELETED(src) || !parent)
		return
	RegisterSignal(parent, COMSIG_ATOM_EX_ACT, PROC_REF(on_ex_act), override = TRUE)
	RegisterSignal(parent, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_bullet_act), override = TRUE)
	if(ismovable(parent))
		RegisterSignal(parent, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact), override = TRUE)

/datum/component/volatile/Destroy(force, silent)
	if(parent)
		UnregisterSignal(parent, list(COMSIG_ATOM_EX_ACT, COMSIG_ATOM_BULLET_ACT, COMSIG_MOVABLE_IMPACT))
	if(cookoff_timer)
		deltimer(cookoff_timer)
		cookoff_timer = null
	return ..()

/datum/component/volatile/examine(datum/source, mob/user, list/examine_list)
	. = ..()
	if(cooking_off)
		examine_list += "<span class='userdanger'>Syczy i dymi, zaraz wybuchnie!</span>"

/// Zamiast natychmiastowego wybuchu: ostrzeżenie i odliczanie. Po odliczaniu finish_cookoff() wywołuje explode() ponownie.
/datum/component/volatile/explode()
	if(!aquila_cookoff_intercept())
		return ..()
	return FALSE

/datum/component/volatile/emptorp/explode()
	if(!aquila_cookoff_intercept())
		return ..()
	return FALSE

/datum/component/volatile/helltorp/explode()
	if(!aquila_cookoff_intercept())
		return ..()
	return FALSE

/// TRUE, gdy wybuch ma poczekać (zaczyna odliczanie albo o wybuchu decyduje już handler ognia lub eksplozji).
/datum/component/volatile/proc/aquila_cookoff_intercept()
	if(cookoff_ready || !parent)
		return FALSE
	// obrażenia od ognia albo eksplozji z tego ticka: o wybuchu decyduje aquila_heat_act() albo on_ex_act()
	if(handled_exposure_tick == world.time)
		return TRUE
	start_cookoff(AQ_COOKOFF_CAUSE_HIT)
	return TRUE

/// Ostrzeżenie i odliczanie do wybuchu. Zwraca TRUE, jeśli odliczanie trwa.
/datum/component/volatile/proc/start_cookoff(cause = AQ_COOKOFF_CAUSE_HIT, delay)
	if(cooking_off)
		return TRUE
	var/atom/movable/bomb = parent
	if(!istype(bomb) || QDELETED(bomb))
		return FALSE
	cooking_off = TRUE
	cookoff_cause = cause
	if(isnull(delay))
		delay = rand(AQ_COOKOFF_MIN_DELAY, AQ_COOKOFF_MAX_DELAY)
	var/turf/T = get_turf(bomb)
	if(T)
		T.visible_message("<span class='userdanger'>[bomb] zaczyna się przegrzewać!</span>", "<span class='warning'>Słyszysz głośne syczenie!</span>")
		playsound(T, 'sound/effects/fuse.ogg', 75, TRUE)
		do_smoke(0, T, /obj/effect/particle_effect/smoke/transparent)
	bomb.Shake(1, 1, delay * 5) // Shake liczy pętle po 0,2 decysekundy
	log_game("Ammunition [bomb] ([bomb.type]) started cooking off ([cause]) at [AREACOORD(bomb)].")
	cookoff_timer = addtimer(CALLBACK(src, PROC_REF(finish_cookoff)), delay, TIMER_STOPPABLE)
	return TRUE

/// Koniec odliczania: wybuch albo, jeśli przyczyną był ogień, a amunicja już nie jest grzana, wystygnięcie.
/datum/component/volatile/proc/finish_cookoff()
	cookoff_timer = null
	var/atom/movable/bomb = parent
	if(!istype(bomb) || QDELETED(bomb))
		return FALSE
	if(cookoff_cause == AQ_COOKOFF_CAUSE_HEAT && !aquila_still_heated())
		cooking_off = FALSE
		cookoff_cause = null
		var/turf/T = get_turf(bomb)
		T?.visible_message("<span class='notice'>[bomb] syczy coraz ciszej i powoli stygnie.</span>")
		return FALSE
	cookoff_ready = TRUE
	var/turf/T = get_turf(bomb)
	T?.visible_message("<span class='danger'>[bomb] wybucha!</span>")
	explode()
	return TRUE

/// Czy amunicja dalej jest w ogniu: niedawny fire_act albo gorący kafel.
/datum/component/volatile/proc/aquila_still_heated()
	if(world.time - last_heat_time <= AQ_COOKOFF_HEAT_MEMORY)
		return TRUE
	var/turf/open/T = get_turf(parent)
	if(!istype(T))
		return FALSE
	if(T.active_hotspot)
		return TRUE
	var/datum/gas_mixture/air = T.return_air()
	return air && air.return_temperature() >= AQ_COOKOFF_MIN_TEMPERATURE

/// Ogień na amunicji (wywoływane z fire_act amunicji i worków prochu oraz z wózka).
/datum/component/volatile/proc/aquila_heat_act(exposed_temperature)
	// fire_act bez temperatury (np. zapalenie bez atmosfery) traktujemy jak prawdziwy ogień
	if(exposed_temperature && exposed_temperature < AQ_COOKOFF_MIN_TEMPERATURE)
		return FALSE
	last_heat_time = world.time
	if(cooking_off)
		return TRUE
	if(!prob(clamp(volatility * 10, 0, 100)))
		return FALSE
	return start_cookoff(AQ_COOKOFF_CAUSE_HEAT)

/// Cudzy wybuch: szansa zależna od siły fali, z limitem łańcucha.
/datum/component/volatile/proc/on_ex_act(datum/source, severity, target)
	SIGNAL_HANDLER
	handled_exposure_tick = world.time
	if(cooking_off)
		return
	// bezpośredni cel wybuchu i tak przepada
	if(target == parent)
		return
	var/chance
	switch(severity)
		if(EXPLODE_DEVASTATE) // co przetrwa obrażenia z bliska, zapala się prawie na pewno; zniszczone odliczanie i tak przerywa
			chance = volatile_when_hit ? 80 : 40
		if(EXPLODE_HEAVY)
			chance = volatile_when_hit ? 50 : 25
		if(EXPLODE_LIGHT)
			chance = volatile_when_hit ? 20 : 10
	if(!chance || !prob(chance))
		return
	if(!aquila_chain_allowed())
		return
	start_cookoff(AQ_COOKOFF_CAUSE_BLAST)

/// Globalny limit wybuchów łańcuchowych w oknie czasu. Zalicza wybuch, jeśli jest miejsce.
/datum/component/volatile/proc/aquila_chain_allowed()
	if(world.time - GLOB.aquila_cookoff_chain_window_start > AQ_COOKOFF_CHAIN_WINDOW)
		GLOB.aquila_cookoff_chain_window_start = world.time
		GLOB.aquila_cookoff_chain_count = 0
	if(GLOB.aquila_cookoff_chain_count >= AQ_COOKOFF_CHAIN_MAX)
		return FALSE
	GLOB.aquila_cookoff_chain_count++
	return TRUE

/// Postrzał: od AQ_COOKOFF_BULLET_MIN_DAMAGE obrażeń, tylko amunicja wrażliwa na uderzenia (głowice, proch).
/datum/component/volatile/proc/on_bullet_act(datum/source, obj/item/projectile/P, def_zone)
	SIGNAL_HANDLER
	if(!volatile_when_hit || cooking_off || !istype(P) || P.nodamage)
		return
	if(P.damage_type != BRUTE && P.damage_type != BURN)
		return
	if(P.damage <= AQ_COOKOFF_BULLET_MIN_DAMAGE)
		return
	if(prob(clamp(P.damage * volatility * 2, 0, 100)))
		start_cookoff(AQ_COOKOFF_CAUSE_HIT)

/// Rzut przez kogoś albo upadek z piętra (throw_impact bez danych rzutu). Sam się rzucający worek prochu się nie liczy.
/datum/component/volatile/proc/on_throw_impact(datum/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(!volatile_when_hit || cooking_off)
		return
	if(throwingdatum && !throwingdatum.thrower)
		return
	if(prob(10))
		start_cookoff(AQ_COOKOFF_CAUSE_HIT)

// /obj/fire_act nie woła ..() z /atom, więc COMSIG_ATOM_FIRE_ACT do przedmiotów nie dochodzi. Amunicja przekazuje ogień sama.
/obj/item/ship_weapon/ammunition/fire_act(exposed_temperature, exposed_volume)
	var/datum/component/volatile/volatile = GetComponent(/datum/component/volatile)
	if(volatile)
		volatile.handled_exposure_tick = world.time
	. = ..()
	if(volatile && !QDELETED(volatile) && !QDELETED(src))
		volatile.aquila_heat_act(exposed_temperature)

/obj/item/powder_bag/fire_act(exposed_temperature, exposed_volume)
	var/datum/component/volatile/volatile = GetComponent(/datum/component/volatile)
	if(volatile)
		volatile.handled_exposure_tick = world.time
	. = ..()
	if(volatile && !QDELETED(volatile) && !QDELETED(src))
		volatile.aquila_heat_act(exposed_temperature)

// Amunicja na wózku: fire_act dochodzi tylko do rzeczy leżących na kaflu, a eksplozja trafia zawartość tylko w epicentrum.
/obj/structure/munitions_trolley/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	for(var/obj/item/munition in contents)
		munition.fire_act(exposed_temperature, exposed_volume)

/obj/structure/munitions_trolley/contents_explosion(severity, target)
	. = ..()
	for(var/obj/item/munition in contents)
		var/datum/component/volatile/volatile = munition.GetComponent(/datum/component/volatile)
		volatile?.on_ex_act(munition, severity, target)

// Pocisk burtowy to spakowany proch z pociskiem: mały wybuch (niestabilność 1 daje lekką falę na 1 pole).
/obj/item/ship_weapon/ammunition/broadside_shell
	volatility = 1
	explode_when_hit = TRUE

/obj/item/ship_weapon/ammunition/broadside_shell/plasma
	volatility = 2

#undef AQ_COOKOFF_MIN_TEMPERATURE
#undef AQ_COOKOFF_BULLET_MIN_DAMAGE
#undef AQ_COOKOFF_MIN_DELAY
#undef AQ_COOKOFF_MAX_DELAY
#undef AQ_COOKOFF_HEAT_MEMORY
#undef AQ_COOKOFF_CHAIN_WINDOW
#undef AQ_COOKOFF_CHAIN_MAX

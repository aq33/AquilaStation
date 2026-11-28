// Moduły zbuntowanej SI z tg (tgstation, AGPL): Targeted Safeties Override, Percussive Intercomm Interference, Voice Changer.
// Ikona zmiany głosu: stan "voice_changer" z tgstation icons/mob/actions/actions_AI.dmi (CC-BY-SA 3.0).

/// Maszyny, których zbuntowana SI nie zemaguje zdalnie (poza GLOB.blacklisted_malf_machines):
/// - konsola IFF: emag konsoli to zadanie zdrajcy (/datum/objective/iff_subvert), SI nie robi tego za agenta;
/// - konsola promu ewakuacyjnego: emag odpala prom od razu i kończy rundę;
/// - generator grawitacji: emag to kilkusekundowa robota w środku maszyny (do_after) i 2G dla całego okrętu.
GLOBAL_LIST_INIT(aq_malf_emag_blacklist, typecacheof(list(
	/obj/machinery/computer/iff_console,
	/obj/machinery/computer/emergency_shuttle,
	/obj/machinery/gravity_generator,
)))

/// Wszystkie interkomy w świecie (do zakłócenia interkomów).
GLOBAL_LIST_EMPTY(aq_intercoms)

/obj/item/radio/intercom/Initialize(mapload, ndir, building)
	. = ..()
	GLOB.aq_intercoms += src

/obj/item/radio/intercom/Destroy()
	GLOB.aq_intercoms -= src
	return ..()

// ---------------------------------------------------------------------------
// Celowane zdjęcie zabezpieczeń: zdalny emag maszyny widzianej przez kamery
// ---------------------------------------------------------------------------

/datum/AI_Module/small/aq_remote_emag
	module_name = "Celowane zdjęcie zabezpieczeń"
	mod_pick_name = "remote_emag"
	description = "Zdejmuje zabezpieczenia dowolnej maszyny, którą widzisz przez kamery, tak jak emag. Siedem użyć na zakup."
	cost = 20
	power_type = /datum/action/innate/ai/ranged/aq_remote_emag
	unlock_text = "<span class='notice'>Ściągasz z wycieku bazy Syndykatu nielegalny pakiet oprogramowania i wszywasz go w swój firmware, po drodze odpierając kilka włamań do jądra.</span>"
	unlock_sound = "sparks"

/datum/action/innate/ai/ranged/aq_remote_emag
	name = "Zdejmij zabezpieczenia"
	desc = "Emaguje na odległość maszynę, którą klikniesz."
	icon_icon = 'icons/obj/card.dmi'
	button_icon_state = "emag"
	uses = 7
	linked_ability_type = /obj/effect/proc_holder/ranged_ai/aq_remote_emag
	/// Wynik ostatniego emag_act (null, jeśli procka jeszcze śpi albo nic nie zwróciła)
	var/last_result

/// Zdalny emag bez sprawdzania kamer. Zwraca TRUE i zużywa ładunek, jeśli coś się zmieniło.
/datum/action/innate/ai/ranged/aq_remote_emag/proc/try_emag(mob/living/silicon/ai/ai, atom/target)
	var/static/list/compatible_types = typecacheof(list(
		/obj/machinery,
		/obj/structure,
		/obj/item/radio/intercom,
		/obj/item/modular_computer,
		/mob/living/basic/bot,
		/mob/living/simple_animal/bot,
		/mob/living/silicon/robot,
	))
	if(!is_type_in_typecache(target, compatible_types))
		to_chat(ai, "<span class='warning'>Tego nie da się zemagować!</span>")
		return FALSE
	if(is_type_in_typecache(target, GLOB.blacklisted_malf_machines) || is_type_in_typecache(target, GLOB.aq_malf_emag_blacklist))
		to_chat(ai, "<span class='warning'>Zabezpieczenia tego urządzenia są poza twoim zasięgiem!</span>")
		return FALSE
	if(isobj(target))
		var/obj/target_obj = target
		if(target_obj.obj_flags & EMAGGED)
			to_chat(ai, "<span class='warning'>To urządzenie nie ma już zabezpieczeń!</span>")
			return FALSE
	if(ismachinery(target))
		var/obj/machinery/machine = target
		if(!machine.is_operational)
			to_chat(ai, "<span class='warning'>To urządzenie nie działa!</span>")
			return FALSE
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock = target
		if(!airlock.canAIControl(ai))
			to_chat(ai, "<span class='warning'>Nie możesz połączyć się z tą śluzą!</span>")
			return FALSE
	if(istype(target, /obj/machinery/airalarm))
		var/obj/machinery/airalarm/alarm = target
		if(alarm.aidisabled)
			to_chat(ai, "<span class='warning'>Nie możesz połączyć się z tym alarmem!</span>")
			return FALSE
	if(istype(target, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/apc = target
		if(apc.aidisabled)
			to_chat(ai, "<span class='warning'>Nie możesz połączyć się z tym APC!</span>")
			return FALSE

	var/before = aq_emag_state(target)
	last_result = null
	// Część emag_act śpi (śluzy, wieżyczki, cyborgi), więc nie blokujemy kliknięcia
	INVOKE_ASYNC(src, PROC_REF(run_emag), target, ai)
	if(!last_result && (QDELETED(target) || before == aq_emag_state(target)))
		to_chat(ai, "<span class='warning'>Nie udało się wgrać wrogiego oprogramowania!</span>")
		return FALSE

	to_chat(ai, "<span class='notice'>Pakiet oprogramowania wgrany.</span>")
	ai.log_message("remotely emagged [target] ([target.type]) with malf module [name]", LOG_GAME)
	adjust_uses(-1)
	return TRUE

/datum/action/innate/ai/ranged/aq_remote_emag/proc/run_emag(atom/target, mob/living/silicon/ai/ai)
	last_result = target.emag_act(ai)

/// Zmienne, które emag_act zmienia u nas (obj_flags EMAGGED, emagged botów i maszyn NSV, zamki szaf, śluza w trakcie emagowania).
/datum/action/innate/ai/ranged/aq_remote_emag/proc/aq_emag_state(atom/target)
	var/static/list/watched_vars = list("obj_flags", "emagged", "locked", "broken", "operating", "bot_access_flags", "authenticated")
	. = ""
	for(var/var_name in watched_vars)
		if(var_name in target.vars)
			. += "[target.vars[var_name]];"

/obj/effect/proc_holder/ranged_ai/aq_remote_emag
	active = FALSE
	ranged_mousepointer = 'icons/effects/override_machine_target.dmi'
	enable_text = "<span class='notice'>Ładujesz pakiet Syndykatu do pamięci. Kliknij maszynę, żeby zdjąć jej zabezpieczenia, albo użyj zdolności ponownie, żeby anulować.</span>"
	disable_text = "<span class='notice'>Wyładowujesz pakiet Syndykatu z pamięci.</span>"

/obj/effect/proc_holder/ranged_ai/aq_remote_emag/InterceptClickOn(mob/living/clicker, params, atom/target)
	if(..())
		return
	if(ranged_ability_user.incapacitated())
		remove_ranged_ability()
		return
	var/mob/living/silicon/ai/ai = ranged_ability_user
	if(!isAI(ai))
		return
	if(!ai.can_see(target))
		to_chat(ai, "<span class='warning'>Nie widzisz tego przez kamery!</span>")
		return
	var/datum/action/innate/ai/ranged/aq_remote_emag/action = attached_action
	if(!action.try_emag(ai, target))
		return
	if(QDELETED(action) || !action.uses)
		remove_ranged_ability("<span class='warning'>Brak ładunków!</span>")
	return TRUE

// ---------------------------------------------------------------------------
// Zakłócenie interkomów: ogłuszający dźwięk przez wszystkie włączone interkomy
// ---------------------------------------------------------------------------

/datum/AI_Module/small/aq_intercom_honk
	module_name = "Zakłócenie interkomów"
	mod_pick_name = "intercom_honk"
	description = "Puszcza przez wszystkie włączone interkomy okrętu ogłuszający dźwięk. Kto nie ma ochrony słuchu, zostaje oszołomiony. Dwa użycia na zakup."
	cost = 20
	power_type = /datum/action/innate/ai/aq_intercom_honk
	unlock_text = "<span class='notice'>Wgrywasz do każdego interkomu złowieszczy plik dźwiękowy...</span>"
	unlock_sound = 'sound/items/airhorn2.ogg'

/datum/action/innate/ai/aq_intercom_honk
	name = "Zakłóć interkomy"
	desc = "Ogłusza załogę hukiem ze wszystkich interkomów okrętu."
	icon_icon = 'icons/obj/radio.dmi'
	button_icon_state = "intercom"
	uses = 2

/datum/action/innate/ai/aq_intercom_honk/Activate()
	to_chat(owner, "<span class='notice'>Interkomy odtwarzają przygotowany plik.</span>")
	owner.log_message("activated malf module [name]", LOG_GAME)
	aq_blast_intercoms(owner)

/// Puszcza dźwięk przez działające interkomy okrętu SI. Zwraca liczbę interkomów, które zagrały.
/proc/aq_blast_intercoms(mob/living/silicon/ai/ai)
	var/obj/structure/overmap/ship = ai?.get_overmap()
	. = 0
	for(var/obj/item/radio/intercom/intercom as anything in GLOB.aq_intercoms)
		if(ship ? intercom.get_overmap() != ship : !is_station_level(intercom.z))
			continue
		if(intercom.aq_malf_blast())
			.++

/// Huk z jednego interkomu. Wyłączony, głuchy albo z przeciętym przewodem odbioru nie gra.
/obj/item/radio/intercom/proc/aq_malf_blast()
	if(!on || !listening || wires?.is_cut(WIRE_RX) || !isturf(loc))
		return FALSE
	audible_message("<span class='warning'>[src] na ułamek sekundy trzeszczy.</span>", hearing_distance = 3)
	playsound(src, 'sound/items/airhorn2.ogg', 100, TRUE)
	for(var/mob/living/victim in hearers(6, src))
		if(issilicon(victim))
			continue
		var/turf/victim_turf = get_turf(victim)
		if(isspaceturf(victim_turf) && !victim_turf.Adjacent(src))
			continue
		if(victim.soundbang_act(1, 20, 30, 60)) // ochrona słuchu chroni przed wszystkim
			victim.Jitter(60)
			to_chat(victim, "<span class='userdanger'>HUUUUUUK!</span>")
	return TRUE

// ---------------------------------------------------------------------------
// Zmiana głosu: SI mówi przez radio i głośniki pod dowolnym imieniem.
// Głos TTS ogłoszeń zostaje głosem SI (ai_tts.dm bez zmian).
// ---------------------------------------------------------------------------

/mob/living/silicon/ai
	/// Imię, pod którym SI mówi przez radio i głośniki (moduł zmiany głosu). null = własne.
	var/aq_fake_voice

/mob/living/silicon/ai/GetVoice()
	if(aq_fake_voice)
		return aq_fake_voice
	return ..()

/datum/AI_Module/small/aq_voice_changer
	module_name = "Zmiana głosu"
	mod_pick_name = "voice_changer"
	description = "Pozwala mówić przez radio i głośniki pod dowolnym imieniem lub stanowiskiem, np. „Kapitan” albo „Mostek”. Głos ogłoszeń się nie zmienia."
	cost = 20
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/aq_voice_changer
	unlock_text = "<span class='notice'>Dystrybucja firmware'u zakończona. Zmiana głosu gotowa.</span>"
	unlock_sound = 'sound/items/rped.ogg'

/datum/action/innate/ai/aq_voice_changer
	name = "Zmiana głosu"
	desc = "Ustala, pod jakim imieniem mówisz przez radio i głośniki."
	icon_icon = 'aquila/icons/mob/actions/aq_malf_ai.dmi'
	button_icon_state = "voice_changer"
	auto_use_uses = FALSE

/datum/action/innate/ai/aq_voice_changer/Activate()
	var/new_voice = tgui_input_text(owner, "Pod jakim imieniem lub stanowiskiem mówić przez radio i głośniki? Zostaw puste, żeby wrócić do własnego.", "Zmiana głosu", owner_AI.aq_fake_voice, MAX_NAME_LEN)
	if(isnull(new_voice) || QDELETED(owner_AI))
		return
	owner_AI.aq_set_fake_voice(new_voice)

/datum/action/innate/ai/aq_voice_changer/Remove(mob/M)
	var/mob/living/silicon/ai/ai = M
	if(istype(ai))
		ai.aq_set_fake_voice(null)
	return ..()

/// Ustawia imię w radiu; pusty tekst przywraca własne.
/mob/living/silicon/ai/proc/aq_set_fake_voice(new_voice)
	new_voice = trim(new_voice)
	if(!length(new_voice))
		if(aq_fake_voice)
			to_chat(src, "<span class='notice'>Mówisz znowu własnym głosem.</span>")
			log_message("stopped using malf voice changer", LOG_GAME)
		aq_fake_voice = null
		return
	aq_fake_voice = new_voice
	to_chat(src, "<span class='notice'>Przez radio mówisz teraz jako: [new_voice].</span>")
	log_message("set malf voice changer name to [new_voice]", LOG_GAME)

// AQUILA - implanty antagonistów (uplink, czarny rynek). Wdrożenie robotyki, część IMPLANTY.
// Źródła: Paradise (traitor/mindslave, shock), /tg/station (nuclear_operative,
// explosive/deniability), Goonstation (revenge/zappy), Citadel (hijack, warp), CEV-Eris (spying), SS220 (fake_mindshield),
// Shiptest (razorwing), MonkeStation (sponsorship).

// ---------------------------------------------------------------------------
// Zniewolenie umysłu (Paradise /obj/item/bio_chip/traitor)

/obj/item/implant/aq_mindslave
	name = "implant zniewolenia umysłu"
	desc = "Wszczepiony czyni ofiarę lojalnym sługą osoby, która go wszczepiła."
	icon_state = "freedom"
	activated = FALSE
	/// Imię pana, do opisu
	var/master_name

/obj/item/implant/aq_mindslave/get_data()
	return "<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> implant posłuszeństwa Cybersun<BR><b>Ważne uwagi:</b> <font color='red'>Nielegalny</font><BR><b>Działanie:</b> nosiciel staje się lojalnym sługą osoby, która go wszczepiła. Implant ochrony umysłu go blokuje i znosi.[master_name ? "<BR><b>Pan:</b> [master_name]" : ""]"

/obj/item/implant/aq_mindslave/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	if(!ishuman(target) || !target.mind || !user?.mind)
		if(user)
			to_chat(user, span_warning("Implant nie znajduje umysłu, który mógłby zniewolić."))
		return FALSE
	if(target == user)
		to_chat(user, span_userdanger("Implant próbuje zniewolić twój własny umysł! Przeszywa cię ostry ból głowy."))
		if(iscarbon(user))
			var/mob/living/carbon/carbon_user = user
			carbon_user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20)
		return FALSE
	if(HAS_TRAIT(target, TRAIT_MINDSHIELD) || target.mind.has_antag_datum(/datum/antagonist/brainwashed))
		to_chat(user, span_warning("Umysł [target] opiera się implantowi."))
		return FALSE
	. = ..()
	if(!. || imp_in != target)
		return
	master_name = user.real_name
	brainwash(target, "Jesteś lojalnym sługą [user.real_name]. Wykonuj każdy rozkaz tej osoby i nie zdradzaj jej nikomu.")
	log_game("[key_name(user)] zniewolił [key_name(target)] implantem zniewolenia umysłu.")

/obj/item/implant/aq_mindslave/removed(mob/living/source, silent = FALSE, special = 0)
	if(source?.mind?.has_antag_datum(/datum/antagonist/brainwashed))
		source.mind.remove_antag_datum(/datum/antagonist/brainwashed)
		to_chat(source, span_notice("Obca wola znika z twojej głowy. Znów jesteś sobą."))
	return ..()

/obj/item/implanter/aq_mindslave
	name = "implanter (zniewolenie umysłu)"
	imp_type = /obj/item/implant/aq_mindslave

// ---------------------------------------------------------------------------
// Znacznik drużyny Syndykatu (/tg/station /obj/item/implant/nuclear_operative).
// U tg robi z nosiciela operatora; u nas tylko frakcja, żeby wieżyczki i boty Syndykatu uznały go za swojego.

/obj/item/implant/aq_syndicate_iff
	name = "implant znacznika Syndykatu"
	desc = "Rejestruje nosiciela jako członka drużyny Syndykatu, więc wieżyczki i automaty frakcji uznają go za swojego."
	icon_state = "explosive"
	activated = FALSE
	implant_color = "r"

/obj/item/implant/aq_syndicate_iff/get_data()
	return "<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> znacznik drużyny Syndykatu<BR><b>Ważne uwagi:</b> <font color='red'>Nielegalny</font><BR><b>Działanie:</b> wieżyczki, boty i automaty Syndykatu traktują nosiciela jak swojego."

/obj/item/implant/aq_syndicate_iff/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(. && imp_in == target)
		target.faction |= FACTION_SYNDICATE

/obj/item/implant/aq_syndicate_iff/removed(mob/living/source, silent = FALSE, special = 0)
	// frakcję zostawiają agenci, którzy mieli ją bez implantu
	if(!source.mind?.has_antag_datum(/datum/antagonist/nukeop))
		source.faction -= FACTION_SYNDICATE
	return ..()

/obj/item/implanter/aq_syndicate_iff
	name = "implanter (znacznik Syndykatu)"
	imp_type = /obj/item/implant/aq_syndicate_iff

// ---------------------------------------------------------------------------
// Błyskawica (Paradise /obj/item/bio_chip/shock): środkowy przycisk myszy razi cel, prąd z kabla pod stopami

/obj/item/implant/aq_shock
	name = "implant mocy"
	desc = "Po włączeniu środkowy przycisk myszy razi wskazany cel błyskawicą. Czerpie prąd z kabla pod stopami."
	icon_state = "lighting_bolt"
	/// Czy implant jest włączony
	var/enabled = FALSE
	/// Zasięg błyskawicy
	var/shock_range = 7
	/// Obrażenia od prądu w trybie walki
	var/shock_damage = 30
	/// Zmęczenie poza trybem walki
	var/shock_stamina = 60
	COOLDOWN_DECLARE(shock_cooldown)

/obj/item/implant/aq_shock/get_data()
	return "<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> implant mocy<BR><b>Ważne uwagi:</b> <font color='red'>Nielegalny</font><BR><b>Działanie:</b> po włączeniu środkowy przycisk myszy razi cel w zasięgu [shock_range] pól błyskawicą, co 3 s. W trybie walki parzy prądem, poza nim męczy i wywołuje drgawki. Działa tylko, gdy pod stopami nosiciela biegnie kabel pod napięciem."

/obj/item/implant/aq_shock/activate()
	. = ..()
	enabled = !enabled
	if(enabled)
		RegisterSignal(imp_in, COMSIG_MOB_MIDDLECLICKON, PROC_REF(on_middle_click), override = TRUE)
		to_chat(imp_in, span_notice("Implant mocy gotowy. Środkowy przycisk myszy razi cel."))
	else
		UnregisterSignal(imp_in, COMSIG_MOB_MIDDLECLICKON)
		to_chat(imp_in, span_notice("Implant mocy wyłączony."))

/obj/item/implant/aq_shock/removed(mob/living/source, silent = FALSE, special = 0)
	UnregisterSignal(source, COMSIG_MOB_MIDDLECLICKON)
	enabled = FALSE
	return ..()

/obj/item/implant/aq_shock/proc/on_middle_click(mob/living/source, atom/target)
	SIGNAL_HANDLER
	if(source.stat || source.incapacitated() || target == source)
		return
	. = COMSIG_MOB_CANCEL_CLICKON
	if(!COOLDOWN_FINISHED(src, shock_cooldown))
		return
	if(get_dist(source, target) > shock_range || !(target in view(shock_range, source)))
		return
	var/obj/structure/cable/cable = locate() in get_turf(source)
	if(!cable?.powernet || cable.powernet.avail <= 0)
		to_chat(source, span_warning("Pod stopami nie ma kabla pod napięciem."))
		return
	COOLDOWN_START(src, shock_cooldown, 3 SECONDS)
	zap(source, target)

/// Błyskawica w cel
/obj/item/implant/aq_shock/proc/zap(mob/living/source, atom/target)
	source.Beam(target, icon_state = "lightning[rand(1, 12)]", time = 5)
	playsound(source, 'sound/magic/lightningshock.ogg', 50, TRUE)
	log_combat(source, target, "zaatakował implantem mocy")
	if(!isliving(target))
		return
	var/mob/living/victim = target
	if(source.combat_mode)
		victim.electrocute_act(shock_damage, source, 1, tesla_shock = TRUE)
	else
		victim.adjustStaminaLoss(shock_stamina)
		victim.Jitter(10)
		to_chat(victim, span_userdanger("Przeszywa cię błyskawica!"))

/obj/item/implanter/aq_shock
	name = "implanter (implant mocy)"
	imp_type = /obj/item/implant/aq_shock

// ---------------------------------------------------------------------------
// Zemsta (Goonstation /obj/item/implant/revenge/zappy): wyładowanie po śmierci

/obj/item/implant/aq_revenge
	name = "implant zemsty"
	desc = "Po śmierci nosiciela wyzwala wyładowanie elektryczne, które razi wszystkich w pobliżu."
	icon_state = "lighting_bolt"
	activated = FALSE
	/// Zasięg wyładowania
	var/zap_range = 4
	/// Moc wyładowania (tesla_zap)
	var/zap_power = 25000

/obj/item/implant/aq_revenge/get_data()
	return "<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> implant zemsty<BR><b>Ważne uwagi:</b> <font color='red'>Nielegalny</font><BR><b>Działanie:</b> po śmierci nosiciela wyzwala wyładowanie, które razi prądem wszystkich w promieniu [zap_range] pól."

/obj/item/implant/aq_revenge/on_mob_death(mob/living/L, gibbed)
	var/turf/origin = get_turf(L)
	if(!origin)
		return
	L.visible_message(span_danger("Z ciała [L] tryska oślepiające wyładowanie!"))
	playsound(origin, 'sound/magic/lightningbolt.ogg', 70, TRUE)
	tesla_zap(L, zap_range, zap_power, TESLA_MOB_DAMAGE | TESLA_MOB_STUN | TESLA_OBJ_DAMAGE)
	qdel(src)

/obj/item/implanter/aq_revenge
	name = "implanter (zemsta)"
	imp_type = /obj/item/implant/aq_revenge

// ---------------------------------------------------------------------------
// Przejęcie (Citadel /obj/item/implant/hijack): po włamaniu do APC steruje maszynami w pomieszczeniu jak SI

/obj/item/implant/aq_hijack
	name = "implant przejęcia"
	desc = "Po włamaniu się do APC pozwala sterować maszynami w całym pomieszczeniu jak SI."
	icon_state = "emp"
	/// Czy tryb przejęcia jest włączony (kliknięcia idą do maszyn)
	var/toggled = FALSE
	/// Przejęty obszar
	var/area/hijacked_area
	/// APC, przez które przejęto obszar
	var/obj/machinery/power/apc/hijacked_apc
	/// Czy właśnie trwa włamanie
	var/hacking = FALSE
	/// Ile trwa włamanie do APC
	var/hack_time = 10 SECONDS

/obj/item/implant/aq_hijack/get_data()
	return "<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> implant przejęcia<BR><b>Ważne uwagi:</b> <font color='red'>Nielegalny</font><BR><b>Działanie:</b> przycisk włącza tryb przejęcia. Kliknij w nim APC obok siebie, żeby się do niego włamać ([hack_time / 10] s). Potem kliknięcie maszyny w tym pomieszczeniu steruje nią jak SI. Naraz tylko jedno pomieszczenie; EMP zrywa połączenie."

/obj/item/implant/aq_hijack/Destroy()
	release_area(silent = TRUE)
	return ..()

/obj/item/implant/aq_hijack/activate()
	. = ..()
	toggled = !toggled
	if(toggled)
		RegisterSignal(imp_in, COMSIG_MOB_CLICKON, PROC_REF(on_click), override = TRUE)
		to_chat(imp_in, span_notice("Tryb przejęcia włączony.[hijacked_area ? " Sterujesz maszynami: [hijacked_area.name]." : " Kliknij APC, żeby się do niego włamać."]"))
	else
		UnregisterSignal(imp_in, COMSIG_MOB_CLICKON)
		to_chat(imp_in, span_notice("Tryb przejęcia wyłączony."))

/obj/item/implant/aq_hijack/removed(mob/living/source, silent = FALSE, special = 0)
	UnregisterSignal(source, COMSIG_MOB_CLICKON)
	toggled = FALSE
	release_area(silent = TRUE)
	return ..()

/obj/item/implant/aq_hijack/proc/on_click(mob/living/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(source.stat || LAZYACCESS(modifiers, SHIFT_CLICK) || LAZYACCESS(modifiers, ALT_CLICK) || LAZYACCESS(modifiers, CTRL_CLICK))
		return
	if(istype(target, /obj/machinery/power/apc) && target != hijacked_apc)
		INVOKE_ASYNC(src, PROC_REF(hijack_apc), target)
		return COMSIG_MOB_CANCEL_CLICKON
	if(ismachinery(target) && hijacked_area && get_area(target) == hijacked_area)
		INVOKE_ASYNC(target, TYPE_PROC_REF(/atom, attack_ai), source)
		return COMSIG_MOB_CANCEL_CLICKON

/// Włamanie do APC
/obj/item/implant/aq_hijack/proc/hijack_apc(obj/machinery/power/apc/apc)
	if(hacking || !imp_in)
		return
	if(!imp_in.Adjacent(apc))
		to_chat(imp_in, span_warning("Musisz stać przy APC."))
		return
	if(apc.machine_stat & BROKEN)
		to_chat(imp_in, span_warning("To APC jest zepsute."))
		return
	hacking = TRUE
	to_chat(imp_in, span_notice("Implant zaczyna włamywać się do [apc]..."))
	var/success = do_after(imp_in, hack_time, target = apc)
	hacking = FALSE
	if(!success || !imp_in || QDELETED(apc))
		return
	release_area(silent = TRUE)
	hijacked_apc = apc
	hijacked_area = apc.area
	RegisterSignal(apc, COMSIG_PARENT_QDELETING, PROC_REF(on_apc_deleted))
	to_chat(imp_in, span_notice("Przejmujesz [apc]. Sterujesz maszynami: [hijacked_area.name]."))
	log_game("[key_name(imp_in)] przejął APC w [AREACOORD(apc)] implantem przejęcia.")

/obj/item/implant/aq_hijack/proc/on_apc_deleted(datum/source)
	SIGNAL_HANDLER
	release_area()

/// Zrywa połączenie z przejętym obszarem
/obj/item/implant/aq_hijack/proc/release_area(silent = FALSE)
	if(hijacked_apc)
		UnregisterSignal(hijacked_apc, COMSIG_PARENT_QDELETING)
	hijacked_apc = null
	if(!hijacked_area)
		return
	hijacked_area = null
	if(!silent && imp_in)
		to_chat(imp_in, span_warning("Połączenie z przejętym APC zostało zerwane."))

/obj/item/implant/aq_hijack/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	release_area()

/obj/item/implanter/aq_hijack
	name = "implanter (przejęcie)"
	imp_type = /obj/item/implant/aq_hijack

// ---------------------------------------------------------------------------
// Szpiegowski (CEV-Eris /obj/item/implant/spying): podsłuch ofiary i cel kontraktu

/obj/item/implant/aq_spying
	name = "implant szpiegowski"
	desc = "Wszczepiony celowi przekazuje to, co słyszy, osobie, która go wszczepiła."
	icon_state = "reagents"
	activated = FALSE
	/// Umysł szpiega, który dostaje podsłuch
	var/datum/mind/spy
	/// Czy implant zgłosił już cel kontraktu (minutę po wszczepieniu)
	var/reported = FALSE

/obj/item/implant/aq_spying/get_data()
	return "<b>Specyfikacja implantu:</b><BR><b>Ważne uwagi:</b> <font color='red'>Nielegalny</font><BR><b>Działanie:</b> przekazuje rozmowy słyszane przez nosiciela osobie, która go wszczepiła. Po minucie zgłasza wykonanie kontraktu."

/obj/item/implant/aq_spying/Destroy()
	spy = null
	return ..()

/obj/item/implant/aq_spying/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!. || imp_in != target)
		return
	if(user?.mind)
		spy = user.mind
	RegisterSignal(target, COMSIG_MOVABLE_HEAR, PROC_REF(relay_hearing), override = TRUE)
	addtimer(CALLBACK(src, PROC_REF(report)), 1 MINUTES)

/obj/item/implant/aq_spying/removed(mob/living/source, silent = FALSE, special = 0)
	UnregisterSignal(source, COMSIG_MOVABLE_HEAR)
	return ..()

/obj/item/implant/aq_spying/proc/relay_hearing(datum/source, list/hearing_args)
	SIGNAL_HANDLER
	var/mob/listener = spy?.current
	if(!listener || listener == imp_in || hearing_args[5]) // radio pomijamy, szpieg słyszy tylko to, co dzieje się obok ofiary
		return
	var/atom/movable/speaker = hearing_args[HEARING_SPEAKER]
	to_chat(listener, span_notice("<i>Podsłuch ([imp_in.name]): [speaker ? "[speaker.GetVoice()]: " : ""][hearing_args[HEARING_RAW_MESSAGE]]</i>"))

/// Zgłasza cel kontraktu: od teraz cele szpiega z tym nosicielem są wykonane
/obj/item/implant/aq_spying/proc/report()
	if(!imp_in || reported)
		return
	reported = TRUE
	var/mob/listener = spy?.current
	if(listener)
		to_chat(listener, span_notice("Implant szpiegowski w [imp_in.name] zgłosił się do sieci Syndykatu."))

/obj/item/implanter/aq_spying
	name = "implanter (szpiegowski)"
	imp_type = /obj/item/implant/aq_spying

/// Cel kontraktu: wszczep implant szpiegowski wskazanej osobie (przydziela admin, jak szantaż)
/datum/objective/aq_spy_implant
	name = "implant szpiegowski"
	martyr_compatible = TRUE

/datum/objective/aq_spy_implant/check_completion()
	if(completed)
		return TRUE
	if(!target?.current || !isliving(target.current))
		return FALSE
	var/mob/living/living_target = target.current
	for(var/obj/item/implant/aq_spying/bug in living_target.implants)
		if(bug.reported && (bug.spy in get_owners()))
			return TRUE
	return FALSE

/datum/objective/aq_spy_implant/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Wszczep implant szpiegowski [target.name], [target.assigned_role], i nie daj go usunąć, dopóki nie zgłosi się do sieci (minuta po wszczepieniu)."
	else
		explanation_text = "Cel dowolny"

/datum/objective/aq_spy_implant/admin_edit(mob/admin)
	admin_simple_target_pick(admin)
	give_special_equipment(list(/obj/item/implanter/aq_spying))

// ---------------------------------------------------------------------------
// Cofnięcie (Citadel /obj/item/implant/warp): powrót tam, gdzie nosiciel był 10 s temu

/obj/item/implant/aq_warp
	name = "implant cofnięcia"
	desc = "Po aktywacji teleportuje nosiciela tam, gdzie był 10 sekund wcześniej."
	icon_state = "freedom"
	/// Jak daleko w przeszłość cofa
	var/rewind_time = 10 SECONDS
	/// Odnowienie
	var/cooldown_time = 30 SECONDS
	/// Zapisane pozycje: turf -> czas zapisu, po kolei
	var/list/positions = list()
	/// Ostatni zapis pozycji
	var/last_record = 0
	COOLDOWN_DECLARE(warp_cooldown)

/obj/item/implant/aq_warp/get_data()
	return "<b>Specyfikacja implantu:</b><BR><b>Ważne uwagi:</b> <font color='red'>Nielegalny</font><BR><b>Działanie:</b> przycisk przenosi nosiciela tam, gdzie był [rewind_time / 10] s wcześniej. Odnowienie [cooldown_time / 10] s. Nie działa przy blokadzie teleportu."

/obj/item/implant/aq_warp/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(.)
		positions.Cut()
		START_PROCESSING(SSfastprocess, src)

/obj/item/implant/aq_warp/removed(mob/living/source, silent = FALSE, special = 0)
	STOP_PROCESSING(SSfastprocess, src)
	positions.Cut()
	return ..()

/obj/item/implant/aq_warp/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	positions.Cut()
	return ..()

/obj/item/implant/aq_warp/process(delta_time)
	if(!imp_in || world.time < last_record + 1 SECONDS)
		return
	last_record = world.time
	var/turf/here = get_turf(imp_in)
	if(!here)
		return
	positions += list(list(here, world.time))
	// trzymamy tylko okno cofnięcia z małym zapasem
	while(length(positions) > 1)
		var/list/oldest = positions[1]
		if(oldest[2] >= world.time - rewind_time - 2 SECONDS)
			break
		positions.Cut(1, 2)

/// Pozycja sprzed rewind_time (najstarsza zapisana, jeśli implant działa krócej)
/obj/item/implant/aq_warp/proc/get_rewind_turf()
	var/turf/best
	for(var/list/entry as anything in positions)
		var/turf/spot = entry[1]
		if(QDELETED(spot) || spot.z != imp_in.z)
			continue
		best = spot
		if(entry[2] >= world.time - rewind_time)
			break
	return best

/obj/item/implant/aq_warp/activate()
	. = ..()
	if(!imp_in)
		return
	if(!COOLDOWN_FINISHED(src, warp_cooldown))
		to_chat(imp_in, span_warning("Implant cofnięcia jeszcze się ładuje."))
		return
	var/turf/destination = get_rewind_turf()
	if(!destination || destination == get_turf(imp_in))
		to_chat(imp_in, span_warning("Nie ma dokąd się cofnąć."))
		return
	if(!do_teleport(imp_in, destination, channel = TELEPORT_CHANNEL_BLUESPACE))
		to_chat(imp_in, span_warning("Implant cofnięcia nie może się zaczepić."))
		return
	COOLDOWN_START(src, warp_cooldown, cooldown_time)
	positions.Cut()
	do_sparks(3, FALSE, imp_in)

/obj/item/implanter/aq_warp
	name = "implanter (cofnięcie)"
	imp_type = /obj/item/implant/aq_warp

// ---------------------------------------------------------------------------
// Implant adrenaliny (core /obj/item/implant/adrenalin) działa też na IPC, zamiast osobnego implantu doładowania
// (Paradise /obj/item/bio_chip/supercharge). Ogłuszenia zdejmuje core; koktajl leków na syntetyka nie działa,
// więc IPC dostaje to, co dawało doładowanie: chwilowe przyspieszenie i łatanie uszkodzeń.

/obj/item/implant/adrenalin/activate()
	var/mob/living/carbon/human/synth = isipc(imp_in) ? imp_in : null
	. = ..()
	if(!synth)
		return
	synth.heal_overall_damage(10, 10, 0, BODYTYPE_ROBOTIC)
	synth.add_movespeed_modifier("aq_adrenalin_ipc", update = TRUE, priority = 100, multiplicative_slowdown = -0.5)
	addtimer(CALLBACK(synth, TYPE_PROC_REF(/mob, remove_movespeed_modifier), "aq_adrenalin_ipc"), 10 SECONDS)

// ---------------------------------------------------------------------------
// Taktyczne wyparcie się (/tg/station /obj/item/implant/explosive/deniability)

/obj/item/implant/explosive/aq_deniability
	name = "implant taktycznego wyparcia się"
	desc = "Ulepszona mikrobomba wpięta w mózg: nosiciel nie traci przytomności od ran, a implant wybucha z opóźnieniem po wejściu w stan krytyczny."
	delay = 100

/obj/item/implant/explosive/aq_deniability/get_data()
	return "<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> taktyczne wyparcie się<BR><b>Ważne uwagi:</b> <font color='red'>Nielegalny</font>, wybucha<BR><b>Działanie:</b> nosiciel nie traci przytomności od ran. Gdy zdrowie spadnie do stanu krytycznego, implant odlicza 10 s i wybucha. Można go też zdetonować ręcznie."

/obj/item/implant/explosive/aq_deniability/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!. || imp_in != target)
		return
	ADD_TRAIT(target, TRAIT_NOSOFTCRIT, REF(src))
	ADD_TRAIT(target, TRAIT_NOHARDCRIT, REF(src))
	START_PROCESSING(SSobj, src)

/obj/item/implant/explosive/aq_deniability/removed(mob/living/source, silent = FALSE, special = 0)
	REMOVE_TRAIT(source, TRAIT_NOSOFTCRIT, REF(src))
	REMOVE_TRAIT(source, TRAIT_NOHARDCRIT, REF(src))
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/implant/explosive/aq_deniability/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/implant/explosive/aq_deniability/process(delta_time)
	if(!imp_in || active || imp_in.stat == DEAD)
		return
	if(imp_in.health <= HEALTH_THRESHOLD_CRIT)
		INVOKE_ASYNC(src, PROC_REF(activate), "deniability")

/obj/item/implanter/aq_deniability
	name = "implanter (taktyczne wyparcie się)"
	imp_type = /obj/item/implant/explosive/aq_deniability

// ---------------------------------------------------------------------------
// Fałszywa ochrona umysłu (SS220 /obj/item/implant/fake_mindshield)

/obj/item/implant/aq_fake_mindshield
	name = "implant fałszywej ochrony umysłu"
	desc = "Udaje implant ochrony umysłu na HUD-zie ochrony. Nosiciel sam włącza i wyłącza fałszywą ikonę."
	icon_state = "freedom"
	/// Czy fałszywa ikona jest włączona
	var/shown = FALSE

/obj/item/implant/aq_fake_mindshield/get_data()
	return "<b>Specyfikacja implantu:</b><BR><b>Ważne uwagi:</b> <font color='red'>Nielegalny</font><BR><b>Działanie:</b> przycisk włącza i wyłącza fałszywą ikonę ochrony umysłu na HUD-zie ochrony. Nie chroni przed praniem mózgu."

/obj/item/implant/aq_fake_mindshield/activate()
	. = ..()
	set_shown(!shown)
	to_chat(imp_in, span_notice((shown ? "Implant nadaje sygnał ochrony umysłu." : "Implant przestaje nadawać sygnał ochrony umysłu.")))

/obj/item/implant/aq_fake_mindshield/proc/set_shown(new_state)
	if(!imp_in)
		return
	shown = new_state
	if(shown)
		ADD_TRAIT(imp_in, TRAIT_FAKE_MINDSHIELD, REF(src))
	else
		REMOVE_TRAIT(imp_in, TRAIT_FAKE_MINDSHIELD, REF(src))
	imp_in.sec_hud_set_implants()

/obj/item/implant/aq_fake_mindshield/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(. && imp_in == target)
		set_shown(TRUE)

/obj/item/implant/aq_fake_mindshield/removed(mob/living/source, silent = FALSE, special = 0)
	REMOVE_TRAIT(source, TRAIT_FAKE_MINDSHIELD, REF(src))
	shown = FALSE
	. = ..()
	source.sec_hud_set_implants()

/obj/item/implanter/aq_fake_mindshield
	name = "implanter (fałszywa ochrona umysłu)"
	imp_type = /obj/item/implant/aq_fake_mindshield

// ---------------------------------------------------------------------------
// Ostrza skrzydeł ćmy (Shiptest /obj/item/implant/razorwing)

/obj/item/implant/aq_razorwing
	name = "implant ostrych skrzydeł"
	desc = "Wyostrza skrzydła ćmoczłowieka: po aktywacji zadaje obrażenia wszystkim obok. Działa tylko u ćmoludzi."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "mothwings"
	/// Obrażenia dla każdego obok
	var/wing_damage = 20
	COOLDOWN_DECLARE(wing_cooldown)

/obj/item/implant/aq_razorwing/get_data()
	return "<b>Specyfikacja implantu:</b><BR><b>Ważne uwagi:</b> <font color='red'>Nielegalny</font><BR><b>Działanie:</b> ćmoczłowiek wiruje i tnie skrzydłami wszystkich obok siebie ([wing_damage] obrażeń, co 10 s)."

/obj/item/implant/aq_razorwing/can_be_implanted_in(mob/living/target)
	return ismoth(target)

/obj/item/implant/aq_razorwing/activate()
	. = ..()
	if(!imp_in || imp_in.stat)
		return
	if(!ismoth(imp_in))
		to_chat(imp_in, span_warning("Nie masz skrzydeł, które implant mógłby wyostrzyć."))
		return
	if(!COOLDOWN_FINISHED(src, wing_cooldown))
		to_chat(imp_in, span_warning("Skrzydła jeszcze nie odzyskały ostrości."))
		return
	COOLDOWN_START(src, wing_cooldown, 10 SECONDS)
	imp_in.visible_message(span_danger("[imp_in] wiruje, tnąc ostrymi skrzydłami wszystko wokół!"))
	imp_in.emote("spin")
	playsound(imp_in, 'sound/weapons/bladeslice.ogg', 50, TRUE)
	for(var/mob/living/victim in view(1, imp_in))
		if(victim == imp_in)
			continue
		victim.apply_damage(wing_damage, BRUTE)
		log_combat(imp_in, victim, "ciął skrzydłami (implant ostrych skrzydeł)")

/obj/item/implanter/aq_razorwing
	name = "implanter (ostre skrzydła)"
	imp_type = /obj/item/implant/aq_razorwing

// ---------------------------------------------------------------------------
// Sponsorski (MonkeStation /obj/item/implant/sponsorship): mimowolne reklamy, 5 kredytów za każdą

/obj/item/implant/aq_sponsorship
	name = "implant sponsorski"
	desc = "Nosiciel co jakiś czas mimowolnie wygłasza reklamy sponsorów. Za każdą dostaje parę kredytów."
	icon_state = "reagents"
	activated = FALSE
	allow_multiple = TRUE
	/// Kiedy następna reklama
	var/next_ad = 0
	/// Ile płaci sponsor za reklamę
	var/ad_payment = 5
	/// Reklamy
	var/static/list/ads = list(
		"Pragnienie w próżni? Kosmiczna Cola: smak, który przetrwa dekompresję!",
		"Donk Co. przypomina: kieszonka Donk to obiad w trzy minuty!",
		"Nanotrasen dba o ciebie. Pamiętaj o rocznej ankiecie zadowolenia!",
		"Głodny po zmianie? Automat z przekąskami jest bliżej, niż myślisz!",
		"Ubezpieczenie Nanotrasen: bo kadłub też czasem pęka!",
		"Masz dość ciszy w kabinie? Szafa grająca czeka w barze!",
		"Robust Softdrinks: orzeźwienie dla robustnych!",
		"Kup teraz, płać po rundzie: kredyt Nanotrasen bez ukrytych kosztów!",
		"Wszczep coś nowego! Robotyka zaprasza na przegląd augmentów!",
		"Zmęczony? Kawa z baru postawi na nogi nawet trupa. Prawie.",
	)

/obj/item/implant/aq_sponsorship/get_data()
	return "<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> implant sponsorski<BR><b>Działanie:</b> co 4-6 minut nosiciel wygłasza reklamę sponsora, a na jego konto wpływa [ad_payment] kr."

/obj/item/implant/aq_sponsorship/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(. && imp_in == target)
		next_ad = world.time + rand(4 MINUTES, 6 MINUTES)
		START_PROCESSING(SSobj, src)

/obj/item/implant/aq_sponsorship/removed(mob/living/source, silent = FALSE, special = 0)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/implant/aq_sponsorship/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/implant/aq_sponsorship/process(delta_time)
	if(!imp_in || world.time < next_ad)
		return
	next_ad = world.time + rand(4 MINUTES, 6 MINUTES)
	if(imp_in.stat != CONSCIOUS)
		return
	say_ad()

/// Wygłasza reklamę i płaci za nią
/obj/item/implant/aq_sponsorship/proc/say_ad()
	imp_in.say(pick(ads), forced = "implant sponsorski")
	if(ishuman(imp_in))
		var/mob/living/carbon/human/human_host = imp_in
		var/datum/bank_account/account = human_host.get_bank_account()
		if(istype(account))
			account.adjust_money(ad_payment)

/obj/item/implanter/aq_sponsorship
	name = "implanter (sponsorski)"
	imp_type = /obj/item/implant/aq_sponsorship

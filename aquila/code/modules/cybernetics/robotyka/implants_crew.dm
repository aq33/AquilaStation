// AQUILA - implanty dla załogi (medycyna, R&D, ochrona). Wdrożenie robotyki, część IMPLANTY.
// Źródła: Goonstation (antirot, robotalk, access), BurgerStation (iff), YogStation (empshield),
// /tg/station (tacmap, teleport_blocker). Bezpiecznik przedawkowania i zakłócacz augmentów: robotics/robotics_implants.dm.

// ---------------------------------------------------------------------------
// Rotbusttec: formaldehyd po śmierci (Goonstation /obj/item/implant/antirot)

/obj/item/implant/aq_antirot
	name = "implant Rotbusttec"
	desc = "Po śmierci nosiciela wstrzykuje formaldehyd, żeby ciało nie gniło do czasu ożywienia."
	icon_state = "reagents"
	activated = FALSE
	/// Ile formaldehydu wstrzykuje po śmierci
	var/formaldehyde_amount = 30

/obj/item/implant/aq_antirot/get_data()
	return "<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> Rotbusttec, konserwant pośmiertny<BR><b>Działanie:</b> po ustaniu funkcji życiowych wstrzykuje [formaldehyde_amount] j. formaldehydu, który powstrzymuje rozkład ciała do czasu ożywienia.<BR><b>Żywotność:</b> jednorazowy."

/obj/item/implant/aq_antirot/on_mob_death(mob/living/L, gibbed)
	if(gibbed || !L.reagents)
		return
	L.reagents.add_reagent(/datum/reagent/toxin/formaldehyde, formaldehyde_amount)
	qdel(src)

/obj/item/implanter/aq_antirot
	name = "implanter (Rotbusttec)"
	imp_type = /obj/item/implant/aq_antirot

/obj/item/implantcase/aq_antirot
	name = "etui na implant – „Rotbusttec”"
	desc = "Szklane etui z implantem Rotbusttec. Po śmierci nosiciela konserwuje ciało formaldehydem."
	imp_type = /obj/item/implant/aq_antirot

// ---------------------------------------------------------------------------
// Tłumacz maszynowy: język binarny i kanał silikonów (Goonstation /obj/item/implant/robotalk)

/obj/item/implant/aq_robotalk
	name = "implant tłumacza maszynowego"
	desc = "Pozwala rozumieć i używać kanału silikonów oraz języka binarnego."
	icon_state = "lighting_bolt"
	activated = FALSE

/obj/item/implant/aq_robotalk/get_data()
	return "<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> tłumacz maszynowy<BR><b>Działanie:</b> nosiciel rozumie i mówi kodem maszynowym, słyszy kanał binarny silikonów i może na nim mówić (prefiks :b), bez słuchawek z tłumaczem."

/obj/item/implant/aq_robotalk/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(target, TRAIT_AQ_BINARY_SPEAKER, REF(src))
	target.grant_language(/datum/language/machine, TRUE, TRUE, REF(src))

/obj/item/implant/aq_robotalk/removed(mob/living/source, silent = FALSE, special = 0)
	REMOVE_TRAIT(source, TRAIT_AQ_BINARY_SPEAKER, REF(src))
	source.remove_language(/datum/language/machine, TRUE, TRUE, REF(src))
	return ..()

/obj/item/implanter/aq_robotalk
	name = "implanter (tłumacz maszynowy)"
	imp_type = /obj/item/implant/aq_robotalk

/obj/item/implantcase/aq_robotalk
	name = "etui na implant – „Tłumacz maszynowy”"
	desc = "Szklane etui z implantem tłumacza maszynowego."
	imp_type = /obj/item/implant/aq_robotalk

// ---------------------------------------------------------------------------
// Tarcza EMP (YogStation /obj/item/implant/empshield)

/obj/item/implant/aq_empshield
	name = "implant tarczy EMP"
	desc = "Chroni nosiciela przed impulsami elektromagnetycznymi, ale przy częstych trafieniach na chwilę się wyłącza."
	icon_state = "emp"
	activated = FALSE
	/// Punkty przeciążenia: ciężki impuls 2, lekki 1
	var/overload = 0
	/// Od tylu punktów tarcza się wyłącza
	var/overload_limit = 10
	/// Czy tarcza jest chwilowo wyłączona
	var/disabled = FALSE
	/// Bez nowego impulsu przez tyle czasu przeciążenie spada do zera
	var/overload_decay = 10 SECONDS
	/// Na tyle tarcza się wyłącza po przeciążeniu
	var/disable_time = 10 SECONDS
	/// Ostatni pochłonięty impuls
	var/last_emp = 0

/obj/item/implant/aq_empshield/get_data()
	return "<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> tarcza EMP<BR><b>Działanie:</b> pochłania impulsy elektromagnetyczne, zanim dotrą do ciała, implantów i protez nosiciela.<BR><b>Uwaga:</b> seria silnych impulsów przeciąża tarczę na [disable_time / 10] s."

/// Czy tarcza pochłonęła impuls
/obj/item/implant/aq_empshield/proc/absorb_emp(severity)
	if(disabled)
		return FALSE
	if(world.time > last_emp + overload_decay)
		overload = 0
	last_emp = world.time
	overload += (severity == EMP_HEAVY) ? 2 : 1
	if(overload >= overload_limit)
		disabled = TRUE
		overload = 0
		to_chat(imp_in, span_userdanger("Tarcza EMP przeciąża się i gaśnie!"))
		addtimer(CALLBACK(src, PROC_REF(restore)), disable_time)
	return TRUE

/obj/item/implant/aq_empshield/proc/restore()
	disabled = FALSE
	if(imp_in)
		to_chat(imp_in, span_notice("Tarcza EMP znów działa."))

/mob/living/carbon/human/emp_act(severity)
	for(var/obj/item/implant/aq_empshield/shield in implants)
		if(shield.absorb_emp(severity))
			return EMP_PROTECT_SELF | EMP_PROTECT_CONTENTS | EMP_PROTECT_WIRES
	return ..()

/obj/item/implanter/aq_empshield
	name = "implanter (tarcza EMP)"
	imp_type = /obj/item/implant/aq_empshield

/obj/item/implantcase/aq_empshield
	name = "etui na implant – „Tarcza EMP”"
	desc = "Szklane etui z implantem tarczy EMP."
	imp_type = /obj/item/implant/aq_empshield

// ---------------------------------------------------------------------------
// Mapa taktyczna (/tg/station /obj/item/implant/tacmap): holomapa okrętu z pozycjami nosicieli tej samej frakcji

/obj/item/implant/aq_tacmap
	name = "implant mapy taktycznej"
	desc = "Wyświetla hologram okrętu z pozycjami sojuszników, którzy też mają ten implant."
	icon = 'aquila/icons/obj/cybernetics/robotyka_implanty.dmi'
	icon_state = "minimap"
	activated = FALSE // przycisk daje komponent holomapy
	/// Nosiciele implantów tej samej frakcji widzą się nawzajem
	var/tacmap_faction = "nanotrasen"
	/// Nazwa sojuszników w legendzie mapy
	var/ally_legend = "Sojusznicy"

/obj/item/implant/aq_tacmap/get_data()
	return "<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> mapa taktyczna<BR><b>Działanie:</b> przycisk wyświetla hologram okrętu z pozycjami innych nosicieli tego implantu."

/obj/item/implant/aq_tacmap/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return
	var/datum/component/holomap/aq_tacmap/holo = AddComponent(/datum/component/holomap/aq_tacmap)
	holo.holobutton.Grant(target)

/obj/item/implant/aq_tacmap/removed(mob/living/source, silent = FALSE, special = 0)
	var/datum/component/holomap/aq_tacmap/holo = GetComponent(/datum/component/holomap/aq_tacmap)
	if(holo)
		if(holo.holomap_visible)
			holo.deactivate_holomap(source)
		holo.holobutton.Remove(source)
		qdel(holo)
	return ..()

/datum/component/holomap/aq_tacmap

/datum/component/holomap/aq_tacmap/Initialize()
	. = ..()
	holobutton.name = "Mapa taktyczna"
	holobutton.desc = "Pokazuje hologram okrętu z pozycjami sojuszników."

/datum/component/holomap/aq_tacmap/handle_overlays()
	var/list/extra_overlays = ..()
	if(bogus)
		return extra_overlays
	var/obj/item/implant/aq_tacmap/own = parent
	if(!istype(own))
		return extra_overlays
	var/list/markers = list()
	for(var/mob/living/ally as anything in GLOB.mob_living_list)
		if(ally == own.imp_in || ally.z != current_z_level || ally.stat == DEAD)
			continue
		for(var/obj/item/implant/aq_tacmap/other in ally.implants)
			if(other.tacmap_faction != own.tacmap_faction)
				continue
			var/image/marker = image('nsv13/icons/holomap/8x8.dmi', "you")
			marker.color = "#3A9BFF"
			marker.pixel_x = ally.x + HOLOMAP_CENTER_X - 3
			marker.pixel_y = ally.y + HOLOMAP_CENTER_Y - 3
			markers += marker
			break
	if(length(markers))
		var/image/legend_icon = image('nsv13/icons/holomap/8x8.dmi', "you")
		legend_icon.color = "#3A9BFF"
		extra_overlays[own.ally_legend] = list("icon" = legend_icon, "markers" = markers)
	return extra_overlays

/obj/item/implant/aq_tacmap/syndicate
	name = "implant mapy taktycznej Syndykatu"
	tacmap_faction = "syndicate"
	ally_legend = "Agenci"

/obj/item/implanter/aq_tacmap
	name = "implanter (mapa taktyczna)"
	imp_type = /obj/item/implant/aq_tacmap

/obj/item/implanter/aq_tacmap/syndicate
	imp_type = /obj/item/implant/aq_tacmap/syndicate

/obj/item/implantcase/aq_tacmap
	name = "etui na implant – „Mapa taktyczna”"
	desc = "Szklane etui z implantem mapy taktycznej ochrony."
	imp_type = /obj/item/implant/aq_tacmap

// ---------------------------------------------------------------------------
// Elektroniczny dostęp (Goonstation /obj/item/implant/access): karta ID w ciele, z ograniczoną liczbą użyć

/obj/item/implant/aq_access
	name = "implant elektronicznego dostępu"
	desc = "Działa jak karta identyfikacyjna: otwiera drzwi według zapisanego dostępu. Ma ograniczoną liczbę użyć."
	icon_state = "storage"
	activated = FALSE
	uses = 8
	/// Zapisane dostępy (kopiowane z karty przyłożonej do implantera albo etui)
	var/list/access = list()

/obj/item/implant/aq_access/get_data()
	return "<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> elektroniczny dostęp<BR><b>Działanie:</b> zamek, który wymaga dostępu, sprawdza implant, gdy nosiciel nie ma przy sobie karty z tym dostępem. Każde takie otwarcie zużywa jeden ładunek.<BR><b>Pozostałe ładunki:</b> [uses]<BR><b>Zapisanych dostępów:</b> [length(access)]"

/obj/item/implant/aq_access/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(. && imp_in == target)
		RegisterSignal(target, COMSIG_MOB_ALLOWED, PROC_REF(check_access_for), override = TRUE)

/obj/item/implant/aq_access/removed(mob/living/source, silent = FALSE, special = 0)
	UnregisterSignal(source, COMSIG_MOB_ALLOWED)
	return ..()

/obj/item/implant/aq_access/proc/check_access_for(mob/living/source, obj/locked)
	SIGNAL_HANDLER
	if(!uses || !length(access) || !istype(locked))
		return FALSE
	// karta w ręce albo na szyi wystarczy, nie zużywamy ładunku
	if(ishuman(source))
		var/mob/living/carbon/human/human_source = source
		if(locked.check_access(human_source.get_active_held_item()) || locked.check_access(human_source.wear_id))
			return FALSE
	if(!locked.check_access_list(access))
		return FALSE
	uses--
	if(!uses)
		to_chat(source, span_warning("Implant elektronicznego dostępu wyczerpał ładunki."))
	return TRUE

/// Kopiuje dostępy z karty do implantu
/obj/item/implant/aq_access/proc/program_from(obj/item/card/id/card, mob/user)
	access = card.access.Copy()
	to_chat(user, span_notice("Zapisujesz w implancie dostępy z [card] ([length(access)])."))

/obj/item/implanter/aq_access
	name = "implanter (elektroniczny dostęp)"
	desc = "Sterylny automatyczny wstrzykiwacz implantów. Przyłóż kartę identyfikacyjną, żeby zapisać jej dostępy w implancie."
	imp_type = /obj/item/implant/aq_access

/obj/item/implanter/aq_access/attackby(obj/item/W, mob/user, params)
	var/obj/item/implant/aq_access/access_implant = imp
	if(istype(W, /obj/item/card/id) && istype(access_implant))
		access_implant.program_from(W, user)
		return
	return ..()

/obj/item/implantcase/aq_access
	name = "etui na implant – „Elektroniczny dostęp”"
	desc = "Szklane etui z implantem elektronicznego dostępu. Przyłóż kartę identyfikacyjną, żeby zapisać jej dostępy."
	imp_type = /obj/item/implant/aq_access

/obj/item/implantcase/aq_access/attackby(obj/item/W, mob/user, params)
	var/obj/item/implant/aq_access/access_implant = imp
	if(istype(W, /obj/item/card/id) && istype(access_implant))
		access_implant.program_from(W, user)
		return
	return ..()

// ---------------------------------------------------------------------------
// Swój-obcy (BurgerStation iff): pociski strzelców z takim samym implantem przelatują przez nosiciela.
// U Burgera broń jest rejestrowana na frakcję; u nas frakcję ma strzelec (implant), bo broni nie rejestrujemy.

/obj/item/implant/aq_iff
	name = "implant swój-obcy"
	desc = "Pociski wystrzelone przez nosicieli tego samego implantu omijają nosiciela."
	icon_state = "freedom"
	activated = FALSE
	/// Frakcja: strzały nosicieli z tą samą frakcją nie trafiają
	var/iff_faction = "nanotrasen"

/obj/item/implant/aq_iff/get_data()
	return "<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> swój-obcy<BR><b>Działanie:</b> pociski wystrzelone przez nosiciela innego implantu swój-obcy tej samej frakcji przelatują przez nosiciela, więc ogień sojuszniczy go nie rani. Nie chroni przed wybuchami ani walką wręcz."

/obj/item/implanter/aq_iff
	name = "implanter (swój-obcy)"
	imp_type = /obj/item/implant/aq_iff

/obj/item/implantcase/aq_iff
	name = "etui na implant – „Swój-obcy”"
	desc = "Szklane etui z implantem swój-obcy ochrony."
	imp_type = /obj/item/implant/aq_iff

// ---------------------------------------------------------------------------
// Uziemienie bluespace (/tg/station /obj/item/implant/teleport_blocker)

/obj/item/implant/aq_teleport_blocker
	name = "implant uziemienia bluespace"
	desc = "Implant więzienny, który uziemia sygnaturę bluespace nosiciela: próba teleportacji kończy się odrzuceniem i paraliżem."
	icon_state = "storage"
	activated = FALSE

/obj/item/implant/aq_teleport_blocker/get_data()
	return "<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> uziemienie bluespace<BR><b>Działanie:</b> blokuje teleportację nosiciela. Każda próba paraliżuje go na 5 s."

/obj/item/implant/aq_teleport_blocker/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!. || imp_in != target)
		return
	ADD_TRAIT(target, TRAIT_NO_TELEPORT, REF(src))
	RegisterSignal(target, COMSIG_AQ_TELEPORT_DENIED, PROC_REF(on_teleport_denied), override = TRUE)

/obj/item/implant/aq_teleport_blocker/removed(mob/living/source, silent = FALSE, special = 0)
	REMOVE_TRAIT(source, TRAIT_NO_TELEPORT, REF(src))
	UnregisterSignal(source, COMSIG_AQ_TELEPORT_DENIED)
	return ..()

/obj/item/implant/aq_teleport_blocker/proc/on_teleport_denied(mob/living/source)
	SIGNAL_HANDLER
	to_chat(source, span_userdanger("Implant uziemienia odrzuca teleport, a przez ciało przechodzi bolesny wstrząs!"))
	source.Paralyze(5 SECONDS)
	do_sparks(5, FALSE, source)

/obj/item/implanter/aq_teleport_blocker
	name = "implanter (uziemienie bluespace)"
	imp_type = /obj/item/implant/aq_teleport_blocker

/obj/item/implantcase/aq_teleport_blocker
	name = "etui na implant – „Uziemienie bluespace”"
	desc = "Szklane etui z implantem uziemienia bluespace dla więźniów."
	imp_type = /obj/item/implant/aq_teleport_blocker

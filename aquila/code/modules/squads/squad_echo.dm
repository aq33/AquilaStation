// AQUILA - drużyna Echo: piloci i ochotnicy na myśliwcach (rework systemów okrętu, etap E1).
// Echo powstaje przy starcie rundy. Piloci trafiają do niej sami, a ochotników dopisują dowódcy w konsoli drużyn,
// dopóki członków jest mniej niż myśliwców bojowych na statku. Członek Echo dostaje przez drużynę dostęp do
// myśliwców i hangaru; po wypisaniu dostęp znika (drużyna daje dostęp przez allowed(), nie przez kartę).

#define ECHO_SQUAD_NAME "Echo"
#define ECHO_SQUAD_COLOUR "#3cb371"

/datum/squad
	/// AQUILA - drużyna Echo (piloci i ochotnicy na myśliwcach)
	var/aq_is_echo = FALSE

/datum/squad_manager
	var/datum/squad/aq_echo

/// Echo powstaje przy pierwszym użyciu (przydział przy starcie rundy, konsola drużyn), a nie w New() managera:
/// manager jest zmienną globalną tworzoną przed konfiguracją, a retask() sięga wtedy do jeszcze pustych słowników
/datum/squad_manager/proc/aq_get_echo()
	if(aq_echo && !QDELETED(aq_echo) && (aq_echo in squads))
		return aq_echo
	aq_echo = aq_create_squad(ECHO_SQUAD_NAME, ECHO_SQUAD_COLOUR)
	if(!aq_echo)
		return null
	aq_echo.aq_is_echo = TRUE
	aq_echo.desc = "Piloci i ochotnicy na myśliwcach okrętu."
	aq_echo.retask(COMBAT_AIR_PATROL)
	aq_echo.allowed_jobs = list(/datum/job/pilot)
	return aq_echo

/// Ilu członków może mieć Echo: tyle, ile myśliwców bojowych ma główny statek (co najmniej 1)
/datum/squad/proc/aq_echo_limit()
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	var/count = 0
	if(ship)
		for(var/obj/structure/overmap/small_craft/combat/fighter in GLOB.overmap_objects)
			if(QDELETED(fighter) || fighter.obj_integrity <= 0)
				continue
			// Tylko myśliwce okrętu: w jego hangarze albo w locie z jego frakcji
			if(fighter.get_overmap() == ship || (fighter.z == ship.z && fighter.faction == ship.faction))
				count++
	return max(count, 1)

/// Piloci idą do Echo, inni zawodowo nie trafiają tam sami (tylko z konsoli drużyn)
/datum/squad_manager/aq_pick_squad(datum/job/job, preferred_name)
	var/datum/squad/echo = aq_get_echo()
	if(!echo)
		return ..()
	if(istype(job, /datum/job/pilot))
		return echo
	var/was_hidden = echo.hidden
	echo.hidden = TRUE
	. = ..()
	echo.hidden = was_hidden

/datum/squad/retask(task)
	. = ..()
	// Echo zawsze lata: zmiana zadania w konsoli nie może zabrać dostępu do myśliwców
	if(aq_is_echo)
		// access to wspólna lista z role_access_map: kopia, żeby nie dopisać hangaru innym drużynom
		access = (access ? access.Copy() : list()) | list(ACCESS_COMBAT_PILOT, ACCESS_HANGAR)
		access_enabled = TRUE

/// Smycz drużyny Echo też pilnuje limitu (konsola drużyn sprawdza go w squad_console.dm)
/obj/item/clothing/neck/squad/attack_self(mob/living/carbon/human/user)
	if(squad?.aq_is_echo && ishuman(user) && user.squad != squad && length(squad.members) >= squad.aq_echo_limit())
		to_chat(user, "<span class='warning'>Echo ma już tylu członków, ile myśliwców ma okręt.</span>")
		return FALSE
	return ..()

#undef ECHO_SQUAD_NAME
#undef ECHO_SQUAD_COLOUR

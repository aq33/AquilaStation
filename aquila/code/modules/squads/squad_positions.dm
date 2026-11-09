// Funkcje w drużynie (żołnierz, medyk, inżynier; dowódca osobno), auto-przydział według zawodu,
// ikony w HUD-zie drużyny i przejęcie dowodzenia po śmierci dowódcy.

/mob/living/carbon/human
	/// Funkcja w drużynie (SQUAD_POSITION_*); dowódca to squad.leader
	var/squad_position = SQUAD_POSITION_SOLDIER

/// Polska nazwa funkcji
/proc/squad_position_pl(position)
	switch(position)
		if(SQUAD_POSITION_LEADER)
			return "Dowódca"
		if(SQUAD_POSITION_MEDIC)
			return "Medyk"
		if(SQUAD_POSITION_ENGINEER)
			return "Inżynier"
	return "Żołnierz"

/// Funkcja do zestawu i ikon: dowódca ma pierwszeństwo przed zapisaną funkcją
/mob/living/carbon/human/proc/get_squad_position()
	if(squad && squad.leader == src)
		return SQUAD_POSITION_LEADER
	return squad_position || SQUAD_POSITION_SOLDIER

// Wszyscy mogą być w drużynach. AI i cyborgi i tak nie są ludźmi.
/datum/squad
	disallowed_jobs = list(/datum/job/ai, /datum/job/cyborg)
	max_members = SQUAD_AUTO_MAX_MEMBERS

// Zawód -> rola drużyny, do której trafia, i funkcja w niej
/datum/job
	/// Czy zawód trafia do drużyny automatycznie
	var/aq_squad_auto = TRUE
	/// Rola drużyny (DC_SQUAD itd.), do której zawód trafia; null = preferowana albo najmniejsza drużyna
	var/aq_squad_role = null
	/// Funkcja w drużynie
	var/aq_squad_position = SQUAD_POSITION_SOLDIER

// Dowództwo kieruje działami, więc nie trafia do drużyn samo. XO może je dopisać ręcznie.
/datum/job/captain
	aq_squad_auto = FALSE
/datum/job/head_of_personnel
	aq_squad_auto = FALSE
/datum/job/head_of_security
	aq_squad_auto = FALSE
/datum/job/chief_engineer
	aq_squad_auto = FALSE
/datum/job/chief_medical_officer
	aq_squad_auto = FALSE
/datum/job/research_director
	aq_squad_auto = FALSE
/datum/job/quartermaster
	aq_squad_auto = FALSE
/datum/job/master_at_arms
	aq_squad_auto = FALSE

/datum/job/medical_doctor
	aq_squad_role = MEDICAL_SQUAD
	aq_squad_position = SQUAD_POSITION_MEDIC
/datum/job/paramedic
	aq_squad_role = MEDICAL_SQUAD
	aq_squad_position = SQUAD_POSITION_MEDIC
/datum/job/brig_physician
	aq_squad_role = MEDICAL_SQUAD
	aq_squad_position = SQUAD_POSITION_MEDIC
/datum/job/chemist
	aq_squad_role = MEDICAL_SQUAD
	aq_squad_position = SQUAD_POSITION_MEDIC
/datum/job/virologist
	aq_squad_role = MEDICAL_SQUAD
	aq_squad_position = SQUAD_POSITION_MEDIC
/datum/job/geneticist
	aq_squad_role = MEDICAL_SQUAD
	aq_squad_position = SQUAD_POSITION_MEDIC

/datum/job/station_engineer
	aq_squad_role = DC_SQUAD
	aq_squad_position = SQUAD_POSITION_ENGINEER
/datum/job/atmospheric_technician
	aq_squad_role = DC_SQUAD
	aq_squad_position = SQUAD_POSITION_ENGINEER

/datum/job/munitions_tech
	aq_squad_role = MUNITIONS_SUPPORT
/datum/job/deck_tech
	aq_squad_role = MUNITIONS_SUPPORT
/datum/job/pilot
	aq_squad_role = COMBAT_AIR_PATROL
/datum/job/air_traffic_controller
	aq_squad_role = COMBAT_AIR_PATROL
/datum/job/security_officer
	aq_squad_role = SECURITY_SQUAD
/datum/job/warden
	aq_squad_role = SECURITY_SQUAD
/datum/job/detective
	aq_squad_role = SECURITY_SQUAD
/datum/job/deputy
	aq_squad_role = SECURITY_SQUAD
/datum/job/bridge
	aq_squad_role = CIC_OPS

// Pełne nadpisanie (LEGACY_OVERRIDES.md): drużyna według zawodu, potem preferowana, potem najmniejsza
/datum/job/register_squad(mob/living/H)
	if(!ishuman(H))
		return
	var/mob/living/carbon/human/human = H
	if(human.squad || !aq_squad_auto)
		return
	var/preferred = human.client?.prefs?.active_character?.preferred_squad
	var/datum/squad/squad = GLOB.squad_manager.aq_pick_squad(src, preferred)
	if(!squad)
		return
	human.squad_position = aq_squad_position
	squad.add_member(human, give_items = TRUE)

/// Drużyna dla nowego członka: rola zawodu, potem preferowana drużyna gracza, potem najmniej liczna
/datum/squad_manager/proc/aq_pick_squad(datum/job/job, preferred_name)
	var/list/candidates = list()
	for(var/datum/squad/squad as anything in squads)
		if(squad.hidden)
			continue
		if(job && LAZYFIND(squad.disallowed_jobs, job.type) && !LAZYFIND(squad.allowed_jobs, job.type))
			continue
		candidates += squad
	if(!length(candidates))
		return null
	if(job?.aq_squad_role)
		var/list/matching = list()
		for(var/datum/squad/squad as anything in candidates)
			if(squad.role == job.aq_squad_role)
				matching += squad
		if(length(matching))
			return aq_smallest_squad(matching)
	var/datum/squad/preferred = preferred_name ? get_squad(preferred_name) : null
	if(preferred && (preferred in candidates) && length(preferred.members) < preferred.max_members)
		return preferred
	return aq_smallest_squad(candidates)

/datum/squad_manager/proc/aq_smallest_squad(list/squad_list)
	var/datum/squad/smallest = null
	for(var/datum/squad/squad as anything in squad_list)
		if(!smallest || length(squad.members) < length(smallest.members))
			smallest = squad
	return smallest

/datum/squad/add_member(mob/living/carbon/human/H, give_items = FALSE)
	. = ..()
	if(!ishuman(H) || !(H in members))
		return
	RegisterSignal(H, COMSIG_MOB_DEATH, PROC_REF(aq_on_member_death), override = TRUE)
	RegisterSignal(H, COMSIG_MOB_LOGIN, PROC_REF(aq_on_member_login), override = TRUE)
	aq_refresh_all()
	aq_add_marker_images(H)

/datum/squad/remove_member(mob/living/carbon/human/H)
	. = ..()
	if(!istype(H))
		return
	UnregisterSignal(H, list(COMSIG_MOB_DEATH, COMSIG_MOB_LOGIN))
	aq_remove_marker_images(H)
	H.aq_update_squad_hud()
	aq_refresh_all()

/datum/squad/set_leader(mob/living/carbon/human/H)
	. = ..()
	aq_refresh_all()

/datum/squad/unset_leader(mob/living/carbon/human/H)
	var/mob/living/carbon/human/old_leader = leader
	. = ..()
	if(old_leader)
		old_leader.aq_update_squad_hud()
	aq_refresh_all()

/// Odświeża ikony HUD-u wszystkich członków (np. po zmianie dowódcy)
/datum/squad/proc/aq_refresh_all()
	for(var/mob/living/carbon/human/member in members)
		member.aq_update_squad_hud()

/// Zmiana funkcji w drużynie przez XO
/datum/squad/proc/aq_set_position(mob/living/carbon/human/H, position)
	if(!(H in members) || !(position in SQUAD_POSITIONS))
		return FALSE
	if(H.squad_position == position)
		return FALSE
	H.squad_position = position
	H.aq_update_squad_hud()
	to_chat(H, "<span class='sciradio'>Twoja funkcja w drużynie [name]: [squad_position_pl(position)].</span>")
	return TRUE

// Pełne nadpisanie (LEGACY_OVERRIDES.md): najwyższy stopniem spośród żywych (najpierw z graczem);
// gdy żywych nie ma, najwyższy stopniem w ogóle (jak w NSV13)
/datum/squad/assign_leader()
	if(!length(members))
		return
	var/mob/living/carbon/human/highest = aq_best_leader_candidate()
	if(!highest)
		highest = members[1]
		for(var/mob/living/carbon/human/H as anything in members)
			if(check_rank_pecking_order(H.compose_rank(), highest.compose_rank()))
				highest = H
	if(highest != leader)
		unset_leader()
		set_leader(highest)

/// Najlepszy żywy kandydat na dowódcę: gracze przed postaciami bez gracza, potem stopień
/datum/squad/proc/aq_best_leader_candidate(mob/living/carbon/human/exclude)
	var/mob/living/carbon/human/best = null
	for(var/mob/living/carbon/human/H as anything in members)
		if(H == exclude || QDELETED(H) || H.stat == DEAD)
			continue
		if(!best)
			best = H
			continue
		if(!!H.client != !!best.client)
			if(H.client)
				best = H
			continue
		if(check_rank_pecking_order(H.compose_rank(), best.compose_rank()))
			best = H
	return best

/datum/squad/proc/aq_on_member_death(mob/living/carbon/human/source, gibbed)
	SIGNAL_HANDLER
	if(source != leader)
		return
	addtimer(CALLBACK(src, PROC_REF(aq_leader_succession), source), SQUAD_LEADER_SUCCESSION_DELAY, TIMER_UNIQUE | TIMER_OVERRIDE)

/// Po chwili od śmierci dowódcy (na wypadek natychmiastowej reanimacji) dowodzenie przejmuje następny
/datum/squad/proc/aq_leader_succession(mob/living/carbon/human/dead_leader)
	if(leader != dead_leader || (dead_leader && !QDELETED(dead_leader) && dead_leader.stat != DEAD))
		return FALSE
	var/mob/living/carbon/human/successor = aq_best_leader_candidate(dead_leader)
	if(!successor)
		return FALSE
	unset_leader()
	set_leader(successor)
	aq_squad_screen_alert("Dowódca nie żyje. Dowodzenie przejmuje [successor.real_name].", "Automatyczny komunikat CIC")
	return TRUE

/datum/squad/proc/aq_on_member_login(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	aq_add_marker_images(source)

// Ikona funkcji w kolorze drużyny nad postacią (HUD drużyny widzą wszyscy członkowie drużyn)
/mob/living/carbon/human/proc/aq_update_squad_hud()
	var/image/holder = hud_list?[SQUAD_HUD]
	if(!holder)
		return
	holder.cut_overlays()
	if(!squad)
		holder.icon = null
		holder.icon_state = null
		return
	holder.icon = 'aquila/icons/squads/squad_hud.dmi'
	holder.icon_state = "frame"
	holder.color = squad.colour
	holder.appearance_flags = RESET_COLOR | KEEP_APART
	var/image/glyph = image('aquila/icons/squads/squad_hud.dmi', "pos_[get_squad_position()]")
	glyph.appearance_flags = RESET_COLOR
	holder.add_overlay(glyph)

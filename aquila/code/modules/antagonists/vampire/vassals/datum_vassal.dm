/datum/antagonist/vassal
	name = "\improper Wasal"
	roundend_category = "Wasale"
	antagpanel_category = "Vampire"
	antag_hud_name = "vassal"
	banning_key = ROLE_VAMPIRE
	show_in_roundend = FALSE

	/// The Master Vampire's antag datum.
	var/datum/antagonist/vampire/master
	/// The Vampire's team
	var/datum/team/vampire/vampire_team
	/// List of Powers, like Vampires.
	var/list/datum/action/powers = list()
	/// A link to our team monitor, used to track our master.
	var/datum/component/team_monitor/monitor

/datum/antagonist/vassal/antag_panel_data()
	return "Pan : [master.owner.name]"

/datum/antagonist/vassal/get_team()
	return vampire_team

/datum/antagonist/vassal/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current

	RegisterSignal(current_mob, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))

	// Tracking
	setup_monitor(current_mob)
	current_mob.grant_language(/datum/language/vampiric, source = REF(src))

	// Team
	vampire_team = master.vampire_team
	vampire_team.add_member(current_mob.mind)
	current_mob.faction |= FACTION_VAMPIRE

	add_team_hud(current_mob, /datum/antagonist/vassal)

/datum/antagonist/vassal/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current

	UnregisterSignal(current_mob, COMSIG_ATOM_EXAMINE)

	// Tracking
	QDEL_NULL(monitor)
	current_mob.remove_language(/datum/language/vampiric, source = REF(src))

	// Remove traits
	for(var/vampire_trait in owner.current.status_traits)
		REMOVE_TRAIT(owner.current, vampire_trait, TRAIT_VAMPIRE)

	// Team
	vampire_team.remove_member(current_mob.mind)
	vampire_team = null
	current_mob.faction -= FACTION_VAMPIRE

/datum/antagonist/vassal/on_gain()
	. = ..()
	if(!master)
		owner.remove_antag_datum(src)
		CRASH("[owner.current] was vassilized without a master!")

	ADD_TRAIT(owner, TRAIT_VAMPIRE_ALIGNED, REF(src))
	RegisterSignal(SSsunlight, COMSIG_SOL_WARNING_GIVEN, PROC_REF(give_warning))

	// Enslave them to their Master
	master.vassals |= src
	owner.enslave_mind_to_creator(master.owner.current) // AQUILA - u nas parametrem jest mob, nie umysł
	owner.current.log_message("has been vassalized by [master.owner]!", LOG_ATTACK, color="#960000")

	// Give powers
	grant_power(new /datum/action/vampire/recuperate)
	grant_power(new /datum/action/vampire/distress)

	// Give objectives
	forge_objectives()

/datum/antagonist/vassal/on_removal()
	REMOVE_TRAIT(owner, TRAIT_VAMPIRE_ALIGNED, REF(src))
	UnregisterSignal(SSsunlight, COMSIG_SOL_WARNING_GIVEN)

	// Free them from their Master
	if(master)
		master.vassals -= src
		owner.enslaved_to = null

	// Remove powers
	for(var/datum/action/vampire/power in powers)
		powers -= power
		power.Remove(owner.current)

	return ..()

/datum/antagonist/vassal/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	for(var/datum/action/vampire/power in powers)
		power.Remove(old_body)
		power.Grant(new_body)

/datum/antagonist/vassal/greet()
	. = ..()
	if(silent)
		return

	var/mob/living/living_vassal = owner.current
	var/mob/living/living_master = master.owner.current

	// Alert vassal
	var/list/msg = list()
	msg += span_cultlarge("Jesteś teraz śmiertelnym sługą wampira - [living_master]!")
	msg += span_cult("Nie musisz słuchać żadnego innego wampira, bo tylko [living_master] jest twoim panem. Prawa Nanotrasenu już cię nie obowiązują - musisz być posłuszny wyłącznie słowu swojego pana.")
	to_chat(living_vassal, examine_block(msg.Join("\n")))

	living_vassal.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)
	antag_memory += "Jesteś śmiertelnym sługą wampira - <b>[living_master]</b>!<br>"

	// Alert master
	to_chat(living_master, span_userdanger("[living_vassal] uzależnia się od twojej nieśmiertelnej krwi. Od teraz to twój wierny sługa."))
	living_master.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/vassal/farewell()
	if(silent)
		return

	owner.current.visible_message(
		span_deconversionmessage("Oczy [owner.current] gorączkowo biegają na boki, po czym nieruchomieją. Na twarzy pojawia się spokój, \
			jakby odzyskana została jakaś utracona cząstka siebie."),
		span_deconversionmessage("Coś w tobie pęka i nie jesteś już niewolnikiem [master.owner]! Oddychasz ciężko, odzyskawszy wolną wolę.")
	)
	owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)

	// Alert master
	if(master.owner)
		to_chat(master.owner, span_cultbold("Czujesz, że więź z twoim wasalem ([owner.current]) w jakiś sposób została zerwana!"))

/datum/antagonist/vassal/admin_add(datum/mind/new_owner, mob/admin)
	var/list/datum/mind/possible_vampires = list()

	// Get possible vampires
	for(var/datum/antagonist/vampire/vampire in GLOB.antagonists)
		var/datum/mind/vampire_mind = vampire.owner
		if(QDELETED(vampire_mind?.current) || vampire_mind.current.stat == DEAD)
			continue

		possible_vampires += vampire_mind

	if(!length(possible_vampires))
		return

	// CHOOSE A DAMN PERSON
	var/datum/mind/choice = tgui_input_list(admin, "Do którego wampira ma należeć ten wasal?", "Wampir", possible_vampires)
	if(!choice)
		return

	log_admin("[key_name_admin(usr)] turned [key_name_admin(new_owner)] into a vassal of [key_name_admin(choice)]!")
	var/datum/antagonist/vampire/vampire = IS_VAMPIRE(choice.current)
	master = vampire
	new_owner.add_antag_datum(src)

	to_chat(choice, span_notice("Dzięki boskiej interwencji zyskujesz nowego wasala!"))

/datum/antagonist/vassal/forge_objectives()
	var/datum/objective/vampire/vassal/vassal_objective = new
	vassal_objective.owner = owner
	objectives += vassal_objective

/datum/antagonist/vassal/proc/setup_monitor(mob/target)
	QDEL_NULL(monitor)
	if(QDELETED(master?.owner?.current) || QDELETED(master.tracker))
		return

	monitor = target.AddComponent(/datum/component/team_monitor, REF(master))
	monitor.add_to_tracking_network(master.tracker.tracking_beacon)
	monitor.show_hud(target)

/datum/antagonist/vassal/proc/on_examined(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	var/text = "<img class='icon' src='\ref['aquila/icons/vampires/vampiric.dmi']?state=vassal'> "

	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(examiner)
	if(src in vampiredatum?.vassals)
		text += span_cult("<EM>To twój wasal!</EM>")
		examine_text += text
	else if(HAS_MIND_TRAIT(examiner, TRAIT_VAMPIRE_ALIGNED) || is_curator_job(examiner?.mind?.assigned_role))
		text += span_cult("<EM>To wasal, którego panem jest [master.return_full_name()]</EM>")
		examine_text += text

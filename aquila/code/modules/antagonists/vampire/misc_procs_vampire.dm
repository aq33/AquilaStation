/**
 * Helper proc for adding a power
**/
/datum/antagonist/vampire/proc/grant_power(datum/action/vampire/power)
	for(var/datum/action/vampire/current_powers as anything in powers)
		if(current_powers.type == power.type)
			return FALSE
	powers += power

	power.Grant(owner.current)
	log_game("[key_name(owner.current)] has purchased: [power].")
	return TRUE

/**
 * Helper proc for removing a power
**/
/datum/antagonist/vampire/proc/remove_power(datum/action/vampire/power)
	if(power.currently_active)
		power.deactivate_power()
	powers -= power
	power.Remove(owner.current)

/**
 * When a Vampire breaks the Masquerade, they get their HUD icon changed, and Malkavian Vampires get alerted.
**/
/datum/antagonist/vampire/proc/break_masquerade(mob/admin)
	if(broke_masquerade)
		return
	broke_masquerade = TRUE

	to_chat(owner.current, span_userdanger("Złamałeś Maskaradę!"))
	to_chat(owner.current, span_warning("Wskazówka wampira: gdy złamiesz Maskaradę, inne wampiry mogą cię zgładzić, a twoi wasale nie są ci już w pełni wierni, bo inni Spokrewnieni mogą ci ich odebrać!"))

	antag_hud_name = "masquerade_broken"
	add_team_hud(owner.current)

	SEND_GLOBAL_SIGNAL(COMSIG_VAMPIRE_BROKE_MASQUERADE, src)
	GLOB.masquerade_breakers.Add(src)

/**
 * Increment the masquerade infraction counter and warn the vampire accordingly
**/
/datum/antagonist/vampire/proc/give_masquerade_infraction()
	if(broke_masquerade)
		return
	masquerade_infractions++

	owner.current.playsound_local(null, 'aquila/sound/effects/antag/vampire/lunge_warn.ogg', 100, FALSE, pressure_affected = FALSE)

	if(masquerade_infractions >= 3)
		break_masquerade()
	else
		to_chat(owner.current, span_cultbold("Naruszyłeś Maskaradę! Jeszcze [3 - masquerade_infractions] wykroczenia przeciw Maskaradzie, a wszystkie inne wampiry zaczną na ciebie polować!"))

/**
 * Increase our unspent vampire levels by one and try to rank up if inside a coffin
 * Called near the end of Sol and admin abuse
**/
/datum/antagonist/vampire/proc/rank_up(levels, ignore_reqs = FALSE)
	if(QDELETED(owner) || QDELETED(owner.current))
		return

	if(vitae_goal_progress <= current_vitae_goal && !ignore_reqs)
		to_chat(owner.current, span_notice("Brak doświadczenia nie pozwala ci awansować. Następnym razem osiągnij cel vitae, żeby awansować."))
		return

	vampire_level_unspent += levels
	if(!my_clan)
		to_chat(owner.current, span_notice("Twoja moc rośnie. Dołącz do klanu, żeby ją wykorzystać."))
		return

	to_chat(owner, span_notice("<EM>Coraz lepiej znasz swoje moce!"))

	current_vitae_goal += VITAE_GOAL_STANDARD
	vitae_goal_progress = 0

/**
 * Decrease the unspent vampire levels by one. Only for admins
**/
/datum/antagonist/vampire/proc/rank_down()
	vampire_level_unspent--

/datum/antagonist/vampire/proc/remove_nondefault_powers(return_levels = FALSE)
	for(var/datum/action/vampire/power as anything in powers)
		if(power.special_flags & VAMPIRE_DEFAULT_POWER)
			continue
		remove_power(power)
		if(return_levels)
			vampire_level_unspent++

/**
 * Disables all Torpor exclusive powers, if forced is TRUE, disable all powers
**/
/datum/antagonist/vampire/proc/disable_all_powers(forced = FALSE)
	for(var/datum/action/vampire/power as anything in powers)
		if(forced || ((power.check_flags & BP_CANT_USE_IN_TORPOR) && is_in_torpor()))
			if(power.currently_active)
				power.deactivate_power()

/**
 * Check if we have a stake in our heart
**/
/datum/antagonist/vampire/proc/check_if_staked()
	var/obj/item/bodypart/chosen_bodypart = owner.current.get_bodypart(BODY_ZONE_CHEST)
	for(var/obj/item/stake/embedded_stake in chosen_bodypart?.embedded_objects)
		return TRUE

	return FALSE
/**
 * ##adjust_humanity(count, silent)
 *
 * Adds the specified amount of humanity to the vampire
 * Checks to make sure it doesn't exceed 10,
 * Checks to make sure it doesn't go under 0,
 * Adds the masquerade power at 9 or above
 */
/datum/antagonist/vampire/proc/adjust_humanity(count, silent = FALSE)
	// Step one: Toreadors have doubled gains and losses
	if(istype(my_clan, /datum/vampire_clan/toreador))
		count = count * 2

	// No-op if nothing to change
	if(count == 0)
		return FALSE

	// If trying to add but already at max, there's nothing to do
	if(count > 0 && humanity >= 10)
		return FALSE

	// Same for removing
	if(count < 0 && humanity <= 0)
		return FALSE

	var/temp_humanity = humanity + count

	var/power_given = FALSE
	var/power_removed = FALSE

	// Are we adding or removing?
	if(count > 0)
		// We are adding
		if(temp_humanity >= VAMPIRE_HUMANITY_MASQUERADE_POWER && !is_type_in_list(/datum/action/vampire/masquerade, powers))
			// Grant_power might fail, so we need to check if it actually got granted
			var/was_granted = grant_power(new /datum/action/vampire/masquerade)
			if(was_granted)
				power_given = TRUE

		// Only run this code if there is an actual increase in humanity. Also don't run it if we wanna be silent.
		if(humanity < temp_humanity && !silent)
			if(power_given)
				to_chat(owner.current, span_userdanger("Bliskość człowieczeństwa pozwala ci udawać życie!"))
			else
				to_chat(owner.current, span_userdanger("Zyskujesz Człowieczeństwo."))
	else
		// We are removing
		if(temp_humanity < VAMPIRE_HUMANITY_MASQUERADE_POWER)
			for(var/datum/action/vampire/masquerade/power in powers)
				remove_power(power)
				power_removed = TRUE

		// Only run this code if there is an actual decrease in humanity
		if(humanity > temp_humanity && !silent)
			if(power_removed)
				to_chat(owner.current, span_userdanger("Przez swoje nieludzkie czyny tracisz moc Maskarady!"))
			else
				to_chat(owner.current, span_userdanger("Tracisz Człowieczeństwo."))

	// Clamp to valid range, we are so sane we might see the face of god
	if(temp_humanity > 10)
		temp_humanity = 10
	if(temp_humanity < 0)
		temp_humanity = 0

	humanity = temp_humanity
	return TRUE

/// Bacon wanted a signal
/datum/antagonist/vampire/proc/on_track_humanity_gain_signal(datum/source, type, subject)
	SIGNAL_HANDLER
	return track_humanity_gain_progress(type, subject)

/// Signal handler for when the vampire pets an animal
/datum/antagonist/vampire/proc/on_pet_animal(datum/source, mob/living/pet)
	SIGNAL_HANDLER
	return track_humanity_gain_progress(HUMANITY_PETTING_TYPE, pet)

/// Signal handler for when the vampire hugs a carbon
/datum/antagonist/vampire/proc/on_hug_carbon(datum/source, mob/living/carbon/hugged)
	SIGNAL_HANDLER
	if(!hugged.client) // Only count hugs with real players for humanity
		return
	return track_humanity_gain_progress(HUMANITY_HUGGING_TYPE, hugged)

/// Signal handler for when the vampire appraises art
/datum/antagonist/vampire/proc/on_appraise_art(datum/source, atom/art_piece)
	SIGNAL_HANDLER
	return track_humanity_gain_progress(HUMANITY_ART_TYPE, art_piece)

/**
 * ##track_humanity_gain_progress(type, subject)
 *
 * Adds the specified subject to the tracking lists and handles all the other stuff related to it.
 * When a defined threshold is met, hands out humanity as appropriate and stops tracking.
 * Ideally this can be expanded on easily by just defining a new threshold and tracking list in the datum and defines respectively.
 * We return TRUE if it successfully added to tracked, and FALSE if it was already tracked or failed for some other reason.
 */
/datum/antagonist/vampire/proc/track_humanity_gain_progress(type, subject)
	// placeholders to populate // I dunno why this works btw, i thought i made a mistake but it worked anyways.
	var/list/tracking_list = null
	var/goal = null

	if(humanity >= 10) // Don't add anything if we're already at max.
		return

	// map all the placeholders to the correct type, get the list for easier handling
	switch(type)
		if(HUMANITY_HUGGING_TYPE)
			tracking_list = humanity_trackgain_hugged
			goal = humanity_hugging_goal
		if(HUMANITY_PETTING_TYPE)
			tracking_list = humanity_trackgain_petted
			goal = humanity_petting_goal
		if(HUMANITY_ART_TYPE)
			tracking_list = humanity_trackgain_art
			goal = humanity_art_goal
		else
			return FALSE // Cheeky check for type built in? Tsunami you genius!

	// already tracked?
	if(subject in tracking_list)
		return FALSE

	// Update the corresponding list
	switch(type)
		if(HUMANITY_HUGGING_TYPE)
			humanity_trackgain_hugged += subject
		if(HUMANITY_PETTING_TYPE)
			humanity_trackgain_petted += subject
		if(HUMANITY_ART_TYPE)
			humanity_trackgain_art += subject

	if(tracking_list.len >= goal)
		// set the corresponding gained flag and award humanity
		switch(type)
			if(HUMANITY_HUGGING_TYPE)
				humanity_hugging_goal *= 2
			if(HUMANITY_PETTING_TYPE)
				humanity_petting_goal *= 2
			if(HUMANITY_ART_TYPE)
				humanity_art_goal *= 2
		adjust_humanity(1)

	return TRUE

/datum/antagonist/vampire/proc/get_rank_string()
	switch(vampire_level)
		if(0 to 1)
			return "'Inicjowany'"
		if(2 to 3)
			return "'Nowicjusz'"
		if(4 to 5)
			return "'Uczeń'"
		if(6 to 7)
			return "'Adept'"
		if(8 to 9)
			return "'Ekspert'"
		if(10 to 11)
			return "'Mistrz'"
		if(12 to 24)
			return "'Wielki Mistrz'"
		if(25 to INFINITY)
			return "[span_narsiesmall("'Matuzalem'")]"

/// This is where we store clan descriptions.
/// We will need to know the description of a clan before we "make" one,
/// because we can't just get the description from the "not-made" clan ref.
/datum/antagonist/vampire/proc/get_clan_description(clan_name)
	/// This makes descriptions about a billion times cleaner: Spans for discipline names and their individual descriptions:
	var/disciplines = "[span_tooltip("Dyscypliny to aspekty pierwotnej klątwy rzuconej na Kaina, z których cierpi i korzysta każdy ze Spokrewnionych. W rozgrywce to grupy zdolności, które rozwijasz z kolejnymi awansami.", "Dyscypliny")]"
	var/animalism = "[span_tooltip("Animalizm to dyscyplina, która zbliża wampira do jego zwierzęcej natury. Zwykle pozwala porozumiewać się ze stworzeniami natury i zdobywać nad nimi władzę.", "Animalizm")]"
	var/auspex = "[span_tooltip("Postrzeganie to dyscyplina, która daje wampirom nadprzyrodzone zmysły, pozwalając widzieć dalej i głębiej niż jakikolwiek śmiertelnik. Szczególnie silną więź mają z nią Malkavianie.", "Postrzeganie")]"
	var/celerity = "[span_tooltip("Akceleracja to dyscyplina, która daje wampirom nadprzyrodzoną szybkość i refleks.", "Akceleracja")]"
	var/dominate = "[span_tooltip("Dominacja to dyscyplina, która przytłacza umysł innej osoby wolą wampira.", "Dominacja")]"
	var/fortitude = "[span_tooltip("Hart to dyscyplina, która daje Spokrewnionym nieziemską wytrzymałość.", "Hart")]"
	var/obfuscate = "[span_tooltip("Ukrycie to dyscyplina, która pozwala wampirom się ukryć, zwodzić umysły innych albo sprawić, że przeoczą to, czego użytkownik nie chce pokazać.", "Ukrycie")]"
	var/potence = "[span_tooltip("Potęga to dyscyplina, która obdarza wampiry fizycznym wigorem i nadnaturalną siłą.", "Potęga")]"
	var/presence = "[span_tooltip("Prezencja to dyscyplina nadprzyrodzonego uroku i manipulacji emocjami, która pozwala Spokrewnionym przyciągać, przekonywać i kontrolować tłumy.", "Prezencja")]"
	var/protean = "[span_tooltip("Przemiana to dyscyplina, która pozwala wampirom zmieniać postać, od wyrastania dzikich pazurów aż po przemianę w coś zupełnie innego.", "Przemiana")]"
	var/thaumaturgy = "[span_tooltip("Taumaturgia to tajemna sztuka krwi klanu Tremere. Daje dostęp do wszelkich rodzajów magii krwi i paktów.", "Taumaturgia")]"

	/// All the descriptions:
	var/ventrue = "Ventrue to faktyczni przywódcy Camarilli. Uważają się za królów i cesarzy, często zajmują stanowiska władzy.\n\
		<b>WAŻNE:</b> Członkowie Klanu Ventrue mogą zostać Księciem. Jeśli nie ma obecnie Księcia, zostaniesz nim. Pamiętaj, że od Księcia oczekuje się zachowania godnego tego urzędu.\n\
		<b>[disciplines]:</b> [dominate], [fortitude], [presence]"
	var/tremere = "Wywodzący się z potężnego rodu czarodziejów i magów Tremere władają tajemną sztuką magii krwi, której strzegą z najwyższą troską.\n\
		<b>[disciplines]:</b> [thaumaturgy], [auspex], [dominate]"
	var/toreador = "Artyści, kurtyzany, celebryci. Tacy są członkowie klanu Toreador. Ze wszystkich Spokrewnionych są zdecydowanie najbliżej człowieczeństwa, każdy z nich to osoba głęboko wrażliwa.\n\
		<b>[disciplines]:</b> [presence], [auspex], [celerity]"
	var/malkavian = "Kompletne szaleństwo. Masz ciągłe halucynacje, stajesz się prorokiem bełkoczącym niezrozumiałe słowa i zyskujesz wiedzę, której lepiej nie znać. Możesz też podróżować przez rozdarcia Fobetora, szczeliny w czasoprzestrzeni, przez które przejść możesz tylko ty.\n\
		<b>[disciplines]:</b> [dominate], [auspex], [obfuscate]"
	var/gangrel = "Często mylonych z wilkołakami Gangreli wszędzie otacza zapach mokrego psa. Ich wyjątkowa więź z wewnętrzną bestią pozwala im zmieniać części ciała w potężne szpony, a nawet stawać się zupełnie innymi istotami.\n\
		<b>[disciplines]:</b> [animalism], [protean], [fortitude]"
	var/brujah = "Dziś to klan złożony głównie z buntowników, choć niektórzy wciąż noszą ślady utraconego dziedzictwa wojowników-poetów. Dawno oderwali się od Camarilli i często tworzą własne grupy.\n\
		<b>[disciplines]:</b> [potence], [celerity], [presence]"

	// Now the logic
	switch(clan_name)
		if(CLAN_TOREADOR)
			return toreador
		if(CLAN_VENTRUE)
			return ventrue
		if(CLAN_BRUJAH)
			return brujah
		if(CLAN_MALKAVIAN)
			return malkavian
		if(CLAN_TREMERE)
			return tremere
		if(CLAN_GANGREL)
			return gangrel

	log_runtime("Unknown clan name passed to get_clan_description: [clan_name]")
	return "Brak opisu."

/**
 * Called when a Vampire reaches Final Death
 * Releases all Vassals.
 */
/datum/antagonist/vampire/proc/free_all_vassals()
	for(var/datum/antagonist/vassal/all_vassals in vassals)
		all_vassals.owner.remove_antag_datum(/datum/antagonist/vassal)

/// Checks to see if an entity counts as a "watcher" for a masquerade breach
/datum/antagonist/vampire/proc/is_masq_watcher(mob/living/watcher, recursion = 1)
	if(!isliving(watcher) || QDELING(watcher))
		return FALSE
	if(!watcher.mind || !watcher.client || watcher.client.is_afk())
		return FALSE
	if(HAS_MIND_TRAIT(watcher, TRAIT_VAMPIRE_ALIGNED))
		return FALSE
	if((FACTION_VAMPIRE in watcher.faction) || (REF(owner.current) in watcher.faction))
		return FALSE
	if(watcher.has_unlimited_silicon_privilege)
		return FALSE
	if(watcher.stat != CONSCIOUS)
		return FALSE
	if(watcher.is_blind() || watcher.is_nearsighted_currently())
		return FALSE
	var/mob/living/living_current = owner.current
	if(istype(living_current) && (watcher in living_current.hasparasites()))
		return FALSE
	if(recursion > 0)
		var/datum/mind/master = watcher.mind.enslaved_to
		if(master?.current)
			return .(master.current, recursion - 1)
	return TRUE

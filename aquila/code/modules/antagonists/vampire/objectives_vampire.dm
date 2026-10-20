/datum/objective/vampire

/datum/objective/vampire/New()
	update_explanation_text()
	return ..()

//////////////////////////////////////////////////////////////////////////////////////
//	//						   EGO OBJECTIVES 									//	//
//////////////////////////////////////////////////////////////////////////////////////
/datum/objective/vampire/ego
	name = "Władza"
	explanation_text = "Pragniesz władzy, prawa do rządzenia:"

//////////////////////////////////////////////////       Lair
////////////////////////////////////////////////////////////////////

/datum/objective/vampire/ego/lair
	name = "Zajmij legowisko"

/datum/objective/vampire/ego/lair/update_explanation_text()
	. = ..()
	explanation_text = "[initial(explanation_text)] Urządź legowisko, z którego będziesz rządzić, i utrzymaj je do końca zmiany."

// WIN CONDITIONS?
/datum/objective/vampire/ego/lair/check_completion()
	var/datum/antagonist/vampire/vampire_datum = owner.has_antag_datum(/datum/antagonist/vampire)
	if(!vampire_datum)
		return FALSE

	if(vampire_datum.coffin && vampire_datum.vampire_lair_area)
		return TRUE

	return FALSE


////////////////////////////////////////////////// Department Vassal
////////////////////////////////////////////////////////////////////

/datum/objective/vampire/ego/department_vassal
	name = "Podporządkuj dział"

	///The selected department we have to vassalize.
	var/target_department
	///List of all departments that can be selected for the objective.
	// AQUILA - u nas działy to listy nazw zawodów, a nie datumy department_group
	var/static/list/possible_departments = list(
		"engineering",
		"medical",
		"science",
		"cargo",
		"service",
	)

/datum/objective/vampire/ego/department_vassal/New()
	target_department = pick(possible_departments)
	target_amount = 1
	return ..()

/datum/objective/vampire/ego/department_vassal/update_explanation_text()
	var/department_name = target_department
	switch(target_department)
		if("engineering")
			department_name = "inżynieryjnego"
		if("medical")
			department_name = "medycznego"
		if("science")
			department_name = "naukowego"
		if("cargo")
			department_name = "zaopatrzenia"
		if("service")
			department_name = "usług"
	explanation_text = "[initial(explanation_text)] Zrób wasala z członka załogi z działu [department_name]."
	return ..()

/datum/objective/vampire/ego/department_vassal/proc/get_vassal_occupations()
	var/datum/antagonist/vampire/vampire_datum = owner.has_antag_datum(/datum/antagonist/vampire)
	if(!length(vampire_datum?.vassals))
		return null

	var/list/all_vassal_jobs = list()
	for(var/datum/antagonist/vassal/vassal_datum in vampire_datum.vassals)
		if(!vassal_datum.owner)
			continue

		var/datum/mind/vassal_mind = vassal_datum.owner

		// Mind Assigned
		if(!is_unassigned_job(vassal_mind.assigned_role))
			all_vassal_jobs += vassal_mind.assigned_role
			continue
		// Mob Assigned
		if(vassal_mind.current?.job)
			all_vassal_jobs += vassal_mind.current.job
			continue
		// PDA Assigned
		if(ishuman(vassal_mind.current))
			var/mob/living/carbon/human/human_vassal = vassal_mind.current
			all_vassal_jobs += human_vassal.get_assignment()
			continue

	return all_vassal_jobs

/datum/objective/vampire/ego/department_vassal/check_completion()
	var/list/vassal_jobs = get_vassal_occupations()
	var/converted_count = 0
	var/list/department_jobs
	switch(target_department)
		if("engineering")
			department_jobs = GLOB.engineering_positions
		if("medical")
			department_jobs = GLOB.medical_positions
		if("science")
			department_jobs = GLOB.science_positions
		if("cargo")
			department_jobs = GLOB.supply_positions
		if("service")
			department_jobs = GLOB.civilian_positions
	for(var/checked_job in vassal_jobs)
		if(checked_job in department_jobs)
			converted_count++
	if(converted_count >= target_amount)
		return TRUE
	return FALSE


//////////////////////////////////////////////////    Big Places
////////////////////////////////////////////////////////////////////

/datum/objective/vampire/ego/bigplaces
	name = "Wspinaczka po rangach"

/datum/objective/vampire/ego/bigplaces/update_explanation_text()
	. = ..()
	explanation_text = "[initial(explanation_text)] Rośnij w siłę: zostań Księciem albo Biczem lub poluj na tylu śmiertelników, żeby awansować jak najwyżej. Do końca zmiany musisz osiągnąć co najmniej rangę 8!"

// WIN CONDITIONS?
/datum/objective/vampire/ego/bigplaces/check_completion()
	var/datum/antagonist/vampire/vampire_datum = owner.has_antag_datum(/datum/antagonist/vampire)
	if(!vampire_datum)
		return FALSE

	if(vampire_datum.vampire_level + vampire_datum.vampire_level_unspent >= 8)
		return TRUE

	return FALSE


//////////////////////////////////////////////////////////////////////////////////////
//	//						 HEDONISM OBJECTIVES 								//	//
//////////////////////////////////////////////////////////////////////////////////////

/datum/objective/vampire/hedonism
	name = "Głód"
	explanation_text = "Pragniesz zepsucia, chcesz gasić pragnienie krwią śmiertelników:"


//////////////////////////////////////////////////     Heart Thief
////////////////////////////////////////////////////////////////////

/datum/objective/vampire/hedonism/heartthief
	name = "Zbierz serca"

/datum/objective/vampire/hedonism/heartthief/New()
	target_amount = rand(2,3)
	return ..()

/datum/objective/vampire/hedonism/heartthief/update_explanation_text()
	. = ..()
	explanation_text = "[initial(explanation_text)] Miej przy sobie organiczne serca (sztuk: [target_amount]). Będą symbolem twojej władzy."

/datum/objective/vampire/hedonism/heartthief/check_completion()
	if(QDELETED(owner.current))
		return FALSE

	var/list/all_items = owner.current.get_contents()
	var/heart_count = 0
	for(var/obj/item/organ/heart/current_hearts in all_items)
		if(current_hearts.organ_flags & ORGAN_SYNTHETIC) // No robo-hearts allowed
			continue
		heart_count++

	if(heart_count >= target_amount)
		return TRUE
	return FALSE


//////////////////////////////////////////////////     Gourmand
////////////////////////////////////////////////////////////////////

/datum/objective/vampire/hedonism/gourmand
	name = "Obżarstwo"

/datum/objective/vampire/hedonism/gourmand/New()
	target_amount = rand(500, 1000) // This is blood, not vitae.
	return ..()

/datum/objective/vampire/hedonism/gourmand/update_explanation_text()
	. = ..()
	explanation_text = "[initial(explanation_text)] Wypij co najmniej [target_amount] jednostek krwi, żeby zaspokoić swoje wściekłe pragnienie."

/datum/objective/vampire/hedonism/gourmand/check_completion()
	var/datum/antagonist/vampire/vampiredatum = owner.has_antag_datum(/datum/antagonist/vampire)
	if(!vampiredatum)
		return FALSE
	var/stolen_blood = vampiredatum.total_blood_drank
	if(stolen_blood >= target_amount)
		return TRUE
	return FALSE

//////////////////////////////////////////////////     Thirster
////////////////////////////////////////////////////////////////////

/datum/objective/vampire/hedonism/thirster
	name = "Wyssij do końca"

/datum/objective/vampire/hedonism/thirster/update_explanation_text()
	. = ..()
	explanation_text = "[initial(explanation_text)] Wyssij śmiertelnika do ostatniej kropli, niech jego krew stanie się twoim pożywieniem, a ciało zostanie zimne i puste."

/datum/objective/vampire/hedonism/thirster/check_completion()
	var/datum/antagonist/vampire/vampiredatum = owner.has_antag_datum(/datum/antagonist/vampire)
	if(!vampiredatum)
		return FALSE

	if(vampiredatum.thirster_objective)
		return TRUE

	return FALSE

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////       MISC       //////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

/datum/objective/survive/vampire
	name = "Przetrwaj"
	explanation_text = "Za wszelką cenę uniknij Ostatecznej Śmierci."

/**
 * Vassal
 */
/datum/objective/vampire/vassal
	name = "pomóż panu"
	explanation_text = "Łakniesz krwi swojego stwórcy! Słuchaj go i chroń za wszelką cenę!"

/datum/objective/vampire/vassal/check_completion()
	var/datum/antagonist/vassal/vassal_datum = owner.has_antag_datum(/datum/antagonist/vassal)
	var/mob/living/master = vassal_datum.master?.owner?.current
	return !QDELETED(master) && master.stat != DEAD

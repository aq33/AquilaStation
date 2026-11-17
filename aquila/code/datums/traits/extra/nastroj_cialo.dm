// Transhumanista i purysta ciała (tg): nastrój zależy od tego, ile w ciele (i wokół) jest maszyny, a ile mięsa.
// Kończyny nie wysyłają u nas sygnałów przy przyszyciu i odjęciu, więc ciało jest przeliczane okresowo (i od razu przy zmianie organów).

#define AQ_MOOD_CATEGORY_TRANSHUMANIST_PEOPLE "transhumanist_people"
#define AQ_MOOD_CATEGORY_TRANSHUMANIST_BODYPART "transhumanist_bodypart"
// Liczba syntetyków minus liczba organicznych w pobliżu
#define AQ_TRANSHUMANIST_LEVEL_ECSTATIC 4
#define AQ_TRANSHUMANIST_LEVEL_HAPPY 1
#define AQ_TRANSHUMANIST_LEVEL_UNHAPPY -2
#define AQ_TRANSHUMANIST_LEVEL_ANGRY -5
/// Co ile ticków (sekund) przeliczać ciało
#define AQ_BODY_RECHECK_TICKS 5

/// Robotyczna kończyna albo syntetyczny organ
/proc/aq_is_cybernetic_part(obj/item/part)
	if(istype(part, /obj/item/bodypart))
		var/obj/item/bodypart/limb = part
		return !!(limb.bodytype & BODYTYPE_ROBOTIC)
	if(istype(part, /obj/item/organ))
		var/obj/item/organ/organ = part
		return !!(organ.organ_flags & ORGAN_SYNTHETIC)
	return FALSE

/datum/quirk/transhumanist
	name = "Transhumanista"
	desc = "Życie syntetyczne to dla ciebie forma doskonała, a organicznym mięsem gardzisz. Przy syntetykach masz lepszy humor, przy organicznych się złościsz. Chcesz zastąpić słabe ciało doskonałą maszyną. Zaczynasz z robotyczną kończyną."
	icon = "robot"
	value = 0
	mood_quirk = TRUE
	process = TRUE
	gain_text = "<span class='notice'>Masz ochotę pozbyć się słabego organicznego ciała i otoczyć się robotami.</span>"
	lose_text = "<span class='danger'>Roboty nie wydają się już takie wspaniałe.</span>"
	medical_record_text = "Pacjent twierdzi, że nienawidzi żałosnych istot z mięsa i kości."
	/// Która kończyna została wymieniona przy starcie
	var/slot_string
	var/body_recheck = 0

/datum/quirk/transhumanist/add()
	RegisterSignal(quirk_holder, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN), PROC_REF(on_organs_changed))
	calculate_bodypart_score()

/datum/quirk/transhumanist/remove()
	UnregisterSignal(quirk_holder, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN))
	SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, AQ_MOOD_CATEGORY_TRANSHUMANIST_BODYPART)
	SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, AQ_MOOD_CATEGORY_TRANSHUMANIST_PEOPLE)

/datum/quirk/transhumanist/on_spawn()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/limb_slot = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/old_part = human_holder.get_bodypart(limb_slot)
	if(!old_part || (old_part.bodytype & BODYTYPE_ROBOTIC))
		return
	var/obj/item/bodypart/new_part
	switch(limb_slot)
		if(BODY_ZONE_L_ARM)
			new_part = new /obj/item/bodypart/l_arm/robot(quirk_holder)
			slot_string = "lewa ręka"
		if(BODY_ZONE_R_ARM)
			new_part = new /obj/item/bodypart/r_arm/robot(quirk_holder)
			slot_string = "prawa ręka"
		if(BODY_ZONE_L_LEG)
			new_part = new /obj/item/bodypart/l_leg/robot(quirk_holder)
			slot_string = "lewa noga"
		if(BODY_ZONE_R_LEG)
			new_part = new /obj/item/bodypart/r_leg/robot(quirk_holder)
			slot_string = "prawa noga"
	// Jak przy protezie (NSV13): proteza nogi digitigrade też jest digitigrade
	if(old_part.bodytype & BODYTYPE_DIGITIGRADE)
		new_part.bodytype |= BODYTYPE_DIGITIGRADE
		new_part.static_icon = 'nsv13/icons/mob/augmentation/digitigrade_legs.dmi'
		new_part.limb_id = "digitigrade"
	new_part.replace_limb(human_holder)
	qdel(old_part)
	human_holder.regenerate_icons()
	calculate_bodypart_score()

/datum/quirk/transhumanist/post_add()
	if(!slot_string)
		return
	to_chat(quirk_holder, "<span class='boldannounce'>Twoja [slot_string] została zastąpiona robotyczną. Do jej naprawy potrzebujesz spawarki i kabli zamiast szwów i maści.</span>")

/datum/quirk/transhumanist/proc/on_organs_changed()
	SIGNAL_HANDLER
	calculate_bodypart_score()

/// Wynik ciała: list(organiczne, syntetyczne, inne_typy)
/datum/quirk/transhumanist/proc/get_bodypart_score(mob/living/carbon/target, limbs_only = FALSE)
	var/organic_bodytypes = 0
	var/silicon_bodytypes = 0
	var/other_bodytypes = FALSE
	for(var/obj/item/bodypart/part as anything in target.bodyparts)
		if(part.bodytype & BODYTYPE_ROBOTIC)
			silicon_bodytypes += 1
		else if(part.bodytype & BODYTYPE_ORGANIC)
			organic_bodytypes += 0.1
		else
			other_bodytypes = TRUE
	if(!limbs_only)
		for(var/obj/item/organ/organ as anything in target.internal_organs)
			if(organ.organ_flags & ORGAN_SYNTHETIC)
				silicon_bodytypes += 0.25
			else
				organic_bodytypes += 0.02
	return list(organic_bodytypes, silicon_bodytypes, other_bodytypes)

/datum/quirk/transhumanist/proc/calculate_bodypart_score()
	if(!iscarbon(quirk_holder))
		return
	var/list/score = get_bodypart_score(quirk_holder)
	var/organic_bodytypes = score[1]
	var/silicon_bodytypes = score[2]
	var/other_bodytypes = score[3]

	if(!other_bodytypes)
		if(organic_bodytypes <= 0.02)
			SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, AQ_MOOD_CATEGORY_TRANSHUMANIST_BODYPART, /datum/mood_event/completely_robotic)
			return
		else if(silicon_bodytypes == 0)
			SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, AQ_MOOD_CATEGORY_TRANSHUMANIST_BODYPART, /datum/mood_event/completely_organic)
			return
	else if(silicon_bodytypes == 0 && organic_bodytypes == 0)
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, AQ_MOOD_CATEGORY_TRANSHUMANIST_BODYPART)
		return

	var/bodypart_score = silicon_bodytypes - organic_bodytypes
	if(bodypart_score >= 3)
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, AQ_MOOD_CATEGORY_TRANSHUMANIST_BODYPART, /datum/mood_event/very_robotic)
	else if(bodypart_score >= 0)
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, AQ_MOOD_CATEGORY_TRANSHUMANIST_BODYPART, /datum/mood_event/balanced_robotic)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, AQ_MOOD_CATEGORY_TRANSHUMANIST_BODYPART, /datum/mood_event/very_organic)

/datum/quirk/transhumanist/on_process(delta_time)
	if(++body_recheck >= AQ_BODY_RECHECK_TICKS)
		body_recheck = 0
		calculate_bodypart_score()

	var/organics_nearby = 0
	var/silicons_nearby = 0
	for(var/mob/living/target in oview(3, quirk_holder))
		if(!isturf(target.loc) || target.alpha <= 128 || target.invisibility > quirk_holder.see_invisible)
			continue
		if(iscarbon(target))
			var/list/score = get_bodypart_score(target, limbs_only = TRUE)
			// Przeciętny człowiek potrzebuje dwóch wszczepionych kończyn, żeby nie liczyć się ani jako organiczny, ani jako syntetyk
			if(score[2] - score[1] < 1)
				organics_nearby += 1
			else if(score[1] == 0)
				silicons_nearby += 1
		else if(MOB_ORGANIC in target.mob_biotypes)
			organics_nearby += 1
		else if((MOB_ROBOTIC in target.mob_biotypes) && target.stat != DEAD) // martwe syntetyki to już tylko maszyneria
			silicons_nearby += 1

	var/mood_result = silicons_nearby - organics_nearby
	if(mood_result >= AQ_TRANSHUMANIST_LEVEL_ECSTATIC)
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, AQ_MOOD_CATEGORY_TRANSHUMANIST_PEOPLE, /datum/mood_event/surrounded_by_silicon)
	else if(mood_result >= AQ_TRANSHUMANIST_LEVEL_HAPPY)
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, AQ_MOOD_CATEGORY_TRANSHUMANIST_PEOPLE, /datum/mood_event/around_many_silicon)
	else if(mood_result > 0)
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, AQ_MOOD_CATEGORY_TRANSHUMANIST_PEOPLE, /datum/mood_event/around_silicon)
	else if(mood_result == 0)
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, AQ_MOOD_CATEGORY_TRANSHUMANIST_PEOPLE)
	else if(mood_result >= AQ_TRANSHUMANIST_LEVEL_UNHAPPY)
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, AQ_MOOD_CATEGORY_TRANSHUMANIST_PEOPLE, /datum/mood_event/around_organic)
	else if(mood_result >= AQ_TRANSHUMANIST_LEVEL_ANGRY)
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, AQ_MOOD_CATEGORY_TRANSHUMANIST_PEOPLE, /datum/mood_event/around_many_organic)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, AQ_MOOD_CATEGORY_TRANSHUMANIST_PEOPLE, /datum/mood_event/surrounded_by_organic)

/datum/quirk/body_purist
	name = "Purysta Ciała"
	desc = "Wierzysz, że ciało jest świątynią, a jego naturalna forma to ucieleśnienie doskonałości. Brzydzi cię sama myśl o ulepszaniu go sztucznymi częściami: wszczepami, protezami i czymkolwiek podobnym."
	icon = "leaf"
	value = -1
	mood_quirk = TRUE
	process = TRUE
	gain_text = "<span class='danger'>Zaczyna cię brzydzić myśl o cybernetycznych wszczepach.</span>"
	lose_text = "<span class='notice'>Może cybernetyka nie jest taka zła. Wszczepy i protezy już ci nie przeszkadzają.</span>"
	medical_record_text = "Pacjent wyznał, że skrajnie nienawidzi sztucznych części ciała i wszczepów."
	/// Ile sztucznych części ma teraz ciało
	var/cybernetics_level = 0
	var/body_recheck = 0

/datum/quirk/body_purist/add()
	RegisterSignal(quirk_holder, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN), PROC_REF(on_organs_changed))
	check_cybernetics()

/datum/quirk/body_purist/remove()
	UnregisterSignal(quirk_holder, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN))
	SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "body_purist")

/datum/quirk/body_purist/on_process(delta_time)
	if(++body_recheck >= AQ_BODY_RECHECK_TICKS)
		body_recheck = 0
		check_cybernetics()

/datum/quirk/body_purist/proc/on_organs_changed()
	SIGNAL_HANDLER
	check_cybernetics()

/// Przelicza sztuczne części i odświeża nastrój, gdy ich liczba się zmieniła
/datum/quirk/body_purist/proc/check_cybernetics()
	var/mob/living/carbon/owner = quirk_holder
	if(!istype(owner))
		return
	var/new_level = 0
	for(var/obj/item/bodypart/limb as anything in owner.bodyparts)
		if(aq_is_cybernetic_part(limb))
			new_level++
	for(var/obj/item/organ/organ as anything in owner.internal_organs)
		if(aq_is_cybernetic_part(organ))
			new_level++
	if(new_level == cybernetics_level)
		return
	cybernetics_level = new_level
	// Ta sama kategoria z tym samym typem nie odświeża się sama, więc najpierw czyścimy
	SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "body_purist")
	if(cybernetics_level)
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "body_purist", /datum/mood_event/body_purist, -cybernetics_level * 10)

/datum/mood_event/body_purist
	description = "<span class='boldwarning'>Czuję w sobie cybernetykę i NIENAWIDZĘ TEGO!</span>\n"

/datum/mood_event/body_purist/add_effects(power)
	mood_change = power

/datum/mood_event/surrounded_by_silicon
	description = "<span class='nicegreen'>Otaczają mnie doskonałe formy życia!!</span>\n"
	mood_change = 8

/datum/mood_event/around_many_silicon
	description = "<span class='nicegreen'>Tyle syntetycznych form życia wokół mnie!</span>\n"
	mood_change = 4

/datum/mood_event/around_silicon
	description = "<span class='nicegreen'>Syntetyczne formy życia obok mnie są absolutnie doskonałe.</span>\n"
	mood_change = 2

/datum/mood_event/around_organic
	description = "<span class='warning'>Organiczni obok mnie przypominają mi o niższości mięsa.</span>\n"
	mood_change = -2

/datum/mood_event/around_many_organic
	description = "<span class='warning'>Tylu obrzydliwych organicznych!</span>\n"
	mood_change = -4

/datum/mood_event/surrounded_by_organic
	description = "<span class='boldwarning'>Otaczają mnie obrzydliwi organiczni!!</span>\n"
	mood_change = -8

/datum/mood_event/completely_robotic
	description = "<span class='nicegreen'>Porzuciłem słabe mięso, moja forma jest doskonała!!</span>\n"
	mood_change = 8

/datum/mood_event/very_robotic
	description = "<span class='nicegreen'>Jestem bardziej robotem niż organizmem!</span>\n"
	mood_change = 4

/datum/mood_event/balanced_robotic
	description = "Jestem w części maszyną, a w części organizmem.\n"
	mood_change = 0

/datum/mood_event/very_organic
	description = "<span class='warning'>Nienawidzę tego słabego, kruchego mięsa!</span>\n"
	mood_change = -4

/datum/mood_event/completely_organic
	description = "<span class='boldwarning'>Jestem całkowicie organiczny, to żałosne!!</span>\n"
	mood_change = -8

#undef AQ_MOOD_CATEGORY_TRANSHUMANIST_PEOPLE
#undef AQ_MOOD_CATEGORY_TRANSHUMANIST_BODYPART
#undef AQ_TRANSHUMANIST_LEVEL_ECSTATIC
#undef AQ_TRANSHUMANIST_LEVEL_HAPPY
#undef AQ_TRANSHUMANIST_LEVEL_UNHAPPY
#undef AQ_TRANSHUMANIST_LEVEL_ANGRY
#undef AQ_BODY_RECHECK_TICKS

// Podłączenie wirusologii disease2 do naszego rdzenia.
// Monke robi to edycjami w core (readme modułu wymienia: carbon/life.dm, _disease.dm,
// decals/cleanable.dm, atoms.dm, human_defense.dm). U nas prawie wszystko da się zrobić
// nadpisaniem w aquila/, więc rdzeń ruszamy tylko tam, gdzie nie ma czego nadpisać.

// --- tick życia: patogeny, chmury i kontakt z plamami -------------------------
// Nasz /mob/living/carbon/handle_diseases() tylko przewija stopnie chorób advance.
// Patogeny disease2 mają własną pętlę (activate), a chmury i plamy zarażają w handle_virus_updates().
/mob/living/carbon/handle_diseases()
	handle_virus_updates()
	if(QDELETED(src))
		return
	// powietrze: zwykłe choroby rozsiewa nasz spread(), patogeny robią to chmurami
	for(var/datum/disease/disease as anything in diseases)
		if(istype(disease, /datum/disease/acute))
			continue
		if(prob(disease.infectivity))
			disease.spread()

/mob/living/carbon/human/handle_breathing(times_fired)
	. = ..()
	if(stat != DEAD && !HAS_TRAIT(src, TRAIT_VIRUSIMMUNE))
		breath_airborne_diseases()

/mob/living/simple_animal/mouse/Life(seconds, times_fired)
	. = ..()
	if(stat != DEAD)
		handle_virus_updates()

// --- kontakt: dotyk i wpadanie na siebie --------------------------------------
/mob/living/carbon/human/attack_hand(mob/user, modifiers)
	. = ..()
	if(!isliving(user) || user == src)
		return
	var/mob/living/toucher = user
	var/block = toucher.check_contact_sterility(BODY_ZONE_ARMS) || check_contact_sterility(BODY_ZONE_EVERYTHING)
	var/bleeding = toucher.check_bodypart_bleeding(BODY_ZONE_ARMS) && check_bodypart_bleeding(BODY_ZONE_EVERYTHING)
	share_contact_diseases(toucher, block, bleeding)

/mob/living/Bump(atom/bumped_atom)
	. = ..()
	if(!isliving(bumped_atom))
		return
	var/mob/living/other = bumped_atom
	if(!length(diseases) && !length(other.diseases))
		return
	var/block = check_contact_sterility(BODY_ZONE_EVERYTHING) || other.check_contact_sterility(BODY_ZONE_EVERYTHING)
	var/bleeding = check_bodypart_bleeding(BODY_ZONE_EVERYTHING) && other.check_bodypart_bleeding(BODY_ZONE_EVERYTHING)
	share_contact_diseases(other, block, bleeding)

// --- latejoin: część dołączających ma łagodny patogen -------------------------
/mob/dead/new_player/AttemptLateSpawn(rank)
	. = ..()
	var/mob/living/carbon/human/character = mind?.current
	if(ishuman(character))
		DiseaseCarrierCheck(character)

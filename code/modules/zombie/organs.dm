/obj/item/organ/zombie_infection
	name = "ropiejąca maź"
	desc = "Czarna sieć ropy i wnętrzności."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_ZOMBIE
	icon_state = "blacktumor"
	var/causes_damage = TRUE
	var/datum/species/old_species = /datum/species/human
	var/living_transformation_time = 30
	var/converts_living = FALSE

	var/revive_time_min = 450
	var/revive_time_max = 700
	var/timer_id

/obj/item/organ/zombie_infection/Initialize(mapload)
	. = ..()
	if(iscarbon(loc))
		Insert(loc)
	GLOB.zombie_infection_list += src

/obj/item/organ/zombie_infection/Destroy()
	GLOB.zombie_infection_list -= src
	. = ..()

/obj/item/organ/zombie_infection/Insert(var/mob/living/carbon/M, special = 0)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/organ/zombie_infection/Remove(mob/living/carbon/M, special = 0)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	if(iszombie(M) && old_species && !QDELETED(M) && !special)
		M.set_species(old_species)
	if(timer_id)
		deltimer(timer_id)

/obj/item/organ/zombie_infection/on_find(mob/living/finder)
	to_chat(finder, "<span class='warning'>W głowie jest obrzydliwa czarna \
		sieć ropy i wnętrzności, ciasno oplatająca mózg jak jakaś \
		biologiczna uprząż.</span>")

/obj/item/organ/zombie_infection/process(delta_time)
	if(!owner)
		return
	if(owner.IsInStasis())
		return
	if(!(src in owner.internal_organs))
		Remove(owner, TRUE)
	if (causes_damage && !iszombie(owner) && owner.stat != DEAD)
		owner.adjustToxLoss(0.5 * delta_time, forced = TRUE)
		if(DT_PROB(5, delta_time))
			to_chat(owner, "<span class='danger'>Robi ci się niedobrze...</span>")
	if(timer_id)
		return
	if(owner.suiciding)
		return
	if(owner.stat != DEAD && !converts_living)
		return
	if(!owner.getorgan(/obj/item/organ/brain))
		return
	if(!iszombie(owner))
		to_chat(owner, "<span class='cultlarge'>Czujesz, jak serce ci staje, ale coś jest nie tak... \
		życie nie opuściło twojego zniszczonego ciała. Czujesz tylko głęboki i niezmienny głód, którego \
		nawet śmierć nie powstrzyma. Powstaniesz znowu!</span>")
	var/revive_time = rand(revive_time_min, revive_time_max)
	var/flags = TIMER_STOPPABLE
	timer_id = addtimer(CALLBACK(src, PROC_REF(zombify), owner), revive_time, flags)

/obj/item/organ/zombie_infection/proc/zombify(var/mob/living/carbon/C)
	timer_id = null

	if(!converts_living && owner.stat != DEAD)
		return

	if(!iszombie(owner))
		old_species = owner.dna.species.type
		C.set_species(/datum/species/zombie/infectious)

	var/stand_up = (C.stat == DEAD) || (C.stat == UNCONSCIOUS)

	//Fully heal the zombie's damage the first time they rise
	C.setToxLoss(0, 0)
	C.setOxyLoss(0, 0)
	C.heal_overall_damage(INFINITY, INFINITY, INFINITY, null, TRUE)

/* NSV13 - Does this do what they think it does?
	if(!C.revive())
		return
*/
	owner?.revive()

	C.grab_ghost()
	C.visible_message("<span class='danger'>[owner] nagle dostaje drgawek[stand_up ? ", chwiejnie staje na nogi" : ""], a w oczach pojawia się wilczy głód!</span>", "<span class='alien'>JESTEŚ GŁODNY!</span>")
	playsound(C.loc, 'sound/hallucinations/far_noise.ogg', 50, 1)
	C.do_jitter_animation(living_transformation_time)
	C.Stun(living_transformation_time)
	to_chat(C, "<span class='alertalien'>Jesteś teraz zombie! Nie szukaj lekarstwa, w żaden sposób nie pomagaj nikomu, kto nie jest zombie, nie krzywdź swoich zombiaczych braci i szerz chorobę, zabijając innych. Jesteś istotą głodu i przemocy.</span>")

	owner.faction = list("zombie") //NSV13 - used to prevent KNPC zombies remurdering them

/obj/item/organ/zombie_infection/nodamage
	causes_damage = FALSE

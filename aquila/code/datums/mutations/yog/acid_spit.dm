// AQUILA - port z Yogstation (code/datums/mutations/acid_spit.dm) bez blokady rasy polysmorpha,
// plus Unstable Acid Spit z Monkestation (code/datums/mutations/acid_spit.dm)

/datum/mutation/acidspit
	name = "Kwasowa plwocina"
	desc = "Pradawna mutacja ksenomorfów, przez którą gruczoły ślinowe wytwarzają kwas."
	quality = POSITIVE
	instability = 50
	difficulty = 12
	locked = TRUE
	text_gain_indication = "<span class='notice'>Twoja ślina pali cię w usta!</span>"
	text_lose_indication = "<span class='notice'>Twoja ślina stygnie.</span>"
	action_path = /datum/action/cooldown/spell/pointed/projectile/acid_spit
	conflicts = list(/datum/mutation/acidspit/unstable)

/datum/action/cooldown/spell/pointed/projectile/acid_spit
	name = "Kwasowa plwocina"
	desc = "Zbierasz żrącą ślinę i plujesz nią w cel."
	icon_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "alien_neurotoxin_0"
	cooldown_time = 18 SECONDS
	spell_requirements = NONE
	antimagic_flags = NONE
	sound = 'aquila/sound/mutations/yog/alien_spitacid.ogg'
	active_msg = "Skupiasz kwaśną ślinę!"
	deactive_msg = "Rozluźniasz się."
	projectile_type = /obj/item/projectile/bullet/yog_acid_spit
	/// Mnożnik siły kwasu
	var/acid_multiplier = 1

/datum/action/cooldown/spell/pointed/projectile/acid_spit/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return
	if(!get_location_accessible(owner, BODY_ZONE_PRECISE_MOUTH))
		if(feedback)
			to_chat(owner, "<span class='notice'>Coś zasłania ci usta!</span>")
		return FALSE

/datum/action/cooldown/spell/pointed/projectile/acid_spit/ready_projectile(obj/item/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	var/obj/item/projectile/bullet/yog_acid_spit/spit = to_fire
	if(istype(spit))
		spit.multiplier = acid_multiplier

/obj/item/projectile/bullet/yog_acid_spit
	name = "kwasowa plwocina"
	icon_state = "neurotoxin"
	damage = 2
	damage_type = BURN
	flag = "bio"
	range = 7
	speed = 1.8 // ślina nie leci szybko
	/// Mnożnik siły kwasu
	var/multiplier = 1

/obj/item/projectile/bullet/yog_acid_spit/on_hit(atom/target, blocked = FALSE, pierce_hit)
	if(isalien(target)) // na ksenomorfy nie działa
		nodamage = TRUE
	else if(iscarbon(target))
		target.acid_act(18 * multiplier, 15)
	else if(!isopenturf(target))
		target.acid_act(50 * multiplier, 15) // mocno niszczy przedmioty i ściany
	return ..()

// Unstable Acid Spit (Monkestation): bardziej niestabilna, z przepisu, rozpuszcza też kajdanki, kaftan i szafkę

/datum/mutation/acidspit/unstable
	name = "Niestabilna kwasowa plwocina"
	desc = "Pradawna mutacja ksenomorfów, przez którą gruczoły ślinowe wytwarzają kwas. To bardzo niestabilna odmiana."
	instability = 70
	action_path = /datum/action/cooldown/spell/pointed/projectile/acid_spit/unstable
	conflicts = list(/datum/mutation/acidspit)
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/acidspit/unstable/modify()
	if(modified || !owner)
		return
	..()
	var/datum/action/cooldown/spell/pointed/projectile/acid_spit/spit = action_power
	if(istype(spit))
		spit.acid_multiplier = GET_MUTATION_POWER(src)

/datum/action/cooldown/spell/pointed/projectile/acid_spit/unstable
	name = "Niestabilna kwasowa plwocina"
	desc = "Zbierasz żrącą ślinę i plujesz nią w cel. Użyta na sobie wypala wszystko, co cię krępuje."

/datum/action/cooldown/spell/pointed/projectile/acid_spit/unstable/cast(atom/cast_on)
	. = ..()
	if(.)
		return
	// W szafce: wypalamy zawiasy
	var/obj/structure/closet/closet = owner.loc
	if(!istype(closet))
		return
	closet.visible_message("<span class='warning'>Zawiasy [closet] zaczynają się topić!</span>")
	to_chat(owner, "<span class='warning'>Plujesz żrącą śliną na wnętrze [closet]!</span>")
	addtimer(CALLBACK(src, PROC_REF(open_closet), owner, closet), 14 SECONDS / acid_multiplier)
	return TRUE

/datum/action/cooldown/spell/pointed/projectile/acid_spit/unstable/fire_projectile(atom/target)
	var/mob/living/carbon/human/human = owner
	if(!istype(human) || target != owner)
		return ..()
	if(!human.restrained() && !human.legcuffed && !human.wear_suit?.breakouttime)
		return ..()

	current_amount--
	var/obj/item/restraint
	if(human.handcuffed)
		restraint = human.handcuffed
	else if(human.legcuffed)
		restraint = human.legcuffed
	else if(human.wear_suit?.breakouttime)
		restraint = human.wear_suit
	if(!restraint)
		current_amount++
		return ..()
	human.visible_message("<span class='warning'>[human] pluje grudą żrącej śliny na [restraint]!</span>", \
		"<span class='warning'>Plujesz żrącą śliną na [restraint]!</span>")
	addtimer(CALLBACK(src, PROC_REF(dissolve_restraint), human, restraint), 6 SECONDS / acid_multiplier)
	return TRUE

/datum/action/cooldown/spell/pointed/projectile/acid_spit/unstable/proc/dissolve_restraint(mob/living/carbon/human/user, obj/item/restraint)
	if(QDELETED(restraint) || QDELETED(user))
		return
	if(restraint != user.handcuffed && restraint != user.legcuffed && restraint != user.wear_suit)
		return
	user.visible_message("<span class='warning'>[restraint] rozpuszcza się w syczącą kałużę mazi.</span>")
	new /obj/effect/decal/cleanable/greenglow(restraint.drop_location())
	qdel(restraint)

/datum/action/cooldown/spell/pointed/projectile/acid_spit/unstable/proc/open_closet(mob/living/carbon/human/user, obj/structure/closet/closet)
	if(QDELETED(closet) || QDELETED(user) || user.loc != closet)
		return
	closet.visible_message("<span class='warning'>Drzwi [closet] pękają i się otwierają!</span>")
	new /obj/effect/decal/cleanable/greenglow(closet.drop_location())
	closet.welded = FALSE
	closet.locked = FALSE
	closet.broken = TRUE
	closet.open()
	to_chat(user, "<span class='warning'>Otwierasz pojemnik, w którym cię zamknięto!</span>")

// Monkestation: chemiczny kolec z języka + radioaktywność. Tongue spike u nas nie ma, przepis zadziała, gdy ktoś go doda.
/datum/generecipe/acidspit_unstable
	required = "/datum/mutation/tongue_spike/chem; /datum/mutation/radioactive"
	result = /datum/mutation/acidspit/unstable

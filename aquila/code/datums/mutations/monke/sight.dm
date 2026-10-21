// AQUILA - port z Monkestation2.0 (code/datums/mutations/sight.dm)

/datum/mutation/meson_vision
	name = "Meson Visual Enhancement"
	desc = "A mutation that manipulates the subject's eyes in a way that makes them able to see behind walls to a limited degree."
	locked = TRUE
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Do twoich oczu zdaje się docierać więcej informacji...</span>"
	text_lose_indication = "<span class='notice'>Informacji docierających do oczu znów jest mniej...</span>"
	instability = 20
	mutation_traits = list(TRAIT_MADNESS_IMMUNE, TRAIT_MESON_VISION)

/datum/mutation/meson_vision/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	owner.update_sight()

/datum/mutation/meson_vision/on_losing(mob/living/carbon/owner)
	if(..())
		return TRUE
	owner.update_sight()

/datum/mutation/flash_protection
	name = "Protected Cornea"
	desc = "A mutation that causes reinforcement to subject's eyes, allowing them to protect against disorientation from bright flashes via distributing excessive photons hitting the subject's eyes."
	locked = TRUE
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Przestajesz zauważać blask świateł...</span>"
	text_lose_indication = "<span class='notice'>Światła znów zaczynają razić...</span>"
	instability = 30
	/// Ochrona przed błyskiem, jaką dostają organiczne oczy (FLASH_PROTECTION_FLASH w tg)
	var/eye_flash_protect = 1

/datum/mutation/flash_protection/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	RegisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(eye_implanted))
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(eye_removed))
	protect_eyes(owner.getorganslot(ORGAN_SLOT_EYES))

/datum/mutation/flash_protection/on_losing(mob/living/carbon/owner)
	if(..())
		return TRUE
	UnregisterSignal(owner, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN))
	var/obj/item/organ/eyes/eyes = owner.getorganslot(ORGAN_SLOT_EYES)
	if(eyes)
		eyes.flash_protect = initial(eyes.flash_protect)

/datum/mutation/flash_protection/proc/protect_eyes(obj/item/organ/eyes/eyes)
	if(!istype(eyes) || eyes.status == ORGAN_ROBOTIC)
		return
	eyes.flash_protect = max(eyes.flash_protect, eye_flash_protect)

/datum/mutation/flash_protection/proc/eye_implanted(mob/living/source, obj/item/organ/gained)
	SIGNAL_HANDLER
	protect_eyes(gained)

/datum/mutation/flash_protection/proc/eye_removed(mob/living/source, obj/item/organ/removed)
	SIGNAL_HANDLER
	var/obj/item/organ/eyes/eyes = removed
	if(istype(eyes))
		eyes.flash_protect = initial(eyes.flash_protect)

/datum/client_colour/monochrome/monke_colorblind

/datum/mutation/colorblindness
	name = "Genetic achromatopy"
	desc = "This genetic sequence makes the subject occipital lobe not interpret color, rendering the patient completely colorblind."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='notice'>Czujesz, jak twój mózg trochę drętwieje..?</span>"
	text_lose_indication = "<span class='notice'>Znów prawidłowo widzisz kolory.</span>"
	instability = 5
	var/color_typepath = /datum/client_colour/monochrome/monke_colorblind

/datum/mutation/colorblindness/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	owner.add_client_colour(color_typepath)

/datum/mutation/colorblindness/on_losing(mob/living/carbon/owner)
	if(..())
		return TRUE
	owner.remove_client_colour(color_typepath)

// X-Ray przełączany, kosztem zdrowia oczu

/datum/mutation/weaker_xray
	name = "X-Ray Vision"
	desc = "A strange genome that allows the user to see between the spaces of walls at the cost of their eye health."
	quality = POSITIVE
	locked = TRUE
	action_path = /datum/action/cooldown/spell/toggle/monke_xray
	instability = 60
	conflicts = list(/datum/mutation/thermal/x_ray, /datum/mutation/weaker_xray/syndicate)
	synchronizer_coeff = 1

/datum/mutation/weaker_xray/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	update_power()

/datum/mutation/weaker_xray/modify()
	..()
	update_power()

/datum/mutation/weaker_xray/proc/update_power()
	var/datum/action/cooldown/spell/toggle/monke_xray/xray = action_power
	if(istype(xray))
		xray.synchronizer = GET_MUTATION_SYNCHRONIZER(src)

/datum/mutation/weaker_xray/syndicate
	name = "Refined X-Ray Vision"
	desc = "A strange genome that allows the user to see between the spaces of walls at the cost of their eye health. This one seems to be high-quality making it more stable."
	instability = 40
	conflicts = list(/datum/mutation/thermal/x_ray, /datum/mutation/weaker_xray)

/datum/action/cooldown/spell/toggle/monke_xray
	name = "Toggle X-ray"
	desc = "Concentrate your eyes to see through the walls, this makes your eyes take damage and be weaker to flashes."
	icon_icon = 'icons/mob/actions/actions_changeling.dmi'
	button_icon_state = "augmented_eyesight"
	cooldown_time = 0
	spell_requirements = NONE
	antimagic_flags = NONE
	/// Mnożnik obrażeń oczu (chromosom synchronizujący)
	var/synchronizer = 1
	/// Oczy, którym obniżyliśmy ochronę przed błyskiem
	var/obj/item/organ/eyes/weakened_eyes
	/// Ostatnie naliczenie obrażeń oczu
	var/last_damage_time = 0

/datum/action/cooldown/spell/toggle/monke_xray/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!. || active)
		return
	var/mob/living/carbon/carbon_owner = owner
	var/obj/item/organ/eyes/eyes = istype(carbon_owner) ? carbon_owner.getorganslot(ORGAN_SLOT_EYES) : null
	if(!eyes)
		if(feedback)
			to_chat(owner, "<span class='warning'>Nie masz oczu, którymi mógłbyś prześwietlać!</span>")
		return FALSE
	if(eyes.organ_flags & ORGAN_FAILING)
		if(feedback)
			to_chat(owner, "<span class='warning'>Ślepymi oczami nic nie prześwietlisz!</span>")
		return FALSE
	if(eyes.status == ORGAN_ROBOTIC)
		if(feedback)
			to_chat(owner, "<span class='warning'>Twoje oczy są mechaniczne!</span>")
		return FALSE

/datum/action/cooldown/spell/toggle/monke_xray/Enable()
	var/mob/living/carbon/carbon_owner = owner
	var/obj/item/organ/eyes/eyes = istype(carbon_owner) ? carbon_owner.getorganslot(ORGAN_SLOT_EYES) : null
	if(!eyes)
		active = FALSE
		return
	to_chat(owner, "<span class='notice'>Oczy pieką cię, gdy zmuszasz je do patrzenia przez litą materię.</span>")
	weakened_eyes = eyes
	eyes.flash_protect--
	eyes.applyOrganDamage(5 * synchronizer)
	last_damage_time = world.time
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(eye_removed))
	ADD_TRAIT(owner, TRAIT_XRAY_VISION, MONKE_XRAY_TOGGLE_TRAIT)
	owner.update_sight()

/datum/action/cooldown/spell/toggle/monke_xray/Disable()
	if(!QDELETED(weakened_eyes))
		weakened_eyes.flash_protect++
	weakened_eyes = null
	if(!owner)
		return
	UnregisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN)
	REMOVE_TRAIT(owner, TRAIT_XRAY_VISION, MONKE_XRAY_TOGGLE_TRAIT)
	owner.update_sight()
	to_chat(owner, "<span class='notice'>Twoje oczy przestają patrzeć przez ściany.</span>")

/datum/action/cooldown/spell/toggle/monke_xray/process()
	. = ..()
	if(!active || !owner)
		return
	var/mob/living/carbon/carbon_owner = owner
	var/obj/item/organ/eyes/eyes = istype(carbon_owner) ? carbon_owner.getorganslot(ORGAN_SLOT_EYES) : null
	if(!eyes || eyes != weakened_eyes)
		force_off()
		return
	var/elapsed = (world.time - last_damage_time) / (1 SECONDS)
	if(elapsed < 1)
		return
	last_damage_time = world.time
	eyes.applyOrganDamage(elapsed * 2 * synchronizer)
	if(eyes.organ_flags & ORGAN_FAILING)
		force_off()

/datum/action/cooldown/spell/toggle/monke_xray/proc/force_off()
	if(!active)
		return
	active = FALSE
	Disable()
	UpdateButtonIcon()

/datum/action/cooldown/spell/toggle/monke_xray/proc/eye_removed(mob/living/source, obj/item/organ/removed)
	SIGNAL_HANDLER
	if(removed == weakened_eyes)
		INVOKE_ASYNC(src, PROC_REF(force_off))

/datum/action/cooldown/spell/toggle/monke_xray/Destroy()
	if(active)
		force_off()
	weakened_eyes = null
	return ..()

// Niestabilne laserowe oczy: ograniczona liczba strzałów, każdy pali oczy i głowę

/datum/mutation/laser_eyes/unstable
	name = "Unstable Laser Eyes"
	desc = "Reflects concentrated light back from the eyes, however this mutation is very unstable and causes damage to the user."
	instability = 60
	conflicts = list(/datum/mutation/laser_eyes, /datum/mutation/laser_eyes/unstable/syndicate)
	synchronizer_coeff = 1
	/// Ile strzałów mieści się w oczach
	var/max_shots = 4
	var/shots_left = 4
	/// Sekundy do odzyskania następnego strzału
	var/recharge = 0

/datum/mutation/laser_eyes/unstable/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/mutation/laser_eyes/unstable/on_losing(mob/living/carbon/owner)
	if(..())
		return TRUE
	STOP_PROCESSING(SSobj, src)
	shots_left = max_shots
	recharge = 0

/datum/mutation/laser_eyes/unstable/on_ranged_attack(atom/target, modifiers)
	if(!owner.combat_mode || owner.next_move > world.time)
		return
	var/obj/item/organ/eyes/eyes = owner.getorganslot(ORGAN_SLOT_EYES)
	if(!eyes)
		to_chat(owner, "<span class='warning'>Nie masz oczu, z których mógłbyś strzelać!</span>")
		return
	if(eyes.organ_flags & ORGAN_FAILING)
		to_chat(owner, "<span class='warning'>Nie strzelisz laserem ze stopionej rogówki!</span>")
		return
	if(eyes.status == ORGAN_ROBOTIC)
		owner.balloon_alert(owner, "oczy mechaniczne!")
		return
	if(shots_left <= 0)
		owner.balloon_alert(owner, "nie możesz strzelić!")
		to_chat(owner, "<span class='warning'>Nie możesz strzelać laserami tak szybko!</span>")
		return

	owner.LaserEyes(target, modifiers)
	if(shots_left == max_shots)
		START_PROCESSING(SSobj, src)
	shots_left--

	var/backfire_damage = 5 * GET_MUTATION_SYNCHRONIZER(src)
	eyes.applyOrganDamage(backfire_damage)
	var/obj/item/bodypart/head = owner.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		if(head.receive_damage(0, backfire_damage))
			owner.update_damage_overlays()
	else
		owner.adjustFireLoss(backfire_damage)

/datum/mutation/laser_eyes/unstable/process(delta_time)
	recharge += delta_time
	if(recharge >= 5)
		shots_left = min(shots_left + 1, max_shots)
		recharge -= 5
		var/obj/item/organ/eyes/eyes = owner?.getorganslot(ORGAN_SLOT_EYES)
		if(eyes && !(eyes.organ_flags & ORGAN_FAILING))
			owner.balloon_alert(owner, "oczy naładowane!")
	if(shots_left >= max_shots)
		recharge = 0
		return PROCESS_KILL

/datum/mutation/laser_eyes/unstable/syndicate
	name = "Stabilized Laser Eyes"
	desc = "Reflects concentrated light back from the eyes, this strain of the mutation is high-quality, yet still causes the user to take damage on use."
	conflicts = list(/datum/mutation/laser_eyes, /datum/mutation/laser_eyes/unstable)
	instability = 40

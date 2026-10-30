// AQUILA - port z tgstation (code/datums/mutations/sight.dm)

/datum/mutation/illiterate
	name = "Analfabetyzm"
	desc = "Pacjent traci umiejętność czytania i pisania."
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>Czujesz, że nie umiesz czytać ani pisać.</span>"
	text_lose_indication = "<span class='danger'>Znów umiesz czytać i pisać.</span>"
	mutation_traits = list(TRAIT_ILLITERATE)

/datum/mutation/night_vision
	name = "Widzenie w ciemności"
	desc = "Pacjent widzi w ciemności."
	quality = POSITIVE
	instability = 35
	text_gain_indication = "<span class='notice'>Ciemność w kątach pomieszczenia znika.</span>"
	text_lose_indication = "<span class='notice'>Ciemność w kątach pomieszczenia wraca.</span>"
	mutation_traits = list(TRAIT_NIGHT_VISION)
	/// Oczy, którym sami ustawiliśmy widzenie w ciemności
	var/datum/weakref/changed_eyes

/datum/mutation/night_vision/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	// U nas TRAIT_NIGHT_VISION działa przy wkładaniu oczu (jak w quirku), więc ustawiamy obecne oczy sami
	var/obj/item/organ/eyes/eyes = owner.getorganslot(ORGAN_SLOT_EYES)
	if(eyes && !eyes.lighting_alpha)
		eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_NV_TRAIT
		changed_eyes = WEAKREF(eyes)
	owner.update_sight()

/datum/mutation/night_vision/on_losing(mob/living/carbon/owner)
	if(..())
		return TRUE
	var/obj/item/organ/eyes/eyes = owner.getorganslot(ORGAN_SLOT_EYES)
	var/obj/item/organ/eyes/our_eyes = changed_eyes?.resolve()
	// Oczy włożone w trakcie mutacji też dostały noktowizję od traitu
	if(eyes && !HAS_TRAIT(owner, TRAIT_NIGHT_VISION) && (eyes == our_eyes || eyes.lighting_alpha == LIGHTING_PLANE_ALPHA_NV_TRAIT) && !initial(eyes.lighting_alpha))
		eyes.lighting_alpha = null
	changed_eyes = null
	owner.update_sight()

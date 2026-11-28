// AQUILA - okulary śledcze (/vg/station code/modules/clothing/glasses/hud.dm, investigation glasses).
// HUD ochrony, a do tego noszący widzi, na co w promieniu 4 kratek patrzą inni: „X przygląda się Y”
// albo „X zagląda do Z”. Oględzin własnego ekwipunku (poza rękami) nie widać. Tylko w szafce detektywa.

#define EYE_TRACKING_RANGE 4

/obj/item/clothing/glasses/hud/security/sunglasses/aq_investigation
	name = "okulary śledcze"
	desc = "Okulary przeciwsłoneczne z HUD-em ochrony i śledzeniem wzroku: widać, na co patrzą ludzie wokół."

/obj/item/clothing/glasses/hud/security/sunglasses/aq_investigation/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_EYES)
		ADD_TRAIT(user, TRAIT_AQ_EYE_TRACKING, REF(src))

/obj/item/clothing/glasses/hud/security/sunglasses/aq_investigation/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_AQ_EYE_TRACKING, REF(src))

/mob/living
	/// Ile razy okulary śledcze pokazały komuś spojrzenia tego moba (test)
	var/aq_gaze_reports = 0

/mob/living/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/aq_gaze_reporter)

/// Nasłuch udanych oględzin (sygnał wysyła baza run_examinate dopiero po nich). Osobny słuchacz, a nie sam mob:
/// mob rejestrujący ten sygnał na sobie (krwawy robak) nadpisałby handler spojrzenia
/datum/element/aq_gaze_reporter

/datum/element/aq_gaze_reporter/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOB_EXAMINATE, PROC_REF(on_examinate))

/datum/element/aq_gaze_reporter/Detach(datum/source)
	UnregisterSignal(source, COMSIG_MOB_EXAMINATE)
	return ..()

/datum/element/aq_gaze_reporter/proc/on_examinate(mob/living/source, atom/A)
	SIGNAL_HANDLER
	source.aq_report_gaze(A)

/// Powiadamia noszących okulary śledcze w pobliżu, na co patrzy ten mob. Zwraca liczbę powiadomionych (test)
/mob/living/proc/aq_report_gaze(atom/A)
	. = 0
	if(QDELETED(A) || A == src || invisibility > SEE_INVISIBLE_LIVING)
		return
	// własny ekwipunek poza rękami nie jest widoczny z zewnątrz
	if(isitem(A) && A.loc == src && !is_holding(A))
		return
	var/message
	if(isitem(A) && A.loc && !isturf(A.loc) && A.loc != src && !ismob(A.loc))
		message = "[src] zagląda do [A.loc]."
	else
		message = "[src] przygląda się [A]."
	for(var/mob/living/watcher in viewers(EYE_TRACKING_RANGE, src))
		if(watcher == src || !HAS_TRAIT(watcher, TRAIT_AQ_EYE_TRACKING) || is_blind(watcher))
			continue
		to_chat(watcher, "<span class='notice'><i>[message]</i></span>")
		.++
	aq_gaze_reports += .

#undef EYE_TRACKING_RANGE

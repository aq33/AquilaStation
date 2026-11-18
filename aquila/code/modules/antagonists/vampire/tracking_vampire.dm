/datum/antagonist/vampire/proc/setup_tracker(mob/living/body)
	cleanup_tracker()
	tracker = new(body, REF(src))
	// AQUILA - namiernik siedzi w ciele i ginie razem z nim, a rola (na umyśle) dalej go trzymała (wyciek w testach)
	RegisterSignal(tracker, COMSIG_PARENT_QDELETING, PROC_REF(on_tracker_deleted))

	for(var/datum/antagonist/vassal/vassal in vassals)
		vassal.monitor?.add_to_tracking_network(tracker.tracking_beacon)
	tracker.tracking_beacon.toggle_visibility(TRUE)

/datum/antagonist/vampire/proc/cleanup_tracker()
	if(tracker)
		// Remove the tracking beacon from all vassals, maybe this fixes it..
		for(var/datum/antagonist/vassal/vassal in vassals)
			if(!vassal.monitor?.tracking)
				continue
			var/atom/movable/screen/arrow = vassal.monitor.tracking[tracker.tracking_beacon]
			vassal.monitor.tracking.Remove(tracker.tracking_beacon)
			if(arrow)
				if(vassal.monitor.updating?.hud_used)
					vassal.monitor.updating.hud_used.team_finder_arrows -= arrow
				qdel(arrow)
		UnregisterSignal(tracker, COMSIG_PARENT_QDELETING)
		if(QDELING(tracker)) // wołane z on_tracker_deleted(): namiernik już jest usuwany
			tracker = null
		else
			QDEL_NULL(tracker)

/// Namiernik usunięty razem z ciałem: zdejmij go z sieci wasali i zapomnij
/datum/antagonist/vampire/proc/on_tracker_deleted(datum/source)
	SIGNAL_HANDLER
	cleanup_tracker()

/**
 * An abstract object contained within the vampire, used to host the team_monitor component.
**/
/obj/effect/abstract/vampire_tracker_holder
	name = "nośnik namiernika wampira"
	desc = span_danger("<b>NAPRAWDĘ</b> nie powinieneś tego widzieć!")

	var/datum/component/tracking_beacon/tracking_beacon

/obj/effect/abstract/vampire_tracker_holder/Initialize(mapload, key)
	. = ..()
	tracking_beacon = AddComponent(/datum/component/tracking_beacon, \
		_frequency_key = key, \
		_colour = "#960000", \
		_global = TRUE, \
		_always_update = TRUE, \
	)

/obj/effect/abstract/vampire_tracker_holder/Destroy(force)
	if(tracking_beacon)
		tracking_beacon.toggle_visibility(FALSE)
		tracking_beacon = null // Let the component system handle cleanup via parent ..()
	. = ..()

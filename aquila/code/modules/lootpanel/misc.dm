/// On contents change, either reset or update
/datum/lootpanel/proc/on_searchable_deleted(datum/search_object/source)
	SIGNAL_HANDLER

	contents -= source
	to_image -= source

	if(isnull(owner)) // klient się rozłączył, nie ma okna do odświeżenia
		return

	var/datum/tgui/window = SStgui.get_open_ui(owner.mob, src)
#if !defined(UNIT_TESTS) // we dont want to delete contents if we're testing
	if(isnull(window))
		reset_contents()
		return
#endif

	if(isturf(source.item))
		populate_contents()
		return

	window?.send_update()

/// Helper to open the panel
/datum/lootpanel/proc/open(turf/tile)
	if(tile != source_turf)
		if(source_turf)
			UnregisterSignal(source_turf, COMSIG_ATOM_ENTERED)
		RegisterSignal(tile, COMSIG_ATOM_ENTERED, PROC_REF(on_source_turf_entered))

	source_turf = tile
	populate_contents()
	ui_interact(owner.mob)

/**
 * Called by SSlooting whenever this datum is added to its backlog.
 * Iterates over to_image list to create icons, then removes them.
 * Returns boolean - whether this proc has finished the queue or not.
 */
/datum/lootpanel/proc/process_images()
	for(var/datum/search_object/index as anything in to_image)
		to_image -= index

		if(QDELETED(index) || index.icon)
			continue

		index.generate_icon(owner)

		if(TICK_CHECK)
			break

	var/datum/tgui/window = SStgui.get_open_ui(owner.mob, src)
	if(isnull(window))
		reset_contents()
		return TRUE

	window.send_update()

	return !length(to_image)

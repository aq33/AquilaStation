// AQUILA - Zatkany zsyp: kilka zsypów na okręcie z hukiem wypluwa śmieci, z ostatniego wyłażą myszy i karaluchy (port z BlueMoon-Station code/modules/events/disposals_clog.dm)
// As in BlueMoon (itself from Paradise): back pressure in the disposal network makes 4-7 disposal bins on the ship throw
// out 4-8 pieces of ordinary trash each and the last one also lets out 2-4 mice or cockroaches (our basic mobs), with a
// 75% chance of a warning first. The warning is given only if the ship has a disposal bin, so the crew is never warned
// about a clog that cannot happen. Not the same as "Wybuch w zsypie" (disposals_explosion.dm), where one weakened pipe
// bursts.

/datum/round_event_control/aquila_hex_disposals_clog
	name = "Zatkany zsyp"
	typepath = /datum/round_event/aquila_hex_disposals_clog
	weight = 10
	min_players = 3
	max_occurrences = 2
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_disposals_clog
	fakeable = FALSE
	announceWhen = 1
	announceChance = 75
	startWhen = 3
	/// How many bins were spewed out
	var/spewed = 0

/datum/round_event/aquila_hex_disposals_clog/announce(fake)
	if(!fake && !length(ship_bins()))
		return
	priority_announce("Automatyka sieci zsypów zgłasza wsteczne ciśnienie w rurach. Zawartość może zostać wyrzucona przez zsypy. Odsuńcie się od nich i nie zaglądajcie do środka.", "Służba utylizacji Nanotrasen")

/// Disposal bins standing on the ship
/datum/round_event/aquila_hex_disposals_clog/proc/ship_bins()
	. = list()
	for(var/obj/machinery/disposal/bin/bin in GLOB.machines)
		if(isturf(bin.loc) && is_station_level(bin.z))
			. += bin

/datum/round_event/aquila_hex_disposals_clog/start()
	var/list/bins = ship_bins()
	if(!length(bins))
		log_game("Disposals Clog: no disposal bin on the ship, cancelling the event.")
		return kill()
	var/bin_count = min(rand(4, 7), length(bins))
	for(var/i in 1 to bin_count)
		spew(pick_n_take(bins), with_vermin = (i == bin_count))
	log_game("Disposals Clog spewed trash out of [spewed] disposal bin(s).")

/// One bin throws out a fan of trash; with_vermin adds a few mice or cockroaches. Returns the spawned atoms
/datum/round_event/aquila_hex_disposals_clog/proc/spew(obj/machinery/disposal/bin/bin, with_vermin = FALSE)
	. = list()
	var/turf/origin = get_turf(bin)
	if(QDELETED(bin) || !origin)
		return
	spewed++
	bin.visible_message("<span class='warning'>[bin] trzęsie się i wypluwa zawartość rur!</span>")
	playsound(origin, 'sound/machines/disposalflush.ogg', 60, TRUE)
	var/static/list/trash_types = list(
		/obj/item/trash/raisins,
		/obj/item/trash/candy,
		/obj/item/trash/cheesie,
		/obj/item/trash/chips,
		/obj/item/trash/boritos,
		/obj/item/trash/popcorn,
		/obj/item/trash/sosjerky,
		/obj/item/trash/syndi_cakes,
		/obj/item/trash/energybar,
		/obj/item/trash/waffles,
		/obj/item/trash/pistachios,
		/obj/item/trash/semki,
		/obj/item/trash/can,
		/obj/item/trash/tray,
	)
	for(var/i in 1 to rand(4, 8))
		var/junk_type = pick(trash_types)
		var/obj/item/junk = new junk_type(origin)
		junk.throw_at(get_offset_target_turf(origin, rand(-3, 3), rand(-3, 3)), 3, 1)
		. += junk
	if(!with_vermin)
		return
	var/mob/living/first_vermin
	for(var/i in 1 to rand(2, 4))
		var/vermin_type = prob(60) ? /mob/living/basic/mouse : /mob/living/basic/cockroach
		var/mob/living/vermin = new vermin_type(origin)
		vermin.throw_at(get_offset_target_turf(origin, rand(-3, 3), rand(-3, 3)), 3, 1)
		. += vermin
		first_vermin ||= vermin
	announce_to_ghosts(first_vermin)

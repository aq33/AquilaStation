/datum/overmap_objective/scan
	name = "Skanuj anomalie"
	desc = "Zeskanuj docelowy anomaly_type"
	brief = "Zlokalizujcie i zeskanujcie cel: anomaly_type"
	binary = FALSE
	var/anomaly_type
	var/anomaly_name = "anomaly"
	var/list/anomaly_whitelist = list(
		/obj/effect/overmap_anomaly/safe/sun,
		/obj/effect/overmap_anomaly/safe/sun/red_giant,
		/obj/effect/overmap_anomaly/wormhole,
		/obj/effect/overmap_anomaly/singularity)
	var/minimum_anomalies = 1
	var/maximum_anomalies = 5

/datum/overmap_objective/scan/New()
	. = ..()
	var/list/valid_anomalies = anomaly_whitelist
	target = rand(minimum_anomalies, maximum_anomalies)
	while(length(valid_anomalies) && !anomaly_type) //doing this to check if there are enough of this type
		anomaly_type = pick(valid_anomalies)
		anomaly_name = get_atom_by_type(GLOB.overmap_anomalies, anomaly_type)?.name
		if(!anomaly_name || (count_by_type(GLOB.overmap_anomalies, anomaly_type) < target))
			valid_anomalies -= anomaly_type
			anomaly_type = null
			anomaly_name = "ERROR"
	if(!anomaly_type)
		message_admins("Tryb gry overmapy nie znajduje dość anomalii! Cel zostaje automatycznie zaliczony.")
		status = 1

/datum/overmap_objective/scan/instance()
	. = ..()
	desc = "Zeskanuj anomalie: [anomaly_name] (sztuk: [target])"
	brief = "Zlokalizujcie i zeskanujcie anomalie: [anomaly_name] (sztuk: [target])"
	RegisterSignal(SSstar_system.find_main_overmap(), COMSIG_ANOMALY_SCANNED, PROC_REF(register_scan))

/datum/overmap_objective/scan/proc/register_scan()
	tally = count_by_type(SSstar_system.find_main_overmap().scanned, anomaly_type)
	SSovermap_mode.update_reminder(objective=TRUE)
	check_completion()

/datum/overmap_objective/scan/check_completion()
	if(tally >= target)
		status = 1

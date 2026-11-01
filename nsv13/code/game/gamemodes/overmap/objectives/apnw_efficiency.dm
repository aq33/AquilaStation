/datum/overmap_objective/apnw_efficiency
	name = "Test APNW"
	desc = "Doprowadź APNW do docelowej wydajności"
	brief = "Przetestujcie APNW, podnosząc skuteczność napraw do co najmniej target_efficiency %"
	var/obj/machinery/armour_plating_nanorepair_well/APNW = null
	var/target_efficiency = 0.50 // out of 1

/datum/overmap_objective/apnw_efficiency/New()
	. = ..()
	APNW = locate() in GLOB.machines
	if(!APNW)
		message_admins("Tryb gry overmapy nie znajduje APNW! Cel zostaje automatycznie zaliczony.")
		status = 1
	else
		target_efficiency = rand(60, 90) / 100
		START_PROCESSING(SSprocessing, src)

/datum/overmap_objective/apnw_efficiency/instance()
	. = ..()
	desc = "Doprowadź APNW do wydajności [target_efficiency * 100]%"
	brief = "Przetestujcie APNW, podnosząc skuteczność napraw do co najmniej [target_efficiency * 100]%"

/datum/overmap_objective/apnw_efficiency/process()
	check_completion()

/datum/overmap_objective/apnw_efficiency/check_completion()
	if(status != 0)
		STOP_PROCESSING(SSprocessing, src)
		return
	if(APNW.repair_efficiency >= target_efficiency)
		SSovermap_mode.update_reminder(objective=TRUE)
		status = 1
		STOP_PROCESSING(SSprocessing, src)

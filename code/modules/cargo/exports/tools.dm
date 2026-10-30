/datum/export/toolbox
	cost = 4
	message = "szt. – skrzynka narzędziowa"
	export_types = list(/obj/item/storage/toolbox)

// mechanical toolbox:	22cr
// emergency toolbox:	17-20cr
// electrical toolbox:	36cr
// robust: priceless

// Basic tools
/datum/export/screwdriver
	cost = 2
	message = "szt. – śrubokręt"
	export_types = list(/obj/item/screwdriver)
	include_subtypes = FALSE

/datum/export/wrench
	cost = 2
	message = "szt. – klucz nastawny"
	export_types = list(/obj/item/wrench)

/datum/export/crowbar
	cost = 2
	message = "szt. – łom"
	export_types = list(/obj/item/crowbar)

/datum/export/wirecutters
	cost = 2
	message = "szt. – przecinak do drutu"
	export_types = list(/obj/item/wirecutters)

/datum/export/powertool
	cost = 15
	message = "szt. – elektronarzędzie"
	export_types = list(/obj/item/powertool)

/datum/export/weldingtool
	cost = 5
	message = "szt. – spawarka"
	export_types = list(/obj/item/weldingtool)
	include_subtypes = FALSE

/datum/export/weldingtool/emergency
	cost = 2
	message = "szt. – awaryjna spawarka"
	export_types = list(/obj/item/weldingtool/mini)

/datum/export/weldingtool/industrial
	cost = 10
	message = "szt. – przemysłowa spawarka"
	export_types = list(/obj/item/weldingtool/largetank, /obj/item/weldingtool/hugetank)


/datum/export/extinguisher
	cost = 15
	message = "szt. – gaśnica"
	export_types = list(/obj/item/extinguisher)
	include_subtypes = FALSE

/datum/export/extinguisher/mini
	cost = 2
	message = "szt. – gaśnica kieszonkowa"
	export_types = list(/obj/item/extinguisher/mini)


/datum/export/flashlight
	cost = 5
	message = "szt. – latarka"
	export_types = list(/obj/item/flashlight)
	include_subtypes = FALSE

/datum/export/flashlight/flare
	cost = 2
	message = "szt. – raca"
	export_types = list(/obj/item/flashlight/flare)

/datum/export/flashlight/seclite
	cost = 10
	message = "szt. – latarka policyjna"
	export_types = list(/obj/item/flashlight/seclite)


/datum/export/analyzer
	cost = 5
	message = "szt. – analizator gazów"
	export_types = list(/obj/item/analyzer)

/datum/export/analyzer/t_scanner
	cost = 10
	message = "szt. – skaner T-ray"
	export_types = list(/obj/item/t_scanner)


/datum/export/radio
	cost = 5
	message = "szt. – radio"
	export_types = list(/obj/item/radio)
	exclude_types = list(/obj/item/radio/mech)


/datum/export/rcd
	cost = 100
	message = "szt. – RCD"
	export_types = list(/obj/item/construction/rcd)

/datum/export/rcd_ammo
	cost = 60
	message = "szt. – wkład z materią"
	export_types = list(/obj/item/rcd_ammo)

/datum/export/rpd
	cost = 100
	message = "szt. – RPD"
	export_types = list(/obj/item/pipe_dispenser)

/datum/export/singulo //failsafe in case someone decides to ship a live singularity to CentCom without the corresponding bounty
	cost = 1
	message = "szt. – osobliwość"
	export_types = list(/obj/anomaly/singularity)
	include_subtypes = FALSE

/datum/export/singulo/total_printout(datum/export_report/ex, notes = TRUE)
	. = ..()
	if(. && notes)
		. += " BŁĄD: wykryto nieprawidłowy obiekt."

/datum/export/singulo/tesla //see above
	message = "szt. – kula energii"
	export_types = list(/obj/anomaly/energy_ball)

/datum/export/singulo/tesla/total_printout(datum/export_report/ex, notes = TRUE)
	. = ..()
	if(. && notes)
		. += " BŁĄD: wykryto nieplanowaną dostawę kuli energii."

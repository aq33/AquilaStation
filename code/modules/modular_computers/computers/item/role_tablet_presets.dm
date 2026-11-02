/obj/item/modular_computer/tablet/pda/clown
	name = "PDA klauna"
	desc = "Przenośny minikomputer, wyprodukowany przez Thinktronic Systems, LTD. Powierzchnia została pokryta teflonem i resztkami bananów."
	note = "Honk!"
	default_disk = /obj/item/computer_hardware/hard_drive/role/virus/clown
	icon_state = "pda-clown"
	insert_type = /obj/item/toy/crayon/rainbow
	/// List of victims (of a very funny joke, that everyone loves!). Stores references to mobs.
	var/list/slip_victims = list()
	init_ringtone = "honk"
	device_theme = THEME_NTOS_CLOWN_PINK // Give the clown the best theme
	ignore_theme_pref = TRUE

/obj/item/modular_computer/tablet/pda/clown/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, 7 SECONDS, NO_SLIP_WHEN_WALKING, CALLBACK(src, PROC_REF(AfterSlip)), 5 SECONDS, _force_drop = TRUE) //NSV13 - added accidents

/obj/item/modular_computer/tablet/pda/clown/proc/AfterSlip(mob/living/carbon/human/M)
	if (istype(M) && (M.real_name != saved_identification))
		slip_victims |= REF(M)
		var/obj/item/computer_hardware/hard_drive/role/virus/clown/cart = all_components[MC_HDD_JOB]
		if(istype(cart) && cart.charges < 5)
			cart.charges++
			playsound(src,'sound/machines/ping.ogg',30,TRUE)

/obj/item/modular_computer/tablet/pda/mime
	name = "PDA mima"
	desc = "Przenośny minikomputer, wyprodukowany przez Thinktronic Systems, LTD. Zmodyfikowane z myślą o ślubowaniu milczenia."
	default_disk = /obj/item/computer_hardware/hard_drive/role/virus/mime
	insert_type = /obj/item/toy/crayon/mime
	init_ringer_on = FALSE
	init_ringtone = "silence"

/obj/item/modular_computer/tablet/pda/mime/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/hdd = all_components[MC_HDD]

	if(hdd)
		for(var/datum/computer_file/program/messenger/msg in hdd.stored_files)
			msg.mime_mode = TRUE
			msg.allow_emojis = TRUE

/obj/item/modular_computer/tablet/pda/assistant
	name = "PDA majtka"
	icon_state = "pda-assistant"

/obj/item/modular_computer/tablet/pda/medical
	name = "PDA lekarza"
	default_disk = /obj/item/computer_hardware/hard_drive/role/medical
	icon_state = "pda-medical"

/obj/item/modular_computer/tablet/pda/paramedic
	name = "PDA ratownika medycznego"
	default_disk = /obj/item/computer_hardware/hard_drive/role/medical
	icon_state = "pda-paramedical"

/obj/item/modular_computer/tablet/pda/virologist
	name = "PDA wirologa"
	default_disk = /obj/item/computer_hardware/hard_drive/role/medical
	icon_state = "pda-virology"

/obj/item/modular_computer/tablet/pda/station_engineer
	name = "PDA inżyniera"
	default_disk = /obj/item/computer_hardware/hard_drive/role/engineering
	icon_state = "pda-engineer"

/obj/item/modular_computer/tablet/pda/security
	name = "PDA policjanta"
	default_disk = /obj/item/computer_hardware/hard_drive/role/security
	icon_state = "pda-security"

/obj/item/modular_computer/tablet/pda/deputy
	name = "PDA aspiranta"
	default_disk = /obj/item/computer_hardware/hard_drive/role/security
	icon_state = "pda-deputy"

/obj/item/modular_computer/tablet/pda/brig_physician
	name = "PDA lekarza więziennego"
	default_disk = /obj/item/computer_hardware/hard_drive/role/brig_physician
	icon_state = "pda-brigphys"


/obj/item/modular_computer/tablet/pda/detective
	name = "PDA detektywa"
	default_disk = /obj/item/computer_hardware/hard_drive/role/detective
	icon_state = "pda-detective"

/obj/item/modular_computer/tablet/pda/warden
	name = "PDA naczelnika"
	default_disk = /obj/item/computer_hardware/hard_drive/role/security
	icon_state = "pda-warden"

/obj/item/modular_computer/tablet/pda/janitor
	name = "PDA woźnego"
	default_disk = /obj/item/computer_hardware/hard_drive/role/janitor
	icon_state = "pda-janitor"
	init_ringtone = "slip"

/obj/item/modular_computer/tablet/pda/science
	name = "PDA naukowca"
	default_disk = /obj/item/computer_hardware/hard_drive/role/signal/toxins
	icon_state = "pda-science"
	init_ringtone = "boom"

/obj/item/modular_computer/tablet/pda/science/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/radio_card)

/obj/item/modular_computer/tablet/pda/service
	name = "PDA obsługi"
	icon_state = "pda-service"

/obj/item/modular_computer/tablet/pda/heads
	default_disk = /obj/item/computer_hardware/hard_drive/role/head
	icon_state = "pda-heads"

/obj/item/modular_computer/tablet/pda/heads/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/card_slot/secondary)

/obj/item/modular_computer/tablet/pda/heads/head_of_personnel
	name = "PDA starszego oficera"
	default_disk = /obj/item/computer_hardware/hard_drive/role/hop
	icon_state = "pda-hop"

/obj/item/modular_computer/tablet/pda/heads/head_of_personnel/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/pda/heads/head_of_security
	name = "PDA komendanta"
	default_disk = /obj/item/computer_hardware/hard_drive/role/hos
	icon_state = "pda-hos"

/obj/item/modular_computer/tablet/pda/heads/chief_engineer
	name = "PDA głównego inżyniera"
	default_disk = /obj/item/computer_hardware/hard_drive/role/ce
	icon_state = "pda-ce"

/obj/item/modular_computer/tablet/pda/heads/chief_medical_officer
	name = "PDA ordynatora"
	default_disk = /obj/item/computer_hardware/hard_drive/role/cmo
	icon_state = "pda-cmo"

/obj/item/modular_computer/tablet/pda/heads/research_director
	name = "PDA dyrektora naukowego"
	default_disk = /obj/item/computer_hardware/hard_drive/role/rd
	insert_type = /obj/item/pen/fountain
	icon_state = "pda-rd"

/obj/item/modular_computer/tablet/pda/heads/research_director/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/radio_card)

/obj/item/modular_computer/tablet/pda/heads/captain
	name = "PDA kapitana"
	desc = "Przenośny minikomputer, wyprodukowany przez Thinktronic Systems, LTD. Wnętrze zostało wzmocnione, przez co jest twardsze niż zwykle."
	default_disk = /obj/item/computer_hardware/hard_drive/role/captain
	insert_type = /obj/item/pen/fountain/captain
	icon_state = "pda-captain"
	detonatable = FALSE

/obj/item/modular_computer/tablet/pda/cargo_technician
	name = "PDA magazyniera"
	default_disk = /obj/item/computer_hardware/hard_drive/role/cargo_technician
	icon_state = "pda-cargo"

/obj/item/modular_computer/tablet/pda/cargo_technician/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/pda/quartermaster
	name = "PDA kwatermistrza"
	default_disk = /obj/item/computer_hardware/hard_drive/role/quartermaster
	insert_type = /obj/item/pen/fountain
	icon_state = "pda-qm"

/obj/item/modular_computer/tablet/pda/quartermaster/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/pda/shaft_miner
	name = "PDA górnika"
	icon_state = "pda-miner"

/obj/item/modular_computer/tablet/pda/exploration_crew
	name = "PDA odkrywcy"
	icon_state = "pda-exploration"

/obj/item/modular_computer/tablet/pda/syndicate
	name = "wojskowe PDA"
	desc = "Przenośny minikomputer, wyprodukowany przez Thinktronic Systems, LTD. Jest to model z serii WGW-XL-NTOS."
	note = "Gratulacje, twój -uszkodzone- wybrał osobisty asystent cyfrowy Thinktronic 5290 WGW-XL-NTOS!"
	default_disk = /obj/item/computer_hardware/hard_drive/role/virus/syndicate/military
	saved_identification = "John Doe"
	saved_job = "Obywatel"
	icon_state = "pda-syndi"
	messenger_invisible = TRUE
	detonatable = FALSE
	device_theme = THEME_SYNDICATE
	theme_locked = TRUE

/obj/item/modular_computer/tablet/pda/syndicate/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/network_card/network_card = all_components[MC_NET]
	if(istype(network_card))
		forget_component(network_card)
		install_component(new /obj/item/computer_hardware/network_card/advanced/norelay)

/obj/item/modular_computer/tablet/pda/chaplain
	name = "PDA kapłana"
	icon_state = "pda-chaplain"
	init_ringtone = "holy"

/obj/item/modular_computer/tablet/pda/lawyer
	name = "PDA prawnika"
	default_disk = /obj/item/computer_hardware/hard_drive/role/lawyer
	insert_type = /obj/item/pen/fountain
	icon_state = "pda-lawyer"
	init_ringtone = "objection"

/obj/item/modular_computer/tablet/pda/roboticist
	name = "PDA robotyka"
	default_disk = /obj/item/computer_hardware/hard_drive/role/roboticist
	icon_state = "pda-roboticist"

/obj/item/modular_computer/tablet/pda/curator
	name = "PDA bibliotekarza"
	desc = "Przenośny minikomputer, wyprodukowany przez Thinktronic Systems, LTD. Jest to model WGW-11 z serii e-reader."
	note = "Gratulacje, wasza stacja wybrała czytnik e-booków i osobisty asystent cyfrowy Thinktronic 5290 WGW-11-NTOS!"
	default_disk = /obj/item/computer_hardware/hard_drive/role/curator
	icon_state = "pda-library"
	insert_type = /obj/item/pen/fountain
	init_ringtone = "silence"
	init_ringer_on = FALSE

/obj/item/modular_computer/tablet/pda/clear
	name = "przezroczyste PDA"
	desc = "Przenośny minikomputer, wyprodukowany przez Thinktronic Systems, LTD. Specjalna edycja, z przezroczystą obudową."
	note = "Gratulacje, wybrałeś osobisty asystent cyfrowy Thinktronic 5230-NTOS Deluxe Special Max Turbo Limited Edition!"
	icon_state = "pda-clear"

/obj/item/modular_computer/tablet/pda/cook
	name = "PDA kucharza"
	icon_state = "pda-cook"

/obj/item/modular_computer/tablet/pda/bartender
	name = "PDA barmana"
	insert_type = /obj/item/pen/fountain
	icon_state = "pda-bartender"

/obj/item/modular_computer/tablet/pda/atmospheric_technician
	name = "PDA technika atmosferyki"
	default_disk = /obj/item/computer_hardware/hard_drive/role/atmos
	icon_state = "pda-atmos"

/obj/item/modular_computer/tablet/pda/chemist
	name = "PDA chemika"
	default_disk = /obj/item/computer_hardware/hard_drive/role/chemistry
	icon_state = "pda-chemistry"

/obj/item/modular_computer/tablet/pda/geneticist
	name = "PDA genetyka"
	default_disk = /obj/item/computer_hardware/hard_drive/role/medical
	icon_state = "pda-genetics"

/obj/item/modular_computer/tablet/pda/vip
	name = "eleganckie PDA"
	desc = "Przenośny minikomputer, wyprodukowany przez Thinktronic Systems, LTD. To pozłacany model z serii 5230-NTOS LRP, zapewne dość drogi."
	note = "Gratulacje, wybrałeś osobisty asystent cyfrowy Thinktronic 5230-NTOS LRP Golden Edition!"
	default_disk = /obj/item/computer_hardware/hard_drive/role/vip
	insert_type = /obj/item/pen/fountain
	icon_state = "pda-gold"
	init_ringtone = "brzdęk-BRZDĘK"

/obj/item/modular_computer/tablet/pda/unlicensed
	name = "nielicencjonowane PDA"
	desc = "Tandetna podróbka przenośnego minikomputera Thinktronic Systems, LTD. W komplecie scrackowany system operacyjny."
	note = "Błąd: wykryto nielicencjonowane oprogramowanie. Skontaktuj się z przełożonym."
	default_disk = /obj/item/computer_hardware/hard_drive/role/unlicensed
	icon_state = "pda-knockoff"

// NSV13 - PDA Variants
/obj/item/modular_computer/tablet/pda/botanist
	name = "PDA botanika"
	icon_state = "pda-hydro"

/obj/item/modular_computer/tablet/pda/munition
	name = "PDA technika amunicyjnego"
	icon_state = "pda-munition"

/obj/item/modular_computer/tablet/pda/heads/maa
	name = "PDA mistrza broni"
	icon_state = "pda-maa"

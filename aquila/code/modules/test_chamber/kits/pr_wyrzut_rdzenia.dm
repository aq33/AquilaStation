// Wyrzut rdzenia reaktora (plan maszynowni, etap E9)

/datum/test_chamber_kit/pr_wyrzut_rdzenia
	name = "PR: wyrzut rdzenia reaktora"
	pr = "aq33/AquilaStation#0"
	description = "Napęd burzowy z konsolą, RBMK z konsolą prętów sterujących i odłamek supermaterii z konsolą inżynieryjną (program Monitorowanie supermaterii) są połączone. \
	1) Bez karty (albo z kartą inżyniera) przycisk Wyrzut rdzenia w konsoli ma odmówić. Załóż kartę głównego inżyniera z zestawu. \
	2) Konsola napędu burzowego: Wyrzut rdzenia → potwierdź → ogłoszenie i 30 s odliczania w oknie. Przerwij odliczanie: ogłoszenie o przerwaniu, reaktor bez zmian. \
	3) Uruchom wyrzut ponownie i odczekaj: reaktor przechodzi w stan Brakuje rdzenia reaktora, pręty sterujące znikają. Włóż rdzeń z zestawu: reaktor wraca do stanu wyłączonego. \
	4) Włóż do RBMK pręty paliwowe i zrób wyrzut z konsoli prętów sterujących: pręty znikają, reaktor gaśnie, nowe pręty można włożyć od razu. \
	5) Konsola inżynieryjna → Monitorowanie supermaterii → wybierz odłamek → Wyrzut rdzenia: po 30 s odłamek znika. \
	6) Na okręcie (nie w komorze, ta nie leży na overmapie): po wyrzucie za rufą na overmapie dryfuje pomarańczowy rdzeń i wybucha po 30–60 s, raniąc okręty w promieniu 2 pól. \
	7) Cargo: skrzynia z prętami paliwowymi RBMK (15 000) obok rdzenia napędu burzowego i odłamka supermaterii. \
	8) Przełącz język gry na angielski: przyciski i ogłoszenia mają być po angielsku."
	items = list(
		/obj/machinery/atmospherics/components/binary/stormdrive_reactor = 1,
		/obj/machinery/computer/ship/reactor_control_computer = 1,
		/obj/item/stormdrive_core = 1,
		/obj/machinery/atmospherics/components/trinary/nuclear_reactor = 1,
		/obj/machinery/computer/reactor/control_rods = 1,
		/obj/item/fuel_rod = 2,
		/obj/machinery/power/supermatter_crystal/shard = 1,
		/obj/machinery/modular_computer/console/preset/engineering = 1,
		/obj/item/card/id/job/chief_engineer = 1,
	)

/datum/test_chamber_kit/pr_wyrzut_rdzenia/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/obj/machinery/atmospherics/components/binary/stormdrive_reactor/stormdrive = locate() in spawned
	var/obj/machinery/computer/ship/reactor_control_computer/stormdrive_console = locate() in spawned
	if(stormdrive && stormdrive_console)
		stormdrive_console.reactor = stormdrive
		stormdrive.control_rods += new /obj/item/control_rod(stormdrive)
		stormdrive.handle_control_rod_efficiency()
		stormdrive.handle_control_rod_integrity()
	var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/rbmk = locate() in spawned
	var/obj/machinery/computer/reactor/control_rods/rbmk_console = locate() in spawned
	if(rbmk && rbmk_console)
		rbmk_console.reactor = rbmk

/datum/test_chamber_kit/pr_monke_cybernetyka
	name = "Cybernetyka z Monkestation"
	pr = "aq33/AquilaStation#TBD"
	description = "Autochirurgi z parami wszczepiają oba implanty naraz (nogi, Strong-Arm, ostrza). Pusty autochirurg przyjmuje luźne implanty: \
		włóż implant, użyj w ręce. Śrubokręt na implancie zmienia stronę (ręka/noga). \
		Nogi: ślizg (wchodzenie na stół ~3x szybciej), BU-TAM (popchnięcie tylko męczy), wiązadła (freerunning), \
		P.R.Y.Z.H.O.K. (tryb rzutu + klik pustą ręką = szarża), chemplanty odpalają się poniżej 40 zdrowia. \
		Ręce: zestawy kuchenny, detektywa, ratownika, atmos, fryzjera, naprawczy, oficerski, wiertła (Alt+klik kręci); \
		ostrza C.H.R.O.M.A.T.A. tną oboma naraz i w trybie podważania otwierają zasilone drzwi, S.A.Y.A. ma postawę obronną (użyj w ręce), \
		A.R.A.S.A.K.A. doskakuje do celu 3 kratki dalej; Strong-Arm w combat mode odrzuca cel pięścią, para podważa drzwi pustą ręką. \
		Klatka: knockout (przycisk akcji), R.A.G.E. (maska i zbiornik przyrastają), C.C.M.S. (dwie bronie w combat mode). \
		Oczy: HUD naukowy. Organy w nogach wkłada też operacja „organ manipulation” na nodze. \
		Czarny rynek: kategoria „Implanty z drugiej ręki”. R&D: węzły „Zatwierdzone zestawy implantów zawodowych” i „Zatwierdzone implanty ochrony”."
	items = list(
		/obj/item/autosurgeon = 1,
		/obj/item/screwdriver = 1,
		/obj/item/autosurgeon/cyber_test/table_glider = 1,
		/obj/item/autosurgeon/cyber_test/shove_resist = 1,
		/obj/item/autosurgeon/cyber_test/sprinter = 1,
		/obj/item/autosurgeon/cyber_test/accelerator = 1,
		/obj/item/autosurgeon/cyber_test/strongarm = 1,
		/obj/item/autosurgeon/cyber_test/mantis = 1,
		/obj/item/autosurgeon/cyber_test/mantis_shield = 1,
		/obj/item/autosurgeon/cyber_test/mantis_syndie = 1,
		/obj/item/organ/cyberimp/leg/chemplant/emergency = 1,
		/obj/item/organ/cyberimp/leg/chemplant/drugs = 1,
		/obj/item/organ/cyberimp/arm/cook = 1,
		/obj/item/organ/cyberimp/arm/detective = 1,
		/obj/item/organ/cyberimp/arm/paramedic = 1,
		/obj/item/organ/cyberimp/arm/atmospherics = 1,
		/obj/item/organ/cyberimp/arm/barber = 1,
		/obj/item/organ/cyberimp/arm/synth_repair = 1,
		/obj/item/organ/cyberimp/arm/officer = 1,
		/obj/item/organ/cyberimp/arm/mining_drill = 1,
		/obj/item/organ/cyberimp/arm/mining_drill/diamond = 1,
		/obj/item/organ/cyberimp/arm/razorwire = 1,
		/obj/item/organ/cyberimp/arm/cooler = 1,
		/obj/item/organ/cyberimp/arm/cooler/heater = 1,
		/obj/item/organ/cyberimp/chest/spinal/knockout = 1,
		/obj/item/organ/cyberimp/chest/spinal/chemvat = 1,
		/obj/item/organ/cyberimp/chest/spinal/dualwield = 1,
		/obj/item/organ/cyberimp/chest/spinal/dualwield/refurbished = 1,
		/obj/item/organ/cyberimp/eyes/hud/science = 1,
		/obj/item/storage/briefcase/syndie_mantis = 1,
		/obj/structure/table = 1,
		/mob/living/carbon/human = 1,
	)

/// Autochirurg wielokrotny z parą implantów do komory testowej
/obj/item/autosurgeon/cyber_test
	name = "autochirurg testowy"

/obj/item/autosurgeon/cyber_test/table_glider
	name = "autochirurg testowy (ślizg po stołach, obie nogi)"
	starting_organ = list(/obj/item/organ/cyberimp/leg/trait/table_glider, /obj/item/organ/cyberimp/leg/trait/table_glider/l)

/obj/item/autosurgeon/cyber_test/shove_resist
	name = "autochirurg testowy (BU-TAM, obie nogi)"
	starting_organ = list(/obj/item/organ/cyberimp/leg/trait/shove_resist, /obj/item/organ/cyberimp/leg/trait/shove_resist/l)

/obj/item/autosurgeon/cyber_test/sprinter
	name = "autochirurg testowy (wiązadła wakuolowe, obie nogi)"
	starting_organ = list(/obj/item/organ/cyberimp/leg/trait/sprinter, /obj/item/organ/cyberimp/leg/trait/sprinter/l)

/obj/item/autosurgeon/cyber_test/accelerator
	name = "autochirurg testowy (P.R.Y.Z.H.O.K., obie nogi)"
	starting_organ = list(/obj/item/organ/cyberimp/leg/accelerator, /obj/item/organ/cyberimp/leg/accelerator/l)

/obj/item/autosurgeon/cyber_test/strongarm
	name = "autochirurg testowy (Strong-Arm, obie ręce)"
	starting_organ = list(/obj/item/organ/cyberimp/arm/strongarm, /obj/item/organ/cyberimp/arm/strongarm/l)

/obj/item/autosurgeon/cyber_test/mantis
	name = "autochirurg testowy (C.H.R.O.M.A.T.A., obie ręce)"
	starting_organ = list(/obj/item/organ/cyberimp/arm/mantis, /obj/item/organ/cyberimp/arm/mantis/l)

/obj/item/autosurgeon/cyber_test/mantis_shield
	name = "autochirurg testowy (S.A.Y.A., obie ręce)"
	starting_organ = list(/obj/item/organ/cyberimp/arm/mantis/shield, /obj/item/organ/cyberimp/arm/mantis/shield/l)

/obj/item/autosurgeon/cyber_test/mantis_syndie
	name = "autochirurg testowy (A.R.A.S.A.K.A., obie ręce)"
	starting_organ = list(/obj/item/organ/cyberimp/arm/syndie_mantis, /obj/item/organ/cyberimp/arm/syndie_mantis/l)

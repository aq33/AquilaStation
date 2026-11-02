/datum/test_chamber_kit/pr_monke_cybernetyka
	name = "Cybernetyka z Monkestation"
	pr = "aq33/AquilaStation#488"
	description = "Zestaw: autochirurgi z parami implantów (nogi, Strong-Arm, ostrza), luźne implanty, zasilona śluza, stół, dwóch ludzi (jeden na implanty, drugi jako cel). Operację na nodze wykonaj w kąciku chirurgicznym komory. Wszczep implant: pusty autochirurg przyjmuje luźny implant (włóż implant, użyj w ręce); śrubokręt na implancie zmienia stronę (ręka/noga). \
	1) Nogi, ślizg po stołach: wszczep parę, wejdź na stół → oczekiwane: wejście zajmuje ok. 3x krócej niż bez implantu (porównaj bez implantu); BU-TAM: popchnięcie cię tylko męczy, nie przewraca (negatyw: nie leżysz po popchnięciu); wiązadła: freerunning; P.R.Y.Z.H.O.K.: tryb rzutu, klik pustą ręką = szarża. \
	2) Chemplanty (emergency/drugs): zbij zdrowie poniżej 40 → oczekiwane: implant sam odpala wtrysk; przy zdrowiu powyżej 40 nic się nie dzieje (negatyw). \
	3) Ręce, zestawy: kuchenny, detektywa, ratownika, atmos, fryzjera, naprawczy, oficerski, wiertła (Alt+klik kręci) → oczekiwane: narzędzie pojawia się w ręce po użyciu implantu i chowa po ponownym użyciu. \
	4) Ostrza C.H.R.O.M.A.T.A. (para): tną oboma naraz i w trybie podważania otwierają zasilone drzwi (zestaw ma śluzę) → oczekiwane: drzwi się otwierają. S.A.Y.A.: użyj w ręce → postawa obronna. A.R.A.S.A.K.A. (teczka): doskakuje do celu 3 kratki dalej. \
	5) Strong-Arm: w combat mode uderz drugiego człowieka → oczekiwane: cel zostaje odrzucony; para Strong-Arm podważa drzwi pustą ręką. Negatyw: Strong-Arm poza combat mode zwykły cios bez odrzutu. \
	6) Klatka: knockout (przycisk akcji) usypia noszącego, R.A.G.E. (maska i zbiornik przyrastają), C.C.M.S. pozwala trzymać dwie bronie w combat mode. S.M.A.R.T.: weź pistolet lub laser w rękę z implantem → oczekiwane: nad ręką licznik strzałów broni. Oczy: HUD naukowy pokazuje skany. \
	7) Organy w nogach: operacja „organ manipulation” na nodze (kącik chirurgiczny) wkłada implant tak samo jak autochirurg → oczekiwane: implant w nodze działa jak po autochirurgu. \
	8) Poza komorą (opcjonalnie, na stacji): czarny rynek (kategoria „Implanty z drugiej ręki”) i węzły R&D „Zatwierdzone zestawy implantów zawodowych” oraz „Zatwierdzone implanty ochrony” nie da się sprawdzić w komorze."
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
		/obj/item/organ/cyberimp/arm/ammo_counter = 1,
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/gun/energy/laser = 1,
		/obj/item/organ/cyberimp/arm/cooler = 1,
		/obj/item/organ/cyberimp/arm/cooler/heater = 1,
		/obj/item/organ/cyberimp/chest/spinal/knockout = 1,
		/obj/item/organ/cyberimp/chest/spinal/chemvat = 1,
		/obj/item/organ/cyberimp/chest/spinal/dualwield = 1,
		/obj/item/organ/cyberimp/chest/spinal/dualwield/refurbished = 1,
		/obj/item/organ/cyberimp/eyes/hud/science = 1,
		/obj/item/storage/briefcase/syndie_mantis = 1,
		/obj/structure/table = 1,
		/mob/living/carbon/human = 2,
		/obj/machinery/door/airlock = 1,
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

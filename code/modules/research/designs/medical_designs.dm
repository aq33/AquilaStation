/////////////////////////////////////////
////////////Medical Tools////////////////
/////////////////////////////////////////

/datum/design/mmi
	name = "Interfejs człowiek-maszyna"
	desc = "Mdły skrót Wojownika, MMI, skrywa prawdziwą grozę tej potworności."
	id = "mmi"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500)
	construction_time = 75
	build_path = /obj/item/mmi
	category = list("Control Interfaces", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/posibrain
	name = "Mózg pozytroniczny"
	desc = "Najnowsze osiągnięcie w dziedzinie sztucznej inteligencji."
	id = "mmi_posi"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 1700, /datum/material/glass = 1350, /datum/material/gold = 500, /datum/material/copper = 500) //Gold, because SWAG.
	construction_time = 75
	build_path = /obj/item/mmi/posibrain
	category = list("Control Interfaces", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/bluespacebeaker
	name = "Zlewka bluespace"
	desc = "Zlewka bluespace zasilana eksperymentalną technologią bluespace oraz Pierwiastkiem Kubańskim połączonym ze Związkiem Pete'a. Mieści do 300 j."
	id = "bluespacebeaker"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 5000, /datum/material/plasma = 3000, /datum/material/diamond = 1000, /datum/material/bluespace = 1000)
	build_path = /obj/item/reagent_containers/glass/beaker/bluespace
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/noreactbeaker
	name = "Zlewka kriostatyczna"
	desc = "Zlewka kriostatyczna, w której chemikalia można przechowywać bez reakcji. Mieści do 50 j."
	id = "splitbeaker"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000)
	build_path = /obj/item/reagent_containers/glass/beaker/noreact
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/xlarge_beaker
	name = "Bardzo duża zlewka"
	id = "xlarge_beaker"
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	materials = list(/datum/material/glass = 2500, /datum/material/plastic = 3000)
	build_path = /obj/item/reagent_containers/glass/beaker/plastic
	category = list("Medical Designs")

/datum/design/meta_beaker
	name = "Zlewka z metamateriału"
	id = "meta_beaker"
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	materials = list(/datum/material/glass = 2500, /datum/material/plastic = 3000, /datum/material/gold = 1000, /datum/material/titanium = 1000)
	build_path = /obj/item/reagent_containers/glass/beaker/meta
	category = list("Medical Designs")

/datum/design/bluespacesyringe
	name = "Strzykawka bluespace"
	desc = "Zaawansowana strzykawka, która mieści 60 j. chemikaliów."
	id = "bluespacesyringe"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 2000, /datum/material/plasma = 1000, /datum/material/diamond = 1000, /datum/material/bluespace = 500)
	build_path = /obj/item/reagent_containers/syringe/bluespace
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/cloning_disk
	name = "Dysk danych klonowania"
	desc = "Wytwarza dodatkowe dyski do przechowywania danych genetycznych."
	id = "cloning_disk"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100, /datum/material/silver = 50, /datum/material/copper = 50)
	build_path = /obj/item/disk/data
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/noreactsyringe
	name = "Kriostrzykawka"
	desc = "Zaawansowana strzykawka, która powstrzymuje reakcje odczynników w środku. Mieści do 20 j."
	id = "noreactsyringe"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 2000, /datum/material/gold = 1000)
	build_path = /obj/item/reagent_containers/syringe/cryo
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/piercesyringe
	name = "Strzykawka przebijająca"
	desc = "Strzykawka z diamentowym czubkiem, która przebija pancerz, gdy zostanie wystrzelona z dużą prędkością. Mieści do 10 j."
	id = "piercesyringe"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 2000, /datum/material/diamond = 1000)
	build_path = /obj/item/reagent_containers/syringe/piercing
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/bluespacebodybag
	name = "Worek na zwłoki bluespace"
	desc = "Worek na zwłoki bluespace zasilany eksperymentalną technologią bluespace. Mieści mnóstwo ciał, a nawet największe stworzenia."
	id = "bluespacebodybag"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/plasma = 2000, /datum/material/diamond = 500, /datum/material/bluespace = 500)
	build_path = /obj/item/bodybag/bluespace
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/plasmarefiller
	name = "Wkład gaśniczy do kombinezonu plazmamana"
	desc = "Wkład uzupełniający do automatycznej gaśnicy w kombinezonach plazmaludzi."
	id = "plasmarefiller" //Why did this have no plasmatech
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/plasma = 1000)
	build_path = /obj/item/extinguisher_refill
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/crewpinpointer
	name = "Pinpointer załogi"
	desc = "Pozwala śledzić położenie osoby, jeśli jej czujniki kombinezonu są ustawione na śledzenie."
	id = "crewpinpointer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 1500, /datum/material/gold = 200, /datum/material/copper = 200)
	build_path = /obj/item/pinpointer/crew
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/defibrillator
	name = "Defibrylator"
	desc = "Przenośny defibrylator do reanimacji niedawno zmarłych członków załogi."
	id = "defibrillator"
	build_type = PROTOLATHE
	build_path = /obj/item/defibrillator
	materials = list(/datum/material/iron = 8000, /datum/material/glass = 4000, /datum/material/silver = 3000, /datum/material/gold = 1500)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/defibrillator_mount
	name = "Uchwyt ścienny defibrylatora"
	desc = "Kompletna rama ścienna na defibrylatory z zaciskami blokowanymi identyfikatorem i kablami ładującymi."
	id = "defibmount"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	build_path = /obj/item/wallframe/defib_mount
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/defibrillator_compact
	name = "Kompaktowy defibrylator"
	desc = "Kompaktowy defibrylator, który można nosić przy pasie."
	id = "defibrillator_compact"
	build_type = PROTOLATHE
	build_path = /obj/item/defibrillator/compact
	materials = list(/datum/material/iron = 16000, /datum/material/glass = 8000, /datum/material/silver = 6000, /datum/material/gold = 3000)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/genescanner
	name = "Analizator sekwencji genetycznej"
	desc = "Poręczny ręczny analizator do szybkiego określania mutacji i zbierania pełnej sekwencji."
	id = "genescanner"
	build_path = /obj/item/sequence_scanner
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/healthanalyzer_advanced
	name = "Zaawansowany analizator zdrowia"
	desc = "Ręczny skaner ciała, który z dużą dokładnością rozróżnia funkcje życiowe badanego."
	id = "healthanalyzer_advanced"
	build_path = /obj/item/healthanalyzer/advanced
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2500, /datum/material/silver = 2000, /datum/material/gold = 1500)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/medspray
	name = "Spray medyczny"
	desc = "Butelka ze sprayem medycznym do precyzyjnej aplikacji, z odkręcaną nakrętką."
	id = "medspray"
	build_path = /obj/item/reagent_containers/medspray
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 500)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/medipen_epi
	name = "Medipen z epinefryną"
	desc = "Szybki i bezpieczny sposób na stabilizację pacjentów w stanie krytycznym dla personelu bez zaawansowanej wiedzy medycznej. Zawiera silny środek konserwujący, który opóźnia rozkład, gdy poda się go zwłokom."
	id = "medipen_epi"
	build_path = /obj/item/reagent_containers/hypospray/medipen
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 200)
	reagents_list = list(/datum/reagent/medicine/epinephrine = 10, /datum/reagent/toxin/formaldehyde = 3)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/medipen_dex
	name = "Medipen z deksaliną"
	desc = "Autoinjektor z deksaliną do szybkiego leczenia niedotlenienia."
	id = "medipen_dex"
	build_path = /obj/item/reagent_containers/hypospray/medipen/dexalin
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 200)
	reagents_list = list(/datum/reagent/medicine/dexalin = 10)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/medipen_atropine
	name = "Medipen z atropiną"
	desc = "Szybki sposób na uratowanie kogoś ze stanu krytycznego!"
	id = "medipen_atropine"
	build_path = /obj/item/reagent_containers/hypospray/medipen/atropine
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 200)
	reagents_list = list(/datum/reagent/medicine/atropine = 10)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/surgical_drapes
	name = "Serweta chirurgiczna"
	id = "surgical_drapes"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 2000)
	build_path = /obj/item/surgical_drapes
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/laserscalpel
	name = "Skalpel laserowy"
	desc = "Skalpel laserowy do precyzyjnego cięcia."
	id = "laserscalpel"
	build_path = /obj/item/scalpel/advanced
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 6000, /datum/material/glass = 1500, /datum/material/silver = 2000, /datum/material/gold = 1500, /datum/material/diamond = 200, /datum/material/titanium = 4000)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/mechanicalpinches
	name = "Mechaniczne szczypce"
	desc = "Te szczypce mogą służyć jako retraktor albo hemostat."
	id = "mechanicalpinches"
	build_path = /obj/item/retractor/advanced
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 12000, /datum/material/glass = 4000, /datum/material/silver = 4000, /datum/material/titanium = 5000)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/searingtool
	name = "Narzędzie przyżegające"
	desc = "Służy do zespalania tkanek."
	id = "searingtool"
	build_path = /obj/item/surgicaldrill/advanced
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 2000, /datum/material/plasma = 2000, /datum/material/uranium = 3000, /datum/material/titanium = 3000)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/////////////////////////////////////////
//////////Cybernetic Implants////////////
/////////////////////////////////////////

/datum/design/cyberimp_welding
	name = "Osłonięte robotyczne oczy"
	desc = "Te reaktywne mikroosłony chronią cię przed spawarkami i flashami, nie zasłaniając widoku."
	id = "ci-welding"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 600, /datum/material/glass = 400, /datum/material/copper = 200)
	build_path = /obj/item/organ/eyes/robotic/shield
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_gloweyes
	name = "Oczy luminescencyjne"
	desc = "Para cybernetycznych oczu, które emitują wielobarwne światło."
	id = "ci-gloweyes"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 600, /datum/material/glass = 1000, /datum/material/copper = 200)
	build_path = /obj/item/organ/eyes/robotic/glow
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_breather
	name = "Implant rurki oddechowej"
	desc = "Ten prosty implant dodaje na plecach złącze butli, dzięki czemu możesz oddychać z butli bez maski i nie da się cię udusić."
	id = "ci-breather"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 35
	materials = list(/datum/material/iron = 600, /datum/material/glass = 250, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/mouth/breathing_tube
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_surgical
	name = "Implant z zestawem chirurgicznym"
	desc = "Zestaw narzędzi chirurgicznych ukryty za panelem w ręce użytkownika."
	id = "ci-surgery"
	build_type = PROTOLATHE | MECHFAB
	materials = list (/datum/material/iron = 2500, /datum/material/glass = 1500, /datum/material/silver = 1500, /datum/material/copper = 200)
	construction_time = 200
	build_path = /obj/item/organ/cyberimp/arm/surgery
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_toolset
	name = "Implant z zestawem narzędzi"
	desc = "Okrojona wersja zestawu narzędzi cyborga inżynieryjnego, przeznaczona do wszczepienia w rękę."
	id = "ci-toolset"
	build_type = PROTOLATHE | MECHFAB
	materials = list (/datum/material/iron = 2500, /datum/material/glass = 1500, /datum/material/silver = 1500, /datum/material/copper = 200)
	construction_time = 200
	build_path = /obj/item/organ/cyberimp/arm/toolset
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_botany
	name = "Botaniczny implant w ręce"
	desc = "Wszystko, czego potrzebuje botanik, w implancie przeznaczonym do wszczepienia w rękę."
	id = "ci-botany"
	build_type = MECHFAB | PROTOLATHE
	materials = list (/datum/material/iron = 3500, /datum/material/glass = 1500, /datum/material/silver = 1500, /datum/material/plastic = 2000)
	construction_time = 200
	build_path = /obj/item/organ/cyberimp/arm/botany
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_janitor
	name = "Implant z narzędziami woźnego"
	desc = "Zestaw narzędzi woźnego zamknięty w implancie przeznaczonym do wszczepienia w rękę."
	id = "ci-janitor"
	build_type = PROTOLATHE | MECHFAB
	materials = list (/datum/material/iron = 3500, /datum/material/glass = 1500, /datum/material/silver = 1500)
	construction_time = 200
	build_path = /obj/item/organ/cyberimp/arm/janitor
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_medical_hud
	name = "Implant HUD medycznego"
	desc = "Te cybernetyczne oczy wyświetlają HUD medyczny na wszystkim, co widzisz. Steruje się nimi, poruszając oczami."
	id = "ci-medhud"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 500, /datum/material/gold = 500, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/eyes/hud/medical
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_security_hud
	name = "Implant HUD ochrony"
	desc = "Te cybernetyczne oczy wyświetlają HUD ochrony na wszystkim, co widzisz. Steruje się nimi, poruszając oczami."
	id = "ci-sechud"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 750, /datum/material/gold = 750, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/eyes/hud/security
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_diagnostic_hud
	name = "Implant HUD diagnostycznego"
	desc = "Te cybernetyczne oczy wyświetlają HUD diagnostyczny na wszystkim, co widzisz. Steruje się nimi, poruszając oczami."
	id = "ci-diaghud"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 600, /datum/material/gold = 600, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/eyes/hud/diagnostic
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_xray
	name = "Oczy rentgenowskie"
	desc = "Te cybernetyczne oczy dają ci widzenie rentgenowskie. Mruganie nic nie daje."
	id = "ci-xray"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 600, /datum/material/gold = 600, /datum/material/plasma = 1000, /datum/material/uranium = 1000, /datum/material/diamond = 1000, /datum/material/bluespace = 1000, /datum/material/copper = 200)
	build_path = /obj/item/organ/eyes/robotic/xray
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_thermals
	name = "Oczy termowizyjne"
	desc = "Te cybernetyczne oczy dają ci widzenie termowizyjne. Pionowa źrenica w zestawie."
	id = "ci-thermals"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 600, /datum/material/gold = 600, /datum/material/plasma = 1000, /datum/material/diamond = 2000, /datum/material/copper = 200)
	build_path = /obj/item/organ/eyes/robotic/thermals
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_antidrop
	name = "Implant przeciw upuszczaniu"
	desc = "Ten cybernetyczny implant mózgu pozwala wymusić skurcz mięśni dłoni, żeby nie upuszczać przedmiotów. Włączasz go, poruszając uchem."
	id = "ci-antidrop"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 400, /datum/material/gold = 400, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/brain/anti_drop
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_antistun
	name = "Implant restartu OUN"
	desc = "Ten implant automatycznie przywraca ci kontrolę nad ośrodkowym układem nerwowym i skraca czas ogłuszenia."
	id = "ci-antistun"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 500, /datum/material/gold = 1000, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/brain/anti_stun
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_linkedsurgery
	name = "Implant mózgu z łączem serwera chirurgicznego"
	desc = "Implant mózgu z technologią bluespace, który pozwala przeprowadzać zaawansowane operacje dzięki serwerowi badawczemu stacji."
	id = "ci-linkedsurgery"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 1500, /datum/material/silver = 1500, /datum/material/copper = 200, /datum/material/gold = 3000, /datum/material/diamond = 1500, /datum/material/uranium = 250, /datum/material/bluespace = 2000)
	build_path = /obj/item/organ/cyberimp/brain/linkedsurgery
	category = list("Implants", "Medical Designs", "Bluespace Designs")
	dangerous_construction = TRUE
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_nutriment
	name = "Implant pompy odżywczej"
	desc = "Ten implant syntetyzuje i wpompowuje do krwiobiegu niewielką ilość składników odżywczych, gdy głodujesz."
	id = "ci-nutriment"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/gold = 500, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/chest/nutriment
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_nutriment_plus
	name = "Implant pompy odżywczej PLUS"
	desc = "Ten implant syntetyzuje i wpompowuje do krwiobiegu niewielką ilość składników odżywczych, gdy jesteś głodny."
	id = "ci-nutrimentplus"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/gold = 500, /datum/material/uranium = 750, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/chest/nutriment/plus
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_reviver
	name = "Implant reanimacyjny"
	desc = "Ten implant próbuje cię ocucić, gdy tracisz przytomność. Dla ludzi o słabym sercu!"
	id = "ci-reviver"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 800, /datum/material/glass = 800, /datum/material/gold = 300, /datum/material/uranium = 500, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/chest/reviver
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_thrusters
	name = "Wszczepialny zestaw silników manewrowych"
	desc = "Ten implant pozwala używać gazu z otoczenia albo z butli do poruszania się w strefach bez grawitacji."
	id = "ci-thrusters"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 80
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 2000, /datum/material/silver = 1000, /datum/material/diamond = 1000, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/chest/thrusters
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_hydraulic_blade
	name = "Ostrze hydrauliczne"
	desc = "Niezwykle niebezpieczne wszczepione ostrze z plastali."
	id = "hydraulic_blade"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 250
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 5000, /datum/material/silver = 10000, /datum/material/diamond = 3000, /datum/material/titanium = 8000, /datum/material/bluespace = 2000, /datum/material/plasma = 5000)
	build_path = /obj/item/organ/cyberimp/arm/hydraulic_blade
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/////////////////////////////////////////
////////////Regular Implants/////////////
/////////////////////////////////////////

/datum/design/implanter
	name = "Implanter"
	desc = "Sterylny automatyczny iniektor implantów."
	id = "implanter"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 600, /datum/material/glass = 200)
	build_path = /obj/item/implanter
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/implantcase
	name = "Etui na implant"
	desc = "Szklane etui na implant."
	id = "implantcase"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500)
	build_path = /obj/item/implantcase
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/implant_sadtrombone
	name = "Etui z implantem „Smutny puzon”"
	desc = "Sprawia, że śmierć staje się zabawna."
	id = "implant_trombone"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/bananium = 500)
	build_path = /obj/item/implantcase/sad_trombone
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ALL		//if you get bananium you get the sad trombones.

/datum/design/implant_chem
	name = "Etui z implantem chemicznym"
	desc = "Szklane etui z implantem."
	id = "implant_chem"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 700)
	build_path = /obj/item/implantcase/chem
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/implant_tracking
	name = "Etui z implantem śledzącym"
	desc = "Szklane etui z implantem."
	id = "implant_tracking"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/implantcase/tracking
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

//Cybernetic organs

/datum/design/cybernetic_liver
	name = "Cybernetyczna wątroba"
	desc = "Cybernetyczna wątroba."
	id = "cybernetic_liver"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/copper = 200)
	build_path = /obj/item/organ/liver/cybernetic
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_liver_u
	name = "Ulepszona cybernetyczna wątroba"
	desc = "Ulepszona cybernetyczna wątroba."
	id = "cybernetic_liver_u"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/copper = 200)
	build_path = /obj/item/organ/liver/cybernetic/upgraded
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_heart
	name = "Cybernetyczne serce"
	desc = "Cybernetyczne serce."
	id = "cybernetic_heart"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/copper = 200)
	build_path = /obj/item/organ/heart/cybernetic
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_heart_u
	name = "Ulepszone cybernetyczne serce"
	desc = "Ulepszone cybernetyczne serce."
	id = "cybernetic_heart_u"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/silver=500, /datum/material/copper = 300)
	build_path = /obj/item/organ/heart/cybernetic/upgraded
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_lungs
	name = "Cybernetyczne płuca"
	desc = "Para cybernetycznych płuc."
	id = "cybernetic_lungs"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/copper = 200)
	build_path = /obj/item/organ/lungs/cybernetic
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_lungs_u
	name = "Ulepszone cybernetyczne płuca"
	desc = "Para ulepszonych cybernetycznych płuc."
	id = "cybernetic_lungs_u"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/silver = 500, /datum/material/copper = 300)
	build_path = /obj/item/organ/lungs/cybernetic/upgraded
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_stomach
	name = "Cybernetyczny żołądek"
	desc = "Cybernetyczny żołądek."
	id = "cybernetic_stomach"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/copper = 200)
	build_path = /obj/item/organ/stomach/cybernetic
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_stomach_u
	name = "Ulepszony cybernetyczny żołądek"
	desc = "Ulepszony cybernetyczny żołądek."
	id = "cybernetic_stomach_u"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/silver = 500, /datum/material/copper = 300)
	build_path = /obj/item/organ/stomach/cybernetic/upgraded
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/wingpack
	name = "Cybernetyczny plecak skrzydłowy"
	desc = "Kompaktowa para mechanicznych skrzydeł, które wytwarzają ciąg z atmosfery."
	id = "wingpack"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 500
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 1000, /datum/material/uranium = 4000, /datum/material/silver = 100, /datum/material/titanium = 8000, /datum/material/plasma = 10000)
	build_path = /obj/item/organ/wings/cybernetic
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/wingpack_alien
	name = "Zaawansowany cybernetyczny plecak skrzydłowy"
	desc = "Kompaktowa para mechanicznych skrzydeł z miniaturowymi silnikami pustki. Latają w każdej atmosferze, a nawet bez niej."
	id = "wingpack_ayy"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 1000
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 1000, /datum/material/uranium = 500, /datum/material/silver = 100, /datum/material/titanium = 8000, /datum/material/bluespace = 2000, /datum/material/plasma = 5000)
	build_path = /obj/item/organ/wings/cybernetic/ayy
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/////////////////////
///Surgery Designs///
/////////////////////
/datum/design/surgery
	name = "Projekt operacji"
	desc = "co"
	id = "surgery_parent"
	research_icon = 'icons/obj/surgery.dmi'
	research_icon_state = "surgery_any"
	var/surgery

/datum/design/surgery/experimental_dissection
	name = "Eksperymentalna sekcja"
	desc = "Zabieg chirurgiczny, który dogłębnie analizuje biologię zwłok i automatycznie dodaje nowe odkrycia do bazy danych badań."
	id = "surgery_exp_dissection"
	surgery = /datum/surgery/advanced/experimental_dissection
	research_icon_state = "surgery_chest"

/datum/design/surgery/lobotomy
	name = "Lobotomia"
	desc = "Inwazyjny zabieg chirurgiczny, który gwarantuje usunięcie niemal wszystkich urazów mózgu, ale w zamian może wywołać inny, trwały uraz."
	id = "surgery_lobotomy"
	surgery = /datum/surgery/advanced/lobotomy
	research_icon_state = "surgery_head"

/datum/design/surgery/pacify
	name = "Pacyfikacja"
	desc = "Zabieg chirurgiczny, który trwale hamuje ośrodek agresji w mózgu, przez co pacjent nie chce nikogo bezpośrednio krzywdzić."
	id = "surgery_pacify"
	surgery = /datum/surgery/advanced/pacify
	research_icon_state = "surgery_head"

/datum/design/surgery/viral_bonding
	name = "Wiązanie wirusowe"
	desc = "Zabieg chirurgiczny, który wymusza symbiozę między wirusem a nosicielem. Pacjent musi dostać spacyklinę, pożywkę dla wirusów i formaldehyd."
	id = "surgery_viral_bond"
	surgery = /datum/surgery/advanced/viral_bonding
	research_icon_state = "surgery_chest"

/datum/design/surgery/healing //PLEASE ACCOUNT FOR UNIQUE HEALING BRANCHES IN THE hptech HREF (currently 2 for Brute/Burn; Combo is bonus)
	name = "Opatrywanie ran"
	desc = "Ulepszona wersja pierwotnej operacji."
	id = "surgery_healing_base" //holder because travis cries otherwise. Not used in techweb unlocks.
	research_icon_state = "surgery_chest"

/datum/design/surgery/healing/brute_upgrade
	name = "Opatrywanie ran (stłuczenia, zaaw.)"
	surgery = /datum/surgery/healing/brute/upgraded
	id = "surgery_heal_brute_upgrade"

/datum/design/surgery/healing/brute_upgrade_2
	name = "Opatrywanie ran (stłuczenia, eksp.)"
	surgery = /datum/surgery/healing/brute/upgraded/femto
	id = "surgery_heal_brute_upgrade_femto"

/datum/design/surgery/healing/burn_upgrade
	name = "Opatrywanie ran (oparzenia, zaaw.)"
	surgery = /datum/surgery/healing/burn/upgraded
	id = "surgery_heal_burn_upgrade"

/datum/design/surgery/healing/burn_upgrade_2
	name = "Opatrywanie ran (oparzenia, eksp.)"
	surgery = /datum/surgery/healing/burn/upgraded/femto
	id = "surgery_heal_burn_upgrade_femto"

/datum/design/surgery/healing/combo
	name = "Opatrywanie ran (mieszane, podst.)"
	desc = "Zabieg chirurgiczny, który leczy zarówno stłuczenia, jak i oparzenia. Skuteczność jest niższa niż w osobnych operacjach, ale zabieg trwa krócej."
	surgery = /datum/surgery/healing/combo
	id = "surgery_heal_combo"

/datum/design/surgery/healing/combo_upgrade
	name = "Opatrywanie ran (mieszane, zaaw.)"
	surgery = /datum/surgery/healing/combo/upgraded
	id = "surgery_heal_combo_upgrade"

/datum/design/surgery/healing/combo_upgrade_2
	name = "Opatrywanie ran (mieszane, eksp.)"
	desc = "Zabieg chirurgiczny, który leczy stłuczenia i oparzenia szybciej niż osobne operacje. Jest skuteczniejszy od każdej z nich."
	surgery = /datum/surgery/healing/combo/upgraded/femto
	id = "surgery_heal_combo_upgrade_femto"

/datum/design/surgery/revival
	name = "Ożywienie"
	desc = "Eksperymentalny zabieg chirurgiczny, który odbudowuje i ponownie uruchamia mózg pacjenta nawet długo po śmierci. Ciało musi wciąż być zdolne do życia."
	id = "surgery_revival"
	surgery = /datum/surgery/advanced/revival
	research_icon_state = "surgery_head"

/datum/design/surgery/brainwashing
	name = "Pranie mózgu"
	desc = "Zabieg chirurgiczny, który wszczepia rozkaz bezpośrednio do mózgu pacjenta i czyni go jego najwyższym priorytetem. Można go usunąć implantem ochrony umysłu."
	id = "surgery_brainwashing"
	surgery = /datum/surgery/advanced/brainwashing
	research_icon_state = "surgery_head"

/datum/design/surgery/nerve_splicing
	name = "Łączenie nerwów"
	desc = "Zabieg chirurgiczny, który łączy nerwy pacjenta, przez co staje się on odporniejszy na ogłuszenia."
	id = "surgery_nerve_splice"
	surgery = /datum/surgery/advanced/bioware/nerve_splicing
	research_icon_state = "surgery_chest"

/datum/design/surgery/nerve_grounding
	name = "Uziemienie nerwów"
	desc = "Zabieg chirurgiczny, po którym nerwy pacjenta działają jak pręty uziemiające i chronią go przed porażeniem prądem."
	id = "surgery_nerve_ground"
	surgery = /datum/surgery/advanced/bioware/nerve_grounding
	research_icon_state = "surgery_chest"

/datum/design/surgery/vein_threading
	name = "Przeplatanie żył"
	desc = "Zabieg chirurgiczny, który znacznie ogranicza utratę krwi w razie zranienia."
	id = "surgery_vein_thread"
	surgery = /datum/surgery/advanced/bioware/vein_threading
	research_icon_state = "surgery_chest"

/datum/design/surgery/muscled_veins
	name = "Mięśniowa błona żył"
	desc = "Zabieg chirurgiczny, który dodaje do naczyń krwionośnych umięśnioną błonę, dzięki czemu pompują krew bez serca."
	id = "surgery_muscled_veins"
	surgery = /datum/surgery/advanced/bioware/muscled_veins
	research_icon_state = "surgery_chest"

/datum/design/surgery/ligament_hook
	name = "Hak więzadłowy"
	desc = "Zabieg chirurgiczny, który przekształca połączenia między tułowiem a kończynami, dzięki czemu odcięte kończyny można przyczepić ręcznie. \
	Osłabia to jednak połączenie, więc kończyny łatwiej też odpadają."
	id = "surgery_ligament_hook"
	surgery = /datum/surgery/advanced/bioware/ligament_hook
	research_icon_state = "surgery_chest"

/datum/design/surgery/ligament_reinforcement
	name = "Wzmocnienie więzadeł"
	desc = "Zabieg chirurgiczny, który otacza połączenia między tułowiem a kończynami ochronną klatką z tkanki i kości, co zapobiega odcięciu kończyn. \
	Przez to jednak połączenia nerwowe łatwiej się przerywają, więc obrażenia łatwiej unieruchamiają kończyny."
	id = "surgery_ligament_reinforcement"
	surgery = /datum/surgery/advanced/bioware/ligament_reinforcement
	research_icon_state = "surgery_chest"

/datum/design/surgery/cortex_imprint
	name = "Odcisk kory mózgowej"
	desc = "Zabieg chirurgiczny, który przekształca korę mózgową w nadmiarowy wzorzec neuronowy, dzięki czemu mózg omija uszkodzenia wywołane drobnymi urazami mózgu."
	id = "surgery_cortex_imprint"
	surgery = /datum/surgery/advanced/bioware/cortex_imprint
	research_icon_state = "surgery_head"

/datum/design/surgery/cortex_folding
	name = "Fałdowanie kory mózgowej"
	desc = "Zabieg chirurgiczny, który układa korę mózgową w złożoną fałdę i robi miejsce na niestandardowe wzorce neuronowe."
	id = "surgery_cortex_folding"
	surgery = /datum/surgery/advanced/bioware/cortex_folding
	research_icon_state = "surgery_head"


/datum/design/surgery/necrotic_revival
	name = "Ożywienie nekrotyczne"
	desc = "Eksperymentalny zabieg chirurgiczny, który pobudza wzrost guza romerolowego w mózgu pacjenta. Wymaga proszku zombie albo rezadonu."
	id = "surgery_zombie"
	surgery = /datum/surgery/advanced/necrotic_revival
	research_icon_state = "surgery_head"

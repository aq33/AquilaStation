
/////////////////////////////////////////
/////////////////HUDs////////////////////
/////////////////////////////////////////

/datum/design/health_hud
	name = "HUD medyczny"
	desc = "Wyświetlacz przezierny, który skanuje widocznych ludzi i podaje dokładne dane o ich stanie zdrowia."
	id = "health_hud"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/copper = 200)
	build_path = /obj/item/clothing/glasses/hud/health
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/health_hud_night
	name = "Noktowizyjny HUD medyczny"
	desc = "Zaawansowany medyczny wyświetlacz przezierny, dzięki któremu lekarze znajdują pacjentów w zupełnej ciemności."
	id = "health_hud_night"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/uranium = 1000, /datum/material/silver = 350, /datum/material/copper = 300)
	build_path = /obj/item/clothing/glasses/hud/health/night
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/security_hud
	name = "HUD ochrony"
	desc = "Wyświetlacz przezierny, który skanuje widocznych ludzi i podaje dokładne dane z ich identyfikatorów."
	id = "security_hud"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/copper = 200)
	build_path = /obj/item/clothing/glasses/hud/security
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/security_hud_night
	name = "HUD ochrony z noktowizją"
	desc = "Wyświetlacz przezierny, który podaje dane z identyfikatorów i pozwala widzieć w zupełnej ciemności."
	id = "security_hud_night"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/uranium = 1000, /datum/material/gold = 350, /datum/material/copper = 300)
	build_path = /obj/item/clothing/glasses/hud/security/night
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/diagnostic_hud
	name = "HUD diagnostyczny"
	desc = "HUD do analizy i wykrywania usterek w maszynach robotycznych."
	id = "diagnostic_hud"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/copper = 250)
	build_path = /obj/item/clothing/glasses/hud/diagnostic
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/diagnostic_hud_night
	name = "Noktowizyjny HUD diagnostyczny"
	desc = "Ulepszona wersja HUD-u diagnostycznego, zaprojektowana do pracy podczas awarii zasilania."
	id = "diagnostic_hud_night"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/uranium = 1000, /datum/material/plasma = 300, /datum/material/copper = 300)
	build_path = /obj/item/clothing/glasses/hud/diagnostic/night
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/////////////////////////////////////////
//////////////////Misc///////////////////
/////////////////////////////////////////

/datum/design/welding_mask
	name = "Maska spawalnicza"
	desc = "Maska gazowa z wbudowanymi goglami spawalniczymi i osłoną twarzy. Wygląda jak czaszka, najwyraźniej zaprojektował ją nerd."
	id = "weldingmask"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 1000)
	build_path = /obj/item/clothing/mask/gas/welding
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/portaseeder
	name = "Przenośny ekstraktor nasion"
	desc = "Dla przedsiębiorczego botanika w drodze. Mniej wydajny od modelu stacjonarnego, daje jedno nasiono z rośliny."
	id = "portaseeder"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 400)
	build_path = /obj/item/storage/bag/plants/portaseeder
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/air_horn
	name = "Trąbka pneumatyczna"
	desc = "Stary, skąd to wytrzasnąłeś?"
	id = "air_horn"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/bananium = 1000)
	build_path = /obj/item/bikehorn/airhorn
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ALL			//HONK!

/datum/design/mesons
	name = "Gogle mezonowe"
	desc = "Używane przez inżynierów i górników, by widzieć przez ściany podstawowy układ konstrukcji i terenu, niezależnie od oświetlenia."
	id = "mesons"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/clothing/glasses/meson
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/engine_goggles
	name = "Inżynieryjne gogle skanujące"
	desc = "Gogle używane przez inżynierów. Tryb skanera mezonowego pozwala widzieć przez ściany podstawowy układ konstrukcji i terenu, niezależnie od oświetlenia. Tryb skanera T-ray pozwala widzieć obiekty pod podłogą, takie jak kable i rury."
	id = "engine_goggles"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/plasma = 100)
	build_path = /obj/item/clothing/glasses/meson/engine
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/tray_goggles
	name = "Gogle T-ray"
	desc = "Używane przez inżynierów, by widzieć obiekty pod podłogą, takie jak kable i rury."
	id = "tray_goggles"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/clothing/glasses/meson/engine/tray
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/nvgmesons
	name = "Noktowizyjne gogle mezonowe"
	desc = "Prototypowe gogle mezonowe z dodatkowym czujnikiem, który wzmacnia widmo światła widzialnego i nakłada je na wyświetlacz UHD."
	id = "nvgmesons"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/plasma = 350, /datum/material/uranium = 1000)
	build_path = /obj/item/clothing/glasses/meson/night
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_CARGO

/datum/design/night_vision_goggles
	name = "Gogle noktowizyjne"
	desc = "Gogle, które pozwalają swobodnie widzieć w ciemności."
	id = "night_visision_goggles"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/plasma = 350, /datum/material/uranium = 1000)
	build_path = /obj/item/clothing/glasses/night
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_SECURITY

/datum/design/magboots
	name = "Buty magnetyczne"
	desc = "Buty magnetyczne, często używane podczas prac poza pojazdem, by użytkownik pozostał bezpiecznie przyczepiony do kadłuba."
	id = "magboots"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4500, /datum/material/silver = 1500, /datum/material/gold = 2500)
	build_path = /obj/item/clothing/shoes/magboots
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/forcefield_projector
	name = "Projektor pola siłowego"
	desc = "Urządzenie, które wyświetla tymczasowe pola siłowe, by odciąć obszar."
	id = "forcefield_projector"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 1000)
	build_path = /obj/item/forcefield_projector
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/sci_goggles
	name = "Gogle naukowe"
	desc = "Gogle z przenośnym analizatorem, który określa wartość badawczą przedmiotu albo części maszyny."
	id = "scigoggles"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/clothing/glasses/science
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/diskplantgene
	name = "Dysk danych roślin"
	desc = "Dysk do przechowywania danych genetycznych roślin."
	id = "diskplantgene"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=200, /datum/material/glass = 100)
	build_path = /obj/item/disk/plant_disk
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

//TODO: Add designs for all the new botany machines -Racc
/datum/design/tray_maker
	name = "Hydroponiczny konstruktor hydrauliczny"
	desc = "Narzędzie hydrauliczne do sprzętu botanicznego."
	id = "traymaker"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 75000, /datum/material/glass = 37500, /datum/material/plastic = 1000)
	build_path = /obj/item/construction/plumbing/botany
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/roastingstick
	name = "Zaawansowany kij do pieczenia"
	desc = "Kijek do pieczenia kiełbasek w egzotycznych piecach."
	id = "roastingstick"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=1000, /datum/material/glass = 500, /datum/material/bluespace = 250)
	build_path = /obj/item/melee/roastingstick
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/locator
	name = "Lokalizator bluespace"
	desc = "Służy do namierzania przenośnych nadajników teleportacyjnych i celów z wszczepionymi implantami namierzającymi."
	id = "locator"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=1000, /datum/material/glass = 500, /datum/material/silver = 500)
	build_path = /obj/item/locator
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/quantum_keycard
	name = "Kwantowa karta-klucz"
	desc = "Pozwala wykonać kwantową kartę-klucz."
	id = "quantum_keycard"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/iron = 500, /datum/material/silver = 500, /datum/material/bluespace = 1000)
	build_path = /obj/item/quantum_keycard
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/anomaly_neutralizer
	name = "Neutralizator anomalii"
	desc = "Zaawansowane narzędzie, które natychmiast neutralizuje anomalie. Zaprojektowano je do chwytania ulotnych aberracji wytwarzanych przez silnik."
	id = "anomaly_neutralizer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/gold = 2000, /datum/material/plasma = 5000, /datum/material/uranium = 2000)
	build_path = /obj/item/anomaly_neutralizer
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/donksoft_refill
	name = "Wkład do automatu z zabawkami Donksoft"
	desc = "Pojemnik uzupełniający do automatów z zabawkami Donksoft."
	id = "donksoft_refill"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/glass = 15000, /datum/material/plasma = 20000, /datum/material/gold = 10000, /datum/material/silver = 10000)
	build_path = /obj/item/vending_refill/donksoft
	category = list("Equipment")

/datum/design/oxygen_tank
	name = "Butla z tlenem"
	desc = "Pusta butla z tlenem."
	id = "oxygen_tank"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/tank/internals/oxygen/empty
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/plasma_tank
	name = "Butla z plazmą"
	desc = "Pusta butla z tlenem."
	id = "plasma_tank"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/tank/internals/plasma/empty
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/xenoartifact_labeller
	name = "Etykieciarka artefaktów"
	desc = "Naukowa etykieciarka do ostrzegania innych przed niebezpieczeństwami obcego artefaktu."
	id = "xenoa_labeler"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000, /datum/material/silver = 1000, /datum/material/gold = 3000)
	build_path = /obj/item/xenoarchaeology_labeler
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/artifact_pinchers
	name = "Antydotykowe szczypce"
	desc = "Precyzyjne szczypce do badania artefaktów."
	id = "xenoa_gloves"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/silver = 1000)
	build_path = /obj/item/clothing/gloves/artifact_pinchers
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/xenoartifact_tracker
	name = "Lokalizator artefaktów"
	desc = "Lokalizator do badania artefaktów."
	id = "xenoa_tracker"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/silver = 500, /datum/material/gold = 500)
	build_path = /obj/item/sticker/artifact_tracker
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/////////////////////////////////////////
////////////Janitor Designs//////////////
/////////////////////////////////////////

/datum/design/larryframe
	name = "Rama Larry'ego"
	desc = "Obudowa, która służy za podstawę do budowy Larrych."
	id = "larry"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200)
	build_path = /obj/item/larryframe
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/advmop
	name = "Zaawansowany mop"
	desc = "Ulepszony mop z dużym wewnętrznym zbiornikiem na wodę lub inne środki czyszczące."
	id = "advmop"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 200)
	build_path = /obj/item/mop/advanced
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/blutrash
	name = "Worek na śmieci bez dna"
	desc = "Zaawansowany worek na śmieci o właściwościach bluespace. Zmieści mnóstwo odpadków."
	id = "blutrash"
	build_type = PROTOLATHE
	materials = list(/datum/material/gold = 1500, /datum/material/uranium = 250, /datum/material/plasma = 1500)
	build_path = /obj/item/storage/bag/trash/bluespace
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/buffer
	name = "Ulepszenie: polerka do podłóg"
	desc = "Polerka do podłóg, którą można zamontować na wózku woźnego."
	id = "buffer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 200)
	build_path = /obj/item/janiupgrade
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/spraybottle
	name = "Spryskiwacz"
	desc = "Spryskiwacz z odkręcaną nakrętką."
	id = "spraybottle"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 200)
	build_path = /obj/item/reagent_containers/spray
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/beartrap
	name = "Wnyki"
	desc = "Pułapka do łapania kosmicznych niedźwiedzi i innych stworzeń z nogami."
	id = "beartrap"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/titanium = 1000)
	build_path = /obj/item/restraints/legcuffs/beartrap
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/////////////////////////////////////////
/////////////Holobarriers////////////////
/////////////////////////////////////////

/datum/design/holosign
	name = "Projektor holoznaków"
	desc = "Projektor holograficzny wyświetlający różne znaki ostrzegawcze."
	id = "holosign"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	build_path = /obj/item/holosign_creator
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/holobarrier_jani
	name = "Projektor holobarier woźnego"
	desc = "Projektor holograficzny wyświetlający bariery z twardego światła ostrzegające przed mokrą podłogą."
	id = "holobarrier_jani"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000, /datum/material/silver = 1000)
	build_path = /obj/structure/holosign/barrier/wetsign
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/holosignsec
	name = "Projektor holobarier ochrony"
	desc = "Projektor holograficzny tworzący holograficzne bariery ochrony."
	id = "holosignsec"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 1000, /datum/material/gold = 1000, /datum/material/silver = 1000)
	build_path = /obj/item/holosign_creator/security
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/holosignengi
	name = "Projektor holobarier inżynieryjnych"
	desc = "Projektor holograficzny tworzący holograficzne bariery inżynieryjne."
	id = "holosignengi"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 1000, /datum/material/gold = 1000, /datum/material/silver = 1000)
	build_path = /obj/item/holosign_creator/engineering
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/holosignatmos
	name = "Projektor holowentylatorów ATMOS"
	desc = "Projektor holograficzny tworzący holograficzne bariery, które zapobiegają zmianom warunków atmosferycznych."
	id = "holosignatmos"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 1000, /datum/material/gold = 1000, /datum/material/silver = 1000)
	build_path = /obj/item/holosign_creator/atmos
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/holobarrier_med
	name = "Projektor holobarier PENLITE"
	desc = "Holobariery PENLITE, urządzenie zatrzymujące osoby z groźnymi chorobami."
	build_type = PROTOLATHE
	build_path = /obj/item/holosign_creator/medical
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/silver = 100) //a hint of silver since it can troll 2 antags (bad viros and sentient disease)
	id = "holobarrier_med"
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/////////////////////////////////////////
////////////////Armour///////////////////
/////////////////////////////////////////

/datum/design/reactive_armour
	name = "Skorupa pancerza reaktywnego"
	desc = "Eksperymentalny pancerz, który chroni użytkownika za pomocą wszczepionego rdzenia anomalii."
	id = "reactive_armour"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/diamond = 5000, /datum/material/uranium = 8000, /datum/material/silver = 4500, /datum/material/gold = 5000)
	build_path = /obj/item/reactive_armour_shell
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/////////////////////////////////////////
/////////////Security////////////////////
/////////////////////////////////////////

/datum/design/seclite
	name = "Latarka policyjna"
	desc = "Solidna latarka używana przez ochronę."
	id = "seclite"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2500)
	build_path = /obj/item/flashlight/seclite
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/detective_scanner
	name = "Skaner kryminalistyczny"
	desc = "Służy do zdalnego skanowania przedmiotów i biomasy w poszukiwaniu DNA i odcisków palców. Potrafi wydrukować raport z wynikami."
	id = "detective_scanner"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 1000, /datum/material/gold = 2500, /datum/material/silver = 2000)
	build_path = /obj/item/detective_scanner
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/pepperspray
	name = "Gaz pieprzowy"
	desc = "Produkt UhangInc, służy do szybkiego oślepienia i powalenia przeciwnika. Wydrukowane gazy pieprzowe nie zawierają odczynników."
	id = "pepperspray"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 1000)
	build_path = /obj/item/reagent_containers/spray/pepper/empty
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/bola_energy
	name = "Bola energetyczna"
	desc = "Specjalna bola z twardego światła do pętania uciekających przestępców i pomocy przy aresztowaniach."
	id = "bola_energy"
	build_type = PROTOLATHE
	materials = list(/datum/material/silver = 500, /datum/material/plasma = 500, /datum/material/titanium = 500)
	build_path = /obj/item/restraints/legcuffs/bola/energy
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/zipties
	name = "Opaski zaciskowe"
	desc = "Plastikowe, jednorazowe opaski zaciskowe do tymczasowego skrępowania. Po użyciu ulegają zniszczeniu."
	id = "zipties"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 250)
	build_path = /obj/item/restraints/handcuffs/cable/zipties
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/evidencebag
	name = "Torebka na dowody"
	desc = "Pusta torebka na dowody."
	id = "evidencebag"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 100)
	build_path = /obj/item/evidencebag
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/plumbing_rcd
	name = "Konstruktor hydrauliczny"
	id = "plumbing_rcd"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 75000, /datum/material/glass = 37500, /datum/material/plastic = 1000)
	build_path = /obj/item/construction/plumbing
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/glasses_prescription
	name = "Okulary korekcyjne"
	desc = "Produkt Nerd. Co."
	id = "glasses_prescription"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 2000)
	build_path = /obj/item/clothing/glasses/regular
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/////////////////////////////////////////
/////////////////Tape////////////////////
/////////////////////////////////////////

/datum/design/sticky_tape
	name = "Taśma klejąca"
	id = "sticky_tape"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 500)
	build_path = /obj/item/stack/sticky_tape
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/super_sticky_tape
	name = "Superklejąca taśma"
	id = "super_sticky_tape"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 3000)
	build_path = /obj/item/stack/sticky_tape/super
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/pointy_tape
	name = "Kolczasta taśma"
	id = "pointy_tape"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1500, /datum/material/plastic = 1000)
	build_path = /obj/item/stack/sticky_tape/pointy
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/oven_tray
	name = "Blacha do piekarnika"
	desc = "Trzeba coś tam wsadzić!"
	id = "oven_tray"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 500)
	build_path = /obj/item/plate/oven_tray
	category = list("initial","Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

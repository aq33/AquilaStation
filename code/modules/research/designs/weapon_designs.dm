/////////////////////////////////////////
/////////////////Weapons/////////////////
/////////////////////////////////////////

/datum/design/c38/sec
	id = "sec_38"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/c38b/sec
	id = "sec_38b"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/c38_trac
	name = "Szybkoładowacz (.38 TRAC)"
	desc = "Do szybkiego przeładowania rewolwerów. Pociski TRAC wszczepiają w ciało celu implant namierzający."
	id = "c38_trac"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/silver = 5000, /datum/material/gold = 1000)
	build_path = /obj/item/ammo_box/c38/trac
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/c38_hotshot
	name = "Szybkoładowacz (.38 Hot Shot)"
	desc = "Do szybkiego przeładowania rewolwerów. Pociski Hot Shot zawierają ładunek zapalający."
	id = "c38_hotshot"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/plasma = 5000)
	build_path = /obj/item/ammo_box/c38/hotshot
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/c38_iceblox
	name = "Szybkoładowacz (.38 Iceblox)"
	desc = "Do szybkiego przeładowania rewolwerów. Pociski Iceblox zawierają ładunek kriogeniczny."
	id = "c38_iceblox"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/plasma = 5000)
	build_path = /obj/item/ammo_box/c38/iceblox
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/rubbershot/sec
	id = "sec_rshot"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/beanbag_slug/sec
	id = "sec_beanbag_slug"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/shotgun_slug/sec
	id = "sec_slug"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/buckshot_shell/sec
	id = "sec_bshot"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/shotgun_dart/sec
	id = "sec_dart"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/incendiary_slug/sec
	id = "sec_Islug"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/breaching_slug/sec
	name = "Breneka wyważająca"
	desc = "Breneka przeciwsprzętowa kalibru 12. Świetna do wyważania śluz i okien minimalną liczbą strzałów."
	id = "sec_Brslug"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000)
	build_path = /obj/item/ammo_casing/shotgun/breacher
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/pin_testing
	name = "Iglica strzelnicy"
	desc = "Ta zabezpieczająca iglica pozwala strzelać z broni tylko w pobliżu strzelnicy."
	id = "pin_testing"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 300)
	build_path = /obj/item/firing_pin/test_range
	category = list("Firing Pins")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/pin_mindshield
	name = "Iglica ochrony umysłu"
	desc = "Iglica ochrony, która dopuszcza tylko użytkowników z implantem ochrony umysłu."
	id = "pin_loyalty"
	build_type = PROTOLATHE
	materials = list(/datum/material/silver = 600, /datum/material/diamond = 600, /datum/material/uranium = 200)
	build_path = /obj/item/firing_pin/implant/mindshield
	category = list("Firing Pins")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/stunmine/sec/
	name = "Mina ogłuszająca"
	desc = "Podstawowa nieśmiercionośna mina ogłuszająca. Zadaje bardzo duże obrażenia wytrzymałości każdemu, kto na nią wejdzie."
	id = "stunmine"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 1000, /datum/material/copper = 400)
	build_path = /obj/item/deployablemine/stun
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/adv_stunmine/sec
	name = "Inteligentna mina ogłuszająca"
	desc = "Zaawansowana nieśmiercionośna mina ogłuszająca. Zaawansowane oprogramowanie wykrywające sprawia, że wybucha tylko pod kimś bez implantu ochrony umysłu."
	id = "stunmine_adv"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 8000, /datum/material/glass = 3000, /datum/material/copper = 1000, /datum/material/silver = 200)
	build_path = /obj/item/deployablemine/smartstun
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/lm6_stunmine/sec
	name = "Inteligentna mina szybkiego rozstawiania"
	desc = "Zaawansowana nieśmiercionośna mina ogłuszająca. Zaawansowane oprogramowanie wykrywające sprawia, że wybucha tylko pod kimś bez implantu ochrony umysłu. Można ją szybko rozstawić i rozbroić."
	id = "stunmine_rapid"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 4000, /datum/material/copper = 1000, /datum/material/silver = 500, /datum/material/uranium = 200)
	build_path = /obj/item/deployablemine/rapid
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/lm12_stunmine/sec
	name = "Inteligentna mina „Młot”"
	desc = "Zaawansowana nieśmiercionośna mina ogłuszająca. Zaawansowane oprogramowanie wykrywające sprawia, że wybucha tylko pod kimś bez implantu ochrony umysłu. Bardzo silna i trudna do rozbrojenia."
	id = "stunmine_heavy"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 4000, /datum/material/copper = 1000, /datum/material/silver = 500, /datum/material/uranium = 200)
	build_path = /obj/item/deployablemine/heavy
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/honkmine
	name = "Honkblaster 1000"
	desc = "Zaawansowana, naciskowa mina do robienia psikusów, honk!"
	id = "clown_mine"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 1000, /datum/material/bananium = 500)
	build_path = /obj/item/deployablemine/honk
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/stunrevolver
	name = "Rewolwer Tesli"
	desc = "Zaawansowany rewolwer, który strzela wewnętrznymi, wielorazowymi nabojami elektrycznymi z obrotowego bębna. Naboje ładuje się w zwykłych ładowarkach."
	id = "stunrevolver"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 10000, /datum/material/silver = 10000)
	build_path = /obj/item/gun/energy/tesla_revolver
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/nuclear_gun
	name = "Zaawansowana broń energetyczna"
	desc = "Broń energetyczna z eksperymentalnym zminiaturyzowanym reaktorem."
	id = "nuclear_gun"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2000, /datum/material/uranium = 3000, /datum/material/titanium = 1000)
	build_path = /obj/item/gun/energy/e_gun/nuclear
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/tele_shield
	name = "Teleskopowa tarcza prewencyjna"
	desc = "Zaawansowana tarcza prewencyjna z lekkich materiałów, którą można złożyć do przechowania."
	id = "tele_shield"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 4000, /datum/material/silver = 300, /datum/material/titanium = 200)
	build_path = /obj/item/shield/riot/tele
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/beamrifle
	name = "Wiązkowy karabin wyborowy"
	desc = "Potężny przeciwsprzętowy karabin dalekiego zasięgu, który niszczy cele wiązkami naładowanych cząstek."
	id = "beamrifle"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 5000, /datum/material/diamond = 5000, /datum/material/uranium = 8000, /datum/material/silver = 4500, /datum/material/gold = 5000)
	build_path = /obj/item/gun/energy/beam_rifle
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/decloner
	name = "Dekloner"
	desc = "Twój przeciwnik rozbulgocze się w lepką kupkę mazi."
	id = "decloner"
	build_type = PROTOLATHE
	materials = list(/datum/material/gold = 5000,/datum/material/uranium = 10000)
	reagents_list = list(/datum/reagent/toxin/mutagen = 40)
	build_path = /obj/item/gun/energy/decloner
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/rapidsyringe
	name = "Szybka wyrzutnia strzykawek"
	desc = "Broń, która wystrzeliwuje wiele strzykawek."
	id = "rapidsyringe"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 1000)
	build_path = /obj/item/gun/syringe/rapidsyringe
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL		//uwu

/datum/design/temp_gun
	name = "Pistolet temperaturowy"
	desc = "Broń, która strzela temperaturowymi energopociskami zmieniającymi temperaturę."//Change it if you want
	id = "temp_gun"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 500, /datum/material/silver = 3000)
	build_path = /obj/item/gun/energy/temperature
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/flora_gun
	name = "Roślinny somatopromiennik"
	desc = "Narzędzie emitujące kontrolowane promieniowanie, które wywołuje mutacje w komórkach roślin. Nieszkodliwe dla innych form życia."
	id = "flora_gun"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 500)
	reagents_list = list(/datum/reagent/uranium/radium = 20)
	build_path = /obj/item/gun/energy/floragun
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/large_grenade
	name = "Duży granat"
	desc = "Granat, który działa na większym obszarze i mieści większe pojemniki."
	id = "large_Grenade"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000)
	build_path = /obj/item/grenade/chem_grenade/large
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/pyro_grenade
	name = "Granat zapalający"
	desc = "Zaawansowany granat, który sam zapala swoją mieszankę."
	id = "pyro_Grenade"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/plasma = 500)
	build_path = /obj/item/grenade/chem_grenade/pyro
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cryo_grenade
	name = "Granat kriogeniczny"
	desc = "Zaawansowany granat, który przy detonacji gwałtownie schładza zawartość."
	id = "cryo_Grenade"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/silver = 500)
	build_path = /obj/item/grenade/chem_grenade/cryo
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/adv_grenade
	name = "Zaawansowany granat wielokrotnego uwalniania"
	desc = "Zaawansowany granat, który można zdetonować kilka razy. Najlepiej używać go z powtarzalnym zapalnikiem."
	id = "adv_Grenade"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500)
	build_path = /obj/item/grenade/chem_grenade/adv_release
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/xray
	name = "Karabin laserowy na promienie X"
	desc = "Nie aż tak groźny, jak brzmi"
	id = "xray_laser"
	build_type = PROTOLATHE
	materials = list(/datum/material/gold = 5000, /datum/material/uranium = 4000, /datum/material/iron = 5000, /datum/material/titanium = 2000, /datum/material/bluespace = 2000)
	build_path = /obj/item/gun/energy/xray
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/ioncarbine
	name = "Karabinek jonowy"
	desc = "Jak rozebrać cyborga: wersja z bronią."
	id = "ioncarbine"
	build_type = PROTOLATHE
	materials = list(/datum/material/silver = 6000, /datum/material/iron = 8000, /datum/material/uranium = 2000)
	build_path = /obj/item/gun/energy/ionrifle/carbine
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/wormhole_projector
	name = "Projektor tuneli czasoprzestrzennych bluespace"
	desc = "Projektor emitujący gęste, kwantowo sprzężone wiązki bluespace."
	id = "wormholeprojector"
	build_type = PROTOLATHE
	materials = list(/datum/material/silver = 2000, /datum/material/iron = 5000, /datum/material/diamond = 2000, /datum/material/bluespace = 3000)
	build_path = /obj/item/gun/energy/wormhole_projector
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

//WT550 Mags

/datum/design/mag_oldsmg
	name = "Magazynek do WT-550 (4.6x30mm)"
	desc = "Magazynek na 20 naboi do przestarzałego karabinu automatycznego ochrony WT-550"
	id = "mag_oldsmg"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000)
	build_path = /obj/item/ammo_box/magazine/wt550m9
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/mag_oldsmg/rubber
	name = "Magazynek do WT-550, gumowy (4.6x30mm, gumowe)"
	desc = "Magazynek na 20 naboi do przestarzałego karabinu automatycznego ochrony WT-550"
	id = "mag_oldsmg_rubber"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000)
	build_path = /obj/item/ammo_box/magazine/wt550m9/rubber
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/mag_oldsmg/ap_mag
	name = "Magazynek do WT-550, przeciwpancerny (4.6x30mm AP)"
	desc = "Przeciwpancerny magazynek na 20 naboi do przestarzałego karabinu automatycznego ochrony WT-550"
	id = "mag_oldsmg_ap"
	materials = list(/datum/material/iron = 6000, /datum/material/silver = 600)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtap
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/mag_oldsmg/ic_mag
	name = "Magazynek do WT-550, zapalający (4.6x30mm IC)"
	desc = "Przeciwpancerny magazynek na 20 naboi do przestarzałego karabinu automatycznego ochrony WT-550"
	id = "mag_oldsmg_ic"
	materials = list(/datum/material/iron = 6000, /datum/material/silver = 600, /datum/material/glass = 1000)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtic
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/stunshell
	name = "Nabój ogłuszający"
	desc = "Ogłuszający nabój do strzelby."
	id = "stunshell"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200)
	build_path = /obj/item/ammo_casing/shotgun/stunslug
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/techshell
	name = "Pusty nabój technologiczny"
	desc = "Zaawansowany nabój do strzelby, który można napełnić materiałami, by uzyskać wyjątkowe efekty."
	id = "techshotshell"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 200)
	build_path = /obj/item/ammo_casing/shotgun/techshell
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/suppressor
	name = "Tłumik"
	desc = "Tłumik odtworzony metodą inżynierii wstecznej, pasujący do większości broni krótkiej z gwintowaną lufą."
	id = "suppressor"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/silver = 500)
	build_path = /obj/item/suppressor
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/gravitygun
	name = "Jednopunktowy manipulator grawitacyjny bluespace"
	desc = "Wielotrybowe urządzenie, które wystrzeliwuje jednopunktowe pociski grawitacyjne bluespace, lokalnie zakrzywiające grawitację."
	id = "gravitygun"
	build_type = PROTOLATHE
	materials = list(/datum/material/silver = 8000, /datum/material/uranium = 8000, /datum/material/glass = 12000, /datum/material/iron = 12000, /datum/material/diamond = 3000, /datum/material/bluespace = 3000)
	build_path = /obj/item/gun/energy/gravity_gun
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/largecrossbow
	name = "Kusza energetyczna"
	desc = "Kusza energetyczna odtworzona metodą inżynierii wstecznej, ulubiona broń zespołów infiltracyjnych Syndykatu i łowców karpi."
	id = "largecrossbow"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 1500, /datum/material/uranium = 1500, /datum/material/silver = 1500)
	build_path = /obj/item/gun/energy/kinetic_accelerator/crossbow/large
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/cryostasis_shotgun_dart
	name = "Kriostatyczna strzałka do strzelby"
	desc = "Strzałka do strzelby o budowie wewnętrznej podobnej do zlewki kriostatycznej, dzięki czemu odczynniki w środku nie reagują."
	id = "shotgundartcryostasis"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3500)
	build_path = /obj/item/ammo_casing/shotgun/dart/noreact
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/flashbulb
	name = "Żarówka flasha ochrony"
	desc = "Mocna żarówka, która po włożeniu do flasha emituje jasne światło, dezorientujące i obezwładniające cele."
	id = "flashbulb"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 150)
	build_path = /obj/item/flashbulb
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

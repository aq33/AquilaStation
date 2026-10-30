/datum/supply_pack/munitions
	group = "Munitions"
	access_any = list(ACCESS_MUNITIONS, ACCESS_SYNDICATE_REQUISITIONS)
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/munitions/railgun
	name = "Pociski artylerii okrętowej (x10)"
	desc = "Zestaw pocisków artylerii okrętowej do wystrzelenia z tej właśnie broni. Przed strzałem trzeba je uzbroić. OSTRZEŻENIE: SILNIE WYBUCHOWE."
	cost = 2000
	contains = list(/obj/item/ship_weapon/ammunition/naval_artillery,
					/obj/item/ship_weapon/ammunition/naval_artillery,
					/obj/item/ship_weapon/ammunition/naval_artillery,
					/obj/item/ship_weapon/ammunition/naval_artillery,
					/obj/item/ship_weapon/ammunition/naval_artillery,
					/obj/item/ship_weapon/ammunition/naval_artillery,
					/obj/item/ship_weapon/ammunition/naval_artillery,
					/obj/item/ship_weapon/ammunition/naval_artillery,
					/obj/item/ship_weapon/ammunition/naval_artillery,
					/obj/item/ship_weapon/ammunition/naval_artillery)
	crate_name = "skrzynia z pociskami artylerii okrętowej"

/datum/supply_pack/munitions/cannonshot
	name = "Kule armatnie (x10)"
	desc = "Dla zespołów amunicyjnych z ograniczonym budżetem kule armatnie są tanią, ale wciąż w miarę skuteczną amunicją do artylerii okrętowej. Zrobione z najlepszych sztućców, jakie ma flota NT."
	cost = 1000
	contains = list(/obj/item/ship_weapon/ammunition/naval_artillery/cannonball,
					/obj/item/ship_weapon/ammunition/naval_artillery/cannonball,
					/obj/item/ship_weapon/ammunition/naval_artillery/cannonball,
					/obj/item/ship_weapon/ammunition/naval_artillery/cannonball,
					/obj/item/ship_weapon/ammunition/naval_artillery/cannonball,
					/obj/item/ship_weapon/ammunition/naval_artillery/cannonball,
					/obj/item/ship_weapon/ammunition/naval_artillery/cannonball,
					/obj/item/ship_weapon/ammunition/naval_artillery/cannonball,
					/obj/item/ship_weapon/ammunition/naval_artillery/cannonball,
					/obj/item/ship_weapon/ammunition/naval_artillery/cannonball)
	crate_type = /obj/structure/closet/crate/wooden
	crate_name = "najlepsze kule armatnie kapitana Plazmosoli"

/datum/supply_pack/munitions/gunpowder
	name = "Worki prochu (x10)"
	desc = "Worki prochu okrętowego do broni artyleryjskiej. OSTRZEŻENIE: niestabilne."
	cost = 1000
	contains = list(/obj/item/powder_bag,
					/obj/item/powder_bag,
					/obj/item/powder_bag,
					/obj/item/powder_bag,
					/obj/item/powder_bag,
					/obj/item/powder_bag,
					/obj/item/powder_bag,
					/obj/item/powder_bag,
					/obj/item/powder_bag,
					/obj/item/powder_bag)
	crate_type = /obj/structure/closet/crate/wooden
	crate_name = "najlepszy proch kapitana Plazmosoli"

/datum/supply_pack/munitions/muni_pointer
	name = "Lokalizator amunicji"
	desc = "Klaun wyrzucił twoje wieżyczki w kosmos? Mistrz Broni się poślizgnął i wrzucił lokalizator do recyklera? Oto rozwiązanie twoich problemów!"
	cost = 5000 //Don't lose yours, MAA.
	contains = list(/obj/item/pinpointer/munitions)

/datum/supply_pack/munitions/muni_pointer/fill(obj/structure/closet/crate/C)
	if(prob(1))
		new /obj/item/pinpointer/munitions/not_puce(C)
	else
		new /obj/item/pinpointer/munitions(C)

/datum/supply_pack/munitions/pdc_ammo
	name = "Amunicja do PDC (x5)"
	desc = "5 pudełek amunicji PDC, idealnej do odpierania torped i rakiet."
	cost = 1000
	contains = list(/obj/item/ammo_box/magazine/nsv/pdc,
					/obj/item/ammo_box/magazine/nsv/pdc,
					/obj/item/ammo_box/magazine/nsv/pdc,
					/obj/item/ammo_box/magazine/nsv/pdc,
					/obj/item/ammo_box/magazine/nsv/pdc)
	crate_name = "skrzynia z amunicją PDC"

/datum/supply_pack/munitions/trolley
	name = "Zapasowy wózek amunicyjny (x1)"
	desc = "Wózek amunicyjny do przewożenia amunicji. Uzbrojenie sprzedawane osobno."
	cost = 2000
	contains = list(/obj/structure/munitions_trolley)
	crate_name = "skrzynia z wózkiem amunicyjnym"

/datum/supply_pack/munitions/torpedo_construction
	name = "Zestaw do budowy torped"
	desc = "Torpedy są niestabilne, więc nie możemy sprzedawać gotowej amunicji, ale ten zestaw zawiera typowe części torped i kilka obudów, w które je włożysz. Zawiera: 3x standardowa głowica, 3x obudowa torpedy (wózek sprzedawany osobno), 3x moduł układu naprowadzania, 3x moduł napędowy, 3x karta IFF."
	cost = 3000
	contains = list(/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/parts/missile/warhead/torpedo,
					/obj/item/ship_weapon/parts/missile/warhead/torpedo,
					/obj/item/ship_weapon/parts/missile/warhead/torpedo,
					/obj/item/ship_weapon/parts/missile/guidance_system,
					/obj/item/ship_weapon/parts/missile/guidance_system,
					/obj/item/ship_weapon/parts/missile/guidance_system,
					/obj/item/ship_weapon/parts/missile/propulsion_system,
					/obj/item/ship_weapon/parts/missile/propulsion_system,
					/obj/item/ship_weapon/parts/missile/propulsion_system,
					/obj/item/ship_weapon/parts/missile/iff_card,
					/obj/item/ship_weapon/parts/missile/iff_card,
					/obj/item/ship_weapon/parts/missile/iff_card)
	crate_name = "skrzynia z podstawowym zestawem do budowy torped"

/datum/supply_pack/munitions/torpedo_casings
	name = "Obudowy torped"
	desc = "Zestaw 10 obudów torped, wykonanych, ale niezłożonych. Idealne w połączeniu z naszą linią podzespołów torped."
	cost = 750
	contains = list(/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing)
	crate_name = "skrzynia z pustymi obudowami torped"

/datum/supply_pack/munitions/torpedo_construction_guidance
	name = "Moduły naprowadzania ładunku"
	desc = "Hurtowe zamówienie 10 modułów naprowadzania torped. Głowice sprzedawane osobno!"
	cost = 1500
	contains = list(/obj/item/ship_weapon/parts/missile/guidance_system,
					/obj/item/ship_weapon/parts/missile/guidance_system,
					/obj/item/ship_weapon/parts/missile/guidance_system,
					/obj/item/ship_weapon/parts/missile/guidance_system,
					/obj/item/ship_weapon/parts/missile/guidance_system,
					/obj/item/ship_weapon/parts/missile/guidance_system,
					/obj/item/ship_weapon/parts/missile/guidance_system,
					/obj/item/ship_weapon/parts/missile/guidance_system,
					/obj/item/ship_weapon/parts/missile/guidance_system,
					/obj/item/ship_weapon/parts/missile/guidance_system)
	crate_name = "skrzynia z układami naprowadzania amunicji"

/datum/supply_pack/munitions/payload_construction_propulsion
	name = "Układy napędowe ładunku"
	desc = "Hurtowe zamówienie 10 układów napędowych ładunku. Głowice sprzedawane osobno!"
	cost = 1500
	contains = list(/obj/item/ship_weapon/parts/missile/propulsion_system,
					/obj/item/ship_weapon/parts/missile/propulsion_system,
					/obj/item/ship_weapon/parts/missile/propulsion_system,
					/obj/item/ship_weapon/parts/missile/propulsion_system,
					/obj/item/ship_weapon/parts/missile/propulsion_system,
					/obj/item/ship_weapon/parts/missile/propulsion_system,
					/obj/item/ship_weapon/parts/missile/propulsion_system,
					/obj/item/ship_weapon/parts/missile/propulsion_system,
					/obj/item/ship_weapon/parts/missile/propulsion_system,
					/obj/item/ship_weapon/parts/missile/propulsion_system)
	crate_name = "skrzynia z układami napędowymi amunicji"

/datum/supply_pack/munitions/payload_construction_iff
	name = "Karty IFF ładunku"
	desc = "Hurtowe zamówienie 10 kart IFF ładunku. Głowice sprzedawane osobno!"
	cost = 1500
	contains = list(/obj/item/ship_weapon/parts/missile/iff_card,
					/obj/item/ship_weapon/parts/missile/iff_card,
					/obj/item/ship_weapon/parts/missile/iff_card,
					/obj/item/ship_weapon/parts/missile/iff_card,
					/obj/item/ship_weapon/parts/missile/iff_card,
					/obj/item/ship_weapon/parts/missile/iff_card,
					/obj/item/ship_weapon/parts/missile/iff_card,
					/obj/item/ship_weapon/parts/missile/iff_card,
					/obj/item/ship_weapon/parts/missile/iff_card,
					/obj/item/ship_weapon/parts/missile/iff_card)
	crate_name = "skrzynia z kartami rozpoznawania swój-obcy"

/datum/supply_pack/munitions/standard_warheads
	name = "Głowice torped (standardowe)"
	desc = "Paczka 10 standardowych głowic torped o mocy 40 izoton, idealnych do ogólnego użytku."
	cost = 1500
	contains = list(/obj/item/ship_weapon/parts/missile/warhead/torpedo,
					/obj/item/ship_weapon/parts/missile/warhead/torpedo,
					/obj/item/ship_weapon/parts/missile/warhead/torpedo,
					/obj/item/ship_weapon/parts/missile/warhead/torpedo,
					/obj/item/ship_weapon/parts/missile/warhead/torpedo,
					/obj/item/ship_weapon/parts/missile/warhead/torpedo,
					/obj/item/ship_weapon/parts/missile/warhead/torpedo,
					/obj/item/ship_weapon/parts/missile/warhead/torpedo,
					/obj/item/ship_weapon/parts/missile/warhead/torpedo,
					/obj/item/ship_weapon/parts/missile/warhead/torpedo)
	crate_name = "skrzynia ze standardowymi głowicami torped"

/datum/supply_pack/munitions/bb_warheads
	name = "Głowice torped (przeciwpancerne)"
	desc = "Paczka 10 przeciwpancernych głowic torped o łącznej mocy 80 izoton. Te głowice świetnie zadają celowi ogromne obrażenia."
	cost = 2500
	contains = list(/obj/item/ship_weapon/parts/missile/warhead/bunker_buster,
					/obj/item/ship_weapon/parts/missile/warhead/bunker_buster,
					/obj/item/ship_weapon/parts/missile/warhead/bunker_buster,
					/obj/item/ship_weapon/parts/missile/warhead/bunker_buster,
					/obj/item/ship_weapon/parts/missile/warhead/bunker_buster,
					/obj/item/ship_weapon/parts/missile/warhead/bunker_buster,
					/obj/item/ship_weapon/parts/missile/warhead/bunker_buster,
					/obj/item/ship_weapon/parts/missile/warhead/bunker_buster,
					/obj/item/ship_weapon/parts/missile/warhead/bunker_buster,
					/obj/item/ship_weapon/parts/missile/warhead/bunker_buster)
	crate_name = "skrzynia z przeciwpancernymi głowicami torped"

/datum/supply_pack/munitions/decoy_warheads
	name = "Głowice rakiet ECM"
	desc = "Paczka 10 głowic walki elektronicznej, które świetnie odwracają uwagę autonomicznego systemu celowniczego wroga."
	cost = 700
	contains = list(/obj/item/ship_weapon/parts/missile/warhead/decoy,
					/obj/item/ship_weapon/parts/missile/warhead/decoy,
					/obj/item/ship_weapon/parts/missile/warhead/decoy,
					/obj/item/ship_weapon/parts/missile/warhead/decoy,
					/obj/item/ship_weapon/parts/missile/warhead/decoy,
					/obj/item/ship_weapon/parts/missile/warhead/decoy,
					/obj/item/ship_weapon/parts/missile/warhead/decoy,
					/obj/item/ship_weapon/parts/missile/warhead/decoy,
					/obj/item/ship_weapon/parts/missile/warhead/decoy,
					/obj/item/ship_weapon/parts/missile/warhead/decoy)
	crate_name = "skrzynia z głowicami rakiet-wabików"

/datum/supply_pack/munitions/freight_warheads
	name = "Głowice torped (transportowe)"
	desc = "Paczka 3 głowic torped transportowych do dostarczania ładunku na stacje handlowe."
	cost = 350
	contains = list(/obj/item/ship_weapon/parts/missile/warhead/freight,
					/obj/item/ship_weapon/parts/missile/warhead/freight,
					/obj/item/ship_weapon/parts/missile/warhead/freight)
	crate_type = /obj/structure/closet/crate/wooden
	crate_name = "skrzynia z głowicami torped transportowych"

/datum/supply_pack/munitions/pilot_outfitting
	name = "Skrzynia z wyposażeniem pilota"
	desc = "Pełny komplet sprzętu dla nowego pilota."
	cost = 1200
	contains = list(/obj/item/clothing/under/ship/pilot,
					/obj/item/clothing/shoes/jackboots,
					/obj/item/clothing/gloves/color/black,
					/obj/item/clothing/head/beret/ship/pilot,
					/obj/item/radio/headset/munitions/pilot,
					/obj/item/clothing/suit/space/hardsuit/pilot)
	crate_name = "skrzynia z wyposażeniem pilota"

/datum/supply_pack/munitions/missile_warheads
	name = "Głowice rakiet"
	desc = "Paczka 10 standardowych głowic rakiet."
	cost = 1000
	contains = list(/obj/item/ship_weapon/parts/missile/warhead,
					/obj/item/ship_weapon/parts/missile/warhead,
					/obj/item/ship_weapon/parts/missile/warhead,
					/obj/item/ship_weapon/parts/missile/warhead,
					/obj/item/ship_weapon/parts/missile/warhead,
					/obj/item/ship_weapon/parts/missile/warhead,
					/obj/item/ship_weapon/parts/missile/warhead,
					/obj/item/ship_weapon/parts/missile/warhead,
					/obj/item/ship_weapon/parts/missile/warhead,
					/obj/item/ship_weapon/parts/missile/warhead)
	crate_name = "skrzynia ze standardowymi głowicami rakiet"

/datum/supply_pack/munitions/missile_construction
	name = "Zestaw do budowy rakiet"
	desc = "Rakiety są niestabilne, więc nie możemy sprzedawać gotowej amunicji, ale ten zestaw zawiera typowe części rakiet i kilka obudów, w które je włożysz. Zawiera: 3x standardowa głowica, 3x obudowa rakiety (wózek sprzedawany osobno), 3x moduł układu naprowadzania, 3x moduł napędowy, 3x karta IFF."
	cost = 2500
	contains = list(/obj/item/ship_weapon/ammunition/missile/missile_casing,
					/obj/item/ship_weapon/ammunition/missile/missile_casing,
					/obj/item/ship_weapon/ammunition/missile/missile_casing,
					/obj/item/ship_weapon/parts/missile/warhead,
					/obj/item/ship_weapon/parts/missile/warhead,
					/obj/item/ship_weapon/parts/missile/warhead,
					/obj/item/ship_weapon/parts/missile/guidance_system,
					/obj/item/ship_weapon/parts/missile/guidance_system,
					/obj/item/ship_weapon/parts/missile/guidance_system,
					/obj/item/ship_weapon/parts/missile/propulsion_system,
					/obj/item/ship_weapon/parts/missile/propulsion_system,
					/obj/item/ship_weapon/parts/missile/propulsion_system,
					/obj/item/ship_weapon/parts/missile/iff_card,
					/obj/item/ship_weapon/parts/missile/iff_card,
					/obj/item/ship_weapon/parts/missile/iff_card)
	crate_name = "skrzynia z podstawowym zestawem do budowy rakiet"

/datum/supply_pack/munitions/countermeasure_charges
	name = "Potrójne ładunki przeciwdziałania dla myśliwców (x5)"
	desc = "5 potrójnych ładunków dipoli przeciwradarowych dla myśliwca."
	cost = 3500
	contains = list(/obj/item/ship_weapon/ammunition/countermeasure_charge,
					/obj/item/ship_weapon/ammunition/countermeasure_charge,
					/obj/item/ship_weapon/ammunition/countermeasure_charge,
					/obj/item/ship_weapon/ammunition/countermeasure_charge,
					/obj/item/ship_weapon/ammunition/countermeasure_charge)
	crate_name = "skrzynia z ładunkami przeciwdziałania dla myśliwców"

/datum/supply_pack/munitions/fighter_construction
	name = "Zestaw startowy lekkiego myśliwca"
	desc = "Ten zestaw zawiera wszystkie części potrzebne, by założyć własną flotę jak kosmiczny admirał z twoich marzeń."
	cost = 9000
	contains = list(/obj/structure/fighter_frame,
					/obj/item/fighter_component/fuel_tank,
					/obj/item/fighter_component/avionics,
					/obj/item/fighter_component/apu,
					/obj/item/fighter_component/armour_plating,
					/obj/item/fighter_component/targeting_sensor,
					/obj/item/fighter_component/engine,
					/obj/item/fighter_component/countermeasure_dispenser,
					/obj/item/fighter_component/secondary/ordnance_launcher,
					/obj/item/fighter_component/oxygenator,
					/obj/item/fighter_component/canopy,
					/obj/item/fighter_component/docking_computer,
					/obj/item/fighter_component/battery,
					/obj/item/fighter_component/primary/cannon)
	crate_name = "skrzynia z zestawem startowym lekkiego myśliwca"

/datum/supply_pack/munitions/fighter_construction/heavy
	name = "Zestaw startowy ciężkiego myśliwca"
	desc = "Zestaw „zrób to sam” do budowy ciężkich myśliwców klasy Scimitar, ciężkich maszyn szturmowych, które z gwarancją zrównają miasta z ziemią."
	cost = 15000
	contains = list(/obj/structure/fighter_frame/heavy,
					/obj/item/fighter_component/fuel_tank,
					/obj/item/fighter_component/avionics,
					/obj/item/fighter_component/apu,
					/obj/item/fighter_component/armour_plating,
					/obj/item/fighter_component/targeting_sensor,
					/obj/item/fighter_component/engine,
					/obj/item/fighter_component/countermeasure_dispenser,
					/obj/item/fighter_component/oxygenator,
					/obj/item/fighter_component/canopy,
					/obj/item/fighter_component/docking_computer,
					/obj/item/fighter_component/secondary/ordnance_launcher/torpedo,
					/obj/item/fighter_component/battery,
					/obj/item/fighter_component/primary/cannon/heavy)
	crate_name = "skrzynia z zestawem startowym ciężkiego myśliwca"

/datum/supply_pack/munitions/fighter_construction/utility
	name = "Zestaw startowy jednostki pomocniczej"
	desc = "Zestaw „zrób to sam” do budowy jednostek wsparcia klasy Sabre, zdolnych zaopatrywać i naprawiać myśliwce w walce."
	cost = 10000
	contains = list(/obj/structure/fighter_frame/utility,
					/obj/item/fighter_component/fuel_tank/tier2,
					/obj/item/fighter_component/avionics,
					/obj/item/fighter_component/apu,
					/obj/item/fighter_component/armour_plating,
					/obj/item/fighter_component/targeting_sensor,
					/obj/item/fighter_component/engine,
					/obj/item/fighter_component/oxygenator,
					/obj/item/fighter_component/canopy,
					/obj/item/fighter_component/docking_computer,
					/obj/item/fighter_component/battery,
					/obj/item/fighter_component/secondary/utility/hold,
					/obj/item/fighter_component/primary/utility/refuel,
					/obj/item/fighter_component/countermeasure_dispenser)
	crate_name = "skrzynia z zestawem startowym jednostki pomocniczej"

/datum/supply_pack/munitions/light_cannon
	name = "Amunicja do lekkiego działka"
	desc = "10 pudełek amunicji do lekkiego działka myśliwców."
	cost = 1000
	contains = list(/obj/item/ammo_box/magazine/nsv/light_cannon,
					/obj/item/ammo_box/magazine/nsv/light_cannon,
					/obj/item/ammo_box/magazine/nsv/light_cannon,
					/obj/item/ammo_box/magazine/nsv/light_cannon,
					/obj/item/ammo_box/magazine/nsv/light_cannon,
					/obj/item/ammo_box/magazine/nsv/light_cannon,
					/obj/item/ammo_box/magazine/nsv/light_cannon,
					/obj/item/ammo_box/magazine/nsv/light_cannon,
					/obj/item/ammo_box/magazine/nsv/light_cannon,
					/obj/item/ammo_box/magazine/nsv/light_cannon)
	crate_name = "skrzynia z amunicją do lekkiego działka"

/datum/supply_pack/munitions/heavy_cannon
	name = "Amunicja do ciężkiego działka"
	desc = "10 pudełek amunicji do ciężkiego działka myśliwców."
	cost = 1000
	contains = list(/obj/item/ammo_box/magazine/nsv/heavy_cannon,
					/obj/item/ammo_box/magazine/nsv/heavy_cannon,
					/obj/item/ammo_box/magazine/nsv/heavy_cannon,
					/obj/item/ammo_box/magazine/nsv/heavy_cannon,
					/obj/item/ammo_box/magazine/nsv/heavy_cannon,
					/obj/item/ammo_box/magazine/nsv/heavy_cannon,
					/obj/item/ammo_box/magazine/nsv/heavy_cannon,
					/obj/item/ammo_box/magazine/nsv/heavy_cannon,
					/obj/item/ammo_box/magazine/nsv/heavy_cannon,
					/obj/item/ammo_box/magazine/nsv/heavy_cannon)
	crate_name = "skrzynia z amunicją do ciężkiego działka"

/datum/supply_pack/munitions/broadside_casings
	name = "Puste łuski pocisków burtowych"
	desc = "15 pustych łusek do pocisków burtowych."
	cost = 1000
	contains = list(/obj/item/ship_weapon/parts/broadside_casing,
					/obj/item/ship_weapon/parts/broadside_casing,
					/obj/item/ship_weapon/parts/broadside_casing,
					/obj/item/ship_weapon/parts/broadside_casing,
					/obj/item/ship_weapon/parts/broadside_casing,
					/obj/item/ship_weapon/parts/broadside_casing,
					/obj/item/ship_weapon/parts/broadside_casing,
					/obj/item/ship_weapon/parts/broadside_casing,
					/obj/item/ship_weapon/parts/broadside_casing,
					/obj/item/ship_weapon/parts/broadside_casing,
					/obj/item/ship_weapon/parts/broadside_casing,
					/obj/item/ship_weapon/parts/broadside_casing,
					/obj/item/ship_weapon/parts/broadside_casing,
					/obj/item/ship_weapon/parts/broadside_casing,
					/obj/item/ship_weapon/parts/broadside_casing)
	crate_name = "skrzynia z pustymi łuskami pocisków burtowych"

/datum/supply_pack/munitions/broadside_loads
	name = "Ładunki pocisków burtowych"
	desc = "15 ładunków do pocisków burtowych."
	cost = 1000
	contains = list(/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load)
	crate_name = "skrzynia z ładunkami pocisków burtowych"

/datum/supply_pack/munitions/broadside_pack
	name = "Pakiet burtowy"
	desc = "Dość łusek, ładunków i prochu na jedno pełne załadowanie SNBC."
	cost = 1000
	contains = list(/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_casing,
					/obj/item/ship_weapon/parts/broadside_casing,
					/obj/item/ship_weapon/parts/broadside_casing,
					/obj/item/ship_weapon/parts/broadside_casing,
					/obj/item/ship_weapon/parts/broadside_casing,
					/obj/item/powder_bag)
	crate_name = "skrzynia z pełnym załadunkiem burtowym"

/datum/supply_pack/security/armory/peacekeeper_rifles
	name = "Karabiny pulsacyjne M2A45 (x3)"
	desc = "Paczka 3 karabinów pulsacyjnych M2A45, załadowanych nieśmiercionośnymi pociskami ogłuszającymi."
	cost = 9000
	contains = list(/obj/item/gun/ballistic/automatic/peacekeeper,
					/obj/item/gun/ballistic/automatic/peacekeeper,
					/obj/item/gun/ballistic/automatic/peacekeeper)
	crate_name = "skrzynia z M2A45"

/datum/supply_pack/security/armory/peacekeeper_rifles_single
	name = "Karabin pulsacyjny M2A45 (pojedynczy)"
	desc = "Pojedynczy karabin pulsacyjny M2A45, załadowany nieśmiercionośnymi pociskami ogłuszającymi."
	cost = 3500
	small_item = TRUE
	contains = list(/obj/item/gun/ballistic/automatic/peacekeeper)

/datum/supply_pack/security/glock
	name = "Glocki-13 (x3)"
	desc = "Paczka 3 policyjnych Glocków-13, załadowanych gumowymi kulami."
	cost = 5000
	contains = list(/obj/item/gun/ballistic/automatic/pistol/glock,
					/obj/item/gun/ballistic/automatic/pistol/glock,
					/obj/item/gun/ballistic/automatic/pistol/glock)
	crate_name = "skrzynia z Glockami-13"

/datum/supply_pack/security/glock_single
	name = "Glock-13 (pojedynczy)"
	desc = "Pojedynczy policyjny Glock-13, załadowany gumowymi kulami."
	cost = 2000
	small_item = TRUE
	contains = list(/obj/item/gun/ballistic/automatic/pistol/glock)

/datum/supply_pack/security/edged_weapons
	name = "Jak przetrwać starcie z bronią białą: podręcznik"
	desc = "Podręcznik, dzięki któremu nauczysz się jujitsu!"
	cost = 7000
	contains = list(/obj/item/book/granter/martial/jujitsu)
	crate_name = "skrzynia z podręcznikiem jujitsu"

/datum/supply_pack/security/glock_ammo
	name = "Amunicja do Glocka-13 (nieśmiercionośna)"
	desc = "5 magazynków nieśmiercionośnej amunicji do policyjnej broni bocznej."
	cost = 1500
	contains = list(/obj/item/ammo_box/magazine/glock,
					/obj/item/ammo_box/magazine/glock,
					/obj/item/ammo_box/magazine/glock,
					/obj/item/ammo_box/magazine/glock,
					/obj/item/ammo_box/magazine/glock,
					/obj/item/ammo_box/c9mm/rubber)
	crate_name = "skrzynia z nieśmiercionośną amunicją do Glocka-13"

/datum/supply_pack/security/glock_lethal
	name = "Amunicja do Glocka-13 (śmiercionośna)"
	desc = "5 magazynków śmiercionośnej amunicji do policyjnej broni bocznej."
	cost = 1500
	contains = list(/obj/item/ammo_box/magazine/glock/lethal,
					/obj/item/ammo_box/magazine/glock/lethal,
					/obj/item/ammo_box/magazine/glock/lethal,
					/obj/item/ammo_box/magazine/glock/lethal,
					/obj/item/ammo_box/magazine/glock/lethal,
					/obj/item/ammo_box/c9mm)
	crate_name = "skrzynia ze śmiercionośną amunicją do Glocka-13"
	access = ACCESS_ARMORY

/datum/supply_pack/security/ballistic_tazer
	name = "Skrzynia z paralizatorami CzanekCorp"
	desc = "2 paralizatory CzanekCorp i trochę amunicji do nich (OSTRZEŻENIE: MOGĄ WYWOŁAĆ ZAWAŁ SERCA)."
	cost = 5000
	contains = list(/obj/item/ammo_box/magazine/tazer_cartridge_storage,
					/obj/item/ammo_box/magazine/tazer_cartridge_storage,
					/obj/item/gun/ballistic/tazer,
					/obj/item/gun/ballistic/tazer)
	crate_name = "skrzynia z paralizatorami CzanekCorp"

/datum/supply_pack/security/armory/peacekeeper_ammo
	name = "Amunicja do karabinu pulsacyjnego M2A45 (nieśmiercionośna)"
	desc = "5 magazynków nieśmiercionośnej amunicji do karabinów peacekeeper."
	cost = 800
	contains = list(/obj/item/ammo_box/magazine/peacekeeper,
					/obj/item/ammo_box/magazine/peacekeeper,
					/obj/item/ammo_box/magazine/peacekeeper,
					/obj/item/ammo_box/magazine/peacekeeper,
					/obj/item/ammo_box/magazine/peacekeeper)
	crate_name = "skrzynia z nieśmiercionośną amunicją do M2A45"

/datum/supply_pack/security/armory/peacekeeper_ammo_lethal
	name = "Amunicja do karabinu pulsacyjnego M2A45 (śmiercionośna)"
	desc = "5 magazynków śmiercionośnej amunicji do karabinów peacekeeper."
	cost = 1200
	contains = list(/obj/item/ammo_box/magazine/peacekeeper/lethal,
					/obj/item/ammo_box/magazine/peacekeeper/lethal,
					/obj/item/ammo_box/magazine/peacekeeper/lethal,
					/obj/item/ammo_box/magazine/peacekeeper/lethal,
					/obj/item/ammo_box/magazine/peacekeeper/lethal)
	crate_name = "skrzynia ze śmiercionośną amunicją do M2A45"
	access = ACCESS_ARMORY

/datum/supply_pack/security/armory/laser // NSV - We've got to have them somewhere, apparently.
	name = "Skrzynia z laserami"
	desc = "Zawiera trzy śmiercionośne, wysokoenergetyczne karabiny laserowe."
	cost = 2000
	contains = list(/obj/item/gun/energy/laser,
					/obj/item/gun/energy/laser,
					/obj/item/gun/energy/laser)
	crate_name = "skrzynia z laserami"

/datum/supply_pack/security/mparmor
	name = "Skrzynia uzupełnień dla Policji"
	desc = "Trzy kamizelki kuloodporne Policji wraz z koszulkami Policji, czyli wszystko, by zastąpić to, co pochłonął ogień."
	cost = 3600
	contains = list(/obj/item/clothing/suit/ship/squad/military_police,
					/obj/item/clothing/suit/ship/squad/military_police,
					/obj/item/clothing/suit/ship/squad/military_police,
					/obj/item/clothing/under/ship/military_police,
					/obj/item/clothing/under/ship/military_police,
					/obj/item/clothing/under/ship/military_police,
					/obj/item/clothing/head/helmet/ship/squad/leader,
					/obj/item/clothing/head/helmet/ship/squad/leader,
					/obj/item/clothing/head/helmet/ship/squad/leader)
	crate_name = "skrzynia z pancerzami Policji"

/datum/supply_pack/security/armory/m45single
	name = "Pistolet M1911 (pojedynczy)"
	desc = "Pojedynczy M1911 z pasującym magazynkiem .45."
	cost = 1500
	contains = list(/obj/item/gun/ballistic/automatic/pistol/m1911/no_mag,
				/obj/item/ammo_box/magazine/m45)
	crate_name = "skrzynia z pojedynczym M1911"

/datum/supply_pack/security/armory/m45guns
	name = "Skrzynia z pistoletami M1911"
	desc = "Zawiera 3 pistolety M1911 z 3 magazynkami do każdego z nich."
	cost = 4200
	contains = list(/obj/item/gun/ballistic/automatic/pistol/m1911/no_mag,
					/obj/item/gun/ballistic/automatic/pistol/m1911/no_mag,
					/obj/item/gun/ballistic/automatic/pistol/m1911/no_mag,
					/obj/item/ammo_box/magazine/m45,
					/obj/item/ammo_box/magazine/m45,
					/obj/item/ammo_box/magazine/m45)
	crate_name = "skrzynia z pistoletami M1911"

/datum/supply_pack/security/armory/m45ammo
	name = "Skrzynia z amunicją do M1911"
	desc = "Zawiera 6 magazynków i 2 pudełka amunicji po 3 załadowania każde. Powinno wystarczyć ołowiu na tę świętą krucjatę, o której zawsze marzył twój kapłan."
	cost = 2200
	contains = list(/obj/item/ammo_box/magazine/m45,
					/obj/item/ammo_box/magazine/m45,
					/obj/item/ammo_box/magazine/m45,
					/obj/item/ammo_box/magazine/m45,
					/obj/item/ammo_box/magazine/m45,
					/obj/item/ammo_box/magazine/m45,
					/obj/item/ammo_box/c45/m45,
					/obj/item/ammo_box/c45/m45) // yes, they use the C20R ammo, funny KMC
	crate_name = "skrzynia z amunicją do M1911"

/datum/supply_pack/munitions/fighter_fuel
	name = "Paliwo do myśliwców"
	desc = "Jedna kriogeniczna pompa paliwa tyrozenowego, która w pełni zatankuje 3 myśliwce. Obchodź się ostrożnie."
	cost = 1500
	contains = list(/obj/structure/reagent_dispensers/fueltank/cryogenic_fuel)
	crate_name = "skrzynia z paliwem do myśliwców"

/datum/supply_pack/engineering/control_rods
	name = "Nanowęglowe pręty sterujące reaktora (x5)"
	desc = "5 nanowęglowych prętów sterujących do reaktora napędu burzowego."
	cost = 3000
	contains = list(/obj/item/control_rod,
					/obj/item/control_rod,
					/obj/item/control_rod,
					/obj/item/control_rod,
					/obj/item/control_rod)
	crate_name = "skrzynia z nanowęglowymi prętami sterującymi reaktora"

/datum/supply_pack/engineering/superior_control_rods
	name = "Krystaliczne nanowęglowe pręty sterujące reaktora (x5)"
	desc = "5 krystalicznych nanowęglowych prętów sterujących do reaktora napędu burzowego."
	cost = 8000
	contains = list(/obj/item/control_rod/superior,
					/obj/item/control_rod/superior,
					/obj/item/control_rod/superior,
					/obj/item/control_rod/superior,
					/obj/item/control_rod/superior)
	crate_name = "skrzynia z krystalicznymi nanowęglowymi prętami sterującymi reaktora"

/datum/supply_pack/engineering/armour_plating_nanorepair_well
	name = "Studnia nanonaprawcza płyt pancerza (płytka maszyny)"
	desc = "Zapasowa płytka maszyny do APNW."
	access = ACCESS_CE
	cost = 50000 //These are *really* not meant to be cheap
	contains = list(/obj/item/circuitboard/machine/armour_plating_nanorepair_well)
	crate_name = "skrzynia z płytką studni nanonaprawczej płyt pancerza"

/datum/supply_pack/engineering/armour_plating_nanorepair_pump
	name = "Pompa nanonaprawcza płyt pancerza (płytka maszyny)"
	desc = "Zapasowa płytka maszyny do APNP."
	access = ACCESS_CE
	cost = 25000 //Make sure you look after these
	contains = list(/obj/item/circuitboard/machine/armour_plating_nanorepair_pump)
	crate_name = "skrzynia z płytką pompy nanonaprawczej płyt pancerza"

/datum/supply_pack/engine/stormdrive_core
	name = "Skrzynia z rdzeniem reaktora napędu burzowego"
	desc = "Ta skrzynia zawiera aktywny rdzeń reaktora do jądrowego napędu burzowego klasy IV."
	cost = 35000
	access = ACCESS_CE
	contains = list(/obj/item/stormdrive_core)
	crate_name = "skrzynia z rdzeniem reaktora napędu burzowego"
	crate_type = /obj/structure/closet/crate/secure/engineering
	dangerous = TRUE

/datum/supply_pack/costumes_toys/wardrobes/munitions
	name = "Skrzynia z zaopatrzeniem AmuniSzafy"
	desc = "Ta skrzynia zawiera uzupełnienie do AmuniSzafy."
	cost = 750
	contains = list(/obj/item/vending_refill/wardrobe/muni_wardrobe)
	crate_name = "skrzynia z zaopatrzeniem AmuniSzafy"

/datum/supply_pack/security/armory/mp_smg
	name = "Skrzynia z pistoletami maszynowymi Policji MP-16A4"
	desc = "Zawiera trzy standardowe pistolety maszynowe Policji, przeznaczone do ukrytego noszenia podczas działań na okręcie i abordażu. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 3280 //20%
	contains = list(/obj/item/gun/ballistic/automatic/mp_smg,
					/obj/item/gun/ballistic/automatic/mp_smg,
					/obj/item/gun/ballistic/automatic/mp_smg)
	crate_name = "skrzynia z pistoletami maszynowymi MP-16A4"

/datum/supply_pack/security/armory/mp_smgammo
	name = "Skrzynia z amunicją do pistoletów maszynowych Policji MP-16A4"
	desc = "Zawiera dwa 21-nabojowe magazynki do pistoletu maszynowego peacekeeper i dwa pudełka amunicji 9 mm. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 1700
	contains = list(/obj/item/ammo_box/magazine/smgm9mm,
					/obj/item/ammo_box/magazine/smgm9mm,
					/obj/item/ammo_box/c9mm,
					/obj/item/ammo_box/c9mm)
	crate_name = "skrzynia z amunicją do MP-16A4"

/datum/supply_pack/security/armory/marine_rifle
	name = "Skrzynia z karabinkami szturmowymi M4A-16A1"
	desc = "Zawiera trzy potężne, w pełni automatyczne karabinki szturmowe kalibru 5.56 mm. Ta bardzo silna broń szturmowa jest często używana przez marines podczas abordażu. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 4000 //20%
	contains = list(/obj/item/gun/ballistic/automatic/marine_rifle,
					/obj/item/gun/ballistic/automatic/marine_rifle,
					/obj/item/gun/ballistic/automatic/marine_rifle)
	crate_name = "skrzynia z karabinkami szturmowymi M4A-16A1"

/datum/supply_pack/security/armory/marine_rifle_ammo
	name = "Skrzynia z amunicją do karabinków szturmowych M4A-16A1"
	desc = "Zawiera cztery 30-nabojowe magazynki 5.56 do karabinka M4A16A1 i dwa pudełka amunicji 9 mm do ich napełnienia. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 2000
	contains = list(/obj/item/ammo_box/magazine/m556,
					/obj/item/ammo_box/magazine/m556,
					/obj/item/ammo_box/magazine/m556,
					/obj/item/ammo_box/magazine/m556)
	crate_name = "skrzynia z amunicją do M4A-16A1"

/datum/supply_pack/engineering/hulljuice
	name = "Skrzynia ze zbiornikiem soku kadłubowego"
	desc = "Utrzymaj okręt na powierzchni dzięki zdrowemu SOKOWI do naprawy kadłuba! Zawiera jeden zbiornik i dwie gaśnice. Nakładaj obficie na uszkodzone płyty kadłuba."
	cost = 1200
	contains = list(/obj/structure/reagent_dispensers/foamtank/hull_repair_juice,
					/obj/item/extinguisher/advanced/hull_repair_juice,
					/obj/item/extinguisher/advanced/hull_repair_juice)
	crate_name = "skrzynia inżynieryjna"

//Bottle chem packs - yes I have taken some liberties
/datum/supply_pack/medical/chemical_supply_compounds
	name = "Skrzynia z chemikaliami - związki organiczne"
	desc = "Ta skrzynia zawiera po 3 butelki: etanol i cukier."
	cost = 1000
	hidden = TRUE
	contains = list(/obj/item/reagent_containers/glass/bottle/ethanol,
					/obj/item/reagent_containers/glass/bottle/ethanol,
					/obj/item/reagent_containers/glass/bottle/ethanol,
					/obj/item/reagent_containers/glass/bottle/sugar,
					/obj/item/reagent_containers/glass/bottle/sugar,
					/obj/item/reagent_containers/glass/bottle/sugar)
	crate_name = "skrzynia z chemikaliami - związki organiczne"

/datum/supply_pack/medical/chemical_supply_metals
	name = "Skrzynia z chemikaliami - metale"
	desc = "Ta skrzynia zawiera po 3 butelki: miedź, żelazo, srebro i rtęć."
	cost = 1000
	hidden = TRUE
	contains = list(/obj/item/reagent_containers/glass/bottle/copper,
					/obj/item/reagent_containers/glass/bottle/copper,
					/obj/item/reagent_containers/glass/bottle/copper,
					/obj/item/reagent_containers/glass/bottle/iron,
					/obj/item/reagent_containers/glass/bottle/iron,
					/obj/item/reagent_containers/glass/bottle/iron,
					/obj/item/reagent_containers/glass/bottle/silver,
					/obj/item/reagent_containers/glass/bottle/silver,
					/obj/item/reagent_containers/glass/bottle/silver,
					/obj/item/reagent_containers/glass/bottle/mercury,
					/obj/item/reagent_containers/glass/bottle/mercury,
					/obj/item/reagent_containers/glass/bottle/mercury)
	crate_name = "skrzynia z chemikaliami - metale"

/datum/supply_pack/medical/chemical_supply_alkali_metals
	name = "Skrzynia z chemikaliami - metale alkaliczne"
	desc = "Ta skrzynia zawiera po 3 butelki: wodór, lit, sód i potas."
	cost = 1000
	hidden = TRUE
	contains = list(/obj/item/reagent_containers/glass/bottle/hydrogen,
					/obj/item/reagent_containers/glass/bottle/hydrogen,
					/obj/item/reagent_containers/glass/bottle/hydrogen,
					/obj/item/reagent_containers/glass/bottle/lithium,
					/obj/item/reagent_containers/glass/bottle/lithium,
					/obj/item/reagent_containers/glass/bottle/lithium,
					/obj/item/reagent_containers/glass/bottle/sodium,
					/obj/item/reagent_containers/glass/bottle/sodium,
					/obj/item/reagent_containers/glass/bottle/sodium,
					/obj/item/reagent_containers/glass/bottle/potassium,
					/obj/item/reagent_containers/glass/bottle/potassium,
					/obj/item/reagent_containers/glass/bottle/potassium)
	crate_name = "skrzynia z chemikaliami - metale alkaliczne"

/datum/supply_pack/medical/chemical_supply_pnictogens
	name = "Skrzynia z chemikaliami - azotowce"
	desc = "Ta skrzynia zawiera po 3 butelki: azot i fosfor."
	cost = 1000
	hidden = TRUE
	contains = list(/obj/item/reagent_containers/glass/bottle/nitrogen,
					/obj/item/reagent_containers/glass/bottle/nitrogen,
					/obj/item/reagent_containers/glass/bottle/nitrogen,
					/obj/item/reagent_containers/glass/bottle/phosphorus,
					/obj/item/reagent_containers/glass/bottle/phosphorus,
					/obj/item/reagent_containers/glass/bottle/phosphorus)
	crate_name = "skrzynia z chemikaliami - azotowce"

/datum/supply_pack/medical/chemical_supply_tetrels
	name = "Skrzynia z chemikaliami - węglowce"
	desc = "Ta skrzynia zawiera po 3 butelki: węgiel, krzem i plazma."
	cost = 1000
	hidden = TRUE
	contains = list(/obj/item/reagent_containers/glass/bottle/carbon,
					/obj/item/reagent_containers/glass/bottle/carbon,
					/obj/item/reagent_containers/glass/bottle/carbon,
					/obj/item/reagent_containers/glass/bottle/silicon,
					/obj/item/reagent_containers/glass/bottle/silicon,
					/obj/item/reagent_containers/glass/bottle/silicon,
					/obj/item/reagent_containers/glass/bottle/plasma,
					/obj/item/reagent_containers/glass/bottle/plasma,
					/obj/item/reagent_containers/glass/bottle/plasma)
	crate_name = "skrzynia z chemikaliami - węglowce"

/datum/supply_pack/medical/chemical_supply_alkaline_earth_metals_triels
	name = "Skrzynia z chemikaliami - berylowce i borowce"
	desc = "Ta skrzynia zawiera po 3 butelki: rad i aluminium."
	cost = 1000
	hidden = TRUE
	contains = list(/obj/item/reagent_containers/glass/bottle/radium,
					/obj/item/reagent_containers/glass/bottle/radium,
					/obj/item/reagent_containers/glass/bottle/radium,
					/obj/item/reagent_containers/glass/bottle/aluminium,
					/obj/item/reagent_containers/glass/bottle/aluminium,
					/obj/item/reagent_containers/glass/bottle/aluminium)
	crate_name = "skrzynia z chemikaliami - berylowce i borowce"

/datum/supply_pack/medical/chemical_supply_halogens
	name = "Skrzynia z chemikaliami - fluorowce"
	desc = "Ta skrzynia zawiera po 3 butelki: fluor, chlor, brom i jod."
	cost = 1000
	hidden = TRUE
	contains = list(/obj/item/reagent_containers/glass/bottle/fluorine,
					/obj/item/reagent_containers/glass/bottle/fluorine,
					/obj/item/reagent_containers/glass/bottle/fluorine,
					/obj/item/reagent_containers/glass/bottle/chlorine,
					/obj/item/reagent_containers/glass/bottle/chlorine,
					/obj/item/reagent_containers/glass/bottle/chlorine,
					/obj/item/reagent_containers/glass/bottle/bromine,
					/obj/item/reagent_containers/glass/bottle/bromine,
					/obj/item/reagent_containers/glass/bottle/bromine,
					/obj/item/reagent_containers/glass/bottle/iodine,
					/obj/item/reagent_containers/glass/bottle/iodine,
					/obj/item/reagent_containers/glass/bottle/iodine)
	crate_name = "skrzynia z chemikaliami - fluorowce"

/datum/supply_pack/medical/chemical_supply_chalcogens
	name = "Skrzynia z chemikaliami - tlenowce"
	desc = "Ta skrzynia zawiera po 3 butelki: tlen, siarka i kwas siarkowy."
	cost = 1000
	hidden = TRUE
	contains = list(/obj/item/reagent_containers/glass/bottle/oxygen,
					/obj/item/reagent_containers/glass/bottle/oxygen,
					/obj/item/reagent_containers/glass/bottle/oxygen,
					/obj/item/reagent_containers/glass/bottle/sulfur,
					/obj/item/reagent_containers/glass/bottle/sulfur,
					/obj/item/reagent_containers/glass/bottle/sulfur,
					/obj/item/reagent_containers/glass/bottle/sacid,
					/obj/item/reagent_containers/glass/bottle/sacid,
					/obj/item/reagent_containers/glass/bottle/sacid)
	crate_name = "skrzynia z chemikaliami - tlenowce"

/datum/supply_pack/medical/robotic_firstaid
	name = "Skrzynia z zestawami do leczenia syntetyków"
	desc = "Zawiera trzy robotyczne apteczki do wszelkich napraw syntetyków. W zestawie narzędzia, środek odkażający z promieniowania i medipeny z czyścicielem systemu."
	contains = list(/obj/item/storage/firstaid/robot,
					/obj/item/storage/firstaid/robot,
					/obj/item/storage/firstaid/robot)
	cost = 1400
	small_item = TRUE
	crate_name = "skrzynia z zestawami do leczenia syntetyków"

/datum/supply_pack/materials/plasma_canister //Purely used for the Serendipity's plasma caster
	name = "Kanister foronu"
	desc = "Pojedynczy kanister gazowego foronu na wszystkie twoje potrzeby plazmowe!"
	cost = 2500
	contains = list(
		/obj/machinery/portable_atmospherics/canister/toxins)
	hidden = TRUE
	crate_name = "przenośny kanister gazu z foronem"

//Coffee Related Packs
/datum/supply_pack/service/coffee_kit
	name = "Awaryjny zestaw uzupełnienia kawy"
	desc = "Marines wypili ostatnią kawę na okręcie i teraz nawożą tace hydroponiczne? Klaun zniszczył twoje kubki, a Runtime strąciła dzbanek na podłogę i go rozbiła? Bez obaw, ta skrzynia zawiera wszystko, czego potrzebujesz, by płynna ambrozja znów popłynęła!"
	cost = 1000 //It's a starter pack, so we're not completely greedy, unlike the grill.
	contains = list(/obj/item/reagent_containers/food/drinks/mug,
					/obj/item/reagent_containers/food/drinks/mug,
					/obj/item/reagent_containers/food/drinks/mug,
					/obj/item/reagent_containers/glass/coffeepot,
					/obj/item/coffee_cartridge,
					/obj/item/coffee_cartridge)
	crate_type = /obj/structure/closet/crate/secure // We don't mess around when it comes to those desperate for coffee.
	crate_name = "awaryjna skrzynia z zaopatrzeniem w kawę"

/datum/supply_pack/service/coffee_cartridge
	name = "Uzupełnienie kartridży kawy marynarki"
	desc = "Pięć kartridży z naszymi najlepszymi ziarnami kawy marynarki do wspaniałego ekspresu."
	cost = 3000 //Two thousand more than the Emergency kit, because it's a refill.
	contains = list(/obj/item/coffee_cartridge,
					/obj/item/coffee_cartridge,
					/obj/item/coffee_cartridge,
					/obj/item/coffee_cartridge,
					/obj/item/coffee_cartridge)
	crate_type = /obj/structure/closet/crate/secure // We still don't mess around with our coffee supply, this thing is getting to that machine one way or another
	crate_name = "skrzynia z kartridżami kawy"

/datum/supply_pack/service/coffee_cartridge_fancy
	name = "Uzupełnienie kartridży wymyślnej kawy-śmiecia"
	desc = "Nie wiemy, po co ci kawa o smaku śmieci, skoro jest Kawa Marynarki o wspaniałym smaku ambrozji, ale proszę bardzo. Zawiera 5 kartridży."
	cost = 5000 //It's fancy coffee, so it's pretty expensive because the Navy wants to hoard it all from you.
	contains = list(/obj/item/coffee_cartridge/fancy,
					/obj/item/coffee_cartridge/fancy,
					/obj/item/coffee_cartridge/fancy,
					/obj/item/coffee_cartridge/fancy,
					/obj/item/coffee_cartridge/fancy)
	crate_type = /obj/structure/closet/crate/secure
	crate_name = "skrzynia z kawą-śmieciem"

/datum/supply_pack/service/coffeekit
	name = "Skrzynia ze sprzętem do kawy"
	desc = "Kompletny zestaw do urządzenia własnej przytulnej kawiarenki. Z jakiegoś powodu ekspresu brak w zestawie."
	cost = 2000
	contains = list(/obj/item/storage/box/coffeepack/robusta,
					/obj/item/storage/box/coffeepack/arabica,
					/obj/item/reagent_containers/glass/coffeepot,
					/obj/item/storage/fancy/coffee_condi_display,
					/obj/item/reagent_containers/food/drinks/bottle/cream,
					/obj/item/reagent_containers/food/condiment/milk,
					/obj/item/reagent_containers/food/condiment/soymilk,
					/obj/item/reagent_containers/food/condiment/sugar,
					/obj/item/reagent_containers/glass/bottle/syrup_bottle/caramel)
	crate_name = "skrzynia ze sprzętem do kawy"

/datum/supply_pack/service/coffeemaker
	name = "Skrzynia z ekspresem Pendulum"
	desc = "Złożony ekspres do kawy model Pendulum."
	cost = 4000
	contains = list(/obj/machinery/coffeemaker/pendulum)
	crate_name = "skrzynia z ekspresem do kawy"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/organic/syrup
	name = "Pudełko syropów do kawy"
	desc = "Zapakowane pudełko różnych syropów, idealnych, by twoja pyszna kawa była jeszcze bardziej cukrzycowa."
	cost = 3000
	contains = list(/obj/item/reagent_containers/glass/bottle/syrup_bottle/caramel,
					/obj/item/reagent_containers/glass/bottle/syrup_bottle/liqueur,
					/obj/item/reagent_containers/glass/bottle/syrup_bottle/honey,
					/obj/item/reagent_containers/glass/bottle/syrup_bottle/vanilla,
					/obj/item/reagent_containers/glass/bottle/syrup_bottle/tea,
					/obj/item/reagent_containers/glass/bottle/syrup_bottle/creme_de_cacao,
					/obj/item/reagent_containers/glass/bottle/syrup_bottle/creme_de_menthe)
	crate_name = "pudełko syropów do kawy"
	crate_type = /obj/structure/closet/cardboard

//Countermeasure charges
/datum/design/countermeasure_charge
	name = "Potrójny ładunek środków przeciwdziałania"
	desc = "Potrójny ładunek plew przeciwradarowych dla myśliwca."
	id = "countermeasure_charge"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/copper = 500, /datum/material/titanium = 500)
	build_path = /obj/item/ship_weapon/ammunition/countermeasure_charge
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_ENGINEERING

//Frames
/datum/design/light_frame
	name = "Rama lekkiego myśliwca"
	desc = "Płatowiec lekkiego myśliwca bez podzespołów. Trzeba nad nim jeszcze popracować, żeby wzbił się w powietrze."
	id = "light_frame"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/titanium = 10000, /datum/material/copper = 7500)
	build_path = /obj/structure/fighter_frame
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/heavy_frame
	name = "Rama ciężkiego myśliwca"
	desc = "Płatowiec ciężkiego myśliwca bez podzespołów. Te myśliwce świetnie nadają się do montażu cięższych podzespołów."
	id = "heavy_frame"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 35000, /datum/material/titanium = 20000, /datum/material/copper = 7500)
	build_path = /obj/structure/fighter_frame/heavy
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/utility_frame
	name = "Rama jednostki pomocniczej"
	desc = "Płatowiec jednostki pomocniczej bez podzespołów. Te jednostki świetnie sprawdzają się w liniach zaopatrzenia i potrafią zaopatrywać oraz naprawiać inne statki!"
	id = "utility_frame"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/titanium = 10000, /datum/material/copper = 5000)
	build_path = /obj/structure/fighter_frame/utility
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

//Upgradeable components
//Tier 1
/datum/design/fuel_tank
	name = "Zbiornik paliwa myśliwca"
	desc = "Zbiornik paliwa, który utrzymuje myśliwce w powietrzu."
	id = "fuel_tank"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000)
	build_path = /obj/item/fighter_component/fuel_tank
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/avionics
	name = "Awionika myśliwca"
	desc = "Podzespół do budowy myśliwców."
	id = "avionics"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 5000)
	build_path = /obj/item/fighter_component/avionics
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/apu
	name = "APU myśliwca"
	desc = "Podzespół do budowy myśliwców."
	id = "apu"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/copper = 5000)
	build_path = /obj/item/fighter_component/apu
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/armour_plating
	name = "Pancerz myśliwca"
	desc = "Podzespół do budowy myśliwców."
	id = "armour_plating"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000)
	build_path = /obj/item/fighter_component/armour_plating
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/targeting_sensor
	name = "Czujniki celownicze myśliwca"
	desc = "Podzespół do budowy myśliwców."
	id = "targeting_sensor"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/copper = 10000)
	build_path = /obj/item/fighter_component/targeting_sensor
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/fighter_engine
	name = "Silnik myśliwca"
	desc = "Podzespół do budowy myśliwców."
	id = "fighter_engine"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 2000)
	build_path = /obj/item/fighter_component/engine
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/countermeasure_dispenser
	name = "Wyrzutnik flar myśliwca"
	desc = "Podzespół do budowy myśliwców."
	id = "countermeasure_dispenser"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/copper = 2000)
	build_path = /obj/item/fighter_component/countermeasure_dispenser
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/ordnance_launcher
	name = "Wyrzutnia torped myśliwca"
	desc = "Podzespół do budowy myśliwców."
	id = "ordnance_launcher"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/copper = 2000)
	build_path = /obj/item/fighter_component/secondary/ordnance_launcher/torpedo
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/fighter_missile_launcher
	name = "Wyrzutnia rakiet myśliwca"
	desc = "Podzespół do budowy myśliwców."
	id = "fighter_missile_launcher"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/copper = 2000)
	build_path = /obj/item/fighter_component/secondary/ordnance_launcher
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS


/datum/design/oxygenator
	name = "Regulator atmosfery myśliwca"
	desc = "System regulacji atmosfery dla myśliwców, który kosztem pewnego zużycia energii eliminuje potrzebę noszenia skafandra."
	id = "oxygenator"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 5000)
	build_path = /obj/item/fighter_component/oxygenator
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/docking_computer
	name = "Komputer dokowania myśliwca"
	desc = "Kompletne rozwiązanie do dokowania myśliwców. Absolutnie niezbędne przy operacjach na pokładzie okrętu."
	id = "docking_computer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 5000)
	build_path = /obj/item/fighter_component/docking_computer
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/fighter_battery
	name = "Akumulator myśliwca"
	desc = "Specjalistyczny akumulator kwasowo-ołowiowy, niezbędny do zasilania modułów myśliwca, takich jak APU, oksygenatory i inne!"
	id = "fighter_battery"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 7000, /datum/material/copper = 5000, /datum/material/glass = 2000)
	build_path = /obj/item/fighter_component/battery
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/primary_cannon
	name = "Główne działko myśliwca (lekkie)"
	desc = "Standardowe lekkie działko pasujące do większości myśliwców. Lekkie, tanie, skuteczne. Lekkie działko."
	id = "primary_cannon"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/copper = 7000, /datum/material/glass = 6000)
	build_path = /obj/item/fighter_component/primary/cannon
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/heavy_cannon
	name = "Główne działko myśliwca (ciężkie)"
	desc = "Standardowe ciężkie działko myśliwca, które strzela pociskami większego kalibru. Waży sporo więcej od lekkiej wersji, ale jest niezwykle niszczycielskie."
	id = "heavy_cannon"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/copper = 7000, /datum/material/glass = 6000)
	build_path = /obj/item/fighter_component/primary/cannon/heavy
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/refuel_kit
	name = "Zestaw do tankowania w locie"
	desc = "Zestaw, który pozwala jednostkom pomocniczym przekazywać paliwo i energię innym myśliwcom."
	id = "refuel_kit"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 5000, /datum/material/glass = 5000)
	build_path = /obj/item/fighter_component/primary/utility/refuel
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/cargo_hold
	name = "Ładownia myśliwca"
	desc = "Ładownia dla jednostek pomocniczych."
	id = "cargo_hold"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 5000)
	build_path = /obj/item/fighter_component/secondary/utility/hold
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/repair
	name = "Zestaw do napraw w locie"
	desc = "Moduł, który pozwala jednostkom pomocniczym zdalnie naprawiać myśliwce, gdy jest napełniony płynem do naprawy kadłuba."
	id = "resupply"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 5000)
	build_path = /obj/item/fighter_component/primary/utility/repairer
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/air_plasmacutter
	name = "Montowany przecinak plazmowy"
	desc = "Ciężki przecinak plazmowy 217-A na przegubowym mocowaniu. Przeznaczony dla jednostek pomocniczych klasy Sabre."
	id = "r_cutter"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2000, /datum/material/plasma = 5000)
	build_path = /obj/item/fighter_component/primary/plasmacutter
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

//Tier 2
/datum/design/fuel_tank_tier2
	name = "Ulepszony zbiornik paliwa myśliwca"
	desc = "Ogromny zbiornik paliwa, który utrzymuje myśliwce w powietrzu."
	id = "fuel_tank_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000)
	build_path = /obj/item/fighter_component/fuel_tank/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/apu_tier2
	name = "Ulepszone APU myśliwca"
	desc = "Podzespół do budowy myśliwców."
	id = "apu_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/copper = 15000)
	build_path = /obj/item/fighter_component/apu/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/armour_plating_tier2
	name = "Ulepszony pancerz myśliwca"
	desc = "Podzespół do budowy myśliwców."
	id = "armour_plating_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/titanium = 20000)
	build_path = /obj/item/fighter_component/armour_plating/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/fighter_engine_tier2
	name = "Ulepszony silnik myśliwca"
	desc = "Podzespół do budowy myśliwców."
	id = "fighter_engine_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/diamond = 5000, /datum/material/titanium = 20000)
	build_path = /obj/item/fighter_component/engine/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/ordnance_launcher_tier2
	name = "Ulepszona wyrzutnia torped myśliwca"
	desc = "Podzespół do budowy myśliwców."
	id = "ordnance_launcher_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/copper = 20000, /datum/material/titanium = 20000)
	build_path = /obj/item/fighter_component/secondary/ordnance_launcher/torpedo/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/fighter_missile_launcher_tier2
	name = "Ulepszona wyrzutnia rakiet myśliwca"
	desc = "Podzespół do budowy myśliwców."
	id = "fighter_missile_launcher_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/copper = 12000, /datum/material/titanium = 10000)
	build_path = /obj/item/fighter_component/secondary/ordnance_launcher/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/oxygenator_tier2
	name = "Ulepszony regulator atmosfery myśliwca"
	desc = "System regulacji atmosfery dla myśliwców, który kosztem pewnego zużycia energii eliminuje potrzebę noszenia skafandra."
	id = "oxygenator_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/copper = 15000)
	build_path = /obj/item/fighter_component/oxygenator/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/fighter_battery_tier2
	name = "Ulepszony akumulator myśliwca"
	desc = "Specjalistyczny akumulator kwasowo-ołowiowy, niezbędny do zasilania modułów myśliwca, takich jak APU, oksygenatory i inne!"
	id = "fighter_battery_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 17000, /datum/material/copper = 15000, /datum/material/glass = 12000)
	build_path = /obj/item/fighter_component/battery/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/refuel_kit_tier2
	name = "Ulepszony zestaw do tankowania w locie"
	desc = "Zestaw, który pozwala jednostkom pomocniczym przekazywać paliwo i energię innym myśliwcom."
	id = "refuel_kit_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/copper = 5000, /datum/material/glass = 5000)
	build_path = /obj/item/fighter_component/primary/utility/refuel/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/cargo_hold_tier2
	name = "Ulepszona ładownia myśliwca"
	desc = "Ładownia dla jednostek pomocniczych."
	id = "cargo_hold_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/glass = 15000)
	build_path = /obj/item/fighter_component/secondary/utility/hold/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/repair_tier2
	name = "Ulepszony zestaw do napraw w locie"
	desc = "Moduł, który pozwala jednostkom pomocniczym zdalnie naprawiać myśliwce, gdy jest napełniony płynem do naprawy kadłuba."
	id = "resupply_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 15000)
	build_path = /obj/item/fighter_component/primary/utility/repairer/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING
//Tier 3
/datum/design/fuel_tank_tier3
	name = "Eksperymentalny zbiornik paliwa myśliwca"
	desc = "Absurdalnie duży zbiornik paliwa, który utrzymuje myśliwce w powietrzu."
	id = "fuel_tank_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/titanium = 25000, /datum/material/glass = 25000)
	build_path = /obj/item/fighter_component/fuel_tank/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/apu_tier3
	name = "Eksperymentalne APU myśliwca"
	desc = "Podzespół do budowy myśliwców."
	id = "apu_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/copper = 15000, /datum/material/titanium = 25000)
	build_path = /obj/item/fighter_component/apu/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/armour_plating_tier3
	name = "Eksperymentalny pancerz myśliwca"
	desc = "Podzespół do budowy myśliwców."
	id = "armour_plating_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/plasma = 20000, /datum/material/diamond = 25000)
	build_path = /obj/item/fighter_component/armour_plating/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/fighter_engine_tier3
	name = "Eksperymentalny silnik myśliwca"
	desc = "Podzespół do budowy myśliwców."
	id = "fighter_engine_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 35000, /datum/material/uranium = 15000, /datum/material/diamond = 10000, /datum/material/titanium = 20000)
	build_path = /obj/item/fighter_component/engine/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/ordnance_launcher_tier3
	name = "Eksperymentalna wyrzutnia torped myśliwca"
	desc = "Podzespół do budowy myśliwców."
	id = "ordnance_launcher_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/plasma = 25000, /datum/material/copper = 20000, /datum/material/titanium = 20000)
	build_path = /obj/item/fighter_component/secondary/ordnance_launcher/torpedo/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/fighter_missile_launcher_tier3
	name = "Eksperymentalna wyrzutnia rakiet myśliwca"
	desc = "Podzespół do budowy myśliwców."
	id = "fighter_missile_launcher_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/plasma = 15000, /datum/material/copper = 12000, /datum/material/titanium = 10000)
	build_path = /obj/item/fighter_component/secondary/ordnance_launcher/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/oxygenator_tier3
	name = "Eksperymentalny regulator atmosfery myśliwca"
	desc = "System regulacji atmosfery dla myśliwców, który kosztem pewnego zużycia energii eliminuje potrzebę noszenia skafandra."
	id = "oxygenator_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/titanium = 15000)
	build_path = /obj/item/fighter_component/oxygenator/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/fighter_battery_tier3
	name = "Eksperymentalny akumulator myśliwca"
	desc = "Specjalistyczny akumulator kwasowo-ołowiowy, niezbędny do zasilania modułów myśliwca, takich jak APU, oksygenatory i inne!"
	id = "fighter_battery_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/titanium = 15000, /datum/material/diamond = 5000)
	build_path = /obj/item/fighter_component/battery/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/refuel_kit_tier3
	name = "Eksperymentalny zestaw do tankowania w locie"
	desc = "Zestaw, który pozwala jednostkom pomocniczym przekazywać paliwo i energię innym myśliwcom."
	id = "refuel_kit_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/copper = 7000, /datum/material/glass = 10000)
	build_path = /obj/item/fighter_component/primary/utility/refuel/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/cargo_hold_tier3
	name = "Eksperymentalna ładownia myśliwca"
	desc = "Ładownia dla jednostek pomocniczych."
	id = "cargo_hold_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 35000, /datum/material/titanium = 15000)
	build_path = /obj/item/fighter_component/secondary/utility/hold/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/repair_tier3
	name = "Eksperymentalny zestaw do napraw w locie"
	desc = "Moduł, który pozwala jednostkom pomocniczym zdalnie naprawiać myśliwce, gdy jest napełniony płynem do naprawy kadłuba."
	id = "resupply_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/glass = 15000, /datum/material/titanium = 5000 )
	build_path = /obj/item/fighter_component/primary/utility/repairer/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

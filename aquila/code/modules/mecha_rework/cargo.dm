// AQUILA - zakup mechów, zestawów i amunicji w cargo (wzór: code/modules/cargo/packs/mechs.dm z Shiptestu).
// Gotowe mechy przychodzą z ogniwem i częściami, zestawy konwersji osobno. Nowe zakładki fabrykatora egzoszkieletów.

/obj/machinery/modular_fabricator/exosuit_fab/Initialize(mapload)
	categories = categories.Copy()
	categories |= list("Clarke", "Savannah-Ivanov", "Red Sunday", "Sentinel", "Modular")
	return ..()

/datum/supply_pack/engineering/aq_ripley_complete
	name = "Używany APLU MK-I \"Ripley\""
	desc = "Złożony, używany Ripley MK-I z ogniwem, wiertłem i chwytakiem. Prosto z magazynu, gotowy do pracy."
	cost = 6000
	access_budget = FALSE
	contains = list(/obj/mecha/working/ripley,
					/obj/item/mecha_parts/mecha_equipment/drill,
					/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp)
	crate_name = "skrzynia z mechem APLU"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/engineering/aq_clarke
	name = "Zestaw do budowy Clarke'a"
	desc = "Rama, części i płytki górniczego mecha Clarke. Ogniwo, kondensator i moduł skanujący w zestawie."
	cost = 4000
	access_budget = FALSE
	contains = list(/obj/item/mecha_parts/chassis/aq/clarke,
					/obj/item/mecha_parts/part/aq/clarke_torso,
					/obj/item/mecha_parts/part/aq/clarke_head,
					/obj/item/mecha_parts/part/aq/clarke_left_arm,
					/obj/item/mecha_parts/part/aq/clarke_right_arm,
					/obj/item/mecha_parts/part/aq/clarke_treads,
					/obj/item/circuitboard/mecha/aq_clarke/main,
					/obj/item/circuitboard/mecha/aq_clarke/peripherals,
					/obj/item/stock_parts/cell/high,
					/obj/item/stock_parts/capacitor,
					/obj/item/stock_parts/scanning_module)
	crate_name = "zestaw Clarke'a"

/datum/supply_pack/engineering/aq_mech_equipment
	name = "Skrzynia wyposażenia mechów"
	desc = "Zestaw narzędzi inżynieryjnych, szczęki ratownicze, aktywne chłodzenie i płyta pancerza dla mechów roboczych."
	cost = 2500
	access_budget = FALSE
	contains = list(/obj/item/mecha_parts/mecha_equipment/aq_tool/toolset,
					/obj/item/mecha_parts/mecha_equipment/aq_tool/rescue_jaw,
					/obj/item/mecha_parts/mecha_equipment/aq_cooling/active,
					/obj/item/mecha_parts/aq_armor_plating)
	crate_name = "skrzynia wyposażenia mechów"

/datum/supply_pack/engineering/aq_mech_drop
	name = "Skrzynia systemu zrzutu mechów"
	desc = "System zrzutu orbitalnego dla jednego mecha i dwie latarnie zrzutu do rozstawienia na planecie."
	cost = 5000
	access_budget = ACCESS_ROBOTICS
	contains = list(/obj/item/mecha_parts/mecha_equipment/aq_drop_system,
					/obj/item/aq_mech_drop_beacon,
					/obj/item/aq_mech_drop_beacon)
	crate_name = "skrzynia systemu zrzutu"

/datum/supply_pack/security/aq_paddy
	name = "Zestaw konwersji APLU \"Paddy\""
	desc = "Zestaw przerabiający Ripleya MK-I na mech ochrony Paddy, z chwytakiem na ludzi i wyrzutnią bol."
	cost = 3500
	contains = list(/obj/item/mecha_parts/mecha_equipment/aq_conversion_kit/paddy,
					/obj/item/mecha_parts/mecha_equipment/aq_tool/paddy_claw,
					/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/aq_bola)
	crate_name = "zestaw Paddy"

/datum/supply_pack/security/aq_mech_kits
	name = "Zestawy konwersji mechów bojowych"
	desc = "Zestawy frakcyjne z Rubieży: CLIP Paladin dla Duranda i IRMG Basenji dla Gygaxa."
	cost = 6000
	contains = list(/obj/item/mecha_parts/mecha_equipment/aq_conversion_kit/paladin,
					/obj/item/mecha_parts/mecha_equipment/aq_conversion_kit/basenji)
	crate_name = "zestawy konwersji mechów"

/datum/supply_pack/security/aq_mech_ammo
	name = "Skrzynia amunicji do mechów"
	desc = "Taśma do lekkiego karabinu maszynowego, śrut, amunicja zapalająca i rakiety SRM-8 dla mechów bojowych."
	cost = 3000
	contains = list(/obj/item/mecha_ammo/lmg,
					/obj/item/mecha_ammo/scattershot,
					/obj/item/mecha_ammo/incendiary,
					/obj/item/mecha_ammo/missiles_he)
	crate_name = "skrzynia amunicji do mechów"

/datum/supply_pack/security/aq_mech_magazines
	name = "Skrzynia magazynków do mechów"
	desc = "Magazynki do karabinu UMG-2 i Executora oraz amunicja portów strzeleckich M56."
	cost = 2500
	contains = list(/obj/item/mecha_ammo/umg2,
					/obj/item/mecha_ammo/umg2,
					/obj/item/mecha_ammo/executor,
					/obj/item/mecha_ammo/fpw)
	crate_name = "skrzynia magazynków do mechów"

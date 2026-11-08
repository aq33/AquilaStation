// Hardsuity z gotowymi modułami: zastępują dawne gotowe MODsuity (pre_equipped, port BeeStation).
// Listy modułów przepisane z dawnych applied_modules i wbudowanych modułów motywów, bez usuniętych modułów,
// bez plecaków odrzutowych MOD (hardsuity mają własny /obj/item/tank/jetpack/suit) i bez insygniów
// (hardsuit nie rysuje nakładek modułów, więc insygnia nic by nie robiły).
// Wygląd i statystyki zostają z bazowego hardsuitu, nowe sprite'y nie powstały.

////////////////////////////////////////////////////////////////////
//							STATEK								  //
////////////////////////////////////////////////////////////////////

/// Kapitan (dawny MODsuit magnata)
/obj/item/clothing/suit/space/hardsuit/swat/captain/loaded
	initial_cell = /obj/item/stock_parts/cell/hyper
	initial_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/hat_stabilizer,
		/obj/item/mod/module/magnetic_harness,
	)

/// Inżynier (dawny inżynieryjny MODsuit)
/obj/item/clothing/suit/space/hardsuit/engine/loaded
	initial_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/tether,
		/obj/item/mod/module/magboot,
	)

/// Główny inżynier (dawny zaawansowany MODsuit)
/obj/item/clothing/suit/space/hardsuit/engine/elite/loaded
	initial_cell = /obj/item/stock_parts/cell/super
	initial_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/tether,
		/obj/item/mod/module/magboot/advanced,
	)

/// Szef ochrony (dawny MODsuit strażnika)
/obj/item/clothing/suit/space/hardsuit/security/head_of_security/loaded
	initial_cell = /obj/item/stock_parts/cell/super
	initial_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/megaphone,
		/obj/item/mod/module/projectile_dampener,
		/obj/item/mod/module/pepper_shoulders,
	)

/// Lekarz (dawny medyczny MODsuit)
/obj/item/clothing/suit/space/hardsuit/medical/loaded
	initial_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/health_analyzer,
		/obj/item/mod/module/quick_carry,
	)

/// Ordynator (dawny ratunkowy MODsuit)
/obj/item/clothing/suit/space/hardsuit/medical/cmo/loaded
	initial_cell = /obj/item/stock_parts/cell/super
	initial_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/health_analyzer,
		/obj/item/mod/module/injector,
		/obj/item/mod/module/quick_carry/advanced,
	)

/// Ładowacz z zaopatrzenia (dawny MODsuit ładowacza)
/obj/item/clothing/suit/space/hardsuit/mining/loader
	initial_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/hydraulic,
		/obj/item/mod/module/clamp/loader,
		/obj/item/mod/module/magnet,
	)

////////////////////////////////////////////////////////////////////
//							SYNDYKAT							  //
////////////////////////////////////////////////////////////////////

/// Agent Syndykatu z uplinka (dawny MODsuit Syndykatu)
/obj/item/clothing/suit/space/hardsuit/syndi/loaded
	initial_cell = /obj/item/stock_parts/cell/super
	initial_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/dna_lock,
		/obj/item/mod/module/hat_stabilizer/syndicate,
	)

/// Elitarny agent Syndykatu z uplinka (dawny elitarny MODsuit Syndykatu)
/obj/item/clothing/suit/space/hardsuit/syndi/elite/loaded
	initial_cell = /obj/item/stock_parts/cell/bluespace
	initial_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/dna_lock,
		/obj/item/mod/module/hat_stabilizer/syndicate,
	)

/// Agent nuklearny w szafie na skafandry (dawny nuklearny MODsuit)
/obj/item/clothing/suit/space/hardsuit/syndi/nuclear
	initial_cell = /obj/item/stock_parts/cell/hyper
	initial_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/hat_stabilizer/syndicate,
	)

/// Zestaw infiltratora z uplinka (dawny MODsuit infiltratora)
/obj/item/clothing/suit/space/hardsuit/infiltration/loaded
	initial_cell = /obj/item/stock_parts/cell/super
	initial_modules = list(
		/obj/item/mod/module/infiltrator,
		/obj/item/mod/module/storage/belt,
		/obj/item/mod/module/demoralizer,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/quick_carry,
		/obj/item/mod/module/visor/diaghud,
		/obj/item/mod/module/hat_stabilizer/syndicate,
	)

////////////////////////////////////////////////////////////////////
//						CZARODZIEJ I NINJA						  //
////////////////////////////////////////////////////////////////////

/// Zbroja maga bitewnego z księgi zaklęć (dawny zaczarowany MODsuit). Tarczę daje moduł, nie sam kombinezon.
/obj/item/clothing/suit/space/hardsuit/wizard/battlemage
	name = "zbroja maga bitewnego"
	desc = "Zaczarowany hardsuit, który pozwala rzucać zaklęcia. Chroni go potężna, odnawialna tarcza, a runy na płytach trzymają próżnię kosmosu z dala od noszącego."
	icon_state = "battlemage"
	item_state = "battlemage"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/wizard
	slowdown = 0
	initial_core = /obj/item/mod/core/infinite
	initial_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/energy_shield/wizard,
		/obj/item/mod/module/emp_shield/advanced,
		/obj/item/mod/module/anti_magic/wizard,
	)

/// Skafander ninja Klanu Pająka (dawny MODsuit ninja), wygląd dawnego skafandra ninja
/obj/item/clothing/suit/space/hardsuit/ninja
	name = "skafander ninja"
	desc = "Unikalny, szczelny na próżnię, nanowzmocniony pancerz zaprojektowany specjalnie dla zabójców Klanu Pająka."
	icon_state = "s-ninja"
	item_state = "s-ninja_suit"
	armor = list("melee" = 40, "bullet" = 30, "laser" = 20, "energy" = 30, "bomb" = 30, "bio" = 100, "rad" = 60, "fire" = 100, "acid" = 100, "stamina" = 60, "bleed" = 60)
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	allowed = list(/obj/item/gun, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/energy_katana)
	slowdown = 0
	strip_delay = 12
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ninja
	jetpack = /obj/item/tank/jetpack/suit
	charge_drain = DEFAULT_CHARGE_DRAIN * 0.5
	complexity_max = DEFAULT_MAX_COMPLEXITY + 2
	initial_cell = /obj/item/stock_parts/cell/ninja
	initial_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/noslip,
		/obj/item/mod/module/status_readout/ninja,
		/obj/item/mod/module/stealth/ninja,
		/obj/item/mod/module/dispenser/ninja,
		/obj/item/mod/module/dna_lock/reinforced,
		/obj/item/mod/module/emp_shield/pulse,
		/obj/item/mod/module/welding/camera_vision,
		/obj/item/mod/module/hacker,
		/obj/item/mod/module/weapon_recall,
		/obj/item/mod/module/adrenaline_boost,
		/obj/item/mod/module/energy_net,
	)

/// Sam wygląd do podglądu roli (bez modułów i rdzenia)
/obj/item/clothing/suit/space/hardsuit/ninja/empty
	initial_core = null
	jetpack = null
	initial_modules = list()

/obj/item/clothing/head/helmet/space/hardsuit/ninja
	name = "kaptur ninja"
	desc = "Wygląda jak zwykła czarna tkanina, ale to zaawansowany hełm z nanosplotu. Standardowe wyposażenie ninja."
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	armor = list("melee" = 40, "bullet" = 30, "laser" = 20, "energy" = 30, "bomb" = 30, "bio" = 100, "rad" = 60, "fire" = 100, "acid" = 100, "stamina" = 60, "bleed" = 60)
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	strip_delay = 12
	blockTracking = TRUE
	actions_types = null //bez latarki, kaptur nie ma wersji ze światłem

/obj/item/clothing/head/helmet/space/hardsuit/ninja/attack_self(mob/user)
	return

////////////////////////////////////////////////////////////////////
//						CENTCOM I ZRK							  //
////////////////////////////////////////////////////////////////////

/// Dowódca ZRK (dawny MODsuit reagowania z insygniami dowódcy)
/obj/item/clothing/suit/space/hardsuit/ert/loaded
	initial_cell = /obj/item/stock_parts/cell/hyper
	initial_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/power_kick,
	)

/// Operator ZRK
/obj/item/clothing/suit/space/hardsuit/ert/sec/loaded
	initial_cell = /obj/item/stock_parts/cell/hyper
	initial_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/gps,
		/obj/item/mod/module/pepper_shoulders,
	)

/// Sanitariusz ZRK
/obj/item/clothing/suit/space/hardsuit/ert/med/loaded
	initial_cell = /obj/item/stock_parts/cell/hyper
	initial_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/quick_carry,
	)

/// Inżynier ZRK
/obj/item/clothing/suit/space/hardsuit/ert/engi/loaded
	initial_cell = /obj/item/stock_parts/cell/hyper
	initial_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
	)

/// Woźny ZRK
/obj/item/clothing/suit/space/hardsuit/ert/jani/loaded
	initial_cell = /obj/item/stock_parts/cell/hyper
	initial_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/clamp,
	)

/// Kapelan ZRK (zawsze w hardsuicie inkwizytora)
/obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor/chaplain
	initial_cell = /obj/item/stock_parts/cell/hyper
	initial_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/injector,
	)

/// Dowódca Inkwizycji (dawny MODsuit inkwizycji)
/obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisition_commander
	initial_cell = /obj/item/stock_parts/cell/hyper
	initial_modules = list(
		/obj/item/mod/module/anti_magic,
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
	)

/// Inkwizytor (dawny MODsuit inkwizycji bez dodatków, łup w domenie bitrunnerów)
/obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor/loaded
	initial_cell = /obj/item/stock_parts/cell/hyper
	initial_modules = list(
		/obj/item/mod/module/anti_magic,
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
	)

/// Ochroniarz Inkwizycji
/obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor/loaded/security
	initial_modules = list(
		/obj/item/mod/module/anti_magic,
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/pepper_shoulders,
	)

/// Sanitariusz Inkwizycji
/obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor/loaded/medic
	initial_modules = list(
		/obj/item/mod/module/anti_magic,
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/quick_carry,
	)

/// Kapelan Inkwizycji
/obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor/loaded/chaplain
	initial_modules = list(
		/obj/item/mod/module/anti_magic,
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/injector,
	)

/// Komandos szwadronu śmierci (dawny apokryficzny MODsuit)
/obj/item/clothing/suit/space/hardsuit/deathsquad/loaded
	initial_cell = /obj/item/stock_parts/cell/bluespace
	initial_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield/advanced,
		/obj/item/mod/module/magnetic_harness,
	)

/// Oficer szwadronu śmierci
/obj/item/clothing/suit/space/hardsuit/deathsquad/loaded/officer
	initial_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/hat_stabilizer,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield/advanced,
		/obj/item/mod/module/magnetic_harness,
	)

/// Dowódca CentComu i szafa CentComu (dawny korporacyjny MODsuit)
/obj/item/clothing/suit/space/hardsuit/ert/corporate
	initial_core = /obj/item/mod/core/infinite
	initial_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/hat_stabilizer,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/emp_shield/advanced,
	)

////////////////////////////////////////////////////////////////////
//							ADMINISTRACJA						  //
////////////////////////////////////////////////////////////////////

/// Strój debugowy (dawny MODsuit debugowy)
/obj/item/clothing/suit/space/hardsuit/syndi/elite/debug
	initial_core = /obj/item/mod/core/infinite
	complexity_max = 50
	initial_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/tether,
		/obj/item/mod/module/injector,
	)

/// Strój admina (dawny administracyjny MODsuit)
/obj/item/clothing/suit/space/hardsuit/syndi/elite/admin
	initial_core = /obj/item/mod/core/infinite
	complexity_max = 1000
	initial_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/emp_shield/advanced,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/stealth/ninja,
		/obj/item/mod/module/quick_carry/advanced,
		/obj/item/mod/module/magboot/advanced,
	)

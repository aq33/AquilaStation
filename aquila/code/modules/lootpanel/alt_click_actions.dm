// AQUILA - typy z własną akcją Alt+klik (nadpisują AltClick): nie otwierają okna kafelka z RPG Loot,
// tak jak TRAIT_ALT_CLICK_BLOCKER w tgstation/tgstation#82533. Podtypy dziedziczą. Listę sprawdza
// tools/ci/check_alt_click_loot.py: nowy typ z AltClick trzeba tu dopisać (albo świadomie zostawić okno).
// Kafelek pod spodem nadal da się przejrzeć Alt+klikiem na podłogę.

/atom/movable/screen/movable/action_button/hide_toggle
	alt_click_loot = FALSE

/mob/living/silicon/robot
	alt_click_loot = FALSE

/mob/living/simple_animal/bot
	alt_click_loot = FALSE

/mob/living/simple_animal/hostile/heretic_summon/star_gazer
	alt_click_loot = FALSE

/mob/living/simple_animal/hostile/mining_drone
	alt_click_loot = FALSE

/mob/living/simple_animal/slime
	alt_click_loot = FALSE

/obj/abstract/mind_ui_element/hoverable/movable
	alt_click_loot = FALSE

/obj/effect/sound_emitter
	alt_click_loot = FALSE

/obj/item/airlock_painter
	alt_click_loot = FALSE

/obj/item/analyzer
	alt_click_loot = FALSE

/obj/item/assembly/health
	alt_click_loot = FALSE

/obj/item/attachment/laser_sight
	alt_click_loot = FALSE

/obj/item/borg/apparatus
	alt_click_loot = FALSE

/obj/item/broadcast_camera
	alt_click_loot = FALSE

/obj/item/camera
	alt_click_loot = FALSE

/obj/item/card/id
	alt_click_loot = FALSE

/obj/item/circuitboard/machine/dish_drive
	alt_click_loot = FALSE

/obj/item/clipboard
	alt_click_loot = FALSE

/obj/item/clothing/accessory
	alt_click_loot = FALSE

/obj/item/clothing/glasses
	alt_click_loot = FALSE

/obj/item/clothing/head/fedora/det_hat
	alt_click_loot = FALSE

/obj/item/clothing/head/hardhat/weldhat
	alt_click_loot = FALSE

/obj/item/clothing/head/helmet/riot
	alt_click_loot = FALSE

/obj/item/clothing/head/helmet/space/hardsuit
	alt_click_loot = FALSE

/obj/item/clothing/head/helmet/space/plasmaman
	alt_click_loot = FALSE

/obj/item/clothing/head/soft
	alt_click_loot = FALSE

/obj/item/clothing/mask/bandana
	alt_click_loot = FALSE

/obj/item/clothing/mask/breath
	alt_click_loot = FALSE

/obj/item/clothing/neck/neckerchief
	alt_click_loot = FALSE

/obj/item/clothing/suit/hooded/wintercoat
	alt_click_loot = FALSE

/obj/item/clothing/suit/space/hardsuit
	alt_click_loot = FALSE

/obj/item/clothing/suit/toggle
	alt_click_loot = FALSE

/obj/item/clothing/under
	alt_click_loot = FALSE

/obj/item/construction/plumbing
	alt_click_loot = FALSE

/obj/item/desynchronizer
	alt_click_loot = FALSE

/obj/item/detective_scanner
	alt_click_loot = FALSE

/obj/item/extinguisher
	alt_click_loot = FALSE

/obj/item/fighter_component
	alt_click_loot = FALSE

/obj/item/flamethrower
	alt_click_loot = FALSE

/obj/item/flashlight/atc_wavy_sticks
	alt_click_loot = FALSE

/obj/item/folder
	alt_click_loot = FALSE

/obj/item/geiger_counter
	alt_click_loot = FALSE

/obj/item/grenade/barrier
	alt_click_loot = FALSE

/obj/item/gun/ballistic
	alt_click_loot = FALSE

/obj/item/healthanalyzer
	alt_click_loot = FALSE

/obj/item/holochip
	alt_click_loot = FALSE

/obj/item/implantpad
	alt_click_loot = FALSE

/obj/item/mining_scanner
	alt_click_loot = FALSE

/obj/item/modular_computer
	alt_click_loot = FALSE

/obj/item/munition_cast
	alt_click_loot = FALSE

/obj/item/nanite_remote
	alt_click_loot = FALSE

/obj/item/paper
	alt_click_loot = FALSE

/obj/item/perfume
	alt_click_loot = FALSE

/obj/item/pet_carrier
	alt_click_loot = FALSE

/obj/item/pickaxe/drill/implant
	alt_click_loot = FALSE

/obj/item/plant_seeds/debug
	alt_click_loot = FALSE

/obj/item/quantum_keycard
	alt_click_loot = FALSE

/obj/item/radio
	alt_click_loot = FALSE

/obj/item/reagent_containers/borghypo
	alt_click_loot = FALSE

/obj/item/reagent_containers/food/drinks/coffee/empty
	alt_click_loot = FALSE

/obj/item/reagent_containers/food/drinks/modglass
	alt_click_loot = FALSE

/obj/item/reagent_containers/glass/bottle/syrup_bottle
	alt_click_loot = FALSE

/obj/item/reagent_containers/glass/mortar
	alt_click_loot = FALSE

/obj/item/reagent_containers/glass/waterbottle
	alt_click_loot = FALSE

/obj/item/reagent_containers/hypospray/autoinjector
	alt_click_loot = FALSE

/obj/item/resonator
	alt_click_loot = FALSE

/obj/item/slimecross/gentle
	alt_click_loot = FALSE

/obj/item/soundsynth
	alt_click_loot = FALSE

/obj/item/spear/explosive
	alt_click_loot = FALSE

/obj/item/stack
	alt_click_loot = FALSE

/obj/item/sticker/artifact_tracker
	alt_click_loot = FALSE

/obj/item/sticker/trait_pearl/debug
	alt_click_loot = FALSE

/obj/item/storage/belt/sabre
	alt_click_loot = FALSE

/obj/item/storage/fancy/cigarettes
	alt_click_loot = FALSE

/obj/item/storage/lockbox/medal
	alt_click_loot = FALSE

/obj/item/storage/pod
	alt_click_loot = FALSE

/obj/item/supplypod_beacon
	alt_click_loot = FALSE

/obj/item/swapper
	alt_click_loot = FALSE

/obj/item/t_scanner/adv_mining_scanner
	alt_click_loot = FALSE

/obj/item/tome
	alt_click_loot = FALSE

/obj/item/toy/cards/singlecard/cas
	alt_click_loot = FALSE

/obj/item/toy/crayon/spraycan
	alt_click_loot = FALSE

/obj/item/xenoarchaeology_labeler/debug
	alt_click_loot = FALSE

/obj/machinery/advanced_airlock_controller
	alt_click_loot = FALSE

/obj/machinery/airalarm
	alt_click_loot = FALSE

/obj/machinery/ammo_sorter
	alt_click_loot = FALSE

/obj/machinery/anesthetic_machine
	alt_click_loot = FALSE

/obj/machinery/atmospherics
	alt_click_loot = FALSE

/obj/machinery/aug_manipulator
	alt_click_loot = FALSE

/obj/machinery/autoinject_printer
	alt_click_loot = FALSE

/obj/machinery/big_broadcast_camera
	alt_click_loot = FALSE

/obj/machinery/biogenerator
	alt_click_loot = FALSE

/obj/machinery/broadside_shell_packer
	alt_click_loot = FALSE

/obj/machinery/chem_dispenser
	alt_click_loot = FALSE

/obj/machinery/chem_heater
	alt_click_loot = FALSE

/obj/machinery/chem_master
	alt_click_loot = FALSE

/obj/machinery/clonepod
	alt_click_loot = FALSE

/obj/machinery/computer/ai_control_console
	alt_click_loot = FALSE

/obj/machinery/computer/card
	alt_click_loot = FALSE

/obj/machinery/computer/cloning
	alt_click_loot = FALSE

/obj/machinery/computer/emergency_shuttle
	alt_click_loot = FALSE

/obj/machinery/computer/nanite_cloud_controller
	alt_click_loot = FALSE

/obj/machinery/computer/piratepad_control/civilian
	alt_click_loot = FALSE

/obj/machinery/computer/plant_machine_controller
	alt_click_loot = FALSE

/obj/machinery/computer/prisoner
	alt_click_loot = FALSE

/obj/machinery/computer/reactor/pump
	alt_click_loot = FALSE

/obj/machinery/computer/scan_consolenew
	alt_click_loot = FALSE

/obj/machinery/computer/shuttle_flight/custom_shuttle
	alt_click_loot = FALSE

/obj/machinery/conveyor_switch
	alt_click_loot = FALSE

/obj/machinery/defibrillator_mount
	alt_click_loot = FALSE

/obj/machinery/dish_drive
	alt_click_loot = FALSE

/obj/machinery/dna_infuser
	alt_click_loot = FALSE

/obj/machinery/fat_sucker
	alt_click_loot = FALSE

/obj/machinery/harvester
	alt_click_loot = FALSE

/obj/machinery/mineral/ore_redemption
	alt_click_loot = FALSE

/obj/machinery/mineral/processing_unit
	alt_click_loot = FALSE

/obj/machinery/mineral/processing_unit_console
	alt_click_loot = FALSE

/obj/machinery/missile_builder
	alt_click_loot = FALSE

/obj/machinery/modular_computer
	alt_click_loot = FALSE

/obj/machinery/munitions_forge
	alt_click_loot = FALSE

/obj/machinery/nanite_program_hub
	alt_click_loot = FALSE

/obj/machinery/nanite_programmer
	alt_click_loot = FALSE

/obj/machinery/netpod
	alt_click_loot = FALSE

/obj/machinery/pdapainter
	alt_click_loot = FALSE

/obj/machinery/portable_atmospherics
	alt_click_loot = FALSE

/obj/machinery/power/apc
	alt_click_loot = FALSE

/obj/machinery/power/generator
	alt_click_loot = FALSE

/obj/machinery/refillable_chem_dispenser
	alt_click_loot = FALSE

/obj/machinery/sleeper
	alt_click_loot = FALSE

/obj/machinery/slime_compressor
	alt_click_loot = FALSE

/obj/machinery/species_converter
	alt_click_loot = FALSE

/obj/machinery/stasis
	alt_click_loot = FALSE

/obj/machinery/washing_machine
	alt_click_loot = FALSE

/obj/mecha
	alt_click_loot = FALSE

/obj/structure/aquarium
	alt_click_loot = FALSE

/obj/structure/bodycontainer/morgue
	alt_click_loot = FALSE

/obj/structure/c_transit_tube
	alt_click_loot = FALSE

/obj/structure/chair
	alt_click_loot = FALSE

/obj/structure/closet
	alt_click_loot = FALSE

/obj/structure/etherealball
	alt_click_loot = FALSE

/obj/structure/extinguisher_cabinet
	alt_click_loot = FALSE

/obj/structure/frame/computer
	alt_click_loot = FALSE

/obj/structure/liquid_pump
	alt_click_loot = FALSE

/obj/structure/marker_beacon
	alt_click_loot = FALSE

/obj/structure/munitions_trolley
	alt_click_loot = FALSE

/obj/structure/peacekeeper_barricade
	alt_click_loot = FALSE

/obj/structure/railing
	alt_click_loot = FALSE

/obj/structure/reagent_dispensers/plumbed/storage
	alt_click_loot = FALSE

/obj/structure/reflector
	alt_click_loot = FALSE

/obj/structure/shadowcocoon
	alt_click_loot = FALSE

/obj/structure/ship_weapon/artillery_frame
	alt_click_loot = FALSE

/obj/structure/vampire
	alt_click_loot = FALSE

/obj/structure/window
	alt_click_loot = FALSE

/obj/vehicle/ridden
	alt_click_loot = FALSE

/turf/closed/indestructible/hoteldoor
	alt_click_loot = FALSE

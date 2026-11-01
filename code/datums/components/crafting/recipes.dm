
/datum/crafting_recipe
	var/name = "" //in-game display name
	var/reqs[] = list() //type paths of items consumed associated with how many are needed
	var/blacklist[] = list() //type paths of items explicitly not allowed as an ingredient
	var/result //type path of item resulting from this craft
	var/tools[] = list() //type paths of items needed but not consumed
	var/time = 30 //time in deciseconds
	var/parts[] = list() //type paths of items that will be placed in the result
	var/chem_catalysts[] = list() //like tools but for reagents
	var/category = CAT_NONE //where it shows up in the crafting UI
	var/subcategory = CAT_NONE
	var/always_available = TRUE //Set to FALSE if it needs to be learned first.

/datum/crafting_recipe/New()
	if(!(result in reqs))
		blacklist += result

/**
  * Run custom pre-craft checks for this recipe
  *
  * user: the /mob that initiated the crafting
  * collected_requirements: A list of lists of /obj/item instances that satisfy reqs. Top level list is keyed by requirement path.
  */
///Called after the result is created and placed (newfood marks chef-made food here)
/datum/crafting_recipe/proc/on_craft_completion(mob/user, atom/result)
	return

/datum/crafting_recipe/proc/check_requirements(mob/user, list/collected_requirements)
	return TRUE

/datum/crafting_recipe/IED
	name = "improwizowany ładunek wybuchowy"
	result = /obj/item/grenade/iedcasing
	reqs = list(/datum/reagent/fuel = 50,
				/obj/item/stack/cable_coil = 1,
				/obj/item/assembly/igniter = 1,
				/obj/item/reagent_containers/food/drinks/soda_cans = 1)
	parts = list(/obj/item/reagent_containers/food/drinks/soda_cans = 1)
	time = 15
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/lance
	name = "lanca wybuchowa (granat)"
	result = /obj/item/spear/explosive
	reqs = list(/obj/item/spear = 1,
				/obj/item/grenade = 1)
	blacklist = list(/obj/item/spear/bonespear)
	parts = list(/obj/item/spear = 1,
				/obj/item/grenade = 1)
	time = 15
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/strobeshield
	name = "tarcza stroboskopowa"
	result = /obj/item/shield/riot/flash
	reqs = list(/obj/item/wallframe/flasher = 1,
				/obj/item/assembly/flash/handheld = 1,
				/obj/item/shield/riot = 1)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/molotov
	name = "koktajl Mołotowa"
	result = /obj/item/reagent_containers/food/drinks/bottle/molotov
	reqs = list(/obj/item/reagent_containers/glass/rag = 1,
				/obj/item/reagent_containers/food/drinks/bottle = 1)
	parts = list(/obj/item/reagent_containers/food/drinks/bottle = 1)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/stunprod
	name = "poganiacz elektryczny"
	result = /obj/item/melee/baton/cattleprod
	reqs = list(/obj/item/restraints/handcuffs/cable = 1,
				/obj/item/stack/rods = 1,
				/obj/item/assembly/igniter = 1)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/teleprod
	name = "telepoganiacz"
	result = /obj/item/melee/baton/cattleprod/teleprod
	reqs = list(/obj/item/restraints/handcuffs/cable = 1,
				/obj/item/stack/rods = 1,
				/obj/item/assembly/igniter = 1,
				/obj/item/stack/ore/bluespace_crystal = 1)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/bola
	name = "bola"
	result = /obj/item/restraints/legcuffs/bola
	reqs = list(/obj/item/restraints/handcuffs/cable = 1,
				/obj/item/stack/sheet/iron = 6)
	time = 20//15 faster than crafting them by hand!
	category= CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/gonbola
	name = "gonbola"
	result = /obj/item/restraints/legcuffs/bola/gonbola
	reqs = list(/obj/item/restraints/handcuffs/cable = 1,
				/obj/item/stack/sheet/iron = 6,
				/obj/item/stack/sheet/animalhide/gondola = 1)
	time = 40
	category= CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/tailclub
	name = "pałka z ogona"
	result = /obj/item/club/tailclub
	reqs = list(/obj/item/organ/tail/lizard = 1,
	            /obj/item/stack/sheet/iron = 1)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/club
	name = "improwizowany młot"
	result = /obj/item/club/ghettoclub
	reqs = list(/obj/item/stack/sheet/iron = 1,
				/obj/item/stack/rods = 1,
				/obj/item/restraints/handcuffs/cable = 2,
				/obj/item/stack/sheet/cotton/cloth = 3)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/tailwhip
	name = "jaszczurza dziewięciorzemienna"
	result = /obj/item/melee/chainofcommand/tailwhip
	reqs = list(/obj/item/organ/tail/lizard = 1,
	            /obj/item/stack/cable_coil = 1)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/catwhip
	name = "kot o dziewięciu ogonach"
	result = /obj/item/melee/chainofcommand/tailwhip/kitty
	reqs = list(/obj/item/organ/tail/cat = 1,
	            /obj/item/stack/cable_coil = 1)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/ed209
	name = "ED-209"
	result = /mob/living/simple_animal/bot/ed209
	reqs = list(/obj/item/robot_suit = 1,
				/obj/item/clothing/head/helmet = 1,
				/obj/item/clothing/suit/armor/vest = 1,
				/obj/item/bodypart/l_leg/robot = 1,
				/obj/item/bodypart/r_leg/robot = 1,
				/obj/item/stack/sheet/iron = 1,
				/obj/item/stack/cable_coil = 1,
				/obj/item/gun/energy/e_gun/dragnet = 1,
				/obj/item/stock_parts/cell = 1,
				/obj/item/assembly/prox_sensor = 1)
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	time = 60
	category = CAT_ROBOT

/datum/crafting_recipe/secbot
	name = "securitron"
	result = /mob/living/simple_animal/bot/secbot
	reqs = list(/obj/item/assembly/signaler = 1,
				/obj/item/clothing/head/helmet/sec = 1,
				/obj/item/melee/baton = 1,
				/obj/item/assembly/prox_sensor = 1,
				/obj/item/bodypart/r_arm/robot = 1)
	tools = list(TOOL_WELDER)
	time = 60
	category = CAT_ROBOT

/datum/crafting_recipe/cleanbot
	name = "cleanbot"
	result = /mob/living/simple_animal/bot/cleanbot
	reqs = list(/obj/item/reagent_containers/glass/bucket = 1,
				/obj/item/assembly/prox_sensor = 1,
				/obj/item/bodypart/r_arm/robot = 1)
	time = 40
	category = CAT_ROBOT

/datum/crafting_recipe/cleanbot/larry
	name = "Larry"
	result = /mob/living/simple_animal/bot/cleanbot/larry
	reqs = list(/obj/item/larryframe = 1,
				/obj/item/assembly/prox_sensor = 1,
				/obj/item/bodypart/r_arm/robot = 1)


/datum/crafting_recipe/floorbot
	name = "floorbot"
	result = /mob/living/simple_animal/bot/floorbot
	reqs = list(/obj/item/storage/toolbox = 1,
				/obj/item/stack/tile/plasteel = 10,
				/obj/item/assembly/prox_sensor = 1,
				/obj/item/bodypart/r_arm/robot = 1)
	time = 40
	category = CAT_ROBOT

/datum/crafting_recipe/medbot
	name = "medibot"
	result = /mob/living/simple_animal/bot/medbot
	reqs = list(/obj/item/healthanalyzer = 1,
				/obj/item/storage/firstaid = 1,
				/obj/item/assembly/prox_sensor = 1,
				/obj/item/bodypart/r_arm/robot = 1)
	time = 40
	category = CAT_ROBOT

/datum/crafting_recipe/honkbot
	name = "honkbot"
	result = /mob/living/simple_animal/bot/honkbot
	reqs = list(/obj/item/storage/box/clown = 1,
				/obj/item/bodypart/r_arm/robot = 1,
				/obj/item/assembly/prox_sensor = 1,
				/obj/item/bikehorn/ = 1)
	time = 40
	category = CAT_ROBOT

/datum/crafting_recipe/Firebot
	name = "firebot"
	result = /mob/living/simple_animal/bot/firebot
	reqs = list(/obj/item/extinguisher = 1,
				/obj/item/bodypart/r_arm/robot = 1,
				/obj/item/assembly/prox_sensor = 1,
				/obj/item/clothing/head/hardhat/red = 1)
	time = 40
	category = CAT_ROBOT

/datum/crafting_recipe/Atmosbot
	name = "atmosbot"
	result = /mob/living/simple_animal/bot/atmosbot
	reqs = list(/obj/item/analyzer = 1,
				/obj/item/bodypart/r_arm/robot = 1,
				/obj/item/assembly/prox_sensor = 1,
				/obj/item/tank/internals = 1)
	time = 40
	category = CAT_ROBOT

/datum/crafting_recipe/improvised_pneumatic_cannon //Pretty easy to obtain but
	name = "improwizowane działko pneumatyczne"
	result = /obj/item/pneumatic_cannon/ghetto
	tools = list(TOOL_WELDER, TOOL_WRENCH)
	reqs = list(/obj/item/stack/sheet/iron = 4,
				/obj/item/stack/package_wrap = 8,
				/obj/item/pipe = 2)
	time = 50
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/flamethrower
	name = "miotacz ognia"
	result = /obj/item/flamethrower
	reqs = list(/obj/item/weldingtool = 1,
				/obj/item/assembly/igniter = 1,
				/obj/item/stack/rods = 1)
	parts = list(/obj/item/assembly/igniter = 1,
				/obj/item/weldingtool = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 10
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/pipebow
	name = "łuk z rury"
	result = /obj/item/gun/ballistic/bow/pipe
	reqs = list(/obj/item/pipe = 5,
				/obj/item/stack/sheet/plastic = 15,
				/obj/item/weaponcrafting/silkstring = 4)
	time = 120
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/woodenbow
	name = "drewniany łuk"
	result = /obj/item/gun/ballistic/bow
	reqs = list(/obj/item/stack/sheet/mineral/wood = 8,
				/obj/item/stack/sheet/iron = 2,
				/obj/item/weaponcrafting/silkstring = 4)
	time = 120
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/meteorslug
	name = "nabój meteorytowy"
	result = /obj/item/ammo_casing/shotgun/meteorslug
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/rcd_ammo = 1,
				/obj/item/stock_parts/manipulator = 2)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/pulseslug
	name = "breneka pulsacyjna"
	result = /obj/item/ammo_casing/shotgun/pulseslug
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/stock_parts/capacitor/adv = 2,
				/obj/item/stock_parts/micro_laser/ultra = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/dragonsbreath
	name = "nabój smoczy oddech"
	result = /obj/item/ammo_casing/shotgun/dragonsbreath
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1, /datum/reagent/phosphorus = 5)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/frag12
	name = "breneka FRAG-12"
	result = /obj/item/ammo_casing/shotgun/frag12
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/datum/reagent/glycerol = 5,
				/datum/reagent/toxin/acid = 5,
				/datum/reagent/toxin/acid/fluacid = 5)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/ionslug
	name = "nabój jonowy"
	result = /obj/item/ammo_casing/shotgun/ion
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/stock_parts/micro_laser/ultra = 1,
				/obj/item/stock_parts/subspace/crystal = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/improvisedslug
	name = "improwizowany nabój"
	result = /obj/item/ammo_casing/shotgun/improvised
	reqs = list(/obj/item/grenade/chem_grenade = 1,
				/obj/item/stack/sheet/iron = 1,
				/obj/item/stack/cable_coil = 1,
				/datum/reagent/fuel = 10)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/laserslug
	name = "nabój z laserem rozpraszającym"
	result = /obj/item/ammo_casing/shotgun/laserslug
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/stock_parts/capacitor/adv = 1,
				/obj/item/stock_parts/micro_laser/high = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/arrow
	name = "drewniana strzała"
	result = /obj/item/ammo_casing/caseless/arrow/wood
	time = 30
	reqs = list(/obj/item/stack/sheet/mineral/wood = 1,
				/obj/item/stack/sheet/silk = 1,
				/obj/item/stack/rods = 1) //1 metal sheet = 2 rods= 2 arrows
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/bone_arrow
	name = "kościana strzała"
	result = /obj/item/ammo_casing/caseless/arrow/bone
	time = 30
	reqs = list(/obj/item/stack/sheet/bone = 1,
				/obj/item/stack/sheet/sinew = 1,
				/obj/item/ammo_casing/caseless/arrow/ash = 1)
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/ashen_arrow
	name = "opalona strzała"
	result = /obj/item/ammo_casing/caseless/arrow/ash
	tools = list(TOOL_WELDER)
	time = 30
	reqs = list(/obj/item/ammo_casing/caseless/arrow/wood = 1)
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/bronze_arrow
	name = "brązowa strzała"
	result = /obj/item/ammo_casing/caseless/arrow/bronze
	time = 30
	reqs = list(/obj/item/stack/sheet/mineral/wood = 1,
				/obj/item/stack/tile/bronze = 1,
				/obj/item/stack/sheet/silk = 1)
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/ishotgun
	name = "improwizowana strzelba"
	result = /obj/item/gun/ballistic/shotgun/doublebarrel/improvised
	reqs = list(/obj/item/weaponcrafting/receiver = 1,
				/obj/item/pipe = 1,
				/obj/item/weaponcrafting/stock = 1,
				/obj/item/stack/package_wrap = 5)
	tools = list(TOOL_SCREWDRIVER)
	time = 100
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/chainsaw
	name = "piła łańcuchowa"
	result = /obj/item/chainsaw
	reqs = list(/obj/item/circular_saw = 1,
				/obj/item/stack/cable_coil = 3,
				/obj/item/stack/sheet/plasteel = 5)
	tools = list(TOOL_WELDER)
	time = 50
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/spear
	name = "włócznia"
	result = /obj/item/spear
	reqs = list(/obj/item/restraints/handcuffs/cable = 1,
				/obj/item/shard = 1,
				/obj/item/stack/rods = 1)
	parts = list(/obj/item/shard = 1)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/switchblade_kitchen
	name = "żelazny nóż sprężynowy"
	result = /obj/item/switchblade/kitchen
	reqs = list(/obj/item/stack/sheet/iron = 2,
				/obj/item/weaponcrafting/receiver = 1,
				/obj/item/kitchen/knife = 1,
				/obj/item/stack/cable_coil = 2)
	tools = list(TOOL_WELDER)
	time = 45
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/switchblade_kitchenupgrade
	name = "plastytanowy nóż sprężynowy"
	result = /obj/item/switchblade/plastitanium
	reqs = list(/obj/item/switchblade/kitchen = 1,
				/obj/item/stack/sheet/mineral/plastitanium = 2)
	tools = list(TOOL_WELDER)
	time = 20
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/switchblade_plastitanium
	name = "plastytanowy nóż sprężynowy"
	result = /obj/item/switchblade/plastitanium
	reqs = list(/obj/item/weaponcrafting/stock = 1,
				/obj/item/weaponcrafting/receiver = 1,
				/obj/item/kitchen/knife = 1,
				/obj/item/stack/cable_coil = 2,
				/obj/item/stack/sheet/mineral/plastitanium = 2)
	tools = list(TOOL_WELDER)
	time = 65
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/spooky_camera
	name = "camera obscura"
	result = /obj/item/camera/spooky
	time = 15
	reqs = list(/obj/item/camera = 1,
				/datum/reagent/water/holywater = 10)
	parts = list(/obj/item/camera = 1)
	category = CAT_MISC

/datum/crafting_recipe/lizardhat
	name = "kapelusz cloche z jaszczurczej skóry"
	result = /obj/item/clothing/head/lizard
	time = 10
	reqs = list(/obj/item/organ/tail/lizard = 1)
	category = CAT_MISC

/datum/crafting_recipe/lizardhat_alternate
	name = "kapelusz cloche z jaszczurczej skóry"
	result = /obj/item/clothing/head/lizard
	time = 10
	reqs = list(/obj/item/stack/sheet/animalhide/lizard = 1)
	category = CAT_MISC

/datum/crafting_recipe/kittyears
	name = "kocie uszy"
	result = /obj/item/clothing/head/kitty/genuine
	time = 10
	reqs = list(/obj/item/organ/tail/cat = 1,
				/obj/item/organ/ears/cat = 1)
	category = CAT_MISC

/datum/crafting_recipe/skateboard
	name = "improwizowana deskorolka"
	result = /obj/item/melee/skateboard
	time = 60
	reqs = list(/obj/item/stack/sheet/iron = 5,
				/obj/item/stack/rods = 10)
	category = CAT_MISC

/datum/crafting_recipe/scooter
	name = "hulajnoga"
	result = /obj/vehicle/ridden/scooter
	time = 65
	reqs = list(/obj/item/stack/sheet/iron = 5,
				/obj/item/stack/rods = 12)
	category = CAT_MISC

/datum/crafting_recipe/wheelchair
	name = "wózek inwalidzki"
	result = /obj/vehicle/ridden/wheelchair
	reqs = list(/obj/item/stack/sheet/iron = 4,
				/obj/item/stack/rods = 6)
	time = 100
	category = CAT_MISC

/datum/crafting_recipe/motorized_wheelchair
	name = "zmotoryzowany wózek inwalidzki"
	result = /obj/vehicle/ridden/wheelchair/motorized
	reqs = list(/obj/item/stack/sheet/iron = 10,
		/obj/item/stack/rods = 8,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/capacitor = 1)
	parts = list(/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/capacitor = 1)
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WRENCH)
	time = 200
	category = CAT_MISC

/datum/crafting_recipe/mousetrap
	name = "pułapka na myszy"
	result = /obj/item/assembly/mousetrap
	time = 10
	reqs = list(/obj/item/stack/sheet/cardboard = 1,
				/obj/item/stack/rods = 1)
	category = CAT_MISC

/datum/crafting_recipe/papersack
	name = "papierowa torba"
	result = /obj/item/storage/box/papersack
	time = 10
	reqs = list(/obj/item/paper = 5)
	category = CAT_MISC


/datum/crafting_recipe/flashlight_eyes
	name = "oczy-latarki"
	result = /obj/item/organ/eyes/robotic/flashlight
	time = 10
	reqs = list(
		/obj/item/flashlight = 2,
		/obj/item/restraints/handcuffs/cable = 1
	)
	category = CAT_MISC

/datum/crafting_recipe/paperframes
	name = "papierowe ramy"
	result = /obj/item/stack/sheet/paperframes/five
	time = 10
	reqs = list(/obj/item/stack/sheet/mineral/wood = 5, /obj/item/paper = 20)
	category = CAT_MISC

/datum/crafting_recipe/naturalpaper
	name = "ręcznie prasowany papier"
	time = 30
	reqs = list(/datum/reagent/water = 50, /obj/item/stack/sheet/mineral/wood = 1)
	tools = list(/obj/item/hatchet)
	result = /obj/item/paper_bin/bundlenatural
	category = CAT_MISC

/datum/crafting_recipe/toysword
	name = "zabawkowy miecz"
	reqs = list(/obj/item/light/bulb = 1, /obj/item/stack/cable_coil = 1, /obj/item/stack/sheet/plastic = 4)
	result = /obj/item/toy/sword
	category = CAT_MISC

/datum/crafting_recipe/blackcarpet
	name = "czarna wykładzina"
	reqs = list(/obj/item/stack/tile/carpet = 50, /obj/item/toy/crayon/black = 1)
	result = /obj/item/stack/tile/carpet/black/fifty
	category = CAT_MISC

/datum/crafting_recipe/showercurtain
	name = "zasłona prysznicowa"
	reqs = 	list(/obj/item/stack/sheet/cotton/cloth = 2, /obj/item/stack/sheet/plastic = 2, /obj/item/stack/rods = 1)
	result = /obj/structure/curtain
	category = CAT_MISC

/datum/crafting_recipe/extendohand
	name = "wysuwana ręka"
	reqs = list(/obj/item/bodypart/r_arm/robot = 1, /obj/item/clothing/gloves/boxing = 1)
	result = /obj/item/extendohand
	category = CAT_MISC

/datum/crafting_recipe/mothplush
	name = "pluszowa ćma"
	result = /obj/item/toy/plush/moth
	reqs = list(/obj/item/stack/sheet/animalhide/mothroach = 1,
				/obj/item/stack/sheet/cotton/cloth = 3)
	category = CAT_MISC

/datum/crafting_recipe/chemical_payload
	name = "ładunek chemiczny (C4)"
	result = /obj/item/bombcore/chemical
	reqs = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/grenade/plastic/c4 = 1,
		/obj/item/grenade/chem_grenade = 2
	)
	parts = list(/obj/item/stock_parts/matter_bin = 1, /obj/item/grenade/chem_grenade = 2)
	time = 30
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/chemical_payload2
	name = "ładunek chemiczny (gibtonit)"
	result = /obj/item/bombcore/chemical
	reqs = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/gibtonite = 1,
		/obj/item/grenade/chem_grenade = 2
	)
	parts = list(/obj/item/stock_parts/matter_bin = 1, /obj/item/grenade/chem_grenade = 2)
	time = 50
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/bonearmor
	name = "pancerz z kości"
	result = /obj/item/clothing/suit/armor/bone
	time = 30
	reqs = list(/obj/item/stack/sheet/bone = 6)
	category = CAT_PRIMAL

/datum/crafting_recipe/heavybonearmor
	name = "ciężki pancerz z kości"
	result = /obj/item/clothing/suit/hooded/cloak/bone
	time = 60
	reqs = list(/obj/item/stack/sheet/bone = 8,
				/obj/item/stack/sheet/sinew = 3)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonetalisman
	name = "kościany talizman"
	result = /obj/item/clothing/accessory/talisman
	time = 20
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonecodpiece
	name = "czaszkowy ochraniacz krocza"
	result = /obj/item/clothing/accessory/skullcodpiece
	time = 20
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/animalhide/goliath_hide = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/bracers
	name = "kościane karwasze"
	result = /obj/item/clothing/gloves/bracer
	time = 20
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/skullhelm
	name = "hełm z czaszki"
	result = /obj/item/clothing/head/helmet/skull
	time = 30
	reqs = list(/obj/item/stack/sheet/bone = 4)
	category = CAT_PRIMAL

/datum/crafting_recipe/goliathcloak
	name = "peleryna z goliata"
	result = /obj/item/clothing/suit/hooded/cloak/goliath
	time = 50
	reqs = list(/obj/item/stack/sheet/leather = 2,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2) //it takes 4 goliaths to make 1 cloak if the plates are skinned
	category = CAT_PRIMAL

/datum/crafting_recipe/drakecloak
	name = "smocza zbroja"
	result = /obj/item/clothing/suit/hooded/cloak/drake
	time = 60
	reqs = list(/obj/item/stack/sheet/bone = 10,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/ashdrake = 5)
	category = CAT_PRIMAL

/datum/crafting_recipe/watcherbola
	name = "bola z obserwatora"
	result = /obj/item/restraints/legcuffs/bola/watcher
	time = 30
	reqs = list(/obj/item/stack/sheet/animalhide/goliath_hide = 2,
				/obj/item/restraints/handcuffs/cable/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/goliathshield
	name = "tarcza z goliata"
	result = /obj/item/shield/riot/goliath
	time = 60
	reqs = list(/obj/item/stack/sheet/bone = 4,
				/obj/item/stack/sheet/animalhide/goliath_hide = 3)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonesword
	name = "kościany miecz"
	result = /obj/item/claymore/bone
	time = 40
	reqs = list(/obj/item/stack/sheet/bone = 3,
				/obj/item/stack/sheet/sinew = 2)
	category = CAT_PRIMAL

/datum/crafting_recipe/hunterbelt
	name = "pas myśliwego"
	result = /obj/item/storage/belt/mining/primitive
	time = 20
	reqs = list(/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2)
	category = CAT_PRIMAL

/datum/crafting_recipe/quiver
	name = "skórzany kołczan"
	result = /obj/item/storage/belt/quiver
	time = 80
	reqs = list(/obj/item/stack/sheet/leather = 3,
				/obj/item/stack/sheet/sinew = 4)
	category = CAT_PRIMAL

/datum/crafting_recipe/bone_bow
	name = "kościany łuk"
	result = /obj/item/gun/ballistic/bow/ashen
	time = 200
	reqs = list(/obj/item/stack/sheet/bone = 8,
				/obj/item/stack/sheet/sinew = 4)
	category = CAT_PRIMAL

/datum/crafting_recipe/firebrand
	name = "żagiew"
	result = /obj/item/match/firebrand
	time = 100 //Long construction time. Making fire is hard work.
	reqs = list(/obj/item/stack/sheet/mineral/wood = 2)
	category = CAT_PRIMAL

/datum/crafting_recipe/gold_horn
	name = "złota trąbka"
	result = /obj/item/bikehorn/golden
	time = 20
	reqs = list(/obj/item/stack/sheet/mineral/bananium = 5,
				/obj/item/bikehorn = 1)
	category = CAT_MISC

/datum/crafting_recipe/bonedagger
	name = "kościany sztylet"
	result = /obj/item/kitchen/knife/combat/bone
	time = 20
	reqs = list(/obj/item/stack/sheet/bone = 2)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonespear
	name = "kościana włócznia"
	result = /obj/item/spear/bonespear
	time = 30
	reqs = list(/obj/item/stack/sheet/bone = 4,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/boneaxe
	name = "kościany topór"
	result = /obj/item/fireaxe/boneaxe
	time = 50
	reqs = list(/obj/item/stack/sheet/bone = 6,
				 /obj/item/stack/sheet/sinew = 3)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonfire
	name = "ognisko"
	time = 60
	reqs = list(/obj/item/grown/log = 5)
	result = /obj/structure/bonfire
	category = CAT_PRIMAL

/datum/crafting_recipe/skeleton_key
	name = "klucz-szkielet"
	time = 30
	reqs = list(/obj/item/stack/sheet/bone = 5)
	result = /obj/item/skeleton_key
	always_available = FALSE
	category = CAT_PRIMAL

/datum/crafting_recipe/headpike
	name = "głowa na włóczni (szklana włócznia)"
	time = 65
	reqs = list(/obj/item/spear = 1,
				/obj/item/bodypart/head = 1)
	parts = list(/obj/item/bodypart/head = 1,
			/obj/item/spear = 1)
	blacklist = list(/obj/item/spear/explosive, /obj/item/spear/bonespear, /obj/item/spear/bamboospear)
	result = /obj/structure/headpike/glass
	category = CAT_PRIMAL

/datum/crafting_recipe/headpikebone
	name = "głowa na włóczni (kościana włócznia)"
	time = 65
	reqs = list(/obj/item/spear/bonespear = 1,
				/obj/item/bodypart/head = 1)
	parts = list(/obj/item/bodypart/head = 1,
			/obj/item/spear/bonespear = 1)
	result = /obj/structure/headpike/bone
	category = CAT_PRIMAL

/datum/crafting_recipe/headpikebamboo
	name = "głowa na włóczni (bambusowa włócznia)"
	time = 65
	reqs = list(/obj/item/spear/bamboospear = 1,
				/obj/item/bodypart/head = 1)
	parts = list(/obj/item/bodypart/head = 1,
			/obj/item/spear/bamboospear = 1)
	result = /obj/structure/headpike/bamboo
	category = CAT_PRIMAL

/datum/crafting_recipe/pressureplate
	name = "płyta naciskowa"
	result = /obj/item/pressure_plate
	time = 5
	reqs = list(/obj/item/stack/sheet/iron = 1,
				  /obj/item/stack/tile/plasteel = 1,
				  /obj/item/stack/cable_coil = 2,
				  /obj/item/assembly/igniter = 1)
	category = CAT_MISC


/datum/crafting_recipe/noose
	name = "pętla wisielcza"
	result = /obj/structure/chair/noose
	time = 80
	reqs = list(/obj/item/stack/cable_coil = 30)
	category = CAT_MISC

/datum/crafting_recipe/noose/check_requirements(mob/user, list/collected_requirements)
	if(!(locate(/obj/structure/chair) in get_turf(user)))
		to_chat(user, "<span class='warning'>Aby zrobić pętlę, musisz stać na krześle!</span>")
		return FALSE
	return ..()

/datum/crafting_recipe/mummy
	name = "bandaże mumii (maska)"
	result = /obj/item/clothing/mask/mummy
	time = 10
	tools = list(/obj/item/nullrod/egyptian)
	reqs = list(/obj/item/stack/sheet/cotton/cloth = 2)
	category = CAT_CLOTHING

/datum/crafting_recipe/mummy/body
	name = "bandaże mumii (ciało)"
	result = /obj/item/clothing/under/costume/mummy
	reqs = list(/obj/item/stack/sheet/cotton/cloth = 5)


/datum/crafting_recipe/chaplain_hood
	name = "bluza wyznawcy"
	result = /obj/item/clothing/suit/hooded/chaplain_hoodie
	time = 10
	tools = list(/obj/item/clothing/suit/hooded/chaplain_hoodie, /obj/item/storage/book/bible)
	reqs = list(/obj/item/stack/sheet/cotton/cloth = 4)
	category = CAT_CLOTHING

/datum/crafting_recipe/guillotine
	name = "gilotyna"
	result = /obj/structure/guillotine
	time = 150 // Building a functioning guillotine takes time
	reqs = list(/obj/item/stack/sheet/plasteel = 3,
		        /obj/item/stack/sheet/mineral/wood = 20,
		        /obj/item/stack/cable_coil = 10)
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH, TOOL_WELDER)
	category = CAT_MISC

/datum/crafting_recipe/aitater
	name = "intelliTater"
	result = /obj/item/aicard/aitater
	time = 30
	tools = list(TOOL_WIRECUTTER)
	reqs = list(/obj/item/aicard = 1,
					/obj/item/food/grown/potato = 1,
					/obj/item/stack/cable_coil = 5)
	category = CAT_MISC

/datum/crafting_recipe/aispook
	name = "intelliLantern"
	result = /obj/item/aicard/aispook
	time = 30
	tools = list(TOOL_WIRECUTTER)
	reqs = list(/obj/item/aicard = 1,
					/obj/item/food/grown/pumpkin = 1,
					/obj/item/stack/cable_coil = 5)
	category = CAT_MISC

/datum/crafting_recipe/ghettojetpack
	name = "improwizowany plecak odrzutowy"
	result = /obj/item/tank/jetpack/improvised
	time = 30
	reqs = list(/obj/item/tank/internals/oxygen/red = 2, /obj/item/extinguisher = 1, /obj/item/pipe = 3, /obj/item/stack/cable_coil = 30)//red oxygen tank so it looks right
	category = CAT_MISC
	tools = list(TOOL_WRENCH, TOOL_WELDER, TOOL_WIRECUTTER)

/datum/crafting_recipe/upgraded_gauze
	name = "sterylna gaza medyczna"
	result = /obj/item/stack/medical/gauze/adv/one
	time = 1
	reqs = list(/obj/item/stack/medical/gauze = 1,
				/datum/reagent/space_cleaner/sterilizine = 10)
	category = CAT_MISC

/datum/crafting_recipe/bruise_pack
	name = "nici z lekiem" // AQ EDIT - tgstation sutures replace bruise packs
	result = /obj/item/stack/medical/suture/medicated/one
	time = 1
	reqs = list(/obj/item/stack/medical/gauze = 1,
				/datum/reagent/medicine/styptic_powder = 40)
	category = CAT_MISC

/datum/crafting_recipe/burn_pack
	name = "siatka regeneracyjna" // AQ EDIT - tgstation mesh replaces ointment
	result = /obj/item/stack/medical/mesh/one
	time = 1
	reqs = list(/obj/item/stack/medical/gauze = 1,
				/datum/reagent/medicine/silver_sulfadiazine = 40)
	category = CAT_MISC

// Shank - Makeshift weapon that can embed on throw
/datum/crafting_recipe/shank
	name = "kosa"
	reqs = list(/obj/item/shard = 1,
					/obj/item/stack/cable_coil = 10) // 1 glass shard + 10 cable; needs a wirecutter to snip the cable.
	result = /obj/item/kitchen/knife/shank
	tools = list(TOOL_WIRECUTTER)
	time = 20
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	always_available = TRUE

/datum/crafting_recipe/sharpmop
	name = "zaostrzony mop"
	result = /obj/item/mop/sharp
	time = 30
	reqs = list(/obj/item/mop = 1,
				/obj/item/shard = 1)
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	tools = list(TOOL_WIRECUTTER)

/datum/crafting_recipe/poppy_pin
	name = "przypinka z makiem"
	result = /obj/item/clothing/accessory/poppy_pin
	time = 5
	reqs = list(/obj/item/stack/rods = 1,
				/obj/item/food/grown/poppy = 1)
	category = CAT_MISC

/datum/crafting_recipe/poppy_pin_removal
	name = "zdjęcie przypinki z makiem"
	result = /obj/item/food/grown/poppy
	time = 5
	reqs = list(/obj/item/clothing/accessory/poppy_pin = 1)

	category = CAT_MISC

/datum/crafting_recipe/insulated_boxing_gloves
	name = "izolowane rękawice bokserskie"
	result = /obj/item/clothing/gloves/boxing/yellow/insulated
	time = 60
	reqs = list(/obj/item/clothing/gloves/boxing = 1,
				/obj/item/clothing/gloves/color/yellow = 1)

	category = CAT_CLOTHING


/datum/crafting_recipe/aquarium
	name = "akwarium"
	result = /obj/structure/aquarium
	time = 10 SECONDS
	reqs = list(/obj/item/stack/sheet/iron = 15,
				/obj/item/stack/sheet/glass = 10,
				/obj/item/aquarium_kit = 1
				)
	category = CAT_MISC

/datum/crafting_recipe/paper_cup
	name= "kubek papierowy"
	result = /obj/item/reagent_containers/food/drinks/sillycup
	time = 10
	reqs = list(/obj/item/paper = 1)
	category = CAT_MISC
	tools = list(TOOL_WIRECUTTER)

/datum/crafting_recipe/basic_lasso
	name= "kosmiczne lasso"
	result = /obj/item/mob_lasso
	time = 20
	reqs = list(/obj/item/stack/sheet/leather = 5)
	category = CAT_MISC

/datum/crafting_recipe/primal_lasso
	name= "pierwotne lasso"
	result = /obj/item/mob_lasso/primal
	always_available = FALSE
	time = 20
	reqs = list(/obj/item/stack/sheet/animalhide/goliath_hide = 3)
	category = CAT_PRIMAL

/datum/crafting_recipe/foldable
	name = "krzesło składane"
	result = /obj/item/chair/foldable
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/stack/sheet/plastic = 1
				)
	tools = list(TOOL_WRENCH, TOOL_WIRECUTTER)
	category = CAT_MISC

/datum/crafting_recipe/chair_fancy
	name = "eleganckie krzesło"
	result = /obj/item/chair/fancy
	time = 60
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/chair = 1
				)
	tools = list(TOOL_WRENCH, TOOL_WIRECUTTER)
	category = CAT_MISC

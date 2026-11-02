/datum/crafting_recipe/durathread_vest
	name = "kamizelka z duranici"
	result = /obj/item/clothing/suit/armor/vest/durathread
	reqs = list(/obj/item/stack/sheet/durathread = 5,
				/obj/item/stack/sheet/leather = 4)
	time = 50
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_helmet
	name = "hełm z duranici"
	result = /obj/item/clothing/head/helmet/durathread
	reqs = list(/obj/item/stack/sheet/durathread = 4,
				/obj/item/stack/sheet/leather = 5)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_jumpsuit
	name = "kombinezon z duranici"
	result = /obj/item/clothing/under/color/durathread
	reqs = list(/obj/item/stack/sheet/durathread = 4)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_beret
	name = "beret z duranici"
	result = /obj/item/clothing/head/beret/durathread
	reqs = list(/obj/item/stack/sheet/durathread = 2)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_beanie
	name = "czapka zimowa z duranici"
	result = /obj/item/clothing/head/beanie/durathread
	reqs = list(/obj/item/stack/sheet/durathread = 2)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_bandana
	name = "bandana z duranici"
	result = /obj/item/clothing/mask/bandana/durathread
	reqs = list(/obj/item/stack/sheet/durathread = 1)
	time = 25
	category = CAT_CLOTHING

/datum/crafting_recipe/fannypack
	name = "nerka"
	result = /obj/item/storage/belt/fannypack
	reqs = list(/obj/item/stack/sheet/cotton/cloth = 2,
				/obj/item/stack/sheet/leather = 1)
	time = 20
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunsec
	name = "okulary przeciwsłoneczne z HUD-em ochrony"
	result = /obj/item/clothing/glasses/hud/security/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security = 1,
				/obj/item/clothing/glasses/sunglasses/advanced = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/hudsunsecremoval
	name = "zdjęcie HUD-u ochrony"
	result = /obj/item/clothing/glasses/sunglasses/advanced
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security/sunglasses = 1)
	blacklist = list(/obj/item/clothing/glasses/hud/security/sunglasses/degraded)
	category = CAT_EYEWEAR

/datum/crafting_recipe/hudsunmed
	name = "okulary przeciwsłoneczne z HUD-em medycznym"
	result = /obj/item/clothing/glasses/hud/health/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health = 1,
				/obj/item/clothing/glasses/sunglasses/advanced = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/hudsunmedremoval
	name = "zdjęcie HUD-u medycznego"
	result = /obj/item/clothing/glasses/sunglasses/advanced
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health/sunglasses = 1)
	blacklist = list(/obj/item/clothing/glasses/hud/health/sunglasses/degraded)
	category = CAT_EYEWEAR

/datum/crafting_recipe/hudsundiag
	name = "okulary przeciwsłoneczne z HUD-em diagnostycznym"
	result = /obj/item/clothing/glasses/hud/diagnostic/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic = 1,
				/obj/item/clothing/glasses/sunglasses/advanced = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/hudsundiagremoval
	name = "zdjęcie HUD-u diagnostycznego"
	result = /obj/item/clothing/glasses/sunglasses/advanced
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic/sunglasses = 1)
	blacklist = list(/obj/item/clothing/glasses/hud/diagnostic/sunglasses/degraded)
	category = CAT_EYEWEAR

/datum/crafting_recipe/beergoggles
	name = "piwne gogle"
	result = /obj/item/clothing/glasses/sunglasses/advanced/reagent
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/science = 1,
				/obj/item/clothing/glasses/sunglasses/advanced = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/beergogglesremoval
	name = "zdjęcie piwnych gogli"
	result = /obj/item/clothing/glasses/sunglasses/advanced
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/sunglasses/advanced/reagent = 1)
	category = CAT_EYEWEAR

/datum/crafting_recipe/sunhudscience
	name = "naukowe okulary przeciwsłoneczne"
	result = /obj/item/clothing/glasses/science/sciencesun
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/science = 1,
				/obj/item/clothing/glasses/sunglasses/advanced = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/sunhudscienceremoval
	name = "zdjęcie naukowych okularów przeciwsłonecznych"
	result = /obj/item/clothing/glasses/sunglasses/advanced
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/science/sciencesun = 1)
	blacklist = list(/obj/item/clothing/glasses/science/sciencesun/degraded)
	category = CAT_EYEWEAR

/datum/crafting_recipe/deghudsunsec
	name = "zużyte okulary przeciwsłoneczne z HUD-em ochrony"
	result = /obj/item/clothing/glasses/hud/security/sunglasses/degraded
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security = 1,
				/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/deghudsunsecremoval
	name = "zdjęcie zużytego HUD-u ochrony"
	result = /obj/item/clothing/glasses/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security/sunglasses/degraded = 1)
	category = CAT_EYEWEAR

/datum/crafting_recipe/deghudsunmed
	name = "zużyte okulary przeciwsłoneczne z HUD-em medycznym"
	result = /obj/item/clothing/glasses/hud/health/sunglasses/degraded
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health = 1,
				/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/deghudsunmedremoval
	name = "zdjęcie zużytego HUD-u medycznego"
	result = /obj/item/clothing/glasses/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health/sunglasses/degraded = 1)
	category = CAT_EYEWEAR

/datum/crafting_recipe/deghudsundiag
	name = "zużyte okulary przeciwsłoneczne z HUD-em diagnostycznym"
	result = /obj/item/clothing/glasses/hud/diagnostic/sunglasses/degraded
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic = 1,
				/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/deghudsundiagremoval
	name = "zdjęcie zużytego HUD-u diagnostycznego"
	result = /obj/item/clothing/glasses/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic/sunglasses/degraded = 1)
	category = CAT_EYEWEAR

/datum/crafting_recipe/degsunhudscience
	name = "zużyte naukowe okulary przeciwsłoneczne"
	result = /obj/item/clothing/glasses/science/sciencesun/degraded
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/science = 1,
				/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/degsunhudscienceremoval
	name = "zdjęcie zużytych naukowych okularów przeciwsłonecznych"
	result = /obj/item/clothing/glasses/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/science/sciencesun/degraded = 1)
	category = CAT_EYEWEAR

/datum/crafting_recipe/hudpresmed
	name = "okulary korekcyjne z HUD-em medycznym"
	result = /obj/item/clothing/glasses/hud/health/prescription
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health = 1,
				/obj/item/clothing/glasses/regular/ = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/hudpressec
	name = "okulary korekcyjne z HUD-em ochrony"
	result = /obj/item/clothing/glasses/hud/security/prescription
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security = 1,
				/obj/item/clothing/glasses/regular/ = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/hudpressci
	name = "korekcyjne gogle naukowe"
	result = /obj/item/clothing/glasses/science/prescription
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/science = 1,
				/obj/item/clothing/glasses/regular/ = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/hudpresmeson
	name = "korekcyjne gogle mezonowe"
	result = /obj/item/clothing/glasses/meson/prescription
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/meson = 1,
				/obj/item/clothing/glasses/regular/ = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/hudpresdiag
	name = "okulary korekcyjne z HUD-em diagnostycznym"
	result = /obj/item/clothing/glasses/hud/diagnostic/prescription
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic = 1,
				/obj/item/clothing/glasses/regular/ = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/ghostsheet
	name = "prześcieradło ducha"
	result = /obj/item/clothing/suit/ghost_sheet
	time = 5
	tools = list(TOOL_WIRECUTTER)
	reqs = list(/obj/item/bedsheet = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/foilhat
	name = "czapka z folii aluminiowej"
	result = /obj/item/clothing/head/foilhat
	time = 5
	tools = list(TOOL_CROWBAR)
	reqs = list(/obj/item/stack/sheet/iron = 3)
	category = CAT_CLOTHING

/datum/crafting_recipe/foilenvirohelm
	name = "hełm środowiskowy z folii aluminiowej"
	result = /obj/item/clothing/head/foilhat/plasmaman
	time = 40
	tools = list(TOOL_CROWBAR, TOOL_WIRECUTTER, TOOL_SCREWDRIVER)
	reqs = list(/obj/item/clothing/head/foilhat = 1,
				/obj/item/stack/package_wrap = 10,
				/obj/item/stack/cable_coil = 15,
				/obj/item/clothing/glasses/meson = 1,
				/obj/item/flashlight = 1,
				/obj/item/clothing/head/hardhat = 1,
				/obj/item/stack/sheet/glass = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/rainbowbunchcrown
	name = "tęczowy wianek"
	result = /obj/item/clothing/head/rainbowbunchcrown/
	time = 20
	reqs = list(/obj/item/food/grown/rainbow_flower = 5,
				/obj/item/stack/cable_coil = 3)
	category = CAT_CLOTHING

/datum/crafting_recipe/sunflowercrown
	name = "wianek ze słoneczników"
	result = /obj/item/clothing/head/sunflowercrown/
	time = 20
	reqs = list(/obj/item/grown/sunflower = 5,
				/obj/item/stack/cable_coil = 3)
	category = CAT_CLOTHING

/datum/crafting_recipe/poppycrown
	name = "wianek z maków"
	result = /obj/item/clothing/head/poppycrown/
	time = 20
	reqs = list(/obj/item/food/grown/poppy = 5,
				/obj/item/stack/cable_coil = 3)
	category = CAT_CLOTHING

/datum/crafting_recipe/lilycrown
	name = "wianek z lilii"
	result = /obj/item/clothing/head/lilycrown/
	time = 20
	reqs = list(/obj/item/food/grown/poppy/lily = 3,
				/obj/item/stack/cable_coil = 3)
	category = CAT_CLOTHING

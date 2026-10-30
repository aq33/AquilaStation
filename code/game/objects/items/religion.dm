/obj/item/banner
	name = "sztandar"
	desc = "Sztandar z logo Nanotrasen."
	icon = 'icons/obj/banner.dmi'
	icon_state = "banner"
	item_state = "banner"
	force = 8
	attack_verb = list("siłą inspiruje", "brutalnie zachęca", "bezlitośnie galwanizuje")
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	var/inspiration_available = TRUE //If this banner can be used to inspire crew
	var/morale_time = 0
	var/morale_cooldown = 600 //How many deciseconds between uses
	var/list/job_loyalties //Mobs with any of these assigned roles will be inspired
	var/list/role_loyalties //Mobs with any of these special roles will be inspired
	var/warcry

/obj/item/banner/examine(mob/user)
	. = ..()
	if(inspiration_available)
		. += "<span class='notice'>Aktywuj go w ręce, by zainspirować pobliskich sojuszników tego sztandaru!</span>"

/obj/item/banner/attack_self(mob/living/carbon/human/user)
	if(!inspiration_available)
		return
	if(morale_time > world.time)
		to_chat(user, "<span class='warning'>Nie czujesz się jeszcze dość natchniony, by znów wymachiwać [src].</span>")
		return
	user.visible_message("<span class='big notice'>[user] wymachuje [src]!</span>", \
	"<span class='notice'>Unosisz [src] ku niebu, inspirując sojuszników!</span>")
	playsound(src, "rustle", 100, FALSE)
	if(warcry)
		user.say("[warcry]", forced="banner")
	var/old_transform = user.transform
	user.transform *= 1.2
	animate(user, transform = old_transform, time = 10)
	morale_time = world.time + morale_cooldown

	var/list/inspired = list()
	var/has_job_loyalties = LAZYLEN(job_loyalties)
	var/has_role_loyalties = LAZYLEN(role_loyalties)
	inspired += user //The user is always inspired, regardless of loyalties
	for(var/mob/living/carbon/human/H in viewers(4, get_turf(src)))
		if(H.stat == DEAD || H == user)
			continue
		if(H.mind && (has_job_loyalties || has_role_loyalties))
			if(has_job_loyalties && (H.mind.assigned_role in job_loyalties))
				inspired += H
			else if(has_role_loyalties && (H.mind.special_role in role_loyalties))
				inspired += H
		else if(check_inspiration(H))
			inspired += H

	for(var/V in inspired)
		var/mob/living/carbon/human/H = V
		if(H != user)
			to_chat(H, "<span class='notice'>Twoja pewność siebie rośnie, gdy [user] wymachuje [name]!</span>")
		inspiration(H)
		special_inspiration(H)

/obj/item/banner/proc/check_inspiration(mob/living/carbon/human/H) //Banner-specific conditions for being eligible
	return

/obj/item/banner/proc/inspiration(mob/living/carbon/human/H)
	H.adjustBruteLoss(-15)
	H.adjustFireLoss(-15)
	H.AdjustStun(-40)
	H.AdjustKnockdown(-40)
	H.AdjustImmobilized(-40)
	H.AdjustParalyzed(-40)
	H.AdjustUnconscious(-40)
	playsound(H, 'sound/magic/staff_healing.ogg', 25, FALSE)

/obj/item/banner/proc/special_inspiration(mob/living/carbon/human/H) //Any banner-specific inspiration effects go here
	return

/obj/item/banner/security
	name = "sztandar Securistanu"
	desc = "Sztandar Securistanu, który rządzi stacją żelazną ręką."
	icon_state = "banner_security"
	item_state = "banner_security"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_BRIGPHYSICIAN, JOB_NAME_DEPUTY)
	warcry = "WSZYSCY NA ZIEMIĘ!!"

/obj/item/banner/security/mundane
	inspiration_available = FALSE

/datum/crafting_recipe/security_banner
	name = "Sztandar Securistanu"
	result = /obj/item/banner/security/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/under/rank/security/officer = 1)
	category = CAT_MISC

/obj/item/banner/medical
	name = "sztandar Meditopii"
	desc = "Sztandar Meditopii, hojnych dobroczyńców, którzy leczą rany i chronią słabych."
	icon_state = "banner_medical"
	item_state = "banner_medical"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = list(JOB_NAME_MEDICALDOCTOR, JOB_NAME_CHEMIST, JOB_NAME_GENETICIST, JOB_NAME_VIROLOGIST, JOB_NAME_PARAMEDIC, JOB_NAME_CHIEFMEDICALOFFICER)
	warcry = "Nie ma ran nie do uleczenia!"

/obj/item/banner/medical/mundane
	inspiration_available = FALSE

/obj/item/banner/medical/check_inspiration(mob/living/carbon/human/H)
	return H.stat //Meditopia is moved to help those in need

/datum/crafting_recipe/medical_banner
	name = "Sztandar Meditopii"
	result = /obj/item/banner/medical/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/under/rank/medical = 1)
	category = CAT_MISC

/obj/item/banner/medical/special_inspiration(mob/living/carbon/human/H)
	H.adjustToxLoss(-15, FALSE, TRUE)
	H.setOxyLoss(0)
	H.reagents.add_reagent(/datum/reagent/medicine/inaprovaline, 5)

/obj/item/banner/science
	name = "sztandar Sciencji"
	desc = "Sztandar Sciencji, śmiałych i odważnych taumaturgów i badaczy, którzy wybierają mniej uczęszczane ścieżki."
	icon_state = "banner_science"
	item_state = "banner_science"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = list(JOB_NAME_SCIENTIST, JOB_NAME_ROBOTICIST, JOB_NAME_RESEARCHDIRECTOR)
	warcry = "Za Aitlera!"

/obj/item/banner/science/mundane
	inspiration_available = FALSE

/obj/item/banner/science/check_inspiration(mob/living/carbon/human/H)
	return H.on_fire //Sciencia is pleased by dedication to the art of Toxins

/datum/crafting_recipe/science_banner
	name = "Sztandar Sciencji"
	result = /obj/item/banner/science/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/under/rank/rnd/scientist = 1)
	category = CAT_MISC

/obj/item/banner/cargo
	name = "sztandar Cargonii"
	desc = "Sztandar wiecznej Cargonii, która ma mistyczną moc przywoływania do istnienia dowolnego przedmiotu."
	icon_state = "banner_cargo"
	item_state = "banner_cargo"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = list(JOB_NAME_CARGOTECHNICIAN, JOB_NAME_SHAFTMINER, JOB_NAME_QUARTERMASTER)
	warcry = "Wiwat Cargonia!"

/obj/item/banner/cargo/mundane
	inspiration_available = FALSE

/datum/crafting_recipe/cargo_banner
	name = "Sztandar Cargonii"
	result = /obj/item/banner/cargo/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/under/rank/cargo/tech = 1)
	category = CAT_MISC

/obj/item/banner/engineering
	name = "sztandar Engitopii"
	desc = "Sztandar Engitopii, władców nieograniczonej mocy."
	icon_state = "banner_engineering"
	item_state = "banner_engineering"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = list(JOB_NAME_STATIONENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN, JOB_NAME_CHIEFENGINEER)
	warcry = "Wiwat lordzie Stormdrivus!!"

/obj/item/banner/engineering/mundane
	inspiration_available = FALSE

/obj/item/banner/engineering/special_inspiration(mob/living/carbon/human/H)
	H.radiation = 0

/datum/crafting_recipe/engineering_banner
	name = "Sztandar Engitopii"
	result = /obj/item/banner/engineering/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/under/rank/engineering/engineer = 1)
	category = CAT_MISC

/obj/item/banner/command
	name = "sztandar Dowództwa"
	desc = "Sztandar Dowództwa, niezłomnego i starożytnego rodu biurokratycznych królów i królowych."
	//No icon state here since the default one is the NT banner
	job_loyalties = list(JOB_NAME_CAPTAIN, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_CHIEFENGINEER, JOB_NAME_HEADOFSECURITY, JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_MASTERATARMS) //NSV13 - added MAA
	warcry = "Wiwat Nanotrasen!"

/obj/item/banner/command/mundane
	inspiration_available = FALSE

/obj/item/banner/command/check_inspiration(mob/living/carbon/human/H)
	return HAS_TRAIT(H, TRAIT_MINDSHIELD) //Command is stalwart but rewards their allies.

/datum/crafting_recipe/command_banner
	name = "Sztandar Dowództwa"
	result = /obj/item/banner/command/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/under/rank/captain/parade = 1)
	category = CAT_MISC

/obj/item/banner/red
	name = "czerwony sztandar"
	icon_state = "banner-red"
	item_state = "banner-red"
	desc = "Sztandar z logo czerwonego bóstwa."

/obj/item/banner/blue
	name = "niebieski sztandar"
	icon_state = "banner-blue"
	item_state = "banner-blue"
	desc = "Sztandar z logo niebieskiego bóstwa."

/obj/item/storage/backpack/bannerpack
	name = "plecak ze sztandarem Nanotrasen"
	desc = "Plecak z mnóstwem dodatkowego miejsca. Ma przyczepiony sztandar z logo Nanotrasen, którego nie da się zdjąć."
	icon_state = "bannerpack"

/obj/item/storage/backpack/bannerpack/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 27 //6 more then normal, for the tradeoff of declaring yourself an antag at all times.

/obj/item/storage/backpack/bannerpack/red
	name = "plecak z czerwonym sztandarem"
	desc = "Plecak z mnóstwem dodatkowego miejsca. Ma przyczepiony czerwony sztandar, którego nie da się zdjąć."
	icon_state = "bannerpack-red"

/obj/item/storage/backpack/bannerpack/blue
	name = "plecak z niebieskim sztandarem"
	desc = "Plecak z mnóstwem dodatkowego miejsca. Ma przyczepiony niebieski sztandar, którego nie da się zdjąć."
	icon_state = "bannerpack-blue"

//this is all part of one item set
/obj/item/clothing/suit/armor/plate/crusader
	name = "zbroja krzyżowca"
	desc = "Zbroja z metalu i tkaniny."
	icon_state = "crusader"
	w_class = WEIGHT_CLASS_BULKY
	slowdown = 2.0 //gotta pretend we're balanced.
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 40, "bomb" = 60, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60, "stamina" = 50)

/obj/item/clothing/suit/armor/plate/crusader/red
	icon_state = "crusader-red"

/obj/item/clothing/suit/armor/plate/crusader/blue
	icon_state = "crusader-blue"

/obj/item/clothing/head/helmet/plate/crusader
	name = "kaptur krzyżowca"
	desc = "Brązowawy kaptur."
	icon_state = "crusader"
	w_class = WEIGHT_CLASS_NORMAL
	flags_inv = HIDEHAIR|HIDEEARS|HIDEFACE
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 40, "bomb" = 60, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60, "stamina" = 50, "bleed" = 60)

/obj/item/clothing/head/helmet/plate/crusader/blue
	icon_state = "crusader-blue"

/obj/item/clothing/head/helmet/plate/crusader/red
	icon_state = "crusader-red"

//Prophet helmet
/obj/item/clothing/head/helmet/plate/crusader/prophet
	name = "kapelusz proroka"
	desc = "Kapelusz o religijnym wyglądzie."
	worn_icon = 'icons/mob/large-worn-icons/64x64/head.dmi'
	flags_1 = 0
	armor = list("melee" = 60, "bullet" = 60, "laser" = 60, "energy" = 50, "bomb" = 70, "bio" = 50, "rad" = 50, "fire" = 60, "acid" = 60, "stamina" = 60, "bleed" = 60) //religion protects you from disease and radiation, honk.
	worn_x_dimension = 64
	worn_y_dimension = 64

/obj/item/clothing/head/helmet/plate/crusader/prophet/red
	icon_state = "prophet-red"

/obj/item/clothing/head/helmet/plate/crusader/prophet/blue
	icon_state = "prophet-blue"

//Structure conversion staff
/obj/item/godstaff
	name = "laska boża"
	desc = "To patyk..?"
	icon_state = "godstaff-red"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	var/conversion_color = "#ffffff"
	var/staffcooldown = 0
	var/staffwait = 30


/obj/item/godstaff/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(staffcooldown + staffwait > world.time)
		return
	user.visible_message("[user] intonuje głęboko i macha laską!")
	if(do_after(user, 20,1,src))
		target.add_atom_colour(conversion_color, WASHABLE_COLOUR_PRIORITY) //wololo
	staffcooldown = world.time

/obj/item/godstaff/red
	icon_state = "godstaff-red"
	conversion_color = "#ff0000"

/obj/item/godstaff/blue
	icon_state = "godstaff-blue"
	conversion_color = "#0000ff"

/obj/item/clothing/gloves/plate
	name = "płytowe rękawice"
	icon_state = "crusader"
	desc = "Jak rękawiczki, tylko z metalu."
	siemens_coefficient = 0
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT

/obj/item/clothing/gloves/plate/red
	icon_state = "crusader-red"

/obj/item/clothing/gloves/plate/blue
	icon_state = "crusader-blue"

/obj/item/clothing/shoes/plate
	name = "płytowe buty"
	desc = "Metalowe buty, wyglądają na ciężkie."
	icon_state = "crusader"
	w_class = WEIGHT_CLASS_NORMAL
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 40, "bomb" = 60, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60, "stamina" = 30, "bleed" = 60) //does this even do anything on boots?
	clothing_flags = NOSLIP
	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT


/obj/item/clothing/shoes/plate/red
	icon_state = "crusader-red"

/obj/item/clothing/shoes/plate/blue
	icon_state = "crusader-blue"


/obj/item/storage/box/itemset/crusader
	name = "zestaw zbroi krzyżowca" //i can't into ck2 references
	desc = "Ta zbroja podobno wzorowana jest na zbrojach królów z innego świata sprzed tysięcy lat, którzy mordowali, spiskowali i knuli przeciwko każdemu, kto próbował zrobić im to samo. Niektóre rzeczy się nie zmieniają."


/obj/item/storage/box/itemset/crusader/blue/PopulateContents()
	new /obj/item/clothing/suit/armor/plate/crusader/blue(src)
	new /obj/item/clothing/head/helmet/plate/crusader/blue(src)
	new /obj/item/clothing/gloves/plate/blue(src)
	new /obj/item/clothing/shoes/plate/blue(src)


/obj/item/storage/box/itemset/crusader/red/PopulateContents()
	new /obj/item/clothing/suit/armor/plate/crusader/red(src)
	new /obj/item/clothing/head/helmet/plate/crusader/red(src)
	new /obj/item/clothing/gloves/plate/red(src)
	new /obj/item/clothing/shoes/plate/red(src)


/obj/item/claymore/weak
	desc = "Ten jest zardzewiały."
	force = 30
	block_level = 1
	block_upgrade_walk = 1
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	armour_penetration = 15

/obj/item/claymore/weak/ceremonial
	desc = "Zardzewiały claymore, niegdyś serce potężnego szkockiego klanu pokonanego i uciskanego przez tyranów. Przekazywany z pokolenia na pokolenie jako symbol oporu."
	force = 15
	block_power = 30
	armour_penetration = 5

/obj/item/katana/weak/curator
	desc = "Starożytna katana. Wykuta przez... cóż, nie jest napisane, ale na pewno jest autentyczna! I do tego ostra!"
	force = 15
	block_power = 5


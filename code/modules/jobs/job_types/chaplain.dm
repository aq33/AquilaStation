/datum/job/chaplain
	title = JOB_NAME_CHAPLAIN
	flag = CHAPLAIN
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = JOB_NAME_HEADOFPERSONNEL //NSV13
	selection_color = "#dddddd"


	outfit = /datum/outfit/job/chaplain

	access = list(ACCESS_MORGUE, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_THEATRE)
	minimal_access = list(ACCESS_MORGUE, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_THEATRE)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_CHAPLAIN
	departments = DEPARTMENT_BITFLAG_SERVICE
	rpg_title = "Paladyn"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/chaplain
	)

/datum/job/chaplain/after_spawn(mob/living/H, mob/M)
	. = ..()

	var/obj/item/storage/book/bible/booze/B = new

	if(GLOB.religion)
		H.mind?.holy_role = HOLY_ROLE_PRIEST
		B.deity_name = GLOB.deity
		B.name = GLOB.bible_name
		B.icon_state = GLOB.bible_icon_state
		B.item_state = GLOB.bible_item_state
		to_chat(H, "Na stacji istnieje już ustanowiona religia. Jesteś akolitą [GLOB.deity]. Podporządkuj się kapelanowi.")
		H.equip_to_slot_or_del(B, ITEM_SLOT_BACKPACK)
		GLOB.religious_sect?.on_conversion(H)
		return
	H.mind?.holy_role = HOLY_ROLE_HIGHPRIEST

	var/new_religion = DEFAULT_RELIGION
	if(M.client && M.client.prefs.active_character.custom_names["religion"])
		new_religion = M.client.prefs.active_character.custom_names["religion"]

	var/new_deity = DEFAULT_DEITY
	if(M.client && M.client.prefs.active_character.custom_names["deity"])
		new_deity = M.client.prefs.active_character.custom_names["deity"]

	B.deity_name = new_deity


	switch(lowertext(new_religion))
		if("christianity") // DEFAULT_RELIGION
			B.name = pick("Pismo Święte","Zwoje znad Morza Martwego")
		if("buddhism")
			B.name = "Sutry"
		if("clownism","honkmother","honk","honkism","comedy")
			B.name = pick("Święta Księga Żartów", "To tylko żart", "Hymny do Honkmatki")
		if("chaos")
			B.name = "Księga Lorgara"
		if("cthulhu")
			B.name = "Necronomicon"
		if("hinduism")
			B.name = "Wedy"
		if("imperium")
			B.name = "Budujący Elementarz"
		if("islam")
			B.name = "Koran"
		if("judaism")
			B.name = "Tora"
		if("lampism")
			B.name = "Fluorescencyjne Żarzenie"
		if("monkeyism","apism","gorillism","primatism")
			B.name = pick("Bananowe Szaleństwo", "Banany dla Harambe")
		if("mormonism")
			B.name = "Księga Mormona"
		if("pastafarianism")
			B.name = "Ewangelia Latającego Potwora Spaghetti"
		if("rastafarianism","rasta")
			B.name = "Święta Piby"
		if("satanism")
			B.name = "Nieświęta Biblia"
		if("science")
			B.name = pick("Zasada Względności", "Kwantowa Zagadka: Fizyka Spotyka Świadomość", "Programowanie Wszechświata", "Fizyka Kwantowa i Teologia", "Teoria Strun dla Opornych", "Poradnik: Zbuduj Własny Napęd Warp", "Tajemnice Bluespace", "Zabawa w Boga: Edycja Kolekcjonerska")
		if("scientology")
			B.name = pick("Biografia L. Rona Hubbarda","Dianetyka")
		if("servicianism", "partying")
			B.name = "Zasady Servicii"
			B.deity_name = pick("Servicia", "Kosmiczny Bachus", "Kosmiczny Dionizos")
			B.desc = "Szczęśliwy, syty, czysty. Żyj tym i dawaj to innym."
		if("subgenius")
			B.name = "Księga SubGeniusza"
		if("toolboxia","greytide")
			B.name = pick("Manifest Skrzynki z Narzędziami","Asystenci iRękawic")
		if("weeaboo","kawaii")
			B.name = pick("Kompendium Fanfików","Japoński dla Opornych","Manganomicon","Jak Ustalić Swój OTP")
		else
			B.name = "Święta Księga: [new_religion]"

	GLOB.religion = new_religion
	GLOB.bible_name = B.name
	GLOB.deity = B.deity_name

	H.equip_to_slot_or_del(B, ITEM_SLOT_BACKPACK)

	SSblackbox.record_feedback("text", "religion_name", 1, "[new_religion]", 1)
	SSblackbox.record_feedback("text", "religion_deity", 1, "[new_deity]", 1)

/datum/outfit/job/chaplain
	name = JOB_NAME_CHAPLAIN
	jobtype = /datum/job/chaplain

	id = /obj/item/card/id/job/chaplain
	belt = /obj/item/modular_computer/tablet/pda/chaplain
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/chaplain
	backpack_contents = list(
		/obj/item/nullrod = 1,
		/obj/item/choice_beacon/holy = 1,
		/obj/item/camera/spooky = 1
	)
	backpack = /obj/item/storage/backpack/cultpack
	satchel = /obj/item/storage/backpack/cultpack

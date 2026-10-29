/// Global proc that sets up all MOD themes as singletons in a list and returns it.
/proc/setup_mod_themes()
	. = list()
	for(var/path in typesof(/datum/mod_theme))
		var/datum/mod_theme/new_theme = new path()
		.[path] = new_theme

/// MODsuit theme, instanced once and then used by MODsuits to grab various statistics.
/datum/mod_theme
	/// Theme name for the MOD.
	var/name = "standardowy"
	/// Description added to the MOD.
	var/desc = "Skafander klasy cywilnej od Nakamura Engineering; poza nieco szybszym ruchem niewiele oferuje."
	/// Extended description on examine_more
	var/extended_desc = "Trzeciej generacji modułowy skafander klasy cywilnej od Nakamura Engineering, \
		w całej galaktyce podstawa w zastosowaniach cywilnych. Te skafandry mają własne zasilanie w tlen, \
		nadają się do próżni, są odporne na ogień i zagrożenia chemiczne i chronią przed wszystkim od \
		kichnięcia po broń biologiczną. Do walki nadają się jednak bardzo słabo ze względu na ilość \
		domyślnie montowanego poszycia, a ich siłowniki dają tylko odrobinę większą szybkość niż skafandry przemysłowe."
	/// Default skin of the MOD.
	var/default_skin = "standard"
	/// The slot this mod theme fits on
	var/slot_flags = ITEM_SLOT_BACK
	/// Armor shared across the MOD parts.
	var/list/armor = list("melee" = 10, "bullet" = 5, "laser" = 5, "energy" = 5, "bio" = 100, "rad" = 50, "fire" = 25, "acid" = 25, "bleed" = 5)
	/// Resistance flags shared across the MOD parts.
	var/resistance_flags = NONE
	/// Atom flags shared across the MOD parts.
	var/atom_flags = NONE
	/// Max heat protection shared across the MOD parts.
	var/max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	/// Max cold protection shared across the MOD parts.
	var/min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	/// Permeability shared across the MOD parts.
	var/permeability_coefficient = 0.01
	/// Siemens shared across the MOD parts.
	var/siemens_coefficient = 0.5
	/// How much modules can the MOD carry without malfunctioning.
	var/complexity_max = DEFAULT_MAX_COMPLEXITY
	/// How much battery power the MOD uses by just being on
	var/charge_drain = DEFAULT_CHARGE_DRAIN
	/// Slowdown of the MOD when all of its pieces are deployed.
	var/slowdown_deployed = 0.50 //same as syndicate hardsuits
	/// How long this MOD takes each part to seal.
	var/activation_step_time = MOD_ACTIVATION_STEP_TIME
	/// Theme used by the MOD TGUI.
	var/ui_theme = "ntos"
	/// List of inbuilt modules. These are different from the pre-equipped suits, you should mainly use these for unremovable modules with 0 complexity.
	var/list/inbuilt_modules = list()
	/// Allowed items in the chestplate's suit storage.
	var/list/allowed_suit_storage = list()
	/// List of variants and items created by them, with the flags we set.
	var/list/variants = list(
		"standard" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|HEADINTERNALS,
				SEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

#ifdef UNIT_TESTS
/datum/mod_theme/New()
	var/list/skin_parts = list()
	for(var/variant in variants)
		skin_parts += list(assoc_list_strip_value(variants[variant]))
	for(var/skin in skin_parts)
		for(var/compared_skin in skin_parts)
			if(skin ~! compared_skin)
				stack_trace("[type] variants [skin] and [compared_skin] aren't made of the same parts.")
		skin_parts -= skin
#endif

/// Create parts of the suit and modify them using the theme's variables.
/datum/mod_theme/proc/set_up_parts(obj/item/mod/control/mod, skin)
	var/list/parts = list(mod)
	mod.slot_flags = slot_flags
	mod.extended_desc = extended_desc
	mod.slowdown_deployed = slowdown_deployed
	mod.activation_step_time = activation_step_time
	mod.complexity_max = complexity_max
	mod.ui_theme = ui_theme
	mod.charge_drain = charge_drain
	var/datum/mod_part/control_part_datum = new()
	control_part_datum.part_item = mod
	mod.mod_parts["[mod.slot_flags]"] = control_part_datum
	for(var/path in variants[default_skin])
		if(!ispath(path))
			continue
		var/obj/item/mod_part = new path(mod)
		if(mod_part.slot_flags == ITEM_SLOT_OCLOTHING && isclothing(mod_part))
			var/obj/item/clothing/chestplate = mod_part
			chestplate.allowed |= allowed_suit_storage
		var/datum/mod_part/part_datum = new()
		part_datum.part_item = mod_part
		mod.mod_parts["[mod_part.slot_flags]"] = part_datum
		parts += mod_part

	for(var/obj/item/part as anything in parts)
		part.name = "[part.name] (model [name])"
		part.desc = "[part.desc] [desc]"
		part.armor = getArmor(arglist(armor))
		part.resistance_flags = resistance_flags
		part.flags_1 |= atom_flags //flags like initialization or admin spawning are here, so we cant set, have to add
		part.heat_protection = NONE
		part.cold_protection = NONE
		part.max_heat_protection_temperature = max_heat_protection_temperature
		part.min_cold_protection_temperature = min_cold_protection_temperature
		part.siemens_coefficient = siemens_coefficient

	set_skin(mod, skin || default_skin)

/datum/mod_theme/proc/set_skin(obj/item/mod/control/mod, skin)
	mod.skin = skin
	var/list/used_skin = variants[skin]
	var/list/parts = mod.get_parts()
	for(var/obj/item/clothing/part as anything in parts)
		var/list/category = used_skin[part.type]
		var/datum/mod_part/part_datum = mod.get_part_datum(part)
		part_datum.unsealed_layer = category[UNSEALED_LAYER]
		part_datum.sealed_layer = category[SEALED_LAYER]
		part_datum.unsealed_message = category[UNSEALED_MESSAGE] || "Brak komunikatu rozszczelnienia! Powiedz koderowi!"
		part_datum.sealed_message = category[SEALED_MESSAGE] || "Brak komunikatu uszczelnienia! Powiedz koderowi!"
		part_datum.can_overslot = category[CAN_OVERSLOT] || FALSE
		part.clothing_flags = category[UNSEALED_CLOTHING] || NONE
		part.visor_flags = category[SEALED_CLOTHING] || NONE
		part.flags_inv = category[UNSEALED_INVISIBILITY] || NONE
		part.visor_flags_inv = category[SEALED_INVISIBILITY] || NONE
		part.flags_cover = category[UNSEALED_COVER] || NONE
		part.visor_flags_cover = category[SEALED_COVER] || NONE
		if(mod.get_part_datum(part).sealed)
			part.clothing_flags |= part.visor_flags
			part.flags_inv |= part.visor_flags_inv
			part.flags_cover |= part.visor_flags_cover
			part.alternate_worn_layer = part_datum.sealed_layer
		else
			part.alternate_worn_layer = part_datum.unsealed_layer
		if(!part_datum.can_overslot && part_datum.overslotting)
			var/obj/item/overslot = part_datum.overslotting
			overslot.forceMove(mod.drop_location())
	for(var/obj/item/part as anything in parts + mod)
		part.icon = used_skin[MOD_ICON_OVERRIDE] || 'icons/obj/clothing/modsuit/mod_clothing.dmi'
		part.worn_icon = used_skin[MOD_WORN_ICON_OVERRIDE] || 'icons/mob/clothing/modsuit/mod_clothing.dmi'
		part.icon_state = "[skin]-[part.base_icon_state][mod.get_part_datum(part).sealed ? "-sealed" : ""]"
		mod.wearer?.update_clothing(part.slot_flags)

/datum/mod_theme/civilian
	name = "cywilny"
	desc = "Lekki skafander cywilny, który daje niezrównaną swobodę ruchu, ale nie chroni przed próżnią kosmosu."
	extended_desc = "Eksperymentalny projekt Nakamura Engineering, przeznaczony dla klientów na planetach. \
		Ten model rezygnuje z ochrony przed zagrożeniami biologicznymi i chemicznymi oraz próżnią w zamian za \
		znacznie lepszą mobilność. Ze względu na odchudzoną sylwetkę ma też mniej miejsca na modyfikacje niż \
		główne modele."
	default_skin = "civilian"
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 5, "bio" = 50, "rad" = 5, "fire" = 25, "acid" = 25, "bleed" = 10)
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
	slowdown_deployed = 0
	variants = list(
		"civilian" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/engineering
	name = "inżynieryjny"
	desc = "Skafander dla inżyniera, odporny na ciepło i prąd. Klasyk Nakamura Engineering."
	extended_desc = "Klasyk od Nakamura Engineering i z pewnością ich największa duma. Ten model to \
		ulepszenie prototypów pierwszej generacji sprzed Wojny Pustki, z całą gamą funkcji. \
		Modułową elastyczność bazowej konstrukcji połączono z izolowaną warstwą wewnętrzną tłumiącą wybuchy i \
		odporną na wstrząsy warstwą zewnętrzną, dzięki czemu skafander jest niemal niewrażliwy nawet na skrajnie wysokie napięcie. \
		Pojemność na modyfikacje pozostaje jednak taka sama jak w skafandrach cywilnych."
	default_skin = "engineering"
	armor = list("melee" = 15, "bullet" = 5, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 50, "stamina" = 15, "bleed" = 50)
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_deployed = 0.75
	allowed_suit_storage = list(
		/obj/item/construction/rcd,
		/obj/item/pipe_dispenser,
		/obj/item/storage/bag/construction,
	)
	variants = list(
		"engineering" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/atmospheric
	name = "atmosferyczny"
	desc = "Odporny na warunki atmosferyczne skafander od Nakamura Engineering, znacznie bardziej odporny na ciepło niż skafander inżynieryjny."
	extended_desc = "Zmodyfikowana wersja przemysłowego modelu Nakamura Engineering. Ten egzemplarz \
		wzmocniono najnowszymi stopami odpornymi na ciepło i serią zaawansowanych radiatorów. \
		Do tego materiały użyte do budowy skafandra czynią go niezwykle odpornym na \
		żrące gazy i ciecze, co przydaje się w świecie rur. \
		Pojemność na modyfikacje pozostaje jednak taka sama jak w skafandrach cywilnych."
	default_skin = "atmospheric"
	armor = list("melee" = 15, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 25, "fire" = 100, "acid" = 75, "stamina" = 15, "bleed" = 50)
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	slowdown_deployed = 0.75
	allowed_suit_storage = list(
		/obj/item/analyzer,
		/obj/item/t_scanner,
		/obj/item/construction/rcd,
		/obj/item/pipe_dispenser,
	)
	variants = list(
		"atmospheric" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDESNOUT,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR,
				UNSEALED_COVER = HEADCOVERSMOUTH,
				SEALED_COVER = HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/advanced
	name = "zaawansowany"
	desc = "Zaawansowana wersja klasycznego skafandra Nakamura Engineering, lśniąca białym lakierem odpornym na kwas i ogień."
	extended_desc = "Flagowa wersja przemysłowego modelu Nakamura Engineering i ich najnowszy produkt. \
		Łączy wszystkie funkcje pozostałych przemysłowych skafandrów firmy, a odpornością na wybuchy zbliża się \
		do niektórych skafandrów saperskich. Zewnętrzną powłokę pokryto białym lakierem, ponoć tajemnicą firmy. \
		Farba jest niemal całkowicie odporna na substancje żrące i wygląda cholernie dobrze. \
		Skafander ma fabrycznie zamontowane buty magnetyczne z zaawansowanym systemem, który włącza je i wyłącza w trakcie chodu."
	default_skin = "advanced"
	armor = list("melee" = 20, "bullet" = 5, "laser" = 20, "energy" = 15, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 90, "stamina" = 20, "bleed" = 50)
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_deployed = 0.5
	inbuilt_modules = list(/obj/item/mod/module/magboot/advanced)
	allowed_suit_storage = list(
		/obj/item/analyzer,
		/obj/item/construction/rcd,
		/obj/item/melee/classic_baton/police/telescopic,
		/obj/item/pipe_dispenser,
		/obj/item/storage/bag/construction,
		/obj/item/t_scanner,
	)
	variants = list(
		"advanced" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/mining
	name = "górniczy"
	desc = "Górniczy skafander Nanotrasenu do pracy w terenie, z narastającym pancerzem z popiołu i formą kuli."
	extended_desc = "Mocny skafander zaprojektowany przez Nanotrasen na bazie prac Nakamura Engineering. \
		Pierwsze projekty powstały z myślą o trudach górnictwa na asteroidach, z odpornością na wybuchy dzięki wbudowanej ceramice, \
		ale zespoły górnicze same mocno przerobiły skafander, wspierając się urządzeniami stworzonymi \
		dzięki niszczącej analizie nieznanych technologii odkrytych w kopalniach Indecipheres, wzorowanymi na \
		ich typowych skafandrach eksploracyjnych bez ochrony EVA. Wizjer rozbudowano do układu siedmiu pajęczych kamer, \
		dających pełny widok na teren i jego niedługo martwych mieszkańców. Poszycie zredukowano \
		do niezbędnego minimum, nastawionego bardziej na zagrożenia środowiskowe niż walkę z fauną; za to \
		daje świetną ochronę przed substancjami żrącymi i izolację termiczną wystarczającą zarówno \
		na swobodne pływanie grzbietem w roztopionej magmie, jak i romantyczne spacery po arktycznym terenie. \
		Zamiast tego skafander potrafi dzięki swoim anomalnym właściwościom przyciągać i \
		starannie rozprowadzać po powierzchni warstwy popiołu albo lodu; warstwy te się ścierają, ale są niezwykle wytrzymałe. \
		Wreszcie skafander potrafi ścisnąć i zmniejszyć masę noszącego, a także \
		przebudować własną strukturę, tak by ten zmieścił się w postaci kuli, która \
		toczy się, mając połowę pierwotnych rozmiarów, i zostawia za sobą potężne ładunki górnicze. \
		Wszystko to okazało się jednak zbyt dużym obciążeniem dla ogniw zatwierdzonych przez Nanotrasen, \
		do tego stopnia, że skafander domyślnie zasila równie zagadkowe paliwo plazmowe, a nie zwykłe ładowanie. \
		Do tego systemy pracują niemal na maksymalnym obciążeniu, przez co skafander pozwala na znacznie mniej modyfikacji niż inne."
	default_skin = "mining"
	armor = list("melee" = 25, "bullet" = 5, "laser" = 10, "energy" = 10, "bomb" = 30, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 75, "stamina" = 20, "bleed" = 60)
	resistance_flags = FIRE_PROOF|LAVA_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY - 2
	charge_drain = DEFAULT_CHARGE_DRAIN * 2
	allowed_suit_storage = list(
		/obj/item/resonator,
		/obj/item/mining_scanner,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/pickaxe,
		/obj/item/kinetic_crusher,
		/obj/item/stack/ore/plasma,
		/obj/item/storage/bag/ore,
		/obj/item/gun/energy/kinetic_accelerator,
	)
	inbuilt_modules = list(/obj/item/mod/module/ash_accretion, /obj/item/mod/module/sphere_transform)
	variants = list(
		"mining" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEEARS|HIDEHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDEBELT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
		"asteroid" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEEARS|HIDEHAIR|HIDESNOUT,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEYES|HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDEBELT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/loader
	name = "załadowczy"
	desc = "Nieszczelna, eksperymentalna zmotoryzowana uprząż od Scarborough Arms do szybkiego i sprawnego dostarczania amunicji."
	extended_desc = "Ten zasilany skafander to eksperymentalna odnoga skafandrów inżynieryjnych do pracy w atmosferze. \
		Ten w pełni przegubowy tytanowy egzoszkielet to ulubiony skafander dostawców amunicji Scarborough Arms, \
		a brak ochrony EVA nadrabia siłą i elastycznością. Główną cechą \
		skafandra są dwa ramiona manipulatorów, starannie zsynchronizowane z myślami użytkownika i \
		niemal dokładnie powtarzające jego ruchy. Napędza je myomer, sztuczny odpowiednik mięśni, \
		który do działania wymaga dużego napięcia; pod obciążeniem czasem iskrzy od samej mocy \
		skafandra zdolnego podnieść 250 ton. Nawet nogi skafandra dostrojono do niesamowitej wydajności, \
		dzięki czemu użytkownik biega szybciej, dalej i dłużej niż bez skafandra. \
		Wiele osób powie, że załadunek towarów to nudna praca. Nie możesz się z tym bardziej nie zgodzić."
	default_skin = "loader"
	armor = list("melee" = 15, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 25, "acid" = 25, "stamina" = 10, "bleed" = 25)
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	siemens_coefficient = 0.25
	complexity_max = DEFAULT_MAX_COMPLEXITY - 5
	slowdown_deployed = 0
	allowed_suit_storage = list(
		/obj/item/mail,
		/obj/item/small_delivery,
		/obj/item/paper,
		/obj/item/storage/bag/mail,
	)
	inbuilt_modules = list(/obj/item/mod/module/hydraulic, /obj/item/mod/module/clamp/loader, /obj/item/mod/module/magnet)
	variants = list(
		"loader" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				UNSEALED_INVISIBILITY = HIDEEARS|HIDEHAIR,
				SEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEYES|HIDEFACE|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				SEALED_CLOTHING = THICKMATERIAL,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				SEALED_CLOTHING = THICKMATERIAL,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/medical
	name = "medyczny"
	desc = "Lekki skafander od DeForest Medical Corporation, ułatwiający poruszanie się."
	extended_desc = "Lekki skafander produkcji DeForest Medical Corporation, oparty na pracach \
		Nakamura Engineering. Najnowsza technologia uodparnia go na \
		alergeny, toksyny w powietrzu i zwykłe patogeny. Główną zaletą skafandra jest szybkość, \
		łącząca mocne serwomechanizmy i siłowniki z konstrukcją z włókna węglowego. Pancerza jest bardzo mało, ale \
		skafander jest niezwykle odporny na kwasy. Pobiera nieco więcej energii niż modele cywilne \
		i nie lubi pukania palcem w szybkę."
	default_skin = "medical"
	armor = list("melee" = 10, "bullet" = 5, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 60, "acid" = 75, "stamina" = 15, "bleed" = 55)
	charge_drain = DEFAULT_CHARGE_DRAIN * 1.5
	slowdown_deployed = 0.5
	allowed_suit_storage = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/stack/medical,
		/obj/item/sensor_device,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/bag/chemistry,
		/obj/item/storage/bag/bio,
	)
	variants = list(
		"medical" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
		"corpsman" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/rescue
	name = "ratunkowy"
	desc = "Zaawansowana wersja skafandra medycznego DeForest Medical Corporation do szybkiego wydobywania ciał z najniebezpieczniejszych środowisk."
	extended_desc = "Ulepszona, opancerzona wersja skafandra medycznego DeForest Medical Corporation, \
		zaprojektowana do szybkiego wydobywania ciał z najniebezpieczniejszych środowisk. Ma te same zaawansowane serwa nóg \
		co wersja bazowa, dające ratownikom niesamowitą szybkość, ale takie same serwa są też w ramionach. \
		Ten skafander pozwala szybko taszczyć nawet najcięższych członków załogi, \
		a przy tym zapewnia pełną odporność na zagrożenia chemiczne i termiczne. \
		Pobiera nieco więcej energii niż modele cywilne i nie lubi pukania palcem w szybkę."
	default_skin = "rescue"
	armor = list("melee" = 15, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 15, "bio" = 100, "rad" = 60, "fire" = 100, "acid" = 100, "stamina" = 20, "bleed" = 50)
	resistance_flags = FIRE_PROOF|ACID_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	charge_drain = DEFAULT_CHARGE_DRAIN * 1.5
	slowdown_deployed = 0.25
	inbuilt_modules = list(/obj/item/mod/module/quick_carry/advanced)
	allowed_suit_storage = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/stack/medical,
		/obj/item/sensor_device,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/bag/chemistry,
		/obj/item/storage/bag/bio,
		/obj/item/melee/classic_baton/police/telescopic,
	)
	variants = list(
		"rescue" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/research
	name = "badawczy"
	desc = "Prywatny wojskowy skafander saperski od Aussec Armory do badań nad materiałami wybuchowymi. Masywny, ale pojemny."
	extended_desc = "Prywatny wojskowy skafander saperski od Aussec Armory, oparty na pracach Nakamura Engineering. \
		Przeznaczony do badań nad materiałami wybuchowymi, jest niezwykle masywny i szczelnie kryje ciało. \
		Ma wbudowany zestaw skanerów chemicznych i dwie warstwy pancerza z plastytanu, \
		między którymi znajduje się obojętna warstwa rozpraszająca energię kinetyczną w skafandrze, z dala od użytkownika; \
		przewyższa nawet najlepsze konwencjonalne skafandry saperskie. Mimo odporności nawet na \
		pociski rakietowe i artylerię cała ta odporność na wybuchy służy głównie temu, by użytkownik pozostał w jednym kawałku, \
		niekoniecznie żywy. Użytkownik przekona się też, że przejście przez wąskie framugi jest niemal niemożliwe."
	default_skin = "research"
	armor = list("melee" = 20, "bullet" = 15, "laser" = 5, "energy" = 5, "bomb" = 100, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 100, "stamina" = 25, "bleed" = 50)
	resistance_flags = FIRE_PROOF|ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY + 5
	slowdown_deployed = 1
	inbuilt_modules = list(/obj/item/mod/module/reagent_scanner/advanced)
	allowed_suit_storage = list(
		/obj/item/analyzer,
		/obj/item/dnainjector,
		//obj/item/biopsy_tool,
		//obj/item/experi_scanner,
		/obj/item/storage/bag/bio,
		/obj/item/melee/classic_baton/police/telescopic,
	)
	variants = list(
		"research" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/security
	name = "ochrony"
	desc = "Skafander ochrony od Apadyne Technologies, szybszy kosztem pojemności."
	extended_desc = "Klasyk od Apadyne Technologies; ten model MODsuitu zaprojektowano do szybkiej reakcji na \
		wrogie sytuacje. Pokryto go poszyciem odpornym na ogień i środowiska żrące, \
		a pod kadłubem ma kompozytowe amortyzatory i zaawansowaną strukturę plastra miodu chroniące \
		przed złamaniami i możliwymi oderwaniami tkanek. Nogi skafandra dostały mocniejsze siłowniki, \
		dzięki czemu skafander bardziej odciąża użytkownika przy noszeniu ciężaru. Systemy w tych skafandrach są jednak \
		przestarzałe o dobrych kilka lat, przez co pojemność na moduły jest ogólnie mniejsza."
	default_skin = "security"
	armor = list("melee" = 20, "bullet" = 20, "laser" = 15, "energy" = 25, "bomb" = 25, "bio" = 100, "rad" = 30, "fire" = 75, "acid" = 75, "stamina" = 25, "bleed" = 50)
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
	slowdown_deployed = 0.5
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
	)
	variants = list(
		"security" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEEARS|HIDEHAIR|HIDESNOUT,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEYES|HIDEFACE,
				UNSEALED_COVER = HEADCOVERSMOUTH,
				SEALED_COVER = HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/safeguard
	name = "Safeguard"
	desc = "Zaawansowany skafander ochrony od Apadyne Technologies, szybszy i lepiej chroniący przed ogniem niż standardowy model ochrony."
	extended_desc = "Zaawansowany skafander ochrony od Apadyne Technologies, ich najnowszy model. W tym wariancie \
		całkowicie zrezygnowano ze zbrojonego szklanego wizjera, zastępując go „wizjerem przeciwwybuchowym”, w którym \
		mała kamera po lewej stronie pokazuje użytkownikowi otoczenie. Poszycie skafandra \
		znacznie pogrubiono, zwłaszcza na naramiennikach, co nadaje noszącemu imponującą sylwetkę. \
		Boki skafandra wyłożono radiatorami, a lepsza technologia izoluje go zarówno od \
		środowisk żrących, jak i od nagłych uderzeń w stawy użytkownika."
	default_skin = "safeguard"
	armor = list("melee" = 20, "bullet" = 20, "laser" = 15, "energy" = 25, "bomb" = 40, "bio" = 100, "rad" = 40, "fire" = 100, "acid" = 95, "stamina" = 30, "bleed" = 55)
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	//inbuilt_modules = list(/obj/item/mod/module/shove_blocker/locked)
	slowdown_deployed = 0.25
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
	)
	variants = list(
		"safeguard" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/magnate
	name = "Magnat"
	desc = "Elegancki, bardzo wytrzymały skafander dla kapitanów Nanotrasenu. Odporny na prąd, ogień i kwas, a przy tym pojemny i szybki."
	extended_desc = "Mówią, że utrzymanie tego MODsuitu kosztuje czterysta tysięcy kredytów... za dwanaście sekund. \
		Skafander Magnat zaprojektowano z myślą o ochronie, wygodzie i luksusie kapitanów Nanotrasenu. \
		Pokładowe filtry powietrza zaprogramowano z dodatkowymi pięciuset zapachami, które mogą \
		być wtłaczane do hełmu, wszystkie z bardzo zagrożonych gatunków kwiatów. W nadgarstku umieszczono \
		szyty na miarę mechaniczny zegarek Tralex, a pakiet Magnat zawiera spinki do mankietów z włókna węglowego do noszenia pod spodem. \
		Mój Boże, ma nawet granitowe wykończenia. Podwójnie tajna farba, którą pieczołowicie nałożono na kadłub, \
		chroni przed prądem, ogniem i najsilniejszymi kwasami. Systemy pokładowe korzystają z metapozytronowego uczenia \
		i przetwarzania bluespace, by obsłużyć szeroką gamę modułów, a do szybkości użyto tylko najlepszych siłowników. \
		Podobieństwo do hełmu Maruderów Gorlex jest czysto przypadkowe."
	default_skin = "magnate"
	armor = list("melee" = 20, "bullet" = 25, "laser" = 25, "energy" = 25, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100, "stamina" = 30, "bleed" = 50)
	resistance_flags = FIRE_PROOF|ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	complexity_max = DEFAULT_MAX_COMPLEXITY + 5
	slowdown_deployed = 0.25
	allowed_suit_storage = list(
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
	)
	variants = list(
		"magnate" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/cosmohonk
	name = "Cosmohonk"
	desc = "Skafander od Honk Ltd. Chroni przed środowiskami o niskim poziomie humoru. Większość technologii poszła na obniżenie poboru energii."
	extended_desc = "MODsuit Cosmohonk pierwotnie zaprojektowano do międzygwiezdnej komedii w środowiskach o niskim poziomie humoru. \
		Ma obudowę z elektroceramiki wolframowej i chromowe bipolary, pokryte farbą cyrkonowo-borową pod \
		dermatiraeliańskim stopem podprzestrzennym. Mimo rzucających się w oczy pedałów optronicznego napędu próżniowego \
		ten model nie korzysta z manganowych bipolarnych oczyszczaczy kondensatorów, dzięki niech będą Matce Honk. \
		Wiesz tylko, że ten skafander jest zagadkowo energooszczędny i zbyt kolorowy, by Mim go ukradł."
	default_skin = "cosmohonk"
	armor = list("melee" = 5, "bullet" = 5, "laser" = 20, "energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 25, "fire" = 60, "acid" = 30, "stamina" = 5, "bleed" = 5)
	charge_drain = DEFAULT_CHARGE_DRAIN * 0.25
	slowdown_deployed = 1
	allowed_suit_storage = list(
		/obj/item/bikehorn,
		/obj/item/food/grown/banana,
		/obj/item/grown/bananapeel,
		/obj/item/reagent_containers/spray/waterflower,
		/obj/item/instrument,
		//obj/item/toy/balloon_animal,
	)
	variants = list(
		"cosmohonk" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEEARS|HIDEHAIR,
				SEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEYES|HIDEFACE|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/syndicate
	name = "Syndykatu"
	desc = "Skafander zaprojektowany przez Maruderów Gorlex, z pancerzem zakazanym w większości Gwiezdnej Koalicji Spinward."
	extended_desc = "Zaawansowany skafander bojowy w złowrogiej, karmazynowej kolorystyce, projektowany i produkowany \
		do specjalnych operacji najemniczych. Konstrukcja to opływowe warstwy formowanej plastali \
		i kompozytowej ceramiki, a podkład wyścielono lekkim hybrydowym splotem kevlaru i duratkaniny, \
		który chroni użytkownika tam, gdzie nie sięga poszycie; do tego nielegalny pokładowy, zasilany elektrycznie \
		moduł tarczy ablacyjnej zapewnia odporność na konwencjonalną broń energetyczną. \
		Zwisa z niego mała metka z napisem: „Własność Maruderów Gorlex, przy wsparciu Cybersun Industries. \
		Wszelkie prawa zastrzeżone, ingerencja w skafander unieważnia gwarancję”."
	default_skin = "syndicate"
	armor = list("melee" = 22.5, "bullet" = 22.5, "laser" = 15, "energy" = 30, "bomb" = 35, "bio" = 100, "rad" = 40, "fire" = 50, "acid" = 90, "stamina" = 30, "bleed" = 70)
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	complexity_max = DEFAULT_MAX_COMPLEXITY + 3
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_deployed = 0
	ui_theme = "syndicate"
	resistance_flags = FIRE_PROOF
	inbuilt_modules = list(/obj/item/mod/module/armor_booster)
	allowed_suit_storage = list(
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
		/obj/item/melee/transforming/energy/sword,
		/obj/item/shield/energy,
	)
	variants = list(
		"syndicate" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
		"honkerative" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/elite
	name = "elitarny"
	desc = "Elitarny skafander ulepszony przez Cybersun Industries, z mocniejszym pancerzem."
	extended_desc = "Ewolucja skafandra Syndykatu o masywniejszej budowie i matowej czarnej kolorystyce; \
		produkuje się go wyłącznie dla wysokich rangą oficerów Syndykatu i elitarnych oddziałów uderzeniowych. \
		W poszycie wbudowano drugą warstwę ceramiki i kevlaru, co daje mu \
		wyjątkowo lepszą ochronę oraz odporność na ogień i kwas. Zwisa z niego mała metka z napisem: \
		„Własność Maruderów Gorlex, przy wsparciu Cybersun Industries. \
		Wszelkie prawa zastrzeżone, ingerencja w skafander unieważnia oczekiwaną długość życia”."
	default_skin = "elite"
	armor = list("melee" = 35, "bullet" = 30, "laser" = 35, "energy" = 35, "bomb" = 55, "bio" = 100, "rad" = 65, "fire" = 100, "acid" = 100, "stamina" = 45, "bleed" = 70)
	resistance_flags = FIRE_PROOF|ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY + 3
	siemens_coefficient = 0
	slowdown_deployed = 0
	ui_theme = "syndicate"
	inbuilt_modules = list(/obj/item/mod/module/armor_booster)
	allowed_suit_storage = list(
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
		/obj/item/melee/transforming/energy/sword,
		/obj/item/shield/energy,
	)
	variants = list(
		"elite" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/infiltrator
	name = "Infiltrator"
	desc = "Specjalistyczny skafander infiltracyjny opracowany przez Gildię Aktorów Roseus Galactic, by budzić strach i podziw w sercach publiczności."
	extended_desc = "Przez lata pojawiło się wiele pytań o tajny modułowy skafander Infiltrator. \
		Dlaczego skafander do skradania jest krwistoczerwony? Dlaczego akurat wytwórnia filmowa opracowała skafander maskujący? \
		Najprostsza odpowiedź: Roseus Galactic zatrudnia sporo ekscentryków, którzy wiedzą więcej o \
		estetyce i projektowaniu rekwizytów niż o skutecznym kamuflażu operacyjnym. Prawdziwy powód sięga jednak głębiej. \
		Wygląd skafandra to bezczelny pokaz siły, a nie prawdziwe ukrycie. Wbudowane mechanizmy maskujące \
		sprawiają jednak, że nikt nie rozpozna noszącego, tylko sam skafander, co daje doskonałą anonimowość. Tę wizualną przemianę \
		wspierają wbudowane psi-emitery, które potęgują stresory typowe dla personelu Nanotrasenu i zaciemniają dane identyfikacyjne. \
		Oczyszczone dane statystyczne wykazały jedną korelację w udokumentowanych profilach psychologicznych. Strach przed Nieznanym."
	default_skin = "infiltrator"
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 40, "bomb" = 40, "rad" = 75, "fire" = 100, "acid" = 100, "stamina" = 40, "bleed" = 50)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	siemens_coefficient = 0
	slowdown_deployed = 0
	activation_step_time = MOD_ACTIVATION_STEP_TIME * 0.5
	ui_theme = "syndicate"
	slot_flags = ITEM_SLOT_BELT
	inbuilt_modules = list(/obj/item/mod/module/infiltrator, /obj/item/mod/module/storage/belt, /obj/item/mod/module/demoralizer)
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
		/obj/item/melee/transforming/energy/sword,
		/obj/item/shield/energy,
	)
	variants = list(
		"infiltrator" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				UNSEALED_INVISIBILITY = HIDEEARS|HIDEHAIR,
				SEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEYES|HIDEFACE|HIDESNOUT|HIDEANTENNAE,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDEMUTWINGS,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				SEALED_CLOTHING = THICKMATERIAL,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				SEALED_CLOTHING = THICKMATERIAL,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/enchanted
	name = "zaczarowany"
	desc = "Stosunkowo prymitywny technicznie MODsuit Federacji Czarodziejów. Za to bardzo dobrze chroni."
	extended_desc = "Stosunkowo prymitywny technicznie MODsuit Federacji Czarodziejów. Ten pancerz nie chroni \
		plastalą ani włóknem węglowym, tylko łuskami kosmicznego smoka. Rekruci mają je \
		zebrać sami, ale wysiłek się opłaca, bo skafander dobrze chroni przed zagrożeniami \
		zarówno przyziemnymi, jak i mistycznymi. Zamiast polegać wyłącznie na ogniwie, które z pewnością padłoby \
		pod takim obciążeniem, jako domyślne źródło zasilania wykorzystano kilka naturalnie występujących \
		kamieni szlachetnych bluespace. Przeznaczenie kaptura i butów na platformie jest nieznane, ale podejrzewa się, \
		że czarodzieje mają skłonność do dramatyzmu."
	default_skin = "enchanted"
	armor = list("melee" = 40, "bullet" = 40, "laser" = 50, "energy" = 50, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100, "stamina" = 50, "bleed" = 60)
	resistance_flags = FIRE_PROOF|ACID_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	slowdown_deployed = 0.25
	ui_theme = "wizard"
	inbuilt_modules = list(/obj/item/mod/module/anti_magic/wizard)
	allowed_suit_storage = list(
		/obj/item/teleportation_scroll,
		//obj/item/highfrequencyblade/wizard,
		/obj/item/gun/magic,
	)
	variants = list(
		"enchanted" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL|CASTING_CLOTHES,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL|CASTING_CLOTHES,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/ninja
	name = "ninja"
	desc = "Unikalny, szczelny na próżnię, nanowzmocniony pancerz zaprojektowany specjalnie dla zabójców Klanu Pająka."
	extended_desc = "Nanowzmocniony pancerz zaprojektowany specjalnie dla zabójców-sabotażystów Klanu Pająka. \
		Ten MODsuit to szczyt technologii maskowania i walki: przylega do skóry, a jest równie wytrzymały jak \
		skafandry dwa lub trzy razy grubsze. Nanomaszyny tworzące zewnętrzną warstwę pancerza \
		potrafią zmieniać kształt w niemal mikroskopijne żeberka chłodzące, przez co sam skafander \
		jest prawie niewrażliwy nawet na wulkaniczny żar. Jest całkowicie szczelny nawet na najsilniejsze kwasy, \
		a mioelektryczne sztuczne mięśnie sprawiają, że w ruchu jest lekki jak piórko."
	default_skin = "ninja"
	armor = list("melee" = 40, "bullet" = 30, "laser" = 20, "energy" = 30, "bomb" = 30, "bio" = 100, "rad" = 60, "fire" = 100, "acid" = 100, "bleed" = 60)
	resistance_flags = LAVA_PROOF|FIRE_PROOF|ACID_PROOF
	charge_drain = DEFAULT_CHARGE_DRAIN * 0.5
	complexity_max = DEFAULT_MAX_COMPLEXITY + 2 //Minor enough to allow for installing HUDs or storage expander if the crew research it
	siemens_coefficient = 0
	slowdown_deployed = 0
	ui_theme = "hackerman"
	inbuilt_modules = list(/obj/item/mod/module/welding/camera_vision, /obj/item/mod/module/hacker, /obj/item/mod/module/weapon_recall, /obj/item/mod/module/adrenaline_boost, /obj/item/mod/module/energy_net)
	allowed_suit_storage = list(
		/obj/item/gun,
		/obj/item/melee/baton,
		/obj/item/restraints/handcuffs,
	)
	variants = list(
		"ninja" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEEARS|HIDEHAIR,
				SEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEYES|HIDEFACE|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/prototype
	name = "prototypowy"
	desc = "Prototypowy skafander modułowy napędzany lokomotywami. Jest wygodny i pojemny, ale wciąż bardzo masywny i nieoszczędny."
	extended_desc = "To prototyp zasilanego egzoszkieletu, konstrukcja niewidziana od setek lat, pierwszy \
		modułowy skafander z ery po Wojnie Pustki, którego operator mógł bezpiecznie używać. Ten pradawny grat wciąż działa, \
		choć brakuje mu kilku nowoczesnych udogodnień z nowszych projektów Nakamura Engineering. \
		Przede wszystkim mioelektryczna warstwa skafandra w ogóle nie istnieje, a serwa niewiele \
		pomagają rozłożyć ciężar na ciało noszącego, gdy skafander jest wyłączony, przez co porusza się w nim wolno i ociężale. \
		Wewnętrzny wyświetlacz HUD jest w niemal nieczytelnym cyjanie, co sugeruje już wizjer, \
		przez co użytkownik nie widzi na duże odległości. Za to sposób, w jaki chowa się hełm, jest całkiem fajny."
	default_skin = "prototype"
	armor = list("melee" = 25, "bullet" = 10, "laser" = 20, "energy" = 15, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 75, "stamina" = 30, "bleed" = 55)
	resistance_flags = FIRE_PROOF
	siemens_coefficient = 0
	complexity_max = DEFAULT_MAX_COMPLEXITY + 7
	charge_drain = DEFAULT_CHARGE_DRAIN * 2
	slowdown_deployed = 0.75
	ui_theme = "hackerman"
	inbuilt_modules = list(/obj/item/mod/module/anomaly_locked/kinesis)
	allowed_suit_storage = list(
		/obj/item/analyzer,
		/obj/item/t_scanner,
		/obj/item/pipe_dispenser,
		/obj/item/construction/rcd,
	)
	variants = list(
		"prototype" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/responsory
	name = "interwencyjny"
	desc = "Szybki skafander ratunkowy Nanotrasenu dla zespołów reagowania kryzysowego."
	extended_desc = "Opływowy skafander projektu Nanotrasenu; te smukłe czarne skafandry noszą wyłącznie \
		elitarni ratownicy zespołów reagowania kryzysowego, którzy ratują sytuację. Smukła i zwinna konstrukcja \
		ogranicza ilość ceramiki i warstw ablacyjnych, obniżając ochronę, \
		ale chroni noszącego przed surową próżnią kosmosu, nie tracąc przy tym ani trochę szybkości. \
		Nosząc go, czujesz ogromny szacunek dla ciemności. "
	default_skin = "responsory"
	armor = list("melee" = 45, "bullet" = 40, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 90, "fire" = 100, "acid" = 90, "stamina" = 40, "bleed" = 60)
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_deployed = 0
	allowed_suit_storage = list(
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
		/obj/item/storage/bag/trash,
		/obj/item/construction,
	)
	variants = list(
		"responsory" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
		"inquisitory" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/apocryphal
	name = "Apocryphal"
	desc = "Zaawansowany, legalny tylko formalnie opancerzony skafander, wspólne dzieło Nanotrasenu i Apadyne Technologies."
	extended_desc = "Masywny i legalny tylko na mocy kruczka MODsuit; ten złowrogi czarno-czerwony skafander noszą wyłącznie \
		oddziały Black Ops Nanotrasenu. Jeśli widzisz ten skafander, to coś spieprzyłeś. Wspólne dzieło \
		Apadyne i Nanotrasenu; konstrukcja i moduły dają użytkownikowi solidną ochronę przed \
		wszystkim, czym można w niego rzucić, oraz narzędzia do wyostrzonej świadomości sytuacji w walce. \
		Czy noszący z nich skorzysta, zależy od niego. \
		Na nadgarstku widnieje mały napis: „squiddie”, ojej."
	default_skin = "apocryphal"
	armor = list("melee" = 70, "bullet" = 70, "laser" = 50, "energy" = 60, "bomb" = 100, "bio" = 100, "rad" = 80, "fire" = 100, "acid" = 100, "stamina" = 50, "bleed" = 60)
	resistance_flags = FIRE_PROOF|ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	complexity_max = DEFAULT_MAX_COMPLEXITY + 10
	allowed_suit_storage = list(
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
		/obj/item/melee/transforming/energy/sword,
		/obj/item/shield/energy,
	)
	variants = list(
		"apocryphal" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEEARS|HIDEHAIR,
				SEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEYES|HIDEFACE|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/corporate
	name = "korporacyjny"
	desc = "Elegancki, zaawansowany skafander dla wysokich rangą oficerów Nanotrasenu."
	extended_desc = "Jeszcze droższa wersja modelu Magnat; skafander korporacyjny jest izolowany termicznie, \
		pokryty powłoką antykorozyjną i przeznaczony dla wysokich rangą oficerów Centrali; rozkłada nieskazitelny pancerz ochronny i \
		zaawansowane siłowniki, a po włączeniu jest praktycznie nieważki. Zdrapanie farby z tego skafandra \
		uznaje się za zbrodnię wojenną i powód do natychmiastowej egzekucji na ponad pięćdziesięciu stacjach Nanotrasenu. \
		Podobieństwo do hełmu Maruderów Gorlex jest czysto przypadkowe. To najnowsza rewizja V2, która ma \
		odblaskową osłonę ze zbrojonego szkła plazmowego przeplecioną zaawansowanymi włóknami kevlaru. Źródła mówią, że część pancerza \
		zdarto prosto z MODsuitu Apocryphal."
	default_skin = "corporate"
	armor = list("melee" = 65, "bullet" = 65, "laser" = 55, "energy" = 50, "bomb" = 60, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 100, "bleed" = 15)
	resistance_flags = FIRE_PROOF|ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_deployed = 0
	allowed_suit_storage = list(
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
	)
	variants = list(
		"corporate" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEEARS|HIDEHAIR|HIDESNOUT,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEYES|HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/debug
	name = "debugowy"
	desc = "Dziwnie nostalgiczny."
	extended_desc = "Zaawansowany skafander z dwoma silnikami jonowymi, na tyle mocnymi, że humanoid może latać. \
		Zawiera wewnętrzny, samoładujący się kondensator wysokoprądowy do krótkich, potężnych zry- \
		A nie, czekaj, to wcale nie jest skafander do latania. Kurwa."
	default_skin = "debug"
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100, "stamina" = 50)
	resistance_flags = FIRE_PROOF|ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	complexity_max = 50
	siemens_coefficient = 0
	slowdown_deployed = 0
	activation_step_time = MOD_ACTIVATION_STEP_TIME * 0.2
	allowed_suit_storage = list(
		/obj/item/gun,
	)
	variants = list(
		"debug" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEEARS|HIDEHAIR|HIDESNOUT,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE,
				UNSEALED_COVER = HEADCOVERSMOUTH,
				SEALED_COVER = HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/administrative
	name = "administracyjny"
	desc = "Skafander z adminium. Kto wymyśla te głupie nazwy minerałów?"
	extended_desc = "No dobra, chyba można to nazwać eventem. Dla mnie event to coś naprawdę \
		zabawnego i wciągającego dla graczy, a tu większość siedziała z boku, martwa albo rozerwana, a tylko garstka szczęściarzy \
		miała całą zabawę. Jeśli tak dalej będą wyglądać twoje „eventy” (Admin Abuse), \
		będzie skarga na admina. Zostałeś ostrzeżony."
	default_skin = "debug"
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100, "stamina" = 100, "bleed" = 100)
	resistance_flags = INDESTRUCTIBLE|LAVA_PROOF|FIRE_PROOF|UNACIDABLE|ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	complexity_max = 1000
	charge_drain = DEFAULT_CHARGE_DRAIN * 0
	siemens_coefficient = 0
	slowdown_deployed = 0
	activation_step_time = MOD_ACTIVATION_STEP_TIME * 0.01
	allowed_suit_storage = list(
		/obj/item/gun,
	)
	variants = list(
		"debug" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEEARS|HIDEHAIR|HIDESNOUT,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)


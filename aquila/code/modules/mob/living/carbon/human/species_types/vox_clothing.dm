// Ubrania na sylwetce Voxa (dziób, wysunięta głowa, pazury, nogi jak u ptaka).
// U Yoga każdy rodzaj przedmiotu ma sprite_sheets = list(SPECIES_VOX = plik), a update_icons() bierze z niego stan,
// jeśli istnieje. U nas sprite_sheets to bitflaga starego systemu Bee, więc robimy to w jednym miejscu:
// gotowy wygląd z build_worn_icon() dostaje plik Voxa, gdy dla pliku źródłowego jest odpowiednik ze stanem o tej nazwie.
// Pliki Voxa (aquila/icons/mob/species/vox/clothing/) mają te same nazwy stanów co nasze pliki. Zawierają sprite'y Voxa
// z Yogstation tam, gdzie nasz przedmiot wygląda jak u Yoga, a dla głowy, maski, okularów, słuchawek, rękawic i butów
// także wersje przerobione automatycznie z naszych ludzkich sprite'ów. Czego nie ma w pliku Voxa, zostaje ludzkie.

/// Nasz plik ubrań na postaci -> plik Voxa z tymi samymi stanami
GLOBAL_LIST_INIT(vox_worn_icons, list(
	"icons/mob/clothing/head.dmi" = 'aquila/icons/mob/species/vox/clothing/head.dmi',
	"nsv13/icons/mob/head.dmi" = 'aquila/icons/mob/species/vox/clothing/head_nsv13.dmi',
	"aquila/icons/mob/head.dmi" = 'aquila/icons/mob/species/vox/clothing/head_aquila.dmi',
	"aquila/icons/mob/clothing/head/helmet.dmi" = 'aquila/icons/mob/species/vox/clothing/helmet_aquila.dmi',
	"icons/mob/mask.dmi" = 'aquila/icons/mob/species/vox/clothing/mask.dmi',
	"nsv13/icons/mob/mask.dmi" = 'aquila/icons/mob/species/vox/clothing/mask_nsv13.dmi',
	"icons/mob/eyes.dmi" = 'aquila/icons/mob/species/vox/clothing/eyes.dmi',
	"icons/mob/ears.dmi" = 'aquila/icons/mob/species/vox/clothing/ears.dmi',
	"icons/mob/clothing/hands.dmi" = 'aquila/icons/mob/species/vox/clothing/hands.dmi',
	"nsv13/icons/mob/hands.dmi" = 'aquila/icons/mob/species/vox/clothing/hands_nsv13.dmi',
	"icons/mob/clothing/feet.dmi" = 'aquila/icons/mob/species/vox/clothing/feet.dmi',
	"nsv13/icons/mob/feet.dmi" = 'aquila/icons/mob/species/vox/clothing/feet_nsv13.dmi',
	"aquila/icons/mob/feet.dmi" = 'aquila/icons/mob/species/vox/clothing/feet_aquila.dmi',
	"icons/mob/clothing/uniform.dmi" = 'aquila/icons/mob/species/vox/clothing/uniform.dmi',
	"icons/mob/clothing/suit.dmi" = 'aquila/icons/mob/species/vox/clothing/suit.dmi',
	"icons/mob/clothing/back.dmi" = 'aquila/icons/mob/species/vox/clothing/back.dmi',
	"icons/mob/clothing/modsuit/mod_clothing.dmi" = 'aquila/icons/mob/species/vox/clothing/mod_clothing.dmi',
	"aquila/icons/nfz/nfz_noszone.dmi" = 'aquila/icons/mob/species/vox/clothing/nfz.dmi',
	"aquila/icons/inpost/inpost_noszone.dmi" = 'aquila/icons/mob/species/vox/clothing/inpost.dmi',
	"aquila/icons/policja/przedmioty_noszone.dmi" = 'aquila/icons/mob/species/vox/clothing/policja.dmi',
	"aquila/icons/mob/clothing/hardsuit_trauma.dmi" = 'aquila/icons/mob/species/vox/clothing/hardsuit_trauma.dmi',
))

/// Konfiguracja GAGS na postaci -> wersja dla Voxa (kombinezony i trampki z Yoga, te same pliki JSON)
GLOBAL_LIST_INIT(vox_gags_worn_configs, list(
	"/datum/greyscale_config/jumpsuit_worn" = /datum/greyscale_config/vox_jumpsuit_worn,
	"/datum/greyscale_config/jumpsuit_prison_worn" = /datum/greyscale_config/vox_jumpsuit_prison_worn,
	"/datum/greyscale_config/sneakers_worn" = /datum/greyscale_config/vox_sneakers_worn,
	"/datum/greyscale_config/sneakers_orange_worn" = /datum/greyscale_config/vox_sneakers_orange_worn,
))

/datum/greyscale_config/vox_jumpsuit_worn
	name = "Kombinezon na postaci (Vox)"
	icon_file = 'aquila/icons/mob/species/vox/clothing/gags_uniform.dmi'
	json_config = 'code/datums/greyscale/json_configs/jumpsuit_worn.json'

/datum/greyscale_config/vox_jumpsuit_prison_worn
	name = "Kombinezon więzienny na postaci (Vox)"
	icon_file = 'aquila/icons/mob/species/vox/clothing/gags_uniform.dmi'
	json_config = 'code/datums/greyscale/json_configs/jumpsuit_prison_worn.json'

/datum/greyscale_config/vox_sneakers_worn
	name = "Trampki na postaci (Vox)"
	icon_file = 'aquila/icons/mob/species/vox/clothing/gags_feet.dmi'
	json_config = 'code/datums/greyscale/json_configs/sneakers_worn.json'

/datum/greyscale_config/vox_sneakers_orange_worn
	name = "Pomarańczowe trampki na postaci (Vox)"
	icon_file = 'aquila/icons/mob/species/vox/clothing/gags_feet.dmi'
	json_config = 'code/datums/greyscale/json_configs/sneakers_orange_worn.json'

/obj/item/build_worn_icon(default_layer = 0, default_icon_file = null, isinhands = FALSE, femaleuniform = NO_FEMALE_UNIFORM, override_state = null, special_override_flags = NONE)
	. = ..()
	if(isinhands || !isvox(loc))
		return
	vox_refit_worn_icon(.)

/// Podmienia plik ikony gotowego wyglądu na wersję dla sylwetki Voxa, jeśli taka istnieje
/obj/item/proc/vox_refit_worn_icon(mutable_appearance/standing)
	if(!standing)
		return
	var/state = standing.icon_state
	if(greyscale_config_worn && greyscale_colors)
		var/vox_config = GLOB.vox_gags_worn_configs["[greyscale_config_worn]"]
		if(!vox_config)
			return
		var/icon/vox_icon = SSgreyscale.GetColoredIconByType(vox_config, greyscale_colors)
		if(vox_icon && icon_exists(vox_icon, state))
			standing.icon = vox_icon
		return
	var/vox_file = GLOB.vox_worn_icons["[standing.icon]"]
	if(vox_file && icon_exists(vox_file, state))
		standing.icon = vox_file

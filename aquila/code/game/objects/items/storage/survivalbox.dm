// AQUILA - zestaw przetrwania z własną grafiką (czerwona skrzynka z kieszonkami).
// Butla i hełm leżą na wierzchu: ich nakładki są widoczne, dopóki przedmiot jest w zestawie.
// Kieszonki są narysowane na podstawie jako zamknięte: nakładka otwartej kieszonki pojawia się, gdy jej przedmiotu brakuje.
// Storage woła update_icon przy wkładaniu i wyjmowaniu. Bandaże, łom, flara i radio nie mają nakładek.

/obj/item/storage/box/survival
	name = "zestaw przetrwania"
	desc = "Awaryjny zestaw z maską, obcisłym skafandrem, butlą i medipenem na wypadek rozszczelnienia."
	icon = 'aquila/icons/obj/survivalbox.dmi'
	icon_state = "survivalbox-base"
	illustration = null

/obj/item/storage/box/survival_mining
	name = "górniczy zestaw przetrwania"
	desc = "Awaryjny zestaw górnika z maską gazową, łomem, obcisłym skafandrem i medipenem."
	icon = 'aquila/icons/obj/survivalbox.dmi'
	icon_state = "survivalbox-base"
	illustration = null

/// Nakładka => typ przedmiotu, który ją pokazuje, gdy jest w zestawie
GLOBAL_LIST_INIT(survivalbox_present_overlays, list(
	"overlay-survivalbox-oxygen" = /obj/item/tank/internals,
	"overlay-survivalbox-helmet" = /obj/item/clothing/head/helmet/space/skinsuit,
))

/// Nakładka otwartej kieszonki => typ przedmiotu, którego brak ją pokazuje
GLOBAL_LIST_INIT(survivalbox_missing_overlays, list(
	"overlay-survivalbox-first-pouch" = /obj/item/reagent_containers/hypospray,
	"overlay-survivalbox-second-pouch" = /obj/item/clothing/mask,
	"overlay-survivalbox-main-pouch" = /obj/item/clothing/suit/space/skinsuit,
))

/// Bandaże dokłada Initialize w medical_tg_supplies.dm przez new(), bez update_icon, więc odświeżamy na końcu
/obj/item/storage/box/survival/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/storage/box/survival/update_overlays()
	. = ..()
	. += survivalbox_content_overlays(src)

/obj/item/storage/box/survival_mining/update_overlays()
	. = ..()
	. += survivalbox_content_overlays(src)

/proc/survivalbox_content_overlays(obj/item/storage/box/box)
	. = list()
	for(var/overlay_state in GLOB.survivalbox_missing_overlays)
		if(!(locate(GLOB.survivalbox_missing_overlays[overlay_state]) in box))
			. += overlay_state
	for(var/overlay_state in GLOB.survivalbox_present_overlays)
		if(locate(GLOB.survivalbox_present_overlays[overlay_state]) in box)
			. += overlay_state

// AQUILA - pudełko przetrwania z własną grafiką: na podstawie leżą nakładki zawartości,
// a każda znika, gdy wyjmie się odpowiadający jej przedmiot (storage woła update_icon przy wkładaniu i wyjmowaniu).
// Bandaże, łom, flara i radio nie mają nakładek.

/obj/item/storage/box/survival
	icon = 'aquila/icons/obj/survivalbox.dmi'
	icon_state = "survivalbox-base"
	illustration = null

/obj/item/storage/box/survival_mining
	icon = 'aquila/icons/obj/survivalbox.dmi'
	icon_state = "survivalbox-base"
	illustration = null

/// Nakładka => typ przedmiotu, który ją pokazuje
GLOBAL_LIST_INIT(survivalbox_overlays, list(
	"overlay-survivalbox-main-pouch" = /obj/item/clothing/suit/space/skinsuit,
	"overlay-survivalbox-first-pouch" = /obj/item/clothing/mask,
	"overlay-survivalbox-second-pouch" = /obj/item/reagent_containers/hypospray,
	"overlay-survivalbox-oxygen" = /obj/item/tank/internals,
	"overlay-survivalbox-helmet" = /obj/item/clothing/head/helmet/space/skinsuit,
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
	for(var/overlay_state in GLOB.survivalbox_overlays)
		if(locate(GLOB.survivalbox_overlays[overlay_state]) in box)
			. += overlay_state

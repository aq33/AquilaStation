// AQUILA - skąd wziąć NIF: projekt autochirurga w protolathe i fabrykatorze mechów (węzeł „Implanty cybernetyczne”)
// oraz skrzynie w zaopatrzeniu z tanim NIF-em, dyskami NIFSoft i akcesoriami.

/datum/design/aq_nif_autosurgeon
	name = "Autochirurg z NIF typu Standard"
	desc = "Jednorazowy autochirurg z Nanitową Platformą Implantów typu Standard."
	id = "aq_nif_autosurgeon"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 100
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1500, /datum/material/silver = 1000, /datum/material/gold = 500)
	build_path = /obj/item/autosurgeon/nif
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/techweb_node/cyber_implants/New()
	. = ..()
	design_ids += list("aq_nif_autosurgeon")

/datum/supply_pack/medical/nif_starter
	name = "Skrzynia startowa NIF"
	desc = "Tani NIF typu Econo-Deck w autochirurgu, dwa adaptery okularów do soczewek NIFSoft i regenerator NIF."
	cost = 2500
	contains = list(/obj/item/autosurgeon/nif/econo,
					/obj/item/nif_hud_adapter,
					/obj/item/nif_hud_adapter,
					/obj/item/nif_repair_kit)
	crate_name = "skrzynia startowa NIF"

/datum/supply_pack/medical/nifsoft_disks
	name = "Skrzynia dysków NIFSoft"
	desc = "Dyski z NIFSoftami: medyczna, diagnostyczna, naukowa i mezonowa soczewka jasnowidza oraz automatyczna wycena. Soczewki wymagają NIF-u typu Standard i okularów z adapterem."
	cost = 2000
	contains = list(/obj/item/disk/nifsoft_uploader/med_hud,
					/obj/item/disk/nifsoft_uploader/diag_hud,
					/obj/item/disk/nifsoft_uploader/sci_hud,
					/obj/item/disk/nifsoft_uploader/meson_hud,
					/obj/item/disk/nifsoft_uploader/money_sense,
					/obj/item/nif_hud_adapter)
	crate_name = "skrzynia dysków NIFSoft"

/datum/supply_pack/security/nifsoft_sec_hud
	name = "Skrzynia soczewek ochrony NIFSoft"
	desc = "Dwa dyski z soczewką jasnowidza ochrony, dwa adaptery okularów i przecinak NIF do usuwania NIFSoftów. Do otwarcia wymaga dostępu ochrony."
	cost = 2000
	contains = list(/obj/item/disk/nifsoft_uploader/sec_hud,
					/obj/item/disk/nifsoft_uploader/sec_hud,
					/obj/item/nif_hud_adapter,
					/obj/item/nif_hud_adapter,
					/obj/item/nifsoft_remover)
	crate_name = "skrzynia soczewek ochrony NIFSoft"

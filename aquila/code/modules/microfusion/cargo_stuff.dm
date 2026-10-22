// Ceny: tg CARGO_CRATE_VALUE (200) razy mnożnik z Monkestation, u nas mniej więcej dwa razy więcej (jak w gizmo.dm)

/datum/supply_pack/security/armory/mcr01
	name = "MCR-01 Microfusion Crate"
	desc = "Broń microfusion MCR-01 od Micron Control Systems Incorporated. W środku cztery zaawansowane karabiny! Do otwarcia potrzebny dostęp do zbrojowni."
	cost = 8000
	contains = list(
		/obj/item/gun/microfusion/mcr01/advanced,
		/obj/item/gun/microfusion/mcr01/advanced,
		/obj/item/gun/microfusion/mcr01/advanced,
		/obj/item/gun/microfusion/mcr01/advanced,
	)
	crate_name = "skrzynia MCR-01"

/datum/supply_pack/security/microfusion
	name = "Assorted Microfusion Upgrade Crate"
	desc = "Ogniwa i emitery microfusion od Micron Control Systems Incorporated! Do otwarcia potrzebny dostęp ochrony."
	cost = 2000
	contains = list(
		/obj/item/microfusion_phase_emitter/advanced,
		/obj/item/microfusion_phase_emitter/advanced,
		/obj/item/stock_parts/cell/microfusion/advanced,
		/obj/item/stock_parts/cell/microfusion/advanced,
	)
	crate_name = "skrzynia ulepszeń microfusion"

/datum/supply_pack/security/mcr01_attachments_a
	name = "MCR-01 Military Attachments Crate Type A"
	desc = "Wojskowe dodatki do MCR-01 od Micron Control Systems Incorporated! W środku dwa praktyczne zestawy z powtarzaczem. Do otwarcia potrzebny dostęp ochrony."
	cost = 5600
	contains = list(
		/obj/item/microfusion_gun_attachment/grip,
		/obj/item/microfusion_gun_attachment/grip,
		/obj/item/microfusion_gun_attachment/rail,
		/obj/item/microfusion_gun_attachment/rail,
		/obj/item/microfusion_gun_attachment/barrel/repeater,
		/obj/item/microfusion_gun_attachment/barrel/repeater,
	)
	crate_name = "skrzynia dodatków MCR-01 typ A"

/datum/supply_pack/security/mcr01_attachments_type_b
	name = "MCR-01 Military Attachments Crate Type B"
	desc = "Wojskowe dodatki do MCR-01 od Micron Control Systems Incorporated! W środku mieszany zestaw specjalistyczny. Do otwarcia potrzebny dostęp ochrony."
	cost = 6400
	contains = list(
		/obj/item/microfusion_gun_attachment/grip,
		/obj/item/microfusion_gun_attachment/grip,
		/obj/item/microfusion_gun_attachment/grip,
		/obj/item/microfusion_gun_attachment/barrel/scatter,
		/obj/item/microfusion_gun_attachment/barrel/scatter,
		/obj/item/microfusion_gun_attachment/barrel/scatter,
		/obj/item/microfusion_gun_attachment/scope,
		/obj/item/microfusion_gun_attachment/barrel/lance,
	)
	crate_name = "skrzynia dodatków MCR-01 typ B"

/datum/supply_pack/security/mcr01_attachments_h
	name = "HCR-01 Military Attachments Crate Type H"
	desc = "Klaunowe dodatki HCR-01 od Honkicron Clownery Systems Inhonkorated! Skrzynia dziwnie pachnie bananami."
	cost = 8000
	contraband = TRUE
	contains = list(
		/obj/item/microfusion_gun_attachment/barrel/honk,
		/obj/item/microfusion_gun_attachment/barrel/honk,
		/obj/item/microfusion_gun_attachment/barrel/honk,
		/obj/item/microfusion_gun_attachment/camo/honk,
		/obj/item/microfusion_gun_attachment/camo/honk,
		/obj/item/microfusion_gun_attachment/camo/honk,
		/obj/item/food/pie/cream,
		/obj/item/food/pie/cream,
		/obj/item/food/pie/cream,
	)
	crate_name = "skrzynia dodatków MCR-01 typ H"

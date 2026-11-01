/datum/overmap_objective/cargo/transfer/data
	name = "Dostarcz chip z danymi"
	desc = "Dostarcz pod stołem dysk z dowolnymi danymi"
	crate_name = "Bezpieczny transfer danych"

/datum/overmap_objective/cargo/transfer/data/New()
	var/datum/freight_type/single/object/C = new /datum/freight_type/single/object( /obj/item/disk/tech_disk )
	C.send_prepackaged_item = TRUE
	C.allow_replacements = FALSE // This is secure data, replacement is not an option
	C.overmap_objective = src
	send_to_station_pickup_point = TRUE
	freight_type_group = new( list( C ) )

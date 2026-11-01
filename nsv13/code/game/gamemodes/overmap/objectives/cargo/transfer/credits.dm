/datum/overmap_objective/cargo/transfer/credits
	name = "Dostarcz kredyty"
	desc = "Dostarcz kredyty pod stołem"
	crate_name = "Fizyczny transfer kredytów"

/datum/overmap_objective/cargo/transfer/credits/New()
	var/datum/freight_type/single/object/credits/C = new( rand( 3, 15 ) * 1000 )
	C.send_prepackaged_item = TRUE
	C.allow_replacements = FALSE // No. If you steal the credits you fail the objective.
	C.overmap_objective = src
	send_to_station_pickup_point = TRUE
	freight_type_group = new( list( C ) )

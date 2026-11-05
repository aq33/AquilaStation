//   --------------------
// -- HOLODECK TEMPLATES --
//   --------------------

/datum/map_template/holodeck
	var/template_id = "id"
	var/restricted = FALSE
	var/datum/parsed_map/lastparsed

	should_place_on_top = FALSE
	returns_created_atoms = TRUE
	keep_cached_map = TRUE

	var/obj/machinery/computer/holodeck/linked

/datum/map_template/holodeck/recreation/offline
	name = "Holodeck - Wyłączony"
	template_id = "recreational-offline"
	mappath = "_maps/holodeck/offline.dmm"

/datum/map_template/holodeck/recreation/emptycourt
	name = "Holodeck - Puste boisko"
	template_id = "emptycourt"
	mappath = "_maps/holodeck/emptycourt.dmm"

/datum/map_template/holodeck/recreation/dodgeball
	name = "Holodeck - Boisko do zbijaka"
	template_id = "dodgeball"
	mappath = "_maps/holodeck/dodgeball.dmm"

/datum/map_template/holodeck/recreation/basketball
	name = "Holodeck - Boisko do koszykówki"
	template_id = "basketball"
	mappath = "_maps/holodeck/basketball.dmm"

/datum/map_template/holodeck/recreation/thunderdome
	name = "Holodeck - Arena Thunderdome"
	template_id = "thunderdome"
	mappath = "_maps/holodeck/thunderdome.dmm"

/datum/map_template/holodeck/recreation/beach
	name = "Holodeck - Plaża"
	template_id = "beach"
	mappath = "_maps/holodeck/beach.dmm"

/datum/map_template/holodeck/recreation/lounge
	name = "Holodeck - Salon"
	template_id = "lounge"
	mappath = "_maps/holodeck/lounge.dmm"

/datum/map_template/holodeck/recreation/petpark
	name = "Holodeck - Park dla zwierzaków"
	template_id = "petpark"
	mappath = "_maps/holodeck/petpark.dmm"

/datum/map_template/holodeck/recreation/firingrange
	name = "Holodeck - Strzelnica"
	template_id = "firingrange"
	mappath = "_maps/holodeck/firingrange.dmm"

/datum/map_template/holodeck/recreation/anime_school
	name = "Holodeck - Szkoła z anime"
	template_id = "animeschool"
	mappath = "_maps/holodeck/animeschool.dmm"

/datum/map_template/holodeck/recreation/chapelcourt
	name = "Holodeck - Sala sądowa w kaplicy"
	template_id = "chapelcourt"
	mappath = "_maps/holodeck/chapelcourt.dmm"

/datum/map_template/holodeck/recreation/spacechess
	name = "Holodeck - Kosmiczne szachy"
	template_id = "spacechess"
	mappath = "_maps/holodeck/spacechess.dmm"

/datum/map_template/holodeck/recreation/spacecheckers
	name = "Holodeck - Kosmiczne warcaby"
	template_id = "spacecheckers"
	mappath = "_maps/holodeck/spacecheckers.dmm"

/datum/map_template/holodeck/recreation/kobayashi
	name = "Holodeck - Kobayashi Maru"
	template_id = "kobayashi"
	mappath = "_maps/holodeck/kobayashi.dmm"

/datum/map_template/holodeck/recreation/winterwonderland
	name = "Holodeck - Zimowa kraina czarów"
	template_id = "winterwonderland"
	mappath = "_maps/holodeck/winterwonderland.dmm"

/datum/map_template/holodeck/recreation/photobooth
	name = "Holodeck - Fotobudka"
	template_id = "photobooth"
	mappath = "_maps/holodeck/photobooth.dmm"

/datum/map_template/holodeck/recreation/skatepark
	name = "Holodeck - Skatepark"
	template_id = "skatepark"
	mappath = "_maps/holodeck/skatepark.dmm"

/datum/map_template/holodeck/recreation/teahouse
	name = "Holodeck - Japońska herbaciarnia"
	template_id = "holodeck_teahouse"
	mappath = "_maps/templates/holodeck_teahouse.dmm"

/datum/map_template/holodeck/recreation/kitchen
	name = "Holodeck - Holokuchnia"
	template_id = "holodeck_kitchen"
	mappath = "_maps/templates/holodeck_kitchen.dmm"

//bad evil no good programs

/datum/map_template/holodeck/recreation/medicalsim
	name = "Holodeck - Nagły wypadek medyczny"
	template_id = "medicalsim"
	mappath = "_maps/holodeck/medicalsim.dmm"
	restricted = TRUE

/datum/map_template/holodeck/recreation/thunderdome1218
	name = "Holodeck - Rok 1218"
	template_id = "thunderdome1218"
	mappath = "_maps/holodeck/thunderdome1218.dmm"
	restricted = TRUE

/datum/map_template/holodeck/recreation/burntest
	name = "Holodeck - Test spalania atmosferycznego"
	template_id = "burntest"
	mappath = "_maps/holodeck/burntest.dmm"
	restricted = TRUE

/datum/map_template/holodeck/recreation/wildlifesim
	name = "Holodeck - Symulacja dzikiej przyrody"
	template_id = "wildlifesim"
	mappath = "_maps/holodeck/wildlifesim.dmm"
	restricted = TRUE

/datum/map_template/holodeck/recreation/holdoutbunker
	name = "Holodeck - Bunkier obronny"
	template_id = "holdoutbunker"
	mappath = "_maps/holodeck/holdoutbunker.dmm"
	restricted = TRUE

/datum/map_template/holodeck/recreation/anthophillia
	name = "Holodeck - Antofilia"
	template_id = "anthophillia"
	mappath = "_maps/holodeck/anthophillia.dmm"
	restricted = TRUE

/datum/map_template/holodeck/recreation/refuelingstation
	name = "Holodeck - Stacja tankowania"
	template_id = "refuelingstation"
	mappath = "_maps/holodeck/refuelingstation.dmm"
	restricted = TRUE

/datum/map_template/holodeck/recreation/asylum
	name = "Holodeck - Zakład psychiatryczny"
	template_id = "holodeck_asylum"
	mappath = "_maps/templates/holodeck_asylum.dmm"
	restricted = TRUE

/datum/map_template/holodeck/recreation/clownworld
	name = "Holodeck - Świat klaunów"
	template_id = "holodeck_clownworld"
	mappath = "_maps/templates/holodeck_clownworld.dmm"
	restricted = TRUE

//   --------------------
// -- PRISON TEMPLATES --
//   --------------------
/datum/map_template/holodeck/prison

/datum/map_template/holodeck/prison/offline
	name = "Workshop - Wyłączony"
	template_id = "workshop-offline"
	mappath = "_maps/holodeck/workshop/offline.dmm"

/datum/map_template/holodeck/prison/donut
	name = "Workshop - Warsztat pączków"
	template_id = "donut"
	mappath = "_maps/holodeck/workshop/donut.dmm"

/datum/map_template/holodeck/prison/plushes
	name = "Workshop - Szwalnia pluszaków"
	template_id = "plush"
	mappath = "_maps/holodeck/workshop/plush.dmm"

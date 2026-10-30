//Cargo

/datum/map_template/shuttle/cargo/hammerhead
	suffix = "hammerhead"
	name = "\[NSV\] prom zaopatrzeniowy (Hammerhead)"

/datum/map_template/shuttle/ferry/galactica
	suffix = "galactica"
	name = "\[NSV\] prom transportowy Centrali (Galactica)"

/datum/map_template/shuttle/cargo/sausage
	suffix = "sausage"
	name = "\[NSV\] prom zaopatrzeniowy (Jolly Sausage)"

/datum/map_template/shuttle/cargo/gladius
	suffix = "gladius"
	name = "\[NSV\] prom zaopatrzeniowy (Gladius)"

/datum/map_template/shuttle/cargo/atlas
	suffix = "atlas"
	name = "\[NSV\] winda zaopatrzeniowa (Atlas)"

/datum/map_template/shuttle/cargo/shrike
	suffix = "shrike"
	name = "\[NSV\] prom zaopatrzeniowy (Shrike)"

/datum/map_template/shuttle/cargo/serendipity
	suffix = "serendipity"
	name = "\[NSV\] prom zaopatrzeniowy (Serendipity)"

//Arrivals

/datum/map_template/shuttle/arrival/aetherwhisp
	suffix = "aetherwhisp"
	name = "prom przylotów (Aetherwhisp)"

/datum/map_template/shuttle/arrival/gladius
	suffix = "gladius"
	name = "prom przylotów (Gladius)"

/datum/map_template/shuttle/arrival/shrike
	suffix = "shrike"
	name = "prom przylotów (Shrike)"

/datum/map_template/shuttle/arrival/serendipity
	suffix = "serendipity"
	name = "prom przylotów (Serendipity)"

/datum/map_template/shuttle/hammurabi //This is definitely an elevator trust me.
	prefix = "_maps/shuttles/turbolifts/"
	port_id = "elevator"
	suffix = "hammurabi"
	name = "winda górnicza (Hammurabi)"
//Mining

/datum/map_template/shuttle/mining/shrike
	suffix = "shrike"
	name = "prom górniczy (Shrike)"

//Escape
/datum/map_template/shuttle/escape_pod/shrike
	suffix = "shrike"
	name = "kapsuła ratunkowa (Shrike)"

/datum/map_template/shuttle/emergency/void
	suffix = "void"
	name = "Pustka zamiast promu ewakuacyjnego"
	description = "Nawet nie prom."
	admin_notes = "Do map, na których są tylko kapsuły ratunkowe"
	credit_cost = 0
	can_be_bought = FALSE

/datum/map_template/shuttle/emergency/atlas
	suffix = "atlas"
	name = "Jacht klasy Danube"
	description = "Mały, luksusowy prom, który w komforcie i stylu przewiezie małe i średnie załogi."
	credit_cost = 4000

/datum/map_template/shuttle/emergency/celerity
	suffix = "celerity"
	name = "Prom ewakuacyjny klasy Celerity Dominium Światła"
	admin_notes = "Ten prom nie działa na żadnym statku poza Serendipity"
	can_be_bought = FALSE

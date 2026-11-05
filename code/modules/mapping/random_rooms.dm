/datum/map_template/random_room
	var/room_id //The SSmapping random_room_template list is ordered by this var
	var/spawned //Whether this template (on the random_room template list) has been spawned
	var/centerspawner = TRUE
	var/template_height = 0
	var/template_width = 0
	var/weight = 10 //weight a room has to appear
	var/stock = 1 //how many times this room can appear in a round

/datum/map_template/random_room/sk_rdm001
	name = "Tunele techniczne - magazyn"
	room_id = "sk_rdm001_9storage"
	mappath = "_maps/RandomRooms/3x3/sk_rdm001_9storage.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 2


/datum/map_template/random_room/sk_rdm002
	name = "Tunele techniczne - kapliczka"
	room_id = "sk_rdm002_shrine"
	mappath = "_maps/RandomRooms/3x3/sk_rdm002_shrine.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 2

/datum/map_template/random_room/sk_rdm003
	name = "Tunele techniczne"
	room_id = "sk_rdm003_plasma"
	mappath = "_maps/RandomRooms/3x3/sk_rdm003_plasma.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm004
	name = "Tunele techniczne - solarium"
	room_id = "sk_rdm004_tanning"
	mappath = "_maps/RandomRooms/3x3/sk_rdm004_tanning.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm005
	name = "Tunele techniczne - umywalnia"
	room_id = "sk_rdm005_wash"
	mappath = "_maps/RandomRooms/3x3/sk_rdm005_wash.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm006
	name = "Tunele techniczne"
	room_id = "sk_rdm006_gibs"
	mappath = "_maps/RandomRooms/3x3/sk_rdm006_gibs.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm007
	name = "Tunele techniczne"
	room_id = "sk_rdm007_radspill"
	mappath = "_maps/RandomRooms/3x3/sk_rdm007_radspill.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm008
	name = "Tunele techniczne - magazyn"
	room_id = "sk_rdm008_2storage"
	mappath = "_maps/RandomRooms/3x3/sk_rdm008_2storage.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm009
	name = "Stacja uzupełniania powietrza"
	room_id = "sk_rdm009_airstation"
	mappath = "_maps/RandomRooms/3x3/sk_rdm009_airstation.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm010
	name = "Tunele techniczne - HAZMAT"
	room_id = "sk_rdm010_hazmat"
	mappath = "_maps/RandomRooms/3x3/sk_rdm010_hazmat.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm011
	name = "Zakład fryzjerski"
	room_id = "sk_rdm011_barbershop"
	mappath = "_maps/RandomRooms/10x5/sk_rdm011_barbershop.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10

/datum/map_template/random_room/sk_rdm012
	name = "Box - bar"
	room_id = "sk_rdm012_boxbar"
	mappath = "_maps/RandomRooms/5x4/sk_rdm012_boxbar.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm013
	name = "Box - kuchnia"
	room_id = "sk_rdm013_boxkitchen"
	mappath = "_maps/RandomRooms/3x5/sk_rdm013_boxkitchen.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3

/datum/map_template/random_room/sk_rdm014
	name = "Box - okno"
	room_id = "sk_rdm014_boxwindow"
	mappath = "_maps/RandomRooms/3x3/sk_rdm014_boxwindow.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm015
	name = "Box - graty 1"
	room_id = "sk_rdm015_boxclutter1"
	mappath = "_maps/RandomRooms/5x3/sk_rdm015_boxclutter1.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5
	stock = 2

/datum/map_template/random_room/sk_rdm016
	name = "Box - graty 2"
	room_id = "sk_rdm016_boxclutter2"
	mappath = "_maps/RandomRooms/3x3/sk_rdm016_boxclutter2.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm017
	name = "Box - graty 3"
	room_id = "sk_rdm017_boxclutter3"
	mappath = "_maps/RandomRooms/3x3/sk_rdm017_boxclutter3.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm018
	name = "Box - graty 4"
	room_id = "sk_rdm018_boxclutter4"
	mappath = "_maps/RandomRooms/3x3/sk_rdm018_boxclutter4.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm019
	name = "Box - graty 5"
	room_id = "sk_rdm019_boxclutter5"
	mappath = "_maps/RandomRooms/3x3/sk_rdm019_boxclutter5.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm020
	name = "Box - graty 6"
	room_id = "sk_rdm020_boxclutter6"
	mappath = "_maps/RandomRooms/3x3/sk_rdm020_boxclutter6.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm021
	name = "Box - kolacja"
	room_id = "sk_rdm021_boxdinner"
	mappath = "_maps/RandomRooms/5x4/sk_rdm021_boxdinner.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm022
	name = "Box - schowek chemiczny"
	room_id = "sk_rdm022_boxchemcloset"
	mappath = "_maps/RandomRooms/3x3/sk_rdm022_boxchemcloset.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 7

/datum/map_template/random_room/sk_rdm023
	name = "Box - graty 7"
	room_id = "sk_rdm023_boxclutter7"
	mappath = "_maps/RandomRooms/3x5/sk_rdm023_boxclutter7.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm024
	name = "Box - sypialnia"
	room_id = "sk_rdm024_boxbedroom"
	mappath = "_maps/RandomRooms/3x3/sk_rdm024_boxbedroom.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm025
	name = "Box - graty 8"
	room_id = "sk_rdm025_boxclutter8"
	mappath = "_maps/RandomRooms/3x3/sk_rdm025_boxclutter8.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm026
	name = "Box - graty 8"
	room_id = "sk_rdm026_boxsurgery"
	mappath = "_maps/RandomRooms/5x4/sk_rdm026_boxsurgery.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/*/datum/map_template/random_room/sk_rdm027
	name = "Box - wyrwa w kadłubie"
	room_id = "sk_rdm027_hullbreach"
	mappath = "_maps/RandomRooms/3x3/sk_rdm027_hullbreach.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3 */

/datum/map_template/random_room/sk_rdm028
	name = "Spokój"
	room_id = "sk_rdm028_tranquility"
	mappath = "_maps/RandomRooms/3x3/sk_rdm028_tranquility.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 1

/datum/map_template/random_room/sk_rdm029
	name = "Delta - bar"
	room_id = "sk_rdm029_deltabar"
	mappath = "_maps/RandomRooms/5x4/sk_rdm029_deltabar.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	stock = 2

/datum/map_template/random_room/sk_rdm030
	name = "Delta - salon"
	room_id = "sk_rdm030_deltalounge"
	mappath = "_maps/RandomRooms/5x4/sk_rdm030_deltalounge.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm031
	name = "Delta - robotyka"
	room_id = "sk_rdm031_deltarobotics"
	mappath = "_maps/RandomRooms/10x5/sk_rdm031_deltarobotics.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 5

/datum/map_template/random_room/sk_rdm032
	name = "Delta - EVA"
	room_id = "sk_rdm032_deltaEVA"
	mappath = "_maps/RandomRooms/5x4/sk_rdm032_deltaEVA.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	weight = 3

/datum/map_template/random_room/sk_rdm033
	name = "Delta - biblioteka"
	room_id = "sk_rdm033_deltalibrary"
	mappath = "_maps/RandomRooms/10x10/sk_rdm033_deltalibrary.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 7

/datum/map_template/random_room/sk_rdm034
	name = "Delta - biuro detektywa"
	room_id = "sk_rdm034_deltadetective"
	mappath = "_maps/RandomRooms/5x4/sk_rdm034_deltadetective.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm035
	name = "Delta - chirurgia"
	room_id = "sk_rdm035_deltasurgery"
	mappath = "_maps/RandomRooms/5x4/sk_rdm035_deltasurgery.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm036
	name = "Delta - biuro Sowy"
	room_id = "sk_rdm036_owloffice"
	mappath = "_maps/RandomRooms/3x3/sk_rdm036_owloffice.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 7

/datum/map_template/random_room/sk_rdm037
	name = "Delta - schowek woźnego"
	room_id = "sk_rdm037_deltajanniecloset"
	mappath = "_maps/RandomRooms/3x3/sk_rdm037_deltajanniecloset.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 8

/datum/map_template/random_room/sk_rdm038
	name = "Delta - przebieralnia"
	room_id = "sk_rdm038_deltadressing"
	mappath = "_maps/RandomRooms/5x4/sk_rdm038_deltadressing.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm039
	name = "Delta - graty 1"
	room_id = "sk_rdm039_deltaclutter1"
	mappath = "_maps/RandomRooms/10x5/sk_rdm039_deltaclutter1.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10

/datum/map_template/random_room/sk_rdm040
	name = "Delta - botanika"
	room_id = "sk_rdm040_deltabotnis"
	mappath = "_maps/RandomRooms/10x5/sk_rdm040_deltabotnis.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 9

/datum/map_template/random_room/sk_rdm041
	name = "Delta - jaskinia hazardu"
	room_id = "sk_rdm041_deltagamble"
	mappath = "_maps/RandomRooms/5x4/sk_rdm041_deltagamble.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm042
	name = "Delta - graty 2"
	room_id = "sk_rdm042_deltaclutter2"
	mappath = "_maps/RandomRooms/5x3/sk_rdm042_deltaclutter2.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm043
	name = "Delta - graty 3"
	room_id = "sk_rdm043_deltaclutter3"
	mappath = "_maps/RandomRooms/5x3/sk_rdm043_deltaclutter3.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

/*/datum/map_template/random_room/sk_rdm044
	name = "Delta - handel organami"
	room_id = "sk_rdm044_deltaorgantrade"
	mappath = "_maps/RandomRooms/3x3/sk_rdm044_deltaorgantrade.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3*/

/datum/map_template/random_room/sk_rdm045
	name = "Delta - kafeteria"
	room_id = "sk_rdm045_deltacafeteria"
	mappath = "_maps/RandomRooms/10x5/sk_rdm045_deltacafeteria.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 7

/datum/map_template/random_room/sk_rdm046
	name = "Delta - salon gier"
	room_id = "sk_rdm046_deltaarcade"
	mappath = "_maps/RandomRooms/10x5/sk_rdm046_deltaarcade.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10

/datum/map_template/random_room/sk_rdm047
	name = "Meta - robotyka"
	room_id = "sk_rdm047_metarobotics"
	mappath = "_maps/RandomRooms/5x4/sk_rdm047_metarobotics.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	weight = 5

/datum/map_template/random_room/sk_rdm048
	name = "Meta - teatr"
	room_id = "sk_rdm048_metatheatre"
	mappath = "_maps/RandomRooms/5x4/sk_rdm048_metatheatre.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm049
	name = "Meta - kuchnia"
	room_id = "sk_rdm049_metakitchen"
	mappath = "_maps/RandomRooms/5x4/sk_rdm049_metakitchen.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm050
	name = "Meta - schowek medyczny"
	room_id = "sk_rdm050_medicloset"
	mappath = "_maps/RandomRooms/3x3/sk_rdm050_medicloset.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm051
	name = "Meta - sprzęt gamera"
	room_id = "sk_rdm051_metagamergear"
	mappath = "_maps/RandomRooms/3x3/sk_rdm051_metagamergear.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 6

/datum/map_template/random_room/sk_rdm052
	name = "Meta - graty 1"
	room_id = "sk_rdm052_metaclutter1"
	mappath = "_maps/RandomRooms/5x3/sk_rdm052_metaclutter1.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5
	stock = 2

/datum/map_template/random_room/sk_rdm053
	name = "Meta - graty 2"
	room_id = "sk_rdm053_metaclutter2"
	mappath = "_maps/RandomRooms/3x3/sk_rdm053_metaclutter2.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm054
	name = "Meta - graty 3"
	room_id = "sk_rdm054_metaclutter3"
	mappath = "_maps/RandomRooms/5x3/sk_rdm054_metaclutter3.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm055
	name = "Meta - medyczny"
	room_id = "sk_rdm055_metamedical"
	mappath = "_maps/RandomRooms/5x4/sk_rdm055_metamedical.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm056
	name = "Meta - graty 4"
	room_id = "sk_rdm056_metaclutter4"
	mappath = "_maps/RandomRooms/3x3/sk_rdm056_metaclutter4.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm057
	name = "Pubby - graty 1"
	room_id = "sk_rdm057_pubbyclutter1"
	mappath = "_maps/RandomRooms/3x3/sk_rdm057_pubbyclutter1.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm058
	name = "Pubby - graty 2"
	room_id = "sk_rdm058_pubbyclutter2"
	mappath = "_maps/RandomRooms/3x3/sk_rdm058_pubbyclutter2.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm059
	name = "Pubby - graty 3"
	room_id = "sk_rdm059_pubbyclutter3"
	mappath = "_maps/RandomRooms/3x3/sk_rdm059_pubbyclutter3.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm060
	name = "Pubby - dół badawczy"
	room_id = "sk_rdm060_snakefighter"
	mappath = "_maps/RandomRooms/10x10/sk_rdm060_snakefighter.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 6

/datum/map_template/random_room/sk_rdm061
	name = "Pubby - graty 4"
	room_id = "sk_rdm061_pubbyclutter4"
	mappath = "_maps/RandomRooms/5x3/sk_rdm061_pubbyclutter4.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm062 //TODO: add cockfights
	name = "Pubby - KOGUCIDROM"
	room_id = "sk_rdm062_roosterdome"
	mappath = "_maps/RandomRooms/10x10/sk_rdm062_roosterdome.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 6

/datum/map_template/random_room/sk_rdm063
	name = "Pubby - graty 5"
	room_id = "sk_rdm063_pubbyclutter5"
	mappath = "_maps/RandomRooms/3x5/sk_rdm063_pubbyclutter5.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3

/datum/map_template/random_room/sk_rdm064
	name = "Pubby - robotyka"
	room_id = "sk_rdm064_pubbyrobotics"
	mappath = "_maps/RandomRooms/3x5/sk_rdm064_pubbyrobotics.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3

/datum/map_template/random_room/sk_rdm065
	name = "Pubby - graty 6"
	room_id = "sk_rdm065_pubbyclutter6"
	mappath = "_maps/RandomRooms/3x5/sk_rdm065_pubbyclutter6.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm066
	name = "Pubby - sypialnia"
	room_id = "sk_rdm066_pubbybedroom"
	mappath = "_maps/RandomRooms/5x3/sk_rdm066_pubbybedroom.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm067
	name = "Pubby - chirurgia"
	room_id = "sk_rdm067_pubbysurgery"
	mappath = "_maps/RandomRooms/5x4/sk_rdm067_pubbysurgery.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm068
	name = "Pubby - graty 7"
	room_id = "sk_rdm068_pubbyclutter7"
	mappath = "_maps/RandomRooms/5x3/sk_rdm068_pubbyclutter7.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm069
	name = "Pubby - pracownia plastyczna"
	room_id = "sk_rdm069_pubbyartism"
	mappath = "_maps/RandomRooms/3x3/sk_rdm069_pubbyartism.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm070
	name = "Pubby - bar"
	room_id = "sk_rdm070_pubbybar"
	mappath = "_maps/RandomRooms/10x10/sk_rdm070_pubbybar.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10

/datum/map_template/random_room/sk_rdm071
	name = "Pubby - kuchnia"
	room_id = "sk_rdm071_pubbykitchen"
	mappath = "_maps/RandomRooms/5x3/sk_rdm071_pubbykitchen.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm072 //donut is such a shit map, this was the ONLY room in its maintenance that was suitable.
	name = "Donut - pistolet na kapiszony"
	room_id = "sk_rdm072_donutcapgun"
	mappath = "_maps/RandomRooms/3x3/sk_rdm072_donutcapgun.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 6

/datum/map_template/random_room/sk_rdm073
	name = "Kilo - ładowarka mechów"
	room_id = "sk_rdm073_kilomechcharger"
	mappath = "_maps/RandomRooms/3x3/sk_rdm073_kilomechcharger.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm074
	name = "Kilo - teatr"
	room_id = "sk_rdm074_kilotheatre"
	mappath = "_maps/RandomRooms/3x3/sk_rdm074_kilotheatre.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm075 //the bane of all unprepared greytiders who value their humanity. Though, it's mostly nonlethal...
	name = "Kilo - chirurgia"
	room_id = "sk_rdm075_kilosurgery"
	mappath = "_maps/RandomRooms/5x4/sk_rdm075_kilosurgery.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	weight = 6
	stock = 2 //because i hate you

/datum/map_template/random_room/sk_rdm076
	name = "Kilo - nawiedzona biblioteka"
	room_id = "sk_rdm076_kilohauntedlibrary"
	mappath = "_maps/RandomRooms/5x4/sk_rdm076_kilohauntedlibrary.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	weight = 4

/datum/map_template/random_room/sk_rdm077
	name = "Kilo - kryjówka pokojówek"
	room_id = "sk_rdm077_kilolustymaid"
	mappath = "_maps/RandomRooms/3x3/sk_rdm077_kilolustymaid.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm078
	name = "Kilo - graty"
	room_id = "sk_rdm078_kiloclutter1"
	mappath = "_maps/RandomRooms/5x3/sk_rdm078_kiloclutter1.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm079 //comment this out if you want to avoid tiders dying to a simplemob once in awhile
	name = "Kilo - legowisko potworów"
	room_id = "sk_rdm079_kilomobden"
	mappath = "_maps/RandomRooms/3x5/sk_rdm079_kilomobden.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 3
	stock = 2

/datum/map_template/random_room/sk_rdm080
	name = "Starożytny klonownik"
	room_id = "sk_rdm080_cloner"
	mappath = "_maps/RandomRooms/5x3/sk_rdm080_cloner.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5
	weight = 1

/datum/map_template/random_room/sk_rdm081
	name = "Tunele techniczne - wirusologia"
	room_id = "sk_rdm081_biohazard"
	mappath = "_maps/RandomRooms/3x3/sk_rdm081_biohazard.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 3

/datum/map_template/random_room/sk_rdm082
	name = "Tunele techniczne - chemia"
	room_id = "sk_rdm082_maintmedical"
	mappath = "_maps/RandomRooms/10x5/sk_rdm082_maintmedical.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 6

/datum/map_template/random_room/sk_rdm083
	name = "Duży teatr"
	room_id = "sk_rdm083_bigtheatre"
	mappath = "_maps/RandomRooms/10x10/sk_rdm083_bigtheatre.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 9

/datum/map_template/random_room/sk_rdm084
	name = "Małpi raj"
	room_id = "sk_rdm084_monky"
	mappath = "_maps/RandomRooms/3x5/sk_rdm084_monky.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm085
	name = "Pokój Hanka"
	room_id = "sk_rdm085_hank"
	mappath = "_maps/RandomRooms/3x5/sk_rdm085_hank.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 1

/datum/map_template/random_room/sk_rdm086
	name = "Ostatni bastion Maxa Tide'a"
	room_id = "sk_rdm086_laststand"
	mappath = "_maps/RandomRooms/3x5/sk_rdm086_laststand.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 3

/datum/map_template/random_room/sk_rdm087
	name = "Schowek z rupieciami"
	room_id = "sk_rdm087_junkcloset"
	mappath = "_maps/RandomRooms/3x5/sk_rdm087_junkcloset.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm088
	name = "Strefa budowy"
	room_id = "sk_rdm088_bigconstruction"
	mappath = "_maps/RandomRooms/10x10/sk_rdm088_bigconstruction.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 5

/datum/map_template/random_room/sk_rdm089
	name = "Paskudna pułapka"
	room_id = "sk_rdm089_nastytrap"
	mappath = "_maps/RandomRooms/5x3/sk_rdm089_nastytrap.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5
	weight = 4

/datum/map_template/random_room/sk_rdm090
	name = "Malutki zakład fryzjerski"
	room_id = "sk_rdm090_tinybarbershop"
	mappath = "_maps/RandomRooms/5x4/sk_rdm090_tinybarbershop.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	weight = 7


/datum/map_template/random_room/sk_rdm091
	name = "Pokój ze śmieciami"
	room_id = "sk_rdm091_skidrow"
	mappath = "_maps/RandomRooms/10x5/sk_rdm091_skidrow.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10

/datum/map_template/random_room/sk_rdm092
	name = "Melina menela"
	room_id = "sk_rdm092_hobohut"
	mappath = "_maps/RandomRooms/3x3/sk_rdm092_hobohut.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 8

/datum/map_template/random_room/sk_rdm093
	name = "Ołtarz Bubblegum"
	room_id = "sk_rdm093_bubblegumaltar"
	mappath = "_maps/RandomRooms/3x3/sk_rdm093_bubblegumaltar.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 1

/datum/map_template/random_room/sk_rdm094
	name = "Pokój z kanistrami"
	room_id = "sk_rdm094_canisterroom"
	mappath = "_maps/RandomRooms/3x5/sk_rdm094_canisterroom.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm095
	name = "Wrak Duranda"
	room_id = "sk_rdm095_durandwreck"
	mappath = "_maps/RandomRooms/3x5/sk_rdm095_durandwreck.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm096
	name = "Pokój komputerowy"
	room_id = "sk_rdm096_comproom"
	mappath = "_maps/RandomRooms/5x4/sk_rdm096_comproom.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm097
	name = "Płonący pokój"
	room_id = "sk_rdm097_firemanroom"
	mappath = "_maps/RandomRooms/5x4/sk_rdm097_firemanroom.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm098
	name = "Pokój z graffiti"
	room_id = "sk_rdm098_graffitiroom"
	mappath = "_maps/RandomRooms/10x10/sk_rdm098_graffitiroom.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 4

/datum/map_template/random_room/sk_rdm099
	name = "Zniszczona podłoga"
	room_id = "sk_rdm099_incompletefloor"
	mappath = "_maps/RandomRooms/5x3/sk_rdm099_incompletefloor.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm100
	name = "Sala spotkań"
	room_id = "sk_rdm100_meetingroom"
	mappath = "_maps/RandomRooms/10x5/sk_rdm100_meetingroom.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 6

/datum/map_template/random_room/sk_rdm101
	name = "Mały pokój socjalny"
	room_id = "sk_rdm101_minibreakroom"
	mappath = "_maps/RandomRooms/5x3/sk_rdm101_minibreakroom.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm102
	name = "Warsztat naprawczy"
	room_id = "sk_rdm102_podrepairbay"
	mappath = "_maps/RandomRooms/10x10/sk_rdm102_podrepairbay.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 6

/datum/map_template/random_room/sk_rdm103
	name = "„magazym”"
	room_id = "sk_rdm103_stroreroom"
	mappath = "_maps/RandomRooms/5x3/sk_rdm103_stroreroom.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5
	stock = 2

/datum/map_template/random_room/sk_rdm104
	name = "loteria pigułek"
	room_id = "sk_rdm104_pills"
	mappath = "_maps/RandomRooms/5x3/sk_rdm104_pills.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5
	weight = 1

/datum/map_template/random_room/sk_rdm105
	name = "strefa zagrożenia biologicznego"
	room_id = "sk_rdm105_phage"
	mappath = "_maps/RandomRooms/10x5/sk_rdm105_phage.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 3

/datum/map_template/random_room/sk_rdm106
	name = "Gabinet psychiatry"
	room_id = "sk_rdm106_sanitarium"
	mappath = "_maps/RandomRooms/10x10/sk_rdm106_sanitarium.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10

/datum/map_template/random_room/sk_rdm107
	name = "banan"
	room_id = "sk_rdm107_banana"
	mappath = "_maps/RandomRooms/3x3/sk_rdm107_banana.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm108
	name = "brudni komuniści"
	room_id = "sk_rdm108_communism"
	mappath = "_maps/RandomRooms/3x3/sk_rdm108_communism.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 8

/datum/map_template/random_room/sk_rdm109
	name = "twardy skafander klauna"
	room_id = "sk_rdm109_hardclown"
	mappath = "_maps/RandomRooms/3x3/sk_rdm109_hardclown.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 1

/datum/map_template/random_room/sk_rdm110
	name = "komora lipidowa"
	room_id = "sk_rdm110_lipidchamber"
	mappath = "_maps/RandomRooms/3x3/sk_rdm110_lipidchamber.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm111
	name = "źle"
	room_id = "sk_rdm111_naughtyroom"
	mappath = "_maps/RandomRooms/3x3/sk_rdm111_naughtyroom.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 2

/datum/map_template/random_room/sk_rdm112
	name = "czemuonmatrzychromosomy"
	room_id = "sk_rdm112_chromosomes"
	mappath = "_maps/RandomRooms/3x5/sk_rdm112_chromosomes.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm113
	name = "pokój z organami"
	room_id = "sk_rdm113_dissection"
	mappath = "_maps/RandomRooms/3x5/sk_rdm113_dissection.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 6

/datum/map_template/random_room/sk_rdm114
	name = "pokój tlenowy"
	room_id = "sk_rdm114_emergencyoxy"
	mappath = "_maps/RandomRooms/3x5/sk_rdm114_emergencyoxy.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3

/datum/map_template/random_room/sk_rdm115
	name = "krab"
	room_id = "sk_rdm115_krebs"
	mappath = "_maps/RandomRooms/3x5/sk_rdm115_krebs.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 1

/datum/map_template/random_room/sk_rdm116
	name = "ruda"
	room_id = "sk_rdm116_oreboxes"
	mappath = "_maps/RandomRooms/3x5/sk_rdm116_oreboxes.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm117
	name = "ayylmoa"
	room_id = "sk_rdm117_chestburst"
	mappath = "_maps/RandomRooms/5x3/sk_rdm117_chestburst.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5
	weight = 3

/datum/map_template/random_room/sk_rdm118
	name = "pokój z rękawicami"
	room_id = "sk_rdm118_gloveroom"
	mappath = "_maps/RandomRooms/5x3/sk_rdm118_gloveroom.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5
	weight = 4//it has insuls and maybe a hostile spessman

/datum/map_template/random_room/sk_rdm119
	name = "części"
	room_id = "sk_rdm119_spareparts"
	mappath = "_maps/RandomRooms/5x3/sk_rdm119_spareparts.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5
	weight = 8

/datum/map_template/random_room/sk_rdm120
	name = "seeeeeer"
	room_id = "sk_rdm120_cheese"
	mappath = "_maps/RandomRooms/5x4/sk_rdm120_cheese.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	weight = 1

/datum/map_template/random_room/sk_rdm121
	name = "homk"
	room_id = "sk_rdm121_honkaccident"
	mappath = "_maps/RandomRooms/5x4/sk_rdm121_honkaccident.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	weight = 2


/datum/map_template/random_room/sk_rdm122
	name = "muzyka"
	room_id = "sk_rdm122_musicroom"
	mappath = "_maps/RandomRooms/5x4/sk_rdm122_musicroom.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	weight = 8

/datum/map_template/random_room/sk_rdm123
	name = "muzyka"
	room_id = "sk_rdm123_nanitechamber"
	mappath = "_maps/RandomRooms/5x4/sk_rdm123_nanitechamber.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	weight = 8

/datum/map_template/random_room/sk_rdm124
	name = "kriogenika"
	room_id = "sk_rdm124_oldcryoroom"
	mappath = "_maps/RandomRooms/5x4/sk_rdm124_oldcryoroom.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm125
	name = "sala sądowa"
	room_id = "sk_rdm125_courtroom"
	mappath = "_maps/RandomRooms/10x5/sk_rdm125_courtroom.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 5

/datum/map_template/random_room/sk_rdm126
	name = "komora gazowa"
	room_id = "sk_rdm126_gaschamber"
	mappath = "_maps/RandomRooms/10x5/sk_rdm126_gaschamber.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 4

/datum/map_template/random_room/sk_rdm127
	name = "rdzeń SI"
	room_id = "sk_rdm127_oldaichamber"
	mappath = "_maps/RandomRooms/10x5/sk_rdm127_oldaichamber.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 2

/datum/map_template/random_room/sk_rdm128
	name = "pokój radiacyjny"
	room_id = "sk_rdm128_radiationtherapy"
	mappath = "_maps/RandomRooms/10x5/sk_rdm128_radiationtherapy.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 4

/datum/map_template/random_room/sk_rdm129
	name = "Plaża"
	room_id = "sk_rdm129_beach"
	mappath = "_maps/RandomRooms/10x10/sk_rdm129_beach.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 2

/datum/map_template/random_room/sk_rdm130 //several tricky xeno spawners, and four two-percent egg spawners. this spawning a live xeno egg will be somewhat rare
	name = "ksenomorfy"
	room_id = "sk_rdm130_benoegg"
	mappath = "_maps/RandomRooms/10x10/sk_rdm130_benoegg.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 1

/datum/map_template/random_room/sk_rdm131 //contains several cells with the same spawners psychologist has, each of which has a chance to spawn a doorbolt trap
	name = "więzienie"
	room_id = "sk_rdm131_confinementroom"
	mappath = "_maps/RandomRooms/10x10/sk_rdm131_confinementroom.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 4

/datum/map_template/random_room/sk_rdm132
	name = "pokój z taśmociągami"
	room_id = "sk_rdm132_conveyorroom"
	mappath = "_maps/RandomRooms/10x10/sk_rdm132_conveyorroom.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 8

/datum/map_template/random_room/sk_rdm133
	name = "opuszczone biuro"
	room_id = "sk_rdm133_oldoffice"
	mappath = "_maps/RandomRooms/10x10/sk_rdm133_oldoffice.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 6

/datum/map_template/random_room/sk_rdm134 //contains a few traps, which can cause darkness and spawn angry trees
	name = "śnieżny las"
	room_id = "sk_rdm134_snowforest"
	mappath = "_maps/RandomRooms/10x10/sk_rdm134_snowforest.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 3

/datum/map_template/random_room/sk_rdm137
	name = "Malutki oddział psychiatryczny"
	room_id = "sk_rdm137_tinyshrink"
	mappath = "_maps/RandomRooms/3x5/sk_rdm137_tinyshrink.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm138
	name = "Przebieralnia"
	room_id = "sk_rdm138_magicroom"
	mappath = "_maps/RandomRooms/5x3/sk_rdm138_magicroom.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5
	weight = 4

/datum/map_template/random_room/sk_rdm139
	name = "cela izolacyjna"
	room_id = "sk_rdm139_containmentcell"
	mappath = "_maps/RandomRooms/3x3/containmentcell.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 3

/datum/map_template/random_room/sk_rdm140 //this is hilarious
	name = "mylące skrzyżowanie"
	room_id = "sk_rdm140_crossroads"
	mappath = "_maps/RandomRooms/3x5/sk_rdm140_crossroads.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 2

/datum/map_template/random_room/sk_rdm141
	name = "miejsce 6 sektorów niżej"
	room_id = "sk_rdm141_6sectorsdown"
	mappath = "_maps/RandomRooms/10x10/sk_rdm141_6sectorsdown.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 2

/datum/map_template/random_room/sk_rdm142
	name = "stara jadłodajnia"
	room_id = "sk_rdm142_olddiner"
	mappath = "_maps/RandomRooms/10x10/sk_rdm142_olddiner.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 4

/datum/map_template/random_room/sk_rdm143
	name = "jaskinia gamera"
	room_id = "sk_rdm143_gamercave"
	mappath = "_maps/RandomRooms/10x10/sk_rdm143_gamercave.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 3

/datum/map_template/random_room/sk_rdm144 //has Stage Magician Spawner
	name = "mała scena i bar"
	room_id = "sk_rdm144_smallmagician"
	mappath = "_maps/RandomRooms/10x10/sk_rdm144_smallmagician.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 3

/datum/map_template/random_room/sk_rdm145 //has tela anchor
	name = "ołtarz pani Tesli"
	room_id = "sk_rdm145_ladytesla_altar"
	mappath = "_maps/RandomRooms/10x10/sk_rdm145_ladytesla_altar.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 1 //rare

/datum/map_template/random_room/sk_rdm146
	name = "węzeł grodzi"
	room_id = "sk_rdm146_blastdoor_interchange"
	mappath = "_maps/RandomRooms/10x10/sk_rdm146_blastdoor_interchange.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 4 //common

/datum/map_template/random_room/sk_rdm147
	name = "zaawansowana mikrobotanika"
	room_id = "sk_rdm147_advbotany"
	mappath = "_maps/RandomRooms/10x10/sk_rdm147_advbotany.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 2

/datum/map_template/random_room/sk_rdm148
	name = "pasieka w tunelach technicznych"
	room_id = "sk_rdm148_botany_apiary"
	mappath = "_maps/RandomRooms/10x10/sk_rdm148_botany_apiary.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 2

/datum/map_template/random_room/sk_rdm149
	name = "okno na kosmos ze skrzyniami"
	room_id = "sk_rdm149_cratewindow"
	mappath = "_maps/RandomRooms/10x5/sk_rdm149_cratewindow.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 3

/datum/map_template/random_room/sk_rdm150
	name = "mała poczekalnia medyczna"
	room_id = "sk_rdm150_smallmedlobby"
	mappath = "_maps/RandomRooms/10x5/sk_rdm150_smallmedlobby.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 3 //common

/datum/map_template/random_room/sk_rdm151 //delicious
	name = "mała poczekalnia medyczna"
	room_id = "sk_rdm151_ratburger"
	mappath = "_maps/RandomRooms/10x5/sk_rdm151_ratburger.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 1 //rare

/datum/map_template/random_room/sk_rdm152
	name = "stare biuro genetyki"
	room_id = "sk_rdm152_geneticsoffice"
	mappath = "_maps/RandomRooms/10x5/sk_rdm152_geneticsoffice.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 2

/datum/map_template/random_room/sk_rdm153 //its a hobo den featuring Peter the pet frog.
	name = "pokój Petera"
	room_id = "sk_rdm153_hobowithpeter"
	mappath = "_maps/RandomRooms/10x5/sk_rdm153_hobowithpeter.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 2

/datum/map_template/random_room/sk_rdm154 //rare, has a cleaver.
	name = "jaskinia rzeźnika"
	room_id = "sk_rdm154_butchersden"
	mappath = "_maps/RandomRooms/10x5/sk_rdm154_butchersden.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 1

/datum/map_template/random_room/sk_rdm155
	name = "pułapka z kolcami punji na taśmociągu"
	room_id = "sk_rdm155_punjiconveyor"
	mappath = "_maps/RandomRooms/10x5/sk_rdm155_punjiconveyor.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 1

/datum/map_template/random_room/sk_rdm156
	name = "starożytny węzeł"
	room_id = "sk_rdm156_oldairlock_interchange"
	mappath = "_maps/RandomRooms/10x5/sk_rdm156_oldairlock_interchange.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 4
	stock = 2

/datum/map_template/random_room/sk_rdm157
	name = "Kosmiczne szachy"
	room_id = "sk_rdm157_chess"
	mappath = "_maps/RandomRooms/10x10/sk_rdm157_chess.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10

/datum/map_template/random_room/sk_rdm158
	name = "Magazyn kaplicy"
	room_id = "sk_rdm158_chapelstorage"
	mappath = "_maps/RandomRooms/3x5/sk_rdm158_kilochapelstorage.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3

/datum/map_template/random_room/sk_rdm159
	name = "Jama węży"
	room_id = "sk_rdm159_kilosnakepit"
	mappath = "_maps/RandomRooms/10x10/sk_rdm159_kilosnakepit.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10

/datum/map_template/random_room/sk_rdm160
	name = "Zaniedbany bar"
	room_id = "sk_rdm160_kilomaintbar"
	mappath = "_maps/RandomRooms/3x5/sk_rdm160_kilomaintbar.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3

/datum/map_template/random_room/sk_rdm161
	name = "Skarbiec banku"
	room_id = "sk_rdm161_kilovault"
	mappath = "_maps/RandomRooms/10x5/sk_rdm161_kilovault.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 1

/datum/map_template/random_room/sk_rdm162
	name = "Sterownia"
	room_id = "sk_rdm162_control_room"
	mappath = "_maps/RandomRooms/3x3/sk_rdm162_control_room.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 6

/datum/map_template/random_room/sk_rdm163 // potentially traumatising
	name = "Rzeźnik corgi"
	room_id = "sk_rdm163_corgi_butcher"
	mappath = "_maps/RandomRooms/3x3/sk_rdm163_corgi_butcher.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 2

/datum/map_template/random_room/sk_rdm164
	name = "Róg obfitości"
	room_id = "sk_rdm164_cornucopia"
	mappath = "_maps/RandomRooms/3x3/sk_rdm164_cornucopia.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm165
	name = "Minibiblioteka"
	room_id = "sk_rdm165_library"
	mappath = "_maps/RandomRooms/3x3/sk_rdm165_library.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm166
	name = "Drukarnia"
	room_id = "sk_rdm166_printing_press"
	mappath = "_maps/RandomRooms/5x4/sk_rdm166_printing_press.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	weight = 4

/datum/map_template/random_room/sk_rdm167 // has a real (but nonfunctional) cult rune
	name = "Rytuał w bibliotece"
	room_id = "sk_rdm167_library_ritual"
	mappath = "_maps/RandomRooms/10x10/sk_rdm167_library_ritual.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 1

/datum/map_template/random_room/sk_rdm168
	name = "Offish"
	room_id = "sk_rdm168_offish"
	mappath = "_maps/RandomRooms/3x5/sk_rdm168_offish.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 2

/datum/map_template/random_room/sk_rdm169
	name = "Tunele techniczne - panele słoneczne"
	room_id = "sk_rdm168_solars"
	mappath = "_maps/RandomRooms/5x4/sk_rdm168_solars.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	weight = 2

//Flandstation Dedicated Random Room

/datum/map_template/random_room/sk_rdm_fln_01
	name = "Wypożyczalnia hulajnóg"
	room_id = "sk_rdm_fln_01_scooterpark"
	mappath = "_maps/RandomRooms/fland/sk_rdm_fln_01_scooterpark.dmm"
	centerspawner = FALSE
	template_height = 11
	template_width = 5

/datum/map_template/random_room/sk_rdm_fln_02
	name = "Pszczeli salon"
	room_id = "sk_rdm_fln_02_beelounge"
	mappath = "_maps/RandomRooms/fland/sk_rdm_fln_02_beelounge.dmm"
	centerspawner = FALSE
	template_height = 11
	template_width = 5

/datum/map_template/random_room/sk_rdm_fln_03
	name = "Minimarket z automatami"
	room_id = "sk_rdm_fln_03_vendingminimarket"
	mappath = "_maps/RandomRooms/fland/sk_rdm_fln_03_vendingminimarket.dmm"
	centerspawner = FALSE
	template_height = 11
	template_width = 5

/datum/map_template/random_room/sk_rdm_fln_04
	name = "Pusty sklepik"
	room_id = "sk_rdm_fln_04_conveniencestore"
	mappath = "_maps/RandomRooms/fland/sk_rdm_fln_04_conveniencestore.dmm"
	centerspawner = FALSE
	template_height = 11
	template_width = 5

/datum/map_template/random_room/sk_rdm_fln_05
	name = "Pasieka"
	room_id = "sk_rdm_fln_05_apiary"
	mappath = "_maps/RandomRooms/fland/sk_rdm_fln_05_apiary.dmm"
	centerspawner = FALSE
	template_height = 11
	template_width = 5

/datum/map_template/random_room/sk_rdm_fln_06
	name = "Ogród publiczny"
	room_id = "sk_rdm_fln_06_publicgarden"
	mappath = "_maps/RandomRooms/fland/sk_rdm_fln_06_publicgarden.dmm"
	centerspawner = FALSE
	template_height = 11
	template_width = 5

/datum/map_template/random_room/sk_rdm_fln_07
	name = "Litera H"
	room_id = "sk_rdm_fln_07_theletterh"
	mappath = "_maps/RandomRooms/fland/sk_rdm_fln_07_theletterh.dmm"
	centerspawner = FALSE
	template_height = 11
	template_width = 5

/datum/map_template/random_room/sk_rdm_fln_08
	name = "Pokój zen"
	room_id = "sk_rdm_fln_08_zenroom"
	mappath = "_maps/RandomRooms/fland/sk_rdm_fln_08_zenroom.dmm"
	centerspawner = FALSE
	template_height = 11
	template_width = 5

/datum/map_template/random_room/sk_rdm_fln_09
	name = "Zakład fryzjerski"
	room_id = "sk_rdm_fln_09_barbershop"
	mappath = "_maps/RandomRooms/fland/sk_rdm_fln_09_barbershop.dmm"
	centerspawner = FALSE
	template_height = 11
	template_width = 5

/datum/map_template/random_room/sk_rdm_fln_10
	name = "Czytelnia"
	room_id = "sk_rdm_fln_10_readingroom"
	mappath = "_maps/RandomRooms/fland/sk_rdm_fln_10_readingroom.dmm"
	centerspawner = FALSE
	template_height = 11
	template_width = 5

/datum/map_template/random_room/sk_rdm_fln_11
	name = "Pudło menela"
	room_id = "sk_rdm_fln_11_hobobox"
	mappath = "_maps/RandomRooms/fland/sk_rdm_fln_11_hobobox.dmm"
	centerspawner = FALSE
	template_height = 11
	template_width = 5

/datum/map_template/random_room/sk_rdm_fln_12
	name = "Magiczna scena"
	room_id = "sk_rdm_fln_12_magicstage"
	mappath = "_maps/RandomRooms/fland/sk_rdm_fln_12_magicstage.dmm"
	centerspawner = FALSE
	template_height = 11
	template_width = 5

//AQ EDIT START
/datum/map_template/random_room/sk_rdm_glg_01
	name = "Placówka badawcza popielnych wędrowców"
	room_id = "sk_rdm_glg_01_ashwalker"
	mappath = "_maps/RandomRuins/GulagRuins/ashwalker.dmm"
	centerspawner = FALSE
	template_height = 40
	template_width = 40

/datum/map_template/random_room/sk_rdm_glg_02
	name = "Rozbity statek wolnych golemów"
	room_id = "sk_rdm_glg_02_golem"
	mappath = "_maps/RandomRuins/GulagRuins/golem.dmm"
	centerspawner = FALSE
	template_height = 40
	template_width = 40

/datum/map_template/random_room/sk_rdm_glg_03
	name = "Kosmiczny bank nasion"
	room_id = "sk_rdm_glg_03_seed"
	mappath = "_maps/RandomRuins/GulagRuins/seed.dmm"
	centerspawner = FALSE
	template_height = 40
	template_width = 40

/datum/map_template/random_room/sk_rdm_glg_04
	name = "Menele Beach"
	room_id = "sk_rdm_glg_04_menele"
	mappath = "_maps/RandomRuins/GulagRuins/menele.dmm"
	centerspawner = FALSE
	template_height = 40
	template_width = 40

/datum/map_template/random_room/sk_rdm_glg_05
	name = "Placówka broni biologicznej Syndykatu"
	room_id = "sk_rdm_glg_05_syndicate_bio"
	mappath = "_maps/RandomRuins/GulagRuins/syndicate_bio.dmm"
	centerspawner = FALSE
	template_height = 40
	template_width = 40

/datum/map_template/random_room/sk_rdm_glg_06
	name = "Posterunek nasłuchowy Syndykatu"
	room_id = "sk_rdm_glg_06_syndicate_listening"
	mappath = "_maps/RandomRuins/GulagRuins/syndicate_listening.dmm"
	centerspawner = FALSE
	template_height = 40
	template_width = 40

/datum/map_template/random_room/sk_rdm_glg_07
	name = "Pokój gier"
	room_id = "sk_rdm_glg_07_gameroom"
	mappath = "_maps/RandomRuins/GulagRuins/gameroom.dmm"
	centerspawner = FALSE
	template_height = 40
	template_width = 40

/datum/map_template/random_room/sk_rdm_eng_atl_01
	name = "Atlas - napęd Stormdrive"
	room_id = "sk_rdm_eng_atl_01_atlas_engine_stormdrive"
	mappath = "_maps/RandomRooms/engine/atlas_engine_stormdrive.dmm"
	centerspawner = FALSE
	template_height = 18
	template_width = 22

/datum/map_template/random_room/sk_rdm_eng_atl_02
	name = "Atlas - silnik supermaterii"
	room_id = "sk_rdm_eng_atl_02_atlas_engine_supermatter"
	mappath = "_maps/RandomRooms/engine/atlas_engine_supermatter.dmm"
	centerspawner = FALSE
	template_height = 18
	template_width = 22

/datum/map_template/random_room/sk_rdm_eng_atl_03
	name = "Atlas - silnik Tesli"
	room_id = "sk_rdm_eng_atl_03_atlas_engine_tesla"
	mappath = "_maps/RandomRooms/engine/atlas_engine_tesla.dmm"
	centerspawner = FALSE
	template_height = 18
	template_width = 22

//Space Ruin Parents

/area/ruin/space
	has_gravity = FALSE
	area_flags = UNIQUE_AREA

/area/ruin/space/has_grav
	has_gravity = STANDARD_GRAVITY

/area/ruin/space/has_grav/powered
	requires_power = FALSE

/////////////

/area/ruin/space/way_home
	name = "\improper Ocalenie"
	icon_state = "away"
	always_unpowered = FALSE

// Ruins of "onehalf" ship

/area/ruin/space/has_grav/onehalf/hallway
	name = "Korytarz"
	icon_state = "hallC"

/area/ruin/space/has_grav/onehalf/drone_bay
	name = "Hangar Dronów Górniczych"
	icon_state = "engine"

/area/ruin/space/has_grav/onehalf/dorms_med
	name = "Kwatery Załogi"
	icon_state = "Sleep"

/area/ruin/space/has_grav/onehalf/bridge
	name = "Mostek"
	icon_state = "bridge"



/area/ruin/space/has_grav/powered/dinner_for_two
	name = "Kolacja we Dwoje"

/area/ruin/space/has_grav/powered/cat_man
	name = "Kocia Nora"

/area/ruin/space/has_grav/powered/authorship
	name = "Autorstwo"

/area/ruin/space/has_grav/powered/aesthetic
	name = "Estetyka"
	ambientsounds = list('sound/ambience/ambivapor1.ogg')


//Ruin of Hotel

/area/ruin/space/has_grav/hotel
	name = "Hotel"

/area/ruin/space/has_grav/hotel/guestroom
	name = "Pokój Gościnny Hotelu"
	icon_state = "Sleep"

/area/ruin/space/has_grav/hotel/guestroom/room_1
	name = "Pokój Gościnny Hotelu 1"

/area/ruin/space/has_grav/hotel/guestroom/room_2
	name = "Pokój Gościnny Hotelu 2"

/area/ruin/space/has_grav/hotel/guestroom/room_3
	name = "Pokój Gościnny Hotelu 3"

/area/ruin/space/has_grav/hotel/guestroom/room_4
	name = "Pokój Gościnny Hotelu 4"

/area/ruin/space/has_grav/hotel/guestroom/room_5
	name = "Pokój Gościnny Hotelu 5"

/area/ruin/space/has_grav/hotel/guestroom/room_6
	name = "Pokój Gościnny Hotelu 6"

/area/ruin/space/has_grav/hotel/security
	name = "Posterunek Ochrony Hotelu"
	icon_state = "security"

/area/ruin/space/has_grav/hotel/pool
	name = "Basen Hotelu"
	icon_state = "fitness"

/area/ruin/space/has_grav/hotel/bar
	name = "Bar Hotelu"
	icon_state = "cafeteria"

/area/ruin/space/has_grav/hotel/power
	name = "Rozdzielnia Hotelu"
	icon_state = "engine_smes"

/area/ruin/space/has_grav/hotel/custodial
	name = "Schowek Woźnego Hotelu"
	icon_state = "janitor"

/area/ruin/space/has_grav/hotel/shuttle
	name = "Prom Hotelu"
	icon_state = "shuttle"
	requires_power = FALSE

/area/ruin/space/has_grav/hotel/dock
	name = "Dok Promu Hotelu"
	icon_state = "start"

/area/ruin/space/has_grav/hotel/workroom
	name = "Pokój Personelu Hotelu"
	icon_state = "crew_quarters"

/area/ruin/space/has_grav/hotel/secondary_solars
	name = "Pomocnicza Sterownia Paneli Słonecznych Hotelu"
	icon_state = "engine_smes"




//Ruin of Derelict Oupost

/area/ruin/space/has_grav/derelictoutpost
	name = "Opuszczony Posterunek"
	icon_state = "green"

/area/ruin/space/has_grav/derelictoutpost/cargostorage
	name = "Magazyn Ładunków Opuszczonego Posterunku"
	icon_state = "storage"

/area/ruin/space/has_grav/derelictoutpost/cargobay
	name = "Ładownia Opuszczonego Posterunku"
	icon_state = "quartstorage"

/area/ruin/space/has_grav/derelictoutpost/powerstorage
	name = "Magazyn Energii Opuszczonego Posterunku"
	icon_state = "engine_smes"

/area/ruin/space/has_grav/derelictoutpost/dockedship
	name = "Statek Zadokowany przy Opuszczonym Posterunku"
	icon_state = "red"

//Ruin of turretedoutpost

/area/ruin/space/has_grav/turretedoutpost
	name = "Posterunek z Wieżyczkami"
	icon_state = "red"


//Ruin of old teleporter

/area/ruin/space/oldteleporter
	name = "Stary Teleporter"
	icon_state = "teleporter"


//Ruin of mech transport

/area/ruin/space/has_grav/powered/mechtransport
	name = "Transport Mechów"
	icon_state = "green"


//Ruin of gas the lizard

/area/ruin/space/has_grav/gasthelizard
	name = "Zagazuj Jaszczura"


//Ruin of Deep Storage

/area/ruin/space/has_grav/deepstorage
	name = "Głęboki Magazyn"
	icon_state = "storage"

/area/ruin/space/has_grav/deepstorage/airlock
	name = "Śluza Głębokiego Magazynu"
	icon_state = "quart"

/area/ruin/space/has_grav/deepstorage/power
	name = "Rozdzielnia i Atmosferyka Głębokiego Magazynu"
	icon_state = "engi_storage"

/area/ruin/space/has_grav/deepstorage/hydroponics
	name = "Hydroponika Głębokiego Magazynu"
	icon_state = "garden"

/area/ruin/space/has_grav/deepstorage/armory
	name = "Strzeżony Magazyn Głębokiego Magazynu"
	icon_state = "armory"

/area/ruin/space/has_grav/deepstorage/storage
	name = "Składzik Głębokiego Magazynu"
	icon_state = "storage_wing"

/area/ruin/space/has_grav/deepstorage/dorm
	name = "Kwatery Głębokiego Magazynu"
	icon_state = "crew_quarters"

/area/ruin/space/has_grav/deepstorage/kitchen
	name = "Kuchnia Głębokiego Magazynu"
	icon_state = "kitchen"

/area/ruin/space/has_grav/deepstorage/crusher
	name = "Recykler Głębokiego Magazynu"
	icon_state = "storage"


//Ruin of Abandoned Zoo

/area/ruin/space/has_grav/abandonedzoo
	name = "Opuszczone Zoo"
	icon_state = "green"


//Ruin of ancient Space Station

/area/ruin/space/has_grav/ancientstation
	name = "Główny Korytarz Stacji Charlie"
	icon_state = "green"

/area/ruin/space/has_grav/ancientstation/powered
	name = "Zasilane Pole"
	icon_state = "teleporter"
	requires_power = FALSE

/area/ruin/space/has_grav/ancientstation/space
	name = "Otwarte na Kosmos"
	icon_state = "teleporter"
	has_gravity = FALSE

/area/ruin/space/has_grav/ancientstation/atmo
	name = "Atmosferyka Stacji Beta"
	icon_state = "red"
	has_gravity = FALSE
	ambience_index = AMBIENCE_ENGI

/area/ruin/space/has_grav/ancientstation/betanorth
	name = "Północny Korytarz Stacji Beta"
	icon_state = "blue"

/area/ruin/space/has_grav/ancientstation/solar
	name = "Panele Słoneczne Stacji"
	icon_state = "panelsAP"

/area/ruin/space/has_grav/ancientstation/engi
	name = "Inżynieria Stacji Charlie"
	icon_state = "engine"
	ambience_index = AMBIENCE_ENGI

/area/ruin/space/has_grav/ancientstation/comm
	name = "Dowództwo Stacji Charlie"
	icon_state = "captain"

/area/ruin/space/has_grav/ancientstation/hydroponics
	name = "Hydroponika Stacji Charlie"
	icon_state = "garden"

/area/ruin/space/has_grav/ancientstation/kitchen
	name = "Kuchnia Stacji Charlie"
	icon_state = "kitchen"

/area/ruin/space/has_grav/ancientstation/sec
	name = "Ochrona Stacji Charlie"
	icon_state = "red"

/area/ruin/space/has_grav/ancientstation/deltacorridor
	name = "Główny Korytarz Stacji Delta"
	icon_state = "green"

/area/ruin/space/has_grav/ancientstation/proto
	name = "Laboratorium Prototypów Stacji Delta"
	icon_state = "toxlab"

/area/ruin/space/has_grav/ancientstation/rnd
	name = "Badania i Rozwój Stacji Delta"
	icon_state = "toxlab"

/area/ruin/space/has_grav/ancientstation/hivebot
	name = "Statek-Matka Hivebotów"
	icon_state = "teleporter"

//DERELICT

/area/ruin/space/derelict
	name = "Opuszczona Stacja"
	icon_state = "storage"

/area/ruin/space/derelict/hallway/primary
	name = "Główny Korytarz Opuszczonej Stacji"
	icon_state = "hallP"

/area/ruin/space/derelict/hallway/secondary
	name = "Boczny Korytarz Opuszczonej Stacji"
	icon_state = "hallS"

/area/ruin/space/derelict/hallway/primary/port
	name = "Korytarz Burty Opuszczonej Stacji"
	icon_state = "hallFP"

/area/ruin/space/derelict/arrival
	name = "Centrum Przylotów Opuszczonej Stacji"
	icon_state = "yellow"

/area/ruin/space/derelict/storage/equipment
	name = "Magazyn Sprzętu Opuszczonej Stacji"

/area/ruin/space/derelict/bridge
	name = "Sterownia Opuszczonej Stacji"
	icon_state = "bridge"

/area/ruin/space/derelict/bridge/access
	name = "Przejście do Sterowni Opuszczonej Stacji"
	icon_state = "auxstorage"

/area/ruin/space/derelict/bridge/ai_upload
	name = "Rdzeń Komputerowy Opuszczonej Stacji"
	icon_state = "ai"

/area/ruin/space/derelict/solar_control
	name = "Sterownia Paneli Słonecznych Opuszczonej Stacji"
	icon_state = "engine"

/area/ruin/space/derelict/se_solar
	name = "Południowo-Wschodnie Panele Słoneczne"
	icon_state = "engine"

/area/ruin/space/derelict/medical
	name = "Ambulatorium Opuszczonej Stacji"
	icon_state = "medbay"

/area/ruin/space/derelict/medical/chapel
	name = "Kaplica Opuszczonej Stacji"
	icon_state = "chapel"

/area/solar/derelict_starboard
	name = "Panele Słoneczne Sterburty Opuszczonej Stacji"
	icon_state = "panelsS"

/area/solar/derelict_aft
	name = "Panele Słoneczne Rufy Opuszczonej Stacji"
	icon_state = "yellow"

/area/ruin/space/derelict/singularity_engine
	name = "Silnik Osobliwości Opuszczonej Stacji"
	icon_state = "engine"

/area/ruin/space/derelict/gravity_generator
	name = "Pomieszczenie Generatora Grawitacji Opuszczonej Stacji"
	icon_state = "red"

/area/ruin/space/derelict/atmospherics
	name = "Atmosferyka Opuszczonej Stacji"
	icon_state = "red"

//DJSTATION

/area/ruin/space/djstation
	name = "Ruska Stacja DJ-a"
	icon_state = "DJ"
	has_gravity = STANDARD_GRAVITY

/area/ruin/space/djstation/solars
	name = "Panele Słoneczne Stacji DJ-a"
	icon_state = "DJ"
	has_gravity = STANDARD_GRAVITY


//ABANDONED TELEPORTER

/area/ruin/space/abandoned_tele
	name = "Opuszczony Teleporter"
	icon_state = "teleporter"
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/signal.ogg')

//OLD AI SAT

/area/tcommsat/oldaisat
	name = "Opuszczony Satelita"
	icon_state = "tcomsatcham"

//ABANDONED BOX WHITESHIP

/area/ruin/space/has_grav/whiteship/box

	name = "Opuszczony Statek"
	icon_state = "red"


//SYNDICATE LISTENING POST STATION

/area/ruin/space/has_grav/listeningstation
	name = "Posterunek Nasłuchowy"
	icon_state = "yellow"

/area/ruin/space/has_grav/powered/ancient_shuttle
	name = "Starożytny Prom"
	icon_state = "yellow"

/area/ruin/space/has_grav/powered/macspace
	name = "Kosmiczna Restauracja Mac"
	icon_state = "yellow"

//POWER PUZLE

/area/ruin/space/has_grav/storage/central
	name = "Magazyn Centralny"
	icon_state = "hallC"

/area/ruin/space/has_grav/storage/central2
	name = "Skarbiec Magazynu"
	icon_state = "red"

/area/ruin/space/has_grav/storage/materials1
	name = "Dziobowy Pokój Materiałów Magazynu"
	icon_state = "storage_wing"

/area/ruin/space/has_grav/storage/materials2
	name = "Strzeżony Pokój Materiałów Magazynu"
	icon_state = "storage"

/area/ruin/space/has_grav/storage/materials3
	name = "Różne Materiały Magazynu"
	icon_state = "yellow"

/area/ruin/space/has_grav/storage/power1
	name = "Centralna Inżynieria Magazynu"
	icon_state = "yellow"

/area/ruin/space/has_grav/storage/power2
	name = "Inżynieria Magazynu"
	icon_state = "engi_storage"

/area/ruin/space/has_grav/storage/power3
	name = "Skrzynie Magazynu"
	icon_state = "green"

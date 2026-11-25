// Szarfy mięsoludzi (Fulpstation, fulp_modules/features/species/beefmen/beefman_clothing.dm).
// Mięsoczłowiek dostaje na start szarfę działu zamiast kombinezonu (after_equip_job w beefman.dm), z pancerzem i czujnikami kombinezonu.

/obj/item/clothing/under/bodysash
	name = "szarfa majtka"
	desc = "Prosta szarfa majtka, przewieszona od ramienia do biodra."
	icon = 'aquila/icons/mob/species/beefman/beefclothing.dmi'
	worn_icon = 'aquila/icons/mob/species/beefman/beefclothing_worn.dmi'
	icon_state = "assistant"
	lefthand_file = 'aquila/icons/mob/species/beefman/beefclothing_hold_left.dmi'
	righthand_file = 'aquila/icons/mob/species/beefman/beefclothing_hold_right.dmi'
	item_state = "sash"
	can_adjust = FALSE
	fitted = NO_FEMALE_UNIFORM
	body_parts_covered = CHEST

/obj/item/clothing/under/bodysash/Initialize(mapload)
	. = ..()
	worn_icon_state = icon_state // item_state to stan w ręce, na ciele szarfa ma własny stan

/obj/item/clothing/under/bodysash/captain
	name = "szarfa kapitana"
	desc = "Szarfa haftowana złotem, której znaki zdradzają, że jej właściciel jest kapitanem."
	icon_state = "captain_beef"

/obj/item/clothing/under/bodysash/hop
	name = "szarfa starszego oficera"
	desc = "Szarfa dla tych, którzy tańczą z papierami."
	icon_state = "hop"

/obj/item/clothing/under/bodysash/command
	name = "szarfa dowództwa"
	desc = "Szarfa oficera dowództwa."
	icon_state = "command"

/obj/item/clothing/under/bodysash/security
	name = "szarfa żandarma"
	desc = "„Taktyczna” szarfa żandarmerii."
	icon_state = "security"

/obj/item/clothing/under/bodysash/security/hos
	name = "szarfa komendanta"
	desc = "„Taktyczna” szarfa dla tych, którzy cenią „sprawiedliwość” na tyle, by zostać komendantem."
	icon_state = "hos"

/obj/item/clothing/under/bodysash/security/warden
	name = "szarfa naczelnika"
	desc = "„Taktyczna” szarfa naczelnika."
	icon_state = "warden"

/obj/item/clothing/under/bodysash/security/detective
	name = "szarfa detektywa"
	desc = "Szarfa kogoś, kto nie żartuje."
	icon_state = "detective"

/obj/item/clothing/under/bodysash/security/deputy
	name = "szarfa aspiranta"
	desc = "Budząca podziw „taktyczna” szarfa, bo bezpieczeństwo nie bierze urlopu."
	icon_state = "deputy"

/obj/item/clothing/under/bodysash/medical
	name = "szarfa lekarza"
	desc = "Szarfa lekarza. Trochę chroni przed zagrożeniami biologicznymi."
	icon_state = "medical"

/obj/item/clothing/under/bodysash/medical/cmo
	name = "szarfa ordynatora"
	desc = "Szarfa ordynatora. Trochę chroni przed zagrożeniami biologicznymi."
	icon_state = "cmo"

/obj/item/clothing/under/bodysash/medical/chemist
	name = "szarfa chemika"
	desc = "Szarfa chemika. Trochę chroni przed kwasem."
	icon_state = "chemist"

/obj/item/clothing/under/bodysash/medical/virologist
	name = "szarfa wirusologa"
	desc = "Szarfa wirusologa. Trochę chroni przed zagrożeniami biologicznymi."
	icon_state = "virologist"

/obj/item/clothing/under/bodysash/medical/paramedic
	name = "szarfa ratownika medycznego"
	desc = "Szarfa ratownika medycznego. Trochę chroni przed zagrożeniami biologicznymi."
	icon_state = "paramedic"

/obj/item/clothing/under/bodysash/engineer
	name = "szarfa inżyniera"
	desc = "Szarfa inżyniera. Trochę chroni przed promieniowaniem i ogniem."
	icon_state = "engineer"

/obj/item/clothing/under/bodysash/engineer/ce
	name = "szarfa głównego inżyniera"
	desc = "Szarfa głównego inżyniera. Trochę chroni przed promieniowaniem i ogniem."
	icon_state = "ce"

/obj/item/clothing/under/bodysash/engineer/atmos
	name = "szarfa technika atmosferyki"
	desc = "Szarfa technika atmosferyki."
	icon_state = "atmos"

/obj/item/clothing/under/bodysash/rd
	name = "szarfa dyrektora naukowego"
	desc = "Szarfa dyrektora naukowego. Trochę chroni przed zagrożeniami biologicznymi."
	icon_state = "rd"

/obj/item/clothing/under/bodysash/scientist
	name = "szarfa naukowca"
	desc = "Szarfa naukowca. Trochę chroni przed wybuchami."
	icon_state = "scientist"

/obj/item/clothing/under/bodysash/roboticist
	name = "szarfa robotyka"
	desc = "Szarfa robotyka. Trochę chroni przed wybuchami."
	icon_state = "roboticist"

/obj/item/clothing/under/bodysash/geneticist
	name = "szarfa genetyka"
	desc = "Szarfa genetyka. Trochę chroni przed wybuchami."
	icon_state = "geneticist"

/obj/item/clothing/under/bodysash/qm
	name = "szarfa kwatermistrza"
	desc = "Szarfa kwatermistrza."
	icon_state = "qm"

/obj/item/clothing/under/bodysash/cargo
	name = "szarfa magazyniera"
	desc = "Szarfa magazyniera."
	icon_state = "cargo"

/obj/item/clothing/under/bodysash/miner
	name = "szarfa górnika"
	desc = "Szarfa górnika."
	icon_state = "miner"

/obj/item/clothing/under/bodysash/clown
	name = "szarfa klauna"
	desc = "Szarfa klauna. Honk!"
	icon_state = "clown"

/obj/item/clothing/under/bodysash/mime
	name = "szarfa mima"
	desc = "..."
	icon_state = "mime"

/obj/item/clothing/under/bodysash/prisoner
	name = "szarfa więźnia"
	desc = "Standardowa więzienna szarfa Nanotrasen. Jej czujniki utknęły na „W pełni włączone”."
	icon_state = "prisoner"
	has_sensor = LOCKED_SENSORS
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/bodysash/cook
	name = "szarfa kucharza"
	desc = "Szarfa kucharza."
	icon_state = "cook"

/obj/item/clothing/under/bodysash/bartender
	name = "szarfa barmana"
	desc = "Szarfa barmana."
	icon_state = "bartender"

/obj/item/clothing/under/bodysash/chaplain
	name = "szarfa kapłana"
	desc = "Szarfa kapłana."
	icon_state = "chaplain"

/obj/item/clothing/under/bodysash/curator
	name = "szarfa bibliotekarza"
	desc = "Szarfa bibliotekarza."
	icon_state = "curator"

/obj/item/clothing/under/bodysash/lawyer
	name = "szarfa prawnika"
	desc = "Szarfa prawnika."
	icon_state = "lawyer"

/obj/item/clothing/under/bodysash/botanist
	name = "szarfa botanika"
	desc = "Szarfa botanika."
	icon_state = "botanist"

/obj/item/clothing/under/bodysash/janitor
	name = "szarfa woźnego"
	desc = "Szarfa woźnego."
	icon_state = "janitor"

/obj/item/clothing/under/bodysash/psychologist
	name = "szarfa psychiatry"
	desc = "Szarfa psychiatry."
	icon_state = "psychologist"

/obj/item/clothing/under/bodysash/civilian
	name = "szarfa cywila"
	desc = "Szarfa cywila."
	icon_state = "civilian"

/obj/item/clothing/under/bodysash/official
	name = "szarfa urzędnika"
	desc = "Szarfa urzędnika."
	icon_state = "official"

/obj/item/clothing/under/bodysash/intern
	name = "szarfa stażysty"
	desc = "Szarfa stażysty."
	icon_state = "intern"

/obj/item/clothing/under/bodysash/centcom
	name = "szarfa CentComu"
	desc = "Szarfa CentComu."
	icon_state = "centcom"

/obj/item/clothing/under/bodysash/russia
	name = "rosyjska szarfa"
	desc = "Szarfa w barwach Kosmicznej Rosji."
	icon_state = "russia"

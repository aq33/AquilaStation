GLOBAL_LIST_INIT(abductor_gear, subtypesof(/datum/abductor_gear))

/datum/abductor_gear
	/// Name of the gear
	var/name = "Ogólny sprzęt porywaczy"
	/// Description of the gear
	var/description = "Ogólny opis."
	/// Unique ID of the gear
	var/id = "abductor_generic"
	/// Credit cost of the gear
	var/cost = 1
	/// Build path of the gear itself
	var/build_path = null
	/// Category of the gear
	var/category = "Sprzęt podstawowy"

/datum/abductor_gear/agent_helmet
	name = "Hełm agenta"
	description = "Porywaj ze stylem - kolczastym stylem. Zapobiega namierzaniu cyfrowemu."
	id = "agent_helmet"
	build_path = /obj/item/clothing/head/helmet/abductor

/datum/abductor_gear/agent_vest
	name = "Kamizelka agenta"
	description = "Kamizelka z zaawansowaną technologią maskującą. Ma dwa tryby - bojowy i maskujący."
	id = "agent_vest"
	build_path = /obj/item/clothing/suit/armor/abductor/vest

/datum/abductor_gear/radio_silencer
	name = "Wyciszacz radiowy"
	description = "Kompaktowe urządzenie do wyłączania sprzętu komunikacyjnego."
	id = "radio_silencer"
	build_path = /obj/item/abductor/silencer

/datum/abductor_gear/science_tool
	name = "Narzędzie naukowe"
	description = "Dwutrybowe narzędzie do odbierania okazów i skanowania wyglądu. Skanować można przez kamery."
	id = "science_tool"
	build_path = /obj/item/abductor/gizmo

/datum/abductor_gear/advanced_baton
	name = "Zaawansowana pałka"
	description = "Czterotrybowa pałka do obezwładniania i krępowania okazów."
	id = "advanced_baton"
	cost = 2
	build_path = /obj/item/abductor/baton

/datum/abductor_gear/agent_id
	name = "Karta agenta"
	description = "Karta agenta, która kopiuje dostępy z kart identyfikacyjnych okazów."
	id = "agent_id"
	build_path = /obj/item/card/id/syndicate

/datum/abductor_gear/superlingual_matrix
	name = "Matryca nadjęzykowa"
	description = "Tajemnicza struktura pozwalająca na natychmiastową komunikację między użytkownikami. Robi wrażenie, dopóki nie trzeba czegoś zjeść."
	id = "superlingual_matrix"
	build_path = /obj/item/organ/tongue/abductor
	category = "Sprzęt zaawansowany"

/datum/abductor_gear/mental_interface
	name = "Interfejs mentalny"
	description = "Dwutrybowe narzędzie do bezpośredniej komunikacji ze świadomymi mózgami. Można nim wysłać wiadomość prosto do celu \
				albo rozkaz obiektowi z naładowanym gruczołem."
	id = "mental_interface"
	cost = 2
	build_path = /obj/item/abductor/mind_device
	category = "Sprzęt zaawansowany"

/datum/abductor_gear/reagent_synthesizer
	name = "Syntezator odczynników"
	description = "Syntetyzuje różne substancje z protomaterii."
	id = "reagent_synthesizer"
	cost = 2
	build_path = /obj/item/abductor_machine_beacon/chem_dispenser
	category = "Sprzęt zaawansowany"

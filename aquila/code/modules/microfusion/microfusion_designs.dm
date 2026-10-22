// Projekty broni microfusion. Ilości materiałów z tg przeliczone na nasze (arkusz = 2000).

/datum/design/microfusion
	name = "Microfusion Part"
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	category = list("Weapons")

/datum/design/microfusion/phase_emitter/enhanced
	name = "Ulepszony emiter fazowy microfusion"
	desc = "Serce broni microfusion, to on wytwarza laser."
	id = "enhanced_microfusion_phase_emitter"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 1000)
	build_path = /obj/item/microfusion_phase_emitter/enhanced

/datum/design/microfusion/phase_emitter/advanced
	name = "Zaawansowany emiter fazowy microfusion"
	desc = "Serce broni microfusion. Trwalszy i lepiej radzi sobie z ciepłem niż poprzednie generacje."
	id = "advanced_microfusion_phase_emitter"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 1000, /datum/material/gold = 1000)
	build_path = /obj/item/microfusion_phase_emitter/advanced

/datum/design/microfusion/phase_emitter/bluespace
	name = "Bluespace'owy emiter fazowy microfusion"
	desc = "Serce broni microfusion. W większości dziedzin dwa razy wytrzymalszy od pierwszej generacji."
	id = "bluespace_microfusion_phase_emitter"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 1000, /datum/material/gold = 1000, /datum/material/diamond = 1000)
	build_path = /obj/item/microfusion_phase_emitter/bluespace

/datum/design/microfusion/cell/basic
	name = "Podstawowe ogniwo microfusion"
	desc = "Podstawowe ogniwo microfusion o pojemności 1200 MF i jednym miejscu na dodatek."
	id = "basic_microfusion_cell"
	build_type = PROTOLATHE | AUTOLATHE
	category = list("initial", "Security", "Weapons")
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 400)
	build_path = /obj/item/stock_parts/cell/microfusion

/datum/design/microfusion/cell/enhanced
	name = "Ulepszone ogniwo microfusion"
	desc = "Ulepszone ogniwo microfusion o pojemności 1500 MF i jednym miejscu na dodatek."
	id = "enhanced_microfusion_cell"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 400, /datum/material/uranium = 400)
	build_path = /obj/item/stock_parts/cell/microfusion/enhanced

/datum/design/microfusion/cell/advanced
	name = "Zaawansowane ogniwo microfusion"
	desc = "Zaawansowane ogniwo microfusion o pojemności 1700 MF i trzech miejscach na dodatki."
	id = "advanced_microfusion_cell"
	materials = list(/datum/material/iron = 1000, /datum/material/gold = 600, /datum/material/silver = 600, /datum/material/glass = 600, /datum/material/uranium = 600)
	build_path = /obj/item/stock_parts/cell/microfusion/advanced

/datum/design/microfusion/cell/bluespace
	name = "Bluespace'owe ogniwo microfusion"
	desc = "Bluespace'owe ogniwo microfusion o pojemności 2000 MF i czterech miejscach na dodatki."
	id = "bluespace_microfusion_cell"
	materials = list(/datum/material/iron = 1000, /datum/material/gold = 600, /datum/material/glass = 600, /datum/material/diamond = 600, /datum/material/uranium = 600, /datum/material/titanium = 600, /datum/material/bluespace = 600)
	build_path = /obj/item/stock_parts/cell/microfusion/bluespace

/datum/design/microfusion/cell_attachment/stabilising
	name = "Dodatek stabilizujący do ogniwa microfusion"
	desc = "Ogniwo z nim nie iskrzy i nie promieniuje przy samoładowaniu."
	id = "microfusion_cell_attachment_stabiliser"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/plasma = 1000, /datum/material/silver = 1000)
	build_path = /obj/item/microfusion_cell_attachment/stabiliser

/datum/design/microfusion/cell_attachment/overcapacity
	name = "Dodatek nadpojemnościowy do ogniwa microfusion"
	desc = "Zwiększa pojemność ogniwa o 20%."
	id = "microfusion_cell_attachment_overcapacity"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/plasma = 1000, /datum/material/gold = 8000)
	build_path = /obj/item/microfusion_cell_attachment/overcapacity

/datum/design/microfusion/cell_attachment/selfcharging
	name = "Dodatek samoładujący do ogniwa microfusion"
	desc = "Ogniwo ładuje się samo, ale bez stabilizatora może promieniować."
	id = "microfusion_cell_attachment_selfcharging"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 1000, /datum/material/uranium = 6000, /datum/material/titanium = 6000, /datum/material/bluespace = 2000)
	build_path = /obj/item/microfusion_cell_attachment/selfcharging

/datum/design/microfusion/attachment/rail
	name = "Szyna montażowa microfusion"
	desc = "Pozwala zamontować na broni latarkę albo bagnet."
	id = "microfusion_gun_attachment_rail"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 1000, /datum/material/gold = 1000)
	build_path = /obj/item/microfusion_gun_attachment/rail

/datum/design/microfusion/attachment/scope
	name = "Luneta microfusion"
	desc = "Luneta do strzelania na duże odległości."
	id = "microfusion_gun_attachment_scope"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 1000)
	build_path = /obj/item/microfusion_gun_attachment/scope

/datum/design/microfusion/attachment/grip
	name = "Chwyt microfusion"
	desc = "Chwyt, który zmniejsza rozrzut i odrzut."
	id = "microfusion_gun_attachment_grip"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 1000)
	build_path = /obj/item/microfusion_gun_attachment/grip

/datum/design/microfusion/attachment/heatsink
	name = "Radiator emitera fazowego"
	desc = "Znacznie przyspiesza chłodzenie emitera fazowego."
	id = "microfusion_gun_attachment_heatsink"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 1000, /datum/material/gold = 1000)
	build_path = /obj/item/microfusion_gun_attachment/heatsink

/datum/design/microfusion/attachment/suppressor
	name = "Tłumik laserowy"
	desc = "Wycisza strzały broni microfusion."
	id = "microfusion_gun_attachment_suppressor"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 1000)
	build_path = /obj/item/microfusion_gun_attachment/barrel/suppressor

/datum/design/microfusion/attachment/honk
	name = "Bananiowy emiter fazowy"
	desc = "Lasery, które przewracają. Honk!"
	id = "microfusion_gun_attachment_honk"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/bananium = 1000)
	build_path = /obj/item/microfusion_gun_attachment/barrel/honk

/datum/design/microfusion/attachment/lance
	name = "Indukcyjna karetka lancy"
	desc = "Robi z MCR karabin wyborowy: mocne, szybkie strzały, ale ogromne ciepło i pobór energii."
	id = "microfusion_gun_attachment_lance"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 1000, /datum/material/plasma = 1000, /datum/material/bluespace = 1000)
	build_path = /obj/item/microfusion_gun_attachment/barrel/lance

/datum/design/microfusion/attachment/scatter
	name = "Rozpraszająca soczewka microfusion"
	desc = "Dzieli wiązkę na trzy."
	id = "microfusion_gun_attachment_scatter"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 1000, /datum/material/silver = 1000)
	build_path = /obj/item/microfusion_gun_attachment/barrel/scatter

/datum/design/microfusion/attachment/scattermax
	name = "Krystaliczna rozpraszająca soczewka microfusion"
	desc = "Dzieli wiązkę na siedem, kosztem odrzutu i energii."
	id = "microfusion_gun_attachment_scattermax"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 1000, /datum/material/silver = 1000)
	build_path = /obj/item/microfusion_gun_attachment/barrel/scatter/max

/datum/design/microfusion/attachment/superheat
	name = "Przegrzewacz emitera fazowego"
	desc = "Wiązki podpalają cele."
	id = "microfusion_gun_attachment_superheat"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 1000, /datum/material/plasma = 1000)
	build_path = /obj/item/microfusion_gun_attachment/barrel/superheat

/datum/design/microfusion/attachment/hellfire
	name = "Piekielny emiter"
	desc = "Szybsze wiązki niosące dodatkową falę ciepła."
	id = "microfusion_gun_attachment_hellfire"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 1000, /datum/material/plasma = 1000)
	build_path = /obj/item/microfusion_gun_attachment/barrel/hellfire

/datum/design/microfusion/attachment/repeater
	name = "Powtarzacz emitera fazowego"
	desc = "Broń strzela seriami po dwie wiązki."
	id = "microfusion_gun_attachment_repeater"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 1000, /datum/material/bluespace = 1000)
	build_path = /obj/item/microfusion_gun_attachment/barrel/repeater

/datum/design/microfusion/attachment/penetrator
	name = "Skupiony powtarzacz emitera fazowego"
	desc = "Serie wiązek przebijających pancerz, za cenę dużego poboru energii."
	id = "microfusion_gun_attachment_penetrator"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 1000, /datum/material/bluespace = 1000)
	build_path = /obj/item/microfusion_gun_attachment/barrel/repeater/penetrator

/datum/design/microfusion/attachment/xray
	name = "Kwantowy odwracacz fazy"
	desc = "Wiązki rentgenowskie przechodzące przez ściany."
	id = "microfusion_gun_attachment_xray"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 1000, /datum/material/uranium = 1000, /datum/material/bluespace = 1000)
	build_path = /obj/item/microfusion_gun_attachment/barrel/xray

/datum/design/microfusion/attachment/rgb
	name = "Spektrograf emitera fazowego"
	desc = "Pozwala ustawić kolor wiązki."
	id = "microfusion_gun_attachment_rgb"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 1000, /datum/material/gold = 1000)
	build_path = /obj/item/microfusion_gun_attachment/rgb

/datum/design/microfusion/attachment/camo_black
	name = "Czarna rama microfusion"
	desc = "Czarne malowanie MCR-01."
	id = "microfusion_gun_attachment_black_camo"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/gold = 1000)
	build_path = /obj/item/microfusion_gun_attachment/camo

/datum/design/microfusion/attachment/camo_nanotrasen
	name = "Rama microfusion marki Nanotrasen"
	desc = "Niebieskie malowanie MCR-01."
	id = "microfusion_gun_attachment_nt_camo"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/plasma = 1000)
	build_path = /obj/item/microfusion_gun_attachment/camo/nanotrasen

/datum/design/microfusion/attachment/camo_syndicate
	name = "Krwistoczerwona rama microfusion"
	desc = "Krwistoczerwone malowanie MCR-01."
	id = "microfusion_gun_attachment_syndi_camo"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/titanium = 1000)
	build_path = /obj/item/microfusion_gun_attachment/camo/syndicate

/datum/design/microfusion/attachment/camo_bananium
	name = "Bananiowa rama microfusion"
	desc = "MCR-01 pokryty bananium."
	id = "microfusion_gun_attachment_honk_camo"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/bananium = 1000)
	build_path = /obj/item/microfusion_gun_attachment/camo/honk

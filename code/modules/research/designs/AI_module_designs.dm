///////////////////////////////////
//////////AI Module Disks//////////
///////////////////////////////////

/datum/design/board/aicore
	name = "Projekt SI (rdzeń SI)"
	desc = "Pozwala zbudować płytki drukowane do nowych rdzeni SI."
	id = "aicore"
	build_path = /obj/item/circuitboard/aicore
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/safeguard_module
	name = "Projekt modułu (Ochrona)"
	desc = "Pozwala zbudować moduł SI „Ochrona”."
	id = "safeguard_module"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 2000, /datum/material/copper = 300)
	build_path = /obj/item/aiModule/supplied/safeguard
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/onehuman_module
	name = "Projekt modułu (Jeden człowiek)"
	desc = "Pozwala zbudować moduł SI „Jeden człowiek”."
	id = "onehuman_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 6000, /datum/material/copper = 300)
	build_path = /obj/item/aiModule/zeroth/oneHuman
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/protectstation_module
	name = "Projekt modułu (Chroń stację)"
	desc = "Pozwala zbudować moduł SI „Chroń stację”."
	id = "protectstation_module"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 2000, /datum/material/copper = 300)
	build_path = /obj/item/aiModule/supplied/protectStation
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/quarantine_module
	name = "Projekt modułu (Kwarantanna)"
	desc = "Pozwala zbudować moduł SI „Kwarantanna”."
	id = "quarantine_module"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 2000, /datum/material/copper = 300)
	build_path = /obj/item/aiModule/supplied/quarantine
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/oxygen_module
	name = "Projekt modułu (Tlen jest toksyczny dla ludzi)"
	desc = "Pozwala zbudować moduł SI „Tlen jest toksyczny dla ludzi”."
	id = "oxygen_module"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 2000, /datum/material/copper = 300)
	build_path = /obj/item/aiModule/supplied/oxygen
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/freeform_module
	name = "Projekt modułu (Prawo dowolne)"
	desc = "Pozwala zbudować moduł SI „Prawo dowolne”."
	id = "freeform_module"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 10000, /datum/material/copper = 300)//Custom inputs should be more expensive to get
	build_path = /obj/item/aiModule/supplied/freeform
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/reset_module
	name = "Projekt modułu (Reset)"
	desc = "Pozwala zbudować moduł SI „Reset”."
	id = "reset_module"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 2000, /datum/material/copper = 300)
	build_path = /obj/item/aiModule/reset
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/purge_module
	name = "Projekt modułu (Czystka)"
	desc = "Pozwala zbudować moduł SI „Czystka”."
	id = "purge_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/copper = 300)
	build_path = /obj/item/aiModule/reset/purge
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/remove_module
	name = "Projekt modułu (Usuń prawo)"
	desc = "Pozwala zbudować moduł SI „Usuń prawo”."
	id = "remove_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/copper = 300)
	build_path = /obj/item/aiModule/remove
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/freeformcore_module
	name = "Moduł rdzenia SI (Prawo dowolne)"
	desc = "Pozwala zbudować moduł rdzenia SI „Prawo dowolne”."
	id = "freeformcore_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 10000, /datum/material/copper = 300)//Ditto
	build_path = /obj/item/aiModule/core/freeformcore
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/asimov
	name = "Projekt modułu rdzenia (Asimov)"
	desc = "Pozwala zbudować moduł rdzenia SI „Asimov”."
	id = "asimov_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/copper = 300)
	build_path = /obj/item/aiModule/core/full/asimov
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/paladin_module
	name = "Projekt modułu rdzenia (P.A.L.A.D.I.N.)"
	desc = "Pozwala zbudować moduł rdzenia SI „P.A.L.A.D.I.N.”."
	id = "paladin_module"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/copper = 300)
	build_path = /obj/item/aiModule/core/full/paladin
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/tyrant_module
	name = "Projekt modułu rdzenia (T.Y.R.A.N.T.)"
	desc = "Pozwala zbudować moduł SI „T.Y.R.A.N.T.”."
	id = "tyrant_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/copper = 300)
	build_path = /obj/item/aiModule/core/full/tyrant
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/overlord_module
	name = "Projekt modułu rdzenia (Władca)"
	desc = "Pozwala zbudować moduł SI „Władca”."
	id = "overlord_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/copper = 300)
	build_path = /obj/item/aiModule/core/full/overlord
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/corporate_module
	name = "Projekt modułu rdzenia (Korporacyjne)"
	desc = "Pozwala zbudować moduł rdzenia SI „Korporacyjne”."
	id = "corporate_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/copper = 300)
	build_path = /obj/item/aiModule/core/full/corp
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/default_module
	name = "Projekt modułu rdzenia (Domyślne)"
	desc = "Pozwala zbudować domyślny moduł rdzenia SI."
	id = "default_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/copper = 300)
	build_path = /obj/item/aiModule/core/full/custom
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/dadbot_module
	name = "Projekt modułu rdzenia (DadBOT)"
	desc = "Pozwala zbudować moduł rdzenia SI „DadBOT”."
	id = "dadbot_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/copper = 300)
	build_path = /obj/item/aiModule/core/full/dadbot
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

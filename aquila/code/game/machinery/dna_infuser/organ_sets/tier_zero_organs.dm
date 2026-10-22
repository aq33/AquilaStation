// AQUILA - port z tgstation: organy żartobliwych zestawów tieru 0
// (fox_organs.dm, cechy jaszczurki i ćmy jako organy zewnętrzne, organy roślinne z podpeople)

/// lisie uszy - u nas nie ma osobnego sprite'a lisich uszu, więc rysują się jak kocie
/obj/item/organ/ears/cat/fox
	name = "lisie uszy"
	desc = "Wstydź się."
	damage_multiplier = 2

/// Organ zewnętrzny, który tylko dokłada cechę wyglądu (mutant_bodypart) gatunkowi właściciela.
/obj/item/organ/infuser_feature
	name = "zmutowana narośl"
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	zone = BODY_ZONE_HEAD
	infuser_external = TRUE
	/// klucz w dna.features i species.mutant_bodyparts
	var/feature_key
	/// domyślny wygląd, jeśli właściciel nie ma żadnego
	var/feature_value
	/// czy to my dodaliśmy część ciała
	var/added_bodypart = FALSE

/obj/item/organ/infuser_feature/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(owner != M || !ishuman(M))
		return
	var/mob/living/carbon/human/human_owner = M
	if(!human_owner.dna?.species || (feature_key in human_owner.dna.species.mutant_bodyparts))
		return
	if(!human_owner.dna.features[feature_key] || human_owner.dna.features[feature_key] == "None")
		human_owner.dna.features[feature_key] = feature_value
	human_owner.dna.species.mutant_bodyparts |= feature_key
	added_bodypart = TRUE
	human_owner.update_body()

/obj/item/organ/infuser_feature/Remove(mob/living/carbon/M, special = 0)
	if(added_bodypart && ishuman(M))
		var/mob/living/carbon/human/human_owner = M
		if(human_owner.dna?.species)
			human_owner.dna.species.mutant_bodyparts -= feature_key
			human_owner.update_body()
	added_bodypart = FALSE
	return ..()

/obj/item/organ/infuser_feature/lizard_horns
	name = "jaszczurze rogi"
	desc = "Para ozdobnych rogów. Ktoś za nimi nie tęskni."
	icon_state = "horns"
	slot = "horns"
	feature_key = "horns"
	feature_value = "Simple"

/obj/item/organ/infuser_feature/lizard_frills
	name = "jaszczurza kryza"
	desc = "Skórzana kryza, która kiedyś zdobiła czyjąś głowę."
	icon_state = "frills"
	slot = "frills"
	feature_key = "frills"
	feature_value = "Short"

/obj/item/organ/infuser_feature/lizard_snout
	name = "jaszczurzy pysk"
	desc = "Uciąć komuś pysk to nowy poziom bezczelności."
	icon_state = "snout"
	slot = "snout"
	feature_key = "snout"
	feature_value = "Round"

/obj/item/organ/infuser_feature/moth_antennae
	name = "czułki ćmy"
	desc = "Para puchatych czułków ćmy."
	icon_state = "antennae"
	slot = "moth_antennae"
	feature_key = "moth_antennae"
	feature_value = "Plain"

//-- organy roślinne (u nas podpeople nie mają własnych organów poza językiem) --//
/obj/item/organ/appendix/pod
	name = "roślinny wyrostek"
	desc = "Wyrostek z czegoś, co bardziej przypomina łodygę niż mięso."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "pod_appendix"

/obj/item/organ/appendix/pod/update_icon()
	if(inflamed)
		icon = 'icons/obj/surgery.dmi'
		icon_state = "appendixinflamed"
	else
		icon = 'aquila/icons/dna_infuser/organs.dmi'
		icon_state = "pod_appendix"

/obj/item/organ/ears/pod
	name = "roślinne uszy"
	desc = "Para zielonych, liściastych uszu."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "pod_ears"

/obj/item/organ/eyes/pod
	name = "roślinne oczy"
	desc = "Dwie zielone jagody, które jakimś cudem widzą."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "pod_eyes"

/obj/item/organ/heart/pod
	name = "roślinne serce"
	desc = "Serce pompujące coś, co bardziej przypomina sok niż krew."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "pod_heart"

/obj/item/organ/heart/pod/update_icon()
	icon_state = "pod_heart"

/obj/item/organ/liver/pod
	name = "roślinna wątroba"
	desc = "Zielona, włóknista wątroba."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "pod_liver"

/obj/item/organ/lungs/pod
	name = "roślinne płuca"
	desc = "Płuca o strukturze liścia."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "pod_lungs"

/obj/item/organ/stomach/pod
	name = "roślinny żołądek"
	desc = "Żołądek, który bardziej przypomina dzbanek rośliny mięsożernej."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "pod_stomach"

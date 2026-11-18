// AQUILA - kucharz zna przepis na głodny worek prochu (raport nsv_martwe_08, pkt 5).
// W NSV13 uczył go nsv13/code/modules/jobs/job_types/cook.dm, który nie jest w buildzie (zepsuta ścieżka procki),
// więc przepisu nikt nie znał. Worek działa jak dawniej: rośnie od jedzenia i potrafi pożreć karmiącego.
// Przy profesji, nie w stroju: /datum/outfit/job/cook noszą też KNPC i inne warianty.

/datum/job/cook/after_spawn(mob/living/H, mob/M, latejoin = FALSE)
	. = ..()
	H.mind?.teach_crafting_recipe(/datum/crafting_recipe/hungrypowder)

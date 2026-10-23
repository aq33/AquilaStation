// Port cybernetyki z Monkestation: implant HUD naukowego (fakehud/science).
// Działa jak gogle naukowe: skaner odczynników i skaner badawczy. Pominięty HUD patologiczny (brak TRAIT_VIRUS_SCANNER).

/obj/item/organ/cyberimp/eyes/hud/science
	name = "implant HUD naukowego"
	desc = "Wszczepy oczne, które pokazują dokładny skład odczynników i to, na co rozkładają się przedmioty w destruktorze."
	icon = 'aquila/icons/obj/cybernetics/implants.dmi'
	icon_state = "eye_implant_science"
	implant_overlay = null
	HUD_trait = TRAIT_REAGENT_SCANNER

/obj/item/organ/cyberimp/eyes/hud/science/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = FALSE)
	var/was_owner = owner == M
	. = ..()
	if(!was_owner && owner == M)
		M.research_scanner++

/obj/item/organ/cyberimp/eyes/hud/science/Remove(mob/living/carbon/M, special = 0)
	if(M && owner == M)
		M.research_scanner = max(M.research_scanner - 1, 0)
	return ..()

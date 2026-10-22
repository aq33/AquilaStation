// AQUILA - port z tgstation (code/datums/mutations/passive.dm)
// TRAIT_ADVANCEDTOOLUSER i TRAIT_LITERATE czyta rdzeń: /mob/proc/IsAdvancedToolUser(), /mob/proc/is_literate()
// i /mob/living/carbon/human/IsAdvancedToolUser() (AQUILA EDIT).

/datum/mutation/clever
	name = "Clever"
	desc = "The subject's intelligence level is raised to that of the average assistant."
	quality = POSITIVE
	instability = 25 // dorównuje sprzętowi na stacji
	text_gain_indication = "<span class='danger'>Czujesz się odrobinę mądrzejszy.</span>"
	text_lose_indication = "<span class='danger'>W głowie robi ci się trochę mętnie.</span>"
	mutation_traits = list(TRAIT_ADVANCEDTOOLUSER, TRAIT_LITERATE)

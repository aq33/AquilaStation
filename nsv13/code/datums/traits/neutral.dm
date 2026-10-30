/datum/quirk/spaceborn
	name = "Urodzony w kosmosie"
	desc = "Większość życia spędzasz w niskiej grawitacji i twoje ciało się do tego przystosowało. Wytrzymujesz bez tlenu dłużej niż większość ludzi, ale słabo znosisz duże przeciążenia."
	value = 0
	mob_trait = TRAIT_GFORCE_WEAKNESS
	human_only = TRUE
	gain_text = "<span class='notice'>Twoje ciało wydaje się ciężkie.</span>"
	lose_text = "<span class='notice'>Nie czujesz się już taki ciężki.</span>"
	medical_record_text = "Ciało pacjenta przystosowało się do środowisk o niskiej grawitacji."
	// Extra safety checks to make sure no one cheeses the multiplication somehow. Although ideally this trait shouldn't be removed
	var/og_oxmod = 1
	var/cached_oxmod = 1

/datum/quirk/spaceborn/add()
	var/mob/living/carbon/human/H = quirk_holder
	if(!istype(H) || (TRAIT_NOBREATH in H.dna.species.inherent_traits))
		qdel(src)
		return
	og_oxmod = H.physiology.oxy_mod
	H.physiology.oxy_mod *= 0.8
	cached_oxmod = H.physiology.oxy_mod

/datum/quirk/spaceborn/remove()
	if(!quirk_holder)
		return
	var/mob/living/carbon/human/H = quirk_holder
	if(H.physiology.oxy_mod == cached_oxmod)
		H.physiology.oxy_mod = og_oxmod
	else
		H.physiology.oxy_mod = initial(H.physiology.oxy_mod)

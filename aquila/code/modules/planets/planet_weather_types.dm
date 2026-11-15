// AQUILA - rodzaje pogody planet, port z Shiptesta (shiptest-ss13/Shiptest, AGPLv3): code/datums/weather/weather_types/
// rain.dm, snowfall.dm, hailstorm.dm, sandstorm.dm, shroud_storm.dm, nuclear_fallout.dm i snow_storm.dm. Nakładki
// w aquila/icons/effects/planet_weather.dmi (z Shiptesta, CC BY-SA 3.0). Działają tylko na planetach (probability = 0,
// planet_surface.dm wybiera je z weather_types typu planety).
// Różnice względem Shiptesta:
// - odmiany „blocking” nie zasłaniają widoku (bez opacity_in_main_stage), mają tylko gęstszą nakładkę;
// - deszcz gasi płonących (fire_suppression w planet_weather.dm), ale nie moczy (nie mamy wet_stacks);
// - opad radioaktywny napromieniowuje przez nasze SSradiation.irradiate zamiast rad_act(100);
// - burza elektryczna nie mnoży nakładki (multiply_blend_on_main_stage), syrena burzy piaskowej bez dźwięku (nie mamy).

/datum/weather/planet
	name = "pogoda planety"
	area_type = /area
	protect_indoors = TRUE
	barometer_predictable = TRUE
	probability = 0
	overlay_icon = 'aquila/icons/effects/planet_weather.dmi'

// Deszcze

/datum/weather/planet/rain
	name = "deszcz"
	desc = "Deszcz pada na powierzchnię planety."
	telegraph_message = "<span class='notice'>Nad głową zbierają się ciemne chmury, w powietrzu czuć wilgoć...</span>"
	telegraph_duration = 300
	weather_message = "<span class='notice'>Zaczyna padać deszcz...</span>"
	weather_overlay = "rain"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	end_duration = 100
	end_message = "<span class='notice'>Deszcz ustaje...</span>"
	overlay_alpha = 75
	aesthetic = TRUE
	fire_suppression = 6
	planet_sound_active_outside = /datum/looping_sound/planet_rain
	planet_sound_active_inside = /datum/looping_sound/planet_rain/indoors

/datum/weather/planet/rain/heavy
	name = "ulewa"
	desc = "Ulewny deszcz."
	telegraph_message = "<span class='notice'>Chmury nagle się zbiegają i pęka z nich deszcz...</span>"
	telegraph_overlay = "rain"
	weather_message = "<span class='notice'>Deszcz zamienia się w ulewę...</span>"
	weather_overlay = "storm"
	end_message = "<span class='notice'>Ulewa słabnie...</span>"
	end_overlay = "rain"
	fire_suppression = 8
	thunder_chance = 2
	planet_sound_active_outside = /datum/looping_sound/planet_rain/no_start
	planet_sound_active_inside = /datum/looping_sound/planet_rain/indoors
	planet_sound_weak_outside = /datum/looping_sound/planet_rain/weak
	planet_sound_weak_inside = /datum/looping_sound/planet_rain/weak/indoors

/datum/weather/planet/rain/heavy/storm
	name = "burza"
	desc = "Burza z deszczem i piorunami."
	weather_message = "<span class='warning'>Chmury czernieją, niebo zaczyna błyskać, a w dół bije grom!</span>"
	fire_suppression = 12
	thunder_chance = 10

/// Odmiana „blocking” z Shiptesta: gęsta nakładka bez zasłaniania widoku
/datum/weather/planet/rain/heavy/storm/severe
	name = "nawałnica"
	desc = "Potężna burza, w której prawie nic nie widać."
	telegraph_message = "<span class='notice'>Robi się mglisto, a chmury zapowiadają potężną burzę...</span>"
	telegraph_overlay = "smoke"
	weather_message = "<span class='userdanger'>Zaczyna lać jak z cebra! Prawie nic nie widać!</span>"
	weather_overlay = "rain_high"
	end_message = "<span class='notice'>Ulewa słabnie...</span>"
	end_overlay = "smoke"
	overlay_alpha = 255
	thunder_chance = 60

/// Sztorm bez końca nad wodnymi planetami karłowatymi
/datum/weather/planet/rain/heavy/storm/intense
	name = "sztorm"
	desc = "Sztorm z deszczem i piorunami, który nigdy nie mija."
	weather_overlay = "storm_very"
	overlay_alpha = 125
	thunder_chance = 20
	weather_color = "#a3daf7"
	weather_duration_lower = 420690
	weather_duration_upper = 420690
	fire_suppression = 16
	planet_sound_active_outside = /datum/looping_sound/planet_rain/storm
	planet_sound_active_inside = /datum/looping_sound/planet_rain/storm/indoors

/// Toksyczny deszcz: trucizna bez kasku i kombinezonu, płuca bez maski gazowej, oczy bez osłony
/datum/weather/planet/rain/toxic
	name = "toksyczny deszcz"
	desc = "Toksyczny deszcz pada na powierzchnię planety."
	telegraph_message = "<span class='danger'>Nad głową wiszą toksyczne chmury, w powietrzu czuć wilgoć. Załóż maskę gazową i dobrze się okryj.</span>"
	weather_message = "<span class='userdanger'>Zaczyna padać toksyczny deszcz!</span>"
	weather_overlay = "toxic_rain_low"
	overlay_alpha = 255
	aesthetic = FALSE
	fire_suppression = 0
	planet_sound_active_outside = /datum/looping_sound/planet_rain/no_start
	planet_sound_active_inside = /datum/looping_sound/planet_rain/indoors
	planet_sound_weak_outside = /datum/looping_sound/planet_rain/weak
	planet_sound_weak_inside = /datum/looping_sound/planet_rain/weak/indoors
	/// Siła trucizny na cykl
	var/toxic_power = 2

/datum/weather/planet/rain/toxic/weather_act(mob/living/living_mob)
	if(!iscarbon(living_mob))
		return
	var/mob/living/carbon/carbon = living_mob
	toxic_rain_face(carbon)
	toxic_rain_eyes(carbon)
	if(!ishuman(carbon))
		carbon.reagents?.add_reagent(/datum/reagent/toxin, toxic_power / 2)
		return
	var/mob/living/carbon/human/human = carbon
	if(!human.head)
		human.reagents?.add_reagent(/datum/reagent/toxin, toxic_power / 4)
	if(!human.wear_suit && !istype(human.wear_neck, /obj/item/clothing/neck/cloak))
		human.reagents?.add_reagent(/datum/reagent/toxin, toxic_power / 4)

/datum/weather/planet/rain/toxic/proc/toxic_rain_face(mob/living/carbon/living_mob)
	if(HAS_TRAIT(living_mob, TRAIT_NOBREATH) || living_mob.internal)
		return
	if(istype(living_mob.wear_mask, /obj/item/clothing/mask/gas))
		return
	living_mob.adjustOrganLoss(ORGAN_SLOT_LUNGS, toxic_power / 4)
	if(prob(45))
		living_mob.emote("cough")
		to_chat(living_mob, "<span class='userdanger'>Oddychanie boli!</span>")
		living_mob.adjustOxyLoss(1.5 * toxic_power)

/datum/weather/planet/rain/toxic/proc/toxic_rain_eyes(mob/living/carbon/living_mob)
	if(living_mob.is_eyes_covered() || istype(living_mob.wear_mask, /obj/item/clothing/mask/gas))
		return
	if(toxic_power / 2 - living_mob.get_eye_protection() < 0)
		return
	living_mob.adjustOrganLoss(ORGAN_SLOT_EYES, toxic_power / 2)
	if(prob(65))
		living_mob.emote("cry")
		to_chat(living_mob, "<span class='userdanger'>Oczy łzawią i strasznie pieką!</span>")
		living_mob.blur_eyes(10)

/datum/weather/planet/rain/toxic/heavy
	name = "toksyczna ulewa"
	desc = "Ulewa toksycznego deszczu."
	telegraph_message = "<span class='userdanger'>Toksyczne chmury nagle się zbiegają i pęka z nich deszcz. Załóż maskę gazową i dobrze się okryj.</span>"
	telegraph_overlay = "toxic_rain_low"
	weather_message = "<span class='userdanger'>Leje toksyczny deszcz!</span>"
	weather_overlay = "toxic_rain"
	end_message = "<span class='notice'>Ulewa słabnie...</span>"
	end_overlay = "rain"
	thunder_chance = 10
	toxic_power = 10

/datum/weather/planet/rain/toxic/heavy/severe
	name = "toksyczna nawałnica"
	desc = "Potężna toksyczna burza, w której prawie nic nie widać."
	telegraph_message = "<span class='userdanger'>Robi się mglisto, a toksyczne chmury zapowiadają potężną burzę. Załóż maskę gazową i dobrze się okryj: bez ochrony taka burza zabija.</span>"
	telegraph_overlay = "smoke"
	weather_message = "<span class='userdanger'>Leje toksyczny deszcz! Prawie nic nie widać!</span>"
	end_overlay = "smoke"
	thunder_chance = 60
	toxic_power = 20

// Śnieg i grad

/datum/weather/planet/snowfall
	name = "opady śniegu"
	desc = "Nieszkodliwe płatki śniegu sypią się na powierzchnię."
	telegraph_message = "<span class='notice'>Unoszące się płatki śniegu zaczynają przyprószać okolicę...</span>"
	telegraph_duration = 300
	telegraph_overlay = "snowfall_light"
	weather_message = "<span class='notice'>Z nieba sypie miękki, puszysty śnieg i okrywa powierzchnię...</span>"
	weather_overlay = "snowfall_med"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	end_duration = 100
	end_message = "<span class='notice'>Śnieg przestaje padać...</span>"
	aesthetic = TRUE

/datum/weather/planet/snowfall/heavy
	name = "śnieżyca"
	desc = "Z nieba sypią się zwały śniegu."
	telegraph_message = "<span class='notice'>Nagle zaczyna mocno sypać śnieg...</span>"
	telegraph_overlay = "snowfall_med"
	weather_message = "<span class='danger'>Opady zamieniają się w śnieżycę...</span>"
	weather_overlay = "snowfall_heavy"
	end_overlay = "snowfall_light"
	end_message = "<span class='notice'>Śnieżyca słabnie...</span>"
	immunity_type = "snow"
	aesthetic = FALSE
	thunder_chance = 2
	planet_sound_active_outside = /datum/looping_sound/planet_wind
	planet_sound_active_inside = /datum/looping_sound/planet_wind/indoors
	planet_sound_weak_outside = /datum/looping_sound/planet_wind/indoors
	planet_sound_weak_inside = /datum/looping_sound/planet_wind/indoors

/datum/weather/planet/snowfall/heavy/weather_act(mob/living/living_mob)
	living_mob.adjust_bodytemperature(-rand(2, 4), 243)

/datum/weather/planet/hailstorm
	name = "gradobicie"
	desc = "Srogi grad okłada każdego, kto dał się złapać pod gołym niebem."
	telegraph_message = "<span class='danger'>Zbierają się ciemne chmury, a płatki śniegu zaczynają przyprószać okolicę...</span>"
	telegraph_duration = 300
	telegraph_overlay = "snowfall_light"
	weather_message = "<span class='userdanger'><i>Z nieba zaczyna sypać grad! Znajdź schronienie!</i></span>"
	weather_overlay = "hail"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	end_duration = 100
	end_message = "<span class='notice'>Grad ustaje, na zewnątrz powinno już być bezpiecznie.</span>"
	immunity_type = "snow"
	thunder_chance = 4
	planet_sound_active_outside = /datum/looping_sound/planet_wind
	planet_sound_active_inside = /datum/looping_sound/planet_wind/indoors
	planet_sound_weak_outside = /datum/looping_sound/planet_wind/indoors
	planet_sound_weak_inside = /datum/looping_sound/planet_wind/indoors

/datum/weather/planet/hailstorm/weather_act(mob/living/living_mob)
	if(!ishuman(living_mob) && !(living_mob.mind))
		return // Jak w Shiptest: grad nie męczy fauny
	living_mob.adjust_bodytemperature(-rand(3, 6), 243)
	living_mob.adjustBruteLoss(rand(2, 4))

/// Burza śnieżna z Lavalandu/Snowdina w wersji planetarnej: ta sama burza z nakładką i dźwiękami Shiptesta
/datum/weather/snow_storm/planet
	probability = 0
	area_type = /area
	protect_indoors = TRUE
	telegraph_overlay = "snowfall_light"
	end_overlay = "snowfall_light"
	overlay_icon = 'aquila/icons/effects/planet_weather.dmi'
	planet_sound_active_outside = /datum/looping_sound/active_outside_ashstorm
	planet_sound_active_inside = /datum/looping_sound/active_inside_ashstorm
	planet_sound_weak_outside = /datum/looping_sound/weak_outside_ashstorm
	planet_sound_weak_inside = /datum/looping_sound/weak_inside_ashstorm

/datum/weather/snow_storm/planet/weather_act(mob/living/living_mob)
	living_mob.adjust_bodytemperature(-rand(2, 4))

// Piasek i pył

/// Burza piaskowa: bez zasłoniętych ust dusi piasek
/datum/weather/planet/sandstorm
	name = "burza piaskowa"
	desc = "Wiatr niesie fale piasku."
	telegraph_message = "<span class='danger'>Wiatr przyspiesza i po okolicy zaczynają sunąć fale piasku...</span>"
	telegraph_duration = 300
	telegraph_overlay = "dust"
	weather_message = "<span class='userdanger'><i>Nadciąga burza piaskowa! Znajdź schronienie!</i></span>"
	weather_overlay = "sandstorm"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	end_duration = 100
	end_message = "<span class='notice'>Burza się rozwiewa.</span>"
	end_overlay = "dust"
	immunity_type = "ash"
	planet_sound_active_outside = /datum/looping_sound/active_outside_ashstorm
	planet_sound_active_inside = /datum/looping_sound/active_inside_ashstorm
	planet_sound_weak_outside = /datum/looping_sound/weak_outside_ashstorm
	planet_sound_weak_inside = /datum/looping_sound/weak_inside_ashstorm

/datum/weather/planet/sandstorm/weather_act(mob/living/living_mob)
	if(!iscarbon(living_mob))
		return
	var/mob/living/carbon/carbon = living_mob
	if(HAS_TRAIT(carbon, TRAIT_NOBREATH) || carbon.is_mouth_covered())
		return
	carbon.adjustOxyLoss(1.5)
	if(prob(10))
		carbon.emote("cough")

/datum/weather/planet/sandstorm/desert
	weather_overlay = "sandstorm-sand"

/// Ostra burza piaskowa planet skalistych: piasek rani, a bez zasłoniętych ust mocniej dusi
/datum/weather/planet/sandstorm/rockplanet
	name = "ostra burza piaskowa"
	desc = "Gruby piasek niesiony huraganowym wiatrem."
	telegraph_message = "<span class='userdanger'>Nad horyzontem wznosi się chmura pyłu i szybko się zbliża!</span>"
	telegraph_overlay = "dust_med"
	weather_message = "<span class='userdanger'><i>Ostry piasek i wiatr smagają cię bez litości! Wracaj do środka!</i></span>"
	weather_overlay = "dust_high"
	end_message = "<span class='notice'>Wrzeszczący wiatr zmiata resztki piasku i przechodzi w zwykły szmer. Na zewnątrz powinno już być bezpiecznie.</span>"
	end_overlay = "dust_low"

/datum/weather/planet/sandstorm/rockplanet/weather_act(mob/living/living_mob)
	if(!iscarbon(living_mob))
		return
	var/mob/living/carbon/carbon = living_mob
	carbon.adjustBruteLoss(6)
	to_chat(carbon, "<span class='danger'>Gruby piasek okłada cię ze wszystkich stron!</span>")
	if(HAS_TRAIT(carbon, TRAIT_NOBREATH) || carbon.is_mouth_covered())
		return
	carbon.adjustOxyLoss(3.5)
	if(prob(10))
		carbon.emote("cough")

/datum/weather/planet/sandstorm/rockplanet/harmless
	name = "opad pyłu"
	desc = "Przechodząca burza piaskowa przysypuje okolicę pyłem."
	telegraph_message = "<span class='notice'>Wiatr się wzmaga i podrywa piasek z gruntu.</span>"
	telegraph_overlay = "dust_low"
	weather_message = "<span class='notice'>Wokół ciebie łagodnie opada piasek, jak dziwaczny śnieg.</span>"
	weather_overlay = "dust_med"
	end_message = "<span class='notice'>Opad pyłu słabnie i ustaje. Pod stopami kolejna warstwa piasku.</span>"
	end_overlay = "dust_low"
	aesthetic = TRUE

/// Burza elektryczna mglistych planet: porażenia i impulsy elektromagnetyczne
/datum/weather/planet/shroud_storm
	name = "burza elektryczna"
	desc = "Wyładowania elektryczne w gęstej mgle."
	telegraph_message = "<span class='danger'>W oddali słychać grzmoty, powietrze naelektryzowane, wiatr zaczyna się wzmagać...</span>"
	telegraph_duration = 300
	telegraph_overlay = "electric_ash"
	weather_message = "<span class='userdanger'><i>Nadciąga burza elektryczna! Znajdź schronienie!</i></span>"
	weather_overlay = "electric_storm"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	end_duration = 100
	end_message = "<span class='notice'>Burza się rozwiewa.</span>"
	end_overlay = "electric_ash"
	immunity_type = "ash"
	thunder_chance = 14
	planet_sound_active_outside = /datum/looping_sound/planet_wind
	planet_sound_active_inside = /datum/looping_sound/planet_wind/indoors
	planet_sound_weak_outside = /datum/looping_sound/planet_wind/indoors
	planet_sound_weak_inside = /datum/looping_sound/planet_wind/indoors

/datum/weather/planet/shroud_storm/weather_act(mob/living/living_mob)
	if(!ishuman(living_mob) && !(living_mob.mind))
		return
	if(prob(10))
		living_mob.electrocute_act(rand(5, 20), "burza", 1, TRUE)
	if(prob(10))
		empulse(living_mob, 0, 3)

/// Opad radioaktywny planet-wysypisk (w Shiptest przeniesiony z NSV)
/datum/weather/planet/fallout
	name = "opad radioaktywny"
	desc = "Wszędzie opada napromieniowany pył."
	telegraph_duration = 20 SECONDS
	telegraph_message = "<span class='boldwarning'>Powietrze nagle robi się pyliste...</span>"
	telegraph_overlay = "fallout"
	weather_message = "<span class='userdanger'><i>Spada na ciebie fala gorącego popiołu.</i></span>"
	weather_overlay = "snowfall_heavy"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_color = "green"
	weather_sound = 'aquila/sound/weather/falloutwind.ogg'
	end_duration = 100
	end_message = "<span class='notice'>Popiół przestaje opadać.</span>"
	immunity_type = "rad"

/datum/weather/planet/fallout/weather_act(mob/living/living_mob)
	if(HAS_TRAIT(living_mob, TRAIT_RADIMMUNE))
		return
	if(SSradiation.irradiate(living_mob, intensity = rand(1, 5)) && prob(10))
		to_chat(living_mob, "<span class='notice'>Czujesz w ustach metaliczny posmak.</span>")

/datum/weather/planet/fallout/dust
	name = "burza pyłowa"
	desc = "Gęsty pył niesiony silnym, ale nieszkodliwym wiatrem."
	weather_message = "<span class='notice'>Przez okolicę przetacza się fala pylistego powietrza.</span>"
	weather_overlay = "dust"
	weather_color = null
	weather_sound = null
	end_message = "<span class='notice'>Pył przestaje wiać.</span>"
	aesthetic = TRUE

/datum/weather/snow_storm
	name = "burza śnieżna"
	desc = "Srogie zamiecie przetaczają się po powierzchni tej arktycznej planety i zasypują każde miejsce, które stanie im na drodze."
	probability = 90

	telegraph_message = "<span class='warning'>Unoszące się płatki śniegu zaczynają przyprószać okolicę..</span>"
	telegraph_duration = 300
	telegraph_overlay = "light_snow"

	weather_message = "<span class='userdanger'><i>Zrywa się porywisty wiatr, a z nieba zaczyna sypać gęsty śnieg! Znajdź schronienie!</i></span>"
	weather_overlay = "snow_storm"
	weather_duration_lower = 600
	weather_duration_upper = 1500

	end_duration = 100
	end_message = "<span class='boldannounce'>Śnieżyca słabnie, na zewnątrz powinno już być bezpiecznie.</span>"

	area_type = /area/awaymission/snowdin/outside
	target_trait = ZTRAIT_AWAY

	immunity_type = "snow"

	barometer_predictable = TRUE


/datum/weather/snow_storm/weather_act(mob/living/L)
	L.adjust_bodytemperature(-rand(5,15))


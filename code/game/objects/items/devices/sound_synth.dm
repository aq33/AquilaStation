/*
        Ported from /vg/station:
        https://github.com/vgstation-coders/vgstation13/blob/Bleeding-Edge/code/game/objects/items/devices/sound_synth.dm
*/

/obj/item/soundsynth
    name = "syntezator dźwięków"
    desc = "Urządzenie, które potrafi wytwarzać dźwięki."
    icon = 'icons/obj/radio.dmi'
    icon_state = "radio"
    item_state = "radio"
    w_class = WEIGHT_CLASS_TINY
    siemens_coefficient = 1

    var/tmp/spam_flag = 0 //To prevent mashing the button to cause annoyance like a huge idiot.
    var/selected_sound = "sound/items/bikehorn.ogg"
    var/shiftpitch = 1
    var/volume = 50

    var/list/sound_list = list( //How I would like to add tabbing to make this not as messy, but BYOND doesn't like that.
    "Honk" = "selected_sound=sound/items/bikehorn.ogg&shiftpitch=1&volume=50",
    "Oklaski" = "selected_sound=sound/effects/applause.ogg&shiftpitch=1&volume=65",
    "Śmiech" = "selected_sound=sound/effects/laughtrack.ogg&shiftpitch=1&volume=65",
    "Rimshot" = "selected_sound=sound/effects/rimshot.ogg&shiftpitch=1&volume=65",
    "Puzon" = "selected_sound=sound/misc/sadtrombone.ogg&shiftpitch=1&volume=50",
    "Trąbka pneumatyczna" = "selected_sound=sound/items/airhorn.ogg&shiftpitch=1&volume=50",
    "Alarm" = "selected_sound=sound/effects/alert.ogg&shiftpitch=1&volume=50",
    "Bum" = "selected_sound=sound/effects/explosion1.ogg&shiftpitch=1&volume=50",
    "Bum z daleka" = "selected_sound=sound/effects/explosionfar.ogg&shiftpitch=1&volume=50",
    "Bąbelki" = "selected_sound=sound/effects/bubbles.ogg&shiftpitch=1&volume=50",
    "Odliczanie" = "selected_sound=sound/ambience/countdown.ogg&shiftpitch=0&volume=55",
    "Upiorny szept" = "selected_sound=sound/hallucinations/turn_around1.ogg&shiftpitch=1&volume=50",
    "Ding" = "selected_sound=sound/machines/ding.ogg&shiftpitch=1&volume=50",
    "Bwoink" = "selected_sound=sound/effects/adminhelp.ogg&shiftpitch=1&volume=50",
    "Podwójne piknięcie" = "selected_sound=sound/machines/twobeep.ogg&shiftpitch=1&volume=50",
    "Spłukiwanie" = "selected_sound=sound/machines/disposalflush.ogg&shiftpitch=1&volume=40",
    "Kawaii" = "selected_sound=sound/ai/default/animes.ogg&shiftpitch=0&volume=60",
    "Uruchomienie" = "selected_sound=sound/mecha/nominal.ogg&shiftpitch=0&volume=50",
    "Odgłosy spawania" = "selected_sound=sound/items/welder.ogg&shiftpitch=1&volume=55",
    "Krótki gwizdek suwakowy" = "selected_sound=sound/effects/slide_whistle_short.ogg&shiftpitch=1&volume=50",
    "Długi gwizdek suwakowy" = "selected_sound=sound/effects/slide_whistle_long.ogg&shiftpitch=1&volume=50",
    "YEET" = "selected_sound=sound/effects/yeet.ogg&shiftpitch=1&volume=50",
    "Zatrzymanie czasu" = "selected_sound=sound/magic/timeparadox2.ogg&shiftpitch=0&volume=80",
    "Klik" = "selected_sound=sound/machines/click.ogg&shiftpitch=0&volume=80",
    "Buczenie" = "selected_sound=sound/effects/audience-boo.ogg&shiftpitch=0&volume=80",
    "Rozczulenie" = "selected_sound=sound/effects/audience-aww.ogg&shiftpitch=0&volume=80",
    "Westchnienia" = "selected_sound=sound/effects/audience-gasp.ogg&shiftpitch=0&volume=80",
    "Zachwyty" = "selected_sound=sound/effects/audience-ooh.ogg&shiftpitch=0&volume=80"
    )

/obj/item/soundsynth/verb/pick_sound()
    set category = "Object"
    set name = "Select Sound Playback"
    var/thesoundthatwewant = input("Wybierz dźwięk:", null) as null|anything in sound_list
    if(!thesoundthatwewant)
        return
    to_chat(usr, "Odtwarzany dźwięk ustawiony na: [thesoundthatwewant]!")
    var/list/assblast = params2list(sound_list[thesoundthatwewant])
    selected_sound = assblast["selected_sound"]
    shiftpitch = text2num(assblast["shiftpitch"])
    volume = text2num(assblast["volume"])

/obj/item/soundsynth/attack_self(mob/user as mob)
    if(spam_flag + 2 SECONDS < world.timeofday)
        playsound(src, selected_sound, volume, shiftpitch)
        spam_flag = world.timeofday

/obj/item/soundsynth/AltClick(mob/living/carbon/user)
	pick_sound()

/obj/item/soundsynth/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
    if(M == user)
        pick_sound()
    else if(spam_flag + 2 SECONDS < world.timeofday)
        M.playsound_local(get_turf(src), selected_sound, volume, shiftpitch)
        spam_flag = world.timeofday
        //to_chat(M, selected_sound) //this doesn't actually go to their chat very much at all.

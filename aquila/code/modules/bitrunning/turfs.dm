/turf/open/indestructible/bitrunning_transport
	name = "podłoga z obwodami"
	desc = "Wygląda na skomplikowaną. W podłodze widać biegnące obwody."
	icon = 'aquila/icons/turf/bitrunning.dmi'
	icon_state = "bitrunning"
	baseturfs = /turf/open/indestructible/bitrunning_transport

/turf/closed/indestructible/binary
	name = "rozdarcie w tkance rzeczywistości"
	icon = 'icons/turf/floors.dmi'
	icon_state = "binary"

/// tg baseturf_helper/virtual_domain: pod turfy domeny wstawia binarny bazowy turf
/obj/effect/baseturf_helper/virtual_domain
	name = "edytor bazowego turfu domeny wirtualnej"
	baseturf = /turf/open/indestructible/binary

/obj/item/radio/headset/headset_bridge
	name = "słuchawki radiowe mostka"
	desc = "Słuchawki dla tych, którzy myślą, że mają władzę, choć jej nie mają."
	icon_state = "com_headset"
	keyslot = new /obj/item/encryptionkey/bridge_staff

/obj/item/encryptionkey/bridge_staff
	name = "klucz szyfrujący oficera pokładowego"
	icon_state = "hop_cypherkey"
	channels = list(RADIO_CHANNEL_COMMAND = 1)

const_value set 2
	const GOLDENRODHARBOR_FISHER
	const GOLDENRODHARBOR_POKE_BALL
	const GOLDENRODHARBOR_ROCKET
	const GOLDENRODHARBOR_COOLTRAINER_F
	const GOLDENRODHARBOR_POKEFAN_M
	const GOLDENRODHARBOR_MAGIKARP
	const GOLDENRODHARBOR_YOUNGSTER
	const GOLDENRODHARBOR_JACQUES

GoldenrodHarbor_MapScriptHeader:
.MapTriggers:
	db 0

.MapCallbacks:
	db 0

GoldenrodHarborFisherScript:
	faceplayer
	opentext
	checkevent EVENT_LISTENED_TO_HYPER_VOICE_INTRO
	iftrue GoldenrodHarborTutorHyperVoiceScript
	writetext GoldenrodHarborFisherText
	waitbutton
	setevent EVENT_LISTENED_TO_HYPER_VOICE_INTRO
GoldenrodHarborTutorHyperVoiceScript:
	writetext Text_GoldenrodHarborTutorHyperVoice
	waitbutton
	checkitem SILVER_LEAF
	iffalse .NoSilverLeaf
	writetext Text_GoldenrodHarborTutorQuestion
	yesorno
	iffalse .TutorRefused
	writebyte HYPER_VOICE
	writetext Text_GoldenrodHarborTutorClear
	special Special_MoveTutor
	if_equal $0, .TeachMove
.TutorRefused
	writetext Text_GoldenrodHarborTutorRefused
	waitbutton
	closetext
	end

.NoSilverLeaf
	writetext Text_GoldenrodHarborTutorNoSilverLeaf
	waitbutton
	closetext
	end

.TeachMove
	takeitem SILVER_LEAF
	writetext Text_GoldenrodHarborTutorTaught
	waitbutton
	closetext
	end

GoldenrodHarborCooltrainerfScript:
	faceplayer
	opentext
	writetext GoldenrodHarborCooltrainerfText
	waitbutton
	pokemart MARTTYPE_STANDARD, MART_GOLDENROD_HARBOR
	closetext
	end

GoldenrodHarborMagikarpScript:
	jumptextfaceplayer GoldenrodHarborMagikarpText

GoldenrodHarborPokefanmScript:
	faceplayer
	opentext
	writetext GoldenrodHarborDollVendorText
.Start:
	special PlaceMoneyTopRight
	loadmenudata .MenuData
	verticalmenu
	closewindow
	if_equal $1, .MagikarpDoll
	if_equal $2, .TentacoolDoll
	if_equal $3, .ShellderDoll
	closetext
	end

.MagikarpDoll:
	checkmoney $0, 1200
	if_equal $2, .NotEnoughMoney
	checkevent EVENT_DECO_MAGIKARP_DOLL
	iftrue .AlreadyBought
	takemoney $0, 1200
	setevent EVENT_DECO_MAGIKARP_DOLL
	writetext GoldenrodHarborMagikarpDollText
	playsound SFX_TRANSACTION
	waitbutton
	writetext GoldenrodHarborMagikarpDollSentText
	waitbutton
	jump .Start

.TentacoolDoll:
	checkmoney $0, 2400
	if_equal $2, .NotEnoughMoney
	checkevent EVENT_DECO_TENTACOOL_DOLL
	iftrue .AlreadyBought
	takemoney $0, 2400
	setevent EVENT_DECO_TENTACOOL_DOLL
	writetext GoldenrodHarborTentacoolDollText
	playsound SFX_TRANSACTION
	waitbutton
	writetext GoldenrodHarborTentacoolDollSentText
	waitbutton
	jump .Start

.ShellderDoll:
	checkmoney $0, 3600
	if_equal $2, .NotEnoughMoney
	checkevent EVENT_DECO_SHELLDER_DOLL
	iftrue .AlreadyBought
	takemoney $0, 3600
	setevent EVENT_DECO_SHELLDER_DOLL
	writetext GoldenrodHarborShellderDollText
	playsound SFX_TRANSACTION
	waitbutton
	writetext GoldenrodHarborShellderDollSentText
	waitbutton
	jump .Start

.NotEnoughMoney:
	writetext GoldenrodHarborNoMoneyText
	waitbutton
	jump .Start

.AlreadyBought:
	writetext GoldenrodHarborAlreadyBoughtText
	waitbutton
	jump .Start

.MenuData:
	db $40 ; flags
	db 02, 00 ; start coords
	db 11, 19 ; end coords
	dw .MenuData2
	db 1 ; default option

.MenuData2:
	db $80 ; flags
	db 4 ; items
	db "Magikarp    ¥1200@"
	db "Tentacool   ¥2400@"
	db "Shellder    ¥3600@"
	db "Cancel@"

GoldenrodHarborYoungsterScript:
	faceplayer
	opentext
	writetext GoldenrodHarborPlantVendorText
.Start:
	special PlaceMoneyTopRight
	loadmenudata .MenuData
	verticalmenu
	closewindow
	if_equal $1, .MagnaPlant
	if_equal $2, .TropicPlant
	if_equal $3, .JumboPlant
	closetext
	end

.MagnaPlant:
	checkmoney $0, 5400
	if_equal $2, .NotEnoughMoney
	checkevent EVENT_DECO_PLANT_1
	iftrue .AlreadyBought
	takemoney $0, 5400
	setevent EVENT_DECO_PLANT_1
	writetext GoldenrodHarborMagnaPlantText
	playsound SFX_TRANSACTION
	waitbutton
	writetext GoldenrodHarborMagnaPlantSentText
	waitbutton
	jump .Start

.TropicPlant:
	checkmoney $0, 8600
	if_equal $2, .NotEnoughMoney
	checkevent EVENT_DECO_PLANT_2
	iftrue .AlreadyBought
	takemoney $0, 8600
	setevent EVENT_DECO_PLANT_2
	writetext GoldenrodHarborTropicPlantText
	playsound SFX_TRANSACTION
	waitbutton
	writetext GoldenrodHarborTropicPlantSentText
	waitbutton
	jump .Start

.JumboPlant:
	checkmoney $0, 10800
	if_equal $2, .NotEnoughMoney
	checkevent EVENT_DECO_PLANT_3
	iftrue .AlreadyBought
	takemoney $0, 10800
	setevent EVENT_DECO_PLANT_3
	writetext GoldenrodHarborJumboPlantText
	playsound SFX_TRANSACTION
	waitbutton
	writetext GoldenrodHarborJumboPlantSentText
	waitbutton
	jump .Start

.NotEnoughMoney:
	writetext GoldenrodHarborNoMoneyText
	waitbutton
	jump .Start

.AlreadyBought:
	writetext GoldenrodHarborAlreadyBoughtText
	waitbutton
	jump .Start

.MenuData:
	db $40 ; flags
	db 02, 00 ; start coords
	db 11, 19 ; end coords
	dw .MenuData2
	db 1 ; default option

.MenuData2:
	db $80 ; flags
	db 4 ; items
	db "Magna P.    ¥5400@"
	db "Tropic P.   ¥8600@"
	db "Jumbo P.   ¥10800@"
	db "Cancel@"

Jacques:
	faceplayer
	opentext
	trade $6
	waitbutton
	closetext
	end

GoldenrodHarborStarPiece:
	itemball STAR_PIECE

GoldenrodHarborSign:
	jumptext GoldenrodHarborSignText

GoldenrodHarborCrateSign:
	jumptext GoldenrodHarborCrateSignText

GoldenrodHarborFisherText:
	text "If you're fishing,"
	line "you have to be"

	para "quiet so you don't"
	line "scare the #mon."

	para "But to be heard"
	line "over the waves,"

	para "you have to say"
	line "things LOUD!"
	done

Text_GoldenrodHarborTutorHyperVoice:
	text "I can teach your"
	line "#mon how to"

	para "use Hyper Voice"
	line "for a Silver Leaf."
	done

Text_GoldenrodHarborTutorNoSilverLeaf:
	text "You don't have a"
	line "Silver Leaf!"
	done

Text_GoldenrodHarborTutorQuestion:
	text "Should I teach"
	line "your #mon"
	cont "Hyper Voice?"
	done

Text_GoldenrodHarborTutorRefused:
	text "Okay then."
	done

Text_GoldenrodHarborTutorClear:
	text ""
	done

Text_GoldenrodHarborTutorTaught:
	text "Now your #mon"
	line "knows how to use"
	cont "Hyper Voice!"
	done

GoldenrodHarborCooltrainerfText:
	text "I picked up some"
	line "rare items abroad!"
	done

GoldenrodHarborMagikarpText:
	text "This is a Fish"
	line "#mon! Huh?"

	para "It's only a doll…"
	done

GoldenrodHarborDollVendorText:
	text "Welcome! I have"
	line "adorable aquatic"
	cont "dolls for sale."
	done

GoldenrodHarborMagikarpDollText:
	text "<PLAYER> bought"
	line "Magikarp Doll."
	done

GoldenrodHarborMagikarpDollSentText:
	text "Magikarp Doll"
	line "was sent home."
	done

GoldenrodHarborTentacoolDollText:
	text "<PLAYER> bought"
	line "Tentacool Doll."
	done

GoldenrodHarborTentacoolDollSentText:
	text "Tentacool Doll"
	line "was sent home."
	done

GoldenrodHarborShellderDollText:
	text "<PLAYER> bought"
	line "Shellder Doll."
	done

GoldenrodHarborShellderDollSentText:
	text "Shellder Doll"
	line "was sent home."
	done

GoldenrodHarborNoMoneyText:
	text "You can't afford"
	line "that!"
	done

GoldenrodHarborAlreadyBoughtText:
	text "You already have"
	line "that!"
	done

GoldenrodHarborPlantVendorText:
	text "Welcome! I have"
	line "a selection of"

	para "exotic plants to"
	line "adorn your home."
	done

GoldenrodHarborMagnaPlantText:
	text "<PLAYER> bought"
	line "Magna Plant."
	done

GoldenrodHarborMagnaPlantSentText:
	text "Magna Plant"
	line "was sent home."
	done

GoldenrodHarborTropicPlantText:
	text "<PLAYER> bought"
	line "Tropic Plant."
	done

GoldenrodHarborTropicPlantSentText:
	text "Tropic Plant"
	line "was sent home."
	done

GoldenrodHarborJumboPlantText:
	text "<PLAYER> bought"
	line "Jumbo Plant."
	done

GoldenrodHarborJumboPlantSentText:
	text "Jumbo Plant"
	line "was sent home."
	done

GoldenrodHarborSignText:
	text "Goldenrod Harbor"
	done

GoldenrodHarborCrateSignText:
	text "A crate full of"
	line "rare items!"
	done

GoldenrodHarbor_MapEventHeader:
	; filler
	db 0, 0

.Warps:
	db 0

.XYTriggers:
	db 0

.Signposts:
	db 2
	signpost 19, 23, SIGNPOST_READ, GoldenrodHarborSign
	signpost 15, 24, SIGNPOST_READ, GoldenrodHarborCrateSign

.PersonEvents:
	db 8
	person_event SPRITE_FISHER, 7, 11, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, (1 << 3) | PAL_OW_BLUE, PERSONTYPE_SCRIPT, 0, GoldenrodHarborFisherScript, -1
	person_event SPRITE_POKE_BALL, 8, 7, SPRITEMOVEDATA_ITEM_TREE, 0, 0, -1, -1, 0, PERSONTYPE_ITEMBALL, 0, GoldenrodHarborStarPiece, EVENT_GOLDENROD_HARBOR_STAR_PIECE
	person_event SPRITE_ROCKET, 16, 32, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, PERSONTYPE_SCRIPT, 0, ObjectEvent, EVENT_GOLDENROD_CITY_ROCKET_SCOUT
	person_event SPRITE_COOLTRAINER_F, 15, 23, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, (1 << 3) | PAL_OW_GREEN, PERSONTYPE_SCRIPT, 0, GoldenrodHarborCooltrainerfScript, -1
	person_event SPRITE_POKEFAN_M, 15, 18, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, (1 << 3) | PAL_OW_RED, PERSONTYPE_SCRIPT, 0, GoldenrodHarborPokefanmScript, -1
	person_event SPRITE_MAGIKARP, 15, 17, SPRITEMOVEDATA_ITEM_TREE, 0, 0, -1, -1, (1 << 3) | PAL_OW_RED, PERSONTYPE_SCRIPT, 0, GoldenrodHarborMagikarpScript, -1
	person_event SPRITE_YOUNGSTER, 15, 12, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, (1 << 3) | PAL_OW_GREEN, PERSONTYPE_SCRIPT, 0, GoldenrodHarborYoungsterScript, -1
	person_event SPRITE_FISHER, 21, 10, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, (1 << 3) | PAL_OW_BLUE, PERSONTYPE_SCRIPT, 0, Jacques, -1

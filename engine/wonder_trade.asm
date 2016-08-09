WonderTrade::
	ld hl, .Text_WonderTradeQuestion
	call PrintText
	call YesNoBox
	ret c

	ld hl, .Text_WonderTradePrompt
	call PrintText

	ld b, 6
	callba SelectTradeOrDaycareMon
	ret c

	ld hl, PartyMonNicknames
	ld bc, PKMN_NAME_LENGTH
	call Trade_GetAttributeOfCurrentPartymon
	ld de, StringBuffer1
	call CopyTradeName
	ld hl, .Text_WonderTradeConfirm
	call PrintText
	call YesNoBox
	ret c

	ld hl, .Text_WonderTradeSetup
	call PrintText

	call DoWonderTrade

	ld hl, .Text_WonderTradeReady
	call PrintText

	call DisableSpriteUpdates
	predef TradeAnimation
	call ReturnToMapWithSpeechTextbox

	ld hl, .Text_WonderTradeComplete
	call PrintText

	call RestartMapMusic

	ld hl, PartyMon1Item
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfLastPartymon
	ld a, [de]
	ld b, a
	ld a, GS_BALL
	cp b
	ret nz

	ld de, EVENT_GOT_GS_BALL_FROM_POKECOM_CENTER
	ld b, SET_FLAG
	call EventFlagAction
	ld de, EVENT_CAN_GIVE_GS_BALL_TO_KURT
	ld b, SET_FLAG
	call EventFlagAction
	ld hl, .Text_WonderTradeForGSBallPichuText
	call PrintText
	ret

.Text_WonderTradeQuestion:
	text_jump WonderTradeQuestionText
	db "@"

.Text_WonderTradePrompt:
	text_jump WonderTradePromptText
	db "@"

.Text_WonderTradeConfirm:
	text_jump WonderTradeConfirmText
	db "@"

.Text_WonderTradeSetup:
	text_jump WonderTradeSetupText
	db "@"

.Text_WonderTradeReady:
	text_jump WonderTradeReadyText
	db "@"

.Text_WonderTradeComplete:
	text_jump WonderTradeCompleteText
	start_asm
	ld de, MUSIC_NONE
	call PlayMusic
	call DelayFrame
	ld hl, .trade_done
	ret

.trade_done
	text_jump WonderTradeDoneFanfare
	db "@"

.Text_WonderTradeForGSBallPichuText:
	text_jump WonderTradeForGSBallPichuText
	db "@"

DoWonderTrade:
	ld a, [CurPartySpecies]
	ld [wPlayerTrademonSpecies], a

	; If you've beaten the Elite Four...
	ld de, EVENT_BEAT_ELITE_FOUR
	ld b, CHECK_FLAG
	call EventFlagAction
	ld a, c
	and a
	jr z, .random_trademon
	; ...and haven't gotten the GS Ball Pichu yet...
	ld de, EVENT_GOT_GS_BALL_FROM_POKECOM_CENTER
	ld b, CHECK_FLAG
	call EventFlagAction
	ld a, c
	and a
	jr nz, .random_trademon

	; ...then receive a shiny Pichu holding a GS Ball
	call GetGSBallPichu
	jp .compute_trademon_stats

.random_trademon
	ld a, NUM_POKEMON
	call RandomRange
	inc a
	ld [wOTTrademonSpecies], a
	call CheckValidLevel
	and a
	jr nz, .random_trademon

	ld a, [wPlayerTrademonSpecies]
	ld de, wPlayerTrademonSpeciesName
	call GetTradeMonName
	call CopyTradeName

	ld a, [wOTTrademonSpecies]
	ld de, wOTTrademonSpeciesName
	call GetTradeMonName
	call CopyTradeName

	ld hl, PartyMonOT
	ld bc, NAME_LENGTH
	call Trade_GetAttributeOfCurrentPartymon
	ld de, wPlayerTrademonOTName
	call CopyTradeName

	ld hl, PlayerName
	ld de, wPlayerTrademonSenderName
	call CopyTradeName

	ld hl, PartyMon1ID
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfCurrentPartymon
	ld de, wPlayerTrademonID
	call Trade_CopyTwoBytes

	ld hl, PartyMon1DVs
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfCurrentPartymon
	ld de, wPlayerTrademonDVs
	call Trade_CopyTwoBytes

	ld hl, PartyMon1Species
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfCurrentPartymon
	ld b, h
	ld c, l
	callba GetCaughtGender
	ld a, c
	ld [wPlayerTrademonCaughtData], a

	; BUG: Caught data doesn't seem to be saved.
	; Look at source code for SetGiftPartyMonCaughtData.
	xor a
	ld [wOTTrademonCaughtData], a

	ld hl, PartyMon1Level
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfCurrentPartymon
	ld a, [hl]
	ld [CurPartyLevel], a
	ld a, [wOTTrademonSpecies]
	ld [CurPartySpecies], a
	xor a
	ld [MonType], a
	ld [wPokemonWithdrawDepositParameter], a
	callab RemoveMonFromPartyOrBox
	predef TryAddMonToParty

	ld b, RESET_FLAG
	callba SetGiftPartyMonCaughtData

	ld a, [wOTTrademonSpecies]
	ld de, wOTTrademonNickname
	call GetTradeMonName
	call CopyTradeName

	ld hl, PartyMonNicknames
	ld bc, PKMN_NAME_LENGTH
	call Trade_GetAttributeOfLastPartymon
	ld hl, wOTTrademonNickname
	call CopyTradeName

	; a = random byte
	; OT ID = (a ^ %10101010) << 8 | a
	call Random
	ld [Buffer1], a
	ld b, %10101010
	xor b
	ld [Buffer1 + 1], a
	ld hl, Buffer1
	ld de, wOTTrademonID
	call Trade_CopyTwoBytes

	ld hl, PartyMon1ID
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfLastPartymon
	ld hl, wOTTrademonID
	call Trade_CopyTwoBytes

	ld a, [wOTTrademonID]
	call GetWonderTradeOTName
	push hl
	ld de, wOTTrademonOTName
	call CopyTradeName
	pop hl
	ld de, wOTTrademonSenderName
	call CopyTradeName

	ld hl, PartyMonOT
	ld bc, NAME_LENGTH
	call Trade_GetAttributeOfLastPartymon
	ld hl, wOTTrademonOTName
	call CopyTradeName

	; Random DVs
	call Random
	ld [Buffer1], a
	call Random
	ld [Buffer1 + 1], a
	ld hl, Buffer1
	ld de, wOTTrademonDVs
	call Trade_CopyTwoBytes

	ld hl, PartyMon1DVs
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfLastPartymon
	ld hl, wOTTrademonDVs
	call Trade_CopyTwoBytes

	ld hl, PartyMon1Item
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfLastPartymon
	call GetWonderTradeHeldItem
	ld [de], a

.compute_trademon_stats
	push af
	push bc
	push de
	push hl
	ld a, [CurPartyMon]
	push af
	ld a, [PartyCount]
	dec a
	ld [CurPartyMon], a
	callba ComputeNPCTrademonStats
	pop af
	ld [CurPartyMon], a
	pop hl
	pop de
	pop bc
	pop af
	ret


GetGSBallPichu:
	ld a, PICHU
	ld [wOTTrademonSpecies], a

	ld a, [wPlayerTrademonSpecies]
	ld de, wPlayerTrademonSpeciesName
	call GetTradeMonName
	call CopyTradeName

	ld a, [wOTTrademonSpecies]
	ld de, wOTTrademonSpeciesName
	call GetTradeMonName
	call CopyTradeName

	ld hl, PartyMonOT
	ld bc, NAME_LENGTH
	call Trade_GetAttributeOfCurrentPartymon
	ld de, wPlayerTrademonOTName
	call CopyTradeName

	ld hl, PlayerName
	ld de, wPlayerTrademonSenderName
	call CopyTradeName

	ld hl, PartyMon1ID
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfCurrentPartymon
	ld de, wPlayerTrademonID
	call Trade_CopyTwoBytes

	ld hl, PartyMon1DVs
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfCurrentPartymon
	ld de, wPlayerTrademonDVs
	call Trade_CopyTwoBytes

	ld hl, PartyMon1Species
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfCurrentPartymon
	ld b, h
	ld c, l
	callba GetCaughtGender
	ld a, c
	ld [wPlayerTrademonCaughtData], a

	; BUG: Caught data doesn't seem to be saved.
	; Look at source code for SetGiftPartyMonCaughtData.
	xor a
	ld [wOTTrademonCaughtData], a

	ld hl, PartyMon1Level
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfCurrentPartymon
	ld a, 30
	ld [CurPartyLevel], a
	ld a, [wOTTrademonSpecies]
	ld [CurPartySpecies], a
	xor a
	ld [MonType], a
	ld [wPokemonWithdrawDepositParameter], a
	callab RemoveMonFromPartyOrBox
	predef TryAddMonToParty

	ld b, RESET_FLAG
	callba SetGiftPartyMonCaughtData

	ld a, [wOTTrademonSpecies]
	ld de, wOTTrademonNickname
	call GetTradeMonName
	call CopyTradeName

	ld hl, PartyMonNicknames
	ld bc, PKMN_NAME_LENGTH
	call Trade_GetAttributeOfLastPartymon
	ld hl, wOTTrademonNickname
	call CopyTradeName

	ld hl, PlayerID
	ld de, wOTTrademonID
	call Trade_CopyTwoBytes

	ld hl, PartyMon1ID
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfLastPartymon
	ld hl, wOTTrademonID
	call Trade_CopyTwoBytes

	ld hl, PlayerName
	push hl
	ld de, wOTTrademonOTName
	call CopyTradeName
	pop hl
	ld de, wOTTrademonSenderName
	call CopyTradeName

	ld hl, PartyMonOT
	ld bc, NAME_LENGTH
	call Trade_GetAttributeOfLastPartymon
	ld hl, wOTTrademonOTName
	call CopyTradeName

	ld a, ATKDEFDV_SHINY
	ld [wOTTrademonDVs], a
	ld a, SPDSPCDV_SHINY
	ld [wOTTrademonDVs + 1], a

	ld hl, PartyMon1DVs
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfLastPartymon
	ld hl, wOTTrademonDVs
	call Trade_CopyTwoBytes

	ld hl, PartyMon1Item
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfLastPartymon
	ld a, GS_BALL
	ld [de], a

	ret

GetWonderTradeOTName:
; hl = .WonderTradeOTNameTable + a * PLAYER_NAME_LENGTH
	ld hl, .WonderTradeOTNameTable
	ld b, 0
	ld c, PLAYER_NAME_LENGTH
	call AddNTimes
	ret

; TODO: Associate each OT name with a correct gender (via wOTTrademonCaughtData?)
.WonderTradeOTNameTable:
	db "Nemo@@@@" ; $00
	db "Rangi@@@" ; $01
	db "Satoshi@" ; $02
	db "Tajiri@@" ; $03
	db "Satoru@@" ; $04
	db "Iwata@@@" ; $05
	db "Junichi@" ; $06
	db "Masuda@@" ; $07
	db "Imakuni@" ; $08
	db "Bryan@@@" ; $09
	db "Mateo@@@" ; $0a
	db "Drayano@" ; $0b
	db "Pum@@@@@" ; $0c
	db "Marckus@" ; $0d
	db "Brock@@@" ; $0e
	db "Misty@@@" ; $0f
	db "Surge@@@" ; $10
	db "Erika@@@" ; $11
	db "Janine@@" ; $12
	db "Sabrina@" ; $13
	db "Blaine@@" ; $14
	db "Gio@@@@@" ; $15
	db "Lorelei@" ; $16
	db "Bruno@@@" ; $17
	db "Agatha@@" ; $18
	db "Lance@@@" ; $19
	db "Falkner@" ; $1a
	db "Bugsy@@@" ; $1b
	db "Whitney@" ; $1c
	db "Morty@@@" ; $1d
	db "Chuck@@@" ; $1e
	db "Jasmine@" ; $1f
	db "Pryce@@@" ; $20
	db "Clair@@@" ; $21
	db "Will@@@@" ; $22
	db "Koga@@@@" ; $23
	db "Karen@@@" ; $24
	db "Cissy@@@" ; $25
	db "Danny@@@" ; $26
	db "Rudy@@@@" ; $27
	db "Luana@@@" ; $28
	db "Prima@@@" ; $29
	db "Drake@@@" ; $2a
	db "Kiyo@@@@" ; $2b
	db "Valerie@" ; $2c
	db "Red@@@@@" ; $2d
	db "Blue@@@@" ; $2e
	db "Green@@@" ; $2f
	db "Yellow@@" ; $30
	db "Gold@@@@" ; $31
	db "Silver@@" ; $32
	db "Crystal@" ; $33
	db "Ruby@@@@" ; $34
	db "Safire@@" ; $35
	db "Emerald@" ; $36
	db "Diamond@" ; $37
	db "Pearl@@@" ; $38
	db "Black@@@" ; $39
	db "White@@@" ; $3a
	db "Ash@@@@@" ; $3b
	db "Gary@@@@" ; $3c
	db "Ethan@@@" ; $3d
	db "Lyra@@@@" ; $3e
	db "Kris@@@@" ; $3f
	db "Brendan@" ; $40
	db "May@@@@@" ; $41
	db "Wally@@@" ; $42
	db "Leaf@@@@" ; $43
	db "Lucas@@@" ; $44
	db "Dawn@@@@" ; $45
	db "Barry@@@" ; $46
	db "Hilbert@" ; $47
	db "Hilda@@@" ; $48
	db "Cheren@@" ; $49
	db "Bianca@@" ; $4a
	db "Nate@@@@" ; $4b
	db "Rosa@@@@" ; $4c
	db "Hugh@@@@" ; $4d
	db "Calem@@@" ; $4e
	db "Serena@@" ; $4f
	db "Shauna@@" ; $50
	db "Trevor@@" ; $51
	db "Tierno@@" ; $52
	db "Lillie@@" ; $53
	db "Hau@@@@@" ; $54
	db "Hibiki@@" ; $55
	db "Kotone@@" ; $56
	db "Yuuki@@@" ; $57
	db "Haruka@@" ; $58
	db "Mitsuru@" ; $59
	db "Kouki@@@" ; $5a
	db "Hikari@@" ; $5b
	db "Jun@@@@@" ; $5c
	db "Touya@@@" ; $5d
	db "Touko@@@" ; $5e
	db "Bel@@@@@" ; $5f
	db "Kyouhei@" ; $60
	db "Mei@@@@@" ; $61
	db "Naoko@@@" ; $62
	db "Sayo@@@@" ; $63
	db "Zuki@@@@" ; $64
	db "Kuni@@@@" ; $65
	db "Miki@@@@" ; $66
	db "Jessie@@" ; $67
	db "James@@@" ; $68
	db "Cassidy@" ; $69
	db "Butch@@@" ; $6a
	db "Bonnie@@" ; $6b
	db "Clyde@@@" ; $6c
	db "Attila@@" ; $6d
	db "Hun@@@@@" ; $6e
	db "Domino@@" ; $6f
	db "Carr@@@@" ; $70
	db "Orm@@@@@" ; $71
	db "Sird@@@@" ; $72
	db "Joy@@@@@" ; $73
	db "Jenny@@@" ; $74
	db "Oak@@@@@" ; $75
	db "Elm@@@@@" ; $76
	db "Birch@@@" ; $77
	db "Rowan@@@" ; $78
	db "Juniper@" ; $79
	db "Ivy@@@@@" ; $7a
	db "Hala@@@@" ; $7b
	db "Kukui@@@" ; $7c
	db "Bill@@@@" ; $7d
	db "Lanette@" ; $7e
	db "Celio@@@" ; $7f
	db "Bebe@@@@" ; $80
	db "Amanita@" ; $81
	db "Cassius@" ; $82
	db "Joey@@@@" ; $83
	db "A.J.@@@@" ; $84
	db "Camila@@" ; $85
	db "Alice@@@" ; $86
	db "Leo@@@@@" ; $87
	db "Aoooo@@@" ; $88
	db "Jimmy@@@" ; $89
	db "Cly@@@@@" ; $8a
	db "Revo@@@@" ; $8b
	db "Everyle@" ; $8c
	db "Zetsu@@@" ; $8d
	db "Richie@@" ; $8e
	db "Assunta@" ; $8f
	db "Tracey@@" ; $90
	db "Duplica@" ; $91
	db "Casey@@@" ; $92
	db "Giselle@" ; $93
	db "Melanie@" ; $94
	db "Damian@@" ; $95
	db "Rick@@@@" ; $96
	db "Reiko@@@" ; $97
	db "Kamon@@@" ; $98
	db "Karuta@@" ; $99
	db "Nozomi@@" ; $9a
	db "Amos@@@@" ; $9b
	db "Mark@@@@" ; $9c
	db "Alan@@@@" ; $9d
	db "Robin@@@" ; $9e
	db "Mitch@@@" ; $9f
	db "Carl@@@@" ; $a0
	db "Victor@@" ; $a1
	db "Daniel@@" ; $a2
	db "Emma@@@@" ; $a3
	db "Sakura@@" ; $a4
	db "Shinji@@" ; $a5
	db "Rei@@@@@" ; $a6
	db "Asuka@@@" ; $a7
	db "Mari@@@@" ; $a8
	db "Alexis@@" ; $a9
	db "Hanson@@" ; $aa
	db "Sawyer@@" ; $ab
	db "Nickel@@" ; $ac
	db "Olson@@@" ; $ad
	db "Wright@@" ; $ae
	db "Bickett@" ; $af
	db "Saito@@@" ; $b0
	db "Diaz@@@@" ; $b1
	db "Hunter@@" ; $b2
	db "Hill@@@@" ; $b3
	db "Javier@@" ; $b4
	db "Kaufman@" ; $b5
	db "O'Brien@" ; $b6
	db "Frost@@@" ; $b7
	db "Morse@@@" ; $b8
	db "Yufune@@" ; $b9
	db "Rajan@@@" ; $ba
	db "Stock@@@" ; $bb
	db "Thurman@" ; $bc
	db "Wagner@@" ; $bd
	db "Yates@@@" ; $be
	db "Andrews@" ; $bf
	db "Bahn@@@@" ; $c0
	db "Mori@@@@" ; $c1
	db "Buckman@" ; $c2
	db "Cobb@@@@" ; $c3
	db "Hughes@@" ; $c4
	db "Arita@@@" ; $c5
	db "Easton@@" ; $c6
	db "Freeman@" ; $c7
	db "Giese@@@" ; $c8
	db "Hatcher@" ; $c9
	db "Jackson@" ; $ca
	db "Kahn@@@@" ; $cb
	db "Leong@@@" ; $cc
	db "Marino@@" ; $cd
	db "Newman@@" ; $ce
	db "Nguyen@@" ; $cf
	db "Ogden@@@" ; $d0
	db "Park@@@@" ; $d1
	db "Raine@@@" ; $d2
	db "Sells@@@" ; $d3
	db "Turner@@" ; $d4
	db "Walker@@" ; $d5
	db "Meyer@@@" ; $d6
	db "Johnson@" ; $d7
	db "Adams@@@" ; $d8
	db "Smith@@@" ; $d9
	db "Baker@@@" ; $da
	db "Collins@" ; $db
	db "Smart@@@" ; $dc
	db "Dykstra@" ; $dd
	db "Eaton@@@" ; $de
	db "Wong@@@@" ; $df
	db "Candela@" ; $e0
	db "Blanche@" ; $e1
	db "Spark@@@" ; $e2
	db "Willow@@" ; $e3
	db "Mallow@@" ; $e4
	db "Lana@@@@" ; $e5
	db "Sophos@@" ; $e6
	db "Kiawe@@@" ; $e7
	db "Nemo@@@@" ; $e8
	db "Nemo@@@@" ; $e9
	db "Nemo@@@@" ; $ea
	db "Nemo@@@@" ; $eb
	db "Nemo@@@@" ; $ec
	db "Nemo@@@@" ; $ed
	db "Nemo@@@@" ; $ee
	db "Nemo@@@@" ; $ef
	db "Nemo@@@@" ; $f0
	db "Nemo@@@@" ; $f1
	db "Nemo@@@@" ; $f2
	db "Nemo@@@@" ; $f3
	db "Nemo@@@@" ; $f4
	db "Nemo@@@@" ; $f5
	db "Nemo@@@@" ; $f6
	db "Nemo@@@@" ; $f7
	db "Nemo@@@@" ; $f8
	db "Nemo@@@@" ; $f9
	db "Nemo@@@@" ; $fa
	db "Nemo@@@@" ; $fb
	db "Nemo@@@@" ; $fc
	db "Nemo@@@@" ; $fd
	db "Nemo@@@@" ; $fe
	db "Nemo@@@@" ; $ff


GetWonderTradeHeldItem:
; Pick a random held item based on the bits of a random number.
; If bit 1 is set (50% chance), no held item.
; Otherwise, if bit 2 is set (25% chance), then Berry.
; And so on, with better items being more rare.
	call Random
	ld b, a
; TODO: factor out the repetition here with rept...endr and sla
	and a, %00000001
	jr z, .isbit2on
	ld a, 0
	jp .done
.isbit2on
	ld a, b
	and a, %00000010
	jr z, .isbit3on
	ld a, 1
	jp .done
.isbit3on
	ld a, b
	and a, %00000100
	jr z, .isbit4on
	ld a, 2
	jp .done
.isbit4on
	ld a, b
	and a, %00001000
	jr z, .isbit5on
	ld a, 3
	jp .done
.isbit5on
	ld a, b
	and a, %00010000
	jr z, .isbit6on
	ld a, 4
	jp .done
.isbit6on
	ld a, b
	and a, %00100000
	jr z, .isbit7on
	ld a, 5
	jp .done
.isbit7on
	ld a, b
	and a, %01000000
	jr z, .isbit8on
	ld a, 6
	jp .done
.isbit8on
	ld a, b
	and a, %10000000
	jr z, .allbitsoff
	ld a, 7
	jp .done
.allbitsoff
	ld a, 8
.done
	ld hl, .HeldItemsTable
	ld b, 0
	ld c, a
	add hl, bc
	ld a, [hl]
	ret

.HeldItemsTable:
	db NO_ITEM      ; 1/2
	db BERRY        ; 1/4
	db GOLD_BERRY   ; 1/8
	db MYSTERYBERRY ; 1/16
	db QUICK_CLAW   ; 1/32
	db SCOPE_LENS   ; 1/64
	db KINGS_ROCK   ; 1/128
	db LEFTOVERS    ; 1/256
	db LUCKY_EGG    ; 1/256

CheckValidLevel:
; Don't receive Pokémon outside a valid level range.
; Legendaries and other banned Pokémon have a "valid" range of 255 to 255.
	ld hl, PartyMon1Level
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfCurrentPartymon
	ld a, [hl]
	ld d, a

	ld a, [wOTTrademonSpecies]
	ld hl, .ValidPokemonLevels
	ld b, 0
	ld c, a
	add hl, bc
	add hl, bc

	ld a, [hli]
	dec a
	cp d
	ret nc

	ld a, [hl]
	cp d
	ret c

	xor a
	ret

.ValidPokemonLevels
	;  min, max
	db 255, 255 ; ?????
	db   1,  15 ; Bulbasaur
	db  16,  31 ; Ivysaur
	db  32, 100 ; Venusaur
	db   1,  15 ; Charmander
	db  16,  35 ; Charmeleon
	db  36, 100 ; Charizard
	db   1,  15 ; Squirtle
	db  16,  35 ; Wartortle
	db  36, 100 ; Blastoise
	db   1,   6 ; Caterpie
	db   7,   9 ; Metapod
	db  10, 100 ; Butterfree
	db   1,   6 ; Weedle
	db   7,   9 ; Kakuna
	db  10, 100 ; Beedrill
	db   1,  17 ; Pidgey
	db  18,  35 ; Pidgeotto
	db  36, 100 ; Pidgeot
	db   1,  19 ; Rattata
	db  20, 100 ; Raticate
	db   1,  17 ; Marill
	db  18, 100 ; Azumarill
	db   1,  21 ; Ekans
	db  22, 100 ; Arbok
	db   1,  19 ; Pikachu
	db  20, 100 ; Raichu
	db   1,  21 ; Sandshrew
	db  22, 100 ; Sandslash
	db   1,  15 ; Nidoran♀
	db  16,  35 ; Nidorina
	db  36, 100 ; Nidoqueen
	db   1,  15 ; Nidoran♂
	db  16,  35 ; Nidorino
	db  36, 100 ; Nidoking
	db   5,  19 ; Clefairy
	db  20, 100 ; Clefable
	db   1,  19 ; Vulpix
	db  20, 100 ; Ninetales
	db   5,  19 ; Jigglypuff
	db  20, 100 ; Wigglytuff
	db   1,  21 ; Zubat
	db  22, 100 ; Golbat
	db   1,  20 ; Oddish
	db  21,  31 ; Gloom
	db  32, 100 ; Vileplume
	db   1,  23 ; Paras
	db  24, 100 ; Parasect
	db   1,  30 ; Venonat
	db  31, 100 ; Venomoth
	db   1,  25 ; Diglett
	db  26, 100 ; Dugtrio
	db   1,  27 ; Meowth
	db  28, 100 ; Persian
	db   1,  32 ; Psyduck
	db  33, 100 ; Golduck
	db   1,  27 ; Mankey
	db  28, 100 ; Primeape
	db   1,  19 ; Growlithe
	db  20, 100 ; Arcanine
	db   1,  24 ; Poliwag
	db  25,  35 ; Poliwhirl
	db  36, 100 ; Poliwrath
	db   1,  15 ; Abra
	db  16,  35 ; Kadabra
	db  36, 100 ; Alakazam
	db   1,  27 ; Machop
	db  28,  45 ; Machoke
	db  46, 100 ; Machamp
	db   1,  20 ; Bellsprout
	db  21,  31 ; Weepinbell
	db  32, 100 ; Victreebel
	db   1,  29 ; Tentacool
	db  30, 100 ; Tentacruel
	db   1,  24 ; Geodude
	db  25,  44 ; Graveler
	db  45, 100 ; Golem
	db   1,  39 ; Ponyta
	db  40, 100 ; Rapidash
	db   1,  36 ; Slowpoke
	db  37, 100 ; Slowbro
	db   1,  29 ; Magnemite
	db  30,  49 ; Magneton
	db   1, 100 ; Farfetch'd
	db   1,  30 ; Doduo
	db  31, 100 ; Dodrio
	db   1,  33 ; Seel
	db  34, 100 ; Dewgong
	db   1,  37 ; Grimer
	db  38, 100 ; Muk
	db   1,  33 ; Shellder
	db  34, 100 ; Cloyster
	db   1,  24 ; Gastly
	db  25,  44 ; Haunter
	db  45, 100 ; Gengar
	db   1, 100 ; Onix
	db   1,  25 ; Drowzee
	db  26, 100 ; Hypno
	db   1,  27 ; Krabby
	db  28, 100 ; Kingler
	db   1,  29 ; Voltorb
	db  30, 100 ; Electrode
	db   1,  29 ; Exeggcute
	db  30, 100 ; Exeggutor
	db   1,  27 ; Cubone
	db  28, 100 ; Marowak
	db  20, 100 ; Hitmonlee
	db  20, 100 ; Hitmonchan
	db   1,  34 ; Koffing
	db  35, 100 ; Weezing
	db   1,  41 ; Rhyhorn
	db  42,  54 ; Rhydon
	db   1, 100 ; Chansey
	db   1,  38 ; Tangela
	db   1, 100 ; Kangaskhan
	db   1,  31 ; Horsea
	db  32,  54 ; Seadra
	db   1,  19 ; Togepi
	db  20,  39 ; Togetic
	db  40, 100 ; Togekiss
	db   1,  32 ; Staryu
	db  33, 100 ; Starmie
	db   1, 100 ; Mr.Mime
	db  10, 100 ; Scyther
	db   1, 100 ; Jynx
	db  20,  46 ; Electabuzz
	db  20,  46 ; Magmar
	db  10, 100 ; Pinsir
	db   1, 100 ; Tauros
	db   1,  19 ; Magikarp
	db  20, 100 ; Gyarados
	db  20, 100 ; Lapras
	db   1, 100 ; Ditto
	db   1,  19 ; Eevee
	db  20, 100 ; Vaporeon
	db  20, 100 ; Jolteon
	db  20, 100 ; Flareon
	db   1,  20 ; Porygon
	db  15,  39 ; Omanyte
	db  40, 100 ; Omastar
	db  15,  39 ; Kabuto
	db  40, 100 ; Kabutops
	db  15, 100 ; Aerodactyl
	db  20, 100 ; Snorlax
	db 255, 255 ; Articuno
	db 255, 255 ; Zapdos
	db 255, 255 ; Moltres
	db  20,  29 ; Dratini
	db  30,  54 ; Dragonair
	db  55, 100 ; Dragonite
	db 255, 255 ; Mewtwo
	db 255, 255 ; Mew
	db   1,  15 ; Chikorita
	db  16,  31 ; Bayleef
	db  32, 100 ; Meganium
	db   1,  13 ; Cyndaquil
	db  14,  35 ; Quilava
	db  36, 100 ; Typhlosion
	db   1,  17 ; Totodile
	db  18,  29 ; Croconaw
	db  30, 100 ; Feraligatr
	db   1,  14 ; Sentret
	db  15, 100 ; Furret
	db   1,  19 ; Hoothoot
	db  20, 100 ; Noctowl
	db   1,  17 ; Ledyba
	db  18, 100 ; Ledian
	db   1,  21 ; Spinarak
	db  22, 100 ; Ariados
	db  32, 100 ; Crobat
	db   1,  26 ; Chinchou
	db  27, 100 ; Lanturn
	db   1,  19 ; Pichu
	db   1,  19 ; Munchlax
	db  50, 100 ; Magnezone
	db  39, 100 ; Tangrowth
	db   1,  24 ; Natu
	db  25, 100 ; Xatu
	db   1,  14 ; Mareep
	db  15,  29 ; Flaaffy
	db  30, 100 ; Ampharos
	db  32, 100 ; Bellossom
	db  55, 100 ; Rhyperior
	db   1, 100 ; Sudowoodo
	db  36, 100 ; Politoed
	db   1,  31 ; Sunkern
	db  32, 100 ; Sunflora
	db   1,  37 ; Yanma
	db  38, 100 ; Yanmega
	db   1,  19 ; Wooper
	db  20, 100 ; Quagsire
	db  20, 100 ; Espeon
	db  20, 100 ; Umbreon
	db  20, 100 ; Leafeon
	db  20, 100 ; Glaceon
	db   1,  19 ; Murkrow
	db  20, 100 ; Honchkrow
	db  37, 100 ; Slowking
	db   1,  19 ; Misdreavus
	db  20, 100 ; Mismagius
	db   1, 100 ; Unown
	db   1, 100 ; Wobbuffet
	db   1, 100 ; Girafarig
	db   1,  30 ; Pineco
	db  31, 100 ; Forretress
	db   1, 100 ; Dunsparce
	db   1,  19 ; Gligar
	db  20, 100 ; Gliscor
	db  20, 100 ; Steelix
	db   1,  22 ; Snubbull
	db  23, 100 ; Granbull
	db   1, 100 ; Qwilfish
	db  20, 100 ; Scizor
	db   1, 100 ; Heracross
	db   1,  19 ; Sneasel
	db  20, 100 ; Weavile
	db   1,  29 ; Teddiursa
	db  30, 100 ; Ursaring
	db   1,  37 ; Slugma
	db  38, 100 ; Magcargo
	db   1,  32 ; Swinub
	db  33,  40 ; Piloswine
	db  41, 100 ; Mamoswine
	db   1, 100 ; Corsola
	db   1,  24 ; Remoraid
	db  25, 100 ; Octillery
	db   1, 100 ; Mantine
	db   1, 100 ; Skarmory
	db   1,  23 ; Houndour
	db  24, 100 ; Houndoom
	db  55, 100 ; Kingdra
	db   1,  24 ; Phanpy
	db  25, 100 ; Donphan
	db  20,  39 ; Porygon2
	db   1, 100 ; Smeargle
	db   1,  19 ; Tyrogue
	db  20, 100 ; Hitmontop
	db   1,  19 ; Elekid
	db  47, 100 ; Electivire
	db   1,  19 ; Magby
	db  47, 100 ; Magmortar
	db   1,  19 ; Miltank
	db  20, 100 ; Blissey
	db 255, 255 ; Raikou
	db 255, 255 ; Entei
	db 255, 255 ; Suicune
	db   1,  29 ; Larvitar
	db  30,  54 ; Pupitar
	db  55, 100 ; Tyranitar
	db 255, 255 ; Lugia
	db 255, 255 ; Ho-Oh
	db 255, 255 ; Celebi
	db  20, 100 ; Sylveon
	db  40, 100 ; Porygon-Z
	db 255, 255 ; Egg
	db 255, 255 ; ?????

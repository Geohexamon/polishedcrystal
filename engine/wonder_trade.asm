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

	;ld b, SET_FLAG
	;callba SetGiftPartyMonCaughtData

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

	ld b, SET_FLAG
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

; TODO: Associate each OT name with a correct gender (via wOTTrademonCaughtData)
.WonderTradeOTNameTable:
	db "Nemo@@@@" ; $00
	db "Rangi@@@" ; $01
	db "Matthew@" ; $02
	db "Mateo@@@" ; $03
	db "Drayano@" ; $04
	db "Marckus@" ; $05
	db "Pum@@@@@" ; $06
	db "Bryan@@@" ; $07
	db "Don@@@@@" ; $08
	db "Miguel@@" ; $09
	db "Satoru@@" ; $0a
	db "Iwata@@@" ; $0b
	db "Junichi@" ; $0c
	db "Masuda@@" ; $0d
	db "Imakuni@" ; $0e
	db "Red@@@@@" ; $0f
	db "Blue@@@@" ; $10
	db "Green@@@" ; $11
	db "Yellow@@" ; $12
	db "Orange@@" ; $13
	db "Gold@@@@" ; $14
	db "Silver@@" ; $15
	db "Crystal@" ; $16
	db "Ruby@@@@" ; $17
	db "Safire@@" ; $18
	db "Emerald@" ; $19
	db "Diamond@" ; $1a
	db "Pearl@@@" ; $1b
	db "Black@@@" ; $1c
	db "White@@@" ; $1d
	db "Alpha@@@" ; $1e
	db "Omega@@@" ; $1f
	db "Sun@@@@@" ; $20
	db "Moon@@@@" ; $21
	db "Ash@@@@@" ; $22
	db "Gary@@@@" ; $23
	db "Leaf@@@@" ; $24
	db "Ethan@@@" ; $25
	db "Lyra@@@@" ; $26
	db "Kris@@@@" ; $27
	db "Brendan@" ; $28
	db "May@@@@@" ; $29
	db "Wally@@@" ; $2a
	db "Lucas@@@" ; $2b
	db "Dawn@@@@" ; $2c
	db "Barry@@@" ; $2d
	db "Hilbert@" ; $2e
	db "Hilda@@@" ; $2f
	db "Cheren@@" ; $30
	db "Bianca@@" ; $31
	db "Nate@@@@" ; $32
	db "Rosa@@@@" ; $33
	db "Hugh@@@@" ; $34
	db "Calem@@@" ; $35
	db "Serena@@" ; $36
	db "Shauna@@" ; $37
	db "Trevor@@" ; $38
	db "Tierno@@" ; $39
	db "Lillie@@" ; $3a
	db "Hau@@@@@" ; $3b
	db "Oak@@@@@" ; $3c
	db "Ivy@@@@@" ; $3d
	db "Birch@@@" ; $3e
	db "Rowan@@@" ; $3f
	db "Juniper@" ; $40
	db "Sycamor@" ; $41
	db "Kukui@@@" ; $42
	db "Willow@@" ; $43
	db "Bill@@@@" ; $44
	db "Lanette@" ; $45
	db "Celio@@@" ; $46
	db "Bebe@@@@" ; $47
	db "Amanita@" ; $48
	db "Cassius@" ; $49
	db "Brock@@@" ; $4a
	db "Misty@@@" ; $4b
	db "Surge@@@" ; $4c
	db "Erika@@@" ; $4d
	db "Janine@@" ; $4e
	db "Sabrina@" ; $4f
	db "Blaine@@" ; $50
	db "Giovani@" ; $51
	db "Lorelei@" ; $52
	db "Bruno@@@" ; $53
	db "Agatha@@" ; $54
	db "Lance@@@" ; $55
	db "Cissy@@@" ; $56
	db "Danny@@@" ; $57
	db "Rudy@@@@" ; $58
	db "Luana@@@" ; $59
	db "Prima@@@" ; $5a
	db "Drake@@@" ; $5b
	db "Falkner@" ; $5c
	db "Bugsy@@@" ; $5d
	db "Whitney@" ; $5e
	db "Morty@@@" ; $5f
	db "Chuck@@@" ; $60
	db "Jasmine@" ; $61
	db "Pryce@@@" ; $62
	db "Clair@@@" ; $63
	db "Will@@@@" ; $64
	db "Koga@@@@" ; $65
	db "Karen@@@" ; $66
	db "Steven@@" ; $67
	db "Wallace@" ; $68
	db "Cynthia@" ; $69
	db "Alder@@@" ; $6a
	db "Iris@@@@" ; $6b
	db "Diantha@" ; $6c
	db "Lana@@@@" ; $6d
	db "Mallow@@" ; $6e
	db "Sophcls@" ; $6f
	db "Kiawe@@@" ; $70
	db "Hala@@@@" ; $71
	db "Valerie@" ; $72
	db "Candela@" ; $73
	db "Blanche@" ; $74
	db "Spark@@@" ; $75
	db "Satoshi@" ; $76
	db "Tajiri@@" ; $77
	db "Shigeru@" ; $78
	db "Hibiki@@" ; $79
	db "Kotone@@" ; $7a
	db "Elm@@@@@" ; $7b
	db "Yuuki@@@" ; $7c
	db "Haruka@@" ; $7d
	db "Mitsuru@" ; $7e
	db "Kouki@@@" ; $7f
	db "Hikari@@" ; $80
	db "Jun@@@@@" ; $81
	db "Touya@@@" ; $82
	db "Touko@@@" ; $83
	db "Bel@@@@@" ; $84
	db "Kyouhei@" ; $85
	db "Mei@@@@@" ; $86
	db "Joy@@@@@" ; $87
	db "Jenny@@@" ; $88
	db "Looker@@" ; $89
	db "Jessie@@" ; $8a
	db "James@@@" ; $8b
	db "Cassidy@" ; $8c
	db "Butch@@@" ; $8d
	db "Bonnie@@" ; $8e
	db "Clyde@@@" ; $8f
	db "Attila@@" ; $90
	db "Hun@@@@@" ; $91
	db "Domino@@" ; $92
	db "Carr@@@@" ; $93
	db "Orm@@@@@" ; $94
	db "Sird@@@@" ; $95
	db "Archie@@" ; $96
	db "Maxie@@@" ; $97
	db "Cyrus@@@" ; $98
	db "N@@@@@@@" ; $99
	db "Ghetsis@" ; $9a
	db "Colress@" ; $9b
	db "Lysandr@" ; $9c
	db "Guzma@@@" ; $9d
	db "Naoko@@@" ; $9e
	db "Sayo@@@@" ; $9f
	db "Zuki@@@@" ; $a0
	db "Kuni@@@@" ; $a1
	db "Miki@@@@" ; $a2
	db "Kiyo@@@@" ; $a3
	db "Richie@@" ; $a4
	db "Assunta@" ; $a5
	db "Tracey@@" ; $a6
	db "Duplica@" ; $a7
	db "Casey@@@" ; $a8
	db "Giselle@" ; $a9
	db "Melanie@" ; $aa
	db "Damian@@" ; $ab
	db "Rick@@@@" ; $ac
	db "Reiko@@@" ; $ad
	db "Joey@@@@" ; $ae
	db "A.J.@@@@" ; $af
	db "Camila@@" ; $b0
	db "Alice@@@" ; $b1
	db "Leo@@@@@" ; $b2
	db "Aoooo@@@" ; $b3
	db "Jimmy@@@" ; $b4
	db "Cly@@@@@" ; $b5
	db "Revo@@@@" ; $b6
	db "Everyle@" ; $b7
	db "Zetsu@@@" ; $b8
	db "Kamon@@@" ; $b9
	db "Karuta@@" ; $ba
	db "Nozomi@@" ; $bb
	db "Amos@@@@" ; $bc
	db "Mark@@@@" ; $bd
	db "Alan@@@@" ; $be
	db "Robin@@@" ; $bf
	db "Mitch@@@" ; $c0
	db "Carl@@@@" ; $c1
	db "Victor@@" ; $c2
	db "Daniel@@" ; $c3
	db "Emma@@@@" ; $c4
	db "Ami@@@@@" ; $c5
	db "Minako@@" ; $c6
	db "Usagi@@@" ; $c7
	db "Rei@@@@@" ; $c8
	db "Makoto@@" ; $c9
	db "Mamoru@@" ; $ca
	db "Luna@@@@" ; $cb
	db "Artemis@" ; $cc
	db "Diana@@@" ; $cd
	db "Sakura@@" ; $ce
	db "Tomoyo@@" ; $cf
	db "Syaoran@" ; $d0
	db "Shinji@@" ; $d1
	db "Rei@@@@@" ; $d2
	db "Asuka@@@" ; $d3
	db "Mari@@@@" ; $d4
	db "Luke@@@@" ; $d5
	db "Lun@@@@@" ; $d6
	db "Rhue@@@@" ; $d7
	db "Traziun@" ; $d8
	db "Gaius@@@" ; $d9
	db "Lyrra@@@" ; $da
	db "Kloe@@@@" ; $db
	db "Cetsa@@@" ; $dc
	db "Lexus@@@" ; $dd
	db "Sorya@@@" ; $de
	db "Strata@@" ; $df
	db "Slade@@@" ; $e0
	db "Dirk@@@@" ; $e1
	db "Lys@@@@@" ; $e2
	db "Talan@@@" ; $e3
	db "Kersh@@@" ; $e4
	db "Emily@@@" ; $e5
	db "Roxanne@" ; $e6
	db "Brawly@@" ; $e7
	db "Wattson@" ; $e8
	db "Flanery@" ; $e9
	db "Norman@@" ; $ea
	db "Winona@@" ; $eb
	db "Liza@@@@" ; $ec
	db "Tate@@@@" ; $ed
	db "Wallace@" ; $ee
	db "Juan@@@@" ; $ef
	db "Sidney@@" ; $f0
	db "Phoebe@@" ; $f1
	db "Glacia@@" ; $f2
	db "Drake@@@" ; $f3
	db "Roark@@@" ; $f4
	db "Garden@@" ; $f5
	db "Maylene@" ; $f6
	db "Wake@@@@" ; $f7
	db "Fantina@" ; $f8
	db "Byron@@@" ; $f9
	db "Candice@" ; $fa
	db "Volkner@" ; $fb
	db "Aaron@@@" ; $fc
	db "Bertha@@" ; $fd
	db "Flint@@@" ; $fe
	db "Lucian@@" ; $ff


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

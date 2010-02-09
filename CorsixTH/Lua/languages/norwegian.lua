--[[ Copyright (c) 2010 Erlend Mongstad

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. --]]

-- Note: This file contains UTF-8 text. Make sure your editor is set to UTF-8.

Language("norwegian", "nb", "nob")
Inherit("english")

-- override
staff_class = {
  nurse                 = "Sykepleier",
  doctor                = "Lege",
  handyman              = "Vaktmester",
  receptionist          = "Resepsjonist",
  surgeon               = "Kirurg",
}

-- override
object = {
  desk                  = "Kontorpult",
  cabinet               = "Arkivskap",
  door                  = utf8 "Dör",
  bench                 = "Benk",
  table_1               = "Bord",
  chair                 = "Stol",
  drinks_machine        = "Brusautomat",
  bed1                  = "Seng",
  inflator              = "Pumpe",
  pool_table            = "Biljardbord",
  reception_desk        = "Resepsjon",
  table_2               = "Bord",
  cardio                = "Kardio",
  scanner               = "Skanner",
  console               = "Konsoll",
  screen                = "Skjerm",
  litter_bomb           = utf8 "Söppelbombe",
  couch                 = "Sofa",
  sofa                  = "Sofa",
  crash_trolley         = "Tralle",
  tv                    = "TV",
  ultrascanner          = "Ultraskanner",
  dna_fixer             = "DNA-fikser",
  cast_remover          = "Gipsfjerner",
  hair_restorer         = utf8 "Hårrenoverer",
  slicer                = "Tungekutter",
  x_ray                 = utf8 "Röntgen",
  radiation_shield      = utf8 "Strålingsvern",
  x_ray_viewer          = utf8 "Röntgenfremviser",
  operating_table       = "Operasjonsbord",
  lamp                  = "Lampe",
  sink1                 = "Vask",
  sink2                 = "Vask",
  sink3                 = "Vask",
  surgeon_screen        = "Forheng",
  lecture_chair         = "Forelesningsstol",
  projector             = "Prosjektor",
  bed2                  = "Seng",
  pharmacy_cabinet      = "Medisinskap",
  computer              = "Datamaskin",
  atom_analyser         = "Atomanalyser",
  blood_machine         = "Blodmaskin",
  fire_extinguisher     = "Brannslukningsapparat",
  radiator              = "Ovn",
  plant                 = "Plante",
  electrolyser          = "Elektrolyser",
  jelly_moulder         = utf8 "Geléstøper",
  gates_of_hell         = "Helvetesporten",
  bed3                  = "Seng",
  bin                   = utf8 "Söppelbötte",
  toilet                = "Toalett",
  swing_door1           = utf8 "Svingdör",
  swing_door2           = utf8 "Svingdör",
  shower                = "Saneringsdusj",
  auto_autopsy          = "Obduseringsmaskin",
  bookcase              = "Bokhylle",
  video_game            = "Videospill",
  entrance_left         = utf8 "Inngang venstre dör",
  entrance_right        = utf8 "Inngang höyre dör",
  skeleton              = "Skjelett",
  comfortable_chair     = "Komfortabel stol",
}

-- override
diseases = {
  -- none                = D( 1), -- not used/needed?
  general_practice       = { 
  	name 		= "Allmennpraksis", 
  },
  bloaty_head 			 = { 
	name 		= "Ballonghode", 
	cause 		= utf8 "Årsak - Pasienten har sniffet ost og drukket forurenset vann.", 
	symptoms 	= utf8 "Symptomer - Den rammede er meget ukomfortabel.", 
	cure 		= utf8 "Behandling - Man stikker hull på det oppsvulmede hodet, og pumper det opp igjen til korrekt PSI med en intelligent maskin.", 
  },
  hairyitis              = { 
  	name 		= "Pelssyndrom", 
  	cause 		= utf8 "Årsak - Fullmåne.", 
  	symptoms 	= utf8 "Symptomer - Ökt luktesans.", 
  	cure		= utf8 "Behandling - En elektrosjokkmaskin fjerner håret, og tetter igjen porene.", 
  },
  king_complex           = { 
  	name 		= "Rock'n'Roll syndrom", 
  	cause 		= utf8 "Årsak - Elivs' ånd tar over kontrollen over pasientens hode", 
  	symptoms 	= utf8 "Symptomer - Går med fargede lærsko, og spiser cheeseburgere", 
  	cure 		= utf8 "Behandling - En psykolog forteller pasienten hvor tåpelig han eller hun ser ut", 
  },
  invisibility           = { 
  	name 		= "Usynlighet", 
  	cause 		= utf8 "Årsak - Bitt av en radioaktiv (og usynlig) maur", 
  	symptoms 	= utf8 "Symptomer - Pasienten lider ikke - tvert imot! De utnytter situasjonen, og lurer familie og venner trill rundt", 
  	cure 		= utf8 "Behandling - En fargerik kur fra apoteket gjör pasienten fullt synlig igjen", 
  },
  serious_radiation      = { 
  	name 		= utf8 "Alvorlig stråling", 
  	cause 		= utf8 "Årsak - Har forvekslet plutonium-isotoper med tyggegummi.", 
  	symptoms 	= utf8 "Symptomer - Pasienten föler seg meget ukomfortabel.", 
  	cure 		= utf8 "Behandling - Pasienten blir plassert i en saneringsdusj og renset fullstendig.", 
  },
  slack_tongue           = { 
  	name 		= utf8 "Lös tunge", 
  	cause 		= utf8 "Årsak - Kronisk overivrig i diskusjoner om såpeopera.", 
  	symptoms 	= "Symptomer - Tungen hever seg til det femdoble.", 
  	cure 		= "Behandling - Tungen blir plassert i en tungekutter. Hevelsen fjernes deretter hurtig, effektivt og smertefullt.",
  },
  alien_dna              = { 
  	name 		= "Utenomjordisk DNA", 
  	cause 		= utf8 "Årsak - Bitt av facehuggere utstyrt med intelligent utenomjordisk blod.", 
  	symptoms 	= utf8 "Symptomer - Er under gradvis forvandling til romvesen, og har et önske om å ta over våre byer.", 
  	cure 		= "Behandling - Alt DNA blir fjernet mekanisk, renset for utenomjordiske celler, og blir hurtig erstattet.",
  },
  fractured_bones        = { 
  	name 		= "Benbrudd",
  	cause 		= utf8 "Årsak - Fall fra store høyder mot betong.", 
  	symptoms 	= utf8 "Symptomer - Höye knaselyder og liten bevegelighet på utsatte steder.", 
  	cure 		= "Behandling - Gipsen blir fjernet ved hjelp av en laserstyrt gipsfjerner.", 
  },
  baldness               = { 
  	name 		= "Flintskalle", 
  	cause 		= utf8 "Årsak - Forteller lögner og dikter opp historier for å öke sin popularitet.", 
  	symptoms 	= "Symptomer - Forlegen pasient med skinnende skalle.", 
  	cure 		= utf8 "Behandling - Hår blir hurtig smeltet fast til pasientens hode med en smertefull hårmaskin.",
  },
  discrete_itching       = { 
  	name 		= "Skrapesyke", 
  	cause 		= utf8 "Årsak - Små insekter med skarpe tenner.", 
  	symptoms 	= utf8 "Symptomer - Pasienten klör intenst, og huden flasser.", 
  	cure 		= utf8 "Behandling - En sykepleier gir pasienten en sirupaktig drikk som leger huden og hindrer videre klöe.",
  },
  jellyitis              = { 
  	name 		= utf8 "Gelésyndrom", 
  	cause 		= utf8 "Årsak - Gelatinrik diett og for mye mosjon.", 
  	symptoms 	= utf8 "Symptomer - Meget ustödig og faller mye.", 
  	cure 		= utf8 "Behandling - Pasienten blir presset ned i en gelétönne i et spesielt rom.",
  },
  sleeping_illness       = { 
  	name 		= utf8 "Sövnsyke", 
  	cause 		= utf8 "Forårsaket av overaktive sövnkjertler i munnens gane.", 
  	symptoms 	= utf8 "Symptomer - Sterkt önske om å sove, hvor og når som helst.", 
  	cure 		= "Behandling - En sterk dose stimulerende medisin blir delt ut av en sykepleier.",
  },
  pregnancy              = { 
  	name 		= "Graviditet", 
  	cause 		= utf8 "Forårsaket av strömbrudd i urbane strøk.", 
  	symptoms 	= utf8 "Symptomer - Lei av å spise med konstant ölmage.", 
  	cure 		= "Behandling - Spedbarnet blir fjernet med keisersnitt, blir deretter vasket og presentert for sin nye mor.",
  },   -- unused
  transparency           = { 
  	name 		= "Gjennomsiktighet", 
  	cause 		= utf8 "Årsak - Slikket folien på et gammelt yoghurtbeger.", 
  	symptoms 	= "Symptomer - Kroppen blir gjennomsiktig og ekkel.", 
  	cure 		= utf8 "Behandling - En kald og fargerik drikk fra apoteket gjör susen.",
  },
  uncommon_cold          = { 
  	name 		= utf8 "Forkjölelse",
  	cause 		= utf8 "Årsak - Små snörrpartikler i luften.", 
  	symptoms 	= "Symptomer - Rennende nese, hoste og misfarget slim fra lungene.", 
  	cure 		= utf8 "Behandling - En real slurk hostesaft fra apoteket vil gjöre susen.", 
  },
  broken_wind            = { 
  	name 		= "Forurensende gasser", 
  	cause 		= utf8 "Årsak - Har löpt på 3d-mölle rett etter middag.", 
  	symptoms 	= "Symptomer - Ubehag hos folk som befinner seg rett bak pasienten.", 
  	cure 		= utf8 "Behandling - En sterk blanding av spesielle vannatomer må svelges hurtig.",
  },
  spare_ribs             = { 
  	name 		= "Juleribbe", 
  	cause 		= utf8 "Årsak - Pasienten har sittet på kalde steingulv.", 
  	symptoms 	= utf8 "Symptomer - Ubehagelig fölelse i brystet.", 
  	cure 		= "Behandling - Ribben fjernes av to kirurger, og leveres til pasienten i en doggybag.",
  },
  kidney_beans           = { 
  	name 		= "Kikkerter", 
  	cause 		= utf8 "Årsak - Pasienten har spist isbiter.", 
  	symptoms 	= utf8 "Symptomer - Smerte og hyppige turer til toalettet.", 
  	cure 		= utf8 "Behandling - To kirurger fjerner de ertelignende parasittene, uten å beröre nyrene!",
  },
  broken_heart           = { 
  	name 		= "Knust hjerte",
  	cause 		= utf8 "Årsak - Noen er rikere, yngre og slankere enn pasienten.", 
  	symptoms 	= utf8 "Symptomer - Hysterisk gråtende. Blodsprengte fingertupper etter å ha revet opp feriebilder.", 
  	cure 		= "Behandling - To kirurger spretter opp brystet og setter deretter hjertet forsiktig sammen, mens de holder pusten.", 
  },
  ruptured_nodules       = { 
  	name 		= utf8 "Knekte nötter", 
  	cause 		= utf8 "Årsak - Strikkhopp om vinteren.", 
  	symptoms 	= utf8 "Symptomer - Umulig å sitte behagelig.", 
  	cure 		= utf8 "Behandling - To kvalifiserte kirurger må fjerne nöttene med stödige hender.",
  },
  tv_personalities       = { 
  	name 		= "Programledersyndrom", 
  	cause 		= utf8 "Årsak - TV-titting på dagtid.", 
  	symptoms 	= utf8 "Symptomer - Forestiller seg at han/hun er programleder i frokost-tv, og elsker å introdusere kjökkenseansen.", 
  	cure 		= utf8 "Behandling - En psykolog må overtale pasienten til å selge fjernsynet og heller kjöpe radio.",
  },
  infectious_laughter    = { 
  	name 		= "Smittsom latter", 
  	cause 		= utf8 "Årsak - Klassisk situasjonskomedie på TV.", 
  	symptoms 	= utf8 "Symptomer - Ler hjelpelöst hele tiden, og repeterer stadig dårlige poeng som absolutt ikke er morsomme.", 
  	cure 		= utf8 "Behandling - En kvalifisert psykolog må minne pasienten på at dette faktisk er en alvorlig tilstand.",
  },
  corrugated_ankles      = { 
  	name 	 	= utf8 "Böyde ankler", 
  	cause 		= utf8 "Årsak - Busskjöring over fartsdempere.", 
  	symptoms 	= "Symptomer - Skoene passer ikke.", 
  	cure 		= utf8 "Behandling - En giftig blanding av urter og krydder må drikkes for å rette ut anklene.",
  },
  chronic_nosehair       = { 
  	name 		= utf8 "Kronisk nesehår", 
  	cause 		= utf8 "Årsak - Snöfter med forakt på folk med lavere inntekt.", 
  	symptoms 	= utf8 "Symptomer - Så mye nesehår at en grevling kunne bodd der.", 
  	cure 		= utf8 "Behandling - En ekkel hårfjernende drikk blir inntatt gjennom munnen. Fåes på apoteket.",
  },
  third_degree_sideburns = { 
  	name 		= "Tredjegrads koteletter", 
  	cause 		= utf8 "Årsak - Lengter tilbake til 70-tallet.", 
  	symptoms 	= utf8 "Symptomer - Stort hår, inntilsittende klær, langt skinnskjegg og glitter.", 
  	cure 		= utf8 "Behandling - Psykologisk personell må, ved hjelp av nåtidens teknikker, overbevise pasienten om at parykk er noe tull.",
  },
  fake_blood             = { 
  	name 		= "Teaterblod", 
  	cause 		= utf8 "Årsak - Pasienten er ofte utsatt for narrestreker.", 
  	symptoms 	= utf8 "Symptomer - Rödt blod som dunster ved kontakt med klær.", 
  	cure 		= utf8 "Behandling - Eneste måten å behandle dette på, er å få en psykolog til å roe ned pasienten.",
  },
  gastric_ejections      = { 
  	name 		= utf8 "Krydrede oppstöt", 
  	cause 		= utf8 "Årsak - Sterkt krydret meksikansk eller indisk mat har skylden.", 
  	symptoms 	= "Symptomer - Gulper karrikylling og tacolefser.", 
  	cure 		= utf8 "Behandling - En sykepleier gir pasienten en bindende indisk kumelk-blanding som forhindrer nye oppstöt..",
  },
  the_squits             = { 
  	name 		= utf8 "Lös mage", 
  	cause 		= utf8 "Årsak - Har spist pizzabiter som har falt bak komfyren.", 
  	symptoms 	= utf8 "Symptomer - æsj. Tipper du vet symptomene.", 
  	cure 		= utf8 "Behandling - En klebig blanding kjemikalier må drikkes for å stabilisere magen innvendig.",
  },
  iron_lungs             = { 
  	name 		= "Jernlunger", 
  	cause 		= utf8 "Årsak - Forurenset byluft blandet med kebabrester.", 
  	symptoms 	= utf8 "Symptomer - Kan puste flammer og bröle höyt under vann.", 
  	cure 		= "Behandling - To kirurger mykner de solide lungene i operasjonssalen.",
  },
  sweaty_palms           = { 
  	name 		= utf8 "Håndsvette", 
  	cause 		= utf8 "Årsak - Er livredd jobbintervjuer.", 
  	symptoms 	= utf8 "Symptomer - Å håndhilse på pasienten er som å ta tak i en våt svamp.", 
  	cure 		= utf8 "Behandling - En psykolog må snakke pasienten ut av denne oppdiktede lidelsen.",
  },
  heaped_piles           = { 
  	name 		= "Hemoroider", 
  	cause 		= utf8 "Årsak - Står i nærheten av drikkevannskjölere.", 
  	symptoms 	= utf8 "Symptomer - Pasienten föler han/hun sitter på en pose med stein.", 
  	cure 		= utf8 "Behandling - En behagelig, men meget syrlig drikk, lösner opp hemoroidene innenifra.",
  },
  gut_rot                = { 
  	name 		= utf8 "Mageråte", 
  	cause 		= utf8 "Årsak - Onkel Georgs miks av hostesaft og whisky.", 
  	symptoms 	= "Symptomer - Ingen hoste, men ingen magesekk heller.", 
  	cure 		= "Behandling - En sykepleier skriver ut en rekke kjemikalier og gjenskaper veggen i magesekken.",
  },
  golf_stones            = { 
  	name 		= "Golfsteiner", 
  	cause 		= utf8 "Årsak - Utsatt for giftige gasser fra golfballer.", 
  	symptoms 	= "Symptomer - Forvirring og kraftig skamfölelse.", 
  	cure 		= "Behandling - Steinene fjernes kjapt og effektivt av to kirurger.",
  },
  unexpected_swelling    = { 
  	name 		= "Uventet hevelse", 
  	cause 		= utf8 "Årsak - Hva som helst uventet.", 
  	symptoms 	= "Symptomer - Hevelse.", 
  	cure 		= utf8 "Behandling - Hevelsen må skjæres bort av to kirurger.",
  },
  diag_scanner           = { name = "Diag Skanner", },
  diag_blood_machine     = { name = "Diag Blodmaskin", },
  diag_cardiogram        = { name = "Diag Kardio", },
  diag_x_ray             = { name = utf8 "Diag Röntgen", },
  diag_ultrascan         = { name = "Diag Ultraskanner", },
  diag_general_diag      = { name = "Diag Generell", },
  diag_ward              = { name = "Diag Sengeavd.", },
  diag_psych             = { name = "Diag Psykiatri", },
  autopsy                = { name = "Obduksjon", },
  -- mixer               = D(46), -- not used/needed?
}


-- new strings
object.litter 				  = utf8 "Söppel"

menu_options_game_speed.pause = "  PAUSE"

menu_debug = {
  transparent_walls           = "  GJENNOMSIKTIGE VEGGER",
  limit_camera                = "  BEGRENS KAMERA",
  disable_salary_raise        = utf8 "  DEAKTIVER LÖNNSÖKNING",
  make_debug_patient          = "  LAG DEBUG PASIENT",
  spawn_patient               = "  SPAWN PASIENT",
  make_adviser_talk           = utf8 "  FÅ RÅDGIVER TIL Å SNAKKE",
  show_watch                  = "  VIS KLOKKE",
  place_objects               = "  PLASSER OBJEKTER",
  map_overlay                 = "  KART OVERLEGG",
  sprite_viewer               = "  SPRITE VISER",
}
menu_debug_overlay = {
  none                        = "  INGEN",
  flags                       = "  FLAGG",
  byte_0_1                    = "  BYTE 0 & 1",
  byte_floor                  = "  BYTE GULV",
  byte_n_wall                 = "  BYTE N VEGG",
  byte_w_wall                 = "  BYTE W VEGG",
  byte_5                      = "  BYTE 5",
  byte_6                      = "  BYTE 6",
  byte_7                      = "  BYTE 7",
  parcel                      = "  PAKKE",
}
adviser.room_forbidden_non_reachable_parts = utf8 "Ved å plassere et rom her vil noen områder på sykehuset bli utilgjengelig."

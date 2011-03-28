--[[ Copyright (c) 2010 <Jukka Kauppinen>

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
SOFTWARE.

-------------------------------------------------------------------------------
   READ BEFORE DOING ANY CHANGES
-------------------------------------------------------------------------------

Since the Finnish language isn't in the original Theme Hospital game, this 
file is split in two sections (A and B). The first section contains all the new 
language strings, made by the Corsix-TH team, and the second section contains 
the override translation of all the original english strings.

FORMATING AND FINNISH LETTERS
This file contains UTF-8 text. Make sure your editor is set to UTF-8.

-------------------------------------------------------------------------------
    Table of Contents
-------------------------------------------------------------------------------
 
 -- SECTION A - NEW STRINGS

        1. Global settings
        2. Faxes
        3. Menu
        4. Adviser
        5. Main menu
        6. Tooltip
        7. Letter
        8. Installation
        9. Level introduction
        10. Tips
        11. Room descriptions
        12. Lua console
        13. Information
        14. Misc
 
 -- SECTION B - OLD STRINGS (OVERRIDE)
 
        Huge section with all original strings, translated from english.
        New strings to existing string sets have been placed here instead of
        section A to keep similar strings close to each other.

-----------------------------------------------------------------------------]]


-------------------------------------------------------------------------------
--   SECTION A - NEW STRINGS
-------------------------------------------------------------------------------

-- 1. Global setings (do not edit!)
Language("Suomi", "Finnish", "fi", "fin")
Inherit("english")

-- 2. Faxes
fax = {
  choices = {
    return_to_main_menu = utf8 "Palaa päävalikkoon",
    accept_new_level    = utf8 "Siirry seuraavalle tasolle",
    decline_new_level   = utf8 "Jatka pelaamista vielä jonkin aikaa",
  },
}

-- 3. Menu
menu_debug = {
  jump_to_level         = utf8 "  SIIRRY TASOLLE  ",
  transparent_walls     = utf8 "  (X) LÄPINÄKYVÄT SEINÄT  ",
  limit_camera          = utf8 "  RAJOITETTU KAMERA  ",
  disable_salary_raise  = utf8 "  ESTÄ PALKAN KOROTTAMINEN  ",
  make_debug_fax        = utf8 "  (F8) LUO DEBUG-FAKSI  ",
  make_debug_patient    = utf8 "  (F9) LISÄÄ DEBUG-POTILAS  ",
  cheats                = utf8 "  (F11) HUIJAUKSET  ",
  lua_console           = utf8 "  (F12) LUA-KOMENTORIVI  ",
  calls_dispatcher      = utf8 "  TEHTÄVIEN VÄLITYS  ",
  dump_strings          = utf8 "  DUMPPAA TEKSTIT  ",
  dump_gamelog          = utf8 "  (CTRL+D) DUMPPAA PELILOGI  ",
  map_overlay           = utf8 "  KARTTAKERROKSET  ",
  sprite_viewer         = utf8 "  SPRITE-KATSELIN  ",
}

menu_debug_overlay = {
  none          = utf8 "  TYHJÄ  ",
  flags         = utf8 "  LIPUT  ",
  positions     = utf8 "  SIJAINNIT  ",
  heat          = utf8 "  LÄMPÖTILA  ",
  byte_0_1      = utf8 "  TAVU 0 & 1  ",
  byte_floor    = utf8 "  TAVU LATTIA  ",
  byte_n_wall   = utf8 "  TAVU N SEINÄ  ",
  byte_w_wall   = utf8 "  TAVU W SEINÄ  ",
  byte_5        = utf8 "  TAVU 5  ",
  byte_6        = utf8 "  TAVU 6  ",
  byte_7        = utf8 "  TAVU 7  ",
  parcel        = utf8 "  PAKETTI  ",
}

menu_options_game_speed = {
  slowest               = utf8 "  (1) HITAIN  ",
  slower                = utf8 "  (2) HITAAMPI  ",
  normal                = utf8 "  (3) NORMAALI  ",
  max_speed             = utf8 "  (4) MAKSIMINOPEUS  ",
  and_then_some_more    = utf8 "  (5) JA VÄHÄN PÄÄLLE  ",
  pause                 = utf8 "  (P) PYSÄYTÄ  "
}

cheats_window = {
  caption       = utf8 "Huijaukset",
  warning       = utf8 "Varoitus: Et saa yhtään bonuspisteitä tason jälkeen, jos käytät huijauksia!",
  close         = utf8 "Sulje",
  cheated = {
    no  = utf8 "Huijauksia käytetty: Ei",
    yes = utf8 "Huijauksia käytetty: Kyllä",
  },
  cheats = {
    money               = utf8 "Rahahuijaus",
    all_research        = utf8 "Kaikki tutkimus -huijaus",
    emergency           = utf8 "Luo hätätilanne",
    create_patient      = utf8 "Luo potilas",
    end_month           = utf8 "Siirry kuukauden loppuun",
    end_year            = utf8 "Siirry vuoden loppuun",
    lose_level          = utf8 "Häviä",
    win_level           = utf8 "Voita",
  },
}

debug_patient_window = {
  caption = utf8 "Debug-potilas",
}

calls_dispatcher = {
  -- Dispatcher description message. Visible in Calls Dispatcher dialog
  summary       = utf8 "%d tehtävää; %d välitetty",
  staff         = utf8 "%s - %s",
  watering      = utf8 "Kastellaan @ %d,%d",
  repair        = utf8 "Korjaa %s",
  close         = utf8 "Sulje",
}

-- 4. Adviser
adviser = {
  room_forbidden_non_reachable_parts = utf8 "Huoneen sijoittaminen tähän estäisi pääsyn joihinkin sairaalan osiin.",
  cheats = {
    th_cheat            = utf8 "Onnittelut, olet saanut huijaukset käyttöösi! Tai olisit saanut, jos tämä olisi alkuperäinen peli. Kokeile jotain muuta.",
    crazy_on_cheat      = utf8 "Voi ei! Kaikki lääkärit ovat tulleet hulluiksi!",
    crazy_off_cheat     = utf8 "Huh... lääkärit ovat jälleen tulleet järkiinsä.",
    roujin_on_cheat     = utf8 "Roujinin haaste otettu käyttöön! Onnea...",
    roujin_off_cheat    = utf8 "Roujinin haaste poistettu käytöstä.",
    hairyitis_cheat     = utf8 "Turkinkasvu-huijaus otettu käyttöön!",
    hairyitis_off_cheat = utf8 "Turkinkasvu-huijaus poistettu käytöstä.",
    bloaty_cheat        = utf8 "Pallopäisyys-huijaus otettu käyttöön!",
    bloaty_off_cheat    = utf8 "Pallopäisyys-huijaus poistettu käytöstä.",
  },
}

-- 5. Main menu
main_menu = {
  new_game      = utf8 "Uusi peli",
  custom_level  = utf8 "Luo oma sairaala",
  load_game     = utf8 "Lataa peli",
  options       = utf8 "Asetukset",
  exit          = utf8 "Lopeta",
}

load_game_window = {
  caption       = utf8 "Lataa peli",
}

custom_game_window = {
  caption = utf8 "Luo oma sairaala",
}

save_game_window = {
  caption       = utf8 "Talenna peli",
  new_save_game = utf8 "Uusi tallennus",
}

menu_list_window = {
  back = utf8 "Takaisin",
}

options_window = {
  fullscreen            = utf8 "Koko ruutu",
  width                 = utf8 "Leveys",
  height                = utf8 "Korkeus",
  change_resolution     = utf8 "Vaihda resoluutio",
  browse                = utf8 "Selaa...",
  new_th_directory      = utf8 "Tässä voit määrittää uuden Theme Hospital -pelin asennushakemiston. Kun olet valinnut uuden hakemiston, peli käynnistyy uudestaan.",
  cancel                = utf8 "Peruuta",
  back                  = utf8 "Takaisin",
}

errors = {
  dialog_missing_graphics       = utf8 "Pahoittelut, demon pelitiedostot eivät sisällä tämän ikkunan grafiikkaa.",
  save_prefix                   = utf8 "Virhe tallennettaessa peliä: ",
  load_prefix                   = utf8 "Virhe ladattaessa peliä: ",
  map_file_missing              = utf8 "Tasolle %s ei löydetty karttatiedostoa!",
  minimum_screen_size           = utf8 "Ole hyvä ja syötä resoluutio, joka on vähintään 640x480.",
  maximum_screen_size           = utf8 "Ole hyvä ja syötä resoluutio, joka on enintään 3000x2000.",
  unavailable_screen_size       = utf8 "Syöttämäsi resoluutio ei ole käytettävissä koko ruutu -tilassa.",
}

new_game_window = {
  hard          = utf8 "Konsultti (Vaikea)",
  cancel        = utf8 "Peruuta",
  tutorial      = utf8 "Esittely",
  easy          = utf8 "Harjoittelija (Helppo)",
  medium        = utf8 "Tohtori (Keskitaso)",
}

-- 6. Tooltip
tooltip = {
  objects = {
    litter = utf8 "Roska: Potilas on jättänyt sen lattialle, koska ei löytänyt roskakoria, johon sen olisi voinut heittää",
  },

  totd_window = {
    previous    = utf8 "Näytä edellinen vihje",
    next        = utf8 "Näytä seuraava vihje",
  },

  main_menu = {
    new_game            = utf8 "Aloita uusi peli aivan alusta",
    custom_level        = utf8 "Rakenna oma sairaala itse suunnittelemaasi rakennukseen",
    load_game           = utf8 "Lataa aiemmin tallennettu peli",
    options             = utf8 "Muuta pelin asetuksia",
    exit                = utf8 "Ei, ei, ole kiltti äläkä lähde!",
  },

  load_game_window = {
    load_game           = utf8 "Lataa peli %s",
    load_game_number    = utf8 "Lataa peli numero %d",
    load_autosave       = utf8 "Lataa viimeisin automaattitallennus",
  },

  custom_game_window = {
    start_game_with_name = utf8 "Lataa taso %s",
  },

  save_game_window = {
    save_game           = utf8 "Tallenna tallennuksen %s tilalle",
    new_save_game       = utf8 "Anna nimi uudelle tallennukselle",
  },

  menu_list_window = {
    back = utf8 "Sulje tämä ikkuna",
  },

  options_window = {
    fullscreen_button   = utf8 "Klikkaa kytkeäksesi koko ruudun -tilan päälle tai pois",
    width               = utf8 "Syötä peli-ikkunan haluttu leveys",
    height              = utf8 "Syötä peli-ikkunan haluttu korkeus",
    change_resolution   = utf8 "Muuta ikkunan resoluutio vasemmalla annettujen arvojen mukaiseksi",
    language            = utf8 "Valitse kieleksi %s",
    original_path       = utf8 "Käytössä oleva Theme Hospital -pelin asennushakemisto",
    browse              = utf8 "Selaa hakemistoja valitaksesi uuden Theme Hospital -pelin asennushakemiston",
    back                = utf8 "Sulje tämä ikkuna",
  },

  new_game_window = {
    hard          = utf8 "Jos olet pelannut tällaista peliä aiemminkin ja kaipaat haastetta, valitse tämä",
    cancel        = utf8 "Hups, ei minun oikeasti pitänyt aloittaa uutta peliä!",
    tutorial      = utf8 "Jos haluat vähän apua alkuun pääsemisessä, valitse tämä",
    easy          = utf8 "Jos tämä on ensimmäinen kertasi tämän tyyppisen pelin parissa, tämä vaikeustaso on sinua varten",
    medium        = utf8 "Tämä on kultainen keskitie, jos et ole varma, mitä valitsisit",
  },

  lua_console = {
    textbox             = utf8 "Syötä suoritettava Lua-koodi tähän",
    execute_code        = utf8 "Suorita syöttämäsi koodi",
    close               = utf8 "Sulje komentorivi",
  },

  fax = {
    close = utf8 "Sulje ikkuna poistamatta viestiä",
  },

  message = {
    button              = utf8 "Avaa viesti klikkaamalla",
    button_dismiss      = utf8 "Klikkaa vasemalla avataksesi viestin, klikkaa oikealla poistaaksesi sen",
  },

  cheats_window = {
    close = utf8 "Sulje huijaukset-ikkuna",
    cheats = {
      money             = utf8 "Lisää 10 000$ pankkitilillesi",
      all_research      = utf8 "Saat kaiken tutkimuksen valmiiksi",
      emergency         = utf8 "Luo hätätilanteen",
      create_patient    = utf8 "Luo potilaan kartan reunalle",
      end_month         = utf8 "Siirtää aikaa eteenpäin kuukauden loppuun",
      end_year          = utf8 "Siirtää aikaa eteenpäin vuoden loppuun",
      lose_level        = utf8 "Häviät tämän tason",
      win_level         = utf8 "Voitat tämän tason",
    },
  },

  calls_dispatcher = {
    task        = utf8 "Tehtävälista - klikkaa tehtävää avataksesi sitä suorittavan henkilökunnan jäsenen ikkunan ja keskittääksesi näkymän tehtävän kohteeseen",
    assigned    = utf8 "Tässä on merkki, kun vastaava tehtävä on välitetty jonkun tehtäväksi",
    close       = utf8 "Sulje tehtävien välitys -ikkuna",
  },

  casebook = {
    cure_requirement = {
      hire_staff = utf8 "Sinun täytyy palkata lisää henkilökuntaa tämän taudin hoitamiseksi",
    },
    cure_type = {
      unknown = utf8 "Et vielä tiedä, miten tätä tautia pitää hoitaa",
    },
  },

  research_policy = {
    no_research         = utf8 "Tämän aiheen parissa ei tehdä tutkimusta tällä hetkellä",
    research_progress   = utf8 "Edistyminen kohti seuraavaa löytöä tällä aihealueella: %1%/%2%",
  },
}

-- 7. Letter
letter = {
  dear_player                   = utf8 "Hyvä %s", --%s (player's name)
  custom_level_completed        = utf8 "Hienosti tehty! Olet suorittanut kaikki tämän itse laaditun tason tavoitteet!",
  return_to_main_menu           = utf8 "Haluatko palata takaisin päävalikkoon vai jatkaa pelaamista?",
}

-- 8. Installation
install = {
  title         = utf8 "-------------------------------- CorsixTH asennus --------------------------------",
  th_directory  = utf8 "CorsixTH tarvitsee kopion alkuperäisen Theme Hospital -pelin (tai demon) tiedostoista toimiakseen. Ole hyvä ja käytä alla olevaa valitsinta Theme Hospital-pelin asennushakemiston etsimiseen.",
  exit          = utf8 "Sulje",
}

-- 9. Level introductions
introduction_texts = {
  demo = {
    [1] = utf8 "Tervetuloa demosairaalaan!",
    [2] = utf8 "Valitettavasti demoversio sisältää ainoastaan tämän tason (itse luotuja tasoja lukuun ottamatta). Täällä on kuitenkin enemmän kuin tarpeeksi tekemistä!",
    [3] = utf8 "Kohtaat erilaisia sairauksia, joiden hoitaminen vaatii erilaisia huoneita. Hätätilanteita saattaa tapahtua ajoittain. Lisäksi sinun pitää kehittää lisää huoneita tutkimusosaston avulla.",
    [4] = utf8 "Tavoitteesi on ansaita 100 000$, nostaa sairaalan arvo yli 70 000$:n ja maineesi yli 700:n parantaen samalla vähintään 75% potilaistasi.",
    [5] = utf8 "Pidä huoli, ettei maineesi putoa alle 300:n ja ettei yli 40 prosenttia potilaistasi pääse kuolemaan, tai häviät tason.",
    [6] = utf8 "Onnea!",
  },
  level1 = {
    [1] = utf8 "Tervetuloa ensimmäiseen sairaalaasi!//",
    [2] = utf8 "Pääset alkuun rakentamalla vastaanottopöydän ja yleislääkärin toimiston sekä palkkaamalla vastaanottoapulaisen ja lääkärin. ",
    [3] = utf8 "Sitten vain odotat asiakkaiden saapumista.",
    [4] = utf8 "Olisi hyvä ajatus rakentaa psykiatrin vastaanotto ja palkata lääkäri, joka on erikoistunut psykiatriaan. ",
    [5] = utf8 "Apteekki ja sairaanhoitaja ovat myös tärkeä yhdistelmä potilaidesi parantamiseksi. ",
    [6] = utf8 "Tarkkaile pallopäisyydestä kärsiviä potilaitasi - pumppaushuone hoitaa heidät alta aikayksikön. ",
    [7] = utf8 "Tavoitteenasi on parantaa kaikkiaan 10 potilasta ja varmistaa, ettei maineesi putoa alle 200:n.",
  },
  level2 = {
    [1] = utf8 "Tällä alueella on enemmän erilaisia sairauksia kuin edellisellä. ",
    [2] = utf8 "Sairaalasi pitää selvitä suuremmasta potilasmäärästä, ja sinun kannattaa varautua tutkimusosaston rakentamiseen. ",
    [3] = utf8 "Muista pitää laitoksesi puhtaana, ja yritä nostaa maineesi niin korkeaksi kuin mahdollista - alueella on liikkeellä velttokielisyyttä, joten tarvitset kieliklinikan. ",
    [4] = utf8 "Voit myös rakentaa kardiogrammihuoneen auttamaan uusien sairauksien diagnosoinnissa. ",
    [5] = utf8 "Molemmat näistä huoneista täytyy kehittää ennen kuin voit rakentaa niitä. Nyt voit myös ostaa lisää maata sairaalasi laajentamiseksi - Tämä tapahtuu kartta-ikkunassa. ",
    [6] = utf8 "Tavoitteesi ovat 300:n maine, 10 000$ pankissa and 40 parannettua potilasta.",
  },
  level3 = {
    [1] = utf8 "Tällä kertaa sairaalasi sijaitsee varakkaalla alueella. ",
    [2] = utf8 "Terveysministeriö odottaa sinun saavan täältä muhkeat voitot. ",
    [3] = utf8 "Alussa sinun täytyy hankkia sairaalallesi hyvä maine. Kun saat sairaalan pyörimään kunnolla, keskity ansaitsemaan niin paljon rahaa kuin pystyt. ",
    [4] = utf8 "Alueella saattaa myös sattua hätätapauksia. ",
    [5] = utf8 "Näissä tilanteissa suuri joukko samalla tavoin loukkaantuneita potilaita saapuu sairaalaasi yhtä aikaa. ",
    [6] = utf8 "Jos onnistut parantamaan heidät annetun aikarajan puitteissa saat lisää mainetta ja ison bonuksen. ",
    [7] = utf8 "Kuningas-kompleksin kaltaisia sairauksia saattaa esiintyä, joten kannattaa budjetoida rahaa leikkaussalin ja vuodeosaston rakentamiseen lähelle toisiaan. ",
    [8] = utf8 "Ansaitse 20 000$ päästäksesi seuraavalle tasolle.",
  },
  level4 = {
    [1] = utf8 "Pidä kaikki potilaasi tyytyväisinä, hoida heitä niin tehokkaasti kuin pystyt ja pidä kuolemantapaukset minimissään. ",
    [2] = utf8 "Maineesi on kyseessä, joten pidä huolta, että se pysyy niin korkealla kuin mahdollista. ",
    [3] = utf8 "Älä huolehdi rahasta liikaa - sitä alkaa kyllä tulla lisää maineesi kasvaessa. ",
    [4] = utf8 "Voit myös kouluttaa lääkäreitäsi parantaaksesi heidän osaamistaan. ",
    [5] = utf8 "He saattavat hyvinkin joutua hoitamaan tavallista läpinäkyvämpiä potilaita. ",
    [6] = utf8 "Nosta maineesi yli 500:n.",
  },
  level5 = {
    [1] = utf8 "Tästä tulee kiireinen sairaala, joka joutuu hoitamaan laajaa kirjoa sairauksia. ",
    [2] = utf8 "Kaikki lääkärisi ovat vastavalmistuneita, joten on ensiarvoisen tärkeää, että rakennat koulutushuoneen ja nostat lääkäreidesi osaamisen hyväksyttävälle tasolle. ",
    [3] = utf8 "Sinulla on vain kolme konsulttia opettamassa kokematonta henkilökuntaasi, joten pidä heidät tyytyväisinä. ",
    [4] = utf8 "Huomaa myös, että sairaalasi on rakennettu geologisen siirroksen läheisyyteen. ",
    [5] = utf8 "Maanjäristysten riski on siis koko ajan olemassa. ",
    [6] = utf8 "Ne aiheuttavat sattuessaan mittavia vahinkoja laitteillesi ja häiritsevät sairaalasi sujuvaa toimintaa. ",
    [7] = utf8 "Hanki sairaalallesi 400 mainetta ja kasvata 50 000$:n pankkitili onnistuaksesi. Paranna samalla 200 potilasta.",
  },
  level6 = {
    [1] = utf8 "Käytä kaikkea oppimaasi ja rakenna sujuvasti toimiva sairaala, joka on taloudellisesti terveellä pohjalla ja pystyy selviytymään kaikista eteen tulevista tilanteista. ",
    [2] = utf8 "Sinun on hyvä tietää, että ilmasto täällä levittää erityisen tehokkaasti bakteereja ja viruksia. ",
    [3] = utf8 "Ellet onnistu pitämään sairaalaasi putipuhtaana, potilaasi voivat joutua epidemioiden kierteeseen. ",
    [4] = utf8 "Pidä huolta, että ansaitset 150 000$ ja sairaalasi arvo ylittää 140 000$.",
  },
  level7 = {
    [1] = utf8 "Täällä joudut terveysministeriön tiukan valvonnan kohteeksi, joten pidä huolta, että tilikirjoissasi näkyy suuria voittoja ja maineesi pysyy korkealla. ",
    [2] = utf8 "Meillä ei ole varaa ylimääräisiin kuolemantapauksiin - ne ovat huonoja liiketoiminnan kannalta. ",
    [3] = utf8 "Varmista, että henkilökuntasi on parasta mahdollista ja heillä on kaikki tarvittavat toimitilat ja tarvikkeet. ",
    [4] = utf8 "Tavoitteesi ovat 600 mainetta ja 200 000$ pankkitilillä.",
  },
  level8 = {
    [1] = utf8 "Sinun tehtäväsi on rakentaa tehokkain ja tuottavin mahdollinen sairaala. ",
    [2] = utf8 "Ihmiset täällä ovat melko varakkaita, joten heiltä kannattaa kerätä niin paljon rahaa kuin mahdollista. ",
    [3] = utf8 "Muista, että niin kivaa kuin ihmisten parantaminen onkin, tarvitset kipeästi rahaa, jota se tuottaa. ",
    [4] = utf8 "Putsaa näiltä ihmisiltä tuhkatkin pesästä. ",
    [5] = utf8 "Sinun tulee kerätä vaikuttavat 300 000$ läpäistäksesi tason.",
  },
  level9 = {
    [1] = utf8 "Täytettyäsi ministeriön pankkitilin ja kustannettuasi uuden limusiinin ministerille itselleen pääset taas luomaan huolehtivan ja hyvin hoidetun sairaalan sairaiden avuksi. ",
    [2] = utf8 "Voit odottaa monia erilaisia ongelmia tällä alueella.",
    [3] = utf8 "Jos sinulla on riittävästi hyvin koulutettua henkilökuntaa ja huoneita, sinulla pitäisi olla kaikki hallinnassa. ",
    [4] = utf8 "Sairaalasi arvon tulee olla 200 000$ ja sinulla pitää olla 400 000$ pankissa. ",
    [5] = utf8 "Pienemmillä summilla et pääse tätä tasoa läpi.",
  },
  level10 = {
    [1] = utf8 "Sen lisäksi, että huolehdit kaikista sairauksista, joita täällä päin ilmenee, ministeriö pyytää, että käytät aikaa lääkkeidesi tehon parantamiseen. ",
    [2] = utf8 "Terveysjärjestöt ovat esittäneet joitakin valituksia, joten näyttääkseen hyvältä sairaalasi täytyy varmistaa, että kaikki käyttettävät lääkkeet ovat erittäin tehokkaita. ",
    [3] = utf8 "Varmista myös, että sairaalasi on arvostelun yläpuolella. Pidä kuolemantapausten määrä kurissa. ",
    [4] = utf8 "Ihan vihjeenä: saattaa olla hyvä idea säästää tilaa hyytelömuovainhuoneelle. ",
    [5] = utf8 "Kehitä kaikki lääkkeesi vähintään 80%%:n tehokkuuteen, nosta maineesi vähintään 650:n ja kokoa 500 000$ pankkitilillesi voittaaksesi. ",
  },
  level11 = {
    [1] = utf8 "Sinulle tarjoutuu nyt mahdollisuus rakentaa yksi maailman parhaista sairaaloista. ",
    [2] = utf8 "Tämä on erittäin arvostettu asuinalue ja ministeriö haluaa tänne parhaan mahdollisen sairaalan. ",
    [3] = utf8 "Odotamme sinun ansaitsevan runsaasti rahaa, hankkivan erinomaisen maineen sairaalallesi ja pystyvän hoitamaan vaikeimmatkin tapaukset. ",
    [4] = utf8 "Tämä on hyvin tärkeä työ. ",
    [5] = utf8 "Sinun täytyy käyttää kaikkea osaamistasi selvitäksesi tästä kunnialla. ",
    [6] = utf8 "Huomaa, että alueella on havaittu UFOja. Pidä huolta, että henkilökuntasi on valmiina odottamattomien vierailijoiden varalta. ",
    [7] = utf8 "Sairaalasi arvon pitää olla 240 000$, pankkitililläsi pitää olla 500 000$ ja maineesi pitää olla 700.",
  },
  level12 = {
    [1] = utf8 "Tämä on kaikkien haasteiden äiti. ",
    [2] = utf8 "Vaikuttuneena saavutuksistasi ministeriö on päättänyt antaa sinulle huipputyön; he haluavat toisen maailmanluokan sairaalan, joka tuottaa mainiosti ja jolla on erinomainen maine. ",
    [3] = utf8 "Sinun odotetaan myös ostavan kaikki saatavilla olevat maa-alueet, parantavan kaikki sairaudet (ja me tosiaan tarkoitamme kaikki) ja voittavan kaikki palkinnot. ",
    [4] = utf8 "Luuletko onnistuvasi?",
    [5] = utf8 "Ansaitse 650 000$, paranna 750 ihmistä ja hanki 800 mainetta voittaaksesi tämän.",
  },
  level13 = {
    [1] = utf8 "Uskomattomat kykysi sairaalanjohtajana ovat tulleet Salaisen erityispalvelun erityisen salaosaston tietoon. ",
    [2] = utf8 "Heillä on sinulle erityinen bonus: täynnä rottia oleva sairaala, joka kaipaa kipeästi tehokasta tuholaistorjuntaa. ",
    [3] = utf8 "Sinun pitää ampua mahdollisimman monta rottaa ennen kuin huoltomiehet siivoavat kaikki roskat pois. ",
    [4] = utf8 "Uskotko olevasi tehtävän tasalla?",
  },
  level14 = {
    [1] = utf8 "Vielä yksi haaste on tarjolla - täysin odottamaton yllätyssairaala. ",
    [2] = utf8 "Jos onnistut saamaan tämän paikan toimimaan, olet todellinen mestareiden mestari. ",
    [3] = utf8 "Älä kuvittelekkaan, että tästä tulee helppoa kuin puistossa kävely, sillä tämä on pahin haaste, jonka saat vastaasi. ",
    [4] = utf8 "Paljon onnea!",
  },
  level15 = {
    [1] = utf8 "Nyt olemme käsitelleet perusteet sairaalan saamiseksi toimintaan.//",
    [2] = utf8 "Lääkärisi tarvitsevat kaiken mahdollisen avun diagnosoidessaan osan näistä potilaista. ",
    [3] = utf8 "Voit auttaa heitä rakentamalla toisen diagnoosihuoneen kuten yleislääkärin vastaanoton.",
  },
  level16 = {
    [1] = utf8 "Diagnosoituasi potilaita tarvitset hoitohuoneita ja klinikoita heidän parantamisekseen ",
    [2] = utf8 "Apteekista on hyvä aloittaa. Toimiakseen se tarvitsee sairaanhoitajan annostelemaan lääkkeitä.",
  },
  level17 = {
    [1] = utf8 "Viimeinen varoituksen sana: pidä tarkasti silmällä mainettasi, sillä se houkuttelee sairaalaasi potilaita niin läheltä kuin kaukaa. ",
    [2] = utf8 "Jos potilaita ei kuole liikaa ja he pysyvät kohtuullisen tyytyväisinä, sinulla ei ole mitään hätää tällä tasolla!//",
    [3] = utf8 "Olet nyt omillasi. Onnea ja menestystä!.",
  },
  level18 = {
  },
}

-- 10. Tips
totd_window = {
  tips = {
    utf8 "Jokainen sairaala tarvitsee vastaanoton ja yleislääkärin toimiston. Tämän jälkeen kaikki riippuu siitä, mitä potilaasi tarvitsevat. Apteekki on kuitenkin yleensä hyvä alku.",
    utf8 "Kaikki laitteet, kuten verikone, tarvitsevat huoltoa. Palkkaa huoltomies tai pari korjaamaan laitteitasi tai työntekijöillesi ja potilaillesi saattaa käydä hassusti.",
    utf8 "Työntekijäsi kaipaavat välillä taukoja. Muista rakentaa heille henkilökunnan huone, jossa he voivat käydä lepäämässä.",
    utf8 "Asenna sairaalaasi riittävästi lämpöpattereita, jotta henkilökunnalle ja asiakkaille ei tule kylmä.",
    utf8 "Lääkärin taidot vaikuttavat paljon hänen tekemiensä diagnoosien laatuun ja nopeuteen. Palkkaamalla hyvän lääkärin yleislääkärin toimistoon tarvitset vähemmän muita diagnoosihuoneita.",
    utf8 "Tohtorit ja harjoittelijat voivat parantaa taitojaan oppimalla konsulteilta koulutushuoneessa. Jos konsultti on erikoistunut johonkin alaan (kirurgia, psykiatria tai tutkimus) hän siirtää tämän alan osaamisensa myös oppilailleen.",
    utf8 "Oletko kokeillut syöttää yleisen hätänumeron (112) faksiin? Varmista, että sinulla on äänet päällä!",
    utf8 "Asetukset-valikkoa ei ole vielä toteutettu, mutta voit muuttaa asetuksia kuten resoluutiota ja kieltä muokkaamalla config.txt-tiedostoa pelin asennushakemistossa.",
    utf8 "Olet vaihtanut kielen suomeksi. Jos kuitenkin näet pelissä englannin kielistä tekstiä, voit auttaa suomentamalla puuttuvia tekstejä!",
    utf8 "CorsixTH-tiimi etsii aina vahvistuksia! Oletko kiinnostunut ohjelmoimaan, kääntämään tai laatimaan grafiikkaa CorsixTH:ta varten? Saat meihin yhteyden Foorumimme, Sähköpostilistamme tai IRC-kanavamme (corsix-th at freenode) kautta.",
    utf8 "Jos löydät pelistä bugin, ilmoitathan niistä buginseurantaamme: th-issues.corsix.org.",
    utf8 "Jokaisella tasolla on joukko vaatimuksia, jotka sinun tulee täyttää ennen kuin pääset siirtymään seuraavalle tasolle. Voit tarkastella edistymistäsi tilanne-valikosta.",
    utf8 "Jos haluat muokata huonetta tai poistaa sen, voit tehdä niin ruudun alareunassa olevasta työkalupalkista löytyvän muokkaa huonetta -painikkeen avulla.",
    utf8 "Viemällä hiiren osoittimen huoneen päälle saat nopeasti tietää, ketkä ulkopuolella olevien potilaiden rykelmässä odottavat pääsyä kyseiseen huoneeseen.",
    utf8 "Klikkaa huoneen ovea nähdäksesi sen jonon. Tässä ikkunassa voit tehdä hyödyllistä hienosäätöä kuten järjestää jonon uudestaan tai lähettää potilaita toiseen huoneeseen.",
    utf8 "Tyytymättömät työntekijät pyytävät useammin palkankorotuksia. Pidä huolta, että he työskentelevät mukavassa ympäristössä välttääksesi tätä.",
    utf8 "Potilaat tulevat janoisiksi odottaessaan sairaalassasi; erityisesti, jos nostat lämpötilaa! Aseta juoma-automaatteja strategisesti ympäri sairaalaasi saadaksesi vähän lisätuloja.",
    utf8 "Voit peruuttaa potilaan diagnosoinnin ennenaikaisesti ja arvata hoidon, jos olet törmännyt kyseiseen tautiin jo aiemmin. Muista kuitenkin, että tämä lisää väärästä hoidosta aiheutuvan kuoleman riskiä.",
    utf8 "Hätätilanteet voivat olla hyvä ylimääräisen rahan lähde olettaen, että sairaalallasi on riittävästi kapasiteettia hätätilannepotilaiden hoitamiseen ajoissa.",
  },
  previous      = utf8 "Edellinen vihje",
  next          = utf8 "Seuraava vihje",
}

-- 11. Room descriptions (These were not present with the old strings so I assume they are new then)
room_descriptions = {
  blood_machine = {
    [1] = utf8 "Verikonehuone//",
    [2] = utf8 "Verikone tutkii potilaan verisoluja selvittääkseen mikä häntä vaivaa.//",
    [3] = utf8 "Verikone tarvitsee käyttäjäkseen lääkärin ja huoltoa huoltomieheltä. ",
  },
  cardiogram = {
    [1] = utf8 "Kardiogrammihuone//",
    [2] = utf8 "Potilaan sydän tutkitaan täällä ja hänet lähetetään takaisin yleislääkärin vastaanotolle, jossa määrätään sopiva hoito.//",
    [3] = utf8 "Kardiogrammikone tarvitsee käyttäjäkseen lääkärin ja huoltoa huoltomieheltä. ",
  },
  decontamination = {
    [1] = utf8 "Säteilyklinikka//",
    [2] = utf8 "Säteilylle altistuneet potilaat ohjataan nopeasti säteilyklinikalle. Huoneessa on suihku, jolla huuhdellaan potilaista kaikki kammottava radioaktiivinen aines ja lika.//",
    [3] = utf8 "Puhdistussuihku tarvitsee käyttäjäkseen lääkärin ja huoltoa huoltomieheltä. ",
  },
  dna_fixer = {
    [1] = utf8 "DNA-klinikka//",
    [2] = utf8 "Potilaat, jotka ovat joutuneet alieneiden kynsiin, tarvitsevat DNA-vaihdon tässä huoneessa. DNA-korjain on hyvin monimutkainen kone, joten on suositeltavaa pitää vaahtosammutin sen kanssa samassa huoneessa varmuuden vuoksi.//",
    [3] = utf8 "DNA-korjain tarvitsee käyttäjäkseen tutkimukseen erikoistuneen lääkärin ja säännöllistä huoltoa huoltomieheltä. ",
  },
  electrolysis = {
    [1] = utf8 "Elektrolyysihuone//",
    [2] = utf8 "Turkinkasvusta kärsivät potilaat ohjataan tähän huoneeseen, jossa elektrolyysikone nyppii karvat pois ja sulkee huokoset sähköisesti käyttäen ainetta joka muistuttaa saumauslaastia.//",
    [3] = utf8 "Elektrolyysikone tarvitsee käyttäjäkseen lääkärin ja huoltoa huoltomieheltä. ",
  },
  fracture_clinic = {
    [1] = utf8 "Murtumaklinikka//",
    [2] = utf8 "Ne epäonniset potilaat, joilla on murtumia luissaan lähetetään tänne. Kipsinpoistin leikkaa voimakkailla laser-säteillä kovettuneet kipsit pois aiheuttaen vain vähän tuskaa potilaalle.//",
    [3] = utf8 "Kipsinpoistin tarvitsee käyttäjäkseen sairaanhoitajan ja satunnaista huoltoa huoltomieheltä. ",
  },
  general_diag = {
    [1] = utf8 "Yleinen diagnoosihuone//",
    [2] = utf8 "Potilaat, jotka tarvitsevat jatkotutkimusta lähetetään tänne tutkittaviksi. Jos yleislääkärin vastaanotolla ei selviä, mikä potilasta vaivaa, yleisessä diagnoosihuoneessa monesti selviää. Potilaat lähetetään täältä takaisin yleislääkärin vastaanotolle tulosten analysointia varten.//",
    [3] = utf8 "Yleiseen diagnoosihuoneeseen tarvitaan lääkäri. ",
  },
  gp = {
    [1] = utf8 "Yleislääkärin vastaanotto//",
    [2] = utf8 "Tämä on sairaalasi perusdiagnoosihuone. Kaikki uudet potilaat lähetetään tänne lääkärin tutkittaviksi ja täältä heidät ohjataan joko jatkotutkimuksiin tai huoneeseen, jossa heidät voidaan parantaa. Saatat tarvita toisen yleislääkärin vastaanoton, jos ensimmäisestä tulee liian kiireinen. Mitä suurempi huone ja mitä enemmän lisäkalusteita sinne ostat sitä arvostetummaksi lääkäri tuntee itsensä. Tämä pätee myös kaikkiin muihin huoneisiin, joissa tarvitaan henkilökuntaa.//",
    [3] = utf8 "Yleislääkärin vastaanotolle tarvitaan lääkäri. ",
  },
  hair_restoration = {
    [1] = utf8 "Hiusklinikka//",
    [2] = utf8 "Kaljuudesta kärsivät potilaat ohjataan tällä klinikalla olevalle hiustenpalauttimelle. Lääkäri ohjaa konetta, joka kylvää potilaan päähän nopealla tahdilla tuorreita hiuksia.//",
    [3] = utf8 "Hiustenpalautin tarvitsee käyttäjäkseen lääkärin ja huoltoa huoltomieheltä. ",
  },
  inflation = {
    [1] = utf8 "Pumppaushuone//",
    [2] = utf8 "Kivuliaasta mutta huvittavasta pallopäisyydestä kärsivien potilaiden pitää mennä pumppaushuoneeseen, jossa heidän ylisuuri nuppinsa puhkaistaan ja täytetään sopivaan paineeseen.//",
    [3] = utf8 "Pumppauskone tarvitsee käyttäjäkseen lääkärin ja säännöllistä huoltoa huoltomieheltä. ",
  },
  jelly_vat = {
    [1] = utf8 "Hyytelöklinikka//",
    [2] = utf8 "Potilaiden, jotka sairastavat hyytelöitymistä, täytyy huojua hyytelöklinikalle ja asettua hyytelömuovaimeen. Tämä parantaa heidät vielä lääketieteelle tuntemattomalla tavalla.//",
    [3] = utf8 "Hyytelömuovain tarvitsee käyttäjäkseen lääkärin ja huoltoa huoltomieheltä. ",
  },
  no_room = {
    [1] = utf8 "",
  },
  operating_theatre = {
    [1] = utf8 "Leikkaussali//",
    [2] = utf8 "Tämä on tärkeä huone, sillä täällä hoidetaan lukuisia eri sairauksia. Leikkaussalin tulee olla riittävän suuri ja siellä pitää olla oikeat välineet. Se on elintärkeä osa sairaalaasi.//",
    [3] = utf8 "Leikkaussaliin tarvitaan kaksi kirurgiaan erikoistunutta lääkäriä. ",
  },
  pharmacy = {
    [1] = utf8 "Apteekki//",
    [2] = utf8 "Potilaat, joilla on diagnosoitu lääkkeillä parantuva sairaus, ohjataan apteekkiin hakemaan lääkkeensä. Sitä mukaa, kun uusia lääkehoitoja kehitetään, apteekki tulee kiireisemmäksi, joten toisen apteekin rakentaminen myöhemmin saattaa tulla tarpeen.//",
    [3] = utf8 "Apteekkiin tarvitaan sairaanhoitaja. ",
  },
  psych = {
    [1] = utf8 "Psykiatrin vastaanotto//",
    [2] = utf8 "Psykologisista sairauksista kärsivät potilaat lähetetään keskustelemaan psykiatrin kanssa. Psykiatrit voivat tarkentaa potilaan diagnoosia ja hoitaa psykologisia sairauksia uskollisen sohvansa avulla.//",
    [3] = utf8 "Psykiatrin vastaanotolle tarvitaan psykiatriaan erikoistunut lääkäri. ",
  },
  research = {
    [1] = utf8 "Tutkimusosasto//",
    [2] = utf8 "Täällä kehitetään uusia lääkkeitä ja hoitoja sekä parannellaan vanhoja. Tutkimusosasto on tärkeä osa tehokasta sairaalaa ja se tekee ihmeitä hoitoprosentillesi.//",
    [3] = utf8 "Tutkimusosastolle tarvitaan tutkimukseen erikoistunut lääkäri. ",
  },
  scanner = {
    [1] = utf8 "Magneettikuvaushuone//",
    [2] = utf8 "Potilaille saadaan tarkka diagnoosi edistyneen magneettikuvaimen avulla. Tämän jälkeen heidät lähetetään takaisin yleislääkärin vastaanotolle, jossa heille määrätään sopiva hoito.//",
    [3] = utf8 "Magneettikuvain tarvitsee käyttäjäkseen lääkärin ja huoltoa huoltomieheltä. ",
  },
  slack_tongue = {
    [1] = utf8 "Kieliklinikka//",
    [2] = utf8 "Potilaat, joilla yleislääkäri on todennut velttokielisyyden, lähetetään tänne hoitoon. Lääkäri käyttää kehittynyttä paloittelukonetta kielen venyttämiseen ja katkaisee sen normaaliin mittaansa parantaen potilaan.//",
    [3] = utf8 "Paloittelukone tarvitsee käyttäjäkseen lääkärin ja huoltoa huoltomieheltä. ",
  },
  staff_room = {
    [1] = utf8 "Henkilökunnan taukohuone//",
    [2] = utf8 "Henkilökuntasi väsyy suorittaessaan työtehtäviään. He käyttävät tätä huonetta rentoutumiseen ja lepäämiseen. Väsyneet työntekijät toimivat hitaammin, tekevät enemmän kohtalokkaita virheitä, vaativat palkankorotuksia ja eroavat lopulta palveluksestasi. Taukohuoneen rakentaminen on siis hyvin kannattavaa. Varmista, että huone on riittävän suuri useammalle henkilölle ja että siellä on riittävästi tekemistä henkilökunnallesi. ",
  },
  toilets = {
    [1] = utf8 "Käymälä//",
    [2] = utf8 "Potilaat, joita luonto kutsuu, voivat helpottaa oloaan käymälässäsi. Voit rakentaa enemmän eriöitä ja pesualtaita, jos odotat paljon potilaita. Joissain tilanteissa voi olla parempi rakentaa useampia käymälöitä eri puolille sairaalaasi. ",
  },
  training = {
    [1] = utf8 "Koulutushuone//",
    [2] = utf8 "Harjoittelijasi ja tohtorisi voivat oppia arvokkaita erikoistumistaitoja opiskelemalla tässä huoneessa. Konsultti, joka on erikoistunut kirurgiaan, tutkimukseen tai psykiatriaan siirtää näitä taitojaan koulutettavina oleville lääkäreille. Lääkärit, joilla jo on koulutus opetettavista erikoistumisaloista parantavat kykyään käyttää taitojaan täällä.//",
    [3] = utf8 "Koulutushuoneeseen tarvitaan konsultti. ",
  },
  tv_room = {
    [1] = utf8 "TV-HUONE EI KÄYTÖSSÄ",
  },
  ultrascan = {
    [1] = utf8 "Ultraäänihuone//",
    [2] = utf8 "Ultraäänilaite on pitkälle kehittynyt diagnoosilaite. Se maksaa paljon, mutta on sen arvoinen, jos haluat saada ensiluokkaisia diagnooseja sairaalassasi.//",
    [3] = utf8 "Ultraäänilaite tarvitsee käyttäjäkseen lääkärin ja huoltoa huoltomieheltä. ",
  },
  ward = {
    [1] = utf8 "Vuodeosasto//",
    [2] = utf8 "Potilaita pidetään täällä vuodelevossa tarkkailtavina diagnosoinnin aikana ja ennen leikkausta.//",
    [3] = utf8 "Vuodeosastolle tarvitaan sairaanhoitaja. ",
  },
  x_ray = {
    [1] = utf8 "Röntgenhuone//",
    [2] = utf8 "Röntgenillä kuvataan potilaiden sisäelimet ja luusto käyttäen erityistä säteilylähdettä. Hoitohenkilökunta saa näin hyvän kuvan siitä, mikä potilasta vaivaa.//",
    [3] = utf8 "Röntgen tarvitsee käyttäjäkseen lääkärin ja huoltoa huoltomieheltä. ",
  },
}

-- 12. Lua console
lua_console = {
  execute_code  = utf8 "Suorita",
  close         = utf8 "Sulje",
}

-- 13. Information
information = {
  custom_game           = utf8 "Tervetuloa pelaamaan CorsixTH:ta. Toivottavasti viihdyt tällä itse laaditulla kartalla!",
  cannot_restart        = utf8 "Valitettavasti tämä peli on tallennettu ennen uudelleen käynnistämisen toteuttamista.",
  level_lost            = {
    utf8 "Harmin paikka! Olet hävinnyt tämän tason. Parempaa onnea ensi kerralla!",
    utf8 "Syy tappioosi oli:",
    reputation          = utf8 "Maineesi putosi alle %d:n.",
    balance             = utf8 "Pankkitilisi saldo putosi alle %d$:n.",
    percentage_killed   = utf8 "Olet tappanut yli %d prosenttia potilaista.",
  },
}

-- 14. Misc
misc = {
  not_yet_implemented   = utf8 "(ei toteutettu vielä)",
  no_heliport           = utf8 "Joko yhtään tautia ei vielä tunneta tai sairaalalla ei ole helikopterikenttää",
}

-------------------------------------------------------------------------------
--   SECTION B - OLD STRINGS (OVERRIDE)
-------------------------------------------------------------------------------

-- Staff class
-- each of these corresponds to a sprite
staff_class = {
  nurse         = utf8 "Sairaanhoitaja",
  doctor        = utf8 "Lääkäri",
  handyman      = utf8 "Huoltomies",
  receptionist  = utf8 "Vastaanottoapulainen",
  surgeon       = utf8 "Kirurgi",
}

-- Staff titles
-- these are titles used e.g. in the dynamic info bar
staff_title = {
  receptionist  = utf8 "Vastaanottoapulainen",
  general       = utf8 "Yleinen", -- unused?
  nurse         = utf8 "Sairaanhoitaja",
  junior        = utf8 "Harjoittelija",
  doctor        = utf8 "Tohtori",
  surgeon       = utf8 "Kirurgi",
  psychiatrist  = utf8 "Psykiatri",
  consultant    = utf8 "Konsultti",
  researcher    = utf8 "Tutkija",
}

-- Pay rises
pay_rise = {
  definite_quit = utf8 "Et voi enää pidätellä minua mitenkään. Se on loppu nyt!",
  regular = {
    utf8 "Olen ihan loppuunpalanut. Vaadin kunnon tauon ja %d$:n palkankorotuksen, jos et halua nähdä minun kävelevän ympäriinsä ja valittavan käytävillä.", -- %d (rise)
    utf8 "Olen hyvin väsynyt. Vaadin lepoa ja %d$:n palkankorotuksen eli yhteensä %d$ palkkaa. Se saa kelvata, senkin tyranni!", -- %d (rise) %d (new total)
    utf8 "Anteeksi kuinka? Raadan täällä kuin orja. Anna minulle %d$:n bonus niin tulen sairaalaasi.", -- %d (rise)
    utf8 "Olen niin masentunut, että haluan %d$:n palkankorotuksen, joka tekee yhteensä %d$, tai muuten otan lopputilin.", -- %d (rise) %d (new total)
    utf8 "Vanhempani käskivät opiskella lääkäriksi, että saisin kunnon palkkaa. Anna minulle siis %d$ lisää liksaa, tai lähden täältä nopeammin kuin uskotkaan.", -- %d (rise)
    utf8 "Nyt olen vihainen. Anna minulle enemmän palkkaa. Uskoisin, että %d$ lisää riittää tällä erää.", -- %d (rise)
  },
  poached = utf8 "Minulle on tarjottu %d$ palkkaa %s-nimisen kilpailijasi sairaalassa. Siirryn sinne töihin, ellet anna minulle vastaavaa palkankorotusta.", -- %d (new total) %s (competitor)
}

-- Staff descriptions
staff_descriptions = {
  good = {
    [1] = utf8 "Hyvin nopea ja ahkera työntekijä. ",
    [2] = utf8 "Hyvin velvollisuudentuntoinen. Oikein huolellinen. ",
    [3] = utf8 "Todella monipuolinen. ",
    [4] = utf8 "Ystävällinen ja aina hyvällä tuulella. ",
    [5] = utf8 "Äärimmäisen sisukas. Työskentelee yöt ja päivät. ",
    [6] = utf8 "Uskomattoman kohtelias ja hyvätapainen. ",
    [7] = utf8 "Uskomattoman ammattitaitoinen ja osaava. ",
    [8] = utf8 "Hyvin keskittynyt ja arvostettu työssään. ",
    [9] = utf8 "Perfektionisti, joka ei koskaan luovuta. ",
    [10] = utf8 "Auttaa aina ihmisiä hymyssä suin. ",
    [11] = utf8 "Hurmaava, kohtelias ja auttavainen. ",
    [12] = utf8 "Hyvin motivoitunut ja omistautunut työlleen. ",
    [13] = utf8 "Luonteeltaan kiltti ja ahkera. ",
    [14] = utf8 "Lojaali ja ystävällinen. ",
    [15] = utf8 "Huomaavainen. Rauhallinen ja luotettava hätätilanteissa. ",
  },
  misc = {
    [1] = utf8 "Pelaa Golfia. ",
    [2] = utf8 "Pitää kampasimpukoista. ",
    [3] = utf8 "Veistää jääpatsaita. ",
    [4] = utf8 "Juo viiniä. ",
    [5] = utf8 "Ajaa rallia. ",
    [6] = utf8 "Harrastaa benjihyppyä. ",
    [7] = utf8 "Kerää lasinalusia. ",
    [8] = utf8 "Harrastaa yleisösurffausta. ",
    [9] = utf8 "Nauttii vauhdikkaasta surffaamisesta. ",
    [10] = utf8 "Pitää ankeriaiden venyttämisestä. ",
    [11] = utf8 "Tislaa viskiä. ",
    [12] = utf8 "Tee-se-itse ekspertti. ",
    [13] = utf8 "Pitää ranskalaisista taide-elokuvista. ",
    [14] = utf8 "Pelaa OpenTTD-peliä. ",
    [15] = utf8 "C-ajokortin ylpeä omistaja. ",
    [16] = utf8 "Osallistuu moottoripyöräkilpailuihin. ",
    [17] = utf8 "Soittaa klassista viulua ja selloa. ",
    [18] = utf8 "Innokas junanromuttaja. ",
    [19] = utf8 "Koiraihminen. ",
    [20] = utf8 "Kuuntelee radiota. ",
    [21] = utf8 "Kylpee usein. ",
    [22] = utf8 "Opettaa bambunletitystä. ",
    [23] = utf8 "Valmistaa saippuakuppeja vihanneksista. ",
    [24] = utf8 "Osa-aikainen miinanraivaaja. ",
    [25] = utf8 "Visailumestari. ",
    [26] = utf8 "Kerää sirpaleita 2. maailmansodasta. ",
    [27] = utf8 "Pitää sisustamisesta. ",
    [28] = utf8 "Kuuntelee rave- ja trip-hop-musikkia. ", --see original for trip-hop
    [29] = utf8 "Tappaa hyönteisiä deodorantilla. ",
    [30] = utf8 "Pitää kamalia stand up -esityksiä. ",
    [31] = utf8 "Tekee ostoksia sairaalaneuvostolle. ",
    [32] = utf8 "Salaperäinen puutarhuri. ",
    [33] = utf8 "Salakuljettaa piraattikelloja. ",
    [34] = utf8 "Rock-bändin laulaja. ",
    [35] = utf8 "Rakastaa TV:n katselua päivällä. ",
    [36] = utf8 "Kalastaa taimenia. ",
    [37] = utf8 "Houkuttelee turisteja museoon. ",
  },
  bad = {
    [1] = utf8 "Hidas ja nirso. ",
    [2] = utf8 "Laiska ja heikosti motivoitunut. ",
    [3] = utf8 "Huonosti koulutettu ja hyödytön. ",
    [4] = utf8 "Tyhmä ja ärsyttävä. Toimii sijaisena. ",
    [5] = utf8 "Alhainen kestävyys. Hänellä on huono ryhti. ",
    [6] = utf8 "Tyhmä kuin saapas. Haisee kaalilta. ",
    [7] = utf8 "Ei välitä työstään. Ei ota vastuuta. ",
    [8] = utf8 "Keskittymisvaikeuksia, häiriintyy helposti. ",
    [9] = utf8 "Stressaantunut ja tekee runsaasti virheitä. ",
    [10] = utf8 "Suuttuu helposti. Mököttää vihaisena. ",
    [11] = utf8 "Varomaton ja epäonninen. ",
    [12] = utf8 "Ei välitä työstään. Epäaktiivinen. ",
    [13] = utf8 "Uhkarohkea ja piittaamaton. ",
    [14] = utf8 "Viekas ja ovela. Puhuu muista pahaa. ",
    [15] = utf8 "Ylimielinen ja mahtaileva. ",
  },
} 

-- Staff list
staff_list = {
  morale        = utf8 "MORAALI",
  tiredness     = utf8 "VÄSYMYS",
  skill         = utf8 "TAITO",
  total_wages   = utf8 "KOKONAISPALKKA",
}

-- Objects
object = {
  desk                  = utf8 "Toimistopöytä",
  cabinet               = utf8 "Arkistokaappi",
  door                  = utf8 "Ovi",
  bench                 = utf8 "Penkki",
  table1                = utf8 "Pöytä", -- unused object
  chair                 = utf8 "Tuoli",
  drinks_machine        = utf8 "Juoma-automaatti",
  bed                   = utf8 "Sänky",
  inflator              = utf8 "Pumppauskone",
  pool_table            = utf8 "Biljardipöytä",
  reception_desk        = utf8 "Vastaanottopöytä",
  table2                = utf8 "Pöytä", -- unused object & duplicate
  cardio                = utf8 "Kardiogrammikone",
  scanner               = utf8 "Magneettikuvain",
  console               = utf8 "Konsoli",
  screen                = utf8 "Sermi",
  litter_bomb           = utf8 "Roskapommi",
  couch                 = utf8 "Sohva",
  sofa                  = utf8 "Sohva",
  crash_trolley         = utf8 "Kärry",
  tv                    = utf8 "TV",
  ultrascanner          = utf8 "Ultraäänilaite",
  dna_fixer             = utf8 "DNA-korjain",
  cast_remover          = utf8 "Kipsinpoistin",
  hair_restorer         = utf8 "Hiustenpalautin",
  slicer                = utf8 "Paloittelukone",
  x_ray                 = utf8 "Röntgen",
  radiation_shield      = utf8 "Säteilysuoja",
  x_ray_viewer          = utf8 "Röntgenkatselin",
  operating_table       = utf8 "Leikkauspöytä",
  lamp                  = utf8 "Lamppu", -- unused object
  toilet_sink           = utf8 "Pesuallas",
  op_sink1              = utf8 "Allas",
  op_sink2              = utf8 "Lavuaari",
  surgeon_screen        = utf8 "Kirurgin sermi",
  lecture_chair         = utf8 "Luentotuoli",
  projector             = utf8 "Projektori",
  bed2                  = utf8 "Sänky", -- unused duplicate
  pharmacy_cabinet      = utf8 "Lääkekaappi",
  computer              = utf8 "Tietokone",
  atom_analyser         = utf8 "Atomianalysaattori",
  blood_machine         = utf8 "Verikone",
  fire_extinguisher     = utf8 "Vaahtosammutin",
  radiator              = utf8 "Lämpöpatteri",
  plant                 = utf8 "Kasvi",
  electrolyser          = utf8 "Elektrolyysikone",
  jelly_moulder         = utf8 "Hyytelömuovain",
  gates_of_hell         = utf8 "Manalan portit",
  bed3                  = utf8 "Sänky", -- unused duplicate
  bin                   = utf8 "Roskakori",
  toilet                = utf8 "Eriö",
  swing_door1           = utf8 "Heiluriovi",
  swing_door2           = utf8 "Heiluriovi",
  shower                = utf8 "Puhdistussuihku",
  auto_autopsy          = utf8 "Ruumiinavauskone",
  bookcase              = utf8 "Kirjahylly",
  video_game            = utf8 "Videopeli",
  entrance_left         = utf8 "Sisäänkäynnin vasen ovi",
  entrance_right        = utf8 "Sisäänkäynnin oikea ovi",
  skeleton              = utf8 "Luuranko",
  comfortable_chair     = utf8 "Mukava tuoli",
  litter                = utf8 "Roska",
}

-- Place objects window
place_objects_window = {
  drag_blueprint                = utf8 "Muuta suunnitelmaa kunnes olet tyytyväinen siihen",
  place_door                    = utf8 "Aseta ovi paikalleen",
  place_windows                 = utf8 "Aseta joitakin ikkunoita, jos haluat. Vahvista, kun olet valmis",
  place_objects                 = utf8 "Aseta kalusteet paikalleen. Vahvista, kun olet valmis",
  confirm_or_buy_objects        = utf8 "Voit hyväksyä huoneen, jatkaa kalusteiden ostamista tai siirtää kalusteita",
  pick_up_object                = utf8 "Klikkaa kalusteita poimiaksesi ne ylös tai tee toinen valinta ikkunasta",
  place_objects_in_corridor     = utf8 "Aseta kalusteita käytävään",
}

-- Competitor names
competitor_names = {
  [1] = utf8 "ORAAKKELI",
  [2] = utf8 "TÖPPÖ",
  [3] = utf8 "KOLOSSI",
  [4] = utf8 "NULJASKA",
  [5] = utf8 "PYHIMYS",
  [6] = utf8 "SYVÄ AJATUS",
  [7] = utf8 "ZEN",
  [8] = utf8 "LEO",
  [9] = utf8 "AKIRA",
  [10] = utf8 "SAMI",
  [11] = utf8 "KAARLE",
  [12] = utf8 "JANNE",
  [13] = utf8 "ARTTURI",
  [14] = utf8 "MATTI",
  [15] = utf8 "MAMMA",
  [16] = utf8 "SARI",
  [17] = utf8 "KUNKKU",
  [18] = utf8 "JOONAS",
  [19] = utf8 "TANELI",
  [20] = utf8 "OLIVIA",
  [21] = utf8 "NIKKE",
}

-- Months
months = {
  "Tam",
  "Hel",
  "Maa",
  "Huh",
  "Tou",
  "Kes",
  "Hei",
  "Elo",
  "Syy",
  "Lok",
  "Mar",
  "Jou",
}

-- Graphs
graphs = {
  money_in      = utf8 "Tulot",
  money_out     = utf8 "Menot",
  wages         = utf8 "Palkat",
  balance       = utf8 "Rahavarat",
  visitors      = utf8 "Vierailijoita",
  cures         = utf8 "Parantumisia",
  deaths        = utf8 "Kuolemia",
  reputation    = utf8 "Maine",
  
  time_spans = {
    utf8 "1 vuosi",
    utf8 "12 vuotta",
    utf8 "48 vuotta",
  }
}

-- Transactions
transactions = {
  --null                = S[8][ 1], -- not needed
  wages                 = utf8 "Palkat",
  hire_staff            = utf8 "Palkkaa henkilökuntaa",
  buy_object            = utf8 "Osta kalusteita",
  build_room            = utf8 "Rakenna huoneita",
  cure                  = utf8 "Hoitokeino",
  buy_land              = utf8 "Osta maata",
  treat_colon           = utf8 "Hoito:",
  final_treat_colon     = utf8 "Viimeisin hoito:",
  cure_colon            = utf8 "Hoitokeino:",
  deposit               = utf8 "Hoitomaksut",
  advance_colon         = utf8 "Ennakko:",
  research              = utf8 "Tutkimuskustannukset",
  drinks                = utf8 "Tulot: juoma-automaatti",
  jukebox               = utf8 "Tulot: jukeboksi", -- unused
  cheat                 = utf8 "Huijaukset",
  heating               = utf8 "Lämmityskustannukset",
  insurance_colon       = utf8 "Vakuutus:",
  bank_loan             = utf8 "Pankkilaina",
  loan_repayment        = utf8 "Lainan lyhennys",
  loan_interest         = utf8 "Lainan korko",
  research_bonus        = utf8 "Tutkimusbonus",
  drug_cost             = utf8 "Lääkekustannukset",
  overdraft             = utf8 "Tilin ylitys",
  severance             = utf8 "Irtisanomiskustannukset",
  general_bonus         = utf8 "Yleisbonus",
  sell_object           = utf8 "Myy kalusteita",
  personal_bonus        = utf8 "Henkilökunnan bonukset",
  emergency_bonus       = utf8 "Hätätilannebonukset",
  vaccination           = utf8 "Rokotukset",
  epidemy_coverup_fine  = utf8 "Sakot epidemian peittelystä",
  compensation          = utf8 "Valtion tuet",
  vip_award             = utf8 "VIP-palkkinnot",
  epidemy_fine          = utf8 "Epidemiasakot",
  eoy_bonus_penalty     = utf8 "Vuosittaiset bonukset/sakot",
  eoy_trophy_bonus      = utf8 "Vuoden palkintobonukset",
  machine_replacement   = utf8 "Vaihtolaitteiden kustannukset",
}


-- Level names
level_names = {
  utf8 "Lahjala",
  utf8 "Unikylä",
  utf8 "Isola",
  utf8 "Kotokartano",
  utf8 "Lepikylä",
  utf8 "Susimetsä",
  utf8 "Kaukala",
  utf8 "Puolitie",
  utf8 "Tammikuja",
  utf8 "Tiukylä",
  utf8 "Kaarela",
  utf8 "Kannosto",
  utf8 "Kamukylä",
  utf8 "Pikku-Rajala",
  utf8 "Vaatimala",
}


-- Town map
town_map = {
  chat         = utf8 "Chat",
  for_sale     = utf8 "Myytävänä",
  not_for_sale = utf8 "Ei myytävänä",
  number       = utf8 "Tonttinumero", 
  owner        = utf8 "Omistaja",
  area         = utf8 "Pinta-ala",
  price        = utf8 "Hinta",
}


-- Rooms short
-- NB: includes some special "rooms"
-- reception, destroyed room and "corridor objects"
rooms_short = {
  reception         = utf8 "Vastaanotto",
  destroyed         = utf8 "Tuhoutunut",
  corridor_objects  = utf8 "Käytäväkalusteet",
  
  gps_office        = utf8 "Yleislääkäri",
  psychiatric       = utf8 "Psykiatria",
  ward              = utf8 "Vuodeosasto",
  operating_theatre = utf8 "Leikkaussali",
  pharmacy          = utf8 "Apteekki",
  cardiogram        = utf8 "Kardiogrammi",
  scanner           = utf8 "Magneettikuvaus",
  ultrascan         = utf8 "Ultraääni",
  blood_machine     = utf8 "Verikone",
  x_ray             = utf8 "Röntgen",
  inflation         = utf8 "Pumppaushuone",
  dna_fixer         = utf8 "DNA-klinikka",
  hair_restoration  = utf8 "Hiusklinikka",
  tongue_clinic     = utf8 "Kieliklinikka",
  fracture_clinic   = utf8 "Murtumaklinikka",
  training_room     = utf8 "Koulutushuone",
  electrolysis      = utf8 "Elektrolyysiklinikka",
  jelly_vat         = utf8 "Hyytelöklinikka",
  staffroom         = utf8 "Taukohuone",
  -- rehabilitation = utf8 "Vieroitushuone", -- unused
  general_diag      = utf8 "Yleinen diagnoosi",
  research_room     = utf8 "Tutkimusosasto",
  toilets           = utf8 "Käymälä",
  decontamination   = utf8 "Säteilyklinikka",
}

-- Rooms long
rooms_long = {
  general           = utf8 "Yleinen", -- unused?
  emergency         = utf8 "Hätätilanne",
  corridors         = utf8 "Käytävät",
  
  gps_office        = utf8 "Yleislääkärin vastaanotto",
  psychiatric       = utf8 "Psykiatrin vastaanotto",
  ward              = utf8 "Vuodeosasto",
  operating_theatre = utf8 "Leikkaussali",
  pharmacy          = utf8 "Apteekki",
  cardiogram        = utf8 "Kardiogrammihuone",
  scanner           = utf8 "Magneettikuvaushuone",
  ultrascan         = utf8 "Ultraäänihuone",
  blood_machine     = utf8 "Verikonehuone",
  x_ray             = utf8 "Röntgenhuone",
  inflation         = utf8 "Pumppaushuone",
  dna_fixer         = utf8 "DNA-klinikka",
  hair_restoration  = utf8 "Hiusklinikka",
  tongue_clinic     = utf8 "Kieliklinikka",
  fracture_clinic   = utf8 "Murtumaklinikka",
  training_room     = utf8 "Koulutushuone",
  electrolysis      = utf8 "Elektrolyysiklinikka",
  jelly_vat         = utf8 "Hyytelöklinikka",
  staffroom         = utf8 "Henkilökunnan taukohuone",
  -- rehabilitation = utf8 "Vieroitushuone", -- unused
  general_diag      = utf8 "Yleinen diagnoosihuone",
  research_room     = utf8 "Tutkimusosasto",
  toilets           = utf8 "Käymälä",
  decontamination   = utf8 "Säteilyklinikka",
}

-- Drug companies
drug_companies = {
  utf8 "Hoidake Yhtiöt",
  utf8 "Para 'N' Nus",
  utf8 "Pyöreät pikku-pillerit Oy",
  utf8 "Tyyrislääke Oyj",
  utf8 "Kaik-tabletit Ky",
}

-- Build rooms
build_room_window = {
  pick_department   = utf8 "Valitse osasto",
  pick_room_type    = utf8 "Valitse huonetyyppi",
  cost              = utf8 "Hinta: ",
}

-- Build objects
buy_objects_window = {
  choose_items      = utf8 "Valitse kalusteet",
  price             = utf8 "Hinta:",
  total             = utf8 "Yhteensä:",
}

-- Research
research = {
  categories = {
    cure            = utf8 "Hoitomenetelmät",
    diagnosis       = utf8 "Diagnoosimenetelmät",
    drugs           = utf8 "Lääketutkimus",
    improvements    = utf8 "Laitteisto",
    specialisation  = utf8 "Erikoistuminen",
  },
  
  funds_allocation  = utf8 "Myönnettävissä rahastosta",
  allocated_amount  = utf8 "Myönnetty rahasumma",
}

-- Policy screen
policy = {
  header            = utf8 "SAIRAALAN KÄYTÄNNÖT",
  diag_procedure    = utf8 "diagnosointikäytäntö",
  diag_termination  = utf8 "hoidon lopettaminen",
  staff_rest        = utf8 "taukokäytäntö",
  staff_leave_rooms = utf8 "salli tauolle poistuminen",
  
  sliders = {
    guess           = utf8 "ARVAA HOITO", -- belongs to diag_procedure
    send_home       = utf8 "LÄHETÄ KOTIIN", -- also belongs to diag_procedure
    stop            = utf8 "LOPETA HOITO", -- belongs to diag_termination
    staff_room      = utf8 "PIDÄ TAUKO", -- belongs to staff_rest
  }
}

-- Rooms
room_classes = {
  -- S[19][2] -- "Käytävät" - unused for now
  diagnosis  = utf8 "Diagnoosi",
  treatment  = utf8 "Hoito",
  clinics    = utf8 "Klinikat",
  facilities = utf8 "Toimitilat",
}

-- Insurance companies
insurance_companies = {
  out_of_business   = utf8 "KONKURSSISSA",
  utf8 "Kuorittu Sipuli Oy",
  utf8 "Pohjanmaalainen",
  utf8 "Sääntövakuutukset Oy",
  utf8 "Itikka Yhtiöt",
  utf8 "Uniturva",
  utf8 "Vam Pyyri Ky",
  utf8 "Sureol Vakuutusyhtiö",
  utf8 "Okto Pus ja kumppanit",
  utf8 "Larinnon Henkiturva",
  utf8 "Glade Vakuutukset Oy",
  utf8 "Mafia Vakuutus Oyj",
}

-- Menu root
-- Keep 2 spaces as prefix and suffix
menu = {
  file          = utf8 "  TIEDOSTO  ",
  options       = utf8 "  VALINNAT  ",
  display       = utf8 "  NÄYTÄ  ",
  charts        = utf8 "  TILASTOT  ",
  debug         = utf8 "  DEBUG  ",
}

-- Menu File
menu_file = {
  load          = utf8 "  LATAA  ",
  save          = utf8 "  TALLENNA  ",
  restart       = utf8 "  ALOITA ALUSTA  ",
  quit          = utf8 "  LOPETA  ",
}
menu_file_load = {
  [1] = utf8 "  PELI 1  ",
  [2] = utf8 "  PELI 2  ",
  [3] = utf8 "  PELI 3  ",
  [4] = utf8 "  PELI 4  ",
  [5] = utf8 "  PELI 5  ",
  [6] = utf8 "  PELI 6  ",
  [7] = utf8 "  PELI 7  ",
  [8] = utf8 "  PELI 8  ",
}

-- Menu Options
menu_options = {
  sound                 = utf8 "  ÄÄNI  ",
  announcements         = utf8 "  KUULUTUKSET  ",
  music                 = utf8 "  MUSIIKKI  ",
  sound_vol             = utf8 "  ÄÄNENVOIMAKKUUS  ",
  announcements_vol     = utf8 "  KUULUTUSTEN VOIMAKKUUS  ",
  music_vol             = utf8 "  MUSIIKIN VOIMAKKUUS  ",
  autosave              = utf8 "  AUTOMAATTITALLENNUS  ",
  game_speed            = utf8 "  PELINOPEUS  ",
  jukebox               = utf8 "  JUKEBOKSI  ",
  edge_scrolling        = utf8 "  REUNAVIERITYS  ",
  settings              = utf8 "  ASETUKSET  ",
  lock_windows          = utf8 "  LUKITSE IKKUNAT  "
}

-- Menu Display
menu_display = {
  high_res      = utf8 "  KORKEA RESOLUUTIO  ",
  mcga_lo_res   = utf8 "  MCGA - MATALA RESOLUUTIO  ",
  shadows       = utf8 "  VARJOT  ",
}

-- Menu Charts
menu_charts = {
  statement     = utf8 "  TILIOTE  ",
  casebook      = utf8 "  TAPAUSKIRJA  ",
  policy        = utf8 "  KÄYTÄNNÖT  ",
  research      = utf8 "  TUTKIMUS  ",
  graphs        = utf8 "  GRAAFIT  ",
  staff_listing = utf8 "  TYÖNTEKIJÄT  ",
  bank_manager  = utf8 "  PANKINJOHTAJA  ",
  status        = utf8 "  TILANNE  ",
  briefing      = utf8 "  TIIVISTELMÄ  ",
}

-- Menu Debug
menu_debug = {
  object_cells          = utf8 "  KALUSTESOLUT        ",
  entry_cells           = utf8 "  SYÖTESOLUT          ",
  keep_clear_cells      = utf8 "  PIDÄ TYHJÄNÄ -SOLUT ",
  nav_bits              = utf8 "  NAVIGOINTIBITIT     ",
  remove_walls          = utf8 "  POISTA SEINÄT       ",
  remove_objects        = utf8 "  POISTA KALUSTEET    ",
  display_pager         = utf8 "  NÄYTÄ VIESTIT       ",
  mapwho_checking       = utf8 "  MAPWHO-TARKISTUS    ",
  plant_pagers          = utf8 "  KASVIVIESTIT        ",
  porter_pagers         = utf8 "  KANTOVIESTIT        ",
  pixbuf_cells          = utf8 "  PIXBUF-SOLUT        ",
  enter_nav_debug       = utf8 "  SYÖTÄ NAVIG. DEBUG  ",
  show_nav_cells        = utf8 "  NÄYTÄ NAVIG. SOLUT  ",
  machine_pagers        = utf8 "  LAITEVIESTIT        ",
  display_room_status   = utf8 "  NÄYTÄ HUONEEN TILA  ",
  display_big_cells     = utf8 "  NÄYTÄ SUURET SOLUT  ",
  show_help_hotspot     = utf8 "  NÄYTÄ APUPISTEET    ",
  win_game_anim         = utf8 "  PELIN VOITTOANIM.   ",
  win_level_anim        = utf8 "  KENTÄN VOITTOANIM.  ",
  lose_game_anim = {
    [1]  = utf8 "  HÄVITTY PELI 1 ANIM  ",
    [2]  = utf8 "  HÄVITTY PELI 2 ANIM  ",
    [3]  = utf8 "  HÄVITTY PELI 3 ANIM  ",
    [4]  = utf8 "  HÄVITTY PELI 4 ANIM  ",
    [5]  = utf8 "  HÄVITTY PELI 5 ANIM  ",
    [6]  = utf8 "  HÄVITTY PELI 6 ANIM  ",
    [7]  = utf8 "  HÄVITTY PELI 7 ANIM  ",
  },
}

-- High score screen
high_score = {
  pos           = utf8 "SIJOITUS",
  player        = utf8 "PELAAJA",
  score         = utf8 "PISTEITÄ",
  best_scores   = utf8 "HALL OF FAME",
  worst_scores  = utf8 "HALL OF SHAME",
  killed        = utf8 "Kuolleita", -- is this used?
  
  categories = {
    money               = utf8 "RIKKAIN",
    salary              = utf8 "KORKEIN PALKKA",
    clean               = utf8 "PUHTAIN",
    cures               = utf8 "PARANTUNEIDEN MÄÄRÄ",
    deaths              = utf8 "KUOLLEIDEN MÄÄRÄ",
    cure_death_ratio    = utf8 "PARANTUNEET-KUOLLEET-SUHDE",
    patient_happiness   = utf8 "POTILAIDEN TYYTYVÄISYYS",
    staff_happiness     = utf8 "HENKILÖSTÖN TYYTYVÄISYYS",
    staff_number        = utf8 "ENITEN HENKILÖKUNTAA",
    visitors            = utf8 "ENITEN POTILAITA",
    total_value         = utf8 "KOKONAISARVO",
  },
}

-- Trophy room
trophy_room = {
  many_cured = {
    awards = {
      utf8 "Onnittelut Marie Curie -palkinnosta: olet onnistunut parantamaan suurimman osan sairaalaan saapuneista potilaista viime vuonna.",
    },
    trophies = {
      utf8 "Kansainvälinen lääkintähallitus toivottaa onnea hyvästä paranemisten osuudesta sairaalassasi viime vuonna. He myöntävät täten sinulle Puolet parannettu -kunniamaininnan.",
      utf8 "Sinulle on myönnetty Ei sairaana kotiin -kunniamaininta, koska ole parantanut suurimman osan sairaalaasi saapuneista potilaista viime vuonna.",
    },
  },
  all_cured = {
    awards = {
      utf8 "Onnittelut Marie Curie -palkinnosta: olet onnistunut parantamaan kaikki sairaalaan saapuneet potilaat viime vuonna.",
    },
    trophies = {
      utf8 "Kansainvälinen lääkintähallitus toivottaa onnea hyvästä paranemisten osuudesta sairaalassasi viime vuonna. He myöntävät täten sinulle Kaikki parannettu -kunniamaininnan.",
      utf8 "Sinulle on myönnetty Ei sairaana kotiin -kunniamaininta, koska ole parantanut kaikki sairaalaasi saapuneet potilaat.",
    },
  },
  high_rep = {
    awards = {
      utf8 "Sinulle myönnetään täten sisäministeriön Kiiltävät sairaalastandardit -palkinto, joka myönnetään vuosittain parhaan maineen saavuttaneelle sairaalalle. Onneksi olkoon!",
      utf8 "Ole hyvä ja ota vastaan Bullfrog-palkinto, joka myönnetään maineeltaan vuoden parhaalle sairaalalle. Olet ehdottomasti ansainnut sen!",
    },
    trophies = {
      utf8 "Onnittelut Siisti ja kaunis -kunniamaininnasta, joka myönnetään vuosittain sairaalalle, jolla on paras maine. Tämä kunnianosoitus meni takuulla oikeaan osoitteeseen!",
    },
  },
  happy_staff = {
    awards = {
    },
    trophies = {
      utf8 "Sinulle on myönnetty Hymynaama-kunniamaininta ahkeran henkilökuntasi pitämisestä niin tyytyväisenä kuin mahdollista.",
      utf8 "Mielialainstituutti on todennut, ettei kenelläkään ollut sinun sairaalassassi huolia tai murheita viime vuonna ja se antaa sinulle tunnustuksena tästä kunniamaininnan.",
      utf8 "Aurinko paistaa aina -kunniamaininta myönnetään täten sinulle, koska olet onnistunut pitämään henkilöstösi tyytyväisenä koko vuoden huolimatta valtaisasta työmäärästä. Hymyä huuleen!",
    },
  },
  happy_vips = {
    awards = {
      utf8 "Olet voittanut Nobel-palkinnon hoidettuasi VIP-potilaasi kunnialla. Kenelläkään viime vuonna sairaalassasi vierailleista VIP-potilaista ei ollut mitään pahaa sanottavaa.",
      utf8 "Onnittelut VIP-palkinnosta, joka myönnetään työteliäiden julkkisten elämänlaadun parantamisesta. Viime vuonna joka ainoa julkimo lähti sairaalastasi paremmalla tuulella kuin saapui sinne.",
    },
    trophies = {
      utf8 "Tunnettujen henkilöiden toimisto haluaa palkita sinut Julkkis-kunniamaininnalla, koska olet pitänyt hyvää huolta kaikista VIP-potilaistasi. Olet jo itsekin melkein tunnettu!",
    },
  },
  no_deaths = {
    awards = {
      utf8 "Olet voittanut Elä pitkään -palkinnon pidettyäsi viime vuoden aikana 100 prosenttia potilaistasi hengissä.",
    },
    trophies = {
      utf8 "Elämä jatkuu -komitea on myöntänyt sinulle nimikkokunniamainintansa, koska olet selvinnyt ilman ainuttakaan kuolemantapausta koko viime vuoden.",
      utf8 "Sinulle on myönnetty Pidä elämästä kiinni -kunniamaininnan onnistuttuasi välttämään kuolemantapaukset kuluneena vuonna kokonaan. Mahtavuutta!",
    },
  },
  rats_killed = {
    awards = {
    },
    trophies = {
      utf8 "Sinulle on myönnetty Nolla tuholaista -kunniamaininta, koska sairaalassasi on ammuttu %d rottaa vuoden aikana.", -- %d (number of rats)
      utf8 "Otat vastaaan rottien ja hiirten vastaisen järjestön kunniamaininnan erinomaisen rotta-ammuntasi johdosta. Otit hengiltä %d jyrsijää viime vuonna.", -- %d (number of rats)
      utf8 "Onnittelut Rotta-ampuja-kunniamaininnasta, jonka sait osoitettuasi erityistä lahjakkuutta hävittämällä %d rottaa sairaalastasi kuluneen vuoden aikana.", -- %d (number of rats)
    },
  },
  rats_accuracy = {
    awards = {
    },
    trophies = {
      utf8 "Sinulle on myönnetty Kiitettävä ampuja toivottomassa sodassa -kunniamaininta, koska osamatarkkuutesi inhottavien rottien jahtaamisessa oli %d%% viime vuonna.", -- %d (accuracy percentage)
      utf8 "Tämä kunniamaininta on osoitus taitavuudestasi saatuasi hengiltä %d%% rotista, joita ammuit viime vuonna.", -- %d (accuracy percentage)
      utf8 "Olet osoittanut suurta tarkkuutta tappaessasi %d%% kaikista sairaalasi rotista ja sinulle on myönnetty Dungeon Keeper -kunniamaininta. Rottaiset onnittelut!", -- %d (accuracy percentage)
    },
  },
  healthy_plants = {
    awards = {
      utf8 "Onnittelut Kasvukausi-palkinnosta! Olet onnistunut pitämään sairaalasi kasvit erinomaisessa kunnossa koko vuoden.",
    },
    trophies = {
      utf8 "Ruukasvien ystävät -järjestö myöntää sinulle Vihreä terveys -kunniamaininnan, koska olet pitänyt hyvää huolta sairaalasi kasveista viimeiset 12 kuukautta.",
      utf8 "Sinulle on myönnetty Viherpeukalo-kunniamainnita, koska kasveiltasi ei ole puuttunut vettä eikä hoitoa viime vuonna.",
    },
  },
  sold_drinks = {
    awards = {
    },
    trophies = {
      utf8 "Kansainvälinen automaattiyhdistys on ylpeä voidessaan antaa sinulle kunniamaininnan sairaalassasi viime vuonna myytyjen virvoitusjuomien suuresta määrästä.",
      utf8 "Sairaalallesi on myönnetty Ravistetut tölkit -kunniamaininta viime vuoden aikana myytyjen virvoitusjuomatölkkien määrästä.",
      utf8 "Suomen hammaspaikat Oy on myöntänyt sinulle kunniamaininnan, koska sairaalasi on ansiokkaasti edistänyt virvoitusjuomien myyntiä viime vuonna.",
    },
  },
}


-- Casebook screen
casebook = {
  reputation            = utf8 "maine",
  treatment_charge      = utf8 "hoidon hinta",
  earned_money          = utf8 "tulot yhteensä",
  cured                 = utf8 "parannettuja",
  deaths                = utf8 "kuolleita",
  sent_home             = utf8 "kotiin lähetettyjä",
  research              = utf8 "kohdista tutkimusta",
  cure                  = utf8 "hoito",
  cure_desc = {
    build_room          = utf8 "Tarvitset huoneen: %s", -- %s (room name)
    build_ward          = utf8 "Tarvitset nopeasti vuodeosaston.",
    hire_doctors        = utf8 "Tarvitset lisää lääkäreitä.",
    hire_surgeons       = utf8 "Tarvitset lisää kirurgeja.",
    hire_psychiatrists  = utf8 "Tarvitset lisää psykologeja.",
    hire_nurses         = utf8 "Tarvitset lisää sairaanhoitajia.",
    no_cure_known       = utf8 "Ei tunnettuja hoitoja.",
    cure_known          = utf8 "Hoito tunnetaan.",
    improve_cure        = utf8 "Parannettu hoito",
  },
}

-- Tooltips
tooltip = {
  
  -- Build room window
  build_room_window = {
    room_classes = {
      diagnosis         = utf8 "Valitse diagnoosihuone",
      treatment         = utf8 "Valitse yleinen hoitohuone",
      clinic            = utf8 "Valitse erityisklinikka",
      facilities        = utf8 "Valitse laitokset",
    },
    cost                = utf8 "Kustannukset nykyisestä huoneesta",
    close               = utf8 "Keskeytä toiminto ja palaa peliin",
  },
  
  -- Toolbar
  toolbar = {
    bank_button         = utf8 "Vasen klikkaus: pankinjohtaja, oikea klikkaus: tiliote",
    balance             = utf8 "Tilin saldo",
    reputation          = utf8 "Maine:", -- NB: no %d! Append " ([reputation])".
    date                = utf8 "Päivä",
    rooms               = utf8 "Rakenna huone",
    objects             = utf8 "Osta kalusteita",
    edit                = utf8 "Muuta huonetta/kalusteita",
    hire                = utf8 "Palkkaa henkilökuntaa",
    staff_list          = utf8 "Henkilökuntaluettelo",
    town_map            = utf8 "Kartta",
    casebook            = utf8 "Hoitokirja",
    research            = utf8 "Tutkimus",
    status              = utf8 "Tilanne",
    charts              = utf8 "Kuvaajat",
    policy              = utf8 "Sairaalan käytännöt",
  },
  
  -- Hire staff window
  hire_staff_window = {
    doctors             = utf8 "Näytä työtä etsivät lääkärit",
    nurses              = utf8 "Näytä työtä etsivät sairaanhoitajat",
    handymen            = utf8 "Näytä työtä etsivät huoltomiehet",
    receptionists       = utf8 "Näytä työtä etsivät vastaanottoapulaiset",
    prev_person         = utf8 "Näytä edellinen",
    next_person         = utf8 "Näytä seuraava",
    hire                = utf8 "Palkkaa",
    cancel              = utf8 "Peruuta",
    doctor_seniority    = utf8 "Kokemus (Harjoittelija, Tohtori, Konsultti)",
    staff_ability       = utf8 "Kyvyt",
    salary              = utf8 "Palkkavaatimus",
    qualifications      = utf8 "Erikoistumisalat",
    surgeon             = utf8 "Kirurgi",
    psychiatrist        = utf8 "Psykiatri",
    researcher          = utf8 "Tutkija",
  },
  
  -- Buy objects window
  buy_objects_window = {
    price               = utf8 "Kalusteen hinta",
    total_value         = utf8 "Ostettujen kalusteiden kokonaisarvo",
    confirm             = utf8 "Osta kaluste(et)",
    cancel              = utf8 "Peruuta",
    increase            = utf8 "Kasvata valitun kalusteen ostetavaa määrää",
    decrease            = utf8 "Pienennä valitun kalusteen ostettavaa määrää",
  },
  
  -- Staff list
  staff_list = {
    doctors             = utf8 "Näytä katsaus lääkäreistäsi",
    nurses              = utf8 "Näytä katsaus sairaanhoitajistasi",
    handymen            = utf8 "Näytä katsaus huoltomiehistäsi",
    receptionists       = utf8 "Näytä katsaus vastaanottoapulaisistasi",
    
    happiness           = utf8 "Näyttää, kuinka tyytyväisiä työntekijäsi ovat",
    tiredness           = utf8 "Näyttää, kuinka väsyneitä työntekijäsi ovat",
    ability             = utf8 "Näyttää työntekijöidesi kyvyt",
    salary              = utf8 "Työntekijälle maksettava palkka",
    
    happiness_2         = utf8 "Työntekijän tyytyväisyys",
    tiredness_2         = utf8 "Työntekijän väsymys",
    ability_2           = utf8 "Työntekijän kyvyt",
    
    prev_person         = utf8 "Näytä edellinen sivu",
    next_person         = utf8 "Näytä seuraava sivu",
    
    bonus               = utf8 "Anna työntekijälle 10%:n bonus",
    sack                = utf8 "Anna työntekijälle potkut",
    pay_rise            = utf8 "Nosta työntekijän palkkaa 10%",
    
    close               = utf8 "Sulje ikkuna",
    
    doctor_seniority    = utf8 "Lääkärin kokemus",
    detail              = utf8 "Yksityiskohtien huomioimiskyky",
    
    view_staff          = utf8 "Näytä työntekijä",
    
    surgeon             = utf8 "Erikoistunut kirurgiaan",
    psychiatrist        = utf8 "Erikoistunut psykiatriaan",
    researcher          = utf8 "Erikoistunut tutkimukseen",
    surgeon_train       = utf8 "%d%% suoritettu kirurgiaan erikoistumisesta", -- %d (percentage trained)
    psychiatrist_train  = utf8 "%d%% suoritettu psykiatriaan erikoistumisesta", -- %d (percentage trained)
    researcher_train    = utf8 "%d%% suoritettu tutkimukseen erikoistumisesta", -- %d (percentage trained)
    
    skills              = utf8 "Taidot",
  },
  
  -- Queue window
  queue_window = {
    num_in_queue        = utf8 "Jonottavien potilaiden määrä",
    num_expected        = utf8 "Vastaanotosta jonoon pian saapuvien potilaiden määrä",
    num_entered         = utf8 "Tässä huoneessa tähän mennessä hoidettujen potilaiden kokonaismäärä",
    max_queue_size      = utf8 "Vastaanotosta jonoon päästettävien potilaiden enimmäismäärä",
    dec_queue_size      = utf8 "Pienennä jonoon päästettävien potilaiden enimmäismäärää",
    inc_queue_size      = utf8 "Kasvata jonoon päästettävien potilaiden enimmäismäärää",
    front_of_queue      = utf8 "Vedä potilas tähän asettaaksesi hänet jonon ensimmäiseksi",
    end_of_queue        = utf8 "Vedä potilas tähän asettaaksesi hänet jonon viimeiseksi",
    close               = utf8 "Sulje ikkuna",
    patient             = utf8 "Siirrä potilasta jonossa vetämällä. Klikkaa oikealla lähettääksesi potilas kotiin, vastaanottoon tai kilpailevaan sairaalaan",
    patient_dropdown = {
      reception         = utf8 "Lähetä potilas vastaanottoon",
      send_home         = utf8 "Lähetä potilas kotiin",
      hospital_1        = utf8 "Lähetä potilas toiseen sairaalaan",
      hospital_2        = utf8 "Lähetä potilas toiseen sairaalaan",
      hospital_3        = utf8 "Lähetä potilas toiseen sairaalaan",
    },
  },
  
  -- Main menu
  main_menu = {
    new_game            = utf8 "Aloita uusi peli",
    load_game           = utf8 "Lataa aiemmin tallennettu peli",
    continue            = utf8 "Jatka edellistä peliä",
    network             = utf8 "Aloita verkkopeli",
    quit                = utf8 "Lopeta",
    load_menu = {
      load_slot         = utf8 "  PELI  ", -- NB: no %d! Append " [slotnumber]".
      empty_slot        = utf8 "  TYHJÄ  ",
    },
  },
  -- Window general
  window_general = {
    cancel              = utf8 "Peruuta",
    confirm             = utf8 "Vahvista",
  },
  -- Information dialog
  information = {
    close = "Sulje tiedoteikkuna",
  },
  -- Patient window
  patient_window = {
    close               = utf8 "Sulje ikkuna",
    graph               = utf8 "Klikkaa vaihtaaksesi potilaan terveyskuvaajan ja hoitohistorian välillä",
    happiness           = utf8 "Potilaan tyytyväisyys",
    thirst              = utf8 "Potilaan jano",
    warmth              = utf8 "Potilaan lämpötila",
    casebook            = utf8 "Näytä lisätietoja potilaan sairaudesta",
    send_home           = utf8 "Lähetä potilas kotiin sairaalasta",
    center_view         = utf8 "Keskitä näkymä potilaaseen",
    abort_diagnosis     = utf8 "Lähetä potilas suoraan hoitoon ennen diagnoosin valmistumista",
    queue               = utf8 "Näytä jono, jossa potilas on",
  },
  -- window
  staff_window = {
    name                = utf8 "Työntekijän nimi",
    close               = utf8 "Sulje ikkuna",
    face                = utf8 "Työntekijän kuva - avaa henkilökuntaluettelo klikkaamalla",
    happiness           = utf8 "Tyytyväisyys",
    tiredness           = utf8 "Väsymys",
    ability             = utf8 "Kyvyt",
    doctor_seniority    = utf8 "Kokemus (Harjoittelija, Tohtori, Konsultti)",
    skills              = utf8 "Erikoistuminen",
    surgeon             = utf8 "Kirurgi",
    psychiatrist        = utf8 "Psykiatri",
    researcher          = utf8 "Tutkija",
    salary              = utf8 "Kuukausipalkka",
    center_view         = utf8 "Keskitä näkymä työntekijään klikkaamalla vasemmalla, selaa työntekijöitä klikkaamalla oikealla",
    sack                = utf8 "Anna potkut",
    pick_up             = utf8 "Poimi työntekijä",
  },
  -- Machine window
  machine_window = {
    name                = utf8 "Koneen nimi",
    close               = utf8 "Sulje ikkuna",
    times_used          = utf8 "Käyttökertojen määrä",
    status              = utf8 "Koneen tila",
    repair              = utf8 "Kutsu huoltomies huoltamaan kone",
    replace             = utf8 "Korvaa kone uudella",
  },
  
  
  -- Handyman window
  -- Apparently handymen have their own set of strings (partly) containing "handyman".
  -- We could just get rid of this category and include the three prios into staff_window.
  handyman_window = {
    name                = utf8 "Huoltomiehen nimi", -- contains "handyman"
    close               = utf8 "Sulje ikkuna",
    face                = utf8 "Huoltomiehen kuva", -- contains "handyman"
    happiness           = utf8 "Tyytyväisyys",
    tiredness           = utf8 "Väsymys",
    ability             = utf8 "Kyvyt",
    prio_litter         = utf8 "Pyydä huoltomiestä keskittymään lattioiden siivoamiseen", -- contains "handyman"
    prio_plants         = utf8 "Pyydä huoltomiestä keskittymään kasvien kastelemiseen", -- contains "handyman"
    prio_machines       = utf8 "Pyydä huoltomiestä keskittymään koneiden huoltamiseen", -- contains "handyman"
    salary              = utf8 "Kuukausipalkka",
    center_view         = utf8 "Keskitä näkymä huoltomieheen", -- contains "handyman"
    sack                = utf8 "Anna potkut",
    pick_up             = utf8 "Poimi huoltomies",
  },
  
  -- Place objects window
  place_objects_window = {
    cancel              = utf8 "Peruuta",
    buy_sell            = utf8 "Osta/Myy kalusteita",
    pick_up             = utf8 "Poimi kaluste",
    confirm             = utf8 "Vahvista",
  },
  
  -- Casebook
  casebook = {
    up                  = utf8 "Vieritä ylös",
    down                = utf8 "Vieritä alas",
    close               = utf8 "Sulje hoitokirja",
    reputation          = utf8 "Hoito- ja diagnoosimaine lähialueella",
    treatment_charge    = utf8 "Hoidon hinta",
    earned_money        = utf8 "Tähän mennessä ansaittu rahasumma",
    cured               = utf8 "Parannettujen potilaiden määrä",
    deaths              = utf8 "Hoidon seurauksena kuolleiden potilaiden määrä",
    sent_home           = utf8 "Kotiin lähetettyjen potilaiden määrä",
    decrease            = utf8 "Laske hintaa",
    increase            = utf8 "Nosta hintaa",
    research            = utf8 "Klikkaa käyttääksesi tutkimusbudjettia taudin tutkimukseen ja sen hoitoon erikoistumiseen",
    cure_type = {
      drug              = utf8 "Tämä tauti vaatii lääkitystä",
      drug_percentage   = utf8 "Tämä tauti vaatii lääkitystä - sinun lääkkeesi tehokkuus on %d%%", -- %d (effectiveness percentage)
      psychiatrist      = utf8 "Tämä tauti vaatii psykiatrin hoitoa",
      surgery           = utf8 "Tämä tauti vaatii leikkauksen",
      machine           = utf8 "Tämä tauti vaatii erikoislaitteen",
    },
    
    cure_requirement = {
      possible          = utf8 "Voit hoitaa potilaan terveeksi",
      research_machine  = utf8 "Sinun täytyy kehittää erikoislaite hoitaaksesi sairautta",
      build_room        = utf8 "Sinun täytyy rakentaa hoitohuone hoitaaksesi sairautta",
      hire_surgeons     = utf8 "Tarvitset kaksi kirurgia hoitaaksesi sairautta", -- unused
      hire_surgeon      = utf8 "Tarvitset yhden kirurgin hoitaaksesi sairautta", -- unused
      hire_staff_old    = utf8 "Sinun täytyy palkata %s hoitaaksesi sairautta", -- %s (staff type), unused. Use hire_staff instead.
      build_ward        = utf8 "Sinun täytyy rakentaa vuodeosasto hoitaaksesi sairautta", -- unused
      ward_hire_nurse   = utf8 "Tarvitset sairaanhoitajan vuodeosastollesi hoitaaksesi sairautta", -- unused
      not_possible      = utf8 "Et voi vielä hoitaa sairautta", -- unused
    },
  },
  
  -- Statement
  statement = {
    close               = utf8 "Sulje tiliote",
  },
  
  -- Research
  research = {
    close               = utf8 "Poistu tutkimusosastolta",
    cure_dec            = utf8 "Laske hoitotutkimuksen tärkeysastetta",
    diagnosis_dec       = utf8 "Laske diagnoositutkimuksen tärkeysastetta",
    drugs_dec           = utf8 "Laske lääketutkimuksen tärkeysastetta",
    improvements_dec    = utf8 "Laske laitteistotutkimuksen tärkeysastetta",
    specialisation_dec  = utf8 "Laske erikoistumistutkimuksen tärkeysastetta",
    cure_inc            = utf8 "Nosta hoitotutkimuksen tärkeysastetta",
    diagnosis_inc       = utf8 "Nosta diagnoositutkimuksen tärkeysastetta",
    drugs_inc           = utf8 "Nosta lääketutkimuksen tärkeysastetta",
    improvements_inc    = utf8 "Nosta laitteistotutkimuksen tärkeysastetta",
    specialisation_inc  = utf8 "Nosta erikoistumistutkimuksen tärkeysastetta",
    allocated_amount    = utf8 "Tutkimukseen suunnattu rahoitus",
  },
  
  -- Graphs
  graphs = {
    close               = utf8 "Sulje kuvaajaikkuna",
    scale               = utf8 "Skaalaa diagrammia",
    money_in            = utf8 "Näytä/Piilota tulot",
    money_out           = utf8 "Näytä/Piilota menot",
    wages               = utf8 "Näytä/Piilota palkat",
    balance             = utf8 "Näytä/Piilota tilin saldo",
    visitors            = utf8 "Näytä/Piilota potilaat",
    cures               = utf8 "Näytä/Piilota parannetut",
    deaths              = utf8 "Näytä/Piilota kuolleet",
    reputation          = utf8 "Näytä/Piilota maine",
  },

  -- Town map
  town_map = {
    people              = utf8 "Näytä/Piilota ihmiset",
    plants              = utf8 "Näytä/Piilota kasvit",
    fire_extinguishers  = utf8 "Näytä/Piilota vaahtosammuttimet",
    objects             = utf8 "Näytä/Piilota kalusteet",
    radiators           = utf8 "Näytä/Piilota lämpöpatterit",
    heat_level          = utf8 "Lämpötila",
    heat_inc            = utf8 "Nosta lämpötilaa",
    heat_dec            = utf8 "Laske lämpötilaa",
    heating_bill        = utf8 "Lämmityskustannukset",
    balance             = utf8 "Tilin saldo",
    close               = utf8 "Sulje kartta",
  },
  
  -- Jukebox.
  jukebox = {
    current_title       = utf8 "Jukeboksi",
    close               = utf8 "Sulje jukeboksi-ikkuna",
    play                = utf8 "Käynnistä jukeboksi",
    rewind              = utf8 "Kelaa jukeboksia taakse",
    fast_forward        = utf8 "Kelaa jukeboksia eteen",
    stop                = utf8 "Pysäytä jukeboksi",
    loop                = utf8 "Toista jukeboksia silmukassa",
  },
  
  -- Bank Manager
  bank_manager = {
    hospital_value      = utf8 "Sairaalasi tämänhetkinen arvo",
    balance             = utf8 "Pankkitilisi saldo",
    current_loan        = utf8 "Pankkilainan määrä",
    repay_5000          = utf8 "Maksa pankille 5000 takaisin",
    borrow_5000         = utf8 "Lainaa pankilta 5000 lisää",
    interest_payment    = utf8 "Kuukausittaiset korkokustannukset",
    inflation_rate      = utf8 "Vuotuinen inflaatio",
    interest_rate       = utf8 "Vuotuinen korko",
    close               = utf8 "Poistu pankista",
    insurance_owed      = utf8 "Määrä, jonka %s on sinulle velkaa", -- %s (name of debitor)
    show_graph          = utf8 "Näytä velallisen %s maksusuunnitelma", -- %s (name of debitor)
    graph               = utf8 "Velallisen %s maksusuunnitelma", -- %s (name of debitor)
    graph_return        = utf8 "Palaa edelliseen näyttöön",
  },
  
  -- Status
  status = {
    win_progress_own    = utf8 "Näytä pelaajan edistyminen tämän tason vaatimusten suhteen",
    win_progress_other  = utf8 "Näytä kilpailijan %s edistyminen tämän tason vaatimusten suhteen", -- %s (name of competitor)
    population_chart    = utf8 "Kuvaaja, joka näyttää kuinka suuri osa paikallisesta väestöstä hakeutuu mihinkin sairaalaan hoidettavaksi",
    happiness           = utf8 "Kaikkien sairaalassasi olevien keskimääräinen tyytyväisyys",
    thirst              = utf8 "Kaikkien sairaalassasi olevien keskimääräinen janoisuus",
    warmth              = utf8 "Kaikkien sairaalassasi olevien keskimääräinen lämpötila",
    close               = utf8 "Sulje tilanneikkuna",
    reputation          = utf8 "Maineesi pitää olla vähintään %d. Tällä hetkellä se on %d", -- %d (target reputation) %d (current reputation)
    balance             = utf8 "Sinulla tulee olla rahaa tililläsi vähintää %d$. Tällä hetkellä sitä on %d$", -- %d (target balance) %d (current balance)
    population          = utf8 "%d%% alueen väestöstä pitää kuulua asiakaskuntaasi",
    num_cured           = utf8 "Tavoitteenasi on parantaa %d ihmistä. Tähän mennessä olet parantanut %d",
    percentage_killed   = utf8 "Tavoitteenasi on tappaa vähemmän kuin %d%% potilaistasi. Tähän mennessä olet tappanut %d%% heistä",
    value               = utf8 "Sairaalasi arvon tulee olla vähintään $%d. Nyt se on $%d",
    percentage_cured    = utf8 "Sinun pitää parantaa %d%% sairaalaasi saapuneista potilaista. Tähän mennessä olet parantanut %d%% heistä",
  },
  
  -- Policy
  policy = {
    close               = utf8 "Sulje käytännöt-ikkuna",
    staff_leave         = utf8 "Klikkaa tästä asettaaksesi henkilökunnan liikkumaan vapaasti huoneiden välillä ja auttamaan kollegojaan tarvittaessa",
    staff_stay          = utf8 "Klikkaa tästä asettaaksesi henkilökunnan pysymään huoneissa, joihin olet heidät asettanut",
    diag_procedure      = utf8 "Jos lääkärin diagnoosi on epävarmempi kuin LÄHETÄ KOTIIN-prosentti, lähetetään potilas kotiin. Jos diagnoosi on varmempi kuin ANNA HOITO-prosentti, lähetetään potilas suoraan hoitoon",
    diag_termination    = utf8 "Potilaan diagnoosia jatketaan, kunnes lääkärit ovat yhtä varmoja kuin KESKEYTÄ PROSESSI-prosentti tai kaikkia diagnoosikoneita on kokeiltu",
    staff_rest          = utf8 "Kuinka väsynyttä henkilöstön pitää olla ennen kuin he saavat levätä",
  },
  
  -- Pay rise window
  pay_rise_window = {
    accept              = utf8 "Myönny vaatimuksiin",
    decline             = utf8 "Kieltäydy vaatimuksista - Anna lopputili sen sijaan",
  },
  
  -- Watch
  watch = {
    hospital_opening    = utf8 "Rakennusaika: sinulla on tämän verran aikaa jäljellä ennen kuin sairaala avataan potilaille. Paina vihreää AVAA-nappia avataksesi sairaalasi välittömästi.",
    emergency           = utf8 "Hätätilanne: Akuuttien potilaiden parantamiseen jäljellä oleva aika.",
    epidemic            = utf8 "Epidemia: Epidemian taltuttamiseen jäljellä oleva aika. Kun aika kuluu loppuun TAI tartunnan saanut potilas poistuu sairaalasta, terveystarkastaja saapuu vierailulle. Paina nappia aloittaaksesi ja lopettaaksesi rokotukset. Klikkaa potilaita kutsuaksesi sairaanhoitajan rokottamaan heidät.",
  },
  
  -- Rooms
  rooms = {
    gps_office          = utf8 "Potilaat tutkitaan ja diagnosoidaan alustavasti yleislääkärin toimistossa.",
    psychiatry          = utf8 "Psykiatrin vastaanotolla hoidetaan mielenhäiriöistä kärsiviä potilaita ja autetaan diagnosoinnissa. Vaatii psykiatriaan erikoistuneen lääkärin",
    ward                = utf8 "Vuodeosasto on hyödyllinen sekä diagnosoinnissa että hoidossa. Potilaita lähetetään tänne tarkkailtavaksi ja toipumaan leikkauksen jälkeen. Vaatii sairaanhoitajan",
    operating_theatre   = utf8 "Leikkaussalissa tarvitaan kaksi kirurgiaan erikoistunutta lääkäriä",
    pharmacy            = utf8 "Apteekissa sairaanhoitaja jakaa lääkkeitä niitä tarvitseville potilaille",
    cardiogram          = utf8 "Lääkäri tutkii potilaiden sydänkäyriä kardiogrammin avulla ja diagnosoi sydäntauteja",
    scanner             = utf8 "Lääkäri käyttää magneettikuvausta potilaiden diagnosoimiseen",
    ultrascan           = utf8 "Lääkäri käyttää ultraääntä potilaiden diagnosoimiseen",
    blood_machine       = utf8 "Lääkäri käyttää verikonetta potilaiden veren tutkimiseen ja diagnosoimiseen",
    x_ray               = utf8 "Lääkäri kuvaa röntgenillä potilaiden luut ja tekee niiden perusteella diagnooseja",
    inflation           = utf8 "Lääkäri käyttää pumppauskonetta pallopäisyyttä sairastavien potilaiden hoitoon",
    dna_fixer           = utf8 "Lääkäri käyttää DNA-konetta alienin DNA:sta kärsivien potilaiden hoidossa",
    hair_restoration    = utf8 "Lääkäri käyttää hiustenpalautinta kaljuuntumisesta kärsivien potilaiden hoitoon",
    tongue_clinic       = utf8 "Kieliklinikalla lääkäri hoitaa potilaita, joilla on löyhä kieli",
    fracture_clinic     = utf8 "Murtumaklinikkalla sairaanhoitaja korjaa potilaiden murtumia",
    training_room       = utf8 "Konsultointiin erikoistunut lääkäri pitää luentoja koulutushuoneessa ja opettaa muita lääkäreitä",
    electrolysis        = utf8 "Elektrolyysiklinikkalla lääkäri hoitaa turkinkasvua sairastavia potilaita",
    jelly_vat           = utf8 "Lääkäri käyttää hyytelömuovainta hyytelöitymisestä kärsivien potilaiden parantamiseen",
    staffroom           = utf8 "Lääkärit, sairaanhoitajat ja huoltomiehet käyttävät taukohuonetta lepäämiseen ja mielialansa parantamiseen",
    -- rehabilitation   = S[33][27], -- unused
    general_diag        = utf8 "Lääkäri suorittaa täällä perusdiagnoosin yleislääkärillä vierailleille potilaille. Halpa ja monien sairauksien diagnosointiin varsin tehokas huone",
    research_room       = utf8 "Tutkimukseen erikoistunut lääkäri voi kehittää täällä uusia lääkkeitä ja koneita sairauksien parantamiseksi",
    toilets             = utf8 "Rakenna käymälä, jotta potilaat eivät sotke sairaalaasi!",
    decontamination     = utf8 "Säteilyklinikalla lääkäri hoitaa vakavasta säteilystä kärsiviä potilaita",
  },
  
  -- Objects
  objects = {
    -- NB: most objects do not have a tooltip because they're not (extra-)buyable
    desk                = utf8 "Pöytä: Lääkäri voi käyttää pöydällä tietokonettaan.",
    cabinet             = utf8 "Arkistokaappi: Pitää sisällään potilastietoja, muistiinpanoja ja tutkimusaineistoa.",
    door                = utf8 "Ovi: Ihmiset avaavat ja sulkevat tätä vähän väliä.",
    bench               = utf8 "Penkki: Tarjoaa potilaille istumapaikan ja tekee odottamisesta mukavampaa.",
    table1              = S[40][ 6], -- unused
    chair               = utf8 "Tuoli: Potilaat istuvat tässä ja kertovat ongelmistaan ja oireistaan.",
    drinks_machine      = utf8 "Juoma-automaatti: Pitää potilaiden janon kurissa ja tuottaa tuloja sairaalalle.",
    bed                 = utf8 "Sänky: Vakavasti sairaat potilaat makaavat näissä.",
    inflator            = utf8 "Pumppauskone: Parantaa potilaat, jotka sairastavat pallopäisyyttä.",
    pool_table          = utf8 "Biljardipöytä: Auttaa henkilökuntaasi rentoutumaan.",
    reception_desk      = utf8 "Vastaanotto: Vaatii vastaanottoapulaisen, joka opastaa potilaita eteenpäin.",
    table2              = S[40][13], -- unused & duplicate
    cardio              = S[40][14], -- no description
    scanner             = S[40][15], -- no description
    console             = S[40][16], -- no description
    screen              = S[40][17], -- no description
    litter_bomb         = utf8 "Roskapommi: Sabotoi kilpailijan sairaalaa",
    couch               = S[40][19], -- no description
    sofa                = utf8 "Sohva: Työntekijät, jotka ovat taukohuoneessa, istuvat paikallaan sohvalla kuin parempaa rentoutumistapaa ei olisikaan.",
    crash_trolley       = S[40][21], -- no description
    tv                  = utf8 "TV: Harmi, ettei henkilökunnallasi ole yleensä aikaa katsoa lempiohjelmaansa loppuun.",
    ultrascanner        = S[40][23], -- no description
    dna_fixer           = S[40][24], -- no description
    cast_remover        = S[40][25], -- no description
    hair_restorer       = S[40][26], -- no description
    slicer              = S[40][27], -- no description
    x_ray               = S[40][28], -- no description
    radiation_shield    = S[40][29], -- no description
    x_ray_viewer        = S[40][30], -- no description
    operating_table     = S[40][31], -- no description
    lamp                = S[40][32], -- unused
    toilet_sink         = utf8 "Pesuallas: Hygieniariippuvaiset potilaasi voivat pestä likaantuneet kätensä tässä. Jos altaita ei ole riittävästi, he tulevat tyytymättömiksi.",
    op_sink1            = S[40][34], -- no description
    op_sink2            = S[40][35], -- no description
    surgeon_screen      = S[40][36], -- no description
    lecture_chair       = utf8 "Luentotuoli: Lääkäriopiskelijasi istuvat tässä ja tuhertavat innokkaasti muistiinpanoja. Mitä enemmän tuoleja luokassa on sitä enemmän opiskelijoita sinne mahtuu.",
    projector           = S[40][38], -- no description
    bed2                = S[40][39], -- unused duplicate
    pharmacy_cabinet    = utf8 "Lääkekaappi: Lääkevalikoimasi löytyy täältä.",
    computer            = utf8 "Tietokone: Nerokas tiedonlähde",
    atom_analyser       = utf8 "Atomianalysaattori: Sijoitettuna tutkimusosastolle tämä nopeuttaa koko tutkimusprosessia.",
    blood_machine       = S[40][43], -- no description
    fire_extinguisher   = utf8 "Vaahtosammutin: Minimoi vaaran, jonka laitteiden vikaantuminen voi aiheuttaa.",
    radiator            = utf8 "Lämpöpatteri: Pitää huolta, ettei sairaalassasi pääse tulemaan kylmä.",
    plant               = utf8 "Kasvi: Pitää potilaiden mielialan korkealla ja puhdistaa ilmaa.",
    electrolyser        = S[40][47], -- no description
    jelly_moulder       = S[40][48], -- no description
    gates_of_hell       = S[40][49], -- no description
    bed3                = S[40][50], -- unused duplicate
    bin                 = utf8 "Roskakori: Potilaat heittävät roskansa tänne.",
    toilet              = utf8 "Eriö: Potilaat, öh... tekevät tarpeensa tänne.",
    swing_door1         = S[40][53], -- no description
    swing_door2         = S[40][54], -- no description
    shower              = S[40][55], -- no description
    auto_autopsy        = utf8 "Ruumiinavauskone: Mahtava apuväline uusien hoitomenetelmien kehittämisessä.",
    bookcase            = utf8 "Kirjahylly: Referenssimateriaalia lääkärille.",
    video_game          = utf8 "Videopeli: Anna henkilökuntasi rentoutua Hi-Octane-pelin parissa.",
    entrance_left       = S[40][59], -- no description
    entrance_right      = S[40][60], -- no description
    skeleton            = utf8 "Luuranko: Käytetään opetuksessa ja Halloween-koristeena.",
    comfortable_chair   = S[40][62], -- no description
  },
}

-- 32. Adviser
adviser = {
  
  -- Tutorial
  tutorial = {
    start_tutorial                      = utf8 "Lue tason kuvaus ja klikkaa hiiren vasemmalla painikkeella aloittaaksesi esittelyn.",
    build_reception                     = utf8 "Hei! Ensimmäisenä sairaalasi tarvitsee vastaanoton. Löydät sen osta kalusteita -valikosta.",
    order_one_reception                 = utf8 "Klikkaa hiiren vasemmalla painikkeella kerran vilkkuvaa aluetta valitaksesi yhden vastaanoton.",
    accept_purchase                     = utf8 "Klikkaa nyt vilkkuvaa aluetta ostaaksesi valitsemasi kalusteet.",
    rotate_and_place_reception          = utf8 "Klikkaa hiiren oikeaa painikketta pyörittääksesi vastaanotto haluamaasi suuntaan ja klikkaa vasemalla asettaaksesi se paikalleen.",
    reception_invalid_position          = utf8 "Vastaanotto näkyy harmaana, koska sitä ei voida sijoittaa tähän. Kokeile siirtää tai pyörittää sitä.",
    hire_receptionist                   = utf8 "Nyt tarvitset vastaanottoapulaisen ottamaan potilaasi vastaan ja ohjaamaan heidät oikeisiin huoneisiin.",
    select_receptionists                = utf8 "Klikkaa vilkkuvaa ikonia käydäksesi läpi saatavilla olevia vastaanottoapulaisia. Ikonissa näkyvä numero kertoo saatavilla olevien apulaisten määrän.",
    next_receptionist                   = utf8 "Tämä on listan ensimmäinen vastaanottoapulainen. Klikkaa vilkkuvaa ikonia nähdäksesi seuraavan henkilön.",
    prev_receptionist                   = utf8 "Klikkaa vilkkuvaa ikonia nähdäksesi edellisen henkilön.",
    choose_receptionist                 = utf8 "Valitse vastaanottoapulainen, jolla on hyvät taidot ja hyväksyttävä palkkavaatimus. Klikkaa vilkkuvaa ikonia palkataksesi hänet.",
    place_receptionist                  = utf8 "Poimi vastaanottoapulainen ja aseta hänet minne tahansa sairaalassasi. Hän löytää kyllä rakentamaasi vastaanottoon omin avuin.",
    receptionist_invalid_position       = utf8 "Et voi asettaa työntekijääsi tähän. Kokeile asettaa hänet sairaalan sisälle paikkaan, jossa on tyhjää lattiaa.",
    window_in_invalid_position          = utf8 "Ikkuna ei sovi tähän. Ole hyvä ja yritä asettaa se toiseen kohtaan seinällä.",
    choose_doctor                       = utf8 "Käy läpi kaikkien lääkäreiden taidot ja palkkavaatimukset ennen kuin päätät kenet haluat palkata.",
    click_and_drag_to_build             = utf8 "Rakentaaksesi yleislääkärin toimiston sinun pitää ensin päättää kuinka suuri siitä tulee. Pidä hiiren vasen nappi pohjassa ja vedä hiirtä muuttaaksesi huoneen kokoa.",
    build_gps_office                    = utf8 "Jotta voit alkaa diagnosoida potilaita, sinun pitää rakentaa yleislääkärin toimisto.",
    door_in_invalid_position            = utf8 "Hupsista! Yritit sijoittaa oven epäsopivaan paikkaan. Kokeile jotain toista kohtaa pohjapiirrustuksen seinässä.",
    confirm_room                        = utf8 "Klikkaa hiiren vasemmalla painikkeella vilkkuvaa ikonia, kun huone on valmis tai klikkaa X:ää palataksesi edelliseen vaiheeseen.",
    select_diagnosis_rooms              = utf8 "Klikkaa hiiren vasemmalla painikkeella vilkkuvaa ikonia nähdäksesi listan diagnoosihuoneista, joita voit rakentaa.",
    hire_doctor                         = utf8 "Tarvitset lääkärin tutkimaan ja hoitamaan potilaita.",
    select_doctors                      = utf8 "Klikkaa hiiren vasemmalla painikkeella vilkkuvaa ikonia nähdäksesi lääkärit, jotka ovat saatavilla työmarkkinoilla.",
    place_windows                       = utf8 "Aseta ikkunat paikalleen samaan tapaan kuin asetit oven. Sinun ei ole pakko rakentaa ikkunoita, mutta työntekijäsi eivät pitäisi siitä lainkaan.",
    place_doctor                        = utf8 "Aseta lääkäri minne tahansa sairaalassasi. Hän menee yleislääkärin toimistoon heti, kun joku tarvitsee hoitoa.",
    room_in_invalid_position            = utf8 "Hups! Tämä pohjapiirrustus ei kelpaa: punaiset alueet näyttävät, missä kohdin suunnitelmasi menee toisen huoneen päälle tai sairaalan ulkoseinien läpi.",
    doctor_in_invalid_position          = utf8 "Hei! Et voi laittaa lääkäriä tähän. Koeta sijoittaa hänet tyhjälle lattia-alueelle.",
    place_objects                       = utf8 "Klikkaa hiiren oikeaa painikketta pyörittääksesi kalusteita ja vasenta asettaaksesi ne paikalleen.",
    room_too_small                      = utf8 "Tämä pohjapiirrustus näkyy punaisena, koska se on liian pieni. Vedä hiirtä pidempi matka saadaksesi suurempi huone.",
    click_gps_office                    = utf8 "Klikkaa hiiren vasemmalla painikkeella vilkkuvaa aluetta valitaksesi yleislääkärin toimiston.",    
    room_too_small_and_invalid          = utf8 "Pohjapiirrustus on liian pieni ja väärin aseteltu. Kokeile uudestaan.",
    object_in_invalid_position          = utf8 "Tämä kaluste on väärin asetettu. Ole hyvä ja sijoita se toiseen paikkaan tai pyöritä sitä saadaksesi se sopimaan.",
    place_door                          = utf8 "Siirrä hiiri pohjapiirrustuksen reunalle asettaaksesi ovi haluamaasi paikkaan.",
    room_big_enough                     = utf8 "Pohjapiirrustus on riittävän suuri. Kun päästät hiiren painikkeen, asetat sen paikalleen. Voit halutessasi jatkaa sen muokkaamista.",
    build_pharmacy                      = utf8 "Onnittelut! Seuraavaksi kannattaa rakentaa Apteekki ja palkata sairaanhoitaja, jotta sairaalasi on täysin toimintavalmis.",
    information_window                  = utf8 "Tiedoteikkunassa kerrotaan lisätietoja juuri rakentamastasi yleislääkärin toimistosta.",
  },
  
  -- Epidemic
  epidemic = {
    hurry_up            = utf8 "Jos et ota nopeasti epidemiaa hallintaasi, siitä seuraa suuria ongelmia. Kiirehdi!",
    serious_warning     = utf8 "Tartuntatauti leviää sairaalassasi ja alkaa muodostua vakavaksi ongelmaksi. Sinun on tehtävä jotain ja pian!",
    multiple_epidemies  = utf8 "Sinulla näyttää olevan useampi kuin yksi epidemia riesanasi. Tästä voi seurata pahaa jälkeä, joten nyt on tulenpalava kiire.",
  },
  
  -- Staff advice
  staff_advice = {
    need_handyman_machines      = utf8 "Sinun täytyy palkata huoltomiehiä, jos haluat koneidesi pysyvän kunnossa.",
    need_doctors                = utf8 "Tarvitset useita lääkäreitä. Kokeile siirtää parhaat lääkärisi huoneisiin, joihin on pisin jono.",
    need_handyman_plants        = utf8 "Sinun täytyy palkata huoltomies kastelemaan kasvejasi, etteivät ne kuole.",
    need_handyman_litter        = utf8 "Ihmiset valittavat, että sairaalasi muistuttaa kaatopaikkaa. Palkkaa huoltomies siivoamaan potilaidesi sotkut.",
    need_nurses                 = utf8 "Tarvitset useita sairaanhoitajia. Vuodeosastoa ja apteekkia voivat hoitaa vain sairaanhoitajat.",
    too_many_doctors            = utf8 "Sairaalassasi on liikaa lääkäreitä. Osalla heistä ei ole mitään tekemistä.",
    too_many_nurses             = utf8 "Uskoisin, että sinulla on liikaa sairaanhoitajia palkkalistoillasi.",
  },
  
  -- Earthquake
  earthquake = {
    damage      = utf8 "Maanjäristys on vioittanut %d laitetta ja %d potilasta on loukkaantunut sairaalassasi.", -- %d (count machines), &d (count patients)
    alert       = utf8 "Maanjäristysvaroitus. Maanjäristys vahingoittaa laitteitasi ja ne voivat lakata toimimasta kokonaan, jos niitä ei ole huollettu kunnolla.",
    ended       = utf8 "Huh. Se tuntui voimakkaalta järistykseltä - magnitudiksi mitattiin %d Richterin asteikolla.",
  },
  
  -- Multiplayer
  multiplayer = {
    objective_completed = utf8 "Olet saavuttanut kaikki tämän tason tavoitteet. Onnittelut!",
    everyone_failed     = utf8 "Kukaan ei ole saavuttanut asetettuja tavoitteita. Kaikki saavat siis jatkaa yrittämistä!",
    players_failed      = utf8 "Seuraavat pelaajat eivät ole saavuttaneet asetettuja tavoitteita: ",
    objective_failed    = utf8 "Et ole onnistunut saavuttamaan tämän tason tavoitteita.",
    
    poaching = {
      in_progress                       = utf8 "Yritän tiedustella josko tämä henkilö olisi kiinnostunut siirtymään palvelukseesi.",
      not_interested                    = utf8 "Hah! Häntä ei kiinnosta tulla töihin sinulle - hänellä on kaikki hyvin nykyisissä työpaikassaan.",
      already_poached_by_someone        = utf8 "Turha haaveilla! Joku muu yrittää jo parhaillaan viedä tätä työntekijää.",
    },
  },
  
  -- Surgery requirements
  surgery_requirements = {
    need_surgeons_ward_op       = utf8 "Tarvitset kaksi kirurgia ja vuodeosaston leikkaussalin lisäksi voidaksesi suorittaa kirurgisia toimenpiteitä.",
    need_surgeon_ward           = utf8 "Tarvitset vuodeosaston ja yhden kirurgin lisää voidaksesi suorittaa kirurgisia toimenpiteitä.",
  },
  
  -- Vomit wave
  vomit_wave = {
    started     = utf8 "Sairaalaasi näyttää levinneen oksennustautia aiheuttava virus. Jos olisit palkannut lisää huoltomiehiä pitämään paikat puhtaina, näin ei olisi päässyt käymään.",
    ended       = utf8 "Huh! Viruksen aiheuttama oksennustauti on saatu kuriin. Pidä sairaalasi puhtaampana jatkossa.",
  },
  
  -- Level progress
  level_progress = {
    nearly_won          = utf8 "Olet miltei saavuttanut tämän tason tavoitteet.",
    three_quarters_lost = utf8 "Vain yksi neljännes erottaa sinut lopullisesta tappiosta.",
    halfway_won         = utf8 "Olet jo puolittain voittanut tämän tason.",
    halfway_lost        = utf8 "Toinen jalkasi on jo haudassa tavotteiden suhteen.",
    nearly_lost         = utf8 "Tappiosi on viimeistä naulaa vaille valmis.",
    three_quarters_won  = utf8 "Vain yksi neljännes tavoitteista on enää suorittamatta.",
  },
  
  -- Staff place advice
  staff_place_advice = {
    receptionists_only_at_desk  = utf8 "Vain vastaanottoapulaiset voivat työskennellä vastaanotossa.",
    only_psychiatrists          = utf8 "Vain psykiatriaan erikoistuneet lääkärit voivat työskennellä psykiatrin vastaanotolla.",
    only_surgeons               = utf8 "Vain kirurgiaan erikoistuneet lääkärit voivat työskennellä leikkaussalissa.",
    only_nurses_in_room         = utf8 "%s sopii ainoastaan sairaanhoitajan hoidettavaksi.",
    only_doctors_in_room        = utf8 "%s sopii ainoastaan lääkärin hoidettavaksi.",
    only_researchers            = utf8 "Vain tutkimukseen erikoistuneet lääkärit voivat työskennellä tutkimusosastolla.",
    nurses_cannot_work_in_room  = utf8 "%s ei sovellu sairaanhoitajan hoidettavaksi.",
    doctors_cannot_work_in_room = utf8 "%s ei sovellu lääkärin hoidettavaksi.",
  },
  
  -- Research
  research = {
    machine_improved            = utf8 "Kehittyneempi %s on valmistunut tutkimusosastollasi.",
    autopsy_discovered_rep_loss = utf8 "Tieto automaattisesta ruumiinavauskoneestasi on vuotanut julkisuuteen. Ihmisiltä on odotettavissa negatiivinen reaktio.",
    drug_fully_researched       = utf8 "Lääkkeen %s kehitystyö on saatu päätökseen.",
    new_machine_researched      = utf8 "Uusi %s on saatu kehitettyä.",
    drug_improved               = utf8 "Kehittyneempi %s-lääke on valmistunut tutkimusosastollasi.",
    new_available               = utf8 "Uusi %s on nyt saatavilla.",
    new_drug_researched         = utf8 "Sairauteen %s on kehitetty uusi lääke.",
  },
  
  -- Boiler issue
  boiler_issue = {
    minimum_heat        = utf8 "Keskuslämmitys on sanonut työsopimuksensa irti. Vaikuttaisi siltä, että sairaalassasi oleville ihmisille tulee pian jäiset oltavat.",
    maximum_heat        = utf8 "Kellarissa oleva lämmitysuuni on hajonnut. Uuni on jumiutunut täydelle teholle ja ihmiset sulavat sairaalassasi! Sijoita runsaasti juoma-automaatteja kaikkialle.",
    resolved            = utf8 "Hyviä uutisia. Keskuslämmitys toimii taas niin kuin pitääkin. Lämpötilan ei enää pitäisi vaivata potilaita eikä henkilökuntaa.",
  },
  
  -- Competitors
  competitors = {
    staff_poached       = utf8 "Yksi työntekijöistäsi on palkattu kilpailevaan sairaalaan.",
    hospital_opened     = utf8 "Kilpaileva sairaala on avattu lähellä aluetta %s.",
    land_purchased      = utf8 "%s on ostanut itselleen tontin.",
  },
  
  -- Room requirements
  room_requirements = {
    research_room_need_researcher       = utf8 "Sinun täytyy palkata tutkimukseen erikoistunut lääkäri ennen kuin voit ottaa tutkimusosaston käyttöön.",
    op_need_another_surgeon             = utf8 "Tarvitset vielä yhden kirurgin lisää ennen kuin voit ottaa leikkaussalin käyttöön.",
    op_need_ward                        = utf8 "Sinun täytyy rakentaa vuodeosasto, jotta voit valvoa leikkauksessa käyneiden potilaiden paranemista.",
    reception_need_receptionist         = utf8 "Sinun täytyy palkata vastaanottoapulainen ottamaan potilaat vastaan sairaalaasi.",
    psychiatry_need_psychiatrist        = utf8 "Sinun täytyy palkata psykiatriaan erikoistunut lääkäri nyt, kun olet rakentanut psykiatrin vastaanoton.",
    pharmacy_need_nurse                 = utf8 "Tarvitset sairaanhoitajan huolehtimaan apteekistasi.",
    ward_need_nurse                     = utf8 "Sinun täytyy palkata sairaanhoitaja työskentelemään vuodeosastolla.",
    op_need_two_surgeons                = utf8 "Sinun täytyy palkata kaksi kirurgia, jotta voit suorittaa kirurgisia toimenpiteitä leikkaussalissasi.",
    training_room_need_consultant       = utf8 "Tarvitset konsultti-lääkärin opettamaan nuorempia lääkäreitäsi koulutushuoneessa.",
    gps_office_need_doctor              = utf8 "Sinun täytyy palkata lääkäri tekemään alustavia diagnooseja yleislääkärin toimistossa.",
  },
  
  -- Goals
  goals = {
    win = {
      money             = utf8 "Sinulta puuttuu %d$ rahaa tämän tason taloudellisten tavoitteiden saavuttamiseksi.",
      cure              = utf8 "Sinun pitää parantaa vielä %d potilasta tämän tason vaatimusten täyttämiseksi.",
      reputation        = utf8 "Suosiosi pitää olla vähintään %d edetäksesi suraavalle tasolle.",
      value             = utf8 "Sairaalasi arvon tulee ylittää %d, jotta saat tämän tason suoritettua onnistuneesti.",
    },
    lose = {
      kill = utf8 "Jos sairaalassasi kuolee vielä %d potilasta, häviät tämän tason!",
    },
  },
  
  -- Warnings
  warnings = {
    charges_too_low             = utf8 "Veloitat palveluistasi liian vähän. Tämä houkuttelee kyllä sairaalaasi runsaasti potilaita, mutta ansaitset vähemmän jokaista potilasta kohden.",
    charges_too_high            = utf8 "Hintasi ovat liian korkeat. Se tuottaa sinulle runsaasti rahaa lyhyellä tähtäimellä, mutta pitkällä tähtäimellä korkeat hinnat karkoittavat asiakkaita.",
    plants_thirsty              = utf8 "Sinun täytyy huolehtia kasveistasi. Ne ovat janoisia.",
    staff_overworked            = utf8 "Työntekijäsi ovat ylityöllistettyjä. Heistä tulee tehottomia ja he tekevät hengenvaarallisia virheitä ollessaan väsyneitä.",
    queue_too_long_at_reception = utf8 "Sinulla on liikaa potilaita odottamassa vastaanotossasi. Rakenna lisää vastaanottoja ja palkkaa niihin vastaanottoapulaiset.",
    queue_too_long_send_doctor  = utf8 "Jono huoneeseen %s on liian pitkä. Varmista, että huoneessa on lääkäri.",
    handymen_tired              = utf8 "Huoltomiehesi ovat erittäin väsyneitä. Anna heidän levätä riittävästi.",
    money_low                   = utf8 "Rahasi uhkaavat loppua, jollet puutu asioihin!",
    money_very_low_take_loan    = utf8 "Rahasi ovat miltei lopussa. Voit ottaa lainaa pankilta selvitäksesi tästä ainakin hetkeksi.",
    staff_unhappy               = utf8 "Henkilökuntasi on tyytymätön. Kokeile antaa heille bonuksia tai rakentaa heille taukohuone. Voit myös muuttaa taukokäytäntöä Sairaalan käytännöt -ikkunasta.",
    no_patients_last_month      = utf8 "Sairaalaasi ei tullut ainuttakaan uutta potilasta viime kuussa. Shokki!",
    queues_too_long             = utf8 "Jonot ovat liian pitkiä sairaalassasi.",
    patient_stuck               = utf8 "Yksi potilaistasi on eksynyt. Sinun pitäisi järjestää sairaalasi paremmin.",
    patients_too_hot            = utf8 "Potilailla on liian kuuma. Voit poistaa ylimääräisiä lämpöpattereita, laskea lämmityksen tehoa tai rakentaa lisää juoma-automaatteja.",
    doctors_tired               = utf8 "Lääkärisi ovat erittäin väsyneitä. Anna heille lepotaukoja ennen kuin jollekulle käy hassusti.",
    need_toilets                = utf8 "Potilaasi tarvitsevat käymälöitä. Rakenna ne helposti saavutettaviin paikkoihin.",
    machines_falling_apart      = utf8 "Laitteesi ovat hajoamispisteessä. Käske huoltomiehiäsi huoltamaan niitä välittömästi!",
    nobody_cured_last_month     = utf8 "Yhtä ainuttakaan potilasta ei saatu parannettua viime kuussa.",
    patients_thirsty            = utf8 "Potilaasi ovat janoisia. Sinun pitäisi antaa heille mahdollisuus ostaa juotavaa.",
    nurses_tired                = utf8 "Sairaanhoitajasi ovat erittäin väsyneitä. Anna heidän levätä riittävästi.",
    machine_severely_damaged    = utf8 "%s on hyvin lähellä täydellistä tuhoutumista.",
    reception_bottleneck        = utf8 "Vastaanotto on sairaalasi pullonkaula. Palkaa toinen vastaanottoapulainen.",
    bankruptcy_imminent         = utf8 "Huhuu! Tilanteesi lähestyy uhkaavasti konkurssia. Ole varovainen!",
    receptionists_tired         = utf8 "Vastaanottoapulaisesi ovat erittäin väsyneitä. Anna heidän levätä riittävästi.",
    too_many_plants             = utf8 "Sinulla on liikaa kasveja. Sairaalasi näyttää jo ihan viidakolta.",
    many_killed                 = utf8 "Sairaalassasi on kuollut jo %d potilasta. Tiesitkö, että tarkoituksena olisi ollut parantaa heidät.",
    need_staffroom              = utf8 "Rakenna henkilökunnan taukohuone viipymättä, jotta he pääsevät välillä lepäämäänkin.",
    staff_too_hot               = utf8 "Henkilökuntasi on sulamispisteessä. Laske sairaalasi lämpötilaa tai vähennä lämpöpattereita heidän huoneistaan.",
    patients_unhappy            = utf8 "Potilaasi ovat tyytymättömiä sairaalaasi. Sinun pitäisi tehdä jotakin saadaksesi sairaalasi mukavammaksi.",
    pay_back_loan               = utf8 "Sinulla on runsaasti rahaa. Voisit harkita lainasi lyhentämistä.",
  },
  
  -- Placement info
  placement_info = {
    door_can_place              = utf8 "Voit asettaa oven tähän, jos haluat.",
    window_can_place            = utf8 "Ikkuna voidaan rakentaa tähän. Se onnistuu hienosti.",
    door_cannot_place           = utf8 "Valitettavasti et voi rakentaa ovea tähän.",
    object_can_place            = utf8 "Valitsemasi kaluste voidaan sijoittaa tähän.",
    reception_can_place         = utf8 "Vastaanotto voidaan asettaa tähän.",
    staff_cannot_place          = utf8 "Et voi asettaa työntekijääsi tähän. Pahoittelut.",
    staff_can_place             = utf8 "Voit asettaa työntekijän tähän. ",
    object_cannot_place         = utf8 "Huhuu, ei tätä kalustetta voi sijoittaa tähän.",
    room_cannot_place           = utf8 "Huonetta ei voi sijoittaa tähän.",
    room_cannot_place_2         = utf8 "Huonetta ei voi rakentaa tähän.",
    window_cannot_place         = utf8 "Et voi rakentaa ikkunaa tähän.",
    reception_cannot_place      = utf8 "Vastaanottoa ei voi sijoittaa tähän.",
  },
  
  -- Praise
  praise = {
    many_benches        = utf8 "Potilailla on tarpeeksi istumapaikkoja. Hienoa.",
    many_plants         = utf8 "Mahtavaa. Sinulla on paljon kasveja. Potilaasi arvostavat sitä varmasti.",
    patients_cured      = utf8 "%d potilasta parannettu.",
  },
  
  -- Information
  information = {
    larger_rooms                        = utf8 "Suurempi huone saa työntekijät tuntemaan itsensä tärkeämmiksi, mikä parantaa heidän suoritustasoaan.",
    extra_items                         = utf8 "Ylimääräiset kalusteet huoneissa parantavat työntekijöiden viihtyvyyttä ja heidän suoritustasonsa paranee.",
    epidemic                            = utf8 "Sairaalassasi riehuu tarttuva epidemia. Sinun pitää tehdä jotain ja pian!",
    promotion_to_doctor                 = utf8 "Yhdestä harjoittelijastasi on tullut tohtori.",
    emergency                           = utf8 "Hätätilanne! Nyt tuli kiire! Vauhtia siellä!",
    patient_abducted                    = utf8 "Avaruusolennot ovat siepanneet yhden potilaasi.",
    first_cure                          = utf8 "Hyvää työtä! Olet onnistunut parantamaan ensimmäisen potilaasi.",
    promotion_to_consultant             = utf8 "Yhdestä tohtoristasi on tullut konsultti.",
    handyman_adjust                     = utf8 "Voit parantaa huoltomiestesi tehokkuutta säätämällä heidän prioriteettejaan.",
    promotion_to_specialist             = utf8 "Yksi lääkäreistäsi on saanut päätökseen erikoistumisensa %sksi.",
    patient_leaving_too_expensive       = utf8 "Eräs potilas lähtee sairaalastasi maksamatta laskuaan hoidosta huoneessa %s. Se oli liian kallista.",
    vip_arrived                         = utf8 "Huomio! - %s on saapunut sairaalaasi! Tee kaikkesi, jotta hänen jokainen tarpeensa tulee ripeästi täytetyksi.",
    epidemic_health_inspector           = utf8 "Terveysministeriö on kuullut sairaalaasi vaivaavasta epidemiasta. Voit valmistautua siihen, että terveystarkastaja saapuu varsin pian.",
    first_death                         = utf8 "Sairaalassasi on sattunut ensimmäinen kuolemantapaus. Kuinkas tässä nyt näin pääsi käymään?",
    pay_rise                            = utf8 "Yksi työntekijöistäsi uhkaa irtisanoutua. Valitse haluatko suostua hänen palkkavaatimukseensa vai antaa hänelle potkut. Klikkaa vasemmalla alalaidassa olevaa ikonia nähdäksesi kenestä on kyse.",
    place_windows                       = utf8 "Ikkunat tekevät huoneista valoisampia ja parantavat työntekijöidesi mielialaa.",
    fax_received                        = utf8 "Vasempaan alanurkkaan ilmestyvät ikonit ilmoittavat sinulle tärkeistä tiedoista ja päätöksistä, joita voit tehdä.",
    initial_general_advice = {
      rats_have_arrived         = utf8 "Rotat ovat vallanneet sairaalasi. Yritä ampua niitä hiirelläsi.",
      autopsy_available         = utf8 "Tutkijasi ovat keksineet ruumiinavauskoneen, jonka avulla voit hankkiutua eroon ei-toivotuista potilaista ja tehdä tutkimusta heidän jäänteillään. Koneen käyttämisen moraalinen hyväksyttävyys on kuitenkin erittäin kiistanalaista.",
      first_patients_thirsty    = utf8 "Sairaalassasi on janoisia ihmisiä. Osta lisää juoma-automaatteja heidän käyttöönsä.",
      research_now_available    = utf8 "Olet rakentanut ensimmäisen tutkimusosastosi. Nyt pääset käsiksi tutkimus-ikkunaan.",
      psychiatric_symbol        = utf8 "Psykiatriaan erikoistuneet lääkärit on merkitty symbolilla: |",
      decrease_heating          = utf8 "Ihmisillä on liian kuuma sairaalassasi. Säädä lämmitystäsi pienemälle kartta-ikkunasta.",
      surgeon_symbol            = utf8 "Kirurgiaan erikoistuneet lääkärit on merkitty symbolilla: {",
      first_emergency           = utf8 "Hätätilannepotilaiden pään päällä on sininen hälytysvalo. Paranna heidät ennen kuin he kuolevat tai aika loppuu kesken.",
      first_epidemic            = utf8 "Sairaalassasi on havaittu epidemia! Päätä, haluatko salata sen vai tehdä lain vaatiman ilmoituksen.",
      taking_your_staff         = utf8 "Joku yrittää houkutella henkilökuntaasi loikkaamaan palvelukseensa. Sinun täytyy taistella, jos et halua menettää heitä.",
      place_radiators           = utf8 "Ihmisillä on liian kylmä sairaalassasi. Voit asentaa lisää lämpöpattereita ostamalla niitä kalusteet-valikosta.",
      epidemic_spreading        = utf8 "Sairaalassasi on vakavaan tartuntatautiin sairastuneita. Yritä parantaa sairastuneet ennen kuin he lähtevät kotiin.",
      research_symbol           = utf8 "Tutkimukseen erikoistuneet lääkärit on merkitty symbolilla: }",
      machine_needs_repair      = utf8 "Sairaalassasi on kone joka täytyy korjata. Etsi rikkoutunut kone, joka epäilemättä jo savuaa, ja klikkaa sitä. Aukeavasta ruudusta saat käskettyä huoltomiehen korjaamaan sen.",
      increase_heating          = utf8 "Ihmisillä on liian kylmä sairaalassasi. Säädä lämmitystäsi suuremmalle kartta-ikkunasta.",
      first_VIP                 = utf8 "Sairaalaasi on saapumassa ensimmäinen VIP-potilas. Yritä varmistaa, ettei hän pääse näkemään mitään epähygienistä tai yhtään tyytymättömiä potilaita.",
    },
  },
  
  -- Build advice
  build_advice = {
    placing_object_blocks_door  = utf8 "Jos sijoitat kalusteita tähän, kukaan ei pääse ovesta sisään eikä ulos.",
    blueprint_would_block       = utf8 "Tämä huoneen pohjapiirrustus estäisi pääsyn joihinkin muihin huoneisiin. Kokeile muuttaa huoneen kokoa tai siirrä se toiseen paikkaan!",
    door_not_reachable          = utf8 "Ihmiset eivät pääse mitenkään ovelle, jos asetat sen tähän. Mietihän vähän.",
    blueprint_invalid           = utf8 "Tämä pohjapiirrustus ei ole kelvollinen.",
  },
}

-- Confirmation
confirmation = {
  quit                  = utf8 "Jos poistut nyt, kaikki tallentamattomat tiedot menetetään. Oletko varma, että haluat lopettaa pelin?",
  return_to_blueprint   = utf8 "Oletko varma, että haluat palauttaa tämän huoneen pohjapiirros-tilaan?",
  replace_machine       = utf8 "Oletko varma, että haluat korvata koneen %s hintaan %d$?", -- %s (machine name) %d (price)
  overwrite_save        = utf8 "Tällä nimellä on jo tallennettu peli. Oletko varma, että haluat tallentaa sen päälle?",
  delete_room           = utf8 "Oletko varma, että haluat poistaa tämän huoneen?",
  sack_staff            = utf8 "Oletko varma, että haluat irtisanoa tämän työntekijän?",
  restart_level         = utf8 "Oletko varma, että haluat aloittaa tason alusta?",
  needs_restart         = utf8 "Tämän asetuksen muuttaminen vaatii CorsixTH:n käynnistämisen uudelleen. Kaikki tallentamattomat muutokset menetetään. Oletko varma, että haluat jatkaa?",
  abort_edit_room       = utf8 "Huoneen rakentaminen tai muokkaaminen on kesken. Jos kaikki pakolliset kalusteet on asetettu huoneeseen, se valmistuu, mutta muutoin se poistetaan. Oletko varma, että haluat poistua?",
}

-- Bank manager
bank_manager = {
  hospital_value        = utf8 "Sairaalan arvo",
  balance               = utf8 "Rahaa tilillä",
  current_loan          = utf8 "Maksettavaa lainaa",
  interest_payment      = utf8 "Vuokrakulut",
  insurance_owed        = utf8 "Vakuutusvelka",
  inflation_rate        = utf8 "Inflaatio",
  interest_rate         = utf8 "Korkotaso",
  statistics_page = {
    date                = utf8 "Päivä",
    details             = utf8 "Tiedot",
    money_out           = utf8 "Kulut",
    money_in            = utf8 "Tulot",
    balance             = utf8 "Saldo",
    current_balance     = utf8 "Tilillä",
  },
}


-- Newspaper headlines
newspaper = {
  -- Seven categories of funny headlines. I think each category is related
  -- to one criterium you can lose to. TODO: categorize
  { utf8 "TOHTORI KAUHUN KIROUS", utf8 "OUTO LÄÄKÄRI LEIKKII JUMALAA", utf8 "TOHTORI EBOLA SHOKEERAA", utf8 "KUKA USKOO VIILTÄJÄKIRURGIIN?", utf8 "RATSIA PÄÄTTI VAARALLISEN LÄÄKETUTKIMUKSEN" },
  { utf8 "TOHTORI ANKKURI", utf8 "ITKEVÄT PSYKIATRIT", utf8 "KONSULTIN PAKOMATKA", utf8 "KIRURGINEN LAUKAUS", utf8 "KIRURGI JUO LASINSA TYHJÄKSI", utf8 "KIRURGIN HENKI" },
  { utf8 "LEIKKIVÄ PSYKIATRI", utf8 "TOHTORI ILMAN-HOUSUJA", utf8 "TOHTORI KAUHUISSAAN", utf8 "KIRURGIN NÄLKÄ" },
  { utf8 "LÄÄKÄRI VETÄÄ VÄLISTÄ", utf8 "ELINKAUPPA KUKOISTAA", utf8 "PANKKIHOLVIN OHITUSLEIKKAUS", utf8 "LÄÄKÄRIN PIKKURAHAT" },
  { utf8 "HOITAJAT PENKOVAT RUUMISARKUN", utf8 "LÄÄKÄRI TYHJENSI HAUDAN", utf8 "VUOTO VAATEKAAPISSA", utf8 "TOHTORI KUOLEMAN HIENO PÄIVÄ", utf8 "VIIMEISIN HOITOVIRHE", utf8 "KADONNEET LÄÄKÄRIT" },
  { utf8 "LÄÄKÄRI EROAA!", utf8 "LEPSU PUOSKARI", utf8 "HENGENVAARALLINEN DIAGNOOSI", utf8 "VAROMATON KONSULTTI", },
  { utf8 "TOHTORI HUOKAA HELPOTUKSESTA", utf8 "KIRURGI 'LEIKKAA' ITSENSÄ", utf8 "LÄÄKÄRIN PURKAUS", utf8 "LÄÄKÄRI LASKEE KAAPELIA", utf8 "LÄÄKE OLIKIN KURAA" },
}

-- Letters
-- TODO
letter = {
                --original line-ends:                                                 5                                        4                                                         2    3
  [1] = {
    [1] = utf8 "Hyvä %s//",
    [2] = utf8 "Mahtavaa! Olet johtanut tätä sairaalaa erinomaisesti. Me täällä hallinnossa haluamme tietää, oletko kiinnostunut lähtemään suuremman projektin johtoon. Meillä on työtarjous, johon uskomme sinun sopivan täydellisesti. Voimme tarjota sinulle palkkaa %d$. Mieti toki kaikessa rauhassa.//",
    [3] = utf8 "Oletko kiinnostunut työskentelemään %sn sairaalassa?",
  },
  [2] = {
    [1] = utf8 "Hyvä %s//",
    [2] = utf8 "Oikein hyvää työtä! Sairaalasi on kehittynyt hienosti. Meillä on toinen instituutio, jonka johtoon haluaisimme sinut sijoittaa, jos olet saatavilla. Voit jättää tarjouksen hyväksymättä, mutta takaamme, että tämä on ainakin harkitsemisen arvoista. Palkka on %d$//",
    [3] = utf8 "Haluatko töihin %sn sairaalaan?",
  },
  [3] = {
    [1] = utf8 "Hyvä %s//",
    [2] = utf8 "Sinun kautesi tässä sairaalassa on ollut todellinen onnistumistarina. Näemme, että sinulla on kirkas tulevaisuus edessäsi ja haluamme tarjota sinulle pestiä toisessa paikassa. Palkka on %d$ ja uskomme sinun ihastuvan sen tarjoamiin uusiin haasteisiin.//",
    [3] = utf8 "Otatko vastaan paikan %sn sairaalassa?",
  },
  [4] = {
    [1] = utf8 "Hyvä %s//",
    [2] = utf8 "Onnittelut! Me täällä hallinnosssa olemme erittäin vaikuttuneita saavutuksistasi sairaalasi johdossa. Olet todellinen terveysministeriön kultapoika. Me uskomme kuitenkin, että kaipaat vähän haastavampaa työtä. Saisit palkkaa %d$, mutta päätös on sinun.//",
    [3] = utf8 "Oletko kiinnostunut ottamaan vastaan työn %sn sairaalassa?",
  },
  [5] = {
    [1] = utf8 "Hyvä %s//",
    [2] = utf8 "Hei taas. Kunnioitamme toiveitasi, jos et halua jättää tätä upeaa sairaalaa taaksesi, mutta pyydämme, että harkitset tarjoustamme vakavasti. Tarjoamme %d$ palkkaa, jos suostut siirtymään toisen sairaalan johtoon ja saat hoidon sujumaan yhtä hyvin kuin tässä sairaalassa.//",
    [3] = utf8 "Haluaisitko siirtyä %sn sairaalaan?",
  },
  [6] = {
    [1] = utf8 "Hyvä %s//",
    [2] = utf8 "Tervehdys. Tiedämme miten onnellinen olet ollut tässä upeassa ja hyvin johdetussa instituutiossa, mutta uskomme, että sinulla olisi nyt oikea hetki edistää uraasi. Saat kunnioitettavan johtajan palkan: %d$, jos päätät suostua. Ainakin sitä kannattaa harkita.//",
    [3] = utf8 "Haluatko ottaa vastaan paikan %sn sairaalassa?",
  },
  [7] = {
    [1] = utf8 "Hyvä %s//",
    [2] = utf8 "Hyvää päivää! Terveysministeriö haluaa tietää suostutko harkitsemaan uudelleen päätöstäsi pysyä tämän sairaalan johdossa. Me arvostamme nykyistä sairaalaasi, mutta uskomme, että haastavampi tehtävä sopisi sinulle paremmin. Palkkatarjouksemme on %d$.//",
    [3] = utf8 "Hyväksytkö työn %sn sairaalassa?",
  },
  [8] = {
    [1] = utf8 "Hyvä %s//",
    [2] = utf8 "Hei taas. Kieltäydyit aiemmasta tarjouksestamme, joka käsitti ensiluokkaisen paikkan upouuden sairaalan johdossa ja korotetun palkan: %d$. Meidän mielestämme sinun kannattaisi harkita päätöstäsi uudelleen. Kyseessä on nimittäin täydellinen työ juuri sinulle.//",
    [3] = utf8 "Otatko paikan vastaan %sn sairaalassa? Ole niin kiltti ja suostu!",
  },
  [9] = {
    [1] = utf8 "Hyvä %s//",
    [2] = utf8 "Olet todistanut olevasi paras sairaalanjohtaja lääketieteen pitkän ja kunniakkaan historian aikana. Tällainen uskomaton saavutus ei voi jäädä palkitsematta, joten tarjoamme sinulle sairaalaosaston pääjohtajan virkaa. Tämä on kunniavirka ja siihen kuuluu %d$ palkkaa. Kunniaksesi järjestetään paraati ja ihmiset osoittavat sinulle kiitollisuuttaan mihin ikinä menetkin.//",
    [3] = utf8 "Kiitokset kaikesta tekemästäsi työstä. Toivotamme sinulle leppoisia puoliaikaisia eläkepäiviä.//",
  },
  [10] = {
    [1] = utf8 "Hyvä %s//",
    [2] = utf8 "Onnittelut! Olet onnistunut menestyksekkäästi johtamaan kaikkia sairaaloita, joiden johtoon olemme sinut asettaneet. Tämän mahtavan saavutuksen johdosta saat vapauden matkustaa ympäri maailmaa, %d$ eläkettä ja limusiinin. Haluaisimme sinun matkoillasi keskustelevan kiitollisten kansalaisten kanssa ja edistävän kaikkien sairaalojen toimintaa kaikkialla.//",
    [3] = utf8 "Olemme kaikki ylpeitä sinusta. Joukossamme ei ole ketään, joka ei olisi kiitollinen ihmishenkien pelastamiseksi tekemästäsi työstä.//",
  },
  [11] = {
    [1] = utf8 "Hyvä %s//",
    [2] = utf8 "Urasi on ollut esimerkillinen ja olet inspiraation lähde meille kaikille. Kiitokset kaikkien näiden sairaaloiden johtamisesta ja hyvästä työstä jokaisessa niistä. Haluamme myöntää sinulle %d$ elinikäistä palkkaa ja pyydämme ainoastaan, että kierrät kaupungista toiseen pitämässä luentoja siitä kuinka sait aikaan niin paljon niin nopeasti.//",
    [3] = utf8 "Olet esimerkki kaikille järkeville ihmisille ja nautit poikkeuksetta kaikkien ihmisten ihailua ympäri maailman.//",
  },
  [12] = {
    [1] = utf8 "Hyvä %s//",
    [2] = utf8 "Voitokas urasi parhaana sairaalanjohtajana sitten Mooseksen aikojen lähestyy loppuaan. Vaikutuksesi lääketieteen ihmeelliseen maailmaan on ollut niin mahtava, että ministeriö haluaa myöntää sinulle %d$ palkkaa, jos suostut silloin tällöin pitämään puheita, osallistumaan laivojen vesillelaskuihin ja esiintymään TV:n chatti-ohjelmissa.//",
    [3] = utf8 "Voit huoletta hyväksyä tämän tarjouksen, sillä työ ei ole rankkaa ja tarjoamme sinulle auton ja poliisisaattueen minne ikinä menetkin.//",
  },
}


-- Humanoid start of names
humanoid_name_starts = {
  [1] = utf8 "LEPPÄ",
  [2] = utf8 "VIIMA",
  [3] = utf8 "KUUSI",
  [4] = utf8 "KOIVU",
  [5] = utf8 "MÄNTY",
  [6] = utf8 "PAJU",
  [7] = utf8 "TAMMI",
  [8] = utf8 "PYÖKKI",
  [9] = utf8 "LAUTA",
  [10] = utf8 "NAULA",
  [11] = utf8 "SUUR",
  [12] = utf8 "SUVI",
  [13] = utf8 "VIIMA",
  [14] = utf8 "LOVI",
  [15] = utf8 "HURME",
  [16] = utf8 "KOTO",
  [17] = utf8 "NURMI",
  [18] = utf8 "PALO",
  [19] = utf8 "KULO",
  [20] = utf8 "PAASI",
  [21] = utf8 "KAIVO",
  [22] = utf8 "HAVU",
  [23] = utf8 "KARE",
  [24] = utf8 "HALLA",
  [25] = utf8 "NOKI",
  [26] = utf8 "KYTÖ",
  [27] = utf8 "KIVI",
  [28] = utf8 "KALJU",
  [29] = utf8 "TALAS",
  [30] = utf8 "VESI",
  [31] = utf8 "ILMA",
  [32] = utf8 "KANTO",
  [33] = utf8 "SUMU",
}

-- Humanoid end of names
humanoid_name_ends = {
  [1] = utf8 "KOSKI",
  [2] = utf8 "PELTO",
  [3] = utf8 "JÄRVI",
  [4] = utf8 "MAA",
  [5] = utf8 "LAAKSO",
  [6] = utf8 "MÄKI",
  [7] = utf8 "RINTA",
  [8] = utf8 "RANTA",
  [9] = utf8 "JOKI",
  [10] = utf8 "VAARA",
  [11] = utf8 "PURO",
  [12] = utf8 "VIITA",
  [13] = utf8 "VUORI",
  [14] = utf8 "PIHA",
  [15] = utf8 "VIRTA",
  [16] = utf8 "METSÄ",
  [17] = utf8 "RINNE",
  [18] = utf8 "HARJU",
  [19] = utf8 "LEHTO",
  [20] = utf8 "MALMI",
  [21] = utf8 "KORPI",
  [22] = utf8 "SAARI",
  [23] = utf8 "LAHTI",
  [24] = utf8 "KUNNAS",
  [25] = utf8 "KANGAS",
  [26] = utf8 "PÄÄ",
}


-- VIP names
vip_names = {
  health_minister = utf8 "Terveysministeri",
  utf8 "Namikkalan kunnanjohtaja", -- the rest is better organized in an array.
  utf8 "Walesin Prinssi",
  utf8 "Norjan suurlähettiläs",
  utf8 "Aung Sang Su Kyi",
  utf8 "Kaino Vieno Nuppu Lahdelma",
  utf8 "Sir David",
  utf8 "Dalai Lama",
  utf8 "Nobel-palkittu kirjailija",
  utf8 "Valioliigan jalkapalloilija",
  utf8 "Vuorineuvos Viita",
}

-- Deseases
diseases = {
  general_practice = { 
    name = utf8 "Yleishoito", 
  },
  alien_dna = { 
    name        = utf8 "Alienin DNA", 
    cause       = utf8 "Aiheuttaja - joutuminen facehugger-alienin uhriksi.", 
    symptoms    = utf8 "Oireet - vaiheittainen muodonmuutos täysikasvuiseksi alieniksi ja halu tuhota kaikki kaupunkimme.", 
    cure        = utf8 "Hoito - DNA poistetaan mekaanisesti, puhdistetaan ja siirretään nopeasti takaisin.",
  },
  baldness = { 
    name        = utf8 "Kaljuus", 
    cause       = utf8 "Aiheuttaja - valehteleminen ja tarinoiden keksiminen suosion toivossa.", 
    symptoms    = utf8 "Oireet - kiiltävä kupoli ja nolotus.", 
    cure        = utf8 "Hoito - Uudet hiukset sulautetaan saumattomasti potilaan päähän käyttäen kivuliasta konetta.",
  },
  bloaty_head = { 
    name        = utf8 "Pallopäisyys", 
    cause       = utf8 "Aiheuttaja - juuston haistelu ja puhdistamattoman sadeveden juominen.", 
    symptoms    = utf8 "Oireet - hyvin epämukavat potilaalle.", 
    cure        = utf8 "Hoito - Pää puhkaistaan ja pumpataan takaisin oikeaan paineeseen nokkelalla laitteella.", 
  },
  broken_heart = { 
    name        = utf8 "Särkynyt sydän",
    cause       = utf8 "Aiheuttaja - joku rikkaampi, nuorempi ja laihempi kuin potilas.", 
    symptoms    = utf8 "Oireet - hallitsematon itku ja rasitusvamma jatkuvan lomakuvien repimisen johdosta.", 
    cure        = utf8 "Hoito - Kaksi kirurgia avaa rintakehän ja korjaa sydämen hellästi pidättäen hengitystään.", 
  },
  broken_wind = { 
    name        = utf8 "Kaasujen karkailu", 
    cause       = utf8 "Aiheuttaja - kuntosalin juoksumaton käyttäminen heti ruoan jälkeen.", 
    symptoms    = utf8 "Oireet - takana seisovien ihmisten ärsyyntyminen.", 
    cure        = utf8 "Hoito - Potilas juo nopeasti raskaan sekoituksen erityisiä vetisiä atomeja apteekissa.",
  },
  chronic_nosehair = { 
    name        = utf8 "Krooniset nenäkarvat", 
    cause       = utf8 "Aiheuttaja - nenän nyrpistäminen itseään heikompiosaisille ihmisille.", 
    symptoms    = utf8 "Oireet - nenäparta, johon orava voisi tehdä pesän.", 
    cure        = utf8 "Hoito - Sairaanhoitaja valmistaa apteekissa ällöttävän rohdon, joka nautitaan suun kautta.",
  },
  corrugated_ankles = { 
    name        = utf8 "Taipuneet nilkat", 
    cause       = utf8 "Aiheuttaja - liiallinen hidastetöyssyjen yli ajaminen.", 
    symptoms    = utf8 "Oireet - kengät eivät sovi hyvin jalkaan.", 
    cure        = utf8 "Hoito - Lievästi myrkyllinen seos yrttejä ja mausteita juodaan nilkkojen oikaisemiseksi.",
  },
  discrete_itching = { 
    name        = utf8 "Paikallinen kutina", 
    cause       = utf8 "Aiheuttaja - pienet hyönteiset, joilla on terävät hampaat.", 
    symptoms    = utf8 "Oireet - raapiminen, joka johtaa ruumiinosien tulehduksiin.", 
    cure        = utf8 "Hoito - Potilaalle juotetaan lääkesiirappia kutinan ehkäisemiseksi.",
  },
  fake_blood = { 
    name        = utf8 "Valeveri", 
    cause       = utf8 "Aiheuttaja - potilas on yleensä joutunut käytännön pilan uhriksi.", 
    symptoms    = utf8 "Oireet - suonissa punaista nestettä, joka haihtuu joutuessaan kosketuksiin kankaan kanssa.", 
    cure        = utf8 "Hoito - Psykiatrinen rauhoittelu on ainoa keino hoitaa ongelmaa.",
  },
  fractured_bones = { 
    name        = utf8 "Murtuneet luut",
    cause       = utf8 "Aiheuttaja - putoaminen korkealta betonille.", 
    symptoms    = utf8 "Oireet - voimakas napsahdus ja kyvyttömyys käyttää kyseisiä raajoja.", 
    cure        = utf8 "Hoito - Potilaalle asetetaan kipsi, joka sitten poistetaan laser-toimisella kipsinpoistokoneella.", 
  },
  gastric_ejections = { 
    name        = utf8 "Vääntelehtivä vatsa", 
    cause       = utf8 "Aiheuttaja - mausteinen meksikolainen tai intialainen ruoka.", 
    symptoms    = utf8 "Oireet - puolittain sulanutta ruokaa poistuu potilaan elimistöstä satunnaisesti.", 
    cure        = utf8 "Hoito - Erityisen sitouttamisnesteen juominen estää ruokapäästöjen syntymisen.",
  },
  golf_stones = { 
    name        = utf8 "Golf-kivet", 
    cause       = utf8 "Aiheuttaja - altistuminen golfpallojen sisältämälle myrkkykaasulle.", 
    symptoms    = utf8 "Oireet - sekavuus ja edistynyt häpeä.", 
    cure        = utf8 "Hoito - Kivet poistetaan leikkauksella, johon tarvitaan kaksi kirurgia.",
  },
  gut_rot = { 
    name        = utf8 "Mahamätä", 
    cause       = utf8 "Aiheuttaja - rouva Malisen 'Hauskaa iltaa' -viskiyskänlääke.", 
    symptoms    = utf8 "Oireet - ei yskää, mutta ei vatsan limakalvojakaan.", 
    cure        = utf8 "Hoito - Sairaanhoitaja sekoittaa apteekissa lääkeliemen, joka päälystää mahalaukun sisäpinnan.",
  },
  hairyitis = { 
    name        = utf8 "Turkinkasvu", 
    cause       = utf8 "Aiheuttaja - pitkittynyt altistuminen kuun valolle.", 
    symptoms    = utf8 "Oireet - potilaille kehittyy herkistynyt hajuaisti.", 
    cure        = utf8 "Hoito - Elektrolyysikone poistaa karvat ja sulkee huokoset.", 
  },
  heaped_piles = { 
    name        = utf8 "Kasautuneet pukamat", 
    cause       = utf8 "Aiheuttaja - vesiautomaatin lähellä seisoskeleminen.", 
    symptoms    = utf8 "Oireet - potilaasta tuntuu kuin hän istuisi marmorikuulapussin päällä.", 
    cure        = utf8 "Hoito - Miellyttävä, mutta vahvasti hapokas juoma sulattaa pukamat sisältä.",
  },
  infectious_laughter = { 
    name        = utf8 "Tarttuva nauru", 
    cause       = utf8 "Aiheuttaja - klassiset TV:n komediasarjat.", 
    symptoms    = utf8 "Oireet - avuton hihitys ja kuluneiden fraasien toistelu.", 
    cure        = utf8 "Hoito - Ammattitaitoisen psykiatrin täytyy muistuttaa potilaalle, kuinka vakava hänen tilansa on.",
  },
  invisibility = { 
    name        = utf8 "Näkymättömyys",
    cause       = utf8 "Aiheuttaja - radioaktiivisen (ja näkymättömän) muurahaisen purema",
    symptoms    = utf8 "Oireet - potilaat eivät kärsi lainkaan ja monet heistä hyödyntävät tilaansa tekemällä kepposia perheelleen",
    cure        = utf8 "Hoito - Apteekista saatava värikäs juoma palauttaa potilaat pikaisesti näkyviin",
  },
  iron_lungs = { 
    name        = utf8 "Rautakeuhkot", 
    cause       = utf8 "Aiheuttaja - kantakaupungin savusumu yhdistettynä kebabin jäänteisiin.", 
    symptoms    = utf8 "Oireet - kyky syöstä tulta ja huutaa kovaa veden alla.", 
    cure        = utf8 "Hoito - Kaksi kirurgia poistaa jähmettyneet keuhkot leikkaussalissa.",
  },
  jellyitis = { 
    name        = utf8 "Hyytelöityminen", 
    cause       = utf8 "Aiheuttaja - Runsaasti gelatiinia sisältävä ruokavalio ja liiallinen liikunta.", 
    symptoms    = utf8 "Oireet - liiallinen hytkyminen ja runsas kaatuilu.", 
    cure        = utf8 "Hoito - Potilas asetetaan vähäksi aikaa hyytelömuovaimeen erityisessä hyytelömuovainhuoneessa.",
  },
  kidney_beans = { 
    name        = utf8 "Munuaispavut",
    cause       = utf8 "Aiheuttaja - jääkuutioiden murskaaminen juomaan.", 
    symptoms    = utf8 "Oireet - kipuja ja jatkuvaa vessassa käymistä.", 
    cure        = utf8 "Hoito - Kahden kirurgin täytyy poistaa pavut koskematta munuaisiin.",
  },
  king_complex = { 
    name        = utf8 "Kuningas-kompleksi", 
    cause       = utf8 "Aiheuttaja - Kuninkaan henki tunkeutuu potilaan tajuntaan ja ottaa vallan.", 
    symptoms    = utf8 "Oireet - värikkäisiin samettikenkiin pukeutuminen ja juustohampurilaisten syöminen", 
    cure        = utf8 "Hoito - Psykiatri kertoo vastaanotollaan potilaalle, kuinka älyttömän typerältä tämä näyttää", 
  },
  pregnancy = { 
    name        = utf8 "Raskaus", 
    cause       = utf8 "Aiheuttaja - sähkökatkot kaupungistuneilla alueilla.", 
    symptoms    = utf8 "Oireet - taukoamaton syöminen ja siihen liittyvä kaljamaha.", 
    cure        = utf8 "Hoito - Lapsi poistetaan keisarinleikkauksella, pestään ja ojennetaan potilaalle.",
  },   -- unused
  ruptured_nodules = { 
    name        = utf8 "Repeytyneet kyhmyt", 
    cause       = utf8 "Aiheuttaja - benjihyppääminen kylmässä säässä.", 
    symptoms    = utf8 "Oireet - potilaan on mahdotonta istua mukavasti.", 
    cure        = utf8 "Hoito - Kaksi kirurgia poistaa kyhmyt vakain käsin.",
  },
  serious_radiation = { 
    name        = utf8 "Vakava säteily", 
    cause       = utf8 "Aiheuttaja - erehtyminen plutonium-isotooppien ja purukumin välillä.", 
    symptoms    = utf8 "Oireet - potilaat tuntevat itsensä hyvin, hyvin huonovointisiksi.", 
    cure        = utf8 "Hoito - Potilas tulee asettaa puhdistussuihkuun ja pestä huolellisesti.", 
  },
  slack_tongue = { 
    name        = utf8 "Velttokielisyys", 
    cause       = utf8 "Aiheuttaja - krooninen saippuaoopperoista puhuminen.", 
    symptoms    = utf8 "Oireet - kieli turpoaa viisi kertaa pidemmäksi kuin normaalisti.", 
    cure        = utf8 "Hoito - Kieli asetetaan paloittelijaan, joka lyhentää sen nopeasti, tehokkaasti ja kivuliaasti.",
  },
  sleeping_illness = { 
    name        = utf8 "Unitauti", 
    cause       = utf8 "Aiheuttaja - yliaktiivinen unirauhanen kitalaessa.", 
    symptoms    = utf8 "Oireet - ylitsepääsemätön tarve käydä nukkumaan kaikkialla.", 
    cure        = utf8 "Hoito - Sairaanhoitaja annostelee suuren annoksen voimakasta piristysainetta.",
  },
  spare_ribs = { 
    name        = utf8 "Liikakyljykset", 
    cause       = utf8 "Aiheuttaja - kylmillä kivilattioilla istuminen.", 
    symptoms    = utf8 "Oireet - epämiellyttävä rintavuuden tunne.", 
    cure        = utf8 "Hoito - Kaksi kirurgia poistaa kyljykset ja antaa ne folioon käärittynä potilaalle kotiin vietäväksi.",
  },
  sweaty_palms = { 
    name        = utf8 "Hikiset kädet", 
    cause       = utf8 "Aiheuttaja - työhaastattelujen kammo.", 
    symptoms    = utf8 "Oireet - kätteleminen potilaan kanssa on kuin pitelisi vastakasteltua pesusientä.", 
    cure        = utf8 "Hoito - Psykiatrin pitää saada potilas luopumaan päässään luomastaan sairaudesta.",
  },
  the_squits = { 
    name        = utf8 "Oksennustauti", 
    cause       = utf8 "Aiheuttaja - lattialta löytyneen pizzan syöminen.", 
    symptoms    = utf8 "Oireet - yäk, osaat varmaan arvatakin.", 
    cure        = utf8 "Hoito - Kuitupitoinen sekoitus lankamaisia lääkekemikaaleja kiinteyttää potilaan sisuskalut.",
  },
  third_degree_sideburns = { 
    name        = utf8 "Kolmannen asteen pulisongit", 
    cause       = utf8 "Aiheuttaja - kaipuu takaisin 1970-luvulle.", 
    symptoms    = utf8 "Oireet - iso kampaus, leveälahkeiset housut, korokepohjakengät ja kiillemeikit.", 
    cure        = utf8 "Hoito - Psykiatrin täytyy vakuuttaa potilas siitä, että hänen karvakehyksensä ovat inhottavat.",
  },
  transparency = { 
    name        = utf8 "Läpinäkyvyys", 
    cause       = utf8 "Aiheuttaja - jogurtin nuoleminen purkkien kansista.", 
    symptoms    = utf8 "Oireet - potilaan liha muuttuu läpinäkyväksi ja kammottavaksi.", 
    cure        = utf8 "Hoito - Apteekista saatava erityisellä tavalla jäähdytetty ja värjätty vesi parantaa taudin.",
  },
  tv_personalities = { 
    name        = utf8 "TV-kasvous", 
    cause       = utf8 "Aiheuttaja - päiväsaikaan lähetettävä ohjelmatarjonta.", 
    symptoms    = utf8 "Oireet - kuvitelma, että potilas pystyy juontamaan ruoanlaitto-ohjelman.", 
    cure        = utf8 "Hoito - Psykiatrin tulee suostutella potilas myymään televisionsa ja ostamaan radio sen tilalle.",
  },
  uncommon_cold = { 
    name        = utf8 "Epätavallinen flunssa",
    cause       = utf8 "Aiheuttaja - pienet räkähiukkaset ilmassa.", 
    symptoms    = utf8 "Oireet - vuotava nenä, aivastelu ja värjäytyneet keuhkot.", 
    cure        = utf8 "Hoito - Iso kulaus apteekissa valmisteltua epätavallista flunssalääkettä tekee taudista menneen talven lumia.",
  },
  unexpected_swelling = { 
    name        = utf8 "Odottamaton turvotus", 
    cause       = utf8 "Aiheuttaja - mikä tahansa odottamaton.", 
    symptoms    = utf8 "Oireet - turvotus.", 
    cure        = utf8 "Hoito - Kahden kirurgin suorittama puhkomistoimenpide poistaa turvotuksen.",
  },
  diag_scanner = {
    name = utf8 "Diagn. magn. kuvaus",
  },
  diag_blood_machine = {
    name = utf8 "Diagn. verikone",
  },
  diag_cardiogram = {
    name = utf8 "Diagn. kardiogrammi",
  },
  diag_x_ray = {
    name = utf8 "Diagn. röntgen",
  },
  diag_ultrascan = {
    name = utf8 "Diagn. ultraääni",
  },
  diag_general_diag = {
    name = utf8 "Diagn. yleisdiagn.",
  },
  diag_ward = {
    name = utf8 "Diagn. vuodeosasto.",
  },
  diag_psych = {
    name = utf8 "Diagn. psykiatria",
  },
  autopsy = {
    name = utf8 "Ruumiinavaus",
  },
}


-- Faxes
fax = {
  -- Debug fax
  debug_fax = {
    -- never seen this, must be a debug option of original TH
    -- TODO: make this nicer if we ever want to make use of it
    close_text  = utf8 "Kyllä, kyllä, kyllä!",
    text1       = utf8 "PARAS MÄÄRÄ %d", -- %d
    text2       = utf8 "IHMISIÄ YHTEENSÄ SAIRAALASSA %d VERRATTUNA %d:N", -- %d %d
    text3       = utf8 "LUVUT    : LÄÄKÄRIT %d HOITAJAT %d ALUE %d HUONEET %d HINTA %d", -- %d %d %d %d %d
    text4       = utf8 "KERTOIMET: LÄÄKÄRIT %d HOITAJAT %d ALUE %d HUONEET %d HINTA %d", -- %d %d %d %d %d
    text5       = utf8 "OSUUS    : LÄÄKÄRIT %d HOITAJAT %d ALUE %d HUONEET %d HINTA %d PROSENTTIA", -- %d %d %d %d %d
    text6       = utf8 "SEURAAVAT KERTOIMET OTETAAN MYÖS HUOMIOON",
    text7       = utf8 "MAINE: %d ODOTETTU %d VÄHENNYS %d", -- %d %d %d
    text8       = utf8 "WC-TILAT %d IHMISIÄ PALVELTU %d VÄHENNYS %d", -- %d %d %d
    text9       = utf8 "ONNETTOMUUDET %d SALLITTU (KK) %d (%d)VÄHENNYS %d", -- %d %d %d %d
    text10      = utf8 "KUOLEMAT %d SALLITTU (KK) %d (%d) VÄHENNYS %d", -- %d %d %d %d
    text11      = utf8 "IHMISIÄ TÄSSÄ KUUSSA %d", -- %d
  },
  
  -- Emergency
  emergency = {
    choices = {
      accept        = utf8 "Kyllä, minä pystyn hoitamaan sen", 
      refuse        = utf8 "Ei, en voi ottaa potilaita vastaan",
    },
    location                            = utf8 "%s on sattunut onnettomuus.", 
    num_disease                         = utf8 "%d ihmisellä on diagnosoitu %s, joka vaatii välitöntä hoitoa.",
    num_disease_singular                = utf8 "Yhdellä henkilöllä on havaittu %s, joka vaatii välitöntä hoitoa.",
    cure_possible_drug_name_efficiency  = utf8 "Sinulla on jo tarvittavat laitteet ja taidot. Tarvittava lääke on %s ja sen teho on %d%%.", 
    cure_possible                       = utf8 "Sinulla on jo tarvittavat laitteet ja taidot, joten sinun pitäisi selviytyä tilanteesta ongelmitta.", 
    cure_not_possible_build_and_employ  = utf8 "Sinun täytyy rakentaa %s ja palkata %s.",
    cure_not_possible_build             = utf8 "Sinun täytyy rakentaa %s.",
    cure_not_possible_employ            = utf8 "Sinun täytyy palkata %s.",
    cure_not_possible                   = utf8 "Et pysty hoitamaan tätä sairautta tällä hetkellä.",
    bonus                               = utf8 "Jos pystyt hoitamaan tämän hätätapauksen täydellisesti, saat bonuksena %d$. Jos kuitenkin epäonnistut, sairaalasi maine saa aimo kolauksen.",
    
    locations = {      
      utf8 "Tomin asekellarissa",
      utf8 "Innovaatioyliopistossa",       
      utf8 "Puskalan puutarhakeskuksessa", 
      utf8 "Vaarallisten aineiden tutkimuskesuksessa", 
      utf8 "Tanssimessuilla", 
      utf8 "Mykkä Papukaija -baarissa", 
      utf8 "Ison Taunon hautajaispaviljongissa",
      utf8 "Taj-curryravintolassa", 
      utf8 "Pekan petrokemikaalikirpputorilla", 
    },
  },

  emergency_result = {
    close_text          = utf8 "Sulje ikkuna",
    earned_money        = utf8 "Enimmäisbonus oli %d$ ja ansaitsit %d$.",
    saved_people        = utf8 "Pelastit %d ihmistä, kun potilaita oli %d.",
  },  
  
  -- Deseace discovered
  disease_discovered_patient_choice = {
    choices = {
      send_home = utf8 "Lähetä potilas kotiin.",
      wait      = utf8 "Pyydä potilasta odottamaan sairaalassa vähän aikaa.",
      research  = utf8 "Lähetä potilas tutkimusosastolle.",
    },
    need_to_build_and_employ    = utf8 "Sinun täytyy rakentaa %s ja palkkata %s, jotta voit hoitaa sairautta.",
    need_to_build               = utf8 "Sinun täytyy rakentaa %s, jotta voit hoitaa sairautta.",
    need_to_employ              = utf8 "Palkkaa %s auttamaan potilasta.",
    can_not_cure                = utf8 "Et voi hoitaa tätä sairautta.",
    disease_name                = utf8 "Työntekijäsi ovat havainneet uuden sairauden, jonka nimi on %s.",
    what_to_do_question         = utf8 "Miten haluat meidän toimivan potilaan kanssa?",
    guessed_percentage_name     = utf8 "Työntekijäsi ovat joutuneet arvaamaan, mikä potilasta vaivaa. %d%%:n todennäköisyydellä sairaus on %s.",
  },
  
  disease_discovered = {
    close_text                  = utf8 "Uusi sairaus on löydetty.",
    can_cure                    = utf8 "Pystyt parantamaan sairauden.",
    need_to_build_and_employ    = utf8 "Sinun täytyy rakentaa %s ja palkata %s, jotta voit hoitaa sairautta.",
    need_to_build               = utf8 "Sinun täytyy rakentaa %s, jotta voit hoitaa sairautta.",
    need_to_employ              = utf8 "Palkkaa %s hoitamaan potilaita, joilla on tämä sairaus.",
    discovered_name             = utf8 "Työntekijäsi ovat havainneet uuden sairauden, jonka nimi on %s.",
  },
  
  -- Epidemic
  epidemic = {
    choices = {
      declare   = utf8 "Julkista epidemia, maksa sakko ja hyväksy vahinko sairaalasi maineelle.",
      cover_up  = utf8 "Yritä hoitaa kaikki tartunnan saaneet potilaat ennen kuin annettu aika loppuu tai kukaan lähtee sairaalastasi.",
    },
    
    disease_name                = utf8 "Lääkärisi ovat löytäneet helposti tarttuvan %s-kannan.",
    declare_explanation_fine    = utf8 "Jos julkistat epidemian, sinun täytyy maksaa sakkoja %d$, sairaalasi maine kokee kolauksen ja kaikki potilaasi rokotetaan automaattisesti.",
    cover_up_explanation_1      = utf8 "Toisaalta, jos yrität salata epidemian, sinulla on rajoitetusti aikaa parantaa kaikki tartunnan saaneet potilaat.",
    cover_up_explanation_2      = utf8 "Jos vierailulle saapuva terveystarkastaja saa selville, että olet salaillut epidemiaa, seuraukset voivat olla hyvin vakavat.",
  },
  
  -- Epidemic result
  epidemic_result = {
    close_text = utf8 "Hurraa!",
    
    failed = {
      part_1_name       = utf8 "Yrittäessään salata sairaalassasi riehuneen helposti tarttuvan %s-epidemian",
      part_2            = utf8 "henkilökuntasi on päästänyt sairauden leviämään sairaalan ympärillä asuvaan väestöön.",
    },
    succeeded = {
      part_1_name       = utf8 "Terveystarkastaja on kuullut huhuja, että sairaalassasi on riehunut %s-epidemia",
      part_2            = utf8 "Hän ei ole kuitenkaan pystynyt näyttämään näitä huhuja todeksi.",
    },
    
    compensation_amount         = utf8 "Hallitus on myöntänyt sinulle %d$ korvauksena vahingoista, joita nämä valheet ovat sairaalasi maineelle aiheuttaneet.",
    fine_amount                 = utf8 "Hallitus on julistanut kansallisen hätätilan ja määrännyt sinulle %d$ sakkoja.",
    rep_loss_fine_amount        = utf8 "Sanomalehdet pääsevät huomenna kirjoittamaan tästä etusivullaan. Maineesi tahrautuu pahasti ja joudut maksamaan %d$ sakkoja.",
    hospital_evacuated          = utf8 "Terveyslautakunnalla ei ole muuta vaihtoehtoa kuin evakuoida sairaalasi.",
  },
  
  -- VIP visit query
  vip_visit_query = {
    choices = {
      invite    = utf8 "Lähetä virallinen kutsu V.I.P.-potilaalle.",
      refuse    = utf8 "Kieltäydy ottamasta V.I.P-vierasta vastaan jollakin tekosyyllä.",
    },
    vip_name = utf8 "%s on esittänyt toiveen päästä käymään sairaalassasi.",
  },
  
  -- VIP visit result
  vip_visit_result = {
    close_text          = utf8 "Kiitos käynnistä ja tervetuloa uudestaan.",
    telegram            = utf8 "Sähke!",
    vip_remarked_name   = utf8 "%s kommentoi vierailuaan sairaalassasi seuraavasti:",
    cash_grant          = utf8 "Sairaalallesi on tehty käteislahjoitus, jonka arvo on %d$.",
    rep_boost           = utf8 "Sairaalasi maine on parantunut.",
    rep_loss            = utf8 "Sairaalasi maine on huonontunut.",
    
    remarks = {
      super = {
        utf8 "Mikä mahtava sairaala. Seuraavan kerran, kun olen sairas, haluan sinne hoitoon.",
        utf8 "No tuota voi jo kutsua sairaalaksi.",
        utf8 "Uskomaton sairaala. Ja minun pitäisi tietää; olen käynyt aika monessa.",
      },
      good = {
        utf8 "Hyvin johdettu laitos. Kiitos, että kutsuit minut sinne.",
        utf8 "Hmm. Ei totisesti yhtään hullumpi sairaala.",
        utf8 "Nautin käynnistä mukavassa sairaalassasi. Tekeekö kenenkään mieli intialaista?",
      },
      mediocre = {
        utf8 "No, olen nähnyt huonompiakin, mutta voisit kyllä tehdä hieman parannuksia.",
        utf8 "Voi että. Ei mikään mukava paikka, jos tuntee olonsa kurjaksi.",
        utf8 "Rehellisesti sanoen se oli ihan perussairaala. Odotin vähän enemmän.",
      },
      bad = {
        utf8 "Miksi vaivauduin? Se oli kauheampaa kuin nelituntinen ooppera!",
        utf8 "Inhottava paikka. Kutsutaanko tuota sairaalaksi? Sikolättihän tuo oli!",
        utf8 "Olen kyllästynyt käymään tuollaisissa haisevissa koloissa julkisuuden henkilönä. Minä eroan!",
      },
      very_bad = {
        utf8 "Mikä läävä! Yritän saada sen lakkautettua.",
        utf8 "En ole koskaan nähnyt noin kamalaa sairaalaa. Mikä häpeätahra!",
        utf8 "Olen järkyttynyt. Ei tuota voi kutsua sairaalaksi! Minä tarvitsen juotavaa.",
      },
    },
  },
  
  -- Diagnosis failed
  diagnosis_failed = {
    choices = {
      send_home         = utf8 "Lähetä potilas kotiin",
      take_chance       = utf8 "Ota riski ja kokeile luultavinta hoitoa.",
      wait              = utf8 "Pyydä potilasta odottamaan, että saat rakennettua lisää diagnoosihuoneita.",
    },
    situation                           = utf8 "Olemme käyttäneet kaikkia diagnoosimenetelmiämme potilaan tutkimiseen, mutta emme tiedä vieläkään varmasti, mikä on vialla.",
    what_to_do_question                 = utf8 "Miten toimimme potilaan kanssa?",
    partial_diagnosis_percentage_name   = utf8 "Tiedämme %d%%:n todennäköisyydellä, että potilaan sairaus on %s.",
  },
}

-- Queue window
queue_window = {
  num_in_queue       = utf8 "Jono",
  num_expected       = utf8 "Odotettu",
  num_entered        = utf8 "Käyntejä",
  max_queue_size     = utf8 "Jono enint.",
}

-- Dynamic info
dynamic_info = {
  patient = {
    actions = {
      dying                             = utf8 "Tekee kuolemaa!",
      awaiting_decision                 = utf8 "Odottaa päätöstäsi",
      queueing_for                      = utf8 "Jonossa: %s", -- %s
      on_my_way_to                      = utf8 "Matkalla: %s", -- %s
      cured                             = utf8 "Parantunut!",
      fed_up                            = utf8 "Saanut tarpeekseen ja lähtee sairaalasta",
      sent_home                         = utf8 "Lähetetty kotiin",
      sent_to_other_hospital            = utf8 "Lähetetty toiseen sairaalaan",
      no_diagnoses_available            = utf8 "Ei diagnosointivaihtoehtoja jäljellä",
      no_treatment_available            = utf8 "Hoitoa ei ole tarjolla - Menen kotiin",
      waiting_for_diagnosis_rooms       = utf8 "Odottaa, että rakennat lisää diagnoosihuoneita",
      waiting_for_treatment_rooms       = utf8 "Odottaa, että rakennat lisää hoitohuoneita",
      prices_too_high                   = utf8 "Hinnat ovat liian korkeat - Menen kotiin",
      epidemic_sent_home                = utf8 "Terveystarkastaja lähettänyt kotiin",
      epidemic_contagious               = utf8 "Tautini on tarttuva",
      no_gp_available                   = utf8 "Odottaa, että rakennat yleislääkärin toimiston",
    },
    diagnosed           = utf8 "Diagnoosi: %s", -- %s
    guessed_diagnosis   = utf8 "Arvattu diagnoosi: %s", -- %s
    diagnosis_progress  = utf8 "Diagnosointiprosessi",
    emergency           = utf8 "Hätätilanne: %s", -- %s (disease name)
  },
  vip                   = utf8 "Vieraileva V.I.P.",
  health_inspector      = utf8 "Terveystarkastaja",
  
  staff = {
    psychiatrist_abbrev = utf8 "Psyk.",
    tiredness           = utf8 "Väsymys",
    ability             = utf8 "Kyvyt", -- unused?
    actions = {
      waiting_for_patient       = utf8 "Odottaa potilasta",
      wandering                 = utf8 "Vaeltaa ympäriinsä",
      going_to_repair           = utf8 "Korjattava: %s", -- %s (name of machine)
      heading_for               = utf8 "Matkalla kohteeseen: %s",
      fired                     = utf8 "Erotettu",
    },
  },
  
  object = {
    strength            = utf8 "Kestävyys: %d", -- %d (max. uses)
    times_used          = utf8 "Käyttökertoja: %d", -- %d (times used)
    queue_size          = utf8 "Jonon pituus: %d", -- %d (num of patients)
    queue_expected      = utf8 "Odotettu jonon pituus: %d", -- %d (num of patients)
  },
}

-- Miscellangelous
-- Category of strings that fit nowhere else or we are not sure where they belong.
-- If you think a string of these fits somewhere else, please move it there.
-- Don't forget to change all references in the code and other language files.
misc = {
  grade_adverb = {
    mildly      = utf8 "lievästi",
    moderately  = utf8 "keskimääräisesti",
    extremely   = utf8 "vakavasti",
  },
  done  = utf8 "Valmis",
  pause = utf8 "Keskeytä",
  
  send_message          = utf8 "Lähetä viesti pelaajalle %d", -- %d (player number)
  send_message_all      = utf8 "Lähetä viesti kaikille pelaajille",
  
  save_success  = utf8 "Peli tallennettu",
  save_failed   = utf8 "VIRHE: Pelin tallentaminen ei onnistunut",
  
  hospital_open = utf8 "Sairaala avattu",
  out_of_sync   = utf8 "Peli ei ole synkronisoitu",
  
  load_failed   = utf8 "VIRHE: Pelin lataaminen ei onnistunut",
  low_res       = utf8 "Matala resol.",
  balance       = utf8 "Tasapainotiedosto:",
  
  mouse = utf8 "Hiiri",
  force = utf8 "Voima",
}

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
        14. Handyman window
        15. Misc

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
    return_to_main_menu = "Palaa päävalikkoon",
    accept_new_level    = "Siirry seuraavalle tasolle",
    decline_new_level   = "Jatka pelaamista vielä jonkin aikaa",
  },
}

-- 3. Menu
menu_debug = {
  jump_to_level         = "  SIIRRY TASOLLE  ",
  transparent_walls     = "  (X) LÄPINÄKYVÄT SEINÄT  ",
  limit_camera          = "  RAJOITETTU KAMERA  ",
  disable_salary_raise  = "  ESTÄ PALKAN KOROTTAMINEN  ",
  make_debug_fax        = "  LUO DEBUG-FAKSI  ",
  make_debug_patient    = "  LISÄÄ DEBUG-POTILAS  ",
  cheats                = "  (F11) HUIJAUKSET  ",
  lua_console           = "  (F12) LUA-KOMENTORIVI  ",
  calls_dispatcher      = "  TEHTÄVIEN VÄLITYS  ",
  dump_strings          = "  DUMPPAA TEKSTIT  ",
  dump_gamelog          = "  (CTRL+D) DUMPPAA PELILOGI  ",
  map_overlay           = "  KARTTAKERROKSET  ",
  sprite_viewer         = "  SPRITE-KATSELIN  ",
}

menu_debug_overlay = {
  none          = "  TYHJÄ  ",
  flags         = "  LIPUT  ",
  positions     = "  SIJAINNIT  ",
  heat          = "  LÄMPÖTILA  ",
  byte_0_1      = "  TAVU 0 & 1  ",
  byte_floor    = "  TAVU LATTIA  ",
  byte_n_wall   = "  TAVU N SEINÄ  ",
  byte_w_wall   = "  TAVU W SEINÄ  ",
  byte_5        = "  TAVU 5  ",
  byte_6        = "  TAVU 6  ",
  byte_7        = "  TAVU 7  ",
  parcel        = "  ALUE  ",
}

menu_options_game_speed = {
  slowest               = "  (1) HITAIN  ",
  slower                = "  (2) HITAAMPI  ",
  normal                = "  (3) NORMAALI  ",
  max_speed             = "  (4) MAKSIMINOPEUS  ",
  and_then_some_more    = "  (5) JA VÄHÄN PÄÄLLE  ",
  pause                 = "  (P) PYSÄYTÄ  "
}

menu_options_volume = {
  [10]  = "  10%  ",
  [20]  = "  20%  ",
  [30]  = "  30%  ",
  [40]  = "  40%  ",
  [50]  = "  50%  ",
  [60]  = "  60%  ",
  [70]  = "  70%  ",
  [80]  = "  80%  ",
  [90]  = "  90%  ",
  [100] = "  100%  ",
}

menu_file_save = {
  [1] = "  PELI 1  ",
  [2] = "  PELI 2  ",
  [3] = "  PELI 3  ",
  [4] = "  PELI 4  ",
  [5] = "  PELI 5  ",
  [6] = "  PELI 6  ",
  [7] = "  PELI 7  ",
  [8] = "  PELI 8  ",
}

cheats_window = {
  caption       = "Huijaukset",
  warning       = "Varoitus: Et saa yhtään bonuspisteitä tason jälkeen, jos käytät huijauksia!",
  close         = "Sulje",
  cheated = {
    no  = "Huijauksia käytetty: Ei",
    yes = "Huijauksia käytetty: Kyllä",
  },
  cheats = {
    money               = "Rahahuijaus",
    all_research        = "Kaikki tutkimus -huijaus",
    emergency           = "Luo hätätilanne",
    create_patient      = "Luo potilas",
    end_month           = "Siirry kuukauden loppuun",
    end_year            = "Siirry vuoden loppuun",
    lose_level          = "Häviä",
    win_level           = "Voita",
    vip                 = "Luo VIP",
    earthquake          = "Maanjäristys",
  },
}

debug_patient_window = {
  caption = "Debug-potilas",
}

calls_dispatcher = {
  -- Dispatcher description message. Visible in Calls Dispatcher dialog
  summary       = "%d tehtävää; %d välitetty",
  staff         = "%s - %s",
  watering      = "Kastellaan @ %d,%d",
  repair        = "Korjaa %s",
  close         = "Sulje",
}

-- 4. Adviser
adviser = {
  room_forbidden_non_reachable_parts = "Huoneen sijoittaminen tähän estäisi pääsyn joihinkin sairaalan osiin.",
  cheats = {
    th_cheat            = "Onnittelut, olet saanut huijaukset käyttöösi! Tai olisit saanut, jos tämä olisi alkuperäinen peli. Kokeile jotain muuta.",
    crazy_on_cheat      = "Voi ei! Kaikki lääkärit ovat tulleet hulluiksi!",
    crazy_off_cheat     = "Huh... lääkärit ovat jälleen tulleet järkiinsä.",
    roujin_on_cheat     = "Roujinin haaste otettu käyttöön! Onnea...",
    roujin_off_cheat    = "Roujinin haaste poistettu käytöstä.",
    hairyitis_cheat     = "Turkinkasvu-huijaus otettu käyttöön!",
    hairyitis_off_cheat = "Turkinkasvu-huijaus poistettu käytöstä.",
    bloaty_cheat        = "Pallopäisyys-huijaus otettu käyttöön!",
    bloaty_off_cheat    = "Pallopäisyys-huijaus poistettu käytöstä.",
  },
}

-- 5. Main menu
main_menu = {
  custom_level      = "Luo oma sairaala",
  exit              = "Lopeta",
  load_game         = "Lataa peli",
  new_game          = "Uusi peli",
  options           = "Asetukset",
  savegame_version  = "Tallennetun pelin versio: ",
  version           = "Versio: ",
}

load_game_window = {
  caption       = "Lataa peli",
}

custom_game_window = {
  caption     = "Luo oma sairaala",
  free_build  = "Rakenna vapaasti",
}

save_game_window = {
  caption       = "Talenna peli",
  new_save_game = "Uusi tallennus",
}

menu_list_window = {
  back      = "Takaisin",
  name      = "Nimi",
  save_date = "Muokattu",
}

options_window = {
  fullscreen            = "Koko ruutu",
  width                 = "Leveys",
  height                = "Korkeus",
  change_resolution     = "Vaihda resoluutio",
  browse                = "Selaa...",
  new_th_directory      = "Tässä voit määrittää uuden Theme Hospital -pelin asennushakemiston. Kun olet valinnut uuden hakemiston, peli käynnistyy uudestaan.",
  cancel                = "Peruuta",
  back                  = "Takaisin",
}

errors = {
  dialog_missing_graphics       = "Pahoittelut, demon pelitiedostot eivät sisällä tämän ikkunan grafiikkaa.",
  save_prefix                   = "Virhe tallennettaessa peliä: ",
  load_prefix                   = "Virhe ladattaessa peliä: ",
  map_file_missing              = "Tasolle %s ei löydetty karttatiedostoa!",
  minimum_screen_size           = "Ole hyvä ja syötä resoluutio, joka on vähintään 640x480.",
  maximum_screen_size           = "Ole hyvä ja syötä resoluutio, joka on enintään 3000x2000.",
  unavailable_screen_size       = "Syöttämäsi resoluutio ei ole käytettävissä koko ruutu -tilassa.",
}

new_game_window = {
  hard          = "Konsultti (Vaikea)",
  cancel        = "Peruuta",
  tutorial      = "Esittely",
  easy          = "Harjoittelija (Helppo)",
  medium        = "Tohtori (Keskitaso)",
}

-- 6. Tooltip
tooltip = {
  objects = {
    litter = "Roska: Potilas on jättänyt sen lattialle, koska ei löytänyt roskakoria, johon sen olisi voinut heittää",
  },

  totd_window = {
    previous    = "Näytä edellinen vihje",
    next        = "Näytä seuraava vihje",
  },

  main_menu = {
    new_game            = "Aloita uusi peli aivan alusta",
    custom_level        = "Rakenna oma sairaala itse suunnittelemaasi rakennukseen",
    load_game           = "Lataa aiemmin tallennettu peli",
    options             = "Muuta pelin asetuksia",
    exit                = "Ei, ei, ole kiltti äläkä lähde!",
  },

  load_game_window = {
    load_game           = "Lataa peli %s",
    load_game_number    = "Lataa peli numero %d",
    load_autosave       = "Lataa viimeisin automaattitallennus",
  },

  custom_game_window = {
    free_build            = "Valitse tämä, jos haluat pelata ilman rahaa ja mahdollisuutta voittaa tai hävitä",
    start_game_with_name  = "Lataa taso %s",
  },

  save_game_window = {
    save_game           = "Tallenna tallennuksen %s tilalle",
    new_save_game       = "Anna nimi uudelle tallennukselle",
  },

  menu_list_window = {
    back      = "Sulje tämä ikkuna",
    name      = "Järjestä lista nimen mukaan",
    save_date = "Järjestä lista viimeisimmän muutoshetken mukaan",
  },

  options_window = {
    fullscreen_button   = "Klikkaa kytkeäksesi koko ruudun -tilan päälle tai pois",
    width               = "Syötä peli-ikkunan haluttu leveys",
    height              = "Syötä peli-ikkunan haluttu korkeus",
    change_resolution   = "Muuta ikkunan resoluutio vasemmalla annettujen arvojen mukaiseksi",
    language            = "Valitse kieleksi %s",
    original_path       = "Käytössä oleva Theme Hospital -pelin asennushakemisto",
    browse              = "Selaa hakemistoja valitaksesi uuden Theme Hospital -pelin asennushakemiston",
    back                = "Sulje tämä ikkuna",
  },

  new_game_window = {
    hard          = "Jos olet pelannut tällaista peliä aiemminkin ja kaipaat haastetta, valitse tämä",
    cancel        = "Hups, ei minun oikeasti pitänyt aloittaa uutta peliä!",
    tutorial      = "Jos haluat vähän apua alkuun pääsemisessä, valitse tämä",
    easy          = "Jos tämä on ensimmäinen kertasi tämän tyyppisen pelin parissa, tämä vaikeustaso on sinua varten",
    medium        = "Tämä on kultainen keskitie, jos et ole varma, mitä valitsisit",
  },

  lua_console = {
    textbox             = "Syötä suoritettava Lua-koodi tähän",
    execute_code        = "Suorita syöttämäsi koodi",
    close               = "Sulje komentorivi",
  },

  fax = {
    close = "Sulje ikkuna poistamatta viestiä",
  },

  message = {
    button              = "Avaa viesti klikkaamalla",
    button_dismiss      = "Klikkaa vasemalla avataksesi viestin, klikkaa oikealla poistaaksesi sen",
  },

  cheats_window = {
    close = "Sulje huijaukset-ikkuna",
    cheats = {
      money             = "Lisää 10 000$ pankkitilillesi",
      all_research      = "Saat kaiken tutkimuksen valmiiksi",
      emergency         = "Luo hätätilanteen",
      create_patient    = "Luo potilaan kartan reunalle",
      end_month         = "Siirtää aikaa eteenpäin kuukauden loppuun",
      end_year          = "Siirtää aikaa eteenpäin vuoden loppuun",
      lose_level        = "Häviät tämän tason",
      win_level         = "Voitat tämän tason",
      vip               = "Luo VIP-potilaan",
      earthquake        = "Aiheuttaa maanjäristyksen"
    },
  },

  calls_dispatcher = {
    task        = "Tehtävälista - klikkaa tehtävää avataksesi sitä suorittavan henkilökunnan jäsenen ikkunan ja keskittääksesi näkymän tehtävän kohteeseen",
    assigned    = "Tässä on merkki, kun vastaava tehtävä on välitetty jonkun tehtäväksi",
    close       = "Sulje tehtävien välitys -ikkuna",
  },

  casebook = {
    cure_requirement = {
      hire_staff = "Sinun täytyy palkata lisää henkilökuntaa tämän taudin hoitamiseksi",
    },
    cure_type = {
      unknown = "Et vielä tiedä, miten tätä tautia pitää hoitaa",
    },
  },

  research_policy = {
    no_research         = "Tämän aiheen parissa ei tehdä tutkimusta tällä hetkellä",
    research_progress   = "Edistyminen kohti seuraavaa löytöä tällä aihealueella: %1%/%2%",
  },
}

-- 7. Letter
letter = {
  dear_player                   = "Hyvä %s", --%s (player's name)
  custom_level_completed        = "Hienosti tehty! Olet suorittanut kaikki tämän itse laaditun tason tavoitteet!",
  return_to_main_menu           = "Haluatko palata takaisin päävalikkoon vai jatkaa pelaamista?",
}

-- 8. Installation
install = {
  title         = "-------------------------------- CorsixTH asennus --------------------------------",
  th_directory  = "CorsixTH tarvitsee kopion alkuperäisen Theme Hospital -pelin (tai demon) tiedostoista toimiakseen. Ole hyvä ja käytä alla olevaa valitsinta Theme Hospital-pelin asennushakemiston etsimiseen.",
  exit          = "Sulje",
}

-- 9. Level introductions
introduction_texts = {
  demo =
    "Tervetuloa demosairaalaan!" ..
    "Valitettavasti demoversio sisältää ainoastaan tämän tason. Täällä on kuitenkin enemmän kuin tarpeeksi tekemistä!" ..
    "Kohtaat erilaisia sairauksia, joiden hoitaminen vaatii erilaisia huoneita. Hätätilanteita saattaa tapahtua ajoittain. Lisäksi sinun pitää kehittää lisää huoneita tutkimusosaston avulla." ..
    "Tavoitteesi on ansaita 100 000$, nostaa sairaalan arvo yli 70 000$:n ja maineesi yli 700:n parantaen samalla vähintään 75% potilaistasi." ..
    "Pidä huoli, ettei maineesi putoa alle 300:n ja ettei yli 40 prosenttia potilaistasi pääse kuolemaan, tai häviät tason." ..
    "Onnea!",
  level1 =
    "Tervetuloa ensimmäiseen sairaalaasi!//" ..
    "Pääset alkuun rakentamalla vastaanottopöydän ja yleislääkärin toimiston sekä palkkaamalla vastaanottoapulaisen ja lääkärin. " ..
    "Sitten vain odotat asiakkaiden saapumista." ..
    "Olisi hyvä ajatus rakentaa psykiatrin vastaanotto ja palkata lääkäri, joka on erikoistunut psykiatriaan. " ..
    "Apteekki ja sairaanhoitaja ovat myös tärkeä yhdistelmä potilaidesi parantamiseksi. " ..
    "Tarkkaile pallopäisyydestä kärsiviä potilaitasi - pumppaushuone hoitaa heidät alta aikayksikön. " ..
    "Tavoitteenasi on parantaa kaikkiaan 10 potilasta ja varmistaa, ettei maineesi putoa alle 200:n.",
  level2 =
    "Tällä alueella on enemmän erilaisia sairauksia kuin edellisellä. " ..
    "Sairaalasi pitää selvitä suuremmasta potilasmäärästä, ja sinun kannattaa varautua tutkimusosaston rakentamiseen. " ..
    "Muista pitää laitoksesi puhtaana, ja yritä nostaa maineesi niin korkeaksi kuin mahdollista - alueella on liikkeellä velttokielisyyttä, joten tarvitset kieliklinikan. " ..
    "Voit myös rakentaa kardiogrammihuoneen auttamaan uusien sairauksien diagnosoinnissa. " ..
    "Molemmat näistä huoneista täytyy kehittää ennen kuin voit rakentaa niitä. Nyt voit myös ostaa lisää maata sairaalasi laajentamiseksi - Tämä tapahtuu kartta-ikkunassa. " ..
    "Tavoitteesi ovat 300:n maine, 10 000$ pankissa and 40 parannettua potilasta.",
  level3 =
    "Tällä kertaa sairaalasi sijaitsee varakkaalla alueella. " ..
    "Terveysministeriö odottaa sinun saavan täältä muhkeat voitot. " ..
    "Alussa sinun täytyy hankkia sairaalallesi hyvä maine. Kun saat sairaalan pyörimään kunnolla, keskity ansaitsemaan niin paljon rahaa kuin pystyt. " ..
    "Alueella saattaa myös sattua hätätapauksia. " ..
    "Näissä tilanteissa suuri joukko samalla tavoin loukkaantuneita potilaita saapuu sairaalaasi yhtä aikaa. " ..
    "Jos onnistut parantamaan heidät annetun aikarajan puitteissa saat lisää mainetta ja ison bonuksen. " ..
    "Kuningas-kompleksin kaltaisia sairauksia saattaa esiintyä, joten kannattaa budjetoida rahaa leikkaussalin ja vuodeosaston rakentamiseen lähelle toisiaan. " ..
    "Ansaitse 20 000$ päästäksesi seuraavalle tasolle.",
  level4 =
    "Pidä kaikki potilaasi tyytyväisinä, hoida heitä niin tehokkaasti kuin pystyt ja pidä kuolemantapaukset minimissään. " ..
    "Maineesi on kyseessä, joten pidä huolta, että se pysyy niin korkealla kuin mahdollista. " ..
    "Älä huolehdi rahasta liikaa - sitä alkaa kyllä tulla lisää maineesi kasvaessa. " ..
    "Voit myös kouluttaa lääkäreitäsi parantaaksesi heidän osaamistaan. " ..
    "He saattavat hyvinkin joutua hoitamaan tavallista läpinäkyvämpiä potilaita. " ..
    "Nosta maineesi yli 500:n.",
  level5 =
    "Tästä tulee kiireinen sairaala, joka joutuu hoitamaan laajaa kirjoa sairauksia. " ..
    "Kaikki lääkärisi ovat vastavalmistuneita, joten on ensiarvoisen tärkeää, että rakennat koulutushuoneen ja nostat lääkäreidesi osaamisen hyväksyttävälle tasolle. " ..
    "Sinulla on vain kolme konsulttia opettamassa kokematonta henkilökuntaasi, joten pidä heidät tyytyväisinä. " ..
    "Huomaa myös, että sairaalasi on rakennettu geologisen siirroksen läheisyyteen. " ..
    "Maanjäristysten riski on siis koko ajan olemassa. " ..
    "Ne aiheuttavat sattuessaan mittavia vahinkoja laitteillesi ja häiritsevät sairaalasi sujuvaa toimintaa. " ..
    "Hanki sairaalallesi 400 mainetta ja kasvata 50 000$:n pankkitili onnistuaksesi. Paranna samalla 200 potilasta.",
  level6 =
    "Käytä kaikkea oppimaasi ja rakenna sujuvasti toimiva sairaala, joka on taloudellisesti terveellä pohjalla ja pystyy selviytymään kaikista eteen tulevista tilanteista. " ..
    "Sinun on hyvä tietää, että ilmasto täällä levittää erityisen tehokkaasti bakteereja ja viruksia. " ..
    "Ellet onnistu pitämään sairaalaasi putipuhtaana, potilaasi voivat joutua epidemioiden kierteeseen. " ..
    "Pidä huolta, että ansaitset 150 000$ ja sairaalasi arvo ylittää 140 000$.",
  level7 =
    "Täällä joudut terveysministeriön tiukan valvonnan kohteeksi, joten pidä huolta, että tilikirjoissasi näkyy suuria voittoja ja maineesi pysyy korkealla. " ..
    "Meillä ei ole varaa ylimääräisiin kuolemantapauksiin - ne ovat huonoja liiketoiminnan kannalta. " ..
    "Varmista, että henkilökuntasi on parasta mahdollista ja heillä on kaikki tarvittavat toimitilat ja tarvikkeet. " ..
    "Tavoitteesi ovat 600 mainetta ja 200 000$ pankkitilillä.",
  level8 =
    "Sinun tehtäväsi on rakentaa tehokkain ja tuottavin mahdollinen sairaala. " ..
    "Ihmiset täällä ovat melko varakkaita, joten heiltä kannattaa kerätä niin paljon rahaa kuin mahdollista. " ..
    "Muista, että niin kivaa kuin ihmisten parantaminen onkin, tarvitset kipeästi rahaa, jota se tuottaa. " ..
    "Putsaa näiltä ihmisiltä tuhkatkin pesästä. " ..
    "Sinun tulee kerätä vaikuttavat 300 000$ läpäistäksesi tason.",
  level9 =
    "Täytettyäsi ministeriön pankkitilin ja kustannettuasi uuden limusiinin ministerille itselleen pääset taas luomaan huolehtivan ja hyvin hoidetun sairaalan sairaiden avuksi. " ..
    "Voit odottaa monia erilaisia ongelmia tällä alueella." ..
    "Jos sinulla on riittävästi hyvin koulutettua henkilökuntaa ja huoneita, sinulla pitäisi olla kaikki hallinnassa. " ..
    "Sairaalasi arvon tulee olla 200 000$ ja sinulla pitää olla 400 000$ pankissa. " ..
    "Pienemmillä summilla et pääse tätä tasoa läpi.",
  level10 =
    "Sen lisäksi, että huolehdit kaikista sairauksista, joita täällä päin ilmenee, ministeriö pyytää, että käytät aikaa lääkkeidesi tehon parantamiseen. " ..
    "Terveysjärjestöt ovat esittäneet joitakin valituksia, joten näyttääkseen hyvältä sairaalasi täytyy varmistaa, että kaikki käyttettävät lääkkeet ovat erittäin tehokkaita. " ..
    "Varmista myös, että sairaalasi on arvostelun yläpuolella. Pidä kuolemantapausten määrä kurissa. " ..
    "Ihan vihjeenä: saattaa olla hyvä idea säästää tilaa hyytelömuovainhuoneelle. " ..
    "Kehitä kaikki lääkkeesi vähintään 80%%:n tehokkuuteen, nosta maineesi vähintään 650:n ja kokoa 500 000$ pankkitilillesi voittaaksesi. ",
  level11 =
    "Sinulle tarjoutuu nyt mahdollisuus rakentaa yksi maailman parhaista sairaaloista. " ..
    "Tämä on erittäin arvostettu asuinalue ja ministeriö haluaa tänne parhaan mahdollisen sairaalan. " ..
    "Odotamme sinun ansaitsevan runsaasti rahaa, hankkivan erinomaisen maineen sairaalallesi ja pystyvän hoitamaan vaikeimmatkin tapaukset. " ..
    "Tämä on hyvin tärkeä työ. " ..
    "Sinun täytyy käyttää kaikkea osaamistasi selvitäksesi tästä kunnialla. " ..
    "Huomaa, että alueella on havaittu UFOja. Pidä huolta, että henkilökuntasi on valmiina odottamattomien vierailijoiden varalta. " ..
    "Sairaalasi arvon pitää olla 240 000$, pankkitililläsi pitää olla 500 000$ ja maineesi pitää olla 700.",
  level12 =
    "Tämä on kaikkien haasteiden äiti. " ..
    "Vaikuttuneena saavutuksistasi ministeriö on päättänyt antaa sinulle huipputyön; he haluavat toisen maailmanluokan sairaalan, joka tuottaa mainiosti ja jolla on erinomainen maine. " ..
    "Sinun odotetaan myös ostavan kaikki saatavilla olevat maa-alueet, parantavan kaikki sairaudet (ja me tosiaan tarkoitamme kaikki) ja voittavan kaikki palkinnot. " ..
    "Luuletko onnistuvasi?" ..
    "Ansaitse 650 000$, paranna 750 ihmistä ja hanki 800 mainetta voittaaksesi tämän.",
  level13 =
    "Uskomattomat kykysi sairaalanjohtajana ovat tulleet Salaisen erityispalvelun erityisen salaosaston tietoon. " ..
    "Heillä on sinulle erityinen bonus: täynnä rottia oleva sairaala, joka kaipaa kipeästi tehokasta tuholaistorjuntaa. " ..
    "Sinun pitää ampua mahdollisimman monta rottaa ennen kuin huoltomiehet siivoavat kaikki roskat pois. " ..
    "Uskotko olevasi tehtävän tasalla?",
  level14 =
    "Vielä yksi haaste on tarjolla - täysin odottamaton yllätyssairaala. " ..
    "Jos onnistut saamaan tämän paikan toimimaan, olet todellinen mestareiden mestari. " ..
    "Älä kuvittelekkaan, että tästä tulee helppoa kuin puistossa kävely, sillä tämä on pahin haaste, jonka saat vastaasi. " ..
    "Paljon onnea!",
  level15 =
    "Nyt olemme käsitelleet perusteet sairaalan saamiseksi toimintaan.//" ..
    "Lääkärisi tarvitsevat kaiken mahdollisen avun diagnosoidessaan osan näistä potilaista. " ..
    "Voit auttaa heitä rakentamalla toisen diagnoosihuoneen kuten yleislääkärin vastaanoton.",
  level16 =
    "Diagnosoituasi potilaita tarvitset hoitohuoneita ja klinikoita heidän parantamisekseen " ..
    "Apteekista on hyvä aloittaa. Toimiakseen se tarvitsee sairaanhoitajan annostelemaan lääkkeitä.",
  level17 =
    "Viimeinen varoituksen sana: pidä tarkasti silmällä mainettasi, sillä se houkuttelee sairaalaasi potilaita niin läheltä kuin kaukaa. " ..
    "Jos potilaita ei kuole liikaa ja he pysyvät kohtuullisen tyytyväisinä, sinulla ei ole mitään hätää tällä tasolla!//" ..
    "Olet nyt omillasi. Onnea ja menestystä!.",
  level18 = "",
}

-- 10. Tips
totd_window = {
  tips = {
    "Jokainen sairaala tarvitsee vastaanoton ja yleislääkärin toimiston. Tämän jälkeen kaikki riippuu siitä, mitä potilaasi tarvitsevat. Apteekki on kuitenkin yleensä hyvä alku.",
    "Kaikki laitteet, kuten verikone, tarvitsevat huoltoa. Palkkaa huoltomies tai pari korjaamaan laitteitasi tai työntekijöillesi ja potilaillesi saattaa käydä hassusti.",
    "Työntekijäsi kaipaavat välillä taukoja. Muista rakentaa heille henkilökunnan huone, jossa he voivat käydä lepäämässä.",
    "Asenna sairaalaasi riittävästi lämpöpattereita, jotta henkilökunnalle ja asiakkaille ei tule kylmä.",
    "Lääkärin taidot vaikuttavat paljon hänen tekemiensä diagnoosien laatuun ja nopeuteen. Palkkaamalla hyvän lääkärin yleislääkärin toimistoon tarvitset vähemmän muita diagnoosihuoneita.",
    "Tohtorit ja harjoittelijat voivat parantaa taitojaan oppimalla konsulteilta koulutushuoneessa. Jos konsultti on erikoistunut johonkin alaan (kirurgia, psykiatria tai tutkimus) hän siirtää tämän alan osaamisensa myös oppilailleen.",
    "Oletko kokeillut syöttää yleisen hätänumeron (112) faksiin? Varmista, että sinulla on äänet päällä!",
    "Asetukset-valikkoa ei ole vielä toteutettu, mutta voit muuttaa asetuksia kuten resoluutiota ja kieltä muokkaamalla config.txt-tiedostoa pelin asennushakemistossa.",
    "Olet vaihtanut kielen suomeksi. Jos kuitenkin näet pelissä englannin kielistä tekstiä, voit auttaa suomentamalla puuttuvia tekstejä!",
    "CorsixTH-tiimi etsii aina vahvistuksia! Oletko kiinnostunut ohjelmoimaan, kääntämään tai laatimaan grafiikkaa CorsixTH:ta varten? Saat meihin yhteyden Foorumimme, Sähköpostilistamme tai IRC-kanavamme (corsix-th at freenode) kautta.",
    "Jos löydät pelistä bugin, ilmoitathan niistä buginseurantaamme: th-issues.corsix.org.",
    "Jokaisella tasolla on joukko vaatimuksia, jotka sinun tulee täyttää ennen kuin pääset siirtymään seuraavalle tasolle. Voit tarkastella edistymistäsi tilanne-valikosta.",
    "Jos haluat muokata huonetta tai poistaa sen, voit tehdä niin ruudun alareunassa olevasta työkalupalkista löytyvän muokkaa huonetta -painikkeen avulla.",
    "Viemällä hiiren osoittimen huoneen päälle saat nopeasti tietää, ketkä ulkopuolella olevien potilaiden rykelmässä odottavat pääsyä kyseiseen huoneeseen.",
    "Klikkaa huoneen ovea nähdäksesi sen jonon. Tässä ikkunassa voit tehdä hyödyllistä hienosäätöä kuten järjestää jonon uudestaan tai lähettää potilaita toiseen huoneeseen.",
    "Tyytymättömät työntekijät pyytävät useammin palkankorotuksia. Pidä huolta, että he työskentelevät mukavassa ympäristössä välttääksesi tätä.",
    "Potilaat tulevat janoisiksi odottaessaan sairaalassasi; erityisesti, jos nostat lämpötilaa! Aseta juoma-automaatteja strategisesti ympäri sairaalaasi saadaksesi vähän lisätuloja.",
    "Voit peruuttaa potilaan diagnosoinnin ennenaikaisesti ja arvata hoidon, jos olet törmännyt kyseiseen tautiin jo aiemmin. Muista kuitenkin, että tämä lisää väärästä hoidosta aiheutuvan kuoleman riskiä.",
    "Hätätilanteet voivat olla hyvä ylimääräisen rahan lähde olettaen, että sairaalallasi on riittävästi kapasiteettia hätätilannepotilaiden hoitamiseen ajoissa.",
  },
  previous      = "Edellinen vihje",
  next          = "Seuraava vihje",
}

-- 11. Room descriptions (These were not present with the old strings so I assume they are new then)
room_descriptions = {
  blood_machine = {
    [1] = "Verikonehuone//",
    [2] = "Verikone tutkii potilaan verisoluja selvittääkseen mikä häntä vaivaa.//",
    [3] = "Verikone tarvitsee käyttäjäkseen lääkärin ja huoltoa huoltomieheltä. ",
  },
  cardiogram = {
    [1] = "Kardiogrammihuone//",
    [2] = "Potilaan sydän tutkitaan täällä ja hänet lähetetään takaisin yleislääkärin vastaanotolle, jossa määrätään sopiva hoito.//",
    [3] = "Kardiogrammikone tarvitsee käyttäjäkseen lääkärin ja huoltoa huoltomieheltä. ",
  },
  decontamination = {
    [1] = "Säteilyklinikka//",
    [2] = "Säteilylle altistuneet potilaat ohjataan nopeasti säteilyklinikalle. Huoneessa on suihku, jolla huuhdellaan potilaista kaikki kammottava radioaktiivinen aines ja lika.//",
    [3] = "Puhdistussuihku tarvitsee käyttäjäkseen lääkärin ja huoltoa huoltomieheltä. ",
  },
  dna_fixer = {
    [1] = "DNA-klinikka//",
    [2] = "Potilaat, jotka ovat joutuneet alieneiden kynsiin, tarvitsevat DNA-vaihdon tässä huoneessa. DNA-korjain on hyvin monimutkainen kone, joten on suositeltavaa pitää vaahtosammutin sen kanssa samassa huoneessa varmuuden vuoksi.//",
    [3] = "DNA-korjain tarvitsee käyttäjäkseen tutkimukseen erikoistuneen lääkärin ja säännöllistä huoltoa huoltomieheltä. ",
  },
  electrolysis = {
    [1] = "Elektrolyysihuone//",
    [2] = "Turkinkasvusta kärsivät potilaat ohjataan tähän huoneeseen, jossa elektrolyysikone nyppii karvat pois ja sulkee huokoset sähköisesti käyttäen ainetta joka muistuttaa saumauslaastia.//",
    [3] = "Elektrolyysikone tarvitsee käyttäjäkseen lääkärin ja huoltoa huoltomieheltä. ",
  },
  fracture_clinic = {
    [1] = "Murtumaklinikka//",
    [2] = "Ne epäonniset potilaat, joilla on murtumia luissaan lähetetään tänne. Kipsinpoistin leikkaa voimakkailla laser-säteillä kovettuneet kipsit pois aiheuttaen vain vähän tuskaa potilaalle.//",
    [3] = "Kipsinpoistin tarvitsee käyttäjäkseen sairaanhoitajan ja satunnaista huoltoa huoltomieheltä. ",
  },
  general_diag = {
    [1] = "Yleinen diagnoosihuone//",
    [2] = "Potilaat, jotka tarvitsevat jatkotutkimusta lähetetään tänne tutkittaviksi. Jos yleislääkärin vastaanotolla ei selviä, mikä potilasta vaivaa, yleisessä diagnoosihuoneessa monesti selviää. Potilaat lähetetään täältä takaisin yleislääkärin vastaanotolle tulosten analysointia varten.//",
    [3] = "Yleiseen diagnoosihuoneeseen tarvitaan lääkäri. ",
  },
  gp = {
    [1] = "Yleislääkärin vastaanotto//",
    [2] = "Tämä on sairaalasi perusdiagnoosihuone. Kaikki uudet potilaat lähetetään tänne lääkärin tutkittaviksi ja täältä heidät ohjataan joko jatkotutkimuksiin tai huoneeseen, jossa heidät voidaan parantaa. Saatat tarvita toisen yleislääkärin vastaanoton, jos ensimmäisestä tulee liian kiireinen. Mitä suurempi huone ja mitä enemmän lisäkalusteita sinne ostat sitä arvostetummaksi lääkäri tuntee itsensä. Tämä pätee myös kaikkiin muihin huoneisiin, joissa tarvitaan henkilökuntaa.//",
    [3] = "Yleislääkärin vastaanotolle tarvitaan lääkäri. ",
  },
  hair_restoration = {
    [1] = "Hiusklinikka//",
    [2] = "Kaljuudesta kärsivät potilaat ohjataan tällä klinikalla olevalle hiustenpalauttimelle. Lääkäri ohjaa konetta, joka kylvää potilaan päähän nopealla tahdilla tuorreita hiuksia.//",
    [3] = "Hiustenpalautin tarvitsee käyttäjäkseen lääkärin ja huoltoa huoltomieheltä. ",
  },
  inflation = {
    [1] = "Pumppaushuone//",
    [2] = "Kivuliaasta mutta huvittavasta pallopäisyydestä kärsivien potilaiden pitää mennä pumppaushuoneeseen, jossa heidän ylisuuri nuppinsa puhkaistaan ja täytetään sopivaan paineeseen.//",
    [3] = "Pumppauskone tarvitsee käyttäjäkseen lääkärin ja säännöllistä huoltoa huoltomieheltä. ",
  },
  jelly_vat = {
    [1] = "Hyytelöklinikka//",
    [2] = "Potilaiden, jotka sairastavat hyytelöitymistä, täytyy huojua hyytelöklinikalle ja asettua hyytelömuovaimeen. Tämä parantaa heidät vielä lääketieteelle tuntemattomalla tavalla.//",
    [3] = "Hyytelömuovain tarvitsee käyttäjäkseen lääkärin ja huoltoa huoltomieheltä. ",
  },
  no_room = {
    [1] = "",
  },
  operating_theatre = {
    [1] = "Leikkaussali//",
    [2] = "Tämä on tärkeä huone, sillä täällä hoidetaan lukuisia eri sairauksia. Leikkaussalin tulee olla riittävän suuri ja siellä pitää olla oikeat välineet. Se on elintärkeä osa sairaalaasi.//",
    [3] = "Leikkaussaliin tarvitaan kaksi kirurgiaan erikoistunutta lääkäriä. ",
  },
  pharmacy = {
    [1] = "Apteekki//",
    [2] = "Potilaat, joilla on diagnosoitu lääkkeillä parantuva sairaus, ohjataan apteekkiin hakemaan lääkkeensä. Sitä mukaa, kun uusia lääkehoitoja kehitetään, apteekki tulee kiireisemmäksi, joten toisen apteekin rakentaminen myöhemmin saattaa tulla tarpeen.//",
    [3] = "Apteekkiin tarvitaan sairaanhoitaja. ",
  },
  psych = {
    [1] = "Psykiatrin vastaanotto//",
    [2] = "Psykologisista sairauksista kärsivät potilaat lähetetään keskustelemaan psykiatrin kanssa. Psykiatrit voivat tarkentaa potilaan diagnoosia ja hoitaa psykologisia sairauksia uskollisen sohvansa avulla.//",
    [3] = "Psykiatrin vastaanotolle tarvitaan psykiatriaan erikoistunut lääkäri. ",
  },
  research = {
    [1] = "Tutkimusosasto//",
    [2] = "Täällä kehitetään uusia lääkkeitä ja hoitoja sekä parannellaan vanhoja. Tutkimusosasto on tärkeä osa tehokasta sairaalaa ja se tekee ihmeitä hoitoprosentillesi.//",
    [3] = "Tutkimusosastolle tarvitaan tutkimukseen erikoistunut lääkäri. ",
  },
  scanner = {
    [1] = "Magneettikuvaushuone//",
    [2] = "Potilaille saadaan tarkka diagnoosi edistyneen magneettikuvaimen avulla. Tämän jälkeen heidät lähetetään takaisin yleislääkärin vastaanotolle, jossa heille määrätään sopiva hoito.//",
    [3] = "Magneettikuvain tarvitsee käyttäjäkseen lääkärin ja huoltoa huoltomieheltä. ",
  },
  slack_tongue = {
    [1] = "Kieliklinikka//",
    [2] = "Potilaat, joilla yleislääkäri on todennut velttokielisyyden, lähetetään tänne hoitoon. Lääkäri käyttää kehittynyttä paloittelukonetta kielen venyttämiseen ja katkaisee sen normaaliin mittaansa parantaen potilaan.//",
    [3] = "Paloittelukone tarvitsee käyttäjäkseen lääkärin ja huoltoa huoltomieheltä. ",
  },
  staff_room = {
    [1] = "Henkilökunnan taukohuone//",
    [2] = "Henkilökuntasi väsyy suorittaessaan työtehtäviään. He käyttävät tätä huonetta rentoutumiseen ja lepäämiseen. Väsyneet työntekijät toimivat hitaammin, tekevät enemmän kohtalokkaita virheitä, vaativat palkankorotuksia ja eroavat lopulta palveluksestasi. Taukohuoneen rakentaminen on siis hyvin kannattavaa. Varmista, että huone on riittävän suuri useammalle henkilölle ja että siellä on riittävästi tekemistä henkilökunnallesi. ",
  },
  toilets = {
    [1] = "Käymälä//",
    [2] = "Potilaat, joita luonto kutsuu, voivat helpottaa oloaan käymälässäsi. Voit rakentaa enemmän eriöitä ja pesualtaita, jos odotat paljon potilaita. Joissain tilanteissa voi olla parempi rakentaa useampia käymälöitä eri puolille sairaalaasi. ",
  },
  training = {
    [1] = "Koulutushuone//",
    [2] = "Harjoittelijasi ja tohtorisi voivat oppia arvokkaita erikoistumistaitoja opiskelemalla tässä huoneessa. Konsultti, joka on erikoistunut kirurgiaan, tutkimukseen tai psykiatriaan siirtää näitä taitojaan koulutettavina oleville lääkäreille. Lääkärit, joilla jo on koulutus opetettavista erikoistumisaloista parantavat kykyään käyttää taitojaan täällä.//",
    [3] = "Koulutushuoneeseen tarvitaan konsultti. ",
  },
  tv_room = {
    [1] = "TV-HUONE EI KÄYTÖSSÄ",
  },
  ultrascan = {
    [1] = "Ultraäänihuone//",
    [2] = "Ultraäänilaite on pitkälle kehittynyt diagnoosilaite. Se maksaa paljon, mutta on sen arvoinen, jos haluat saada ensiluokkaisia diagnooseja sairaalassasi.//",
    [3] = "Ultraäänilaite tarvitsee käyttäjäkseen lääkärin ja huoltoa huoltomieheltä. ",
  },
  ward = {
    [1] = "Vuodeosasto//",
    [2] = "Potilaita pidetään täällä vuodelevossa tarkkailtavina diagnosoinnin aikana ja ennen leikkausta.//",
    [3] = "Vuodeosastolle tarvitaan sairaanhoitaja. ",
  },
  x_ray = {
    [1] = "Röntgenhuone//",
    [2] = "Röntgenillä kuvataan potilaiden sisäelimet ja luusto käyttäen erityistä säteilylähdettä. Hoitohenkilökunta saa näin hyvän kuvan siitä, mikä potilasta vaivaa.//",
    [3] = "Röntgen tarvitsee käyttäjäkseen lääkärin ja huoltoa huoltomieheltä. ",
  },
}

-- 12. Lua console
lua_console = {
  execute_code  = "Suorita",
  close         = "Sulje",
}

-- 13. Information
information = {
  custom_game           = "Tervetuloa pelaamaan CorsixTH:ta. Toivottavasti viihdyt tällä itse laaditulla kartalla!",
  cannot_restart        = "Valitettavasti tämä peli on tallennettu ennen uudelleen käynnistämisen toteuttamista.",
  level_lost            = {
    "Harmin paikka! Olet hävinnyt tämän tason. Parempaa onnea ensi kerralla!",
    "Syy tappioosi oli:",
    reputation          = "Maineesi putosi alle %d:n.",
    balance             = "Pankkitilisi saldo putosi alle %d$:n.",
    percentage_killed   = "Olet tappanut yli %d prosenttia potilaista.",
  },
}

-- 14. Handyman window
handyman_window = {
  all_parcels = "Kaikkialla",
  parcel = "Alue",
}

-- 15. Misc
misc = {
  not_yet_implemented   = "(ei toteutettu vielä)",
  no_heliport           = "Joko yhtään tautia ei vielä tunneta tai sairaalalla ei ole helikopterikenttää",
}

date_format.daymonth = "%1%. %2:months%"

-------------------------------------------------------------------------------
--   SECTION B - OLD STRINGS (OVERRIDE)
-------------------------------------------------------------------------------

-- Staff class
-- each of these corresponds to a sprite
staff_class = {
  nurse         = "Sairaanhoitaja",
  doctor        = "Lääkäri",
  handyman      = "Huoltomies",
  receptionist  = "Vastaanottoapulainen",
  surgeon       = "Kirurgi",
}

-- Staff titles
-- these are titles used e.g. in the dynamic info bar
staff_title = {
  receptionist  = "Vastaanottoapulainen",
  general       = "Yleinen", -- unused?
  nurse         = "Sairaanhoitaja",
  junior        = "Harjoittelija",
  doctor        = "Tohtori",
  surgeon       = "Kirurgi",
  psychiatrist  = "Psykiatri",
  consultant    = "Konsultti",
  researcher    = "Tutkija",
}

-- Pay rises
pay_rise = {
  definite_quit = "Et voi enää pidätellä minua mitenkään. Se on loppu nyt!",
  regular = {
    "Olen ihan loppuunpalanut. Vaadin kunnon tauon ja %d$:n palkankorotuksen, jos et halua nähdä minun kävelevän ympäriinsä ja valittavan käytävillä.", -- %d (rise)
    "Olen hyvin väsynyt. Vaadin lepoa ja %d$:n palkankorotuksen eli yhteensä %d$ palkkaa. Se saa kelvata, senkin tyranni!", -- %d (rise) %d (new total)
    "Anteeksi kuinka? Raadan täällä kuin orja. Anna minulle %d$:n bonus niin tulen sairaalaasi.", -- %d (rise)
    "Olen niin masentunut, että haluan %d$:n palkankorotuksen, joka tekee yhteensä %d$, tai muuten otan lopputilin.", -- %d (rise) %d (new total)
    "Vanhempani käskivät opiskella lääkäriksi, että saisin kunnon palkkaa. Anna minulle siis %d$ lisää liksaa, tai lähden täältä nopeammin kuin uskotkaan.", -- %d (rise)
    "Nyt olen vihainen. Anna minulle enemmän palkkaa. Uskoisin, että %d$ lisää riittää tällä erää.", -- %d (rise)
  },
  poached = "Minulle on tarjottu %d$ palkkaa %s-nimisen kilpailijasi sairaalassa. Siirryn sinne töihin, ellet anna minulle vastaavaa palkankorotusta.", -- %d (new total) %s (competitor)
}

-- Staff descriptions
staff_descriptions = {
  good = {
    [1] = "Hyvin nopea ja ahkera työntekijä. ",
    [2] = "Hyvin velvollisuudentuntoinen. Oikein huolellinen. ",
    [3] = "Todella monipuolinen. ",
    [4] = "Ystävällinen ja aina hyvällä tuulella. ",
    [5] = "Äärimmäisen sisukas. Työskentelee yöt ja päivät. ",
    [6] = "Uskomattoman kohtelias ja hyvätapainen. ",
    [7] = "Uskomattoman ammattitaitoinen ja osaava. ",
    [8] = "Hyvin keskittynyt ja arvostettu työssään. ",
    [9] = "Perfektionisti, joka ei koskaan luovuta. ",
    [10] = "Auttaa aina ihmisiä hymyssä suin. ",
    [11] = "Hurmaava, kohtelias ja auttavainen. ",
    [12] = "Hyvin motivoitunut ja omistautunut työlleen. ",
    [13] = "Luonteeltaan kiltti ja ahkera. ",
    [14] = "Lojaali ja ystävällinen. ",
    [15] = "Huomaavainen. Rauhallinen ja luotettava hätätilanteissa. ",
  },
  misc = {
    [1] = "Pelaa Golfia. ",
    [2] = "Pitää kampasimpukoista. ",
    [3] = "Veistää jääpatsaita. ",
    [4] = "Juo viiniä. ",
    [5] = "Ajaa rallia. ",
    [6] = "Harrastaa benjihyppyä. ",
    [7] = "Kerää lasinalusia. ",
    [8] = "Harrastaa yleisösurffausta. ",
    [9] = "Nauttii vauhdikkaasta surffaamisesta. ",
    [10] = "Pitää ankeriaiden venyttämisestä. ",
    [11] = "Tislaa viskiä. ",
    [12] = "Tee-se-itse ekspertti. ",
    [13] = "Pitää ranskalaisista taide-elokuvista. ",
    [14] = "Pelaa OpenTTD-peliä. ",
    [15] = "C-ajokortin ylpeä omistaja. ",
    [16] = "Osallistuu moottoripyöräkilpailuihin. ",
    [17] = "Soittaa klassista viulua ja selloa. ",
    [18] = "Innokas junanromuttaja. ",
    [19] = "Koiraihminen. ",
    [20] = "Kuuntelee radiota. ",
    [21] = "Kylpee usein. ",
    [22] = "Opettaa bambunletitystä. ",
    [23] = "Valmistaa saippuakuppeja vihanneksista. ",
    [24] = "Osa-aikainen miinanraivaaja. ",
    [25] = "Visailumestari. ",
    [26] = "Kerää sirpaleita 2. maailmansodasta. ",
    [27] = "Pitää sisustamisesta. ",
    [28] = "Kuuntelee rave- ja trip-hop-musikkia. ", --see original for trip-hop
    [29] = "Tappaa hyönteisiä deodorantilla. ",
    [30] = "Pitää kamalia stand up -esityksiä. ",
    [31] = "Tekee ostoksia sairaalaneuvostolle. ",
    [32] = "Salaperäinen puutarhuri. ",
    [33] = "Salakuljettaa piraattikelloja. ",
    [34] = "Rock-bändin laulaja. ",
    [35] = "Rakastaa TV:n katselua päivällä. ",
    [36] = "Kalastaa taimenia. ",
    [37] = "Houkuttelee turisteja museoon. ",
  },
  bad = {
    [1] = "Hidas ja nirso. ",
    [2] = "Laiska ja heikosti motivoitunut. ",
    [3] = "Huonosti koulutettu ja hyödytön. ",
    [4] = "Tyhmä ja ärsyttävä. Toimii sijaisena. ",
    [5] = "Alhainen kestävyys. Hänellä on huono ryhti. ",
    [6] = "Tyhmä kuin saapas. Haisee kaalilta. ",
    [7] = "Ei välitä työstään. Ei ota vastuuta. ",
    [8] = "Keskittymisvaikeuksia, häiriintyy helposti. ",
    [9] = "Stressaantunut ja tekee runsaasti virheitä. ",
    [10] = "Suuttuu helposti. Mököttää vihaisena. ",
    [11] = "Varomaton ja epäonninen. ",
    [12] = "Ei välitä työstään. Epäaktiivinen. ",
    [13] = "Uhkarohkea ja piittaamaton. ",
    [14] = "Viekas ja ovela. Puhuu muista pahaa. ",
    [15] = "Ylimielinen ja mahtaileva. ",
  },
}

-- Staff list
staff_list = {
  morale        = "MORAALI",
  tiredness     = "VÄSYMYS",
  skill         = "TAITO",
  total_wages   = "KOKONAISPALKKA",
}

-- Objects
object = {
  desk                  = "Toimistopöytä",
  cabinet               = "Arkistokaappi",
  door                  = "Ovi",
  bench                 = "Penkki",
  table1                = "Pöytä", -- unused object
  chair                 = "Tuoli",
  drinks_machine        = "Juoma-automaatti",
  bed                   = "Sänky",
  inflator              = "Pumppauskone",
  pool_table            = "Biljardipöytä",
  reception_desk        = "Vastaanottopöytä",
  table2                = "Pöytä", -- unused object & duplicate
  cardio                = "Kardiogrammikone",
  scanner               = "Magneettikuvain",
  console               = "Konsoli",
  screen                = "Sermi",
  litter_bomb           = "Roskapommi",
  couch                 = "Sohva",
  sofa                  = "Sohva",
  crash_trolley         = "Kärry",
  tv                    = "TV",
  ultrascanner          = "Ultraäänilaite",
  dna_fixer             = "DNA-korjain",
  cast_remover          = "Kipsinpoistin",
  hair_restorer         = "Hiustenpalautin",
  slicer                = "Paloittelukone",
  x_ray                 = "Röntgen",
  radiation_shield      = "Säteilysuoja",
  x_ray_viewer          = "Röntgenkatselin",
  operating_table       = "Leikkauspöytä",
  lamp                  = "Lamppu", -- unused object
  toilet_sink           = "Pesuallas",
  op_sink1              = "Allas",
  op_sink2              = "Lavuaari",
  surgeon_screen        = "Kirurgin sermi",
  lecture_chair         = "Luentotuoli",
  projector             = "Projektori",
  bed2                  = "Sänky", -- unused duplicate
  pharmacy_cabinet      = "Lääkekaappi",
  computer              = "Tietokone",
  atom_analyser         = "Atomianalysaattori",
  blood_machine         = "Verikone",
  fire_extinguisher     = "Vaahtosammutin",
  radiator              = "Lämpöpatteri",
  plant                 = "Kasvi",
  electrolyser          = "Elektrolyysikone",
  jelly_moulder         = "Hyytelömuovain",
  gates_of_hell         = "Manalan portit",
  bed3                  = "Sänky", -- unused duplicate
  bin                   = "Roskakori",
  toilet                = "Eriö",
  swing_door1           = "Heiluriovi",
  swing_door2           = "Heiluriovi",
  shower                = "Puhdistussuihku",
  auto_autopsy          = "Ruumiinavauskone",
  bookcase              = "Kirjahylly",
  video_game            = "Videopeli",
  entrance_left         = "Sisäänkäynnin vasen ovi",
  entrance_right        = "Sisäänkäynnin oikea ovi",
  skeleton              = "Luuranko",
  comfortable_chair     = "Mukava tuoli",
  litter                = "Roska",
}

-- Place objects window
place_objects_window = {
  drag_blueprint                = "Muuta suunnitelmaa kunnes olet tyytyväinen siihen",
  place_door                    = "Aseta ovi paikalleen",
  place_windows                 = "Aseta joitakin ikkunoita, jos haluat. Vahvista, kun olet valmis",
  place_objects                 = "Aseta kalusteet paikalleen. Vahvista, kun olet valmis",
  confirm_or_buy_objects        = "Voit hyväksyä huoneen, jatkaa kalusteiden ostamista tai siirtää kalusteita",
  pick_up_object                = "Klikkaa kalusteita poimiaksesi ne ylös tai tee toinen valinta ikkunasta",
  place_objects_in_corridor     = "Aseta kalusteita käytävään",
}

-- Competitor names
competitor_names = {
  [1] = "ORAAKKELI",
  [2] = "TÖPPÖ",
  [3] = "KOLOSSI",
  [4] = "NULJASKA",
  [5] = "PYHIMYS",
  [6] = "SYVÄ AJATUS",
  [7] = "ZEN",
  [8] = "LEO",
  [9] = "AKIRA",
  [10] = "SAMI",
  [11] = "KAARLE",
  [12] = "JANNE",
  [13] = "ARTTURI",
  [14] = "MATTI",
  [15] = "MAMMA",
  [16] = "SARI",
  [17] = "KUNKKU",
  [18] = "JOONAS",
  [19] = "TANELI",
  [20] = "OLIVIA",
  [21] = "NIKKE",
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
  money_in      = "Tulot",
  money_out     = "Menot",
  wages         = "Palkat",
  balance       = "Rahavarat",
  visitors      = "Vierailijoita",
  cures         = "Parantumisia",
  deaths        = "Kuolemia",
  reputation    = "Maine",

  time_spans = {
    "1 vuosi",
    "12 vuotta",
    "48 vuotta",
  }
}

-- Transactions
transactions = {
  --null                = S[8][ 1], -- not needed
  wages                 = "Palkat",
  hire_staff            = "Palkkaa henkilökuntaa",
  buy_object            = "Osta kalusteita",
  build_room            = "Rakenna huoneita",
  cure                  = "Hoitokeino",
  buy_land              = "Osta maata",
  treat_colon           = "Hoito:",
  final_treat_colon     = "Viimeisin hoito:",
  cure_colon            = "Hoitokeino:",
  deposit               = "Hoitomaksut",
  advance_colon         = "Ennakko:",
  research              = "Tutkimuskustannukset",
  drinks                = "Tulot: juoma-automaatti",
  jukebox               = "Tulot: jukeboksi", -- unused
  cheat                 = "Huijaukset",
  heating               = "Lämmityskustannukset",
  insurance_colon       = "Vakuutus:",
  bank_loan             = "Pankkilaina",
  loan_repayment        = "Lainan lyhennys",
  loan_interest         = "Lainan korko",
  research_bonus        = "Tutkimusbonus",
  drug_cost             = "Lääkekustannukset",
  overdraft             = "Tilin ylitys",
  severance             = "Irtisanomiskustannukset",
  general_bonus         = "Yleisbonus",
  sell_object           = "Myy kalusteita",
  personal_bonus        = "Henkilökunnan bonukset",
  emergency_bonus       = "Hätätilannebonukset",
  vaccination           = "Rokotukset",
  epidemy_coverup_fine  = "Sakot epidemian peittelystä",
  compensation          = "Valtion tuet",
  vip_award             = "VIP-palkkinnot",
  epidemy_fine          = "Epidemiasakot",
  eoy_bonus_penalty     = "Vuosittaiset bonukset/sakot",
  eoy_trophy_bonus      = "Vuoden palkintobonukset",
  machine_replacement   = "Vaihtolaitteiden kustannukset",
}


-- Level names
level_names = {
  "Lahjala",
  "Unikylä",
  "Isola",
  "Kotokartano",
  "Lepikylä",
  "Susimetsä",
  "Kaukala",
  "Puolitie",
  "Tammikuja",
  "Tiukylä",
  "Kaarela",
  "Kannosto",
  "Kamukylä",
  "Pikku-Rajala",
  "Vaatimala",
}


-- Town map
town_map = {
  chat         = "Chat",
  for_sale     = "Myytävänä",
  not_for_sale = "Ei myytävänä",
  number       = "Tonttinumero",
  owner        = "Omistaja",
  area         = "Pinta-ala",
  price        = "Hinta",
}


-- Rooms short
-- NB: includes some special "rooms"
-- reception, destroyed room and "corridor objects"
rooms_short = {
  reception         = "Vastaanotto",
  destroyed         = "Tuhoutunut",
  corridor_objects  = "Käytäväkalusteet",

  gps_office        = "Yleislääkäri",
  psychiatric       = "Psykiatria",
  ward              = "Vuodeosasto",
  operating_theatre = "Leikkaussali",
  pharmacy          = "Apteekki",
  cardiogram        = "Kardiogrammi",
  scanner           = "Magneettikuvaus",
  ultrascan         = "Ultraääni",
  blood_machine     = "Verikone",
  x_ray             = "Röntgen",
  inflation         = "Pumppaushuone",
  dna_fixer         = "DNA-klinikka",
  hair_restoration  = "Hiusklinikka",
  tongue_clinic     = "Kieliklinikka",
  fracture_clinic   = "Murtumaklinikka",
  training_room     = "Koulutushuone",
  electrolysis      = "Elektrolyysiklinikka",
  jelly_vat         = "Hyytelöklinikka",
  staffroom         = "Taukohuone",
  -- rehabilitation = "Vieroitushuone", -- unused
  general_diag      = "Yleinen diagnoosi",
  research_room     = "Tutkimusosasto",
  toilets           = "Käymälä",
  decontamination   = "Säteilyklinikka",
}

-- Rooms long
rooms_long = {
  general           = "Yleinen", -- unused?
  emergency         = "Hätätilanne",
  corridors         = "Käytävät",

  gps_office        = "Yleislääkärin vastaanotto",
  psychiatric       = "Psykiatrin vastaanotto",
  ward              = "Vuodeosasto",
  operating_theatre = "Leikkaussali",
  pharmacy          = "Apteekki",
  cardiogram        = "Kardiogrammihuone",
  scanner           = "Magneettikuvaushuone",
  ultrascan         = "Ultraäänihuone",
  blood_machine     = "Verikonehuone",
  x_ray             = "Röntgenhuone",
  inflation         = "Pumppaushuone",
  dna_fixer         = "DNA-klinikka",
  hair_restoration  = "Hiusklinikka",
  tongue_clinic     = "Kieliklinikka",
  fracture_clinic   = "Murtumaklinikka",
  training_room     = "Koulutushuone",
  electrolysis      = "Elektrolyysiklinikka",
  jelly_vat         = "Hyytelöklinikka",
  staffroom         = "Henkilökunnan taukohuone",
  -- rehabilitation = "Vieroitushuone", -- unused
  general_diag      = "Yleinen diagnoosihuone",
  research_room     = "Tutkimusosasto",
  toilets           = "Käymälä",
  decontamination   = "Säteilyklinikka",
}

-- Drug companies
drug_companies = {
  "Hoidake Yhtiöt",
  "Para 'N' Nus",
  "Pyöreät pikku-pillerit Oy",
  "Tyyrislääke Oyj",
  "Kaik-tabletit Ky",
}

-- Build rooms
build_room_window = {
  pick_department   = "Valitse osasto",
  pick_room_type    = "Valitse huonetyyppi",
  cost              = "Hinta: ",
}

-- Build objects
buy_objects_window = {
  choose_items      = "Valitse kalusteet",
  price             = "Hinta:",
  total             = "Yhteensä:",
}

-- Research
research = {
  categories = {
    cure            = "Hoitomenetelmät",
    diagnosis       = "Diagnoosimenetelmät",
    drugs           = "Lääketutkimus",
    improvements    = "Laitteisto",
    specialisation  = "Erikoistuminen",
  },

  funds_allocation  = "Myönnettävissä rahastosta",
  allocated_amount  = "Myönnetty rahasumma",
}

-- Policy screen
policy = {
  header            = "SAIRAALAN KÄYTÄNNÖT",
  diag_procedure    = "diagnosointikäytäntö",
  diag_termination  = "hoidon lopettaminen",
  staff_rest        = "taukokäytäntö",
  staff_leave_rooms = "salli tauolle poistuminen",

  sliders = {
    guess           = "ARVAA HOITO", -- belongs to diag_procedure
    send_home       = "LÄHETÄ KOTIIN", -- also belongs to diag_procedure
    stop            = "LOPETA HOITO", -- belongs to diag_termination
    staff_room      = "PIDÄ TAUKO", -- belongs to staff_rest
  }
}

-- Rooms
room_classes = {
  -- S[19][2] -- "Käytävät" - unused for now
  diagnosis  = "Diagnoosi",
  treatment  = "Hoito",
  clinics    = "Klinikat",
  facilities = "Toimitilat",
}

-- Insurance companies
insurance_companies = {
  out_of_business   = "KONKURSSISSA",
  "Kuorittu Sipuli Oy",
  "Pohjanmaalainen",
  "Sääntövakuutukset Oy",
  "Itikka Yhtiöt",
  "Uniturva",
  "Vam Pyyri Ky",
  "Sureol Vakuutusyhtiö",
  "Okto Pus ja kumppanit",
  "Larinnon Henkiturva",
  "Glade Vakuutukset Oy",
  "Mafia Vakuutus Oyj",
}

-- Menu root
-- Keep 2 spaces as prefix and suffix
menu = {
  file          = "  TIEDOSTO  ",
  options       = "  VALINNAT  ",
  display       = "  NÄYTÄ  ",
  charts        = "  TILASTOT  ",
  debug         = "  DEBUG  ",
}

-- Menu File
menu_file = {
  load          = "  LATAA  ",
  save          = "  TALLENNA  ",
  restart       = "  ALOITA ALUSTA  ",
  quit          = "  LOPETA  ",
}
menu_file_load = {
  [1] = "  PELI 1  ",
  [2] = "  PELI 2  ",
  [3] = "  PELI 3  ",
  [4] = "  PELI 4  ",
  [5] = "  PELI 5  ",
  [6] = "  PELI 6  ",
  [7] = "  PELI 7  ",
  [8] = "  PELI 8  ",
}

-- Menu Options
menu_options = {
  adviser_disabled  = "  AVUSTAJA  ",
  announcements     = "  KUULUTUKSET  ",
  announcements_vol = "  KUULUTUSTEN VOIMAKKUUS  ",
  autosave          = "  AUTOMAATTITALLENNUS  ",
  edge_scrolling    = "  REUNAVIERITYS  ",
  game_speed        = "  PELINOPEUS  ",
  jukebox           = "  JUKEBOKSI  ",
  lock_windows      = "  LUKITSE IKKUNAT  ",
  music             = "  MUSIIKKI  ",
  music_vol         = "  MUSIIKIN VOIMAKKUUS  ",
  settings          = "  ASETUKSET  ",
  sound             = "  ÄÄNI  ",
  sound_vol         = "  ÄÄNENVOIMAKKUUS  ",
}

-- Menu Display
menu_display = {
  high_res      = "  KORKEA RESOLUUTIO  ",
  mcga_lo_res   = "  MCGA - MATALA RESOLUUTIO  ",
  shadows       = "  VARJOT  ",
}

-- Menu Charts
menu_charts = {
  statement     = "  TILIOTE  ",
  casebook      = "  TAPAUSKIRJA  ",
  policy        = "  KÄYTÄNNÖT  ",
  research      = "  TUTKIMUS  ",
  graphs        = "  GRAAFIT  ",
  staff_listing = "  TYÖNTEKIJÄT  ",
  bank_manager  = "  PANKINJOHTAJA  ",
  status        = "  TILANNE  ",
  briefing      = "  TIIVISTELMÄ  ",
}

-- Menu Debug
menu_debug = {
  object_cells          = "  KALUSTESOLUT        ",
  entry_cells           = "  SYÖTESOLUT          ",
  keep_clear_cells      = "  PIDÄ TYHJÄNÄ -SOLUT ",
  nav_bits              = "  NAVIGOINTIBITIT     ",
  remove_walls          = "  POISTA SEINÄT       ",
  remove_objects        = "  POISTA KALUSTEET    ",
  display_pager         = "  NÄYTÄ VIESTIT       ",
  mapwho_checking       = "  MAPWHO-TARKISTUS    ",
  plant_pagers          = "  KASVIVIESTIT        ",
  porter_pagers         = "  KANTOVIESTIT        ",
  pixbuf_cells          = "  PIXBUF-SOLUT        ",
  enter_nav_debug       = "  SYÖTÄ NAVIG. DEBUG  ",
  show_nav_cells        = "  NÄYTÄ NAVIG. SOLUT  ",
  machine_pagers        = "  LAITEVIESTIT        ",
  display_room_status   = "  NÄYTÄ HUONEEN TILA  ",
  display_big_cells     = "  NÄYTÄ SUURET SOLUT  ",
  show_help_hotspot     = "  NÄYTÄ APUPISTEET    ",
  win_game_anim         = "  PELIN VOITTOANIM.   ",
  win_level_anim        = "  KENTÄN VOITTOANIM.  ",
  lose_game_anim = {
    [1]  = "  HÄVITTY PELI 1 ANIM  ",
    [2]  = "  HÄVITTY PELI 2 ANIM  ",
    [3]  = "  HÄVITTY PELI 3 ANIM  ",
    [4]  = "  HÄVITTY PELI 4 ANIM  ",
    [5]  = "  HÄVITTY PELI 5 ANIM  ",
    [6]  = "  HÄVITTY PELI 6 ANIM  ",
    [7]  = "  HÄVITTY PELI 7 ANIM  ",
  },
}

-- High score screen
high_score = {
  pos           = "SIJOITUS",
  player        = "PELAAJA",
  score         = "PISTEITÄ",
  best_scores   = "HALL OF FAME",
  worst_scores  = "HALL OF SHAME",
  killed        = "Kuolleita", -- is this used?

  categories = {
    money               = "RIKKAIN",
    salary              = "KORKEIN PALKKA",
    clean               = "PUHTAIN",
    cures               = "PARANTUNEIDEN MÄÄRÄ",
    deaths              = "KUOLLEIDEN MÄÄRÄ",
    cure_death_ratio    = "PARANTUNEET-KUOLLEET-SUHDE",
    patient_happiness   = "POTILAIDEN TYYTYVÄISYYS",
    staff_happiness     = "HENKILÖSTÖN TYYTYVÄISYYS",
    staff_number        = "ENITEN HENKILÖKUNTAA",
    visitors            = "ENITEN POTILAITA",
    total_value         = "KOKONAISARVO",
  },
}

-- Trophy room
trophy_room = {
  many_cured = {
    awards = {
      "Onnittelut Marie Curie -palkinnosta: olet onnistunut parantamaan suurimman osan sairaalaan saapuneista potilaista viime vuonna.",
    },
    trophies = {
      "Kansainvälinen lääkintähallitus toivottaa onnea hyvästä paranemisten osuudesta sairaalassasi viime vuonna. He myöntävät täten sinulle Puolet parannettu -kunniamaininnan.",
      "Sinulle on myönnetty Ei sairaana kotiin -kunniamaininta, koska ole parantanut suurimman osan sairaalaasi saapuneista potilaista viime vuonna.",
    },
  },
  all_cured = {
    awards = {
      "Onnittelut Marie Curie -palkinnosta: olet onnistunut parantamaan kaikki sairaalaan saapuneet potilaat viime vuonna.",
    },
    trophies = {
      "Kansainvälinen lääkintähallitus toivottaa onnea hyvästä paranemisten osuudesta sairaalassasi viime vuonna. He myöntävät täten sinulle Kaikki parannettu -kunniamaininnan.",
      "Sinulle on myönnetty Ei sairaana kotiin -kunniamaininta, koska ole parantanut kaikki sairaalaasi saapuneet potilaat.",
    },
  },
  high_rep = {
    awards = {
      "Sinulle myönnetään täten sisäministeriön Kiiltävät sairaalastandardit -palkinto, joka myönnetään vuosittain parhaan maineen saavuttaneelle sairaalalle. Onneksi olkoon!",
      "Ole hyvä ja ota vastaan Bullfrog-palkinto, joka myönnetään maineeltaan vuoden parhaalle sairaalalle. Olet ehdottomasti ansainnut sen!",
    },
  },
  happy_staff = {
    awards = {
    },
    trophies = {
      "Sinulle on myönnetty Hymynaama-kunniamaininta ahkeran henkilökuntasi pitämisestä niin tyytyväisenä kuin mahdollista.",
      "Mielialainstituutti on todennut, ettei kenelläkään ollut sinun sairaalassassi huolia tai murheita viime vuonna ja se antaa sinulle tunnustuksena tästä kunniamaininnan.",
      "Aurinko paistaa aina -kunniamaininta myönnetään täten sinulle, koska olet onnistunut pitämään henkilöstösi tyytyväisenä koko vuoden huolimatta valtaisasta työmäärästä. Hymyä huuleen!",
    },
  },
  happy_vips = {
    trophies = {
      "Tunnettujen henkilöiden toimisto haluaa palkita sinut Julkkis-kunniamaininnalla, koska olet pitänyt hyvää huolta kaikista VIP-potilaistasi. Olet jo itsekin melkein tunnettu!",
    },
  },
  no_deaths = {
    awards = {
      "Olet voittanut Elä pitkään -palkinnon pidettyäsi viime vuoden aikana 100 prosenttia potilaistasi hengissä.",
    },
    trophies = {
      "Elämä jatkuu -komitea on myöntänyt sinulle nimikkokunniamainintansa, koska olet selvinnyt ilman ainuttakaan kuolemantapausta koko viime vuoden.",
      "Sinulle on myönnetty Pidä elämästä kiinni -kunniamaininnan onnistuttuasi välttämään kuolemantapaukset kuluneena vuonna kokonaan. Mahtavuutta!",
    },
  },
  rats_killed = {
    awards = {
    },
    trophies = {
      "Sinulle on myönnetty Nolla tuholaista -kunniamaininta, koska sairaalassasi on ammuttu %d rottaa vuoden aikana.", -- %d (number of rats)
      "Otat vastaaan rottien ja hiirten vastaisen järjestön kunniamaininnan erinomaisen rotta-ammuntasi johdosta. Otit hengiltä %d jyrsijää viime vuonna.", -- %d (number of rats)
      "Onnittelut Rotta-ampuja-kunniamaininnasta, jonka sait osoitettuasi erityistä lahjakkuutta hävittämällä %d rottaa sairaalastasi kuluneen vuoden aikana.", -- %d (number of rats)
    },
  },
  rats_accuracy = {
    awards = {
    },
    trophies = {
      "Sinulle on myönnetty Kiitettävä ampuja toivottomassa sodassa -kunniamaininta, koska osamatarkkuutesi inhottavien rottien jahtaamisessa oli %d%% viime vuonna.", -- %d (accuracy percentage)
      "Tämä kunniamaininta on osoitus taitavuudestasi saatuasi hengiltä %d%% rotista, joita ammuit viime vuonna.", -- %d (accuracy percentage)
      "Olet osoittanut suurta tarkkuutta tappaessasi %d%% kaikista sairaalasi rotista ja sinulle on myönnetty Dungeon Keeper -kunniamaininta. Rottaiset onnittelut!", -- %d (accuracy percentage)
    },
  },
  healthy_plants = {
    awards = {
      "Onnittelut Kasvukausi-palkinnosta! Olet onnistunut pitämään sairaalasi kasvit erinomaisessa kunnossa koko vuoden.",
    },
    trophies = {
      "Ruukasvien ystävät -järjestö myöntää sinulle Vihreä terveys -kunniamaininnan, koska olet pitänyt hyvää huolta sairaalasi kasveista viimeiset 12 kuukautta.",
      "Sinulle on myönnetty Viherpeukalo-kunniamainnita, koska kasveiltasi ei ole puuttunut vettä eikä hoitoa viime vuonna.",
    },
  },
  sold_drinks = {
    awards = {
    },
    trophies = {
      "Kansainvälinen automaattiyhdistys on ylpeä voidessaan antaa sinulle kunniamaininnan sairaalassasi viime vuonna myytyjen virvoitusjuomien suuresta määrästä.",
      "Sairaalallesi on myönnetty Ravistetut tölkit -kunniamaininta viime vuoden aikana myytyjen virvoitusjuomatölkkien määrästä.",
      "Suomen hammaspaikat Oy on myöntänyt sinulle kunniamaininnan, koska sairaalasi on ansiokkaasti edistänyt virvoitusjuomien myyntiä viime vuonna.",
    },
  },
}


-- Casebook screen
casebook = {
  reputation            = "maine",
  treatment_charge      = "hoidon hinta",
  earned_money          = "tulot yhteensä",
  cured                 = "parannettuja",
  deaths                = "kuolleita",
  sent_home             = "kotiin lähetettyjä",
  research              = "kohdista tutkimusta",
  cure                  = "hoito",
  cure_desc = {
    build_room          = "Tarvitset huoneen: %s", -- %s (room name)
    build_ward          = "Tarvitset nopeasti vuodeosaston.",
    hire_doctors        = "Tarvitset lisää lääkäreitä.",
    hire_surgeons       = "Tarvitset lisää kirurgeja.",
    hire_psychiatrists  = "Tarvitset lisää psykologeja.",
    hire_nurses         = "Tarvitset lisää sairaanhoitajia.",
    no_cure_known       = "Ei tunnettuja hoitoja.",
    cure_known          = "Hoito tunnetaan.",
    improve_cure        = "Parannettu hoito",
  },
}

-- Tooltips
tooltip = {

  -- Build room window
  build_room_window = {
    room_classes = {
      diagnosis         = "Valitse diagnoosihuone",
      treatment         = "Valitse yleinen hoitohuone",
      clinic            = "Valitse erityisklinikka",
      facilities        = "Valitse laitokset",
    },
    cost                = "Kustannukset nykyisestä huoneesta",
    close               = "Keskeytä toiminto ja palaa peliin",
  },

  -- Toolbar
  toolbar = {
    bank_button         = "Vasen klikkaus: pankinjohtaja, oikea klikkaus: tiliote",
    balance             = "Tilin saldo",
    reputation          = "Maine:", -- NB: no %d! Append " ([reputation])".
    date                = "Päivä",
    rooms               = "Rakenna huone",
    objects             = "Osta kalusteita",
    edit                = "Muuta huonetta/kalusteita",
    hire                = "Palkkaa henkilökuntaa",
    staff_list          = "Henkilökuntaluettelo",
    town_map            = "Kartta",
    casebook            = "Hoitokirja",
    research            = "Tutkimus",
    status              = "Tilanne",
    charts              = "Kuvaajat",
    policy              = "Sairaalan käytännöt",
  },

  -- Hire staff window
  hire_staff_window = {
    doctors             = "Näytä työtä etsivät lääkärit",
    nurses              = "Näytä työtä etsivät sairaanhoitajat",
    handymen            = "Näytä työtä etsivät huoltomiehet",
    receptionists       = "Näytä työtä etsivät vastaanottoapulaiset",
    prev_person         = "Näytä edellinen",
    next_person         = "Näytä seuraava",
    hire                = "Palkkaa",
    cancel              = "Peruuta",
    doctor_seniority    = "Kokemus (Harjoittelija, Tohtori, Konsultti)",
    staff_ability       = "Kyvyt",
    salary              = "Palkkavaatimus",
    qualifications      = "Erikoistumisalat",
    surgeon             = "Kirurgi",
    psychiatrist        = "Psykiatri",
    researcher          = "Tutkija",
  },

  -- Buy objects window
  buy_objects_window = {
    price               = "Kalusteen hinta",
    total_value         = "Ostettujen kalusteiden kokonaisarvo",
    confirm             = "Osta kaluste(et)",
    cancel              = "Peruuta",
    increase            = "Kasvata valitun kalusteen ostetavaa määrää",
    decrease            = "Pienennä valitun kalusteen ostettavaa määrää",
  },

  -- Staff list
  staff_list = {
    doctors             = "Näytä katsaus lääkäreistäsi",
    nurses              = "Näytä katsaus sairaanhoitajistasi",
    handymen            = "Näytä katsaus huoltomiehistäsi",
    receptionists       = "Näytä katsaus vastaanottoapulaisistasi",

    happiness           = "Näyttää, kuinka tyytyväisiä työntekijäsi ovat",
    tiredness           = "Näyttää, kuinka väsyneitä työntekijäsi ovat",
    ability             = "Näyttää työntekijöidesi kyvyt",
    salary              = "Työntekijälle maksettava palkka",

    happiness_2         = "Työntekijän tyytyväisyys",
    tiredness_2         = "Työntekijän väsymys",
    ability_2           = "Työntekijän kyvyt",

    prev_person         = "Näytä edellinen sivu",
    next_person         = "Näytä seuraava sivu",

    bonus               = "Anna työntekijälle 10%:n bonus",
    sack                = "Anna työntekijälle potkut",
    pay_rise            = "Nosta työntekijän palkkaa 10%",

    close               = "Sulje ikkuna",

    doctor_seniority    = "Lääkärin kokemus",
    detail              = "Yksityiskohtien huomioimiskyky",

    view_staff          = "Näytä työntekijä",

    surgeon             = "Erikoistunut kirurgiaan",
    psychiatrist        = "Erikoistunut psykiatriaan",
    researcher          = "Erikoistunut tutkimukseen",
    surgeon_train       = "%d%% suoritettu kirurgiaan erikoistumisesta", -- %d (percentage trained)
    psychiatrist_train  = "%d%% suoritettu psykiatriaan erikoistumisesta", -- %d (percentage trained)
    researcher_train    = "%d%% suoritettu tutkimukseen erikoistumisesta", -- %d (percentage trained)

    skills              = "Taidot",
  },

  -- Queue window
  queue_window = {
    num_in_queue        = "Jonottavien potilaiden määrä",
    num_expected        = "Vastaanotosta jonoon pian saapuvien potilaiden määrä",
    num_entered         = "Tässä huoneessa tähän mennessä hoidettujen potilaiden kokonaismäärä",
    max_queue_size      = "Vastaanotosta jonoon päästettävien potilaiden enimmäismäärä",
    dec_queue_size      = "Pienennä jonoon päästettävien potilaiden enimmäismäärää",
    inc_queue_size      = "Kasvata jonoon päästettävien potilaiden enimmäismäärää",
    front_of_queue      = "Vedä potilas tähän asettaaksesi hänet jonon ensimmäiseksi",
    end_of_queue        = "Vedä potilas tähän asettaaksesi hänet jonon viimeiseksi",
    close               = "Sulje ikkuna",
    patient             = "Siirrä potilasta jonossa vetämällä. Klikkaa oikealla lähettääksesi potilas kotiin, vastaanottoon tai kilpailevaan sairaalaan",
    patient_dropdown = {
      reception         = "Lähetä potilas vastaanottoon",
      send_home         = "Lähetä potilas kotiin",
      hospital_1        = "Lähetä potilas toiseen sairaalaan",
      hospital_2        = "Lähetä potilas toiseen sairaalaan",
      hospital_3        = "Lähetä potilas toiseen sairaalaan",
    },
  },

  -- Main menu
  main_menu = {
    new_game            = "Aloita uusi peli",
    load_game           = "Lataa aiemmin tallennettu peli",
    continue            = "Jatka edellistä peliä",
    network             = "Aloita verkkopeli",
    quit                = "Lopeta",
    load_menu = {
      load_slot         = "  PELI  ", -- NB: no %d! Append " [slotnumber]".
      empty_slot        = "  TYHJÄ  ",
    },
  },
  -- Window general
  window_general = {
    cancel              = "Peruuta",
    confirm             = "Vahvista",
  },
  -- Information dialog
  information = {
    close = "Sulje tiedoteikkuna",
  },
  -- Patient window
  patient_window = {
    close               = "Sulje ikkuna",
    graph               = "Klikkaa vaihtaaksesi potilaan terveyskuvaajan ja hoitohistorian välillä",
    happiness           = "Potilaan tyytyväisyys",
    thirst              = "Potilaan jano",
    warmth              = "Potilaan lämpötila",
    casebook            = "Näytä lisätietoja potilaan sairaudesta",
    send_home           = "Lähetä potilas kotiin sairaalasta",
    center_view         = "Keskitä näkymä potilaaseen",
    abort_diagnosis     = "Lähetä potilas suoraan hoitoon ennen diagnoosin valmistumista",
    queue               = "Näytä jono, jossa potilas on",
  },
  -- window
  staff_window = {
    name                = "Työntekijän nimi",
    close               = "Sulje ikkuna",
    face                = "Työntekijän kuva - avaa henkilökuntaluettelo klikkaamalla",
    happiness           = "Tyytyväisyys",
    tiredness           = "Väsymys",
    ability             = "Kyvyt",
    doctor_seniority    = "Kokemus (Harjoittelija, Tohtori, Konsultti)",
    skills              = "Erikoistuminen",
    surgeon             = "Kirurgi",
    psychiatrist        = "Psykiatri",
    researcher          = "Tutkija",
    salary              = "Kuukausipalkka",
    center_view         = "Keskitä näkymä työntekijään klikkaamalla vasemmalla, selaa työntekijöitä klikkaamalla oikealla",
    sack                = "Anna potkut",
    pick_up             = "Poimi työntekijä",
  },
  -- Machine window
  machine_window = {
    name                = "Koneen nimi",
    close               = "Sulje ikkuna",
    times_used          = "Käyttökertojen määrä",
    status              = "Koneen tila",
    repair              = "Kutsu huoltomies huoltamaan kone",
    replace             = "Korvaa kone uudella",
  },


  -- Handyman window
  -- Apparently handymen have their own set of strings (partly) containing "handyman".
  -- We could just get rid of this category and include the three prios into staff_window.
  handyman_window = {
    ability             = "Kyvyt",
    center_view         = "Keskitä näkymä huoltomieheen", -- contains "handyman"
    close               = "Sulje ikkuna",
    face                = "Huoltomiehen kuva", -- contains "handyman"
    happiness           = "Tyytyväisyys",
    name                = "Huoltomiehen nimi", -- contains "handyman"
    parcel_select       = "Alue, jolla huoltomies hoitaa tehtäviään. Klikkaa vaihtaaksesi asetusta",
    pick_up             = "Poimi huoltomies",
    prio_litter         = "Pyydä huoltomiestä keskittymään lattioiden siivoamiseen", -- contains "handyman"
    prio_plants         = "Pyydä huoltomiestä keskittymään kasvien kastelemiseen", -- contains "handyman"
    prio_machines       = "Pyydä huoltomiestä keskittymään koneiden huoltamiseen", -- contains "handyman"
    sack                = "Anna potkut",
    salary              = "Kuukausipalkka",
    tiredness           = "Väsymys",
  },

  -- Place objects window
  place_objects_window = {
    cancel              = "Peruuta",
    buy_sell            = "Osta/Myy kalusteita",
    pick_up             = "Poimi kaluste",
    confirm             = "Vahvista",
  },

  -- Casebook
  casebook = {
    up                  = "Vieritä ylös",
    down                = "Vieritä alas",
    close               = "Sulje hoitokirja",
    reputation          = "Hoito- ja diagnoosimaine lähialueella",
    treatment_charge    = "Hoidon hinta",
    earned_money        = "Tähän mennessä ansaittu rahasumma",
    cured               = "Parannettujen potilaiden määrä",
    deaths              = "Hoidon seurauksena kuolleiden potilaiden määrä",
    sent_home           = "Kotiin lähetettyjen potilaiden määrä",
    decrease            = "Laske hintaa",
    increase            = "Nosta hintaa",
    research            = "Klikkaa käyttääksesi tutkimusbudjettia taudin tutkimukseen ja sen hoitoon erikoistumiseen",
    cure_type = {
      drug              = "Tämä tauti vaatii lääkitystä",
      drug_percentage   = "Tämä tauti vaatii lääkitystä - sinun lääkkeesi tehokkuus on %d%%", -- %d (effectiveness percentage)
      psychiatrist      = "Tämä tauti vaatii psykiatrin hoitoa",
      surgery           = "Tämä tauti vaatii leikkauksen",
      machine           = "Tämä tauti vaatii erikoislaitteen",
    },

    cure_requirement = {
      possible          = "Voit hoitaa potilaan terveeksi",
      research_machine  = "Sinun täytyy kehittää erikoislaite hoitaaksesi sairautta",
      build_room        = "Sinun täytyy rakentaa hoitohuone hoitaaksesi sairautta",
      hire_surgeons     = "Tarvitset kaksi kirurgia hoitaaksesi sairautta", -- unused
      hire_surgeon      = "Tarvitset yhden kirurgin hoitaaksesi sairautta", -- unused
      hire_staff_old    = "Sinun täytyy palkata %s hoitaaksesi sairautta", -- %s (staff type), unused. Use hire_staff instead.
      build_ward        = "Sinun täytyy rakentaa vuodeosasto hoitaaksesi sairautta", -- unused
      ward_hire_nurse   = "Tarvitset sairaanhoitajan vuodeosastollesi hoitaaksesi sairautta", -- unused
      not_possible      = "Et voi vielä hoitaa sairautta", -- unused
    },
  },

  -- Statement
  statement = {
    close               = "Sulje tiliote",
  },

  -- Research
  research = {
    close               = "Poistu tutkimusosastolta",
    cure_dec            = "Laske hoitotutkimuksen tärkeysastetta",
    diagnosis_dec       = "Laske diagnoositutkimuksen tärkeysastetta",
    drugs_dec           = "Laske lääketutkimuksen tärkeysastetta",
    improvements_dec    = "Laske laitteistotutkimuksen tärkeysastetta",
    specialisation_dec  = "Laske erikoistumistutkimuksen tärkeysastetta",
    cure_inc            = "Nosta hoitotutkimuksen tärkeysastetta",
    diagnosis_inc       = "Nosta diagnoositutkimuksen tärkeysastetta",
    drugs_inc           = "Nosta lääketutkimuksen tärkeysastetta",
    improvements_inc    = "Nosta laitteistotutkimuksen tärkeysastetta",
    specialisation_inc  = "Nosta erikoistumistutkimuksen tärkeysastetta",
    allocated_amount    = "Tutkimukseen suunnattu rahoitus",
  },

  -- Graphs
  graphs = {
    close               = "Sulje kuvaajaikkuna",
    scale               = "Skaalaa diagrammia",
    money_in            = "Näytä/Piilota tulot",
    money_out           = "Näytä/Piilota menot",
    wages               = "Näytä/Piilota palkat",
    balance             = "Näytä/Piilota tilin saldo",
    visitors            = "Näytä/Piilota potilaat",
    cures               = "Näytä/Piilota parannetut",
    deaths              = "Näytä/Piilota kuolleet",
    reputation          = "Näytä/Piilota maine",
  },

  -- Town map
  town_map = {
    people              = "Näytä/Piilota ihmiset",
    plants              = "Näytä/Piilota kasvit",
    fire_extinguishers  = "Näytä/Piilota vaahtosammuttimet",
    objects             = "Näytä/Piilota kalusteet",
    radiators           = "Näytä/Piilota lämpöpatterit",
    heat_level          = "Lämpötila",
    heat_inc            = "Nosta lämpötilaa",
    heat_dec            = "Laske lämpötilaa",
    heating_bill        = "Lämmityskustannukset",
    balance             = "Tilin saldo",
    close               = "Sulje kartta",
  },

  -- Jukebox.
  jukebox = {
    current_title       = "Jukeboksi",
    close               = "Sulje jukeboksi-ikkuna",
    play                = "Käynnistä jukeboksi",
    rewind              = "Kelaa jukeboksia taakse",
    fast_forward        = "Kelaa jukeboksia eteen",
    stop                = "Pysäytä jukeboksi",
    loop                = "Toista jukeboksia silmukassa",
  },

  -- Bank Manager
  bank_manager = {
    hospital_value      = "Sairaalasi tämänhetkinen arvo",
    balance             = "Pankkitilisi saldo",
    current_loan        = "Pankkilainan määrä",
    repay_5000          = "Maksa pankille 5000 takaisin",
    borrow_5000         = "Lainaa pankilta 5000 lisää",
    interest_payment    = "Kuukausittaiset korkokustannukset",
    inflation_rate      = "Vuotuinen inflaatio",
    interest_rate       = "Vuotuinen korko",
    close               = "Poistu pankista",
    insurance_owed      = "Määrä, jonka %s on sinulle velkaa", -- %s (name of debitor)
    show_graph          = "Näytä velallisen %s maksusuunnitelma", -- %s (name of debitor)
    graph               = "Velallisen %s maksusuunnitelma", -- %s (name of debitor)
    graph_return        = "Palaa edelliseen näyttöön",
  },

  -- Status
  status = {
    win_progress_own    = "Näytä pelaajan edistyminen tämän tason vaatimusten suhteen",
    win_progress_other  = "Näytä kilpailijan %s edistyminen tämän tason vaatimusten suhteen", -- %s (name of competitor)
    population_chart    = "Kuvaaja, joka näyttää kuinka suuri osa paikallisesta väestöstä hakeutuu mihinkin sairaalaan hoidettavaksi",
    happiness           = "Kaikkien sairaalassasi olevien keskimääräinen tyytyväisyys",
    thirst              = "Kaikkien sairaalassasi olevien keskimääräinen janoisuus",
    warmth              = "Kaikkien sairaalassasi olevien keskimääräinen lämpötila",
    close               = "Sulje tilanneikkuna",
    reputation          = "Maineesi pitää olla vähintään %d. Tällä hetkellä se on %d", -- %d (target reputation) %d (current reputation)
    balance             = "Sinulla tulee olla rahaa tililläsi vähintää %d$. Tällä hetkellä sitä on %d$", -- %d (target balance) %d (current balance)
    population          = "%d%% alueen väestöstä pitää kuulua asiakaskuntaasi",
    num_cured           = "Tavoitteenasi on parantaa %d ihmistä. Tähän mennessä olet parantanut %d",
    percentage_killed   = "Tavoitteenasi on tappaa vähemmän kuin %d%% potilaistasi. Tähän mennessä olet tappanut %d%% heistä",
    value               = "Sairaalasi arvon tulee olla vähintään $%d. Nyt se on $%d",
    percentage_cured    = "Sinun pitää parantaa %d%% sairaalaasi saapuneista potilaista. Tähän mennessä olet parantanut %d%% heistä",
  },

  -- Policy
  policy = {
    close               = "Sulje käytännöt-ikkuna",
    staff_leave         = "Klikkaa tästä asettaaksesi henkilökunnan liikkumaan vapaasti huoneiden välillä ja auttamaan kollegojaan tarvittaessa",
    staff_stay          = "Klikkaa tästä asettaaksesi henkilökunnan pysymään huoneissa, joihin olet heidät asettanut",
    diag_procedure      = "Jos lääkärin diagnoosi on epävarmempi kuin LÄHETÄ KOTIIN-prosentti, lähetetään potilas kotiin. Jos diagnoosi on varmempi kuin ANNA HOITO-prosentti, lähetetään potilas suoraan hoitoon",
    diag_termination    = "Potilaan diagnoosia jatketaan, kunnes lääkärit ovat yhtä varmoja kuin KESKEYTÄ PROSESSI-prosentti tai kaikkia diagnoosikoneita on kokeiltu",
    staff_rest          = "Kuinka väsynyttä henkilöstön pitää olla ennen kuin he saavat levätä",
  },

  -- Pay rise window
  pay_rise_window = {
    accept              = "Myönny vaatimuksiin",
    decline             = "Kieltäydy vaatimuksista - Anna lopputili sen sijaan",
  },

  -- Watch
  watch = {
    hospital_opening    = "Rakennusaika: sinulla on tämän verran aikaa jäljellä ennen kuin sairaala avataan potilaille. Paina vihreää AVAA-nappia avataksesi sairaalasi välittömästi.",
    emergency           = "Hätätilanne: Akuuttien potilaiden parantamiseen jäljellä oleva aika.",
    epidemic            = "Epidemia: Epidemian taltuttamiseen jäljellä oleva aika. Kun aika kuluu loppuun TAI tartunnan saanut potilas poistuu sairaalasta, terveystarkastaja saapuu vierailulle. Paina nappia aloittaaksesi ja lopettaaksesi rokotukset. Klikkaa potilaita kutsuaksesi sairaanhoitajan rokottamaan heidät.",
  },

  -- Rooms
  rooms = {
    gps_office          = "Potilaat tutkitaan ja diagnosoidaan alustavasti yleislääkärin toimistossa.",
    psychiatry          = "Psykiatrin vastaanotolla hoidetaan mielenhäiriöistä kärsiviä potilaita ja autetaan diagnosoinnissa. Vaatii psykiatriaan erikoistuneen lääkärin",
    ward                = "Vuodeosasto on hyödyllinen sekä diagnosoinnissa että hoidossa. Potilaita lähetetään tänne tarkkailtavaksi ja toipumaan leikkauksen jälkeen. Vaatii sairaanhoitajan",
    operating_theatre   = "Leikkaussalissa tarvitaan kaksi kirurgiaan erikoistunutta lääkäriä",
    pharmacy            = "Apteekissa sairaanhoitaja jakaa lääkkeitä niitä tarvitseville potilaille",
    cardiogram          = "Lääkäri tutkii potilaiden sydänkäyriä kardiogrammin avulla ja diagnosoi sydäntauteja",
    scanner             = "Lääkäri käyttää magneettikuvausta potilaiden diagnosoimiseen",
    ultrascan           = "Lääkäri käyttää ultraääntä potilaiden diagnosoimiseen",
    blood_machine       = "Lääkäri käyttää verikonetta potilaiden veren tutkimiseen ja diagnosoimiseen",
    x_ray               = "Lääkäri kuvaa röntgenillä potilaiden luut ja tekee niiden perusteella diagnooseja",
    inflation           = "Lääkäri käyttää pumppauskonetta pallopäisyyttä sairastavien potilaiden hoitoon",
    dna_fixer           = "Lääkäri käyttää DNA-konetta alienin DNA:sta kärsivien potilaiden hoidossa",
    hair_restoration    = "Lääkäri käyttää hiustenpalautinta kaljuuntumisesta kärsivien potilaiden hoitoon",
    tongue_clinic       = "Kieliklinikalla lääkäri hoitaa potilaita, joilla on löyhä kieli",
    fracture_clinic     = "Murtumaklinikkalla sairaanhoitaja korjaa potilaiden murtumia",
    training_room       = "Konsultointiin erikoistunut lääkäri pitää luentoja koulutushuoneessa ja opettaa muita lääkäreitä",
    electrolysis        = "Elektrolyysiklinikkalla lääkäri hoitaa turkinkasvua sairastavia potilaita",
    jelly_vat           = "Lääkäri käyttää hyytelömuovainta hyytelöitymisestä kärsivien potilaiden parantamiseen",
    staffroom           = "Lääkärit, sairaanhoitajat ja huoltomiehet käyttävät taukohuonetta lepäämiseen ja mielialansa parantamiseen",
    -- rehabilitation   = S[33][27], -- unused
    general_diag        = "Lääkäri suorittaa täällä perusdiagnoosin yleislääkärillä vierailleille potilaille. Halpa ja monien sairauksien diagnosointiin varsin tehokas huone",
    research_room       = "Tutkimukseen erikoistunut lääkäri voi kehittää täällä uusia lääkkeitä ja koneita sairauksien parantamiseksi",
    toilets             = "Rakenna käymälä, jotta potilaat eivät sotke sairaalaasi!",
    decontamination     = "Säteilyklinikalla lääkäri hoitaa vakavasta säteilystä kärsiviä potilaita",
  },

  -- Objects
  objects = {
    -- NB: most objects do not have a tooltip because they're not (extra-)buyable
    desk                = "Pöytä: Lääkäri voi käyttää pöydällä tietokonettaan.",
    cabinet             = "Arkistokaappi: Pitää sisällään potilastietoja, muistiinpanoja ja tutkimusaineistoa.",
    door                = "Ovi: Ihmiset avaavat ja sulkevat tätä vähän väliä.",
    bench               = "Penkki: Tarjoaa potilaille istumapaikan ja tekee odottamisesta mukavampaa.",
    table1              = S[40][ 6], -- unused
    chair               = "Tuoli: Potilaat istuvat tässä ja kertovat ongelmistaan ja oireistaan.",
    drinks_machine      = "Juoma-automaatti: Pitää potilaiden janon kurissa ja tuottaa tuloja sairaalalle.",
    bed                 = "Sänky: Vakavasti sairaat potilaat makaavat näissä.",
    inflator            = "Pumppauskone: Parantaa potilaat, jotka sairastavat pallopäisyyttä.",
    pool_table          = "Biljardipöytä: Auttaa henkilökuntaasi rentoutumaan.",
    reception_desk      = "Vastaanotto: Vaatii vastaanottoapulaisen, joka opastaa potilaita eteenpäin.",
    table2              = S[40][13], -- unused & duplicate
    cardio              = S[40][14], -- no description
    scanner             = S[40][15], -- no description
    console             = S[40][16], -- no description
    screen              = S[40][17], -- no description
    litter_bomb         = "Roskapommi: Sabotoi kilpailijan sairaalaa",
    couch               = S[40][19], -- no description
    sofa                = "Sohva: Työntekijät, jotka ovat taukohuoneessa, istuvat paikallaan sohvalla kuin parempaa rentoutumistapaa ei olisikaan.",
    crash_trolley       = S[40][21], -- no description
    tv                  = "TV: Harmi, ettei henkilökunnallasi ole yleensä aikaa katsoa lempiohjelmaansa loppuun.",
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
    toilet_sink         = "Pesuallas: Hygieniariippuvaiset potilaasi voivat pestä likaantuneet kätensä tässä. Jos altaita ei ole riittävästi, he tulevat tyytymättömiksi.",
    op_sink1            = S[40][34], -- no description
    op_sink2            = S[40][35], -- no description
    surgeon_screen      = S[40][36], -- no description
    lecture_chair       = "Luentotuoli: Lääkäriopiskelijasi istuvat tässä ja tuhertavat innokkaasti muistiinpanoja. Mitä enemmän tuoleja luokassa on sitä enemmän opiskelijoita sinne mahtuu.",
    projector           = S[40][38], -- no description
    bed2                = S[40][39], -- unused duplicate
    pharmacy_cabinet    = "Lääkekaappi: Lääkevalikoimasi löytyy täältä.",
    computer            = "Tietokone: Nerokas tiedonlähde",
    atom_analyser       = "Atomianalysaattori: Sijoitettuna tutkimusosastolle tämä nopeuttaa koko tutkimusprosessia.",
    blood_machine       = S[40][43], -- no description
    fire_extinguisher   = "Vaahtosammutin: Minimoi vaaran, jonka laitteiden vikaantuminen voi aiheuttaa.",
    radiator            = "Lämpöpatteri: Pitää huolta, ettei sairaalassasi pääse tulemaan kylmä.",
    plant               = "Kasvi: Pitää potilaiden mielialan korkealla ja puhdistaa ilmaa.",
    electrolyser        = S[40][47], -- no description
    jelly_moulder       = S[40][48], -- no description
    gates_of_hell       = S[40][49], -- no description
    bed3                = S[40][50], -- unused duplicate
    bin                 = "Roskakori: Potilaat heittävät roskansa tänne.",
    toilet              = "Eriö: Potilaat, öh... tekevät tarpeensa tänne.",
    swing_door1         = S[40][53], -- no description
    swing_door2         = S[40][54], -- no description
    shower              = S[40][55], -- no description
    auto_autopsy        = "Ruumiinavauskone: Mahtava apuväline uusien hoitomenetelmien kehittämisessä.",
    bookcase            = "Kirjahylly: Referenssimateriaalia lääkärille.",
    video_game          = "Videopeli: Anna henkilökuntasi rentoutua Hi-Octane-pelin parissa.",
    entrance_left       = S[40][59], -- no description
    entrance_right      = S[40][60], -- no description
    skeleton            = "Luuranko: Käytetään opetuksessa ja Halloween-koristeena.",
    comfortable_chair   = S[40][62], -- no description
  },
}

-- 32. Adviser
adviser = {

  -- Tutorial
  tutorial = {
    start_tutorial                      = "Lue tason kuvaus ja klikkaa hiiren vasemmalla painikkeella aloittaaksesi esittelyn.",
    build_reception                     = "Hei! Ensimmäisenä sairaalasi tarvitsee vastaanoton. Löydät sen osta kalusteita -valikosta.",
    order_one_reception                 = "Klikkaa hiiren vasemmalla painikkeella kerran vilkkuvaa aluetta valitaksesi yhden vastaanoton.",
    accept_purchase                     = "Klikkaa nyt vilkkuvaa aluetta ostaaksesi valitsemasi kalusteet.",
    rotate_and_place_reception          = "Klikkaa hiiren oikeaa painikketta pyörittääksesi vastaanotto haluamaasi suuntaan ja klikkaa vasemalla asettaaksesi se paikalleen.",
    reception_invalid_position          = "Vastaanotto näkyy harmaana, koska sitä ei voida sijoittaa tähän. Kokeile siirtää tai pyörittää sitä.",
    hire_receptionist                   = "Nyt tarvitset vastaanottoapulaisen ottamaan potilaasi vastaan ja ohjaamaan heidät oikeisiin huoneisiin.",
    select_receptionists                = "Klikkaa vilkkuvaa ikonia käydäksesi läpi saatavilla olevia vastaanottoapulaisia. Ikonissa näkyvä numero kertoo saatavilla olevien apulaisten määrän.",
    next_receptionist                   = "Tämä on listan ensimmäinen vastaanottoapulainen. Klikkaa vilkkuvaa ikonia nähdäksesi seuraavan henkilön.",
    prev_receptionist                   = "Klikkaa vilkkuvaa ikonia nähdäksesi edellisen henkilön.",
    choose_receptionist                 = "Valitse vastaanottoapulainen, jolla on hyvät taidot ja hyväksyttävä palkkavaatimus. Klikkaa vilkkuvaa ikonia palkataksesi hänet.",
    place_receptionist                  = "Poimi vastaanottoapulainen ja aseta hänet minne tahansa sairaalassasi. Hän löytää kyllä rakentamaasi vastaanottoon omin avuin.",
    receptionist_invalid_position       = "Et voi asettaa työntekijääsi tähän. Kokeile asettaa hänet sairaalan sisälle paikkaan, jossa on tyhjää lattiaa.",
    window_in_invalid_position          = "Ikkuna ei sovi tähän. Ole hyvä ja yritä asettaa se toiseen kohtaan seinällä.",
    choose_doctor                       = "Käy läpi kaikkien lääkäreiden taidot ja palkkavaatimukset ennen kuin päätät kenet haluat palkata.",
    click_and_drag_to_build             = "Rakentaaksesi yleislääkärin toimiston sinun pitää ensin päättää kuinka suuri siitä tulee. Pidä hiiren vasen nappi pohjassa ja vedä hiirtä muuttaaksesi huoneen kokoa.",
    build_gps_office                    = "Jotta voit alkaa diagnosoida potilaita, sinun pitää rakentaa yleislääkärin toimisto.",
    door_in_invalid_position            = "Hupsista! Yritit sijoittaa oven epäsopivaan paikkaan. Kokeile jotain toista kohtaa pohjapiirrustuksen seinässä.",
    confirm_room                        = "Klikkaa hiiren vasemmalla painikkeella vilkkuvaa ikonia, kun huone on valmis tai klikkaa X:ää palataksesi edelliseen vaiheeseen.",
    select_diagnosis_rooms              = "Klikkaa hiiren vasemmalla painikkeella vilkkuvaa ikonia nähdäksesi listan diagnoosihuoneista, joita voit rakentaa.",
    hire_doctor                         = "Tarvitset lääkärin tutkimaan ja hoitamaan potilaita.",
    select_doctors                      = "Klikkaa hiiren vasemmalla painikkeella vilkkuvaa ikonia nähdäksesi lääkärit, jotka ovat saatavilla työmarkkinoilla.",
    place_windows                       = "Aseta ikkunat paikalleen samaan tapaan kuin asetit oven. Sinun ei ole pakko rakentaa ikkunoita, mutta työntekijäsi eivät pitäisi siitä lainkaan.",
    place_doctor                        = "Aseta lääkäri minne tahansa sairaalassasi. Hän menee yleislääkärin toimistoon heti, kun joku tarvitsee hoitoa.",
    room_in_invalid_position            = "Hups! Tämä pohjapiirrustus ei kelpaa: punaiset alueet näyttävät, missä kohdin suunnitelmasi menee toisen huoneen päälle tai sairaalan ulkoseinien läpi.",
    doctor_in_invalid_position          = "Hei! Et voi laittaa lääkäriä tähän. Koeta sijoittaa hänet tyhjälle lattia-alueelle.",
    place_objects                       = "Klikkaa hiiren oikeaa painikketta pyörittääksesi kalusteita ja vasenta asettaaksesi ne paikalleen.",
    room_too_small                      = "Tämä pohjapiirrustus näkyy punaisena, koska se on liian pieni. Vedä hiirtä pidempi matka saadaksesi suurempi huone.",
    click_gps_office                    = "Klikkaa hiiren vasemmalla painikkeella vilkkuvaa aluetta valitaksesi yleislääkärin toimiston.",
    room_too_small_and_invalid          = "Pohjapiirrustus on liian pieni ja väärin aseteltu. Kokeile uudestaan.",
    object_in_invalid_position          = "Tämä kaluste on väärin asetettu. Ole hyvä ja sijoita se toiseen paikkaan tai pyöritä sitä saadaksesi se sopimaan.",
    place_door                          = "Siirrä hiiri pohjapiirrustuksen reunalle asettaaksesi ovi haluamaasi paikkaan.",
    room_big_enough                     = "Pohjapiirrustus on riittävän suuri. Kun päästät hiiren painikkeen, asetat sen paikalleen. Voit halutessasi jatkaa sen muokkaamista.",
    build_pharmacy                      = "Onnittelut! Seuraavaksi kannattaa rakentaa Apteekki ja palkata sairaanhoitaja, jotta sairaalasi on täysin toimintavalmis.",
    information_window                  = "Tiedoteikkunassa kerrotaan lisätietoja juuri rakentamastasi yleislääkärin toimistosta.",
  },

  -- Epidemic
  epidemic = {
    hurry_up            = "Jos et ota nopeasti epidemiaa hallintaasi, siitä seuraa suuria ongelmia. Kiirehdi!",
    serious_warning     = "Tartuntatauti leviää sairaalassasi ja alkaa muodostua vakavaksi ongelmaksi. Sinun on tehtävä jotain ja pian!",
    multiple_epidemies  = "Sinulla näyttää olevan useampi kuin yksi epidemia riesanasi. Tästä voi seurata pahaa jälkeä, joten nyt on tulenpalava kiire.",
  },

  -- Staff advice
  staff_advice = {
    need_handyman_machines      = "Sinun täytyy palkata huoltomiehiä, jos haluat koneidesi pysyvän kunnossa.",
    need_doctors                = "Tarvitset useita lääkäreitä. Kokeile siirtää parhaat lääkärisi huoneisiin, joihin on pisin jono.",
    need_handyman_plants        = "Sinun täytyy palkata huoltomies kastelemaan kasvejasi, etteivät ne kuole.",
    need_handyman_litter        = "Ihmiset valittavat, että sairaalasi muistuttaa kaatopaikkaa. Palkkaa huoltomies siivoamaan potilaidesi sotkut.",
    need_nurses                 = "Tarvitset useita sairaanhoitajia. Vuodeosastoa ja apteekkia voivat hoitaa vain sairaanhoitajat.",
    too_many_doctors            = "Sairaalassasi on liikaa lääkäreitä. Osalla heistä ei ole mitään tekemistä.",
    too_many_nurses             = "Uskoisin, että sinulla on liikaa sairaanhoitajia palkkalistoillasi.",
  },

  -- Earthquake
  earthquake = {
    damage      = "Maanjäristys on vioittanut %d laitetta ja %d potilasta on loukkaantunut sairaalassasi.", -- %d (count machines), &d (count patients)
    alert       = "Maanjäristysvaroitus. Maanjäristys vahingoittaa laitteitasi ja ne voivat lakata toimimasta kokonaan, jos niitä ei ole huollettu kunnolla.",
    ended       = "Huh. Se tuntui voimakkaalta järistykseltä - magnitudiksi mitattiin %d Richterin asteikolla.",
  },

  -- Multiplayer
  multiplayer = {
    objective_completed = "Olet saavuttanut kaikki tämän tason tavoitteet. Onnittelut!",
    everyone_failed     = "Kukaan ei ole saavuttanut asetettuja tavoitteita. Kaikki saavat siis jatkaa yrittämistä!",
    players_failed      = "Seuraavat pelaajat eivät ole saavuttaneet asetettuja tavoitteita: ",
    objective_failed    = "Et ole onnistunut saavuttamaan tämän tason tavoitteita.",

    poaching = {
      in_progress                       = "Yritän tiedustella josko tämä henkilö olisi kiinnostunut siirtymään palvelukseesi.",
      not_interested                    = "Hah! Häntä ei kiinnosta tulla töihin sinulle - hänellä on kaikki hyvin nykyisissä työpaikassaan.",
      already_poached_by_someone        = "Turha haaveilla! Joku muu yrittää jo parhaillaan viedä tätä työntekijää.",
    },
  },

  -- Surgery requirements
  surgery_requirements = {
    need_surgeons_ward_op       = "Tarvitset kaksi kirurgia ja vuodeosaston leikkaussalin lisäksi voidaksesi suorittaa kirurgisia toimenpiteitä.",
    need_surgeon_ward           = "Tarvitset vuodeosaston ja yhden kirurgin lisää voidaksesi suorittaa kirurgisia toimenpiteitä.",
  },

  -- Vomit wave
  vomit_wave = {
    started     = "Sairaalaasi näyttää levinneen oksennustautia aiheuttava virus. Jos olisit palkannut lisää huoltomiehiä pitämään paikat puhtaina, näin ei olisi päässyt käymään.",
    ended       = "Huh! Viruksen aiheuttama oksennustauti on saatu kuriin. Pidä sairaalasi puhtaampana jatkossa.",
  },

  -- Level progress
  level_progress = {
    nearly_won          = "Olet miltei saavuttanut tämän tason tavoitteet.",
    three_quarters_lost = "Vain yksi neljännes erottaa sinut lopullisesta tappiosta.",
    halfway_won         = "Olet jo puolittain voittanut tämän tason.",
    halfway_lost        = "Toinen jalkasi on jo haudassa tavotteiden suhteen.",
    nearly_lost         = "Tappiosi on viimeistä naulaa vaille valmis.",
    three_quarters_won  = "Vain yksi neljännes tavoitteista on enää suorittamatta.",
  },

  -- Staff place advice
  staff_place_advice = {
    receptionists_only_at_desk  = "Vain vastaanottoapulaiset voivat työskennellä vastaanotossa.",
    only_psychiatrists          = "Vain psykiatriaan erikoistuneet lääkärit voivat työskennellä psykiatrin vastaanotolla.",
    only_surgeons               = "Vain kirurgiaan erikoistuneet lääkärit voivat työskennellä leikkaussalissa.",
    only_nurses_in_room         = "%s sopii ainoastaan sairaanhoitajan hoidettavaksi.",
    only_doctors_in_room        = "%s sopii ainoastaan lääkärin hoidettavaksi.",
    only_researchers            = "Vain tutkimukseen erikoistuneet lääkärit voivat työskennellä tutkimusosastolla.",
    nurses_cannot_work_in_room  = "%s ei sovellu sairaanhoitajan hoidettavaksi.",
    doctors_cannot_work_in_room = "%s ei sovellu lääkärin hoidettavaksi.",
  },

  -- Research
  research = {
    machine_improved            = "Kehittyneempi %s on valmistunut tutkimusosastollasi.",
    autopsy_discovered_rep_loss = "Tieto automaattisesta ruumiinavauskoneestasi on vuotanut julkisuuteen. Ihmisiltä on odotettavissa negatiivinen reaktio.",
    drug_fully_researched       = "Lääkkeen %s kehitystyö on saatu päätökseen.",
    new_machine_researched      = "Uusi %s on saatu kehitettyä.",
    drug_improved               = "Kehittyneempi %s-lääke on valmistunut tutkimusosastollasi.",
    new_available               = "Uusi %s on nyt saatavilla.",
    new_drug_researched         = "Sairauteen %s on kehitetty uusi lääke.",
  },

  -- Boiler issue
  boiler_issue = {
    minimum_heat        = "Keskuslämmitys on sanonut työsopimuksensa irti. Vaikuttaisi siltä, että sairaalassasi oleville ihmisille tulee pian jäiset oltavat.",
    maximum_heat        = "Kellarissa oleva lämmitysuuni on hajonnut. Uuni on jumiutunut täydelle teholle ja ihmiset sulavat sairaalassasi! Sijoita runsaasti juoma-automaatteja kaikkialle.",
    resolved            = "Hyviä uutisia. Keskuslämmitys toimii taas niin kuin pitääkin. Lämpötilan ei enää pitäisi vaivata potilaita eikä henkilökuntaa.",
  },

  -- Competitors
  competitors = {
    staff_poached       = "Yksi työntekijöistäsi on palkattu kilpailevaan sairaalaan.",
    hospital_opened     = "Kilpaileva sairaala on avattu lähellä aluetta %s.",
    land_purchased      = "%s on ostanut itselleen tontin.",
  },

  -- Room requirements
  room_requirements = {
    research_room_need_researcher       = "Sinun täytyy palkata tutkimukseen erikoistunut lääkäri ennen kuin voit ottaa tutkimusosaston käyttöön.",
    op_need_another_surgeon             = "Tarvitset vielä yhden kirurgin lisää ennen kuin voit ottaa leikkaussalin käyttöön.",
    op_need_ward                        = "Sinun täytyy rakentaa vuodeosasto, jotta voit valvoa leikkauksessa käyneiden potilaiden paranemista.",
    reception_need_receptionist         = "Sinun täytyy palkata vastaanottoapulainen ottamaan potilaat vastaan sairaalaasi.",
    psychiatry_need_psychiatrist        = "Sinun täytyy palkata psykiatriaan erikoistunut lääkäri nyt, kun olet rakentanut psykiatrin vastaanoton.",
    pharmacy_need_nurse                 = "Tarvitset sairaanhoitajan huolehtimaan apteekistasi.",
    ward_need_nurse                     = "Sinun täytyy palkata sairaanhoitaja työskentelemään vuodeosastolla.",
    op_need_two_surgeons                = "Sinun täytyy palkata kaksi kirurgia, jotta voit suorittaa kirurgisia toimenpiteitä leikkaussalissasi.",
    training_room_need_consultant       = "Tarvitset konsultti-lääkärin opettamaan nuorempia lääkäreitäsi koulutushuoneessa.",
    gps_office_need_doctor              = "Sinun täytyy palkata lääkäri tekemään alustavia diagnooseja yleislääkärin toimistossa.",
  },

  -- Goals
  goals = {
    win = {
      money             = "Sinulta puuttuu %d$ rahaa tämän tason taloudellisten tavoitteiden saavuttamiseksi.",
      cure              = "Sinun pitää parantaa vielä %d potilasta tämän tason vaatimusten täyttämiseksi.",
      reputation        = "Suosiosi pitää olla vähintään %d edetäksesi suraavalle tasolle.",
      value             = "Sairaalasi arvon tulee ylittää %d, jotta saat tämän tason suoritettua onnistuneesti.",
    },
    lose = {
      kill = "Jos sairaalassasi kuolee vielä %d potilasta, häviät tämän tason!",
    },
  },

  -- Warnings
  warnings = {
    charges_too_low             = "Veloitat palveluistasi liian vähän. Tämä houkuttelee kyllä sairaalaasi runsaasti potilaita, mutta ansaitset vähemmän jokaista potilasta kohden.",
    charges_too_high            = "Hintasi ovat liian korkeat. Se tuottaa sinulle runsaasti rahaa lyhyellä tähtäimellä, mutta pitkällä tähtäimellä korkeat hinnat karkoittavat asiakkaita.",
    plants_thirsty              = "Sinun täytyy huolehtia kasveistasi. Ne ovat janoisia.",
    staff_overworked            = "Työntekijäsi ovat ylityöllistettyjä. Heistä tulee tehottomia ja he tekevät hengenvaarallisia virheitä ollessaan väsyneitä.",
    queue_too_long_at_reception = "Sinulla on liikaa potilaita odottamassa vastaanotossasi. Rakenna lisää vastaanottoja ja palkkaa niihin vastaanottoapulaiset.",
    queue_too_long_send_doctor  = "Jono huoneeseen %s on liian pitkä. Varmista, että huoneessa on lääkäri.",
    handymen_tired              = "Huoltomiehesi ovat erittäin väsyneitä. Anna heidän levätä riittävästi.",
    money_low                   = "Rahasi uhkaavat loppua, jollet puutu asioihin!",
    money_very_low_take_loan    = "Rahasi ovat miltei lopussa. Voit ottaa lainaa pankilta selvitäksesi tästä ainakin hetkeksi.",
    staff_unhappy               = "Henkilökuntasi on tyytymätön. Kokeile antaa heille bonuksia tai rakentaa heille taukohuone. Voit myös muuttaa taukokäytäntöä Sairaalan käytännöt -ikkunasta.",
    no_patients_last_month      = "Sairaalaasi ei tullut ainuttakaan uutta potilasta viime kuussa. Shokki!",
    queues_too_long             = "Jonot ovat liian pitkiä sairaalassasi.",
    patient_stuck               = "Yksi potilaistasi on eksynyt. Sinun pitäisi järjestää sairaalasi paremmin.",
    patients_too_hot            = "Potilailla on liian kuuma. Voit poistaa ylimääräisiä lämpöpattereita, laskea lämmityksen tehoa tai rakentaa lisää juoma-automaatteja.",
    doctors_tired               = "Lääkärisi ovat erittäin väsyneitä. Anna heille lepotaukoja ennen kuin jollekulle käy hassusti.",
    need_toilets                = "Potilaasi tarvitsevat käymälöitä. Rakenna ne helposti saavutettaviin paikkoihin.",
    machines_falling_apart      = "Laitteesi ovat hajoamispisteessä. Käske huoltomiehiäsi huoltamaan niitä välittömästi!",
    nobody_cured_last_month     = "Yhtä ainuttakaan potilasta ei saatu parannettua viime kuussa.",
    patients_thirsty            = "Potilaasi ovat janoisia. Sinun pitäisi antaa heille mahdollisuus ostaa juotavaa.",
    nurses_tired                = "Sairaanhoitajasi ovat erittäin väsyneitä. Anna heidän levätä riittävästi.",
    machine_severely_damaged    = "%s on hyvin lähellä täydellistä tuhoutumista.",
    reception_bottleneck        = "Vastaanotto on sairaalasi pullonkaula. Palkaa toinen vastaanottoapulainen.",
    bankruptcy_imminent         = "Huhuu! Tilanteesi lähestyy uhkaavasti konkurssia. Ole varovainen!",
    receptionists_tired         = "Vastaanottoapulaisesi ovat erittäin väsyneitä. Anna heidän levätä riittävästi.",
    too_many_plants             = "Sinulla on liikaa kasveja. Sairaalasi näyttää jo ihan viidakolta.",
    many_killed                 = "Sairaalassasi on kuollut jo %d potilasta. Tiesitkö, että tarkoituksena olisi ollut parantaa heidät.",
    need_staffroom              = "Rakenna henkilökunnan taukohuone viipymättä, jotta he pääsevät välillä lepäämäänkin.",
    staff_too_hot               = "Henkilökuntasi on sulamispisteessä. Laske sairaalasi lämpötilaa tai vähennä lämpöpattereita heidän huoneistaan.",
    patients_unhappy            = "Potilaasi ovat tyytymättömiä sairaalaasi. Sinun pitäisi tehdä jotakin saadaksesi sairaalasi mukavammaksi.",
    pay_back_loan               = "Sinulla on runsaasti rahaa. Voisit harkita lainasi lyhentämistä.",
  },

  -- Placement info
  placement_info = {
    door_can_place              = "Voit asettaa oven tähän, jos haluat.",
    window_can_place            = "Ikkuna voidaan rakentaa tähän. Se onnistuu hienosti.",
    door_cannot_place           = "Valitettavasti et voi rakentaa ovea tähän.",
    object_can_place            = "Valitsemasi kaluste voidaan sijoittaa tähän.",
    reception_can_place         = "Vastaanotto voidaan asettaa tähän.",
    staff_cannot_place          = "Et voi asettaa työntekijääsi tähän. Pahoittelut.",
    staff_can_place             = "Voit asettaa työntekijän tähän. ",
    object_cannot_place         = "Huhuu, ei tätä kalustetta voi sijoittaa tähän.",
    room_cannot_place           = "Huonetta ei voi sijoittaa tähän.",
    room_cannot_place_2         = "Huonetta ei voi rakentaa tähän.",
    window_cannot_place         = "Et voi rakentaa ikkunaa tähän.",
    reception_cannot_place      = "Vastaanottoa ei voi sijoittaa tähän.",
  },

  -- Praise
  praise = {
    many_benches        = "Potilailla on tarpeeksi istumapaikkoja. Hienoa.",
    many_plants         = "Mahtavaa. Sinulla on paljon kasveja. Potilaasi arvostavat sitä varmasti.",
    patients_cured      = "%d potilasta parannettu.",
  },

  -- Information
  information = {
    larger_rooms                        = "Suurempi huone saa työntekijät tuntemaan itsensä tärkeämmiksi, mikä parantaa heidän suoritustasoaan.",
    extra_items                         = "Ylimääräiset kalusteet huoneissa parantavat työntekijöiden viihtyvyyttä ja heidän suoritustasonsa paranee.",
    epidemic                            = "Sairaalassasi riehuu tarttuva epidemia. Sinun pitää tehdä jotain ja pian!",
    promotion_to_doctor                 = "Yhdestä harjoittelijastasi on tullut tohtori.",
    emergency                           = "Hätätilanne! Nyt tuli kiire! Vauhtia siellä!",
    patient_abducted                    = "Avaruusolennot ovat siepanneet yhden potilaasi.",
    first_cure                          = "Hyvää työtä! Olet onnistunut parantamaan ensimmäisen potilaasi.",
    promotion_to_consultant             = "Yhdestä tohtoristasi on tullut konsultti.",
    handyman_adjust                     = "Voit parantaa huoltomiestesi tehokkuutta säätämällä heidän prioriteettejaan.",
    promotion_to_specialist             = "Yksi lääkäreistäsi on saanut päätökseen erikoistumisensa %sksi.",
    patient_leaving_too_expensive       = "Eräs potilas lähtee sairaalastasi maksamatta laskuaan hoidosta huoneessa %s. Se oli liian kallista.",
    vip_arrived                         = "Huomio! - %s on saapunut sairaalaasi! Tee kaikkesi, jotta hänen jokainen tarpeensa tulee ripeästi täytetyksi.",
    epidemic_health_inspector           = "Terveysministeriö on kuullut sairaalaasi vaivaavasta epidemiasta. Voit valmistautua siihen, että terveystarkastaja saapuu varsin pian.",
    first_death                         = "Sairaalassasi on sattunut ensimmäinen kuolemantapaus. Kuinkas tässä nyt näin pääsi käymään?",
    pay_rise                            = "Yksi työntekijöistäsi uhkaa irtisanoutua. Valitse haluatko suostua hänen palkkavaatimukseensa vai antaa hänelle potkut. Klikkaa vasemmalla alalaidassa olevaa ikonia nähdäksesi kenestä on kyse.",
    place_windows                       = "Ikkunat tekevät huoneista valoisampia ja parantavat työntekijöidesi mielialaa.",
    fax_received                        = "Vasempaan alanurkkaan ilmestyvät ikonit ilmoittavat sinulle tärkeistä tiedoista ja päätöksistä, joita voit tehdä.",
    initial_general_advice = {
      rats_have_arrived         = "Rotat ovat vallanneet sairaalasi. Yritä ampua niitä hiirelläsi.",
      autopsy_available         = "Tutkijasi ovat keksineet ruumiinavauskoneen, jonka avulla voit hankkiutua eroon ei-toivotuista potilaista ja tehdä tutkimusta heidän jäänteillään. Koneen käyttämisen moraalinen hyväksyttävyys on kuitenkin erittäin kiistanalaista.",
      first_patients_thirsty    = "Sairaalassasi on janoisia ihmisiä. Osta lisää juoma-automaatteja heidän käyttöönsä.",
      research_now_available    = "Olet rakentanut ensimmäisen tutkimusosastosi. Nyt pääset käsiksi tutkimus-ikkunaan.",
      psychiatric_symbol        = "Psykiatriaan erikoistuneet lääkärit on merkitty symbolilla: |",
      decrease_heating          = "Ihmisillä on liian kuuma sairaalassasi. Säädä lämmitystäsi pienemälle kartta-ikkunasta.",
      surgeon_symbol            = "Kirurgiaan erikoistuneet lääkärit on merkitty symbolilla: {",
      first_emergency           = "Hätätilannepotilaiden pään päällä on sininen hälytysvalo. Paranna heidät ennen kuin he kuolevat tai aika loppuu kesken.",
      first_epidemic            = "Sairaalassasi on havaittu epidemia! Päätä, haluatko salata sen vai tehdä lain vaatiman ilmoituksen.",
      taking_your_staff         = "Joku yrittää houkutella henkilökuntaasi loikkaamaan palvelukseensa. Sinun täytyy taistella, jos et halua menettää heitä.",
      place_radiators           = "Ihmisillä on liian kylmä sairaalassasi. Voit asentaa lisää lämpöpattereita ostamalla niitä kalusteet-valikosta.",
      epidemic_spreading        = "Sairaalassasi on vakavaan tartuntatautiin sairastuneita. Yritä parantaa sairastuneet ennen kuin he lähtevät kotiin.",
      research_symbol           = "Tutkimukseen erikoistuneet lääkärit on merkitty symbolilla: }",
      machine_needs_repair      = "Sairaalassasi on kone joka täytyy korjata. Etsi rikkoutunut kone, joka epäilemättä jo savuaa, ja klikkaa sitä. Aukeavasta ruudusta saat käskettyä huoltomiehen korjaamaan sen.",
      increase_heating          = "Ihmisillä on liian kylmä sairaalassasi. Säädä lämmitystäsi suuremmalle kartta-ikkunasta.",
      first_VIP                 = "Sairaalaasi on saapumassa ensimmäinen VIP-potilas. Yritä varmistaa, ettei hän pääse näkemään mitään epähygienistä tai yhtään tyytymättömiä potilaita.",
    },
  },

  -- Build advice
  build_advice = {
    placing_object_blocks_door  = "Jos sijoitat kalusteita tähän, kukaan ei pääse ovesta sisään eikä ulos.",
    blueprint_would_block       = "Tämä huoneen pohjapiirrustus estäisi pääsyn joihinkin muihin huoneisiin. Kokeile muuttaa huoneen kokoa tai siirrä se toiseen paikkaan!",
    door_not_reachable          = "Ihmiset eivät pääse mitenkään ovelle, jos asetat sen tähän. Mietihän vähän.",
    blueprint_invalid           = "Tämä pohjapiirrustus ei ole kelvollinen.",
  },
}

-- Confirmation
confirmation = {
  quit                  = "Jos poistut nyt, kaikki tallentamattomat tiedot menetetään. Oletko varma, että haluat lopettaa pelin?",
  return_to_blueprint   = "Oletko varma, että haluat palauttaa tämän huoneen pohjapiirros-tilaan?",
  replace_machine       = "Oletko varma, että haluat korvata koneen %s hintaan %d$?", -- %s (machine name) %d (price)
  overwrite_save        = "Tällä nimellä on jo tallennettu peli. Oletko varma, että haluat tallentaa sen päälle?",
  delete_room           = "Oletko varma, että haluat poistaa tämän huoneen?",
  sack_staff            = "Oletko varma, että haluat irtisanoa tämän työntekijän?",
  restart_level         = "Oletko varma, että haluat aloittaa tason alusta?",
  needs_restart         = "Tämän asetuksen muuttaminen vaatii CorsixTH:n käynnistämisen uudelleen. Kaikki tallentamattomat muutokset menetetään. Oletko varma, että haluat jatkaa?",
  abort_edit_room       = "Huoneen rakentaminen tai muokkaaminen on kesken. Jos kaikki pakolliset kalusteet on asetettu huoneeseen, se valmistuu, mutta muutoin se poistetaan. Oletko varma, että haluat poistua?",
}

-- Bank manager
bank_manager = {
  hospital_value        = "Sairaalan arvo",
  balance               = "Rahaa tilillä",
  current_loan          = "Maksettavaa lainaa",
  interest_payment      = "Vuokrakulut",
  insurance_owed        = "Vakuutusvelka",
  inflation_rate        = "Inflaatio",
  interest_rate         = "Korkotaso",
  statistics_page = {
    date                = "Päivä",
    details             = "Tiedot",
    money_out           = "Kulut",
    money_in            = "Tulot",
    balance             = "Saldo",
    current_balance     = "Tilillä",
  },
}


-- Newspaper headlines
newspaper = {
  -- Seven categories of funny headlines. I think each category is related
  -- to one criterion you can lose to. TODO: categorize
  { "TOHTORI KAUHUN KIROUS", "OUTO LÄÄKÄRI LEIKKII JUMALAA", "TOHTORI EBOLA SHOKEERAA", "KUKA USKOO VIILTÄJÄKIRURGIIN?", "RATSIA PÄÄTTI VAARALLISEN LÄÄKETUTKIMUKSEN" },
  { "TOHTORI ANKKURI", "ITKEVÄT PSYKIATRIT", "KONSULTIN PAKOMATKA", "KIRURGINEN LAUKAUS", "KIRURGI JUO LASINSA TYHJÄKSI", "KIRURGIN HENKI" },
  { "LEIKKIVÄ PSYKIATRI", "TOHTORI ILMAN-HOUSUJA", "TOHTORI KAUHUISSAAN", "KIRURGIN NÄLKÄ" },
  { "LÄÄKÄRI VETÄÄ VÄLISTÄ", "ELINKAUPPA KUKOISTAA", "PANKKIHOLVIN OHITUSLEIKKAUS", "LÄÄKÄRIN PIKKURAHAT" },
  { "HOITAJAT PENKOVAT RUUMISARKUN", "LÄÄKÄRI TYHJENSI HAUDAN", "VUOTO VAATEKAAPISSA", "TOHTORI KUOLEMAN HIENO PÄIVÄ", "VIIMEISIN HOITOVIRHE", "KADONNEET LÄÄKÄRIT" },
  { "LÄÄKÄRI EROAA!", "LEPSU PUOSKARI", "HENGENVAARALLINEN DIAGNOOSI", "VAROMATON KONSULTTI", },
  { "TOHTORI HUOKAA HELPOTUKSESTA", "KIRURGI 'LEIKKAA' ITSENSÄ", "LÄÄKÄRIN PURKAUS", "LÄÄKÄRI LASKEE KAAPELIA", "LÄÄKE OLIKIN KURAA" },
}

-- Letters
-- TODO
letter = {
                --original line-ends:                                                 5                                        4                                                         2    3
  [1] = {
    [1] = "Hyvä %s//",
    [2] = "Mahtavaa! Olet johtanut tätä sairaalaa erinomaisesti. Me täällä hallinnossa haluamme tietää, oletko kiinnostunut lähtemään suuremman projektin johtoon. Meillä on työtarjous, johon uskomme sinun sopivan täydellisesti. Voimme tarjota sinulle palkkaa %d$. Mieti toki kaikessa rauhassa.//",
    [3] = "Oletko kiinnostunut työskentelemään %sn sairaalassa?",
  },
  [2] = {
    [1] = "Hyvä %s//",
    [2] = "Oikein hyvää työtä! Sairaalasi on kehittynyt hienosti. Meillä on toinen instituutio, jonka johtoon haluaisimme sinut sijoittaa, jos olet saatavilla. Voit jättää tarjouksen hyväksymättä, mutta takaamme, että tämä on ainakin harkitsemisen arvoista. Palkka on %d$//",
    [3] = "Haluatko töihin %sn sairaalaan?",
  },
  [3] = {
    [1] = "Hyvä %s//",
    [2] = "Sinun kautesi tässä sairaalassa on ollut todellinen onnistumistarina. Näemme, että sinulla on kirkas tulevaisuus edessäsi ja haluamme tarjota sinulle pestiä toisessa paikassa. Palkka on %d$ ja uskomme sinun ihastuvan sen tarjoamiin uusiin haasteisiin.//",
    [3] = "Otatko vastaan paikan %sn sairaalassa?",
  },
  [4] = {
    [1] = "Hyvä %s//",
    [2] = "Onnittelut! Me täällä hallinnosssa olemme erittäin vaikuttuneita saavutuksistasi sairaalasi johdossa. Olet todellinen terveysministeriön kultapoika. Me uskomme kuitenkin, että kaipaat vähän haastavampaa työtä. Saisit palkkaa %d$, mutta päätös on sinun.//",
    [3] = "Oletko kiinnostunut ottamaan vastaan työn %sn sairaalassa?",
  },
  [5] = {
    [1] = "Hyvä %s//",
    [2] = "Hei taas. Kunnioitamme toiveitasi, jos et halua jättää tätä upeaa sairaalaa taaksesi, mutta pyydämme, että harkitset tarjoustamme vakavasti. Tarjoamme %d$ palkkaa, jos suostut siirtymään toisen sairaalan johtoon ja saat hoidon sujumaan yhtä hyvin kuin tässä sairaalassa.//",
    [3] = "Haluaisitko siirtyä %sn sairaalaan?",
  },
  [6] = {
    [1] = "Hyvä %s//",
    [2] = "Tervehdys. Tiedämme miten onnellinen olet ollut tässä upeassa ja hyvin johdetussa instituutiossa, mutta uskomme, että sinulla olisi nyt oikea hetki edistää uraasi. Saat kunnioitettavan johtajan palkan: %d$, jos päätät suostua. Ainakin sitä kannattaa harkita.//",
    [3] = "Haluatko ottaa vastaan paikan %sn sairaalassa?",
  },
  [7] = {
    [1] = "Hyvä %s//",
    [2] = "Hyvää päivää! Terveysministeriö haluaa tietää suostutko harkitsemaan uudelleen päätöstäsi pysyä tämän sairaalan johdossa. Me arvostamme nykyistä sairaalaasi, mutta uskomme, että haastavampi tehtävä sopisi sinulle paremmin. Palkkatarjouksemme on %d$.//",
    [3] = "Hyväksytkö työn %sn sairaalassa?",
  },
  [8] = {
    [1] = "Hyvä %s//",
    [2] = "Hei taas. Kieltäydyit aiemmasta tarjouksestamme, joka käsitti ensiluokkaisen paikkan upouuden sairaalan johdossa ja korotetun palkan: %d$. Meidän mielestämme sinun kannattaisi harkita päätöstäsi uudelleen. Kyseessä on nimittäin täydellinen työ juuri sinulle.//",
    [3] = "Otatko paikan vastaan %sn sairaalassa? Ole niin kiltti ja suostu!",
  },
  [9] = {
    [1] = "Hyvä %s//",
    [2] = "Olet todistanut olevasi paras sairaalanjohtaja lääketieteen pitkän ja kunniakkaan historian aikana. Tällainen uskomaton saavutus ei voi jäädä palkitsematta, joten tarjoamme sinulle sairaalaosaston pääjohtajan virkaa. Tämä on kunniavirka ja siihen kuuluu %d$ palkkaa. Kunniaksesi järjestetään paraati ja ihmiset osoittavat sinulle kiitollisuuttaan mihin ikinä menetkin.//",
    [3] = "Kiitokset kaikesta tekemästäsi työstä. Toivotamme sinulle leppoisia puoliaikaisia eläkepäiviä.//",
  },
  [10] = {
    [1] = "Hyvä %s//",
    [2] = "Onnittelut! Olet onnistunut menestyksekkäästi johtamaan kaikkia sairaaloita, joiden johtoon olemme sinut asettaneet. Tämän mahtavan saavutuksen johdosta saat vapauden matkustaa ympäri maailmaa, %d$ eläkettä ja limusiinin. Haluaisimme sinun matkoillasi keskustelevan kiitollisten kansalaisten kanssa ja edistävän kaikkien sairaalojen toimintaa kaikkialla.//",
    [3] = "Olemme kaikki ylpeitä sinusta. Joukossamme ei ole ketään, joka ei olisi kiitollinen ihmishenkien pelastamiseksi tekemästäsi työstä.//",
  },
  [11] = {
    [1] = "Hyvä %s//",
    [2] = "Urasi on ollut esimerkillinen ja olet inspiraation lähde meille kaikille. Kiitokset kaikkien näiden sairaaloiden johtamisesta ja hyvästä työstä jokaisessa niistä. Haluamme myöntää sinulle %d$ elinikäistä palkkaa ja pyydämme ainoastaan, että kierrät kaupungista toiseen pitämässä luentoja siitä kuinka sait aikaan niin paljon niin nopeasti.//",
    [3] = "Olet esimerkki kaikille järkeville ihmisille ja nautit poikkeuksetta kaikkien ihmisten ihailua ympäri maailman.//",
  },
  [12] = {
    [1] = "Hyvä %s//",
    [2] = "Voitokas urasi parhaana sairaalanjohtajana sitten Mooseksen aikojen lähestyy loppuaan. Vaikutuksesi lääketieteen ihmeelliseen maailmaan on ollut niin mahtava, että ministeriö haluaa myöntää sinulle %d$ palkkaa, jos suostut silloin tällöin pitämään puheita, osallistumaan laivojen vesillelaskuihin ja esiintymään TV:n chatti-ohjelmissa.//",
    [3] = "Voit huoletta hyväksyä tämän tarjouksen, sillä työ ei ole rankkaa ja tarjoamme sinulle auton ja poliisisaattueen minne ikinä menetkin.//",
  },
}


-- Humanoid start of names
humanoid_name_starts = {
  [1] = "LEPPÄ",
  [2] = "VIIMA",
  [3] = "KUUSI",
  [4] = "KOIVU",
  [5] = "MÄNTY",
  [6] = "PAJU",
  [7] = "TAMMI",
  [8] = "PYÖKKI",
  [9] = "LAUTA",
  [10] = "NAULA",
  [11] = "SUUR",
  [12] = "SUVI",
  [13] = "VIIMA",
  [14] = "LOVI",
  [15] = "HURME",
  [16] = "KOTO",
  [17] = "NURMI",
  [18] = "PALO",
  [19] = "KULO",
  [20] = "PAASI",
  [21] = "KAIVO",
  [22] = "HAVU",
  [23] = "KARE",
  [24] = "HALLA",
  [25] = "NOKI",
  [26] = "KYTÖ",
  [27] = "KIVI",
  [28] = "KALJU",
  [29] = "TALAS",
  [30] = "VESI",
  [31] = "ILMA",
  [32] = "KANTO",
  [33] = "SUMU",
}

-- Humanoid end of names
humanoid_name_ends = {
  [1] = "KOSKI",
  [2] = "PELTO",
  [3] = "JÄRVI",
  [4] = "MAA",
  [5] = "LAAKSO",
  [6] = "MÄKI",
  [7] = "RINTA",
  [8] = "RANTA",
  [9] = "JOKI",
  [10] = "VAARA",
  [11] = "PURO",
  [12] = "VIITA",
  [13] = "VUORI",
  [14] = "PIHA",
  [15] = "VIRTA",
  [16] = "METSÄ",
  [17] = "RINNE",
  [18] = "HARJU",
  [19] = "LEHTO",
  [20] = "MALMI",
  [21] = "KORPI",
  [22] = "SAARI",
  [23] = "LAHTI",
  [24] = "KUNNAS",
  [25] = "KANGAS",
  [26] = "PÄÄ",
}


-- VIP names
vip_names = {
  health_minister = "Terveysministeri",
  "Namikkalan kunnanjohtaja", -- the rest is better organized in an array.
  "Walesin Prinssi",
  "Norjan suurlähettiläs",
  "Aung Sang Su Kyi",
  "Kaino Vieno Nuppu Lahdelma",
  "Sir David",
  "Dalai Lama",
  "Nobel-palkittu kirjailija",
  "Valioliigan jalkapalloilija",
  "Vuorineuvos Viita",
}

-- Deseases
diseases = {
  general_practice = {
    name = "Yleishoito",
  },
  alien_dna = {
    name        = "Alienin DNA",
    cause       = "Aiheuttaja - joutuminen facehugger-alienin uhriksi.",
    symptoms    = "Oireet - vaiheittainen muodonmuutos täysikasvuiseksi alieniksi ja halu tuhota kaikki kaupunkimme.",
    cure        = "Hoito - DNA poistetaan mekaanisesti, puhdistetaan ja siirretään nopeasti takaisin.",
  },
  baldness = {
    name        = "Kaljuus",
    cause       = "Aiheuttaja - valehteleminen ja tarinoiden keksiminen suosion toivossa.",
    symptoms    = "Oireet - kiiltävä kupoli ja nolotus.",
    cure        = "Hoito - Uudet hiukset sulautetaan saumattomasti potilaan päähän käyttäen kivuliasta konetta.",
  },
  bloaty_head = {
    name        = "Pallopäisyys",
    cause       = "Aiheuttaja - juuston haistelu ja puhdistamattoman sadeveden juominen.",
    symptoms    = "Oireet - hyvin epämukavat potilaalle.",
    cure        = "Hoito - Pää puhkaistaan ja pumpataan takaisin oikeaan paineeseen nokkelalla laitteella.",
  },
  broken_heart = {
    name        = "Särkynyt sydän",
    cause       = "Aiheuttaja - joku rikkaampi, nuorempi ja laihempi kuin potilas.",
    symptoms    = "Oireet - hallitsematon itku ja rasitusvamma jatkuvan lomakuvien repimisen johdosta.",
    cure        = "Hoito - Kaksi kirurgia avaa rintakehän ja korjaa sydämen hellästi pidättäen hengitystään.",
  },
  broken_wind = {
    name        = "Kaasujen karkailu",
    cause       = "Aiheuttaja - kuntosalin juoksumaton käyttäminen heti ruoan jälkeen.",
    symptoms    = "Oireet - takana seisovien ihmisten ärsyyntyminen.",
    cure        = "Hoito - Potilas juo nopeasti raskaan sekoituksen erityisiä vetisiä atomeja apteekissa.",
  },
  chronic_nosehair = {
    name        = "Krooniset nenäkarvat",
    cause       = "Aiheuttaja - nenän nyrpistäminen itseään heikompiosaisille ihmisille.",
    symptoms    = "Oireet - nenäparta, johon orava voisi tehdä pesän.",
    cure        = "Hoito - Sairaanhoitaja valmistaa apteekissa ällöttävän rohdon, joka nautitaan suun kautta.",
  },
  corrugated_ankles = {
    name        = "Taipuneet nilkat",
    cause       = "Aiheuttaja - liiallinen hidastetöyssyjen yli ajaminen.",
    symptoms    = "Oireet - kengät eivät sovi hyvin jalkaan.",
    cure        = "Hoito - Lievästi myrkyllinen seos yrttejä ja mausteita juodaan nilkkojen oikaisemiseksi.",
  },
  discrete_itching = {
    name        = "Paikallinen kutina",
    cause       = "Aiheuttaja - pienet hyönteiset, joilla on terävät hampaat.",
    symptoms    = "Oireet - raapiminen, joka johtaa ruumiinosien tulehduksiin.",
    cure        = "Hoito - Potilaalle juotetaan lääkesiirappia kutinan ehkäisemiseksi.",
  },
  fake_blood = {
    name        = "Valeveri",
    cause       = "Aiheuttaja - potilas on yleensä joutunut käytännön pilan uhriksi.",
    symptoms    = "Oireet - suonissa punaista nestettä, joka haihtuu joutuessaan kosketuksiin kankaan kanssa.",
    cure        = "Hoito - Psykiatrinen rauhoittelu on ainoa keino hoitaa ongelmaa.",
  },
  fractured_bones = {
    name        = "Murtuneet luut",
    cause       = "Aiheuttaja - putoaminen korkealta betonille.",
    symptoms    = "Oireet - voimakas napsahdus ja kyvyttömyys käyttää kyseisiä raajoja.",
    cure        = "Hoito - Potilaalle asetetaan kipsi, joka sitten poistetaan laser-toimisella kipsinpoistokoneella.",
  },
  gastric_ejections = {
    name        = "Vääntelehtivä vatsa",
    cause       = "Aiheuttaja - mausteinen meksikolainen tai intialainen ruoka.",
    symptoms    = "Oireet - puolittain sulanutta ruokaa poistuu potilaan elimistöstä satunnaisesti.",
    cure        = "Hoito - Erityisen sitouttamisnesteen juominen estää ruokapäästöjen syntymisen.",
  },
  golf_stones = {
    name        = "Golf-kivet",
    cause       = "Aiheuttaja - altistuminen golfpallojen sisältämälle myrkkykaasulle.",
    symptoms    = "Oireet - sekavuus ja edistynyt häpeä.",
    cure        = "Hoito - Kivet poistetaan leikkauksella, johon tarvitaan kaksi kirurgia.",
  },
  gut_rot = {
    name        = "Mahamätä",
    cause       = "Aiheuttaja - rouva Malisen 'Hauskaa iltaa' -viskiyskänlääke.",
    symptoms    = "Oireet - ei yskää, mutta ei vatsan limakalvojakaan.",
    cure        = "Hoito - Sairaanhoitaja sekoittaa apteekissa lääkeliemen, joka päälystää mahalaukun sisäpinnan.",
  },
  hairyitis = {
    name        = "Turkinkasvu",
    cause       = "Aiheuttaja - pitkittynyt altistuminen kuun valolle.",
    symptoms    = "Oireet - potilaille kehittyy herkistynyt hajuaisti.",
    cure        = "Hoito - Elektrolyysikone poistaa karvat ja sulkee huokoset.",
  },
  heaped_piles = {
    name        = "Kasautuneet pukamat",
    cause       = "Aiheuttaja - vesiautomaatin lähellä seisoskeleminen.",
    symptoms    = "Oireet - potilaasta tuntuu kuin hän istuisi marmorikuulapussin päällä.",
    cure        = "Hoito - Miellyttävä, mutta vahvasti hapokas juoma sulattaa pukamat sisältä.",
  },
  infectious_laughter = {
    name        = "Tarttuva nauru",
    cause       = "Aiheuttaja - klassiset TV:n komediasarjat.",
    symptoms    = "Oireet - avuton hihitys ja kuluneiden fraasien toistelu.",
    cure        = "Hoito - Ammattitaitoisen psykiatrin täytyy muistuttaa potilaalle, kuinka vakava hänen tilansa on.",
  },
  invisibility = {
    name        = "Näkymättömyys",
    cause       = "Aiheuttaja - radioaktiivisen (ja näkymättömän) muurahaisen purema",
    symptoms    = "Oireet - potilaat eivät kärsi lainkaan ja monet heistä hyödyntävät tilaansa tekemällä kepposia perheelleen",
    cure        = "Hoito - Apteekista saatava värikäs juoma palauttaa potilaat pikaisesti näkyviin",
  },
  iron_lungs = {
    name        = "Rautakeuhkot",
    cause       = "Aiheuttaja - kantakaupungin savusumu yhdistettynä kebabin jäänteisiin.",
    symptoms    = "Oireet - kyky syöstä tulta ja huutaa kovaa veden alla.",
    cure        = "Hoito - Kaksi kirurgia poistaa jähmettyneet keuhkot leikkaussalissa.",
  },
  jellyitis = {
    name        = "Hyytelöityminen",
    cause       = "Aiheuttaja - Runsaasti gelatiinia sisältävä ruokavalio ja liiallinen liikunta.",
    symptoms    = "Oireet - liiallinen hytkyminen ja runsas kaatuilu.",
    cure        = "Hoito - Potilas asetetaan vähäksi aikaa hyytelömuovaimeen erityisessä hyytelömuovainhuoneessa.",
  },
  kidney_beans = {
    name        = "Munuaispavut",
    cause       = "Aiheuttaja - jääkuutioiden murskaaminen juomaan.",
    symptoms    = "Oireet - kipuja ja jatkuvaa vessassa käymistä.",
    cure        = "Hoito - Kahden kirurgin täytyy poistaa pavut koskematta munuaisiin.",
  },
  king_complex = {
    name        = "Kuningas-kompleksi",
    cause       = "Aiheuttaja - Kuninkaan henki tunkeutuu potilaan tajuntaan ja ottaa vallan.",
    symptoms    = "Oireet - värikkäisiin samettikenkiin pukeutuminen ja juustohampurilaisten syöminen",
    cure        = "Hoito - Psykiatri kertoo vastaanotollaan potilaalle, kuinka älyttömän typerältä tämä näyttää",
  },
  pregnancy = {
    name        = "Raskaus",
    cause       = "Aiheuttaja - sähkökatkot kaupungistuneilla alueilla.",
    symptoms    = "Oireet - taukoamaton syöminen ja siihen liittyvä kaljamaha.",
    cure        = "Hoito - Lapsi poistetaan keisarinleikkauksella, pestään ja ojennetaan potilaalle.",
  },   -- unused
  ruptured_nodules = {
    name        = "Repeytyneet kyhmyt",
    cause       = "Aiheuttaja - benjihyppääminen kylmässä säässä.",
    symptoms    = "Oireet - potilaan on mahdotonta istua mukavasti.",
    cure        = "Hoito - Kaksi kirurgia poistaa kyhmyt vakain käsin.",
  },
  serious_radiation = {
    name        = "Vakava säteily",
    cause       = "Aiheuttaja - erehtyminen plutonium-isotooppien ja purukumin välillä.",
    symptoms    = "Oireet - potilaat tuntevat itsensä hyvin, hyvin huonovointisiksi.",
    cure        = "Hoito - Potilas tulee asettaa puhdistussuihkuun ja pestä huolellisesti.",
  },
  slack_tongue = {
    name        = "Velttokielisyys",
    cause       = "Aiheuttaja - krooninen saippuaoopperoista puhuminen.",
    symptoms    = "Oireet - kieli turpoaa viisi kertaa pidemmäksi kuin normaalisti.",
    cure        = "Hoito - Kieli asetetaan paloittelijaan, joka lyhentää sen nopeasti, tehokkaasti ja kivuliaasti.",
  },
  sleeping_illness = {
    name        = "Unitauti",
    cause       = "Aiheuttaja - yliaktiivinen unirauhanen kitalaessa.",
    symptoms    = "Oireet - ylitsepääsemätön tarve käydä nukkumaan kaikkialla.",
    cure        = "Hoito - Sairaanhoitaja annostelee suuren annoksen voimakasta piristysainetta.",
  },
  spare_ribs = {
    name        = "Liikakyljykset",
    cause       = "Aiheuttaja - kylmillä kivilattioilla istuminen.",
    symptoms    = "Oireet - epämiellyttävä rintavuuden tunne.",
    cure        = "Hoito - Kaksi kirurgia poistaa kyljykset ja antaa ne folioon käärittynä potilaalle kotiin vietäväksi.",
  },
  sweaty_palms = {
    name        = "Hikiset kädet",
    cause       = "Aiheuttaja - työhaastattelujen kammo.",
    symptoms    = "Oireet - kätteleminen potilaan kanssa on kuin pitelisi vastakasteltua pesusientä.",
    cure        = "Hoito - Psykiatrin pitää saada potilas luopumaan päässään luomastaan sairaudesta.",
  },
  the_squits = {
    name        = "Oksennustauti",
    cause       = "Aiheuttaja - lattialta löytyneen pizzan syöminen.",
    symptoms    = "Oireet - yäk, osaat varmaan arvatakin.",
    cure        = "Hoito - Kuitupitoinen sekoitus lankamaisia lääkekemikaaleja kiinteyttää potilaan sisuskalut.",
  },
  third_degree_sideburns = {
    name        = "Kolmannen asteen pulisongit",
    cause       = "Aiheuttaja - kaipuu takaisin 1970-luvulle.",
    symptoms    = "Oireet - iso kampaus, leveälahkeiset housut, korokepohjakengät ja kiillemeikit.",
    cure        = "Hoito - Psykiatrin täytyy vakuuttaa potilas siitä, että hänen karvakehyksensä ovat inhottavat.",
  },
  transparency = {
    name        = "Läpinäkyvyys",
    cause       = "Aiheuttaja - jogurtin nuoleminen purkkien kansista.",
    symptoms    = "Oireet - potilaan liha muuttuu läpinäkyväksi ja kammottavaksi.",
    cure        = "Hoito - Apteekista saatava erityisellä tavalla jäähdytetty ja värjätty vesi parantaa taudin.",
  },
  tv_personalities = {
    name        = "TV-kasvous",
    cause       = "Aiheuttaja - päiväsaikaan lähetettävä ohjelmatarjonta.",
    symptoms    = "Oireet - kuvitelma, että potilas pystyy juontamaan ruoanlaitto-ohjelman.",
    cure        = "Hoito - Psykiatrin tulee suostutella potilas myymään televisionsa ja ostamaan radio sen tilalle.",
  },
  uncommon_cold = {
    name        = "Epätavallinen flunssa",
    cause       = "Aiheuttaja - pienet räkähiukkaset ilmassa.",
    symptoms    = "Oireet - vuotava nenä, aivastelu ja värjäytyneet keuhkot.",
    cure        = "Hoito - Iso kulaus apteekissa valmisteltua epätavallista flunssalääkettä tekee taudista menneen talven lumia.",
  },
  unexpected_swelling = {
    name        = "Odottamaton turvotus",
    cause       = "Aiheuttaja - mikä tahansa odottamaton.",
    symptoms    = "Oireet - turvotus.",
    cure        = "Hoito - Kahden kirurgin suorittama puhkomistoimenpide poistaa turvotuksen.",
  },
  diag_scanner = {
    name = "Diagn. magn. kuvaus",
  },
  diag_blood_machine = {
    name = "Diagn. verikone",
  },
  diag_cardiogram = {
    name = "Diagn. kardiogrammi",
  },
  diag_x_ray = {
    name = "Diagn. röntgen",
  },
  diag_ultrascan = {
    name = "Diagn. ultraääni",
  },
  diag_general_diag = {
    name = "Diagn. yleisdiagn.",
  },
  diag_ward = {
    name = "Diagn. vuodeosasto.",
  },
  diag_psych = {
    name = "Diagn. psykiatria",
  },
  autopsy = {
    name = "Ruumiinavaus",
  },
}


-- Faxes
fax = {
  -- Debug fax
  debug_fax = {
    -- never seen this, must be a debug option of original TH
    -- TODO: make this nicer if we ever want to make use of it
    close_text  = "Kyllä, kyllä, kyllä!",
    text1       = "PARAS MÄÄRÄ %d", -- %d
    text2       = "IHMISIÄ YHTEENSÄ SAIRAALASSA %d VERRATTUNA %d:N", -- %d %d
    text3       = "LUVUT    : LÄÄKÄRIT %d HOITAJAT %d ALUE %d HUONEET %d HINTA %d", -- %d %d %d %d %d
    text4       = "KERTOIMET: LÄÄKÄRIT %d HOITAJAT %d ALUE %d HUONEET %d HINTA %d", -- %d %d %d %d %d
    text5       = "OSUUS    : LÄÄKÄRIT %d HOITAJAT %d ALUE %d HUONEET %d HINTA %d PROSENTTIA", -- %d %d %d %d %d
    text6       = "SEURAAVAT KERTOIMET OTETAAN MYÖS HUOMIOON",
    text7       = "MAINE: %d ODOTETTU %d VÄHENNYS %d", -- %d %d %d
    text8       = "WC-TILAT %d IHMISIÄ PALVELTU %d VÄHENNYS %d", -- %d %d %d
    text9       = "ONNETTOMUUDET %d SALLITTU (KK) %d (%d)VÄHENNYS %d", -- %d %d %d %d
    text10      = "KUOLEMAT %d SALLITTU (KK) %d (%d) VÄHENNYS %d", -- %d %d %d %d
    text11      = "IHMISIÄ TÄSSÄ KUUSSA %d", -- %d
  },

  -- Emergency
  emergency = {
    choices = {
      accept        = "Kyllä, minä pystyn hoitamaan sen",
      refuse        = "Ei, en voi ottaa potilaita vastaan",
    },
    location                            = "%s on sattunut onnettomuus.",
    num_disease                         = "%d ihmisellä on diagnosoitu %s, joka vaatii välitöntä hoitoa.",
    num_disease_singular                = "Yhdellä henkilöllä on havaittu %s, joka vaatii välitöntä hoitoa.",
    cure_possible_drug_name_efficiency  = "Sinulla on jo tarvittavat laitteet ja taidot. Tarvittava lääke on %s ja sen teho on %d%%.",
    cure_possible                       = "Sinulla on jo tarvittavat laitteet ja taidot, joten sinun pitäisi selviytyä tilanteesta ongelmitta.",
    cure_not_possible_build_and_employ  = "Sinun täytyy rakentaa %s ja palkata %s.",
    cure_not_possible_build             = "Sinun täytyy rakentaa %s.",
    cure_not_possible_employ            = "Sinun täytyy palkata %s.",
    cure_not_possible                   = "Et pysty hoitamaan tätä sairautta tällä hetkellä.",
    bonus                               = "Jos pystyt hoitamaan tämän hätätapauksen täydellisesti, saat bonuksena %d$. Jos kuitenkin epäonnistut, sairaalasi maine saa aimo kolauksen.",

    locations = {
      "Tomin asekellarissa",
      "Innovaatioyliopistossa",
      "Puskalan puutarhakeskuksessa",
      "Vaarallisten aineiden tutkimuskesuksessa",
      "Tanssimessuilla",
      "Mykkä Papukaija -baarissa",
      "Ison Taunon hautajaispaviljongissa",
      "Taj-curryravintolassa",
      "Pekan petrokemikaalikirpputorilla",
    },
  },

  emergency_result = {
    close_text          = "Sulje ikkuna",
    earned_money        = "Enimmäisbonus oli %d$ ja ansaitsit %d$.",
    saved_people        = "Pelastit %d ihmistä, kun potilaita oli %d.",
  },

  -- Deseace discovered
  disease_discovered_patient_choice = {
    choices = {
      send_home = "Lähetä potilas kotiin.",
      wait      = "Pyydä potilasta odottamaan sairaalassa vähän aikaa.",
      research  = "Lähetä potilas tutkimusosastolle.",
    },
    need_to_build_and_employ    = "Sinun täytyy rakentaa %s ja palkkata %s, jotta voit hoitaa sairautta.",
    need_to_build               = "Sinun täytyy rakentaa %s, jotta voit hoitaa sairautta.",
    need_to_employ              = "Palkkaa %s auttamaan potilasta.",
    can_not_cure                = "Et voi hoitaa tätä sairautta.",
    disease_name                = "Työntekijäsi ovat havainneet uuden sairauden, jonka nimi on %s.",
    what_to_do_question         = "Miten haluat meidän toimivan potilaan kanssa?",
    guessed_percentage_name     = "Työntekijäsi ovat joutuneet arvaamaan, mikä potilasta vaivaa. %d%%:n todennäköisyydellä sairaus on %s.",
  },

  disease_discovered = {
    close_text                  = "Uusi sairaus on löydetty.",
    can_cure                    = "Pystyt parantamaan sairauden.",
    need_to_build_and_employ    = "Sinun täytyy rakentaa %s ja palkata %s, jotta voit hoitaa sairautta.",
    need_to_build               = "Sinun täytyy rakentaa %s, jotta voit hoitaa sairautta.",
    need_to_employ              = "Palkkaa %s hoitamaan potilaita, joilla on tämä sairaus.",
    discovered_name             = "Työntekijäsi ovat havainneet uuden sairauden, jonka nimi on %s.",
  },

  -- Epidemic
  epidemic = {
    choices = {
      declare   = "Julkista epidemia, maksa sakko ja hyväksy vahinko sairaalasi maineelle.",
      cover_up  = "Yritä hoitaa kaikki tartunnan saaneet potilaat ennen kuin annettu aika loppuu tai kukaan lähtee sairaalastasi.",
    },

    disease_name                = "Lääkärisi ovat löytäneet helposti tarttuvan %s-kannan.",
    declare_explanation_fine    = "Jos julkistat epidemian, sinun täytyy maksaa sakkoja %d$, sairaalasi maine kokee kolauksen ja kaikki potilaasi rokotetaan automaattisesti.",
    cover_up_explanation_1      = "Toisaalta, jos yrität salata epidemian, sinulla on rajoitetusti aikaa parantaa kaikki tartunnan saaneet potilaat.",
    cover_up_explanation_2      = "Jos vierailulle saapuva terveystarkastaja saa selville, että olet salaillut epidemiaa, seuraukset voivat olla hyvin vakavat.",
  },

  -- Epidemic result
  epidemic_result = {
    close_text = "Hurraa!",

    failed = {
      part_1_name       = "Yrittäessään salata sairaalassasi riehuneen helposti tarttuvan %s-epidemian",
      part_2            = "henkilökuntasi on päästänyt sairauden leviämään sairaalan ympärillä asuvaan väestöön.",
    },
    succeeded = {
      part_1_name       = "Terveystarkastaja on kuullut huhuja, että sairaalassasi on riehunut %s-epidemia",
      part_2            = "Hän ei ole kuitenkaan pystynyt näyttämään näitä huhuja todeksi.",
    },

    compensation_amount         = "Hallitus on myöntänyt sinulle %d$ korvauksena vahingoista, joita nämä valheet ovat sairaalasi maineelle aiheuttaneet.",
    fine_amount                 = "Hallitus on julistanut kansallisen hätätilan ja määrännyt sinulle %d$ sakkoja.",
    rep_loss_fine_amount        = "Sanomalehdet pääsevät huomenna kirjoittamaan tästä etusivullaan. Maineesi tahrautuu pahasti ja joudut maksamaan %d$ sakkoja.",
    hospital_evacuated          = "Terveyslautakunnalla ei ole muuta vaihtoehtoa kuin evakuoida sairaalasi.",
  },

  -- VIP visit query
  vip_visit_query = {
    choices = {
      invite    = "Lähetä virallinen kutsu VIP-potilaalle.",
      refuse    = "Kieltäydy ottamasta VIP-vierasta vastaan jollakin tekosyyllä.",
    },
    vip_name = "%s on esittänyt toiveen päästä käymään sairaalassasi.",
  },

  -- VIP visit result
  vip_visit_result = {
    close_text          = "Kiitos käynnistä ja tervetuloa uudestaan.",
    telegram            = "Sähke!",
    vip_remarked_name   = "%s kommentoi vierailuaan sairaalassasi seuraavasti:",
    cash_grant          = "Sairaalallesi on tehty käteislahjoitus, jonka arvo on %d$.",
    rep_boost           = "Sairaalasi maine on parantunut.",
    rep_loss            = "Sairaalasi maine on huonontunut.",

    remarks = {
      super = {
        "Mikä mahtava sairaala. Seuraavan kerran, kun olen sairas, haluan sinne hoitoon.",
        "No tuota voi jo kutsua sairaalaksi.",
        "Uskomaton sairaala. Ja minun pitäisi tietää; olen käynyt aika monessa.",
      },
      good = {
        "Hyvin johdettu laitos. Kiitos, että kutsuit minut sinne.",
        "Hmm. Ei totisesti yhtään hullumpi sairaala.",
        "Nautin käynnistä mukavassa sairaalassasi. Tekeekö kenenkään mieli intialaista?",
      },
      mediocre = {
        "No, olen nähnyt huonompiakin, mutta voisit kyllä tehdä hieman parannuksia.",
        "Voi että. Ei mikään mukava paikka, jos tuntee olonsa kurjaksi.",
        "Rehellisesti sanoen se oli ihan perussairaala. Odotin vähän enemmän.",
      },
      bad = {
        "Miksi vaivauduin? Se oli kauheampaa kuin nelituntinen ooppera!",
        "Inhottava paikka. Kutsutaanko tuota sairaalaksi? Sikolättihän tuo oli!",
        "Olen kyllästynyt käymään tuollaisissa haisevissa koloissa julkisuuden henkilönä. Minä eroan!",
      },
      very_bad = {
        "Mikä läävä! Yritän saada sen lakkautettua.",
        "En ole koskaan nähnyt noin kamalaa sairaalaa. Mikä häpeätahra!",
        "Olen järkyttynyt. Ei tuota voi kutsua sairaalaksi! Minä tarvitsen juotavaa.",
      },
    },
  },

  -- Diagnosis failed
  diagnosis_failed = {
    choices = {
      send_home         = "Lähetä potilas kotiin",
      take_chance       = "Ota riski ja kokeile luultavinta hoitoa.",
      wait              = "Pyydä potilasta odottamaan, että saat rakennettua lisää diagnoosihuoneita.",
    },
    situation                           = "Olemme käyttäneet kaikkia diagnoosimenetelmiämme potilaan tutkimiseen, mutta emme tiedä vieläkään varmasti, mikä on vialla.",
    what_to_do_question                 = "Miten toimimme potilaan kanssa?",
    partial_diagnosis_percentage_name   = "Tiedämme %d%%:n todennäköisyydellä, että potilaan sairaus on %s.",
  },
}

-- Queue window
queue_window = {
  num_in_queue       = "Jono",
  num_expected       = "Odotettu",
  num_entered        = "Käyntejä",
  max_queue_size     = "Jono enint.",
}

-- Dynamic info
dynamic_info = {
  patient = {
    actions = {
      dying                             = "Tekee kuolemaa!",
      awaiting_decision                 = "Odottaa päätöstäsi",
      queueing_for                      = "Jonossa: %s", -- %s
      on_my_way_to                      = "Matkalla: %s", -- %s
      cured                             = "Parantunut!",
      fed_up                            = "Saanut tarpeekseen ja lähtee sairaalasta",
      sent_home                         = "Lähetetty kotiin",
      sent_to_other_hospital            = "Lähetetty toiseen sairaalaan",
      no_diagnoses_available            = "Ei diagnosointivaihtoehtoja jäljellä",
      no_treatment_available            = "Hoitoa ei ole tarjolla - Menen kotiin",
      waiting_for_diagnosis_rooms       = "Odottaa, että rakennat lisää diagnoosihuoneita",
      waiting_for_treatment_rooms       = "Odottaa, että rakennat lisää hoitohuoneita",
      prices_too_high                   = "Hinnat ovat liian korkeat - Menen kotiin",
      epidemic_sent_home                = "Terveystarkastaja lähettänyt kotiin",
      epidemic_contagious               = "Tautini on tarttuva",
      no_gp_available                   = "Odottaa, että rakennat yleislääkärin toimiston",
    },
    diagnosed           = "Diagnoosi: %s", -- %s
    guessed_diagnosis   = "Arvattu diagnoosi: %s", -- %s
    diagnosis_progress  = "Diagnosointiprosessi",
    emergency           = "Hätätilanne: %s", -- %s (disease name)
  },
  vip                   = "Vieraileva VIP",
  health_inspector      = "Terveystarkastaja",

  staff = {
    psychiatrist_abbrev = "Psyk.",
    tiredness           = "Väsymys",
    ability             = "Kyvyt", -- unused?
    actions = {
      waiting_for_patient       = "Odottaa potilasta",
      wandering                 = "Vaeltaa ympäriinsä",
      going_to_repair           = "Korjattava: %s", -- %s (name of machine)
      heading_for               = "Matkalla kohteeseen: %s",
      fired                     = "Erotettu",
    },
  },

  object = {
    strength            = "Kestävyys: %d", -- %d (max. uses)
    times_used          = "Käyttökertoja: %d", -- %d (times used)
    queue_size          = "Jonon pituus: %d", -- %d (num of patients)
    queue_expected      = "Odotettu jonon pituus: %d", -- %d (num of patients)
  },
}

-- Miscellangelous
-- Category of strings that fit nowhere else or we are not sure where they belong.
-- If you think a string of these fits somewhere else, please move it there.
-- Don't forget to change all references in the code and other language files.
misc = {
  grade_adverb = {
    mildly      = "lievästi",
    moderately  = "keskimääräisesti",
    extremely   = "vakavasti",
  },
  done  = "Valmis",
  pause = "Keskeytä",

  send_message          = "Lähetä viesti pelaajalle %d", -- %d (player number)
  send_message_all      = "Lähetä viesti kaikille pelaajille",

  save_success  = "Peli tallennettu",
  save_failed   = "VIRHE: Pelin tallentaminen ei onnistunut",

  hospital_open = "Sairaala avattu",
  out_of_sync   = "Peli ei ole synkronisoitu",

  load_failed   = "VIRHE: Pelin lataaminen ei onnistunut",
  low_res       = "Matala resol.",
  balance       = "Tasapainotiedosto:",

  mouse = "Hiiri",
  force = "Voima",
}

original_credits = {
  " ",
  " ",
  " ",
  " ",
  " ",
  " ",
  " ",
  " ",
  " ",
  " ",
  " ",
  ":Suunnittelu ja toteutus",
  ":Bullfrog Productions",
  " ",
  ":Pluto Development Team",
  ",",
  "Mark Webley",
  "Gary Carr",
  "Matt Chilton",
  "Matt Sullivan",
  "Jo Rider",
  "Rajan Tande",
  "Wayne Imlach",
  "Andy Bass",
  "Jon Rennie",
  "Adam Coglan",
  "Natalie White",
  " ",
  " ",
  " ",
  ":Ohjelmointi",
  ",",
  "Mark Webley",
  "Matt Chilton",
  "Matt Sullivan",
  "Rajan Tande",
  " ",
  " ",
  " ",
  ":Ulkoasu",
  ",",
  "Gary Carr",
  "Jo Rider",
  "Andy Bass",
  "Adam Coglan",
  " ",
  " ",
  " ",
  ":Oheisohjelmointi",
  ",",
  "Ben Deane",
  "Gary Morgan",
  "Jonty Barnes",
  " ",
  " ",
  " ",
  ":Oheisulkoasu",
  ",",
  "Eoin Rogan",
  "George Svarovsky",
  "Saurev Sarkar",
  "Jason Brown",
  "John Kershaw",
  "Dee Lee",
  " ",
  " ",
  " ",
  ":Alkuanimaatio",
  ",",
  "Stuart Black",
  " ",
  " ",
  " ",
  ":Musiikki ja äänet",
  ",",
  "Russell Shaw",
  "Adrian Moore",
  " ",
  " ",
  " ",
  ":Oheismusiikki",
  ",",
  "Jeremy Longley",
  "Andy Wood",
  " ",
  " ",
  " ",
  ":Kuuluttajan ääni",
  ",",
  "Rebecca Green",
  " ",
  " ",
  " ",
  ":Tasojen suunnittelu",
  ",",
  "Wayne Imlach",
  "Natalie White",
  "Steven Jarrett",
  "Shin Kanaoya",
  " ",
  " ",
  " ",
  ":Skriptaus",
  ",",
  "James Leach",
  "Sean Masterson",
  "Neil Cook",
  " ",
  " ",
  " ",
  ":Tuotekehitys",
  " ",
  ":Grafiikkamoottori",
  ",",
  "Andy Cakebread",
  "Richard Reed",
  " ",
  " ",
  " ",
  ":Tuotekehitystuki",
  ",",
  "Glenn Corpes",
  "Martin Bell",
  "Ian Shaw",
  "Jan Svarovsky",
  " ",
  " ",
  " ",
  ":Kirjastot ja työkalut",
  " ",
  ":Dos ja Win 95 kirjasto",
  ",",
  "Mark Huntley",
  "Alex Peters",
  "Rik Heywood",
  " ",
  " ",
  " ",
  ":Verkkokirjasto",
  ",",
  "Ian Shippen",
  "Mark Lamport",
  " ",
  " ",
  " ",
  ":Äänikirjasto",
  ",",
  "Russell Shaw",
  "Tony Cox",
  " ",
  " ",
  " ",
  ":Asennusohjelma",
  ",",
  "Andy Nuttall",
  "Tony Cox",
  "Andy Cakebread",
  " ",
  " ",
  " ",
  ":Moraalinen tuki",
  ",",
  "Peter Molyneux",
  " ",
  " ",
  " ",
  ":Testausmanageri",
  ",",
  "Andy Robson",
  " ",
  " ",
  " ",
  ":Päätestaajat",
  ",",
  "Wayne Imlach",
  "Jon Rennie",
  " ",
  " ",
  " ",
  ":Pelitestaajat",
  ",",
  "Jeff Brutus",
  "Wayne Frost",
  "Steven Lawrie",
  "Tristan Paramor",
  "Nathan Smethurst",
  " ",
  "Ryan Corkery",
  "Simon Doherty",
  "James Dormer",
  "Martin Gregory",
  "Ben Lawley",
  "Joel Lewis",
  "David Lowe",
  "Robert Monczak",
  "Dominic Mortoza",
  "Karl O'Keeffe",
  "Michael Singletary",
  "Andrew Skipper",
  "Stuart Stephen",
  "David Wallington",
  " ",
  "Ja kaikki pelitestaajina toimineet harjoittelijat",
  " ",
  " ",
  " ",
  ":Tekninen tuki",
  ",",
  "Kevin Donkin",
  "Mike Burnham",
  "Simon Handby",
  " ",
  " ",
  " ",
  ":Markkinointi",
  ",",
  "Pete Murphy",
  "Sean Ratcliffe",
  " ",
  " ",
  " ",
  ":Kiittäen:",
  ",",
  "Tamara Burke",
  "Annabel Roose",
  "Chris Morgan",
  "Pete Larsen",
  " ",
  " ",
  " ",
  ":PR",
  ",",
  "Cathy Campos",
  " ",
  " ",
  " ",
  ":Dokumentaatio",
  ",",
  "Mark Casey",
  "Richard Johnston",
  "James Lenoel",
  "Jon Rennie",
  " ",
  " ",
  " ",
  ":Dokumentaatio & pakkaussuunnittelu",
  ",",
  "Caroline Arthur",
  "James Nolan",
  " ",
  " ",
  " ",
  ":Lokalisaation projektimanageri",
  ",",
  "Carol Aggett",
  " ",
  " ",
  " ",
  ":Lokalisaatio",
  ",",
  "Sandra Picaper",
  "Sonia 'Sam' Yazmadjian",
  " ",
  "Bettina Klos",
  "Alexa Kortsch",
  "Bianca Normann",
  " ",
  "C.T.O. S.p.A. Zola Predosa (BO)",
  "Gian Maria Battistini",
  "Maria Ziino",
  "Gabriele Vegetti",
  " ",
  "Elena Ruiz de Velasco",
  "Julio Valladares",
  "Ricardo Martínez",
  " ",
  "Kia Collin",
  "CBG Consult",
  "Ulf Thor",
  " ",
  " ",
  " ",
  ":Tuotanto",
  ",",
  "Rachel Holman",
  " ",
  " ",
  " ",
  ":Tuottaja",
  ",",
  "Mark Webley",
  " ",
  " ",
  " ",
  ":Apulaistuottaja",
  ",",
  "Andy Nuttall",
  " ",
  " ",
  " ",
  ":Toiminnot",
  ",",
  "Steve Fitton",
  " ",
  " ",
  " ",
  ":Yrityshallinto",
  ",",
  "Audrey Adams",
  "Annette Dabb",
  "Emma Gibbs",
  "Lucia Gobbo",
  "Jo Goodwin",
  "Sian Jones",
  "Kathy McEntee",
  "Louise Ratcliffe",
  " ",
  " ",
  " ",
  ":Yritysjohto",
  ",",
  "Les Edgar",
  "Peter Molyneux",
  "David Byrne",
  " ",
  " ",
  ":Kaikki Bullfrog Productions -työntekijät",
  " ",
  " ",
  " ",
  ":Erityiskiitokset",
  ",",
  "Kaikille Frimley Park Hospital -sairaalassa",
  " ",
  ":Erityisesti",
  ",",
  "Beverley Cannell",
  "Doug Carlisle",
  " ",
  " ",
  " ",
  ":Pitäkää ajatukset liikkeessä",
  " ",
  " ",
  " ",
  " ",
  " ",
  " ",
  " ",
  " ",
  " ",
  " ",
  " ",
  " ",
  " ",
  " ",
  " ",
  " ",
  " ",
  " ",
  ".",
}

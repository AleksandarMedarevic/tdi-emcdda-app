# config.example.R ────────────────────────────────────────────────────────────
# PRIMER konfiguracije — kopirajte u config.R i popunite stvarnim vrednostima.
# config.R NE IDE na GitHub, ovaj fajl (config.example.R) ide.
# ─────────────────────────────────────────────────────────────────────────────

# ── Nazivi kolona ─────────────────────────────────────────────────────────────
# Redosled mora tacno odgovarati kolonama u vasem ulaznom Excel fajlu.
# Broj kolona: 66
KOLONE_ULAZ <- c(
  "Kolona_01",   # ID zapisa
  "Kolona_02",   # Okrug
  "Kolona_03",   # Ustanova
  "Kolona_04",   # Organizaciona jedinica
  "Kolona_05",   # Opstina
  "Kolona_06",   # Datum pocetka popunjavanja
  "Kolona_07",   # Datum dostavljanja
  "Kolona_08",   # Ime
  "Kolona_09",   # Prezime
  "Kolona_10",   # Drzavljanstvo
  "Kolona_11",   # Jedinstveni identifikator
  "Kolona_12",   # Datum rodjenja
  "Kolona_13",   # Pol
  "Kolona_14",   # Sifra lica
  "Kolona_15",   # Prebivaliste
  "Kolona_16",   # Gde zivi
  "Kolona_17",   # Gde zivi - drugo
  "Kolona_18",   # Sa kim zivi
  "Kolona_19",   # Sa kim zivi - drugo
  "Kolona_20",   # Radni status
  "Kolona_21",   # Radni status - drugo
  "Kolona_22",   # Obrazovanje
  "Kolona_23",   # Deca
  "Kolona_24",   # Uzrast najmladjeg deteta
  "Kolona_25",   # Zivi sa decom
  "Kolona_26",   # Zivi sa maloletnicima
  "Kolona_27",   # Glavni uzrok zavisnosti
  "Kolona_28",   # Glavni uzrok - navedite
  "Kolona_29",   # Nacin korisicenja
  "Kolona_30",   # Ucestalost korisicenja
  "Kolona_31",   # Uzrast pocetka korisicenja
  "Kolona_32",   # Sporedni uzrok 1
  "Kolona_33",   # Sporedni uzrok 1 - navedite
  "Kolona_34",   # Sporedni uzrok 2
  "Kolona_35",   # Sporedni uzrok 2 - navedite
  "Kolona_36",   # Sporedni uzrok 3
  "Kolona_37",   # Sporedni uzrok 3 - navedite
  "Kolona_38",   # Vise supstanci istovremeno
  "Kolona_39",   # Meseci bez supstanci
  "Kolona_40",   # Injektiranje
  "Kolona_41",   # Uzrast prvog injektiranja
  "Kolona_42",   # Deljenje igala
  "Kolona_43",   # Testiranje HIV
  "Kolona_44",   # Rezultat HIV
  "Kolona_45",   # Testiranje Hepatitis C
  "Kolona_46",   # Rezultat Hepatitis C
  "Kolona_47",   # Testiranje Hepatitis B
  "Kolona_48",   # Rezultat Hepatitis B
  "Kolona_49",   # Datum pocetka epizode lecenja
  "Kolona_50",   # Ranije lecenje - alkohol
  "Kolona_51",   # Godina prvog lecenja - alkohol
  "Kolona_52",   # Ranije lecenje - PAS
  "Kolona_53",   # Godina prvog lecenja - PAS
  "Kolona_54",   # Ranije lecenje - kockanje
  "Kolona_55",   # Godina prvog lecenja - kockanje
  "Kolona_56",   # Upucivanje
  "Kolona_57",   # Upucivanje - drugo
  "Kolona_58",   # Tip centra
  "Kolona_59",   # Tip centra - drugo
  "Kolona_60",   # OST ikada
  "Kolona_61",   # Godina prve OST
  "Kolona_62",   # OST trenutno
  "Kolona_63",   # Godina trenutne OST
  "Kolona_64",   # OST propisana u ovom centru
  "Kolona_65",   # Lek u OST
  "Kolona_66"    # Lek u OST - drugo
)

# ── Kolone sa datumima ────────────────────────────────────────────────────────
KOLONE_DATUMI <- c(
  "Kolona_06",   # Datum pocetka popunjavanja
  "Kolona_07",   # Datum dostavljanja
  "Kolona_12",   # Datum rodjenja
  "Kolona_49"    # Datum pocetka epizode lecenja
)

# ── Vrednosti za filtriranje ──────────────────────────────────────────────────
FILTER_ISKLJUCI_UZROK    <- c("vrednost_alkohol", "vrednost_kockanje")
FILTER_ISKLJUCI_LECENJE  <- c("vrednost_nastavak", "vrednost_drugi_centar")
FILTER_ISKLJUCI_SPOREDNI <- "vrednost_kockanje"

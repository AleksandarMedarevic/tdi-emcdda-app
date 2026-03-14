# helpers.R ---------------------------------------------------------------
# Pomoćne funkcije za generisanje TDI/EMCDDA tabela
# Projekat: Obrada podataka "bolesti zavisnosti" iz .sjz.rs
# Autori: Milica Savic, Aleksandar Medarevic
#
# OUTPUT: Popunjava TDI XLS template (jedan fajl, tabele složene vertikalno)
#         Koristi openxlsx za pisanje u specifične ćelije

# =========================================================================
# BIBLIOTEKE
# =========================================================================

library(openxlsx)

# =========================================================================
# GLOBALNE KONSTANTE
# =========================================================================

OPIOIDI <- c(
  "11 - Heroin", "12 - Metadon", "13 - Buprenorfin", "14 - Fentanil",
  "15 - Tramadol", "16 - Opioid, bez detaljnih informacija",
  "17 - Drugi opioidi (navedite)"
)
KOKAIN <- c(
  "21 - Prah kokaina", "22 - Krek", "23 - Drugi kokain (navedite)"
)
STIMULANSI <- c(
  "31 - Amfetamin", "32 - Metamfetamin", "33 - Ekstazi (MDMA i derivati)",
  "34 - Sintetički katinoni", "35 - Stimulans, bez detaljnih informacija",
  "36 - Drugi stimulansi (navedite)"
)
HIPNOTICI <- c(
  "41 - Barbiturati", "42 - Benzodiazepini", "43 - GHB/GBL",
  "44 - Pregabalin", "45 - Hipnotik i sedativ, bez detaljnih informacija",
  "46 - Drugi hipnotici i sedativi (navedite)"
)
HALUCINOGENI <- c(
  "51 - LSD", "52 - Ketamin", "53 - Halucinogen, bez detaljnih informacija",
  "54 - Drugi halucinogeni (navedite)"
)
KANABIS <- c(
  "70 - Marihuana", "71 - Hašiš",
  "72 - Kanabis bez detaljnih informacija", "73 - Drugi kanabis (navedite)"
)

NIKAD_LECEN    <- "5 - Ne, nije se nikad ranije lečilo"
LECEN_ISTI     <- "2 - Da, ranije se lečilo u istom centru, ali ne u poslednjih 6 meseci"
LECEN_DRUGI    <- "4 - Da, ranije se lečilo u drugom centru, ali ne u poslednjih 6 meseci"
LECEN_NEPOZNAT <- "0 - Nepoznat podatak"

TIP_AMBULANTNO <- "1 - Ambulantno lečenje/dnevna bolnica"
TIP_BOLNICKO   <- "2 - Bolničko lečenje"
TIP_ZATVOR     <- "3 - Lečenje u zatvoru"
TIP_LEKAR      <- "4 - Izabrani lekar"
TIP_AGENCIJA   <- "6 - Agencija niskog praga"
TIP_DRUGO      <- "5 - Drugo"
TIP_NEPOZNATO  <- "0 - Nepoznato"

INJ_NIKAD      <- "1 - Ne, nikada"
INJ_30DANA     <- "2 - Da, u poslednjih 30 dana"
INJ_12MES      <- "3 - Da, u poslednjih 12 meseci, ali ne i u poslednjih 30 dana"
INJ_VISE12     <- "4 - Da, pre više od 12 meseci"
INJ_ODBIJA     <- "5 - Ne želi da odgovori"
INJ_NEPOZNATO  <- "0 - Nepoznat podatak"

# Putanje fajlova
TEMPLATE_FAJL <- "data/TDI_template.xlsx"  # Konvertovana kopija TDI_2022_XX_XX.xls
IZLAZNI_FAJL  <- "data/izlazniPodaci.xlsx"
SHEET_NAME    <- 1  # Indeks ili ime sheeta u template-u

# =========================================================================
# MAPA TABELA
# Ključ: ID tabele (npr "8.1.1")
# start: redni broj prvog reda (title header) u parsed CSV-u (1-baziran)
# data_offset: koliko redova ispod title-a počinju podaci (obično 2: title + col_header)
# col_start: prva kolona sa podacima u xlsx (1=A, 2=B...) — podaci su u kolonama B+
# =========================================================================

TABELA_REDOVI <- list(
  "8.1.1"  = list(start = 177, data_offset = 2, col_start = 2),
  "8.1.2"  = list(start = 185, data_offset = 2, col_start = 2),
  "8.1.3"  = list(start = 193, data_offset = 2, col_start = 2),
  "9.1.1"  = list(start = 210, data_offset = 2, col_start = 2),
  "9.1.2"  = list(start = 247, data_offset = 2, col_start = 2),
  "9.1.3"  = list(start = 284, data_offset = 2, col_start = 2),
  "10.1.1" = list(start = 328, data_offset = 2, col_start = 2),
  "10.1.2" = list(start = 365, data_offset = 2, col_start = 2),
  "10.1.3" = list(start = 402, data_offset = 2, col_start = 2),
  "11.1.1" = list(start = 446, data_offset = 2, col_start = 2),
  "11.1.2" = list(start = 483, data_offset = 2, col_start = 2),
  "11.1.3" = list(start = 520, data_offset = 2, col_start = 2),
  "11.1.4" = list(start = 557, data_offset = 2, col_start = 2),
  "11.1.5" = list(start = 594, data_offset = 2, col_start = 2),
  "11.1.6" = list(start = 631, data_offset = 2, col_start = 2),
  "11.1.7" = list(start = 668, data_offset = 2, col_start = 2),
  "11.1.8" = list(start = 705, data_offset = 2, col_start = 2),
  "11.1.9" = list(start = 742, data_offset = 2, col_start = 2),
  "12.1.1" = list(start = 786, data_offset = 2, col_start = 2),
  "12.1.2" = list(start = 823, data_offset = 2, col_start = 2),
  "12.1.3" = list(start = 860, data_offset = 2, col_start = 2),
  "13.1.1" = list(start = 904, data_offset = 2, col_start = 2),
  "13.1.2" = list(start = 918, data_offset = 2, col_start = 2),
  "13.1.3" = list(start = 932, data_offset = 2, col_start = 2),
  "14.1.1" = list(start = 953, data_offset = 2, col_start = 2),
  "14.1.2" = list(start = 967, data_offset = 2, col_start = 2),
  "14.1.3" = list(start = 981, data_offset = 2, col_start = 2),
  "15.1.1" = list(start = 1002, data_offset = 2, col_start = 2),
  "15.1.2" = list(start = 1016, data_offset = 2, col_start = 2),
  "15.1.3" = list(start = 1030, data_offset = 2, col_start = 2),
  "16.1.1" = list(start = 1051, data_offset = 2, col_start = 2),
  "16.1.2" = list(start = 1065, data_offset = 2, col_start = 2),
  "16.1.3" = list(start = 1079, data_offset = 2, col_start = 2),
  "17.1.1" = list(start = 1100, data_offset = 2, col_start = 2),
  "17.1.2" = list(start = 1114, data_offset = 2, col_start = 2),
  "17.1.3" = list(start = 1128, data_offset = 2, col_start = 2),
  "18.1.1" = list(start = 1149, data_offset = 2, col_start = 2),
  "18.1.2" = list(start = 1163, data_offset = 2, col_start = 2),
  "18.1.3" = list(start = 1177, data_offset = 2, col_start = 2),
  "19.1.1" = list(start = 1198, data_offset = 2, col_start = 2),
  "19.1.2" = list(start = 1235, data_offset = 2, col_start = 2),
  "19.1.3" = list(start = 1272, data_offset = 2, col_start = 2),
  "20.1.1" = list(start = 1316, data_offset = 2, col_start = 2),
  "20.1.2" = list(start = 1353, data_offset = 2, col_start = 2),
  "20.1.3" = list(start = 1390, data_offset = 2, col_start = 2),
  "21.1.1" = list(start = 1434, data_offset = 2, col_start = 2),
  "21.1.2" = list(start = 1471, data_offset = 2, col_start = 2),
  "21.1.3" = list(start = 1508, data_offset = 2, col_start = 2),
  "22.1.1" = list(start = 1552, data_offset = 2, col_start = 2),
  "22.1.2" = list(start = 1589, data_offset = 2, col_start = 2),
  "22.1.3" = list(start = 1626, data_offset = 2, col_start = 2),
  "23.1.1" = list(start = 1670, data_offset = 2, col_start = 2),
  "23.1.2" = list(start = 1688, data_offset = 2, col_start = 2),
  "23.1.3" = list(start = 1706, data_offset = 2, col_start = 2),
  "24.1.1" = list(start = 1731, data_offset = 2, col_start = 2),
  "25.1.1" = list(start = 1746, data_offset = 2, col_start = 2),
  "25.1.2" = list(start = 1763, data_offset = 2, col_start = 2),
  "25.1.3" = list(start = 1780, data_offset = 2, col_start = 2),
  "25.1.4" = list(start = 1797, data_offset = 2, col_start = 2),
  "25.1.5" = list(start = 1814, data_offset = 2, col_start = 2),
  "25.1.6" = list(start = 1831, data_offset = 2, col_start = 2),
  "26.1.1" = list(start = 1876, data_offset = 2, col_start = 2),
  "26.1.2" = list(start = 1887, data_offset = 2, col_start = 2),
  "26.1.3" = list(start = 1898, data_offset = 2, col_start = 2),
  "27.1.1" = list(start = 1916, data_offset = 2, col_start = 2),
  "27.1.2" = list(start = 1927, data_offset = 2, col_start = 2),
  "27.1.3" = list(start = 1938, data_offset = 2, col_start = 2),
  "28.1.1" = list(start = 1956, data_offset = 2, col_start = 2),
  "29.1.1" = list(start = 1975, data_offset = 2, col_start = 2),
  "29.1.2" = list(start = 2012, data_offset = 2, col_start = 2)
)

# =========================================================================
# CORE: Pisanje matrice vrednosti u workbook (openxlsx)
# matrica: matrix(nrow, ncol) — redovi = data rows, kolone = data columns
# =========================================================================

pisi_tabelu <- function(wb, tabela_id, matrica) {
  info <- TABELA_REDOVI[[tabela_id]]
  if (is.null(info)) stop(paste("Tabela", tabela_id, "nije definisana u TABELA_REDOVI"))
  if (is.null(dim(matrica))) matrica <- matrix(matrica, ncol = 1)

  first_row <- info$start + info$data_offset
  first_col <- info$col_start

  for (r in seq_len(nrow(matrica))) {
    for (c in seq_len(ncol(matrica))) {
      val <- matrica[r, c]
      if (!is.na(val)) {
        writeData(wb, sheet = SHEET_NAME,
                  x        = val,
                  startRow = first_row + r - 1,
                  startCol = first_col + c - 1,
                  colNames = FALSE)
      }
    }
  }
}

# =========================================================================
# POMOĆNE FUNKCIJE NISKOG NIVOA
# =========================================================================

n_filter <- function(df, kolona, vrednosti) {
  as.integer(df |> filter(.data[[kolona]] %in% vrednosti) |> nrow())
}

mean_r <- function(df, kolona) {
  round(as.numeric(df |> summarise(m = mean(.data[[kolona]], na.rm = TRUE)) |> pull(m)), 1)
}

sd_r <- function(df, kolona) {
  round(as.numeric(df |> summarise(s = sd(.data[[kolona]], na.rm = TRUE)) |> pull(s)), 1)
}

n_valid <- function(df, kolona) {
  as.integer(df |> summarise(n = sum(!is.na(.data[[kolona]]))) |> pull(n))
}

filter_status <- function(df, status) {
  if (is.null(status)) return(df)
  st_col <- "Da_li_se_lice_ranije_lechilo_od_bolesti_zavisnosti_povezane_sa_psihoaktivnim_supstancama"
  if (status == "nikad") {
    df |> filter(.data[[st_col]] == NIKAD_LECEN)
  } else {
    df |> filter(.data[[st_col]] %in% c(LECEN_ISTI, LECEN_DRUGI))
  }
}

# =========================================================================
# RAČUNANJE VEKTORA ZA PRIMARNU DROGU (33 elemenata, bez header-a)
# =========================================================================

broji_po_drogi <- function(df) {
  col <- "Glavni_uzrok_zavisnosti"
  r1  <- n_filter(df, col, OPIOIDI)
  r2  <- n_filter(df, col, "11 - Heroin")
  r3  <- n_filter(df, col, "12 - Metadon")
  r4  <- n_filter(df, col, "13 - Buprenorfin")
  r5  <- n_filter(df, col, "14 - Fentanil")
  r6  <- n_filter(df, col, c("15 - Tramadol","16 - Opioid, bez detaljnih informacija","17 - Drugi opioidi (navedite)"))
  r7  <- n_filter(df, col, KOKAIN)
  r8  <- n_filter(df, col, "21 - Prah kokaina")
  r9  <- n_filter(df, col, "22 - Krek")
  r10 <- n_filter(df, col, "23 - Drugi kokain (navedite)")
  r11 <- n_filter(df, col, STIMULANSI)
  r12 <- n_filter(df, col, "31 - Amfetamin")
  r13 <- n_filter(df, col, "32 - Metamfetamin")
  r14 <- n_filter(df, col, "33 - Ekstazi (MDMA i derivati)")
  r15 <- n_filter(df, col, "34 - Sintetički katinoni")
  r16 <- n_filter(df, col, c("35 - Stimulans, bez detaljnih informacija","36 - Drugi stimulansi (navedite)"))
  r17 <- n_filter(df, col, HIPNOTICI)
  r18 <- n_filter(df, col, "41 - Barbiturati")
  r19 <- n_filter(df, col, "42 - Benzodiazepini")
  r20 <- n_filter(df, col, "43 - GHB/GBL")
  r21 <- n_filter(df, col, c("44 - Pregabalin","45 - Hipnotik i sedativ, bez detaljnih informacija","46 - Drugi hipnotici i sedativi (navedite)"))
  r22 <- n_filter(df, col, HALUCINOGENI)
  r23 <- n_filter(df, col, "51 - LSD")
  r24 <- n_filter(df, col, "52 - Ketamin")
  r25 <- n_filter(df, col, c("53 - Halucinogen, bez detaljnih informacija","54 - Drugi halucinogeni (navedite)"))
  r26 <- n_filter(df, col, "60 - Isparljivi inhalanti")
  r27 <- n_filter(df, col, KANABIS)
  r28 <- n_filter(df, col, c("70 - Marihuana","71 - Hašiš"))
  r29 <- 0L
  r30 <- n_filter(df, col, c("72 - Kanabis bez detaljnih informacija","73 - Drugi kanabis (navedite)"))
  r31 <- n_filter(df, col, "88 - Druga supstanca (navedite)")
  r32 <- 0L
  r33 <- r1 + r7 + r11 + r17 + r22 + r26 + r27 + r31
  c(r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,
    r16,r17,r18,r19,r20,r21,r22,r23,r24,r25,r26,r27,r28,r29,r30,r31,r32,r33)
}

# 10-elementni vektor za grupe droga (tabela 13)
broji_grupe_droga <- function(df) {
  col <- "Glavni_uzrok_zavisnosti"
  r1 <- n_filter(df,col,OPIOIDI); r2 <- n_filter(df,col,KOKAIN)
  r3 <- n_filter(df,col,STIMULANSI); r4 <- n_filter(df,col,HIPNOTICI)
  r5 <- n_filter(df,col,HALUCINOGENI); r6 <- n_filter(df,col,"60 - Isparljivi inhalanti")
  r7 <- n_filter(df,col,KANABIS); r8 <- n_filter(df,col,"88 - Druga supstanca (navedite)")
  r9 <- 0L; r10 <- r1+r2+r3+r4+r5+r6+r7+r8
  c(r1,r2,r3,r4,r5,r6,r7,r8,r9,r10)
}

# Statistike po drogi za tabelu 11 (34 = 33 + Total)
statistika_po_drogi <- function(df, fn, stat_col) {
  col <- "Glavni_uzrok_zavisnosti"
  grupe <- list(
    OPIOIDI, "11 - Heroin", "12 - Metadon", "13 - Buprenorfin", "14 - Fentanil",
    c("15 - Tramadol","16 - Opioid, bez detaljnih informacija","17 - Drugi opioidi (navedite)"),
    KOKAIN, "21 - Prah kokaina", "22 - Krek", "23 - Drugi kokain (navedite)",
    STIMULANSI, "31 - Amfetamin", "32 - Metamfetamin", "33 - Ekstazi (MDMA i derivati)",
    "34 - Sintetički katinoni",
    c("35 - Stimulans, bez detaljnih informacija","36 - Drugi stimulansi (navedite)"),
    HIPNOTICI, "41 - Barbiturati", "42 - Benzodiazepini", "43 - GHB/GBL",
    c("44 - Pregabalin","45 - Hipnotik i sedativ, bez detaljnih informacija","46 - Drugi hipnotici i sedativi (navedite)"),
    HALUCINOGENI, "51 - LSD", "52 - Ketamin",
    c("53 - Halucinogen, bez detaljnih informacija","54 - Drugi halucinogeni (navedite)"),
    "60 - Isparljivi inhalanti", KANABIS, c("70 - Marihuana","71 - Hašiš"),
    NULL,  # synthetic cannabinoids
    c("72 - Kanabis bez detaljnih informacija","73 - Drugi kanabis (navedite)"),
    "88 - Druga supstanca (navedite)", NULL
  )
  rezultati <- vapply(grupe, function(g) {
    if (is.null(g)) return(NA_real_)
    fn(df |> filter(.data[[col]] %in% g), stat_col)
  }, numeric(1))
  c(rezultati, fn(df, stat_col))
}

# Grupe uzrasta (iste za tabele 12, 21)
GRUPE_UZRAST <- c("0-14","15-19","20-24","25-29","30-34","35-39",
                   "40-44","45-49","50-54","55-59","60-64","65+")

# =========================================================================
# GENERIČKA: 33-redna matrica droga x kategorije
# kategorije_vals: lista vektora vrednosti (NULL = Total)
# =========================================================================
tabela_kat_matrica <- function(df, kolona_kat, kategorije_vals) {
  m <- matrix(0L, nrow = 33, ncol = length(kategorije_vals))
  for (j in seq_along(kategorije_vals)) {
    val <- kategorije_vals[[j]]
    pod <- if (is.null(val)) df else df |> filter(.data[[kolona_kat]] %in% val)
    m[, j] <- broji_po_drogi(pod)
  }
  m
}

# =========================================================================
# TABELE 8.x.x — Tip centra × Status lečenja (4 rows × 8 cols)
# =========================================================================

tabela_8_matrica <- function(df) {
  tipovi <- list(TIP_AMBULANTNO, TIP_BOLNICKO, TIP_ZATVOR, TIP_LEKAR,
                 NULL, TIP_DRUGO, NULL, NA)
  st_col <- "Da_li_se_lice_ranije_lechilo_od_bolesti_zavisnosti_povezane_sa_psihoaktivnim_supstancama"
  m <- matrix(0L, nrow = 4, ncol = 8)
  for (j in seq_along(tipovi)) {
    tip <- tipovi[[j]]
    pod <- if (is.null(tip)) df[0,] else if (is.na(tip)) df else
      df |> filter(Tip_centra_programa_za_lechenje == tip)
    m[1,j] <- n_filter(pod, st_col, NIKAD_LECEN)
    m[2,j] <- n_filter(pod, st_col, c(LECEN_ISTI, LECEN_DRUGI))
    m[3,j] <- n_filter(pod, st_col, LECEN_NEPOZNAT)
    m[4,j] <- m[1,j] + m[2,j] + m[3,j]
  }
  m
}

dodaj_tabelu_811 <- function(wb, baza) pisi_tabelu(wb, "8.1.1", tabela_8_matrica(baza))
dodaj_tabelu_812 <- function(wb, baza) pisi_tabelu(wb, "8.1.2", tabela_8_matrica(baza |> filter(Pol == "Muško")))
dodaj_tabelu_813 <- function(wb, baza) pisi_tabelu(wb, "8.1.3", tabela_8_matrica(baza |> filter(Pol == "Žensko")))

# =========================================================================
# TABELE 9.x.x — Primarna droga × Tip centra (33 rows × 8 cols)
# =========================================================================

tabela_9_matrica <- function(df) {
  tipovi <- list(TIP_AMBULANTNO, TIP_BOLNICKO, TIP_ZATVOR, TIP_LEKAR,
                 TIP_AGENCIJA, TIP_DRUGO, TIP_NEPOZNATO, NA)
  m <- matrix(0L, nrow = 33, ncol = 8)
  for (j in seq_along(tipovi)) {
    tip <- tipovi[[j]]
    pod <- if (is.na(tip)) df else df |> filter(Tip_centra_programa_za_lechenje == tip)
    m[,j] <- broji_po_drogi(pod)
  }
  m
}

dodaj_tabelu_911 <- function(wb, baza) pisi_tabelu(wb, "9.1.1", tabela_9_matrica(baza))
dodaj_tabelu_912 <- function(wb, baza) pisi_tabelu(wb, "9.1.2", tabela_9_matrica(filter_status(baza, "nikad")))
dodaj_tabelu_913 <- function(wb, baza) pisi_tabelu(wb, "9.1.3", tabela_9_matrica(filter_status(baza, "prethodno")))

# =========================================================================
# TABELE 10.x.x — Primarna droga × Pol (33 rows × 4 cols)
# =========================================================================

tabela_10_matrica <- function(df) {
  cbind(
    broji_po_drogi(df |> filter(Pol == "Muško")),
    broji_po_drogi(df |> filter(Pol == "Žensko")),
    broji_po_drogi(df |> filter(!Pol %in% c("Muško","Žensko"))),
    broji_po_drogi(df)
  )
}

dodaj_tabelu_1011 <- function(wb, baza) pisi_tabelu(wb, "10.1.1", tabela_10_matrica(baza))
dodaj_tabelu_1012 <- function(wb, baza) pisi_tabelu(wb, "10.1.2", tabela_10_matrica(filter_status(baza, "nikad")))
dodaj_tabelu_1013 <- function(wb, baza) pisi_tabelu(wb, "10.1.3", tabela_10_matrica(filter_status(baza, "prethodno")))

# =========================================================================
# TABELE 11.x.x — Primarna droga × Mean age / SD / N (33 rows × 9 cols)
# =========================================================================

tabela_11_matrica <- function(df) {
  m <- cbind(
    statistika_po_drogi(df, mean_r,  "year_complete_round"),
    statistika_po_drogi(df, sd_r,    "year_complete_round"),
    statistika_po_drogi(df, n_valid, "year_complete_round"),
    statistika_po_drogi(df, mean_r,  "Uzrast_na_pochetku_korishcenja_glavni_uzrok_zavisnosti"),
    statistika_po_drogi(df, sd_r,    "Uzrast_na_pochetku_korishcenja_glavni_uzrok_zavisnosti"),
    statistika_po_drogi(df, n_valid, "Uzrast_na_pochetku_korishcenja_glavni_uzrok_zavisnosti"),
    statistika_po_drogi(df, mean_r,  "lag_years_first_use_treatment"),
    statistika_po_drogi(df, sd_r,    "lag_years_first_use_treatment"),
    statistika_po_drogi(df, n_valid, "lag_years_first_use_treatment")
  )
  m[is.nan(m)] <- NA
  m
}

dodaj_tabelu_1111 <- function(wb, baza) pisi_tabelu(wb, "11.1.1", tabela_11_matrica(baza))
dodaj_tabelu_1112 <- function(wb, baza) pisi_tabelu(wb, "11.1.2", tabela_11_matrica(filter_status(baza, "nikad")))
dodaj_tabelu_1113 <- function(wb, baza) pisi_tabelu(wb, "11.1.3", tabela_11_matrica(filter_status(baza, "prethodno")))
dodaj_tabelu_1114 <- function(wb, baza) pisi_tabelu(wb, "11.1.4", tabela_11_matrica(baza |> filter(Pol == "Muško")))
dodaj_tabelu_1115 <- function(wb, baza) pisi_tabelu(wb, "11.1.5", tabela_11_matrica(filter_status(baza |> filter(Pol == "Muško"), "nikad")))
dodaj_tabelu_1116 <- function(wb, baza) pisi_tabelu(wb, "11.1.6", tabela_11_matrica(filter_status(baza |> filter(Pol == "Muško"), "prethodno")))
dodaj_tabelu_1117 <- function(wb, baza) pisi_tabelu(wb, "11.1.7", tabela_11_matrica(baza |> filter(Pol == "Žensko")))
dodaj_tabelu_1118 <- function(wb, baza) pisi_tabelu(wb, "11.1.8", tabela_11_matrica(filter_status(baza |> filter(Pol == "Žensko"), "nikad")))
dodaj_tabelu_1119 <- function(wb, baza) pisi_tabelu(wb, "11.1.9", tabela_11_matrica(filter_status(baza |> filter(Pol == "Žensko"), "prethodno")))

# =========================================================================
# TABELE 12.x.x — Primarna droga × Starosna grupa (33 rows × 13 cols)
# =========================================================================

tabela_12_matrica <- function(df) {
  m <- matrix(0L, nrow = 33, ncol = 13)
  for (i in seq_along(GRUPE_UZRAST)) {
    m[,i] <- broji_po_drogi(df |> filter(year_complete_round_categories == GRUPE_UZRAST[i]))
  }
  m[,13] <- broji_po_drogi(df)
  m
}

dodaj_tabelu_1211 <- function(wb, baza) pisi_tabelu(wb, "12.1.1", tabela_12_matrica(baza))
dodaj_tabelu_1212 <- function(wb, baza) pisi_tabelu(wb, "12.1.2", tabela_12_matrica(filter_status(baza, "nikad")))
dodaj_tabelu_1213 <- function(wb, baza) pisi_tabelu(wb, "12.1.3", tabela_12_matrica(filter_status(baza, "prethodno")))

# =========================================================================
# TABELE 13.x.x — Grupe droga × Izvor upućivanja (10 rows × 9 cols)
# Cols: court/GP/drugcentre/otherhealth/school/self+fam/other/NK/Total
# =========================================================================

UPUCIVACI_13_VALS <- list(
  c("9 - Sud/pravosudni organ/policija"),
  c("6 - Izabrani lekar"),
  c("5 - Drugi centar za lečenje zavisnosti"),
  c("7 - Druga zdravstvena ustanova","8 - Bolnica"),
  c("10 - Obrazovna institucija"),
  c("1 - Lična odluka","2 - Porodica ili prijatelji"),
  c("11 - Drugo"),
  c("0 - Nepoznat podatak"),
  NULL  # Total
)

tabela_13_matrica <- function(df) {
  ref_col <- "Ko_je_imao_najvecu_ulogu_u_upucivanju_lica_na_ovu_epizodu_lechenja"
  m <- matrix(0L, nrow = 10, ncol = 9)
  for (j in seq_along(UPUCIVACI_13_VALS)) {
    val <- UPUCIVACI_13_VALS[[j]]
    pod <- if (is.null(val)) df else df |> filter(.data[[ref_col]] %in% val)
    m[,j] <- broji_grupe_droga(pod)
  }
  m
}

dodaj_tabelu_1311 <- function(wb, baza) pisi_tabelu(wb, "13.1.1", tabela_13_matrica(baza))
dodaj_tabelu_1312 <- function(wb, baza) pisi_tabelu(wb, "13.1.2", tabela_13_matrica(filter_status(baza, "nikad")))
dodaj_tabelu_1313 <- function(wb, baza) pisi_tabelu(wb, "13.1.3", tabela_13_matrica(filter_status(baza, "prethodno")))

# =========================================================================
# TABELE 14-20 — Primarna droga × Kategorijska promenljiva (33 rows)
# =========================================================================

# --- 14: S kim živi (8 cols) ---
KAT_14_VALS <- list(
  c("1 - Živi sam"),
  c("3 - S licima rodbinski povezanim s klijentom"),
  c("2 - S partnerom"),
  c("4 - S prijateljima i drugim odraslim licima-bez rodbinske povezanosti"),
  c("5 - U zatvoru/pritovoru"),
  c("6 - Bez stalnog smeštaja","7 - Hostel/prihvatilište"),
  c("0 - Nepoznat podatak"),
  NULL
)
dodaj_tabelu_1411 <- function(wb, baza) pisi_tabelu(wb, "14.1.1", tabela_kat_matrica(baza, "S_kojim_punoletnim_licima_zivi", KAT_14_VALS))
dodaj_tabelu_1412 <- function(wb, baza) pisi_tabelu(wb, "14.1.2", tabela_kat_matrica(baza |> filter(Pol == "Muško"), "S_kojim_punoletnim_licima_zivi", KAT_14_VALS))
dodaj_tabelu_1413 <- function(wb, baza) pisi_tabelu(wb, "14.1.3", tabela_kat_matrica(baza |> filter(Pol == "Žensko"), "S_kojim_punoletnim_licima_zivi", KAT_14_VALS))

# --- 15: Deca (4 cols) ---
KAT_15_VALS <- list(
  c("3 - Ne","4 - Nema dece"),
  c("1 - Da, stalno","2 - Da, povremeno"),
  c("0 - Nepoznat podatak","5 - Ne primenjuje se"),
  NULL
)
dodaj_tabelu_1511 <- function(wb, baza) pisi_tabelu(wb, "15.1.1", tabela_kat_matrica(baza, "Da_li_zivi_sa_svojom_decom", KAT_15_VALS))
dodaj_tabelu_1512 <- function(wb, baza) pisi_tabelu(wb, "15.1.2", tabela_kat_matrica(baza |> filter(Pol == "Muško"), "Da_li_zivi_sa_svojom_decom", KAT_15_VALS))
dodaj_tabelu_1513 <- function(wb, baza) pisi_tabelu(wb, "15.1.3", tabela_kat_matrica(baza |> filter(Pol == "Žensko"), "Da_li_zivi_sa_svojom_decom", KAT_15_VALS))

# --- 16: Smeštaj (6 cols) ---
KAT_16_VALS <- list(
  c("1 - Stalni smeštaj"),
  c("2 - Privremeni smeštaj","4 - Bez stalnog smeštaja","5 - Hostel/prihvatilište"),
  c("3 - U zatvoru/pritvoru"),
  c("6 - Drugo"),
  c("0 - Nepoznat podatak"),
  NULL
)
dodaj_tabelu_1611 <- function(wb, baza) pisi_tabelu(wb, "16.1.1", tabela_kat_matrica(baza, "Gde_zivi", KAT_16_VALS))
dodaj_tabelu_1612 <- function(wb, baza) pisi_tabelu(wb, "16.1.2", tabela_kat_matrica(filter_status(baza, "nikad"), "Gde_zivi", KAT_16_VALS))
dodaj_tabelu_1613 <- function(wb, baza) pisi_tabelu(wb, "16.1.3", tabela_kat_matrica(filter_status(baza, "prethodno"), "Gde_zivi", KAT_16_VALS))

# --- 17: Obrazovanje (6 cols) ---
KAT_17_VALS <- list(
  c("Bez škole","Nepotpuna osnovna škola"),
  c("Osnovna škola (8 razreda)"),
  c("Srednja škola"),
  c("Viša škola","Visoka škola (fakultet)"),
  c("Nepoznato"),
  NULL
)
dodaj_tabelu_1711 <- function(wb, baza) pisi_tabelu(wb, "17.1.1", tabela_kat_matrica(baza, "Najvisha_zavrshena_shkola", KAT_17_VALS))
dodaj_tabelu_1712 <- function(wb, baza) pisi_tabelu(wb, "17.1.2", tabela_kat_matrica(filter_status(baza, "nikad"), "Najvisha_zavrshena_shkola", KAT_17_VALS))
dodaj_tabelu_1713 <- function(wb, baza) pisi_tabelu(wb, "17.1.3", tabela_kat_matrica(filter_status(baza, "prethodno"), "Najvisha_zavrshena_shkola", KAT_17_VALS))

# --- 18: Radni status (6 cols) ---
KAT_18_VALS <- list(
  c("1 - Zaposlen","2 - Obavlja privremene i povremene poslove"),
  c("4 - Učenik/student"),
  c("3 - Nezaposlen"),
  c("5 - Domaćin/domaćica","6 - Drugi neaktivni"),
  c("0 - Nepoznat podatak"),
  NULL
)
dodaj_tabelu_1811 <- function(wb, baza) pisi_tabelu(wb, "18.1.1", tabela_kat_matrica(baza, "Radni_status", KAT_18_VALS))
dodaj_tabelu_1812 <- function(wb, baza) pisi_tabelu(wb, "18.1.2", tabela_kat_matrica(filter_status(baza, "nikad"), "Radni_status", KAT_18_VALS))
dodaj_tabelu_1813 <- function(wb, baza) pisi_tabelu(wb, "18.1.3", tabela_kat_matrica(filter_status(baza, "prethodno"), "Radni_status", KAT_18_VALS))

# --- 19: Način korišćenja (7 cols) ---
KAT_19_VALS <- list(
  c("1 - Injektiranjem"),
  c("2 - Pušenjem/udisanjem"),
  c("3 - Jelom/pićem"),
  c("4 - Ušmrkavanjem"),
  c("5 - Drugo"),
  c("0 - Nepoznat podatak"),
  NULL
)
dodaj_tabelu_1911 <- function(wb, baza) pisi_tabelu(wb, "19.1.1", tabela_kat_matrica(baza, "Uobichajen_nachin_korishcenja_glavni_uzrok_zavisnosti", KAT_19_VALS))
dodaj_tabelu_1912 <- function(wb, baza) pisi_tabelu(wb, "19.1.2", tabela_kat_matrica(filter_status(baza, "nikad"), "Uobichajen_nachin_korishcenja_glavni_uzrok_zavisnosti", KAT_19_VALS))
dodaj_tabelu_1913 <- function(wb, baza) pisi_tabelu(wb, "19.1.3", tabela_kat_matrica(filter_status(baza, "prethodno"), "Uobichajen_nachin_korishcenja_glavni_uzrok_zavisnosti", KAT_19_VALS))

# --- 20: Učestalost (7 cols) ---
KAT_20_VALS <- list(
  c("1 - Svakodnevno"),
  c("2 - 4-6 dana nedeljno"),
  c("3 - 2-3 dana nedeljno"),
  c("4 - Jednom nedeljno ili ređe"),
  c("5 - Ne koristi u poslednjih 30 dana"),
  c("0 - Nepoznat podatak"),
  NULL
)
dodaj_tabelu_2011 <- function(wb, baza) pisi_tabelu(wb, "20.1.1", tabela_kat_matrica(baza, "Uchestalost_korishcenja_u_poslednjih_30_dana_glavni_uzrok_zavisnosti", KAT_20_VALS))
dodaj_tabelu_2012 <- function(wb, baza) pisi_tabelu(wb, "20.1.2", tabela_kat_matrica(filter_status(baza, "nikad"), "Uchestalost_korishcenja_u_poslednjih_30_dana_glavni_uzrok_zavisnosti", KAT_20_VALS))
dodaj_tabelu_2013 <- function(wb, baza) pisi_tabelu(wb, "20.1.3", tabela_kat_matrica(filter_status(baza, "prethodno"), "Uchestalost_korishcenja_u_poslednjih_30_dana_glavni_uzrok_zavisnosti", KAT_20_VALS))

# =========================================================================
# TABELE 21.x.x — Primarna droga × Uzrast pri prvom korišćenju (33 × 13)
# =========================================================================

tabela_21_matrica <- function(df) {
  m <- matrix(0L, nrow = 33, ncol = 13)
  for (i in seq_along(GRUPE_UZRAST)) {
    m[,i] <- broji_po_drogi(df |> filter(age_cat_pocetak_koriscenja == GRUPE_UZRAST[i]))
  }
  m[,13] <- broji_po_drogi(df)
  m
}

dodaj_tabelu_2111 <- function(wb, baza) pisi_tabelu(wb, "21.1.1", tabela_21_matrica(baza))
dodaj_tabelu_2112 <- function(wb, baza) pisi_tabelu(wb, "21.1.2", tabela_21_matrica(filter_status(baza, "nikad")))
dodaj_tabelu_2113 <- function(wb, baza) pisi_tabelu(wb, "21.1.3", tabela_21_matrica(filter_status(baza, "prethodno")))

# =========================================================================
# TABELE 22.x.x — Primarna droga × Injektiranje (33 × 8)
# Template cols: never / ever / 2.1 not last 12m / 2.2 last 12m / 2.3 current / refuse / NK / Total
# =========================================================================

KAT_22_VALS <- list(
  c(INJ_NIKAD),
  c(INJ_30DANA, INJ_12MES, INJ_VISE12),  # ever injected
  c(INJ_VISE12),                           # 2.1 not in last 12m
  c(INJ_12MES),                            # 2.2 last 12m not last 30d
  c(INJ_30DANA),                           # 2.3 currently
  c(INJ_ODBIJA),
  c(INJ_NEPOZNATO),
  NULL
)

dodaj_tabelu_2211 <- function(wb, baza) pisi_tabelu(wb, "22.1.1", tabela_kat_matrica(baza, "Da_li_je_lice_uzimalo_psihoaktivne_supstance_injektiranjem", KAT_22_VALS))
dodaj_tabelu_2212 <- function(wb, baza) pisi_tabelu(wb, "22.1.2", tabela_kat_matrica(filter_status(baza, "nikad"), "Da_li_je_lice_uzimalo_psihoaktivne_supstance_injektiranjem", KAT_22_VALS))
dodaj_tabelu_2213 <- function(wb, baza) pisi_tabelu(wb, "22.1.3", tabela_kat_matrica(filter_status(baza, "prethodno"), "Da_li_je_lice_uzimalo_psihoaktivne_supstance_injektiranjem", KAT_22_VALS))

# =========================================================================
# TABELE 23.x.x — Uzrast pri ulasku × Godine od prvog injektiranja (14 × 6)
# Template cols: <=1yr / 2-4yr / 5-9yr / 10+yr / NK / Total
# Template rows: age groups (<15..65+) + NK + Total
# =========================================================================

tabela_23_matrica <- function(df) {
  inj <- df |> filter(Da_li_je_lice_uzimalo_psihoaktivne_supstance_injektiranjem %in%
                      c(INJ_30DANA, INJ_12MES, INJ_VISE12))

  grupe_inj <- list(
    function(d) d |> filter(!is.na(year_since_first_injection) & year_since_first_injection <= 1),
    function(d) d |> filter(year_since_first_injection >= 2 & year_since_first_injection <= 4),
    function(d) d |> filter(year_since_first_injection >= 5 & year_since_first_injection <= 9),
    function(d) d |> filter(year_since_first_injection >= 10),
    function(d) d |> filter(is.na(year_since_first_injection)),
    function(d) d
  )

  m <- matrix(0L, nrow = 14, ncol = 6)
  for (j in seq_along(grupe_inj)) {
    pod_j <- grupe_inj[[j]](inj)
    for (i in seq_along(GRUPE_UZRAST)) {
      m[i,j] <- pod_j |> filter(year_complete_round_categories == GRUPE_UZRAST[i]) |> nrow()
    }
    m[13,j] <- pod_j |> filter(is.na(year_complete_round_categories)) |> nrow()
    m[14,j] <- nrow(pod_j)
  }
  m
}

dodaj_tabelu_2311 <- function(wb, baza) pisi_tabelu(wb, "23.1.1", tabela_23_matrica(baza))
dodaj_tabelu_2312 <- function(wb, baza) pisi_tabelu(wb, "23.1.2", tabela_23_matrica(filter_status(baza, "nikad")))
dodaj_tabelu_2313 <- function(wb, baza) pisi_tabelu(wb, "23.1.3", tabela_23_matrica(filter_status(baza, "prethodno")))

# =========================================================================
# TABELA 24.1.1 — Polidrug × Status lečenja (4 × 4)
# =========================================================================

dodaj_tabelu_2411 <- function(wb, baza) {
  st_col <- "Da_li_se_lice_ranije_lechilo_od_bolesti_zavisnosti_povezane_sa_psihoaktivnim_supstancama"
  pd_col <- "Da_li_je_lice_koristilo_vishe_vrsta_supstanci_istovremeno_u_poslednjih_30_dana"
  nikad   <- baza |> filter(.data[[st_col]] == NIKAD_LECEN)
  prethod <- baza |> filter(.data[[st_col]] %in% c(LECEN_ISTI, LECEN_DRUGI))
  nep     <- baza |> filter(.data[[st_col]] == LECEN_NEPOZNAT)
  red <- function(d) {
    a <- n_filter(d, pd_col, "1 - Da"); b <- n_filter(d, pd_col, "2 - Ne")
    cc <- n_filter(d, pd_col, "3 - Nepoznato")
    c(a, b, cc, a+b+cc)
  }
  pisi_tabelu(wb, "24.1.1", rbind(red(nikad), red(prethod), red(nep), red(baza)))
}

# =========================================================================
# TABELE 25.x.x — Primarna × Sekundarna droga
# Template 25.1.1-5: 13 × 13 (simplified categories per primary drug group)
# Template 25.1.6:   33 × 33 (full matrix)
# =========================================================================

# 13 simplified secondary drug categories (template column layout)
SPOREDNE_13_VALS <- list(
  c("11 - Heroin"),
  c("12 - Metadon","13 - Buprenorfin","14 - Fentanil","15 - Tramadol",
    "16 - Opioid, bez detaljnih informacija","17 - Drugi opioidi (navedite)"),
  c("21 - Prah kokaina"),
  c("22 - Krek"),
  c("31 - Amfetamin","32 - Metamfetamin"),
  KANABIS,
  c("33 - Ekstazi (MDMA i derivati)","34 - Sintetički katinoni",
    "35 - Stimulans, bez detaljnih informacija","36 - Drugi stimulansi (navedite)"),
  HIPNOTICI,
  c("80 - Alkohol"),
  c("23 - Drugi kokain (navedite)","51 - LSD","52 - Ketamin",
    "53 - Halucinogen, bez detaljnih informacija","54 - Drugi halucinogeni (navedite)",
    "60 - Isparljivi inhalanti","88 - Druga supstanca (navedite)"),
  NULL,   # None (no secondary drug)
  NA,     # NK secondary
  NA      # Total — handled separately
)

ima_sporednu <- function(df, vrednosti) {
  as.integer(df |> filter(
    Sporedni_uzrok_zavisnosti_1 %in% vrednosti |
    Sporedni_uzrok_zavisnosti_2 %in% vrednosti |
    Sporedni_uzrok_zavisnosti_3 %in% vrednosti
  ) |> nrow())
}

nema_sporednu <- function(df) {
  as.integer(df |> filter(is.na(Sporedni_uzrok_zavisnosti_1) &
                           is.na(Sporedni_uzrok_zavisnosti_2) &
                           is.na(Sporedni_uzrok_zavisnosti_3)) |> nrow())
}

broji_sporedne_13 <- function(d) {
  vapply(seq_len(12), function(i) {
    val <- SPOREDNE_13_VALS[[i]]
    if (is.null(val)) return(nema_sporednu(d))
    if (is.na(val[1])) return(as.integer(nrow(d)))
    ima_sporednu(d, val)
  }, integer(1)) |> c(as.integer(nrow(d)))  # append Total
}

# 13 row categories for primary side (same groupings)
PRIMARNE_13_VALS <- list(
  c("11 - Heroin"),
  c("12 - Metadon","13 - Buprenorfin","14 - Fentanil","15 - Tramadol",
    "16 - Opioid, bez detaljnih informacija","17 - Drugi opioidi (navedite)"),
  c("21 - Prah kokaina"), c("22 - Krek"),
  c("31 - Amfetamin","32 - Metamfetamin"),
  KANABIS,
  c("33 - Ekstazi (MDMA i derivati)","34 - Sintetički katinoni",
    "35 - Stimulans, bez detaljnih informacija","36 - Drugi stimulansi (navedite)"),
  HIPNOTICI, c("80 - Alkohol"),
  c("23 - Drugi kokain (navedite)","51 - LSD","52 - Ketamin",
    "53 - Halucinogen, bez detaljnih informacija","54 - Drugi halucinogeni (navedite)",
    "60 - Isparljivi inhalanti","88 - Druga supstanca (navedite)"),
  NULL, NA, NA  # None, NK, Total (row 13 = Total over all primaries)
)

tabela_25_matrica <- function(df) {
  m <- matrix(0L, nrow = 13, ncol = 13)
  for (i in seq_len(12)) {
    val <- PRIMARNE_13_VALS[[i]]
    if (is.null(val) || is.na(val[1])) next
    pod <- df |> filter(Glavni_uzrok_zavisnosti %in% val)
    m[i,] <- broji_sporedne_13(pod)
  }
  m[13,] <- broji_sporedne_13(df)
  m
}

dodaj_tabelu_2511 <- function(wb, baza) pisi_tabelu(wb, "25.1.1", tabela_25_matrica(baza |> filter(Glavni_uzrok_zavisnosti %in% OPIOIDI)))
dodaj_tabelu_2512 <- function(wb, baza) pisi_tabelu(wb, "25.1.2", tabela_25_matrica(baza |> filter(Glavni_uzrok_zavisnosti %in% KOKAIN)))
dodaj_tabelu_2513 <- function(wb, baza) pisi_tabelu(wb, "25.1.3", tabela_25_matrica(baza |> filter(Glavni_uzrok_zavisnosti %in% STIMULANSI)))
dodaj_tabelu_2514 <- function(wb, baza) pisi_tabelu(wb, "25.1.4", tabela_25_matrica(baza |> filter(Glavni_uzrok_zavisnosti %in% KANABIS)))
dodaj_tabelu_2515 <- function(wb, baza) pisi_tabelu(wb, "25.1.5", tabela_25_matrica(
  baza |> filter(Glavni_uzrok_zavisnosti %in% c(HIPNOTICI, HALUCINOGENI,
    "60 - Isparljivi inhalanti","88 - Druga supstanca (navedite)"))))

# 25.1.6 — Full 33×33 matrix
SPOREDNE_33_VALS <- list(
  OPIOIDI,"11 - Heroin","12 - Metadon","13 - Buprenorfin","14 - Fentanil",
  c("15 - Tramadol","16 - Opioid, bez detaljnih informacija","17 - Drugi opioidi (navedite)"),
  KOKAIN,"21 - Prah kokaina","22 - Krek","23 - Drugi kokain (navedite)",
  STIMULANSI,"31 - Amfetamin","32 - Metamfetamin","33 - Ekstazi (MDMA i derivati)",
  "34 - Sintetički katinoni",
  c("35 - Stimulans, bez detaljnih informacija","36 - Drugi stimulansi (navedite)"),
  HIPNOTICI,"41 - Barbiturati","42 - Benzodiazepini","43 - GHB/GBL",
  c("44 - Pregabalin","45 - Hipnotik i sedativ, bez detaljnih informacija","46 - Drugi hipnotici i sedativi (navedite)"),
  HALUCINOGENI,"51 - LSD","52 - Ketamin",
  c("53 - Halucinogen, bez detaljnih informacija","54 - Drugi halucinogeni (navedite)"),
  "60 - Isparljivi inhalanti", KANABIS, c("70 - Marihuana","71 - Hašiš"),
  c("72 - Kanabis bez detaljnih informacija","73 - Drugi kanabis (navedite)"),
  "80 - Alkohol","88 - Druga supstanca (navedite)", NULL
)

dodaj_tabelu_2516 <- function(wb, baza) {
  m <- matrix(0L, nrow = 33, ncol = 33)
  for (i in seq_len(32)) {
    val <- SPOREDNE_33_VALS[[i]]
    df_p <- baza |> filter(Glavni_uzrok_zavisnosti %in% val)
    for (j in seq_len(32)) {
      sv <- SPOREDNE_33_VALS[[j]]
      m[i,j] <- if (is.null(sv)) nema_sporednu(df_p) else ima_sporednu(df_p, sv)
    }
    m[i,33] <- nrow(df_p)
  }
  for (j in seq_len(32)) {
    sv <- SPOREDNE_33_VALS[[j]]
    m[33,j] <- if (is.null(sv)) nema_sporednu(baza) else ima_sporednu(baza, sv)
  }
  m[33,33] <- nrow(baza)
  pisi_tabelu(wb, "25.1.6", m)
}

# =========================================================================
# TABELE 26/27 — HIV/HCV testiranje × Injektiranje (7 × 8)
# Rows: not tested / ever tested / neg / pos / refuse / NK / Total
# Cols: never inj / ever inj / not12m / last12m / current / refuse / NK / Total
# =========================================================================

INJ_KOL_VALS <- list(
  c(INJ_NIKAD),
  c(INJ_30DANA,INJ_12MES,INJ_VISE12),
  c(INJ_VISE12), c(INJ_12MES), c(INJ_30DANA),
  c(INJ_ODBIJA), c(INJ_NEPOZNATO), NULL
)

tabela_test_inj_matrica <- function(df, kol_test, kol_rez) {
  inj_col <- "Da_li_je_lice_uzimalo_psihoaktivne_supstance_injektiranjem"
  test_fns <- list(
    function(d) n_filter(d, kol_test, "1 - Nije testiran/a"),
    function(d) n_filter(d, kol_test, "2 - Da, testiran/a"),
    function(d) n_filter(d, kol_rez,  "1 - Negativan"),
    function(d) n_filter(d, kol_rez,  "2 - Pozitivan"),
    function(d) n_filter(d, kol_test, "5 - Ne želi da odgovori"),
    function(d) n_filter(d, kol_test, "0 - Nepoznat podatak"),
    function(d) as.integer(nrow(d))
  )
  m <- matrix(0L, nrow = 7, ncol = 8)
  for (j in seq_along(INJ_KOL_VALS)) {
    val <- INJ_KOL_VALS[[j]]
    pod_j <- if (is.null(val)) df else df |> filter(.data[[inj_col]] %in% val)
    for (i in seq_along(test_fns)) m[i,j] <- test_fns[[i]](pod_j)
  }
  m
}

dodaj_tabelu_2611 <- function(wb, baza) pisi_tabelu(wb, "26.1.1", tabela_test_inj_matrica(baza, "Testiranje_na_HIV", "Rezultat_poslednjeg_testiranja_na_HIV"))
dodaj_tabelu_2612 <- function(wb, baza) pisi_tabelu(wb, "26.1.2", tabela_test_inj_matrica(filter_status(baza,"nikad"), "Testiranje_na_HIV", "Rezultat_poslednjeg_testiranja_na_HIV"))
dodaj_tabelu_2613 <- function(wb, baza) pisi_tabelu(wb, "26.1.3", tabela_test_inj_matrica(filter_status(baza,"prethodno"), "Testiranje_na_HIV", "Rezultat_poslednjeg_testiranja_na_HIV"))
dodaj_tabelu_2711 <- function(wb, baza) pisi_tabelu(wb, "27.1.1", tabela_test_inj_matrica(baza, "Testiranje_na_Hepatits_C", "Rezultat_poslednjeg_testiranja_na_Hepatits_C"))
dodaj_tabelu_2712 <- function(wb, baza) pisi_tabelu(wb, "27.1.2", tabela_test_inj_matrica(filter_status(baza,"nikad"), "Testiranje_na_Hepatits_C", "Rezultat_poslednjeg_testiranja_na_Hepatits_C"))
dodaj_tabelu_2713 <- function(wb, baza) pisi_tabelu(wb, "27.1.3", tabela_test_inj_matrica(filter_status(baza,"prethodno"), "Testiranje_na_Hepatits_C", "Rezultat_poslednjeg_testiranja_na_Hepatits_C"))

# =========================================================================
# TABELA 28.1.1 — Needle sharing × Injektiranje (8 × 9)
# Rows: never shared / ever shared / not last 12m / last 12m / currently / refuse / NK / Total
# Cols: same injecting behaviour cols (8) + Total (9th)
# =========================================================================

dodaj_tabelu_2811 <- function(wb, baza) {
  igl_col <- "Da_li_je_lice_za_injektiranje_psihoaktivne_supstance_delilo_igle_i_ili_shpriceve_s_drugim_licima"
  inj_col <- "Da_li_je_lice_uzimalo_psihoaktivne_supstance_injektiranjem"
  sharing_fns <- list(
    function(d) n_filter(d, igl_col, "1 - Ne, nikada"),
    function(d) n_filter(d, igl_col, c("2 - Da, u poslednjih 30 dana",
                                        "3 - Da, u poslednjih 12 meseci, ali ne i u poslednjih 30 dana",
                                        "4 - Da, pre više od 12 meseci")),
    function(d) n_filter(d, igl_col, "4 - Da, pre više od 12 meseci"),
    function(d) n_filter(d, igl_col, "3 - Da, u poslednjih 12 meseci, ali ne i u poslednjih 30 dana"),
    function(d) n_filter(d, igl_col, "2 - Da, u poslednjih 30 dana"),
    function(d) n_filter(d, igl_col, "5 - Ne želi da odgovori"),
    function(d) n_filter(d, igl_col, "0 - Nepoznat podatak"),
    function(d) as.integer(nrow(d))
  )
  INJ_KOL_9 <- c(INJ_KOL_VALS, list(NULL))  # add Total col
  m <- matrix(0L, nrow = 8, ncol = 9)
  for (j in seq_along(INJ_KOL_9)) {
    val <- INJ_KOL_9[[j]]
    pod_j <- if (is.null(val)) baza else baza |> filter(.data[[inj_col]] %in% val)
    for (i in seq_along(sharing_fns)) m[i,j] <- sharing_fns[[i]](pod_j)
  }
  pisi_tabelu(wb, "28.1.1", m)
}

# =========================================================================
# TABELE 29.x.x — Primarna droga × OST status
# 29.1.1: 33 × 5 (Never/EverNot/Currently/NK/Total)
# 29.1.2: 7 × 11 (drug groups × years since first OST)
# =========================================================================

dodaj_tabelu_2911 <- function(wb, baza) {
  nikad  <- baza |> filter(opioid_substitution_therapy == "Never_been_in_OST")
  evernot<- baza |> filter(opioid_substitution_therapy == "Ever_been_not_currently")
  curr   <- baza |> filter(opioid_substitution_therapy == "Ever_been_currently")
  nep    <- baza |> filter(opioid_substitution_therapy == "Not_known" | is.na(opioid_substitution_therapy))
  pisi_tabelu(wb, "29.1.1", cbind(
    broji_po_drogi(nikad), broji_po_drogi(evernot),
    broji_po_drogi(curr),  broji_po_drogi(nep),
    broji_po_drogi(baza)
  ))
}

dodaj_tabelu_2912 <- function(wb, baza) {
  PRIMARNE_292_VALS <- list(
    c("11 - Heroin"),
    c("12 - Metadon","13 - Buprenorfin","14 - Fentanil","15 - Tramadol",
      "16 - Opioid, bez detaljnih informacija","17 - Drugi opioidi (navedite)"),
    KOKAIN, STIMULANSI,
    c(HIPNOTICI, HALUCINOGENI,"60 - Isparljivi inhalanti","88 - Druga supstanca (navedite)"),
    NULL, NA  # NK, Total
  )
  ost_df <- baza |> filter(!is.na(years_since_first_OST))
  ost_grupe <- list(
    function(d) d |> filter(years_since_first_OST < 1),
    function(d) d |> filter(years_since_first_OST >= 1  & years_since_first_OST < 2),
    function(d) d |> filter(years_since_first_OST >= 2  & years_since_first_OST < 3),
    function(d) d |> filter(years_since_first_OST >= 3  & years_since_first_OST < 4),
    function(d) d |> filter(years_since_first_OST >= 4  & years_since_first_OST < 5),
    function(d) d |> filter(years_since_first_OST >= 5  & years_since_first_OST < 6),
    function(d) d |> filter(years_since_first_OST >= 6  & years_since_first_OST <= 10),
    function(d) d |> filter(years_since_first_OST >= 11 & years_since_first_OST <= 20),
    function(d) d |> filter(years_since_first_OST > 20),
    function(d) d |> filter(is.na(years_since_first_OST)),
    function(d) d
  )
  m <- matrix(0L, nrow = 7, ncol = 11)
  for (i in seq_len(6)) {
    val <- PRIMARNE_292_VALS[[i]]
    pod_i <- if (is.null(val) || is.na(val[1])) ost_df[0,] else ost_df |> filter(Glavni_uzrok_zavisnosti %in% val)
    for (j in seq_along(ost_grupe)) m[i,j] <- nrow(ost_grupe[[j]](pod_i))
  }
  for (j in seq_along(ost_grupe)) m[7,j] <- nrow(ost_grupe[[j]](ost_df))
  pisi_tabelu(wb, "29.1.2", m)
}

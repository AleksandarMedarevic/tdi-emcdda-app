# app.R ─────────────────────────────────────────────────────────────────────
# TDI / EMCDDA Shiny aplikacija
# Autori: Milica Savic, Aleksandar Medarevic
#
# UPOTREBA:
#   1. Postavi app.R i helpers.R u isti folder
#   2. U RStudio: runApp("app.R")  ili klikni Run App dugme
# ─────────────────────────────────────────────────────────────────────────────

# ── Auto-instalacija paketa ako nedostaju ─────────────────────────────────────
.paketi <- c("shiny","bslib","dplyr","tidyverse","readxl",
             "openxlsx","lubridate","epikit","DT")
.nedostaju <- .paketi[!.paketi %in% rownames(installed.packages())]
if (length(.nedostaju) > 0) {
  message("Instaliram pakete: ", paste(.nedostaju, collapse = ", "))
  install.packages(.nedostaju, repos = "https://cloud.r-project.org")
}
rm(.paketi, .nedostaju)
# ─────────────────────────────────────────────────────────────────────────────

library(shiny)
library(bslib)
library(dplyr)
library(tidyverse)
library(readxl)
library(openxlsx)
library(lubridate)
library(epikit)
library(DT)

source("helpers.R")
source("config.R")

# ─── PUTANJA DO TEMPLATE FAJLA ────────────────────────────────────────────────
# Promeni ovu putanju prema lokaciji TDI template fajla na tvom računaru.
# Ako fajl ne postoji, app automatski generiše klasičan xlsx (jedan sheet po tabeli).
TEMPLATE_PATH <- "data/TDI_template.xlsx"

# ─── THEMES ───────────────────────────────────────────────────────────────────
theme_light <- bs_theme(
  preset     = "flatly",
  bg         = "#ffffff",
  fg         = "#2c3e50",
  primary    = "#18bc9c",
  secondary  = "#95a5a6",
  font_scale = 1.05
)
theme_dark <- bs_theme(
  preset     = "darkly",
  bg         = "#1e1e2e",
  fg         = "#cdd6f4",
  primary    = "#89b4fa",
  secondary  = "#585b70",
  success    = "#a6e3a1",
  font_scale = 1.05
)

# ─── DEFINICIJE TABELA ZA PREGLED ─────────────────────────────────────────────

DRUG_ROWS_LABELS <- c(
  "1. Opioids (Total)", "1.1 heroin", "1.2 methadone misused",
  "1.3 buprenorphine misused", "1.4 fentanils misused", "1.5 other opioids",
  "2. Cocaine (Total)", "2.1 powder cocaine (HCL)", "2.2 crack cocaine", "2.3 other cocaine",
  "3. Stimulants excl. cocaine (Total)", "3.1 amphetamines", "3.2 methamphetamines",
  "3.3 MDMA and derivates", "3.4 synthetic cathinones", "3.5 other stimulants",
  "4. Hypnotics & Sedatives (Total)", "4.1 barbiturates misused", "4.2 benzodiazepines misused",
  "4.3 GHB / GBL", "4.4 other hypnotics/sedatives",
  "5. Hallucinogens (Total)", "5.1 LSD", "5.2 ketamine", "5.3 other hallucinogens",
  "6. Volatile Inhalants",
  "7. Cannabis (Total)", "7.1 herbal cannabis / resin", "7.2 synthetic cannabinoids", "7.3 other cannabis",
  "9. Other Substances", "99. Not known / missing", "TOTAL"
)

TABELE_META <- list(
  list(id="8.1.1",  rows=c("Never treated","Previously treated","Not known","All entrants"),
       cols=c("Outpatient","Inpatient","Prison","GP","Low threshold","Other","NK","Total")),
  list(id="8.1.2",  rows=c("Never treated","Previously treated","Not known","All entrants"),
       cols=c("Outpatient","Inpatient","Prison","GP","Low threshold","Other","NK","Total")),
  list(id="8.1.3",  rows=c("Never treated","Previously treated","Not known","All entrants"),
       cols=c("Outpatient","Inpatient","Prison","GP","Low threshold","Other","NK","Total")),
  list(id="9.1.1",  rows=DRUG_ROWS_LABELS, cols=c("Outpatient","Inpatient","Prison","GP","Low threshold","Other","NK","Total")),
  list(id="9.1.2",  rows=DRUG_ROWS_LABELS, cols=c("Outpatient","Inpatient","Prison","GP","Low threshold","Other","NK","Total")),
  list(id="9.1.3",  rows=DRUG_ROWS_LABELS, cols=c("Outpatient","Inpatient","Prison","GP","Low threshold","Other","NK","Total")),
  list(id="10.1.1", rows=DRUG_ROWS_LABELS, cols=c("Males","Females","NK","Total")),
  list(id="10.1.2", rows=DRUG_ROWS_LABELS, cols=c("Males","Females","NK","Total")),
  list(id="10.1.3", rows=DRUG_ROWS_LABELS, cols=c("Males","Females","NK","Total")),
  list(id="11.1.1", rows=DRUG_ROWS_LABELS, cols=c("Mean age (entry)","SD","N","Mean age (1st use)","SD","N","Mean lag (yrs)","SD","N")),
  list(id="11.1.2", rows=DRUG_ROWS_LABELS, cols=c("Mean age (entry)","SD","N","Mean age (1st use)","SD","N","Mean lag (yrs)","SD","N")),
  list(id="11.1.3", rows=DRUG_ROWS_LABELS, cols=c("Mean age (entry)","SD","N","Mean age (1st use)","SD","N","Mean lag (yrs)","SD","N")),
  list(id="11.1.4", rows=DRUG_ROWS_LABELS, cols=c("Mean age (entry)","SD","N","Mean age (1st use)","SD","N","Mean lag (yrs)","SD","N")),
  list(id="11.1.5", rows=DRUG_ROWS_LABELS, cols=c("Mean age (entry)","SD","N","Mean age (1st use)","SD","N","Mean lag (yrs)","SD","N")),
  list(id="11.1.6", rows=DRUG_ROWS_LABELS, cols=c("Mean age (entry)","SD","N","Mean age (1st use)","SD","N","Mean lag (yrs)","SD","N")),
  list(id="11.1.7", rows=DRUG_ROWS_LABELS, cols=c("Mean age (entry)","SD","N","Mean age (1st use)","SD","N","Mean lag (yrs)","SD","N")),
  list(id="11.1.8", rows=DRUG_ROWS_LABELS, cols=c("Mean age (entry)","SD","N","Mean age (1st use)","SD","N","Mean lag (yrs)","SD","N")),
  list(id="11.1.9", rows=DRUG_ROWS_LABELS, cols=c("Mean age (entry)","SD","N","Mean age (1st use)","SD","N","Mean lag (yrs)","SD","N")),
  list(id="12.1.1", rows=DRUG_ROWS_LABELS, cols=c("<15","15–19","20–24","25–29","30–34","35–39","40–44","45–49","50–54","55–59","60–64","65+","Total")),
  list(id="12.1.2", rows=DRUG_ROWS_LABELS, cols=c("<15","15–19","20–24","25–29","30–34","35–39","40–44","45–49","50–54","55–59","60–64","65+","Total")),
  list(id="12.1.3", rows=DRUG_ROWS_LABELS, cols=c("<15","15–19","20–24","25–29","30–34","35–39","40–44","45–49","50–54","55–59","60–64","65+","Total")),
  list(id="13.1.1", rows=c("Opioids","Cocaine","Stimulants","Hypnotics","Hallucinogens","Inhalants","Cannabis","Other","NK","TOTAL"),
       cols=c("Court/police","GP","Drug centre","Other health","School","Self/family","Other","NK","Total")),
  list(id="13.1.2", rows=c("Opioids","Cocaine","Stimulants","Hypnotics","Hallucinogens","Inhalants","Cannabis","Other","NK","TOTAL"),
       cols=c("Court/police","GP","Drug centre","Other health","School","Self/family","Other","NK","Total")),
  list(id="13.1.3", rows=c("Opioids","Cocaine","Stimulants","Hypnotics","Hallucinogens","Inhalants","Cannabis","Other","NK","TOTAL"),
       cols=c("Court/police","GP","Drug centre","Other health","School","Self/family","Other","NK","Total")),
  list(id="14.1.1", rows=DRUG_ROWS_LABELS, cols=c("Alone","With family","With partner","With friends","Prison","Homeless","NK","Total")),
  list(id="14.1.2", rows=DRUG_ROWS_LABELS, cols=c("Alone","With family","With partner","With friends","Prison","Homeless","NK","Total")),
  list(id="14.1.3", rows=DRUG_ROWS_LABELS, cols=c("Alone","With family","With partner","With friends","Prison","Homeless","NK","Total")),
  list(id="15.1.1", rows=DRUG_ROWS_LABELS, cols=c("No","Yes","NK/NA","Total")),
  list(id="15.1.2", rows=DRUG_ROWS_LABELS, cols=c("No","Yes","NK/NA","Total")),
  list(id="15.1.3", rows=DRUG_ROWS_LABELS, cols=c("No","Yes","NK/NA","Total")),
  list(id="16.1.1", rows=DRUG_ROWS_LABELS, cols=c("Stable","Unstable/homeless","Prison","Other","NK","Total")),
  list(id="16.1.2", rows=DRUG_ROWS_LABELS, cols=c("Stable","Unstable/homeless","Prison","Other","NK","Total")),
  list(id="16.1.3", rows=DRUG_ROWS_LABELS, cols=c("Stable","Unstable/homeless","Prison","Other","NK","Total")),
  list(id="17.1.1", rows=DRUG_ROWS_LABELS, cols=c("No/incomplete primary","Primary","Secondary","Tertiary","NK","Total")),
  list(id="17.1.2", rows=DRUG_ROWS_LABELS, cols=c("No/incomplete primary","Primary","Secondary","Tertiary","NK","Total")),
  list(id="17.1.3", rows=DRUG_ROWS_LABELS, cols=c("No/incomplete primary","Primary","Secondary","Tertiary","NK","Total")),
  list(id="18.1.1", rows=DRUG_ROWS_LABELS, cols=c("Employed","Student","Unemployed","Other inactive","NK","Total")),
  list(id="18.1.2", rows=DRUG_ROWS_LABELS, cols=c("Employed","Student","Unemployed","Other inactive","NK","Total")),
  list(id="18.1.3", rows=DRUG_ROWS_LABELS, cols=c("Employed","Student","Unemployed","Other inactive","NK","Total")),
  list(id="19.1.1", rows=DRUG_ROWS_LABELS, cols=c("Injecting","Smoking","Oral","Snorting","Other","NK","Total")),
  list(id="19.1.2", rows=DRUG_ROWS_LABELS, cols=c("Injecting","Smoking","Oral","Snorting","Other","NK","Total")),
  list(id="19.1.3", rows=DRUG_ROWS_LABELS, cols=c("Injecting","Smoking","Oral","Snorting","Other","NK","Total")),
  list(id="20.1.1", rows=DRUG_ROWS_LABELS, cols=c("Daily","4–6 d/wk","2–3 d/wk","≤1 d/wk","Not last 30d","NK","Total")),
  list(id="20.1.2", rows=DRUG_ROWS_LABELS, cols=c("Daily","4–6 d/wk","2–3 d/wk","≤1 d/wk","Not last 30d","NK","Total")),
  list(id="20.1.3", rows=DRUG_ROWS_LABELS, cols=c("Daily","4–6 d/wk","2–3 d/wk","≤1 d/wk","Not last 30d","NK","Total")),
  list(id="21.1.1", rows=DRUG_ROWS_LABELS, cols=c("<15","15–19","20–24","25–29","30–34","35–39","40–44","45–49","50–54","55–59","60–64","65+","Total")),
  list(id="21.1.2", rows=DRUG_ROWS_LABELS, cols=c("<15","15–19","20–24","25–29","30–34","35–39","40–44","45–49","50–54","55–59","60–64","65+","Total")),
  list(id="21.1.3", rows=DRUG_ROWS_LABELS, cols=c("<15","15–19","20–24","25–29","30–34","35–39","40–44","45–49","50–54","55–59","60–64","65+","Total")),
  list(id="22.1.1", rows=DRUG_ROWS_LABELS, cols=c("Never","Ever","Not last 12m","Last 12m","Currently","Refuse","NK","Total")),
  list(id="22.1.2", rows=DRUG_ROWS_LABELS, cols=c("Never","Ever","Not last 12m","Last 12m","Currently","Refuse","NK","Total")),
  list(id="22.1.3", rows=DRUG_ROWS_LABELS, cols=c("Never","Ever","Not last 12m","Last 12m","Currently","Refuse","NK","Total")),
  list(id="23.1.1", rows=c("<15","15–19","20–24","25–29","30–34","35–39","40–44","45–49","50–54","55–59","60–64","65+","NK","Total"),
       cols=c("≤1 yr","2–4 yrs","5–9 yrs","10+ yrs","NK","Total")),
  list(id="23.1.2", rows=c("<15","15–19","20–24","25–29","30–34","35–39","40–44","45–49","50–54","55–59","60–64","65+","NK","Total"),
       cols=c("≤1 yr","2–4 yrs","5–9 yrs","10+ yrs","NK","Total")),
  list(id="23.1.3", rows=c("<15","15–19","20–24","25–29","30–34","35–39","40–44","45–49","50–54","55–59","60–64","65+","NK","Total"),
       cols=c("≤1 yr","2–4 yrs","5–9 yrs","10+ yrs","NK","Total")),
  list(id="24.1.1", rows=c("Never treated","Previously treated","NK","All entrants"),
       cols=c("Yes","No","NK","Total")),
  list(id="25.1.1", rows=c("Heroin","Other opioids","Cocaine","Crack","Amphetamines/meth","Cannabis","Other stimulants","Hypnotics/sed","Alcohol","Other","None","NK","Total"),
       cols=c("Heroin","Other opioids","Cocaine","Crack","Amphetamines/meth","Cannabis","Other stimulants","Hypnotics/sed","Alcohol","Other","None","NK","Total")),
  list(id="25.1.2", rows=c("Heroin","Other opioids","Cocaine","Crack","Amphetamines/meth","Cannabis","Other stimulants","Hypnotics/sed","Alcohol","Other","None","NK","Total"),
       cols=c("Heroin","Other opioids","Cocaine","Crack","Amphetamines/meth","Cannabis","Other stimulants","Hypnotics/sed","Alcohol","Other","None","NK","Total")),
  list(id="25.1.3", rows=c("Heroin","Other opioids","Cocaine","Crack","Amphetamines/meth","Cannabis","Other stimulants","Hypnotics/sed","Alcohol","Other","None","NK","Total"),
       cols=c("Heroin","Other opioids","Cocaine","Crack","Amphetamines/meth","Cannabis","Other stimulants","Hypnotics/sed","Alcohol","Other","None","NK","Total")),
  list(id="25.1.4", rows=c("Heroin","Other opioids","Cocaine","Crack","Amphetamines/meth","Cannabis","Other stimulants","Hypnotics/sed","Alcohol","Other","None","NK","Total"),
       cols=c("Heroin","Other opioids","Cocaine","Crack","Amphetamines/meth","Cannabis","Other stimulants","Hypnotics/sed","Alcohol","Other","None","NK","Total")),
  list(id="25.1.5", rows=c("Heroin","Other opioids","Cocaine","Crack","Amphetamines/meth","Cannabis","Other stimulants","Hypnotics/sed","Alcohol","Other","None","NK","Total"),
       cols=c("Heroin","Other opioids","Cocaine","Crack","Amphetamines/meth","Cannabis","Other stimulants","Hypnotics/sed","Alcohol","Other","None","NK","Total")),
  list(id="25.1.6", rows=DRUG_ROWS_LABELS, cols=DRUG_ROWS_LABELS),
  list(id="26.1.1", rows=c("Not tested","Ever tested","Negative","Positive","Refuse","NK","Total"),
       cols=c("Never inj","Ever inj","Not last 12m","Last 12m","Currently","Refuse","NK","Total")),
  list(id="26.1.2", rows=c("Not tested","Ever tested","Negative","Positive","Refuse","NK","Total"),
       cols=c("Never inj","Ever inj","Not last 12m","Last 12m","Currently","Refuse","NK","Total")),
  list(id="26.1.3", rows=c("Not tested","Ever tested","Negative","Positive","Refuse","NK","Total"),
       cols=c("Never inj","Ever inj","Not last 12m","Last 12m","Currently","Refuse","NK","Total")),
  list(id="27.1.1", rows=c("Not tested","Ever tested","Negative","Positive","Refuse","NK","Total"),
       cols=c("Never inj","Ever inj","Not last 12m","Last 12m","Currently","Refuse","NK","Total")),
  list(id="27.1.2", rows=c("Not tested","Ever tested","Negative","Positive","Refuse","NK","Total"),
       cols=c("Never inj","Ever inj","Not last 12m","Last 12m","Currently","Refuse","NK","Total")),
  list(id="27.1.3", rows=c("Not tested","Ever tested","Negative","Positive","Refuse","NK","Total"),
       cols=c("Never inj","Ever inj","Not last 12m","Last 12m","Currently","Refuse","NK","Total")),
  list(id="28.1.1", rows=c("Never shared","Ever shared","Not last 12m","Last 12m","Currently","Refuse","NK","Total"),
       cols=c("Never inj","Ever inj","Not last 12m","Last 12m","Currently","Refuse","NK","All","Total")),
  list(id="29.1.1", rows=DRUG_ROWS_LABELS, cols=c("Never in OST","Ever not currently","Currently","NK","Total")),
  list(id="29.1.2", rows=c("Heroin","Other opioids","Cocaine","Stimulants","Other","NK","Total"),
       cols=c("<1 yr","1 yr","2 yrs","3 yrs","4 yrs","5 yrs","6–10 yrs","11–20 yrs",">20 yrs","NK","Total"))
)

tabela_ids <- sapply(TABELE_META, `[[`, "id")

# ─── POMOĆNE FUNKCIJE ─────────────────────────────────────────────────────────

pripremi_bazu <- function(input_path, godina) {
  procitanEksel <- read_excel(input_path)
  
  names(procitanEksel) <- KOLONE_ULAZ
  
  date_cols <- KOLONE_DATUMI
  for (col in date_cols)
    procitanEksel[[col]] <- as.Date(procitanEksel[[col]], format="%d.%m.%Y")
  
  baza <- procitanEksel |>
    filter(year(Datum_pochetka_popunjavanja_prijave) == godina) |>
    filter(!Glavni_uzrok_zavisnosti %in% FILTER_ISKLJUCI_UZROK) |>
    filter(!Da_li_se_lice_ranije_lechilo_od_bolesti_zavisnosti_povezane_sa_psihoaktivnim_supstancama %in% FILTER_ISKLJUCI_LECENJE) |>
    mutate(
      Sporedni_uzrok_zavisnosti_1 = na_if(as.character(Sporedni_uzrok_zavisnosti_1), FILTER_ISKLJUCI_SPOREDNI),
      Sporedni_uzrok_zavisnosti_2 = na_if(as.character(Sporedni_uzrok_zavisnosti_2), FILTER_ISKLJUCI_SPOREDNI),
      Sporedni_uzrok_zavisnosti_3 = na_if(as.character(Sporedni_uzrok_zavisnosti_3), FILTER_ISKLJUCI_SPOREDNI)
    ) |>
    arrange(Datum_pochetka_popunjavanja_prijave) |>
    mutate(
      years_diff          = time_length(difftime(Datum_pochetka_ove_epizode_lechenja, Datum_rodjenja), "years"),
      year_complete_round = as.numeric(floor(years_diff)),
      lag_years_first_use_treatment = year_complete_round -
        as.numeric(Uzrast_na_pochetku_korishcenja_glavni_uzrok_zavisnosti),
      .after = Datum_pochetka_ove_epizode_lechenja
    ) |>
    mutate(
      age_cat_pocetak_koriscenja = age_categories(
        Uzrast_na_pochetku_korishcenja_glavni_uzrok_zavisnosti,
        breakers = c(0,15,20,25,30,35,40,45,50,55,60,65)
      ),
      year_complete_round_categories = age_categories(
        year_complete_round,
        breakers = c(0,15,20,25,30,35,40,45,50,55,60,65)
      ),
      year_since_first_injection = year_complete_round -
        Uzrast_prvog_uzimanja_psihoaktivne_supstance_injektiranjem,
      opioid_substitution_therapy = case_when(
        Da_li_je_lice_ikada_bilo_na_supstitucionoj_terapiji_opioidima == "2 - Ne"       ~ "Never_been_in_OST",
        Da_li_je_lice_ikada_bilo_na_supstitucionoj_terapiji_opioidima == "3 - Nepoznato" ~ "Not_known",
        Da_li_je_lice_sada_na_supstitucionoj_terapiji_opiodima        == "2 - Ne"        ~ "Ever_been_not_currently",
        Da_li_je_lice_sada_na_supstitucionoj_terapiji_opiodima        == "1 - Da"        ~ "Ever_been_currently"
      ),
      years_since_first_OST = godina -
        Godina_u_kojoj_je_zapocheta_prva_supstituciona_terapija_opioidima
    )
  
  baza
}

izracunaj_tabelu <- function(baza, tabela_id) {
  fn_name <- paste0("dodaj_tabelu_", gsub("\\.", "", tabela_id))
  fn <- tryCatch(get(fn_name), error = function(e) NULL)
  if (is.null(fn)) return(NULL)
  
  # Capture the matrix that pisi_tabelu would write
  # We intercept by temporarily overriding pisi_tabelu
  result <- NULL
  local_env <- environment()
  old_pisi <- get("pisi_tabelu", envir = parent.env(environment()))
  
  withCallingHandlers(
    tryCatch({
      # Override pisi_tabelu to capture matrix instead of writing
      assign("pisi_tabelu", function(wb, tid, matrica) {
        result <<- matrica
      }, envir = parent.env(local_env))
      fn(NULL, baza)
      assign("pisi_tabelu", old_pisi, envir = parent.env(local_env))
    }, error = function(e) {
      assign("pisi_tabelu", old_pisi, envir = parent.env(local_env))
    }),
    message = function(m) invokeRestart("muffleMessage")
  )
  result
}

matrica_u_df <- function(matrica, row_labels, col_labels) {
  if (is.null(matrica)) return(NULL)
  df <- as.data.frame(matrica)
  colnames(df) <- col_labels[seq_len(ncol(df))]
  rownames(df) <- row_labels[seq_len(nrow(df))]
  df
}

# ─── UI ───────────────────────────────────────────────────────────────────────

ui <- page_fillable(
  theme = theme_light,

  tags$head(
    tags$script(HTML("
      var _darkMode = false;
      function toggleDarkMode(btn) {
        _darkMode = !_darkMode;
        document.body.classList.toggle('dark-mode', _darkMode);
        document.body.classList.toggle('light-mode', !_darkMode);
        btn.textContent = _darkMode ? '\u2600\uFE0F  Light' : '\uD83C\uDF19  Dark';
        Shiny.setInputValue('dark_mode', _darkMode ? 'dark' : 'light', {priority: 'event'});
      }
      document.addEventListener('DOMContentLoaded', function() {
        document.body.classList.add('light-mode');
      });
      Shiny.addCustomMessageHandler('setThemeClass', function(mode) {
        document.body.classList.toggle('dark-mode', mode === 'dark');
        document.body.classList.toggle('light-mode', mode !== 'dark');
      });
    ")),
    tags$style(HTML("
    .tab-panel  { padding: 16px 0; }

    .panel-title {
      text-transform: uppercase; letter-spacing: 0.1em;
      opacity: 0.5; font-size: 0.82rem; font-weight: 600; margin-bottom: 10px;
    }

    .status-box {
      padding: 10px 14px; border-radius: 6px; font-size: 0.9rem; margin-top: 12px;
    }
    .status-idle    { background: #f8f9fa; border: 1px solid #dee2e6; color: #6c757d; }
    .status-running { background: #cff4fc; border: 1px solid #9eeaf9; color: #055160; }
    .status-done    { background: #d1e7dd; border: 1px solid #a3cfbb; color: #0a3622; }
    .status-error   { background: #f8d7da; border: 1px solid #f1aeb5; color: #58151c; }

    .table-id-badge {
      display: inline-block; background: #e7f1ff; color: #0d6efd;
      font-size: 0.8rem; font-weight: 600;
      padding: 3px 10px; border-radius: 4px; margin-bottom: 8px;
    }

    .path-display {
      font-size: 0.8rem; color: #198754;
      background: #d1e7dd; border: 1px solid #a3cfbb;
      padding: 6px 10px; border-radius: 4px; margin-top: 6px; word-break: break-all;
    }

    body.light-mode { background-color: #ffffff; }

    .panel-box {
      box-shadow: 0 1px 3px rgba(0,0,0,0.06);
      border-radius: 8px;
      padding: 16px;
      margin-bottom: 16px;
    }
    body.light-mode .panel-box {
      background: #ffffff;
      border: 1px solid #e2e8f0;
    }
    body.dark-mode .panel-box {
      background: #313244;
      border: 1px solid #45475a;
    }

    .summary-card {
      border-radius: 8px;
      padding: 14px 16px;
      text-align: center;
    }
    body.light-mode .summary-card { background: #f8f9fa; border: 1px solid #dee2e6; }
    body.dark-mode  .summary-card { background: #313244; border: 1px solid #45475a; }

    .summary-num { font-size: 1.6rem; font-weight: 700; color: #18bc9c; }
    .summary-lbl { font-size: 0.75rem; margin-top: 2px; opacity: 0.65; }
  "))
  ),

  uiOutput("loading_overlay"),

  tags$a(
    href = "https://lecenjezavisnosti.online", target = "_blank",
    "📋 Metodološko uputstvo",
    style = paste0(
      "position:fixed; bottom:16px; right:16px; z-index:9999;",
      "background:#ffffff; border:1px solid #dee2e6; border-radius:20px;",
      "padding:6px 14px; font-size:0.78rem; color:#18bc9c; font-weight:600;",
      "text-decoration:none; box-shadow:0 2px 8px rgba(0,0,0,0.12);",
      "transition:opacity 0.2s;",
      "opacity:0.85;"
    )
  ),

  div(style = "display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; padding: 20px 20px 0;",
    div(
      h3("TDI / EMCDDA", style = "margin:0; font-weight:700;"),
      p("Automatizacija izveštaja · Treatment Demand Indicator",
        style = "margin:0; font-size:0.85rem; opacity:0.55; text-transform:uppercase; letter-spacing:0.07em;")
    ),
    tags$button(
      id = "dark_mode_btn",
      onclick = "toggleDarkMode(this)",
      "🌙  Dark",
      style = paste0(
        "background:none; border:1px solid #dee2e6; border-radius:20px;",
        "padding:5px 14px; font-size:0.82rem; cursor:pointer;",
        "color:inherit; transition:all 0.2s;"
      )
    )
  ),
  div(style = "padding: 0 20px;",
  
  # ── Tabs ──
  tabsetPanel(id = "main_tabs",
              # ── Tab 1: Podešavanja i pokretanje ──────────────────────────────────────
              tabPanel("⚙ Generisanje izveštaja",
                       div(class = "tab-panel",
                           fluidRow(
                             # --- Leva kolona: Input ---
                             column(5,
                                    div(class = "panel-box",
                                        div(class = "panel-title", "1. Ulazni podaci"),
                                        fileInput("input_file", "Odaberi ulazni Excel fajl (ulazniPodaci.xlsx)",
                                                  accept = c(".xlsx",".xls"),
                                                  buttonLabel = "Pretraži...", placeholder = "Nijedan fajl nije odabran"
                                        ),
                                        numericInput("godina", "Godina izveštaja", value = 2023,
                                                     min = 2010, max = 2030, step = 1),
                                        uiOutput("nivo_filter_ui")
                                    ),

                                    div(class = "panel-box",
                                        div(class = "panel-title", "2. Format izlaza"),
                                        uiOutput("format_ui")
                                    ),

                                    div(class = "panel-box",
                                        div(class = "panel-title", "3. Odredišni folder za čuvanje"),
                                        fluidRow(
                                          column(9,
                                                 textInput("output_dir", NULL,
                                                           value = path.expand("~"),
                                                           placeholder = "Upiši putanju ili klikni Pretraži..."
                                                 )
                                          ),
                                          column(3,
                                                 tags$br(),
                                                 actionButton("btn_browse", "📁 Pretraži", class = "btn-outline-secondary")
                                          )
                                        ),
                                        textInput("output_filename", "Naziv output fajla",
                                                  value = paste0("TDI_", format(Sys.Date(), "%Y"), "_izlaz.xlsx")
                                        ),
                                        uiOutput("full_path_display")
                                    )
                             ),
                             
                             # --- Desna kolona: Pokretanje ---
                             column(7,
                                    div(class = "panel-box",
                                        div(class = "panel-title", "4. Pokreni obradu"),
                                        fluidRow(
                                          column(6,
                                                 actionButton("btn_run", "▶  Generiši izveštaj", class = "btn-primary btn-lg w-100")
                                          ),
                                          column(6,
                                                 downloadButton("btn_download", "⬇  Preuzmi .xlsx",
                                                                class = "btn-outline-success btn-lg w-100")
                                          )
                                        ),
                                        uiOutput("status_ui"),
                                        uiOutput("progress_ui"),
                                        uiOutput("summary_cards")
                                    ),
                                    
                                    div(class = "panel-box",
                                        div(class = "panel-title", "Log"),
                                        verbatimTextOutput("log_output",
                                                           placeholder = TRUE)
                                    )
                             )
                           )
                       )
              ),
              
              # ── Tab 2: Pregled tabela ─────────────────────────────────────────────────
              tabPanel("📊 Pregled tabela",
                       div(class = "tab-panel",
                           fluidRow(
                             column(3,
                                    div(class = "panel-box",
                                        div(class = "panel-title", "Odaberi tabelu"),
                                        selectInput("selected_table", NULL,
                                                    choices = setNames(tabela_ids, paste(tabela_ids, "—", sapply(TABELE_META, function(t) {
                                                      meta <- TABELE_META[[which(tabela_ids == t$id)]]
                                                      paste0(length(meta$rows), "×", length(meta$cols))
                                                    }))),
                                                    selected = "8.1.1", size = 20, selectize = FALSE
                                        )
                                    )
                             ),
                             column(9,
                                    uiOutput("table_header_ui"),
                                    div(style = "overflow-x: auto",
                                        DT::dataTableOutput("table_preview")
                                    ),
                                    uiOutput("table_note_ui")
                             )
                           )
                       )
              )
  )   # closes tabsetPanel
  )   # closes div(padding wrapper)
)     # closes page_fillable

# ─── SERVER ───────────────────────────────────────────────────────────────────

server <- function(input, output, session) {
  
  # Reaktivne vrednosti
  rv <- reactiveValues(
    baza        = NULL,
    output_path = NULL,
    status      = "idle",   # idle | running | done | error
    log         = character(0),
    n_rows      = 0,
    elapsed     = NULL,
    prog_val    = 0,         # 0–100
    prog_detail = ""
  )
  
  # ── Dark/light mode switch ────────────────────────────────────────────────
  observe({
    if (!is.null(input$dark_mode)) {
      if (input$dark_mode == "dark") {
        session$setCurrentTheme(theme_dark)
        session$sendCustomMessage("setThemeClass", "dark")
      } else {
        session$setCurrentTheme(theme_light)
        session$sendCustomMessage("setThemeClass", "light")
      }
    }
  })

  # ── Ustanova dropdown (puni se kad se učita fajl) ─────────────────────────
  # ── Tri nivoa filtera: Sve / Okrug / Ustanova ────────────────────────────────
  output$nivo_filter_ui <- renderUI({
    req(input$input_file)
    df <- tryCatch(readxl::read_excel(input$input_file$datapath, n_max = 5000), error = function(e) NULL)
    if (is.null(df)) return(NULL)

    # Kolona 2 = Okrug, kolona 3 = Ustanova
    okruzi   <- sort(unique(as.character(df[[2]])))
    okruzi   <- okruzi[!is.na(okruzi) & okruzi != ""]
    ustanove <- sort(unique(as.character(df[[3]])))
    ustanove <- ustanove[!is.na(ustanove) & ustanove != ""]

    tagList(
      radioButtons("nivo_izvestaja", "Nivo izveštaja",
        choices  = c(
          "Sve ustanove (državni nivo)"  = "sve",
          "Po okrugu (regionalni nivo)"  = "okrug",
          "Po ustanovi"                  = "ustanova"
        ),
        selected = "sve",
        width    = "100%"
      ),
      conditionalPanel(
        condition = "input.nivo_izvestaja == 'okrug'",
        selectInput("okrug_filter", "Okrug",
          choices = setNames(okruzi, okruzi),
          width   = "100%"
        )
      ),
      conditionalPanel(
        condition = "input.nivo_izvestaja == 'ustanova'",
        selectInput("ustanova_filter", "Ustanova",
          choices = setNames(ustanove, ustanove),
          width   = "100%"
        )
      )
    )
  })

  # ── Format UI (dinamicki, zavisi od toga da li postoji data/TDI_template.xlsx)
  TEMPLATE_DATA_PATH <- file.path(getwd(), "data", "TDI_template.xlsx")

  template_postoji <- reactive({
    file.exists(TEMPLATE_DATA_PATH)
  })

  output$format_ui <- renderUI({
    ima_template <- template_postoji()
    tagList(
      radioButtons("output_format", NULL,
        choices = c(
          "Sheet po tabeli  (jedan sheet = jedna tabela)" = "sheets",
          "TDI template  (punjenje originalnog XLS-a)"   = "template"
        ),
        selected = if (ima_template) "template" else "sheets"
      ),
      if (ima_template) {
        div(class = "status-box status-done",
            style = "font-size:0.82rem; padding:6px 12px; margin-top:4px;",
            paste0("✓  Template pronadjen: data/TDI_template.xlsx")
        )
      } else {
        tagList(
          div(class = "status-box status-idle",
              style = "font-size:0.82rem; padding:6px 12px; margin-top:4px;",
              "⚠  Template nije pronadjen u data/ folderu"
          ),
          conditionalPanel(
            condition = "input.output_format == 'template'",
            tags$hr(style = "margin: 10px 0;"),
            fileInput("template_file", "Uploaduj TDI template (.xlsx)",
              accept = c(".xlsx", ".xls"),
              buttonLabel = "Pretrazi...",
              placeholder = "TDI_2022_XX_XX.xlsx",
              width = "100%"
            ),
            tags$small(style = "color:#6c757d; font-size:0.8rem;",
              "Korak: otvori TDI_2022_XX_XX.xls u Excel-u, Sacuvaj kao .xlsx"
            )
          )
        )
      }
    )
  })

  # ── Putanja fajla ──────────────────────────────────────────────────────────
  output$full_path_display <- renderUI({
    req(input$output_dir, input$output_filename)
    full <- file.path(input$output_dir, input$output_filename)
    div(class = "path-display", "→ ", full)
  })
  
  # ── Folder browser (native dialog u RStudio) ───────────────────────────────
  observeEvent(input$btn_browse, {
    chosen <- tryCatch(
      tcltk::tk_choose.dir(
        default = input$output_dir,
        caption = "Odaberi folder za čuvanje"
      ),
      error = function(e) NULL
    )
    if (!is.null(chosen) && !is.na(chosen))
      updateTextInput(session, "output_dir", value = chosen)
  })
  
  # ── Log helper ─────────────────────────────────────────────────────────────
  add_log <- function(msg) {
    ts <- format(Sys.time(), "[%H:%M:%S]")
    rv$log <- c(rv$log, paste(ts, msg))
  }
  
  output$log_output <- renderText({
    paste(tail(rv$log, 30), collapse = "\n")
  })
  
  # ── Status UI ──────────────────────────────────────────────────────────────
  output$status_ui <- renderUI({
    cls <- switch(rv$status,
                  idle    = "status-box status-idle",
                  running = "status-box status-running",
                  done    = "status-box status-done",
                  error   = "status-box status-error"
    )
    msg <- switch(rv$status,
                  idle    = "⏸  Čeka na pokretanje",
                  running = "⚙  Obrada u toku...",
                  done    = paste0("✓  Završeno za ", round(rv$elapsed, 1), " sek · ", rv$n_rows, " zapisa obrađeno"),
                  error   = "✕  Greška — vidite log ispod"
    )
    div(class = cls, msg)
  })
  
  # ── Loading overlay ────────────────────────────────────────────────────────
  output$loading_overlay <- renderUI({
    if (rv$status != "running") return(NULL)
    div(class = "loading-overlay",
      div(class = "loading-box",
        div(class = "loading-spinner"),
        div(class = "loading-title", "Generisanje izveštaja..."),
        div(class = "loading-detail", rv$prog_detail)
      )
    )
  })

  # ── Progress bar UI ────────────────────────────────────────────────────────
  output$progress_ui <- renderUI({
    if (rv$status != "running") return(NULL)
    val <- rv$prog_val
    detail <- rv$prog_detail
    div(style = "margin-top:10px;",
      div(style = "font-size:0.82rem; color:#888; margin-bottom:4px;", detail),
      div(style = "background:#e9ecef; border-radius:6px; height:18px; overflow:hidden;",
        div(style = paste0(
          "width:", val, "%;",
          "height:100%;",
          "background: linear-gradient(90deg, #2ecc71, #27ae60);",
          "border-radius:6px;",
          "transition: width 0.3s ease;",
          "display:flex; align-items:center; justify-content:center;"
        ),
          if (val >= 15) span(style = "color:white; font-size:0.75rem; font-weight:600;",
                              paste0(val, "%")) else NULL
        )
      )
    )
  })

  # ── Summary cards ──────────────────────────────────────────────────────────
  output$summary_cards <- renderUI({
    req(rv$baza)
    b <- rv$baza
    fluidRow(
      style = "margin-top:14px",
      column(3, div(class="summary-card",
                    div(class="summary-num", nrow(b)),
                    div(class="summary-lbl", "Zapisa u bazi")
      )),
      column(3, div(class="summary-card",
                    div(class="summary-num", sum(b$Pol == "Muško", na.rm=TRUE)),
                    div(class="summary-lbl", "Muških")
      )),
      column(3, div(class="summary-card",
                    div(class="summary-num", sum(b$Pol == "Žensko", na.rm=TRUE)),
                    div(class="summary-lbl", "Ženskih")
      )),
      column(3, div(class="summary-card",
                    div(class="summary-num", length(unique(b$Ustanova))),
                    div(class="summary-lbl", "Ustanova")
      ))
    )
  })
  
  # ── Pokreni obradu ─────────────────────────────────────────────────────────
  observeEvent(input$btn_run, {
    req(input$input_file, input$output_dir, input$output_filename)
    
    rv$status <- "running"
    rv$log    <- character(0)
    rv$baza   <- NULL
    
    start_t <- Sys.time()
    
    withCallingHandlers(
      tryCatch({
        
        add_log("Učitavanje ulaznih podataka...")
        baza <- pripremi_bazu(input$input_file$datapath, input$godina)

        # ── Filter po nivou izveštaja ──────────────────────────────────────────
        nivo <- if (!is.null(input$nivo_izvestaja)) input$nivo_izvestaja else "sve"

        if (nivo == "okrug" && !is.null(input$okrug_filter)) {
          baza <- baza |> filter(Okrug == input$okrug_filter)
          add_log(paste("  → Filter: Okrug =", input$okrug_filter))
        } else if (nivo == "ustanova" && !is.null(input$ustanova_filter)) {
          baza <- baza |> filter(Ustanova == input$ustanova_filter)
          add_log(paste("  → Filter: Ustanova =", input$ustanova_filter))
        } else {
          add_log("  → Nivo: Sve ustanove (državni)")
        }

        # Ukloni duplikate po JMBG tek nakon filtera ustanove
        n_pre <- nrow(baza)
        baza <- baza |> distinct(JMBG_EBS, .keep_all = TRUE)
        n_dup <- n_pre - nrow(baza)
        if (n_dup > 0) add_log(paste("  → Uklonjeno duplikata:", n_dup))

        rv$baza <- baza
        rv$n_rows <- nrow(baza)
        add_log(paste("  →", nrow(baza), "zapisa nakon filtriranja"))
        
        tabele_ids_order <- c(
          "8.1.1","8.1.2","8.1.3",
          "9.1.1","9.1.2","9.1.3",
          "10.1.1","10.1.2","10.1.3",
          "11.1.1","11.1.2","11.1.3","11.1.4","11.1.5","11.1.6","11.1.7","11.1.8","11.1.9",
          "12.1.1","12.1.2","12.1.3",
          "13.1.1","13.1.2","13.1.3",
          "14.1.1","14.1.2","14.1.3",
          "15.1.1","15.1.2","15.1.3",
          "16.1.1","16.1.2","16.1.3",
          "17.1.1","17.1.2","17.1.3",
          "18.1.1","18.1.2","18.1.3",
          "19.1.1","19.1.2","19.1.3",
          "20.1.1","20.1.2","20.1.3",
          "21.1.1","21.1.2","21.1.3",
          "22.1.1","22.1.2","22.1.3",
          "23.1.1","23.1.2","23.1.3",
          "24.1.1",
          "25.1.1","25.1.2","25.1.3","25.1.4","25.1.5","25.1.6",
          "26.1.1","26.1.2","26.1.3",
          "27.1.1","27.1.2","27.1.3",
          "28.1.1",
          "29.1.1","29.1.2"
        )

        tabele_fns <- list(
          dodaj_tabelu_811, dodaj_tabelu_812, dodaj_tabelu_813,
          dodaj_tabelu_911, dodaj_tabelu_912, dodaj_tabelu_913,
          dodaj_tabelu_1011, dodaj_tabelu_1012, dodaj_tabelu_1013,
          dodaj_tabelu_1111, dodaj_tabelu_1112, dodaj_tabelu_1113,
          dodaj_tabelu_1114, dodaj_tabelu_1115, dodaj_tabelu_1116,
          dodaj_tabelu_1117, dodaj_tabelu_1118, dodaj_tabelu_1119,
          dodaj_tabelu_1211, dodaj_tabelu_1212, dodaj_tabelu_1213,
          dodaj_tabelu_1311, dodaj_tabelu_1312, dodaj_tabelu_1313,
          dodaj_tabelu_1411, dodaj_tabelu_1412, dodaj_tabelu_1413,
          dodaj_tabelu_1511, dodaj_tabelu_1512, dodaj_tabelu_1513,
          dodaj_tabelu_1611, dodaj_tabelu_1612, dodaj_tabelu_1613,
          dodaj_tabelu_1711, dodaj_tabelu_1712, dodaj_tabelu_1713,
          dodaj_tabelu_1811, dodaj_tabelu_1812, dodaj_tabelu_1813,
          dodaj_tabelu_1911, dodaj_tabelu_1912, dodaj_tabelu_1913,
          dodaj_tabelu_2011, dodaj_tabelu_2012, dodaj_tabelu_2013,
          dodaj_tabelu_2111, dodaj_tabelu_2112, dodaj_tabelu_2113,
          dodaj_tabelu_2211, dodaj_tabelu_2212, dodaj_tabelu_2213,
          dodaj_tabelu_2311, dodaj_tabelu_2312, dodaj_tabelu_2313,
          dodaj_tabelu_2411,
          dodaj_tabelu_2511, dodaj_tabelu_2512, dodaj_tabelu_2513,
          dodaj_tabelu_2514, dodaj_tabelu_2515, dodaj_tabelu_2516,
          dodaj_tabelu_2611, dodaj_tabelu_2612, dodaj_tabelu_2613,
          dodaj_tabelu_2711, dodaj_tabelu_2712, dodaj_tabelu_2713,
          dodaj_tabelu_2811,
          dodaj_tabelu_2911, dodaj_tabelu_2912
        )

        # ── Odabir nacina generisanja: template ili klasicni multi-sheet ──
        koristiti_template <- !is.null(input$output_format) && input$output_format == "template"

        if (koristiti_template) {
          # Prvo pokusaj iz data/ foldera, pa onda uploaded fajl
          template_path <- NULL
          if (file.exists(TEMPLATE_DATA_PATH)) {
            template_path <- TEMPLATE_DATA_PATH
            add_log(paste("Template iz data/ foldera:", basename(template_path)))
          } else if (!is.null(input$template_file)) {
            template_path <- input$template_file$datapath
            add_log("Template uploadovan od strane korisnika")
          } else {
            add_log("GRESKA: Template nije pronadjen. Dodajte data/TDI_template.xlsx ili uploadujte template.")
            rv$status <- "error"
            return()
          }
          add_log("Punjenje TDI template-a...")
          wb <- loadWorkbook(template_path)

          n <- length(tabele_fns)
          for (i in seq_along(tabele_fns)) {
            tid <- tabele_ids_order[[i]]
            rv$prog_val    <- as.integer(round(100 * i / n))
            rv$prog_detail <- paste0("Tabela ", tid, "  (", i, " / ", n, ")")
            tabele_fns[[i]](wb, baza)
            if (i %% 10 == 0) add_log(paste0("  → ", i, "/", n, " tabela završeno"))
          }

        } else {
          add_log("⚠ Template nije pronađen — generišem klasični multi-sheet xlsx...")
          wb <- createWorkbook()

          # Sadržaj sheet (prvi tab)
          sadrzaj_df <- data.frame(
            Redni_broj = seq_along(tabele_ids_order),
            Tabela     = tabele_ids_order,
            stringsAsFactors = FALSE
          )
          addWorksheet(wb, "Sadrzaj")
          writeData(wb, "Sadrzaj", sadrzaj_df, rowNames = FALSE)

          # Jedan sheet po tabeli — interceptujemo pisi_tabelu
          n <- length(tabele_fns)
          for (i in seq_along(tabele_fns)) {
            tid <- tabele_ids_order[[i]]
            rv$prog_val    <- as.integer(round(100 * i / n))
            rv$prog_detail <- paste0("Tabela ", tid, "  (", i, " / ", n, ")")
            mat <- NULL
            tryCatch({
              old_pisi <- pisi_tabelu
              pisi_tabelu <<- function(wb_ignored, tid_ignored, matrica) { mat <<- matrica }
              tabele_fns[[i]](NULL, baza)
              pisi_tabelu <<- old_pisi
            }, error = function(e) {
              pisi_tabelu <<- old_pisi
            })

            sheet_name <- gsub("\\.", "_", tid)
            addWorksheet(wb, sheet_name)
            if (!is.null(mat)) {
              df_out <- as.data.frame(mat)
              writeData(wb, sheet_name, df_out, rowNames = FALSE, colNames = TRUE)
            }
            if (i %% 10 == 0) add_log(paste0("  → ", i, "/", n, " tabela završeno"))
          }
        }

        add_log(paste("  → Svih", n, "tabela generisano"))

        out_path <- file.path(input$output_dir, input$output_filename)
        add_log(paste("Snimanje:", out_path))

        if (!dir.exists(input$output_dir))
          dir.create(input$output_dir, recursive = TRUE)

        saveWorkbook(wb, file = out_path, overwrite = TRUE)
        rv$output_path <- out_path
        
        rv$elapsed     <- as.numeric(difftime(Sys.time(), start_t, units = "secs"))
        rv$prog_val    <- 100
        rv$prog_detail <- ""
        add_log(paste0("✓ Završeno za ", round(rv$elapsed, 1), " sek"))
        rv$status <- "done"
        
      }, error = function(e) {
        add_log(paste("GREŠKA:", conditionMessage(e)))
        rv$status <- "error"
      }),
      message = function(m) {
        add_log(paste("  ", trimws(conditionMessage(m))))
        invokeRestart("muffleMessage")
      }
    )
  })
  
  # ── Download handler ────────────────────────────────────────────────────────
  output$btn_download <- downloadHandler(
    filename = function() input$output_filename,
    content  = function(file) {
      req(rv$output_path, file.exists(rv$output_path))
      file.copy(rv$output_path, file)
    }
  )
  
  # ── Pregled tabela ──────────────────────────────────────────────────────────
  output$table_header_ui <- renderUI({
    req(input$selected_table)
    meta <- TABELE_META[[which(tabela_ids == input$selected_table)]]
    div(
      div(class = "table-id-badge", input$selected_table),
      tags$p(style = "font-size:0.85rem; opacity:0.6; margin:4px 0 12px",
             paste0(length(meta$rows), " redova × ", length(meta$cols), " kolona")
      )
    )
  })
  
  output$table_preview <- DT::renderDataTable({
    req(input$selected_table, rv$baza)
    
    meta <- TABELE_META[[which(tabela_ids == input$selected_table)]]
    fn_name <- paste0("dodaj_tabelu_", gsub("\\.", "", input$selected_table))
    fn <- tryCatch(get(fn_name), error = function(e) NULL)
    
    if (is.null(fn)) {
      df <- as.data.frame(matrix("—", nrow=length(meta$rows), ncol=length(meta$cols)))
    } else {
      mat <- NULL
      tryCatch({
        old_pisi <- pisi_tabelu
        pisi_tabelu <<- function(wb, tid, matrica) { mat <<- matrica }
        fn(NULL, rv$baza)
        pisi_tabelu <<- old_pisi
      }, error = function(e) NULL)
      
      if (is.null(mat)) {
        df <- as.data.frame(matrix("—", nrow=length(meta$rows), ncol=length(meta$cols)))
      } else {
        df <- as.data.frame(mat)
      }
    }
    
    n_rows <- min(nrow(df), length(meta$rows))
    n_cols <- min(ncol(df), length(meta$cols))
    rownames(df) <- meta$rows[seq_len(n_rows)]
    colnames(df) <- meta$cols[seq_len(n_cols)]
    
    DT::datatable(df,
                  options = list(
                    pageLength  = 50,
                    scrollX     = TRUE,
                    dom         = "t",
                    ordering    = FALSE
                  ),
                  rownames = TRUE,
                  class    = "compact stripe"
    )
  })
  
  output$table_note_ui <- renderUI({
    if (is.null(rv$baza)) {
      div(style = "margin-top:12px;",
          "ℹ  Učitaj ulazni fajl i pokreni obradu da vidiš stvarne vrednosti."
      )
    }
  })
}

shinyApp(ui, server)
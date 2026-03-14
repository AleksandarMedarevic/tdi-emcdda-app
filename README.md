# TDI / EMCDDA — Softver za generisanje izveštaja

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-v1.1.0-green.svg)](CHANGELOG.md)
[![R](https://img.shields.io/badge/R-%3E%3D4.1-276DC3.svg)](https://www.r-project.org/)

Softver za automatizaciju generisanja godišnjeg izveštaja o tražnji za lečenjem od zavisnosti prema **EMCDDA Treatment Demand Indicator (TDI)** standardu.

---

## O softveru

Aplikacija čita izvoz iz nacionalnog informacionog sistema, primenjuje EMCDDA metodologiju i generiše svih **65 TDI tabela** (8.1.1 — 29.1.2) u Excel formatu. Sadrži grafički interfejs (Shiny web aplikacija) i radi lokalno na računaru korisnika — podaci se ne šalju na mreži.

### Ključne funkcionalnosti

- Generisanje 65 TDI tabela u jednom koraku
- Tri nivoa izveštavanja: državni (Batut/Ministarstvo), regionalni (po okrugu), po ustanovi
- Dva formata izlaza: punjenje originalnog TDI template-a ili sheet po tabeli
- Interaktivni pregled tabela unutar aplikacije
- Podrška za Windows (dvoklikom), RStudio i R konzolu

---

## Instalacija

### Preduslovi

- [R](https://cran.r-project.org/) verzija 4.1 ili novija
- Windows 7/10/11 (ili macOS/Linux sa RStudio)

### Koraci

**1. Klonirajte repozitorijum**

```bash
git clone https://github.com/vas-nalog/TDI_aplikacija.git
cd TDI_aplikacija
```

**2. Kreirajte config.R**

Kopirajte primer konfiguracije i popunite stvarnim nazivima kolona:

```bash
cp config.example.R config.R
```

Otvorite `config.R` u tekst editoru i zamenite `"Kolona_01"`, `"Kolona_02"` itd. stvarnim nazivima kolona iz vašeg sistema.

**3. Dodajte TDI template**

Kreirajte folder `data/` i dodajte TDI template:

```
data/
└── TDI_template.xlsx
```

**4. Pokrenite aplikaciju — paketi se instaliraju automatski**

Pri prvom pokretanju, `app.R` automatski instalira sve potrebne pakete (može potrajati 2–5 minuta).

> **Opciono:** Možete ručno pokrenuti `instaliraj_pakete.R` u RStudiu ako želite da proverite verzije paketa ili ako automatska instalacija ne uspe.

---

## Pokretanje

### Windows — dvoklikom

Dvaput kliknite na `pokreni_app.bat`. Pri prvom pokretanju otvara se prozor za odabir `Rscript.exe`.

### RStudio

Otvorite `app.R` u RStudiu i kliknite **Run App**, ili u konzoli:

```r
shiny::runApp("app.R", launch.browser = TRUE)
```

### R konzola

```r
setwd("C:/putanja/do/TDI_aplikacija")
shiny::runApp("app.R", launch.browser = TRUE)
```

---

## Struktura projekta

```
TDI_aplikacija/
├── app.R                    # Shiny aplikacija (UI + server)
├── helpers.R                # 65 funkcija za TDI tabele
├── config.example.R         # Primer konfiguracije
├── config.R                 # Vaša konfiguracija (nije na GitHub)
├── instaliraj_pakete.R      # Opciona provera paketa (instalacija je automatska)
├── pokreni_app.bat          # Windows pokretač
├── nadji_r.ps1              # Helper za lociranje R
├── data/                    # Vaši podaci (nisu na GitHub)
│   └── TDI_template.xlsx
├── ARCHITECTURE.md          # Tehnička arhitektura
├── CHANGELOG.md             # Istorija verzija
└── LICENSE                  # MIT licenca
```

---

## Dokumentacija

| Dokument | Opis |
|---|---|
| [UPUTSTVO.pdf](UPUTSTVO.pdf) | Korisničko uputstvo (srpski) |
| [TEHNICKA_DOKUMENTACIJA.pdf](TEHNICKA_DOKUMENTACIJA.pdf) | Tehnička dokumentacija |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Arhitektura sistema |
| [CHANGELOG.md](CHANGELOG.md) | Istorija verzija |

---

## TDI tabele

Softver generiše 65 tabela po EMCDDA standardu:

| Grupe | Tabele | Opis |
|---|---|---|
| 8–10 | 9 tabela | Tip centra, primarna supstanca, pol |
| 11–12 | 12 tabela | Starost pri ulasku i prvoj upotrebi |
| 13–18 | 18 tabela | Socijalni pokazatelji |
| 19–22 | 12 tabela | Način i učestalost korišćenja, injektiranje |
| 23–25 | 8 tabela | Kombinacije supstanci, dužina korišćenja |
| 26–29 | 6 tabela | HIV, Hepatitis, OST status |

---

## Bezbednost podataka

Aplikacija radi isključivo lokalno. Nema mrežnih poziva — podaci se ne šalju na eksterne servere. Interni nazivi kolona i podaci nisu deo ovog repozitorijuma.

---

## Povezani resursi

| Resurs | Opis | Link |
|---|---|---|
| Uputstvo za popunjavanje prijave | Online uputstvo kako popuniti individualnu prijavu za lica obolela od bolesti zavisnosti | [lecenjezavisnosti.online](https://lecenjezavisnosti.online) |
| EMCDDA TDI protokol | Zvanični EMCDDA standard za prikupljanje TDI podataka | [emcdda.europa.eu](https://www.emcdda.europa.eu) |

---

## Autori

**Milica Savić, Aleksandar Međarević**

---

## Licenca

[MIT License](LICENSE) — slobodno koristite, menjajte i distribuirajte uz navođenje autora.

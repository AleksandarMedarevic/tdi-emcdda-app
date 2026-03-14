# Arhitektura sistema — TDI/EMCDDA

## Pregled

TDI/EMCDDA aplikacija automatizuje generisanje godišnjeg izveštaja o tražnji za
lečenjem od zavisnosti (Treatment Demand Indicator) po EMCDDA standardu.
Aplikacija čita izvoz iz nacionalnog informacionog sistema, primenjuje
EMCDDA metodologiju i popunjava standardizovani template za izveštavanje.

---

## Struktura fajlova

```
TDI_aplikacija/
│
├── app.R                  # Shiny UI + server logika
├── helpers.R              # 65 funkcija za računanje tabela
├── config.R               # Interni nazivi kolona i filter vrednosti (nije na GitHub)
├── config.example.R       # Primer konfiguracije (na GitHub)
│
├── instaliraj_pakete.R    # Jednokratna instalacija R paketa
├── pokreni_app.bat        # Windows pokretač
├── nadji_r.ps1            # Helper za lociranje Rscript.exe
│
├── data/
│   └── TDI_template.xlsx  # EMCDDA template (nije na GitHub)
│
├── LICENSE
├── CHANGELOG.md
├── ARCHITECTURE.md
├── README.txt
├── UPUTSTVO.pdf
└── UPUTSTVO.docx
```

---

## Komponente

### app.R
Glavna Shiny aplikacija. Sadrži:
- **UI** — `page_fillable()` sa bslib cosmo temom, svetli/tamni mod
- **`pripremi_bazu()`** — čita Excel, preimenuje kolone, filtrira podatke
- **Server logika** — orkestracija obrade, status prikaz, download handler
- **Pregled tabela** — DT widget za interaktivni pregled rezultata

### helpers.R
65 funkcija oblika `dodaj_tabelu_XYZW(wb, baza)`:
- Svaka funkcija odgovara jednoj TDI tabeli (8.1.1 — 29.1.2)
- Prima workbook objekat i obrađenu bazu podataka
- Izračunava matricu vrednosti i upisuje u template ili novi sheet
- Koristi konstante: `OPIOIDI`, `KOKAIN`, `KANABIS`, `TIP_AMBULANTNO` itd.

### config.R
Konfiguracija specifična za sistem izvoza:
- `KOLONE_ULAZ` — vektor od 66 naziva kolona
- `KOLONE_DATUMI` — kolone koje se parsiraju kao datum
- `FILTER_ISKLJUCI_UZROK` — vrednosti koje se isključuju iz obrade
- `FILTER_ISKLJUCI_LECENJE` — filter za tip prethodnog lečenja
- `FILTER_ISKLJUCI_SPOREDNI` — filter za sporedne uzroke

---

## Tok podataka

```
ulazniPodaci.xlsx
       │
       ▼
  read_excel()
       │
       ▼
pripremi_bazu()
  ├── Preimenuj kolone (KOLONE_ULAZ iz config.R)
  ├── Parsiraj datume (KOLONE_DATUMI)
  ├── Filtriraj po godini
  ├── Filtriraj po Okrugu ili Ustanovi (ako je izabran nivo)
  ├── Isključi alkohol i kockanje
  ├── Isključi nastavke lečenja
  ├── Ukloni duplikate (JMBG)
  └── Izračunaj izvedene kolone
       │ (starost, kategorije starosti, lag, OST status)
       ▼
    baza (data.frame, ~N redova)
       │
       ├── Format: TDI template
       │     ├── loadWorkbook(TDI_template.xlsx)
       │     ├── dodaj_tabelu_811(wb, baza)
       │     ├── dodaj_tabelu_812(wb, baza)
       │     ├── ... (65 funkcija)
       │     └── saveWorkbook(wb, izlaz.xlsx)
       │
       └── Format: Sheet po tabeli
             ├── createWorkbook()
             ├── Za svaku tabelu: addWorksheet() + writeData()
             └── saveWorkbook(wb, izlaz.xlsx)
```

---

## TDI Tabele

| Grupa | Tabele | Opis |
|-------|--------|------|
| 8 | 8.1.1 — 8.1.3 | Tip centra × status lečenja |
| 9 | 9.1.1 — 9.1.3 | Primarna supstanca × tip centra |
| 10 | 10.1.1 — 10.1.3 | Primarna supstanca × pol |
| 11 | 11.1.1 — 11.1.9 | Starost pri ulasku i prvoj upotrebi |
| 12 | 12.1.1 — 12.1.3 | Starosne kategorije |
| 13 | 13.1.1 — 13.1.3 | Izvor upućivanja |
| 14 | 14.1.1 — 14.1.3 | Životna situacija |
| 15 | 15.1.1 — 15.1.3 | Deca |
| 16 | 16.1.1 — 16.1.3 | Stambena situacija |
| 17 | 17.1.1 — 17.1.3 | Obrazovanje |
| 18 | 18.1.1 — 18.1.3 | Radni status |
| 19 | 19.1.1 — 19.1.3 | Način korišćenja |
| 20 | 20.1.1 — 20.1.3 | Učestalost korišćenja |
| 21 | 21.1.1 — 21.1.3 | Starost pri prvoj upotrebi |
| 22 | 22.1.1 — 22.1.3 | Status injektiranja |
| 23 | 23.1.1 — 23.1.3 | Starost × dužina korišćenja |
| 24 | 24.1.1 | Status lečenja × OST |
| 25 | 25.1.1 — 25.1.6 | Kombinacije supstanci |
| 26 | 26.1.1 — 26.1.3 | HIV testiranje × injektiranje |
| 27 | 27.1.1 — 27.1.3 | Hepatitis C × injektiranje |
| 28 | 28.1.1 | Hepatitis B × injektiranje |
| 29 | 29.1.1 — 29.1.2 | OST status i trajanje |

Ukupno: **65 tabela**

---

## R Paketi

| Paket | Verzija | Namena |
|-------|---------|--------|
| shiny | ≥ 1.7 | Web aplikacija |
| bslib | ≥ 0.5 | UI tema (cosmo) |
| openxlsx | ≥ 4.2 | Čitanje i pisanje Excel fajlova |
| readxl | ≥ 1.4 | Čitanje ulaznih podataka |
| dplyr | ≥ 1.1 | Manipulacija podacima |
| tidyverse | ≥ 2.0 | Ekosistem za obradu podataka |
| lubridate | ≥ 1.9 | Parsiranje datuma |
| epikit | ≥ 0.1 | Starosne kategorije |
| DT | ≥ 0.28 | Interaktivne tabele |

---

## Bezbednost podataka

Aplikacija radi isključivo lokalno na računaru korisnika.
- Nema mrežnih poziva (nema `httr`, `curl`, `GET`, `POST`)
- Podaci se ne šalju na externe servere
- `config.R` i `data/` nisu deo javnog repozitorijuma
- Svaka ustanova čuva svoje podatke lokalno

---

## Autori

- Milica Savić
- Aleksandar Međarević

## Licenca

MIT License — videti LICENSE fajl.

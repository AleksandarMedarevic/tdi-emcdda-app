# Changelog

Sve značajne promene u projektu su dokumentovane ovde.
Format prati [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Verzioniranje prati [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [v1.1.0] — 2026-03-08

### Dodato
- Shiny aplikacija sa bslib cosmo temom (svetli/tamni mod)
- Tri nivoa izveštavanja: državni (sve), regionalni (po okrugu), po ustanovi
- Kaskadni filter — okrug/ustanova dropdown se pojavljuje prema izboru nivoa
- Izbor formata izlaza: TDI template ili sheet po tabeli
- Automatska detekcija `data/TDI_template.xlsx`
- Pokretanje kroz `pokreni_app.bat` sa automatskim traženjem R
- File picker dialog za lociranje Rscript.exe (`nadji_r.ps1`)
- Čuvanje putanje do R u `r_putanja.txt`
- Pregled tabela unutar aplikacije (DT widget)
- `config.R` — odvajanje internih naziva kolona od koda
- Kompletno uputstvo za korisnike (PDF + DOCX)

### Promenjeno
- Arhitektura refaktorisana: `helpers.R` + `main.R` umesto 65 zasebnih skripti
- Svi nazivi kolona i filter vrednosti premješteni u `config.R`

---

## [v1.0.0] — 2025-12-21

### Dodato
- Inicijalna verzija projekta
- 65 R skripti za generisanje TDI/EMCDDA tabela (tabela_811.R ... tabela_2912.R)
- Podrška za tabele 8.1.1 — 29.1.2 po EMCDDA standardu
- Punjenje TDI_2022_XX_XX.xls template fajla
- `main.R` kao orkestracija svih tabela

---

## Planirano

- [ ] Automatski izveštaj o kvalitetu podataka (missing values, outlieri)
- [ ] Export u CSV format
- [ ] Višejezična podrška (EN/SR)
- [ ] Automatski testovi za svaku tabelu

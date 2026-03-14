# instaliraj_pakete.R ─────────────────────────────────────────────────────────
# Pokrenite ovaj skript JEDNOM pre prve upotrebe aplikacije.
# U RStudiu: otvorite fajl, pa kliknite dugme "Source" (gore desno).
# ─────────────────────────────────────────────────────────────────────────────

cat("Instalacija paketa za TDI/EMCDDA aplikaciju...\n\n")

paketi <- c(
  "shiny",
  "bslib",
  "dplyr",
  "tidyverse",
  "readxl",
  "openxlsx",
  "lubridate",
  "epikit",
  "DT",
  "future",
  "promises"
)

instalirani    <- rownames(installed.packages())
za_instalaciju <- paketi[!paketi %in% instalirani]

if (length(za_instalaciju) == 0) {
  cat("✓ Svi paketi su vec instalirani. Mozete pokrenuti aplikaciju.\n")
} else {
  cat("Instaliram:", paste(za_instalaciju, collapse = ", "), "\n\n")
  install.packages(za_instalaciju, repos = "https://cloud.r-project.org")
  cat("\n✓ Instalacija zavrsena.\n")
}

cat("\nProvera verzija:\n")
for (p in paketi) {
  v <- tryCatch(as.character(packageVersion(p)), error = function(e) "NIJE INSTALIRAN")
  cat(sprintf("  %-12s %s\n", p, v))
}

cat("\nMozete sada pokrenuti aplikaciju pomocu pokreni_app.bat\n")
cat("ili u RStudiu: shiny::runApp('app.R')\n")

# BUT FIT - Bachelor's Thesis

SwiftUI User Interface Component for Structured User Inputs

# VUT FIT - Bakalářská práce

SwiftUI komponenta pro výběr strukturovaného vstupu od uživatele na platformě iOS

**Autor:** [Šimon Strýček](https://github.com/IanNobody) <<xstryc06@stud.fit.vutbr.cz>>

**Vedoucí práce:** [Ing. Martin Hrubý Ph.D.](https://www.fit.vut.cz/person/hrubym/teaching) (UITS FIT VUT)

**Zadání:**

1) Prostudujte programování aplikací pro platformu iOS/macOS. Prostudujte koncepci komponent pro výběr hodnoty uživatelem (picker, slider apod). Zaměřte se na komponenty pro výběr číselné hodnoty z daného intervalu.
2) Navrhněte komponentu pro efektivní a komfortní uživatelský vstup založený na komponentě slider (lineární posuv po zadané škále, kombinace výběrové škály v jednom a dvou dimenzích). Zaměřte se na přesnost zadání hodnoty (např. dynamickou rekonfigurací měřítka škály). Předpokládá se kreativita v návrhu koncepce UI.
3) Implementujte komponentu ve SwiftUI. Zaměřte se na robustní návrh API (datasource, delegate, konfigurace vizuální stránky komponenty).
4) Demonstrujte komponentu v několika aplikacích, přinejmenším v aplikaci pro přehrávání videa, kde slider slouží pro přesné posouvání ve videu.

 
**Kategorie:** Uživatelská rozhraní

## Použití balíčku

V následujících bodech bude popsán způsob použití balíčku ve vlastním projektu.
Sám balíček nabízí dvě komponenty, a to pro výběr jednorozměrných hodnot (`PreciseSlider`) a pro výběr dvourozměrných hodnot (`PreciseSlider2D`).

**Požadavky:**
- Vývojové prostředí XCode
- iOS 15.0 / macOS 12.0

### Import balíčku

Import balíčku je možný pomocí nabídky `Package Manager`, kterou je možné nalézt ve vývojovém prostředí XCode volbou `File > Add Packages....`
Zde je nejprve potřeba do pole v pravém horním rohu zadat [adresu URL](https://github.com/IanNobody/SwiftUI-sliders) veřejného repozitáře balíčku.
Po zadání adresy následně vybrat parametry pro specifikaci verze, konkrétního bodu, či větve repozitáře a cílový projekt pro import balíčku.
Po zvolení parametrů pak stačí pouze výběr potvrdit, přičemž se provede stažení.
Následně lze využít tento balíček v kódu.

![Ukázka nabídky Package Manager.](https://github.com/IanNobody/SwiftUI-sliders/blob/main/doc/import.png?raw=true)

Využití obou komponent je možné v implementační části provést po importu v konkrétním souboru ve formátu `import <nazev_komponenty>`.
Implementace obou komponent obsahuje rozhraní pro použití v aplikacích jak za použití technologie SwiftUI, tak i UIKit. 
Příklad jejich použití je možné nalézt v demonstračních projektech v adresáři [Examples](https://github.com/IanNobody/SwiftUI-sliders/tree/main/Examples).

Spuštění demonstračních projektů je možné otevřením konkrétního projektu ve vývojovém prostředí XCode a spuštění klávesovou zkratkou `Command+R`, případně volbou `Product > Run`.



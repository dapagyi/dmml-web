#set document(
  author: "Apagyi Dávid",
  title: "DMML 12. gyakorlat",
  date: datetime(year: 2025, month: 12, day: 11, hour: 10, minute: 10, second: 0),
)
#set page(
  paper: "a4",
  number-align: center,
  // numbering: "— 1/1 —",
  numbering: "— 1 —",
)
#set text(lang: "hu")

#let qs(body) = {
  set enum(numbering: "(a)")
  set par(justify: true)
  block(body, breakable: false)
  // body
  v(0.5em)
}
#let pt(body) = {
  body
}
#show math.equation.where(block: true): eq => {
  block(width: 100%, inset: (top: 0em, bottom: 0.5em), align(center, eq))
}

#align(center)[
  *DMML*\ 12. gyakorlat  (2025. december 11.)#footnote([
    #link("https://apagyidavid.web.elte.hu/2025-2026-1/dmml")[#raw("https://apagyidavid.web.elte.hu/2025-2026-1/dmml")]
  ])\ _Gyakorlás vizsgára_
  #v(1em)
]

Minden feladat négy állításból áll, amelyek közül vagy pontosan egy igaz, vagy pontosan egy hamis. A feladat annak eldöntése, hogy melyik állítás igazságértéke tér el a többitől.

+ #qs[
    A VC-dimenzió...
    + #pt[mindig pozitív egész szám.]
    + #pt[lehet negatív.]
    + #pt[alsó korlát abban az értelemben, hogy ha egy $cal(F)$ klasszifikátorosztályra $dim_"VC" (cal(F))=d$, akkor az alaphalmaz minden legalább $d$ méretű $A$ részhalmazának minden címkézéséhez létezik egy $cal(F)$-beli klasszifikátor, amely helyesen osztályozza az $A$-beli pontokat.]
    + #pt[alsó korlát abban az értelemben, hogy ha egy $cal(F)$ klasszifikátorosztályra $dim_"VC" (cal(F))=d$, akkor létezik az alaphalmaznak olyan $d$ méretű $A$ részhalmaza, amelynek minden címkézéséhez létezik olyan $cal(F)$-beli klasszifikátor, amely helyesen osztályozza az $A$-beli pontokat.]
  ]
+ #qs[
    Bináris klasszifikáció esetén...
    + #pt[az _$F_1$-score_ mindig legalább annyi, mint a _precision_ és a _recall_ számtani közepe.]
    + #pt[az _$F_1$-score_ mindig legfeljebb annyi, mint a _precision_ és a _recall_ számtani közepe.]
    + #pt[az _accuracy_ mindig egyenlő a _precision_ és a _recall_ mértani közepével.]
    + #pt[az _accuracy_ mindig egyenlő a _precision_ és a _recall_ négyzetes közepével.]
  ]
+ #qs[
    A ridge regresszióval meghatározott $hat(theta)_lambda$ paramétervektor...
    + #pt[torzítatlan becslése a valódi $theta$ paramétervektornak, és kisebb a kovarianciája (Löwner értelemben és mátrixelemenként is), mint az LS becslésnek.]
    + #pt[torzítatlan becslése (...), de nagyobb a kovarianciája (...).]
    + #pt[nem torzítatlan becslése (...), de kisebb a kovarianciája (...).]
    + #pt[nem torzítatlan becslése (...), és nagyobb a kovarianciája (...).]
  ]
+ #qs[
    RKHS esetén az $cal(X)$ alaptér pontjaira definiált (kiértékelő) funkcionálok...
    + #pt[által meghatározott kernel mindig bilineáris függvény.]
    + #pt[által meghatározott kernel mindig pozitív szemidefinit.]
    + #pt[mindig korlátosak.]
    + #pt[mindig folytonosak.]
  ]
+ #qs[
    A reprezentációs tételben...
    + #pt[szereplő regularizált veszteségfüggvényben az $Omega(||f||_cal(H))$ regularizációs tag tetszőleges függvénye az $||f||_cal(H)$ kernel normának.]
    + #pt[szereplő (regularizációs tag nélküli) veszteségfüggvény mindig az RMSE.]
    + #pt[a megoldás, ha létezik, előáll véges sok "bázisfüggvény" lineáris kombinációjaként.]
    + #pt[szereplő kernel Gram-mátrixa minden $n$-re és minden különböző $x in cal(X)^n$ inputra pozitív szemidefinit mátrix, de nem feltétlenül (szigorúan) pozitív definit.]
  ]
+ #qs[
    + #pt[Az RKHS meghatároz egy szimmetrikus, pozitív definit kernelt.]
    + #pt[Egy szimmetrikus, pozitív definit kernel egyértelműen meghatároz egy RKHS-t.]
    + #pt[Egy RKHS kernelére minden $z in cal(X)$ és $f in cal(H)$ esetén teljesül az, hogy $chevron.l k_z, f chevron.r_cal(H) = f(z)$, ahol $k_z (dot.c) = k(dot.c, z)$ a kernel $z$ szerinti kiértékelése.]
    + #pt[Egy RKHS-ben egy $f$ függvény két tetszőleges pontban való kiértékelésének $|f(x) - f(x')|$ különbségét felülről becsüli az $||f||_cal(H)$ kernel norma.]
  ]
+ #qs[
    + #pt[A regularizáció segíthet csökkenteni a túltanulás (_overfitting_) mértékét.]
    + #pt[A regularizáció segíthet a megoldás alakját befolyásolni, egyszerűsíteni.]
    + #pt[A regularizált veszteségfüggvény használata "növeli" (nem csökkenti) a tanító adathalmazon mért (regularizáció nélküli) hibát a regularizáció nélkülihez képest.]
    + #pt[A LAD feladat visszavezethető az OLS feladatra.]
  ]
+ #qs[
    + #pt[Az OLS feladat megoldása meghatározható a regressziós mátrix pszeudoinverzével.]
    + #pt[Csak teljesrangú mátrixoknak létezik pszeudoinverze.]
    + #pt[Valós mátrix és pszeudoinverzének szorzata mindig szimmetrikus mátrix.]
    + #pt[Egy mátrix pszeudoinverze meghatározható az SVD-felbontás segítségével.]
  ]
+ #qs[
    A VC-dimenzió...
    + #pt[(azonos alaphalmaz felett) kevesebb paraméterrel rendelkező klasszifikátorosztályok esetén mindig szigorúan kisebb.]
    + #pt[monoton halmazfüggvény, azaz $cal(H)_1 subset.eq cal(H)_2$ halmazrendszerek esetén teljesül, hogy $dim_"VC" (cal(H)_1) <= dim_"VC" (cal(H)_2)$.]
    + #pt[az $cal(X)=RR^d$ alaphalmaz felett lineáris klasszifikátorokra éppen $d+1$.]
    + #pt[véges halmazrendszerre mindig véges.]
  ]
+ #qs[
    + #pt[A $k$-közép (_$k$-means_) algoritmus nem mindig talál globális optimumot.]
    + #pt[Egy ponthalmaz hierarchikus klaszterezése megfelel a ponthalmaz felett egy lamináris halmazrendszernek.]
    + #pt[A DBSCAN algoritmusban, ha a $p$ pont közvetlenül elérhető a $q$ pontból, akkor a $q$ pont is közvetlenül elérhető a $p$ pontból.]
    + #pt[Az OPTICS algoritmussal meghatározott klaszterek egy-egy összefüggő résznek felelnek meg az elérhetőségi diagramon (_reachability plot_).]
  ]
+ #qs[
    + #pt[A $k$-közép (_$k$-means_) algoritmus a klaszterközéppontok közötti távolságok négyzetösszegének maximalizálására törekszik.]
    + #pt[A DBSCAN algoritmus használható anomáliakeresésre.]
    + #pt[Az OPTICS algoritmus kimenete egy klaszterezés.]
    + #pt[A Kleinberg-tételben szereplő konzisztencia azt jelenti, hogy az algoritmus csak determinisztikus lépéseket végezhet, tehát egy adott bemenetre minden futtatáskor ugyanazt a kimenetet adja.]
  ]
+ #qs[A véletlen erdő (_random forest_) algoritmus...
    + #pt[az egyes döntési fák tanításához visszatevés nélkül mintavételez az eredeti adathalmazból.]
    + #pt[újabb és újabb döntési fákkal sorban egymás után bővíti a modellt, mindegyikkel az eddig felépített modell tévesztéseinek kijavítására törekedve.]
    + #pt[a vágásokhoz döntési fánként rögzített valódi részhalmazát használja csak a jellemzőknek.]
    + #pt[jól párhuzamosítható.]
  ]

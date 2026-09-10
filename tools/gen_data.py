#!/usr/bin/env python3
"""Generates the VITA game data (.tres files) from the design documents.

Run from the project root:  python3 tools/gen_data.py
Outputs: src/resources/data/{values,characters,scenarios}/*.tres, game_config.tres, game_catalog.tres
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "src/resources/data"

S, I, V, E = "selbststaendigkeit", "sicherheit", "verbundenheit", "entlastung"
TALK, SMS, CALL, EMAIL = 0, 1, 2, 3


def esc(s: str) -> str:
    return s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")


def unquote(s: str) -> str:
    """Spoken text and answers are shown without German quotation marks (design feedback)."""
    return s.replace("\u201e", "").replace("\u201c", "").strip()


# ----------------------------------------------------------------------------- values
VALUES = [
    {
        "id": S, "name": "Selbstständigkeit", "color": "Color(0.165, 0.616, 0.561, 1)",
        "focus": "Eigene Entscheidungen treffen, digitale Dinge verstehen und möglichst selbst handhaben.",
        "tiers": [
            (0, 0, "Stark auf andere angewiesen", "Viele digitale Aufgaben und Entscheidungen überlässt du anderen. Das kann vieles erleichtern, bedeutet aber auch, dass du häufiger darauf angewiesen bist, dass jemand Zeit hat und für dich übernimmt."),
            (1, 3, "Viel Unterstützung", "Du lässt dir bei digitalen Dingen häufig helfen und gibst manche Aufgaben gerne ab. Das kann entlasten, aber manchmal fehlt dir dadurch der Überblick darüber, was genau gemacht oder entschieden wurde."),
            (4, 6, "Selbstbestimmt mit Unterstützung", "Du entscheidest selbst, was du alleine machen möchtest und wo Unterstützung hilfreich ist. Hilfe anzunehmen bedeutet für dich nicht automatisch, die Kontrolle abzugeben."),
            (7, 9, "Sehr eigenständig", "Du möchtest digitale Dinge möglichst selbst verstehen, prüfen und erledigen. Das gibt dir viel Kontrolle und Unabhängigkeit, kann aber manchmal zusätzlichen Aufwand bedeuten."),
            (10, 10, "Alles selbst im Blick", "Du möchtest sehr viel selbst verstehen und entscheiden. Dadurch behältst du die Kontrolle, nutzt Unterstützung oder Vereinfachungen aber möglicherweise seltener, auch wenn sie dir in manchen Situationen guttun könnten."),
        ],
    },
    {
        "id": I, "name": "Sicherheit", "color": "Color(0.239, 0.353, 0.600, 1)",
        "focus": "Daten, Geld, Geräte und die eigene Person schützen, Risiken erkennen und überprüfen.",
        "tiers": [
            (0, 0, "Sehr risikobereit", "Du handelst häufig schnell und vertraust darauf, dass schon alles stimmen wird. Das ist unkompliziert, kann dich aber anfälliger für Betrug, Datenverlust oder andere unerwünschte Folgen machen."),
            (1, 3, "Eher unbeschwert", "Du hinterfragst ungewöhnliche Nachrichten, Angebote oder Einstellungen nicht immer. Oft spart das Zeit, bei manchen Situationen wäre ein zweiter Blick aber hilfreich."),
            (4, 6, "Wachsam mit Augenmaß", "Du prüfst genauer, wenn es einen guten Grund dafür gibt, ohne digitale Angebote grundsätzlich abzulehnen. Sicherheit ist für dich wichtig, aber nicht das einzige Kriterium."),
            (7, 9, "Sehr vorsichtig", "Du überprüfst Kontakte, Datenfreigaben und ungewöhnliche Situationen sorgfältig. Das schützt dich vor vielen Risiken, macht manches aber auch langsamer oder aufwendiger."),
            (10, 10, "Sicherheit hat Vorrang", "Du entscheidest fast immer zugunsten der sichereren Variante. Das schützt dich sehr konsequent, kann aber bedeuten, dass Komfort, spontane Kontakte oder hilfreiche digitale Angebote häufiger zurückstecken."),
        ],
    },
    {
        "id": V, "name": "Verbundenheit", "color": "Color(0.906, 0.435, 0.318, 1)",
        "focus": "Kontakt zu Familie, Freunden, Nachbarschaft und Gesellschaft – digital und persönlich.",
        "tiers": [
            (0, 0, "Viel für dich allein", "Du bindest andere nur selten ein und nutzt Möglichkeiten zum Austausch eher wenig. Das gibt dir viel Privatsphäre und eigenen Raum, kann aber Unterstützung und gemeinsame Erlebnisse erschweren."),
            (1, 3, "Eher zurückhaltend verbunden", "Du hältst deine Kontakte eher überschaubar und regelst vieles für dich. Dadurch bestimmst du selbst, wie viel andere mitbekommen, nutzt aber manche Möglichkeiten für Austausch und Unterstützung weniger."),
            (4, 6, "Gut verbunden", "Du nutzt persönliche und digitale Kontakte dort, wo sie dir guttun. Gleichzeitig entscheidest du bewusst, was du teilen möchtest und wann du Dinge lieber selbst regelst."),
            (7, 9, "Stark verbunden", "Familie, Freunde, Nachbarschaft und andere Kontakte spielen in deinem Alltag eine wichtige Rolle. Das schafft Nähe und Unterstützung, bedeutet aber auch, dass andere häufiger Einblick bekommen oder beteiligt sind."),
            (10, 10, "Sehr eng eingebunden", "Du beziehst andere sehr häufig ein und nutzt viele Möglichkeiten, miteinander verbunden zu bleiben. Das kann viel Unterstützung und Nähe schaffen, lässt dir aber manchmal weniger Privatsphäre oder eigenen Entscheidungsspielraum."),
        ],
    },
    {
        "id": E, "name": "Entlastung", "color": "Color(0.859, 0.612, 0.192, 1)",
        "focus": "Aufwand reduzieren, digitale Hilfen sinnvoll nutzen und Aufgaben so organisieren, dass sie für dich und dein Umfeld gut machbar bleiben.",
        "tiers": [
            (0, 0, "Viel Aufwand", "Viele Aufgaben erledigst du auf eher aufwendige Weise oder ohne zusätzliche Hilfen. Das kann dir Kontrolle geben, kostet dich und manchmal auch dein Umfeld jedoch viel Zeit und Energie."),
            (1, 3, "Eher aufwendig organisiert", "Du nutzt digitale Erleichterungen, Automatisierung oder Unterstützung eher zurückhaltend. Dadurch bleibt vieles vertraut, manches könnte aber einfacher oder weniger zeitintensiv sein."),
            (4, 6, "Gut entlastet", "Du nutzt Hilfen dort, wo sie dir wirklich etwas bringen. Dabei achtest du darauf, nicht mehr Verantwortung abzugeben, als du möchtest, und Belastung nicht einfach auf andere zu verschieben."),
            (7, 9, "Stark entlastet", "Viele Abläufe sind für dich bequem organisiert oder werden durch Technik und andere Menschen unterstützt. Das spart Zeit und Kraft, kann aber auch mehr Abhängigkeit oder weniger eigenen Überblick bedeuten."),
            (10, 10, "Möglichst viel abgenommen", "Viele Aufgaben werden vereinfacht, automatisiert oder von anderen übernommen. Das kann deinen Alltag deutlich erleichtern, kann aber auch dazu führen, dass du weniger selbst steuerst oder Angehörige dauerhaft Verantwortung übernehmen."),
        ],
    },
]

# ----------------------------------------------------------------------------- characters
CHARACTERS = [
    dict(id="silke", name="Silke", tagline="Die besorgte Tochter", age="ca. Mitte 50", role="Tochter der spielenden Person", formal=False,
         accent="Color(0.557, 0.361, 0.541, 1)",
         desc="Silke möchte ihre Eltern schützen und ihnen das Leben erleichtern. Sie ist grundsätzlich digital fit, arbeitet noch und hat deshalb oft wenig Zeit. Wenn etwas nicht funktioniert, übernimmt sie schnell selbst.",
         strengths="Sie erkennt viele Risiken, kennt gängige digitale Anwendungen und hilft schnell und zuverlässig.",
         weaknesses="Sie ist manchmal paternalistisch und unterschätzt, was ihre Eltern selbst können oder lernen könnten. Außerdem kennt auch sie nicht jede neue Betrugsmasche."),
    dict(id="gerhard", name="Gerhard", tagline="Der technikaffine Ehepartner", age="Seniorenalter", role="Ehepartner bzw. enger Begleiter", formal=False,
         accent="Color(0.435, 0.561, 0.353, 1)",
         desc="Gerhard interessiert sich für neue Technik und probiert gern selbst Dinge aus. Er liest Anleitungen, klickt sich durch Einstellungen und ist stolz darauf, nicht ständig Hilfe zu benötigen.",
         strengths="Neugierig, selbstständig, lernbereit und nicht technikängstlich.",
         weaknesses="Er überschätzt manchmal seine Fähigkeiten und ist gelegentlich zu gutgläubig. Wenn etwas schiefgeht, bittet er ungern um Hilfe."),
    dict(id="noah", name="Noah", tagline="Der klugscheißende Enkel", age="ca. Anfang 20", role="Enkel", formal=False,
         accent="Color(0.227, 0.525, 1, 1)",
         desc="Noah ist mit Smartphones, Apps und sozialen Medien aufgewachsen. Für ihn sind viele Dinge selbstverständlich. Er meint es gut, erklärt aber oft zu schnell und benutzt Begriffe, die für andere nicht selbstverständlich sind.",
         strengths="Kennt viele digitale Möglichkeiten und findet schnell Lösungen.",
         weaknesses="Er verwechselt Bedienkompetenz manchmal mit echter Medienkompetenz. Datenschutz, Betrug oder langfristige Konsequenzen nimmt er teilweise weniger ernst."),
    dict(id="jana", name="Jana", tagline="Die VITA-Begleitung", age="ca. Anfang 40", role="Professionelle Alltagsbegleitung", formal=True,
         accent="Color(0.165, 0.616, 0.561, 1)",
         desc="Jana unterstützt ältere Menschen bei organisatorischen und alltäglichen Aufgaben, zum Beispiel Arzttermine, Einkäufe, Behördengänge oder die Nutzung digitaler Angebote. Sie möchte ihre Klienten möglichst selbstständig halten und erklärt Dinge geduldig.",
         strengths="Sie kennt viele praktische digitale Lösungen, kann gut unterstützen und achtet darauf, nicht unnötig zu bevormunden.",
         weaknesses="Im Arbeitsalltag steht sie manchmal unter Zeitdruck. Dann ist es verlockend, etwas schnell selbst zu erledigen. Außerdem ist sie keine IT- oder Sicherheitsexpertin."),
    dict(id="michael", name="Michael Müller", tagline="Der Postbote", age="ca. Mitte 40", role="Vertrauter Paket- und Briefzusteller", formal=True,
         accent="Color(0.949, 0.718, 0.020, 1)",
         desc="Michael kennt viele Menschen in der Gegend und ist freundlich und hilfsbereit. Er bringt Pakete, erklärt Abholscheine oder hilft gelegentlich bei Fragen zur Packstation.",
         strengths="Vertrauenswürdig, alltagsnah und nah an der Schnittstelle zwischen analoger und digitaler Welt.",
         weaknesses="Er kennt die digitalen Systeme seines Arbeitgebers aus der Praxis, aber nicht jede technische oder sicherheitsrelevante Besonderheit."),
    dict(id="cem", name="Cem Yilmaz", tagline="Der Polizist", age="ca. Mitte 40", role="Polizeibeamter im örtlichen Revier", formal=True,
         accent="Color(0.122, 0.227, 0.373, 1)",
         desc="Cem arbeitet schon lange bei der Polizei und hat im Berufsalltag regelmäßig mit Betrugsfällen zu tun. Er ist ruhig, sachlich und nimmt Sorgen ernst, ohne gleich hinter jeder ungewöhnlichen Situation eine Straftat zu vermuten.",
         strengths="Er kennt typische Vorgehensweisen von Betrügern und weiß, welche Schritte im Verdachtsfall sinnvoll sind.",
         weaknesses="Er ist kein Digitalexperte und kennt nicht jede neue App. Manchmal denkt er stärker in klassischen Sicherheitskategorien als in Fragen von Komfort oder digitaler Teilhabe."),
    dict(id="hildegard", name="Hildegard", tagline="Die übervorsichtige Freundin", age="Seniorenalter", role="Freundin der spielenden Person", formal=False,
         accent="Color(0.788, 0.482, 0.518, 1)",
         desc="Hildegard ist überzeugt, dass man im Internet sehr vorsichtig sein muss. Sie liest viel über Betrugsfälle und warnt ihre Freunde regelmäßig.",
         strengths="Hinterfragt Dinge und lässt sich schwer unter Druck setzen.",
         weaknesses="Sie überschätzt Risiken und verzichtet manchmal auf hilfreiche digitale Angebote."),
    dict(id="linh", name="Linh Nguyen", tagline="Die Bankmitarbeiterin", age="ca. Anfang 30", role="Langjährige Mitarbeiterin der örtlichen Bank", formal=True,
         accent="Color(0.184, 0.420, 0.310, 1)",
         desc="Linh kennt viele Kundinnen und Kunden persönlich. Sie möchte sichere Bankgeschäfte fördern und erklärt auch Online-Banking, Kartenzahlung und TAN-Verfahren.",
         strengths="Gute Kenntnisse rund um Bankgeschäfte und typische Bankbetrugsmaschen.",
         weaknesses="Für sie sind manche Prozesse Routine. Dadurch erklärt sie manchmal zu schnell oder unterschätzt, wie verwirrend digitale Bankverfahren wirken können."),
]

# ----------------------------------------------------------------------------- scenarios
# (id, character, title, channel, body, a_label, a_outcome, a_delta, b_label, b_outcome, b_delta, follows)
SC = []


def sc(cid, n, title, body, a, ao, ad, b, bo, bd, channel=TALK, follows="", sender=""):
    SC.append((f"{cid}_{n:02d}", cid, title, channel, body, a, ao, ad, b, bo, bd, follows, sender))


# --- Silke
sc("silke", 1, "Die Sensoren",
   "„Nach deinem Beinahe-Sturz mache ich mir echt Sorgen. Es gibt Sensoren für die Wohnung, die merken können, wenn etwas passiert. Dann könnte automatisch jemand informiert werden. Ich würde mich besser fühlen, wenn wir sowas einrichten. Was meinst du?“",
   "„Okay, lass uns so ein System einrichten.“",
   "Die Sensoren geben Silke mehr Sicherheit und können im Notfall Hilfe auslösen. Gleichzeitig werden nun Informationen darüber erfasst, was in der Wohnung passiert.",
   {I: 1, V: 1, S: -1},
   "„Lass uns erst schauen, ob es weniger eingreifende Lösungen gibt.“",
   "Ihr prüft zunächst Beleuchtung, Stolperstellen und Haltegriffe. Das senkt einige Risiken, ohne dass die Wohnung technisch überwacht wird.",
   {S: 1, I: 1, E: -1})
sc("silke", 2, "Der Fehlalarm",
   "„Das Hausnotrufsystem hat mich heute Nacht schon wieder alarmiert und ich bin völlig umsonst aufgeschreckt. So bringt das doch nichts. Sollen wir das Ding nicht einfach wieder abschalten?“",
   "„Lass uns erst prüfen, warum die Fehlalarme kommen.“",
   "Die Empfindlichkeit des Sensors wird angepasst und die Alarmkette neu eingestellt. Das kostet Zeit, danach funktioniert das System zuverlässiger.",
   {I: 1, E: -1},
   "„Ja, wenn es ständig Fehlalarme gibt, schalten wir ihn ab.“",
   "Die Fehlalarme hören auf. Damit fällt aber auch die zusätzliche Absicherung weg.",
   {E: 1, I: -1})
sc("silke", 3, "Die neue Nummer",
   "„Hallo, ich bin’s. Mein Handy ist kaputt, das ist meine neue Handynummer. Kannst du die bitte speichern? Ich muss dich gleich noch um etwas bitten.“",
   "„Ich rufe Silke erst über ihre bekannte Nummer an.“",
   "Silke meldet sich ganz normal und weiß von nichts. Die Nachricht kam von Betrügern, die Nähe und Zeitdruck genutzt haben, um Vertrauen aufzubauen.",
   {I: 1, S: 1, E: -1},
   "„Klar, ich speichere die Nummer.“",
   "Kurz darauf bittet „Silke“ dringend um eine Überweisung und darum, niemandem etwas zu sagen. Die vertraute Ansprache, neue Nummer, Zeitdruck und Geheimhaltung waren Warnzeichen.",
   {V: 1, I: -2}, channel=SMS)
sc("silke", 4, "Unterstützung bei der virtuellen Sprechstunde",
   "„Wenn du möchtest, setze ich mich bei der Videosprechstunde mit der Ärztin einfach daneben. Dann kann ich erklären, wenn irgendwas mit der Technik nicht klappt – und vielleicht fällt mir auch noch etwas ein, was du der Ärztin sagen solltest.“",
   "„Ja, bleib beim Gespräch dabei.“",
   "Silke kann bei technischen Problemen helfen und fühlt sich einbezogen. Gleichzeitig übernimmt sie im Gespräch schnell das Wort.",
   {V: 1, S: -1},
   "„Hilf mir beim Einrichten, aber das Gespräch möchte ich allein führen.“",
   "Silke hilft beim Start der Videosprechstunde und lässt dich danach allein mit der Ärztin sprechen. Du entscheidest selbst, was du besprechen möchtest.",
   {S: 1, V: -1})
sc("silke", 5, "Zugriff auf die Patientenakte",
   "„Wenn du möchtest, kann ich dir bei der Patientenakte helfen. Gib mir einfach dein Passwort, dann kann ich nachsehen, wenn du mal nicht weiterkommst.“",
   "„Lass uns lieber schauen, ob es eine offizielle Möglichkeit gibt, dich zu bevollmächtigen.“",
   "Ihr nutzt eine vorgesehene Vertretungs- oder Unterstützungsfunktion. Silke kann helfen, ohne dass du dein persönliches Passwort weitergeben musst.",
   {I: 1, S: 1, E: -1},
   "„Okay, dann hast du meine Zugangsdaten.“",
   "Silke kann schnell helfen, hat damit aber auch Zugang zu sehr persönlichen Gesundheitsdaten und kann in deinem Namen auf das Konto zugreifen.",
   {E: 1, V: 1, I: -1})
sc("silke", 6, "Alle Meldungen mitbekommen",
   "„Die App könnte mir auch eine Nachricht schicken, wenn du eine Einnahme nicht bestätigst. Dann könnte ich dich erinnern, falls du mal etwas vergisst. Wollen wir das einschalten?“",
   "„Ja, dann bekommst du alle Meldungen.“",
   "Silke kann schnell reagieren, wenn eine Einnahme ausbleibt. Dafür weiß sie nun sehr genau, wann du deine Medikamente einnimmst oder eine Erinnerung verpasst.",
   {I: 1, V: 1, S: -1},
   "„Ich möchte erst festlegen, wann du informiert wirst.“",
   "Ihr stellt gemeinsam ein, dass Silke nur bei bestimmten Situationen benachrichtigt wird. Du behältst mehr Kontrolle darüber, welche Informationen sie bekommt.",
   {S: 1, V: 1, E: -1})
sc("silke", 7, "Alles in eine Mappe?",
   "„Ich hab mir gedacht, falls mal wirklich was ist, sollten wir deine wichtigen Unterlagen und Zugänge schnell finden. Wir könnten einfach alles in eine Mappe legen – Vollmachten, Verträge und auch die Passwörter. Dann weiß jeder sofort, wo er suchen muss. Was meinst du?“",
   "„Die Unterlagen ja, aber die Zugangsdaten würde ich getrennt schützen.“",
   "Die wichtigen Dokumente sind gut auffindbar, während Passwörter und andere sensible Zugänge separat geschützt bleiben. Im Notfall braucht es deshalb einen klaren Plan, wie eine Vertrauensperson an die nötigen Zugänge kommt.",
   {I: 1, E: -1},
   "„Ja, dann ist wenigstens alles an einem Ort.“",
   "Im Notfall wäre vieles schnell auffindbar. Gleichzeitig lägen sensible Dokumente und Zugangsdaten ungeschützt zusammen – wer die Mappe findet, hätte sehr viel auf einmal.",
   {E: 1, I: -1})
sc("silke", 8, "Der Schockanruf",
   "Anruf von einer unterdrückten Nummer: „Mama/Papa? Bitte erschrick nicht … ich hatte einen Unfall. Mir geht’s nicht gut und ich kann gerade kaum reden. Gleich erklärt dir jemand, was passiert ist. Bitte hilf mir einfach.“\nEine andere Stimme übernimmt: „Hier ist die Polizei. Ihre Tochter hat einen schweren Unfall verursacht. Damit sie jetzt nach Hause kann, muss kurzfristig eine größere Summe als Kaution hinterlegt werden. Jemand könnte das Geld bei Ihnen abholen.“",
   "„Wenn Silke mich braucht, bereite ich das Geld vor.“",
   "Silke hatte keinen Unfall. Die Betrüger haben eine künstlich erzeugte Stimme benutzt, die wie Silke klang. Mit KI können heute schon kurze Sprachaufnahmen ausreichen, um Stimmen täuschend ähnlich nachzubilden. Mit dem erfundenen Szenario wollen die Täter dich unter Schock setzen, um so an dein Geld zu kommen.",
   {V: 1, I: -2},
   "„Ich lege auf und rufe Silke selbst an.“",
   "Die echte Silke geht ans Telefon und weiß von nichts. Die Stimme im ersten Anruf war nachgeahmt, um dich unter Schock zu setzen und an dein Geld zu kommen. Gerade weil KI Stimmen sehr überzeugend imitieren kann, ist ein Rückruf über eine bekannte Nummer oder ein anderer unabhängiger Kontaktweg besonders hilfreich.",
   {I: 1, S: 1, E: -1}, channel=CALL, sender="Anruf von einer unterdrückten Nummer")

# --- Gerhard
sc("gerhard", 1, "Der verdächtige Anhang",
   "„Walter aus dem Kleingartenverein hat mir eine Mail geschickt. Im Anhang soll die neue Teilnehmerliste sein. Komisch nur, gestern hat er davon gar nichts gesagt. Soll ich die Datei öffnen?“",
   "„Ruf Walter kurz an und frag nach.“",
   "Walter ist überrascht: Er hat die Mail gar nicht geschickt. Gemeinsam warnt ihr die anderen Vereinsmitglieder.",
   {I: 1, V: 1, E: -1},
   "„Du kennst Walter, öffne sie ruhig.“",
   "Walters E-Mail-Konto wurde gehackt. Der Anhang enthält Schadsoftware und Gerhard muss seinen Rechner anschließend überprüfen lassen.",
   {E: 1, I: -2})
sc("gerhard", 2, "Passwortchaos",
   "„Ich kann mir diese ganzen Passwörter einfach nicht merken. Ich hab mir überlegt, für die unwichtigen Sachen überall dasselbe zu nehmen. Das wäre doch viel einfacher, oder?“",
   "„Für unwichtige Konten kannst du das ruhig machen.“",
   "Gerhard muss sich deutlich weniger merken. Als später ein Dienst gehackt wird, ist dasselbe Passwort allerdings auch bei anderen Konten gefährdet.",
   {E: 1, I: -1},
   "„Nimm lieber unterschiedliche Passwörter und such dir eine Lösung zum Verwalten.“",
   "Die Einrichtung kostet Gerhard zunächst Zeit, danach findet er seine Zugangsdaten aber zuverlässig wieder.",
   {I: 1, E: -1})
sc("gerhard", 3, "Das Schnäppchen",
   "„Schau mal, ich hab online eine Küchenmaschine gefunden, die sonst fast 500 Euro kostet. Hier gibt’s die für 179 Euro. Aber das Angebot läuft angeblich nur noch zehn Minuten. Eigentlich wär das schon ein super Preis. Was meinst du?“",
   "„Schau dir den Shop und den Preis lieber erst genauer an.“",
   "Gerhard vergleicht den Preis, prüft den Anbieter und findet mehrere Warnzeichen: ungewöhnlich günstiger Preis, künstlicher Zeitdruck und kaum verlässliche Informationen zum Shop. Er lässt das Angebot aus.",
   {I: 1, E: -1},
   "„Wenn du sie sowieso willst, bestell lieber gleich.“",
   "Gerhard bestellt unter Zeitdruck. Später stellt sich heraus, dass der Shop nicht seriös war. Der extrem niedrige Preis und der Countdown waren Warnzeichen, die zum schnellen Kauf drängen sollten.",
   {I: -2})
sc("gerhard", 4, "Handy heruntergefallen",
   "„Mein Handy ist mir runtergefallen. Es geht noch, aber der Bildschirm flackert. Da sind fast alle Familienfotos und meine Kontakte drauf. Ich könnte es noch ein bisschen weiterbenutzen oder mich jetzt endlich um eine Sicherung kümmern. Was meinst du?“",
   "„Solange es noch geht, nutz es erst mal weiter.“",
   "Gerhard schiebt die Sicherung auf. Kurz darauf fällt das Display ganz aus und einige Daten lassen sich nur mit Aufwand wiederherstellen. Das Warnzeichen war nicht der Sturz allein, sondern dass wichtige Daten nur an einem Ort gespeichert waren.",
   {E: 1, I: -2},
   "„Richte lieber jetzt eine Sicherung ein.“",
   "Gerhard sichert Fotos und Kontakte, bevor das Handy endgültig ausfällt. Danach weiß er auch, wo seine Daten liegen und wie er sie wiederbekommt.",
   {I: 1, V: 1, E: -1})
sc("gerhard", 5, "Die Bewegungs-App",
   "„Ich hab mir so eine Bewegungs-App eingerichtet. Die setzt mir jeden Tag ein Ziel und heute meint sie, ich könnte noch ein bisschen mehr machen. Nach den Übungen tut mir aber das Knie deutlich mehr weh als sonst. Was meinst du – noch fertig machen oder für heute Schluss?“",
   "„Mach das Ziel noch voll.“",
   "Gerhard zieht die Einheit durch. Die App kennt aber weder seine Beschwerden noch seine individuelle Belastungsgrenze – ein höheres Tagesziel ist nicht automatisch sinnvoll.",
   {S: 1, I: -2},
   "„Für heute reicht es, hör lieber auf deinen Körper.“",
   "Gerhard beendet das Training und beobachtet, wie sich die Beschwerden entwickeln. Wenn sie anhalten oder stärker werden, lässt er sie fachlich abklären.",
   {I: 1, S: 1})
sc("gerhard", 6, "Der Brief mit KI",
   "„Ich hab da was Neues ausprobiert – so eine KI. Du schreibst einfach rein, was du brauchst, und die formuliert dir Texte oder erklärt Sachen. Echt praktisch! Ich will damit jetzt einen Brief an meine Versicherung schreiben. Am einfachsten wäre es, wenn ich den alten Brief mit Namen, Versicherungsnummer und allem Drum und Dran einfach reinkopiere. Was meinst du?“",
   "„Lass persönliche Daten lieber weg und arbeite mit Platzhaltern.“",
   "Gerhard gibt nur die Informationen ein, die für den Inhalt nötig sind, und ersetzt sensible Angaben zunächst durch Platzhalter. Der Brief funktioniert trotzdem – Namen und Nummern ergänzt er erst danach selbst.",
   {I: 1, S: 1, E: -1},
   "„Ja, dann hat die KI gleich alle Informationen und kann ihn ganz präzise schreiben.“",
   "Der Brief ist schnell formuliert und Gerhard ist erstmal zufrieden. Dafür hat er viele persönliche Daten eingegeben. Wo und wie diese Daten beim KI-Anbieter verarbeitet oder gespeichert werden, ist für ihn nicht ohne Weiteres nachvollziehbar.",
   {E: 1, I: -1})
sc("gerhard", 7, "Passwörter in der Handyhülle",
   "„Ich bin bei diesen ganzen Internetseiten ja vorsichtig. Deshalb schreibe ich meine Passwörter lieber auf einen Zettel, statt sie irgendwo digital zu speichern. Den Zettel habe ich hier in der Handyhülle – dann habe ich ihn immer dabei.“",
   "„Das ist doch praktisch, dann findest du die Passwörter wenigstens immer.“",
   "Solange das Handy bei Gerhard ist, funktioniert das bequem. Geht es aber verloren oder wird gestohlen, liegen Handy und Zugangsdaten direkt zusammen – und jemand könnte mehrere Konten auf einmal ausprobieren.",
   {E: 1, I: -1},
   "„Ich würde den Zettel nicht direkt beim Handy aufbewahren.“",
   "Gerhard trennt Handy und Passwörter voneinander. Das macht den Zugriff im Alltag etwas umständlicher, verhindert aber, dass bei einem Verlust gleich beides zusammen in fremde Hände gerät.",
   {I: 1, E: -1})

# --- Noah
sc("noah", 1, "Lost in Translation",
   "„Du wolltest doch im Urlaub auch mal alleine losziehen. Wenn du dort etwas fragen musst und die Leute kein Deutsch sprechen – und du mit Englisch auch nicht weiterkommst – kannst du dein Handy zum Übersetzen nehmen. Du kannst sogar die Kamera auf Schilder oder Speisekarten halten. Soll ich dir zeigen, wie das geht?“",
   "„Ach, irgendwie werde ich mich schon verständigen, hat ja bisher auch immer geklappt.“",
   "Vieles klappt mit Gesten und freundlichem Nachfragen und du machst nette Bekanntschaften. Wenn aber weder Deutsch noch eine gemeinsame andere Sprache funktioniert, bist du stärker darauf angewiesen, dass jemand anderes weiterhelfen kann.",
   {V: 1, S: -1},
   "„Ja, zeig mir, wie ich das selbst benutzen kann.“",
   "Im Urlaub kannst du Schilder und Speisekarten übersetzen und auch einfache Gespräche unterstützen. Die Übersetzung ist nicht immer perfekt, gibt dir aber mehr Möglichkeiten, dir selbst zu helfen.",
   {S: 1, V: 1})
sc("noah", 2, "Die Supermarkt-App",
   "„Du kaufst doch ständig in dem Supermarkt ein. Die haben jetzt eine App mit extra Rabatten. Ich kann dir die schnell installieren und ein Konto anlegen, dann sparst du jedes Mal ein bisschen. Willst du?“",
   "„Zeig mir erst mal, welche Daten die App sammelt.“",
   "Noah ist etwas überrascht, wie viele Informationen verarbeitet werden können. Ihr schaut euch gemeinsam die Einstellungen an und entscheidet bewusster, was du freigibst.",
   {S: 1, I: 1, E: -1},
   "„Ja, richte mir die App ein.“",
   "Du bekommst zusätzliche Rabatte und findest die App praktisch. Dafür werden deine Einkäufe mit deinem Kundenkonto verknüpft und können für personalisierte Angebote ausgewertet werden.",
   {E: 1, I: -1})
sc("noah", 3, "Kannst du mir kurz helfen?",
   "„Hey, ich hab eine neue Nummer. Mein Handy ist kaputt und ich komme gerade an mein Online-Banking nicht ran. Könntest du mir eine Rechnung auslegen? Es ist dringend, habe Mist gebaut. Ich zahl’s dir morgen zurück.“",
   "„Klar, wenn es dringend ist.“",
   "Die Nachricht war nicht von Noah. Die neue Nummer, der Zeitdruck und die Bitte um Geld waren Teil der Masche.",
   {V: 1, I: -2},
   "„Ich frag dich erst etwas, das nur wir beide wissen.“",
   "Auf die Kontrollfrage kommt nur eine ausweichende Antwort. Es waren Fremde, die sich als Noah ausgegeben haben und Geld abgreifen wollten.",
   {I: 1, S: 1, E: -1}, channel=SMS)
sc("noah", 4, "Sicherung in der Cloud",
   "„Die ganzen Fotos von früher sind nur auf deinem Handy? Wenn das kaputtgeht, sind die weg. Ich kann dir eine Cloud einrichten. Das ist einfach ein Speicherplatz im Internet, wo deine Fotos zusätzlich gespeichert werden. Dann kannst du sie wiederbekommen, auch wenn mit dem Handy was passiert. Soll ich die automatische Sicherung einschalten?“",
   "„Ja, schalte die automatische Sicherung ein.“",
   "Deine Fotos werden künftig automatisch zusätzlich in der Cloud gespeichert. Das schützt vor Datenverlust und ist bequem. Dafür landen auch neue Bilder automatisch beim Cloud-Anbieter.",
   {E: 1, I: 1, S: -1},
   "„Ich möchte lieber selbst auswählen, welche Fotos gesichert werden.“",
   "Du behältst mehr Kontrolle darüber, welche Bilder in der Cloud gespeichert werden. Dafür musst du regelmäßig selbst daran denken, wichtige Fotos zu sichern.",
   {S: 1, I: 1, E: -1})
sc("noah", 5, "Ich hab mal die KI gefragt",
   "„Du hast doch erzählt, dass dir das Knie seit ein paar Tagen wehtut. Ich hab das gerade mal in die KI eingegeben. Die sagt, das klingt wahrscheinlich nach Überlastung und du sollst es ein paar Tage schonen. Klingt doch eigentlich ganz vernünftig, oder?“",
   "„Als erste Orientierung okay, aber ich lasse das lieber fachlich abklären.“",
   "Die KI hilft dir dabei, das Problem etwas einzuordnen. Ob die Erklärung wirklich passt, klärst du aber mit einer Fachperson.",
   {I: 1, S: 1, E: -1},
   "„Dann probiere ich das erst mal so.“",
   "Der Vorschlag klingt nachvollziehbar, berücksichtigt aber nur die Informationen, die Noah eingegeben hat. Eine KI kann überzeugend antworten, ohne beurteilen zu können, was tatsächlich hinter den Beschwerden steckt.",
   {E: 1, I: -2})
sc("noah", 6, "Der erste Videocall",
   "„Die Familie will sich heute Abend per Video zusammenschalten. Tante Karin und die Kinder sind auch dabei. Du hast das noch nie gemacht, aber ich könnte dir vorher kurz zeigen, wo Kamera und Mikrofon sind. Willst du es selbst ausprobieren?“",
   "„Ja, zeig mir kurz, wie es geht, dann probiere ich es selbst.“",
   "Am Anfang musst du noch suchen, wo du tippen musst. Nach ein paar Minuten klappt es und du kannst beim nächsten Mal vieles selbst machen.",
   {V: 2, S: 1},
   "„Bleib lieber dabei und mach das für mich.“",
   "Der Videocall klappt ohne viel Herumprobieren und du kannst dich ganz auf die Familie konzentrieren. Allerdings brauchst du beim nächsten Anruf Noah wahrscheinlich wieder.",
   {V: 2, S: -1})

# --- Jana
sc("jana", 1, "Virtuelle Sprechstunde",
   "„Die Praxis hat kurzfristig einen Termin per Video angeboten. Das wäre natürlich praktisch, weil der Weg wegfällt. Aber wir sollten vorher schauen, ob Kamera, Ton und der Zugangslink funktionieren. Wollen Sie den Termin nehmen?“",
   "„Ich möchte lieber einen Termin vor Ort.“",
   "Du musst länger auf einen Termin warten und den Weg zur Praxis auf dich nehmen. Dafür kann die Ärztin dich direkt untersuchen.",
   {I: 1, E: -1},
   "„Ja, wir probieren den Videotermin.“",
   "Jana testet vorher mit dir Kamera und Ton. Der Termin klappt gut und du sparst dir den Weg zur Praxis. Für manche Beschwerden reicht ein Videogespräch allerdings nicht aus.",
   {E: 1, S: 1})
sc("jana", 2, "Die elektronische Patientenakte",
   "„Ihre Krankenkasse hat Ihnen die elektronische Patientenakte eingerichtet. Darin können zum Beispiel Befunde oder Arztbriefe gespeichert werden. In der App können Sie festlegen, wer worauf zugreifen darf. Wollen wir die Einstellungen einfach so lassen oder einmal gemeinsam durchgehen?“",
   "„Zeigen Sie mir bitte, wo ich die Zugriffe einstellen kann.“",
   "Ihr geht die Berechtigungen gemeinsam durch und du entscheidest selbst, welche Informationen verfügbar sein sollen. Das dauert etwas länger.",
   {S: 1, I: 1, E: -1},
   "„Lassen wir erst mal alles so.“",
   "Die Akte ist schnell nutzbar. Dir bleibt aber zunächst unklar, welche Daten für wen sichtbar sind.",
   {E: 1, I: -1})
sc("jana", 3, "Die Medikamenten-App",
   "„Sie nehmen mehrere Medikamente zu unterschiedlichen Zeiten. Es gibt Apps, die Sie an die Einnahme erinnern können. Eine davon zeigt aber eine andere Uhrzeit als Ihr Medikationsplan. Wollen wir uns nach der App richten oder erst prüfen, was stimmt?“",
   "„Dann nehme ich es so, wie die App es anzeigt.“",
   "Die App war nicht korrekt eingestellt. Digitale Erinnerungen können hilfreich sein, sollten aber nicht eigenständig einen ärztlichen Medikationsplan ersetzen.",
   {E: 1, I: -2},
   "„Lassen Sie uns das erst mit Praxis oder Apotheke klären.“",
   "Die Abweichung wird geklärt und die App anschließend richtig eingestellt. Du kannst die Erinnerungsfunktion weiter nutzen, ohne die medizinische Entscheidung an die App abzugeben.",
   {I: 1, E: -1})
sc("jana", 4, "Die Übung in der Sport-App",
   "„Sie wollten heute ja ein bisschen Bewegung machen, und die Sport-App hat Ihnen dafür eine neue Übung vorgeschlagen. Die sieht ziemlich anspruchsvoll aus. Ich kann Ihnen helfen, erst einmal eine leichtere Variante auszuprobieren – oder wir versuchen es so, wie es im Video gezeigt wird. Was ist Ihnen lieber?“",
   "„Zeigen Sie mir lieber erst eine einfachere Variante.“",
   "Jana hilft dir, die Bewegung so anzupassen, dass du sie sicherer ausprobieren kannst. Wenn du unsicher bleibst, kann eine Physiotherapie oder Arztpraxis klären, welche Übungen für dich geeignet sind.",
   {I: 1, S: 1},
   "„Ich probiere die Übung so wie im Video.“",
   "Du versuchst, die Bewegung möglichst genau nachzumachen. Das Video kann aber nicht erkennen, ob du die Übung richtig ausführst oder ob sie für dich gerade passend ist. Dadurch steigt das Risiko für eine falsche Ausführung.",
   {S: 1, I: -2})
sc("jana", 5, "Die Online-Nachbarschaftsgruppe",
   "„Sie haben ja erzählt, dass Sie hier nach dem Umzug noch kaum jemanden kennen. Ich habe im Internet eine Nachbarschaftsgruppe gefunden, in der sich Leute aus dem Viertel online austauschen und Treffen organisieren. Für das Profil können Sie einiges über sich angeben. Wollen Sie lieber etwas mehr von sich zeigen oder nur das Nötigste eintragen?“",
   "„Ja, tragen wir ruhig ein bisschen mehr über mich ein.“",
   "Dein Profil wirkt persönlich und andere können leichter Anknüpfungspunkte finden. Gleichzeitig sind nun auch Informationen über dich öffentlich sichtbar, die für die Teilnahme gar nicht nötig gewesen wären.",
   {V: 2, I: -1},
   "„Zeigen Sie mir erst, welche Angaben wirklich nötig sind.“",
   "Du richtest ein schlichtes Profil ein und gibst nur wenige persönliche Informationen preis. Für den Austausch in der Gruppe reicht das trotzdem aus.",
   {V: 1, I: 1})
sc("jana", 6, "Das erste Treffen war komisch",
   "„Sie waren gestern doch bei diesem Treffen aus der Nachbarschaftsgruppe. Aber Sie sind kaum mit jemandem ins Gespräch gekommen? Wollen Sie es noch einmal versuchen oder war das nichts für Sie?“",
   "„Ich probiere es noch einmal.“",
   "Beim zweiten Treffen kennst du schon ein paar Gesichter und kommst leichter ins Gespräch. Aus einem ersten unbeholfenen Abend entsteht langsam ein neuer Kontakt.",
   {V: 2, E: -1},
   "„Nein, das war wohl einfach nicht meine Gruppe.“",
   "Du musst dich nicht zu einem Angebot zwingen, bei dem du dich nicht wohlfühlst. Gleichzeitig bleibt dir offen, ob der erste Abend vielleicht einfach ein schwieriger Einstieg war.",
   {E: 1, V: -1}, follows="jana_05")

# --- Michael Müller
sc("michael", 1, "Paket angeblich zugestellt",
   "„Bei mir im System steht, dass Ihr Paket gestern zugestellt wurde. Sie haben aber nichts bekommen?“",
   "„Ich frage erst bei den Nachbarn nach.“",
   "Das Paket liegt tatsächlich zwei Häuser weiter und du bekommst es noch am selben Tag.",
   {V: 1, E: 1},
   "„Dann melde ich sofort, dass es verschwunden ist.“",
   "Kurz darauf stellt sich heraus, dass ein Nachbar das Paket angenommen hat.",
   {I: 1, E: -1})
sc("michael", 2, "Zustellwunsch in der App",
   "„Sie können in der App einstellen, dass Pakete künftig automatisch vor der Haustür abgelegt werden. Dann müssen Sie nicht mehr zuhause sein. Wollen Sie das machen?“",
   "„Ja, das wäre praktisch.“",
   "Pakete werden künftig auch bei Abwesenheit zugestellt. Dafür liegen sie zeitweise unbeaufsichtigt.",
   {E: 1, I: -1},
   "„Nein, ich möchte Pakete lieber persönlich annehmen.“",
   "Die Übergabe ist sicherer, dafür musst du häufiger zuhause sein oder zur Abholung gehen.",
   {I: 1, E: -1})
sc("michael", 3, "Die Nachzahlung",
   "„Sie haben doch auf ein Paket gewartet, oder? Sie meinten, es kam eine SMS, in der stand, es sei noch eine kleine Zustellgebühr offen? Soll ich mal schauen, ob bei mir dazu etwas steht?“",
   "„Schauen wir lieber erst nach, ob wirklich etwas offen ist.“",
   "Michael findet keine Nachzahlung im System. Anscheinend handelte es sich um einen Betrugsversuch, um an die Zahlungsdaten zu kommen. Das Paket wird ganz normal zugestellt.",
   {I: 1, E: -1},
   "„Die 1,99 Euro zahle ich einfach schnell.“",
   "Die SMS gehörte nicht zur Sendung. Über den Link sollten Zahlungsdaten abgegriffen werden.",
   {E: 1, I: -2})
sc("michael", 4, "Paket liegt zur Abholung bereit",
   "„Sie haben eine Mail bekommen, dass Ihr Paket zur Abholung bereitliegt? Wenn Sie möchten, können wir kurz schauen, ob die Sendungsnummer zu Ihrem Paket passt.“",
   "„Ich öffne einfach den Link aus der Mail.“",
   "Die Nachricht war gefälscht und führte auf eine Seite, die persönliche Daten abfragen wollte.",
   {E: 1, I: -2},
   "„Ich prüfe die Sendung lieber über die offizielle Sendungsverfolgung.“",
   "Dort findest du den echten Abholort. Die Mail gehörte nicht zu deiner Sendung und war ein Versuch, deine persönlichen Daten abzugreifen.",
   {I: 1, E: -1})
sc("michael", 5, "Das unerwartete Paket",
   "„Ich habe hier ein Paket auf Ihren Namen, aber Sie sagen, Sie haben nichts bestellt. Es ist bereits bezahlt. Wollen Sie es trotzdem annehmen?“",
   "„Nein, ich nehme nichts an, was ich nicht bestellt habe.“",
   "Die Sendung geht zurück und du musst dich nicht weiter darum kümmern. Hinterher stellt sich heraus, dass das Paket von Betrügern kam und diese dich bei Annahme zur Zahlung aufgefordert hätten.",
   {I: 1, E: -1},
   "„Wenn es bezahlt ist und mein Name draufsteht, nehme ich es an.“",
   "Später kommt eine Zahlungsaufforderung für eine Bestellung, die du nie gemacht hast.",
   {E: 1, I: -2})

# --- Cem Yilmaz
sc("cem", 1, "„Ihre Wertsachen sind nicht sicher“",
   "Anruf von der 110: „Guten Tag, hier spricht die Polizei. Wir haben Hinweise, dass in Ihrer Straße eingebrochen werden soll. Bitte legen Sie Bargeld und Schmuck bereit, ein Kollege kommt gleich vorbei und bringt alles in Sicherheit.“",
   "„Ich bereite die Wertsachen vor.“",
   "Der Anrufer war nicht Cem. Die angebliche Gefahr sollte dich dazu bringen, Bargeld und Schmuck freiwillig an einen Kriminellen zu übergeben.",
   {E: 1, I: -2},
   "„Ich lege auf und rufe selbst beim Revier an.“",
   "Der echte Cem bestätigt, dass es keinen solchen Einsatz gibt. Die Polizei nimmt keine Wertsachen zur „Sicherung“ mit und ruft nicht mit der 110 an.",
   {I: 1, E: -1}, channel=CALL, sender="Anruf von der 110")
sc("cem", 2, "Der Rückruf",
   "„Guten Tag, hier ist Cem Yilmaz vom örtlichen Revier. Sie hatten gestern wegen eines Betrugsversuchs Anzeige erstattet. Ich hätte dazu noch eine kurze Rückfrage zu der Telefonnummer, von der Sie angerufen wurden.“",
   "„Ich rufe lieber selbst beim Revier zurück.“",
   "Du erreichst Cem über die offizielle Nummer und bestätigst so zusätzlich, dass der Anruf wirklich von der Polizei kam.",
   {I: 1, E: -1},
   "„Okay, ich beantworte die Rückfrage.“",
   "Der Anruf ist echt und Cem fragt nur nach Angaben, die zur bereits bekannten Anzeige gehören.",
   {E: 1, V: 1}, channel=CALL)
sc("cem", 3, "Was machen wir mit der Nachricht?",
   "„Sie haben die verdächtige SMS zum Glück nicht geöffnet. Darin wird mit einem Gerichtsverfahren gedroht und Sie sollen über einen Link sofort zahlen. Wollen Sie die Nachricht gleich löschen oder erst noch sichern?“",
   "„Ich lösche sie sofort.“",
   "Die gefährliche Nachricht ist weg und du kannst nicht mehr versehentlich darauf tippen. Für eine Meldung oder spätere Nachfragen fehlen allerdings möglicherweise Informationen aus der Nachricht.",
   {E: 1, I: -1},
   "„Ich mache erst einen Screenshot und lösche sie danach.“",
   "Du behältst die wichtigsten Informationen, ohne auf den Link zu gehen. Das kann hilfreich sein, wenn du den Vorgang melden oder später nachvollziehen möchtest. Falsche SMS im Namen von Banken, Behörden oder zu angeblichen Gerichtsverfahren kommen tatsächlich vor.",
   {I: 1, S: 1, E: -1})
sc("cem", 4, "Die Smart-Glasses",
   "„Sie haben die Smart Glasses wohl neu? Vorhin auf dem Marktplatz haben Sie damit eine Aufnahme gestartet. Eine Frau hat sich beschwert, weil sie dabei mitgefilmt wurde. Ihnen war gar nicht klar, dass die kleine Leuchte bedeutet, dass die Kamera läuft, oder?“",
   "„Dann lösche ich die Aufnahme lieber gleich.“",
   "Die Aufnahme ist weg und die Situation mit der Frau ist schnell geklärt. Du weißt allerdings noch nicht genau, wie es überhaupt dazu gekommen ist – beim nächsten Mal könnte dir dasselbe wieder passieren.",
   {E: 1, S: -1},
   "„Ich möchte erst verstehen, wie ich die Aufnahme versehentlich gestartet habe.“",
   "Cem hilft dir zunächst, die Aufnahme zu stoppen, und du schaust anschließend nach, wie Kamera, Leuchte und Aufnahmefunktion deiner Brille funktionieren. Das dauert etwas länger, hilft dir aber beim nächsten Mal.",
   {S: 1, I: 1, E: -1})
sc("cem", 5, "Die Nachricht in der Nachbarschaftsgruppe",
   "„Sie haben also eine Nachricht in Ihrer Facebook-Nachbarschaftsgruppe bekommen, in der Sie konkret bedroht wurden? Das ist ziemlich heftig. Wenn so eine Nachricht kommt, will man sie am liebsten sofort loswerden. Haben Sie schon etwas unternommen, bevor Sie zu mir gekommen sind?“",
   "„Ich habe die Person blockiert, die Nachricht aber behalten.“",
   "Die Person kann dich nicht mehr direkt anschreiben und die Nachricht bleibt als Nachweis erhalten. Falls du den Vorfall melden möchtest, kannst du zeigen, was geschrieben wurde und von welchem Account es kam.",
   {I: 1, S: 1},
   "„Ich habe die Nachricht sofort gelöscht.“",
   "Die Nachricht ist weg und du musst sie nicht mehr sehen. Für eine spätere Meldung fehlt dir dadurch aber möglicherweise ein wichtiger Nachweis.",
   {E: 1, I: -1})

# --- Hildegard
sc("hildegard", 1, "Die Hausverwaltung wird digital",
   "„Jetzt will meine Hausverwaltung Schadensmeldungen, Termine und Dokumente über so ein Onlineportal machen. Ein Telefon hat doch bisher auch funktioniert! Was meinst du?“",
   "„Bleib bei Telefon und Brief, solange das möglich ist.“",
   "Hildegard bleibt bei ihrem gewohnten Weg und kommt damit zurecht. Bei manchen Anliegen muss sie allerdings länger auf eine Antwort warten.",
   {V: 1, E: -1},
   "„Probier das Portal zumindest einmal aus.“",
   "Die erste Anmeldung ist lästig. Danach entdeckt Hildegard, dass sie Reparaturtermine und Dokumente jederzeit selbst abrufen kann.",
   {S: 1, E: 1})
sc("hildegard", 2, "Busverbindung fällt aus",
   "„Na toll, unser Bus fällt aus. Du sagst, dass dein Handy als schnellste Alternative einen Weg mit zwei Umstiegen vorschlägt? Und beim zweiten Umstieg haben wir nur vier Minuten? Ich weiß ja nicht, ob das eine gute Idee ist. Was meinst du?“",
   "„Wir nehmen die schnellste Verbindung.“",
   "Die App zeigt zwar die kürzeste Reisezeit, aber schon eine kleine Verspätung macht den Umstieg hektisch. Die schnellste Route ist nicht immer die passendste.",
   {E: 1, I: -1},
   "„Wir suchen eine Verbindung mit mehr Zeit zum Umsteigen.“",
   "Ihr seid etwas länger unterwegs, könnt aber ohne Hektik umsteigen und kommt entspannter an.",
   {I: 1, S: 1, E: -1})
sc("hildegard", 3, "Aufzug kaputt",
   "„Wir müssen ja am Hauptbahnhof umsteigen, damit wir rechtzeitig beim Theater sind. Jetzt zeigt dein Handy, dass der Aufzug dort kaputt ist. Mit meinen Knien die Treppen hoch muss ich echt nicht haben. Was meinst du?“",
   "„Wir suchen lieber gleich eine andere Verbindung.“",
   "Die Alternative dauert etwas länger, dafür vermeidet ihr die Treppen und kommt ohne großen Stress an.",
   {I: 1, E: -1},
   "„Wir fahren trotzdem hin und schauen dann.“",
   "Der Aufzug ist tatsächlich außer Betrieb und ihr müsst vor Ort spontan umplanen.",
   {E: 1, I: -1})
sc("hildegard", 4, "Der Akku wird knapp",
   "„Ich freu mich ja auf unseren Ausflug zum Kunsthandwerkermarkt – da waren wir beide noch nie. Du hast ja die Fahrkarten, die Verbindung und die Adresse auf dem Handy? Ich sehe nur gerade, dass du nur noch 30 % Akku hast. Ich würde mir die wichtigsten Sachen lieber kurz aufschreiben und die Tickets nochmal ausdrucken. Oder meinst du, das Handy hält noch durch?“",
   "„Das Handy hält bestimmt noch.“",
   "Auf dem Hinweg klappt alles. Auf dem Rückweg geht der Akku aus und ihr könnt bei einer Fahrkartenkontrolle kein Ticket vorzeigen. Außerdem vertut ihr euch beim Umstieg und kommt erst spät am Abend wieder zuhause an.",
   {E: 1, I: -2},
   "„Wir schreiben die wichtigsten Sachen kurz auf und drucken die Tickets nochmal aus.“",
   "Der Akku hält am Ende doch durch. Mit Route, Adresse und den wichtigsten Angaben auf Papier hättet ihr aber auch bei einem Ausfall weitergewusst.",
   {I: 1, S: 1, E: -1})
sc("hildegard", 5, "Der Fahrdienst an der Haustür",
   "„Du, hier steht gerade ein Mann von einem Fahrdienst vor meiner Tür. Der sagt, ich könnte für einen ziemlich günstigen Monatspreis überall hingefahren werden – aber nur, wenn ich heute noch unterschreibe. Er wartet gerade draußen. Das wäre schon praktisch für mich … was meinst du?“",
   "„Lass dir die Unterlagen geben und schick ihn erst mal weg.“",
   "Hildegard nimmt den Vertrag mit und schaut ihn später in Ruhe durch. Dabei entdeckt sie Zusatzkosten und eine längere Bindung, die an der Haustür nicht erwähnt wurden.",
   {I: 1, S: 1, E: -1},
   "„Wenn du den Dienst gebrauchen kannst, unterschreib ruhig.“",
   "Hildegard unterschreibt unter Zeitdruck. Erst später merkt sie, dass zusätzlich eine Aufnahmegebühr und eine längere Vertragslaufzeit dazukommen. Dass der Preis angeblich nur „heute“ gilt, war ein Warnzeichen.",
   {E: 1, I: -2}, channel=CALL)
sc("hildegard", 6, "Anbieter will IBAN",
   "„Ein Mann von einem Einkaufsservice für Senioren steht gerade bei mir vor der Tür. Wäre eigentlich schon praktisch, gerade mit meinem schlimmen Knie … Wenn ich regelmäßig beliefert werden will, soll ich gleich meine IBAN eintragen, dann wird alles automatisch abgebucht. Er sagt, das sei bei allen Kunden so. Soll ich das machen?“",
   "„Wenn du den Service nutzen willst, trag sie ein.“",
   "Eine Lastschrift ist grundsätzlich normal. Hildegard hat aber noch gar nicht geprüft, wer hinter dem Anbieter steckt und welche Kosten genau anfallen. Die Kombination aus Haustürgeschäft und sofort verlangten Bankdaten wäre ein Grund, genauer hinzuschauen.",
   {E: 1, I: -2},
   "„Gib die Bankverbindung noch nicht raus und prüf erst den Anbieter.“",
   "Hildegard nimmt die Unterlagen mit und schaut später nach. Dabei findet sie zusätzliche Gebühren, die im Gespräch kaum erwähnt wurden.",
   {I: 1, S: 1, E: -1}, channel=CALL)

# --- Linh Nguyen
sc("linh", 1, "Kontaktlos bezahlen",
   "„Ihre neue Bankkarte kann kontaktlos bezahlen. Bei kleineren Beträgen müssen Sie oft nicht einmal die PIN eingeben. Möchten Sie die Funktion nutzen?“",
   "„Nein, ich möchte lieber immer mit PIN bezahlen.“",
   "Du fühlst dich bei jeder Zahlung bewusster abgesichert. Der Bezahlvorgang dauert dafür etwas länger.",
   {I: 1, E: -1},
   "„Ja, das klingt praktisch.“",
   "Kleine Einkäufe gehen deutlich schneller. Du musst dich aber daran gewöhnen, die Karte bewusster im Blick zu behalten.",
   {E: 1, I: -1})
sc("linh", 2, "Online-Banking einrichten",
   "„Sie erledigen Ihre Überweisungen ja noch in der Filiale. Wenn Sie möchten, kann ich Ihnen zeigen, wie unser Online-Banking funktioniert. Dann müssten Sie für viele Dinge nicht mehr extra herkommen. Wollen Sie das ausprobieren?“",
   "„Ja, zeigen Sie mir, wie ich das selbst machen kann.“",
   "Die Einrichtung dauert etwas, danach kannst du Überweisungen und Kontostand selbst von zu Hause aus erledigen und im Notfall deine Karten schnell sperren lassen.",
   {S: 1, E: 1},
   "„Nein, ich komme lieber weiterhin in die Filiale.“",
   "Du bleibst bei deinem vertrauten Weg, hast bei Bankgeschäften persönlichen Kontakt und kannst Fragen schnell klären. Dafür bist du an Öffnungszeiten und Wege gebunden.",
   {V: 1, E: -1})
sc("linh", 3, "Vollmacht für Silke",
   "„Falls einmal etwas passiert, könnten Sie Ihrer Tochter Silke eine Kontovollmacht geben. Dann könnte sie bestimmte Bankgeschäfte für Sie erledigen. Möchten Sie das?“",
   "„Nein, meine Bankgeschäfte möchte ich selbst regeln.“",
   "Du behältst die volle Kontrolle. Falls du plötzlich Unterstützung brauchst, muss die Familie aber erst andere Lösungen finden.",
   {S: 1, E: -1},
   "„Ja, das gibt mir Sicherheit.“",
   "Silke kann im Bedarfsfall schnell helfen. Gleichzeitig gibst du ihr weitreichenden Einblick und Handlungsmöglichkeiten.",
   {V: 1, E: 1, S: -1})
sc("linh", 4, "Die Überweisung an Silke",
   "„Sie wollten doch Geld an Silke überweisen. Die neue Kontoverbindung, die Sie eingetragen haben, ist bei uns bisher noch nie aufgetaucht. Soll die Überweisung trotzdem raus?“",
   "„Ja, Silke hat mir die neue IBAN geschickt.“",
   "Kurz danach stellt sich heraus, dass Silkes Messenger-Konto übernommen wurde. Die Nachricht mit der neuen Bankverbindung kam nicht von ihr.",
   {V: 1, I: -2},
   "„Ich rufe Silke lieber noch einmal an.“",
   "Silke kennt die neue Kontoverbindung nicht. Die Überweisung wird nicht ausgeführt.",
   {I: 1, V: 1, E: -1})
sc("linh", 5, "Die Mail von der Bank",
   "„Guten Tag, aus Sicherheitsgründen muss Ihr TAN-Verfahren neu bestätigt werden. Bitte führen Sie die Aktualisierung bis heute 18:00 Uhr über den folgenden Link durch. Andernfalls kann Ihr Online-Banking vorübergehend eingeschränkt werden.“",
   "„Ich öffne die Banking-App selbst und prüfe dort, ob etwas ansteht.“",
   "In der App gibt es keine Aufforderung zur Aktualisierung. Die Mail war ein Phishing-Versuch, um deine Bankdaten abzugreifen.",
   {I: 1, S: 1, E: -1},
   "„Ich klicke auf den Link und bestätige das schnell.“",
   "Die Mail war gefälscht. Der Link führte auf eine nachgebaute Bankseite, auf der deine Zugangsdaten abgegriffen werden sollten. Die knappe Frist und die angekündigte Einschränkung sollten dich unter Druck setzen.",
   {E: 1, I: -2}, channel=EMAIL, sender="E-Mail von deiner Bank")
sc("linh", 6, "Der unbekannte Händlername",
   "„Auf Ihrem Konto steht eine Abbuchung von ‚PAYONE GmbH‘. Der Name sagt mir nichts. Soll ich die Zahlung vorsichtshalber reklamieren oder möchten Sie erst schauen, ob sie zu einem Einkauf passt?“",
   "„Reklamieren wir sie lieber.“",
   "Die Zahlung stammt von einem Geschäft, bei dem du tatsächlich eingekauft hast. Auf dem Kontoauszug erscheint nur der Zahlungsdienstleister statt des Ladennamens.",
   {I: 1, E: -1},
   "„Ich prüfe erst meine letzten Einkäufe.“",
   "Du findest den Kassenbon, auf dem auch der Zahlungsdienstleister des Händlers vermerkt ist, und kannst die Buchung zuordnen. Es war alles in Ordnung.",
   {S: 1, E: 1})
sc("linh", 7, "Das Geld ist schon überwiesen",
   "„Sie sagen, die Küchenmaschine, die Sie online bestellt haben, wurde nie geliefert und der Händler reagiert nicht mehr? … Leider ist die Überweisung schon raus. Haben Sie die Bestellbestätigung und den Zahlungsbeleg noch?“",
   "„Ja, ich habe alles aufgehoben.“",
   "Linh kann Empfänger, Betrag und Bestelldaten schnell nachvollziehen. Die gesicherten Unterlagen helfen, den Fall weiterzugeben und mögliche Schritte zu prüfen.",
   {I: 1, S: 1},
   "„Nein, die Mails habe ich inzwischen gelöscht.“",
   "Linh kann den Vorgang trotzdem aufnehmen, aber ohne Belege ist vieles schwerer nachzuvollziehen. Gerade bei auffälligen Shops lohnt es sich, Bestellbestätigung, Zahlungsbeleg und Screenshots aufzubewahren.",
   {E: 1, I: -2})

assert len(SC) == 50, len(SC)

# ----------------------------------------------------------------------------- writers
def write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def write_values() -> None:
    for v in VALUES:
        tiers = v["tiers"]
        lines = [f'[gd_resource type="Resource" script_class="ValueDefinition" load_steps={3 + len(tiers) + 1} format=3]', ""]
        lines.append('[ext_resource type="Script" path="res://src/resources/ValueDefinition.gd" id="1_def"]')
        lines.append('[ext_resource type="Script" path="res://src/resources/ValueTier.gd" id="2_tier"]')
        lines.append(f'[ext_resource type="Texture2D" path="res://assets/sprites/icons/value_{v["id"]}.svg" id="3_icon"]')
        lines.append("")
        for n, (lo, hi, state, desc) in enumerate(tiers):
            lines += [f'[sub_resource type="Resource" id="tier_{n}"]', 'script = ExtResource("2_tier")',
                      f"min_score = {lo}", f"max_score = {hi}", f'state_name = "{esc(state)}"', f'description = "{esc(desc)}"', ""]
        refs = ", ".join(f'SubResource("tier_{n}")' for n in range(len(tiers)))
        lines += ["[resource]", 'script = ExtResource("1_def")', f'id = &"{v["id"]}"', f'display_name = "{esc(v["name"])}"',
                  f'focus = "{esc(v["focus"])}"', f'color = {v["color"]}', 'icon = ExtResource("3_icon")',
                  f'tiers = Array[ExtResource("2_tier")]([{refs}])', ""]
        write(DATA / "values" / f'value_{v["id"]}.tres', "\n".join(lines))


def write_characters() -> None:
    for c in CHARACTERS:
        lines = ['[gd_resource type="Resource" script_class="CharacterData" load_steps=3 format=3]', "",
                 '[ext_resource type="Script" path="res://src/resources/CharacterData.gd" id="1_char"]',
                 f'[ext_resource type="Texture2D" path="res://assets/sprites/characters/{c["id"]}.svg" id="2_portrait"]', "",
                 "[resource]", 'script = ExtResource("1_char")', f'id = &"{c["id"]}"', f'display_name = "{esc(c["name"])}"',
                 f'tagline = "{esc(c["tagline"])}"', f'age_text = "{esc(c["age"])}"', f'role_text = "{esc(c["role"])}"',
                 f'description = "{esc(c["desc"])}"', f'strengths = "{esc(c["strengths"])}"', f'weaknesses = "{esc(c["weaknesses"])}"',
                 'portrait = ExtResource("2_portrait")', f'accent_color = {c["accent"]}', f'formal_address = {"true" if c["formal"] else "false"}', ""]
        write(DATA / "characters" / f'{c["id"]}.tres', "\n".join(lines))


def delta_block(res_id: str, d: dict) -> list:
    return [f'[sub_resource type="Resource" id="{res_id}"]', 'script = ExtResource("3_delta")',
            f"selbststaendigkeit = {d.get(S, 0)}", f"sicherheit = {d.get(I, 0)}",
            f"verbundenheit = {d.get(V, 0)}", f"entlastung = {d.get(E, 0)}", ""]


def write_scenarios() -> None:
    for (sid, cid, title, channel, body, a, ao, ad, b, bo, bd, follows, sender) in SC:
        lines = ['[gd_resource type="Resource" script_class="ScenarioData" load_steps=9 format=3]', "",
                 '[ext_resource type="Script" path="res://src/resources/ScenarioData.gd" id="1_scenario"]',
                 '[ext_resource type="Script" path="res://src/resources/ChoiceData.gd" id="2_choice"]',
                 '[ext_resource type="Script" path="res://src/resources/ValueDelta.gd" id="3_delta"]',
                 f'[ext_resource type="Resource" path="res://src/resources/data/characters/{cid}.tres" id="4_character"]', ""]
        lines += delta_block("delta_a", ad)
        lines += ['[sub_resource type="Resource" id="choice_a"]', 'script = ExtResource("2_choice")',
                  f'label = "{esc(unquote(a))}"', f'outcome_text = "{esc(ao)}"', 'delta = SubResource("delta_a")', ""]
        lines += delta_block("delta_b", bd)
        lines += ['[sub_resource type="Resource" id="choice_b"]', 'script = ExtResource("2_choice")',
                  f'label = "{esc(unquote(b))}"', f'outcome_text = "{esc(bo)}"', 'delta = SubResource("delta_b")', ""]
        lines += ["[resource]", 'script = ExtResource("1_scenario")', f'id = &"{sid}"', 'character = ExtResource("4_character")',
                  f'title = "{esc(unquote(title))}"', f'body_text = "{esc(unquote(body))}"', f"channel = {channel}", f'sender_label = "{esc(sender)}"',
                  'choice_a = SubResource("choice_a")', 'choice_b = SubResource("choice_b")', f'follows = &"{follows}"', ""]
        write(DATA / "scenarios" / f"{sid}.tres", "\n".join(lines))


def write_config_and_catalog() -> None:
    write(DATA / "game_config.tres", "\n".join([
        '[gd_resource type="Resource" script_class="GameConfig" load_steps=2 format=3]', "",
        '[ext_resource type="Script" path="res://src/resources/GameConfig.gd" id="1_config"]', "",
        "[resource]", 'script = ExtResource("1_config")', "max_rounds = 10", "start_value = 5", "min_value = 0",
        "max_value = 10", "end_on_extreme = true", "avoid_consecutive_character = true", ""]))

    ext = ['[ext_resource type="Script" path="res://src/resources/GameCatalog.gd" id="1_catalog"]',
           '[ext_resource type="Script" path="res://src/resources/ValueDefinition.gd" id="2_valdef"]',
           '[ext_resource type="Script" path="res://src/resources/CharacterData.gd" id="3_chardef"]',
           '[ext_resource type="Script" path="res://src/resources/ScenarioData.gd" id="4_scdef"]',
           '[ext_resource type="Resource" path="res://src/resources/data/game_config.tres" id="5_config"]']
    val_ids, char_ids, sc_ids = [], [], []
    for v in VALUES:
        rid = f'val_{v["id"]}'
        ext.append(f'[ext_resource type="Resource" path="res://src/resources/data/values/value_{v["id"]}.tres" id="{rid}"]')
        val_ids.append(rid)
    for c in CHARACTERS:
        rid = f'char_{c["id"]}'
        ext.append(f'[ext_resource type="Resource" path="res://src/resources/data/characters/{c["id"]}.tres" id="{rid}"]')
        char_ids.append(rid)
    for row in SC:
        rid = f"sc_{row[0]}"
        ext.append(f'[ext_resource type="Resource" path="res://src/resources/data/scenarios/{row[0]}.tres" id="{rid}"]')
        sc_ids.append(rid)
    lines = [f'[gd_resource type="Resource" script_class="GameCatalog" load_steps={len(ext) + 1} format=3]', ""] + ext + ["",
             "[resource]", 'script = ExtResource("1_catalog")', 'config = ExtResource("5_config")',
             'values = Array[ExtResource("2_valdef")]([' + ", ".join(f'ExtResource("{r}")' for r in val_ids) + "])",
             'characters = Array[ExtResource("3_chardef")]([' + ", ".join(f'ExtResource("{r}")' for r in char_ids) + "])",
             'scenarios = Array[ExtResource("4_scdef")]([' + ", ".join(f'ExtResource("{r}")' for r in sc_ids) + "])", ""]
    write(DATA / "game_catalog.tres", "\n".join(lines))


if __name__ == "__main__":
    write_values()
    write_characters()
    write_scenarios()
    write_config_and_catalog()
    print(f"wrote {len(VALUES)} values, {len(CHARACTERS)} characters, {len(SC)} scenarios, config + catalog")

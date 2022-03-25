### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 30e9b066-6796-4670-98c7-be8476adebfd
begin
	import Pkg
	Pkg.activate(mktempdir())
	Pkg.add([
			"PlutoUI",
			"JuMP",
			"GLPK",
			"DataFrames"
			])
	using PlutoUI
	using JuMP
	using GLPK
	using DataFrames
end

# ╔═╡ 056db7e6-fb6d-4714-9dcb-21172a2cc31e
PlutoUI.TableOfContents(title="Inhaltsverzeichnis", aside=true)

# ╔═╡ a4143656-cdf5-11eb-3517-551d69401a1d
md"""# Modellierung logischer Aussagen - das "Einstein Rätsel" """

# ╔═╡ 91c0d672-99b2-4aa4-aa2e-5ea1ae4155a7
md"""## Einleitung

Kombinatorische Optimierungsprobleme sind allgegenwärtige Alltagsaufgaben, und als herausfordernde Aufgaben sind sie in mehreren wissenschaftlichen Bereichen interessant. Eines der bekanntesten Beispiele aus dem Bereich der kombinatorischen Optimierung, das Albert Einstein zugeschrieben wird, ist das "Einstein-Rätsel" [1]. In der Literatur ist dieses Problem auch als "Zebra-Rätsel" [2] bekannt und wird oft mit Lewis Carroll in Verbindung gebracht [3].

Auch wenn nicht klar ist, ob das Problem ursprünglich von Einstein formuliert wurde, gilt es aufgrund von Einsteins großer Popularität, seinen wissenschaftlichen Errungenschaften und seinem Charisma weithin als Lehrbuchbeispiel und ist ein häufig untersuchtes Optimierungsproblem. Das logische Rätsel und seine Variationen haben im Laufe der Jahre großes Interesse in der wissenschaftlichen Gemeinschaft geweckt. 

Nach einer kurzen Vorstellung des Rätsels und einer Einführung in die Grundlagen von Bedingungserfüllungsproblemen, wird ein Lösungsvorschlag mit der Programmiersprache Julia und dem JuMP-Package vorgestellt.
"""

# ╔═╡ 7b2cf9ef-a01e-4dd8-a368-299de0c05462
md"""## Einsteins Rätsel
"""

# ╔═╡ 1d0fdde8-7164-48ae-8fea-619efbf1e934
md"""### Hintergrund des Rätsels 


Das "Einstein Rätsel", auch als Zebrarätsel bekannt, gehört zu der Gruppe der Logikrätsel. Diese Art von Rätsel können mittels Deduktion, eine Form von logischer Schlussfolgerung, gelöst werden.\
Es ist unklar, ob die ursprüngliche Formulierung des Rätsels von dem berühmten Albert Einstein stammt, der als Junge gemeint haben soll, dass nur etwa 2% der Weltbevölkerung das Rätsel lösen könnte. Die im Rätsel erwähnten Zigarettenmarken waren zu Einsteins Jugendzeit nicht erhältlich und Einstein selbst hat nie ausdrücklich behauptet das Rätsel formuliert zu haben. Aus diesen Gründen sind die Meisten der Ansicht, dass er dieses Rätsel nicht formuliert hat. Allerdings hat es seit seiner ersten Veröffentlichung im "Life International Magazine" am 17. Dezember 1962 das Interesse sowohl der allgemeinen als auch der wissenschaftlichen Gemeinschaft auf sich gezogen. In der Literatur wird das Rätsel oft als Beispiel für ein kombinatorisches Optimierungs- und Bedingungserfüllungsproblem beschrieben. Das Lösen des Rätsels gilt als eine schwierige Herausforderung für den Menschen [4].

"""

# ╔═╡ 0f21d27d-e9e9-4493-b0d2-807e483377c8
md"""### Einsteins Hinweise

Die Fragestellung des "Einstein Rätsels" beinhaltet 16 Hinweise, die dem Löser es ermöglichen herauszufinden wer das Wasser trinkt und wem das Zebra gehört.

1. Es gibt fünf Häuser.
2. Der Engländer wohnt im roten Haus.
3. Der Spanier hat einen Hund.
4. Kaffee wird im grünen Haus getrunken.
5. Der Ukrainer trinkt Tee.
6. Das grüne Haus ist direkt links vom weißen Haus.
7. Der Raucher von Old-Gold-Zigaretten hält Schnecken als Haustiere.
8. Die Zigaretten der Marke Kools werden im gelben Haus geraucht.
9. Milch wird im mittleren Haus getrunken.
10. Der Norweger wohnt im ersten Haus.
11. Der Mann, der Chesterfields raucht, wohnt neben dem Mann mit dem Fuchs.
12. Die Marke Kools wird geraucht im Haus neben dem Haus mit dem Pferd.
13. Der Lucky-Strike-Raucher trinkt am liebsten Orangensaft.
14. Der Japaner raucht Zigaretten der Marke Parliaments.
15. Der Norweger wohnt neben dem blauen Haus.
16. Der Chesterfields-Raucher hat einen Nachbarn, der Wasser trinkt.

In den Hinweisen ist von den fünf Eigenschaften: Farbe des Hauses, Nationalität, Getränk, Zigarettenmarke und Haustier die Rede. Diese Eigenschaften sollen jeweils für jedes Haus individuell sein. 

###### Fragestellung
Die beiden folgenden Fragen sollen mit den Informationen aus der Beschreibung und den Hinweisen beantwortet werden.
- Wer trinkt Wasser? 
- Wem gehört das Zebra?

"""

# ╔═╡ ffa1abe8-5586-452c-9ebf-93f782e26c5a
md"""### Bedingungserfüllungsproblem 

Ein Bedingungserfüllungsproblem (Constraint Satisfaction Problem, abgekürzt CSP) wird in der Literatur als ein mathematisches Problem definiert, das versucht einen Zustand unter Belegung von Variablen zu finden, der alle aufgestellten Bedingungen erfüllt [5]. Im Grunde besteht ein jedes CSP-Problem aus einer Menge von Variablen, ihren Wertebereichen und den Nebenbedingungen. Hierbei erstellen die Nebenbedingungen Verknüpfungen zwischen den Variablen und legen dadurch fest, welche Kombinationen von Zuständen der Variablen erlaubt sind. Auf diese Weise ist es möglich Probleme aus der Informatik, Mathematik und weiteren Anwendungsgebieten zu formulieren. Beispiele für solche Probleme sind das Damenproblem, Sudoku oder das in dieser Arbeit behandelte "Einstein Rätsel".

Während andere Optimierungsproblem nur nach einer optimalen, möglichst guten Lösung suchen, ist das Ziel bei der Lösung eines CSP eine Belegung der Variablen zu finden bei der alle Nebenbedingungen vollständig erfüllt sind. Die Komplexität des Problems hängt somit größtenteils von der Enge der gestellten Nebenbedingungen ab. Wenn die Nebenbedingungen locker sind, kann es mehrere Lösungen geben. Sind die Nebenbedingungen zu eng formuliert sind, können diese widersprüchlich sein und es gibt keine Lösung. [6]\
Wenn die Nebenbedingungen der Aufgabenstellung nur eine Lösung zulassen, dann spricht man von einer "eindeutigen Lösung". Um eine Lösung zu erhalten können in einigen Fällen gegebene Nebenbedingungen miteinander kombiniert oder verrechnet werden, um den Wertebereich der Variablen zusätzlich einzuschränken. Dieses Verfahren wird Bedingungsfortpflanzung genannt.
"""

# ╔═╡ acd3aca1-6287-4cd9-a3bc-e26fa78d940d
md"""## Modellierung des "Einstein Rätsels" mit JuMP """

# ╔═╡ 1352d79e-94c4-4758-aeaa-7ef7281202a2
md"""### Initialisierung des Modells
Im ersten Schritt, bevor die aus der Aufgabenstellung bekannten Variablen und Hinweise implementiert werden können, muss das Modell mit dem gewählten Löser erzeugt werden. Dadurch können im Anschluss die zu implementierenden Modellvariablen, sowie Nebenbedingungen dem Modell hinzugefügt werden. Im Fall des "Einstein Rätsels" handelt es sich um ein Integer Problem, denn die Modellvariablen sind so definiert, dass sie nur eine ``0`` oder ``1`` annehmen können. Für die Lösung des Problems kann somit prinzipiell jeder Integer Löser verwendet werden.

###### Löser
Bei dem in dieser Arbeit verwendeten Löser handelt es sich um den GLPK-Solver (GNU Linear Programming Kit). Dieser kann Optimierungsprobleme der linearen Programmierung (LP), der Mixed-Integer-Programmierung (MIP) und der Integer-Programmierung (IP) lösen. Er umfasst Algorithmen wie die Simplex-Methode, die Innere-Punkt-Methode und die Branch-and-Bound-Methode. [7]


Der folgende Code erzeugt das für das Optimierungsproblem verwendete JuMP-Modell `einstein_raetsel`, und definiert den gewählten Löser `GLPK.Optimizier`
"""

# ╔═╡ 782c2e02-3937-4665-9fdc-e87a37c25711
einstein_raetsel = Model(GLPK.Optimizer)

# ╔═╡ b4afc5ce-4a0c-4bd9-b4f4-627e4125077a
md"""
Die Ausgabe verrät, dass es sich bei dem erzeugten Modell `einstein_raetsel` um ein "Feasibility"-Problem mit ``0`` Variablen handelt und als Löser der `GLPK-Optimizer` verwendet wird. Die Anzahl der Variablen verändert sich, sobald diese formuliert und dem Modell hinzugefügt worden sind.\
Die Eigenschaften des Modells werden in den weiteren Abschnitten nochmals betrachtet.
"""

# ╔═╡ 4598426b-fee1-4b19-ba68-e51cfa465bd7
md"""### Modellvariablen

Der erste Hinweis des Rätsels gibt darüber Aufschluss, dass es fünf Häuser gibt, die wiederum fünf verschiedene Eigenschaften mit sich bringen: Nationalität ``N_i``, Hausfarbe ``F_i``, Getränk ``G_i``, Haustier ``T_i`` und Zigarettenmarke ``Z_i``. Zur Lösung des Optimierungsproblems mit dem JuMP-Package werden diese in Modellvariablen übersetzt.\
Hierbei wird für jede der fünf Eigenschaften eine binäre ``5 x 5`` Matrix erstellt. Die Zeilen der Matrix bilden die Zustände ``i`` der jeweiligen Eigenschaft und die Spalten die Hausnummern ``H_j``. Somit entstehen pro Eigenschaft ``25`` binäre Variablen, was in Summe ``125`` binären Modellvariablen entspricht.

###### Nationalität
Die Variable ``N_{i,j}`` beschreibt, ob die Nationalität ``N_i`` im Haus ``H_j`` wohnt.

 Nationalität ``N_i``|Haus ``H_1``|Haus ``H_2``|Haus ``H_3``|Haus ``H_4``|Haus ``H_5``
:--------------------|:---------:|:---------:|:---------:|:---------:|:---------:
``N_1`` Engländer    |``N_{1,1}``|``N_{1,2}``|``N_{1,3}``|``N_{1,4}``|``N_{1,5}`` 
``N_2`` Spanier      |``N_{2,1}``|``N_{2,2}``|``N_{2,3}``|``N_{2,4}``|``N_{2,5}`` 
``N_3`` Ukrainer     |``N_{3,1}``|``N_{2,2}``|``N_{3,3}``|``N_{3,4}``|``N_{3,5}``
``N_4`` Norweger     |``N_{4,1}``|``N_{2,2}``|``N_{4,3}``|``N_{4,4}``|``N_{4,5}`` 
``N_5`` Japaner      |``N_{5,1}``|``N_{2,2}``|``N_{5,3}``|``N_{5,4}``|``N_{5,5}``


###### Hausfarbe
Die Variable ``F_{i,j}`` beschreibt, ob die Hausfarbe ``F_i`` der Farbe des Hauses ``H_j`` entspricht.

 Hausfarbe ``F_i`` |Haus ``H_1``|Haus ``H_2``|Haus ``H_3``|Haus ``H_4``|Haus ``H_5``
:------------------|:---------:|:---------:|:---------:|:---------:|:---------:
``F_1`` rot        |``F_{1,1}``|``F_{1,2}``|``F_{1,3}``|``F_{1,4}``|``F_{1,5}`` 
``F_2`` grün       |``F_{2,1}``|``F_{2,2}``|``F_{2,3}``|``F_{2,4}``|``F_{2,5}`` 
``F_3`` weiß       |``F_{3,1}``|``F_{3,2}``|``F_{3,3}``|``F_{3,4}``|``F_{3,5}``
``F_4`` gelb       |``F_{4,1}``|``F_{4,2}``|``F_{4,3}``|``F_{4,4}``|``F_{4,5}`` 
``F_5`` blau       |``F_{5,1}``|``F_{5,2}``|``F_{5,3}``|``F_{5,4}``|``F_{5,5}``


###### Getränk
Die Variable ``G_{i,j}`` beschreibt, ob das Getränk ``G_i`` im Haus ``H_j`` getrunken wird.

 Getränk ``G_i``    |Haus ``H_1``|Haus ``H_2``|Haus ``H_3``|Haus ``H_4``|Haus ``H_5``
:----------------   |:---------:|:---------:|:---------:|:---------:|:---------:
``G_1`` Kaffee      |``G_{1,1}``|``G_{1,2}``|``G_{1,3}``|``G_{1,4}``|``G_{1,5}`` 
``G_2`` Tee         |``G_{2,1}``|``G_{2,2}``|``G_{2,3}``|``G_{2,4}``|``G_{2,5}`` 
``G_3`` Milch       |``G_{3,1}``|``G_{3,2}``|``G_{3,3}``|``G_{3,4}``|``G_{3,5}``
``G_4`` Orangensaft |``G_{4,1}``|``G_{4,2}``|``G_{4,3}``|``G_{4,4}``|``G_{4,5}`` 
``G_5`` Wasser      |``G_{5,1}``|``G_{5,2}``|``G_{5,3}``|``G_{5,4}``|``G_{5,5}``


###### Haustier
Die Variable ``T_{i,j}`` beschreibt, ob das Tier ``T_i`` im Haus ``H_j`` wohnt.

 Haustier ``T_i`` |Haus ``H_1``|Haus ``H_2``|Haus ``H_3``|Haus ``H_4``|Haus ``H_5``
:-----------------|:---------:|:---------:|:---------:|:---------:|:---------:
``T_1`` Hund      |``T_{1,1}``|``T_{1,2}``|``T_{1,3}``|``T_{1,4}``|``T_{1,5}`` 
``T_2`` Schnecken |``T_{2,1}``|``T_{2,2}``|``T_{2,3}``|``T_{2,4}``|``T_{2,5}`` 
``T_3`` Fuchs     |``T_{3,1}``|``T_{3,2}``|``T_{3,3}``|``T_{3,4}``|``T_{3,5}``
``T_4`` Pferd     |``T_{4,1}``|``T_{4,2}``|``T_{4,3}``|``T_{4,4}``|``T_{4,5}`` 
``T_5`` Zebra     |``T_{5,1}``|``T_{5,2}``|``T_{5,3}``|``T_{5,4}``|``T_{5,5}``


###### Zigarettenmarke
Die Variable ``Z_{i,j}`` beschreibt, ob die Zigarettenmarke ``Z_i`` im Haus ``H_j`` geraucht wird.

Zigarettenmarke ``Z_i``|Haus ``H_1``|Haus ``H_2``|Haus ``H_3``|Haus ``H_4``|Haus ``H_5``
:---------------------|:---------:|:---------:|:---------:|:---------:|:--------:
``Z_1`` Old-Gold      |``Z_{1,1}``|``Z_{1,2}``|``Z_{1,3}``|``Z_{1,4}``|``Z_{1,5}`` 
``Z_2`` Kools         |``Z_{2,1}``|``Z_{2,2}``|``Z_{2,3}``|``Z_{2,4}``|``Z_{2,5}`` 
``Z_3`` Chesterfield  |``Z_{3,1}``|``Z_{3,2}``|``Z_{3,3}``|``Z_{3,4}``|``Z_{3,5}``
``Z_4`` Lucky-Strike  |``Z_{4,1}``|``Z_{4,2}``|``Z_{4,3}``|``Z_{4,4}``|``Z_{4,5}`` 
``Z_5`` Parliament    |``Z_{5,1}``|``Z_{5,2}``|``Z_{5,3}``|``Z_{5,4}``|``Z_{5,5}``


"""

# ╔═╡ eb2e5e66-3525-4021-8543-c5be8c602a1b
md"""
Die fünf binären Matrizen können dem Modell `einstein_raetsel` als Variablen mit dem JuMP-Makro `@variable()` hinzugefügt werden.
"""

# ╔═╡ 9c68469c-2bcc-4e22-ac3f-ca6fcff03c65
begin
	@variable(einstein_raetsel, N[1:5, 1:5], Bin)
	@variable(einstein_raetsel, F[1:5, 1:5], Bin)
	@variable(einstein_raetsel, G[1:5, 1:5], Bin)
	@variable(einstein_raetsel, T[1:5, 1:5], Bin)
	@variable(einstein_raetsel, Z[1:5, 1:5], Bin)
end;

# ╔═╡ 2737e2ae-6ac3-4782-be33-ec319a665bf6
einstein_raetsel

# ╔═╡ 0c552418-0a4b-486b-88ea-b9c706a10cc1
md"""
Wie in der Definition des JuMP-Modells zu sehen ist, existieren nun ``125`` Variablen. Hierbei handelt es sich um die jeweils ``25`` Variablen der fünf Eigenschaften. Zusätzlich resultiert die Erzeugung der Variablen in ``125`` `MathOptInterface.ZeroOne` Nebenbedingungen. Hierbei handelt es sich um Nebenbedingungen, die die Variablen auf den Wert ``0`` oder ``1`` begrenzen, was bei  den ``125`` angelegten binären Variablen der Fall ist.
"""

# ╔═╡ 2b2d3b35-9109-44f7-8c85-8257e94cd75b
md"""
Zu diesem Zeitpunkt existieren für die Zustände einer Eigenschaften ``5^5`` mögliche Lösungen. Dies entspricht einer Anzahl von ``(5^5)^5`` möglichen Kombinationen für alle Eigenschaften. Wenn jetzt noch die relative Position der Häuser zueinander betrachtet wird, ergeben sich für das Optimierungsproblem ``(5^{25})^5`` mögliche Lösungen. Dies entspricht einer Zahl von ``931.322.574.615.479.000.000``. Diese beinhalten auch Kombinationen, die keinen Sinn ergeben und nicht vom Menschen ausprobiert werden würden. Dennoch zeigt dies auf, wie wichtig es ist Nebenbedingungen für die Modellvariablen zu erstellen, denn selbst wenn für das Erzeugen einer Lösung und Überprüfen auf das Einhalten der Hinweise nur eine Nanosekunde benötigt wird, dann würde dies in etwa ``30.000`` Jahren benötigen. 
"""

# ╔═╡ 637971d6-47ed-4c39-93e8-a3e2c813ab1b
md"""
###### Nebenbedingungen der Modellvariablen
Um die Anzahl der möglichen Lösung zu reduzieren, soll die aus der Aufgabenstellung bekannte Information, dass jede Eigenschaft mit nur einem Zustand pro Haus vertreten ist und jeder Zustand nur einmal in allen fünf Häusern vorkommen darf, berücksichtigt werden. Diese Information kann als Nebenbedingungen für die einzelnen Modellvariablen definiert werden. Im Folgenden werden die neuen Nebenbedingungen am Beispiel der Nationalität gezeigt:

$$\sum_{i=1}^5 N_{i,j} = 1 ; \quad (1) \quad \sum_{j=1}^5 N_{i,j} = 1 ; \quad (2) \quad \sum_{i=1}^5\sum_{j=1}^5 N_{i,j} = 5 \quad (3).$$ 


Diese Nebenbedingungen gelten ebenfalls für alle weiteren Eigenschaften und können dem Modell `einstein_raetsel` mit dem JuMP-Makro `@constraint()` hinzugefügt werden.

"""

# ╔═╡ 37f0e178-2c0f-43d7-a742-1c5fced1460e
begin
	@constraints(einstein_raetsel, begin 
		[i in 1:5], sum(N[i, :]) 	== 1 
		[i in 1:5], sum(F[i, :]) 	== 1
		[i in 1:5], sum(G[i, :]) 	== 1
		[i in 1:5], sum(T[i, :]) 	== 1
		[i in 1:5], sum(Z[i, :]) 	== 1
		end)

	@constraints(einstein_raetsel, begin 
		[j in 1:5], sum(N[:, j]) 	== 1 
		[j in 1:5], sum(F[:, j]) 	== 1
		[j in 1:5], sum(G[:, j]) 	== 1
		[j in 1:5], sum(T[:, j]) 	== 1
		[j in 1:5], sum(Z[:, j]) 	== 1
		end)

	@constraints(einstein_raetsel, begin 
					sum(N[:, :]) 	== 5 
					sum(F[:, :]) 	== 5
					sum(G[:, :])  	== 5
					sum(T[:, :]) 	== 5
					sum(Z[:, :]) 	== 5
					end)
end;

# ╔═╡ 32972424-fc07-43d5-a528-1476a10e1aff
einstein_raetsel

# ╔═╡ bf1508bd-cd99-4e7c-a7c9-7aa04fcc18a6
md"""
Nachdem die ersten drei Nebenbedingungen  ``(1)``, ``(2)``, ``(3)`` für alle fünf Eigenschaften dem JuMP-Modell hinzugefügt worden sind, besitzt das Modell nun ``55`` weitere Nebenbedingungen. Hierbei handelt es sich um `MathOptInterface.EqualTo` Bedingungen, die, wie der Name schon sagt, eine Gleichheit fordern.
Die Gleichung ``(1)`` und ``(2)`` erzeugen jeweils fünf Nebenbedingung für jede Eigenschaft und die Gleichung ``(3)`` Eine.\
Die dritte aufgestellte Gleichung ist hier zwar als Nebenbedingung formuliert, könnte aber auch als Zielfunktion definiert werden. Wenn die Summe aller Matrizenwerte einer Eigenschaft gleich ``5`` ist, dann sind alle Zustände der Eigenschaft verteilt und somit ist das Ziel erreicht.
"""

# ╔═╡ 3db2ecdb-8b2e-4663-bba4-214207ea55b2
md"""### Hinweise des Rätsels"""

# ╔═╡ 6a14e3b1-1ea4-4b6d-b03e-36e3c59f26a7
md"""
In diesem Abschnitt werden die restlichen 15 Hinweise des Rätsels als Nebenbedingungen mathematisch formuliert und dem Modell `einstein_raetsel` mit dem JuMP-Makro `@constraints()` als Bedingungen hinzugefügt.
Prinzipiell könnten die Nebenbedingungen auch alle in einem `@constraints()` JuMP-Makro dem Modell hinzugefügt werden, auf Grund der folgenden Gliederung wurde hierauf verzichtet.\
Bei der Formulierung der Hinweise zu Nebenbedingungen wird die Hausnummer ``j`` mit den Zuständen der Modellvariablen multipliziert, damit in Summe die Nebenbedingungen für jede Hausnummer erfüllt sind.
"""

# ╔═╡ ab29401d-777e-4aef-aff1-1e1ddbf24a6a
md"""
###### Hinweis 2 
Der Engländer wohnt im roten Haus. 

$$\sum_{j=1}^5 j \cdot (N_{1,j} - F_{1,j}) = 0 \qquad (4)$$ 
"""

# ╔═╡ 83e7de3d-4d9f-4b3e-8056-c1e1f96d518f
@constraint(einstein_raetsel, 
	sum(j * (N[1, j] - F[1, j]) for j in 1:5) == 0);

# ╔═╡ b36b9bcc-4867-40f6-9092-6b06a95d5bd2
md"""
###### Hinweis 3 
Der Spanier hat einen Hund.

$$\sum_{j=1}^5 j \cdot (N_{2,j} - T_{1,j}) = 0 \qquad (5)$$ 
"""

# ╔═╡ 2d7e6db8-4e48-407b-9a69-115b4b848f40
@constraint(einstein_raetsel, 
	sum(j * (N[2, j] - T[1, j]) for j in 1:5) == 0);

# ╔═╡ 1559d56d-7043-47ab-bc93-b825890f8c4e
md"""
###### Hinweis 4 
Kaffee wird im grünen Haus getrunken.

$$\sum_{j=1}^5 j \cdot (G_{1,j} - F_{2,j}) = 0\qquad (6)$$ 
"""

# ╔═╡ a387c3a0-c661-497f-b903-a988afde4638
@constraint(einstein_raetsel, 
	sum(j * (G[1, j] - F[2, j]) for j in 1:5) == 0);

# ╔═╡ acda2eb2-f749-482d-94af-9a737c32be2a
md"""
###### Hinweis 5 
Der Ukrainer trinkt Tee.

$$\sum_{j=1}^5 j \cdot (N_{3,j} - G_{2,j}) \qquad (7)$$ 
"""

# ╔═╡ 5d4ef4b9-4d2d-4ad7-9c3d-8c2522cfc850
@constraint(einstein_raetsel, 
	sum(j * (N[3, j] - G[2, j]) for j in 1:5) == 0);

# ╔═╡ 04fc361d-2020-4e82-9e00-732d8a6d02d5
md"""
###### Hinweis 6 
Das grüne Haus ist direkt links vom weißen Haus.

$$\sum_{j=1}^5 j \cdot (F_{2,j} - F_{3,j+1}) = 0; \qquad (8)$$ 
"""

# ╔═╡ 2ff117af-b038-416e-9edf-e4595bd4efa9
@constraint(einstein_raetsel, 
	sum(j * (F[2, j] - get(F,(3, j+1),0)) for j in 1:5) == 0);

# ╔═╡ 77bfe36f-00ab-4b40-85f0-c986c8610bfc
md"""
In dem Fall von ``F_{3,j+1}`` muss die Funktion `get()` verwendet werden, um den Wert aus der Matrix der Hausfarbe ``F`` zu erlangen. Diese nimmt den Ersatzwert ``0`` an, wenn es keine Lösung für ``F_{3,j}`` gibt und zwar immer dann wenn ``j`` den erlaubten Wertebereich ``0 \leq j \leq  5`` verlässt.
"""

# ╔═╡ c853c705-61ee-46af-abd9-4d9ce033cde2
md"""
###### Hinweis 7 
Der Raucher von Old-Gold-Zigaretten hält Schnecken als Haustiere.

$$\sum_{j=1}^5 j \cdot (Z_{1,j} - T_{2,j}) =  0 \qquad (9)$$ 
"""

# ╔═╡ 0c953445-6136-4129-8321-dbd922e71783
@constraint(einstein_raetsel, 
	sum(j * (Z[1, j] - T[2, j]) for j in 1:5) == 0);

# ╔═╡ dca5eeca-1fbc-419c-9a29-6200cd9badf3
md"""
###### Hinweis 8 
Die Zigaretten der Marke Kools werden im gelben Haus geraucht.

$$\sum_{j=1}^5 j \cdot (Z_{2,j} - F_{4,j}) =  0 \qquad (10)$$ 
"""

# ╔═╡ 9fd86a07-18cb-437a-b655-9cdc9ca43814
@constraint(einstein_raetsel, 
	sum(j * (Z[2, j] - F[4, j]) for j in 1:5) == 0);

# ╔═╡ c55aaad9-9a3f-4ee0-bb5c-1a09e2719cb4
md"""
###### Hinweis 9 
Milch wird im mittleren Haus getrunken.

$$G_{3,3} = 1 \qquad (11)$$ 
"""

# ╔═╡ 8c93d7cb-3bd3-4da0-bd9b-c6aa0c4f8db0
@constraint(einstein_raetsel,
	1 - G[3, 3] == 0);

# ╔═╡ cdd8a024-0605-4cda-b88e-dd6e0e463420
md"""
###### Hinweis 10
Der Norweger wohnt im ersten Haus.

$$N_{4,1} = 1 \qquad (12)$$ 
"""


# ╔═╡ 327d57eb-c5c2-4461-8600-efaa59793a26
@constraint(einstein_raetsel,
	1 - N[4, 1] == 0);

# ╔═╡ 9b599e67-819f-4813-a50a-45a7be8c7b61
md"""
Da es sich bei der Nebenbedingung ``(11)`` und ``(12)`` um Tatsachen handelt, könnte die Matrix für die Eigenschaft "Getränke" an der Stelle ``G_{3,3}`` und die Matrix für die Eigenschaft "Nationalität" an der Stelle ``N_{4,1}``, noch vor dem Lösen des Optimierungsproblems, mit einer ``1`` beschrieben werden.
"""

# ╔═╡ 29195a7f-cc17-4c40-b0f0-886b918575e2
md"""
###### Hinweis 11 
Der Mann, der Chesterfields raucht, wohnt neben dem Mann mit dem Fuchs.

$$\sum_{j=1}^5 j \cdot (T_{3,j} - Z_{3,j}) =  1 - (2 \cdot D_1) \qquad (13)$$ 
"""


# ╔═╡ 913e64b7-52c9-494e-b615-917084bad955
md"""
Um die relative Position der zweiten Modellvariable (Zigarettenmarke) zur ersten Modellvariable (Haustier) zu beschreiben, wird eine dritte binäre Entscheidungsvariable definiert. Diese wird benötigt, da es sich hier um eine entweder/oder Nebenbedingung handelt, die für den "entweder" und den "oder" Fall erfüllt sein muss. Da der Unterscheid zwischen den beiden Häusern entweder ``+1`` oder ``-1`` ist, kann eine Gleichung mit der Entscheidungsvariable ``D_1`` definiert werden, dessen Lösung ``1 - (2 \cdot D_1)`` entspricht.\
Diese Art der Nebenbedingung kommt ebenfalls bei den Hinweisen 12, 15 und 16 zum Einsatz.\
"""

# ╔═╡ 5bd60068-4346-4bbf-a010-ccba5eb582f9
@variable(einstein_raetsel, D[1:4], Bin);

# ╔═╡ 48557c79-80e1-4ab2-bd8f-9c37c43ba936
@constraint(einstein_raetsel, 
	sum(j * (T[3, j] - Z[3, j]) for j in 1:5) == 1 - (2 * D[1]));

# ╔═╡ e47394d4-9ff6-487b-a35e-d19b0b710b08
md"""
Im Beispiel von Hinweis 11 bedeutet ``D_1 = 0``, dass die Zigarettenmarke Chesterfields direkt links vom Haus mit dem Fuchs geraucht wird und wenn ``D_1 = 1``, rechts vom Haus mit dem Fuchs.
"""

# ╔═╡ 677dc17f-6989-49f9-9046-dee43e4fff16
md"""
###### Hinweis 12
Die Marke Kools wird geraucht im Haus neben dem Haus mit dem Pferd.

$$\sum_{j=1}^5 j \cdot (T_{4,j} - Z_{2,j})  = 1 - (2 \cdot D_2) \qquad (14)$$ 
"""

# ╔═╡ 00ee3133-4520-498a-821f-120a7d961f0b
@constraint(einstein_raetsel, 
	sum(j * (T[4, j] - Z[2, j]) for j in 1:5) == 1 - (2 * D[2]));

# ╔═╡ 925a10eb-9eea-42ce-878a-71582fd75baa
md"""
###### Hinweis 13
Der Lucky-Strike-Raucher trinkt am liebsten Orangensaft.

$$\sum_{j=1}^5 j \cdot (Z_{4,j} - G_{4,j}) =  0 \qquad (15)$$ 

"""

# ╔═╡ 0f9e0b22-f72e-45cc-90cc-50e92e3cbb1f
@constraint(einstein_raetsel, 
	sum(j * (Z[4, j] - G[4,j]) for j in 1:5) == 0);

# ╔═╡ b868be45-8ecd-48bb-99e7-6341cb25b6ec
md"""
###### Hinweis 14
Der Japaner raucht Zigaretten der Marke Parliaments.

$$\sum_{j=1}^5 j \cdot (N_{5,j} - Z_{5,j}) =  0 \qquad (16)$$ 
"""

# ╔═╡ 3c287869-3e65-44e6-9f83-722379ac856e
@constraint(einstein_raetsel, 
	sum(j * (N[5, j] - Z[5,j]) for j in 1:5) == 0);

# ╔═╡ 5d8419e7-4f42-4695-8fd6-33e9e5a19fb0
md"""
###### Hinweis 15
Der Norweger wohnt neben dem blauen Haus.

$$\sum_{j=1}^5 j \cdot (N_{4,j} - F_{5,j}) = 1 - (2 \cdot D_3); \qquad (17)$$ 

"""

# ╔═╡ 6f98edd3-9d6c-435a-90cf-8dbaebc50aba
@constraint(einstein_raetsel, 
	sum(j * (N[4, j] - F[5, j]) for j in 1:5) == 1 - (2 * D[3]));

# ╔═╡ b3bc867f-d188-47f4-8c91-2c822736031a
md"""
###### Hinweis 16
Der Chesterfields-Raucher hat einen Nachbarn, der Wasser trinkt.

$$\sum_{j=1}^5 j \cdot (Z_{3,j} - G_{5,j}) =  1 - (2 \cdot D_4); \qquad (18)$$ 

"""

# ╔═╡ 55fbd7db-29e6-4533-a919-0ad6f95c151c
@constraint(einstein_raetsel, 
	sum(j * (Z[3, j] - G[5, j]) for j in 1:5) == 1 - (2 * D[4]));

# ╔═╡ dbe83cb8-8e92-40a5-a6de-afbc91811c41
md"""
###### Erkenntnis
Da es sich bei den Nebenbedingungen ``(11)`` und ``(12)`` um Tatsachen handelt, könnten diese Zustände direkt in die Matrix für die jeweilige Eigenschaft eingefügt werden und somit die beiden Nebenbedingungen entfallen. Da der Löser genau dies tut und zwar deutlich schneller als von Hand, wird hierauf verzichtet.\
Unter Berücksichtigung der Nebenbedingung ``(12)`` kann der Hinweis 15 und somit die Nebenbedingung ``(17)`` ebenfalls direkt gelöst werden, denn wenn der Norweger im ersten Haus wohnt ``N_{4,1} = 1``, dann kann das blaue Haus nur das Zweite sein. Diese Schlussfolgerung nennt sich Bedingungsfortpflanzung und ist bei dieser Art von Optimierungsproblemen üblich. Daher könnte hier ebenfalls die Matrix für die Eigenschaft "Hausfarbe" beschrieben werden und die Nebenbedingung entfallen. Auf dies wird aber ebenfalls verzichtet.
"""

# ╔═╡ 123cba50-92dd-4133-b33e-d3a5c973e1fb
einstein_raetsel

# ╔═╡ 28dbe5d7-7dc3-4763-b217-6bcf6d5b86b6
md"""
Nachdem die restlichen 15 Hinweise als Nebenbedingungen formuliert und dem Modell `einstein_raetsel` hinzugefügt sind, besitzt das Modell ``70`` `MathOptInterface.EqualTo` Nebenbedingungen. Zusätzlich kommt durch die Entscheidungsvariable ``D``  weitere ``4`` `MathOptInterface.ZeroOne` Nebenbedingungen hinzu.\
Nun ist das Rätsel vollständig mit allen Modellvariablen und Nebenbedingungen in das JuMP-Modell `einstein_raetsel` übertragen und der Lösungsprozess kann beginnen.
"""

# ╔═╡ e1ff982b-95a9-45dd-ba5b-0347ee80824d
md"""### Optimierung des Modells"""

# ╔═╡ 38a7d76b-c845-49b9-88bd-6ef57ae7863a
md"""
Das Lösen des Optimierungsproblems ist, nachdem alle Modellvariablen und Nebenbedingungen formuliert und definiert sind, der einfachste Teil der Arbeit.
Mit der Funktion `optimize!()` kann das erzeugte JuMP-Modell `einstein_raetsel` mit dem gewählten Löser `GLPK.Optimizer` gelöst werden.
"""

# ╔═╡ 1cd97d8d-b091-4bce-b3d5-a94e4392b9cd
optimize!(einstein_raetsel)

# ╔═╡ ee4a67e6-8af2-4d5e-9b9a-24a72e08978c
solution_summary(einstein_raetsel)

# ╔═╡ 0d274cfe-4ea6-4998-ab50-59574604db96
md"""
Die Funktion `solution_summary` gibt eine Auskunft über die vom Löser gefundene Lösung. Im Allgemeinen Fall können, wie bereits erwähnt, bei Optimierungsproblemen mehrere Ergebnisse richtig sein. Im Falle vom "Einstein Rätsel" gibt es aber nur eine richtige Lösung. Der `Termination status`, `Primal status` sowie der `Dual status` informieren, ob die gefundene Lösung, die "Richtige" ist.\
Als Status der Lösung gibt die Funktion `solution_summary` zu erkennen, dass eine optimale Lösung an einem zulässigen Punkt und keine doppelte Lösung gefunden worden ist. Die `Candidate Solution` gibt im Falle des `einstein_raetsel` Modells kein Ergebnis der Zielfunktion, da die Zielfunktion als Nebenbedingung ``(3)`` definiert ist. Tatsächlich handelt es sich bei dem "Einstein Rätsel" nicht um ein Optimierungsproblem mit einer Zielvorgabe, sondern um ein Machbarkeitsproblem, das einem Optimierungsproblem mit einer Zielvorgabe von ``0`` entspricht.\
Die benötigte Zeit zum Lösen des Modells ist immer unterschiedlich und hängt von der Leistung des verwendeten Computers und Browser ab. 
"""

# ╔═╡ 5c6c3773-b4f9-4b5e-a4e6-48a4f7af2f89
md"""### Ausgabe der Lösung"""

# ╔═╡ a3f747fd-822b-4d07-929a-3ebf59752722
md"""
Ist eine optimale Lösung gefunden, kann der optimale Zustand der Modellvariablen mit der Funktion `value.(Modellvariable)` ausgegeben werden. Hierbei steht in der Matrix, wie bereits bei den Modellvariablen beschrieben, die Spaltenzahl für die Hausnummer und die Zeilen für die möglichen Zustände der Eigenschaft.\
Am Beispiel der Eigenschaft "Nationalität" sieht die Lösungsmatrix wie folgt aus:
"""

# ╔═╡ cb8f8606-3c9e-42cb-830f-a3566e83b672
value.(N)

# ╔═╡ e6538c57-b754-462b-9805-20fa24ae6c1c
md"""
Um das Ergebnis der Optimierung, also die Lösung für die Matrix der "Nationalität", besser zu verstehen wird hier nochmals die Matrix der Modellvariablen ``N_{i,j}`` gezeigt.

 Nationalität ``N_i``|Haus ``H_1``|Haus ``H_2``|Haus ``H_3``|Haus ``H_4``|Haus ``H_5``
:--------------------|:---------:|:---------:|:---------:|:---------:|:---------:
``N_1`` Engländer    |``N_{1,1}``|``N_{1,2}``|``N_{1,3}``|``N_{1,4}``|``N_{1,5}`` 
``N_2`` Spanier      |``N_{2,1}``|``N_{2,2}``|``N_{2,3}``|``N_{2,4}``|``N_{2,5}`` 
``N_3`` Ukrainer     |``N_{3,1}``|``N_{3,2}``|``N_{3,3}``|``N_{3,4}``|``N_{3,5}``
``N_4`` Norweger     |``N_{4,1}``|``N_{4,2}``|``N_{4,3}``|``N_{4,4}``|``N_{4,5}`` 
``N_5`` Japaner      |``N_{5,1}``|``N_{5,2}``|``N_{5,3}``|``N_{5,4}``|``N_{5,5}``


"""

# ╔═╡ 8f9ea444-d23a-4424-9d32-d871a13d022d
md"""
Letztlich kann einfach abgelesen werden in welchem Haus welche Nationalität vorkommt. In Haus 1 der Norweger, in Haus 2 der Ukrainer, in Haus 3 der Engländer in Haus 4 der Japaner und in Haus 5 der Spanier. Diese Art des manuellen Ablesens und Bestimmen der Zustände müsste nun für jede Modellvariable wiederholt werden, um die gefundene  Lösung in eine Tabelle überführen zu können. Dieser Prozess kann jedoch deutlich schneller und fehlerfreier mit ein paar `for`-Schleifen und `if`-Abfragen erledigt werden.\
Hierfür müssen zuerst die Namen der Zustände in Variablen für die jeweiligen Eigenschaften definiert werden. Mit der Funktion `split(Zustände)` werden für die Eigenschaften Nationalität ``n``, Hausfarbe ``f``, Haustier ``t``, Getränk ``g`` und Zigarettenmarke ``z`` `SubString`-Arrays mit den jeweils möglichen Zustände angelegt. Dabei ist darauf zu achten, dass die gleiche Reihenfolge wie bei der Erstellung der Modellvariablen eingehalten wird. Die Variablen ``n``, ``f``, ``t``, ``g`` und ``z`` werden im nächsten Schritt benötigt, um die optimalen Zustände der Modellvariablen für die Häuser in ein `String`-Array zu schreiben.
"""

# ╔═╡ 26373449-9954-4b76-b630-3b66fc631aeb
begin
	n = split("Engländer Spanier Ukrainer Norweger Japaner");
	f = split("rot grün weiß gelb blau");
	t = split("Hund Schnecken Fuchs Pferd Zebra");
	g = split("Kaffee Tee Milch Orangensaft Wasser");
	z = split("Old-Gold Kools Chesterfield Lucky-Strike Parliament");
end;

# ╔═╡ f565b9a6-9068-4113-8ab4-465d62c5d15a
md"""
Im nächsten Schritt wird ein leeres `5x5` String-Array erzeugt, um die Eigenschaften für die fünf verschiedenen Häuser aufzulisten. Hierbei steht die Spaltennummer für die Hausnummer und die Zeilen für die Eigenschaft in folgender Reihenfolge: Nationalität, Hausfarbe, Haustier, Getränk und Zigarettenmarke. Zur übersichtlicheren Darstellung wird das Array `S` später in einem `DataFrame` tabellarisch dargestellt.
"""

# ╔═╡ bba6a08f-360c-478c-a408-aa407c2d4530
S = Array{Union{Nothing, String}}(nothing, 5, 5)

# ╔═╡ a494dd4f-6325-429b-9157-c109531d563b
md"""
Das Array `S` kann nun mit zwei `for`-Schleifen, eine für die Zustände ``i`` der Eigenschaften und eine für die Hausnummer ``j``, befüllt werden. Innerhalb beider `for`-Schleifen befinden sich fünf `if`-Abfragen für die Modellvariablen ``N``, ``F``, ``T``, ``G`` und ``Z``.\
Wenn beispielsweise die `if`-Abfrage ``N_{3,3} == 1`` erfüllt wäre, dann würde die der Stringwert von ``n_4`` an die Stelle ``S_{1,3}`` geschrieben werden.
"""

# ╔═╡ 7f3aece5-c49e-4614-94ae-d3048516d3c6
begin
	for i in 1:5
		for j in 1:5
			if value.(N)[i, j] == 1 
				S[1,j] = n[i]
			end
			
			if value.(F)[i, j] == 1 
				S[2,j] = f[i]
			end
			
			if value.(T)[i, j] == 1 
				S[3,j] = t[i]
			end
			
			if value.(G)[i, j] == 1 
				S[4,j] = g[i]
			end
			
			if value.(Z)[i, j] == 1 
				S[5,j] = z[i]
			end			
		end
	end
end


# ╔═╡ b4794043-8d35-4ef3-bed5-b9ba9fab585a
md"""
Nachdem die beiden `for`-Schleifen durchlaufen sind, sieht das Array wie folgt aus:
"""

# ╔═╡ 28711d41-d183-4c65-83aa-128cb96d1bfb
S

# ╔═╡ 78a10fe0-221d-4797-880e-2dccf89de052
md"""
Um die Lösung etwas übersichtlicher darzustellen, lohnt sich eine Umformung des Arrays in ein `DataFrame`. Diese werden bei Pluto.jl als Tabelle dargestellt. Nach einer Erweiterung der Lösung um eine Spalte mit den Eigenschaften und einer Kopfzeile sieht die `Lösungsmatrix` wie folgt aus:
"""

# ╔═╡ b3350a07-f4f9-463b-b976-f5660ada1557
Lösungsmatrix = DataFrame(
		Eigenschaft = split("Nationalität Farbe Tier Getränk Zigaretten"), 
		Haus_1 = S[:,1], 
		Haus_2 = S[:,2], 
		Haus_3 = S[:,3], 
		Haus_4 = S[:,4], 
		Haus_5 = S[:,5])

# ╔═╡ 8a2a5059-ee5a-4de2-9013-9d9ab27c1399
md"""
Nun können die aus der Fragestellung bekannten Fragen beantwortet werden. Einerseits könnten diese einfach aus der Tabelle abgelesen werden indem nach dem Getränk und dem Tier gesucht wird. Andererseits um das Ganze etwas zu vereinfachen, werden wieder zwei `for`-Schleifen verwendet, um im `Array` ``S`` nach dem Getränk ``Wasser`` und dem Haustier ``Zebra`` zu suchen. Ist das Haus in dem ``Wasser`` getrunken wird, sowie das Haus in dem das ``Zebra`` wohnt, gefunden, wird die Nationalität des jeweiligen Hauses mit der Eigenschaft in Verbindung gebracht. Die gefundenen Nationalitäten werden dann in bereits vorformulierte Lückentexte eingefügt und in dem `Array` ``result`` gespeichert.
"""

# ╔═╡ 001e539b-e9a9-4248-861f-168702403065
begin
	result = Array{Union{Nothing, String}}(nothing, 2, 1)
	for i in 1:5
		for j in 1:5
			if S[i,j] == "Wasser"
				result[1,1] = string("Der ", S[1,j], " trinkt ", S[i,j], ".")
			end
			if S[i,j] == "Zebra"
				result[2,1] = string("Dem ", S[1,j], " gehört das ", S[i,j], ".")
			end
		end
	end 
end

# ╔═╡ 1ef35d33-c4b8-4bb7-b09e-d3190954a7d0
md"""
Die Antwort auf die Fragen, wer trinkt Wasser und wem gehört das Zebra, lautet wie folgt:
"""

# ╔═╡ e3abcdba-e840-44a9-869b-932287996a2f
result

# ╔═╡ 3813a5a5-66af-4878-86ca-24c127986449
md"""## Literaturverzeichnis

[1] Plenert, G. J. 2014: Supply Chain Optimization Through Segmentation and Analytics, CRC Press, London.\

[2] Gregor, M.; Zábovská, K.; Smataník, V. 2015: The zebra puzzle and getting to know your tools. Intelligent Engineering Systems (INES), 2015 IEEE 19th International Conference on: IEEE; pp. 159-164.\

[3] Crabtree, J.; Zhang, X. 2015: Recognizing and Managing Complexity: Teaching Advanced Programming Concepts and Techniques Using the Zebra Puzzle, Journal of Information Technology Education: Innovations in Practice, 14 pp. 171-189.\

[4] Browne, C. 2013: Deductive search for logic puzzles. Computational Intelligence in Games (CIG), 2013 IEEE Conference on: IEEE; pp. 1-8.\

[5] Kumar, V. 1992: Algorithms for constraint-satisfaction problems: A survey, AI magazine, 13 (1), pp. 32-44.\

[6] Smith, B. M. 2001: Constructing an asymptotic phase transition in random binary constraint satisfaction problems, Theoretical Computer Science, 265 (1), pp. 265-283, https://doi.org/10.1016/S0304-3975(01)00166-9\

[7] Makhorin, A. 2012: GLPK (GNU Linear Programming Kit), [Online], Available: https://www.gnu.org/software/glpk/


"""

# ╔═╡ 6d26cf21-b684-4780-99b5-72bd833499de
md"""## Anhang"""

# ╔═╡ 67da20bd-ae64-43e7-9bdc-3211451ae334
md"""
Es folgt der für diese Arbeit implementierte - zusammengefasste - Julia/(JuMP)-Code:
"""

# ╔═╡ 99ebdfb5-50c6-44a8-ae95-42f8b5717f61
#.	#Thema E Modellierung logischer Aussagen das "Einstein Rätsel".
#.	
#.	#Benötigte Packages
#.	using JuMP
#.	using GLPK
#.	
#.	#Erzeugung des Modells und Wahl des Optimierers
#.	einstein_raetsel = Model(GLPK.Optimizer)
#.
#. 	#Erzeugung der Modellvariablen 5x5-Matrix für die fünf Eigenschaften
#.	@variable(einstein_raetsel, N[1:5, 1:5], Bin)
#.	@variable(einstein_raetsel, F[1:5, 1:5], Bin)
#.	@variable(einstein_raetsel, G[1:5, 1:5], Bin)
#.	@variable(einstein_raetsel, T[1:5, 1:5], Bin)
#.	@variable(einstein_raetsel, Z[1:5, 1:5], Bin)
#.	@variable(einstein_raetsel, D[1:4], Bin)
#.
#.	#Nebenbedingung, dass die Zustände einer Eigenschaft nur einmal vorkommen dürfen
#.	@constraints(einstein_raetsel, begin
#.		[i in 1:5], sum(N[i, :]) 	== 1
#.		[i in 1:5], sum(F[i, :]) 	== 1
#.		[i in 1:5], sum(G[i, :]) 	== 1
#.		[i in 1:5], sum(T[i, :]) 	== 1
#.		[i in 1:5], sum(Z[i, :]) 	== 1
#.		end)
#.	
#.	#Nebenbedingung, dass eine Eigenschaft pro Haus nur einmal vorkommen darf
#.	@constraints(einstein_raetsel, begin
#.		[j in 1:5], sum(N[:, j]) 	== 1
#.		[j in 1:5], sum(F[:, j]) 	== 1
#.		[j in 1:5], sum(G[:, j]) 	== 1
#.		[j in 1:5], sum(T[:, j]) 	== 1
#.		[j in 1:5], sum(Z[:, j]) 	== 1
#.		end)
#.	
#.	#Nebenbedingung, dass fünf Zustände einer Eigenschaft vorkommen müssen
#.	@constraints(einstein_raetsel, begin
#.					sum(N[:, :]) 	== 5
#.					sum(F[:, :]) 	== 5
#.					sum(G[:, :])  	== 5
#.					sum(T[:, :]) 	== 5
#.					sum(Z[:, :]) 	== 5
#.					end)
#.	
#.	#Abgeleitet Nebenbedingungen aus den Hinweisen 2-15
#.	@constraint(einstein_raetsel, sum(j * (N[1, j] - F[1, j]) for j in 1:5) == 0);
#.	@constraint(einstein_raetsel, sum(j * (N[2, j] - T[1, j]) for j in 1:5) == 0);
#.	@constraint(einstein_raetsel, sum(j * (G[1, j] - F[2, j]) for j in 1:5) == 0);
#.	@constraint(einstein_raetsel, sum(j * (N[3, j] - G[2, j]) for j in 1:5) == 0);
#.	@constraint(einstein_raetsel, sum(j * (F[2, j] - get(F,(3, j+1),0)) for j in 1:5) == 0);
#.	@constraint(einstein_raetsel, sum(j * (Z[1, j] - T[2, j]) for j in 1:5) == 0);
#.	@constraint(einstein_raetsel, sum(j * (Z[2, j] - F[4, j]) for j in 1:5) == 0);
#.	@constraint(einstein_raetsel, 1 - G[3, 3] == 0);
#.	@constraint(einstein_raetsel, 1 - N[4, 1] == 0);
#.	@constraint(einstein_raetsel, sum(j * (T[3, j] - Z[3, j]) for j in 1:5) == 1 - (2 * D[1]));
#.	@constraint(einstein_raetsel, sum(j * (T[4, j] - Z[2, j]) for j in 1:5) == 1 - (2 * D[2]));
#.	@constraint(einstein_raetsel, sum(j * (Z[4, j] - G[4,j]) for j in 1:5) == 0);
#.	@constraint(einstein_raetsel, sum(j * (N[5, j] - Z[5,j]) for j in 1:5) == 0);
#.	@constraint(einstein_raetsel, sum(j * (N[4, j] - F[5, j]) for j in 1:5) == 1 - (2 * D[3]));
#.	@constraint(einstein_raetsel, sum(j * (Z[3, j] - G[5, j]) for j in 1:5) == 1 - (2 * D[4]));
#.	
#.	#Optimierung des Modells
#.	optimize!(einstein_raetsel)
#.	
#. 	#Deklarierung der Zustände in String-Variablen
#.	n = split("Englaender Spanier Ukrainer Norweger Japaner");
#.	f = split("rot gruen weiß gelb blau");
#.	t = split("Hund Schnecken Fuchs Pferd Zebra");
#.	g = split("Kaffee Tee Milch Orangensaft Wasser");
#.	z = split("Old-Gold Kools Chesterfield Lucky-Strike Parliament");
#.	
#. 	#Erzeugung der Lösungsmatrix und Antworten auf die Fragen, wenn optimale Lösung gefunden
#.	if termination_status(einstein_raetsel) == MOI.OPTIMAL && primal_status(einstein_raetsel) == MOI.FEASIBLE_POINT
#.
#.		#Erzeugung der Lösungsmatrix S
#.	    S = Array{Union{Nothing, String}}(nothing, 5, 5)
#.	    	for i in 1:5
#.	    		for j in 1:5
#.	    			if value.(N)[i, j] == 1
#.	    				S[1,j] = n[i]
#.	    			end
#.	    			if value.(F)[i, j] == 1
#.	    				S[2,j] = f[i]
#.	    			end
#.	    			if value.(T)[i, j] == 1
#.	    				S[3,j] = t[i]
#.	    			end
#.	    			if value.(G)[i, j] == 1
#.	    				S[4,j] = g[i]
#.	    			end
#.	    			if value.(Z)[i, j] == 1
#.    				S[5,j] = z[i]
#.	    			end
#.	    		end
#.	    	end
#.	
#.		#Erzeugung des Arrays für die Antworten auf die Fragen
#.	    result = Array{Union{Nothing, String}}(nothing, 2, 1)
#.	    	for i in 1:5
#.	    		for j in 1:5
#.	    			if S[i,j] == "Wasser"
#.						result[1,1] = string("Der ", S[1,j], " trinkt ", S[i,j], ".")
#.	    			end
#.	                if S[i,j] == "Zebra"
#.						result[2,1] = string("Dem ", S[1,j], " gehört das ", S[i,j], ".")
#.	                end
#.	            end
#.	        end
#.	    
#.	else
#.	    S = "Keine optimale Lösung gefunden."
#.		result = "Keine Antwort gefunden."
#.	end
#.	
#.	#Ausgabe der Lösung
#.	display(S)
#. 	display(result)



# ╔═╡ 808b32f9-a431-417b-977d-87b034ccd8d3
md"""
Der Code ist auskommentiert, da sonst Fehlermeldungen bezüglich doppelter Benennung  der Variablen etc. entstehen. Zur Ausführung in die Julia IDE einfügen und die `#.` entfernen.
"""

# ╔═╡ Cell order:
# ╟─30e9b066-6796-4670-98c7-be8476adebfd
# ╟─056db7e6-fb6d-4714-9dcb-21172a2cc31e
# ╟─a4143656-cdf5-11eb-3517-551d69401a1d
# ╟─91c0d672-99b2-4aa4-aa2e-5ea1ae4155a7
# ╟─7b2cf9ef-a01e-4dd8-a368-299de0c05462
# ╟─1d0fdde8-7164-48ae-8fea-619efbf1e934
# ╟─0f21d27d-e9e9-4493-b0d2-807e483377c8
# ╟─ffa1abe8-5586-452c-9ebf-93f782e26c5a
# ╟─acd3aca1-6287-4cd9-a3bc-e26fa78d940d
# ╟─1352d79e-94c4-4758-aeaa-7ef7281202a2
# ╠═782c2e02-3937-4665-9fdc-e87a37c25711
# ╟─b4afc5ce-4a0c-4bd9-b4f4-627e4125077a
# ╟─4598426b-fee1-4b19-ba68-e51cfa465bd7
# ╟─eb2e5e66-3525-4021-8543-c5be8c602a1b
# ╠═9c68469c-2bcc-4e22-ac3f-ca6fcff03c65
# ╟─2737e2ae-6ac3-4782-be33-ec319a665bf6
# ╟─0c552418-0a4b-486b-88ea-b9c706a10cc1
# ╟─2b2d3b35-9109-44f7-8c85-8257e94cd75b
# ╟─637971d6-47ed-4c39-93e8-a3e2c813ab1b
# ╠═37f0e178-2c0f-43d7-a742-1c5fced1460e
# ╟─32972424-fc07-43d5-a528-1476a10e1aff
# ╟─bf1508bd-cd99-4e7c-a7c9-7aa04fcc18a6
# ╟─3db2ecdb-8b2e-4663-bba4-214207ea55b2
# ╟─6a14e3b1-1ea4-4b6d-b03e-36e3c59f26a7
# ╟─ab29401d-777e-4aef-aff1-1e1ddbf24a6a
# ╠═83e7de3d-4d9f-4b3e-8056-c1e1f96d518f
# ╟─b36b9bcc-4867-40f6-9092-6b06a95d5bd2
# ╠═2d7e6db8-4e48-407b-9a69-115b4b848f40
# ╟─1559d56d-7043-47ab-bc93-b825890f8c4e
# ╠═a387c3a0-c661-497f-b903-a988afde4638
# ╟─acda2eb2-f749-482d-94af-9a737c32be2a
# ╠═5d4ef4b9-4d2d-4ad7-9c3d-8c2522cfc850
# ╟─04fc361d-2020-4e82-9e00-732d8a6d02d5
# ╠═2ff117af-b038-416e-9edf-e4595bd4efa9
# ╟─77bfe36f-00ab-4b40-85f0-c986c8610bfc
# ╟─c853c705-61ee-46af-abd9-4d9ce033cde2
# ╠═0c953445-6136-4129-8321-dbd922e71783
# ╟─dca5eeca-1fbc-419c-9a29-6200cd9badf3
# ╠═9fd86a07-18cb-437a-b655-9cdc9ca43814
# ╟─c55aaad9-9a3f-4ee0-bb5c-1a09e2719cb4
# ╠═8c93d7cb-3bd3-4da0-bd9b-c6aa0c4f8db0
# ╟─cdd8a024-0605-4cda-b88e-dd6e0e463420
# ╠═327d57eb-c5c2-4461-8600-efaa59793a26
# ╟─9b599e67-819f-4813-a50a-45a7be8c7b61
# ╟─29195a7f-cc17-4c40-b0f0-886b918575e2
# ╟─913e64b7-52c9-494e-b615-917084bad955
# ╠═5bd60068-4346-4bbf-a010-ccba5eb582f9
# ╠═48557c79-80e1-4ab2-bd8f-9c37c43ba936
# ╟─e47394d4-9ff6-487b-a35e-d19b0b710b08
# ╟─677dc17f-6989-49f9-9046-dee43e4fff16
# ╠═00ee3133-4520-498a-821f-120a7d961f0b
# ╟─925a10eb-9eea-42ce-878a-71582fd75baa
# ╠═0f9e0b22-f72e-45cc-90cc-50e92e3cbb1f
# ╟─b868be45-8ecd-48bb-99e7-6341cb25b6ec
# ╠═3c287869-3e65-44e6-9f83-722379ac856e
# ╟─5d8419e7-4f42-4695-8fd6-33e9e5a19fb0
# ╠═6f98edd3-9d6c-435a-90cf-8dbaebc50aba
# ╟─b3bc867f-d188-47f4-8c91-2c822736031a
# ╠═55fbd7db-29e6-4533-a919-0ad6f95c151c
# ╟─dbe83cb8-8e92-40a5-a6de-afbc91811c41
# ╟─123cba50-92dd-4133-b33e-d3a5c973e1fb
# ╟─28dbe5d7-7dc3-4763-b217-6bcf6d5b86b6
# ╟─e1ff982b-95a9-45dd-ba5b-0347ee80824d
# ╟─38a7d76b-c845-49b9-88bd-6ef57ae7863a
# ╠═1cd97d8d-b091-4bce-b3d5-a94e4392b9cd
# ╠═ee4a67e6-8af2-4d5e-9b9a-24a72e08978c
# ╟─0d274cfe-4ea6-4998-ab50-59574604db96
# ╟─5c6c3773-b4f9-4b5e-a4e6-48a4f7af2f89
# ╟─a3f747fd-822b-4d07-929a-3ebf59752722
# ╠═cb8f8606-3c9e-42cb-830f-a3566e83b672
# ╟─e6538c57-b754-462b-9805-20fa24ae6c1c
# ╟─8f9ea444-d23a-4424-9d32-d871a13d022d
# ╠═26373449-9954-4b76-b630-3b66fc631aeb
# ╟─f565b9a6-9068-4113-8ab4-465d62c5d15a
# ╟─bba6a08f-360c-478c-a408-aa407c2d4530
# ╟─a494dd4f-6325-429b-9157-c109531d563b
# ╠═7f3aece5-c49e-4614-94ae-d3048516d3c6
# ╟─b4794043-8d35-4ef3-bed5-b9ba9fab585a
# ╟─28711d41-d183-4c65-83aa-128cb96d1bfb
# ╟─78a10fe0-221d-4797-880e-2dccf89de052
# ╟─b3350a07-f4f9-463b-b976-f5660ada1557
# ╟─8a2a5059-ee5a-4de2-9013-9d9ab27c1399
# ╠═001e539b-e9a9-4248-861f-168702403065
# ╟─1ef35d33-c4b8-4bb7-b09e-d3190954a7d0
# ╟─e3abcdba-e840-44a9-869b-932287996a2f
# ╟─3813a5a5-66af-4878-86ca-24c127986449
# ╟─6d26cf21-b684-4780-99b5-72bd833499de
# ╟─67da20bd-ae64-43e7-9bdc-3211451ae334
# ╠═99ebdfb5-50c6-44a8-ae95-42f8b5717f61
# ╟─808b32f9-a431-417b-977d-87b034ccd8d3

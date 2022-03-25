# EinsteinRiddle_Pluto
Solving the Einstein Riddle using the Julia language and the JuMP optimization package.\
This project was created as part of the course "Applied Optimization" of my master studies at the University of Applied Sciences Munich. Hence the descripton is in german.

## Using EinsteinRiddle_Pluto.jl file
The script should be run with Pluto.jl. The file consists a basic description of the riddle and the used optimization algo.

## Das Rätsel
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

### Fragestellung
Die beiden folgenden Fragen sollen mit den Informationen aus der Beschreibung und den Hinweisen beantwortet werden.
- Wer trinkt Wasser? 
- Wem gehört das Zebra?

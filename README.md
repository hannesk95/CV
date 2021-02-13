# Person Image Segmentation

---

### Allgemeines:

Diese Projekt wurde im Rahmen der Computer Vision Vorlesung an der Technischen Universität München (TUM) im Sommersemester 2020 durchgeführt. Ziel dieses war es, eine Personen Image Semgentierung mittels konventioneller Computer Vision Methoden zu implementieren. 

---

### Vorraussetzungen:

- Getestete Matlab Release Versionen: R2019a, R2020a


- Auflistung notwendiger Matlab Zusatzmodule:
	- Computer Vision Toolbox
	- Image Processing Toolbox
	
---

### Start des Programms (2 Möglichkeiten):

1. Aufruf: start_gui (graphische Benutzeroberfläche wird gestartet)
	- 1.1.	Auswahl des Szenenordnerpfads
	- 1.2. 	Auswahl des 'virtuellen' Hintergrundbildes (wenn gewünscht)
	- 1.3. 	Auswahl der Kamera für linken und rechten Kanal über Dropdown Menü
	- 1.4. 	Auswahl der Tensorgröße (Anzahl der Nachfolgebilder N, unser Vorschlag: Tensorgröße = 3)
	- 1.5. 	Auswahl des Start Frames ab dem das Programm startet
	- 1.6.	Auswahl des Renderingmodus
		- foreground: Hintergrund wird ausgeblendet und Person (Fordergrund) ist sichtbar.
		- background: Fordergrund wird ausgeblendet (Person) und nur Hintergrund ist sichtbar.
		- overlay: 
		- substitute: Echter Hintergrund wird durch virtuellen Hintergrund ersetzt.
	- 1.7.	Mit "Play" wird Programm gestaret, "Pause" hält das Programm an, "Stop" beendet das Programm
	- 1.8.	Bei Auswahl der "Loop" Funktion startet das Programm nach Durchlauf aller Frames im Szenen Ordner wieder beim ersten Frame
	- 1.9.	Die Option "Video speichern" ermöglicht es den Outputstream als '.avi' Datei abzuspeichern. 
	
	**oder**

2. 	Anpassung der 'config.m' Datei (Datei öffnen und Anweisungen innerhalb der Datei folgen).
	Anpassungen umfassen ähnlich wie in Möglichkeit 1 angegeben:
	- Auswahl des Szenenordnerpfades (Zuweisung der Variable 'src').
	- Auswahl der linken und rechten Kamera (Zuweisung der Variablen 'L' und 'R').
	- Auswahl des Start Frames (Zuweisung der Variable 'start').
	- Auswahl der Anzahl der Nachfolgebilder (Zuweisung der Variable 'N').
	- Auswahl des Outputpfades für das Video und dessen Name (Zuweisung der Variable 'dst').
	- Auswahl eines virtuellen Hintergrundbildes, falls erwünscht (Zuweisung über Variable 'bg', wenn nicht erwünscht 'bg = 0').
	- Auswahl des Renderingmodus (Zuweisung der 'mode' Variable, Bsp: Wenn virtueller Hintergrund erwünscht, dann 'mode = substitue').
	- Über die Variable 'store' kann über einen logischen-Wert (true/false) festgelegt werden, ob der Output-Stream gespeichert werden soll. 
	- Alle Änderungen speichern. 
	
2.1. 	Ausführen der 'challenge.m' Datei. 

---

### Mitwirkende:

- Muhr, Florian:			florian.muhr@tum.de
- Hacket, Franziska:			franziska.hacket@tum.de
- Kiechle, Johannes: 			johannes.kiechle@tum.de
- Stümke, Daniel:			daniel.stuemke@tum.de

---

### Hinweis

Dieses Projekt wurde nach dessen Abschluss vom internen Lehrstuhl Gitlab hierher umgezogen. 

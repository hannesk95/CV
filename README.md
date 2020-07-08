Diese README Datei beschreibt schrittweise, wie das vorliegende Programm ausgeführt werden muss um dieses ordnungsgemäß zu starten. 
Desweiteren ist hier auch aufgelistet welche Zusatzmodule (Libraries) für eine erfolgreiche Ausführung notwendig sind, und welche 
Matlab Versionen erfolgreich getestet wurden. 

[INFO]: Getestete Matlab Release Versionen: R2019a, R2020a

Auflistung notwendiger Matlab Zusatzmodule:
- Computer Vision Toolbox
- Image Processing Toolbox

Start des Programms (2 Möglichkeiten):
1. 	Aufruf: start_gui (graphische Benutzeroberfläche wird gestartet)
1.1.	Auswahl des Szenenordnerpfads
1.2. 	Auswahl des 'virtuellen' Hintergrundbildes (wenn gewünscht)
1.3. 	Auswahl der Kamera für linken und rechten Kanal über Dropdown Menü
1.4. 	Auswahl der Tensorgröße (Anzahl der Nachfolgebilder N, unser Vorschlag: Tensorgröße = 2)
1.5. 	Auswahl des Start Frames ab dem das Programm startet
1.6.	Auswahl des Renderingmodus
	- foreground: Hintergrund wird ausgeblendet und Person (Fordergrund) ist sichtbar.
	- background: Fordergrund wird ausgeblendet (Person) und nur Hintergrund ist sichtbar.
	- overlay: 
	- substitute: Echter Hintergrund wird durch virtuellen Hintergrund ersetzt.
1.7.	Mit "Play" wird Programm gestaret, "Pause" hält das Programm an, "Stop" beendet das Programm
1.8.	Bei Auswahl der "Loop" Funktion startet das Programm nach Durchlauf aller Frames im Szenen Ordner wieder beim ersten Frame
1.9.	Die Option "Video speichern" ermöglicht es den Outputstream als '.avi' Datei abzuspeichern. 
	
	oder

1. 	Anpassung der config.m Datei
1.1.	Spezifikation des Szenen Ordners
1.2.	Auswahl der Kameras für links und rechts
1.3.	Start Bild auswählen
2. 	Aufruf der challenge.m Datei





Diese README Datei beschreibt schrittweise, wie das vorliegende Programm ausgeführt werden muss um dieses ordnungsgemäß zu starten. 
Desweiteren ist hier auch aufgelistet welche Zusatzmodule (Libraries) für eine erfolgreiche Ausführung notwendig sind, und welche 
Matlab Versionen erfolgreich getestet wurden. 

[INFO]: Getestete Matlab Release Versionen: R2019a, R2020a

Auflistung notwendiger Matlab Zusatzmodule:
- Computer Vision Toolbox
- Image Processing Toolbox

Start des Programms:
1. 	Aufruf: start_gui
1.1.	Auswahl des Szenenordnerpfads
1.2. 	Auswahl des Hintergrundbildes
1.3. 	Auswahl der Kamera für linken und rechten Kanal über Dropdown Leiste
1.4. 	Auswahl der Tensorgröße (Anzahl der Nachfolgebilder N)
	Unser Vorschlag: Tensorgröße = 2

	
	oder

1. 	Anpassung der config.m Datei
1.1.	Spezifikation des Szenen Ordners
1.2.	Auswahl der Kameras für links und rechts
1.3.	Start Bild auswählen
2. 	Aufruf der challenge.m Datei





# Plugins for Musescore

<h3>Chord Identifier Plugin  for Musescore</h3>
- Identify chords and put chord symbol between treble staff and bass staff.
- Identify chord by measure,you can define how many chord in one measure.
- Select chord notes in 3 modes, bass staff only,bass+highest note,or full notes
- Chord sysbol can be display in different modes,such as Normal chord F7,or Roman Chord level IV7.
- A mew chord-only score can be creat if you want.
- Works with single or multiple voices, accross one or more staves (like in sheet music for piano).
- Inversions are indicated.
- Notes are colored according to their function in the chord:
	* Root in green
	* Third in brown
	* Seventh in red
- Works on whole sheet or on selected portion.
- Shows chords used in classical music: triads (major, minor, diminished) and seventh chords (MM7, m7, Mm7, dim7).<br/>

<h3>Example:</h3>
<img height="150px" src="https://github.com/yindht/msc_plugins/blob/master/example1.png"/>
<br/>

<h3>Example:</h3>
<img height="150px" src="https://github.com/yindht/msc_plugins/example2.png"/>
<br/>

<h3>HOW-TO:</h3>
1.download 
- [DOWNLOAD](https://github.com/rousselmanu/msc_plugins/archive) the last release.
- Put the plugin (.qml) in the MuseScore/plugins folder (basically "C:/users/%USERNAME%/Documents/MuseScore2/Plugins" in Windows).
- Restart MuseScore.
- Enable the plugin in "Plugin Manager" (you can also associate a shortcut).


2.you may need adjust parameter for different score  in .qml plugin file
  chordPerMeasure  //you need to define how many chord per measure for your specific score.
  chordIdentifyMode  //0:only left hand ,1:left hand + right(no higtest melody ) , 3:all notes 
  displayChordMode
  creatNewChordScore //creat a new chord-only score
  displayChordColor  0  //0: Normal chord C  F7  Gm
                        //1: Roman Chord level   Ⅳ
                       //2: Normal+Roman
                       
  You can change those parameter in Musescore plugin Creator.
  
3.run plugin.

4.if the gap is two narrow between treble staff and bass staff,you can change it ,Muscore->style->General->Page->Grand staff distance.

5.review chord result, you can adjust some chord symbols manually if think it is not right or not accuracy.  

6.enjoy it.

More info: https://musescore.org/en/handbook/plugins

<h3>Acknowledgment:</h3>
I started this plugin as an improvement of: 
  https://github.com/rousselmanu/msc_plugins  plugin by rousselmanu
  
  https://github.com/andresn/standard-notation-experiments/tree/master/MuseScore/plugins/findharmonies
  
  http://musescore.org/en/project/findharmony  by Merte
  
  https://github.com/berteh/musescore-chordsToNotes/  - Jon Ensminger (AddNoteNameNoteHeads v. 1.2 plugin)
  
  Thank you :-)


Comments and feedbacks are welcome!<br/>
Yindht Xu
Mail: yindht@gmail.com

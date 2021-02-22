# Chord Identifier Plugin for Musescore

<h3>Chord Identifier Plugin  for Musescore</h3>

- Shows chords used in classical music: triads (major, minor, diminished) and seventh chords (MM7, m7, Mm7, dim7).
- Identify chords and put chords symbol between treble staff and bass staff.
- Identify chord by measure, you can also define how many chords in one measure.    

<h3>Example 1 :Chord</h3>  
<img height="474px" src="https://github.com/yindht/msc_plugins/blob/master/example1.png"/>  
<br/>  

<h3>Example 2 :Roma chord display mode</h3>  
<img src="https://github.com/yindht/msc_plugins/blob/master/example2.png"/>  
<br/>  

<h3>Example 3 : New chord-only staff</h3>  
<img src="https://github.com/yindht/msc_plugins/blob/master/example3.png"/>  
<br/> 

<h3>HOW-TO:</h3>


1.Download 
- [DOWNLOAD](https://github.com/yindht/msc_plugins) the last release.  
- Put the chordIdentifier.qml in the MuseScore/plugins folder (basically "C:\Program Files (x86)\MuseScore 2\plugins" in Windows).
- Restart MuseScore.
- Go to menu "Plugins"->"Plugin Manager" , Enable the plugin "chord Identifer" (you can also associate a shortcut). then click "OK"

  
2.Run plugin.  
Go to menu Plugins-> Chords->chord Identifier, then the plugin should dock on bottom-left of Musescore UI.
Then Set parameters and click "OK" 
  
<img src="https://github.com/yindht/msc_plugins/blob/master/panel.png"/>
Parameters:  

- Chord Per Measure: you need to define how many chords per measure for your specific score.  

- Chord in: notes in your choice staff (Grand/treble/all) will be used for chord identification. Treble+ grand mode will ignore the highest note(melody)
 

- Symbol :   
Normal chord ( C F7 Gm )
Roman Chord level ( Ⅳ)
Normal+Roman (C/I) 

- Bass: it will figure out a bass note if bass note is not a chord root note, such as (C/G )

- Highlight chord notes: chord notes display on a different color.

- Create New Chord Score: create a new chord-only score
                         

3.Tips  
- you can try to set different parameters to get a different result, Ctr+Z can undo.
- Default it is for the whole score if you don't select any measure.it also works on selected portion, such as several measures.it is useful for a complicated score, such as 4/4 ->3/4 beat changing in a staff.
- you can adjust chord symbols manually if think it is not right or not accuracy.
- if the gap is too narrow between treble staff and bass staff, you can change it, Muscore->style->General->Page->Grand staff distance.
 


More info: https://musescore.org/en/handbook/plugins  

<h3>Acknowledgment:</h3>  
I started this plugin as an improvement of:  
                       
  https://github.com/rousselmanu/msc_plugins  plugin by rousselmanu
  
  https://github.com/andresn/standard-notation-experiments/tree/master/MuseScore/plugins/findharmonies  
  
  http://musescore.org/en/project/findharmony  by Merte  
  
  https://github.com/berteh/musescore-chordsToNotes/  - Jon Ensminger (AddNoteNameNoteHeads v. 1.2 plugin)  
  
  Thank you :-)

Comments and feedbacks are welcome!<br/> 

yindht


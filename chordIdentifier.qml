//=============================================================================
//  MuseScore - Chord Identifier Plugin
//
//  Copyright (C) 2016 Emmanuel Roussel - https://github.com/rousselmanu/msc_plugins
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENSE
//
//  Documentation: https://github.com/yindht/msc_plugins
//
//  I started this plugin as an improvement of:
//  https://github.com/rousselmanu/msc_plugins  plugin by rousselmanu
//  https://github.com/andresn/standard-notation-experiments/tree/master/MuseScore/plugins/findharmonies
//  http://musescore.org/en/project/findharmony  by Merte
//  https://github.com/berteh/musescore-chordsToNotes/  - Jon Ensminger (AddNoteNameNoteHeads v. 1.2 plugin)
//  Thank you :-)
//=============================================================================

import MuseScore 1.0
import QtQuick 2.0

import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.0

MuseScore {
    menuPath: "Plugins.Chords.Chord Identifier"
    description: "Identify chords and put chord symbol on top."
    version: "3.0.0"
    
    pluginType: "dock"
    dockArea:   "left"

//    pluginType: "dialog"
//    width: 370
//    height: 260
    id: chordDialog
    
    onRun: {
      if (typeof curScore === 'undefined') {
        console.log("Quitting: no score");
        Qt.quit();
      }
      var cursor = curScore.newCursor();
      cursor.rewind(1); // start of selection
    }

    property variant chordPerMeasure : 1    //you need to define how many chord per measure for your specific score.
    property variant chordIdentifyMode : 0  //0:only left hand ,1:left hand + right(no higtest melody ) , 2:all notes
    property variant displayChordMode : 0  //0: Normal chord C  F7  Gm
                                            //1: Roman Chord level   Ⅳ
                                            //2: Normal+Roman
    property variant displayChordColor : 0  //0: disable ,1 enable
    property variant display_bass_note : 0 //set to 1: bass note is specified after a / like that: C/E for first inversion C chord.
    property variant creatNewChordScore : 0 //creat a new chord-only score

    property variant black : "#000000"
    //property variant color7th : "#A00000"
    //property variant color5th : "#803030"
    //property variant color3rd : "#605050"
    //property variant colorroot : "#005000"
    property variant color7th : "#0000ff"
    property variant color5th : "#0000ff"
    property variant color3rd : "#0000ff"
    property variant colorroot : "#0000aa"
    property variant red : "#ff0000"
    property variant green : "#00ff00"
    property variant blue : "#0000ff"




    // ---------- get note name from TPC (Tonal Pitch Class):
    function getNoteName(note_tpc){
        var notename = "";
        var tpc_str = ["Cbb","Gbb","Dbb","Abb","Ebb","Bbb",
            "Fb","Cb","Gb","Db","Ab","Eb","Bb","F","C","G","D","A","E","B","F#","C#","G#","D#","A#","E#","B#",
            "F##","C##","G##","D##","A##","E##","B##","Fbb"]; //tpc -1 is at number 34 (last item).
        if(note_tpc != 'undefined' && note_tpc<=33){
            if(note_tpc==-1)
                notename=tpc_str[34];
            else
                notename=tpc_str[note_tpc];
        }
        return notename;
    }

// Roman numeral sequence for chords ①②③④⑤⑥⑦  Ⅰ  Ⅱ Ⅲ  Ⅳ  Ⅴ Ⅵ   Ⅶ Ⅷ Ⅸ Ⅹ Ⅺ Ⅻ
    function getNoteRomanSeq(note,keysig){
        var notename = "";
        var num=0;
        var keysigNote = [11,6,1,8,3,10,5,0,7,2,9,4,11,6,1];
        var Roman_str_flat_mode1 = ["Ⅰ","Ⅱ♭","Ⅱ","Ⅲ♭","Ⅲ","Ⅳ","Ⅴ♭","Ⅴ","Ⅵ♭","Ⅵ","Ⅶ♭","Ⅶ"];
        var Roman_str_flat_mode2 =  ["①","②♭","②","③♭","③","④","⑤♭","⑤","⑥♭","⑥","⑦♭","⑦"];

        if(keysig != 'undefined' ){
            num=(note+12-keysigNote[keysig+7])%12;
            notename=Roman_str_flat_mode1[num];

        }
        //console.log("keysigNote num:"+note + " "+ keysig + " "+notename);
        return notename;
    }

    function string2Roman(str){
        var strtmp="";
        strtmp=str[0];
        if(str.length>1 && str[1]=="♭")
            strtmp+=str[1];
        var Roman_str_flat_mode1 = ["Ⅰ","Ⅱ♭","Ⅱ","Ⅲ♭","Ⅲ","Ⅳ","Ⅴ♭","Ⅴ","Ⅵ♭","Ⅵ","Ⅶ♭","Ⅶ"];
        var Roman_str_flat_mode2 =  ["①","②♭","②","③♭","③","④","⑤♭","⑤","⑥♭","⑥","⑦♭","⑦"];
        var i=0;
        for(;i<Roman_str_flat_mode1.length;i++)
            if(strtmp==Roman_str_flat_mode1[i])
                return i;

        return -1;
    }

    // ---------- remove duplicate notes from chord (notes with same pitch) --------
    function remove_dup(chord){
        var chord_notes=new Array();

        for(var i=0; i<chord.length; i++)
            chord_notes[i] = chord[i].pitch%12; // remove octaves

        chord_notes.sort(function(a, b) { return a - b; }); //sort notes

        var chord_uniq = chord_notes.filter(function(elem, index, self) {
            return index == self.indexOf(elem);
        }); //remove duplicates
        return chord_uniq;
    }

    // ---------- find intervals for all possible positions of the root note ----------
    function find_intervals(chord_uniq){
        var n=chord_uniq.length;
        var intervals = new Array(n); for(var i=0; i<n; i++) intervals[i]=new Array();

        for(var root_pos=0; root_pos<n; root_pos++){ //for each position of root note in the chord
            var idx=-1;
            for(var i=0; i<n-1; i++){ //get intervals from current "root"
                var cur_inter = (chord_uniq[(root_pos+i+1)%n] - chord_uniq[(root_pos+i)%n])%12;  while(cur_inter<0) cur_inter+=12;
                if(cur_inter != 0){// && (idx==-1 || intervals[root_pos][idx] != cur_inter)){   //avoid duplicates and 0 intervals
                    idx++;
                    intervals[root_pos][idx]=cur_inter;
                    if(idx>0)
                        intervals[root_pos][idx]+=intervals[root_pos][idx-1];
                }
            }
            //debug:
            console.log('\t intervals: ' + intervals[root_pos]);
        }

        return intervals;
    }
    

    function compare_arr(ref_arr, search_elt) { //returns an array of size ref_tab.length
        if (ref_arr == null || search_elt == null) return [];
        var cmp_arr=[], nb_found=0;
        for(var i=0; i<ref_arr.length; i++){
            if( search_elt.indexOf(ref_arr[i]) >=0 ){
                cmp_arr[i]=1;
                nb_found++;
            }else{
                cmp_arr[i]=0;
            }
        }
        return {
            cmp_arr: cmp_arr,
            nb_found: nb_found
        };
    }

    function getChordName(chord,keysig) {
        var INVERSION_NOTATION = 0; //set to 0: inversions are not shown
                                    //set to 1: inversions are noted with superscript 1, 2 or 3
                                    //set to 2: figured bass notation is used instead


        //Standard notation for inversions:
        if(INVERSION_NOTATION===1){
            var inversions = ["", "\u00B9", "\u00B2"], // unicode for superscript "1", "2", "3" (e.g. to represent C Major first, or second inversion)
                inversions_7th = ["7", "\u00B9", "\u00B2", "\u00B3"]; //inversions for 7ths chords
        }else if(INVERSION_NOTATION===2){//Figured bass of inversions:
            var inversions = ["", "\u2076", "\u2076\u2084"],
                inversions_7th = ["\u2077", "\u2076\u2085", "\u2074\u2083", "\u2074\u2082"]; //inversions for 7ths chords
        }else{
            var inversions = ["", "", ""],
                inversions_7th = ["7", "7", "7", "7"]; //inversions for 7ths chords
        }

        var rootNote = null,
            inversion = null,
            partial_chord=0;

        // intervals (number of semitones from root note) for main chords types...          //TODO : revoir fonctionnement et identifier d'abord triad, puis seventh ?
        var chord_type = [ [4,7],  //M (0)
                            [3,7],  //m
                            [3,6],  //dim
                            [4,8],  //aug
                            [4,7,11],   //MM7 = Major Seventh
                            [3,7,10],   //m7 = Minor Seventh
                            [3,7,11],   //mM7 = Minor Seventh
                            [4,7,10],   //Mm7 = Dominant Seventh
                            [3,6,10],   //half-dim7 = Half Diminished Seventh
                            [3,6,9],   //dim7 = Diminished Seventh
                            [4,8,11]];   //aug7 = aug Seventh
        //... and associated notation:
        //var chord_str = ["", "m", "\u00B0", "MM7", "m7", "Mm7", "\u00B07"];
        var chord_str = ["","m", "o","+", "M", "m","mM", "", "Φ","o","+"];
        /*var chord_type_reduced = [ [4],  //M
                                    [3],  //m
                                    [4,11],   //MM7
                                    [3,10],   //m7
                                    [4,10]];  //Mm7
        var chord_str_reduced = ["", "m", "MM", "m", "Mm"];*/
        /*var major_scale_chord_type = [[0,3], [1,4], [1,4], [0,3], [0,5], [1,4], [2,6]]; //first index is for triads, second for seventh chords.
        var minor_scale_chord_type = [[0,4], [2,6], [0,3], [1,4], [0,5], [0,3], [2,6]];*/

        // ---------- SORT CHORD from bass to soprano --------
        chord.sort(function(a, b) { return (a.pitch) - (b.pitch); }); //bass note is now chord[0]

        //debug:
//        for(var i=0; i<chord.length; i++){
//            console.log('pitch note ' + i + ': ' + chord[i].pitch + ' -> ' + chord[i].pitch%12);
//        }

        var chord_uniq = remove_dup(chord); //remove multiple occurence of notes in chord
        console.log('chord_uniq:'+chord_uniq);
        var intervals = find_intervals(chord_uniq);

        //debug:
        //for(var i=0; i<chord_uniq.length; i++) console.log('pitch note ' + i + ': ' + chord_uniq[i]);
        // console.log('compare: ' + compare_arr([0,1,2,3,4,5],[1,3,4,2])); //returns [0,1,1,1,1,0}


        // ---------- Compare intervals with chord types for identification ----------
        var idx_chtype=-1, idx_rootpos=-1, nb_found=0;
        var idx_chtype_arr=[], idx_rootpos_arr=[], cmp_result_arr=[];
        for(var idx_chtype_=0; idx_chtype_<chord_type.length; idx_chtype_++){ //chord types.
            for(var idx_rootpos_=0; idx_rootpos_<intervals.length; idx_rootpos_++){ //loop through the intervals = possible root positions
                var cmp_result = compare_arr(chord_type[idx_chtype_], intervals[idx_rootpos_]);
                if(cmp_result.nb_found>0){ //found some intervals
                    if(cmp_result.nb_found == chord_type[idx_chtype_].length){ //full chord found!
                        if(cmp_result.nb_found>nb_found){ //keep chord with maximum number of similar interval
                            nb_found=cmp_result.nb_found;
                            idx_rootpos=idx_rootpos_;
                            idx_chtype=idx_chtype_;
                        }
                    }
                    idx_chtype_arr.push(idx_chtype_); //save partial results
                    idx_rootpos_arr.push(idx_rootpos_);
                    cmp_result_arr.push(cmp_result.cmp_arr);
                }
            }
        }

        if(idx_chtype<0 && idx_chtype_arr.length>0){ //no full chord found, but found partial chords
            console.log('other partial chords: '+ idx_chtype_arr);
            console.log('root_pos: '+ idx_rootpos_arr);
            console.log('cmp_result_arr: '+ cmp_result_arr);

            //third and 7th ok (missing 5th)
            for(var i=0; i<cmp_result_arr.length; i++){
                if(cmp_result_arr[i][0]===1 && cmp_result_arr[i][2]===1){
                    idx_chtype=idx_chtype_arr[i];
                    idx_rootpos=idx_rootpos_arr[i];
                    console.log('3rd + 7th OK!');
                    break;
                }
            }


            //still no chord found. Check for third interval only (missing 5th and 7th)
            /*
            if(idx_chtype<0){
                for(var i=0; i<cmp_result_arr.length; i++){
                    if(cmp_result_arr[i][0]===1){ //third ok
                        idx_chtype=idx_chtype_arr[i];
                        idx_rootpos=idx_rootpos_arr[i];
                        console.log('3rd OK!');
                        break;
                    }
                }
            }
            */

        }

        if(idx_chtype>=0){
            console.log('FOUND CHORD number '+ idx_chtype +'! root_pos: '+idx_rootpos);
            console.log('\t interval: ' + intervals[idx_rootpos]);
            rootNote=chord_uniq[idx_rootpos];
        }else{
            console.log('No chord found');
        }

        var regular_chord=[-1,-1,-1,-1]; //without NCTs
        var bass=null;
        var seventhchord=0;
        var chordName='';
        var chordNameRoman='';
        if (rootNote !== null) { // ----- the chord was identified
            for(i=0; i<chord.length; i++){  // ---- color notes and find root note
                if((chord[i].pitch%12) === (rootNote%12)){  //color root note
                    regular_chord[0] = chord[i];
                    if(displayChordColor==1) chord[i].color = colorroot;
                    if(bass==null) bass=chord[i];
                }else if((chord[i].pitch%12) === ((rootNote+chord_type[idx_chtype][0])%12)){ //third note
                    regular_chord[1] = chord[i];
                    if(displayChordColor==1) chord[i].color = color3rd;
                    if(bass==null) bass=chord[i];
                }else if(chord_type[idx_chtype].length>=2 && (chord[i].pitch%12) === ((rootNote+chord_type[idx_chtype][1])%12)){ //5th
                    regular_chord[2] = chord[i];
                    if(displayChordColor==1) chord[i].color = color5th;
                    if(bass==null) bass=chord[i];
                }else if(chord_type[idx_chtype].length>=3 && (chord[i].pitch%12) === ((rootNote+chord_type[idx_chtype][2])%12)){ //7th
                    regular_chord[3] = chord[i];
                    if(displayChordColor==1) chord[i].color = color7th;
                    if(bass==null) bass=chord[i];
                    seventhchord=1;
                }else{      //reset other note color
                    chord[i].color = black;
                }
            }

            // ----- find root note
            /*var chordRootNote;
            for(var i=0; i<chord.length; i++){
                if(chord[i].pitch%12 == rootNote)
                    chordRootNote = chord[i];
            }*/

            // ----- find chord name:

            var notename = getNoteName(regular_chord[0].tpc);

            chordNameRoman = getNoteRomanSeq(regular_chord[0].pitch,keysig);

            chordName = notename + chord_str[idx_chtype];
            chordNameRoman += chord_str[idx_chtype];

        }else{
            for(var i=0; i<chord.length; i++){
                chord[i].color = black;
            }
        }

        // ----- find inversion
        inv=-1;
        if (chordName !== ''){ // && inversion !== null) {
            var bass_pitch=bass.pitch%12;
            //console.log('bass_pitch: ' + bass_pitch);
            if(bass_pitch == rootNote){ //Is chord in root position ?
                inv=0;
            }else{
                for(var inv=1; inv<chord_type[idx_chtype].length+1; inv++){
                   if(bass_pitch == ((rootNote+chord_type[idx_chtype][inv-1])%12)) break;
                   //console.log('note n: ' + ((chord[idx_rootpos].pitch+intervals[idx_rootpos][inv-1])%12));
                }
            }
            console.log('\t inv: ' + inv);
            if(seventhchord == 0){ //we have a triad:
                chordName += inversions[inv];
                chordNameRoman +=  inversions[inv];
            }else{  //we have a 7th chord
                chordName += inversions_7th[inv];
                chordNameRoman +=  inversions_7th[inv];
            }


            if(display_bass_note===1 && inv>0){
                chordName+="/"+getNoteName(bass.tpc);
            }

            if(displayChordMode === 1 )
                chordName = chordNameRoman;
            else if(displayChordMode === 2 )
                chordName += " "+chordNameRoman;

        }


        return chordName;
    }

    function getSegmentHarmony(segment) {
        //if (segment.segmentType != Segment.ChordRest)
        //    return null;
        var aCount = 0;
        var annotation = segment.annotations[aCount];
        while (annotation) {
            if (annotation.type == Element.HARMONY)
                return annotation;
            annotation = segment.annotations[++aCount];
        }
        return null;
    }

    function getAllCurrentNotes(cursor, startStaff, endStaff){
        var full_chord = [];
        var idx_note=0;
        for (var staff = endStaff; staff >= startStaff; staff--) {
            for (var voice = 3; voice >=0; voice--) {
                cursor.voice = voice;
                cursor.staffIdx = staff;
                if (cursor.element && cursor.element.type == Element.CHORD) {
                    var notes = cursor.element.notes;
                    for (var i = 0; i < notes.length; i++) {
                          full_chord[idx_note]=notes[i];
                          idx_note++;
                    }
                }
            }
        }
        return full_chord;
    }


    function creatNewScore(oldScore,choText){
             //make a new score for all chords
            console.log("hello createscore");
            var score = newScore("Test-Score", "1234", 1);
            //var numerator = 3;
            //var denominator = 4;
            //var ts = newElement(Element.TEXT);
            //ts.setSig(numerator, denominator);

            score.addText("title", oldScore.title);
            score.addText("subtitle", oldScore.subtitle);
            score.addText("composer", oldScore.composer);
            //score.addText("poet", oldScore.poet);


            var cursor = score.newCursor();
            cursor.track = 0;
            cursor.staffIdx = 0;

            cursor.rewind(0);



            var chordstr = choText.split(",");

            var offset=0;
            var chordLevelLast=0;
            for(var i =0;i<(chordstr.length-2);i++){
              var text = newElement(Element.STAFF_TEXT);
              var str=chordstr[i];

              text.pos.y = 5;
              console.log("chordstr:"+chordstr[i]+".");
              if(chordstr[i]=="|"){
                  score.appendMeasures(1);
                  cursor.nextMeasure();
                  offset=1;
              }
              else{
                  if(displayChordMode==2 && str!="/"){
                      var str1=str.split(" ");
                      var chordLevel=string2Roman(str1[1]);

                      console.log("chord: "+string2Roman(str1[1])+" "+(chordLevel+12-chordLevelLast)%12);

                      if (chordLevel!=-1 && chordLevelLast!=-1 && ((chordLevel+12-chordLevelLast)%12==5))
                          text.color="#0000ff";

                      text.text=str1[0]+"\n\n"+str1[1];
                      chordLevelLast=chordLevel;
                  }else{
                      text.text=str;
                  }

                  text.pos.x = offset;
                  cursor.add(text);
                  //console.log("text.pos.x "+text.pos.x+" "+str);
                   offset+=5;
              }

            }
    }



      function runsheet(){
            console.log("Hello Walker");

                  if (typeof curScore === 'undefined')
                      Qt.quit();


                  var tickPerMeasure;
                  var cursor = curScore.newCursor();
                  cursor.rewind(1);

                  if (!cursor.segment) {
                      console.log("no selection,do all staff");
                      cursor.rewind(0);
                      var measure = cursor.measure;
                      measure = measure.nextMeasure;
                      if(measure!=null)
                         tickPerMeasure = measure.lastSegment.tick-measure.firstSegment.tick;
                      console.log("measure"+tickPerMeasure);
                      
                      var lastSegment = curScore.lastSegment;

                      cursor.rewind(0);
                      var segment = cursor.segment;
                      
                  }
                  else{
                      var measure = cursor.measure;
                      if(measure!=null)
                         tickPerMeasure = measure.lastSegment.tick-measure.firstSegment.tick;
                      console.log("measure"+tickPerMeasure);
                      
                      cursor.rewind(2);
                      var lastSegment = cursor.segment;

                      cursor.rewind(1);
                      var segment = cursor.segment;
                  }

                  cursor.track=0;
                  cursor.staffIdx=1;
                    //cursor.setDuration(measuretick / 8, measuretick );


                  var bass_chord = [];
                  var full_chord = [];
                  var idx_note=0;
                  var idx_note_all=0;
                  //var chordPerMeasure=2;
                  var tickStart=0;
                  var chordName = '';
                  var prev_chordName = '';
                  var KeySig = 0;
                  var scoreChordStr ='';

                  while (segment &&(segment.tick <= lastSegment.tick )) {
                     var highestNote='';
                     for (var track = 0; track < curScore.ntracks; ++track) {
                        //console.log(segment.tick+ " " + segment );
                        var element = segment.elementAt(track);
                        if (element) {
                              var type    = element.type;
                              console.log(segment.tick+ " " + element._name()+ " segment , " + "  type " + segment.segmentType );



                              if((segment.tick-tickStart)>=(tickPerMeasure/chordPerMeasure)  || element._name()== "BarLine")
                              {
                                    console.log("||| "+ (segment.tick-tickStart) + " " + (tickPerMeasure/chordPerMeasure));


                                    console.log("KeySig:"+cursor.keySignature);

                                    chordName = getChordName(bass_chord,cursor.keySignature);
                                    console.log("chord:"+chordName);

                                    if(chordName == ''  && chordIdentifyMode ==2) {
                                        chordName = getChordName(full_chord,cursor.keySignature);
                                        console.log("chord:"+chordName);
                                    }

                                    if (chordName !== ''  &&  chordName!=prev_chordName){
                                        var staffText = newElement(Element.STAFF_TEXT);
                                        staffText.text = chordName;
                                        staffText.pos.x = 0;
                                        staffText.pos.y = -2;
                                        cursor.add(staffText);
                                    }

                                    var tempStr;
                                    if (chordName == '')
                                        tempStr =  "/";
                                    else if(chordName==prev_chordName)
                                        tempStr =  "-";
                                    else{
                                        tempStr = chordName;
                                    }
                                    scoreChordStr+=tempStr+",";

                                    if(element._name() == "BarLine"){
                                        tempStr ="|";
                                        scoreChordStr+=tempStr+",";
                                    }

                                    prev_chordName = chordName;

                                    var tcount=0;
                                    while(cursor.tick < segment.tick && (segment.tick != lastSegment.tick)){
                                        cursor.next();
                                        tcount++;
                                    }

                                    console.log("cursor.tick:"+ cursor.tick + " tickStart:" + tickStart);

                                    bass_chord=[];
                                    full_chord=[]

                                    idx_note=0;
                                    idx_note_all=0;

                                    tickStart=segment.tick;

                                    if(element._name()== "BarLine"){
                                        prev_chordName = '';
                                    }

                              }

                              if(element._name()=="Chord" ){
                                 var notes = element.notes;
                                 console.log("notes: "+ notes.length + " track:" + track);

                                 //chordIdentifyMode ==2
                                 for (var i = 0; i < notes.length; i++) {
                                     full_chord[idx_note_all]=notes[i];
                                     idx_note_all++;
                                 }


                                 //chordIdentifyMode ==0
                                 if(track >=4){ //add all left hand notes
                                     for (var i = 0; i < notes.length; i++) {
                                         bass_chord[idx_note]=notes[i];
                                         idx_note++;
                                         console.log("add4:"+notes[i].pitch);
                                     }
                                 }
                                 else if(chordIdentifyMode ==1){ // delete highest melody note in same timetick notes.
                                     var notesR = [];
                                     for (var i = 0; i < notes.length; i++) {
                                         notesR[i]=notes[i];
                                     }

                                     if(notesR.length>1)
                                         notesR.sort(function(a, b) { return (b.pitch) - (a.pitch); }); //melody note is now notes[0]

                                     if(highestNote==''  || (notesR[0].pitch>highestNote.pitch))
                                         highestNote=notesR[0];


                                     for (var i = 0; i < notesR.length; i++) {
                                         var diff = (highestNote.pitch-notesR[i].pitch)%12;
                                         //if(diff ==0 || diff ==3 || diff ==4 || diff ==8 || diff ==9 ){  thrid/sixth/eighth note
                                         if(diff ==0 ){
                                         }
                                         else{
                                             console.log("add:"+notesR[i].pitch+" highest:"+highestNote.pitch+"");
                                             bass_chord[idx_note]=notesR[i];
                                             idx_note++;
                                         }
                                     }
                                 }
                              }
                        }
                      }
                      segment = segment.next;
                  }

              if(creatNewChordScore==1){
                 creatNewScore(curScore,scoreChordStr);
              }
            }


  function showVals () {
    for (var i=0; i < chrodMeasure.buttonList.length; i++ ) {
      var s = chrodMeasure.buttonList[i];
      if (s.checked) {
          chordPerMeasure=chrodMeasure.buttonList.length-i;
          break;
      }
    }

    for (var i=0; i < chordStaff.buttonList.length; i++ ) {
      var s = chordStaff.buttonList[i];
      if (s.checked) {
          chordIdentifyMode=chordStaff.buttonList.length-1-i;
          break;
      }
    }
    
    
    for (var i=0; i < symbolMode.buttonList.length; i++ ) {
      var s = symbolMode.buttonList[i];
      if (s.checked) {
          displayChordMode=symbolMode.buttonList.length-1-i;
          break;
      }
    }
    
    for (var i=0; i < bassMode.buttonList.length; i++ ) {
      var s = bassMode.buttonList[i];
      if (s.checked) {
          display_bass_note=chordColcorMode.buttonList.length-1-i;
          break;
      }
    }


    for (var i=0; i < chordColcorMode.buttonList.length; i++ ) {
      var s = chordColcorMode.buttonList[i];
      if (s.checked) {
          displayChordColor=chordColcorMode.buttonList.length-1-i;
          break;
      }
    }
    
    for (var i=0; i < newScoreMode.buttonList.length; i++ ) {
      var s = newScoreMode.buttonList[i];
      if (s.checked) {
          creatNewChordScore=newScoreMode.buttonList.length-1-i;
          break;
      }
    }


  }


  ColumnLayout {
      // Left: column of note names
      // Right: radio buttons in flat/nat/sharp positions
      id: radioVals
      anchors.left: pedalPositions.right

      RowLayout {
        id: flatRow1
        spacing: 20
        Text  { text:  "  "; font.bold: true }

      }

      RowLayout {
        id: chrodMeasure
        spacing: 20
        Text  { text:  "  Chords per Measure:"; font.bold: true }
        property list<RadioButton> buttonList: [
          RadioButton { parent: chrodMeasure;text: "4"; exclusiveGroup: rowA },
          RadioButton { parent: chrodMeasure;text: "3"; exclusiveGroup: rowA },
          RadioButton { parent: chrodMeasure;text: "2"; exclusiveGroup: rowA },
          RadioButton { parent: chrodMeasure;text: "1"; exclusiveGroup: rowA ;checked: true }
        ]
      }
      
      RowLayout {
        id: chordStaff
        spacing: 20
        Text  { text:  "  Chord for:"; font.bold: true }
        property list<RadioButton> buttonList: [
          RadioButton { parent: chordStaff;text: "All"; exclusiveGroup: rowB },
          RadioButton { parent: chordStaff;text: "Treble+grand"; exclusiveGroup: rowB },
          RadioButton { parent: chordStaff;text: "Grand"; exclusiveGroup: rowB ;checked: true }
        ]
      }
      
      RowLayout {
        id: symbolMode
        spacing: 20
        Text  { text:  "  Symbol:"; font.bold: true }
        property list<RadioButton> buttonList: [
          RadioButton { parent: symbolMode;text: "N+R"; exclusiveGroup: rowC ;},
          RadioButton { parent: symbolMode;text: "Roman"; exclusiveGroup: rowC ;},
          RadioButton { parent: symbolMode;text: "Normal"; exclusiveGroup: rowC ;checked: true }
        ]
      }

      RowLayout {
        id: bassMode
        spacing: 20
        Text  { text:  "  Bass:"; font.bold: true }
        property list<RadioButton> buttonList: [
          RadioButton { parent: bassMode;text: "Yes"; exclusiveGroup: rowD },
          RadioButton { parent: bassMode;text: "No"; exclusiveGroup: rowD ;checked: true }
        ]
      }

      RowLayout {
        id: chordColcorMode
        spacing: 20
        Text  { text:  "  Highlight Chord Notes:"; font.bold: true }
        property list<RadioButton> buttonList: [
          RadioButton { parent: chordColcorMode;text: "Yes"; exclusiveGroup: rowE },
          RadioButton { parent: chordColcorMode;text: "No"; exclusiveGroup: rowE ;checked: true }

        ]
      }

      RowLayout {
        id: newScoreMode
        spacing: 20
        Text  { text:  "  Creat Chord Score:"; font.bold: true }
        property list<RadioButton> buttonList: [
          RadioButton { parent: newScoreMode;text: "Yes"; exclusiveGroup: rowF },
          RadioButton { parent: newScoreMode;text: "No"; exclusiveGroup: rowF ;checked: true }

        ]
      }



      ExclusiveGroup { id: rowA; onCurrentChanged: { showVals(); }}
      ExclusiveGroup { id: rowB; onCurrentChanged: { showVals(); }}
      ExclusiveGroup { id: rowC; onCurrentChanged: { showVals(); }}
      ExclusiveGroup { id: rowD; onCurrentChanged: { showVals(); }}
      ExclusiveGroup { id: rowE; onCurrentChanged: { showVals(); }}
      ExclusiveGroup { id: rowF; onCurrentChanged: { showVals(); }}
  }


  Button {
    id: buttonCancel
    text: qsTr("Cancel")
    anchors.bottom: chordDialog.bottom
    anchors.right: chordDialog.right
    anchors.bottomMargin: 10
    anchors.rightMargin: 10
    width: 100
    height: 40
    onClicked: {
      Qt.quit();
    }
  }



  Button {
    id: buttonOK
    text: qsTr("OK")
    width: 100
    height: 40
    anchors.bottom: chordDialog.bottom
    anchors.right:  buttonCancel.left
    anchors.topMargin: 10
    anchors.bottomMargin: 10
    onClicked: {
      curScore.startCmd();
      runsheet();
      curScore.endCmd();
//      Qt.quit();
    }
  }

}



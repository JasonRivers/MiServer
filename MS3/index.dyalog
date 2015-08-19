﻿:Class index : MiPageSample

    :SECTION GLOBALS ⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

    :Field TYPES←'Simple' 'Advanced'⍝ Types of samples (if not App)
    :Field GROUPS      ⍝ Names of groups of elements
    :Field REFS        ⍝ ... their refs
    :Field APPS        ⍝ List of all apps
    :Field SAMPLES     ⍝ List of all samples (well, groups and controls really)
    :Field INFOLONG    ⍝ Long desc of each control
    :Field INFOSHORT   ⍝ Short (1-3 words) desc of each control
    :Field NAMESLONG   ⍝ Elements that have long info
    :Field NAMESSHORT  ⍝ Elements that have short info
    :Field SEARCH←''   ⍝ Last-search cache
    :Field CONTROLS←'' ⍝ All control names
    :Field APPDESCS    ⍝ Sample Apps' Description::
    :Field APPCTRLS    ⍝ Sample Apps' Control:: (i.e. the title)
    :Field CORE        ⍝ Core subset of controls

    :ENDSECTION

    :SECTION UTILITIES ⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

    Q←'"'∘,,∘'"'  ⍝ Surround with quotes, a.k.a. APL dragon

    D←{(×≢⍵)/' – ',⍵} ⍝ Prepend a dash if non-empty

    P←{1⌽(×≢#.HTMLInput.dtlb ⍵)/') (',⍵} ⍝ Surround with parens if non-empty

    Words←{(1↓¨(' '∘=⊂⊢)' ',⍵)~⊂''} ⍝ Split at spaces

    SpaceToDir←{'Examples/',1↓⍵} ⍝ Convert Space name to Folder name

    Frame←{'.iframed' ('src=',Q⍵,'?NoWrapper=1') New _.iframe}

    NewWinA←{('target' '_blank')('href=',Q⊃⌽⍵) New _.a (⊃⍵)} ⍝ New link that opens in a new window/tab

    NewDiv←{⍵ New _.div} ⍝ Make a div

    Horz←{⍺←⊢ ⋄ r⊣(r←⍺ New _.StackPanel ⍵).Horizontal←1} ⍝ Horizontal StackPanel

    Type←{P(1⍳⍨∨/¨TYPES⍷¨⊂⍺)⊃(TYPES,¨⊂' sample for ',⍵),⊂'Sample app'} ⍝ Simple/Advanced/App?

    Dread←{0::,⊂'[file read failed]' ⋄ #.UnicodeFile.ReadNestedText #.Boot.AppRoot,⍵,'.dyalog'} ⍝ Read dyalog file

    Dlist←{0::⍬ ⋄ ¯7↓¨6⊃#.Files.DirX #.Boot.AppRoot,⍵,'/*.dyalog'} ⍝ List dyalog files

    NodeID←{⍺←⊢ ⋄ ('#node',⊃⍵)∘,¨⍕¨⍺+⍳⍴⊃⌽⍵} ⍝ Generate node ids (⍵='L' items) optional (⍺=offset)

    Split←{{⍵↑⍨+/∨\' '≠⌽⍵}¨('_'⎕R' ')⍵((⍳↑⊣){⍺⍵}(⍳↓⊣))'_'} ⍝ Split at first _ and fix _s

    In←{∨/¨⊃⍷¨/{⎕SE.Dyalog.Utils.lcase¨eis ⍵}¨⍺ ⍵} ⍝ Case-insensitive find

    Names←{1↓¨⍵↑¨⍨¯1+⍵⍳¨':'} ⍝ Extract section names from set of several 'name:: description'

    AddShortInfo←{⍵,¨P¨(4+⍴¨⍵)↓¨(INFOSHORT,⊂'')[NAMESSHORT⍳⍵]} ⍝ ⍵ (ShortDesc)

    AddLongInfo←{(New¨_.strong,¨⍵),¨D¨{⍵,'[no info available]'/⍨0∊⍴⍵}¨(4+⍴¨⍵)↓¨(INFOLONG,⊂'')[NAMESLONG⍳⍵]} ⍝ ⍵ - LongDesc

      Section←{ ⍝ extract section ⍺:: from code ⍵
          regex←'^\s*⍝\s*',⍺,':(:.*?)$((\R^⍝(?!\s*\w+::).*?$)*)'
          opts←('Mode' 'M')('DotAll' 1)
          res←(regex ⎕S'\1\2'⍠opts)⍵
          (1↓⊃res)~'⍝'
      }

      JSsafe←{ ⍝ Make text JS safe by escaping problematic chars
          fr←'''' '"' '\\' '\n' '\r',⎕UCS 9 8 12               ⍝ ' " \ NL CR TB BS FF
          to←'\\''' '\\"' '\\\\' '\\n' '\\r' '\\t' '\\b' '\\f' ⍝ problematic in regex too :-)
          Q(fr ⎕R to⍠'Mode' 'D')⍵ ⍝ Replace problematic chars and sourround with quotes
      }

    ∇ js←APLtoJS vtv;act;data
      :Access public shared
     ⍝ Convert vectors of pseudo JS (generated by Replace, Execute, et al.) to proper JS
     
      js←''
      :For act data :In eis vtv
          data←JSsafe⊃⌽eis data ⍝ the last or only one
          :Select ⊃eis act      ⍝ the first or only one
          :Case 'assign'
              js,←(⊃⌽act),' = ',data,';' ⍝ variable = "data"
          :Case 'execute'
              js,←'eval(',data,');' ⍝ eval("data")
          :Case 'replace'
              js,←'$("',(⊃⌽act),'").html(',data,');' ⍝ $("#myid").html("data")
          :Else
              js,←'$("',(⊃⌽act),'").',(⊃act),'(',data,');' ⍝ $("#myid").append("data")
          :EndSelect
      :EndFor
    ∇

    :ENDSECTION

    :SECTION MAIN ⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

    ∇ Compose;left;mid;right;sp;style
      :Access public
     
     ⍝ Initialize globals
      SAMPLES←0 3⍴⍬
      GROUPS←'Dyalog Controls' 'Base HTML' 'SyncFusion' 'JQueryUI'
      REFS←_DC _html _SF _JQ
      INFOSHORT←'⍝',¨Dread'Examples/Data/infoShort'
      INFOLONG←'⍝',¨Dread'Examples/Data/infoLong'
      NAMESSHORT←Names INFOSHORT
      NAMESLONG←Names INFOLONG
     
      '#title'Add _.title'MS3: About' ⍝ After the : will be updated
     
      Add _.StyleSheet'/Styles/homepage.css'
      style←''
      style,←'#leftBar {background-color:inherit;margin-right:6px;} '
      style,←'.menu {padding-left,padding-right:0;} '
      style,←'.cat {font-size:12pt;cursor:pointer;border:1px solid transparent;padding:0 4px 2px 4px;} '
      style,←'.cat:hover {background:linear-gradient(to bottom,#ffbb60 0%,#f37603 100%);border:1px solid #f9cb59;font-weight:bold;} '
      style,←'.menuitem {margin-bottom,margin-left:0px;padding-left:2px;cursor:pointer;} '
      style,←'.menuitem:hover {background-color:highlight;} '
      style,←'.framed {width:730px;max-height:600px;min-height:400px;border-left:1px inset;overflow-y:auto;} '
      style,←'.iframed {width:730px;max-height:600px;min-height:400px;border:2px inset;overflow-y:auto;background-color:white;} '
      style,←'.listitem {margin:0px;padding:4px;cursor:pointer;box-sizing:border-box;} '
      style,←'.listitem:before {content:"▶";padding: 1px 3px 3px 4px;'
      style,←'    background: ThreeDFace;'
      style,←'    color: ButtonText;'
      style,←'    border-radius: 4px;'
      style,←'    border: solid 1px ThreeDLightShadow;'
      style,←'    box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.4), 0 1px 1px rgba(0, 0, 0, 0.2);'
      style,←'    transition-duration: 0.2s;'
      style,←'    margin-right: 4px;'
      style,←'}'
      style,←'.listitem:active:before {'
      style,←'    box-shadow: inset 0 1px 4px rgba(0, 0, 0, 0.6);'
      style,←'    background: ThreeDShadow;'
      style,←'    border: solid 1px ThreeDDarkShadow;'
      style,←'}'
      style,←'.listitem:hover:before {'
      style,←'    background: ThreeDHighlight;'
      style,←'    border: solid 1px ThreeDFace;'
      style,←'    text-decoration: none;'
      style,←'}'
      style,←'.noitems {margin:0px;padding:4px;cursor:not-allowed;} '
      style,←'.samplesource {overflow-x:auto;width:730px;background-color:#e5e5cc;border:2px inset;} '
      Add _.style style
     
      (left mid)←NewDiv¨'#leftBar' '#midBar' ⍝ Create panes
      sp←Add'mainSP'Horz left mid
     
      sp.Items[1].style←⊂'width: 200px; max-height: 450px;'
      sp.Items[2].style←⊂'margin: 5px;'
      sp.style←'height: 450px;background-color:inherit;'
     
      PopulateLeft left
      PopulateMid mid
    ∇

    ∇ PopulateLeft thediv;class;depths;group;items;ref;samples;vp;search;style;menu;i;fs;ac;text;stuff;treeall;treecore;names;tree
     
      stuff←''
      tree←0 3⍴0 '' ''
     
         ⍝ SEARCH FIELD ⍝⍝⍝
      stuff,←New _.EditField'searchfield'⍝).On'change' 'OnSearch'('str' 'val')
      (stuff,←'#searchbutton' '.menu'New _.button'Search').On'click' 'OnSearch'('str' '#searchfield' 'val')
     
      thediv.Add Horz stuff
      thediv.Add _.hr
     
      ⍝ SAMPLE APPS ⍝⍝⍝
      APPS←(Dlist'Examples/Apps')~⊂'index'
      APPDESCS←(⊂'Description')Section¨Dread¨'Examples/Apps/'∘,¨APPS
      APPCTRLS←(⊂'Control')Section¨Dread¨'Examples/Apps/'∘,¨APPS
      ('.cat'thediv.Add _.span'Sample Apps').On'click' 'OnAppHeader'
      APPS{tree⍪←1 ⍵('nodeA',⍺)}¨APPCTRLS
      tree←'#treeA'thediv.Add _.ejTreeView tree
      tree.On'nodeSelect' 'OnApp'('node' 'eval' 'argument.id')
     
      thediv.Add _.hr
     
      ('#node01All' '.cat'thediv.Add _.span'Controls').On'click' 'OnTree'
      CORE←⎕SE.SALT.Load #.Boot.AppRoot,'Examples/Data/core -noname'
      treecore←1 3⍴1 'Core' 'node0_Core'
      treeall←1 3⍴1 'All' 'node00All'
     
      :For group class :InEach GROUPS(3↓¨⍕¨REFS) ⍝ Remove leading #._
          names←⎕THIS.⎕SE.SALT.Load #.Boot.AppRoot,'Examples/Data/tree',class,' -noname'
          CONTROLS,←⊂names[;2]/⍨(⊢=⌈/)names[;1]
          ⍎class,'←names'
     
          :If ∨/names[;2]∊CORE
              treecore⍪←2(group,P'_',class)('node__',class)
              treecore⍪←3,0 1↓names⌿⍨names[;2]∊CORE
          :EndIf
     
          treeall⍪←2(group,P'_',class)('node_',class)
          treeall⍪←⍎class
     
      :EndFor
     
      tree←'#treeC' 'style="max-height:260px"'thediv.Add _.ejTreeView,⊂treecore⍪treeall
      tree.On'nodeSelect' 'OnTree'('node' 'eval' 'argument.id')
    ∇

    ∇ PopulateMid mid;url;code;frame;mya
     
     ⍝ Read framed pages
      url←'Examples/Apps/About'
      code←Dread url
     ⍝ Create and fill placeholder for title header
      mya←('#SampleTitle'mid.Add _.h2).Add NewWinA('Control'Section code)url
     ⍝ Create and fill placeholder for description line
      '#SampleDesc'mid.Add _.p('Description'Section code)
     ⍝ Create and fill placeholder for embedded page
      frame←mid.Add NewDiv'#SampleFrame'
      frame.Add Frame url
      '#SampleSource' '.samplesource'mid.Add _.div⍝,⊂'x-small;border:none'#.HTMLInput.APLToHTMLColour code ⍝ No source on page load
    ∇

    :ENDSECTION

    :SECTION CALLBACKS ⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

    ∇ r←OnTree;node;descs;out;items;spacectrl;control;spacedir;files;file;i;url;code;ctrlsec;desc;item;title;currctrls;core;names;class;group;cat
      :Access Public
      node←GetNode
      :If '0'∊node ⍝ 'All'
          core←'_'=2⊃node
          currctrls←(CORE∘∩⍣core)⊃,/CONTROLS ⍝ Filter if core-only
          out←NewDiv'.framed'
          descs←AddLongInfo currctrls
          items←(currctrls,⍨¨⊂'list',1⌽node)out.Add¨_.p,¨descs ⍝ make IDs like 'DC_Button'
          items.Set⊂'.listitem'
          items.On⊂'click' 'OnTree'
          r←(2↓node)(2↓node,' Controls')((⍕⍴currctrls),(core/' core'),' controls')out''
      :ElseIf '_'=⊃node ⍝ Class or core subset thereof
          core←'_'=2⊃node
          node↓⍨←core ⍝ Remove additional _ from '__html' if core-only
          i←REFS⍳⍎node
          currctrls←(CORE∘∩⍣core)i⊃CONTROLS ⍝ Filter if core-only
          out←NewDiv'.framed'
          descs←AddLongInfo currctrls
          items←(currctrls,⍨¨⊂'list',1⌽node)out.Add¨_.p,¨descs ⍝ make IDs like 'DC_Button'
          items.Set⊂'.listitem'
          items.On⊂'click' 'OnTree'
          r←node((i⊃GROUPS),P node)((⍕⍴currctrls),(core/' core'),' controls')out''
      :ElseIf '_'=⊃⌽node ⍝ Category
          (class cat)←Split node
          names←⍎class
          i←(names[;3]/⍨(⊢=⌊/)names[;1])⍳⊂'node',node
          currctrls←1↓i⊃names[;2]⊂⍨(⊢=⌊/)names[;1]
          group←GROUPS⊃⍨REFS⍳⍎'_',class
          out←NewDiv'.framed'
          descs←AddLongInfo currctrls
          items←(currctrls,⍨¨⊂'list',class)out.Add¨_.p,¨descs ⍝ make IDs like 'DC_Button'
          items.Set⊂'.listitem'
          items.On⊂'click' 'OnTree'
          r←('_',class)(group,(P'_',class),' ',cat)(' controls',⍨⍕⍴currctrls)out''
      :Else ⍝ Control
          spacectrl←'_',('_'⎕R'.')node
          (class control)←Split node
          spacedir←'Examples/',class
          files←Dlist spacedir
          out←NewDiv'.framed'
          CURRFILES←''
          i←0
          :For file :In files
              url←spacedir,'/',file
              code←Dread url
              ctrlsec←Words'Control'Section code
              :If (⊂spacectrl)∊ctrlsec ⍝ Extract space-separated words
                  i+←1
                  CURRFILES,←⊂url
                  desc←⊂'Description'Section code
                  desc←∊desc,file Type⊃ctrlsec
                  item←('#nodeS',⍕i)'.listitem'out.Add _.p desc
                  item.On'click' 'OnSample'
              :EndIf
          :EndFor
          :If ~×i
              '.noitems'out.Add _.p,⊂'[no samples using ',spacectrl,']'
          :EndIf
          title←(⍕≢CURRFILES),' results for ',spacectrl
          desc←'Click on a button below to view it embedded in this page or double-click to see it as a stand-alone page.'
          r←spacectrl title desc out''
      :EndIf
      r←GenJS r
    ∇

    ∇ r←OnAppHeader;descs;out;items
      :Access Public
     ⍝ Gets called upon clicking the "Sample Apps" header
      descs←APPCTRLS,¨' – '∘,¨APPDESCS
      out←NewDiv'.framed'
      items←APPS{('nodeB',⍺)out.Add _.p ⍵}¨descs
      items.Set⊂'.listitem'
      items.On⊂'click' 'OnApp'
      r←GenJS'Apps' 'Small applications to showcase MiServer 3.0 functionality'(' apps',⍨≢APPS)out''
    ∇

    ∇ r←OnCtrlHeader;descs;out;items
      :Access Public
     ⍝ Gets called upon clicking the "Sample Apps" header
      r←GenJS'Controls' 'Something about controls' 'Controls' 'list of all controls with long descs' ''
    ∇

    ∇ r←OnApp
      :Access Public
     ⍝ Gets called upon selection in Sample Apps tree
      r←GenJS Update'Examples/Apps/',1↓GetNode
    ∇

    ∇ r←OnSample
      :Access Public
      :Select _event
      :Case 'click'
          r←GenJS Update CURRFILES⊃⍨⍎5↓_what ⍝ id="nodeS23"
      :Case 'dblclick'
          r←Execute'window.location.href=',Q CURRFILES⊃⍨⍎5↓_what ⍝ id="nodeS23"
      :EndSelect
    ∇

    ∇ r←OnSearch;str;terms;out;i;dir;files;file;url;code;ctrlsec;desc;item;title
      :Access Public
      :If ×≢str←Get'str'  ⍝ get search string
      ⍝⍝⍝ Controls
          terms←INFOSHORT/⍨str In INFOSHORT
          terms,←terms~⍨INFOLONG/⍨str In INFOLONG
          terms←'.',¨∪Names terms
      ⍝⍝⍝ Samples
          out←NewDiv'.framed'
          CURRFILES←''
          i←0
          :For dir :In 'Apps' 'html' 'HTMLplus' 'DC' 'JQ' 'SF'
              files←Dlist'Examples/',dir
              :For file :In files~⊂'index'
                  url←'Examples/',dir,'/',file
                  code←Dread url
                  ctrlsec←'Control'Section code
                  desc←⊂'Description'Section code
                  :If ∨/str In desc
                  :OrIf ∨/∊(terms,⊂str)In¨⊂ctrlsec ⍝ always case sensitive
                      i+←1
                      CURRFILES,←⊂url
                      desc←∊desc,file Type⊃Words ctrlsec
                      item←('#nodeS',⍕i)'.listitem'out.Add _.p desc
                      item.On'click dblclick' 'OnSample'
                  :EndIf
              :EndFor
          :EndFor
          :If ~×i
              '.noitems'out.Add _.p,⊂'[no results for ',str,']'
          :EndIf
          title←(⍕≢CURRFILES),' results for ',Q str
          desc←'Click on a button below to view it embedded in this page or double-click to see it as a stand-alone page.'
          SEARCH←(Q str)title desc out''
      :EndIf
      r←GenJS SEARCH
     
    ∇

    ∇ (page title desc iframe code)←Update url;ctrlsec
     ⍝ Create new placeholder values
      page←'Sample'
      iframe←Frame url
      code←Dread url
      ctrlsec←'Control'Section code
      desc←'Description'Section code
      title←NewWinA ctrlsec url
     
    ∇

    ∇ r←GenJS(page title desc iframe code)
     ⍝ Generate JavaScript for filling placeholders
      r←'#title'Replace'MS3: ',page
      r,←'#SampleTitle'Replace title
      r,←'#SampleDesc'Replace desc
      r,←'#SampleFrame'Replace iframe
      r,←'#SampleSource'Replace(×≢code)/'x-small;border:none'#.HTMLInput.APLToHTMLColour code
    ∇

    ∇ node←GetNode
      node←4↓(1+'tree'≡4↑_what)⊃_what(Get'node')
    ∇
    :ENDSECTION

:EndClass
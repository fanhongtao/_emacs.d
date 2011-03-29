;; todo:
;; Constants other than Constants.au3
;; Macros

(defvar au3-mode-hook nil)

(defvar au3-mode-map
  (let ((au3-mode-map (make-keymap)))
    (define-key au3-mode-map "\C-j" 'newline-and-indent)
    au3-mode-map)
  "Keymap for AU3 major mode")


(add-to-list 'auto-mode-alist '("\\.au3\\'" . au3-mode))

(defvar au3-font-lock-keywords-builtins
  (list   
   '("\\<\\(A\\(?:Cos\\|Sin\\|Tan\\|bs\\|dlib\\(?:\\(?:Dis\\|En\\)able\\)\\|s\\(?:c\\|sign\\)\\|utoIt\\(?:SetOption\\|Win\\(?:[GS]etTitle\\)\\)\\)\\|B\\(?:eep\\|i\\(?:naryString\\|t\\(?:AND\\|NOT\\|OR\\|Rotate\\|Shift\\|XOR\\)\\)\\|lockInput\\|reak\\)\\|C\\(?:DTray\\|all\\|eiling\\|hr\\|lip\\(?:\\(?:Ge\\|Pu\\)t\\)\\|o\\(?:n\\(?:sole\\(?:Read\\|Write\\(?:Error\\)?\\)\\|trol\\(?:C\\(?:lick\\|ommand\\)\\|Disable\\|Enable\\|Focus\\|Get\\(?:Focus\\|Handle\\|Pos\\|Text\\)\\|Hide\\|ListView\\|Move\\|S\\(?:e\\(?:nd\\|tText\\)\\|how\\)\\)\\)\\|s\\)\\)\\|D\\(?:ec\\|ir\\(?:C\\(?:opy\\|reate\\)\\|\\(?:GetSiz\\|\\(?:M\\|Rem\\)ov\\)e\\)\\|ll\\(?:C\\(?:all\\|lose\\)\\|Open\\|Struct\\(?:Create\\|Get\\(?:Data\\|Ptr\\|Size\\)\\|SetData\\)\\)\\|rive\\(?:Get\\(?:Drive\\|FileSystem\\|Label\\|Serial\\|Type\\)\\|Map\\(?:Add\\|Del\\|Get\\)\\|S\\(?:etLabel\\|pace\\(?:Free\\|Total\\)\\|tatus\\)\\)\\)\\|E\\(?:nv\\(?:Get\\|Set\\|Update\\)\\|val\\|x\\(?:ecute\\|p\\)\\)\\|F\\(?:ile\\(?:C\\(?:hangeDir\\|lose\\|opy\\|reate\\(?:NTFSLink\\|Shortcut\\)\\)\\|Delete\\|Exists\\|Find\\(?:\\(?:Firs\\|Nex\\)tFile\\)\\|Get\\(?:Attrib\\|LongName\\|S\\(?:hort\\(?:Name\\|cut\\)\\|ize\\)\\|Time\\|Version\\)\\|Install\\|Move\\|Open\\(?:Dialog\\)?\\|Re\\(?:ad\\(?:Line\\)?\\|cycle\\(?:Empty\\)?\\)\\|S\\(?:aveDialog\\|e\\(?:lectFolder\\|t\\(?:Attrib\\|Time\\)\\)\\)\\|Write\\(?:Line\\)?\\)\\|loor\\|tpSetProxy\\)\\|GUI\\(?:C\\(?:reate\\|trl\\(?:Create\\(?:Avi\\|Button\\|C\\(?:heckbox\\|o\\(?:mbo\\|ntextMenu\\)\\)\\|D\\(?:ate\\|ummy\\)\\|Edit\\|Gr\\(?:aphic\\|oup\\)\\|I\\(?:con\\|nput\\)\\|L\\(?:abel\\|ist\\(?:View\\(?:Item\\)?\\)?\\)\\|M\\(?:enu\\(?:item\\)?\\|onthCal\\)\\|Obj\\|P\\(?:ic\\|rogress\\)\\|Radio\\|Slider\\|T\\(?:ab\\(?:Item\\)?\\|reeView\\(?:Item\\)?\\)\\|Updown\\)\\|Delete\\|Get\\(?:\\(?:Handl\\|Stat\\)e\\)\\|Re\\(?:ad\\|cvMsg\\|gisterListViewSort\\)\\|Se\\(?:nd\\(?:Msg\\|ToDummy\\)\\|t\\(?:BkColor\\|C\\(?:\\(?:ol\\|urs\\)or\\)\\|Data\\|Font\\|Graphic\\|Image\\|Limit\\|OnEvent\\|Pos\\|Resizing\\|St\\(?:\\(?:at\\|yl\\)e\\)\\|Tip\\)\\)\\)\\)\\|Delete\\|Get\\(?:CursorInfo\\|Msg\\)\\|RegisterMsg\\|S\\(?:et\\(?:BkColor\\|C\\(?:oord\\|ursor\\)\\|Font\\|Help\\|Icon\\|OnEvent\\|State\\)\\|tartGroup\\|witch\\)\\)\\|H\\(?:Wnd\\|ex\\|otKeySet\\|ttpSetProxy\\)\\|I\\(?:n\\(?:etGet\\(?:Size\\)?\\|i\\(?:Delete\\|Re\\(?:ad\\(?:Section\\(?:Names\\)?\\)?\\|nameSection\\)\\|Write\\(?:Section\\)?\\)\\|putBox\\|t\\)\\|s\\(?:A\\(?:dmin\\|rray\\)\\|B\\(?:inaryString\\|ool\\)\\|D\\(?:eclared\\|llStruct\\)\\|Float\\|HWnd\\|Int\\|Keyword\\|Number\\|Obj\\|String\\)\\)\\|Log\\|M\\(?:emGetStats\\|o\\(?:d\\|use\\(?:Click\\(?:Drag\\)?\\|Down\\|Get\\(?:Cursor\\|Pos\\)\\|Move\\|Up\\|Wheel\\)\\)\\|sgBox\\)\\|Number\\|Obj\\(?:Create\\|Event\\|Get\\|Name\\)\\|P\\(?:i\\(?:ng\\|xel\\(?:Checksum\\|GetColor\\|Search\\)\\)\\|ro\\(?:cess\\(?:Close\\|Exists\\|List\\|SetPriority\\|Wait\\(?:Close\\)?\\)\\|gress\\(?:O\\(?:ff\\|n\\)\\|Set\\)\\)\\)\\|R\\(?:andom\\|eg\\(?:Delete\\|Enum\\(?:Key\\|Val\\)\\|Read\\|Write\\)\\|ound\\|un\\(?:\\(?:AsSe\\|Wai\\)t\\)?\\)\\|S\\(?:Random\\|e\\(?:nd\\|tE\\(?:rror\\|xtended\\)\\)\\|h\\(?:ellExecute\\(?:Wait\\)?\\|utdown\\)\\|in\\|leep\\|ound\\(?:Play\\|SetWaveVolume\\)\\|plash\\(?:ImageOn\\|Off\\|TextOn\\)\\|qrt\\|t\\(?:atusbarGetText\\|d\\(?:errRead\\|inWrite\\|outRead\\)\\|ring\\(?:AddCR\\|Format\\|I\\(?:nStr\\|s\\(?:A\\(?:SCII\\|l\\(?:Num\\|pha\\)\\)\\|Digit\\|Float\\|Int\\|Lower\\|Space\\|Upper\\|XDigit\\)\\)\\|L\\(?:e\\(?:ft\\|n\\)\\|ower\\)\\|Mid\\|R\\(?:e\\(?:gExp\\(?:Replace\\)?\\|place\\)\\|ight\\)\\|S\\(?:plit\\|trip\\(?:CR\\|WS\\)\\)\\|Trim\\(?:\\(?:Lef\\|Righ\\)t\\)\\|Upper\\)?\\)\\)\\|T\\(?:CP\\(?:Accept\\|C\\(?:\\(?:loseSocke\\|onnec\\)t\\)\\|Listen\\|NameToIP\\|Recv\\|S\\(?:end\\|\\(?:hutdown\\|tartup\\),\\)\\)\\|an\\|imer\\(?:Diff\\|Init\\)\\|oolTip\\|ray\\(?:Create\\(?:Item\\|Menu\\)\\|GetMsg\\|Item\\(?:Delete\\|Get\\(?:Handle\\|State\\|Text\\)\\|Set\\(?:OnEvent\\|State\\|Text\\)\\)\\|Set\\(?:Click\\|Icon\\|OnEvent\\|PauseIcon\\|State\\|ToolTip\\)\\|Tip\\)\\)\\|U\\(?:Bound\\|DP\\(?:Bind\\|CloseSocket\\|Open\\|Recv\\|Send\\)\\)\\|Win\\(?:Activ\\(?:\\(?:at\\)?e\\)\\|Close\\|Exists\\|Flash\\|Get\\(?:C\\(?:aretPos\\|l\\(?:assList\\|ientSize\\)\\)\\|Handle\\|P\\(?:\\(?:o\\|roces\\)s\\)\\|State\\|T\\(?:ext\\|itle\\)\\)\\|Kill\\|List\\|M\\(?:enuSelectItem\\|inimizeAll\\(?:Undo\\)?\\|ove\\)\\|Set\\(?:OnTop\\|State\\|T\\(?:itle\\|rans\\)\\)\\|Wait\\(?:\\(?:Activ\\|Clos\\|NotActiv\\)e\\)?\\)\\)\\>"
     . font-lock-builtin-face))
  "Highlighting expressions for au3 builtins")
   
(defvar au3-font-lock-keywords-constants
  (list
   '("\\<\\(\\$\\(?:ACS_\\(?:AUTOPLAY\\|CENTER\\|NONTRANSPARENT\\|T\\(?:IMER\\|RANSPARENT\\)\\)\\|BS_\\(?:3STATE\\|AUTO\\(?:3STATE\\|CHECKBOX\\|RADIOBUTTON\\)\\|B\\(?:ITMAP\\|OTTOM\\)\\|C\\(?:ENTER\\|HECKBOX\\)\\|DEFPUSHBUTTON\\|FLAT\\|GROUPBOX\\|ICON\\|LEFT\\|MULTILINE\\|PUSH\\(?:BOX\\|LIKE\\)\\|RIGHT\\(?:BUTTON\\)?\\|TOP\\|VCENTER\\)\\|C\\(?:B\\(?:S_\\(?:AUTOHSCROLL\\|D\\(?:ISABLENOSCROLL\\|ROPDOWN\\(?:LIST\\)?\\)\\|LOWERCASE\\|NOINTEGRALHEIGHT\\|OEMCONVERT\\|S\\(?:IMPLE\\|ORT\\)\\|UPPERCASE\\)\\|_\\(?:ADDSTRING\\|D\\(?:DL_\\(?:ARCHIVE\\|D\\(?:IRECTORY\\|RIVES\\)\\|EXCLUSIVE\\|HIDDEN\\|READ\\(?:ONLY\\|WRITE\\)\\|SYSTEM\\)\\|ELETESTRING\\|IR\\)\\|ERR\\(?:ATTRIBUTE\\|REQUIRED\\|SPACE\\)?\\|FINDSTRING\\(?:EXACT\\)?\\|GET\\(?:C\\(?:OUNT\\|URSEL\\)\\|DROPPED\\(?:CONTROLRECT\\|STATE\\|WIDTH\\)\\|E\\(?:DITSEL\\|XTENDEDUI\\)\\|HORIZONTALEXTENT\\|ITEM\\(?:DATA\\|HEIGHT\\)\\|L\\(?:BTEXT\\(?:LEN\\)?\\|OCALE\\)\\|MINVISIBLE\\|TOPINDEX\\)\\|IN\\(?:ITSTORAGE\\|SERTSTRING\\)\\|LIMITTEXT\\|OKAY\\|RESETCONTENT\\|S\\(?:E\\(?:LECTSTRING\\|T\\(?:CURSEL\\|DROPPEDWIDTH\\|E\\(?:DITSEL\\|XTENDEDUI\\)\\|HORIZONTALEXTENT\\|ITEM\\(?:DATA\\|HEIGHT\\)\\|LOCALE\\|MINVISIBLE\\|TOPINDEX\\)\\)\\|HOWDROPDOWN\\)\\)\\)\\|C\\(?:M_\\(?:\\(?:FIRS\\|[GS]ETUNICODEFORMA\\)T\\)\\|S_\\(?:ADJUSTABLE\\|BOTTOM\\|NO\\(?:DIVIDER\\|HILITE\\|MOVEY\\|PARENTALIGN\\|RESIZE\\)\\|TOP\\)\\)\\|LR_NONE\\|OLOR_\\(?:AQUA\\|BL\\(?:ACK\\|UE\\)\\|FUCHSIA\\|GR\\(?:AY\\|EEN\\)\\|LIME\\|MAROON\\|NAVY\\|OLIVE\\|PURPLE\\|RED\\|SILVER\\|TEAL\\|WHITE\\|YELLOW\\)\\)\\|D\\(?:DL_\\(?:ARCHIVE\\|D\\(?:IRECTORY\\|RIVES\\)\\|EXCLUSIVE\\|HIDDEN\\|READ\\(?:ONLY\\|WRITE\\)\\|SYSTEM\\)\\|LG_\\(?:MOVEABLE\\|NOT\\(?:ITLE\\|ONTOP\\)\\|TEXT\\(?:LEFT\\|RIGHT\\|VCENTER\\)\\)\\|S_\\(?:CONTEXTHELP\\|MODALFRAME\\|SETFOREGROUND\\)\\|TS_\\(?:LONGDATEFORMAT\\|RIGHTALIGN\\|SHO\\(?:RTDATEFORMAT\\|WNONE\\)\\|TIMEFORMAT\\|UPDOWN\\)\\)\\|E\\(?:C\\(?:M_FIRST\\|_ERR\\)\\|M_\\(?:CANUNDO\\|EMPTYUNDOBUFFER\\|GET\\(?:FIRSTVISIBLELINE\\|LINE\\(?:COUNT\\)?\\|MODIFY\\|RECT\\|SEL\\)\\|LINE\\(?:FROMCHAR\\|INDEX\\|LENGTH\\|SCROLL\\)\\|REPLACESEL\\|S\\(?:CROLL\\(?:CARET\\)?\\|ET\\(?:MODIFY\\|READONLY\\|SEL\\|TABSTOPS\\)\\)\\|UNDO\\)\\|OF\\|S_\\(?:AUTO\\(?:[HV]SCROLL\\)\\|CENTER\\|DISABLENOSCROLL\\|L\\(?:EFT\\|OWERCASE\\)\\|MULTILINE\\|N\\(?:OHIDESEL\\|UMBER\\)\\|OEMCONVERT\\|PASSWORD\\|R\\(?:EADONLY\\|IGHT\\)\\|S\\(?:ELECTIONBAR\\|UNKEN\\)\\|UPPERCASE\\|VERTICAL\\|WANTRETURN\\)\\)\\|F\\(?:C_\\(?:\\(?:NO\\)?OVERWRITE\\)\\|D_\\(?:FILEMUSTEXIST\\|MULTISELECT\\|P\\(?:ATHMUSTEXIST\\|ROMPT\\(?:CREATENEW\\|OVERWRITE\\)\\)\\)\\|O_\\(?:APPEND\\|OVERWRITE\\|READ\\)\\|T_\\(?:\\(?:ACCESS\\|CREAT\\|MODIFI\\)ED\\)\\)\\|GUI_\\(?:A\\(?:CCEPTFILES\\|VI\\(?:CLOSE\\|ST\\(?:ART\\|OP\\)\\)\\)\\|BKCOLOR_\\(?:DEFAULT\\|LV_ALTERNATE\\|TRANSPARENT\\)\\|CHECKED\\|D\\(?:EFBUTTON\\|ISABLE\\|OCK\\(?:A\\(?:LL\\|UTO\\)\\|BO\\(?:RDERS\\|TTOM\\)\\|H\\(?:CENTER\\|EIGHT\\)\\|LEFT\\|MENUBAR\\|RIGHT\\|S\\(?:IZE\\|TATEBAR\\)\\|TOP\\|VCENTER\\|WIDTH\\)\\|ROPACCEPTED\\)\\|E\\(?:NABLE\\|VENT_\\(?:CLOSE\\|DROPPED\\|M\\(?:\\(?:AXIMIZ\\|INIMIZ\\|OUSEMOV\\)E\\)\\|PRIMARY\\(?:DOWN\\|UP\\)\\|RES\\(?:IZED\\|TORE\\)\\|SECONDARY\\(?:DOWN\\|UP\\)\\)\\|XPAND\\)\\|FO\\(?:CUS\\|NT\\(?:ITALIC\\|STRIKE\\|UNDER\\)\\)\\|GR_\\(?:BEZIER\\|C\\(?:LOSE\\|OLOR\\)\\|DOT\\|ELLIPSE\\|HINT\\|LINE\\|MOVE\\|NOBKCOLOR\\|P\\(?:ENSIZE\\|I\\(?:E\\|XEL\\)\\)\\|RE\\(?:CT\\|FRESH\\)\\)\\|HIDE\\|INDETERMINATE\\|NO\\(?:DROPACCEPTED\\|FOCUS\\)\\|ONTOP\\|RUNDEFMSG\\|S\\(?:HOW\\|S_DEFAULT_\\(?:AVI\\|BUTTON\\|C\\(?:HECKBOX\\|OMBO\\)\\|DATE\\|EDIT\\|G\\(?:R\\(?:APHIC\\|OUP\\)\\|UI\\)\\|I\\(?:CON\\|NPUT\\)\\|L\\(?:ABEL\\|IST\\(?:VIEW\\)?\\)\\|MONTHCAL\\|P\\(?:IC\\|ROGRESS\\)\\|RADIO\\|SLIDER\\|T\\(?:AB\\|REEVIEW\\)\\|UPDOWN\\)\\)\\|UNCHECKED\\|WS_EX_PARENTDRAG\\)\\|ID\\(?:ABORT\\|C\\(?:ANCEL\\|ONTINUE\\|_\\(?:A\\(?:PPSTARTING\\|RROW\\)\\|CROSS\\|HELP\\|I\\(?:BEAM\\|CON\\)\\|NO\\|SIZE\\(?:ALL\\|N\\(?:ESW\\|S\\|WSE\\)\\|WE\\)?\\|U\\(?:NKNOWN\\|PARROW\\)\\|WAIT\\)\\)\\|IGNORE\\|NO\\|OK\\|RETRY\\|T\\(?:IMEOUT\\|RYAGAIN\\)\\|YES\\)\\|KB_\\(?:CAPSO\\(?:FF\\|N\\)\\|SEND\\(?:RAW\\|SPECIAL\\)\\)\\|L\\(?:B\\(?:S_\\(?:DISABLENOSCROLL\\|MULTIPLESEL\\|NO\\(?:INTEGRALHEIGHT\\|SEL\\|TIFY\\)\\|S\\(?:ORT\\|TANDARD\\)\\|USETABSTOPS\\)\\|_\\(?:ADDSTRING\\|D\\(?:ELETESTRING\\|IR\\)\\|ERR\\(?:ATTRIBUTE\\|REQUIRED\\|SPACE\\)?\\|FINDSTRING\\(?:EXACT\\)?\\|GET\\(?:ANCHORINDEX\\|C\\(?:ARETINDEX\\|OUNT\\|URSEL\\)\\|HORIZONTALEXTENT\\|ITEMRECT\\|L\\(?:ISTBOXINFO\\|OCALE\\)\\|SEL\\(?:COUNT\\|ITEMS\\)?\\|T\\(?:EXT\\(?:LEN\\)?\\|OPINDEX\\)\\)\\|INSERTSTRING\\|RESETCONTENT\\|SE\\(?:L\\(?:ECTSTRING\\|ITEMRANGE\\(?:EX\\)?\\)\\|T\\(?:ANCHORINDEX\\|C\\(?:ARETINDEX\\|URSEL\\)\\|HORIZONTALEXTENT\\|ITEMHEIGHT\\|LOCALE\\|SEL\\|TOPINDEX\\)\\)\\)\\)\\|V\\(?:A_\\(?:ALIGN\\(?:LEFT\\|TOP\\)\\|DEFAULT\\|SNAPTOGRID\\)\\|CF\\(?:MT_\\(?:CENTER\\|\\(?:LEF\\|RIGH\\)T\\)\\|_\\(?:FMT\\|TEXT\\|WIDTH\\)\\)\\|FI_\\(?:PAR\\(?:AM\\|TIAL\\)\\|STRING\\|WRAP\\)\\|I\\(?:F_\\(?:STATE\\|TEXT\\)\\|R_BOUNDS\\|S_\\(?:CUT\\|DROPHILITED\\|FOCUSED\\|OVERLAYMASK\\|S\\(?:ELECTED\\|TATEIMAGEMASK\\)\\)\\)\\|M_\\(?:ARRANGE\\|CANCELEDITLABEL\\|DELETE\\(?:ALLITEMS\\|COLUMN\\|ITEM\\)\\|E\\(?:DITLABELA?\\|N\\(?:ABLEGROUPVIEW\\|SUREVISIBLE\\)\\)\\|FI\\(?:NDITEM\\|RST\\)\\|GET\\(?:BKCOLOR\\|C\\(?:ALLBACKMASK\\|O\\(?:LUMN\\(?:ORDERARRAY\\|WIDTH\\)\\|UNTPERPAGE\\)\\)\\|E\\(?:DITCONTROL\\|XTENDEDLISTVIEWSTYLE\\)\\|H\\(?:EADER\\|O\\(?:T\\(?:CURSOR\\|ITEM\\)\\|VERTIME\\)\\)\\|I\\(?:MAGELIST\\|TEM\\(?:A\\|COUNT\\|STATE\\|TEXTA\\)\\)\\|NEXTITEM\\|S\\(?:ELECTEDCO\\(?:LUMN\\|UNT\\)\\|UBITEMRECT\\)\\|TOPINDEX\\|UNICODEFORMAT\\|VIEW\\(?:RECT\\)?\\)\\|INSERT\\(?:\\(?:COLUMN\\|ITEM\\)A\\)\\|REDRAWITEMS\\|S\\(?:CROLL\\|ET\\(?:BKCOLOR\\|C\\(?:ALLBACKMASK\\|OLUMN\\(?:A\\|ORDERARRAY\\|WIDTH\\)\\)\\|EXTENDEDLISTVIEWSTYLE\\|HO\\(?:TITEM\\|VERTIME\\)\\|I\\(?:CONSPACING\\|TEM\\(?:COUNT\\|POSITION\\|STATE\\|TEXTA\\)\\)\\|SELECTEDCOLUMN\\|TEXT\\(?:\\(?:BK\\)?COLOR\\)\\|UNICODEFORMAT\\|VIEW\\)\\)\\|UPDATE\\)\\|NI_\\(?:A\\(?:BOVE\\|LL\\)\\|BELOW\\|CUT\\|DROPHILITED\\|FOCUSED\\|SELECTED\\|TO\\(?:\\(?:LEF\\|RIGH\\)T\\)\\)\\|S\\(?:CW_AUTOSIZE\\(?:_USEHEADER\\)?\\|I\\(?:CF_NO\\(?:\\(?:INVALIDATEA\\|SCRO\\)LL\\)\\|L_\\(?:NORMAL\\|S\\(?:MALL\\|TATE\\)\\)\\)\\|_\\(?:E\\(?:DITLABELS\\|X_\\(?:BORDERSELECT\\|CHECKBOXES\\|DOUBLEBUFFER\\|F\\(?:LATSB\\|ULLROWSELECT\\)\\|GRIDLINES\\|H\\(?:EADERDRAGDROP\\|IDELABELS\\)\\|INFOTIP\\|LABELTIP\\|MULTIWORKAREAS\\|ONECLICKACTIVATE\\|REGIONAL\\|S\\(?:INGLEROW\\|NAPTOGRID\\|UBITEMIMAGES\\)\\|T\\(?:RACKSELECT\\(?:\\)?\\|WOCLICKACTIVATE\\)\\|UNDERLINE\\(?:COLD\\|HOT\\)\\)\\)\\|ICON\\|LIST\\|NO\\(?:COLUMNHEADER\\|LABELWRAP\\|SORTHEADER\\)\\|REPORT\\|S\\(?:HOWSELALWAYS\\|INGLESEL\\|MALLICON\\|ORT\\(?:\\(?:A\\|DE\\)SCENDING\\)\\)\\)\\)\\|_\\(?:ERR\\|VIEW_\\(?:DETAILS\\|ICON\\|LIST\\|SMALLICON\\|TILE\\)\\)\\)\\)\\|M\\(?:B_\\(?:A\\(?:BORTRETRYIGNORE\\|PPLMODAL\\)\\|DEFBUTTON[123]\\|ICON\\(?:ASTERISK\\|EXCLAMATION\\|HAND\\|QUESTION\\)\\|OK\\(?:CANCEL\\)?\\|R\\(?:ETRYCANCEL\\|IGHTJUSTIFIED\\)\\|SYSTEMMODAL\\|T\\(?:ASKMODAL\\|OPMOST\\)\\|YESNO\\(?:CANCEL\\)?\\)\\|C\\(?:M_\\(?:FIRST\\|GET\\(?:COLOR\\|FIRSTDAYOFWEEK\\|M\\(?:AX\\(?:SELCOUNT\\|TODAYWIDTH\\)\\|INREQRECT\\|ONTHDELTA\\)\\)\\|SET\\(?:COLOR\\|FIRSTDAYOFWEEK\\|M\\(?:AXSELCOUNT\\|ONTHDELTA\\)\\)\\)\\|S\\(?:C_\\(?:BACKGROUND\\|MONTHBK\\|T\\(?:EXT\\|ITLE\\(?:BK\\|TEXT\\)\\|RAILINGTEXT\\)\\)\\|_\\(?:MULTISELECT\\|NOTODAY\\(?:CIRCLE\\)?\\|WEEKNUMBERS\\)\\)\\)\\)\\|OPT_\\(?:C\\(?:APS\\(?:\\(?:NO\\)?STORE\\)\\|OORDS\\(?:ABSOLUTE\\|CLIENT\\|RELATIVE\\)\\)\\|ERROR\\(?:FATAL\\|SILENT\\)\\|MATCH\\(?:A\\(?:DVANCED\\|NY\\)\\|\\(?:EXAC\\|STAR\\)T\\)\\)\\|PBS_\\(?:SMOOTH\\|VERTICAL\\)\\|REG_\\(?:BINARY\\|DWORD\\(?:_BIG_ENDIAN\\)?\\|EXPAND_SZ\\|FULL_RESOURCE_DESCRIPTOR\\|LINK\\|MULTI_SZ\\|NONE\\|RESOURCE_\\(?:\\(?:REQUIREMENTS_\\)?LIST\\)\\|SZ\\)\\|S\\(?:B\\(?:ARS_SIZEGRIP\\|T_\\(?:NOBORDERS\\|OWNERDRAW\\|POPOUT\\|RTLREADING\\|SUNKEN\\|TOOLTIPS\\)\\|_\\(?:GET\\(?:BORDERS\\|ICON\\|PARTS\\|RECT\\|T\\(?:EXT\\(?:LENGTH\\)?\\|IPTEXT\\)\\|UNICODEFORMAT\\)\\|ISSIMPLE\\|LINE\\(?:DOWN\\|UP\\)\\|PAGE\\(?:DOWN\\|UP\\)\\|S\\(?:CROLLCARET\\|ET\\(?:BKCOLOR\\|ICON\\|MINHEIGHT\\|PARTS\\|\\(?:T\\(?:\\(?:IPT\\)?EX\\)\\|UNICODEFORMA\\)T\\)\\|IMPLE\\(?:ID\\)?\\)\\)\\)\\|D_\\(?:FORCE\\|LOGOFF\\|POWERDOWN\\|REBOOT\\|SHUTDOWN\\)\\|S_\\(?:B\\(?:ITMAP\\|LACK\\(?:FRAME\\|RECT\\)\\)\\|CENTER\\(?:IMAGE\\)?\\|ETCHED\\(?:FRAME\\|HORZ\\|VERT\\)\\|GRAY\\(?:FRAME\\|RECT\\)\\|ICON\\|LEFT\\(?:NOWORDWRAP\\)?\\|NO\\(?:PREFIX\\|TIFY\\)\\|RIGHT\\(?:JUST\\)?\\|S\\(?:IMPLE\\|UNKEN\\)\\|WHITE\\(?:FRAME\\|RECT\\)\\)\\|T\\(?:D\\(?:\\(?:ERR\\|IN\\|OUT\\)_CHILD\\)\\|R_\\(?:CASESENSE\\|NOCASESENSE\\|STRIP\\(?:ALL\\|LEADING\\|SPACES\\|TRAILING\\)\\)\\)\\)\\|T\\(?:B\\(?:M_\\(?:CLEARTICS\\|GET\\(?:LINESIZE\\|NUMTICS\\|P\\(?:AGESIZE\\|OS\\)\\|RANGEM\\(?:AX\\|IN\\)\\)\\|SET\\(?:LINESIZE\\|P\\(?:AGESIZE\\|OS\\)\\|TICFREQ\\)\\)\\|S_\\(?:AUTOTICKS\\|BOT\\(?:H\\|TOM\\)\\|HORZ\\|LEFT\\|NOT\\(?:HUMB\\|ICKS\\)\\|RIGHT\\|TOP\\|VERT\\)\\)\\|C\\(?:CM_\\(?:\\(?:FIRS\\|[GS]ETUNICODEFORMA\\)T\\)\\|IS_BUTTONPRESSED\\|M_\\(?:DE\\(?:LETE\\(?:ALLITEMS\\|ITEM\\)\\|SELECTALL\\)\\|FIRST\\|GET\\(?:CUR\\(?:FOCUS\\|SEL\\)\\|EXTENDEDSTYLE\\|\\(?:ITEM\\(?:COUN\\|REC\\)\\|ROWCOUN\\|UNICODEFORMA\\)T\\)\\|HIGHLIGHTITEM\\|SET\\(?:CUR\\(?:FOCUS\\|SEL\\)\\|ITEMSIZE\\|MINTABWIDTH\\|PADDING\\|UNICODEFORMAT\\)\\)\\|N_\\(?:FIRST\\|SELCHANG\\(?:E\\|ING\\)\\)\\|S_\\(?:B\\(?:OTTOM\\|UTTONS\\)\\|EX_\\(?:FLATSEPARATORS\\(?:\\)?\\|REGISTERDROP\\(?:\\)?\\)\\|F\\(?:IXEDWIDTH\\|LATBUTTONS\\|O\\(?:CUS\\(?:NEVER\\|ONBUTTONDOWN\\)\\|RCE\\(?:\\(?:ICON\\|LABEL\\)LEFT\\)\\)\\)\\|HOTTRACK\\|MULTI\\(?:LINE\\|SELECT\\)\\|OWNERDRAWFIXED\\|R\\(?:AGGEDRIGHT\\|IGHT\\(?:JUSTIFY\\)?\\)\\|S\\(?:\\(?:CROLLOPPOSIT\\|INGLELIN\\)E\\)\\|T\\(?:\\(?:AB\\|OOLTIP\\)S\\)\\|VERTICAL\\)\\|_ERR\\)\\|IP_\\(?:ICON\\(?:ASTERISK\\|EXCLAMATION\\|HAND\\|NONE\\)\\|NOSOUND\\)\\|RAY_\\(?:CHECKED\\|D\\(?:EFAULT\\|ISABLE\\)\\|E\\(?:NABLE\\|VENT_\\(?:FLASHICON\\|HIDEICON\\|MOUSEO\\(?:UT\\|VER\\)\\|NOFLASHICON\\|PRIMARY\\(?:DO\\(?:UBLE\\|WN\\)\\|UP\\)\\|S\\(?:ECONDARY\\(?:DO\\(?:UBLE\\|WN\\)\\|UP\\)\\|HOWICON\\)\\)\\)\\|FOCUS\\|ITEM_\\(?:EXIT\\|FIRST\\|PAUSE\\)\\|UNCHECKED\\)\\|V\\(?:E_\\(?:COLLAPSE\\(?:RESET\\)?\\|EXPAND\\(?:PARTIAL\\)?\\|TOGGLE\\)\\|GN_\\(?:C\\(?:ARET\\|HILD\\)\\|\\(?:NEX\\|PAREN\\|ROO\\)T\\)\\|I\\(?:F_\\(?:CHILDREN\\|HANDLE\\|IMAGE\\|PARAM\\|S\\(?:\\(?:ELECTEDIMAG\\|TAT\\)E\\)\\|TEXT\\)\\|S_\\(?:BOLD\\|CUT\\|DROPHILITED\\|EXPAND\\(?:ED\\(?:ONCE\\)?\\|PARTIAL\\)\\|OVERLAYMASK\\|S\\(?:ELECTED\\|TATEIMAGEMASK\\)\\)\\|_\\(?:\\(?:FIRS\\|LAS\\|ROO\\|SOR\\)T\\)\\)\\|M_\\(?:DELETEITEM\\|E\\(?:NSUREVISIBLE\\|XPAND\\)\\|GET\\(?:BKCOLOR\\|COUNT\\|I\\(?:MAGELIST\\|NDENT\\|TEM\\)\\|LINECOLOR\\|NEXTITEM\\|TEXTCOLOR\\)\\|INSERTITEM\\|S\\(?:E\\(?:LECTITEM\\|T\\(?:BKCOLOR\\|I\\(?:MAGELIST\\|NDENT\\|TEM\\)\\|\\(?:LINE\\|TEXT\\)COLOR\\)\\)\\|ORTCHILDREN\\)\\)\\|S_\\(?:CHECKBOXES\\|DISABLEDRAGDROP\\|EDITLABELS\\|FULLROWSELECT\\|HAS\\(?:\\(?:BUTTON\\|LINE\\)S\\)\\|INFOTIP\\|LINESATROOT\\|NO\\(?:NEVENHEIGHT\\|SCROLL\\|TOOLTIPS\\)\\|RTLREADING\\|S\\(?:HOWSELALWAYS\\|INGLEEXPAND\\)\\|TRACKSELECT\\)\\|_FIRST\\)\\|WM_USER\\)\\|UDS_\\(?:A\\(?:LIGN\\(?:\\(?:LEF\\|RIGH\\)T\\)\\|RROWKEYS\\)\\|HORZ\\|NOTHOUSANDS\\|SETBUDDYINT\\|WRAP\\)\\|VK_\\(?:DOWN\\|END\\|LEFT\\|NEXT\\|PRIOR\\|RIGHT\\|UP\\)\\|W\\(?:M_\\(?:GETTEXT\\(?:LENGTH\\)?\\|SIZ\\(?:E\\|ING\\)\\|USER\\)\\|S_\\(?:BORDER\\|C\\(?:APTION\\|HILD\\|LIP\\(?:CHILDREN\\|SIBLINGS\\)\\)\\|D\\(?:ISABLED\\|LGFRAME\\)\\|EX_\\(?:A\\(?:CCEPTFILES\\|PPWINDOW\\)\\|C\\(?:LIENTEDGE\\|ONTEXTHELP\\)\\|DLGMODALFRAME\\|L\\(?:AYERED\\|EFTSCROLLBAR\\)\\|MDICHILD\\|OVERLAPPEDWINDOW\\|RIGHT\\|STATICEDGE\\|T\\(?:O\\(?:OLWINDOW\\|PMOST\\)\\|RANSPARENT\\)\\|WINDOWEDGE\\)\\|GROUP\\|HSCROLL\\|M\\(?:AXIMIZE\\(?:BOX\\)?\\|INIMIZE\\(?:BOX\\)?\\)\\|OVERLAPPED\\(?:WINDOW\\)?\\|POPUP\\(?:WINDOW\\)?\\|S\\(?:IZEBOX\\|YSMENU\\)\\|T\\(?:ABSTOP\\|HICKFRAME\\|ILED\\(?:WINDOW\\)?\\)\\|V\\(?:ISIBLE\\|SCROLL\\)\\)\\)\\)\\|\\(?:Fals\\|Tru\\)e\\)\\>"
     . font-lock-constant-face))
  "Highlighting expressions for au3 constants")
   
(defvar au3-font-lock-keywords-keywords
  (list
   '("\\<\\(#\\(?:NoTrayIcon\\|RequireAdmin\\|c\\(?:omments-start\\|[es]\\)\\|include\\(?:-once\\)?\\)\\|C\\(?:ase\\(?:\\)?\\|on\\(?:st\\|tinue\\(?:Case\\|Loop\\)\\)\\)\\|D\\(?:efault\\|im\\|o\\)\\|E\\(?:lse\\(?:If\\)?\\|n\\(?:d\\(?:Func\\|If\\|S\\(?:elect\\|witch\\)\\|With\\)\\|um\\)\\|xit\\(?:Loop\\)?\\)\\|F\\(?:or\\(?:\\)?\\|unc\\)\\|Global\\|I[fn]\\|Local\\|N\\(?:\\(?:ex\\(?:\\)?\\|o\\)t\\)\\|OnAutoIt\\(?:\\(?:Exi\\|Star\\)t\\)\\|Re\\(?:Dim\\|turn\\)\\|S\\(?:elect\\|witch\\)\\|Then\\|Until\\|W\\(?:End\\|hile\\|ith\\)\\)\\>"
     . font-lock-keyword-face))
  "Highlighting expressions for au3 keywords")
   
(defvar au3-font-lock-keywords-types
  (list
   '("\\<\\(B\\(?:inaryString\\|oolean\\)\\|Number\\|String\\)\\>"
     . font-lock-type-face))
  "Highlighting expressions for au3 types")
   
(defvar au3-font-lock-keywords-variables
  (list
   '("\\<\\$\\w*\\>" 
     . font-lock-variable-name-face))
  "Highlighting expressions for au3 variables")

(defconst au3-font-lock-keywords 
  (append 
   au3-font-lock-keywords-builtins
   au3-font-lock-keywords-constants
   au3-font-lock-keywords-keywords
   au3-font-lock-keywords-types
   au3-font-lock-keywords-variables
   )
  ) 

(defun au3-indent-line ()
  "Indent current line as AU3 code"
  (interactive)
  (beginning-of-line)
  
  (if (bobp)  ; Check for rule 1
      (indent-line-to 0)
    
    (let ((not-indented t) cur-indent)
      
      (if (looking-at "^[ \t]*\\<\\(Next\\|EndFunc\\|ElseIf\\|Else\\|EndIf\\|EndSelect\\|EndSwitch\\|WEnd\\|EndWith\\)\\>") ; Check for rule 2
          (progn
            (save-excursion
              (forward-line -1)
              (setq cur-indent (- (current-indentation) default-tab-width)))
            
            (if (< cur-indent 0)
                (setq cur-indent 0))

            (if (looking-at "^[ \t]*\\<\\(ElseIf\\|Else\\)\\>")
                (progn
                  (save-excursion
                    (forward-line -1)
                    (setq cur-indent (- (current-indentation) default-tab-width))))))
        
        (save-excursion 
          (while not-indented
            (forward-line -1)
            (if (looking-at "^[ \t]*\\<\\(Next\\|EndFunc\\|EndIf\\|EndSelect\\|EndSwitch\\|WEnd\\|EndWith\\)\\>") ; Check for rule 3
                (progn
                  (setq cur-indent (current-indentation))
                  (setq not-indented nil))
                                        ; Check for rule 4
              (if (looking-at "^[ \t]*\\<\\(For\\|Func\\|If\\|Select\\|Switch\\|While\\|With\\)\\>")
                  (progn
                    (setq cur-indent (+ (current-indentation) default-tab-width))
                    (setq not-indented nil))
                
                (if (bobp) ; Check for rule 5
                    (setq not-indented nil)))))))
      
      (if cur-indent
          (indent-line-to cur-indent)
        (indent-line-to 0))))) ; If we didn't see an indentation hint, then allow no indentation


(defvar au3-mode-syntax-table
  (let ((au3-mode-syntax-table (make-syntax-table)))
    (modify-syntax-entry ?_ "w" au3-mode-syntax-table)
    (modify-syntax-entry ?\; "<" au3-mode-syntax-table)
    (modify-syntax-entry ?\n ">" au3-mode-syntax-table)
    au3-mode-syntax-table)
  "Syntax table for au3-mode")

(defun au3-mode ()
  "Major mode for editing AutoIt version 3 Language files"
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table au3-mode-syntax-table)
  (use-local-map au3-mode-map)
  (set (make-local-variable 'font-lock-defaults) '(au3-font-lock-keywords))
  (set (make-local-variable 'indent-line-function) 'au3-indent-line)  
  (set (make-local-variable 'font-lock-keywords-case-fold-search) t)
  (set (make-local-variable 'default-tab-width) 2)
  (set (make-local-variable 'case-fold-search) t)
  (setq major-mode 'au3-mode)
  (setq mode-name "au3")
  (run-hooks 'au3-mode-hook))

; (define-derived-mode au3-mode fundamental-mode "AU3"
;   "Major mode for editing AutoIt version 3 Language files."
;   (set (make-local-variable 'font-lock-defaults) '(au3-font-lock-keywords))
;   (set (make-local-variable 'indent-line-function) 'au3-indent-line)
;   (setq default-tab-width 2)
;   )

(provide 'au3-mode)



(defun keyword-help-lookup-chm (file-path keyword)
   "Open a window showing the Visual C++ documentation for the word under the point"
   (interactive "fChm File: \nSKeyword: ")
   (start-process "keyhh" nil "keyhh.exe"
		  (concat "-" mode-name) ;; use mode name as ID
		  "-#klink" (format "'%s'" keyword)
		  file-path))

(global-set-key (kbd "<C-f1>") '(lambda ()
				  (interactive)
				  (let ( (symbol (thing-at-point 'symbol)) )
				    (keyword-help-lookup-chm "d:\\wintools\\AutoHotkey\\AutoHotkey.chm" symbol))))






;;;TODO

(setq keyword-help-lookup-alist      
  '(
    ("AHK" . (chm  "d:\\Programs\\AutoHotkey\\AutoHotkey-chs.chm"))
    ("PHP" . (web  "http://www.php.net/manual/en/"))
    ("Emacs-Lisp" . (chm "e:\\emacs.sync\\doc\\elisp.chm"))
    (".afaf" . (hlp "afafa"))
    ))

(defun keyword-help-lookup ()
  (interactive)
  (let ( (myword (if (and transient-mark-mode mark-active)
		     (buffer-substring-no-properties (region-beginning) (region-end))
		   (thing-at-point 'symbol)))
	 (config (assoc mode-name keyword-help-lookup-alist)) )
    (when config
      ;; (let ( (keyword-trans-func (nth 3 config)) )
      ;; 	(funcall (concat "keyword-help-loopup-" (nth 1 config))
      ;; 	       (list (nth 2 config) 

      ;; 		     (or (if (nth 3 config)
      ;; 			     (apply (nth 3 config) 

      ;; 			     (assoc mode-name keyword-help-lookup-alist))
      (keyword-help-lookup-chm (nth 2 config)))))

(global-set-key (kbd "C-h C-w") 'keyword-help-lookup)







;; CHM (HtmlHelp)
;;note: KeyHH.exe needs to be in $PATH.
;;KeyHH -MyHelp -#klink "ActiveX Control Wizard" htmlhelp.chm
(defun keyword-help-lookup-chm (help-file keyword)
  "lookup a keyword in a CHM file and display it"
    (start-process "keyhh" nil
		   "keyhh.exe"
		   (concat "-" (symbol-name major-mode))
		   "-#klink" (format "'%s'" keyword)
		   help-file )
    (set-process-query-on-exit-flag (get-process "keyhh") nil)
    )

;; MS Help 2 (MSDN)
;; http://www.emacswiki.org/emacs/MsdnHelp
;; You need `h2viewer' utility from 
;; 	http://www.helpware.net/mshelp2/h2viewer.htm
;; invoke it as this:
;; 	h2viewer /helpcol MS.PSDK.1033 /keyword K$CreateWindowEx
(defun keyword-help-lookup-hh2 (helpcol keyword)
  "Open a window showing the MSDN documentation for the word under the point"
  (interactive)
  (if (string= "w32" window-system)
      (start-process "h2viewer" nil 
		     "h2viewer.exe"
		     "/appID" "MSDN-Viewer"
		     "/helpcol" helpcol
;; 		     "/filtername" "Visual C++"
		     "/keyword" (concat "K$" (current-word)))))

;;(keyword-help-lookup-hh2 "embarcadero.rs2010" "TListView")

;; GNOME DevHelp
;; got from devhelp's source package
(defun keyword-help-lookup-devhelp (placeholder keyword)
  "Searches for the current word in Devhelp"
  (start-process-shell-command "devhelp" nil "devhelp" "-s" keyword)
  (set-process-query-on-exit-flag (get-process "devhelp") nil))


(defcustom keyword-help-url nil
  "Help file path used to show keyword sensitive help.
  .CHM and .HLP format are supported."
  :type 'string)

 "Paths of Help files used to show keyword sensitive help."
;; Major mode name -> help file path
(setq keyword-help-url-alist 
  '( ("Pascal"		 "e:/lazarus/docs/chm/lazarus.chm")
     ("Delphi"		 "d:/Borland/Delphi7/Help/d7.hlp")
     ;;("PHP"		 "e:/Apache2.2/php_manual_en.chm")
     ("PHP"		 "http://php.chinaunix.net/manual-lookup.php?pattern=%s")
     ("Python"		 "e:/Python/ActivePython25.chm")
     ("Pascal"		 "e:/lazarus/docs/chm/lazarus.chm")
     ("Emacs-Lisp"	 "e:/emacs/doc/manual-chm/elisp.chm")
     ("Help"		 "e:/emacs/doc/manual-chm/elisp.chm")
     ("Lisp Interaction" "e:/emacs/doc/manual-chm/elisp.chm")
     ("AHK"		 "d:/Programs/AutoHotKey/AutoHotkey-chs.chm")
     ;;("AHK"              "http://www.autohotkey.com/docs/commands/%s.htm")
     ("AutoIt"		 "D:/Programs/AutoIt3/AutoIt3.chm")
     ("Java"		 "d:/java/jdk140.chm")
     ("iss"		 "d:/Program Files/Inno Setup 5/ISetup.chm")
     ("Perl"		 "http://perldoc.perl.org/search.html?q=%s")
     ("AWK/l"		 "E:/docs/gnuwin32/gawk.chm")
     ))

(defun invoke-keyword-help(&optional arg)
  "Show the help info for the keyword at point. CHM and HLP are supported.
  
You need to set `keyword-help-url-alist' or `keyword-help-url'
before using this.  By default, the path of help file is
looked-up from `keyword-help-url-alist' by mode name.  If any
ARG given, `keyword-help-url' is used."
  (interactive)
  
  (let ( (typeid    mode-name)
	 (help-url (or (car (cdr (assoc mode-name keyword-help-url-alist)))
			keyword-help-url))
	 (keyword   (if (and transient-mark-mode mark-active)
                   (buffer-substring-no-properties (region-beginning) (region-end))
                 (thing-at-point 'symbol)) ))
    (when help-url
      (if (string= "http" (substring help-url 0 4))
	  (keyword-help-lookup-web help-url keyword)				   
	(let* ( (help-file help-url)
		(ext (downcase (substring help-file (- (length help-file) 3)) )) )
	  (if (file-exists-p help-file)
	      (progn
		(message "invoke help for '%s': %s " keyword help-file)
		(cond
		 ((string= ext "chm") (keyword-help-lookup-chm help-file keyword))
		 ((string= ext "hlp") (keyword-help-lookup-hlp help-file keyword))))
	    (message "Help file not exist: %s" help-file)))))
	))
  
     
  

;;;{{{ WinHelp  http://www.emacswiki.org/emacs/AccessingWindowsHelpFiles
(require 'etags)
 (defun tcl-help ()
   (interactive )
   (shell-command 
    (concat "c:/winnt/winhlp32 -k " 
	    (find-tag-default)  
	    " D:/Program Files/Tcl/doc/tcl83.hlp &")))







;;;{{{ CHM    http://www.emacswiki.org/emacs/MsdnHelp

;; Here¡¯s a little something that I whipped up that will allow newer
;; Htmlhelp-based versions of the msdn work from within emacs. You
;; will need to download and install the free Htmlhelp helper program
;; Keyhh.exe from http://www.keyworks.net, since the default Microsoft
;; HH.exe will not allow you to search for keywords from the
;; command-line, but instead forces you to use the Htmlhelp
;; API. (Note: this is my first attempt at lisp, so YMMV)

(defun show-vc-topic ()
   "Open a window showing the Visual C++ documentation for the word under the point"
   (interactive)
   (cond
    ((string= "w32" window-system)
     (start-process "vc++ msdn lookup" nil "C:/WINNT/keyhh.exe" "-#klink" (format "'%s'" (thing-at-point 'symbol)) "E:/MSDN98/98VS/1033/VCCORE.CHM" ))))

(defun show-glibc-topic ()
  "Open a window showing the glibc documentation for the word under the point"
  (interactive)
  (cond
   ((string= "w32" window-system)
    (start-process "glibc lookup" nil "C:/WINNT/keyhh.exe" "-#klink" (format "'%s'" (thing-at-point 'symbol)) "E:/documents/glibc-2.2.3.chm" ))))

(defun show-chm-keyword-help(chmfile keyword)
  (let ((id (upcase (format "%s" major-mode))))
    (start-process "KEYHH" nil "keyhh" (concat "-" id) "-#klink" keyword chmfile))) 

;;; test
(show-chm-keyword-help "d:/Programs/AutoHotkey/AutoHotkey.chm" "ifWinExist")


;;{{{ MSDN  http://emacswiki.org/emacs/MsdnHelp

;; The new format is ¡°Microsoft Help 2¡± and is viewed with
;; ¡°Microsoft Document Explorer¡±. Just as (as is noted below)
;; Microsoft¡¯s HH.exe does not allow command-line keyword searches,
;; Document Explorer (dexplore.exe) does not allow it. H2Viewer is
;; free software that provides this functionality. The following
;; command will open the MSDN Platform SDK documentation for the
;; ¡°CreateWindowEx?¡± function (1033 indicates English language):

;; h2viewer /helpcol MS.PSDK.1033 /keyword K$CreateWindowEx

(defun show-msdn-topic ()
  "Open a window showing the MSDN documentation for the word under the point"
  (interactive)
  (if (string= "w32" window-system)
      (start-process "MSDN lookup" nil 
		     "D:/H2Viewer132/h2viewer.exe"
		     "/appID" "MSDN-Viewer"
		     "/helpcol" "MS.VSCC.2003"
;; 		     "/filtername" "Visual C++"
		     "/Index" (current-word))))



;;;TODO

(defcustom winhelp-mode-map
  '(
    (".ahk" . ('chm  "d:\Programs\AutoHotkey\AutoHotkey.chm"))
    (".php" . ('web  "http://www.php.net/manual/en/"))
    (".afaf" . ('hlp "afafa"))
    ))

(global-set-key (kbd "C-h C-w") 'keyword-help-lookup)
     
  

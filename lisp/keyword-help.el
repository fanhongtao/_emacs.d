
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
     
  

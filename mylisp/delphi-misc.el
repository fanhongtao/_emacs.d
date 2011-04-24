
(require 'delphi)
(require 'pascal)

;;{{{ imenu improvement
;; Based on code http://www.emacswiki.org/emacs/DelphiMode  
(defvar imenu--function-name-regexp-delphi  
  (concat  
   "^[ \t]*\\(function\\|procedure\\|constructor\\|destructor\\)[ \t]+"  
   "\\([_a-zA-Z][_a-zA-Z0-9]*\\.\\)?"   ; class?  
   "\\([_a-zA-Z][_a-zA-Z0-9]*\\)")  
  "Re to get function/procedure names in Delphi.")  

(defvar imenu--type-name-regexp-delphi  
  (concat "^[ \t]*\\([a-zA-Z0-9]*\\)[ \t]*=[ \t]*\\(class\\|record\\|interface\\)"  
	  "")  
  "regexp to get class/record namesin Delphi.")  

(defun imenu--create-delphi-index-enh (&optional regexp)  
  (let ((index-alist '())  
	(progress-prev-pos 0)  
	(case-fold-search t))  
    (goto-char (point-min))  
    (imenu-progress-message progress-prev-pos 0)  
    ;;first, scan interface part for types  
    (if (eq nil (re-search-forward "interface" nil t))   
	(goto-char (point-min))  
      (progn    ;; if we have interface..implementaion  
	(save-match-data  
	  (while (re-search-forward  
		  (or regexp imenu--type-name-regexp-delphi)  
		  nil t)  
	    (imenu-progress-message progress-prev-pos)  
	    (let ((pos (save-excursion  
			 (beginning-of-line)  
			 (if imenu-use-markers (point-marker) (point))))  
		  (sub-alist '())  
		  (type-name (match-string-no-properties 1)))  
	      (progn  
		(push (cons "(declaration)" pos) sub-alist)  
		(push (cons (format "%s." type-name) sub-alist) index-alist))))  
	  )  
	))  
    ;;now, scan implementation part for methods (and other functions)  
    (goto-char (point-min))  
    (if (eq nil (re-search-forward "implementation" nil t)) ;;advance to the interface part  
	(goto-char (point-min))      
      (save-match-data  
	(while (re-search-forward  
		(or regexp imenu--function-name-regexp-delphi)  
		nil t)  
	  (imenu-progress-message progress-prev-pos)  
	  (let* ((pos (save-excursion  
			(beginning-of-line)  
			(if imenu-use-markers (point-marker) (point))))  
		 (class-name (match-string-no-properties 2))  
		 (function-name (match-string-no-properties 3))  
		 (sub-menu (assoc class-name index-alist)))  
	    (if (eq nil sub-menu)  
		(push (cons (format "%s%s()"  
				    (if (eq nil class-name) "" class-name)  
				    function-name)  
			    pos)  
		      index-alist)  
	      (setcdr sub-menu (cons (cons function-name pos) (cdr sub-submenu)))  
	      )  
	    )))  
      )  
    (imenu-progress-message progress-prev-pos 100)  
    (nreverse index-alist)))   

(defun delphi-imenu-fix()
  (require 'imenu)  
  (setq imenu-sort-function 'imenu--sort-by-name)  
  (setq imenu-create-index-function  
	#'imenu--create-delphi-index-enh)  
  (imenu-add-menubar-index))
;;  
(add-hook 'delphi-mode-hook 'delphi-imenu-fix)
(add-hook 'pascal-mode-hook 'delphi-imenu-fix)

;;}}}

;;{{{ jump to declaration/implementation
(defun delphi-jump-to-declaration ()
  (interactive)
  (let ( (pt (ignore-errors
               (save-excursion
        (end-of-line)
        (re-search-backward "^\\(procedure\\|function\\|constructor\\|destructor\\)[ \t]+\\([_a-zA-Z][_a-zA-Z0-9]*\\>\\)?\\.?\\([_a-zA-Z][_a-zA-Z0-9]*\\)")
        (let ( (method-type  (match-string-no-properties 1)) 
               (class-name   (if (match-string 3) (match-string-no-properties 2) "" ))
               (func-name    (or (match-string-no-properties 3) (match-string-no-properties 2))) )
          (beginning-of-buffer)
          (if (> (length class-name) 0)
              (re-search-forward (format "%s[ \t]+=" class-name)))
          (when (re-search-forward (format "%s[ \t]+%s\\>" method-type func-name))
              (backward-word)
              (point)))))) )
    (when pt (goto-char pt))))
      

(defun delphi-jump-to-implementaion()
  (interactive)
  (let ( (pt (ignore-errors
               (beginning-of-line)
               (when (re-search-forward "\\(procedure\\|function\\|constructor\\|destructor\\)[ \\t]+\\([_a-zA-Z][_a-zA-Z0-9]*\\)")
                 (let ( (method-type  (match-string-no-properties 1))  ;;procedure/function/constructor
                        (func-name    (match-string-no-properties 2))
                        type-name
                        type-type)
                   (when (re-search-backward "\\<\\([_a-zA-Z][_a-zA-Z0-9]*\\)[ \\t]*=[ \\t]*\\(class\\|interface\\)")
                     (setq type-name (match-string-no-properties 1))
                     (setq type-type (match-string-no-properties 2)))
                   (if (string= type-type "interface")
                       (error "interface has no implementation part: %s" type-name)
                     (progn
                       (re-search-forward "^implementation\\>" nil t)
                       ;;(message "%s|%s|%s" method-type type-name func-name)
                       (if type-name
                           (re-search-forward (format "%s[ \\t]+%s\\.[ \\t]?%s\\>" method-type type-name func-name))
                         (re-search-forward (format "%s[ \\t]+%s\\>" method-type func-name))))))))) )
    (when pt (progn
	       (goto-char pt)
	       (beginning-of-line)))))
			

(define-key delphi-mode-map (kbd "<C-S-up>") 'delphi-jump-to-declaration)
(define-key delphi-mode-map (kbd "<C-S-down>") 'delphi-jump-to-implementaion)
(define-key pascal-mode-map (kbd "<C-S-up>") 'delphi-jump-to-declaration)
(define-key pascal-mode-map (kbd "<C-S-down>") 'delphi-jump-to-implementaion)
;;}}}

;;{{{ highlight more
;;(font-lock-add-keywords 


;;}}}
;;{{{ highlight more - delphi-mode

(defcustom delphi-datatype-face 'font-lock-type-face
  "*Face used to color delphi data types."
  :type 'face
  :group 'delphi)

(defcustom delphi-function-face 'font-lock-function-name-face
  "*Face used to color delphi `built-in` functions."
  :type 'face
  :group 'delphi)

;; re-define delphi-face-of
(defun delphi-face-of (token-kind)
  ;; Returns the face property appropriate for the token kind.
  (cond ((delphi-is token-kind delphi-comments) delphi-comment-face)
        ((delphi-is token-kind delphi-strings) delphi-string-face)
        ((string= token-kind '_type) delphi-datatype-face)
        ((string= token-kind '_func) delphi-function-face)
        ((delphi-is token-kind delphi-keywords) delphi-keyword-face)
        (delphi-other-face)))

(defun delphi-word-token-at (p)
  ;; If point p is over a word (i.e. identifier characters), then return a word
  ;; token. If the word is actually a keyword, then return the keyword token.
  (let ((word (delphi-charset-token-at p delphi-word-chars 'word)))
    (when word
      (let* ((word-image (downcase (delphi-token-string word)))
             (keyword (intern-soft word-image)))
        (when (or keyword (string= "nil" word-image))
              (if (delphi-is keyword delphi-keywords)
                  (delphi-set-token-kind word keyword)
                (if (delphi-is keyword delphi-data-types)
                    (delphi-set-token-kind word '_type)
                  (if (delphi-is keyword delphi-system-funcs)
                      (delphi-set-token-kind word '_func)))))
        word))))
;;}}}

(defun pascal-misc-init ()
  ;; make // starts the comment line
  (modify-syntax-entry ?/ ”. 12b” pascal-mode-syntax-table)
  (modify-syntax-entry ?\n ”> b” pascal-mode-syntax-table))

(add-hook 'pascal-mode-hook 'pascal-misc-init)


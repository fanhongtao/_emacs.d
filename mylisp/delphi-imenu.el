;; Based on code from http://www.emacswiki.org/emacs/DelphiMode

;; bamanzi <bamanzi@gmail.com>

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

(add-hook 'delphi-mode-hook
		  #'(lambda ()
			  (require 'imenu)
			  (setq imenu-sort-function 'imenu--sort-by-name)
			  (setq imenu-create-index-function
					#'imenu--create-delphi-index-enh)
			  (imenu-add-menubar-index)))
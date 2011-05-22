;;; auto-complete-scite-api.el --- auto-completion source with scite API files

;;
;; Author: Ralph Young <bamanzi@gmail.com>
;; Keyword: complete, scite
;; Version: 0.2

;;; Commentary:
;; Features:
;; - A candidates source (scite-api) for auto-complete, baked with
;;   Scite's API files.
;;
;;   Candidates provided by this source would have a symbol 'A' at tail
;;   in the candidates menu.
;;
;; - Document string (if provided in API file) would show in
;;   auto-complete's popup area. After selection (RET), the document
;;   string would be displayed in the echo area.
;;
;;   As a side-effect, you can always press M-F1 to query the document
;;   string for a function/symbol.
;;
;; Requirements: 
;; * Auto-Complete package needed
;; 	http://cx4a.org/software/auto-complete/
;;   	(only tested on v1.2, v1.3)
;; * Scite API files
;;   	This library would search API files in folder /usr/share/scite/api/
;;	and ~/.scite/api. You can customize variable `ac-scite-api-directories'.
;;
;; 	If you need more API files, please visit
;;   	 http://code.google.com/p/scite-files/wiki/Customization
;;
;;   The following rules are used to search the API file.
;;   1. <major-mode-name>.api  ("-mode" removed.)
;;	e.g:  init.el -> emacs-lisp-mode -> emacs-lisp.api
;;   2. <file-name-extension>.api
;;	e.g:  init.el -> el.api
;;   If both matches found, both would be loaded.
;;
;; Usage:
;; - to enable ac-source-scite-api for all modes
;;    (require 'auto-complete-scite-api")
;;    (setq-default 'ac-sources
;;		(cons 'ac-source-scite-api ac-sources))
;;
;; - to enable ac-source-scite-api for specific modes
;;    (require 'auto-complete-scite-api")
;;    (add-hook 'xahk-mode 'ac-enable-scite-api-source)
;;   or interactively:
;;    M-x ac-enable-scite-api-source
;; 
;; Note: remember to turn on auto-complete-mode
;;
;; 
;; Limitations/TODO:
;;   - M-x ac-scite-api-reload-api-file
;;   - overloaded functions: AC would ignore duplicate items
;;   - improve performance for namespaced completion. e.g. for python.api
;;        * a package name (such as 'xml.') would lead to too much candidates
;;
;; Changes Log:
;;   * v0.2 (2011-03-29)
;;     Improved performance for big API files
;;     Fixed compatibility with auto-complete 1.4 (thanks sdjc<ºìÉÕÍÁ¶¹>)
;;   * v0.1 (2011-02-18)
;;     First version
;;

;;; Code:

(require 'auto-complete)

(defcustom ac-scite-api-directories '("/usr/share/scite/api" "~/.scite/api")
  "Directories of Scite API files."
  :type '(repeat string)
  :group 'auto-complete)

;; internal variables
(defvar ac-scite-api--key-min-length 3
  "Minimal length of an API. Used internally to create `ac-scite-api--caches'")

(defvar ac-scite-api--cache-default-key "_"
  "Default key for very short API (shorter than
  `ac-scite-api--key-min-length'). Used in ac-scite-api--cache") 

(defvar ac-scite-api--top-caches (make-hash-table :test 'equal)
  "caches for all scite apis.  major-mode-name -> apis-hash-table")

(defvar ac-scite-api--cache (make-hash-table :test 'equal)
  "cache to store apis (for current buffer).  prefix -> (full-line, full-line...)")

(defvar ac-scite-api--last-major-mode ""
  "last major mode auto-complete-scite-api invoked on.")

(defvar ac-scite-api--last-help ""
  "last API's document")


;; in auto-complete 1.4, ac-read-file-dictionary renamed to ac-file-dictionary
(if (fboundp 'ac-file-dictionary)
    (defalias 'ac-read-file-dictionary 'ac-file-dictionary))

;; internal functions
(defun ac-scite-api--read-api-files()
  "read lines from scite api files.

This would read <major-mode-name>.api ('-mode' removed) and/or <file-name-ext>.api.

ac-read-file-dictionary (from auto-complete.el) used to cache the file contents"
  (apply 'append
           (mapcar 'ac-read-file-dictionary
                 (mapcar (lambda (name)
                           (loop for dir in ac-scite-api-directories
                                 for file = (concat dir "/" name ".api")
                                 if (file-exists-p file)
                                 return file))
                         (list (replace-regexp-in-string "-mode" "" (symbol-name major-mode))
			       (ignore-errors (file-name-extension (buffer-file-name))))))))

(defun ac-scite-api--read-line (line result)
  (let ((func-name (replace-regexp-in-string "[ ,\(].*" "" line)))
    (let ( (prefix (if (>= (length func-name) ac-scite-api--key-min-length)
                          (substring line 0 ac-scite-api--key-min-length)
                        ac-scite-api--cache-default-key)) )   ;;short apis are kept in one place use the same key '_'
      (let ( (prefixed-candidates (gethash prefix result)) )
        ;; (message "prefix= %s; line: %s; length(%s) " prefix line (length prefixed-candidates))
        (if prefixed-candidates
            (add-to-list 'prefixed-candidates line)
          (setq prefixed-candidates (make-list 1 line)))
        (puthash prefix prefixed-candidates result)))))

(defun ac-scite-api--read-file()
  "Read api file for current mode/buffer"
  (let ( (result (make-hash-table :test 'equal)) )
    (progn
      (message "Be patient: reading scite-api files for %s" mode-name)
      (clrhash result)
      (mapc '(lambda(line)
	       (ac-scite-api--read-line line result))
	    (ac-scite-api--read-api-files))
      result)))

(defun ac-scite-api-init()
  "parse api lines into hashtable \{ac-scite-api--caches}

called on each completion"
;;  (message "ac-scite-api-init called")
  (let* ( (cache (gethash mode-name ac-scite-api--top-caches 'none)) )
    (progn
      ;; read file and update major hash table
      (if (or (not cache) (eq cache 'none))
	  (let ( (apis (ac-scite-api--read-file)) )
	    (puthash mode-name apis ac-scite-api--top-caches)
	    (setq cache apis)))

      ;; copy from major-hash-table to candidates
      (if (not (eq ac-scite-api--last-major-mode mode-name))
	  (progn
	    (clrhash ac-scite-api--cache)
	    (setq ac-scite-api--cache cache)
	    (setq ac-scite-api--last-major-mode mode-name)))
      cache )))


(defun ac-scite-api--candidates-internal (prefix)
  ;;(message "ac-scite-api-candidates called %s" prefix)
  (when (and ac-scite-api--cache
	     (not (eq ac-scite-api--cache 'none)) )	   
    (let ( (key (if (>= (length prefix) ac-scite-api--key-min-length)
                    (substring prefix 0 ac-scite-api--key-min-length)
		  ac-scite-api--cache-default-key)) )
      (gethash key ac-scite-api--cache))))

(defun ac-scite-api-candidates (prefix)
  (let ( (lines (ac-scite-api--candidates-internal prefix)) )
    (mapcar '(lambda(line)
               (replace-regexp-in-string "[ ,\(].*" "" line))
            lines)))


(defun ac-scite-api-document (symbol)
  (let* ( (word (if (symbolp symbol)
                   (symbol-name symbol)
                 symbol))
          (len (length word)) )
    (let ( help )
      (mapc '(lambda(line)
               (when (>= (length line) len)
                 (when (string= word (substring line 0 (length word)))
                   (setq help line))))
            (ac-scite-api--candidates-internal word))
      help)))


(ac-define-source scite-api
  '((init . ac-scite-api-init)
    (candidates . (ac-scite-api-candidates ac-prefix))
    (document . ac-scite-api-document)
    (cache . t)
    ;;(prefix . "\\([A-Za-z_#$][A-Za-z_0-9_]+\\)")
    (action . (lambda() (message (ac-scite-api-document (thing-at-point 'symbol)))))    
    (symbol . "A")
;;    (candidate-face . ac-scite-api-candidate-face)
;;    (selection-face . ac-scite-api-selection-face)  
    ))


(defun ac-scite-api-show-help ()
  (interactive)
  (let ( (help (or (ac-scite-api-document (thing-at-point 'symbol))
		   ac-scite-api--last-help)) )
    (if (< 0 (length help))
	(message help))))
  
(global-set-key (kbd "<M-f1>") 'ac-scite-api-show-help)


(defun ac-enable-scite-api-source ()
  "Add ac-source-scite-api into ac-sources."
  (interactive)
  (if (not (memq 'ac-source-scite-api ac-sources))
	   (add-to-list 'ac-sources 'ac-source-scite-api)))

;;(defun ac-scite-api-reload-api ()
;;  "Reload API files for current buffer/mode"
;;  (interactive)
;;  (clrhash ac-scite-api--top-caches) ;;FIXME: only delete cache for current mode
;;  (clrhash ac-scite-api--cache) 
;;  (setq ac-scite-api--last-major-mode ""))

;;; auto-complete-scite-api.el ends here

;;--
(defun my-add-sub-dir-to-load-path (dir)
  (let ((default-directory
          (concat (file-name-directory (or load-file-name "./")) dir)))
    (if (file-exists-p default-directory)
	(progn
	  (add-to-list 'load-path default-directory)
	  (normal-top-level-add-subdirs-to-load-path)))))

;;(my-add-sub-dir-to-load-path "common")

;;--

;; (let ( (generated-autoload-file "~/.emacs.d/autoloads.el") )
;;   (mapc '(lambda (dir)
;;     (update-autoloads-from-directories dir))
;;  '("e:/emacs/site-lisp/misc_"
;;    "e:/emacs/site-lisp/filetype_"
;;    "e:/emacs/site-lisp/prog_"
;;    "e:/emacs/site-lisp/win32_"
;;    ))
;;   (load-file generated-autoload-file)

;; (defun generate-autoload-for-each-subdir(top-dir pattern)
;;     (mapc '(lambda (dir)
;; 	     (let ( (generated-autoload-file "~/.emacs.d/autoloads.el") )
;; 	     (update-autoloads-from-directories dir))
;; 	  (mapcar '(lambda (file)
;; 		     (when (file-directory-p file) file))
;; 		  (directory-files "d:/emacs/site-lisp/common" t "\\.*_$"))
;; 	  '("e:/emacs/site-lisp/misc_"
;; 	    "e:/emacs/site-lisp/filetype_"
;; 	    "e:/emacs/site-lisp/prog_"
;; 	    "e:/emacs/site-lisp/win32_"
;; 	    ))
;;   (load-file generated-autoload-file)

(defun my-add-sub-dir-to-load-path (dir)
  (let ((default-directory
          (concat (file-name-directory (or load-file-name "./")) dir)))
    (if (file-exists-p default-directory)
	(progn
	  (add-to-list 'load-path default-directory)
	  (normal-top-level-add-subdirs-to-load-path)))))


;; common
(my-add-sub-dir-to-load-path "common")
;; emacs-xx
(my-add-sub-dir-to-load-path (concat "emacs-" (format "%d" emacs-major-version)))
;; emacs-xx.x
(my-add-sub-dir-to-load-path (concat "emacs-" emacs-version))

   
;; load each file in site-start.d     
;; (mapc (directory-files  
;;        (concat (file-name-directory (or load-file-name "./")) "site-start.d")            
;;        t "\\.el\\'"))      
;; (load file) 
;; )

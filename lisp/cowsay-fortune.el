;;; cowsay-fortune.el -- insert a fortune cookie with external fortune/cowsay program


;;; Bamanzi <bamanzi@gmail.com>

;;; Commentary:
;; You must have `fortune' program & data files installed.
;;
;; M-x fortune  	;; show a fortune cookie
;; M-x insert-fortune   ;; insert a fortune cookie into current buffer
;;
;;
;; You must have `cowsay' program installed to use the following commands:
;;
;; M-x cowsay-quote-region      ;; quote the region with a cowsay figure
;; M-x insert-cowsay-fortune    ;; insert a fortune cookie, quoted with a cowsay figure
;; M-x insert-random-cowsay-fortune
;; 				;; similar to `insert-cowsay-fortune', but use random cowsay figure
;;
;; Sample output of `insert-cowsay-fortune':
;; _________________________________________
;; / "What do you mean with disappear - it's \
;; | completely closed down or disappeared   |
;; \ from the panel or..."Husse Sept 16 2007 /
;;  -----------------------------------------
;;         \   ^__^
;;          \  (oo)\_______
;;             (__)\       )\/\
;;                 ||----w |
;;                 ||     ||
;;
;;

;;; Code:

(defcustom fortune-prg "/usr/games/fortune"
  "Program for `insert-fortune' and `insert-cowsay-fortune'")

(defcustom fortune-data-dir "/usr/share/games/fortunes"
  "Data dir storing fortunes cookies")

(defcustom cowsay-prg "/usr/games/cowsay"
  "Program for `cowsay-quote-region' and `insert-cowsay-fortune'")

(defcustom cowsay-data-dir "/usr/share/cowsay/cows"
  "Data dir storing cowsay figures")



(defun call-fortune (fortune-file)
  "call `fortune' program to retrieve a fortune cookie."
  (shell-command-to-string (format "%s %s"
				   fortune-prg
				   (shell-quote-argument fortune-file))))

(defun fortune (fortune-file)
  "Show a fortune cookie."
  (interactive "sFortune: ")
  (message (call-fortune fortune-file)))

(defun insert-fortune (fortune-file)
  "insert a fortune cookie to current buffer."
  (interactive "sFortune: ")
  (insert-string "\n--\n")
  (insert-string (call-fortune fortune-file)))


(defun call-cowsay (msg &optional cowfile)
  (shell-command-to-string (format "%s %s %s"
				   cowsay-prg
				   (if (< 0 (length cowfile))
				       (concat " -f " cowfile)
				     " " )
				   (shell-quote-argument msg))))



(defun cowsay-quote-region (begin end)
  "Quote a region with a cowsay figure."
  (interactive "r")
  (shell-command-on-region begin end cowsay-prg))



(defun insert-cowsay-fortune (&optional cowfile fortune-file)
  "insert a fortune cookie, quoted by a 'cow'."
  (interactive "sCowfile: \nsFortune: ")
  (insert-string "\n")
  (insert-string (call-cowsay (call-fortune fortune-file) cowfile)))


(defun random-cowfile ()
  (let ( (files (directory-files cowsay-data-dir nil ".*.cow")) )
	 (nth (random (length files)) files)))

(defun insert-random-cowsay-fortune (&optional fortune-file)
  "insert a fortune cookie, quoted by a 'cow'."
  (interactive "sFortune: ")
  (insert-cowsay-fortune (random-cowfile) fortune-file))


(defun ido-insert-cowsay-fortune (&optional cowfile fortune-file)
  "Insert a fortune cookie, quoted by a 'cowsay' figure.

This one would use `ido' to let user choose the cowfile and the fortune cookie file."
   (interactive)
   (let ( (cowfile (ido-completing-read "Cowfile: "
                                        (directory-files cowsay-data-dir nil ".*.cow")
                                        "foobar"
                                        "foobar"
                                        nil
                                        nil
                                        "default.cow"
                                        ))
          (fortune-file (ido-completing-read "Fortune: "
                                              (directory-files fortune-data-dir nil "^[^\\.]*$")
                                              "foobar"
                                              "foobar"
                                              nil
                                              nil
                                              " "
                                              )) )                                              
     (insert-string (cowsay-fortune cowfile fortune-file))))

(defun init-cygwin-cowsay-fortune (cygwin-path)
  "Init `fortune-prg', `fortune-data-dir', `cowsay-prg' and `cowsay-data-dir' with Cygwin."  
  (setq fortune-prg	(concat cygwin-path "/bin/fortune"))
  (setq fortune-data-dir  (concat cygwin-path "/usr/share/games/fortunes"))
  ;; clear LC_ALL / LANG to prevent perl complaining
  (setq cowsay-prg	(concat cygwin-path "/bin/env LC_ALL= LANG= /bin/perl /usr/local/bin/cowsay"))
  (setq cowsay-data-dir	(concat cygwin-path "/usr/share/cowsay")))

(if (eq system-type 'windows-nt)
    (init-cygwin-cowsay-fortune))
 
  

(provide 'cowsay-fortune)

;;; cowsay-fortune.el ends here


				   

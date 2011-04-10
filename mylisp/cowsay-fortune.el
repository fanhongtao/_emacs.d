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

(defvar fortune-prg "/usr/games/fortune")


(defvar cowsay-prg "/usr/games/cowsay")


(defvar cowsay-data-dir "/usr/share/cowsay/cows")


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




				   

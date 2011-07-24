;;; cowsay-cmd.el -- simple wrapper for `cowsay' program


;; Copyright (C) 2010-2011 BaManzi

;; Author: Bamanzi <bamanzi@gmail.com>
;; Version: 0.1.0
;; Keywords: fun, games
;; URL: http://bamanzi-misc.googlecode.com

;; This file is NOT part of Emacs.


;;; Commentary:

;; You must have `cowsay' program installed to use the following commands:
;; (cowsay: http://www.nog.net/~tony/warez/cowsay.shtml)
;;
;; M-x cowsay-quote-region                ;; quote the region with a cowsay figure
;;
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

(defcustom cowsay-prg "/usr/games/cowsay"
  "Program for `cowsay-quote-region' and `insert-cowsay-fortune'")

(defcustom cowsay-prg-extra-args "-W 78"
  "Extra arguments passed to `cowsay' program.")

(defcustom cowsay-data-dir "/usr/share/cowsay/cows"
  "Data dir storing cowsay figures")


(defun call-cowsay (msg &optional cowfile)
  (shell-command-to-string (format "%s %s %s %s"
				   cowsay-prg
                   cowsay-prg-extra-args
				   (if (< 0 (length cowfile))
				       (concat " -f " cowfile)
				     " " )
				   (shell-quote-argument msg))))

(defun random-cowfile ()
  (let ( (files (directory-files cowsay-data-dir nil ".*.cow")) )
	 (nth (random (length files)) files)))


;;;###autoload
(defun cowsay-quote-region (begin end)
  "Quote a region with a cowsay figure."
  (interactive "r")
  (let* ( (cows (directory-files cowsay-data-dir nil ".*.cow"))
          (cow (ido-completing-read "Cowfile: "
                                    (cons " " (cons "(random)" cows))))
          (cowfile-arg (if (eq cow " ")
                       ""
                     (if (eq cow "(random)")
                         (concat " -f " (random-cowfile))
                       (concat " -f " cow)))) )
         (shell-command-on-region begin end (concat cowsay-prg
                                                    " "
                                                    cowsay-prg-extra-args
                                                    cowfile-arg))))
        

;;---  

(defun init-cygwin-cowsay (cygwin-path)
  "Init `fortune-prg', `fortune-data-dir', `cowsay-prg' and `cowsay-data-dir' with Cygwin."  
  (setq fortune-prg	(concat cygwin-path "/bin/fortune"))
  (setq fortune-data-dir  (concat cygwin-path "/usr/share/games/fortunes"))
  ;; clear LC_ALL / LANG to prevent perl complaining
  (setq cowsay-prg	(concat cygwin-path "/bin/env LC_ALL= LANG= /bin/perl /usr/local/bin/cowsay"))
  (setq cowsay-data-dir	(concat cygwin-path "/usr/local/share/cows")))


(provide 'cowsay-cmd)

;;; cowsay-cmd.el ends here


				   

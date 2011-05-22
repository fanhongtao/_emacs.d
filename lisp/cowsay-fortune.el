;;; cowsay-fortune.el -- insert a fortune cookie with external fortune/cowsay program


;; Copyright (C) 2010-2011 BaManzi

;; Author: Bamanzi <bamanzi@gmail.com>
;; Version: 0.1.3
;; Keywords: fun, fortune, games
;; URL: http://bamanzi-misc.googlecode.com

;; This file is NOT part of Emacs.


;;; Commentary:
;; You must have `fortune' program & data files installed.
;; ( http://packages.debian.org/wheezy/fortune-mod )

;; (@* "fortune")
;; M-x fortune-echo  	;; show a fortune cookie
;; M-x insert-fortune   ;; insert a fortune cookie into current buffer
;;
;; M-x fortune-idle-start
;;                     	;; Start a timer so that a fortune cookie would be
;;                     	;; shown each time Emacs became idle
;; M-x fortune-idle-stop
;;                      ;; Stop the timer started by `idle-fortune-start'
;;
;; (@* "cowsay")
;; You must have `cowsay' program installed to use the following commands:
;; (cowsay: http://www.nog.net/~tony/warez/cowsay.shtml)
;;
;; M-x cowsay-quote-region
;;                     ;; quote the region with a cowsay figure
;;
;; (@* "cowsay + fortune")
;; M-x insert-cowsay-fortune
;;                     ;; insert a fortune cookie, quoted with a cowsay figure
;; M-x insert-random-cowsay-fortune
;;                     ;; similar to `insert-cowsay-fortune', but use random
;;                     ;; cowsay figure
;; M-x ido-insert-cowsay-fortune
;;                     ;; similar to `insert-cowsay-fortune', but you can choose
;;                     ;; which cowsay figure and which fortune database to use.
;;
;;
;; Note: For Windows user, refer `init-cygwin-cowsay-fortune'. You may need
;; add it into your ~/.emacs.
;;
;; Hint: If you don't want to install `fortune', and have a good internet connection,
;; you can use `run-with-idle-time' to run (browse-url "http://fortunemod.com/")


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

(defcustom cowsay-prg-extra-args "-W 78"
  "Extra arguments passed to `cowsay' program.")

(defcustom cowsay-data-dir "/usr/share/cowsay/cows"
  "Data dir storing cowsay figures")



(defun call-fortune (fortune-file)
  "call `fortune' program to retrieve a fortune cookie."
  (shell-command-to-string (format "%s %s"
				   fortune-prg
				   (shell-quote-argument fortune-file))))

;;;###autoload
(defun fortune-echo (fortune-file)
  "Show a fortune cookie."
  (interactive "sFortune: ")
  (message (call-fortune fortune-file)))

;;;###autoload
(defun insert-fortune (fortune-file)
  "insert a fortune cookie to current buffer."
  (interactive "sFortune: ")
  (insert-string "\n--\n")
  (insert-string (call-fortune fortune-file)))

;;;###autoload
(defun ido-insert-fortune ()
  "Insert a fortune cookie to current buffer. Fortune-file could be choosed in `ido' style."
  (let ( (fortune-file (ido-completing-read "Fortune: "
                                              (directory-files fortune-data-dir nil "^[^\\.]*$")
                                              "foobar"
                                              "foobar"
                                              nil
                                              nil
                                              " "
                                              )) )
    (insert-string "\n--\n")
    (insert-string (call-fortune fortune-file))))

;;-- cowsay
(defun call-cowsay (msg &optional cowfile)
  (shell-command-to-string (format "%s %s %s %s"
				   cowsay-prg
                   cowsay-prg-extra-args
				   (if (< 0 (length cowfile))
				       (concat " -f " cowfile)
				     " " )
				   (shell-quote-argument msg))))


;;;###autoload
(defun cowsay-quote-region (begin end)
  "Quote a region with a cowsay figure."
  (interactive "r")
  (shell-command-on-region begin end cowsay-prg))


;;-- fortune + cowsay
;;;###autoload
(defun insert-cowsay-fortune (cowfile fortune-file)
  "insert a fortune cookie, quoted by a 'cow'."
  (interactive "sCowfile: \nsFortune: ")
  (insert-string "\n")
  (insert-string (call-cowsay (call-fortune fortune-file) cowfile)))


(defun random-cowfile ()
  (let ( (files (directory-files cowsay-data-dir nil ".*.cow")) )
	 (nth (random (length files)) files)))

;;;###autoload
(defun insert-random-cowsay-fortune (&optional fortune-file)
  "insert a fortune cookie, quoted by a 'cow'."
  (interactive)
  (insert-cowsay-fortune (random-cowfile) ""))


;;;###autoload
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



(defcustom fortune-show-use-cowsay t
  "Whether to use `cowsay' in `fortune-idle-show'.

If you have no `cowsay', you can turn it off."
  :type 'boolean)

;;;###autoload
(defun fortune-show ()
  "Show a fortune cookie in the bottom-est window."
  (interactive)
  (let ( (win (selected-window)) )
    (if (fboundp 'windmove-find-other-window)  ;; use `windmove' to find the bottom window
        (while (windmove-find-other-window 'down nil win)
          (setq win (windmove-find-other-window 'down nil win))))
    (when win
      (with-selected-window win
        (when (get-buffer-create "*fortune*")
          (with-current-buffer "*fortune*"
            (kill-region (point-min) (point-max))
            (insert-string "--\n")
            (if fortune-show-use-cowsay
                (insert-cowsay-fortune "" "")
              (insert-fortune "")))
          (switch-to-buffer "*fortune*")
          (beginning-of-buffer))))
    ))
      

;;;###autoload
(defun fortune-idle-start ()
  "Start to show a random fortune cookie when Emacs is idle for 60 second."
  (interactive)
  (if (file-executable-p fortune-prg)
      (error "'%s' not exist or not executable. Please customize `fortune-prg'." fortune-prg)
    (setq idle-fortune-timer (run-with-idle-timer 60 t 'fortune-show))))

;;;###autoload
(defun fortune-idle-stop ()
  "Stop the timer started by `idle-fortune-start'."
  (interactive)
  (cancel-timer idle-fortune-timer))
        

;;---  

(defun init-cygwin-cowsay-fortune (cygwin-path)
  "Init `fortune-prg', `fortune-data-dir', `cowsay-prg' and `cowsay-data-dir' with Cygwin."  
  (setq fortune-prg	(concat cygwin-path "/bin/fortune"))
  (setq fortune-data-dir  (concat cygwin-path "/usr/share/games/fortunes"))
  ;; clear LC_ALL / LANG to prevent perl complaining
  (setq cowsay-prg	(concat cygwin-path "/bin/env LC_ALL= LANG= /bin/perl /usr/local/bin/cowsay"))
  (setq cowsay-data-dir	(concat cygwin-path "/usr/share/cowsay")))

;;in case you've already set the path for cygwin
(when (eq system-type 'windows-nt)
    (if (boundp 'w32shell-cygwin-bin)  ;;`w32shell-cygwin-bin' came from w32shell.el
        (init-cygwin-cowsay-fortune (replace-regexp-in-string "/bin/?" "" w32shell-cygwin-bin))
      (if (boundp 'cygwin-mount-cygwin-bin-directory)  ;;`cygwin-mount-cygwin-bin-directory' came from cygwin-mount.el
          (init-cygwin-cowsay-fortune (replace-regexp-in-string "/bin/?" "" cygwin-mount-cygwin-bin-directory)))))
    
;; (if (eq system-type 'windows-nt)
 
  

(provide 'cowsay-fortune)

;;; cowsay-fortune.el ends here


				   

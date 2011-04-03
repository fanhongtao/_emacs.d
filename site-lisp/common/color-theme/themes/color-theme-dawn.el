;; Dawn Colour Theme for Emacs.
;;
;; Defines a colour scheme resembling that of the TextMate Dawn colour theme.
;; To use add the following to your .emacs file (requires the color-theme package):
;;
;; (require 'color-theme)
;; (color-theme-initialize)
;; (load-file "~/.emacs.d/themes/color-theme-dawn.el")
;;
;; And then (color-theme-dawn) to activate it.
;;
;; MIT License Copyright (c) 2008 JD Huntington <jdhuntington at gmail dot com>
;; MIT License Copyright (c) 2009 Doug Alcorn <dougalcorn at gmail dot com>
;; Credits due to the excellent TextMate Dawn theme
;;
;; All patches welcome

(defun color-theme-blackboard ()
  "Color theme by JD Huntington, based off the TextMate Blackboard theme, created 2008-11-27"
  (interactive)
  (color-theme-install
   '(color-theme-blackboard
     ((background-color . "#F9F9F9")
      (background-mode . light)
      (border-color . "#F9F9F9")
      (cursor-color . "black")
      (foreground-color . "#080808")
      (mouse-color . "black"))
     (default ((t (:background "#F9F9F9" :foreground "#080808"))))
     (blue ((t (:foreground "blue"))))
     (bold ((t (:bold t))))
     (bold-italic ((t (:bold t))))
     (border-glyph ((t (nil))))
     (buffers-tab ((t (:background "#0C1021" :foreground "#F8F8F8"))))
     (font-lock-builtin-face ((t (:foreground "#6E4B39"))))
     (font-lock-comment-face ((t (:foreground "#58525F"))))
     (font-lock-constant-face ((t (:foreground "#6E2626"))))
     (font-lock-doc-string-face ((t (:foreground "2F5F26"))))
     (font-lock-function-name-face ((t (:foreground "#A75529"))))
     (font-lock-keyword-face ((t (:foreground "#6E4B39"))))
     (font-lock-preprocessor-face ((t (:foreground "Aquamarine"))))
     (font-lock-reference-face ((t (:foreground "SlateBlue"))))

     (font-lock-regexp-grouping-backslash ((t (:foreground "#B55C2D"))))
     (font-lock-regexp-grouping-construct ((t (:foreground "#6E2626"))))

     (font-lock-string-face ((t (:foreground "#2F5F26"))))
     (font-lock-type-face ((t (:foreground "#2F5F26"))))
     (font-lock-variable-name-face ((t (:foreground "#FF6400"))))
     (font-lock-warning-face ((t (:bold t :foreground "Pink"))))
     (gui-element ((t (:background "#D4D0C8" :foreground "black"))))
     (region ((t (:background "#253B76"))))
     (mode-line ((t (:background "grey75" :foreground "black"))))
     (highlight ((t (:background "#222222"))))
     (highline-face ((t (:background "SeaGreen"))))
     (italic ((t (nil))))
     (left-margin ((t (nil))))
     (text-cursor ((t (:background "yellow" :foreground "black"))))
     (toolbar ((t (nil))))
     (underline ((nil (:underline nil))))
     (zmacs-region ((t (:background "snow" :foreground "ble")))))))

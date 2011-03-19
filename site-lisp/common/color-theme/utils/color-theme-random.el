;;; color-theme-random.el ---  random pick a color theme

;; Copyright (C) 2008, Chaoji Li

;; Author: Chaoji Li <lichaoji AT gmail DOT com>
;; Version: 0.1
;; Date: Oct 02, 2008

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Put this file in a folder where Emacs can find it.
;;
;; Add following lines to your .emacs initialization file:
;;
;;     (require 'color-theme-random)
;;     (color-theme-random)
;;


(require 'color-theme)

(setq color-theme-history-max-length 10)

(defun color-theme-current-theme()
  (interactive)
  (message (format "Current theme is: %s" 
		   (symbol-name (car (car color-theme-history))))))

(defvar color-theme-random-init nil)

(defvar my-fav-color-themes
  '(
    (color-theme-andreas)
    (color-theme-aliceblue)
    (color-theme-arjen)
    (color-theme-bharadwaj-slate)
    (color-theme-charcoal-black)
    (color-theme-calm-forest 2)
    (give-other-themes-a-chance)
    ))

(defun give-other-themes-a-chance()
  (funcall (car (nth ( random (length color-themes)) color-themes))))

(defun color-theme-random()
  (interactive)
  (unless color-theme-random-init (random t))
  (setq color-theme-random-init t)
  (let (selected-theme (weight-so-far 0) weight)
    (dolist (theme my-fav-color-themes)
      (setq weight (nth 1 theme))
      (unless weight (setq weight 1)) ;; Default 1
      (if (>= (random (+ weight weight-so-far)) weight-so-far)
	  (setq selected-theme (car theme)))
      (setq weight-so-far (+ weight-so-far weight)))
    (if selected-theme
	(funcall selected-theme))
    (message (format "Random color theme: %s" (symbol-name selected-theme)))
    ))

(provide 'color-theme-random)
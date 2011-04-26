;; allout-tests.el --- Functional testing utilities for allout outlines code

;; Copyright (C) 2007 Ken Manheimer

;; Author: Ken Manheimer <ken dot manheimer at gmail dot com>
;; Maintainer: Ken Manheimer <ken dot manheimer at gmail dot com>
;; Created: May 2007
;; Version: $Id: allout-tests.el,v 1.1 2007/07/06 05:04:43 klm Exp $||
;; Keywords: outlines

;;; Commentary:

;; Utilities not belonging directly in any other allout module.

;;;_. general environment

;;;_. fields
;;;_ > allout-char-field-paint
(defconst allout-field-paint-colors
  '("cyan" "chocolate" "maroon" "green" "orchid" "blue" "orangered" "red" "chartreuse" "deeppink"))
(defconst allout-field-paint-nil-color "yellow")

(defvar allout-field-paint-ings
  (list nil (cons nil allout-field-paint-nil-color))
  "buffer-specific collection of field-highlighting overlays and mappings.

the car is the overlays, the cdr the current field mappings.")
(make-variable-buffer-local 'allout-field-paint-ings)
(defun allout-char-field-paint (&optional beginning ending)
  "color current target's characters distinguish fields, or uncolor if done.

if the character at point already has been painted, then remove
all char-field painting in the buffer.  otherwise:

paint the current region if set, else the current line (including newline).

characters with nil field type get painted with
`allout-field-paint-nil-color'.  otherwise, the first field type
encountered gets the first color in allout-field-paint-colors,
the second gets the second, and so on.

the color-to-field mapping is presented in the minibuffer."
  (interactive)
  (let ((was-modified (buffer-modified-p)))
    (if (get-char-property (point) 'allout-field-paint-overlay)
        ;; Zero all the field-paint overlays in the buffer:
        (when (car allout-field-paint-ings)
          (mapc 'delete-overlay (car allout-field-paint-ings))
          (setcar allout-field-paint-ings nil))

      (let* ((start-point (point))
             (deactivate-mark-afterwards (and mark-active
                                              ;; we'll use the mark:
                                              (not (and beginning ending))))
             (end (or ending
                      (condition-case err (region-end)
                        (mark-inactive
                         (save-excursion (forward-line 1) (point))))))
             (pos (or beginning
                      (and mark-active (region-beginning))
                      (save-excursion (move-to-column 0)
                                      (if (eolp) (forward-line -1))
                                      (point))))
             (all-overlays (car allout-field-paint-ings))
             (color-key (cdr allout-field-paint-ings))
             (colors allout-field-paint-colors)
             next-change-at
             cur-field cur-color
             got
             cur-overlay)

        ;; remove already-used colors from initially available ones:
        (dolist (c (mapcar 'cdr color-key))
          (setq colors (delq c colors)))

        (if (< end pos) (let ((trans end))
                          (setq end pos pos trans)))

        (while (< pos end)
          ;; XXX just for debugging:
          (goto-char pos)
          ;; next-property-change
          (setq cur-field (get-char-property pos 'field))
          (when (not (setq cur-color (cdr (assoc cur-field color-key))))
            (if (not colors)
                ;; used all the colors - restart at beginning of colors list:
                (setq colors (copy-list allout-field-paint-colors)))
            ;; use the next color on the list, and register the association:
            (setq cur-color (pop colors))
            (setq color-key (push (cons cur-field cur-color) color-key)))
          ;; determine the span of the current field setting:
          (setq next-change-at
                (next-single-property-change pos 'field
                                             (current-buffer) end))
          ;; decorate the span:
          (setq cur-overlay (make-overlay pos (min next-change-at end)
                                          nil 'front-advance 'rear-advance))
          (overlay-put cur-overlay 'face (list :background cur-color))
          (overlay-put cur-overlay 'allout-field-paint-overlay t)
          ;; increment:
          (setq pos next-change-at)
          (setq got color-key)
          (if all-overlays
              (push cur-overlay all-overlays)
            (setq all-overlays (list cur-overlay)))
          )
        (setq allout-field-paint-ings (cons all-overlays color-key))
        (if deactivate-mark-afterwards
            (deactivate-mark))
        (message "key: %s" (reverse got))
        got))
    (set-buffer-modified-p was-modified)))
(defun allout-tests-colors-string (color-key)
  "Return string of names painted in colors, according to name/color pairs."
 )
;;;_ > check-newlines-for-fielding
        (defun check-newlines-for-fielding ()
"end at the first newline that has a 'field character property."
(while (and (re-search-forward "\n" nil t)
            (not (get-char-property (1- (point)) 'field)))))

;;;_. provide
(provide 'allout-tests)

;;;_. Local emacs vars.
;;;_ , Local variables:
;;;_ , allout-widgets-mode-inhibit: t
;;;_ , allout-layout: (-1 : 0)
;;;_ , End:

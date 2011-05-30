 
;;--- options
(global-set-key (kbd "<C-f10> g") 'customize-group)
(global-set-key (kbd "<C-f10> v") 'customize-variable)
(global-set-key (kbd "<C-f10> f") 'customize-face)
(global-set-key (kbd "<C-f10> t") 'customize-themes)

;;--- some elisp commands
(global-set-key (kbd "<f3> f") 'find-function-at-point)
(global-set-key (kbd "<f3> F") 'find-function)
(global-set-key (kbd "<f3> v") 'find-variable-at-point)
(global-set-key (kbd "<f3> V") 'find-variable)
(global-set-key (kbd "<f3> l") 'find-library)
(global-set-key (kbd "<f3> C-f") 'ffap-other-window)

(global-set-key (kbd "<f12> l l") 'load-library)
(global-set-key (kbd "<f12> l t") 'load-theme)

(global-set-key (kbd "<f12> e b") 'eval-buffer)
(global-set-key (kbd "<f12> e r") 'eval-region)
(global-set-key (kbd "<f12> e f") 'eval-defun)
(global-set-key (kbd "<f12> e s") 'eval-sexp)

;;--- buffer-local bookmarks
(ignore-errors
  (or (require 'bm nil t)
      (require 'linkmark nil t))
  )
(if (featurep 'bm)
    (progn
      (global-set-key (kbd "<left-fringe> <C-mouse-1>") 'bm-toggle-mouse)
      (global-set-key (kbd "<left-fringe> <C-mouse-5>") 'bm-next-mouse)
      (global-set-key (kbd "<left-fringe> <C-mouse-4>") 'bm-previous-mouse)

      (global-set-key (kbd "<f2> t") 'bm-toggle)
      (global-set-key (kbd "<f2> n") 'bm-next)
      (global-set-key (kbd "<f2> p") 'bm-previous)
      (global-set-key (kbd "<f2> l") 'bm-show)

      (if (fboundp 'anything-bm-list)
          (global-set-key (kbd "<f2> l") 'anything-bm-list))
      )
  (if (featurep 'linemark)              ;; linemark.el from CEDET
      (progn
        (global-set-key (kbd "<left-fringe> <C-mouse-1>") 'viss-bookmark-toggle)
        (global-set-key (kbd "<left-fringe> <C-mouse-5>") 'viss-bookmark-next-buffer)
        (global-set-key (kbd "<left-fringe> <C-mouse-4>") 'viss-bookmark-prev-buffer)
        
        (define-key global-map (kbd "<f2> t") 'viss-bookmark-toggle)
        (define-key global-map (kbd "<f2> n") 'viss-bookmark-prev-buffer)
        (define-key global-map (kbd "<f2> p") 'viss-bookmark-next-buffer)
        (define-key global-map (kbd "<f2> c") 'viss-bookmark-clear-all-buffer))
      ))

;;---
;;TODO: folding

(autoload 'fold-dwim-toggle "fold-dwim" "Toggle folding at point." t)
(autoload 'fold-dwim-show-all "fold-dwim")
(autoload 'fold-dwm-hide-all   "fold-dwim")

(global-set-key (kbd "C-c +") 'fold-dwim-toggle)
(global-set-key (kbd "C-c C-+") 'fold-dwim-show-all)
(global-set-key (kbd "C-c C--") 'fold-dwim-hide-all)

(when (locate-library "fold-dwim")
      ;; FIXME: fold-dwim-toggle would fold/unfold on cursor, not the mouse point
      (global-set-key (kbd "<left-fringe><mouse-1>") 'fold-dwim-toggle)
      )

;;--- selective display (quick & dirty code folding)
;; http://www.emacswiki.org/emacs/HideShow#toc5
;; hide lines whose indentation is bigger than x column
(defun toggle-selective-display (column)
  (interactive "P")
  (set-selective-display
   (or column
       (unless selective-display
         (1+ (current-column))))))

(defun toggle-hiding (column)
  (interactive "P")
  (if hs-minor-mode
      (if (condition-case nil
              (hs-toggle-hiding)
            (error t))
          (hs-show-all))
    (toggle-selective-display column)))

(global-set-key (kbd "C-c \\") 'toggle-selective-display)
;;(global-set-key (kbd "C-+") 'toggle-hiding)

;;--- hidesearch
(autoload 'hidesearch "hidesearch" "Incrementally show only lines in file based on what user types." t)
(autoload 'show-all-invisible "hide-lines" "Show all areas hidden by the filter-buffer command". t)
(autoload 'hide-non-matching-lines "hide-lines" "Hide lines that don't match the specified regexp." t)

(global-set-key (kbd "C-c C-s") 'hidesearch)
(global-set-key (kbd "C-c C-a") 'show-all-invisible)


;;---
(require 'windmove)
(defun goto-scratch-buffer-on-botton-window ()
  (interactive)
  (let ( (win (selected-window)) )
    (while (windmove-find-other-window 'down nil win)
      (setq win (windmove-find-other-window 'down nil win)))
    (when win
      (select-window win)
      (switch-to-buffer "*scratch*"))))

(global-set-key (kbd "<f11> s") 'goto-scratch-buffer-on-botton-window)


;; http://dev.ariel-networks.com/articles/emacs/part4/
;; anything-show-kill-ring ¤òÊ¹¤¦¤è¤¦¤ËÐÞÕý¤·¤¿
(defadvice yank-pop (around anything-kill-ring-maybe activate)
  (if (not (eq last-command 'yank))
      (anything-show-kill-ring)
    ad-do-it))

(defadvice cua-paste-pop (around anything-kill-ring-maybe activate)
  (if (not (eq last-command 'yank))
      (anything-show-kill-ring)
    ad-do-it))

;;--- list & choose method
(require 'idomenu "idomenu" t)  
(require 'eassist "eassist" t)  ;; for `eassist-list-methods'

(defun hkb-select-method()
  (interactive)
  (cond
   ( (and (fboundp 'anything-browse-code)
	  (memq major-mode '(emacs-lisp-mode lisp-interaction-mode python-mode)))
     (anything-browse-code))
   ( (fboundp 'anything-imenu)
     (anything-imenu) )
   ( (fboundp 'idomenu)
     (idomenu) )
   ( (and (fboundp 'eassist-list-methods)
	  (memq major-mode '(emacs-lisp-mode c-mode java-mode python-mode))
	  (memq 'semantic-mode minor-mode-alist))
     (eassist-list-methods) )
   (t (imenu))))

(global-set-key (kbd "C-c C-o") 'hkb-select-method)
(global-set-key (kbd "<f5> I") 'hkb-select-method)

;;--- extend selection incrementally (ergoemacs-functions.el)
;; http://xahlee.org/emacs/syntax_tree_walk.html
(autoload 'extend-selection "ergoemacs-functions" nil t)
(global-set-key (kbd "C-.") 'extend-selection)
;; see also: mark-sexp (C-M-SPC), mark-word (M-@)

;;-- block movement
;;stolen from http://xahlee.org/emacs/xah_emacs_cursor_movement.el
;;(modified: now it move to next occurrence of 3rd newline char)
(defun forward-block ()
  "Move cursor forward to next occurrence of double newline char.
In most major modes, this is the same as `forward-paragraph', however,
this function behaves the same in any mode.
forward-paragraph is mode dependent, because it depends on
syntax table that has different meaning for ¡°paragraph¡±."
  (interactive)
  (skip-chars-forward "\n")
  (when (not (search-forward-regexp "\n[[:blank:]]*\n[[:blank:]]*\n" nil t))
    (goto-char (point-max)) ) )

(defun backward-block ()
  "Move cursor backward to previous occurrence of double newline char.
See: `forward-block'"
  (interactive)
  (skip-chars-backward "\n")
  (when (not (search-backward-regexp "\n[[:blank:]]*\n[[:blank:]]*\n" nil t))
    (goto-char (point-min))
    )
  )

(global-set-key (kbd "C-c n") 'forward-block)
(global-set-key (kbd "C-c p") 'backward-block)

;;--- completion
;; Emacs default:
;;   M-TAB - lisp-complete-symbol(<24)/completion-at-point(v24)
;;   M-/ - dabbrev-expand

;;(if (< emacs-major-version 24)
;;    (global-set-key (kbd "H-/") 'lisp-complete-symbol)))
;;(global-set-key (kbd "H-/") 'completion-at-point)
;;(global-set-key (kbd "H-/") 'hippie-expand)

;;---
;; opening server files always in a new frame
;;http://www.emacswiki.org/emacs/EmacsClient#toc21

(add-hook 'server-switch-hook
          (lambda nil
            (let ((server-buf (current-buffer)))
              (bury-buffer)
              (switch-to-buffer-other-frame server-buf))))

;;--- count region
;; http://xahlee.org/emacs/elisp_count-region.html
;; see also: M-= (M-x count-lines-region)
(defun count-region (begin end)
  "Print number of words and chars in region."
  (interactive "r")
  (message "Counting ...")
  (save-excursion
    (let (wCnt charCnt)
      (setq wCnt 0)
      (setq charCnt (- end begin))
      (goto-char begin)
      (while (and (< (point) end)
                  (re-search-forward "\\w+\\W*" end t))
        (setq wCnt (1+ wCnt)))

      (message "Words: %d. Chars: %d." wCnt charCnt)
      )))

;;---
;;; select rectangle using H-mouse-1 (could it work?)
(require 'cua-rect)	
(defun hkb-mouse-mark-cua-rectangle (event)
  (interactive "e")
  (if (not cua--rectangle)	  
      (cua-mouse-set-rectangle-mark event)
    (cua-mouse-resize-rectangle event)))
(global-set-key (kbd "<A-mouse-1>") 'hkb-mouse-mark-cua-rectangle)
(define-key cua--rectangle-keymap (kbd "<A-mouse-1>") 'hkb-mouse-mark-cua-rectangle)

;;TODO: tempbuf
;;(autoload 'turn-on-tempbuf-mode "tempbuf")
(when (load "tempbuf" t)
  (add-hook 'dired-mode-hook 'turn-on-tempbuf-mode)
  (add-hook 'custom-mode-hook 'turn-on-tempbuf-mode)
  (add-hook 'w3-mode-hook 'turn-on-tempbuf-mode)
  (add-hook 'Man-mode-hook 'turn-on-tempbuf-mode)
  (add-hook 'view-mode-hook 'turn-on-tempbuf-mode))

;;---
;; use `pos-tip' to fix the popup window position issue
(when (require 'popup-pos-tip)
  (defadvice popup-tip
    (around popup-pos-tip-wrapper (string &rest args) activate)
    (if (eq window-system 'x)
        (apply 'popup-pos-tip string args)
      ad-do-it)))


;;; hyper-key-bindings.el -- Some key bindings that use 'hyper as modifier


;; initial magics

(if (memq (framep (selected-frame)) '(w32 win32))
    (progn
      ;;(setq w32-pass-apps-to-system nil)
      (setq w32-apps-modifier 'hyper)

      (setq w32-phantom-key-code 65)  ;;It seems no use
      (setq w32-pass-lwindow-to-system nil) ;; Prevent single press of <lwindow> to open Windows Start Menu
                                      ;; but could not prevent Win+R, Win+L etc 

      ;(setq w32-lwindow-modifier 'super)
      ;(setq w32-pass-rwindow-to-system nil) ;; It semmes no use
      ;(setq w32-rwindow-modifier 'super)

      ;;(setq w32-capslock-is-shiftlock t)   ;;useful?
      ;;(setq w32-scroll-lock-modifier 'alt) ;;useful?
      ))  ;;FIXME: what about Linux?

;;{{{ features
;;you can comment out the features/libraries you don't want to enable

;;(global-semantic-mode t)

;;3rd-party libraries

(if (load "undo-tree" t)
    (global-undo-tree-mode t)
  (load "redo"))

(load "bm" t)			;; visual bookmarks (within buffer)
;;(require 'auto-complete)

(load "highlight-symbol" t)
(load "anything" t)
(load "anything-config" t)	;; for anything-recentf & anything-imenu
(load "idomenu" t)		;; imenu navigation within minibuffer
(load "eassist" t)		;; CEDET's eassist (for eassist-switch-h-cpp, eassist-list-methods )

;;}}}


;;{{{ CUA-like editing
(global-set-key (kbd "H-c") 'kill-ring-save) ;; copy
(global-set-key (kbd "H-x") 'kill-region) ;; cut
(global-set-key (kbd "H-v") 'yank)	;; paste

(global-set-key (kbd "H-a") 'mark-whole-buffer)  ;; select all

(if (featurep 'undo-tree)
    (progn
      (global-set-key (kbd "H-z") 'undo-tree-undo)
      (global-set-key (kbd "H-Z") 'undo-tree-redo)
      (global-set-key (kbd "H-y") 'undo-tree-redo))
  (progn
    (global-set-key (kbd "H-z") 'undo)
    (if (featurep 'redo)
	(progn
	  (global-set-key (kbd "H-Z") 'redo)
	  (global-set-key (kbd "H-y") 'redo)))))


(global-set-key (kbd "H-w") 'toggle-truncate-lines) ;; or visual-line-mode?

;; files
;;(global-set-key (kbd "H-n") 'create-empty-buffer) ;;FIXME
;;(global-set-key (kbd "H-o") 'menu-find-file-existing)
(global-set-key (kbd "H-s") 'save-buffer)
(global-set-key (kbd "H-S") 'write-file)

;; search
(global-set-key (kbd "H-f") 'isearch-forward)
(global-set-key (kbd "H-h") 'query-replace)
(global-set-key (kbd "<H-f3>") 'nonincremental-repeat-search-forward)
(global-set-key (kbd "<C-S-f3>") 'nonincremental-repeat-search-backward)
;;}}}


;;{{{ programming

(global-set-key (kbd "H-;") 'comment-or-uncomment-region)

(defun hkb-list-methods()
  (interactive)
  (cond
   ( (fboundp 'anything-imenu) (anything-imenu) )
   ( (fboundp 'idomenu) (idomenu) )
   ( (and (fboundp 'eassist-list-methods)
	   (memq major-mode '(emacs-lisp-mode c-mode java-mode python-mode))
	   (memq 'semantic-mode minor-mode-alist))
     (eassist-list-methods) )
   (t (imenu))))
(global-set-key (kbd "H-o") 'hkb-list-methods)

(defun hkb-goto-symbol()
  (interactive)
  (let ( (keyword (thing-at-point 'symbol)) )
    (cond
     ( (eq major-mode 'emacs-lisp-mode)
       (find-function-at-point))
     ( (and (fboundp 'semantic-complete-jump)
	     (memq major-mode '(c-mode java-mode python-mode)))
       (semantic-complete-jump))
     (t
      (find-tag)))))
(global-set-key (kbd "H-]") 'hkb-goto-symbol)

(if (featurep 'eassist)
    (global-set-key (kbd "H-`") 'eassist-switch-h-cpp))
;;}}}

;;{{{ operation on current word/symbol
(defun hkb-goto-symbol-occurrence (forward)
  (let ( (symbol (thing-at-point 'symbol)) )
    (if (not (member symbol highlight-symbol-list))
	(highlight-symbol-at-point))  ;;FIXME
    (if forward
	(highlight-symbol-next)
      (highlight-symbol-prev))))

(defun hkb-goto-symbol-next-occur ()
  (interactive)
  (hkb-goto-symbol-occurrence t))

(defun hkb-goto-symbol-prev-occur ()
  (interactive)
  (hkb-goto-symbol-occurrence nil))
      

(if (featurep 'highlight-symbol)
    (progn
      (global-set-key (kbd "H-j") 'highlight-symbol-at-point)
      (global-set-key (kbd "H-*") 'hkb-goto-symbol-next-occur)
      (global-set-key (kbd "H-#") 'hkb-goto-symbol-prev-occur)))
      
;; occur

(global-set-key (kbd "H-l") '(lambda()
			       (interactive)
			       (occur (format "%s" (thing-at-point 'symbol)))))

;; grep

;; completion  (Emacs default: M-TAB - lisp-complete-symbol, M-/ - dabbrev-expand)
;;(global-set-key (kbd "H-/") 'hippie-expand)

;;auto-complete?

;;stardict


;;}}}


;;{{{ misc
;; bookmarks (within buffer)
(if (featurep 'bm)
    (progn
      (global-set-key (kbd "<H-f2>") 'bm-next)
      (global-set-key (kbd "<H-C-f2>") 'bm-toggle)
      (global-set-key (kbd "<H-S-f2>") 'bm-previous)))



;;; select rectangle using H-mouse-1
(require 'cua-rect)
(defun hkb-mouse-mark-cua-rectangle (event)
  (interactive "e")
  (if (not cua--rectangle)
      (cua-mouse-set-rectangle-mark event)
    (cua-mouse-resize-rectangle event)))
(global-set-key (kbd "<H-mouse-1>") 'hkb-mouse-mark-cua-rectangle)
(define-key cua--rectangle-keymap (kbd "<H-mouse-1>") 'hkb-mouse-mark-cua-rectangle)

;;}}}


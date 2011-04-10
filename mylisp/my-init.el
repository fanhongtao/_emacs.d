(tool-bar-mode -1)
(setq frame-title-format '("%b (%m) - Emacs "
			   (:eval emacs-version)))

(if (<= emacs-major-version 23) ;; emacs < 23.2
    (setq tab-always-indent nil)
  (setq tab-always-indent 'complete)) ;; emacs >= 23.2

(if (eq window-system 'x)
    (setq x-select-enable-clipboard t))

;;  (setq x-select-enable-primary t)

(global-set-key (kbd "C-m") 'newline-and-indent)
(global-set-key (kbd "C-j") 'newline)

(global-set-key (kbd "M-/") 'hippie-expand)

(setq cua-enable-cua-keys nil)
(cua-mode)


(global-set-key (kbd "C-c ;") 'comment-or-uncomment-region)

;; make M-z behave more as zap-up-to-char 
(defadvice zap-to-char (after my-zap-to-char-advice (arg char) activate)
    "Kill up to the ARG'th occurence of CHAR, and leave CHAR.
  The CHAR is replaced and the point is put before CHAR."
    (insert char)
    (forward-char -1))

;; Move line up/down. Stolen from org-mode's M-up/down
;; TODO: support region (move region line up/down)
(defun swap-line-up ()
  "Swap the current line with the line above."
  (interactive)
  (transpose-lines 1)
  (beginning-of-line -1))

(defun swap-line-down ()
  "Swap current line with the line below."
  (interactive)
  (beginning-of-line 2) (transpose-lines 1) (beginning-of-line 0))

(global-set-key (kbd "<M-up>") 'swap-line-up)
(global-set-key (kbd "<M-down>") 'swap-line-down)


(require 'recentf)
(recentf-mode)

;;{{{ third party libraries

(ignore-errors
  (require 'undo-tree)
  (global-undo-tree-mode))


(if (load "anything" t)
    (load "anything-config" t))


(if (and (load "auto-complete" t)
	  (load "auto-complete-config" t))
    (progn
      (ac-config-default)
      (add-hook 'lisp-interaction-mode 'ac-emacs-lisp-mode-setup)
      (load "auto-complete-scite-api")))
	  

(if (load "bm" t)
    (progn
      (global-set-key (kbd "<left-fringe> <C-mouse-1>") 'bm-toggle-mouse)
      (global-set-key (kbd "<left-fringe> <C-mouse-5>") 'bm-next-mouse)
      (global-set-key (kbd "<left-fringe> <C-mouse-4>") 'bm-previous-mouse)))

(if (load "fold-dwim" t)
    (progn
      ;; FIXME: fold-dwim-toggle would fold/unfold on cursor, not the mouse point
      (global-set-key (kbd "<left-fringe><mouse-1>") 'fold-dwim-toggle))) 
    

(load "highlight-symbol" t)
(load "highlight-indentation" t)

(load "idomenu" t)
(load "imenu-tree" t)
(load "hyper-key-bindings" t)

(if (or (featurep 'tabbar)
	 (load "tabbar" t))
    (progn
      (global-set-key (kbd "<C-tab>") 'tabbar-forward)
      (global-set-key (kbd "<C-S-tab>") 'tabbar-backward)))

(if (and (load "hide-lines" t)
	 (load "hidesearch" t))
    (progn
      (global-set-key (kbd "C-c C-s") 'hidesearch)
      (global-set-key (kbd "C-c C-a") 'show-all-invisible)))

	 
  

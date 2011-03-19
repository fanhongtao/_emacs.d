(require 'undo-tree)
;;(require 'redo)
(require 'bm)
;;(require 'auto-complete)

(if (memq (framep (selected-frame)) '(w32 win32))
    (progn
      ;;(setq w32-pass-apps-to-system nil)
      (setq w32-apps-modifier 'super)

      (setq w32-pass-lwindow-to-system nil)
      (setq w32-lwindow-modifier 'super)))

;; on nowaday linux, Windows key is Super

;; editing
(global-set-key (kbd "s-c") 'kill-ring-save) ;; copy
(global-set-key (kbd "s-x") 'kill-region) ;; cut
(global-set-key (kbd "s-v") 'yank)	;; paste

(global-set-key (kbd "s-a") 'mark-whole-buffer)  ;; select all

(if (featurep 'undo-tree)
    (progn
      (global-set-key (kbd "s-z") 'undo-tree-undo)
      (global-set-key (kbd "s-S-z") 'undo-tree-redo)
      (global-set-key (kbd "s-y") 'undo-tree-redo))
  (progn
    (global-set-key (kbd "s-z") 'undo)
    (if (featurep 'redo)
	(progn
	  (global-set-key (kbd "s-S-z") 'redo)
	  (global-set-key (kbd "s-y") 'redo)))))


(global-set-key (kbd "s-w") 'toggle-truncate-lines) ;; or visual-line-mode?


;; files
;;(global-set-key (kbd "s-n") 'create-empty-buffer) ;;FIXME
(global-set-key (kbd "s-o") 'menu-find-file-existing)
(global-set-key (kbd "s-s") 'save-buffer)
(global-set-key (kbd "s-S-s") 'write-file)

;; search
(global-set-key (kbd "s-f") 'isearch-forward)
(global-set-key (kbd "s-h") 'query-replace)
(global-set-key (kbd "<s-f3>") 'nonincremental-repeat-search-forward)
(global-set-key (kbd "<C-s-f3>") 'nonincremental-repeat-search-backward)

;; bookmarks (within buffer)
(if (featurep 'bm)
    (progn
      (global-set-key (kbd "<s-f2>") 'bm-next)
      (global-set-key (kbd "<C-s-f2>") 'bm-toggle)
      (global-set-key (kbd "<S-s-f2>") 'bm-previous)))

;;; misc
(global-set-key (kbd "s-l") '(lambda()
			       (interactive)
			       (occur (format "%s" (thing-at-point 'symbol)))))

(global-set-key (kbd "s-;") 'comment-or-uncomment-region)

;; completion  (Emacs default: M-TAB - lisp-complete-symbol, M-/ - dabbrev-expand)
(global-set-key (kbd "s-/") 'hippie-expand)


;; programming
(load "eassist" t)
(load "idomenu" t)
(defun hkb-list-methods()
  (interactive)
  (if (and (boundp 'eassist-list-methods)
	   (memq major-mode '(emacs-lisp-mode c-mode java-mode python-mode))
	   (memq 'semantic-mode minor-mode-alist))
      (eassist-list-methods)
    (idomenu)))
(global-set-key (kbd "s-[") 'hkb-list-methods)

(defun hkb-goto-symbol()
  (interactive)
  (let ((keyword (symbol-value (thing-at-point 'symbol))))
    (cond
     ((eq major-mode emacs-lisp-mode)
      (find-function-at-point))
     ((memq major-mode '(c-mode java-mode python-mode))
      (semantic-complete-jump))
     (t
      (find-tag)))))
(global-set-key (kbd "s-]") 'hkb-goto-symbol)

(if (featurep 'tabbar)
    (progn
      (global-set-key (kbd "<s-tab>") 'tabbar-forward-tab)
      (global-set-key (kbd "<M-s-tab>") 'tabbar-backward-tab)))

;;; misc
;;; select rectangle using H-mouse-1
(require 'cua-rect)
(defun hkb-mouse-mark-cua-rectangle (event)
  (interactive "e")
  (if (not cua--rectangle)
      (cua-mouse-set-rectangle-mark event)
    (cua-mouse-resize-rectangle event)))
(global-set-key (kbd "<s-mouse-1>") 'hkb-mouse-mark-cua-rectangle)
(define-key cua--rectangle-keymap (kbd "<s-mouse-1>") 'hkb-mouse-mark-cua-rectangle)
    



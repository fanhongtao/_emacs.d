(ignore-errors
  (require 'bm)
  (require 'fold-dwim)
  
  (require 'hide-line)
  (require 'hidesearch)
  
  (require 'highlight-symbol)
  (require 'highlight-indentation)
  )



;;---
(when (featurep 'bm)
      (global-set-key (kbd "<left-fringe> <C-mouse-1>") 'bm-toggle-mouse)
      (global-set-key (kbd "<left-fringe> <C-mouse-5>") 'bm-next-mouse)
      (global-set-key (kbd "<left-fringe> <C-mouse-4>") 'bm-previous-mouse)

      (global-set-key (kbd "<f2> t") 'bm-toggle)
      (global-set-key (kbd "<f2> n") 'bm-next)
      (global-set-key (kbd "<f2> p") 'bm-previous)

      (if (fboundp 'anything-bm-list)
	  (global-set-key (kbd "<f2> l") 'anything-bm-list))
      )

;;---
;;TODO: folding
(global-set-key (kbd "H-=") 'fold-dwim-toggle)
(global-set-key (kbd "H-+") 'fold-dwim-show-all)
(global-set-key (kbd "H-_") 'fold-dwim-hide-all)

(when (featurep 'fold-dwim)
      ;; FIXME: fold-dwim-toggle would fold/unfold on cursor, not the mouse point
      (global-set-key (kbd "<left-fringe><mouse-1>") 'fold-dwim-toggle)
      )

;;---
(when (and (featurep 'hide-lines)
	 (load "hidesearch" t))
      (global-set-key (kbd "C-c C-s") 'hidesearch)
      (global-set-key (kbd "C-c C-a") 'show-all-invisible)

      (global-set-key (kbd "<f12> C-s") 'hidesearch)
      (global-set-key (kbd "<f12> C-a") 'show-all-invisible)
      )

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

(global-set-key (kbd "<f12> s") 'goto-scratch-buffer-on-botton-window)

;;---

;; http://dev.ariel-networks.com/articles/emacs/part4/
;; anything-show-kill-ring を聞うように俐屎した
(defadvice yank-pop (around anything-kill-ring-maybe activate)
  (if (not (eq last-command 'yank))
      (anything-show-kill-ring)
    ad-do-it))

(defadvice cua-paste-pop (around anything-kill-ring-maybe activate)
  (if (not (eq last-command 'yank))
      (anything-show-kill-ring)
    ad-do-it))

;;--- some programming related
(load "eassist" t)  ;; for eassist-list-methods, eassist-switch-h-cpp
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

(global-set-key (kbd "H-]") 'hkb-select-method)
(global-set-key (kbd "<f3> C-]") 'hkb-select-method)


;; completion  (Emacs default: M-TAB - lisp-complete-symbol, M-/ - dabbrev-expand)

;;(if (< emacs-major-version 24)
;;    (global-set-key (kbd "H-/") 'lisp-complete-symbol)))
(global-set-key (kbd "H-/") 'completion-at-point)
;;(global-set-key (kbd "H-/") 'hippie-expand)
(global-set-key (kbd "<f12> ;") 'comment-or-uncomment-region)

;;

;;---

;;; select rectangle using H-mouse-1
(require 'cua-rect)	
(defun hkb-mouse-mark-cua-rectangle (event)
  (interactive "e")
  (if (not cua--rectangle)	  
      (cua-mouse-set-rectangle-mark event)
    (cua-mouse-resize-rectangle event)))
(global-set-key (kbd "<s-mouse-1>") 'hkb-mouse-mark-cua-rectangle)
(define-key cua--rectangle-keymap (kbd "<s-mouse-1>") 'hkb-mouse-mark-cua-rectangle)

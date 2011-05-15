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

(global-set-key (kbd "C-+") 'toggle-hiding)
(global-set-key (kbd "C-\\") 'toggle-selective-display)

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

(global-set-key (kbd "<f11> s") 'goto-scratch-buffer-on-botton-window)

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

(global-set-key (kbd "H-]") 'hkb-select-method)
(global-set-key (kbd "<f5> C-]") 'hkb-select-method)

;;--- auto-complete


;;--- completion
;; Emacs default:
;;   M-TAB - lisp-complete-symbol(<24)/completion-at-point(v24)
;;   M-/ - dabbrev-expand

;;(if (< emacs-major-version 24)
;;    (global-set-key (kbd "H-/") 'lisp-complete-symbol)))
(global-set-key (kbd "H-/") 'completion-at-point)
;;(global-set-key (kbd "H-/") 'hippie-expand)
(global-set-key (kbd "<f12> ;") 'comment-or-uncomment-region)

;;---
;; opening server files always in a new frame
;;http://www.emacswiki.org/emacs/EmacsClient#toc21

(add-hook 'server-switch-hook
          (lambda nil
            (let ((server-buf (current-buffer)))
              (bury-buffer)
              (switch-to-buffer-other-frame server-buf))))

;;---
;;; select rectangle using H-mouse-1 (could it work?)
(require 'cua-rect)	
(defun hkb-mouse-mark-cua-rectangle (event)
  (interactive "e")
  (if (not cua--rectangle)	  
      (cua-mouse-set-rectangle-mark event)
    (cua-mouse-resize-rectangle event)))
(global-set-key (kbd "<s-mouse-1>") 'hkb-mouse-mark-cua-rectangle)
(define-key cua--rectangle-keymap (kbd "<s-mouse-1>") 'hkb-mouse-mark-cua-rectangle)

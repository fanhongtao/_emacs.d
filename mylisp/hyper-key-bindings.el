;;; hyper-key-bindings.el -- Some functions bind to 'hyper-, 'super- keys
;;
;; With the following settings, <lwindow> key is used as 'super' modifier,
;; <apps> ("[menu]") used as 'hyper' modifier, <rwindow> key as 'alt' modifier.
;;
;; You can always use `key-translation-map' to map other keys as modifiers.
;;
;; 
;; Window-related commands are bind to super- keys (as the similarity
;; to 'windows' logo).  Other commands bind to hyper- keys. Note `alt'
;; modifier are not used here, but Org Mode use it to input accent
;; chars.
;;
;;

;;{{{ initial magics
(defun enable-hyper-super-modifiers-win32 ()
       ;;(setq w32-pass-apps-to-system nil)
       (setq w32-apps-modifier 'hyper)

       (setq w32-pass-lwindow-to-system nil)
       ;;(setq w32-phantom-key-code 42)  ;; what for?
       (setq w32-lwindow-modifier 'super)
       (setq w32-rwindow-modifier 'alt)  

       )

(defun enable-hyper-super-modifiers-linux-x ()
  ;; on nowadays linux, <windows> key is usually configured to Super
    
  ;; menu key as hyper (Note: for H-s, you need to release <menu> key before pressing 's')
  (define-key key-translation-map [menu] 'event-apply-hyper-modifier) ;H-
  (define-key key-translation-map [apps] 'event-apply-hyper-modifier)

  ;; by default, Emacs bind <menu> to execute-extended-command (same as M-x)
  ;; now <menu> defined as 'hyper, we need to press <menu> twice to get <H-menu>
  (global-set-key (kbd "<H-menu>") 'execute-extended-command)
  )

(defun enable-hyper-super-modifiers-linux-console ()
  (message "fixme: enable-hyper-super-modifiers-linux-console"))

(defun enable-hyper-super-modifiers-macos ()
  ;; http://xahlee.org/emacs/emacs_hyper_super_keys.html
  (setq mac-option-modifier 'hyper) ; sets the Option key as Hyper
  (setq mac-option-modifier 'super) ; sets the Option key as Super
  (setq mac-command-modifier 'meta) ; sets the Command key as Meta
  (setq mac-control-modifier 'meta) ; sets the Control key as Meta
  )

(defun enable-hyper-super-modifiers ()
  (let ( (frame (framep (selected-frame))) )
    (cond
     ( (memq frame '(w32 win32))
       (enable-hyper-super-modifiers-win32) )
     ( (eq frame 'x)
       (enable-hyper-super-modifiers-linux-x ) )
     ( (eq frame 'ns)
       (enable-hyper-super-modifiers-macos) )
     ( frame
       (enable-hyper-super-modifiers-linux-console ))
     ( t
       (message "fixmed: enable-hyper-super-modifiers") )
    ))

  ;; you can always use "C-c h" as 'hyper modifier, even in Linux console or DOS
  (define-key key-translation-map (kbd "C-c h") 'event-apply-hyper-modifier)
  (define-key key-translation-map (kbd "C-c s") 'event-apply-super-modifier)
  (define-key key-translation-map (kbd "C-c a") 'event-apply-alt-modifier)
  )

(enable-hyper-super-modifiers)
;;}}}

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

(load "folding" t)		;; complementary for outline/hideshow, user-definable mark-based folding
(load "fold-dwim" t)		;; uniformed front-end for outline/hideshow/folding
;;}}}

(defun hkb--symbol-selected-or-current ()
  "Get the selected text or (if nothing selected) current symbol."
  (if (and transient-mark-mode mark-active)
      (buffer-substring-no-properties (region-beginning) (region-end))
    (thing-at-point 'symbol)))
       

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

(defun hkb-select-method()
  (interactive)
  (cond
   ( (fboundp 'anything-imenu) (anything-imenu) )
   ( (fboundp 'idomenu) (idomenu) )
   ( (and (fboundp 'eassist-list-methods)
	  (memq major-mode '(emacs-lisp-mode c-mode java-mode python-mode))
	  (memq 'semantic-mode minor-mode-alist))
     (eassist-list-methods) )
   (t (imenu))))
(global-set-key (kbd "H-]") 'hkb-select-method)

(defun hkb-goto-symbol()
  (interactive)
  (let ( (keyword (hkb--symbol-selected-or-current)) )
    (cond
     ( (memq major-mode '(emacs-lisp-mode lisp-interaction-mode))
       (find-function-at-point) )
     ( (and (fboundp 'semantic-complete-jump)
	     (memq major-mode '(c-mode java-mode python-mode)))
       (semantic-complete-jump) )
     (t
      (find-tag)))))
(global-set-key (kbd "H-.") 'hkb-goto-symbol)

;;}}}

;;{{{ operation on current word/symbol
(defun hkb-goto-symbol-occurrence (forward)
  (let ( (symbol (hkb--symbol-selected-or-current)) )
    (unless symbol (error "No symbol at point"))  
    (unless hi-lock-mode (hi-lock-mode 1))  
    (if (not (member symbol highlight-symbol-list))  
	(highlight-symbol-at-point)))  
  (if forward
      (highlight-symbol-next)
    (highlight-symbol-prev)))

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
(defun hkb-occur-at-point ()
  (interactive)
  (occur (format "%s" (hkb--symbol-selected-or-current))))
  
(global-set-key (kbd "H-l") 'hkb-occur-at-point)

(defun hkb-moccur-at-point ()
  (interactive)
  (moccur (format "%s" (hkb--symbol-selected-or-current))))

(global-set-key (kbd "H-L") 'hkb-moccur-at-point)

;; grep
;;TODO: implement this

;; completion  (Emacs default: M-TAB - lisp-complete-symbol, M-/ - dabbrev-expand)

;;(if (< emacs-major-version 24)
;;    (global-set-key (kbd "H-/") 'lisp-complete-symbol)))
(global-set-key (kbd "H-/") 'completion-at-point)
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

;; folding

(global-set-key (kbd "H-=") 'fold-dwim-toggle)
(global-set-key (kbd "H-+") 'fold-dwim-show-all)
(global-set-key (kbd "H-_") 'fold-dwim-hide-all)


;;; select rectangle using H-mouse-1
(require 'cua-rect)	
(defun hkb-mouse-mark-cua-rectangle (event)
  (interactive "e")
  (if (not cua--rectangle)	  
      (cua-mouse-set-rectangle-mark event)
    (cua-mouse-resize-rectangle event)))
(global-set-key (kbd "<s-mouse-1>") 'hkb-mouse-mark-cua-rectangle)
(define-key cua--rectangle-keymap (kbd "<s-mouse-1>") 'hkb-mouse-mark-cua-rectangle)
    


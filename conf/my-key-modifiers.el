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
    


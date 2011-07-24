;;;-- on Linux, wheel-up/-down is called mouse-4/-5
(define-key key-translation-map (kbd "<C-mouse-4>") (kbd "<C-wheel-up>"))
(define-key key-translation-map (kbd "<C-mouse-5>") (kbd "<C-wheel-down>"))
(define-key key-translation-map (kbd "<M-mouse-4>") (kbd "<M-wheel-up>"))
(define-key key-translation-map (kbd "<M-mouse-5>") (kbd "<M-wheel-down>"))
(define-key key-translation-map (kbd "<S-mouse-4>") (kbd "<S-wheel-up>"))
(define-key key-translation-map (kbd "<S-mouse-5>") (kbd "<S-wheel-down>"))
(define-key key-translation-map (kbd "<A-mouse-4>") (kbd "<A-wheel-up>"))
(define-key key-translation-map (kbd "<A-mouse-5>") (kbd "<A-wheel-down>"))


(defmacro defun-mouse (newfunc function)
  `(defun ,newfunc (event)
     (interactive "e")
     (mouse-set-point event)
     (call-interactively ',function)))


;;;-- without any modifier
(autoload 'highlight-symbol-at-point "highlight-symbol" "Toggle highlighting of the symbol at point." t)
(global-set-key (kbd "<double-down-mouse-1>") 'highlight-symbol-at-point)

;;(require 'mouse3)

;;-- <left-fringe>: code folding (hideshow-fringe)


;;;-- Ctrl:  code folding
(global-unset-key (kbd "<C-down-mouse-1>")) ;;moved to <mode-line>
(global-unset-key (kbd "<C-down-mouse-2>"))

(require 'outline)

;; (defun outline-toggle-children-by-mouse (event)
;;   (interactive "e")
;;   (mouse-set-point event)
;;   (call-interactively 'outline-toggle-children))
(defun-mouse outline-toggle-children-by-mouse outline-toggle-children)

(global-set-key (kbd "<C-wheel-up>")   'outline-previous-visible-heading)
(global-set-key (kbd "<C-wheel-down>") 'outline-next-visible-heading)

(global-set-key (kbd "<C-mouse-2>")    'hide-sublevels)


;;-- Ctrl on <left-fringe> :  buffer-local bookmarks
(global-set-key (kbd "<left-fringe> <C-mouse-1>")    'outline-toggle-children-by-mouse)
(global-set-key (kbd "<left-fringe> <C-mouse-2>") 'show-all)

;;-- Ctrl on <mode-line>
(global-set-key (kbd "<mode-line> <C-down-mouse-1>")    'mouse-buffer-menu)

(global-set-key (kbd "<mode-line> <C-wheel-up>")        'text-scale-increase)
(global-set-key (kbd "<mode-line> <C-wheel-down>")      'text-scale-decrease)




;;;-- Shift: some special marks overlays
(global-unset-key (kbd "<S-down-mouse-1>")) ;;mouse-appearance-menu moved to mode-line

(autoload 'markerpen-show-all-pens "markerpen" "Display a buffer with samples of the markerpens in use" t)
;;(global-set-key (kbd "<S-mouse-1>")      'markerpen-mark-start-point-by-mouse)
;;(global-set-key (kbd "<S-mouse-3>")      'makrerpen-mark-end-point-by-mouse)
(global-set-key (kbd "<S-mouse-2>")      'markerpen-show-all-pens)
;;(global-set-key (kbd "<S-wheel-up>")      'makrerpen-previouse-pen)
;;(global-set-key (kbd "<S-wheel-down>")      'makrerpen-next-pen)


(global-set-key (kbd "<S-down-mouse-3>") 'facemenu-menu) ;;moved from C-down-mouse-2

;;FIXME: markerpen.el

;;-- Shift on <left-fringe> :  buffer-local bookmarks


;; see also: (@file :file-name "linemark.el" :to "enable-visual-studio-bookmarks")
(ignore-errors
  (or (require 'bm nil t)
      (require 'linkmark nil t))
  )
(if (load "bm" t)
    (progn
      (global-set-key (kbd "<left-fringe> <S-mouse-1>") 'bm-toggle-mouse)
      (global-set-key (kbd "<left-fringe> <S-wheel-up>") 'bm-previous-mouse)
      (global-set-key (kbd "<left-fringe> <S-wheel-down>") 'bm-next-mouse))
  (if (featurep 'linemark)              ;; linemark.el from CEDET
      (progn
        (global-set-key (kbd "<left-fringe> <S-mouse-1>") 'viss-bookmark-toggle)
        (global-set-key (kbd "<left-fringe> <S-wheel-up>") 'viss-bookmark-next-buffer)
        (global-set-key (kbd "<left-fringe> <S-wheel-down>") 'viss-bookmark-prev-buffer))
    ))

;;-- Shift on <mode-line>
(global-set-key (kbd "<mode-line> <S-down-mouse-1>") 'mouse-appearance-menu)
(global-set-key (kbd "<mode-line> <S-down-mouse-3>") 'facemenu-menu)



;;;-- Meta
;;keep the original behaviour for secondary selection
;; M-mouse-1: mouse-drag-secondary
;; M-mouse-2: mouse-yank-secondary
;; M-mouse-3: mouse-secondary-save-then-kill

;;temp
(global-set-key (kbd "<M-wheel-up>") 'highlight-symbol-prev)
(global-set-key (kbd "<M-wheel-down>")  'highlight-symbol-next)

;;-- Meta on <left-fringe>



;;-- Alt
(global-set-key (kbd "<A-wheel-up>") 'highlight-symbol-prev)
(global-set-key (kbd "<A-wheel-down>")  'highlight-symbol-next)


;;; select rectangle using A-mouse-1 (FIXME: could it work?)
(require 'cua-rect)	
(defun hkb-mouse-mark-cua-rectangle (event)
  (interactive "e")
  (if (not cua--rectangle)	  
      (cua-mouse-set-rectangle-mark event)
    (cua-mouse-resize-rectangle event)))
(global-set-key (kbd "<A-mouse-1>") 'hkb-mouse-mark-cua-rectangle)
(define-key cua--rectangle-keymap (kbd "<A-mouse-1>") 'hkb-mouse-mark-cua-rectangle)

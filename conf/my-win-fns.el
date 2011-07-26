(require 'windmove)


(unless (require 'ide-skel nil t)  ;; `ide-skel' would load `tabbar' and  make its own tab group settings
  (require 'tabbar nil t))

(unless (require 'window-extension nil t)  ;; `window-extension' already contain the functions of `sticky-windows'
    (require 'sticky-windows nil t))
;;(require 'dedicated) ;;A very simple minor mode for dedicated buffers

;;(require 'transpose-frame nil t) ;; flip window layout within a frame
(autoload 'transpose-frame "transpose-frame"  "Transpose windows arrangement at FRAME." t)
(autoload 'flip-frame "transpose-frame" "Flip windows arrangement vertically at FRAME." t)
(autoload 'flop-frame "transpose-frame" "Flop windows arrangement horizontally at FRAME." t)
(autoload 'rotate-frame "transpose-frame" "Rotate windows arrangement 180 degrees at FRAME." t)

;;(require 'window-numbering nil t) ;; each window has a number in mode-line
(autoload 'window-numbering-mode "window-numbering" "A minor mode that assigns a number to each window" t)

;;(require 'pack-windows) ;; Resize all windows to display as much info as possible.

;;(require 'split-root) ;; roote window splitter
(autoload 'split-root-window "split-root" "Split a window of SIZE lines/columns from the root window." t)


;; for some special buffer
;;(require 'imenu-tree nil t)
(autoload 'imenu-tree "imenu-tree" "Display tree view of imenu." t)
(autoload 'tags-tree "tags-tree" "Display tree view of tags." t)

;;(require 'sr-speedbar nil t)
(autoload 'sr-speedbar-toggle "sr-speedbar" "Toggle sr-speedbar window" t)
(autoload 'sr-speedbar-open   "sr-speedbar" "Open the sr-speedbar window" t)

;;(require 'nav)  ;; emacs-nav
(autoload 'nav "nav" "Runs nav-mode in a narrow window on the left side" t)



;;{{{ window resizing

(defcustom win-resize-big-steps-horizontal 5
  "size by columns each time we call enlarge/shrink-window-horizontally-more.")

(defcustom win-resize-big-steps-vertical 3
  "size by rows each time we call enlarge/shrink-window-more.")

(defun enlarge-window-2d (arg)
  (interactive "p")
  (enlarge-window arg)
  (enlarge-window-horizontally arg))
  
(defun shrink-window-2d (arg)
  (interactive "p")
  (shrink-window arg)
  (shrink-window-horizontally arg))

;;(global-set-key (kbd "<f11> +") 'enlarge-window-2d)
;;(global-set-key (kbd "<f11> -") 'shrink-window-2d)

(defun enlarge-window-vertically-more (arg)
  (interactive "p")
  (enlarge-window (* arg win-resize-big-steps-vertical)))

(defun shrink-window-vertically-more (arg)
  (interactive "p")
  (shrink-window (* arg win-resize-big-steps-vertical)))

(defun enlarge-window-horizontally-more ()
  (interactive)
  (enlarge-window win-resize-big-steps-horizontal))

(defun shrink-window-horizontally-more ()
  (interactive)
  (shrink-window win-resize-big-steps-horizontal))

(defun enlarge-window-2d-more ()
  "enlarge window in both 2 dimensions"
  (interactive)
  (enlarge-window win-resize-big-steps-vertical)
  (enlarge-window-horizontally win-resize-big-steps-horizontal))

(defun shrink-window-2d-more ()
  "shrink window in both 2 dimensions"
  (interactive)
  (shrink-window win-resize-big-steps-vertical)
  (shrink-window-horizontally win-resize-big-steps-horizontal))
  
;;}}}
;;{{{ move buffer across windows
;; https://github.com/banister/window-rotate-for-emacs
(defun rotate-windows-helper(x d)
  (if (equal (cdr x) nil) (set-window-buffer (car x) d)
    (set-window-buffer (car x) (window-buffer (cadr x))) (rotate-windows-helper (cdr x) d)))
 
(defun rotate-windows ()
  (interactive)
  (rotate-windows-helper (window-list) (window-buffer (car (window-list))))
  (select-window (car (last (window-list)))))


;;TODO: backward-rotate-windows


;;{{{ swap buffer window
;; modified from windmove-do-window-select
(defun windmove-do-swap-window (dir swap &optional arg window)
  "Move the buffer to the window at direction DIR.

If SWAP is non-nil, the buffers in the source window and target
window would be swapped, otherwise only the source buffer be
moved to target window.  DIR, ARG, and WINDOW are handled as by
`windmove-other-window-loc'.  If no window is at direction DIR,
an error is signaled."
  (let ((other-window (windmove-find-other-window dir arg window)))
    (cond ((null other-window)
           (error "No window %s from selected window" dir))
          ((and (window-minibuffer-p other-window)
                (not (minibuffer-window-active-p other-window)))
           (error "Minibuffer is inactive"))
	  ( (window-dedicated-p window)
	    (error "Current window is dedicated, can't be moved") )
	  ( (window-dedicated-p other-window)
	    (error "Target window is dedicated, can't be swapped") )
	  (t
	   (let ( (this-buffer (window-buffer window))
		  (other-buffer (window-buffer other-window)))
	     (if (eq this-buffer other-buffer)
		 (let ( (this-point (window-point window))
			(other-point (window-point other-window)) )
		   (progn
		     (set-window-point window other-point)
		     (set-window-point other-window this-point)))
	       (progn
                 (if swap
                     (set-window-buffer window (window-buffer other-window)))
		 (set-window-buffer other-window this-buffer)))
	     (select-window other-window))))))


(defun swap-buffer-up (&optional arg)
  (interactive "P")
  (windmove-do-swap-window 'up t arg))

(defun swap-buffer-down (&optional arg)
  (interactive "P")
  (windmove-do-swap-window 'down t arg))

(defun swap-buffer-left (&optional arg)
  (interactive "P")
  (windmove-do-swap-window 'left t arg))

(defun swap-buffer-right (&optional arg)
  (interactive "P")
  (windmove-do-swap-window 'right t arg))

(defun move-buffer-up (&optional arg)
  (interactive "P")
  (windmove-do-swap-window 'up nil arg))

(defun move-buffer-down (&optional arg)
  (interactive "P")
  (windmove-do-swap-window 'down nil arg))

(defun move-buffer-left (&optional arg)
  (interactive "P")
  (windmove-do-swap-window 'left nil arg))

(defun move-buffer-right (&optional arg)
  (interactive "P")
  (windmove-do-swap-window 'right nil arg))


;;--- misc
(defun other-window-backward (arg)
  (interactive "p")
  (other-window (- arg)))

(defun ido-jump-to-window ()
  (interactive)
  (defun swap(l)
    (if (cdr l)
	(cons (cadr l) (cons (car l) (cddr l)))
      l))
  (if (< emacs-major-version 24)
      (ido-common-initialization))
  (let* ( ;; Swaps the current buffer name with the next one along.
         (visible-buffers (swap (mapcar '(lambda (window) (buffer-name (window-buffer window))) (window-list))))
         (buffer-name (ido-completing-read "Window: " visible-buffers))
         window-of-buffer)
    (if (not (member buffer-name visible-buffers))
        (error "'%s' does not have a visible window" buffer-name)
      (setq window-of-buffer
                (delq nil (mapcar '(lambda (window)
                                       (if (equal buffer-name (buffer-name (window-buffer window)))
                                           window
                                         nil))
                                  (window-list))))
      (select-window (car window-of-buffer)))))

;;(when (featurep 'tabbar)
(defun ido-jump-to-tab ()
  (interactive)
  (if (< emacs-major-version 24)
      (ido-common-initialization))
  (let* ( ;; Swaps the current buffer name with the next one along.
         (visible-buffers (mapcar '(lambda (tab) (buffer-name (tabbar-tab-value tab)))
					  (tabbar-tabs (tabbar-current-tabset t))))
         (buffer-name (ido-completing-read "Buffer: " visible-buffers))
         window-of-buffer)
    (if (not (member buffer-name visible-buffers))
        (error "'%s' does not have a visible window" buffer-name)
      (switch-to-buffer buffer-name))))

(defun bmz/imenu-tree (arg)
  (interactive "P")
  (imenu-tree arg)
  (if (featurep 'ide-skel)
      (add-to-list 'ide-skel-tabbar-hidden-buffer-names-regexp-list "^\\*imenu-tree\\*$"))
  (let* ( (windows (delq nil (mapcar '(lambda (window)
                                       (if (equal "*imenu-tree*" (buffer-name (window-buffer window)))
                                           window
                                         nil))
                                  (window-list))))
          (window (car windows)) )
    (if window
        (set-window-dedicated-p window t))))
    

(defun split-root-window-vertially ()
  (interactive)
  (split-root-window nil nil))

(defun split-root-window-horizontally ()
  (interactive)
  (split-root-window nil 'horizontally))

;; keys


(defun init-win-fns-keys (map)
    ;; resizing
    ;(define-key map (kbd "}") 'enlarge-window)
    (define-key map (kbd "}") 'enlarge-window-more)
    ;;(define-key map (kbd "{") 'shrink-window)
    (define-key map (kbd "{") 'shrink-window-more)
    
    ;;(define-key map (kbd "^") 'enlarge-window-horizontally)
    (define-key map (kbd "^") 'enlarge-window--more)
    ;;(define-key map (kbd "v") 'shrink-window-horizontally)
    (define-key map (kbd "v") 'shrink-window-horizontally)
    
    (define-key map (kbd "+") 'enlarge-window-2d-more)
    (define-key map (kbd "-") 'shrink-window-2d-more)
    ;;  (define-key map (kbd "") 'enlarge-window-
				    

    ;; motion between windows
    ;;(windmove-default-keybindings 'super)
    (define-key map (kbd "<up>") 'windmove-up)
    (define-key map (kbd "<down>") 'windmove-down)
    (define-key map (kbd "<left>") 'windmove-right)
    (define-key map (kbd "<right>") 'windmove-right)   
    
    (define-key map (kbd "<C-up>") 'swap-buffer-up)
    (define-key map (kbd "<C-down>") 'swap-buffer-down)
    (define-key map (kbd "<C-left>") 'swap-buffer-left)
    (define-key map (kbd "<C-right>") 'swap-buffer-right)

    (define-key map (kbd "<M-up>") 'swap-buffer-up)
    (define-key map (kbd "<M-down>") 'swap-buffer-down)
    (define-key map (kbd "<M-left>") 'swap-buffer-left)
    (define-key map (kbd "<M-right>") 'swap-buffer-right)
    
    (define-key map (kbd "<tab>") 'other-window)
    (define-key map (kbd "<S-tab>") 'other-window-backward)

;;    (define-key map (kbd "D")   'dired-jump-other-window)
    
    (define-key map (kbd "g w") 'ido-jump-to-window)
    (define-key map (kbd "g t") 'ido-jump-to-tab)

    ;; (if (featurep 'window-numbering)
    ;;     ;;FIXME: customize the keymap
    ;;     (window-numbering-mode t))

    (define-key map (kbd "C-z") 'winner-undo)
    (define-key map (kbd "C-y") 'winner-redo)

    (define-key map (kbd "<s-backspace>") 'rotate-windows)
    
    ;; the following need some 3rd-party library
    
    ;;TODO:
    ;; transpose-frame
    ;; flip-frame
    ;; flop-frame
    ;; rotate-frame
    ;; rotate-frame-clockwise
    ;; rotate-frame-anti-clockwise


    (define-key map (kbd "C-m") 'toggle-one-window)
    (define-key map (kbd "<f11>") 'toggle-one-window)
    
    ;; override C-x 0 and C-x 1, to regard window-dedicated-p
    ;;(when (or (featurep 'window-extensions)
    ;;          (featurep 'sticky-windows)))
    (define-key map (kbd "*") 'sticky-window-keep-window-visible)    
    (when (fboundp 'sticky-window-delete-window)
        (global-set-key (kbd "C-x 0") 'sticky-window-delete-window)
        (global-set-key (kbd "C-x 1") 'sticky-window-delete-other-windows))

    ;; split-root.el
    (define-key map (kbd "2") 'split-root-window-vertially)
    (define-key map (kbd "3") 'split-root-window-horizontally)
    
    ;;(when (featurep 'tabbar)            
    (define-key map (kbd "C-n") 'tabbar-forward-tab)
    (define-key map (kbd "C-p") 'tabbar-backward-tab)

    ;;
    ;; some special windows
    ;;(when (featurep 'imenu-tree)
    (define-key map (kbd "I") 'bmz/imenu-tree)
    (define-key map (kbd "T") 'tags-tree)
    (define-key map (kbd "N") 'nav)

    ;;(when (featurep 'ide-skel)
    (define-key map (kbd "B") 'ide-skel-toggle-bottom-view-window)
    (define-key map (kbd "R") 'ide-skel-toggle-right-view-window)
    (define-key map (kbd "L") 'ide-skel-toggle-left-view-window)

    (define-key map (kbd "s") 'speedbar)
    ;;(if (featurep 'sr-speedbar)
    (define-key map (kbd "S") 'sr-speedbar-toggle)

    map
    )

(defvar my-win-fns-keymap (make-sparse-keymap "Window operations"))
(init-win-fns-keys my-win-fns-keymap)

(define-key global-map (kbd "<f11>") 'my-win-fns-keymap)
(define-key global-map (kbd "<lwindow>") 'my-win-fns-keymap)

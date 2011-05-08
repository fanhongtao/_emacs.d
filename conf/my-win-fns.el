(require 'windmove)

(unless (require 'window-extension nil t)
    (require 'sticky-windows nil t))

(unless (require 'ide-skel nil t)
  (require 'tabbar nil t))

(require 'imenu-tree nil t)
(require 'sr-speedbar nil t)

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

(defun enlarge-window-vertically-more ()
  (interactive)
  (enlarge-window win-resize-big-steps-vertical))

(defun shrink-window-vertically-more ()
  (interactive)
  (shrink-window win-resize-big-steps-vertical))

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
(defun windmove-do-swap-window (dir &optional arg window)
  "Move the buffer to the window at direction DIR.
DIR, ARG, and WINDOW are handled as by `windmove-other-window-loc'.
If no window is at direction DIR, an error is signaled."
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
		     (set-window-point other-window this-point)
		     (message "unimplemented: swap same buffer?")))
	       (progn
		 (set-window-buffer window (window-buffer other-window))
		 (set-window-buffer other-window this-buffer)))
	     (select-window other-window))))))


(defun swap-buffer-up (&optional arg)
  (interactive "P")
  (windmove-do-swap-window 'up arg))

(defun swap-buffer-down (&optional arg)
  (interactive "P")
  (windmove-do-swap-window 'down arg))

(defun swap-buffer-left (&optional arg)
  (interactive "P")
  (windmove-do-swap-window 'left arg))

(defun swap-buffer-right (&optional arg)
  (interactive "P")
  (windmove-do-swap-window 'right arg))

;;--- misc
(defun other-window-backward (arg)
  (interactive "p")
  (other-window (- arg)))

(require 'ido)
(unless (fboundp 'ido-common-initialization)   ;;workaround for emacs 23.1's bug(?)
  (defun ido-common-initialization ()
    (ido-init-completion-maps)
    (add-hook 'minibuffer-setup-hook 'ido-minibuffer-setup)
    (add-hook 'choose-completion-string-functions 'ido-choose-completion-string))
  )

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



;; keys

(defvar my-win-fns-keymap (make-sparse-keymap "Window operations"))
(define-prefix-command 'my-win-fns-keymap)


(defun init-win-fns-keys ()
  (global-set-key (kbd "<f11>") my-win-fns-keymap)

  ;; translate <lwindow> to <f11>
  (define-key key-translation-map (kbd "<lwindow>") (kbd "<f11>"))

  (let ( (map my-win-fns-keymap) )
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

    (define-key map (kbd "<s-backspace>") 'rotate-windows)
    
    (define-key map (kbd "<C-up>") 'swap-buffer-up)
    (define-key map (kbd "<C-down>") 'swap-buffer-down)
    (define-key map (kbd "<C-left>") 'swap-buffer-left)
    (define-key map (kbd "<C-right>") 'swap-buffer-right)

    (define-key map (kbd "<tab>") 'other-window)
    (define-key map (kbd "<S-tab>") 'other-window-backward)

    (define-key map (kbd "j") 'ido-jump-to-window)
    (define-key map (kbd "<C-tab>") 'ido-jump-to-tab)

    ;; the following need some 3rd-party library

    ;;(when (or (featurep 'window-extensions)
    ;;          (featurep 'sticky-windows)))
    (define-key map (kbd "*") 'sticky-window-keep-window-visible)
    (define-key map (kbd "C-m") 'toggle-one-window)
    
    ;; (if (featurep 'tabbar)
    ;;     (progn
    ;;       (define-key super-win-keymap (kbd "<C-tab>")   'tabbar-forward-tab)
    ;;       (define-key super-win-keymap (kbd "<C-s-tab>") 'tabbar-backward-tab)))

    ;;
    ;; some special windows
    ;;(when (featurep 'imenu-tree)
    (define-key map (kbd "s-I") 'imenu-tree)

    ;;(when (featurep 'ide-skel)
    (define-key map (kbd "s-B") 'ide-skel-toggle-bottom-view-window)
    (define-key map (kbd "s-R") 'ide-skel-toggle-right-view-window)
    (define-key map (kbd "s-L") 'ide-skel-toggle-left-view-window)

    (define-key map (kbd "s-s") 'speedbar)
    ;;(if (featurep 'sr-speedbar)
    (define-key map (kbd "s-S") 'sr-speedbar-toggle)
    ))

(init-win-fns-keys)

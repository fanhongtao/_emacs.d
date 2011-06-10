;;{{{ packages, load-path and related
(add-to-list 'load-path "~/.emacs.d/lisp/")
;;(add-to-list 'load-path "~/.emacs.d/mylisp/")

;; (loop for f in (directory-files "~/.emacs.d/init.d" nil ".*.el")
;;       by (message "loading %s" f))


;;; This was installed by package-install.el.
;;; This provides support for the package system and
;;; interfacing with ELPA, the package archive.
;;; Move this code earlier if you want to reference
;;; packages in your .emacs.
(when
    (load
     (expand-file-name "~/.emacs.d/elpa/package.el"))
  (package-initialize))

(when (file-exists-p "~/.emacs.d/site-lisp/site-start.el")
  (load "~/.demacs.d/site-lisp/site-start.el"))


;; leave customization & os/distro/installation-specific settings to another file
;; (customizations, paths, theme)
(setq custom-file "~/.emacs.d/customize.el")
(if (file-exists-p custom-file)
    (load custom-file))

;;}}}


;;{{{ some basic settings
(fset 'yes-or-no-p 'y-or-n-p)

(if (fboundp 'tool-bar-mode)
    (tool-bar-mode -1))

(setq frame-title-format '("%b (%m) - Emacs "
			   (:eval emacs-version)))


(when (eq window-system 'x)
    (setq x-select-enable-clipboard t)
;;  (setq x-select-enable-primary t)
    (set-scroll-bar-mode 'right))


(setq show-paren-mode t)

(setq-default truncate-lines t)
(setq-default fill-column 100)
;;(auto-fill-mode t)

(require 'recentf)
(setq recentf-max-saved-items 100)

(setq recentf-menu-path '("File"))
(recentf-mode t)
;;}}}

;;{{{ key bindings
(setq shift-select-mode t)
(delete-selection-mode t)

(setq cua-enable-cua-keys nil)
;;(setq cua-rectangle-modifier-key 'hyper)  ;;leave C-RET
(cua-mode)



(if (<= emacs-major-version 23) ;; emacs < 23.2
     (setq tab-always-indent nil)
   (setq tab-always-indent 'complete)) ;; emacs >= 23.2
;;(setq tab-always-indent t)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)



(global-set-key (kbd "RET") 'indent-new-comment-line)
(global-set-key (kbd "C-j") 'newline)

(global-set-key (kbd "C-=") 'align-regexp)

(global-set-key (kbd "M-/") 'hippie-expand)

(global-set-key (kbd "C-c ;") 'comment-or-uncomment-region)

(global-set-key (kbd "C-c C-w") 'toggle-truncate-lines)
(global-set-key (kbd "C-c RET") 'cua-set-rectangle-mark)

(global-set-key (kbd "<C-tab>") 'previous-buffer)
(global-set-key (kbd "<C-S-tab>") 'next-buffer)
;;}}}



(load "~/.emacs.d/conf/my-init.el")


;;{{{ generate autoload and load them
(defun generate-dir-autoload-and-load (top-dir)
  (let ( (generated-autoload-file "~/.emacs.d/autoloads.el") )
    (mapc '(lambda (dir)
             (update-autoloads-from-directories dir))
          '("e:/emacs/site-lisp/misc_"
            "e:/emacs/site-lisp/filetype_"
            "e:/emacs/site-lisp/prog_"
            "e:/emacs/site-lisp/win32_"
            ))
    (load-file generated-autoload-file)))

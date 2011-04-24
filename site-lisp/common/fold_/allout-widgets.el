;; allout-widgets.el --- Allout outline item graphics and interleaved settings.

;; Copyright (C) 2005, 2006, 2007 Ken Manheimer

;; Author: Ken Manheimer <ken dot manheimer at gmail dot com>
;; Maintainer: Ken Manheimer <ken dot manheimer at gmail dot com>
;; Created: Dec 2005
;; Version: $Id: allout-widgets.el,v 1.95 2007/12/19 20:16:48 klm Exp $||
;; Keywords: outlines

;;; Commentary:

;; This is an optional add-on to allout outline mode which furnishes items
;; with graphical features and also interleaved state settings.  It is
;; backwards and forwards compatible with recent allout versions, but does
;; cause some outline item changes to provide extended features.  Converted
;; outlines will still be usable in plain allout mode, but will include
;; many extra subitems and dangling reference items which won't be useful
;; there.
;;
;; To add widgets to allout operation, load allout-widgets in addition to
;; allout, and arrange for invocation of the function
;; `allout-mode-widgets-init', e.g., in your .emacs:
;;
;;   (require 'allout)
;;   (require 'allout-widgets)
;;   (allout-mode-widgets-init)
;;
;; Then, any allout outlines you visit will use widgets.
;;
;; You can inhibit widget operation for particular allout outlines by
;; setting the variable `allout-widgets-mode-inhibit' non-nil in that
;; file's buffer, eg using an emacs *file local variables* passages
;; (described in the emacs user and elisp manuals)."
;;
;; NOTE - Settings, described below, are not yet implemented.
;;
;; Conversion to allout-widgets format adds setting subitems to each item
;; which convey its contextual state besides its content, including its
;; unique identifier (item and topic id).  Allout "distinctive" bullets are
;; converted to settings state, and item exposure (empty, collapsed, or
;; expanded) is indicated using the ascii bullet character.  The extended
;; mode provides for situating and otherwise cross referencing items within
;; and across outlines, but those references will be near opaque and
;; useless in regular allout.
;;
;; The graphics include:
;;
;; - icons for item bullets, varying to distinguish whether the item either
;;   lacks any subitems, the subitems are currently collapsed within the
;;   item, or the item is currently expanded.
;;
;; - guide lines connecting item bullet-icons with those of their subitems.
;;
;; - cue area between the bullet-icon and the start of the body headline,
;;   for item numbering, encryption indicator, and user-selected item
;;   status flags.
;;
;; - indication of concealed body lines, when they exist (XXX probably using)
;;   distinctive bullet graphics)
;;
;; - symbols displayed on empty headlines to indicate an empty body, or an
;;   empty headline with concealed torso lines.
;;
;; The bullet-icon and guide line graphics provide keybindings and mouse
;; bindings for easy outline navigation and exposure control, extending
;; outline hot-spot navigation (see `allout-mode' docstring for details).
;;
;; Our use of emacs widgets is limited and unconventional.  We specifically
;; are *not* using them to replace text in the buffer - decorate existing
;; text rather than substituting for it, to piggy-back on existing allout
;; operation.  There's no deletion of existing text and use of format
;; strings to substitute new text, etc.  This employs the C-coded
;; efficiencies of widget-apply, widget-get, and widget-put, along with the
;; basic object-oriented organization of widget-create, to systematically
;; couple overlays, graphics, and other features with allout-governed text..

;;;X - things marked with this haven't yet been properly migrated or removed.

;;;_: General Environment
(require 'widget)
(require 'wid-edit)
(require 'allout-item-settings)
(require 'allout-tests)

(eval-when-compile
  (progn
    (require 'overlay)
    (require 'cl)
    ))

;;;_: USER CUSTOMIZATION VARIABLES:
;;;_ > defgroup allout-decorations
(defgroup allout-decorations nil
  "Allout outline mode extension providing graphical outline presentation."
  :group 'allout)
;;;_ = allout-allow-unruly-edits
(defcustom allout-allow-unruly-edits nil
  "*Control whether manual edits are restricted to maintain outline integrity.

When nil, manual edits must either be within an item's body or encompass
one or more items completely - eg, killing topics as entities, rather than
deleting from the middle of one to the middle of another.

If you only occasionally need to make unrestricted change, you can set this
variable in the specific buffer using set-variable, or just deactivate
`allout-mode' temporarily.  You can customize this to always allow unruly
edits, but you will be able to create outlines that are unnavigable in
principle, and not just for allout's navigation and exposure mechanisms."
  :type 'boolean
  :group 'allout-decorations)
(make-variable-buffer-local 'allout-allow-unruly-edits)
;;;_ = allout-icons-dark-subdir
(defcustom allout-icons-dark-subdir "allout-icons-dark-bg/"
  "Name of directory on load-path holding allout icons for dark backgrounds."
  :type 'string
  :group 'allout-decorations)
;;;_ = allout-icons-light-subdir
(defcustom allout-icons-light-subdir "allout-icons-light-bg/"
  "Name of directory on load-path holding allout icons for light backgrounds."
  :type 'string
  :group 'allout-decorations)
;;;_ = allout-icon-types
(defcustom allout-icon-types '(xpm png)
  "File extensions for the icon graphic format types, in order of preference."
  :type '(repeat symbol)
  :group 'allout-decorations)

;;;_ = allout-empty-body-text
(defcustom allout-empty-body-text "-<>-"
  "Text for headline signifying a completely empty body, including headline."
  :type 'string
  :group 'allout-decorations)
;;;_ = allout-empty-body-face
(defface allout-empty-body-face '((((class color)(background dark))
                                   :foreground "gray40"
                                   :strike-through "gray40")
                                  (((class color)(background light))
                                   :foreground "gray80"
                                   :strike-through "gray80")
                                  (((class grayscale))
                                   :strike-through "gray"
                                   :underline "gray"
                                   :foreground "gray")
                                  (default (:underline)))
  "Face to indicate empty headline *and* body."
  :group 'allout-decorations)
;;;_ = allout-empty-headline-face
(defface allout-empty-headline-face
  '((((class color) (background dark))
     :underline "gray50" :foreground "gray50")
    (((class color) (background light))
     :underline "gray75" :foreground "gray75")
    (((class grayscale))
     :underline "gray75" :foreground "gray"))
  "Face to indicate empty headline."
  :group 'allout-decorations)
;;;_ = allout-headline-fallback-second-body-line t
(defcustom allout-headline-fallback-second-body-line t
  "When true, item will take headline from second body if the first is blank."
  :type 'boolean
  :group 'allout-decorations)
;;;_ = allout-headline-continued-face
(defface allout-headline-continued-face '((((class color)(background dark))
                                           :underline "gray50")
                                          (((class color)(background light))
                                           :underline "gray75")
                                          (((class grayscale))
                                           :underline "gray")
                                          (default (:underline "gray")))
  "Face for use with allout-empty-body-text to indicate empty body."
  :group 'allout-decorations)

;;;_ , Decoration format
;;;_  = allout-widgets-use-alternate-ellipsis
;;; THIS WILL ONLY WORK FOR ONE OF THE TWO COMMON ASCII EXTENDED CHARACTER SETS
(defcustom allout-widgets-use-alternate-ellipsis nil
  "*If non-nil, use char value to signify collapsed content instead of \"...\".

THIS IS A HACK - SOME TERMINALS USE ONE SET OF ASCII EXTENSIONS
AND WHILE OTHER TERMINALS USE A DIFFERENT SET.

When nil, default invisible-text ellipses will be used.

Changes of this setting will only obtain after allout-mode is restarted."
  :type '(choice (const :tag "No (use default \"...\" ellipsis)" nil)
                 (const :tag "» (right angle quote, guillemot right)" ?»)
                 (const :tag "« (left angle quote, guillemot left)" ?«)
                 (const :tag "þ (small thorn - icelandic)" ?þ)
                 (const :tag "÷ (division sign)" ?÷)
                 (const :tag "¤ (general currency sign)" ?¤)
                 (const :tag "* (multiply sign)" ?*)
                 (const :tag "§ (section sign)" ?§)
                 (const :tag "¬ (not sign)" ?¬)
                 (const :tag "¿ (inverted question mark)" ?¿)
                 (const :tag "¡ (inverted exclamation mark)" ?¡)
                 (const :tag "¥ (yen sign)" ?¥)
                 (const :tag "¶ (paragraph sign)" ?¶)
                 (const :tag "± (plus or minus)" ?±)
                 (const :tag "· (middle dot)" ?·)
                 (string :tag "·» (middle dot + right guillemot)" "·»")
                 (string :tag "Arbitrary string" :value "..."))
  :group 'allout)

;;;_  = allout-theme-dark-background
(defcustom allout-theme-dark-background "allout-dark-bg"
  "Identify the outline's icon theme to use with a dark background."
  :type '(string)
  :group 'allout-decorations)
;;;_  = allout-theme-light-background
(defcustom allout-theme-light-background "allout-light-bg"
  "Identify the outline's icon theme to use with a light background."
  :type '(string)
  :group 'allout-decorations)
;;;_  = allout-item-image-properties-emacs
(defcustom allout-item-image-properties-emacs
  '(:ascent center :mask (heuristic t))
  "*Default properties item widget images in mainline Emacs."
  :type 'plist
  :group 'allout-decorations)
;;;_  = allout-item-image-properties-xemacs
(defcustom allout-item-image-properties-xemacs
  nil
  "*Default properties item widget images in XEmacs."
  :type 'plist
  :group 'allout-decorations)
;;;_ , Developer
;;;_  = allout-widgets-run-unit-tests-on-load
(defcustom allout-widgets-run-unit-tests-on-load nil
  "*When non-nil, unit tests will be run at end of loading allout-widgets.

Generally, allout widgets code developers are the only ones who'll want to
set this.

\(If set, this makes it an even better practice to exercise changes by
doing byte-compilation with a repeat count, so the file is loaded after
compilation.)

See `allout-widgets-run-unit-tests' to see what's run."
  :type 'boolean
  :group 'allout-developer)
;;;_  = allout-widgets-time-decoration-activity
(defcustom allout-widgets-time-decoration-activity nil
  "*Retain timing info of the last cooperative redecoration.

The details are retained as the value of
`allout-widgets-last-decoration-timing'.

Generally, allout widgets code developers are the only ones who'll want to
set this."
  :type 'boolean
  :group 'allout-developer)
;;;_  = allout-widgets-hook-error-post-time 0
(defcustom allout-widgets-hook-error-post-time 0
  "*Amount of time to sit showing hook error messages.

0 is minimal, or nil to not post to the message area.

This is for debugging purposes."
  :type 'integer
  :group 'allout-developer)
;;;_  = allout-widgets-maintain-tally nil
(defcustom allout-widgets-maintain-tally nil
  "*If non-nil, maintain a collection of widgets, `allout-widgets-tally'.

This is for debugging purposes."
  :type 'boolean
  :group 'allout-developer)
(defvar allout-widgets-tally nil
  "Hash-table of existing allout widgets, for debugging.

Table is maintained iff `allout-widgets-maintain-tally' is non-nil.

The table contents will be out of sync if any widgets are created
or deleted while this variable is nil.")
(make-variable-buffer-local 'allout-widgets-tally)
(defvar allout-widgets-tally-count nil
  "Size of allout-widgets-tally, for mode-line display.

It is added as to minor-mode-alist just after the allout-mode entry.

This count is maintained if `allout-widgets-maintain-tally' is non-nil.")
(make-variable-buffer-local 'allout-widgets-tally-count)
;;;_  = allout-widgets-track-decoration nil
(defcustom allout-widgets-track-decoration nil
  "*If non-nil, show cursor position of each item decoration.

This is for debugging purposes, and generally set at need in a
buffer rather than as a prevailing configuration \(but it's handy
to publicize it by making it a customization variable\)."
  :type 'boolean
  :group 'allout-developer)
(make-variable-buffer-local 'allout-widgets-track-decoration)

;;;_: Mode context - variables, hookup, and hooks
;;;_ , internal mode variables
;;;_  . Mode activation and environment
;;;_   = allout-widgets-mode
(defvar allout-widgets-mode nil
  "Allout mode enhanced with graphical widgets and contextual settings.")
(make-variable-buffer-local 'allout-widgets-mode)
;;;_   = allout-widgets-mode-inhibit
(defvar allout-widgets-mode-inhibit nil
  "Inhibit `allout-widgets-mode' from activating widgets.

This also inhibits automatic adjustment of widgets to track allout outline
changes.

You can use this as a file local variable setting to disable allout widgets
enhancements in selected buffers while generally enabling widgets via
`allout-mode-widgets-init'.

In addition, you can call `allout-activate-widgets' and
`allout-deactivate-widgets' in buffers where this is set to
enable and disable widget enhancements, directly.")
;;;###autoload
(put 'allout-widgets-mode-inhibit 'safe-local-variable
     (if (fboundp 'booleanp) 'booleanp '(lambda (x) (member x '(t nil)))))
(make-variable-buffer-local 'allout-widgets-mode-inhibit)
;;;_   = allout-inhibit-body-modification-hook
(defvar allout-inhibit-body-modification-hook nil
  "Override de-escaping of text-prefixes in item bodies during specific changes.

This is used by `allout-buffer-modification-handler' to signal such changes
to `allout-body-modification-handler', and is always reset by
`allout-post-command-business'.")
(make-variable-buffer-local 'allout-inhibit-body-modification-hook)
;;;_   = allout-icons-cache
(defvar allout-icons-cache nil
  "Cache allout icon images, as an association list.

`allout-fetch-icon-image' uses this cache transparently, keying
images with lists containing the name of the icon directory \(as
found on the `load-path') and the icon name.

Set this variable to `nil' to empty the cache, and have it replenish from the
filesystem.")
;;;_   = allout-widgets-unset-inhibit-read-only
(defvar allout-widgets-unset-inhibit-read-only nil
  "Tell `allout-widgets-post-command-business' to unset `inhibit-read-only'.

Used by `allout-graphics-modification-handler'")
;;;_   = allout-widgets-reenable-before-change-handler
(defvar allout-widgets-reenable-before-change-handler nil
  "Tell `allout-widgets-post-command-business' to reequip the handler.

Necessary because the handler sometimes deliberately raises an
error, causing it to be disabled.")
;;;_  . State for hooks
;;;_   = allout-unresolved-body-mod-workroster
(defvar allout-unresolved-body-mod-workroster (make-hash-table :size 16)
  "List of body-overlays that did before-change business but not after-change.

See `allout-post-command-business' and `allout-body-modification-handler'.")
;;;_   = allout-structure-unruly-deletion-message
(defvar allout-structure-unruly-deletion-message
  "Unruly edit prevented --
To promote this item: \\[allout-shift-out]
To demote it: \\[allout-shift-in]
To delete it and offspring: \\[allout-kill-topic]
See \\[describe-mode] for more options."
  "Informative message presented on improper editing of outline structure.

The structure includes the guides lines, bullet, and bullet cue.")
;;;_   = allout-widgets-changes-record
(defvar allout-widgets-changes-record nil
  "Record outline changes for processing by post-command hook.

Entries on the list are lists whose first element is a symbol indicating
the change type and subsequent elements are data specific to that change
type.  Specifically:

 'exposure `allout-exposure-from' `allout-exposure-to' `allout-exposure-flag'

The changes are recorded in reverse order, with new values pushed
onto the front.")
(make-variable-buffer-local 'allout-widgets-changes-record)
;;;_   = allout-widgets-undo-exposure-record
(defvar allout-widgets-undo-exposure-record nil
  "Record outline undo traces for processing by post-command hook.

The changes are recorded in reverse order, with new values pushed
onto the front.")
(make-variable-buffer-local 'allout-widgets-undo-exposure-record)
;;;_   = allout-widgets-last-hook-error
(defvar allout-widgets-last-hook-error nil
  "String holding last error string, for debugging purposes.")
;;;_   = allout-widgets-adjust-message-length-threshold 100
(defvar allout-widgets-adjust-message-length-threshold 100
  "Display \"Adjusting widgets\" message above this number of pending changes."
 )
;;;_   = allout-widgets-adjust-message-size-threshold 10000
(defvar allout-widgets-adjust-message-size-threshold 10000
  "Display \"Adjusting widgets\" message above this size of pending changes."
 )
;;;_   = allout-doing-exposure-undo-processor nil
(defvar allout-undo-exposure-in-progress nil
  "State variable to signal recursion within
`allout-widgets-exposure-undo-processor'")
;;;_  . Widget-specific outline text format
;;;_   = allout-escaped-prefix-regexp
(defvar allout-escaped-prefix-regexp ""
  "*Regular expression for body text that would look like an item prefix if
not altered with an escape sequence.")
(make-variable-buffer-local 'allout-escaped-prefix-regexp)
;;;_  . Widget element formatting
;;;_   = allout-item-icon-keymap
(defvar allout-item-icon-keymap
  (let ((km (make-sparse-keymap)))
    (dolist (digit '("0" "1" "2" "3"
                     "4" "5" "6" "7" "8" "9"))
      (define-key km digit 'digit-argument))
    (define-key km "-" 'negative-argument)
    (define-key km [(return)] 'allout-tree-expand-command)
    (define-key km [(meta return)] 'allout-toggle-torso-command)
;;    (define-key km [(control o)] 'allout-toggle-preceeding-blank-line)
    (define-key km [(down-mouse-1)] 'allout-item-button-click)
    (define-key km [(down-mouse-2)] 'allout-toggle-torso-event-command)
    ;; Override underlying mouse-1 and mouse-2 bindings in icon territory:
    (define-key km [(mouse-1)] (lambda () (interactive) nil))
    (define-key km [(mouse-2)] (lambda () (interactive) nil))

    ;; Catchall, handles actual keybindings, dynamically doing keymap lookups:
    (define-key km [t] 'allout-item-icon-key-handler)

    km)
  "General tree-node key bindings.")
;;;_   = allout-item-body-keymap
(defvar allout-item-body-keymap
  (let ((km (make-sparse-keymap))
        (local-map (current-local-map)))
    (define-key km [(control return)] 'allout-tree-expand-command)
    (define-key km [(meta return)] 'allout-toggle-torso-command)
    ;; We need to reset this per buffer's mode; we do so in
    ;; allout-activate-widgets.
    (if local-map
        (set-keymap-parent km local-map))

    km)
  "General key bindings for the text content of outline items.")
(make-variable-buffer-local 'allout-item-body-keymap)
;;;_   = allout-body-span-category
(defvar allout-body-span-category nil
  "Symbol carrying allout body-text overlay properties.")
;;;_   = allout-cue-span-keymap
(defvar allout-cue-span-keymap
  (let ((km (make-sparse-keymap)))
    (set-keymap-parent km allout-item-icon-keymap)
    km)
  "Keymap used in the item cue area - the space between the icon and headline.")
;;;_   = allout-escapes-category
(defvar allout-escapes-category nil
  "Symbol for category of text property used to hide escapes of prefix-like
text in allout item bodies.")
;;;_   = allout-guides-category
(defvar allout-guides-category nil
  "Symbol carrying allout icon-guides overlay properties.")
;;;_   = allout-guides-span-category
(defvar allout-guides-span-category nil
  "Symbol carrying allout icon and guide lines overlay properties.")
;;;_   = allout-icon-span-category
(defvar allout-icon-span-category nil
  "Symbol carrying allout icon and guide lines overlay properties.")
;;;_   = allout-cue-span-category
(defvar allout-cue-span-category nil
  "Symbol carrying common properties of the space following the outline icon.

\(That space is used to convey selected cues indicating body qualities,
including things like:
 - encryption '~'
 - numbering '#'
 - indirect reference '@'
 - user-selected marks - '!', '?', '*', '>', ... - distinguishing the item.\)")
;;;_   = allout-span-to-category
(defvar allout-span-to-category
  '((:guides-span . allout-guides-span-category)
    (:cue-span . allout-cue-span-category)
    (:icon-span . allout-icon-span-category)
    (:body-span . allout-body-span-category))
  "Association list mapping span identifier to category identifier.")
;;;_   = allout-trailing-category
(defvar allout-trailing-category nil
  "Symbol carrying common properties of an overlay's trailing newline.")
;;;_  . Developer
(defvar allout-widgets-last-decoration-timing nil
  "Timing details for the last cooperative decoration action.

This is maintained when `allout-widgets-time-decoration-activity' is set.

The value is a list containing two elements:
  - the elapsed time as a number of seconds
  - the list of changes processed, a la `allout-widgets-changes-record'.

When active, the value is revised each time automatic decoration activity
happens in the buffer.")
(make-variable-buffer-local 'allout-widgets-last-decoration-timing)
;;;_ , mode hookup
;;;_  > allout-widgets-mode ()
(defun allout-widgets-mode ()
  "Toggle `allout-mode' use of graphical widgets and contextual settings.

To add widgets to allout operation, load allout-widgets in
addition to allout, and arrange for invocation of the function
`allout-mode-widgets-init', e.g., in your .emacs:

  (require 'allout)
  (require 'allout-widgets)
  (allout-mode-widgets-init)

Then, any allout outlines you visit will use widgets.

You can inhibit widget operation for particular allout outlines
by setting the variable `allout-widgets-mode-inhibit' non-nil in
that file's buffer, eg using an emacs *file local variables*
passages (described in the emacs user and elisp manuals)."

  (interactive)
  (if allout-mode
      (if (not allout-widgets-mode-inhibit)
          (allout-activate-widgets))
    (allout-deactivate-widgets)))
;;;_  > allout-mode-widgets-init
(defun allout-mode-widgets-init ()
  "Couple `allout-widgets-mode' activation with `allout-mode'"
  (add-hook 'allout-mode-hook 'allout-widgets-mode)
  (add-hook 'allout-mode-deactivate-hook 'allout-widgets-mode)
  t)
;;;_  > allout-activate-widgets
(defun allout-activate-widgets ()
  "Allout-mode extension, providing advanced allout features.

This is meant to run when allout-mode starts, via `allout-mode-widgets-init'."
  (interactive)
  (allout-add-resumptions
   ;; XXX user probably needs say in line-truncation/hscrolling - an option
   ;;     that abstracts mode.
   ;; truncate text lines to keep guide lines intact:
   '(truncate-lines t)
   ;; and enable autoscrolling to ease view of text
   '(auto-hscroll-mode t)
   '(line-move-ignore-fields t)
   '(widget-push-button-prefix "")
   '(widget-push-button-suffix "")
   ;; allout-escaped-prefix-regexp depends on allout-regex, which is
   ;; derived during allout-init.
   (list 'allout-escaped-prefix-regexp (concat "\\(\\\\\\)"
                                               "\\(" allout-regexp "\\)")))
  ;; Adjust settings prefix with comment-start, if necessary:
  (if (and comment-start (boundp allout-use-mode-specific-leader)
           allout-use-mode-specific-leader)
      (allout-add-resumptions
       (list 'allout-settings-prefix-regexp
             (concat comment-start comment-start comment-start
                     (default-value 'allout-settings-prefix-regexp)))))
  ;; allout-widgets-settings-sanitization-regexp depends on
  ;; allout-settings-prefix-regexp, must be set after.
  (allout-add-resumptions
   (list 'allout-widgets-settings-sanitization-regexp
         (concat
          ;; beginning w/a newline and ending at the end-of-line:
          "\\(\n"
          (default-value 'allout-settings-prefix-regexp)
          ".*$"
          ;; or beginning at start of buffer and ending at the newline:
          "\\)\\|\\(\\`"
          (default-value 'allout-settings-prefix-regexp)
          ".*\n"
          ;; or beginning at start of buffer and ending at the end-of-line:
          "\\)\\|\\(\\`"
          (default-value 'allout-settings-prefix-regexp)
          ".*$"
          "\\)"))
   (list 'allout-widgets-escapes-sanitization-regexp-pair
         (list (concat "\\(\n\\|\\`\\)"
                       allout-escaped-prefix-regexp
                       )
               ;; Include everything but the escape symbol.
               "\\1\\3"))
   (list 'allout-widgets-ciphertext-rejects
         (concat "\\(\n\\|\\`\\)" allout-settings-prefix-regexp))
   ;; leave settings and escapes in encrypted text - retains tid/iid, structure
   ;;   (list 'allout-encryption-plaintext-sanitization-regexps
   ;;         'allout-widgets-settings-sanitization-regexp
   ;;         'extend)
   ;;   (list 'allout-encryption-plaintext-sanitization-regexps
   ;;         'allout-widgets-escapes-sanitization-regexp-pair
   ;;         'extend)
   )

  ;; pgp armored text (radix-64) should not include backslashes, but then
  ;; the settings prefix could get changed, or other ciphertext might
  ;; eventually be used.
  (add-hook 'allout-encryption-ciphertext-rejection-regexps
            'allout-widgets-ciphertext-rejects
            nil 'local)

  (add-hook 'after-change-functions 'allout-widgets-after-change-handler
            nil t)

  (allout-setup-text-properties)
  (add-to-invisibility-spec '(allout-torso . t))
  (add-to-invisibility-spec 'allout-escapes)
  (add-to-invisibility-spec 'allout-settings)

  (if allout-widgets-use-alternate-ellipsis
      (let ((dt (make-display-table))
            (formed (cond ((integerp allout-widgets-use-alternate-ellipsis)
                           (vector allout-widgets-use-alternate-ellipsis))
                          ((stringp allout-widgets-use-alternate-ellipsis)
                           (vconcat allout-widgets-use-alternate-ellipsis))
                          (t (error "%s %s: %S"
                                    "Unrecognized"
                                    "allout-widgets-use-alternate-ellipsis"
                                    allout-widgets-use-alternate-ellipsis)))))
        (set-display-table-slot dt 'selective-display formed)
        (allout-add-resumptions (list 'buffer-display-table dt))))

  (when (not (assoc allout-settings-exposure-toggle-key
                    allout-keybindings-list))
    (push (list allout-settings-exposure-toggle-key
                'allout-toggle-settings-exposure)
          allout-keybindings-list)
    (setq allout-mode-map
          (produce-allout-mode-map allout-keybindings-list)))

  (if (current-local-map)
      (set-keymap-parent allout-item-body-keymap (current-local-map)))

  (local-set-key (concat allout-command-prefix
                         allout-settings-exposure-toggle-key)
                 'allout-toggle-settings-exposure)

  (setq allout-container-settings
        (cons (cons nil (current-buffer)) allout-root-settings))

  ;; XXX massage: block on-screen+ancestors, run-at-time chain other visibles

  (add-hook 'allout-exposure-change-hook
            'allout-widgets-exposure-change-recorder
            nil 'local)
  (add-hook 'allout-structure-added-hook 'allout-widgets-additions-recorder
            nil 'local)
  (add-hook 'allout-structure-deleted-hook 'allout-widgets-deletions-recorder
            nil 'local)
  (add-hook 'allout-structure-shifted-hook 'allout-widgets-shifts-recorder
            nil 'local)

  (add-hook 'before-change-functions 'allout-widgets-before-change-handler
            nil 'local)
  (add-hook 'post-command-hook 'allout-widgets-post-command-business
            nil 'local)
  (add-hook 'pre-command-hook 'allout-widgets-pre-command-business
            nil 'local)

  ;; init the widgets tally for debugging:
  (if (not allout-widgets-tally)
      (setq allout-widgets-tally (make-hash-table :test 'eq :weakness 'key)))
  ;; add tally count display to minor-mode-alist just after allout-mode entry:
  (if (not (assq 'allout-widgets-tally-count minor-mode-alist))
      (let ((after (memq (assq 'allout-mode minor-mode-alist)
                         minor-mode-alist)))
        (rplacd after (cons (list 'allout-widgets-tally-count
                                  'allout-widgets-tally-count)
                            (cdr after)))))
  (setq allout-widgets-tally-count (hash-table-count allout-widgets-tally))
  ;;; XXX recognize old-style outlines and offer to upgrade (noting that
  ;;;     upgrades will still be usable with old allout, but will have
  ;;;     stuff jammed in the bodies, etc.)
  )
;;;_  > allout-deactivate-widgets
(defun allout-deactivate-widgets ()
  "Allout-mode extension, providing advanced allout features.

This is meant to run when allout-mode starts, via `allout-mode-widgets-init'."

  ;; We rely on allout-mode's call to allout-do-resumptions during
  ;; deactivation to take care of our resumptions.

  (interactive)

  (let ((inhibit-read-only t)
        (was-modified (buffer-modified-p)))

    (remove-from-invisibility-spec '(allout-torso . t))
    (remove-from-invisibility-spec 'allout-escapes)
    (remove-text-properties (point-min) (point-max)
                            '(allout-trailing-category
                              allout-guides-span-category
                              allout-cue-span-category
                              allout-icon-span-category
                              allout-body-span-category))
    (remove-text-properties (point-min) (point-max) (list 'before-string nil)
                            (current-buffer))

    (remove-hook 'after-change-functions
                 'allout-widgets-after-change-handler 'local)

    (remove-hook 'allout-exposure-change-hook
                 'allout-widgets-exposure-change-recorder
                 'local)
    (remove-hook 'allout-structure-added-hook
                 'allout-widgets-additions-recorder
                 'local)
    (remove-hook 'allout-structure-deleted-hook
                 'allout-widgets-deletions-recorder
                 'local)
    (remove-hook 'allout-structure-shifted-hook
                 'allout-widgets-shifts-recorder
                 'local)
    (remove-hook 'before-change-functions 'allout-widgets-before-change-handler
                 'local)
    (remove-hook 'post-command-hook 'allout-widgets-post-command-business
                 'local)
    (remove-hook 'pre-command-hook 'allout-widgets-pre-command-business
                 'local)
    (set-buffer-modified-p was-modified)))
;;;_  > allout-setup-text-properties ()
(defun allout-setup-text-properties ()
  "Configure category and literal text properties."

  ;; XXX body - before-change, entry, keymap

  (setplist 'allout-guides-span-category nil)
  (put 'allout-guides-span-category
       'modification-hooks '(allout-graphics-modification-handler))
  (put 'allout-guides-span-category 'local-map allout-item-icon-keymap)
  (put 'allout-guides-span-category 'mouse-face widget-button-face)
  (put 'allout-guides-span-category 'field 'structure)
;;  (put 'allout-guides-span-category 'face 'widget-button)

  (setplist 'allout-icon-span-category
            (copy-list (symbol-plist 'allout-guides-span-category)))
  (put 'allout-icon-span-category 'field 'structure)

  ;; XXX for body text we're instead going to use the buffer-wide
  ;;     resources, like before/after-change-functions hooks and the
  ;;     buffer's key map.  that way we won't have to do painful provisions
  ;;     to fixup things after edits, catch outlier interstitial
  ;;     characters, like newline and empty lines after hidden subitems,
  ;;     etc.
  (setplist 'allout-body-span-category nil)
  (put 'allout-body-span-category 'evaporate t)
  (put 'allout-body-span-category 'local-map allout-item-body-keymap)
  ;;(put 'allout-body-span-category
  ;;     'modification-hooks '(allout-body-modification-handler))
  ;;(put 'allout-body-span-category 'field 'body)

  (setplist 'allout-cue-span-category nil)
  (put 'allout-cue-span-category 'evaporate t)
  (put 'allout-cue-span-category
       'modification-hooks '(allout-body-modification-handler))
  (put 'allout-cue-span-category 'local-map allout-cue-span-keymap)
  (put 'allout-cue-span-category 'mouse-face widget-button-face)
  (put 'allout-cue-span-category 'pointer 'arrow)
  (put 'allout-cue-span-category 'field 'structure)

  (setplist 'allout-settings-category nil)
  (put 'allout-settings-category 'evaporate t)
  (put 'allout-settings-category 'invisible 'allout-settings)
  (put 'allout-settings-category 'face 'allout-headline-continued-face)

  (setplist 'allout-trailing-category nil)
  (put 'allout-trailing-category 'evaporate t)
  (put 'allout-trailing-category 'local-map allout-item-body-keymap)

  (if (featurep 'xemacs)
      ;; XXX allout-body-before-change-handler not yet implemented
      (add-hook 'before-change-functions
                'allout-body-before-change-handler
                nil 'local))

  (put-text-property 0 (length allout-empty-body-text)
                     'face 'allout-empty-body-face
                     allout-empty-body-text)
  (put-text-property 0 (length allout-empty-body-text)
                     'help-echo "<empty>"
                     allout-empty-body-text)

  (setplist 'allout-escapes-category nil)
  (put 'allout-escapes-category 'invisible 'allout-escapes)
  (put 'allout-escapes-category 'evaporate t))
;;;_ , conversion
;;;_  . allout-convert-to-enhanced-format (&optional minimal)
(defun allout-convert-to-enhanced-format (&optional minimal)
  "Adjust outline text to format that enables advanced allout features.

Optional MINIMAL, when true, causes only the necessary changes
\(settings, including the unique identifier) to be made, leaving
hanging indentation alone.

Every item in a converted outline acquires subentries for
settings representing information about the item, including at
least an identifier which uniquely identifies the item.  These
entries are not presented by default in the current outline
version, but may show through in older versions.

The new style outlines include a provision for escaping lines
that begin with the item format prefix, so that the complete of
an item, or text that happens to have formatting features of
items, can be included in the bodies without becoming part of the
outline structure.

The new version of the mode no longer requires hanging indentation in
order for interior item body lines to line up with the header.  This
conversion recognizes such indentation and removes it.

The unique ids are the basis for situating items in multiple outline
locations, enabling intricate outline structures which better embody the
ways we use their information."
  ;; Measures:
  ;; - iid/tid.
  ;; - body decorations:
  ;;   - zero out indentation
  ;;   - escapes:
  ;;     - any literal lines that look like settings need escaping.
  ;;       (no old-style body lines can look like topic prefixes without
  ;;       being topic prefixes, so we don't need to look for them in this
  ;;       conversion.)
  ;;     - any literal lines that look like escaped prefixes or settings
  ;;       need additional escaping.  this is so unescaping (eg, for
  ;;       remote connections) can leave them unaltered, while being
  ;;       minimally intrusive, so as little escaping as possible is
  ;;       necessary.
  ;; - collapsed/expanded / brief/full cues, replacing allout-layout.
  ;; - encryption - what needs to be done?  hmm - separating body content from
  ;;   settings
  ;; - include distinctive bullets in cues change bullets to new
 )
;;;_ , settings context
;;;_  = allout-root-settings
;; (nil t) boilerplate association so
;;         (1) the association list is mutable
;;         (2) no potential name collisions with regular associations
;;          - it may be handy for that association to remain as the last one
;;          - it may be handy to have nil assoc for each node, to the widget
(defvar allout-root-settings '((nil . t))
  "Master settings holder, to be used as the parent of all containers.")
;;;_  = allout-container-settings
;; XXX this will probably be subsumed in the container item
(defvar allout-container-settings nil
  "Settings of the current outline's overarching container.

Every outline file or database/connection can be referenced as an item in
another outline \(or recursively, within itself).")
(make-variable-buffer-local 'allout-container-settings)
;;;_  = allout-container-item
(defvar allout-container-item-widget nil
  "A widget for the current outline's overarching container as an item.

The item has settings \(of the file/connection\) and maybe a body, but no
icon/bullet.")
(make-variable-buffer-local 'allout-container-item-widget)
;;;_  = allout-body-mod-settings-carrier
;; For settings stuff that's not yet used.
(defvar allout-body-mod-settings-carrier nil
  "Container for settings text during managed allout item body modifications.

Used by `allout-body-modification-handler'.")
(make-variable-buffer-local 'allout-body-mod-settings-carrier)
;;;_ , Hooks and hook helpers
;;;_  > allout-condition-undo-recording (inhibit body)
(defmacro allout-condition-undo-recording (inhibit body)
  "Evaluate BODY, inhibiting undo recording if \(first arg) INHIBIT is non-nil."
  `(if ,inhibit
       (let ((buffer-undo-list t)) ,body)
     ,body))
;;;_  . major command-loop business:
;;;_   > allout-widgets-pre-command-business (&optional recursing)
(defun allout-widgets-pre-command-business (&optional recursing)
  "Handle actions pending before allout-mode activity."
)
;;;_   > allout-widgets-post-command-business (&optional recursing)
(defun allout-widgets-post-command-business (&optional recursing)
  "Handle actions pending after any allout-mode commands.

Optional RECURSING is for internal use, to limit recursion."
  ;; - check changed text for nesting discontinuities and escape anything
  ;;   that's: (1) asterisks at bol or (2) excessively nested.
  (condition-case failure

      (when (allout-mode-p)

        (if allout-widgets-mode-inhibit

            (setq allout-widgets-changes-record nil)

          (if allout-widgets-unset-inhibit-read-only
              (setq inhibit-read-only nil
                    allout-widgets-unset-inhibit-read-only nil))

          (when allout-widgets-reenable-before-change-handler
            (add-hook 'before-change-functions
                      'allout-widgets-before-change-handler
                      nil 'local)
            (setq allout-widgets-reenable-before-change-handler nil))

          (when (or allout-widgets-undo-exposure-record
                    allout-widgets-changes-record)
            (let* ((debug-on-signal t)
                   (debug-on-error t)
                   ;; inhibit recording new undo records when processing
                   ;; effects of undo-exposure:
                   (debugger 'allout-widgets-hook-error-handler)
                   (adjusting-message " Adjusting widgets...")
                   (replaced-message (allout-widgets-adjusting-message
                                      adjusting-message))
                   (start-time (float-time)))

              (allout-condition-undo-recording
                 allout-widgets-undo-exposure-record
                  ;; inhibit undo recording iff undoing exposure stuff.
                  ;; XXX we might need to inhibit per respective
                  ;;     change-record, rather than assuming that some undo
                  ;;     activity during a command is all undo activity.
                 (progn
                   (allout-widgets-exposure-undo-processor)
                   (allout-widgets-changes-dispatcher)))

              (if allout-widgets-time-decoration-activity
                  (setq allout-widgets-last-decoration-timing
                        (list (- (float-time) start-time)
                              allout-widgets-changes-record)))

              (setq allout-widgets-changes-record nil)

              (if replaced-message
                  (if (stringp replaced-message)
                      (message replaced-message)
                    (message "")))))

          ;; Detect undecorated items, eg during isearch into previously
          ;; unexposed topics, and decorate "economically".  In sufficiently
          ;; elaborate topics some undecorated stuff may be exposed, but lag
          ;; from decorating everything on screen can impede activity too
          ;; much.  We constrain the recursion to avoid being trapped by
          ;; surprisingly undecoratable items.
          (when (and (not recursing)
                     (not (allout-current-decorated-p))
                     (or (not (equal (allout-depth) 0))
                         (not allout-container-item-widget)))
            (let ((buffer-undo-list t))
              (allout-widgets-exposure-change-recorder
               allout-recent-prefix-beginning allout-recent-prefix-end nil)
              (allout-widgets-post-command-business 'recursing)))

          ;; Detect and rectify fouled outline structure - decorated item
          ;; not at beginning of line.
          (let ((this-widget (or (widget-at (point))
                                 ;; XXX we really should be checking
                                 ;; across edited span, not just point
                                 ;; and point+1...
                                 (and (not (eq (point) (point-max)))
                                      (widget-at (1+ (point))))))
                inserted-at)
            (save-excursion
              (if (and this-widget
                       (goto-char (widget-get this-widget :from))
                       (not (bolp)))
                  (if (not
                       (condition-case err
                           (yes-or-no-p
                            (concat "Misplaced item won't be recognizable "
                                    " as part of outline - rectify? "))
                         (quit nil)))
                      (progn
                        (if (allout-hidden-p (max (1- (point)) 1))
                            (save-excursion
                              (goto-char (max (1- (point)) 1))
                              (allout-show-to-offshoot)))
                        (allout-undecorate-item this-widget))
                    ;; expose any hidden intervening items, so resulting
                    ;; position is clear:
                    (setq inserted-at (point))
                    (allout-unprotected (insert-before-markers "\n"))
                    (forward-char -1)
                    ;; ensure the inserted newline is visible:
                    (allout-flag-region inserted-at (1+ inserted-at) nil)
                    (allout-widgets-post-command-business 'recursing)
                    (message (concat "outline structure corrected - item"
                                     " moved to beginning of new line"))
                    ;; preserve cursor position in some cases:
                    (if (and inserted-at
                             (> (point) inserted-at))
                        (forward-char -1))))))

          (if allout-widgets-maintain-tally
              (setq allout-widgets-tally-count
                    (format ":%s" (hash-table-count allout-widgets-tally)))
            (if allout-widgets-tally-count
                (setq allout-widgets-tally (make-hash-table)
                      allout-widgets-tally-count nil)))
          ))

    (error
     ;; zero work list so we don't get stuck futily retrying.
     ;; error recording done by allout-widgets-hook-error-handler.
     (setq allout-widgets-changes-record nil))))
;;;_  . major change handlers:
;;;_   > allout-widgets-before-change-handler
(defun allout-widgets-before-change-handler (beg end)
  "Business to be done before changes in a widgetized allout outline."
  ;; protect against unruly edits to structure:
  (cond
   (undo-in-progress (when (eq (get-text-property beg 'category)
                               'allout-icon-span-category)
                       (save-excursion
                         (goto-char beg)
                         (let* ((item-widget (allout-get-item-widget)))
                           (if item-widget
                               (allout-widgets-exposure-undo-recorder
                                item-widget))))))
   (inhibit-read-only t)
   ((not (allout-mode-p)) t)
   ((not (text-property-any beg (if (equal end beg) (1+ beg) end)
                            'field 'structure))
    t)
   ((yes-or-no-p "Unstructured edit of outline structure - allow? ")
    (setq allout-widgets-unset-inhibit-read-only (not inhibit-read-only)
          inhibit-read-only t))
   (t
    ;; tell the allout-widgets-post-command-business to reestablish the hook:
    (setq allout-widgets-reenable-before-change-handler t)
    ;; and raise an error to prevent the edit (and disable the hook):
    (error
     (substitute-command-keys allout-structure-unruly-deletion-message)))))
;;;_   > allout-widgets-after-change-handler
(defun allout-widgets-after-change-handler (beg end prelength)
  "Reconcile what needs to be reconciled for allout widgets after edits."
  )
;;;_  > allout-current-decorated-p ()
(defun allout-current-decorated-p ()
  "True if the current item is not decorated"
  (save-excursion
    (if (allout-back-to-current-heading)
        (if (> allout-recent-depth 0)
            (and (allout-get-item-widget) t)
          allout-container-item-widget))))

;;;_  > allout-widgets-hook-error-handler
(defun allout-widgets-hook-error-handler (mode args)
  "Process errors which occurred in the course of command hook operation.

We store a backtrace of the error information in the variable,
`allout-widgets-last-hook-error', unset the error handlers, and
reraise the error, so that processing continues to the
encompassing condition-case."
  ;; first deconstruct special error environment so errors here propagate
  ;; to encompassing condition-case:
  (setq debugger 'debug
        debug-on-error nil
        debug-on-signal nil)
  (let* ((bt (with-output-to-string (backtrace)))
         (this "allout-widgets-hook-error-handler")
         (header
          (format "allout-widgets-last-hook-error stored, %s/%s %s %s"
                  this mode args
                  (format-time-string "%e-%b-%Y %r" (current-time)))))
    ;; post to *Messages* then immediately replace with more compact notice:
    (message (setq allout-widgets-last-hook-error
                   (format "%s:\n%s" header bt)))
    (message header) (sit-for allout-widgets-hook-error-post-time)
    ;; reraise the error, or one concerning this function if unexpected:
    (if (equal mode 'error)
        (apply 'signal args)
      (error "%s: unexpected mode, %s %s" this mode args))))
;;;_  > allout-widgets-changes-exceed-threshold-p ()
(defun allout-widgets-adjusting-message (message)
  "Post MESSAGE when pending are likely to make a big enough delay.

If posting of the MESSAGE is warranted and there already is a
`current-message' in the minibuffer, the MESSAGE is appended to
the current one, and the previously pending `current-message' is
returned for later posting on completion.

If posting of the MESSAGE is warranted, but no `current-message'
is pending, then t is returned to indicate that case.

If posting of the MESSAGE is not warranted, then nil is returned.

See `allout-widgets-adjust-message-length-threshold',
`allout-widgets-adjust-message-size-threshold' for message
posting threshold criteria."
  (if (or (> (length allout-widgets-changes-record)
             allout-widgets-adjust-message-length-threshold)
          ;; for size, use distance from start of first to end of last:
          (let ((min (point-max))
                (max 0)
                first second)
            (mapc (function (lambda (entry)
                              (if (eq :undone-exposure (car entry))
                                  nil
                                (setq first (cadr entry)
                                      second (caddr entry))
                                (if (< (min first second) min)
                                    (setq min (min first second)))
                                (if (> (max first second) max)
                                    (setq max (max first second))))))
                    allout-widgets-changes-record)
            (> (- max min) allout-widgets-adjust-message-size-threshold)))
      (let ((prior (current-message)))
        (message (if prior (concat prior " - " message) message))
        (or prior t))))
;;;_  > allout-widgets-changes-dispatcher ()
(defun allout-widgets-changes-dispatcher ()
  "Dispatch CHANGES-RECORD items to respective widgets change processors."

  (let* ((changes-record allout-widgets-changes-record)
         (changes-pending (and changes-record t))
         entry
         exposures
         additions
         deletions
         shifts)

    (when changes-pending
      (while changes-record
        (setq entry (pop changes-record))
        (case (car entry)
          (:exposed (push entry exposures))
          (:added (push entry additions))
          (:deleted (push entry deletions))
          (:shifted (push entry shifts))))

      (if exposures
        (allout-widgets-exposure-change-processor exposures))
      (if additions
          (allout-widgets-additions-processor additions))
      (if deletions
          (allout-widgets-deletions-processor deletions))
      (if shifts
          (allout-widgets-shifts-processor shifts)))))
;;;_  > allout-widgets-exposure-change-recorder (from to flag)
(defun allout-widgets-exposure-change-recorder (from to flag)
  "Record allout exposure changes for tracking during post-command processing.

Records changes in `allout-widgets-changes-record'."
  (push (list :exposed from to flag) allout-widgets-changes-record))
;;;_  > allout-widget-exposure-change-processor (changes)
(defun allout-widgets-exposure-change-processor (changes)
  "Widgetize and adjust item widgets tracking allout outline exposure changes.

Generally invoked via `allout-exposure-change-hook'."

  (let ((changes (sort changes (function (lambda (this next)
                                           (< (cadr this) (cadr next))))))
        ;; have to distinguish between concealing and epxosing so that, eg,
        ;; `allout-expose-topic's mix is handled properly.
        handled-expose
        handled-conceal
        covered
        deactivate-mark)

    (dolist (change changes)
      (let (handling
            (from (cadr change))
            bucket got
            (to (caddr change))
            (flag (cadddr change))
            parent)

        (if (< to from) (setq bucket to to from from bucket))

        ;; have we already handled exposure changes in this region?
        (setq handling (if flag 'handled-conceal 'handled-expose)
              got (allout-range-overlaps from to (symbol-value handling))
              covered (car got))
        (set handling (cadr got))

        (when (not covered)
          (save-excursion
            (goto-char from)
            (cond

             ;; collapsing:
             (flag (allout-beginning-of-current-line)
                   (let ((widget (allout-get-item-widget)))
                     (if (not widget)
                         (allout-get-or-create-item-widget)
                       (widget-apply widget :redecorate))))

             ;; expanding:
             (t
              (while (< (point) to)
                (allout-beginning-of-current-line)
                (setq parent (allout-get-item-widget))
                (if (not parent)
                    (setq parent (allout-get-or-create-item-widget))
                  (widget-apply parent :redecorate))
                (allout-next-visible-heading 1)
                (if (widget-get parent :has-subitems)
                    (allout-redecorate-visible-subtree parent))
                (if (> (point) to)
                    ;; subtree may be well beyond to - incorporate in ranges:
                    (setq handled-expose
                          (allout-range-overlaps from (point) handled-expose)
                          covered (car handled-expose)
                          handled-expose (cadr handled-expose)))
                (allout-next-visible-heading 1))))))))))

;;;_  > allout-widgets-additions-recorder (from to)
(defun allout-widgets-additions-recorder (from to)
  "Record allout item additions for tracking during post-command processing.

Intended for use on `allout-structure-added-hook'.

FROM point at the start of the first new item and TO is point at the start
of the last one.

Records changes in `allout-widgets-changes-record'."
  (push (list :added from to) allout-widgets-changes-record))
;;;_  > allout-widgets-additions-processor (changes)
(defun allout-widgets-additions-processor (changes)
  "Widgetize and adjust items tracking allout outline structure additions.

Dispatched by `allout-widgets-post-command-business' in response to
:added entries recorded by `allout-widgets-additions-recorder'."
  (save-excursion
    (let (handled
          covered)
      (dolist (change changes)
        (let ((from (cadr change))
              bucket
              (to (caddr change)))
          (if (< to from) (setq bucket to to from from bucket))
          ;; have we already handled exposure changes in this region?
          (setq handled (allout-range-overlaps from to handled)
                covered (car handled)
                handled (cadr handled))
          (when (not covered)
            (goto-char from)
            ;; Prior sibling and parent can both be affected.
            (if (allout-ascend)
                (allout-redecorate-visible-subtree
                 (allout-get-or-create-item-widget 'redecorate)))
            (if (< (point) from)
                (goto-char from))
            (while (and (< (point) to) (not (eobp)))
              (allout-beginning-of-current-line)
              (allout-redecorate-visible-subtree
               (allout-get-or-create-item-widget))
              (allout-next-visible-heading 1))
            (if (> (point) to)
                ;; subtree may be well beyond to - incorporate in ranges:
                (setq handled (allout-range-overlaps from (point) handled)
                      covered (car handled)
                      handled (cadr handled)))))))))

;;;_  > allout-widgets-deletions-recorder (depth from)
(defun allout-widgets-deletions-recorder (depth from)
  "Record allout item deletions for tracking during post-command processing.

Intended for use on `allout-structure-deleted-hook'.

DEPTH is the depth of the deleted subtree, and FROM is the point from which
the subtree was deleted.

Records changes in `allout-widgets-changes-record'."
  (push (list :deleted depth from) allout-widgets-changes-record))
;;;_  > allout-widgets-deletions-processor (changes)
(defun allout-widgets-deletions-processor (changes)
  "Adjust items tracking allout outline structure deletions.

Dispatched by `allout-widgets-post-command-business' in response to
:deleted entries recorded by `allout-widgets-deletions-recorder'."
  (save-excursion
    (dolist (change changes)
      (let ((depth (cadr change))
            (from (caddr change)))
        (goto-char from)
        (when (allout-previous-visible-heading 1)
          (if (> depth 1)
              (allout-ascend-to-depth (1- depth)))
          (allout-redecorate-visible-subtree
           (allout-get-or-create-item-widget 'redecorate)))))))

;;;_  > allout-widgets-shifts-recorder (shifted-amount at)
(defun allout-widgets-shifts-recorder (shifted-amount at)
  "Record outline subtree shifts for tracking during post-command processing.

Intended for use on `allout-structure-shifted-hook'.

SHIFTED-AMOUNT is the depth change and AT is the point at the start of the
subtree that's been shifted.

Records changes in `allout-widgets-changes-record'."
  (push (list :shifted shifted-amount at) allout-widgets-changes-record))
;;;_  > allout-widgets-shifts-processor (changes)
(defun allout-widgets-shifts-processor (changes)
  "Widgetize and adjust items tracking allout outline structure additions.

Dispatched by `allout-widgets-post-command-business' in response to
:shifted entries recorded by `allout-widgets-shifts-recorder'."
  (save-excursion
    (dolist (change changes)
      (goto-char (caddr change))
      (allout-ascend)
      (allout-redecorate-visible-subtree))))

;;;_  > allout-widgets-exposure-undo-recorder (widget from-state)
(defun allout-widgets-exposure-undo-recorder (widget)
  "Record outline exposure undo for tracking during post-command processing.

Intended for use by `allout-graphics-modification-handler'.

WIDGET is the widget being changed.

Records changes in `allout-widgets-changes-record'."
  ;; disregard the events if we're currently processing them.
  (if (not allout-undo-exposure-in-progress)
      (push widget allout-widgets-undo-exposure-record)))
;;;_  > allout-widgets-exposure-undo-processor ()
(defun allout-widgets-exposure-undo-processor ()
  "Adjust items tracking undo of allout outline structure exposure.

Dispatched by `allout-widgets-post-command-business' in response to
:undone-exposure entries recorded by `allout-widgets-exposure-undo-recorder'."
  (let* ((allout-undo-exposure-in-progress t)
         ;; inhibit undo recording while twiddling exposure to track undo:
         (widgets allout-widgets-undo-exposure-record)
         widget widget-start-marker widget-end-marker
         from-state icon-start-point to-state
         handled covered)
    (setq allout-widgets-undo-exposure-record nil)
    (save-excursion
      (dolist (widget widgets)
        (setq widget-start-marker (widget-get widget :from)
              widget-end-marker (widget-get widget :to)
              from-state (widget-get widget :icon-state)
              icon-start-point (widget-apply widget :actual-position
                                             :icon-start)
              to-state (get-text-property icon-start-point
                                          :icon-state))
        (setq handled (allout-range-overlaps widget-start-marker
                                             widget-end-marker
                                             handled)
              covered (car handled)
              handled (cadr handled))
        (when (not covered)
          (goto-char (widget-get widget :from))
          (when (not (allout-hidden-p))
            ;; adjust actual exposure to that of to-state viz from-state
            (cond ((and (eq to-state 'closed) (eq from-state 'opened))
                   (allout-hide-current-subtree)
                   (allout-decorate-item-and-context widget))
                  ((and (eq to-state 'opened) (eq from-state 'closed))
                   (save-excursion
                     (dolist
                         (expose-to (allout-chart-exposure-contour-by-icon))
                       (goto-char expose-to)
                       (allout-show-to-offshoot)))))))))))
;;;_  > allout-chart-exposure-contour-by-icon (&optional from-depth)
(defun allout-chart-exposure-contour-by-icon (&optional from-depth)
  "Return points of subtree items to which exposure should be extended.

The qualifying items are ones with a widget icon that is in the closed or
empty state, or items with undecorated subitems.

The resulting list of points is in reverse order.

Optional FROM-DEPTH is for internal use."
  ;; During internal recursion, we return a pair: (at-end . result)
  ;; Otherwise we just return the result.
  (let ((from-depth from-depth)
        start-point
        at-end level-depth
        this-widget
        got subgot)
    (if from-depth
        (setq level-depth (allout-depth))
      ;; at containing item:
      (setq start-point (point))
      (setq from-depth (allout-depth))
      (setq at-end (not (allout-next-heading))
            level-depth allout-recent-depth))

    ;; traverse the level, recursing on deeper levels:
    (while (and (not at-end)
                (> allout-recent-depth from-depth)
                (setq this-widget (allout-get-item-widget)))
      (if (< level-depth allout-recent-depth)
          ;; recurse:
          (progn
            (setq subgot (allout-chart-exposure-contour-by-icon level-depth)
                  at-end (car subgot)
                  subgot (cdr subgot))
            (if subgot (setq got (append subgot got))))
        ;; progress at this level:
        (when (memq (widget-get this-widget :icon-state) '(closed empty))
          (push (point) got)
          (allout-end-of-subtree))
        (setq at-end (not (allout-next-heading)))))

    ;; tailor result depending on whether or not we're a recursion:
    (if (not start-point)
        (cons at-end got)
      (goto-char start-point)
      got)))
;;;_  > allout-range-overlaps (from to ranges)
(defun allout-range-overlaps (from to ranges)
  "Return a pair indicating overlap of FROM and TO subtree range in RANGES.

First element of result indicates whether candadate range FROM, TO
overlapped any of the existing ranges.

Second element of result is a new version of RANGES incorporating the
candidate range with overlaps consolidated.

FROM and TO must be in increasing order, as must be the pairs in RANGES."
  ;; to append to the end: (rplacd next-to-last-cdr (list 'f))
  (let (new-ranges
        entry
        ;; the start of the range that includes the candidate from:
        included-from
        ;; the end of the range that includes the candidate to:
        included-to
        ;; the candidates were inserted:
        done)
    (while (and ranges (not done))
      (setq entry (car ranges)
            ranges (cdr ranges))

      (cond

       (included-from
        ;; some entry included the candidate from.
        (cond ((> (car entry) to)
               ;; current entry exceeds end of candidate range - done.
               (push (list included-from to) new-ranges)
               (push entry new-ranges)
               (setq included-to to
                     done t))
              ((>= (cadr entry) to)
               ;; current entry includes end of candidate range - done.
               (push (list included-from (cadr entry)) new-ranges)
               (setq included-to (cadr entry)
                     done t))
               ;; current entry contained in candidate range - ditch, continue:
              (t nil)))

       ((> (car entry) to)
        ;; current entry start exceeds candidate end - done, placed as new entry
        (push (list from to) new-ranges)
        (push entry new-ranges)
        (setq included-to to
              done t))

       ((>= (car entry) from)
        ;; current entry start is above candidate start, but not above
        ;; candidate end (by prior case).
        (setq included-from from)
        ;; now we have to check on whether this entry contains to, or continue:
        (when (>= (cadr entry) to)
          ;; current entry contains only candidate end - done:
          (push (list included-from (cadr entry)) new-ranges)
          (setq included-to (cadr entry)
                done t))
        ;; otherwise, we will continue to look for placement of candidate end.
        )

       ((>= (cadr entry) to)
        ;; current entry properly contains candidate range.
        (push entry new-ranges)
        (setq included-from (car entry)
              included-to (cadr entry)
              done t))

       ((>= (cadr entry) from)
        ;; current entry contains start of candidate range.
        (setq included-from (car entry)))

       (t
        ;; current entry is below the candidate range.
        (push entry new-ranges))))

    (cond ((and included-from included-to)
           ;; candidates placed.
           nil)
          ((not (or included-from included-to))
           ;; candidates found no place, must be at the end:
           (push (list from to) new-ranges))
          (included-from
           ;; candidate start placed but end not:
           (push (list included-from to) new-ranges))
          ;; might be included-to and not included-from, indicating new entry.
          )
    (setq new-ranges (nreverse new-ranges))
    (if ranges (setq new-ranges (append new-ranges ranges)))
    (list (if included-from t) new-ranges)))
;;;_  > allout-test-range-overlaps ()
(defun allout-test-range-overlaps ()
  "allout-range-overlaps unit tests."
  (let* (ranges
         got
         (try (lambda (from to)
                (setq got (allout-range-overlaps from to ranges))
                (setq ranges (cadr got))
                got)))
;;     ;; biggie:
;;     (setq ranges nil)
;;     ;; ~ .02 to .1 seconds for just repeated listing args instead of funcall
;;     ;; ~ 13 seconds for doing repeated funcall
;;     (message "time-trial: %s, resulting size %s"
;;              (time-trial
;;               '(let ((size 10000)
;;                      doing)
;;                  (random t)
;;                  (dotimes (count size)
;;                    (setq doing (random size))
;;                    (funcall try doing (+ doing (random 5)))
;;                    ;;(list doing (+ doing (random 5)))
;;                    )))
;;              (length ranges))
;;     (sit-for 2)

    ;; fresh:
    (setq ranges nil)
    (assert (equal (funcall try 3 5) '(nil ((3 5)))))
    ;; add range at end:
    (assert (equal (funcall try 10 12) '(nil ((3 5) (10 12)))))
    ;; add range at beginning:
    (assert (equal (funcall try 1 2) '(nil ((1 2) (3 5) (10 12)))))
    ;; insert range somewhere in the middle:
    (assert (equal (funcall try 7 9) '(nil ((1 2) (3 5) (7 9) (10 12)))))
    ;; consolidate some:
    (assert (equal (funcall try 5 8) '(t ((1 2) (3 9) (10 12)))))
    ;; add more:
    (assert (equal (funcall try 15 17) '(nil ((1 2) (3 9) (10 12) (15 17)))))
    ;; add more:
    (assert (equal (funcall try 20 22)
                   '(nil ((1 2) (3 9) (10 12) (15 17) (20 22)))))
    ;; encompass more:
    (assert (equal (funcall try 4 11) '(t ((1 2) (3 12) (15 17) (20 22)))))
    ;; encompass all:
    (assert (equal (funcall try 2 25) '(t ((1 25)))))

    ;; fresh slate:
    (setq ranges nil)
    (assert (equal (funcall try 20 25) '(nil ((20 25)))))
    (assert (equal (funcall try 30 35) '(nil ((20 25) (30 35)))))
    (assert (equal (funcall try 26 28) '(nil ((20 25) (26 28) (30 35)))))
    (assert (equal (funcall try 15 20) '(t ((15 25) (26 28) (30 35)))))
    (assert (equal (funcall try 10 30) '(t ((10 35)))))
    (assert (equal (funcall try 5 6) '(nil ((5 6) (10 35)))))
    (assert (equal (funcall try 2 100) '(t ((2 100)))))

    (setq ranges nil)
    ))
;;;_  > allout-widgetize-buffer (&optional doing)
(defun allout-widgetize-buffer (&optional doing)
  "EXAMPLE FUNCTION.  Widgetize items in buffer using allout-chart-subtree.

We economize by just focusing on the first of local-maximum depth siblings.

Optional DOING is for internal use - a chart of the current level, for
recursive operation."

  (interactive)
  (if (not doing)

      (save-excursion
        (goto-char (point-min))
        ;; Construct the chart by scanning the siblings:
        (dolist (top-level-sibling (allout-chart-siblings))
          (goto-char top-level-sibling)
          (let ((subchart (allout-chart-subtree)))
            (if subchart
                (allout-widgetize-buffer subchart)))))

    ;; save-excursion was done on recursion entry, not necessary here.
    (let (have-sublists)
      (dolist (sibling doing)
        (when (listp sibling)
          (setq have-sublists t)
          (allout-widgetize-buffer sibling)))
      (when (and (not have-sublists) (not (widget-at (car doing))))
        (goto-char (car doing))
        (allout-get-or-create-item-widget)))))

;;;_  : Change Classification - this may be necessary at least for pinpointing
;;;     updates.  it may or may not be worthwhile to enforce ruly changes, tho.
;;;_   > XXXallout-classify-change-span (beginning end)
(defun allout-classify-change-span (beginning end)
  "Identify classification of span as specified from BEGINNING to END.

We return a change-status symbol and a brief text description of the fault,
if unruly.

Change type is one of the following:

 - inbody - ok - the span is within or encompasses an item's body
 - items - ok - the span includes complete item\(s\), including their subtopics
 - unruly - not ok - allout cannot ensure the outline's integrity for this span

Descriptions of unruly deletions:
 - \"Incomplete deletion of single item's structure.\"
 - \"Incomplete deletion of a topic leaving subitem containment gaps.\"
"
  ;; focus on item around beginning (prime allout-recent-*)
  ;; - error if beginning is amidst prefix
  ;; - if beginning is at beginning of prefix:
  ;;   - record bounds of start item
  ;;   - end must be at some pre-next-item
  ;;   - if end is at end of current item's subtree, we're done
  ;;   - otherwise end must be beyond start-item's end-of-subtree
  ;;   - end must be end-of-subtree of some sibling of start-item

  ;; Containment discontinuities disallowed because rectification is ambiguous.
  ;; Mixture of item body and subsequent item alteration disallowed because
  ;; treatment of paste is ambiguous.

  )

;;;_: Item widget and constructors

;;;_ $ allout-item-widget
(define-widget 'allout-item-widget 'default
  "A widget presenting an allout outline item."

  'button        nil
  ;; widget-field-at respects this to get item if 'field is unused.
  ;; we don't use field to avoid collision with end-of-line, etc, on which
  ;; allout depends.
  'real-field    nil

  ;; data fields:

  ;; :settings - combo of :local-settings and parent item's :settings.
  :settings      nil
  ;; :local-settings - plist pairs representing this item's attributes.
  :local-settings nil
  ;; true when settings data structure is up-to-date w.r.t. item body text.
  :settings-assimilated nil

  ;; tailor the widget for a specific item
  :create         'allout-decorate-item-and-context
  :value-delete   'allout-item-widget-delete
  ;; register the inherited deleter, so delete function can run it too:
  :super-value-delete (widget-get (widget-convert 'default) :value-delete)
  ;; Not Yet Converted (from original, tree-widget stab)
  :expander       'allout-tree-event-dispatcher ; get children when nil :args
  :expander-p     'identity              ; always engage the :expander
  :action         'allout-tree-widget-action
  ;; :notify      "when item changes"

  ;; force decoration of item but not context, unless already done this tick:
  :redecorate     'allout-redecorate-item
  :last-decorated-tick nil
  ;; recognize the actual situation of the item's text:
  :parse-item           'allout-parse-item-at-point
  ;; recognize and incorporate the settings within the item's body:
  :parse-body-settings 'allout-parse-body-settings
  :assimilate-body-settings 'allout-assimilate-body-settings
  ;; decorate the entirety of the item, sans offspring:
  :decorate-item-span  'allout-decorate-item-span
  ;; decorate the various item elements:
  :decorate-guides     'allout-decorate-item-guides
  :decorate-icon       'allout-decorate-item-icon
  :decorate-cue        'allout-decorate-item-cue
  :decorate-body       'allout-decorate-item-body
  :actual-position     'allout-item-actual-position

  ;; Layout parameters:
  :is-container   nil   ; is this actually the encompassing file/connection?

  :from           nil                   ; item beginning - marker
  :to             nil                   ; item end - marker
  ;; XXX !!! does :from and :to being markers make span-overlays unnecessary?
  :span-overlay   nil   ; overlay by which actual postion is determined

  ;; also serves as guide-end:
  :icon-start     nil
  ;; also serves as cue-start:
  :icon-end       nil
  ;; also serves as cue-end:
  :body-start     nil
  :settings-start nil
  :body-end       nil
  :depth          nil
  :has-subitems   nil
  :was-has-subitems   'init
  :expanded       nil
  :was-expanded   'init
  :brief          nil
  :was-brief      'init

  :does-encrypt   nil           ; pending encryption when :is-encrypted false.
  :is-encrypted   nil

  ;; the actual location of the item text:
  :location       'allout-item-location

  :button-keymap  allout-item-icon-keymap ; XEmacs
  :keymap         allout-item-icon-keymap        ; Emacs

  ;; Element regions:
  :guides-span         nil
  :icon-span           nil
  :cue-span            nil
  :body-span           nil

  :torso-overlay  nil                 ; possibly remains empty - nil
  :toggle-torso  'allout-item-body-toggle-torso
  :body-brevity-p 'allout-body-brevity-p

  ;; :guide-column-flags indicate (in reverse order) whether or not the
  ;; item's ancestor at the depth corresponding to the column has a
  ;; subsequent sibling - ie, whether or not the corresponding column needs
  ;; a descender line to connect that ancestor with its sibling.
  :guide-column-flags  nil
  :was-guide-column-flags  'init

  ;; ie, has subitems:
  :populous-p    'allout-item-populous-p
  :help-echo     'allout-tree-widget-help-echo
  )
;;;_ > allout-new-item-widget ()
(defsubst allout-new-item-widget ()
  "create a new item widget, not yet situated anywhere."
  (if allout-widgets-maintain-tally
      ;; all the extra overhead is incurred only when doing the
      ;; maintenance, except the condition, which can't be avoided.
      (let ((widget (widget-convert 'allout-item-widget)))
        (puthash widget nil allout-widgets-tally)
        widget)
    (widget-convert 'allout-item-widget)))
;;;_ > allout-delete-item-widget ()
(defsubst allout-delete-item-widget (widget)
  "remove an item widget."
  (when allout-widgets-maintain-tally
    (remhash widget allout-widgets-tally))
  (widget-delete 'allout-item-widget))
;;;_ : Item decoration
;;;_  > allout-decorate-item-and-context (item-widget &optional redecorate
;;;                                                   blank-container parent)
(defun allout-decorate-item-and-context (item-widget &optional redecorate
                                                     blank-container parent)
  "Create or adjust widget decorations for ITEM-WIDGET and neighbors at point.

The neighbors include its siblings and parent.

ITEM-WIDGET can be a created or converted allout-item-widget.

If you're only trying to get or create a widget for an item, use
`allout-get-or-create-item-widget'.  If you have the item-widget, applying
:redecorate will do the right thing.

Optional BLANK-CONTAINER is for internal use.  It is used to fabricate a
container widget for an empty-bodied container, in the course of decorating
a proper \(non-container\) item which starts at the beginning of the file.

Optional REDECORATE causes redecoration of the item-widget and
its siblings, even if already decorated in this cycle of the command loop.

Optional PARENT, when provided, bypasses some navigation and computation
necessary to obtain the parent of the items being processed.

We return the item-widget corresponding to the item at point."

  (when (or redecorate
            (not (equal (widget-get item-widget :last-decorated-tick)
                        allout-command-counter)))
    (let* ((allout-inhibit-body-modification-hook t)
           (was-modified (buffer-modified-p))
           (was-point (point))
           prefix-start
           (is-container (or blank-container
                             (not (setq prefix-start (allout-goto-prefix)))
                             (< was-point prefix-start)))
           ;; steady-point (set in two steps) is reliable across parent
           ;; widget-creation.
           (steady-point (progn (if is-container (goto-char 1))
                                (point-marker)))
           (steady-point (progn (set-marker-insertion-type steady-point t)
                                steady-point))
           (parent (and (not is-container)
                        (allout-get-or-create-parent-widget)))
           parent-flags parent-depth
           successor-sibling
           body
           doing-item
           sub-item-widget
           depth
           reverse-siblings-chart)

      ;; At this point the parent is decorated and parent-flags indicate
      ;; its guide lines.  We will iterate over the siblings according to a
      ;; chart we create at the start, and going from last to first so we
      ;; don't have to worry about text displacement caused by widgetizing.

      (if is-container
          (progn (widget-put item-widget :is-container t)
                 (setq reverse-siblings-chart (list 1)))
        (goto-char (widget-apply parent :actual-position :from))
        (if (widget-get parent :is-container)
            ;; `allout-goto-prefix' will go to first non-container item:
            (allout-goto-prefix)
          (allout-next-heading))
        (setq depth (allout-recent-depth))
        (setq reverse-siblings-chart (list allout-recent-prefix-beginning))
        (while (allout-next-sibling)
          (push allout-recent-prefix-beginning reverse-siblings-chart)))

      (dolist (doing-at reverse-siblings-chart)
        (goto-char doing-at)
        (when allout-widgets-track-decoration
          (sit-for 0))

        (setq doing-item (if (= doing-at steady-point)
                             item-widget
                           (or (allout-get-item-widget)
                               (allout-new-item-widget))))

        (when (or redecorate (not (equal (widget-get doing-item
                                                     :last-decorated-tick)
                                         allout-command-counter)))
          (widget-apply doing-item :parse-item t blank-container)
          (widget-apply doing-item :decorate-item-span)

          (widget-apply doing-item :decorate-guides
                        parent (and successor-sibling t))
          (widget-apply doing-item :decorate-icon)
          (widget-apply doing-item :decorate-cue)
          (widget-apply doing-item :decorate-body)

          (widget-put doing-item :last-decorated-tick allout-command-counter))

        (setq successor-sibling doing-at))

      (set-buffer-modified-p was-modified)
      (goto-char steady-point)
      ;; must null the marker or the buffer gets clogged with impedence:
      (set-marker steady-point nil)

      item-widget)))
;;;_  > allout-redecorate-item (item)
(defun allout-redecorate-item (item-widget)
  "Resituate ITEM-WIDGET decorations, disregarding context.

Use this to redecorate only the item, when you know that it's
situation with respect to siblings, parent, and offspring is
unchanged from its last decoration.  Use
`allout-decorate-item-and-context' instead to reassess and adjust
relevent context, when suitable."
  (if (not (equal (widget-get item-widget :last-decorated-tick)
                  allout-command-counter))
      (let ((was-modified (buffer-modified-p)))
        (widget-apply item-widget :parse-item)
        (widget-apply item-widget :decorate-guides)
        (widget-apply item-widget :decorate-icon)
        (widget-apply item-widget :decorate-cue)
        (widget-apply item-widget :decorate-body)
        (set-buffer-modified-p was-modified))))
;;;_  > allout-redecorate-visible-subtree (&optional parent-widget
;;;                                                  depth chart)
(defun allout-redecorate-visible-subtree (&optional parent-widget depth chart)
  "Redecorate all visible items in subtree at point.

Optional PARENT-WIDGET is for optimization, when the parent widget is already available.

Optional DEPTH restricts the excursion depth of covered.

Optional CHART is for internal recursion, to carry a chart of the
target items.

Point is left at the last sibling in the visible subtree."
  ;; using a treatment that takes care of all the siblings on a level, we
  ;; only need apply it to the first sibling on the level, and we can
  ;; collect and pass the parent of the lower levels to recursive calls as
  ;; we go.
  (let ((parent-widget
         (if (and parent-widget (widget-apply parent-widget
                                              :actual-position :from))
             (progn (goto-char (widget-apply parent-widget
                                             :actual-position :from))
                    parent-widget)
           (let ((got (allout-get-item-widget)))
             (if got
                 (allout-decorate-item-and-context got 'redecorate)
               (allout-get-or-create-item-widget 'redecorate)))))
        (pending-chart (or chart (allout-chart-subtree nil 'visible)))
        item-widget
        previous-sibling-point
        previous-sibling
        recent-sibling-point)
    (setq pending-chart (nreverse pending-chart))
    (dolist (sibling-point pending-chart)
      (cond ((integerp sibling-point)
             (when (not previous-sibling-point)
               (goto-char sibling-point)
               (if (setq item-widget (allout-get-item-widget nil))
                   (allout-decorate-item-and-context item-widget 'redecorate
                                                     nil parent-widget)
                 (allout-get-or-create-item-widget)))
             (setq previous-sibling-point sibling-point
                   recent-sibling-point sibling-point))
            ((listp sibling-point)
             (if (or (not depth)
                     (> depth 1))
                 (allout-redecorate-visible-subtree
                  (if (not previous-sibling-point)
                      ;; containment discontinuity - sigh
                      parent-widget
                    (allout-get-or-create-item-widget 'redecorate))
                  (if depth (1- depth))
                  sibling-point)))))
    (if (and recent-sibling-point (< (point) recent-sibling-point))
        (goto-char recent-sibling-point))))
;;;_  > allout-parse-item-at-point (item-widget &optional at-beginning
;;;                                                       blank-container)
(defun allout-parse-item-at-point (item-widget &optional at-beginning
                                                         blank-container)
  "Set widget ITEM-WIDGET layout parameters per item-at-point's actual layout.

If optional AT-BEGINNING is t, then point is assumed to be at the start of
the item prefix.

If optional BLANK-CONTAINER is true, then the parameters of a container
which has an empty body are set.  \(Though the body is blank, the object
may have settings and subitems.\)"

  ;; Uncomment this sit-for to notice where decoration is happening:
;;  (sit-for .1)
  (let* ((depth (allout-depth))
         (depth (if blank-container 0 depth))
         (is-container (or blank-container (zerop depth)))

         (does-encrypt (and (not is-container)
                            (allout-encrypted-type-prefix)))
         (is-encrypted (and does-encrypt (allout-encrypted-topic-p)))
         (icon-end allout-recent-prefix-end)
         (icon-start (1- icon-end))
         body-start
         body-end
         settings-start
         has-subitems
         (contents-depth (1+ depth))
         )
    (widget-put item-widget :depth depth)
    (if is-container

        (progn
          (widget-put item-widget :from (allout-set-boundary-marker
                                         :from (point-min)
                                         (widget-get item-widget :from)))
          (widget-put item-widget :icon-end nil)
          (widget-put item-widget :icon-start nil)
          (setq body-start (widget-put item-widget :body-start 1)))

      ;; not container:

      (widget-put item-widget :from (allout-set-boundary-marker
                                     :from (if at-beginning
                                               (point)
                                             allout-recent-prefix-beginning)
                                     (widget-get item-widget :from)))
      (widget-put item-widget :icon-start icon-start)
      (widget-put item-widget :icon-end icon-end)
      (when does-encrypt
        (widget-put item-widget :does-encrypt t)
        (widget-put item-widget :is-encrypted is-encrypted))

      ;; cue area: include encrypted-cue "*" or numbered-bullets numbering
      ;; plus any trailling spaces.  we must insert a space if none present.
      (setq body-start icon-end)
      (cond (is-encrypted
             (setq body-start (1+ body-start)))
            ((and (equal (char-to-string (char-before icon-end))
                         allout-numbered-bullet)
                  (goto-char icon-end)
                  (looking-at "[0-9]+"))
             (setq body-start (match-end 0))))
      (if (equal (char-after body-start) ? )
          (setq body-start (1+ body-start)))
      (widget-put item-widget :body-start body-start)
      )

    ;; Both container and regular items:

    ;; :body-end (doesn't include a trailing blank line, if any) -
    (widget-put item-widget :body-end (setq body-end
                                            (if blank-container
                                                1
                                              (allout-end-of-entry))))
    (widget-apply item-widget :parse-body-settings body-start body-end)
    (if (not (widget-get item-widget :settings-assimilated))
        (widget-apply item-widget :assimilate-body-settings))

    (widget-put item-widget :to (allout-set-boundary-marker
                                 :to (if blank-container
                                         (point-min)
                                       (or (allout-pre-next-prefix)
                                           (goto-char (point-max))))
                                 (widget-get item-widget :to)))
    (widget-put item-widget :has-subitems
                (setq has-subitems
                      (and
                       ;; has a subsequent item:
                       (not (= body-end (point-max)))
                       ;; subsequent item is deeper:
                       (< depth (setq contents-depth (allout-recent-depth))))))
    ;; note :expanded - true if widget item's content is currently visible?
    (widget-put item-widget :expanded
                (and has-subitems
                     ;; subsequent item is or isn't visible:
                     (save-excursion
                       (goto-char allout-recent-prefix-beginning)
                       (not (allout-hidden-p)))))))
;;;_  > allout-set-boundary-marker (boundary position &optional current-marker)
(defun allout-set-boundary-marker (boundary position &optional current-marker)
  "Set or create item widget BOUNDARY type marker at POSITION.

Optional CURRENT-MARKER is the marker currently being used for
the boundary, if any.

BOUNDARY type is either :from or :to, determining the marker insertion type."
  (if (not position) (setq position (point)))
  (if current-marker
      (set-marker current-marker position)
    (let ((marker (make-marker)))
      ;; XXX dang - would like for :from boundary to advance after inserted
      ;;     text, but that would omit new header prefixes when allout
      ;;     relevels, etc.  this competes with ad-hoc edits, which would
      ;;     better be omitted
      (set-marker-insertion-type marker nil)
      (set-marker marker position))))
;;;_  > allout-parse-body-settings (item-widget body-start body-end)
(defun allout-parse-body-settings (item-widget body-start body-end)
  "Parse or reparse text body of ITEM-WIDGET, from BODY-START to BODY-END.

Return the point where the settings start, or nil if no settings."
  (let (settings-start)
    (goto-char body-end)
    (while (and (search-backward "\n" nil t)
                (goto-char (match-end 0))
                (>= (point) body-start)
                (looking-at allout-settings-prefix-regexp))
      (setq settings-start (point))
      (forward-char -1))
    (widget-put item-widget :settings-start settings-start)))
;;;_  > allout-assimilate-body-settings (item-widget)
(defun allout-assimilate-body-settings (item-widget)
  "Incorporate settings in ITEM-WIDGET body.

Depends on :settings-start and :body-end having been set, via
`allout-parse-body-settings'."
  (let ((settings-start (widget-get item-widget :settings-start))
        continuation
        name
        value
        more)
    ;; XXX enable this when settings are implemented:
    '(allout-clear-item-settings item-widget)
    (when settings-start
      (goto-char (widget-apply item-widget :actual-position :body-end))
      (while (and (search-backward "\n" nil t)
                  (goto-char (match-end 0))
                  (>= (point) settings-start))
        (cond ((looking-at (concat allout-settings-prefix-regexp
                                   allout-settings-continuation-appendage))
               (setq more (buffer-substring (match-end 0)
                                            (and (looking-at ".*$")
                                                 (match-end 0)))
                     continuation (if continuation
                                      (concat more "\n" continuation)
                                    more)))
              ((looking-at allout-settings-prefix-regexp)
               (setq name
                     ;; get the stuff between prefix and first space on line,
                     ;; or empty string if no space on line.
                     (buffer-substring (match-end 0)
                                       (if (looking-at "[^ \n]* ")
                                           (1- (match-end 0))
                                         (match-end 0))))
               (if (string= name "")
                                        ; ie, was no space on the line:
                   (setq name (buffer-substring (match-end 0)
                                                (progn (looking-at ".*$")
                                                       (match-end 0)))
                         ;; no space on line means an unset value (though
                         ;; pending continuation content could fill the
                         ;; value)
                         value nil)
                 ;; regular line - <prefix><name><space><value>:
                 (setq value (buffer-substring (match-end 0)
                                               (progn (looking-at ".*$")
                                                      (match-end 0)))))
               (when continuation
                 (setq value (concat (or value "") "\n" continuation))
                 (setq continuation nil))
               ;; XXX enable this when settings are implemented:
               '(allout-adjust-item-setting item-widget name value)))
        (forward-char -1)))
      (widget-put item-widget :settings-assimilated t)))
;;;_  > allout-decorate-item-span (item-widget)
(defun allout-decorate-item-span (item-widget)
  "Equip the item with a span, as an entirety.

This span is implemented so it can be used to detect displacement
of the widget in absolute terms, and provides an offset bias for
the various element spans."

  (if (and (widget-get item-widget :is-container)
           ;; the only case where the span could be empty.
           (eq (widget-get item-widget :from)
               (widget-get item-widget :to)))
      nil
    (allout-item-span item-widget
                      (widget-get item-widget :from)
                      (widget-get item-widget :to))))
;;;_  > allout-decorate-item-guides (item-widget
;;;                                  &optional parent-widget has-successor)
(defun allout-decorate-item-guides (item-widget
                                    &optional parent-widget has-successor)
  "Add ITEM-WIDGET guide icon-prefix descender and connector glyphs + overlay.

Optional arguments provide context for deriving the guides.  In
their absence, the current guide column flags are used.

Optional PARENT-WIDGET is the widget for the item's parent item.

Optional HAS-SUCCESSOR is true iff the item is followed by a sibling.

We also hide the header-prefix string.

Guides are established according to the item-widget's :guide-column-flags,
when different than :was-guide-column-flags.  Changing that property and
reapplying this method will rectify the glyphs."

  (when (not (widget-get item-widget :is-container))
    (let* ((depth (widget-get item-widget :depth))
           (parent-depth (and parent-widget
                              (widget-get parent-widget :depth)))
           (parent-flags (and parent-widget
                              (widget-get parent-widget :guide-column-flags)))
           (parent-flags-depth (length parent-flags))
           (extender-length (- depth (+ parent-flags-depth 2)))
           (flags (or (and (> depth 1)
                           parent-widget
                           (widget-put item-widget :guide-column-flags
                                       (append (list has-successor)
                                               (if (< 0 extender-length)
                                                   (make-list extender-length
                                                              '-))
                                               parent-flags)))
                      (widget-get item-widget :guide-column-flags)))
           (was-flags (widget-get item-widget :was-guide-column-flags))
           (guides-start (widget-get item-widget :from))
           (guides-end (widget-get item-widget :icon-start))
           (position guides-start)
           (increment (length allout-header-prefix))
           reverse-flags
           guide-name
           extenders paint-extenders
           (inhibit-read-only t))

      (when (not (equal was-flags flags))

        (setq reverse-flags (reverse flags))
        (while reverse-flags
          (setq guide-name
                (cond ((null (cdr reverse-flags))
                       (if (car reverse-flags)
                           'mid-connector
                         'end-connector))
                      ((eq (car reverse-flags) '-)
                       ;; accumulate extenders tally, to be painted on next
                       ;; non-extender flag, according to the flag type.
                       (setq extenders (1+ (or extenders 0)))
                       nil)
                      ((car reverse-flags)
                       'through-descender)
                      (t 'skip-descender)))
          (when guide-name
            (put-text-property position (setq position (+ position increment))
                               'display (allout-fetch-icon-image guide-name))
            (if (> increment 1) (setq increment 1))
            (when extenders
              ;; paint extenders after a connector, else leave spaces.
              (dotimes (i extenders)
                (put-text-property
                 position (setq position (1+ position))
                 'display (allout-fetch-icon-image
                           (if (memq guide-name '(mid-connector end-connector))
                               'extender-connector
                             'skip-descender))))
              (setq extenders nil)))
          (setq reverse-flags (cdr reverse-flags)))
        (widget-put item-widget :was-guide-column-flags flags))

      (allout-item-element-span-is item-widget :guides-span
                                guides-start guides-end))))
;;;_  > allout-decorate-item-icon (item-widget)
(defun allout-decorate-item-icon (item-widget)
  "Add item icon glyph and overlay to ITEM-WIDGET."

  (when (not (widget-get item-widget :is-container))
    (let* ((icon-start (widget-get item-widget :icon-start))
           (icon-end (widget-get item-widget :icon-end))
           (does-encrypt (widget-get item-widget :does-encrypt))
           (is-encrypted (and does-encrypt (widget-get item-widget
                                                       :is-encrypted)))
           (expanded (widget-get item-widget :expanded))
           (has-subitems (widget-get item-widget :has-subitems))
           (inhibit-read-only t)
           icon-state)

      (when (not (and (equal (widget-get item-widget :was-expanded) expanded)
                      (equal (widget-get item-widget :was-has-subitems)
                             has-subitems)
                      (equal (widget-get item-widget :was-does-encrypt)
                             does-encrypt)
                      (equal (widget-get item-widget :was-is-encrypted)
                             is-encrypted)))

        (setq icon-state
              (cond (does-encrypt (if is-encrypted
                                      'encrypted-locked
                                    'encrypted-unlocked))
                    (expanded 'opened)
                    (has-subitems 'closed)
                    (t 'empty)))
        (put-text-property icon-start (1+ icon-start)
                           'display (allout-fetch-icon-image icon-state))
        (widget-put item-widget :was-expanded expanded)
        (widget-put item-widget :was-has-subitems has-subitems)
        (widget-put item-widget :was-does-encrypt does-encrypt)
        (widget-put item-widget :was-is-encrypted is-encrypted)
        ;; preserve as a widget property to track last known:
        (widget-put item-widget :icon-state icon-state)
        ;; preserve as a text property to track undo:
        (put-text-property icon-start icon-end :icon-state icon-state))

      (allout-item-element-span-is item-widget :icon-span
                                icon-start icon-end))))
;;;_  > allout-decorate-item-cue (item-widget)
(defun allout-decorate-item-cue (item-widget)
  "Incorporate space between bullet icon and body to the ITEM-WIDGET.

That's the cue area.  This area is used for two purposes:

 - indicate the item's essential distinctions, including encryption status,
   numbering, distinctive bullets, and so forth.
 - indicating an empty item body or a non-empty item body that has an empty
   headline."

  (when (not (widget-get item-widget :is-container))
    (let* ((cue-start (widget-get item-widget :icon-end))
           (body-start (widget-get item-widget :body-start))
           (expanded (widget-get item-widget :expanded))
           (has-subitems (widget-get item-widget :has-subitems))
           (inhibit-read-only t))

      (allout-item-element-span-is item-widget :cue-span cue-start body-start)
      ;; prevent the 
      (put-text-property (1- body-start) body-start 'rear-nonsticky t))))
;;;_  > allout-decorate-item-body (item-widget &optional force)
(defun allout-decorate-item-body (item-widget &optional force)
  "Incorporate item body text as part the ITEM-WIDGET.

Optional FORCE means force reassignment of the region property."

  (let* ((allout-inhibit-body-modification-hook t)
         (body-start (widget-get item-widget :body-start))
         (body-end (widget-get item-widget :body-end))
         (settings-start (widget-get item-widget :settings-start))
         (body-text-end (or settings-start body-end))
         (inhibit-read-only t))

    (allout-item-element-span-is item-widget :body-span
                              body-start (min (1+ body-end) (point-max))
                              force)

    (if settings-start
        (put-text-property (max (1- settings-start) 1) body-end
                           'category 'allout-settings-category))))
;;;_  > allout-item-actual-position (item-widget field)
(defun allout-item-actual-position (item-widget field)
  "Return ITEM-WIDGET FIELD position taking item displacement into account."

  ;; XXX are span-overlays still necessary now that :from and :to are
  ;;     maintained as markers?  maybe for settings stuff?

  ;; The item's sub-element positions (:icon-end, :body-start, etc) are
  ;; accurate when the item is parsed, but some offsets from the start
  ;; drift with text added in the body.
  ;;
  ;; Rather than reparse an item with every change (inefficient), or derive
  ;; every position from a distinct field marker/overlay (prohibitive as
  ;; the number of items grows), we use the displacement tracking of the
  ;; :span-overlay's markers, against the registered :from or :body-end
  ;; (depending on whether the requested field value is before or after the
  ;; item body), to bias the registered values.
  ;;
  ;; This is not necessary/useful when the item is being decorated, because
  ;; that always must be preceeded by a fresh item parse.

  (if (not (memq field '(:body-end :settings-start)))
      (widget-get item-widget :from)

    (let* ((span-overlay (widget-get item-widget :span-overlay))
           (body-end-position (widget-get item-widget :body-end))
           (ref-marker-position (and span-overlay
                                     (overlay-end span-overlay)))
           (offset (and body-end-position span-overlay
                        (- (or ref-marker-position 0)
                           body-end-position))))
      (+ (widget-get item-widget field) (or offset 0)))))
;;;_ , Item undecoration
;;;_  . allout-undecorate-item (item-widget &optional no-expose)
(defun allout-undecorate-item (item-widget &optional no-expose)
  ;; XXX Very rough cut.  Eventually limit the extent to not include offspring,
  ;;     leaving them for recursive action?
  "Remove widget decorations from ITEM-WIDGET.

Any concealed content head lines and item body is exposed, unless
optional NO-EXPOSE is non-nil."
  (let ((from (widget-get item-widget :from))
        (to (widget-get item-widget :to))
        (text-properties-to-remove
         '(display nil
                   :icon-state nil
                   rear-nonsticky nil
                   category nil
                   button nil
                   field nil)))
    (if (not no-expose)
        (allout-flag-region from to nil))
    (allout-unprotected
     (remove-text-properties from to text-properties-to-remove))
    (remove-overlays from to 'button item-widget)
    (set-marker from nil)
    (set-marker to nil)
    (allout-delete-item-widget item-widget)
    )
  )
;;;_ : Item decoration support
;;;_  > allout-item-span (item-widget &optional start end)
(defun allout-item-span (item-widget &optional start end)
  "Return or register the location of an ITEM-WIDGET's actual START and END.

If START and END are not passed in, return either a dotted pair
of the current span, if established, or nil if not yet set.

When the START and END are passed, return the distance that the
start of the item moved.  We return 0 if the span was not
previously established or is not moved."
  (let ((overlay (widget-get item-widget :span-overlay))
        was-start was-end
        changed)
    (cond ((not overlay) (when start
                           (setq overlay (make-overlay start end nil t nil))
                           (overlay-put overlay 'button item-widget)
                           (widget-put item-widget :span-overlay overlay)
                           t))
          ;; report:
          ((not start) (cons (overlay-start overlay) (overlay-end overlay)))
          ;; move:
          ((or (not (equal (overlay-start overlay) start))
               (not (equal (overlay-end overlay) end)))
           (move-overlay overlay start end)
           t)
          ;; specified span already set:
          (t nil))))
;;;_  > allout-item-element-span-is (item-widget element
;;;                               &optional start end force)
(defun allout-item-element-span-is (item-widget element
                                             &optional start end force)
  "Return or register the location of the indicated ITEM-WIDGET ELEMENT.

ELEMENT is one of :guides-span, :icon-span, :cue-span, or :body-span.

When optional START is specified, optional END must also be.

START and END are the actual bounds of the region, if provided.

If START and END are not passed in, we return either a dotted
pair of the current span, if established, or nil if not yet set.

When the START and END are passed, we return t if the region
changed or nil if not.

Optional FORCE means force assignment of the region's text
property, even if it's already set."
  (let ((span (widget-get item-widget element)))
    (cond ((or (not span) force)
           (when start
             (widget-put item-widget element (cons start end))
             (put-text-property start end 'category
                                (cdr (assoc element
                                            allout-span-to-category)))
             t))
          ;; report:
          ((not start) span)
          ;; move if necessary:
          ((not (and (eq (car span) start)
                     (eq (cdr span) end)))
           (widget-put item-widget element span)
           t)
          ;; specified span already set:
          (t nil))))
;;;_ : Item widget retrieval (/ high-level creation):
;;;_  > allout-get-item-widget (&optional container)
(defun allout-get-item-widget (&optional container)
  "Return the widget for the item at point, or nil if no widget yet exists.

Point must be in the item before the start of the body, so we
don't get the existing one when we're in the process of creating
an item in the middle of another.

Optional CONTAINER is used to obtain the container item."
  (if (or container (zerop (allout-depth)))
      allout-container-item-widget
    ;; allout-recent-* are calibrated by (allout-depth) if we got here.
    (let* ((got (widget-at allout-recent-prefix-beginning))
           offset)
      (and got
           (listp got)
           (>= (point) (widget-apply got :actual-position :from))
           (<= (point) (widget-apply got :actual-position :body-start))
           got))))
;;;_  > allout-get-or-create-item-widget (&optional redecorate blank-container)
(defun allout-get-or-create-item-widget (&optional redecorate blank-container)
  "Return a widget for the item at point, creating the widget if necessary.

When creating a widget, we assume there has been a context change and decorate its siblings and parent, as well.

Optional BLANK-CONTAINER is for internal use, to fabricate a
container item with an empty body when the first proper
\(non-container\) item starts at the beginning of the file.

Optional REDECORATE, if non-nil, means to redecorate the widget
if it already exists."
  (let ((widget (allout-get-item-widget blank-container)))
    (cond (widget (if redecorate (allout-redecorate-item widget))
                  widget)
          ((or blank-container (zerop (allout-depth)))
           (or allout-container-item-widget
               (setq allout-container-item-widget
                     (allout-condition-undo-recording
                      t
                      (allout-decorate-item-and-context
                       (widget-convert 'allout-item-widget)
                       nil blank-container)))))
          ;; create a widget for a regular/non-container item:
          (t (allout-condition-undo-recording
              t
              (allout-decorate-item-and-context (widget-convert
                                                 'allout-item-widget)))))))
;;;_  > allout-get-or-create-parent-widget (&optional redecorate)
(defun allout-get-or-create-parent-widget (&optional redecorate)
  "Return widget for parent of item at point, decorating it if necessary.

We return the container widget if we're above the first proper item in the
file.

Optional REDECORATE, if non-nil, means to redecorate the widget if it
already exists.

Point will wind up positioned on the beginning of the parent or beginning
of the buffer."
  ;; use existing widget, if there, else establish it
  (if (or (bobp) (and (not (allout-ascend))
                      (looking-at allout-regexp)))
      (allout-get-or-create-item-widget redecorate 'blank-container)
    (allout-get-or-create-item-widget redecorate)))
;;;_ : X- Item ancillaries
;;;_  > allout-body-modification-handler (beg end)
(defun allout-body-modification-handler (beg end)
  "Do routine processing of body text before and after modification.

Operation is inhibited by `allout-inhibit-body-modification-handler'."

;; The primary duties are:
;;
;; - marking of escaped prefix-like text for delayed cleanup of escapes
;; - removal and replacement of the settings
;; - maintenance of beginning-of-line guide lines
;;
;; ?? Escapes removal \(before changes\) is not done when edits span multiple
;; items, recognizing that item structure is being preserved, including
;; escaping of item-prefix-like text within bodies.  See
;; `allout-before-modification-handler' and
;; `allout-inhibit-body-modification-handler'.
;;
;; Adds the overlay to the `allout-unresolved-body-mod-workhash' during
;; before-change operation, and removes from that list during after-change
;; operation.
  (cond (allout-inhibit-body-modification-hook nil)))
;;;_  > allout-graphics-modification-handler (beg end)
(defun allout-graphics-modification-handler (beg end)
  "Protect against incoherent deletion of decoration graphics.

Deletes allowed only when inhibit-read-only is t."
  (cond
   (undo-in-progress (when (eq (get-text-property beg 'category)
                               'allout-icon-span-category)
                       (save-excursion
                         (goto-char beg)
                         (let* ((item-widget (allout-get-item-widget)))
                           (if item-widget
                               (allout-widgets-exposure-undo-recorder
                                item-widget))))))
   (inhibit-read-only t)
   ((not (allout-mode-p)) t)
   ((yes-or-no-p "Unstructured edit of outline structure - allow? ")
    (setq allout-widgets-unset-inhibit-read-only (not inhibit-read-only)
          inhibit-read-only t))
   (t (error
       (substitute-command-keys allout-structure-unruly-deletion-message)))))
;;;_  > allout-item-icon-key-handler ()
(defun allout-item-icon-key-handler ()
  "Catchall handling of key bindings in item icon/cue hot-spots.

Applies `allout-hotspot-key-handler' and calls the result, if any, as an
interactive command."

  (interactive)
  (let* ((mapped-binding (allout-hotspot-key-handler)))
    (when mapped-binding
      (call-interactively mapped-binding))))
;;;_  > allout-item-widget-delete-handler (item)
(defun allout-item-widget-delete-handler (item)
  ;; XXX Widgets are deleted only on text deletion, not on collapse.
  ;;     So here may be where settings surgery would happen.
  "Do widget-specific cleanup and then standard business."
  (let (o)
    (when (setq o (widget-get item :span-overlay))
      (delete-overlay o) (widget-put item :span-overlay nil))
    (when (setq o (widget-get item :torso-overlay))
      (delete-overlay o) (widget-put item :torso-overlay nil)))
  (setq widget-field-list (delq item widget-field-list))
  (widget-apply item :super-value-delete))
;;;_  ? X-allout-body-mod-stash-settings-text (item settings-text)
(defun X-allout-body-mod-stash-settings-text (item settings-text)
  ;; XXX Not yet used.
  "Associate ITEM with SETTINGS-TEXT, for later recovery.

See `allout-body-mod-get-stashed-settings-text' for recovery."
  (setq allout-body-mod-settings-carrier
        (cons (cons item settings-text) allout-body-mod-settings-carrier)))
;;;_  ? X-allout-body-mod-get-stashed-settings-text (item)
(defun X-allout-body-mod-get-stashed-settings-text (item)
  ;; XXX Not yet used.
  "Return settings-text associated ITEM, removing the association.

`allout-body-mod-stash-settings-text' creates the association."
  (let ((got (assq item allout-body-mod-settings-carrier)))
    (when got
        (setq allout-body-mod-settings-carrier
              (assq-delete-all item allout-body-mod-settings-carrier))
        (cdr got))))
;;;_  >! X-allout-before-modification-handler (beg end)
(defun X-allout-before-modification-handler (beg end)
  "Attend to arbitrary text mods, preparing for special processing if needed."

;; Inhibit changes when they incoherently encompass items, unless
;; `allout-allow-unruly-edits' is true.
;; Ensure that body overlays are in place to handle intra-body changes.
;; Inhibit intra-body handling when changes coherently encompass items.
;; When adding before changes, invoke their handlers."
)
;;;_  >! X-allout-after-modification-handler (beg end)
(defun X-allout-after-modification-handler (beg end)
  "Take care of allout-item post-change business."
  ;; Implement:
  ;; - check kill ring for new entries, and if marked as full items, restore
  ;;   settings-text from stash.
 )
;;;_  . X-allout-item-contents-changed (tree)
(defun X-allout-item-contents-changed (tree)
  "Register that tree's expansion needs to be recomputed."
  (widget-put tree :args nil)
  (error "allout-tree-contents-changed - not yet fully implemented")
  )
;;;_  . X-allout-item-after-toggle-handler (tree)
(defun X-allout-item-after-toggle-handler (tree)
  "Handle incidental business when toggling subtree exposure."
  (let ((event-type (if (stringp last-command-event)
                        'string
                      (event-basic-type last-command-event))))
    (if (not (widget-get tree :open))
        (if (and (or (equal 'mouse-2 event-type)
                     current-prefix-arg)
                 (widget-get tree :args))
            ;; Unmark :open offspring, so they aren't inherently
            ;; expanded when this node is next expanded:
            (allout-collapse-opened (widget-get tree :args))))))
;;;_  > X-allout-ensure-overlay-position (overlay start end)
(defun X-allout-ensure-overlay-position (overlay start end)
  "Move OVERLAY if its position has START, END has changed."
  ;; Start and end is reported as nil for overlays that were set with equal
  ;; start and end.  By defaulting those values to the *opposite* setting,
  ;; we do the right thing in all cases.
  (if (not (and (= (or (overlay-start overlay) end) start)
                (= (or (overlay-end overlay) start) end)))
      (move-overlay overlay start end)))

;;;_ : Item widget exposure
;;;_  . allout-tree-widget-action (tree &optional event)
;;; X
'(defun allout-tree-widget-action (tree &optional event)
  "Adjust TREE widget's expansion as its :action.

Normally, we toggle expansion of the TREE.

If there is a positive prefix argument, we extend the expansion to the depth
indicated by the prefix argument.

The optional EVENT argument is ignored."
  (let* ((positive-prefix-arg (and current-prefix-arg
                                   (< 0 (prefix-numeric-value
                                         current-prefix-arg))))
         (open (not (widget-get tree :open)))
         (collapse (and (not positive-prefix-arg) (not open))))
    (if collapse
        ;; Before collapsing, save children vals for recovery on next open.
        (tree-widget-children-value-save tree))
    (widget-put tree :open (not collapse))
    ;; i set the value because that's what `tree-widget-action' does.
    (widget-value-set tree (not collapse))
    (run-hook-with-args 'tree-widget-after-toggle-functions tree)))
;;;_  . allout-item-widget-action (tree &optional event)
;;; X
'(defun allout-item-widget-action (tree &optional event)
  "Adjust TREE widget's expansion as its :action.

Normally, we toggle expansion of the TREE.

If there is a positive prefix argument, we extend the expansion to the depth
indicated by the prefix argument.

The optional EVENT argument is ignored."
  (let* ((positive-prefix-arg (and current-prefix-arg
                                   (< 0 (prefix-numeric-value
                                         current-prefix-arg))))
         (open (not (widget-get tree :open)))
         (collapse (and (not positive-prefix-arg) (not open))))
    (if collapse
        ;; Before collapsing, save children vals for recovery on next open.
        (tree-widget-children-value-save tree))
    (widget-put tree :open (not collapse))
    ;; i set the value because that's what `tree-widget-action' does.
    (widget-value-set tree (not collapse))
    (run-hook-with-args 'tree-widget-after-toggle-functions tree)))
;;;_  . allout-tree-expander (item depth stringent)
;;; X
(defun allout-tree-expander (item depth stringent)
;; XXX Use allout-show-children instead
;;     - exposure-change hook will widgetize
;;     - but respect subitem's open settings to cascade (unless stringent)

  "Return a list of ITEM's immediate children, including those to depth.

We return a list of item records for the immediate offspring.

DEPTH dictates the number of levels to delve: 1 if nil, the indicated
number if an integer, or to maximum depth if t.

STRINGENT means close stuff below depth that was left open."

  (let* ((subitems (widget-get item :args))
         (subitems-text (if (not subitems)
                            (widget-get item :subitems-text)))
         ;; preprocess depth to make recursion decision trivial:
         (deeper (cond ((or (not depth)(and (integerp depth) (<= depth 1)))
                        nil)
                       ((integerp depth) (if (<= depth 1) nil (1- depth)))
                       ((eq depth t) depth)
                       (t (error
                           "Depth must be integer, t, or nil, not %s (%s)"
                           (type-of depth) depth))))
         )
    (if (and subitems-text (not (string= subitems-text "")))
        ;; Turn subitems-text into subitems:
        (setq subitems
              (mapcar
               (lambda (item-record)
                 (let* ((body (car item-record))
                        (do-fallback
                         allout-headline-fallback-second-body-line)
                        (newline-at (string-match "\n" body))
                        (first-line (substring body 0 newline-at))
                        (headline (or (if (not (string= first-line ""))
                                          first-line
                                        (if (and newline-at do-fallback)
                                            (substring body (1+ newline-at)
                                                       (string-match
                                                        "\n" body
                                                        (1+ newline-at))))))))
                   (cons 'allout-tree-widget
                         (list :body body
                               ;; :tag headline
                               :subitems-text (cadr item-record)
                               :settings (caddr item-record)
                               ))))
;;;X               (allout-parse-subitems-text subitems-text)
               )))
    (if deeper
        ;; Recurse, populating subitem on subitems:
        (mapc (lambda (subitem)
                (widget-put subitem :open t)
                (when (or (widget-get subitem :args)
                          (and (widget-get subitem :subitems-text)
                               (not (string= (widget-get subitem
                                                         :subitems-text)
                                             ""))))
                  (widget-put subitem
                              :args (allout-tree-expander subitem
                                                          deeper
                                                          stringent))))
                subitems)
      ;; We're at the depth limit - enforce stringency:
      (if stringent
          (allout-collapse-opened subitems)))
    subitems))
;;;_  . allout-item-expander (item depth stringent)
;;; X
(defun allout-item-expander (item depth stringent)
;; XXX Use allout-show-children instead
;;     - exposure-change hook will widgetize
;;     - but respect subitem's open settings to cascade (unless stringent)

  "Return a list of ITEM's immediate children, including those to depth.

We return a list of item records for the immediate offspring.

DEPTH dictates the number of levels to delve: 1 if nil, the indicated
number if an integer, or to maximum depth if t.

STRINGENT means close stuff below depth that was left open."

  (let* ((subitems (widget-get item :args))
         (subitems-text (if (not subitems)
                            (widget-get item :subitems-text)))
         ;; preprocess depth to make recursion decision trivial:
         (deeper (cond ((or (not depth)(and (integerp depth) (<= depth 1)))
                        nil)
                       ((integerp depth) (if (<= depth 1) nil (1- depth)))
                       ((eq depth t) depth)
                       (t (error
                           "Depth must be integer, t, or nil, not %s (%s)"
                           (type-of depth) depth))))
         )
    (if (and subitems-text (not (string= subitems-text "")))
        ;; Turn subitems-text into subitems:
        (setq subitems
              (mapcar
               (lambda (item-record)
                 (let* ((body (car item-record))
                        (do-fallback
                         allout-headline-fallback-second-body-line)
                        (newline-at (string-match "\n" body))
                        (first-line (substring body 0 newline-at))
                        (headline (if (not (string= first-line ""))
                                      first-line
                                    (if (and newline-at do-fallback)
                                        (substring body (1+ newline-at)
                                                   (string-match
                                                    "\n" body
                                                    (1+ newline-at)))))))
                   (cons 'allout-tree-widget
                         (list :body body
                               ;; :tag headline
                               :subitems-text (cadr item-record)
                               :settings (caddr item-record)
                               ))))
;;;X               (allout-parse-subitems-text subitems-text)
	       )))
    (if deeper
        ;; Recurse, populating subitem on subitems:
        (mapc (lambda (subitem)
                (widget-put subitem :open t)
                (when (or (widget-get subitem :args)
                          (and (widget-get subitem :subitems-text)
                               (not (string= (widget-get subitem
                                                         :subitems-text)
                                             ""))))
                  (widget-put subitem
                              :args (allout-tree-expander subitem
                                                          deeper
                                                          stringent))))
                subitems)
      ;; We're at the depth limit - enforce stringency:
      (if stringent
          (allout-collapse-opened subitems)))
    subitems))
;;;_  . allout-collapse-opened (items)
;;; X
(defun allout-collapse-opened (items)
  "Adjust ITEMS and their offspring to lose prior :open status."
  (dolist (item items)
    (when (widget-get item :open)
      (widget-put item :open nil)
      (let ((subitems (widget-get item :args)))
        (if subitems (allout-collapse-opened subitems))))))
;;;_  . allout-item-event-dispatcher (item)
;;; X
(defun allout-item-event-dispatcher (item &optional stringent)
  "Dispatch allout outline ITEM manipulation depending on type of click.

If optional STRINGENT is true, ensure that offspring beyond the indicated
depth are not left open, ie are closed if they are currently open."
;;             modifiers (event-modifiers event)
;;             movement (mouse-movement-p event)
  (let* ((prefix-arg-value (and current-prefix-arg
                                (prog1 (prefix-numeric-value current-prefix-arg)
                                  ;; this routine is repeatedly invoked due
                                  ;; some re-callback in the widget-creation
                                  ;; process, so we must null the prefix arg
                                  ;; to prevent geometric exaggeration of the
                                  ;; effect - !
                                  (setq current-prefix-arg nil)))))
    (allout-tree-expander item
                ;; depth:
                (and prefix-arg-value (abs prefix-arg-value))
                (or stringent
                    (and prefix-arg-value (> 0 prefix-arg-value))
                    (and (not (stringp last-command-event))
                         (equal 'mouse-2 (event-basic-type
                                          last-command-event)))))))
;;;_  . allout-toggle-torso-command ()
;;; X
(defun allout-toggle-torso-command ()
  "Toggle concealment of item body lines following headline.

This is for binding to key strokes.  Use
`allout-toggle-torso-event-command' for mouse bindings."
  (interactive)
  (widget-apply (widget-at (point)) :toggle-torso))
;;;_ : Item widget predicate and ancillary methods
;;;_  > allout-item-populous-p (item)
;;; X
(defun allout-item-populous-p (item)
  "True if ITEM has any subitems."
  (or (widget-get item :args)
      (let ((subitems-text (widget-get item :subitems-text)))
        (or (not subitems-text)
            (not (string= subitems-text ""))))))
;;;_  > allout-body-brevity-p (item)
;;; X
(defun allout-body-brevity-p (item)
  "True if allout outline ITEM has concealed trailing body lines."
  (eq (overlay-get (widget-get item :field-overlay) 'face)
      'allout-headline-continued-face))
;;;_  > allout-item-widget-help-echo (item)
;;; X
(defun allout-item-widget-help-echo (item)
  "Return the current mouse-over string for the allout outline ITEM."
  (let ((left
         (format "Left click or CR to %s"
                 (if (widget-apply item :populous-p)
                     (if (widget-get item :open)
                         "collapse"
                       "expand")
                   "expand/collapse (but this item has no subitems)")))
        (middle "Middle or Control-CR to reveal/conceal body")
        ;; XXX menu not yet implemented:
        (right "Right for menu of more actions"))
    (concat left ";\n" middle ";\n" right)))
;;;_  > allout-item-body-toggle-torso (item &optional only)
;;; X
(defun allout-item-body-toggle-torso (item &optional only)
  "Adjust item body text to conceal or expose lines following the headline.

When there are no following (torso) lines, nothing is changed.

Optional ONLY can be 'open or 'close, in which case the toggle happens
only if the body is currently in the opposite state."

  ;; Required invariants:
  ;;   - item's :parent == tree
  ;;   - item's :field-overlay and :cue-overlay are properly situated.

  ;; XXX If configured, on empty first line show second if non-empty
  ;; XXX Prefix torso lines with appropriate guide lines
  ;; XXX handle escaped literal bullet content (leading '.', '*')

  (let* ((body-text (widget-get (widget-apply item :get-parent) :body))
         (first-newline-at (string-match "\n" body-text))
         (cue-overlay (widget-get item :cue-overlay))
         body-overlay torso-overlay)

    (if (not first-newline-at)

        (if (equal body-text "")
            (progn
              (overlay-put cue-overlay
                           'after-string allout-empty-body-text)
              (overlay-put cue-overlay 'help-echo "<empty body>"))
          (when (overlay-get cue-overlay 'after-string)
            (overlay-put cue-overlay 'face 'default)
            (overlay-put cue-overlay 'after-string nil)
            (overlay-put cue-overlay 'help-echo "")))

      (setq body-overlay (widget-get item :field-overlay))
      ;; torso-overlay may be absent:
      (setq torso-overlay (widget-get item :torso-overlay))
      (setq cue-overlay (widget-get item :cue-overlay))
      (overlay-put cue-overlay 'face 'allout-headline-continued-face)

      (if (and (widget-apply item :body-brevity-p)
               (not (eq only 'close)))
          ;; torso concealed:
          (when torso-overlay
            ;; expose it:
            (overlay-put body-overlay 'face 'default)
            (overlay-put torso-overlay 'invisible nil)
            (widget-put item :torso-overlay nil))
        ;; torso exposed:
        (when (not (eq only 'open))
          ;; conceal it:
          (overlay-put body-overlay 'face 'allout-headline-continued-face)
          (overlay-put body-overlay 'help-echo body-text)
          (if torso-overlay
              (move-overlay torso-overlay
                            (+ (widget-get item :body-start) first-newline-at)
                            (widget-get item :body-end))
            (setq torso-overlay (make-overlay (+ (widget-get item :body-start)
                                                 first-newline-at)
                                              (widget-get item :body-end)
                                              nil nil nil))
            (overlay-put torso-overlay 'evaporate t)
            (widget-put item :torso-overlay torso-overlay))
          (overlay-put torso-overlay 'invisible 'allout-torso)
          (when (zerop first-newline-at)
            (setq cue-overlay (widget-get item :cue-overlay))
            (overlay-put cue-overlay 'font
                   'allout-empty-headline-face)))))
    ))
;;;_  > allout-toggle-torso-event-command ()
;;; X
(defun allout-toggle-torso-event-command (start-event)
  "Toggle concealment of item body lines following headline.

This is for binding to mouse events.  Use `allout-toggle-torso-command' for
  key strokes."
  (interactive "e")
    (select-window (posn-window (event-start start-event)))
    (goto-char (posn-point (event-start start-event)))
    (allout-toggle-torso-command))
;;;_  > allout-tree-expand-command ()
;;; X
(defun allout-tree-expand-command ()
  "Toggle expansion of subtree.

This is for binding to key strokes.  Use `allout-item-button-click' for
mouse events."
  (interactive)
  '(allout-tree-widget-action (widget-apply (widget-at (point)) :get-parent)))
;;;_  > allout-item-button-click ()
;;; X
(defun allout-item-button-click (start-event)
  "Relocate point to mouse, then invoke tree-widget-button-click."
  (interactive "e")
    (select-window (posn-window (event-start start-event)))
    '(tree-widget-button-click start-event)
    (goto-char (posn-point (event-start start-event))))

;;;_: Status
;;;_ , allout-item-location (item-widget)
(defun allout-item-location (item-widget)
  "Location of the start of the item's text."
  (overlay-start (widget-get item-widget :span-overlay)))

;;;_: Editing
;;; X
;;;_ > allout-toggle-preceeding-blank-line ()
(defun allout-toggle-preceeding-blank-line ()
  "Add an empty line before this item, or remove it if one is already present.

This command toggles rather than just adding blanks because more
than a single blank line between items becomes trailling blanks
in the immediately preceeding item.  It would be poor usability
design to have one item's commands affect a separate item in that
manner."
  (interactive)
  (save-excursion
    (allout-back-to-current-heading)
    (if (and (< (point-min) (point)) (= (char-before (1- (point))) ?\n))
        (delete-region (1- (point))(point))
      (insert "\n"))))

;;;_: Icon management
;;;_ > allout-fetch-icon-image (name)
(defun allout-fetch-icon-image (name)
  "Fetch allout icon for symbol NAME.

We use a caching strategy, so the caller doesn't need to do so."
  (let* ((types allout-icon-types)
         (use-dir (if (equal (frame-parameter nil 'background-mode) 'light)
                      allout-icons-light-subdir
                    allout-icons-dark-subdir))
         (key (list name use-dir))
         (got (assoc key allout-icons-cache)))
    (if got
        ;; display system shows only first of subsequent adjacent
        ;; `eq'-identical repeats - use copies to avoid this problem.
        (copy-list (cadr got))
      (while (and types (not got))
        (setq got
              (find-image (list
                           (append (list :type (car types)
                                         :file (concat use-dir
                                                       (symbol-name name)
                                                       "." (symbol-name
                                                            (car types))))
                                   (if (featurep 'xemacs)
                                       allout-item-image-properties-xemacs
                                     allout-item-image-properties-emacs)
                                   ))))
        (setq types (cdr types)))
      (if got
          (push (list key got) allout-icons-cache))
      got)))

;;;_: Run unit tests:
(defun allout-widgets-run-unit-tests ()
  (message "Running allout-widget tests...")

  (allout-test-range-overlaps)

  (message "Running allout-widget tests...  Done.")
  (sit-for .5))

(when allout-widgets-run-unit-tests-on-load
  (allout-widgets-run-unit-tests))

;;;_. provide
(provide 'allout-widgets)

;;;_. Local emacs vars.
;;;_ , Local variables:
;;;_ , allout-layout: (-1 : 0)
;;;_ , allout-widgets-mode-inhibit: t
;;;_ , End:

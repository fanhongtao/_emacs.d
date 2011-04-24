;; allout-item-settings.el --- Allout outline item identity and congruence

;; Copyright (C) 2005, 2006, 2007 Ken Manheimer

;; Author: Ken Manheimer <ken dot manheimer at gmail dot com>
;; Maintainer: Ken Manheimer <ken dot manheimer at gmail dot com>
;; Created: Feb 2007
;; Version: $Id: allout-item-settings.el,v 1.3 2007/09/13 16:52:16 klm Exp $||
;; Keywords: outlines

;;; Commentary:

;; FOR THE CURIOUS, the below code is in transition.  i think the following
;; commentary may be current, but some (most?) of the code may not be.

;; This component of the allout outliner's widget extensions provides for
;; explicit item identity and congruence between related items, like
;; identical and derivative copies, complementary topical instances in
;; different contexts, and so on.
;;
;; Settings are encoded in items as specially formatted adjacent lines at
;; the ends of item bodies.  The lines are of two types, signified by their
;; prefix:
;;
;; Assignment: \=name value...
;; Continuation: \= value...
;;
;; A Void is a special case of an Assignment:
;;
;; Void: \=name.
;;
;; Assignments denote association of name with "value..." in the item's
;; context.  The value is taken as any characters after the first trailing
;; whitespace character to the end of line.  Assignment values are
;; supplemented with the values of any immediately subsequent continuation
;; lines, accumulated with intervening newlines before each continuation
;; value.
;;
;; A void is a name followed immediately by a "." dot and only whitespace
;; characters (or no characters at all) before the end of line.  Voids
;; undefine the name in that context.
;;
;; Setting assignments are inherited by contained items.  This provides
;; nested spheres of context, where an item has a set of attributes
;; acquired according to the location in which it's visited.

;;;_: General Environment
; no (require ...)s so far.

;;;_. provide
(provide 'allout-item-settings)

;;;_: USER CUSTOMIZATION VARIABLES:
;;;_ > defgroup allout-settings
(defgroup allout-settings nil
  "Allout outline mode extension providing interrelated item metadata."
  :group 'allout)
;;;_ = allout-settings-exposure-toggle-key
(defcustom allout-settings-exposure-toggle-key "_"
  "Key character for command that toggles visibility of item settings.

The character is prefixed with `allout-command-prefix' to create
the local binding."
  :type 'string
  :group 'allout-settings)
;;;_: Mode context - variables, hookup, and hooks
;;;_ , internal mode variables
;;;_  = allout-settings-prefix-regexp
(defvar allout-settings-prefix-regexp "\\\\="
  "Regular expression to match prefix at beginning of an item settings line.

\(The beginning of line '^' carat is added during allout widgets activation.\)

This includes both initial and continuation lines.

When `allout-use-mode-specific-leader' is non-nil and comment-start is
non-empty, the local version of the settings prefix is preceded by the
language's comment-start character.

This value is not intended to to be changed except by allout code.")
;;;_  = allout-settings-continuation-regexp
(defvar allout-settings-continuation-appendage " "
  "Regular expression appended to `allout-settings-prefix-regexp' for
continuation lines.

This value is not intended to to be changed except by allout code.")
;;;_  = allout-widgets-settings-sanitization-regexp
(defvar allout-widgets-settings-sanitization-regexp nil
  "Regular expression used to strip settings from body text.

Configured by `allout-mode-widgets-init'.")
;;;_  = allout-widgets-escapes-sanitization-regexp
(defvar allout-widgets-escapes-sanitization-regexp nil
  "Regular expression used to strip escapes from body text.

Configured by `allout-mode-widgets-init'.")

;;;_: Settings
;;;_ , XXX - implement elaborations
;;;_  . (nil id) boundary marker
;;;_  . think about fall-though:
;;;_   , where do settings that aren't yet established land?
;;;_   , probably in the item
;;;_   , but maybe some cases we need option to escalate
;;;_   , and conversely, some settings need to become localized
;;;_ * Design [see did / Doing / On-deck ...]
;;;_  . In abstract:
;;;_   , Each item has key-value associations connected with it.
;;;_   , An item's settings effectively include those of its ancestors
;;;_   , The item's specific settings override those of its parents, etc.
;;;_   , ... including voids, which inhibit settings for the voided name
;;;_   , The settings are externalized as '\=' bulleted symbol/value subitems
;;;_    . but suppressed in old outline-mode outlines
;;;_  . Use cases:
;;;_   , unique identity
;;;_   , congruence
;;;_    . topic identity - in terms of this and/or other items
;;;_    . synchronization
;;;_    . editability phase
;;;_     , open
;;;_     , settled
;;;_     , final
;;;_   , exposure state
;;;_    . offspring expansion - expanded/collapsed
;;;_    . body brevity - brief/full
;;;_   , access metadata
;;;_    . ownership
;;;_    . access availability
;;;_     , read, write, modify rights
;;;_    . modification history
;;;_     ( not multiple history values, versions may eventually cover that)
;;;_     , created time
;;;_     , created by
;;;_     , last modified time
;;;_     , last modified by
;;;_     , modified from
;;;_     , modifications in
;;;_   , arbitrary (user-extended) metadata
;;;_    . categorical qualifications (see below)
;;;_  ? how do settings facilitate categorical qualifications?
;;;_   , eg:
;;;_    . topics
;;;_    . projects
;;;_    . classifications
;;;_   , use cases:
;;;_    . menu entries
;;;_    . navigation
;;;_    . characterization
;;;_  . Implementation:
;;;_   , association list for conslidated settings of item and ancestors
;;;_    . a node's settings is an alist of (name . value) pairs
;;;_     , '((nil . <nodeid>) (node1 . value1) ... <parent-settings>)
;;;_     , the parent's settings are the tail of the child's
;;;_     , the '(nil . <nodeid>) pair marks the start of each node's settings
;;;_     , some likely common use cases:
;;;_      . given the child settings are in the variable 'subj'
;;;_      . get setting pair for name: (assq name subj)
;;;_      . get unidentified parent settings from child's 'subj' settings:
;;;_       , (memq (assq nil (cddr (memq (assq nil subj) subj))) subj)
;;;_      . get identified ancestor settings from child's 'subj' settings:
;;;_       , (member (cons nil <identifier>) subj)
;;;_    . adding a setting pushes the pair after the node marker
;;;_    . relocating a child reconstructs the consolidated list
;;;_     , copying the local settings,
;;;_     , prepended with the node marker,
;;;_     , and appended with the new parent's settings
;;;_    . with hash tables (from make-hash-table), parent's table is
;;;       privileged entry in child, and looped lookup occurs
;;;_   , association list for local settings, sharing pairs from consolidated
;;;_    . ((name1 . (name1 . value1) ...))
;;;_    . so surgical adjustment of the pair's cdr changes consolidated, too
;;;_   , allout-parse-item-at-point depends on settings trailing other subitems
;;;_ > allout-create-item-settings (item &optional initial parent)
;;; X
(defun allout-create-item-settings (item &optional initial parent)
  "Create a new settings record.

If optional INITIAL is provided, we use the list of alternating name /
value associations.

If optional PARENT is provided, the parent settings are obtained from it
rather than querying the item for its parent."
  (let ((parent (or parent (widget-apply item :get-parent)))
        sansdups
        name value
        tokens)
    (while initial
      (setq name (car initial) value (cadr initial))
      ;; Skip repeats:
      (when (not (memq name tokens))
        (push name tokens)
        (push name sansdups) (push value sansdups))
      (pop initial)(pop initial))
    (widget-put item :settings
                (nconc (nreverse sansdups) (widget-get parent :settings)))
    (widget-put item :local-settings tokens)))
;;;_ } allout-adjust-item-setting (item name value)
;;; X
(defun allout-adjust-item-setting (item name value)
  "In ITEM, change or add a setting for NAME to VALUE."
  ;; XXX not yet converted to delimited settings
  (let ((settings (widget-get item :settings))
        (local-settings (widget-get item :local-settings)))
    (if (memq name local-settings)
        (setcdr (assq name settings) (list value))
      (push value settings)
      (push name settings))))
;;;_ > allout-get-item-setting (settings name &optional default)
;;; X
(defun allout-get-item-setting (item name &optional default)
  "Get ITEM setting for NAME.

Optional DEFAULT provides the value to return if NAME has no setting.

If no DEFAULT is provided and NAME has no setting, nil is returned."
  ;; XXX not yet converted to delimited settings - but may require no changes
  (let ((got (assq name (widget-get item :settings))))
    (if got (cadr got) default)))
;;;_ > allout-connect-parent-item-settings (item &optional parent-settings)
;;; X
(defun allout-connect-parent-item-settings (item &optional parent-settings)
  "Connect the settings for ITEM with those of its parent.

Optional PARENT-SETTINGS is used if provided.  Otherwise, the parent is
sought by navigation and the settings are fetched from it."
  ;; XXX not yet converted to delimited settings
  (widget-put item :settings
              (nconc (widget-get item :settings)
                     (widget-get (or parent-settings
                                     (widget-get (widget-apply item
                                                               :get-parent)
                                                 :settings))
                                 :settings))))
;;;_ > allout-disconnect-parent-item-settings (item &optional parent)
;;; X
(defun allout-disconnect-parent-item-settings (item &optional parent)
  "Disconnect the settings for ITEM from those of its parent.

The item gets a copy of the local settings, rather than doing surgery on
them.  This is necessary in case this item is a copy of another, so that
the original is insulated from the settings changes.

Optional PARENT argument identifies the parent to use, for symmetry with
-connect-parent-settings."
  (let* ((old-settings (widget-get item :settings))
         (parent-settings (widget-get (or parent (widget-apply item
                                                               :get-parent))
                                      :settings))
         new-settings)
    (while (not (eq old-settings parent-settings))
      (push (car old-settings) new-settings)
      (push (cadr old-settings) new-settings)
      (setq old-settings (cdr (cdr old-settings)))
      (if (not old-settings)
          (error "Child settings do not include those of %s parent."
                 (if parent "indicated" "actual"))))
    (widget-put item :settings (nreverse new-settings))))

;;;_ > allout-toggle-settings-exposure ()
(defun allout-toggle-settings-exposure ()
  "Reveal or conceal settings of expanded items."
  (interactive)
  (if (member 'allout-settings buffer-invisibility-spec)
      (remove-from-invisibility-spec 'allout-settings)
    (add-to-invisibility-spec 'allout-settings)))

;;;_. Local emacs vars.
;;;_ , Local variables:
;;;_ , allout-layout: (-1 : 0)
;;;_ , allout-widgets-mode-inhibit: t
;;;_ , End:

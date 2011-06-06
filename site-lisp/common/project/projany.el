;;;_ projany.el --- Project Collection, a unified interface to emacs project managers

;;;_. Headers
;;;_ , License
;; Copyright (C) 2010  Tom Breton (Tehom)

;; Author: Tom Breton (Tehom) <tehom@panix.com>
;; Keywords: maint, tools, lisp

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.
;;;_ , Version 0.3
;;;_ , Commentary:

;;The purpose of this package is to provide a unified interface to the
;;half a dozen emacs project manager libraries out there.  It
;;abstracts over project managers.  It is intended to give libraries a
;;way of knowing about projects without committing to any particular
;;project manager.

;;This is alpha software.  Right now all it provides is
;;`projany-pick', which picks a file of some given type from a
;;project.

;; To use a project manager with projany, first call `projany-setup'
;; to set up.  Only the first three arguments are strictly required.
;;

;; Concepts:
;; * Backend project manager.  A project manager such as project-root,
;;   eproject, EDE, or pgrok.
;; * Project object.  This is a "cookie", an object that the backend
;;   understands.  projany does not try to understand project objects.
;; * Resource.  Something a project manager tries to control, such as
;;   the name of a source file.

;;;_ , Requires

(eval-when-compile
   (require 'cl))

;;;_. Body
;;;_ , Variables / Type
(defvar projany-default-project-key nil 
   "A function returning a key to the default project or `nil'" ) 
(defvar projany-project-keys nil 
   "A function that returns a collection of project names, suitable
   for `completing-read'.  

Takes one arg, a symbol indicating what type of project to return.
   There are no canonical meanings for these symbols yet, except `nil'
   means no filtering (return all projects).

If this returns an alist of (name . project), the default can be
   used for `projany-name->project'." )
(defvar projany-name->project nil 
   "A function that:
 * takes a project name
 * takes a collection of projects
 * returns a project object (as understood by the backend)." )
(defvar projany-resource-keys nil 
   "A function that:
 * takes a project object 
 * takes a symbol
 * returns a collection of project resources (usually filenames)

If this returns an alist of (name . project), the default can be
   used for `projany-name->project'." )
(defvar projany-name->resource nil 
   "A function that:
 * takes the local name of a resource (As given by `projany-resource-keys')
 * takes a collection of resources
 * returns a resource object" )
(defvar projany-resource->filename nil 
   "A function that:
 * takes a resource object (As given by `projany-name->resource')
 * (May take other arguments later)
 * returns a filename" )
(defvar projany-get-history-sym nil 
   "A function that:
 * takes a project object
 * takes a symbol
 * returns the symbol of a history list" )
(defvar projany-edit-project nil 
   "A function that edits a given project.
Unused for now." )
;;;_ , projany
;;;_  . projany-setup
(defun* projany-setup 
   (get-project-keys get-resource-keys &key
      name->project name->resource resource->filename
      default-project-key get-history-sym edit-project)
   "Set up projany for a backend.

Each argument must be a function.  For the proper behavior of an
argument FOO, see the respective projany-FOO variable's
docstring."

   (check-type get-project-keys  function)
   (check-type get-resource-keys function)
   (check-type default-project-key (or function null))
   (check-type get-history-sym (or function null))
   (check-type edit-project    (or function null))
   (check-type name->project   (or function null))
   (check-type name->resource  (or function null))

   (setq projany-project-keys get-project-keys)
   (setq projany-resource-keys get-resource-keys)
   (setq projany-name->project 
      (or
	 name->project
	 #'projany-cdr-assoc))
   (setq projany-name->resource 
      (or
	 name->resource
	 #'projany-cdr-assoc))
   (setq projany-resource->filename resource->filename)
   (setq projany-default-project-key default-project-key) 
   (setq projany-get-history-sym get-history-sym)
   (setq projany-edit-project edit-project))

;;;_  . projany-pick Pick a file from a project
(defvar projany-pick-history () 
   "History list of projects.  Project resource types can have their
   own history lists" )
;;;###autoload
(defun projany-pick (type prompt &optional proj-type)
   "Pick a file (or other resource) from a project.

TYPE should be a symbol indicating the type of file

PROMPT is a prompt string.

Optional arg PROJ-TYPE is a symbol that names the type of
project.  It is only useful if the project manager differentiates
project types.

See the projany source for how to configure this for a project manager."
   (unless (and 
	      projany-project-keys 
	      projany-name->project 
	      projany-resource-keys
	      projany-name->resource)
      (error "Projany does not appear to be configured."))
   
   (let*
      (  (def-proj
	    (if projany-default-project-key
	       (funcall projany-default-project-key)))
	 (collection
	    (funcall projany-project-keys proj-type))
	 (proj-name
	    (completing-read "Project: " collection nil t nil
	       'projany-pick-history def-proj))
	 (proj-obj
	    (funcall projany-name->project proj-name collection))
	 (hist-sym
	    (if projany-get-history-sym
	       (funcall
		  projany-get-history-sym proj-obj
		  'org-remember-file-targets)))
	 (resource-keys
	    (funcall projany-resource-keys
	       proj-obj
	       'org-remember-file-targets))
	 (resource-name
	    (completing-read prompt resource-keys nil t nil
	       hist-sym))
	 (resource
	    (funcall projany-name->resource 
	       resource-name resource-keys proj-obj))
	 (filename
	    (if projany-resource->filename
	       (funcall projany-resource->filename resource type)
	       resource)))
      
      filename))

;;;_  . Utilities
;;;_   , projany-cdr-assoc
(defun projany-cdr-assoc (key collection)
   "Retrieve the object from the result of completeing-read"
   (cdr (assoc key collection)))


;;;_. Footers
;;;_ , Provides

(provide 'projany)

;;;_ * Local emacs vars.
;;;_  + Local variables:
;;;_  + mode: allout
;;;_  + End:

;;;_ , End
;;; projany.el ends here

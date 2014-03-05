;;; psgml-superedit --- additional editing functions for PSGML

;; Copyright (C) 2012 Andreas Nolda

;; Author: Andreas Nolda <nolda.andreas@googlemail.com>
;; Version: 1.4

;; This program is free software; you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the Free Software
;; Foundation; either version 2, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
;; FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
;; details.
;;
;; You should have received a copy of the GNU General Public License along with
;; this program; if not, you can either send email to this program's maintainer
;; or write to: The Free Software Foundation, Inc.; 675 Massachusetts Avenue;
;; Cambridge, MA 02139, USA.


;;; Commentary:

;; This file defines additional editing functions for use with PSGML. For the
;; most part, they generalise more basic editing functions in dwim ('do what I
;; mean') style.
;;
;; Installation and proposed settings:
;;
;; (add-hook 'sgml-mode-hook
;;           (lambda ()
;;             (require 'psgml-superedit)
;;             (define-key sgml-mode-map (kbd "C-c C-e") 'sgml-insert-element-dwim)
;;             (define-key sgml-mode-map (kbd "C-c RET") 'sgml-split-element-dwim)
;;             (define-key sgml-mode-map (kbd "C-c DEL") 'sgml-untag-element) ; freeing C-c -
;;             (define-key sgml-mode-map (kbd "C-c -") 'sgml-delete-attribute)
;;             (define-key sgml-mode-map (kbd "C-c ?") 'sgml-insert-pi)
;;             (define-key sgml-mode-map (kbd "M-;") 'sgml-comment-dwim)
;;             (define-key sgml-mode-map (kbd "C-M-f") 'sgml-forward-dwim)
;;             (define-key sgml-mode-map (kbd "<C-M-right>") 'sgml-forward-dwim)
;;             (define-key sgml-mode-map (kbd "C-M-b") 'sgml-backward-dwim)
;;             (define-key sgml-mode-map (kbd "<C-M-left>") 'sgml-backward-dwim)
;;             (define-key sgml-mode-map (kbd "C-M-d") 'sgml-down-dwim)
;;             (define-key sgml-mode-map (kbd "<C-M-down>") 'sgml-down-dwim)
;;             (define-key sgml-mode-map (kbd "<C-M-next>") 'sgml-forward-up-dwim)
;;             (define-key sgml-mode-map (kbd "C-M-u") 'sgml-backward-up-dwim)
;;             (define-key sgml-mode-map (kbd "<C-M-up>") 'sgml-backward-up-dwim)
;;             (define-key sgml-mode-map (kbd "<C-M-prior>") 'sgml-backward-up-dwim)
;;             (define-key sgml-mode-map (kbd "C-M-SPC") 'sgml-mark-dwim) ; caveat: psgml-other binds C-M-SPC, too
;;             (define-key sgml-mode-map (kbd "C-M-k") 'sgml-kill-dwim)
;;             (define-key sgml-mode-map (kbd "<C-M-delete>") 'sgml-kill-dwim)
;;             (define-key sgml-mode-map (kbd "<C-M-backspace>") 'sgml-kill-backward-dwim)))
;;
;; (setq sgml-show-context-function 'sgml-show-context-xpath)

;; This file is *NOT* part of PSGML.


;;; Code:

(require 'psgml-edit)


;; Generalised element insertion and splitting:

(defun sgml-insert-element-or-tag-region (el)
  "Insert element, tagging region if appropriate."
  (interactive (list (save-excursion
                       (sgml-read-element-name "Element: "))))
  (if mark-active
      (progn (sgml-tag-region el (region-beginning) (region-end))
             (deactivate-mark)
             (sgml-down-element))
    (sgml-insert-element el)))

(defun sgml-insert-empty-element (el)
  "Insert an empty element, even if it is not defined as such."
  (interactive (list (sgml-read-element-name "Element: ")))
  (let (element)
    (when (and el (not (equal el "")))
      (sgml-insert-tag (sgml-start-tag-of el) 'silent)
      (if (sgml-check-empty el)
	  (forward-char -2)
	(forward-char -1))
      (setq element (sgml-find-element-of (point)))
      (sgml-insert-attributes (funcall sgml-new-attribute-list-function
				       element)
			      (sgml-element-attlist element))
      (if (sgml-check-empty el)
	  (forward-char 2)
        (insert "/")
	(forward-char 1)))))

(defun sgml-insert-element-dwim (el &optional empty)
  "Insert element, tagging region if appropriate. With non-nil prefix argument,
insert an empty element, even if it is not defined as such."
  (interactive (list (save-excursion
                       (sgml-read-element-name "Element: "))
                     current-prefix-arg))
  (if empty
      (sgml-insert-empty-element el)
    (sgml-insert-element-or-tag-region el)))

(defun sgml-split-element-dwim (&optional no-att)
  "Split the current element at point. With non-nil prefix argument, don't copy
attributes."
  (interactive "*P")
  (let ((el (sgml-last-element)))
    (when (or (and (> (point) (sgml-element-start el))
                   (< (point) (sgml-element-stag-end el)))
              (> (point) (sgml-element-etag-start el)))
      (error "Point is inside markup"))
    (sgml-insert-end-tag)
    (sgml-insert-tag (sgml-start-tag-of el) 'silent)
    (unless no-att
        (skip-chars-backward ">")
        (sgml-insert-attributes (sgml-element-attribute-specification-list el)
                                (sgml-element-attlist el))
        (skip-chars-forward ">"))))


;; Attribute deletion:

(defun sgml-delete-attribute (name)
  "Delete an attribute."
  (interactive
      (let* ((el (sgml-find-attribute-element))
             (old-asl (sgml-element-attribute-specification-list el))
             (name (completing-read "Attribute name: " old-asl))
             (asl (remove (assoc name old-asl) old-asl))
             (in-tag (< (point) (sgml-element-stag-end el))))
        (sgml-change-start-tag el asl)
        (when in-tag (forward-char -1)))))


;; Processing instruction insertion:

(defun sgml-insert-pi (pi)
  "Insert a processing instruction."
  (interactive "*sProcessing instruction: ")
  (insert "<?" pi "?>"))


;; Generalised commenting:

(defun sgml-comment-dwim ()
  "Comment or uncomment the region or insert a new comment at point."
  (interactive "*")
  (if mark-active
      (progn (if (< (mark) (point))
                 (exchange-point-and-mark))
             (if (looking-at "<!--")
                 (uncomment-region (region-beginning) (region-end))
               (let ((beg (region-beginning))
                     (end (region-end)))
                 (save-excursion
                   (goto-char end)
                   (insert comment-end))
                 (goto-char beg)
                 (insert comment-start))))
    (save-excursion
      (insert comment-end))
    (insert comment-start)))


;; Generalised movement:

(defmacro sgml-with-syntax-table (body)
  `(let ((sgml-markup-syntax
          (if sgml-xml-p
              (copy-syntax-table xml-parser-syntax)
            (copy-syntax-table sgml-parser-syntax))))
     (modify-syntax-entry ?\" "\"" sgml-markup-syntax)
     (modify-syntax-entry ?' "\"" sgml-markup-syntax)
     (with-syntax-table
         sgml-markup-syntax
       ,body)))

(defun sgml-forward-tag ()
  "Move forward in a tag."
  (interactive)
  (unless (looking-at "\"?[/?]?>")
    (sgml-with-syntax-table (forward-sexp))))

(defun sgml-forward-pi ()
  "Move forward over a processing instruction."
  (interactive)
  (if (looking-back "\\?")
      (skip-chars-backward "?"))
  (search-forward "?>"))

(defun sgml-forward-comment ()
  "Move forward over a comment."
  (interactive)
  (if (looking-back "-+")
      (skip-chars-backward "-"))
  (search-forward "-->"))

(defun sgml-forward-dwim ()
  "Move forward over markup."
  (interactive)
  (sgml-parse-to-here)
  (if sgml-markup-type
      (cond ((eq sgml-markup-type 'start-tag)
             (sgml-forward-tag))
            ((eq sgml-markup-type 'end-tag)
             (sgml-forward-tag))
            ((eq sgml-markup-type 'pi)
             (sgml-forward-tag)))
    (let ((next-type
           (save-excursion
             (skip-chars-forward "^<")
             (skip-chars-forward "<")
             (sgml-parse-to-here)
             sgml-markup-type)))
      (cond ((eq next-type 'start-tag)
             (sgml-forward-element))
            ((eq next-type 'pi)
             (sgml-forward-pi))
            ((eq next-type 'comment)
             (sgml-forward-comment))))))

(defun sgml-backward-tag ()
  "Move backward in a tag."
  (interactive)
  (unless (looking-back "<[/?]?")
    (sgml-with-syntax-table (backward-sexp))))

(defun sgml-backward-pi ()
  "Move backward over a processing instruction."
  (interactive)
  (if (looking-at "\\?")
      (skip-chars-forward "?"))
  (search-backward "<?"))

(defun sgml-backward-comment ()
  "Move backward over a comment."
  (interactive)
  (if (looking-at "!?-+")
      (skip-chars-forward "!-"))
  (search-backward "<!--"))

(defun sgml-backward-dwim ()
  "Move backward over markup."
  (interactive)
  (sgml-parse-to-here)
  (if sgml-markup-type
      (cond ((eq sgml-markup-type 'start-tag)
             (sgml-backward-tag))
            ((eq sgml-markup-type 'end-tag)
             (sgml-backward-tag))
            ((eq sgml-markup-type 'pi)
             (sgml-backward-tag)))
    (let ((previous-type
           (save-excursion
             (skip-chars-backward "^>")
             (skip-chars-backward ">")
             (sgml-parse-to-here)
             sgml-markup-type)))
      (cond ((eq previous-type 'start-tag) ; in particular, empty tags
             (sgml-backward-element))
            ((eq previous-type 'end-tag)
             (sgml-backward-element))
            ((eq previous-type 'pi)
             (sgml-backward-pi))
            ((eq previous-type 'comment)
             (sgml-backward-comment))))))

(defun sgml-down-current-element ()
  "Move down into the current element."
  (interactive)
  (search-forward ">"))

(defun sgml-down-dwim ()
  "Move down into markup."
  (interactive)
  (sgml-parse-to-here)
  (if (eq sgml-markup-type 'start-tag)
      (sgml-down-current-element)
    (sgml-down-element)))

(defun sgml-forward-up-pi ()
  "Move forward up out of a processing instruction."
  (interactive)
  (skip-chars-backward "?")
  (search-forward "?>"))

(defun sgml-forward-up-comment ()
  "Move forward up out of a comment."
  (interactive)
  (skip-chars-backward "-")
  (search-forward "-->"))

(defun sgml-forward-up-dwim ()
  "Move forward up out of markup."
  (interactive)
  (sgml-parse-to-here)
  (cond ((eq sgml-markup-type 'pi)
         (sgml-forward-up-pi))
        ((eq sgml-markup-type 'comment)
         (sgml-forward-up-comment))
        (t
         (sgml-up-element))))

(defun sgml-backward-up-pi ()
  "Move backward up out of a processing instruction."
  (interactive)
  (skip-chars-forward "?")
  (search-backward "<?"))

(defun sgml-backward-up-comment ()
  "Move backward up out of a comment."
  (interactive)
  (skip-chars-forward "!-")
  (search-backward "<!--"))

(defun sgml-backward-up-dwim ()
  "Move backward up out of markup."
  (interactive)
  (sgml-parse-to-here)
  (cond ((eq sgml-markup-type 'pi)
         (sgml-backward-up-pi))
        ((eq sgml-markup-type 'comment)
         (sgml-backward-up-comment))
        (t
         (sgml-backward-up-element))))


;; Generalised marking and killing:

(defun sgml-mark-current-element-content ()
  "Mark content of current element."
  (interactive)
  (let ((el (sgml-last-element)))
    (goto-char (sgml-element-stag-end el))
    (push-mark (sgml-element-etag-start el) nil t)))

(defun sgml-mark-pi ()
  "Mark processing instruction."
  (interactive)
  (unless (looking-at "\\s-*<\\?")
    (sgml-backward-up-pi))
  (push-mark (save-excursion
               (sgml-forward-pi)) nil t))

(defun sgml-mark-comment ()
  "Mark comment."
  (interactive)
  (unless (looking-at "\\s-*<!--")
    (sgml-backward-up-comment))
  (push-mark (save-excursion
               (sgml-forward-comment)) nil t))

(defun sgml-mark-dwim (&optional content)
  "Mark markup or content. With non-nil prefix argument, mark content
unconditionally."
  (interactive "P")
  (sgml-parse-to-here)
  (if sgml-markup-type
      (sgml-with-syntax-table (mark-sexp))
    (let ((next-type
           (save-excursion
             (skip-syntax-forward "-")
             (skip-chars-forward "<")
             (sgml-parse-to-here)
             sgml-markup-type)))
      (cond (content
             (sgml-mark-current-element-content))
            ((eq next-type 'start-tag)
             (sgml-mark-element))
            ((eq next-type 'pi)
             (sgml-mark-pi))
            ((eq next-type 'comment)
             (sgml-mark-comment))
            (t
             (sgml-mark-current-element-content))))))

(defun sgml-kill-dwim ()
  "Kill markup or content."
  (interactive "*")
  (sgml-mark-dwim)
  (kill-region (point) (mark)))

(defun sgml-kill-backward-dwim ()
  "Kill backward markup or content."
  (interactive "*")
  (sgml-backward-dwim)
  (sgml-kill-dwim))


;; Context display:

(defun sgml-show-context-xpath (el &optional markup-type)
  "Show the context in XPath style."
  (let ((gis nil))
    (while (not (sgml-off-top-p el))
      (push (sgml-element-gi el) gis)
      (setq el (sgml-element-parent el)))
    (concat "/"
            (mapconcat #'sgml-general-insert-case gis "/"))))


;; Provide:

(provide 'psgml-superedit)


;;; psgml-superedit ends here
